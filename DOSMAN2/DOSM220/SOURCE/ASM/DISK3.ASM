
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                D I S K 3
;                     nulov†n° disku, ru®en°, kop°rov†n°, porovn†n°
;
; =============================================================================
;
; Ve©ejnÇ procedury:
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeDisk SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeDisk,ds:Data

; *****************************************************************************
;
;                            Nulov†n° disku
;
; *****************************************************************************
;˛
NulDisk  PROC      FAR

         mov       dl,ds:[NulDPar]          ; parametry
         mov       dh,0
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         mov       al,ds:[NulDBajt]         ; nulovac° bajt
         mov       ah,0                     ; nen° barva
         push      ds
         pop       es
         mov       di,offset NulDMPl1
         call      far ptr DekHByte         ; dek¢dov†n° bajtu

         mov       ax,word ptr ds:[DMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,0507h                 ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax ; pozice okna

         jmp       far ptr VertMenu         ; obsluha menu volby parametrñ

NulDisk  ENDP

; ------ zad†n° bajtu k nulov†n°

NulDsk1  PROC      FAR

         push      si

         push      ds
         pop       es
         mov       dx,word ptr ds:[si+MnuPoz] ; pozice menu
         add       dx,1*HI+16               ; pozice poloëky bajtu
         mov       si,offset NulDMHl1       ; n†povàda
         mov       di,offset NulDMPl1       ; buffer k uloëen° á°sla
         call      far ptr MenBHex          ; zad†n° novÇ hodnoty á°sla
         mov       ds:[NulDBajt],al         ; nov† hodnota bajtu

         pop       si
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

NulDsk1  ENDP

; ------ p©ep°naá - adres†©e

NulDsk2  PROC      FAR

         xor       dl,bit0                  ; p©°znak adres†©ñ

NulDsk20:test      dl,bit0+bit1             ; je alespo§ nàco zad†no ?
         jnz       NulDsk21                 ; je nàco zad†no
         or        dl,bit2                  ; alespo§ volnÇ bloky
NulDsk21:mov       ds:[NulDPar],dl          ; novÇ nastaven° parametrñ
         call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

NulDsk2  ENDP

; ------ p©ep°naá - soubory

NulDsk24:xor       dl,bit1                  ; p©°znak souborñ
         jmp       short NulDsk20           ; nastaven° p©ep°naáñ

; ------ p©ep°naá - bloky

NulDsk3: xor       dl,bit2                  ; p©°znak volnòch blokñ
         test      dl,bit2+bit1             ; zñstalo nàco zapnuto ?
         jnz       NulDsk21                 ; zñstalo nàco zapnuto OK
         or        dl,bit0                  ; zapnout alespo§ adres†©e
         jmp       short NulDsk21           ; nastaven° p©ep°naáñ

; -----------------------------------------------------------------------------
;        nulov†n° disku
; -----------------------------------------------------------------------------

NulDsk4: add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu

; ------ vytvo©en° pracovn°ho bufferu

         call      far ptr CreatSeg         ; vytvo©en° segmentu
         jc        NulDsk47                 ; chyba pamàti
         mov       ds:[NulDSeg],ax          ; segment bufferu

; ------ vymaz†n° a zobrazen° pr†zdnÇho informaán°ho ©†dku

         call      far ptr InfoClr          ; vymaz†n° informaán°ho ©†dku
         call      far ptr InfoDisp         ; zobrazen° informaán°ho ©†dku

; ------ inicializace parametrñ disku

         call      far ptr InitLDsk         ; inicializace parametrñ log. disku
         jc        NulDsk48                 ; chyba

; ------ p©°prava á°taáe zpracovanòch blokñ na disku

         mov       al,ds:[DskLDisk]         ; á°slo disku
         call      far ptr GetDInfo         ; poskytnut° informac° o disku
         mov       word ptr ds:[InfoKMax],bx ; poáet volnòch blokñ LOW
         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[InfoKMax+2],ax
         mov       word ptr ds:[InfoKCit],ax ; á°taá zpracovanÇ kapacity
         mov       word ptr ds:[InfoKCit+2],ax

; ------ otev©en° bufferu FAT

         call      far ptr OpenLFat         ; otev©en° bufferu tabulky FAT
         jc        NulDsk48                 ; chyba pamàti
         call      far ptr ResDisk          ; resetov†n° diskovÇho systÇmu

; ------ otev©en° bufferu adres†©e

         call      far ptr OpenLDir         ; otev©en° bufferu adres†©e
         jc        NulDsk48                 ; chyba pamàti

; ------ nastaven° velikosti bufferu

         mov       ax,ds:[NulDSeg]          ; segment bufferu
         mov       bx,ds:[DskLBBlk]         ; poáet bajtñ na alokaán° blok
         call      far ptr ModiSegS         ; nastaven° velikosti bufferu
         jnc       NulDsk49                 ; operace OK

NulDsk47:call      far ptr MemErr           ; chyba pamàti
NulDsk48:jmp       short NulDsk8            ; nedostatek pamàti

; ------ adresa bufferu

NulDsk49:call      far ptr GetSgAdr
         mov       ds:[NulDBuf],dx          ; adresa bufferu

; ------ nulov†n° adres†©ñ

         test      byte ptr ds:[NulDPar],bit0 ; nuluj° se adres†©e ?
         jz        NulDsk5                  ; adres†©e se nenuluj°
         call      NulDAdr                  ; nulov†n° adres†©ñ
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        NulDsk8                  ; p©eru®en° operace

; ------ nulov†n° volnÇho m°sta za soubory

NulDsk5: test      byte ptr ds:[NulDPar],bit1 ; nuluj° se soubory ?
         jz        NulDsk6                  ; soubory se nenuluj°
         call      NulDSou                  ; nulov†n° souborñ
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        NulDsk8                  ; p©eru®en° operace

; ------ nulov†n° alokaán°ch blokñ

NulDsk6: test      byte ptr ds:[NulDPar],bit2 ; nuluj° se bloky ?
         jz        NulDsk8                  ; bloky se nenuluj°
         call      NulDBlk                  ; nulov†n° alokaán°ch blokñ

; ------ vypr†zdnàn° bufferu kl†vesnice

NulDsk8: call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         call      far ptr ResDisk          ; resetov†n° diskovÇho systÇmu

; ------ uzav©en° reëimu

         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      far ptr ClosLFat         ; uzav©en° bufferu s FAT tabulkou
         call      far ptr ClosLDir         ; uzav©en° bufferu adres†©e
         mov       ax,ds:[NulDSeg]          ; segment bufferu
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[NulDSeg],ax
         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        nulov†n° volnòch poloëek adres†©e
; -----------------------------------------------------------------------------

NulDAdr  PROC      NEAR

; ------ inicialiace ukazatelñ na adres†© ROOT

         call      far ptr IniLDir          ; inicializace ukazatelñ adres†©e

; ------ zobrazen° hl†®en°

         xor       bx,bx                    ; p©°prava alokaán°ho bloku = ROOT
NulDAdr1:mov       di,offset NulDTxt1       ; hl†®en°
         call      far ptr InfLDir          ; zobrazen° hl†®en°
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr KurzOff          ; vypnut° kurzoru

; ------ naáten° jednÇ poloëky adres†©e

         xor       di,di                    ; offset ukl†dac° adresy do bufferu
         xor       cx,cx                    ; á°taá zapsanòch sektorñ v bloku
         mov       dx,bx                    ; DX <- minulò blok
NulDAdr2:call      far ptr NextLDir         ; nalezen° dal®° poloëky adres†©e
         jc        NulDAdr3                 ; nen° dal®° poloëka adres†©e
         cmp       byte ptr es:[si],0       ; je konec adres†©e ?
         je        NulDAdr3                 ; je konec adres†©e
         cmp       byte ptr es:[si],0e5h    ; je to zru®en† poloëka ?
         je        NulDAdr2                 ; je to zru®en† poloëka - dal®°

; ------ uloëen° poloëky do vòstupn°ho bufferu

         push      cx
         push      ds

         push      es
         mov       es,ds:[NulDBuf]          ; adresa bufferu
         pop       ds                       ; DS <- segment adresy poloëky
         cld
         mov       cx,32/2                  ; dÇlka jednÇ poloëky
         rep       movsw                    ; uloëen° jednÇ poloëky

         pop       ds
         pop       cx

; ------ test, zda je jië konec sektoru

         cmp       di,ds:[DskLBSkt]         ; je konec sektoru ?
         jb        NulDAdr2                 ; nen° je®tà konec sektoru

; ------ uloëen° sektoru adres†©e

         call      NulDWAdr                 ; uloëen° sektoru do adres†©e
         jc        NulDAdr8                 ; konec adres†©e nebo chyba
         jmp       short NulDAdr2           ; dal®° poloëka

; ------ vynulov†n° jednÇ poloëky

NulDAdr3:or        di,di                    ; je zaá†tek sektoru ?
         jz        NulDAdr5                 ; je zaá†tek sektoru
NulDAdr4:push      cx
         xor       ax,ax                    ; nulovac° slovo
         mov       es,ds:[NulDBuf]          ; adresa bufferu
         cld
         mov       cx,32/2                  ; dÇlka jednÇ poloëky
         rep       stosw                    ; uloëen° jednÇ poloëky
         pop       cx

; ------ test, zda je jië konec sektoru

         cmp       di,ds:[DskLBSkt]         ; je konec sektoru ?
         jb        NulDAdr4                 ; nen° je®tà konec sektoru

; ------ uloëen° sektoru adres†©e

         call      NulDWAdr                 ; uloëen° sektoru do adres†©e
         jc        NulDAdr8                 ; je konec adres†©e (nebo chyba)

; ------ adres†© ROOT se nezkracuje

NulDAdr5:or        bx,bx                    ; je adres†© ROOT ?
         jz        NulDAdr4                 ; je adres†© ROOT

; ------ test, zda je zaá†tek dal®°ho bloku

         or        cx,cx                    ; je zaá†tek dal®°ho bloku ?
         jnz       NulDAdr4                 ; nen° zaá†tek dal®°ho bloku

; ------ oznaáen° posledn°ho bloku za koncovò

         xchg      bx,dx                    ; BX <- minulò blok
         mov       ax,-1                    ; oznaáen° - koncovò blok
         call      far ptr SetClust         ; oznaáen° bloku za koncovò
         xchg      bx,dx                    ; BX <- dal®° blok
         cmp       bx,dx                    ; je dal®° blok ?
         je        NulDAdr8                 ; nen° dal®° blok

; ------ nalezen° dal®°ho bloku -> AX

NulDAdr6:call      far ptr GetClust         ; dal®° alokaán° blok
         jc        NulDAdr7                 ; posledn° blok - konec
         jz        NulDAdr8                 ; to je chyba

; ------ oznaáen° bloku za volnò

         xchg      ax,dx                    ; DX <- dal®° blok
         xor       ax,ax                    ; oznaáen° za volnò
         call      far ptr SetClust         ; oznaáen° bloku za volnò
         xchg      bx,dx                    ; BX <- dal®° blok
         jnc       NulDAdr6                 ; nalezen° dal®°ho bloku

; ------ oznaáen° posledn°ho bloku za volnò

NulDAdr7:xor       ax,ax
         call      far ptr SetClust         ; oznaáen° posledn°ho bloku za volnò

; ------ nalezen° dal®°ho podadres†©e

NulDAdr8:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        NulDAdr9                 ; je p©eru®en° operace
         call      far ptr ResLDir          ; resetov†n° adres†©e na zaá†tek
         call      far ptr SrcLDir          ; nalezen° dal®°ho adres†©e -> BX
         jc        NulDAdr9                 ; nen° dal®° adres†©
         jmp       NulDAdr1                 ; nulov†n° dal®°ho adres†©e BX

NulDAdr9:call      far ptr WritFat          ; z†pis tabulky FAT
         ret

NulDAdr  ENDP

; -----------------------------------------------------------------------------
;        uloëen° sektoru z bufferu
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo bloku
;        CX=á°slo sektoru uvnit© bloku
;        ES=segment bufferu
; VùSTUP: BX=novÇ á°slo bloku
;         CX=novÇ á°slo sektoru
;         DX=uschovanÇ á°slo pñvodn°ho bloku
;         DI=0 (nov† ukl†dac° adresa do bufferu)
;         CY=chyba nebo konec adres†©e
; -----------------------------------------------------------------------------

NulDWAdr PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx                       ; £schova á°sla bloku
         push      si

; ------ uloëen° sektoru adres†©e

         call      far ptr ClstSekt         ; vòpoáet á°sla sektoru
         jc        NulDWAd9                 ; nàjak† chyba
         add       ax,cx                    ; p©iáten° sektoru v bloku relativnà
         adc       dx,0                     ; p©enos HIGH
         push      cx
         xor       si,si                    ; offset poá†tku sektoru
         mov       cx,1                     ; zap°®e se 1 sektor
         call      far ptr WritLDsk         ; z†pis sektoru na disk
         pop       cx
         jc        NulDWAd9                 ; chyba

; ------ zvò®en° ukazatele sektorñ v bloku

         xor       di,di                    ; nov† ukl†dac° adresa do bufferu
         inc       cx                       ; zvò®en° á°taáe sektorñ v bloku

; ------ test, zda je konec adres†©e ROOT

         or        bx,bx                    ; je to ROOT ?
         jnz       NulDWAd3                 ; nen° to ROOT
         cmp       cx,ds:[DskLSRot]         ; je to konec ROOT ?
         cmc                                ; CY=konec ROOT
         jmp       short NulDWAd9           ; chyba nebo dal®° adres†©

; ------ test, zda je konec bloku adres†©e

NulDWAd3:cmp       cx,ds:[DskLSBlk]         ; je konec jednoho bloku ?
         jb        NulDWAd8                 ; nen° je®tà konec bloku
         xor       cx,cx                    ; novò á°taá sektorñ v bloku

; ------ nalezen° dal®°ho alokaán°ho bloku

         call      far ptr GetClust         ; dal®° alokaán° blok
         jc        NulDWAd9                 ; chyba nebo konec adres†©e
         stc
         jz        NulDWAd9                 ; neplatnÇ á°slo bloku
         mov       bx,ax                    ; BX <- á°slo novÇho bloku
         dec       ax                       ; á°slo bloku - 1
         cmp       ax,ds:[DskLMBlk]         ; kontrola á°sla bloku
         cmc
         jc        NulDWAd9                 ; neplatnÇ á°slo bloku

NulDWAd8:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

NulDWAd9:pop       si
         pop       dx                       ; á°slo pñvodn°ho bloku
         pop       ax
         ret

NulDWAdr ENDP

; -----------------------------------------------------------------------------
;        nulov†n° poloëek v adres†©i
; -----------------------------------------------------------------------------

NulDSou  PROC      NEAR

; ------ inicialiace ukazatelñ na adres†© ROOT

         call      far ptr IniLDir          ; inicializace ukazatelñ adres†©e

; ------ zobrazen° hl†®en° o nulov†n° souborñ

NulDSou1:mov       di,offset NulDTxt2       ; hl†®en°
         call      far ptr InfLDir          ; zobrazen° hl†®en°
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr KurzOff          ; vypnut° kurzoru

; ------ nalezen° platnÇho souboru v adres†©i

NulDSou2:call      far ptr NextLDir         ; nalezen° poloëky v adres†©i
         jnc       NulDSou4                 ; je dal®° poloëka OK
NulDSou3:jmp       NulDSou8
NulDSou4:cmp       byte ptr es:[si],0       ; je to konec adres†©e ?
         je        NulDSou3                 ; je to konec adres†©e
         cmp       byte ptr es:[si],0e5h    ; je to zru®en† poloëka ?
         je        NulDSou2                 ; je zru®en† poloëka - dal®°
         test      byte ptr es:[si+11],DIR+SYS+HID ; je to platnò soubor ?
         jnz       NulDSou2                 ; nen° to platnò soubor

; ------ parametry nulovanÇho souboru

         mov       cx,es:[si+28]            ; velikost LOW
         mov       dx,es:[si+30]            ; velikost HIGH
         mov       bx,es:[si+26]            ; alokaán° blok souboru
         mov       ax,cx                    ; velikost LOW
         or        ax,dx                    ; je velikost souboru = 0 ?
         jz        NulDSou2                 ; soubor m† velikost = 0

; ------ kontrola platnosti á°sla bloku

NulDSou5:cmp       bx,2                     ; je to platnò blok ?
         jb        NulDSou2                 ; nen° to platnò blok
         cmp       bx,ds:[DskLMBlk]         ; je to platnÇ á°slo bloku ?
         ja        NulDSou2                 ; nen° to platnò blok

; ------ nalezen° posledn°ho alokaán°ho bloku

         call      far ptr GetClust         ; dal®° alokaán° blok
         jc        NulDSou6                 ; konec souboru nebo chyba
         jz        NulDSou2                 ; chyba (blok = 0)
         xchg      ax,bx                    ; BX <- á°slo dal®°ho bloku
         sub       cx,ds:[DskLBBlk]         ; odeáten° velikosti bloku
         sbb       dx,0                     ; p©enos HIGH
         jnc       NulDSou5                 ; dal®° blok
         jmp       short NulDSou2           ; velikost a FAT nesouhlas°

; ------ test, zda velikost souboru a FAT souhlas°

NulDSou6:or        dx,dx                    ; zbòv† v°ce neë 64 KB ?
         jnz       NulDSou2                 ; velikost a FAT nesouhlas°
         sub       cx,ds:[DskLBBlk]         ; - p©ebòvaj°c° data do bloku
         jnc       NulDSou2                 ; velikost+FAT nesouhlas° nebo CX=0
         neg       cx                       ; zbyl† data do velikosti bloku

; ------ stanoven° á°sla sektoru bloku

         call      far ptr ClstSekt         ; vòpoáet á°sla sektoru
         jc        NulDSou7                 ; neplatnÇ á°slo bloku

; ------ naáten° alokaán°ho bloku do bufferu

         push      cx
         mov       es,ds:[NulDBuf]          ; adresa bufferu
         xor       di,di                    ; ukl†dac° adresa
         mov       cx,ds:[DskLSBlk]         ; poáet sektorñ na alokaán° blok
         call      far ptr ReadLDsk         ; naáten° bloku do bufferu
         pop       cx
         jc        NulDSou7                 ; chyba áten°

; ------ vynulov†n° dat

         push      ax                       ; sektor LOW
         mov       di,ds:[DskLBBlk]         ; poáet bajtñ na alokaán° blok
         sub       di,cx                    ; adresa konce dat
         mov       al,ds:[NulDBajt]         ; nulovac° bajt
         mov       ah,al                    ; nulovac° slovo
         cld
         shr       cx,1                     ; poáet slov
         rep       stosw                    ; vynulov†n° dat
         adc       cx,cx                    ; lichò bajt
         rep       stosb                    ; vynulov†n° lichÇho bajtu
         pop       ax                       ; sektor LOW

; ------ z†pis bloku na disk

         xor       si,si                    ; adresa zaá†tku bufferu
         mov       cx,ds:[DskLSBlk]         ; poáet sektorñ na alokaán° blok
         call      far ptr WritLDsk         ; z†pis bloku na disk
NulDSou7:jmp       NulDSou2                 ; dal®° soubor

; ------ nalezen° dal®°ho podadres†©e

NulDSou8:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        NulDSou9                 ; je p©eru®en° operace
         call      far ptr ResLDir          ; resetov†n° adres†©e na zaá†tek
         call      far ptr SrcLDir          ; nalezen° dal®°ho adres†©e
         jc        NulDSou9                 ; nen° dal®° adres†©
         jmp       NulDSou1                 ; nulov†n° dal®°ho adres†©e

NulDSou9:ret

NulDSou  ENDP

; -----------------------------------------------------------------------------
;        nulov†n° volnòch alokaán°ch blokñ
; -----------------------------------------------------------------------------

NulDBlk  PROC      NEAR

; ------ zobrazen° hl†®en°

         mov       si,offset NulDTxt3       ; hl†®en°
         call      far ptr InfDisp0         ; zobrazen° hl†®en°
         xor       cx,cx
         call      far ptr InfoKurz         ; inicializace ukazatele

; ------ p©°prava bufferu alokaán°ho bloku

         mov       es,ds:[NulDBuf]          ; adresa bufferu
         xor       di,di                    ; poá†teán° offset bufferu
         mov       cx,ds:[DskLBBlk]         ; poáet bajtñ na alokaán° blok
         shr       cx,1                     ; poáet slov na alokaán° blok
         mov       al,ds:[NulDBajt]         ; nulovac° bajt
         mov       ah,al                    ; nulovac° slovo
         cld
         rep       stosw                    ; vymaz†n° bufferu

; ------ test p©eru®en° operace

         mov       bx,2                     ; ukazatel á°sla bloku
         call      far ptr KurzOff          ; vypnut° kurzoru
NulDBlk2:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        NulDBlk9                 ; je p©eru®en° operace

; ------ test, zda blok je volnò

         call      far ptr GetClust         ; poskytnut° á°sla bloku
         jnz       NulDBlk3                 ; nen° to volnò alokaán° blok

; ------ vòpoáet á°sla sektoru

         call      far ptr ClstSekt         ; vòpoáet á°sla sektoru
         jc        NulDBlk3                 ; nen° to platnò blok

; ------ z†pis alokaán°ho bloku

         xor       si,si                    ; offset poá†tku dat bloku
         mov       cx,ds:[DskLSBlk]         ; poáet sektorñ na blok
         call      far ptr WritLDsk         ; z†pis dat na disk
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr DispTime         ; obsluha zobrazen° áasu

; ------ ukazatel operace

         mov       cx,1                     ; 1 blok
         call      far ptr InfoKurz         ; ukazatel operace

; ------ dal®° alokaán° blok

NulDBlk3:inc       bx                       ; zvò®en° á°sla alokaán°ho bloku
         cmp       bx,ds:[DskLMBlk]         ; je to platnò blok ?
         jbe       NulDBlk2                 ; je to platnò alokaán° blok

NulDBlk9:ret

NulDBlk  ENDP

; *****************************************************************************
;
;                            Ru®en° obsahu disket
;
; *****************************************************************************
;˛
RusDisk  PROC      FAR

; ------ uzav©en° menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu

; ------ potvrzen° p©ed zah†jen°m operace

         mov       si,offset RusVMnu        ; volba potvrzen°
         call      far ptr Lin0MenF         ; volba mechaniky
         jnc       RusDisk1                 ; je to potvrzeno OK

; ------ konec programu

RusDisk0:mov       ax,ds:[KopDSeg]          ; buffer
         call      far ptr DelSeg           ; zru®en° bufferu
         mov       ds:[KopDSeg],ax
         jmp       far ptr Main0

; ------ vytvo©en° bufferu

RusDisk1:mov       bx,4000h                 ; asi tak velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° datovÇho bufferu
         jnc       RusDisk2                 ; buffer vytvo©en OK
         call      far ptr MemErr           ; chybovÇ hl†®en°
         jmp       short RusDisk0

RusDisk2:mov       ds:[KopDSeg],ax          ; á°slo bufferu
         mov       ds:[KopDSegM],bx         ; velikost bufferu v bajtech
RusDsk22:mov       word ptr ds:[RusDMPl1],offset RusDHTx4 ; nen° ë†dnò text

; ------ volba mechaniky s ru®enou disketou

RusDisk3:call      far ptr FlushChr         ; vypr†zdnàn° bufferu kl†vesnice
         mov       si,offset RusDMnu        ; menu volby mechaniky
         call      far ptr LinPMenu         ; volba mechaniky
         jc        RusDisk0                 ; p©eru®en° operace

; ------ obnoven° obsahñ oken

         cmp       bl,3                     ; je obnoven° obsahu ?
         jne       RusDsk32                 ; nen° obnoven° obsahu

         mov       al,0                     ; disk A:
         mov       ah,bit3+bit4+bit5        ; v®echna okna
         call      far ptr ModWDisk         ; aktualizace oken
         mov       al,1                     ; disk B:
         call      far ptr ModWDisk         ; aktualizace oken
         call      far ptr MainRead         ; obnoven° naáten° oken
         call      far ptr DispAll          ; zobrazen° v®eho
         jmp       short RusDsk22           ; novÇ zobrazen° voleb

RusDsk32:mov       word ptr ds:[RusDMPl1],offset RusDHTx3 ; chyba p©i ru®en°

; ------ zobrazen° hl†®en° o ru®en° obsahu diskety

         mov       si,offset RusDHTxt
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ inicializace parametrñ diskety

         xchg      ax,bx                    ; AL <- zvolenò disk + 1
         dec       ax                       ; AL <- zvolenò disk
         call      far ptr IniLDskZ         ; inicializace parametrñ disku
         jc        RusDisk3                 ; chyba
         test      byte ptr ds:[DskLPar],bit0 ; je FAT 12 ?
         jnz       RusDisk3                 ; FAT 16 se neobsluhuje

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        RusDisk3                 ; p©eru®en° operace

; ------ aktualizace okna

         mov       al,ds:[DskLDisk]         ; zadanò disk
         mov       ah,bit3+bit4+bit5        ; v®echna okna
         call      far ptr ModWDisk         ; aktualizace oken

; ------ poáet sektorñ v bufferu

         mov       ax,ds:[KopDSegM]         ; velikost bufferu v bajtech
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; vòpoáet poátu sektorñ
         mov       ds:[KopDSegN],ax         ; velikost bufferu v sektorech
         or        ax,ax                    ; je alespo§ 1 sektor ?
         jz        RusDisk3                 ; buffer p©°li® malò

; ------ adresa bufferu -> ES

         mov       ax,ds:[KopDSeg]          ; segment
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ p©°prava ukazatelñ dat k operaci

         mov       ax,ds:[DskLBDat]         ; poá†teán° datovò sektor
         mov       ds:[KopDSReN],ax         ; á°taá zbylòch sektorñ k operaci
         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         xor       ax,ax                    ; AX <- 0 ukazatel á°sla sektoru
         xor       dx,dx                    ; DX <- 0

; ------ p©°prava poátu sektorñ pro jednu operaci

RusDisk4:mov       cx,ds:[KopDSegN]         ; velikost bufferu v sektorech
         cmp       cx,ds:[KopDSReN]         ; zbòv† mÇnà sektorñ ?
         jbe       RusDisk5                 ; je to OK
         mov       cx,ds:[KopDSReN]         ; omezen° poátu sektorñ
RusDisk5:jcxz      RusDsk92                 ; je to hotovo

; ------ naáten° dat z disku do bufferu

         xor       di,di                    ; DI <- 0 ukl†dac° adresa
         call      ReaLRDsk                 ; naáten° dat z disku
         jc        RusDisk9                 ; chyba operace

; ------ nulov†n° dat v bufferu

         call      RusDNul                  ; nulov†n° dat v bufferu

; ------ z†pis dat z bufferu na disk

         xor       si,si                    ; SI <- 0 átec° adresa
         mov       bx,1                     ; bude se ukl†dat 1 blok dat
RusDisk6:call      far ptr WritLDsk         ; z†pis sektorñ na disku
         jnc       RusDisk8                 ; data zaps†na OK

; ------ bude ukl†d†n° po sektorech

         cmp       bx,cx                    ; ukl†d† se po sektorech ?
         jae       RusDisk7                 ; ukl†d† se po sektorech
         mov       bx,cx                    ; BX <- poáet sektorñ k z†pisu
         mov       cx,1                     ; bude se ukl†dat po sektoru
         jmp       short RusDisk6           ; z†pis po sektorech

; ------ hl†®en° - chyba áten° z disku

RusDisk7:call      ZobDWErr                 ; hl†®en° - chyba z†pisu
         jc        RusDisk9                 ; p©eru®en° operace
         jz        RusDisk6                 ; opakov†n° operace

; ------ posun ukazatelñ

RusDisk8:add       si,ds:[DskLBSkt]         ; zvò®en° adresy v bufferu
         add       ax,cx                    ; zvò®en° ukazatele sektorñ
         adc       dx,0
         sub       ds:[KopDSReN],cx         ; sn°ëen° á°taáe zbylòch sektorñ
         call      far ptr DispTime         ; zobrazen° áasu
         dec       bx                       ; á°taá sekc° k z†pisu
         jnz       RusDisk6                 ; z†pis dal®°ho bloku dat
         jmp       short RusDisk4           ; dal®° blok dat

; ------ vypnut° kritickÇ sekce

RusDsk92:mov       word ptr ds:[RusDMPl1],offset RusDHTx2 ; operace ru®en° OK
RusDisk9:call      far ptr VypKrit          ; vypnut° kritickÇ sekce

         call      far ptr MainRead         ; obnoven° naáten° oken
         call      far ptr DispAll          ; zobrazen° v®eho
         jmp       RusDisk3                 ; dal®° disketa

RusDisk  ENDP

; -----------------------------------------------------------------------------
;        nulov†n° dat v bufferu ES:DI, CX sektorñ, od sektoru AX
; -----------------------------------------------------------------------------

RusDNul  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         cld
         mov       bp,cx                    ; BP <- poáet sektorñ

RusDNul1:push      ax                       ; á°slo sektoru
         push      di
         mov       cx,ds:[DskLBSkt]         ; CX <- velikost sektoru (bajtñ)

; ------ BOOT sektor

         sub       ax,1                     ; je to BOOT sektor ?
         jae       RusDNul2                 ; nen° BOOT sektor
         cmp       byte ptr es:[di+38],29h  ; (=Boot29) roz®°©enò BOOT sektor ?
         jne       RusDNl12                 ; nen° to roz®°©enò BOOT sektor
         mov       si,offset BootLabl       ; n†và®t° "NO NAME"
         add       di,43                    ; (=BootLabl) buffer k uloëen° jmÇna
         mov       cx,11                    ; dÇlka jmÇna disku
         rep       movsb                    ; nulov†n° jmÇna disku
RusDNl12:jmp       short RusDNul9

; ------ test, zda je sektor FAT

RusDNul2:mov       bl,ds:[DskLNFat]         ; poáet tabulek FAT
RusDNul3:or        ax,ax                    ; je to prvn° sektor FAT ?
         jz        RusDNul4                 ; je to prvn° sektor FAT
         cmp       ax,ds:[DskLSFat]         ; je to sektor FAT ?
         jb        RusDNul5                 ; je to sektor FAT
         sub       ax,ds:[DskLSFat]         ; odeáten° sektorñ na jednu FAT
         dec       bl                       ; á°taá tabulek FAT
         jnz       RusDNul3                 ; dal®° tabulka FAT

; ------ sektor ROOT

RusDNl32:xor       ax,ax                    ; AX <- 0
         shr       cx,1                     ; CX <- velikost sektoru ve slovech
         rep       stosw                    ; vynulov†n° sektoru ROOT
         jmp       short RusDNul9

; ------ prvn° sektor FAT

RusDNul4:add       di,3                     ; p©eskoáen° z†hlav° FAT
         sub       cx,3                     ; sn°ëen° dÇlky sektoru

; ------ vnit©n° sektor FAT

RusDNul5:shl       ax,1                     ; bude offset v tetr†d†ch
         mul       word ptr ds:[DskLBSkt]   ; p©epoáet na offset v bajtech
         mov       bx,3                     ; poáet tetr†d na blok
         cmp       dx,bx                    ; je to OK ?
         jae       RusDNl32                 ; byla by to chyba
         div       bx                       ; vòpoáet tetr†dy
         or        dx,dx                    ; je to tetr†da 0 ?
         jz        RusDNul6                 ; je to zarovn†no na celou tetr†du
         and       byte ptr es:[di],not 0fh ; nulov†n° prvn° tetr†dy
         dec       dx                       ; je to tetr†da 1 ?
         jnz       RusDNl72                 ; je to tetr†da 2
                                            ; jinak tetr†da 1
         mov       al,0
         stosb                              ; vynulov†n° jednoho bajtu
         dec       cx                       ; sn°ëen° á°taáe dat

RusDNul6:cmp       cx,2                     ; je je®tà dost dat ?
         jb        RusDNl82                 ; je m†lo dat
         mov       ax,es:[di]               ; slovo z FAT
         and       ax,0fffh
         cmp       ax,0ff7h                 ; je to vadnò blok ?
         je        RusDNul7                 ; je to vadnò blok
         and       word ptr es:[di],not 0fffh ; nulov†n° poloëky

RusDNul7:inc       di                       ; zvò®en° ukazatele dat
         dec       cx                       ; sn°ëen° á°taáe zbylòch dat
RusDNl72:cmp       cx,2                     ; je je®tà dost dat ?
         jb        RusDNl82                 ; je m†lo dat
         mov       ax,es:[di]               ; slovo z FAT
         and       ax,0fff0h
         cmp       ax,0ff70h                ; je to vadnò blok ?
         je        RusDNul8                 ; je to vadnò blok
         and       word ptr es:[di],not 0fff0h ; nulov†n° poloëky

RusDNul8:inc       di                       ; zvò®en° ukazatele dat
         inc       di
         dec       cx                       ; sn°ëen° á°taáe dat
         loop      RusDNul6                 ; dal®° data

RusDNl82:mov       al,0
         rep       stosb                    ; vynulov†n° zbytku dat

; ------ p©°prava pro dal®° sektor

RusDNul9:pop       di
         pop       ax

         inc       ax                       ; zvò®en° á°sla sektoru
         add       di,ds:[DskLBSkt]         ; adresa dal®°ho sektoru
         dec       bp                       ; á°taá sektorñ
         jz        RusDNulA                 ; jsou jië v®echny sektory
         jmp       RusDNul1                 ; dal®° sektor

; ------ n†vrat registrñ

RusDNulA:pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RusDNul  ENDP

; *****************************************************************************
;
;                             Kop°rov†n° disket
;
; -----------------------------------------------------------------------------
; Zdrojov† a c°lov† disketa nemohou bòt souáasnà soubory, aby byly alespo§
; jednou definov†ny disketovÇ parametry (velikost a poáet sektorñ) a aby
; nemohl bòt zdrojovò a c°lovò soubor stejnò.
; *****************************************************************************
;˛
KopDisk  PROC      FAR

; ------ uzav©en° menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu

; ------ volba mechaniky ke kop°rov†n° disket

KopDiskF LABEL     FAR                      ; skok z kl†vesy Ctrl-F5

         test      byte ptr ds:[DMnuVBlk+5],bit0 ; je operace povolena ?
         jnz       KopDisk0                 ; z†kaz operace

         call      PrepSSou                 ; p©°prava jmÇna souboru
KopDsk02:call      KopZdCls                 ; uzav©en° zdrojovÇho souboru

         mov       si,offset KopDMnu        ; menu zad†n° zdrojovÇho disku
         call      far ptr LinPMenu         ; zad†n° zdrojovÇho disku
         jc        KopDisk0                 ; p©eru®en° operace
         dec       bx                       ; á°slo zvolenÇ mechaniky
         mov       ds:[ZdrjDisk],bl         ; zvolen† zdrojov† mechanika

; ------ zad†n° zdrojovÇho souboru

KopDsk04:cmp       bl,2                     ; je zdrojovò soubor ?
         jne       KopDisk1                 ; nen° zdrojovò soubor
         or        byte ptr ds:[KopD2Blk+2],bit1 ; bude zak†zanò soubor
         mov       bp,offset KopSMnu        ; menu zad†n° zdrojovÇho souboru
         call      ZadSSoub                 ; zad†n° zdrojovÇho souboru
         jc        KopDsk02                 ; p©eru®en° - opakov†n° zad†n°
         jmp       short KopDisk2           ; zad†n° OK

; ------ uzav©en° reëimu kop°rov†n°/porovn†v†n° disket

KopDisk0:call      KopDTClo                 ; uzav©en° p©echodnÇho souboru
         jmp       far ptr Main0

; ------ naáten° zdrojovÇ diskety

KopDisk1:and       byte ptr ds:[KopD2Blk+2],not bit1 ; bude povolen soubor
         mov       si,offset KopDTxt1       ; text hl†®en°
         call      KopDRead                 ; naáten° zdrojovÇ diskety
         jc        KopDsk02                 ; chyba - p©eru®en° operace

; ------ vòzva k vloëen° c°lovÇ diskety

KopDisk2:mov       word ptr ds:[KopD2Pl1],offset KopD2Pl2 ; nen° hl†®en°
KopDsk22:mov       si,offset KopD2Mnu       ; menu vòzvy k vloëen° novÇ diskety
         call      far ptr LinPMenu         ; potvrzen° vloëen° novÇ diskety
         jc        KopDsk02                 ; p©eru®en° operace

; ------ volba BX: ovà©en° kapacity c°lovÇho disku (pokud byl zvolen disk)

KopDisk3:call      OverCil                  ; ovà©en° c°lovÇho disku
         jc        KopDsk22                 ; byla chyba - opakov†n°

; ------ zad†n° c°lovÇho souboru

         cmp       byte ptr ds:[CilDisk],2  ; je c°lovòm diskem soubor ?
         jne       KopDisk8                 ; nen° soubor

KopDisk4:mov       si,offset KopD3Mnu       ; menu zad†n° c°lovÇho souboru
         call      far ptr Lin0Menu         ; zad†n° zdrojovÇho souboru
         jc        KopDisk2                 ; p©eru®en° operace

; ------ normalizace jmÇna souboru

         call      far ptr NormFilL         ; normalizace jmÇna souboru
         jcxz      KopDisk2                 ; nen° nic zad†no - p©eru®en°
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru

; ------ test, zda soubor ES:SI jië existuje

         call      far ptr ExisFile         ; test, zda soubor jië existuje
         jc        KopDisk5                 ; soubor neexistuje

; ------ hl†®en° - soubor jië existuje

         push      si
         mov       si,offset KopD4Mnu
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         pop       si
         jc        KopDisk4                 ; p©eru®en° volby

; ------ zru®en° existuj°c°ho souboru

         call      far ptr DelFile          ; zru®en° existuj°c°ho souboru
         call      far ptr ModiWDir         ; modifikace adres†©e

; ------ vytvo©en° c°lovÇho souboru ES:SI

KopDisk5:call      far ptr CreatFil         ; vytvo©en° souboru
         jnc       KopDisk7                 ; soubor vytvo©en OK

; ------ chyba z†pisu do souboru

         mov       si,offset KopWErr        ; hl†®en° - disk plnò
         call      far ptr Lin0MenF         ; hl†®en°
         jmp       short KopDisk4           ; opakov†n° zad†n°

KopDisk7:mov       ds:[CilDIdnt],ax         ; identifik†tor c°lovÇho souboru
         call      far ptr ModiWDir         ; modifikace adres†©e

; ------ z†pis c°lovÇ diskety

KopDisk8:call      KopDWrit                 ; z†pis c°lovÇ diskety
         jc        KopDisk2                 ; chyba

; ------ operace OK - volba dal®° operace

         mov       si,offset KopD5Mnu       ; menu volby dal®° operace
         call      far ptr LinPMenu         ; volba dal®° operace
         jc        KopDisk2                 ; p©eru®en° operace
         dec       bx                       ; je opakov†n° z†pisu ?
         mov       bx,word ptr ds:[KopD2Mnu+MnuAkt] ; aktivn° poloëka
         jnz       KopDisk3                 ; je opakov†n° z†pisu
         call      KopZdCls                 ; uzav©en° zdrojovÇho souboru
         mov       bl,ds:[ZdrjDisk]         ; zdrojovò disk
         jmp       KopDsk04                 ; nov† zdrojov† disketa

KopDisk  ENDP

; -----------------------------------------------------------------------------
;        uzav©en° zdrojovÇho souboru
; -----------------------------------------------------------------------------

KopZdCls PROC      NEAR

         mov       ax,ds:[ZdrDIdnt]         ; identifik†tor zdrojovÇho souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         mov       ds:[ZdrDIdnt],ax
         ret

KopZdCls ENDP

; -----------------------------------------------------------------------------
;        zad†n° (a otev©en°) zdrojovÇho souboru BP (CY=p©eru®en° operace)
; -----------------------------------------------------------------------------

ZadSSoub PROC      NEAR

; ------ zad†n° zdrojovÇho souboru (menu DS:BP)

ZadSSou2:mov       si,bp                    ; SI <- menu volby
         call      far ptr Lin0Menu         ; zad†n° zdrojovÇho souboru
         jc        ZadSSou9                 ; p©eru®en° operace

; ------ zobrazen° hl†®en° DS:SI o naá°t†n° zdrojovÇ diskety

         mov       si,offset KopDTxt1       ; text - naá°t†m obsah diskety
         mov       word ptr ds:[KopD2Pl4],"-"*HI + 1 ; kapacita nen° zn†m†
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ normalizace jmÇna souboru

         call      far ptr NormFilL         ; normalizace jmÇna souboru
         stc                                ; p©°znak chyby operace
         jcxz      ZadSSou9                 ; nen° nic zad†no - p©eru®en°
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru

; ------ otev©en° souboru ES:SI pro áten°

         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       ZadSSou6                 ; soubor otev©en OK

; ------ chyba - soubor nenalezen (hl†®en° pouëito z editoru)

         mov       si,offset ENFMnLin       ; hl†®en° - soubor nenalezen
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jmp       short ZadSSou2

ZadSSou6:mov       ds:[ZdrDIdnt],ax         ; identifik†tor zdrojovÇho souboru

; ------ zji®tàn° velikosti souboru

         call      far ptr SizeFile         ; zji®tàn° velikosti souboru
         mov       word ptr ds:[KopDSize],cx ; velikost disku LOW
         mov       word ptr ds:[KopDSize+2],bx ; velikost disku HIGH
         call      KopPSize                 ; p©°prava velikosti disku
         clc                                ; p©°znak operace OK

ZadSSou9:call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         ret

ZadSSoub ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©edvolby - jmÇno souboru
; -----------------------------------------------------------------------------

PrepSSou PROC      NEAR

         push      si
         push      di
         push      es

         mov       byte ptr ds:[KopSMnPN],0 ; nen° p©edvolba
         mov       byte ptr ds:[CmpSMnPN],0 ; nen° p©edvolba
         mov       byte ptr ds:[KopD3MPN],0 ; nen° p©edvolba
         mov       byte ptr ds:[CmpD3MPN],0 ; nen° p©edvolba

         call      far ptr GetAKurz         ; adresa aktivn° poloëky
         jc        PrepSSo2                 ; nen° poloëka pod kurzorem
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        PrepSSo2                 ; nen° to platn† poloëka
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       PrepSSo2                 ; adres†© nen° povolen

         push      ds

         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment

         inc       si                       ; zaá†tek jmÇna poloëky
         mov       di,offset FileTxtP+1     ; buffer k dek¢dov†n° jmÇna poloëky
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky

         pop       ds

         sub       di,offset FileTxtP+1
         mov       ds:[KopSMnPD],di         ; dÇlka textu
         mov       ds:[CmpSMnPD],di         ; dÇlka textu
         mov       ds:[KopD3MPD],di         ; dÇlka textu
         mov       ds:[CmpD3MPD],di         ; dÇlka textu

         inc       byte ptr ds:[KopSMnPN]   ; 1 p©edvolba
         inc       byte ptr ds:[CmpSMnPN]   ; 1 p©edvolba
         inc       byte ptr ds:[KopD3MPN]   ; 1 p©edvolba
         inc       byte ptr ds:[CmpD3MPN]   ; 1 p©edvolba

PrepSSo2:pop       es
         pop       di                       ; BP <- adresa menu
         pop       si
         ret

PrepSSou ENDP

; -----------------------------------------------------------------------------
;        ovà©en° kapacity c°lovÇho disku (volba BX -> CY=chyba)
; -----------------------------------------------------------------------------

OverCil  PROC      NEAR

; ------ p©°prava á°sla mechaniky

         dec       bx                       ; á°slo zvolenÇ mechaniky
         mov       ds:[CilDisk],bl          ; zvolen† c°lov† mechanika
         cmp       bl,2                     ; je zvolen disk ?
         jae       OverCil4                 ; nen° zvolen disk

; ------ hl†®en° o naá°t†n° informac°

         mov       si,offset KontKTxt
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ naáten° parametrñ disku

         mov       al,ds:[CilDisk]          ; zvolenò disk
         call      far ptr IniLDskZ         ; inicializace parametrñ disku
         mov       ax,0                     ; pro p©°pad chyby
         jc        OverCil1                 ; byla chyba (kapacita = 0)

; ------ vòpoáet kapacity disku v bajtech -> DX:AX

         mov       ax,word ptr ds:[DskLNSkt] ; poáet sektorñ na disku
OverCil1:mul       word ptr ds:[DskLBSkt]   ; p©epoáet velikosti na bajty

; ------ kontrola kapacity disku

         cmp       dx,word ptr ds:[KopDSize+2] ; souhlas° velikost disku ?
         jne       OverCil2                 ; kapacita nesouhlas°
         cmp       ax,word ptr ds:[KopDSize]
         je        OverCil4                 ; velikost disku souhlas° OK

; ------ p©°prava hl†®en°, ëe velikost disku nesouhlas°
; !!!!!! sem se sk†áe i z obsluhy porovn†n° disket !

OverCil2:mov       word ptr ds:[KopD2Pl1],offset KopD2Pl3 ; nespr†vnò form†t
         mov       word ptr ds:[CmpD2Pl1],offset KopD2Pl3 ; nespr†vnò form†t

         mov       di,offset KopD2P32       ; buffer k dek¢dov†n° kapacity
         call      KopPSiz1                 ; dek¢dov†n° kapacity disku
         mov       ax," )"
         stosw
         mov       al,"!"
         stosb
         xchg      ax,di
         sub       ax,offset KopD2Pl3+1
         mov       ds:[KopD2Pl3],al         ; dÇlka textu

         stc                                ; p©°znak chyby
OverCil4:call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         ret

OverCil  ENDP

; -----------------------------------------------------------------------------
;        p©°prava velikosti zdrojovÇho disku
; -----------------------------------------------------------------------------

KopPSize PROC      NEAR

; ------ parametry disku pro zdrojovò disk

         mov       di,offset KopD2Pl4+1     ; buffer k dek¢dov†n° kapacity disku
         mov       ax,word ptr ds:[KopDSize] ; velikost disku v bajtech
         mov       dx,word ptr ds:[KopDSize+2]
         call      KopPSiz1                 ; dek¢dov†n° kapacity disku
         xchg      ax,di                    ; AX <- konec textu
         sub       ax,offset KopD2Pl4+1     ; dÇlka textu
         mov       ds:[KopD2Pl4],al         ; dÇlka textu
         ret

; ====== je vol†no i odjinud !!!   (DX:AX do DS:DI -> ES:DI=novò konec dat)

; ------ £schova registrñ

KopPSiz1:push      ax
         push      bx
         push      cx
         push      dx

; ------ velikost diskety v KB -> AX

         mov       al,ah                    ; velikost disku / 256
         mov       ah,dl
         shr       ax,1
         shr       ax,1                     ; velikost disku v KB

; ------ rozli®en°, zda bude £daj kapacity v MB nebo v KB

         xor       bx,bx                    ; nen° barva ani oddàlovac° znak
         push      ds
         pop       es                       ; ES <- datovò segment
         cmp       ax,1000                  ; je mÇnà neë 1 MB ?
         jae       KopPSiz2                 ; je 1 MB a v°ce

; ------ dek¢dov†n° kapacity v KB

         call      far ptr DekNumW          ; dek¢dov†n° kapacity v KB
         mov       bl,"K"                   ; oznaáen° kapacity v KB
         jmp       short KopPSiz5

; ------ vòpoáet á°slic pro dek¢dov†n° kapacity v MB

KopPSiz2:cld
         mov       cx,1000                  ; dàlitel
         xor       dx,dx                    ; DX <- 0
         div       cx                       ; vòpoáet jednotek
         aam                                ; rozdàlen° na á°slice
         or        ax,"00"                  ; korekce na znak ASCII
         xchg      al,ah
         cmp       al,"0"                   ; je platn† á°slice ?
         je        KopPSiz3                 ; nen° to platn† á°slice
         stosb
KopPSiz3:xchg      al,ah
         stosb                              ; jednotky
         mov       al,"."
         stosb                              ; oddàlovac° teáka
         xchg      ax,dx                    ; AX <- kilobajty (do 1 MB)
         mov       cl,100
         div       cl                       ; vòpoáet stovek KB
         add       al,"0"                   ; korekce na znak ASCII
         stosb                              ; desetiny MB
         mov       cl,10
         mov       al,ah                    ; AL <- kilobajty (do 100 KB)
         mov       ah,0
         div       cl                       ; vòpoáet des°tek KB
         or        al,al                    ; je = 0 ?
         jz        KopPSiz4                 ; des°tky KB = 0
         add       al,"0"                   ; korekce na znak ASCII
         stosb                              ; setiny MB
KopPSiz4:mov       bl,"M"                   ; oznaáen° jednotky v MB

; ------ ukonáen° textu £daje kapacity

KopPSiz5:cld
         mov       al," "
         stosb                              ; oddàlovac° mezera
         xchg      ax,bx                    ; oznaáen° jednotky "K" nebo "M"
         mov       ah,"B"
         stosw                              ; oznaáen° jednotky

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KopPSize ENDP

; -----------------------------------------------------------------------------
; dek¢dov†n° velikosti disku DX:AX do buff. DS:DI (8 pozic) se zarovn†n°m vpravo
; -----------------------------------------------------------------------------

RghDSize PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ dek¢dov†n° velikosti disku do bufferu zleva

         push      di                       ; zaá†tek bufferu
         call      KopPSiz1                 ; dek¢dov†n° kapacity
         pop       ax                       ; AX <- zaá†tek bufferu

; ------ p©°sun textu ke konci bufferu

         mov       dx,8                     ; DX <- dÇlka bufferu
         mov       cx,di                    ; CX <- konec dat
         sub       cx,ax                    ; CX <- skuteán† dÇlka dat
         add       ax,dx                    ; AX <- poëadovanò konec dat
         mov       si,di                    ; SI <- skuteánò konec dat
         xchg      ax,di                    ; DI <- poëadovanò konec dat
         sub       dx,cx                    ; DX <- chybàj°c° dÇlka dat
         dec       si                       ; SI <- skuteánò posledn° znak
         dec       di                       ; DI <- poëadovanò posledn° znak
         std                                ; p©esun dolñ
         rep       movsb                    ; p©esun dat ke konci
         mov       al," "                   ; mazac° znak mezery
         mov       cx,dx                    ; CX <- chybàj°c° dÇlka dat
         rep       stosb                    ; vymaz†n° bufferu p©ed textem

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

RghDSize ENDP

; -----------------------------------------------------------------------------
;        naáten° zdrojovÇ diskety (CY=chyba nebo p©eru®en°) (SI=hl†®en°)
; -----------------------------------------------------------------------------

KopDRead PROC      NEAR

         mov       byte ptr ds:[DVDSmart],-1 ; stav SMARTDRV nezn†mò

; ------ zobrazen° hl†®en° DS:SI o naá°t†n° zdrojovÇ diskety

         mov       word ptr ds:[KopD2Pl4],"-"*HI + 1 ; kapacita nen° zn†m†
         call      far ptr InfDisp0         ; zobrazen° hl†®en°

; ------ inicializace parametrñ zvolenÇho disku

         mov       al,ds:[ZdrjDisk]         ; zvolenò disk A: nebo B:
         call      far ptr IniLDskZ         ; inicializace parametrñ disku
         jc        KopDRea9                 ; chyba

         call      DiskSOff                 ; £schova a vypnut° SMARTDRV

; ------ inicializace ukazatelñ kurzoru

         cmp       word ptr ds:[DskLNSkt+2],0 ; je platn† velikost disku ?
         stc
         jne       KopDRea9                 ; neplatn† velikost disku

; ------ p©°prava bufferu a ukazatelñ (DS:SI=hl†®en° o operaci)

         call      KopDPreB                 ; vytvo©en° bufferu
         jc        KopDRea9                 ; chyba pamàti

; ------ p©°prava poátu sektorñ pro operaci

KopDRea2:mov       cx,ds:[KopDSegN]         ; velikost bufferu v sektorech
         cmp       cx,ds:[KopDSReN]         ; zbòv† mÇnà sektorñ ?
         jbe       KopDRea4                 ; zbòv† je®tà dost sektorñ
         mov       cx,ds:[KopDSReN]         ; omezen° poátu sektorñ
KopDRea4:jcxz      KopDRea8                 ; je konec disku

; ------ naáten° obsahu bufferu z disku

         xor       di,di                    ; poá†tek bufferu
         call      ReaLRDsk                 ; naáten° bufferu z disku
         jc        KopDRea9                 ; p©eru®en° operace

; ------ z†pis CX sektorñ do souboru

         call      KopDReaW                 ; z†pis bufferu do souboru
         jc        KopDRea9                 ; chyba z†pisu - p©eru®en° operace

; ------ posun ukazatelñ dat

         call      KopDNxt                  ; posun ukazatelñ
         jc        KopDRea9                 ; p©eru®en° operace
         jmp       short KopDRea2           ; jsou jië v®echny sektory

; ------ zru®en° datovÇho bufferu

KopDRea8:clc                                ; p©°znak operace OK
KopDRea9:jmp       KopDWrt9                 ; uzav©en° bufferñ a souborñ

KopDRead ENDP

; -----------------------------------------------------------------------------
;      áten° CX sektorñ z disku od sektoru DX:AX do bufferu ES:DI (CY=p©eru®en°)
; -----------------------------------------------------------------------------

ReaLRDsk PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ áten° £seku dat

         mov       bx,cx                    ; BX <- poáet sektorñ ke áten°
ReaLRDs2:call      far ptr TestBreak        ; je p©eru®en° operace ?
         jc        ReaLRDs9                 ; je p©eru®en° operace
         call      far ptr ReadLDsk         ; naáten° sektorñ do pamàti
         jnc       ReaLRDs6                 ; data naátena OK

; ------ sn°ëen° velikosti dat k operaci

         dec       cx                       ; je jië 1 sektor ?
         mov       cx,1                     ; p©°®tà bude 1 sektor
         jnz       ReaLRDs2                 ; nebyl 1 sektor

; ------ byl jië 1 sektor - chybovÇ hl†®en°

         call      ZobDRErr                 ; hl†®en° - chyba áten°
         jc        ReaLRDs9                 ; p©eru®en° operace
         jz        ReaLRDs2                 ; opakov†n° operace

; ------ je ignorov†n° chyby

         add       di,ds:[DskLBSkt]         ; zvò®en° ukazatele v bufferu
         add       ax,cx                    ; zvò®en° ukazatele á°sla sektoru
         adc       dx,0
         sub       bx,cx                    ; sn°ëen° á°taáe sektorñ
         jz        ReaLRDs9                 ; konec disku
         mov       cx,bx                    ; CX <- sektorñ pro dal®° operaci
         jmp       short ReaLRDs2

; ------ data naátena OK - p©°prava pro dal®° £sek

ReaLRDs6:add       di,ds:[DskLBSkt]         ; zvò®en° ukazatele v bufferu
         add       ax,cx                    ; zvò®en° ukazatele á°sla sektoru
         adc       dx,0
         sub       bx,cx                    ; sn°ëen° á°taáe sektorñ
         jnz       ReaLRDs2                 ; jsou dal®° data

; ------ n†vrat registrñ

ReaLRDs9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReaLRDsk ENDP

; -----------------------------------------------------------------------------
;        p©°prava bufferu pro operaci áten°/z†pis/porovn†n° (DS:SI=hl†®en°)
; -----------------------------------------------------------------------------

KopDPreB PROC      NEAR

; ------ p©°prava ukazatelñ

         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[InfoKCit],ax ; nulov†n° á°taáe sektorñ
         mov       word ptr ds:[InfoKCit+2],ax
         mov       word ptr ds:[InfoKMax+2],ax
         mov       word ptr ds:[CmpDRCit],ax ; á°taá rozd°lnòch sektorñ

         mov       ax,word ptr ds:[DskLNSkt] ; poáet sektorñ na disku
         mov       ds:[KopDSReN],ax         ; á°taá zbylòch sektorñ k operaci
         mov       word ptr ds:[InfoKMax],ax ; poáet sektorñ na disku
         mul       word ptr ds:[DskLBSkt]   ; p©epoáet velikosti na bajty
         mov       word ptr ds:[KopDSize],ax ; velikost disku v bajtech
         mov       word ptr ds:[KopDSize+2],dx

         call      KopPSize                 ; p©°prava velikosti disku

; ------ zobrazen° hl†®en° o operaci

         call      far ptr InfDisp0         ; novÇ zobrazen° hl†®en°
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° kurzoru

; ------ vytvo©en° datovÇho bufferu

         mov       bx,ds:[DskLBSkt]         ; velikost 1 sektoru
         shl       bx,1                     ; minim†lnà 2 sektory
         call      far ptr CreatDat         ; vytvo©en° datovÇho bufferu
         jnc       KopDPrB1                 ; buffer vytvo©en OK

         call      far ptr MemErr           ; zobrazen° hl†®en° - chyba pamàti
         jmp       short KopDPrB9           ; nàjak† chyba

KopDPrB1:mov       ds:[KopDSeg],ax          ; segment pro kop°rov†n°
         call      far ptr GetDat           ; adresa bufferu -> ES

; ------ p©°prava velikosti bufferu

         xchg      ax,bx                    ; AX <- velikost bufferu
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[DskLBSkt]   ; vòpoáet poátu sektorñ v bufferu
         mov       ds:[KopDSegN],ax         ; velikost bufferu v sektorech

; ------ p©°prava poloviny bufferu

         shr       ax,1                     ; poáet sektorñ na polovinu bufferu
         mov       ds:[KopDSgN2],ax         ; poáet sektorñ na polovinu bufferu
         mul       word ptr ds:[DskLBSkt]   ; poáet bajtñ na polovinu bufferu
         mov       ds:[KopDSegM],ax         ; adresa poloviny bufferu

; ------ vytvo©en° a resetov†n° p©echodnÇho souboru

         call      KopDTRes                 ; resetov†n° p©echodnÇho souboru

; ------ p©°prava ukazatelñ (ES=adresa bufferu)

         xor       ax,ax                    ; AX <- 0 ukazatel sektorñ LOW
         xor       dx,dx                    ; DX <- 0 ukazatel sektorñ HIGH
                                          ;* zde je NC !
KopDPrB9:ret

KopDPreB ENDP

; -----------------------------------------------------------------------------
;        z†pis c°lovÇ diskety (CY=chyba nebo p©eru®en°)
; -----------------------------------------------------------------------------

KopDWrit PROC      NEAR

; ------ vypnut° SMARTDRV

         mov       byte ptr ds:[DVDSmart],-1 ; stav SMARTDRV nezn†mò
         cmp       byte ptr ds:[CilDisk],2  ; je z†pis do souboru ?
         je        KopDWrt1                 ; je z†pis do souboru
         call      DiskSOff                 ; £schova a vypnut° SMARTDRV

         mov       al,ds:[CilDisk]          ; c°lovò disk
         mov       ah,bit3+bit4+bit5        ; v®echna okna
         call      far ptr ModWDisk         ; aktualizace oken

; ------ p©°prava bufferu a ukazatelñ (DS:SI=hl†®en° o operaci)

KopDWrt1:mov       si,offset KopDTxt2
         call      KopDPreB                 ; vytvo©en° bufferu
         jc        KopDWrt9                 ; chyba pamàti

; ------ p©°prava poátu sektorñ k z†pisu -> CX

KopDWrt2:mov       bx,1                     ; bude se ukl†dat 1 blok dat
         mov       cx,ds:[KopDSegN]         ; velikost bufferu v sektorech
         cmp       cx,ds:[KopDSReN]         ; zbòv† mÇnà sektorñ ?
         jbe       KopDWrt3                 ; zbòv† je®tà dost sektorñ
         mov       cx,ds:[KopDSReN]         ; omezen° poátu sektorñ
KopDWrt3:jcxz      KopDWrt8                 ; je konec disku

; ------ naáten° obsahu bufferu ze souboru (CX sektorñ)

         call      KopDWrtR                 ; naáten° dat ze souboru
         jc        KopDWrt9                 ; chyba (p©eru®en° operace)

         cmp       byte ptr ds:[CilDisk],2  ; je z†pis do souboru ?
         jne       KopDWrt4                 ; nen° z†pis do souboru

; ------ z†pis do souboru

         call      KopDWrtW                 ; z†pis dat do souboru
         jnc       KopDWrt6                 ; z†pis OK
         jmp       short KopDWrt9           ; chyba z†pisu

; ------ z†pis CX sektorñ na disk

KopDWrt4:xor       si,si                    ; SI <- 0 offset poá†tku bufferu
KopDWrt5:call      far ptr WritLDsk         ; z†pis sektorñ na disku
         jnc       KopDWrt6                 ; data zaps†na OK

; ------ bude ukl†d†n° po sektorech

         cmp       bx,cx                    ; ukl†d† se po sektorech ?
         jae       KopDWr54                 ; ukl†d† se po sektorech
         mov       bx,cx                    ; BX <- poáet sektorñ k z†pisu
         mov       cx,1                     ; bude se ukl†dat po sektoru
         jmp       short KopDWrt5           ; z†pis po sektorech

; ------ hl†®en° - chyba áten° z disku

KopDWr54:call      ZobDWErr                 ; hl†®en° - chyba z†pisu
         jc        KopDWrt9                 ; p©eru®en° operace
         jz        KopDWrt5                 ; opakov†n° operace

; ------ posun ukazatelñ

KopDWrt6:add       si,ds:[DskLBSkt]         ; zvò®en° adresy v bufferu
         call      KopDNxt                  ; posun ukazatelñ dat
         jc        KopDWrt9                 ; p©eru®en° operace
         jnz       KopDWrt5                 ; z†pis dal®°ho bloku dat
         jmp       short KopDWrt2

; ------ zru®en° datovÇho bufferu (sk†áe se sem i z naá°t†n° a porovn†n° disku!)

KopDWrt8:clc                                ; p©°znak operace OK
KopDWrt9:pushf
         call      DiskSRet                 ; navr†cen° stavu SMARTDRV
         call      far ptr FlushEsc         ; vypr†zdnàn° p©eru®en° ESC
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         mov       ax,ds:[KopDSeg]          ; segment pro kop°rov†n°
         call      far ptr DelSeg           ; zru®en° segmentu
         mov       ds:[KopDSeg],ax          ; p©°znak zru®en° segmentu
         mov       ax,ds:[CilDIdnt]
         call      far ptr ClosFile         ; uzav©en° vòstupn°ho souboru
         mov       ds:[CilDIdnt],ax
         popf
         ret

KopDWrit ENDP

; ------ naáten° CX sektorñ z c°lovÇho souboru

CmpDCilR PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         mul       cx                       ; poáet bajtñ dat v bufferu
         xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°

         mov       ax,ds:[CilDIdnt]         ; identifik†tor souboru
         jmp       short KopDWrR1

CmpDCilR ENDP

; ------ naáten° obsahu bufferu ze souboru (CX sektorñ -> CY=p©eru®en°)

KopDWrtR PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         mul       cx                       ; poáet bajtñ dat v bufferu
         xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°

         call      KopDTGet                 ; poskytnut° identifik†toru souboru
         jc        KopDWrR2                 ; chyba
         xor       di,di                    ; DI <- 0 offset zaá†tku bufferu
KopDWrR1:mov       dx,cx                    ; DX <- poáet poëadovanòch bajtñ
         call      far ptr ReadFile         ; naáten° dat ze souboru
         jc        KopDWrR2                 ; operace OK
         cmp       cx,dx                    ; bylo naáteno v®e ?

KopDWrR2:mov       si,offset KopRErr

; ------ n†vrat registrñ a chybovÇ hl†®en° DS:SI

KopDWrR4:pop       dx
         pop       cx
         pop       ax
         jnc       KopDWrR6                 ; operace OK

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        KopDWrR6                 ; p©eru®en° operace

         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         stc                                ; p©°znak chyby
KopDWrR6:ret

KopDWrtR ENDP

; ------ uloëen° CX sektorñ do c°lovÇho souboru

KopDWrtW PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         mul       cx                       ; poáet bajtñ dat v bufferu
         xchg      ax,cx                    ; CX <- poáet bajtñ k naáten°

         mov       ax,ds:[CilDIdnt]         ; identifik†tor souboru

KopDWrW2:xor       si,si                    ; SI <- 0 offset poá†tku bufferu
         call      far ptr WritFile         ; z†pis dat do souboru

KopDWrW4:mov       si,offset KopWErr        ; hl†®en° - disk plnò
         jmp       short KopDWrR4           ; n†vrat registrñ a chybovÇ hl†®en°

KopDWrtW ENDP

; ------ z†pis dat ES do p©echodnÇho souboru (CX sektorñ) -> CY chyba

KopDReaW PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       ax,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         mul       cx                       ; poáet bajtñ dat v bufferu
         xchg      ax,cx                    ; CX <- poáet bajtñ k z†pisu

         call      KopDTGet                 ; poskytnut° identifik†toru souboru
         jc        KopDWrW4                 ; chyba
         jmp       short KopDWrW2           ; z†pis dat

KopDReaW ENDP

; ------ posun ukazatelñ po £spà®nÇ operaci (NZ=dal®° blok, CY=p©eru®en°)

KopDNxt  PROC      NEAR

; ------ zvò®en° ukazatele sektorñ

         add       ax,cx                    ; zvò®en° ukazatele sektorñ
         adc       dx,0
         sub       ds:[KopDSReN],cx         ; sn°ëen° á°taáe zbylòch sektorñ

; ------ zobrazen° informaán°ho kurzoru

         call      far ptr InfoKurz         ; zobrazen° ukazatele operace
         call      far ptr DispTime         ; zobrazen° áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky

; ------ test p©eru®en° operace, á°t†n° sekc° dat

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         dec       bx                       ; á°taá sekc° k z†pisu
         ret

KopDNxt  ENDP

; -----------------------------------------------------------------------------
;        resetov†n° ukazatele p©echodnÇho souboru (pokud existuje)
; -----------------------------------------------------------------------------

KopDTRes PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ identifik†tor p©echodnÇho souboru

         call      KopDTGet                 ; identifik†tor souboru
         jc        KopDTRs9                 ; chyba

; ------ resetov†n° ukazatele v p©echodnÇm souboru

         call      far ptr ResFile          ; resetov†n° ukazatele souboru

; ------ n†vrat registrñ

KopDTRs9:pop       ax
         ret

KopDTRes ENDP

; -----------------------------------------------------------------------------
;        poskytnut° identifik†toru p©echodnÇho souboru (a p©°p. vytvo©en°)
; -----------------------------------------------------------------------------

KopDTGet PROC      NEAR

; ------ data jsou naá°t†na ze souboru

         mov       ax,ds:[ZdrDIdnt]         ; identifik†tor zdrojovÇho souboru
         cmp       byte ptr ds:[ZdrjDisk],2 ; zdrojem je soubor ?
         je        KopDTGt9                 ; zdrojem je soubor

; ------ test, zda je p©echodnò soubor jië vytvo©en (a otev©en)

         mov       ax,ds:[EditTemp]         ; identifik†tor p©echodnÇho souboru
         or        ax,ax                    ; je soubor vytvo©en a otev©en ?
         jnz       KopDTGt9                 ; soubor je vytvo©en

; ------ £schova registrñ

         push      si
         push      es

; ------ vytvo©en° p©echodnÇho souboru

         test      byte ptr ds:[TempDirP],bit0 ; je z†kaz z†pisu ?
         stc                                ; p©°znak chyby
         jnz       KopDTGt8                 ; je z†kaz z†pisu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset EditTmpJ       ; buffer k sestaven° jmÇna souboru
         call      far ptr CreatTmp         ; vytvo©en° souboru
         jc        KopDTGt8                 ; chyba - soubor nelze vytvo©it
         mov       ds:[EditTemp],ax         ; identifik†tor souboru

; ------ n†vrat registrñ

KopDTGt8:pop       es
         pop       si
KopDTGt9:ret

KopDTGet ENDP

; -----------------------------------------------------------------------------
;        uzav©en° (a zru®en°) p©echodnÇho souboru
; -----------------------------------------------------------------------------

KopDTClo PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ test, zda je soubor vytvo©en

         mov       ax,ds:[EditTemp]         ; identifik†tor p©echodnÇho souboru
         or        ax,ax                    ; je soubor otev©en ?
         jz        KopDTCl9                 ; soubor nen° otev©en

; ------ uzav©en° souboru

         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce
         call      far ptr ClosFile         ; uzav©en° p©echodnÇho souboru
         mov       ds:[EditTemp],ax

; ------ zru®en° p©echodnÇho souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset EditTmpJ       ; jmÇno p©echodnÇho souboru
         call      far ptr DelFile          ; zru®en° p©echodnÇho souboru
         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ n†vrat registrñ

KopDTCl9:pop       es
         pop       si
         pop       ax
         ret

KopDTClo ENDP

; *****************************************************************************
;
;                             Porovn†n° disket
;
; -----------------------------------------------------------------------------
; Zdrojov† a c°lov† disketa nemohou bòt souáasnà soubory, aby byly alespo§
; jednou definov†ny disketovÇ parametry (velikost a poáet sektorñ).
; *****************************************************************************
;˛
CmpDisk  PROC      FAR

; ------ uzav©en° menu

         add       sp,4
         call      far ptr ClosMnuA

; ------ volba mechaniky ke kop°rov†n° disket

         call      PrepSSou                 ; p©°prava jmÇna souboru
CmpDsk02:call      KopZdCls                 ; uzav©en° zdrojovÇho souboru

         mov       si,offset CmpDMnu        ; menu volby prvn° diskety
         call      far ptr LinPMenu
         jc        CmpDisk0                 ; p©eru®en° operace
         dec       bx                       ; á°slo zvolenÇ mechaniky
         mov       ds:[ZdrjDisk],bl         ; zvolen† mechanika

; ------ zad†n° zdrojovÇho souboru

CmpDsk04:cmp       bl,2                     ; je zdrojovò soubor ?
         jne       CmpDisk1                 ; nen° zdrojovò soubor
         or        byte ptr ds:[CmpD2Blk+2],bit1 ; bude zak†zanò soubor
         mov       bp,offset CmpSMnu        ; menu zad†n° zdrojovÇho souboru
         call      ZadSSoub                 ; zad†n° zdrojovÇho souboru
         jc        CmpDsk02                 ; p©eru®en° zad†n°
         jmp       short CmpDisk2           ; zad†n° OK

CmpDisk0:jmp       KopDisk0                 ; uzav©en° kop°rov†n°/porovn†n° disket

; ------ naáten° prvn° diskety

CmpDisk1:and       byte ptr ds:[CmpD2Blk+2],not bit1 ; bude povolen soubor
         mov       si,offset CmpDTxt1       ; text hl†®en°
         call      KopDRead                 ; naáten° zdrojovÇ diskety
         jc        CmpDsk02                 ; chyba

; ------ vòzva k vloëen° druhÇ diskety

CmpDisk2:mov       word ptr ds:[CmpD2Pl1],offset KopD2Pl2 ; nen° hl†®en°
CmpDsk22:mov       si,offset CmpD2Mnu       ; menu vòzvy k vloëen° druhÇ diskety
         call      far ptr LinPMenu         ; potvrzen° vloëen° novÇ diskety
         jc        CmpDsk02                 ; p©eru®en° operace

; ------ volba BX: ovà©en° kapacity c°lovÇho disku (pokud byl zvolen disk)

CmpDisk3:call      OverCil                  ; ovà©en° c°lovÇho disku
         jc        CmpDsk22                 ; byla chyba

; ------ zad†n° c°lovÇho souboru

         cmp       byte ptr ds:[CilDisk],2  ; je c°lovòm diskem soubor ?
         jne       CmpDisk8                 ; nen° soubor

CmpDisk4:mov       si,offset CmpD3Mnu       ; menu zad†n° c°lovÇho souboru
         call      far ptr Lin0Menu         ; zad†n° zdrojovÇho souboru
         jc        CmpDisk2                 ; p©eru®en° operace

; ------ normalizace jmÇna souboru

         call      far ptr NormFilL         ; normalizace jmÇna souboru
         jcxz      CmpDisk2                 ; nen° nic zad†no - p©eru®en°
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru

; ------ otev©en° souboru ES:SI pro áten°

         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       CmpDisk5                 ; soubor otev©en OK

; ------ chyba - soubor nenalezen (hl†®en° pouëito z editoru)

         mov       si,offset ENFMnLin       ; hl†®en° - soubor nenalezen
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jmp       short CmpDisk4           ; opakov†n° zad†n°

CmpDisk5:mov       ds:[CilDIdnt],ax         ; identifik†tor c°lovÇho souboru

; ------ kontrola velikosti souboru

         call      far ptr SizeFile         ; zji®tàn° velikosti souboru
         call      far ptr ResFile          ; resetov†n° ukazatele souboru
         mov       dx,bx                    ; DX <- velikost HIGH
         xchg      ax,cx                    ; AX <- velikost LOW
         cmp       ax,word ptr ds:[KopDSize] ; souhlas° velikost disku ?
         jne       CmpDisk6                 ; velikost nesouhlas°
         cmp       dx,word ptr ds:[KopDSize+2]
         je        CmpDisk8                 ; velikost je OK

; ------ p©°prava hl†®en°, ëe je chybn† velikost

CmpDisk6:call      OverCil2                 ; p©°prava hl†®en°
         jmp       short CmpDsk22           ; opakov†n° zad†n°

; ------ porovn†n° disket

CmpDisk8:call      CmpDComp                 ; porovn†n° obsahñ disket
         cmp       word ptr ds:[CmpDRCit],0 ; nalezeny rozd°ly ?
         jne       CmpDsk82                 ; nalezeny rozd°ly
         cmp       word ptr ds:[KopDSReN],0 ; operace p©eru®ena ?
         jne       CmpDisk2                 ; operace p©eru®ena

; ------ p©°prava hl†®en° o vòsledku operace porovn†n°

CmpDsk82:mov       word ptr ds:[CmpD5Pl0],offset CmpD5Pl1 ; jsou shodnÇ
         mov       byte ptr ds:[CmpD5Pl3],0 ; nejsou rozd°lnÇ sektory
         mov       ax,ds:[CmpDRCit]         ; á°taá rozd°lnòch sektorñ
         or        ax,ax                    ; nalezeny rozd°ly ?
         jz        CmpDsk84                 ; nenalezeny rozd°ly
         mov       word ptr ds:[CmpD5Pl0],offset CmpD5Pl2 ; nejsou shodnÇ

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset CmpD5Pl4       ; buffer poátu rozd°lñ
         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; dek¢dov†n° poátu odchylek
         sub       di,offset CmpD5Pl3+1     ; dÇlka textu
         xchg      ax,di                    ; AX <- dÇlka textu
         mov       ds:[CmpD5Pl3],al         ; dÇlka textu

; ------ hl†®en° vòsledku porovn†n°

CmpDsk84:mov       si,offset CmpD5Mnu       ; menu volby dal®° operace
         call      far ptr LinPMenu         ; volba dal®° operace
         jc        CmpDsk85                 ; p©eru®en° operace
         dec       bx                       ; je opakov†n° porovn†n° ?
         jz        CmpDsk86                 ; je dal®° disketa
         mov       bx,word ptr ds:[CmpD2Mnu+MnuAkt] ; aktivn° poloëka
         jmp       CmpDisk3                 ; je opakov†n° porovn†n°

CmpDsk85:jmp       CmpDisk2                 ; p©eru®en° operace

CmpDsk86:call      KopZdCls                 ; uzav©en° zdrojovÇho souboru
         mov       bl,ds:[ZdrjDisk]         ; zdrojovò disk
         jmp       CmpDsk04                 ; nov† zdrojov† disketa

CmpDisk  ENDP

; -----------------------------------------------------------------------------
;        porovn†n° s druhou disketou (CY=chyba nebo p©eru®en°)
; -----------------------------------------------------------------------------

CmpDComp PROC      NEAR

; ------ vypnut° SMARTDRV

         mov       byte ptr ds:[DVDSmart],-1 ; stav SMARTDRV nezn†mò
         cmp       byte ptr ds:[CilDisk],2  ; je z†pis do souboru ?
         je        CmpDCmp1                 ; je z†pis do souboru
         call      DiskSOff                 ; £schova a vypnut° SMARTDRV
CmpDCmp1:mov       byte ptr ds:[CmpD4Mnu+MnuAkt],1 ; nen° ignorov†n° rozd°lñ

; ------ p©°prava bufferu a ukazatelñ

         mov       si,offset CmpDTxt2
         call      KopDPreB                 ; vytvo©en° bufferu
         jc        CmpDCmp9                 ; chyba pamàti

; ------ p©°prava poátu sektorñ k porovn†n° -> CX

CmpDCmp2:mov       cx,ds:[KopDSgN2]         ; velikost poloviny bufferu (sekt.)
         cmp       cx,ds:[KopDSReN]         ; zbòv† mÇnà sektorñ ?
         jbe       CmpDCmp3                 ; zbòv† je®tà dost sektorñ
         mov       cx,ds:[KopDSReN]         ; omezen° poátu sektorñ
CmpDCmp3:jcxz      CmpDCmp8                 ; je konec disku

; ------ naáten° bufferu z prvn°ho disku

         call      KopDWrtR                 ; naáten° dat ze souboru
         jc        CmpDCmp9                 ; chyba (p©eru®en° operace)

; ------ naáten° bufferu z druhÇho disku

         mov       di,ds:[KopDSegM]         ; adresa poloviny bufferu
         cmp       byte ptr ds:[CilDisk],2  ; je c°lovò disk soubor ?
         jne       CmpDCmp4                 ; nen° to soubor
         call      CmpDCilR                 ; naáten° bufferu ze souboru
         jmp       short CmpDCmp5

CmpDCmp4:call      ReaLRDsk                 ; naáten° bufferu z disku
CmpDCmp5:jc        CmpDCmp9                 ; chyba

; ------ p©°prava k porovn†n° bufferñ po sektorech

         mov       bx,cx                    ; BX <- poáet sektorñ k porovn†n°
         xor       si,si                    ; prvn° buffer
         mov       di,ds:[KopDSegM]         ; druhò buffer

; ------ porovn†n° jednoho sektoru

CmpDCmp6:mov       cx,ds:[DskLBSkt]         ; poáet bajtñ na sektor
         shr       cx,1                     ; velikost sektoru ve slovech
         push      si
         push      di
         cld
         repe      cmps word ptr es:[si],es:[di] ; porovn†n° jednoho sektoru
         pop       di
         pop       si
         je        CmpDCmp7                 ; data jsou OK

; ------ hl†®en°, ëe data jsou rozd°ln†

         inc       word ptr ds:[CmpDRCit]   ; á°taá rozd°lnòch sektorñ
         cmp       byte ptr ds:[CmpD4Mnu+MnuAkt],2 ; je ignorov†n° rozd°lñ ?
         je        CmpDCmp7                 ; je ignorov†n° rozd°lñ
         call      CmpDRErr                 ; hl†®en° rozd°lu mezi disketami
         jc        CmpDCmp9                 ; p©eru®en° operace

; ------ posun ukazatele operace

CmpDCmp7:add       si,ds:[DskLBSkt]         ; posun adresy 1
         add       di,ds:[DskLBSkt]         ; posun adresy 2
         mov       cx,1                     ; porovn†n 1 sektor
         call      KopDNxt                  ; posun ukazatelñ
         jc        CmpDCmp9                 ; p©eru®en° operace
         jnz       CmpDCmp6                 ; dal®° sektor
         jmp       short CmpDCmp2           ; dal®° blok dat

CmpDCmp8:clc                                ; p©°znak operace OK
CmpDCmp9:jmp       KopDWrt9                 ; uzav©en° bufferñ a souborñ

CmpDComp ENDP

CodeDisk ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT

; -----------------------------------------------------------------------------
;        menu volby k nulov†n° disku
; -----------------------------------------------------------------------------
;˛
NulDMnu  label     BYTE
         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        5                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        NulDMPol                 ; definián° tabulka poloëek
         dw        NulDMHlp                 ; n†povàda
         dw        Hlp@NulovaniDisku        ; á°slo str†nky velkÇ n†povàdy
         dw        NulDMBlk                 ; blokovac° tabulka
         dw        NulDMSwc                 ; p©ep°naáe
         dw        NulDMTit                 ; adresa titulu okna
         dw        NulDMExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        8                        ; vò®ka okna

NulDMPol db        1,16,'Bajt          '
NulDMPl1 db        '  '
         db        1+bit7,8,'Adres†©e'
         db        1+bit7,7,'Soubory'
         db        1+bit7,11,'VolnÇ bloky'
         db        bit6+bit7,0
         db        1,8,'Nulov†n°'

NulDMBlk db        0,0,0,0,0                ; blokovac° tabulka
NulDMSwc db        0,0,0                    ; p©ep°naáe

NulDMTit db        8,'nulov†n°'

HelpS    SEGMENT   BYTE PUBLIC
NulDMHlp db        59,'Bajt k vynulov†n° volnòch blokñ disku (00 aë FF v HEX k¢du)'
         db        56,'Budou nulov†ny popisovaáe zru®enòch souborñ v adres†©°ch'
         db        57,'Bude nulov†n volnò prostor za soubory (v posledn°m bloku)'
         db        54,'Budou nulov†ny volnÇ bloky (nevyuëitÇ ë†dnòmi soubory)'
         db        31,'Zah†jen° operace nulov†n° disku'
HelpS    ENDS

NulDMExe label     dword                    ; obsluhy voleb
         dd        NulDsk1                  ; bajt
         dd        NulDsk2                  ; adres†©e
         dd        NulDsk24                 ; soubory
         dd        NulDsk3                  ; volnÇ bloky
         dd        NulDsk4                  ; nulov†n°

HelpS    SEGMENT   BYTE PUBLIC
NulDMHl1 db        74,'Zadejte hodnotu bajtu k nulov†n° volnòch blokñ disku (00 aë FF v HEX k¢du)'
HelpS    ENDS

;NulDPar  db        bit0+bit1+bit2           ; parametry pro nulov†n° disku
;                                            ;    bit 0: 1=nuluj° se adres†©e
;                                            ;    bit 1: 1=nuluj° se soubory
;                                            ;    bit 2: 1=nuluj° se volnÇ bloky
;NulDBajt db        0                        ; nulovac° bajt disku

NulDSeg  dw        0                        ; segment bufferu
NulDBuf  dw        0                        ; adresa bufferu

NulDTxt1 db        33,'Nuluji zru®enÇ poloëky adres†©e ',0
NulDTxt2 db        33,'Nuluji volnÇ m°sto za soubory v ',0
NulDTxt3 db        27,'Nuluji volnÇ bloky disku...'

; -----------------------------------------------------------------------------
;        ru®en° disket
; -----------------------------------------------------------------------------
;˛
; ------ potvrzen° p©ed operac° ru®en° disket

RusVMnu  label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        RusVMPol                 ; zaá†tek definice poloëek menu
         dw        RusVMHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@RuseniDiskety        ; á°slo str†nky velkÇ n†povàdy
         dw        RusVMBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        RusDMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
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

RusVMPol db        bit6,0
         db        bit6,13,0,'* VAROVèNã *'
         db        bit6,36,'N†sleduj°c° operace ru®en° disket je'
         db        bit6,39,'uráena k rychlÇmu ru®en° obsahu disket.'
         db        bit6,0
         db        bit6,34,'Pñvodn° obsah disket bude zniáen !'
         db        bit6,0
         db        bit6+bit7,0
         db        2,6,' D†le '
         db        1,8,'P©eru®it'

RusVMBlk db        0,0                      ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
RusVMHlp db        48,'Pokraáov†n° v operaci ru®en° disket dal®° volbou'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

; ------ volba mechaniky k ru®en° diskety

RusDMnu  label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        14                       ; celkovò poáet poloëek menu

         dw        RusDMPol                 ; zaá†tek definice poloëek menu
         dw        RusDMHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@Rusenidiskety        ; á°slo str†nky velkÇ n†povàdy
         dw        RusDMBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        RusDMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        53                       ; ®°©ka okna
         db        15                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

RusDMPol db        bit6,0
         db        bit6,3,1
RusDMPl1 dw        RusDHTx4
         db        bit6,0
         db        bit6,51,'Zvolte oznaáen° disketovÇ mechaniky ',0,'A:',0,' nebo ',0,'B:',0,','
         db        bit6,47,'ve kterÇ je disketa, jej°ë obsah m† bòt zru®en.'
         db        bit6,0
         db        bit6,13,0,'* VAROVèNã *'
         db        bit6,35,'Pñvodn° obsah diskety bude zniáen !'
         db        bit6,0
         db        bit6+bit7,0
         db        4,7,'   A:  '
         db        4,7,'   B:  '
         db        1,5,'Obsah'
         db        1,9,'P©eru®en°'

RusDHTx2 db        26,0,'Obsah diskety byl zru®en.'
RusDHTx3 db        33,0,'Chyba p©i ru®en° obsahu diskety.'
RusDHTx4 db        5,'-----'

RusDMTit db        20,'ru®en° obsahu disket'

RusDMBlk db        0,0,0,0                  ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
RusDMHlp db        5,1
         dw        RusDMHl1
         db        'A:'

         db        5,1
         dw        RusDMHl1
         db        'B:'

         db        69,'Obnoven° obsahñ oken s disketou A: nebo B: (Ctrl-O = zobrazen°)'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

RusDMHl1 db        36,'Zru®en° obsahu diskety v mechanice '

RusDHTxt db        22,'Ru®°m obsah diskety...'

; -----------------------------------------------------------------------------
;        kop°rov†n° disket
; -----------------------------------------------------------------------------
;˛
KopDMnu  label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        KopDMPol                 ; zaá†tek definice poloëek menu
         dw        KopDMHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopDMBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopDMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        52                       ; ®°©ka okna
         db        11                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

KopDMPol db        bit6,0
         db        bit6,37,'Vloëte zdrojovou disketu do disketovÇ'
         db        bit6,42,'mechaniky ',0,'A:',0,' nebo ',0,'B:',0,' a zvolte oznaáen°'
         db        bit6,40,'tÇto mechaniky, pop©. zvolte "',0,'S',0,'oubor".'
         db        bit6,0
         db        bit6+bit7,0
         db        4,7,'   A:  '
         db        4,7,'   B:  '
         db        1,6,'Soubor'
         db        1,9,'P©eru®en°'

KopDMTit db        13,'kopie diskety'

KopDMBlk db        0,0,0,0                  ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
KopDMHlp db        5,1
         dw        KopDMHl1
         db        'A:'

         db        5,1
         dw        KopDMHl1
         db        'B:'

         db        36,'Obsah diskety bude naáten ze souboru'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

KopDMHl1 db        30,'Zdrojov† disketa v mechanice '

; ------ menu - zad†n° souboru k naáten° zdrojovÇ diskety

KopSMnu  label     byte
         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        KopSMnuP                 ; zaá†tek definice poloëek menu
         dw        KopSMnuH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopSMnuB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopSMnuT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        2,'*?    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
KopSMnPN db        1                        ; poáet p©edvoleb
KopSMnPD dw        0                        ; dÇlka p©edvolby
         dd        FileTxtP+1               ; adresa p©edvolby

; ------ poloëky voleb

KopSMnuP db        bit6,36,'Naá°st zdrojovou disketu ze souboru:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Naá°st'
         db        1,8,'P©eru®it'

KopSMnuB db        0,0,0                    ; blokovac° tabulka

KopSMnuT db        15,'zdrojovò soubor'

HelpS    SEGMENT   BYTE PUBLIC
KopSMnuH db        58,'Zadejte jmÇno souboru, z kterÇho bude naáten obsah diskety'

         db        3,1
         dw        KopSMnH1

         db        3,1
         dw        KopSMnH2
HelpS    ENDS

KopSMnH1 db        33,'Naáten° obsahu diskety ze souboru'

KopSMnH2 db        34,'P©eru®en°, n†vrat k p©ede®lÇ volbà'

; ------ vòzva k vloëen° c°lovÇ diskety

KopD2Mnu label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        12                       ; celkovò poáet poloëek menu

         dw        KopD2Pol                 ; zaá†tek definice poloëek menu
         dw        KopD2Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopD2Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopD2Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        56                       ; ®°©ka okna
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

KopD2Pol db        bit6,3,1
KopD2Pl1 dw        KopD2Pl2
         db        bit6,46,'Vloëte pr†zdnou disketu naform†tovanou na ',0,1
         dw        KopD2Pl4
         db        bit6,55,'do disketovÇ mechaniky ',0,'A:',0,' nebo ',0,'B:',0,' a zvolte oznaáen°'
         db        bit6,40,'tÇto mechaniky, pop©. zvolte "',0,'S',0,'oubor".'
         db        bit6,0
         db        bit6,13,0,'* VAROVèNã *'
         db        bit6,35,'Pñvodn° obsah diskety bude zniáen !'
         db        bit6+bit7,0
         db        4,7,'   A:  '
         db        4,7,'   B:  '
         db        1,6,'Soubor'
         db        1,9,'P©eru®en°'

KopD2Pl2 db        0
KopD2Pl3 db        27,0,'CHYBA - nespr†vn† kapacita diskety ('
KopD2P32 db        '99.99 MB) !'            ; buffer kapacity c°lovÇ diskety

KopD2Pl4 db        8,8 dup(" ")             ; buffer k dek¢dov†n° kapacity

KopD2Tit db        14,'c°lov† disketa'

KopD2Blk db        0,0,0,0                  ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
KopD2Hlp db        5,1
         dw        KopD2Hl2
         db        'A:'

         db        5,1
         dw        KopD2Hl2
         db        'B:'

         db        31,'Z†pis obsahu diskety do souboru'

         db        3,1
         dw        KopSMnH2
HelpS    ENDS

KopD2Hl2 db        34,'Z†pis dat na disketu v mechanice '

; ------ menu - zad†n° souboru k uloëen° diskety

KopD3Mnu label     byte
         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        KopD3MnP                 ; zaá†tek definice poloëek menu
         dw        KopD3MnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopD3MnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopD3MnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        48                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        2,'*?    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
KopD3MPN db        1                        ; poáet p©edvoleb
KopD3MPD dw        0                        ; dÇlka p©edvolby
         dd        FileTxtP+1               ; adresa p©edvolby

; ------ poloëky voleb

KopD3MnP db        bit6,32,'Uloëit obsah diskety do souboru:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Uloëit'
         db        1,8,'P©eru®it'

KopD3MnB db        0,0,0                    ; blokovac° tabulka

KopD3MnT db        13,'c°lovò soubor'

HelpS    SEGMENT   BYTE PUBLIC
KopD3MnH db        59,'Zadejte jmÇno souboru, do kterÇho bude uloëen obsah diskety'
         db        31,'Uloëit obsah diskety do souboru'
         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; ------ hl†®en° - soubor jië existuje (pouëito i p©i exportu dat v TABULCE)

KopD4Mnu label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        KopD4MnP                 ; zaá†tek definice poloëek menu
         dw        KopD4MnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@HlavniMenu           ; á°slo str†nky velkÇ n†povàdy
         dw        KopD4MnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopD4MnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        22                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
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

KopD4MnP db        bit6,9,0,'VAROVèNã'
         db        bit6,28,'Zadanò soubor jië existuje !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,6,'N†vrat'

KopD4MnB db        0,0                      ; blokovac° tabulka

KopD4MnT db        15,'soubor existuje'

HelpS    SEGMENT   BYTE PUBLIC
KopD4MnH db        29,'P©eps†n° existuj°c°ho souboru'
         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; ------ hl†®en° o ukonáen° kop°rov†n°

KopD5Mnu label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        KopD5Pol                 ; zaá†tek definice poloëek menu
         dw        KopD5Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopD5Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopD5Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        52                       ; ®°©ka okna
         db        12                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

KopD5Pol db        bit6,0
         db        bit6,33,'Disketa byla £spà®nà zkop°rov†na.'
         db        bit6,0
         db        bit6,13,0,'* VAROVèNã *'
         db        bit6,26,'P©i volbà opakov†n° z†pisu'
         db        bit6,35,'bude pñvodn° obsah diskety zniáen !'
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,9,'Opakov†n°'
         db        1,9,'P©eru®en°'

KopD5Tit db        16,'konec kop°rov†n°'

KopD5Blk db        0,0,0                    ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
KopD5Hlp db        57,'Kop°rov†n° dal®° diskety - vloëte novou zdrojovou disketu'
         db        65,'Opakov†n° z†pisu - vloëte novou c°lovou disketu (bude p©eps†na !)'
         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; -----------------------------------------------------------------------------
;        chyba - disk plnò
; -----------------------------------------------------------------------------

KopWErr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        KopWErrP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopWErrB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopWErrT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
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


KopWErrP db        bit6,6,0,'CHYBA'
         db        bit6,37,'Chyba z†pisu do souboru (disk plnò) !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

KopWErrB db        0                        ; blokovac° tabulka

KopWErrT db        9,'disk plnò'

; -----------------------------------------------------------------------------
;        chyba áten° ze souboru
; -----------------------------------------------------------------------------

KopRErr  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        KopRErrP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@KopirovaniDisket     ; á°slo str†nky velkÇ n†povàdy
         dw        KopRErrB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        KopRErrT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        40                       ; ®°©ka okna
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


KopRErrP db        bit6,6,0,'CHYBA'
         db        bit6,24,'Chyba áten° ze souboru !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

KopRErrB db        0                        ; blokovac° tabulka

KopRErrT db        11,'chyba áten°'

; -----------------------------------------------------------------------------
;        porovn†v†n° disket
; -----------------------------------------------------------------------------
;˛
CmpDMnu  label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        CmpDMPol                 ; zaá†tek definice poloëek menu
         dw        CmpDMHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpDMBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpDMTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        52                       ; ®°©ka okna
         db        11                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CmpDMPol db        bit6,0
         db        bit6,35,'Vloëte ',0,'PRVNã',0,' disketu do disketovÇ'
         db        bit6,42,'mechaniky ',0,'A:',0,' nebo ',0,'B:',0,' a zvolte oznaáen°'
         db        bit6,40,'tÇto mechaniky, pop©. zvolte "',0,'S',0,'oubor".'
         db        bit6,0
         db        bit6+bit7,0
         db        4,7,'   A:  '
         db        4,7,'   B:  '
         db        1,6,'Soubor'
         db        1,9,'P©eru®en°'

CmpDMTit db        16,'porovn†n° disket'

CmpDMBlk db        0,0,0,0                  ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
CmpDMHlp db        5,1
         dw        CmpDMHl2
         db        'A:'

         db        5,1
         dw        CmpDMHl2
         db        'B:'

         db        33,'Vzor prvn° diskety bude v souboru'

         db        3,1
         dw        MenuHlP2
HelpS    ENDS

CmpDMHl2 db        27,'Prvn° disketa v mechanice '

; ------ menu - zad†n° souboru k naáten° prvn° diskety

CmpSMnu  label     byte
         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        CmpSMnuP                 ; zaá†tek definice poloëek menu
         dw        CmpSMnuH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpSMnuB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpSMnuT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        2,'*?    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
CmpSMnPN db        1                        ; poáet p©edvoleb
CmpSMnPD dw        0                        ; dÇlka p©edvolby
         dd        FileTxtP+1               ; adresa p©edvolby

; ------ poloëky voleb

CmpSMnuP db        bit6,38,'Obsah prvn° diskety naá°st ze souboru:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Naá°st'
         db        1,8,'P©eru®it'

CmpSMnuB db        0,0,0                    ; blokovac° tabulka

CmpSMnuT db        23,'soubor s prvn° disketou'

HelpS    SEGMENT   BYTE PUBLIC
CmpSMnuH db        47,'Zadejte jmÇno souboru s obsahem PRVNã diskety'

         db        3,1
         dw        KopSMnH1

         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; ------ vòzva k vloëen° druhÇ diskety

CmpD2Mnu label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        10                       ; celkovò poáet poloëek menu

         dw        CmpD2Pol                 ; zaá†tek definice poloëek menu
         dw        CmpD2Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpD2Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpD2Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        54                       ; ®°©ka okna
         db        11                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CmpD2Pol db        bit6,3,1
CmpD2Pl1 dw        KopD2Pl2
         db        bit6,43,'Vloëte ',0,'DRUHOU',0,' disketu o kapacità ',0,1
         dw        KopD2Pl4
         db        0,' do'
         db        bit6,52,'disketovÇ mechaniky ',0,'A:',0,' nebo ',0,'B:',0,' a zvolte oznaáen°'
         db        bit6,40,'tÇto mechaniky, pop©. zvolte "',0,'S',0,'oubor".'
         db        bit6,0
         db        bit6+bit7,0
         db        4,7,'   A:  '
         db        4,7,'   B:  '
         db        1,6,'Soubor'
         db        1,9,'P©eru®en°'

CmpD2Tit db        25,'druh† porovn†van† disketa'

CmpD2Blk db        0,0,0,0                  ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
CmpD2Hlp db        5,1
         dw        CmpD2Hl2
         db        'A:'

         db        5,1
         dw        CmpD2Hl2
         db        'B:'

         db        35,'Porovn†n° diskety s obsahem souboru'
         db        3,1
         dw        KopSMnH2
HelpS    ENDS

CmpD2Hl2 db        34,'Porovn†n° s disketou v mechanice '

; ------ menu - zad†n° souboru k naáten° prvn° diskety

CmpD3Mnu label     byte
         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        CmpD3MnP                 ; zaá†tek definice poloëek menu
         dw        CmpD3MnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpD3MnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpD3MnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        2,'*?    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
CmpD3MPN db        1                        ; poáet p©edvoleb
CmpD3MPD dw        0                        ; dÇlka p©edvolby
         dd        FileTxtP+1               ; adresa p©edvolby

; ------ poloëky voleb

CmpD3MnP db        bit6,38,'Obsah druhÇ diskety naá°st ze souboru:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Naá°st'
         db        1,8,'P©eru®it'

CmpD3MnB db        0,0,0                    ; blokovac° tabulka

CmpD3MnT db        23,'soubor s druhou disketou'

HelpS    SEGMENT   BYTE PUBLIC
CmpD3MnH db        47,'Zadejte jmÇno souboru s obsahem DRUHê diskety'

         db        3,1
         dw        KopSMnH1

         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; ------ hl†®en° o nalezen° rozd°lu

CmpD4Mnu label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        CmpD4Pol                 ; zaá†tek definice poloëek menu
         dw        CmpD4Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpD4Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpD4Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
         db        10                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

CmpD4Pol db        bit6,0
         db        bit6,31,'Nalezen rozd°l mezi disketami !'
         db        bit6,14,'(sektor ',0,1
         dw        DZCMLPl2
         db        0,')'

         db        bit6,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,8,'Nehl†sit'
         db        1,8,'P©eru®it'

CmpD4Tit db        14,'nalezen rozd°l'

CmpD4Blk db        0,0,0                    ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
CmpD4Hlp db        3,1
         dw        CmpD4Hl2

         db        31,1
         dw        CmpD4Hl2
         db        ' bez hl†®en° dal®°ch rozd°lñ'

         db        3,1
         dw        KopSMnH2
HelpS    ENDS

CmpD4Hl2 db        32,'Pokraáov†n° v porovn†v†n° disket'

; ------ hl†®en° o ukonáen° porovn†v†n°

CmpD5Mnu label     BYTE
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        CmpD5Pol                 ; zaá†tek definice poloëek menu
         dw        CmpD5Hlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniDisket    ; á°slo str†nky velkÇ n†povàdy
         dw        CmpD5Blk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        CmpD5Tit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        45                       ; ®°©ka okna
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

CmpD5Pol db        bit6,0
         db        bit6,23,'Porovn†vanÇ diskety ',1
CmpD5Pl0 dw        CmpD5Pl1
         db        bit6,3,1
         dw        CmpD5Pl3

         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,9,'Opakov†n°'
         db        1,9,'P©eru®en°'

CmpD5Pl1 db        14,'jsou ',0,'SHODNê',0,'.'
CmpD5Pl2 db        17,0,'NEJSOU SHODNê',0,' !'

CmpD5Pl3 db        27,'poáet rozd°lnòch sektorñ: ',0
CmpD5Pl4 db        '      '

CmpD5Tit db        17,'konec porovn†v†n°'

CmpD5Blk db        0,0,0                    ; blokovac° tabulka

HelpS    SEGMENT   BYTE PUBLIC
CmpD5Hlp db        55,'Porovn†n° dal®°ch disket - vloëte novou PRVNã disketu'
         db        51,'Opakov†n° porovn†n° - vloëte novou DRUHOU disketu'
         db        3,1
         dw        KopSMnH2
HelpS    ENDS

; ------ data pro kop°rov†n° a porovn†v†n° disket

ZdrjDisk db        0                        ; zdrojovò disk (0=A:,1=B:, 2=soub.)
CilDisk  db        0                        ; c°lovò disk (0=A:, 1=B:, 2=soub.)

ZdrDIdnt dw        0                        ; identifik†tor zdrojovÇho souboru
CilDIdnt dw        0                        ; identifik†tor c°lovÇho souboru
KopDSize dd        0                        ; velikost disku (souboru) v bajtech

KopDSeg  dw        0                        ; á°slo datovÇho segmentu kop°rov†n°
KopDSegN dw        0                        ; velikost bufferu v sektorech
KopDSgN2 dw        0                        ; poáet sektorñ na polovinu bufferu
KopDSegM dw        0                        ; adresa poloviny bufferu
                                            ; (pro ru®en° diskety velikost
                                            ;  bufferu v bajtech)

KopDSReN dw        0                        ; á°taá zbylòch sektorñ k operaci

CmpDRCit dw        0                        ; á°taá rozd°lnòch sektorñ

KopDTxt1 db        40,'Naá°t†m obsah zdrojovÇ diskety (',0,1
         dd        KopD2Pl4                 ; kapacita
         db        0,')'

CmpDTxt1 db        37,'Naá°t†m obsah prvn° diskety (',0,1
         dd        KopD2Pl4                 ; kapacita
         db        0,')'

KontKTxt db        23,'Ovà©uji form†t disku...'

KopDTxt2 db        42,'Zapisuji data na c°lovou disketu (',0,1
         dd        KopD2Pl4                 ; kapacita
         db        0,')'

CmpDTxt2 db        44,'Porovn†v†m obsah s druhou disketou (',0,1
         dd        KopD2Pl4                 ; kapacita
         db        0,')'

Data     ENDS

         END

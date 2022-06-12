
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                F I N D
;
;                      Obsluha vyhled†v†n° souborñ
;
; =============================================================================
;
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeFnd  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFnd,ds:Data

; -----------------------------------------------------------------------------
;        Volba souborñ k hled†n°
; -----------------------------------------------------------------------------

AWMMnuSH PROC      FAR

         add       sp,4

Hledej   LABEL     FAR

; ------ p©°prava blokov†n° poloëek pro uloëen° a vypnut° seznamu souborñ

         call      far ptr ClosMnuA         ; uzav©en° oken menu

         or        byte ptr ds:[SHZMnLBl+2],bit1 ; uloëen°
         or        byte ptr ds:[SHZMnLBl+4],bit1 ; adres†©

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        Hledej1
         test      byte ptr es:[AWinPrm1],bit5 ; je seznam ?
         jz        Hledej1                  ; nen° seznam

         and       byte ptr ds:[SHZMnLBl+2],not bit1 ; uloëen°
         and       byte ptr ds:[SHZMnLBl+4],not bit1 ; adres†©

; ------ p©°prava bufferu pro p©edvolbu

Hledej1: mov       bp,sp                    ; £schova SP
         sub       sp,FileMax+12            ; m°sto v z†sobn°ku
         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       word ptr ds:[SHZMLinA],di     ; adresa bufferu s p©edvolbou
         mov       word ptr ds:[SHZMLinA+2],ss

; ------ p©°prava vòchoz°ho adres†©e

;         push      ds
;         mov       ax,ds:[SegmLAdr]         ; adres†© - levÇ okno
;         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
;         jnz       Hledej11                 ; je levÇ okno
;         mov       ax,ds:[SegmRAdr]         ; adres†© - pravÇ okno
;Hledej11:call      far ptr GetSgAdr         ; adresa okna
;         mov       cx,ds:[AktPathN]         ; dÇlka aktivn°ho adres†©e
;         mov       si,offset AktPath        ; aktivn° adres†©
;         jc        Hledej12                 ; okno neplatnÇ
;         mov       ds,dx                    ; DS <- segment adresy okna
;         mov       si,AWinDir               ; adres†© okna
;         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
;Hledej12:
         push      ss
         pop       es
         cld

;         rep       movsb                    ; p©enos textu adres†©e
;         pop       ds
;
;; ------ zaji®tàn° koncovÇho znaku "\"
;
;         dec       di                       ; n†vrat na posledn° znak
;         mov       al,"\"                   ; koncovò znak "\"
;         scasb                              ; je adres†© ukonáen "\" ?
;         je        Hledej14                 ; je ukonáen znakem "\" OK
;         stosb                              ; uloëen° znaku "\"

; ------ uloëen° textu '*.* /c "" u'

Hledej14:mov       ax,".*"
         stosw
         mov       ah," "
         stosw
         mov       ax,"c/"
         stosw
         mov       ax,'" '
         stosw
         xchg      al,ah
         stosw
         mov       al,"u"
         stosb
         mov       byte ptr es:[di],0       ; koncov† 0

; ------ dÇlka textu p©edvolby

         sub       di,sp
         mov       ds:[SHZMLinN],di         ; dÇlka p©edvolby

; ------ volba souborñ k hled†n°

         mov       si,offset SHZMLin        ; menu hled†n° souborñ
         call      far ptr Lin0Menu         ; volba souborñ
         mov       sp,bp                    ; n†vrat SP

; ------ obsluha volby

         call      far ptr JumpBX

         dw        1,Hled                   ; zah†jen° hled†n°
         dw        2,Hled                   ; zah†jen° hled†n°
         dw        3,HledU                  ; uloëen° seznamu
         dw        4,HledN                  ; naáten° seznamu
         dw        5,HledA                  ; n†vrat okna adres†©e

         dw        0,HledX                  ; p©eru®en° operace

AWMMnuSH ENDP

; ------ n†vrat okna adres†©e - zru®en° okna seznamu

HledA:   push      cs
         call      near ptr HledClos        ; zru®en° okna seznamu
         call      far ptr MainRead         ; naáten° oken
         call      far ptr DispAll          ; novÇ zobrazen° oken
HledX:   call      far ptr FlushEsc         ; vypr†zdnàn° p©i p©eru®en° ESC
         jmp       far ptr Main0

; -----------------------------------------------------------------------------
;        zru®en° okna seznamu v aktivn°m oknà (niá° registry AX, SI, DI !)
; -----------------------------------------------------------------------------

HledClos PROC      FAR

; ------ ukazatele aktivn°ho okna

         mov       si,offset ParamL         ; parametry levÇho okna
         mov       di,offset SegmL          ; segment levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       HledCls1                 ; je aktivn° levÇ okno
         mov       si,offset ParamR         ; parametry pravÇho okna
         mov       di,offset SegmR          ; segment pravÇho okna

; ------ test, zda je aktivn° seznam

HledCls1:test      byte ptr ds:[si],bit3    ; zobrazen seznam ?
         jz        HledCls4                 ; seznam nen° zobrazen

; ------ p©epnut° p©°znakñ na adres†©

         xor       byte ptr ds:[si],bit3+bit1 ; p©epnut° na adres†©

; ------ zru®en° segmentu seznamu

         mov       ax,ds:[di]               ; segment okna
         call      far ptr DeletAWn         ; zru®en° okna

; ------ navr†cen° segmentu adres†©e

         mov       ax,ds:[di+2]             ; segment adres†©ovÇho okna
         mov       ds:[di],ax               ; segment pravÇho okna

; ------ aktualizace parametrñ

         call      far ptr AktIWin          ; aktualizace oken
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e

; ------ £schova parametrñ (t©°dàn° okna)

         call      far ptr GetAAWin         ; adresa aktu†ln°ho okna
         mov       al,es:[AWinPrm2]
         mov       ds:[si+1],al             ; £schova parametrñ
HledCls4:ret

HledClos ENDP

; -----------------------------------------------------------------------------
;        otev©en° okna seznamu (neuchov†v† registry AX, SI, DI a ES) CY=p©eru®en°
; -----------------------------------------------------------------------------

HledOpen PROC      NEAR

; ------ uzav©en° p©°padnÇho okna stromu

         call      far ptr TreeClos         ; uzav©en° okna stromu
         call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        HledOpn9                 ; p©eru®en° operace

; ------ ukazatele aktivn°ho okna

         mov       si,offset ParamL         ; parametry levÇho okna
         mov       di,offset SegmL          ; segment levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       HledOpn1                 ; je aktivn° levÇ okno
         mov       si,offset ParamR         ; parametry pravÇho okna
         mov       di,offset SegmR          ; segment pravÇho okna

; ------ test, zda je okno hled†n° jië aktivn°

HledOpn1:or        byte ptr ds:[si],bit0    ; zapnut° okna
         or        byte ptr ds:[WindPar],bit1 ; okna jsou zapnuta
         test      byte ptr ds:[si],bit3    ; je jië seznam ?
         jnz       HledOpn8                 ; je jië seznam

; ------ vytvo©en° segmentu okna

         call      far ptr CreatAWn         ; vytvo©en° okna
         jnc       HledOpn2                 ; operace OK
         call      far ptr MemErr           ; chyba - nedostatek pamàti
         jmp       short HledOpn9

; ------ nastaven° p©°znakñ seznamu

HledOpn2:and       byte ptr ds:[si],not bit1 + bit2 ; nen° strom ani adres†©
         or        byte ptr ds:[si],bit3    ; p©°znak zobrazen° seznamu
         and       byte ptr es:[AWinPrm1],not bit3+bit4 ; nen° strom ani adres†©
         or        byte ptr es:[AWinPrm1],bit5 ; je to okno seznamu
         mov       word ptr es:[AWinFndA+2],0 ; nen° zah†jeno hled†n°

; ------ nastaven° segmentñ

         mov       ds:[di],ax               ; segment okna

         mov       al,ds:[si+1]             ; parametry (t©°dàn°)
         and       al,bit0+bit1+bit2+bit3+bit4+bit7 ; pot©ebnÇ atributy
         mov       es:[AWinPrm2],al         ; parametry

;         clc                                ; p©°znak operace OK
HledOpn8:call      far ptr AktIWin          ; aktualizace oken
HledOpn9:ret

HledOpen ENDP

; *****************************************************************************
;                               AktPth0L
; aktualizace cesty v aktivn°m oknà seznamu bez modifikace aktu†ln°ho adres†©e
;         testuje, zda to je okno seznamu a uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

AktPth0L PROC      FAR

         push      ax

         mov       ax,ds:[SegmNAkt]         ; AX <- neaktivn° okno
         xchg      ax,ds:[SegmAkt]          ; AX <- aktivn° okno
         mov       ds:[SegmNAkt],ax         ; okna zamànàna

         call      far ptr AktPathL         ; aktualizace cesty

         xchg      ax,ds:[SegmAkt]          ; n†vrat okna
         mov       ds:[SegmNAkt],ax

         pop       ax
         ret

AktPth0L ENDP

; *****************************************************************************
;                               AktPthAL
;          aktualizace cesty v aktivn°m oknà seznamu (po zmànà kurzoru)
;         testuje, zda to je okno seznamu a uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

AktPthAL PROC      FAR

         push      ax
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr AktPathL         ; aktualizace cesty
         pop       ax
         ret

AktPthAL ENDP

; *****************************************************************************
;                                AktPathL
;            aktualizace cesty v oknà seznamu (po zmànà kurzoru)
;       testuje, zda to je okno seznamu a uchov†v† registr p©°znakñ !
; -----------------------------------------------------------------------------
; VSTUP: AX=segment okna
;        DS=datovò segment
; *****************************************************************************

AktPathL PROC      FAR

; ------ £schova registrñ 1

         pushf
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna -> ES
         jc        AktPthL9                 ; neplatnÇ okno

; ------ test, zda to je okno stromu

         test      byte ptr es:[AWinPrm1],bit5 ; je to okno seznamu ?
         jz        AktPthL9                 ; nen° to okno seznamu

; ------ £schova registrñ 2

         push      bx
         push      cx
         push      si
         push      di
         push      bp
         mov       bp,es                    ; BP <- £schova adresy okna

; ------ nalezen° poloëky cesty

         mov       bx,es:[AWinKurz]         ; kurzor
         inc       bx                       ; p©ednastaven°
AktPthL2:dec       bx                       ; posun ukazatele kurzoru
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        AktPthL8                 ; neplatn† poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       AktPthL2                 ; nen° to cesta

; ------ uloëen° cesty k poloëce kurzoru

         push      ds

         mov       ch,0
         mov       cl,es:[si]               ; dÇlka textu cesty
         inc       si                       ; zaá†tek textu cesty
         mov       di,AWinDir
         push      es
         pop       ds                       ; DS <- segment poloëky
         mov       es,bp                    ; ES <- segment okna
         cld
         cmp       word ptr ds:[si+1],"\:"  ; je zad†n ROOT ?
         je        AktPthL3                 ; ROOT je OK
         add       di,3
AktPthL3:rep       movsb                    ; p©enos textu cesty
         mov       byte ptr es:[di],0       ; oznaáen° konce cesty
         sub       di,AWinDir               ; dÇlka textu cesty
         mov       es:[AWinDNum],di         ; dÇlka textu cesty
         mov       cl,es:[AWinDir]          ; disk
         sub       cl,"A"
         mov       es:[AWinDisk],cl         ; á°slo disku

         pop       ds

; ------ aktualizace aktivn°ho adres†©e

         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       AktPthL8                 ; nen° to aktivn° okno
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
         call      far ptr DispLCom         ; zobrazen° p©°kazovÇho ©†dku

; ------ n†vrat registrñ

AktPthL8:pop       bp
         pop       di
         pop       si
         pop       cx
         pop       bx
AktPthL9:pop       es
         popf
         ret

AktPathL ENDP

; -----------------------------------------------------------------------------
;        uloëen° seznamu poloëek
; -----------------------------------------------------------------------------
;˛
; ------ buffer v z†sobn°ku

HledU:   mov       bp,sp
         sub       sp,FileMax               ; m°sto pro buffer
         push      ss
         pop       es
         mov       di,sp                    ; buffer v z†sobn°ku

; ------ sestaven° p©edvolby

         mov       word ptr ds:[SHZUMLPA+2],es ; segment bufferu
         mov       word ptr ds:[SHZUMLPA],di ; offset bufferu
         mov       si,offset FindMNam       ; soubor $DOSMAN$.FND
         call      far ptr TempFile         ; sestaven° jmÇna souboru
         sub       di,sp                    ; dÇlka textu
         mov       ds:[SHZUMLPN],di         ; dÇlka jmÇna souboru
         call      HledMPre                 ; p©°prava menu hled†n°

; ------ zad†n° souboru k uloëen°

         mov       si,offset SHZUMLin
         call      far ptr Lin0Menu         ; volba souborñ k operaci
         mov       word ptr ds:[SHZUMLPN],0 ; zru®en° textu p©edvolby
         mov       sp,bp                    ; n†vrat SP
         jnc       HledU1                   ; proveden° operace

HledUX:  jmp       HledX                    ; p©eru®en°

; ------ volba form†tu k uloëen°

HledUS:  push      ax
         mov       al,bit0
         jmp       short HledUD2

HledUJ:  push      ax
         mov       al,bit1
         jmp       short HledUD2

HledUD   PROC      FAR

         push      ax
         mov       al,bit2

HledUD2: and       byte ptr ds:[HledUloP],not bit0+bit1+bit2
         or        ds:[HledUloP],al         ; zapnut° form†tu
         mov       dl,al
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ
         pop       ax

         call      HledMPre                 ; p©°prava menu hled†n°
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

HledUD   ENDP

; ------ normalizace jmÇna souboru -> ES:SI/CX

HledU1:  call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         jcxz      HledUX                   ; nen° nic zad†no
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru
         jcxz      HledUX
         call      far ptr TestBEsc         ; bylo p©eru®en° ?
         jc        HledUX                   ; p©eru®en° operace
         call      far ptr ModiWDir         ; modifikace oken

; ------ uloëen° souboru

         call      HledUl                   ; uloëen° souboru
         jmp       HledUX

; -----------------------------------------------------------------------------
;        Uloëen° seznamu
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru
;        CX=dÇlka jmÇna souboru (nen° = 0)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) identifik†tor souboru (0 = nen°)
;                   SS:[BP-4] (2) dÇlka jmÇna souboru
;                   SS:[BP-6] (2) datovò segment
;                   SS:[BP-8] (2) á°slo segmentu okna seznamu
;                   SS:[BP-10] (2) adresa segmentu okna seznamu
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) adresa konce cesty (pro form†t LST)
;                   SS:[BP-18] (4) á°taá poátu z†znamñ DBF
;                   SS:[BP-34] (16)
;                   SS:[BP-120] (86) jmÇno souboru
;                   SS:[BP-123] (3)
;                   SS:[BP-240] (105) buffer k dek¢dov†n° ©†dku
; neuchov†v† ë†dnÇ registry (jen DS) !!!!
; -----------------------------------------------------------------------------
;˛
HledUl   PROC      NEAR

; ------ buffer lok†ln°ch promànnòch

         mov       bp,sp
         sub       sp,240
         mov       ss:[bp-6],ds             ; datovò segment

; ------ £schova jmÇna souboru do z†sobn°ku

         mov       ss:[bp-4],cx             ; dÇlka jmÇna souboru
         push      ds
         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu
         pop       ds                       ; DS <- segment jmÇna souboru
         inc       cx                       ; váetnà koncovÇ 0
         lea       di,ss:[bp-120]           ; buffer jmÇna souboru
         cld
         rep       movsb                    ; £schova jmÇna souboru
         pop       ds

; ------ inicializace ukazatele poloëek

         xor       ax,ax
         mov       ss:[bp-2],ax             ; nen° otev©en soubor
         mov       ss:[bp-12],ax            ; ukazatel á°sla poloëky
         mov       ss:[bp-18+2],ax          ; á°taá poátu z†znamñ DBF
         mov       ss:[bp-18],ax

; ------ test, zda soubor jië existuje (ES=SS)

         lea       si,ss:[bp-120]           ; jmÇno souboru
         call      far ptr ExisFile         ; test, zda soubor jië existuje
         jnc       HledUl1                  ; soubor nalezen OK
HledUl06:jmp       HledUl3                  ; asi neexistuje - vytvo©en°

; ------ p©eru®en° operace

HledUl09:jmp       HledUl9                  ; p©eru®en° operace

; ------ soubor existuje - dotaz na dal®° postup

HledUl1: mov       si,offset HledUEx
         call      far ptr Lin0Menu         ; volba dal®° operace
         jc        HledUl09                 ; p©eru®en° operace
         dec       bx                       ; je p©epis souboru ?
         jz        HledUl06                 ; p©epis souboru souboru

; ------ otev©en° existuj°c°ho souboru

         lea       si,ss:[bp-120]           ; jmÇno souboru
         call      far ptr OpenRW           ; otev©en° souboru
         jc        HledUl13                 ; chyba
         mov       ss:[bp-2],ax             ; identifik†tor souboru

; ------ naáten° zaá†tku souboru (pro test, zda to je DBF)

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       cx,32                    ; dÇlka z†hlav° DBF
         call      far ptr ReadFile         ; naáten° zaá†tku souboru
         jc        HledUl13                 ; je nàjak† chyba

; ------ test, zda je to datab†zovò soubor

         cmp       cx,32
         jne       HledUl14                 ; nen° datab†zovò soubor
         cmp       byte ptr es:[di+7],0     ; poáet vàt v souboru max. 16M
         jne       HledUl14                 ; to nen° DBF
         mov       al,es:[di]               ; prvn° bajt souboru
         cmp       al,83h                   ; DBF s MEMO
         je        HledUl11                 ; je DBF
         cmp       al,0f5h                  ; FOXPRO s MEMO
         je        HledUl11                 ; je DBF
         cmp       al,3
         jne       HledUl14                 ; nen° datab†zovò soubor

; ------ asi to je DBF - z†kaz pro text

HledUl11:test      byte ptr ds:[HledUloP],bit2 ; je DBF ?
         jz        HledUl2                  ; nen° DBF - chybnò form†t

; ------ ovà©en° z†hlav° souboru

         cmp       word ptr es:[di+8],offset(HledDBF0-HledDBF) ; kontrola z†hlav°
         jne       HledUl2                  ; chyba
         cmp       word ptr es:[di+10],105  ; dÇlka z†znamu
         jne       HledUl2                  ; chyba

; ------ £schova ukazatele poloëek

         mov       ax,es:[di+4]             ; poáet vàt v souboru LOW
         mov       ss:[bp-18],ax            ; poáet z†znamñ v DBF LOW
         mov       ax,es:[di+4+2]           ; poáet vàt v souboru HIGH
         mov       ss:[bp-18+2],ax          ; poáet z†znamñ v DBF HIGH

; ------ nastaven° ukazatele v souboru

         mov       ax,105                   ; poáet bajtñ na z†znam
         mul       word ptr ss:[bp-18]      ; offset LOW
         xchg      ax,cx                    ; CX <- offset LOW
         push      dx
         mov       ax,105
         mul       word ptr ss:[bp-18+2]    ; offset HIGH
         pop       dx
         add       dx,ax                    ; offset HIGH
         add       cx,offset(HledDBF0-HledDBF) ; p©iáten° z†hlav°
         adc       dx,0
         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         jnc       HledUl5                  ; operace OK
HledUl13:jmp       short HledUl4            ; chyba

; ------ nen° datab†zovò soubor - mus° bòt textovò form†t

HledUl14:mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr SizeFile         ; nastaven° ukazatele na konec
         jc        HledUl4                  ; nàjak† chyba
         test      byte ptr ds:[HledUloP],bit2 ; je DBF ?
         jz        HledUl5                  ; nen° soubor DBF - to je OK

; ------ chybnò form†t souboru

HledUl2: mov       si,offset ChybHleF       ; hl†®en° - chybnò form†t
         jmp       short HledUl42           ; chybnò form†t souboru

; ------ vytvo©en° novÇho souboru

HledUl3: push      ss
         pop       es
         lea       si,ss:[bp-120]           ; jmÇno souboru
         call      far ptr CreatFil         ; vytvo©en° novÇho souboru
         jc        HledUl4                  ; chyba vytvo©en° souboru
         mov       ss:[bp-2],ax             ; identifik†tor souboru

; ------ z†pis z†hlav° souboru DBF

         test      byte ptr ds:[HledUloP],bit2 ; je form†t DBF ?
         jz        HledUl5                  ; nen° form†t DBF

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset HledDBF        ; definice souboru DBF
         mov       cx,offset(HledDBF0-HledDBF) ; velikost definice
         call      far ptr WritFile         ; z†pis z†hlav° DBF
         jnc       HledUl5                  ; soubor vytvo©en OK

; ------ chyba z†pisu do souboru

HledUl4: mov       si,offset ChybHleU
HledUl42:call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jmp       HledUl9

; ------ p©°prava k vygenerov†n° seznamu

HledUl5: mov       ax,ds:[SegmAkt]          ; aktivn° okno
         mov       ss:[bp-8],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-10],es            ; adresa okna
         mov       ax,es:[AWinSouN]         ; poáet poloëek v seznamu
         mov       word ptr ds:[InfoKMax],ax ; max. poáet poloëek kurzoru
         mov       word ptr ds:[InfoKMax+2],0

; ------ zobrazen° hl†®en° o ukl†d†n° souboru

         call      far ptr InfoClr0         ; vymaz†n° informaán°ho bufferu
         mov       si,offset HledUlT        ; text "Ukl†d†m"
         call      far ptr InfoTxt          ; dek¢dov†n° textu
         mov       cx,ss:[bp-4]             ; dÇlka jmÇna souboru
         lea       si,ss:[bp-120]           ; jmÇno souboru
         push      ss
         pop       es                       ; ES <- segment bufferu se jmÇnem
         call      far ptr InfoDek          ; dek¢dov†n° textu cesty
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° hl†®en° s kurzorem

; ------ vymaz†n° bufferu pro form†t DBF (ES=SS)

         mov       di,sp                    ; DI <- buffer z†znamu v z†sobn°ku
         mov       cx,105                   ; dÇlka z†znamu
         mov       al," "
         cld
         rep       stosb                    ; vymaz†n° bufferu z†znamu

; ------ p©°prava disku a cesty pro form†t DBF (je CLD)

         mov       di,sp                    ; DI <- buffer v z†sobn°ku
         mov       si,offset AktPath        ; aktu†ln° adres†©
         mov       cx,ds:[AktPathN]         ; dÇlka
         test      byte ptr ds:[HledUloP],bit2 ; je DBF ?
         jz        HledUl54                 ; nen° DBF
         inc       di                       ; 1 pozice pro p©°znaky DBF
         movsb                              ; disk
         inc       si                       ; p©eskoáen° znaku ":"
         inc       si                       ; p©eskoáen° znaku "\"
         sub       cl,3                     ; bez disku a znakñ ":\"
         rep       movsb                    ; p©enos textu adres†©e
         jmp       short HledUl6

; ------ p©°prava aktivn° cesty pro form†t LST (je CLD)

HledUl54:rep       movsb                    ; p©enos adres†©e do bufferu
         mov       al,"\"
         dec       di
         scasb                              ; je na konci znak "\" ?
         je        HledUl55                 ; je jië znak "\"
         stosb                              ; uloëen° oddàlovaáe "\"
HledUl55:mov       ss:[bp-14],di            ; adresa konce cesty

; ------ poskytnut° adresy dal®° poloëky -> ES:SI

HledUl6: mov       es,ss:[bp-10]            ; adresa okna
         mov       bx,ss:[bp-12]            ; ukazatel á°sla poloëky
         call      far ptr GetESPol         ; adresa poloëky ES:SI
         jnc       HledUl61                 ; je platn† poloëka
         jmp       HledUl8                  ; konec poloëek

; ------ je-li cesta, test zda bude nàjakò soubor

HledUl61:test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HledUl64                 ; je to platn† poloëka

         push      es
         push      si

         mov       es,ss:[bp-10]            ; adresa okna
         inc       bx                       ; á°slo dal®° poloëky
         call      far ptr GetESPol         ; adresa dal®° poloëky ES:SI
         dec       bx                       ; n†vrat á°sla poloëky
         jc        HledUl62                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; bude platn† poloëka ?
         jnz       HledUl62                 ; bude to platn† poloëka OK
         stc                                ; p©°znak neplatnÇ poloëky

HledUl62:pop       si
         pop       es
         jnc       HledUl64                 ; poloëka se uloë° OK
         jmp       HledUl79                 ; dal®° poloëka

; ------ p©°prava k dek¢dov†n° jednoho z†znamu

HledUl64:mov       di,sp                    ; DI <- buffer v z†sobn°ku
         cld
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[HledUloP]         ; form†t
         push      ds
         mov       dx,ds                    ; DX <- datovò segment
         push      es
         pop       ds                       ; DS <- segment poloëky (offset SI)
         push      ss
         pop       es                       ; ES <- segment bufferu (offset DI)

; ------ uloëen° z†znamu ve form†tu FND

         test      cl,bit0                  ; je seznam FND ?
         jz        HledUl66                 ; nen° form†t seznam FND

         call      HldUFnd                  ; uloëen° z†znamu ve form†tu FND
         jmp       short HledUl77           ; uloëen° CR/LF

; ------ test, zda je form†t jmÇno LST

HledUl66:test      cl,bit1
         jz        HledUl7                  ; nen° form†t LST

; ------ dek¢dov†n° cesty pro LST

         test      byte ptr ds:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HledUl68                 ; je to platn† poloëka
         mov       cl,ds:[si]               ; dÇlka textu cesty
         inc       si
         rep       movsb                    ; p©enos textu cesty
         mov       al,"\"
         dec       di
         scasb                              ; je posledn° znak "\" ?
         je        HledUl67                 ; je jië "\"
         stosb                              ; uloëen° znaku "\"
HledUl67:mov       ss:[bp-14],di            ; adresa konce cesty
         pop       ds
         jmp       short HledUl79           ; z†znam se nebude zapisovat

; ------ dek¢dov†n° jmÇna souboru pro LST

HledUl68:mov       di,ss:[bp-14]            ; ukl†dac° adresa do bufferu
         inc       si                       ; zaá†tek jmÇna souboru
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna souboru

; ------ uloëen° koncovÇho CR/LF pro textovÇ reëimy

HledUl77:cld
         mov       ax,CR + LF*HI
         stosw                              ; uloëen° CR/LF na konec ©†dku
         jmp       short HledUl78

; ------ dek¢dov†n° cesty pro DBF

HledUl7: test      byte ptr ds:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HledUl71                 ; je to platn† poloëka

         push      di
         mov       al," "
         mov       cl,105
         rep       stosb                    ; vymaz†n° bufferu
         pop       di
         mov       cl,ds:[si]               ; dÇlka textu cesty
         inc       si                       ; p©eskoáen° bajtu dÇlky
         inc       di                       ; p©eskoáen° p©°znaku z†znamu
         movsb                              ; disk
         inc       si                       ; p©eskoáen° znaku ":"
         inc       si                       ; p©eskoáen° znaku "\"
         sub       cl,3                     ; bez £vodn°ho ROOT
         jc        HledUl70
         rep       movsb                    ; p©enos textu cesty
HledUl70:pop       ds
         jmp       short HledUl79           ; z†znam se nebude zapisovat

; ------ pro oznaáenou poloëku se uloë° "*"

HledUl71:mov       al," "
         test      byte ptr ds:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        HledUl72                 ; nen° oznaáen†
         mov       al,"*"
HledUl72:stosb                              ; uloëen° p©°znaku oznaáen°

; ------ jmÇno a p©°pona souboru

         add       di,1+63                  ; p©eskoáen° disku a cesty
         mov       cl,11                    ; dÇlka jmÇna a p©°pony
         inc       si                       ; p©eskoáen° atributñ
         rep       movsb                    ; p©enos jmÇna a p©°pony

; ------ velikost souboru

         mov       al," "
         mov       cl,10
         rep       stosb                    ; vymaz†n° pole velikosti
         xor       bx,bx                    ; nen° barva ani oddàlovaáe
         mov       ax,word ptr ds:[si+FileSize-12]
         mov       dx,word ptr ds:[si+FileSize+2-12]
         call      far ptr DekNumD          ; dek¢dov†n° á°sla velikosti

; ------ datum

         call      HledUlDD                 ; dek¢dov†n° data pro DBF

; ------ áas

         call      HledUlDT                 ; dek¢dov†n° áasu pro DBF

; ------ atributy

         call      HledUlDA                 ; dek¢dov†n° atributñ DBF

; ------ z†pis jednÇ vàty do souboru (CX bajtñ)

HledUl78:pop       ds                       ; n†vrat DS
         mov       cx,di                    ; koncov† ukl†dac° adresa
         mov       si,sp                    ; zaá†tek bufferu
         sub       cx,si                    ; dÇlka ©†dku
         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr WritFile         ; z†pis jednoho ©†dku
         jnc       HledUl7B                 ; operace OK
         call      far ptr TestBEsc         ; je p©eru®en° ?
         jc        HledUl8                  ; p©eru®en° - konec
         jmp       HledUl4                  ; chyba z†pisu do souboru

; ------ p©°prava pro dal®° z†znam

HledUl7B:add       word ptr ss:[bp-18],1    ; zvò®en° á°taáe z†znamñ DBF
         adc       word ptr ss:[bp-18+2],0
HledUl79:inc       word ptr ss:[bp-12]      ; zvò®en° ukazatele á°sla poloëky

; ------ zobrazen° kurzoru

         inc       word ptr ds:[InfoKCit]   ; á°taá kurzoru
         call      far ptr TestTDis         ; áasovanÇ zobrazen°
         jc        HledUl7A                 ; nen° pot©eba obsluhy
         xor       cx,cx
         call      far ptr InfoKurz         ; zobrazen° kurzoru
HledUl7A:call      far ptr TestBEsc         ; je p©eru®en° ?
         jc        HledUl8                  ; p©eru®en° - konec
         jmp       HledUl6                  ; dal®° ©†dek

; ------ KONEC - ukonáen° z†pisu pro DBF

HledUl8: test      byte ptr ds:[HledUloP],bit2 ; je DBF ?
         jz        HledUl9                  ; nen° DBF

; ------ p©°prava aktu†ln°ho data

         call      far ptr ZapKrit          ; zapnut° kritickÇ sekce

         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         sub       cx,1900
         cmp       cl,100
         jb        HledUl82
         sub       cl,100
HledUl82:mov       ss:[bp-18-3],cl          ; rok
         xchg      dh,dl
         mov       ss:[bp-18-2],dx          ; màs°c a den

; ------ z†pis koncovÇho EOF pro DBF

         mov       si,sp
         push      ss
         pop       es
         mov       byte ptr es:[si],EOF
         mov       cx,1
         mov       ax,ss:[bp-2]
         call      far ptr WritFile         ; z†pis koncovÇho EOF

; ------ z†pis novÇho poátu poloëek pro DBF

         mov       cx,1
         xor       dx,dx
         call      far ptr SetUFile         ; nastaven° ukazatele v souboru
         lea       si,ss:[bp-18-3]
         mov       cl,4+3
         call      far ptr WritFile         ; z†pis data a poátu poloëek

         call      far ptr VypKrit          ; vypnut° kritickÇ sekce

; ------ uzav©en° souboru

HledUl9: mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         call      far ptr InfoClos         ; uzav©en° reëimu operace
         call      far ptr FlushEsc         ; vypr†zdnàn° p©i p©eru®en° ESC
         call      far ptr DispAll

; ------ n†vrat ukazatele z†sobn°ku

         mov       sp,bp
         ret

HledUl   ENDP

; -----------------------------------------------------------------------------
;        uloëen° z†znamu ve form†tu FND
; -----------------------------------------------------------------------------
;˛
HldUFnd  PROC      NEAR

; ------ dek¢dov†n° cesty

         test      byte ptr ds:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HldUFnd1                 ; je to platn† poloëka
         mov       cl,ds:[si]               ; dÇlka textu cesty
         inc       si
         rep       movsb                    ; p©enos textu cesty
         ret

; ------ pro oznaáenou poloëku se uloë° "*"

HldUFnd1:test      byte ptr ds:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        HldUFn12                 ; nen° oznaáen†
         mov       al,"*"
         stosb                              ; uloëen° p©°znaku oznaáen°

; ------ £vodn° tabul†tor

HldUFn12:mov       al,TAB
         stosb

; ------ dek¢dov†n° jmÇna souboru

         mov       cx,di                    ; CX <- ukl†dac° adresa zaá†tku
         add       cx,8                     ; p©°®t° tabulaán° pozice
         inc       si                       ; p©eskoáen° bajtu atributñ
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna souboru ASCIIZ
         dec       si                       ; n†vrat zaá†tku poloëky

; ------ n†hrada mezer ve jmÇnà znakem "?"

         push      di                       ; konec jmÇna souboru
HldUFn14:dec       di                       ; sn°ëen° ukazatele
         cmp       byte ptr es:[di]," "     ; je znak mezery ?
         jne       HldUFn16                 ; nen° mezera
         mov       byte ptr es:[di],"?"     ; n†hrada znakem "?"
HldUFn16:jae       HldUFn14                 ; nen° je®tà £vodn° TAB - dal®° znak
         pop       di

; ------ oddàlovac° tabul†tor

         cld
         mov       al,TAB                   ; znak tabul†toru
         cmp       di,cx                    ; je dal®° tabulaán° pozice ?
         jae       HldUFnd2                 ; je jië dal®° tabulaán° pozice
         stosb                              ; 1. tabul†tor
HldUFnd2:stosb                              ; 2. tabul†tor

; ------ dek¢dov†n° velikosti souboru

         mov       cx,di                    ; CX <- ukl†dac° adresa zaá†tku
         add       cx,8                     ; p©°®t° tabulaán° pozice
         push      dx
         mov       ax,word ptr ds:[si+FileSize]      ; velikost souboru LOW
         mov       dx,word ptr ds:[si+FileSize+2]    ; velikost souboru HIGH
         xor       bx,bx                    ; nen° barva ani oddàlovaá ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° velikosti souboru
         pop       dx

; ------ oddàlovac° tabul†tor

         cld
         mov       al,TAB                   ; znak tabul†toru
         cmp       di,cx                    ; je dal®° tabulaán° pozice ?
         jae       HldUFnd3                 ; je jië dal®° tabulaán° pozice
         stosb                              ; 1. tabul†tor
HldUFnd3:stosb                              ; 2. tabul†tor

; ------ dek¢dov†n° data souboru

         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekA4Dat         ; dek¢dov†n° data souboru

; ------ oddàlovac° tabul†tor

         cld
         mov       al,TAB
         stosb

; ------ dek¢dov†n° áasu souboru

         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekATmS          ; dek¢dov†n° áasu souboru

; ------ oddàlovac° tabul†tor

         cld
         mov       al,TAB
         stosb

; ------ atributy

         mov       bl,ds:[si+FileAtr]       ; atributy souboru
         shl       bl,1                     ; zru®en° bitu 7
         shl       bl,1                     ; zru®en° bitu 6

; ------ atribut ARC

         mov       al,"A"                   ; archivn°
         shl       bl,1                     ; je atribut nastaven ?
         jc        HldUFn41                 ; atribut ARC je nastaven
         mov       al,"."                   ; atribut ARC nen° nastaven
HldUFn41:stosb                              ; uloëen° atributu ARC

; ------ atribut DIR

         mov       al,"D"                   ; adres†©
         shl       bl,1                     ; je atribut nastaven ?
         jc        HldUFn42                 ; atribut DIR je nastaven
         mov       al,"."                   ; atribut DIR nen° nastaven
HldUFn42:stosb                              ; uloëen° atributu DIR

; ------ atribut SYS

         shl       bl,1                     ; zru®en° bitu 3 (VOL)
         mov       al,"S"                   ; systÇmovò
         shl       bl,1                     ; je atribut nastaven ?
         jc        HldUFn43                 ; atribut SYS je nastaven
         mov       al,"."                   ; atribut SYS nen° nastaven
HldUFn43:stosb                              ; uloëen° atributu SYS

; ------ atribut HID

         mov       al,"H"                   ; skrytò
         shl       bl,1                     ; je atribut nastaven ?
         jc        HldUFn44                 ; atribut HID je nastaven
         mov       al,"."                   ; atribut HID nen° nastaven
HldUFn44:stosb                              ; uloëen° atributu HID

; ------ atribut R/O

         mov       al,"R"                   ; R/O
         shl       bl,1                     ; je atribut nastaven ?
         jc        HldUFn45                 ; atribut R/O je nastaven
         mov       al,"."                   ; atribut R/O nen° nastaven
HldUFn45:stosb                              ; uloëen° atributu R/O
         ret

HldUFnd  ENDP

; -----------------------------------------------------------------------------
;        uloëen° data pro DBF
; -----------------------------------------------------------------------------

HledUlDD:add       di,4
         mov       ax,ds:[si+FileDate-12]
         mov       cl,9
         shr       ax,cl
         add       ax,1980
         xor       dx,dx
         xor       bx,bx
         call      far ptr DekNumD          ; dek¢dov†n° roku

         cld
         mov       al,"0"
         stosb
         inc       di
         mov       ax,ds:[si+FileDate-12]
         mov       cl,5
         shr       ax,cl
         and       ax,0fh
         call      far ptr DekNumD          ; dek¢dov†n° màs°ce

         cld
         mov       al,"0"
         stosb
         inc       di
         mov       ax,ds:[si+FileDate-12]
         and       ax,1fh
         call      far ptr DekNumD          ; dek¢dov†n° dne
         ret

; -----------------------------------------------------------------------------
;        uloëen° áasu pro DBF
; -----------------------------------------------------------------------------

HledUlDT:cld
         mov       al,"0"
         stosb
         inc       di
         mov       ax,ds:[si+FileTime-12]
         mov       cl,11
         shr       ax,cl
         xor       dx,dx
         xor       bx,bx
         call      far ptr DekNumD          ; dek¢dov†n° hodiny

         cld
         mov       al,"0"
         stosb
         inc       di
         mov       ax,ds:[si+FileTime-12]
         mov       cl,5
         shr       ax,cl
         and       ax,3fh
         call      far ptr DekNumD          ; dek¢dov†n° minuty

         cld
         mov       al,"0"
         stosb
         inc       di
         mov       ax,ds:[si+FileTime-12]
         and       ax,1fh
         shl       ax,1
         call      far ptr DekNumD          ; dek¢dov†n° sekundy
         ret

; -----------------------------------------------------------------------------
;        uloëen° atributñ pro DBF
; -----------------------------------------------------------------------------

HledUlDA:mov       bl,ds:[si+FileAtr-12]    ; atributy souboru
         shl       bl,1                     ; zru®en° bitu 7
         shl       bl,1                     ; zru®en° bitu 6
         cld

; ------ atribut ARC

         mov       al,"T"                   ; archivn°
         shl       bl,1                     ; je atribut nastaven ?
         jc        HledUlT1                 ; atribut ARC je nastaven
         mov       al,"F"                   ; atribut ARC nen° nastaven
HledUlT1:stosb                              ; uloëen° atributu ARC

; ------ atribut DIR

         mov       al,"T"                   ; adres†©
         shl       bl,1                     ; je atribut nastaven ?
         jc        HledUlT2                 ; atribut DIR je nastaven
         mov       al,"F"                   ; atribut DIR nen° nastaven
HledUlT2:stosb                              ; uloëen° atributu DIR

; ------ atribut SYS

         shl       bl,1                     ; zru®en° bitu 3 (VOL)
         mov       al,"T"                   ; systÇmovò
         shl       bl,1                     ; je atribut nastaven ?
         jc        HledUlT3                 ; atribut SYS je nastaven
         mov       al,"F"                   ; atribut SYS nen° nastaven
HledUlT3:stosb                              ; uloëen° atributu SYS

; ------ atribut HID

         mov       al,"T"                   ; skrytò
         shl       bl,1                     ; je atribut nastaven ?
         jc        HledUlT4                 ; atribut HID je nastaven
         mov       al,"F"                   ; atribut HID nen° nastaven
HledUlT4:stosb                              ; uloëen° atributu HID

; ------ atribut R/O

         mov       al,"T"                   ; R/O
         shl       bl,1                     ; je atribut nastaven ?
         jc        HledUlT5                 ; atribut R/O je nastaven
         mov       al,"F"                   ; atribut R/O nen° nastaven
HledUlT5:stosb                              ; uloëen° atributu R/O
         ret

; -----------------------------------------------------------------------------
;        naáten° seznamu
; -----------------------------------------------------------------------------
;˛
; ------ buffer pro p©edvolbu

HledN:   mov       bp,sp                    ; BP <- £schova ukazatele z†sobn°ku
         sub       sp,FileMax               ; m°sto pro buffer
         push      ss
         pop       es                       ; ES <- SS
         mov       di,sp                    ; buffer v z†sobn°ku

; ------ sestaven° p©edvolby

         mov       word ptr ds:[SHZNMLPA+2],es ; segment bufferu
         mov       word ptr ds:[SHZNMLPA],di ; offset bufferu
         mov       si,offset FindMNam       ; soubor $DOSMAN$.FND
         call      far ptr TempFile         ; sestaven° jmÇna souboru
         sub       di,sp                    ; dÇlka textu
         mov       ds:[SHZNMLPN],di         ; dÇlka jmÇna souboru
         call      HledMPre                 ; p©°prava menu hled†n°

; ------ zad†n° souboru k naáten°

         mov       si,offset SHZNMLin
         mov       dl,ds:[HledUloP]         ; parametry menu
         rol       dl,1
         rol       dl,1                     ; bit p©ep°naáe
         call      far ptr SetSwch          ; nastaven° p©ep°naáe aktualizace
         call      far ptr Lin0Menu         ; volba souborñ k operaci
         mov       word ptr ds:[SHZNMLPN],0 ; zru®en° textu
         mov       sp,bp                    ; n†vrat ukazatele z†sobn°ku
         jnc       HledN1                   ; proveden° operace

HledNX:  jmp       HledX                    ; p©eru®en°

; ------ p©ep°naá - aktualizace naá°t†n°

HledNAA  PROC      FAR

         xor       byte ptr ds:[HledUloP],bit6 ; zmàna p©°znaku aktualizace
         mov       dl,ds:[HledUloP]         ; parametry menu
         rol       dl,1
         rol       dl,1                     ; bit p©ep°naáe
         call      far ptr SetSwch          ; nastaven° p©ep°naáe aktualizace
         call      HledMPre                 ; p©°prava menu hled†n°
         call      far ptr DispMnu          ; novÇ zobrazen° menu
         ret

HledNAA  ENDP

; ------ normalizace jmÇna souboru -> ES:SI/CX

HledN1:  call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr NormFilL         ; normalizace jmÇna souboru
         jcxz      HledNX                   ; nen° nic zad†no
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno souboru
         jcxz      HledNX                   ; nen° nic zad†no
         call      far ptr TestBEsc         ; bylo p©eru®en° ?
         jc        HledNX                   ; p©eru®en° operace

; ------ naáten° souboru

         call      HledNa                   ; naáten° souboru
         jmp       HledNX

; -----------------------------------------------------------------------------
;        naáten° souboru seznamu (do aktivn°ho okna)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno souboru ASCIIZ (dÇlka max. 85 znakñ !)
;        CX=dÇlka jmÇna souboru (nen° = 0)
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) identifik†tor souboru seznamu (0 = nen°)
;                   SS:[BP-4] (2) dÇlka jmÇna souboru seznamu
;                   SS:[BP-6] (2) datovò segment DS
;                   SS:[BP-8] (2) á°slo segmentu okna seznamu
;                   SS:[BP-10] (2) adresa segmentu okna seznamu
;                   SS:[BP-12] (2) ukazatel á°sla poloëky
;                   SS:[BP-14] (2) adresa konce cesty (pro form†t JMêNO)
;                   SS:[BP-18] (4) á°taá poátu z†znamñ DBF
;                   SS:[BP-19] (1) parametry
;                                       bit 0: 1=je form†t DBF
;                                       bit 1: 1=je jië platn† cesta
;                                       bit 2: 1=ukl†d† se cesta (FILEPATH)
;                                       bit 3: 1=ukl†d† se soubor (DTA)
;                                       bit 4: 1=byla poloëka souboru (je FND)
;                                          ;?  bit 5: 1=byla poloëka vytvo©en† z LST
;                   SS:[BP-120] (86) jmÇno souboru seznamu
;            DTA:       SS:[BP-133] (13) dek¢dovanÇ jmÇno souboru ASCIIZ
;                       SS:[BP-137] (4) velikost souboru
;                       SS:[BP-139] (2) datum souboru
;                       SS:[BP-141] (2) áas souboru
;                       SS:[BP-142] (1) atributy souboru
;                   SS:[BP-145] (3)
;                   SS:[BP-250] (105) vstupn° buffer (k naáten° ©†dku DBF)
; neuchov†v† ë†dnÇ registry (jen DS) !!!!
; -----------------------------------------------------------------------------
;˛
HledNa   PROC      NEAR

; ------ buffer lok†ln°ch promànnòch

         mov       bp,sp
         sub       sp,250
         mov       ss:[bp-6],ds             ; datovò segment

; ------ £schova jmÇna souboru do z†sobn°ku

         mov       ss:[bp-4],cx             ; dÇlka jmÇna souboru
         push      ds
         push      es
         push      ss
         pop       es                       ; ES <- segment bufferu
         pop       ds                       ; DS <- segment jmÇna souboru
         inc       cx                       ; váetnà koncovÇ 0
         lea       di,ss:[bp-120]           ; buffer jmÇna souboru
         cld
         rep       movsb                    ; £schova jmÇna souboru
         pop       ds

; ------ inicializace ukazatele poloëek

         xor       ax,ax
         mov       ss:[bp-2],ax             ; nen° otev©en soubor
         mov       ss:[bp-12],ax            ; ukazatel á°sla poloëky
         mov       ss:[bp-18+2],ax          ; á°taá poátu z†znamñ DBF
         mov       ss:[bp-18],ax
         mov       ss:[bp-19],al            ; parametry - nen° DBF

; ------ otev©en° souboru pro áten°

         lea       si,ss:[bp-120]           ; jmÇno souboru
         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jnc       HledNa1                  ; soubor otev©en OK

; ------ chyba - soubor nenalezen

HledNa04:mov       si,offset ChybFndF
HledNa05:call      far ptr Lin0MenF         ; hl†®en° - soubor nenalezen
         call      far ptr SetEsc           ; p©°znak p©eru®en°
         jmp       HledNa9

HledNa1: mov       ss:[bp-2],ax             ; identifik†tor souboru

; ------ p©°prava velikosti souboru

         call      far ptr SizeFile         ; poskytnut° velikosti souboru
         jc        HledNa04                 ; nàjak† chyba
         mov       word ptr ds:[InfoKMax],cx ; velikost souboru LOW
         mov       word ptr ds:[InfoKMax+2],bx ; velikost souboru HIGH
         call      far ptr ResFile          ; resetov†n° ukazatele souboru

; ------ test, zda to je soubor DBF

         mov       di,sp                    ; vstupn° buffer v z†sobn°ku
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       cx,32                    ; 32 bajtñ z†hlav° DBF
         call      far ptr ReadFile         ; naáten° z†hlav° ze souboru
         jc        HledNa04                 ; chyba áten° ?
         cmp       cl,32                    ; je dostateán† dÇlka dat ?
         jne       HledNa16                 ; to nen° soubor DBF
         cmp       byte ptr es:[di],83h     ; DBF s MEMO
         je        HledNa11
         cmp       byte ptr es:[di],0f5h    ; FOXPRO s MEMO
         je        HledNa11
         cmp       byte ptr es:[di],3       ; identifik†tor souboru
         jne       HledNa16                 ; to nen° DBF
HledNa11:cmp       byte ptr es:[di+7],0     ; poáet vàt v souboru max. 16M
         jne       HledNa16                 ; to nen° DBF
         or        byte ptr ss:[bp-19],bit0 ; je form†t DBF

; ------ ovà©en° z†hlav° souboru DBF

         mov       si,offset ChybHleF       ; hl†®en° - chybnò form†t
         cmp       word ptr es:[di+8],offset(HledDBF0-HledDBF) ; kontrola z†hlav°
         jne       HledNa05                 ; chyba
         cmp       word ptr es:[di+10],105  ; dÇlka z†znamu
         jne       HledNa05                 ; chyba

; ------ ovà©en° popisovaáñ DBF

         mov       bx,offset HledNDBT       ; vzorn°k dÇlek
HledNa12:call      far ptr ReadFile         ; naáten° 1 poloëky 32 bajtñ
         jc        HledNa05
         cmp       cl,32                    ; souhlas° dÇlka ?
         jne       HledNa05                 ; chyba
         mov       dl,cs:[bx]               ; vzor dÇlky poloëky
         cmp       es:[di+16],dl            ; souhlas° dÇlka poloëky ?
         jne       HledNa05                 ; dÇlka poloëky nesouhlas°
         inc       bx
         cmp       byte ptr cs:[bx],0       ; je konec tabulky ?
         jne       HledNa12                 ; test dal®° poloëky

; ------ p©eskoáen° znaku CR

         mov       cl,1                     ; 1 znak
         call      far ptr ReadFile         ; naáten° posledn°ho CR
         jmp       short HledNa2

HledNa15:jmp       HledNa9

; ------ nen° to soubor DBF - resetov†n° ukazatele souboru na zaá†tek

HledNa16:call      far ptr ResFile          ; resetov†n° ukazatele souboru

; ------ inicializace okna seznamu

HledNa2: call      HledOpen                 ; otev©en° okna seznamu
         jc        HledNa15                 ; p©eru®en° operace
         mov       byte ptr ds:[FilePath],"?" ; disk nezn†mò
         mov       word ptr ds:[FilePath+1],"\:" ; inicializace na ROOT
         mov       word ptr ds:[FilePthN],3 ; dÇlka cesty
         mov       ax,ds:[SegmAkt]          ; okno seznamu
         call      far ptr InitLWn          ; inicializace seznamu okna
         jc        HledNa15                 ; p©eru®en° operace
         call      far ptr DispAAWn         ; zobrazen° okna

; ------ zobrazen° hl†®en° o naá°t†n°

         call      far ptr InfoClr0         ; vymaz†n° informaán°ho bufferu
         mov       si,offset HledNaT        ; text "Naá°t†m"
         call      far ptr InfoTxt          ; dek¢dov†n° textu
         mov       cx,ss:[bp-4]             ; dÇlka jmÇna souboru
         lea       si,ss:[bp-120]           ; jmÇno souboru
         push      ss
         pop       es                       ; ES <- segment bufferu se jmÇnem
         call      far ptr InfoDek          ; dek¢dov†n° textu cesty
         xor       cx,cx                    ; CX <- 0
         call      far ptr InfoKurz         ; zobrazen° hl†®en°

; ------ p©ednastaven° aktu†ln°ho adres†©e

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset AktPath        ; aktu†ln° adres†©
         mov       di,offset FilePath
         mov       cx,ds:[AktPathN]         ; dÇlka cesty
         mov       ds:[FilePthN],cx
         cld
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; £schova aktu†ln°ho adres†©e

; ------ p©°prava k naáten° seznamu

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         mov       ss:[bp-8],ax             ; á°slo segmentu okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-10],es            ; adresa okna

; ------ p©°znaky uloëen°

         xor       cx,cx                    ; nezbyly ë†dnÇ znaky (pro text.m¢d)

HledNa3: push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         and       byte ptr ss:[bp-19],not bit2+bit3 ; nen° cesta ani soubor
         test      byte ptr ss:[bp-19],bit1 ; byla jië cesta ?
         jnz       HledNa30                 ; byla jië cesta
         or        byte ptr ss:[bp-19],bit2 ; cesta se mus° uloëit

; ------ nulov†n° parametrñ pro jeden soubor

HledNa30:xor       ax,ax
         mov       ss:[bp-133],al           ; jmÇno - nen°
         mov       ss:[bp-137+2],ax         ; velikost HIGH
         mov       ss:[bp-137],ax           ; velikost LOW
         mov       ss:[bp-139],ax           ; datum
         mov       ss:[bp-141],ax           ; áas
         mov       ss:[bp-142],al           ; atributy

; ------ test, zda je form†t DBF

         test      byte ptr ss:[bp-19],bit0 ; je form†t DBF ?
         jnz       HledN302
         jmp       HledNa4                  ; nen° form†t DBF

; ------ naáten° z†znamu DBF

HledN302:call      HledNaR                  ; naáten° dal®°ho z†znamu
         cmp       cx,105
         jae       HledNa31
         jmp       HledNa9                  ; konec dat

; ------ naáten° z†znamu DBF

HledNa31:cmp       byte ptr es:[si],"*"     ; je poloëka oznaáen† ?
         jne       HledNa32                 ; nen° oznaáen†
         or        byte ptr ss:[bp-142],ATRO ; poloëka oznaáen†
HledNa32:inc       si                       ; p©eskoáen° atributu z†znamu

         call      HlNDDsk                  ; naáten° disku pro DBF
         call      HlNDPth                  ; naáten° cesty pro DBF
         call      HlNDNam                  ; naáten° jmÇna a p©°pony souboru
         call      HlNDSiz                  ; naáten° velikosti souboru
         call      HlNDDat                  ; naáten° data souboru
         call      HlNDTim                  ; naáten° áasu souboru
         mov       bl,ARC                   ; atribut ARC
         call      HledNADA                 ; ARC
         call      HledNADA                 ; DIR
         shr       bl,1                     ; p©eskoáen° atributu VOL
         call      HledNADA                 ; SYS
         call      HledNADA                 ; HID
         call      HledNADA                 ; R/O
         or        byte ptr ss:[bp-19],bit3 ; ukl†d† se soubor
         jmp       HledNa7

; ------ test, zda je prvn° znak mezera

HledNa4: call      HledNaZ                  ; naáten° prvn°ho znaku
         jnc       HledNa41                 ; je dal®° znak OK
HledNa40:jmp       HledNa86                 ; konec dat

HledNa41:cmp       al," "
         je        HledNa42
         cmp       al,"*"
         je        HldNa422
         cmp       al,LF
         je        HledNa68

; ------ uloëen° p©ede®lÇ poloëky, je-li form†t LST

         call      HledNL                   ; uloëen° p©ede®lÇ poloëky LST
         jc        HledNa88                 ; chyba pamàti

; ------ naáten° cesty

HledN415:call      HlNZPth                  ; uloëen° cesty
         jmp       short HledNa68

; ------ naáten° souboru ve form†tu FND

HldNa422:or        byte ptr ss:[bp-142],ATRO ; poloëka oznaáen†
HledNa42:call      HlNZNam                  ; naáten° jmÇna souboru
         jc        HledNa68                 ; jmÇno souboru neplat°
         call      HlNZSiz                  ; naáten° velikosti souboru
         call      HlNZDat                  ; naáten° data souboru
         call      HlNZTim                  ; naáten° áasu souboru
         call      HlNZAtr                  ; naáten° atributñ
         or        byte ptr ss:[bp-19],bit3+bit4 ; ukl†d† se soubor (+ p©°znak)

; ------ nalezen° dal®°ho ©†dku (v textovÇm form†tu)

HledNa68:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HledNa7                  ; nen° dal®° znak
         cmp       al,LF                    ; je konec ©†dku LF ?
         jne       HledNa68                 ; nen° konec ©†dku LF - dal®° znak
         inc       si                       ; p©eskoáen° znaku LF
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ uloëen° cesty (ve FilePath)

HledNa7: test      byte ptr ss:[bp-19],bit2 ; ukl†d† se cesta ?
         jz        HledNa8                  ; cesta se neukl†d†
         call      HlNUPth                  ; uloëen° cesty do seznamu
         jc        HledNa88                 ; chyba pamàti

; ------ uloëen° poloëky do seznamu

HledNa8: test      byte ptr ss:[bp-19],bit3 ; ukl†d† se soubor ?
         jz        HledNa84                 ; soubor se neukl†d†
         call      HlNUFil                  ; uloëen° souboru
         jc        HledNa88                 ; chyba pamàti

; ------ obsluha áasovanÇho zobrazen°

HledNa84:call      far ptr TestTDis         ; test áasovanÇho zobrazen°
         jc        HledNa85                 ; nen° pot©eba zobrazen°

         push      cx
         xor       cx,cx                    ; CX <- 0 nen° p©°rustek
         call      far ptr InfoKurz         ; zobrazen° informaán°ho kurzoru
         mov       ax,ds:[SegmAkt]
         call      far ptr AktPathL
         call      far ptr DispAWin         ; zobrazen° okna
         pop       cx

HledNa85:call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        HledNa9                  ; p©eru®en° operace
         jmp       HledNa3                  ; dal®° soubor

; ------ uloëen° posledn° poloëky, je-li form†t LST

HledNa86:call      HledNL                   ; uloëen° poloëky LST
         jnc       HledNa9

; ------ chyba - nedostatek pamàti

HledNa88:mov       ax,ds:[SegmAkt]
         call      ChybaSez                 ; hl†®en° chyby pamàti
         call      far ptr NulBreak         ; nulov†n° p©eru®en° kvñli aktualizaci

; ------ uzav©en° souboru

HledNa9: mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru

         mov       ax,ds:[SegmAkt]
         call      far ptr EndLWn           ; ukonáen° vyhled†v†n° souborñ

         test      byte ptr ds:[HledUloP],bit6 ; je aktualizace ?
         jz        HledNa92                 ; nen° aktualizace
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        HledNa92                 ; je p©eru®en° operace
         call      far ptr DispAWin         ; zobrazen° aktivn°ho okna
         call      HledAkt                  ; aktualizace seznamu
         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

HledNa92:call      far ptr InfoClos         ; uzav©en° reëimu operace


         mov       sp,bp                    ; n†vrat SP !!!!

         call      HledNKur                 ; n†vrat kurzoru po naáten°

         call      far ptr FlushEsc         ; vypr†zdnàn° p©i p©eru®en° ESC
         call      far ptr DispAll

         ret

HledNa   ENDP

HledNDBT db        1,63,8,3,10,8,6,1,1,1,1,1,0 ; dÇlky poloëek

; -----------------------------------------------------------------------------
;        naáten° disku pro DBF
; -----------------------------------------------------------------------------

HlNDDsk  PROC      NEAR

         mov       al,es:[si]               ; disk
         inc       si
         cmp       al,ds:[FilePath]         ; je jinò disk ?
         je        HlNDDsk2                 ; disk nezmànàn
         cmp       al,"A"                   ; minim†ln° disk
         jb        HlNDDsk2                 ; neplatnò disk
         cmp       al,"A"+DiskMax           ; maxim†ln° disk
         jae       HlNDDsk2                 ; neplatnò disk
         mov       byte ptr ds:[FilePath],al ; novò disk
         mov       byte ptr ds:[FilePath+3],0 ; oznaáen° konce cesty
         mov       byte ptr ds:[FilePthN],3 ; dÇlka cesty - ROOT
         or        byte ptr ss:[bp-19],bit2 ; cesta se bude ukl†dat
HlNDDsk2:ret

HlNDDsk  ENDP

; -----------------------------------------------------------------------------
;        naáten° cesty pro DBF
; -----------------------------------------------------------------------------

HlNDPth  PROC      NEAR

; ------ £schova registrñ

         cld
         push      si

; ------ zji®tàn° dÇlky cesty -> CX

         mov       cx,63                    ; max. dÇlka poloëky
         mov       di,si                    ; DI <- zaá†tek cesty
         add       di,cx                    ; adresa konce cesty
HlNDPth2:dec       di                       ; sn°ëen° ukazatele poloëky
         cmp       byte ptr es:[di]," "     ; nalezen konec ?
         ja        HlNDPth4                 ; nalezen konec cesty
         loop      HlNDPth2                 ; dal®° znak

; ------ porovn†n° dÇlky cesty

HlNDPth4:mov       di,ds:[FilePthN]         ; dÇlka cesty
         sub       di,3                     ; bez ROOT
         cmp       di,cx                    ; je shodn† dÇlka cesty ?
         jne       HlNDPth5                 ; nen° shodn† dÇlka cesty

; ------ porovn†n° shodnosti cesty

         push      cx
         push      si
         mov       di,si                    ; DI <- zaá†tek cesty
         mov       si,offset FilePath+3     ; ukazatel cesty
         repe      cmpsb                    ; porovn†n° cesty
         pop       si
         pop       cx
         je        HlNDPth8                 ; cesta je shodn† OK

; ------ uloëen° novÇ cesty

HlNDPth5:mov       di,offset FilePath+3     ; adresa bufferu k uloëen° cesty
         push      ds
         push      es

         push      ds
         push      es
         pop       ds
         pop       es
         rep       movsb                    ; p©enos cesty

         pop       es
         pop       ds

         mov       byte ptr ds:[di],0       ; koncov† 0
         sub       di,offset FilePath
         mov       ds:[FilePthN],di         ; dÇlka textu adres†©e
         or        byte ptr ss:[bp-19],bit2 ; cesta se bude ukl†dat

; ------ n†vrat registrñ

HlNDPth8:pop       si
         add       si,63                    ; p©eskoáen° poloëky cesty
         ret

HlNDPth  ENDP

; -----------------------------------------------------------------------------
;        naáten° jmÇna a p©°pony souboru DBF
; -----------------------------------------------------------------------------

HlNDNam  PROC      NEAR

         push      ds
         push      ss
         pop       ds                       ; DS <- segment bufferu s poloëkou
         lea       di,ss:[bp-133]           ; buffer jmÇna ASCIIZ
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna souboru
         pop       ds
         add       si,11                    ; p©eskoáen° poloëek jmÇna a p©°pony
         ret

HlNDNam  ENDP

; -----------------------------------------------------------------------------
;        naáten° velikosti souboru DBF
; -----------------------------------------------------------------------------

HlNDSiz  PROC      NEAR

         mov       cx,10                    ; poáet znakñ na velikost
         call      HledNaDN                 ; naáten° velikosti souboru
         mov       ss:[bp-137],ax           ; velikost souboru
         mov       ss:[bp-137+2],dx
         ret

HlNDSiz  ENDP

; -----------------------------------------------------------------------------
;        naáten° data souboru DBF
; -----------------------------------------------------------------------------

HlNDDat  PROC      NEAR

; ------ naáten° roku

         mov       cl,4                     ; 4 á°slice na rok
         call      HledNaDN                 ; naáten° roku
         cmp       ax,80
         jae       HlNDDat1
         add       ax,2000
HlNDDat1:cmp       ax,100                   ; jsou jen 2 á°slice ?
         jae       HlNDDat2
         add       ax,1900                  ; korekce
HlNDDat2:cmp       ax,1000                  ; jsou jen 3 á°slice ?
         jae       HlNDDat3
         add       ax,1000                  ; korekce
HlNDDat3:sub       ax,1980                  ; offset od roku 1980
         jnc       HlNDDat4                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° p©i podteáen°
HlNDDat4:cmp       ax,127
         jbe       HlNDDat5
         mov       ax,127                   ; omezen° p©i p©eteáen°
HlNDDat5:mov       cl,9                     ; poáet rotac°
         shl       ax,cl                    ; rotace na pozici
         mov       ss:[bp-139],ax           ; rok

; ------ naáten° màs°ce

         mov       cl,2                     ; 2 á°slice na màs°c
         call      HledNaDN                 ; naáten° màs°ce
         cmp       al,15                    ; je £daj OK ?
         jb        HlNDDat6                 ; £daj je OK
         mov       al,15                    ; omezen°
HlNDDat6:mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; rotace na pozici
         or        ss:[bp-139],ax           ; màs°c

; ------ naáten° dne

         mov       cl,2                     ; 2 á°slice na den
         call      HledNaDN                 ; naáten° dne
         cmp       al,31                    ; je £daj OK ?
         jb        HlNDDat7                 ; £daj je OK
         mov       al,31                    ; omezen°
HlNDDat7:or        ss:[bp-139],al           ; den
         ret

HlNDDat  ENDP

; -----------------------------------------------------------------------------
;        naáten° áasu souboru DBF
; -----------------------------------------------------------------------------

HlNDTim  PROC      NEAR

; ------ naáten° hodiny

         mov       cl,2                     ; 2 á°slice na hodinu
         call      HledNaDN                 ; naáten° hodiny
         cmp       al,31                    ; je £daj OK ?
         jb        HlNDTim2                 ; je OK
         mov       al,31                    ; omezen°
HlNDTim2:mov       cl,11                    ; poáet rotac°
         shl       ax,cl                    ; rotace hodiny na pozici
         mov       ss:[bp-141],ax           ; hodina

; ------ naáten° minuty

         mov       cl,2                     ; 2 á°slice na minutu
         call      HledNaDN                 ; naáten° minuty
         cmp       al,63                    ; je £daj OK ?
         jb        HlNDTim3                 ; je OK
         mov       al,63                    ; omezen°
HlNDTim3:mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; rotace minuty na pozici
         or        ss:[bp-141],ax           ; minuta

; ------ naáten° sekundy

         mov       cl,2                     ; 2 á°slice na sekundu
         call      HledNaDN                 ; naáten° sekundy
         cmp       al,63                    ; je £daj OK ?
         jb        HlNDTim4                 ; je OK
         mov       al,63                    ; omezen°
HlNDTim4:shr       ax,1                     ; korekce / 2
         or        ss:[bp-141],al           ; sekunda
         ret

HlNDTim  ENDP

; -----------------------------------------------------------------------------
;        naáten° jednoho atributu z ES:SI pro form†t DBF, maska BL
; -----------------------------------------------------------------------------

HledNaDA PROC      NEAR

         mov       al,es:[si]               ; p©ipravenò znak
         inc       si                       ; zvò®en° ukazatele znakñ
         cmp       al,"N"                   ; je vypnuto ?
         je        HledNDA2                 ; je vypnuto
         cmp       al,"F"                   ; je vypnuto ?
         je        HledNDA2                 ; je vypnuto
         cmp       al," "                   ; je mezera = vypnuto ?
         je        HledNDA2                 ; mezera je jako vypnuto
         or        ss:[bp-142],bl           ; jinak nastaven° atributu
HledNDA2:shr       bl,1                     ; p©°prava masky pro dal®° bit
         ret

HledNaDA ENDP

; -----------------------------------------------------------------------------
;        naáten° cesty v m¢du TXT (AL=prvn° znak, nesm° to bòt LF)
; -----------------------------------------------------------------------------

HlNZPth  PROC      NEAR

; ------ p©°prava aktu†ln°ho adres†©e

         push      cx
         push      si
         push      es

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset AktPath        ; aktu†ln° adres†©
         mov       di,offset FilePath
         mov       cx,ds:[AktPathN]         ; dÇlka cesty
         mov       ds:[FilePthN],cx
         cld
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; £schova aktu†ln°ho adres†©e

         pop       es
         pop       si
         pop       cx

; ------ p©°prava ukl†dac° adresy, nen°-li zad†n ROOT

         dec       di                       ; n†vrat na koncovou 0
         cmp       byte ptr ds:[di-1],"\"   ; je oddàlovaá "\" ?
         je        HlNZPth1                 ; je jië oddàlovaá "\"
         mov       byte ptr ds:[di],"\"     ; uloëen° oddàlovaáe "\"
         inc       di                       ; posun ukl†dac° adresy

; ------ uloëen° oznaáen° disku (je-li dal®° znak ":")

HlNZPth1:mov       ah,al                    ; AH <- £schova prvn°ho znaku
         call      HledNaZ                  ; naáten° dal®°ho znaku
         xchg      al,ah                    ; AL <- n†vrat prvn°ho znaku
         jc        HlNZPth3                 ; nen° dal®° znak
         cmp       ah,":"                   ; je dal®° znak ":" ?
         je        HlNZPth2                 ; je to oznaáen° disku
         dec       si                       ; n†vrat ukazatele textu
         inc       cx                       ; n†vrat á°taáe znakñ
         jmp       short HlNZPth3
HlNZPth2:cmp       al,"A"                   ; je to platnò disk ?
         jb        HlNZPt22                 ; nen° to platnò disk
         cmp       al,"A"+DiskMax           ; je to platnò disk ?
         jae       HlNZPt22                 ; nen° to platnò disk
         mov       byte ptr ds:[FilePath],al ; uloëen° oznaáen° disku
HlNZPt22:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HlNZPth6                 ; nen° dal®° znak

; ------ test, zda je zad†n ROOT (zaá†tek s "\")

HlNZPth3:cmp       al,"\"                   ; je adres†© od ROOT ?
         jne       HlNZPth5                 ; nen° zad†n ROOT
         mov       di,offset FilePath+3     ; ukl†dac° adresa od ROOT

; ------ naáten° dal®°ho znaku

HlNZPth4:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HlNZPth6                 ; nen° dal®° znak
HlNZPth5:cmp       al,LF
         je        HlNZPth6                 ; konec ©†dku

; ------ uloëen° znaku do bufferu

         mov       ds:[di],al               ; uloëen° znaku do bufferu
         inc       di                       ; zvò®en° ukazatele znakñ
         cmp       di,offset FilePath + FileMax ; je jië maxim†ln° dÇlka ?
         jb        HlNZPth4                 ; nen° je®tà maxim†ln° dÇlka

; ------ vypu®tàn° koncovòch mezer

HlNZPth6:cmp       byte ptr ds:[di-1]," "
         ja        HlNZPth7
         dec       di
         jmp       short HlNZPth6

; ------ vypu®tàn° koncovÇho "\"

HlNZPth7:cmp       byte ptr ds:[di-1],"\"
         jne       HlNZPth8
         cmp       byte ptr ds:[di-2],":"
         je        HlNZPth8
         dec       di

; ------ uloëen° dÇlky cesty

HlNZPth8:mov       byte ptr ds:[di],0       ; koncov† 0
         sub       di,offset FilePath       ; dÇlka cesty
         mov       ds:[FilePthN],di
         or        byte ptr ss:[bp-19],bit2 ; cesta se bude ukl†dat
         and       byte ptr ss:[bp-19],not bit4 ; nebyla poloëka souboru
         ret

HlNZPth  ENDP

; -----------------------------------------------------------------------------
;        naáten° jmÇna souboru TXT (CY=neplat°)
; -----------------------------------------------------------------------------

HlNZNam  PROC      NEAR

; ------ vypu®tàn° mezer p©ed jmÇnem souboru

HlNZNam1:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HlNZNam9                 ; nen° dal®° znak
         cmp       al," "
         je        HlNZNam1                 ; mezera - vypu®tàn°
         cmp       al,LF                    ; je konec ©†dku ?
         stc                                ; p©°znak chyby
         je        HlNZNam9                 ; LF - konec ©†dku

; ------ uloëen° znaku do bufferu jmÇna souboru

         lea       di,ss:[bp-133]           ; buffer jmÇna souboru
         xor       bx,bx                    ; BX <- 0 á°taá dÇlky jmÇna
HlNZNam2:cmp       bl,12                    ; je jië maxim†ln° dÇlka jmÇna ?
         jae       HlNZNam4                 ; je jië maxim†ln° dÇlka jmÇna
         cmp       al,"?"                   ; je n†hradn° znak za mezeru ?
         jne       HlNZNam3                 ; nen° n†hradn° znak
         mov       al," "                   ; n†hrada znakem mezery
HlNZNam3:mov       ss:[di],al               ; uloëen° znaku do bufferu
         inc       di                       ; zvò®en° ukazatele v bufferu
         inc       bx                       ; zvò®en° á°taáe znakñ

; ------ naáten° dal®°ho znaku

HlNZNam4:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HlNZNam8                 ; nen° dal®° znak
         cmp       al," "                   ; je konec jmÇna souboru ?
         ja        HlNZNam2                 ; je platnò znak - uloëen° znaku
HlNZNam8:mov       byte ptr ss:[di],0       ; oznaáen° konce jmÇna souboru
         clc                                ; p©°znak operace OK
HlNZNam9:ret

HlNZNam  ENDP

; -----------------------------------------------------------------------------
;        naáten° velikosti souboru TXT
; -----------------------------------------------------------------------------

HlNZSiz  PROC      NEAR

         call      HledNaZN                 ; naáten° velikosti souboru
         mov       ss:[bp-137],ax
         mov       ss:[bp-137+2],dx
         ret

HlNZSiz  ENDP

; -----------------------------------------------------------------------------
;        naáten° data souboru TXT
; -----------------------------------------------------------------------------

HlNZDat  PROC      NEAR

; ------ naáten° data -> BX-DX-AX

         call      HledNaZW                 ; prvn° á°slo
         xchg      ax,bx                    ; BX <- prvn° á°slo
         call      HledNaZW                 ; druhÇ á°slo
         xchg      ax,dx                    ; DX <- druhÇ á°slo
         call      HledNaZW                 ; AX <- t©et° á°slo

; ------ n†rodnostn° korekce data

         cmp       byte ptr ds:[FormDat],1  ; je evropskò form†t ?
         je        HlNZDat2                 ; je evropskò form†t
         xchg      bx,dx                    ; po©ad°: DX-BX-AX
         jb        HlNZDat2                 ; form†t USA
         xchg      ax,bx                    ; po©ad°: DX-AX-BX
         xchg      ax,dx                    ; po©ad°: AX-DX-BX

; ------ omezen° dne -> BL

HlNZDat2:cmp       bx,31
         jb        HlNZDat3
         mov       bl,31

; ------ omezen° màs°ce -> DX

HlNZDat3:cmp       dx,15
         jb        HlNZDat4
         mov       dx,15

; ------ korekce roku (AX) p©i ne£plnÇm zad†n°

HlNZDat4:cmp       ax,80
         jae       HlNZDt42
         add       ax,2000
HlNZDt42:cmp       ax,100
         jae       HlNZDat5
         add       ax,1900
HlNZDat5:cmp       ax,1000
         jae       HlNZDat6
         add       ax,1000

; ------ omezen° roku -> AL

HlNZDat6:sub       ax,1980                  ; offset od 1980
         jnc       HlNZDat7                 ; nen° podteáen°
         xor       ax,ax                    ; omezen° p©i podteáen°
HlNZDat7:cmp       al,127                   ; je p©eteáen° ?
         jb        HlNZDat8
         mov       al,127                   ; omezen° p©i p©eteáen°

; ------ uloëen° data

HlNZDat8:shl       al,1                     ; rotace roku na pozici / 256
         push      cx
         mov       cl,5                     ; poáet rotac°
         shl       dx,cl                    ; rotace màs°ce na pozici
         pop       cx
         or        dh,al                    ; rok
         or        dl,bl                    ; den
         mov       ss:[bp-139],dx           ; datum souboru
HlNZDat9:ret

HlNZDat  ENDP

; -----------------------------------------------------------------------------
;        naáten° áasu souboru TXT
; -----------------------------------------------------------------------------

HlNZTim  PROC      NEAR

; ------ naáten° hodiny -> DX

         call      HledNaZW                 ; naáten° hodiny
         cmp       ax,31                    ; maxim†ln° hodina
         jb        HlNZTim1                 ; £daj je OK
         mov       ax,31                    ; omezen° hodiny
HlNZTim1:xchg      ax,dx                    ; DX <- £schova hodiny

; ------ naáten° minuty -> BX

         call      HledNaZW                 ; naáten° minuty
         cmp       ax,63                    ; maxim†ln° minuta
         jb        HlNZTim2                 ; £daj je OK
         mov       ax,63                    ; omezen° minuty
HlNZTim2:xchg      ax,bx                    ; BX <- £schova minuty

; ------ naáten° sekundy -> AX

         call      HledNaZW                 ; naáten° sekundy
         cmp       ax,63                    ; maxim†ln° sekunda
         jb        HlNZTim3                 ; £daj je OK
         mov       ax,63                    ; omezen° sekundy

; ------ uloëen° áasu

HlNZTim3:push      cx
         shr       ax,1                     ; sekunda / 2
         mov       cl,5                     ; poáet rotac° pro minuty
         shl       bx,cl                    ; rotace minut na pozici
         or        ax,bx                    ; minuty + sekundy
         mov       cl,11                    ; poáet rotac° pro hodiny
         shl       dx,cl                    ; rotace hodiny na pozici / 256
         or        ax,dx                    ; p©id†n° hodin
         mov       ss:[bp-141],ax           ; áas souboru
         pop       cx
         ret

HlNZTim  ENDP

; -----------------------------------------------------------------------------
;        naáten° atributñ TXT
; -----------------------------------------------------------------------------

HlNZAtr  PROC      NEAR

; ------ vypu®tàn° mezer

         mov       dx,5                     ; á°taá atributñ k naáten°
HlNZAtr2:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HlNZAtr9                 ; nen° dal®° znak
         cmp       al,LF                    ; je konec ©†dku ?
         je        HlNZAtr9                 ; je konec ©†dku
         cmp       al," "                   ; je mezera ?
         je        HlNZAtr2                 ; je mezera - vypu®tàn°

; ------ dek¢dov†n° znaku (zapnut° atributu)

         mov       ah,ARC
         cmp       al,"A"
         je        HlNZatr3                 ; je ARC

         mov       ah,DIR
         cmp       al,"D"
         je        HlNZAtr3                 ; je DIR

         mov       ah,SYS
         cmp       al,"S"
         je        HlNZAtr3                 ; je SYS

         mov       ah,HID
         cmp       al,"H"
         je        HlNZAtr3                 ; je HID

         mov       ah,RO
         cmp       al,"R"
         jne       HlNZAtr4                 ; nen° R/O

HlNZAtr3:or        ss:[bp-142],ah           ; zapnut° atributu
HlNZAtr4:dec       dx                       ; á°taá znakñ atributñ
         jnz       HlNZAtr2                 ; dek¢dov†n° dal®°ho znaku

HlNZAtr9:ret

HlNZAtr  ENDP

; -----------------------------------------------------------------------------
;        naáten° znaku z bufferu TXT
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=ukazatel bufferu
;        CX=poáet zbylòch znakñ
; VùSTUP: AL=znak (pro LF se neposouvaj° ukazatele SI a CX)
;         CY=nen° dal®° znak
; -----------------------------------------------------------------------------

HledNaZ  PROC      NEAR

HledNaZ1:jcxz      HledNaZ4                 ; nen° dal®° znak
HledNaZ2:mov       al,es:[si]               ; p©ipravenò znak
         cmp       al,LF                    ; je konec ©†dku ?
         je        HledNaZ3                 ; pro LF se nezvy®uje ukazatel
         dec       cx                       ; á°taá znakñ
         inc       si                       ; ukazatel znakñ
         cmp       al,TAB                   ; je tabul†tor ?
         jne       HledNZ22                 ; nen° tabul†tor
         mov       al," "                   ; n†hrada mezerou
HledNZ22:cmp       al," "
         jb        HledNaZ1                 ; takovÇ znaky se ignoruj°
;         clc                                ; p©°znak - je platnò znak
HledNaZ3:ret

HledNaZ4:call      HledNaR                  ; naáten° dal®°ho ©†dku ze souboru
         jnc       HledNaZ2                 ; je dal®° znak OK
         mov       al,0
         ret

HledNaZ  ENDP

; -----------------------------------------------------------------------------
;        naáten° bufferu ze souboru -> ES:SI=novò ukazatel, CX=poáet znakñ, CY=konec
; -----------------------------------------------------------------------------

HledNaR  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      di

; ------ naáten° obsahu bufferu

         lea       di,ss:[bp-250]           ; vstupn° buffer
         mov       si,di                    ; SI <- adresa bufferu
         mov       cx,105                   ; dÇlka bufferu
         push      ss
         pop       es                       ; ES <- z†sobn°k
         mov       ax,ss:[bp-2]             ; identifik†tor souboru
         call      far ptr ReadFile         ; naáten° z†znamu
         cmp       cl,1                     ; jsou nàjak† data ?
         jb        HledNaR4                 ; konec souboru (pop©. chyba)
         add       word ptr ds:[InfoKCit],cx ; á°taá kurzoru
         adc       word ptr ds:[InfoKCit+2],0

; ------ konverze bufferu na velk† p°smena

         push      cx
HledNaR2:mov       al,es:[di]               ; znak v bufferu
         call      far ptr UpCase           ; konverze na velkÇ p°smeno
         clc
         stosb                              ; uloëen° znaku
         loop      HledNaR2                 ; dal®° znak
         pop       cx
         clc

; ------ n†vrat registrñ

HledNaR4:pop       di
         pop       ax
         cld
         ret

HledNaR  ENDP

; -----------------------------------------------------------------------------
;        uloëen° cesty do seznamu (CY=chyba pamàti)
; -----------------------------------------------------------------------------

HlNUPth  PROC      NEAR

; ------ uloëen° cesty s indexem zobrazen°

         mov       es,ss:[bp-10]            ; adresa segmentu okna
         mov       bl,byte ptr es:[AWinFndA]         ; ukl†dac° adresa poloëky
         mov       dx,word ptr es:[AWinFndA+2]
         call      PathLWn                  ; vloëen° cesty do seznamu
         jc        HlNUPth9                 ; nedostatek pamàti
         call      PathLIZ                  ; uloëen° indexu pro zobrazen°
         jc        HlNUPth9                 ; nedostatek pamàti

; ------ aktualizace diskovòch informac°

         test      byte ptr ss:[bp-19],bit1 ; byla jië cesta ?
         jnz       HlNUPth8                 ; byla jië cesta
         or        byte ptr ss:[bp-19],bit1 ; byla jië cesta

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        HlNUPth8                 ; je p©eru®en° operace

         mov       al,ds:[FilePath]
         sub       al,"A"
         call      far ptr TestDisk         ; test platnosti disku
         jc        HLNuPth8                 ; disk neplatnò

         push      cx
         mov       es:[AWinDisk],al         ; disk okna
         mov       di,AWinLab               ; buffer n†và®t° disku
         call      far ptr GetVol           ; poskytnut° n†và®t° disku
         mov       es:[AWinLabN],cl         ; dÇlka n†và®t°
         mov       ax,ss:[bp-8]             ; á°slo segmentu okna
         call      far ptr InitDInf         ; inicializace diskovòch informac°
         pop       cx
         call      far ptr NulBreak         ; nulov†n° p©°padnÇho p©eru®en°

HlNUPth8:clc                                ; p©°znak operace OK
HlNUPth9:ret

HlNUPth  ENDP

; -----------------------------------------------------------------------------
;        uloëen° poloëky souboru do seznamu (CY=chyba pamàti)
; -----------------------------------------------------------------------------

HlNUFil  PROC      NEAR

         push      si
         lea       si,[bp-142]              ; offset bufferu DTA - zaá†tek dat
         mov       es,ss:[bp-10]
         mov       bl,byte ptr es:[AWinFndA]         ; ukl†dac° adresa poloëky
         mov       dx,word ptr es:[AWinFndA+2]
         call      PathLSt                  ; uloëen° poloëky
         pop       si
         jc        HlNUFil9                 ; chyba - p©eteáen° pamàti

         call      PathLIZ                  ; uloëen° indexu pro zobrazen°
         jc        HlNUFil9                 ; chyba - p©eteáen° pamàti

         mov       bx,es:[AWinSouN]
         dec       bx
         mov       dx,es                    ; adresa okna
         call      far ptr GetPolDI
         call      PathLFl                  ; uloëen° parametrñ souboru
         clc                                ; p©°znak operace OK
HlNUFil9:ret

HlNUFil  ENDP

; -----------------------------------------------------------------------------
;        uloëen° poloëky, je-li form†t LST (CY=chyba pamàti)
; -----------------------------------------------------------------------------

HledNL   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ test, zda m† bòt soubor uloëen

         test      byte ptr ss:[bp-19],bit1 ; je to prvn° cesta ?
         jz        HledNL2                  ; je to prvn° cesta
         test      byte ptr ss:[bp-19],bit4 ; byla jië poloëka souboru ?
         jnz       HledNL2                  ; byla jië nàjak† poloëka
         or        byte ptr ss:[bp-19],bit4 ; p©°znak, ëe je poloëka souboru

; ------ adresa posledn° poloëky (màla by to bòt cesta se souborem na konci)

         mov       es,ss:[bp-10]            ; adresa segmentu okna
         mov       bx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         dec       bx                       ; á°slo posledn° poloëky
         call      far ptr GetESPol         ; adresa poloëky ES:SI
         jc        HledNL2                  ; nen° ë†dn† poloëka (???)

         mov       ch,0
         mov       cl,es:[si]               ; dÇlka textu poloëky
         test      cl,ATRT                  ; je to cesta ?
         jnz       HledNL2                  ; nen° to cesta

         inc       si                       ; zaá†tek textu poloëky
         jcxz      HledNL2                  ; m† dÇlku 0 (???)

; ------ nalezen° konce jmÇna v poloëce

         mov       bx,si                    ; £schova adresy zaá†tku poloëky
         add       si,cx                    ; konec textu poloëky
         xor       dx,dx                    ; á°taá dÇlky jmÇna
HledNL1: dec       si                       ; sn°ëen° ukazatele v poloëce
         cmp       byte ptr es:[si],"\"     ; je oddàlovaá cesty ?
         je        HledNL3                  ; nalezen oddàlovaá cesty
         inc       dx                       ; zvò®en° á°taáe dÇlky jmÇna
         loop      HledNL1                  ; dal®° znak cesty

HledNL2: clc                                ; p©°znak operace OK
         jmp       HledNL9                  ; konec

HledNL3: or        dx,dx                    ; je dÇlka jmÇna OK ?
         jz        HledNL2                  ; chyba dÇlky jmÇna

; ------ p©enesen° jmÇna poloëky do bufferu

         cmp       dl,12                    ; max. dÇlka jmÇna poloëky
         jbe       HledNL32
         mov       dl,12                    ; omezen° dÇlky jmÇna poloëky
HledNL32:push      si
         lea       di,ss:[bp-133]           ; buffer jmÇna poloëky
HledNL4: inc       si
         mov       al,es:[si]
         mov       ss:[di],al               ; p©enesen° jmÇna poloëky
         inc       di
         dec       dx                       ; á°taá znakñ
         jnz       HledNL4                  ; dal®° znak
         mov       byte ptr ss:[di],0       ; oznaáen° konce poloëky
         pop       si                       ; adresa oddàlovaáe "\"

; ------ oprava dÇlky poloëky

         cmp       byte ptr es:[si-1],":"   ; je to ROOT ?
         jne       HledNL5                  ; nen° to ROOT
         inc       si                       ; pro ROOT se znak "\" ponech†

HledNL5: mov       ax,si                    ; adresa konce cesty
         sub       ax,bx                    ; nov† dÇlka cesty
         mov       es:[bx-1],al             ; nov† dÇlka cesty
         add       ax,bx                    ; adresa konce cesty

; ------ test, zda cesta jië existuje (jako p©ede®l† cesta)

         push      es
         push      ds

         push      es
         pop       ds                       ; DS <- segment poloëky cesty
         mov       si,bx                    ; SI <- zaá†tek textu poloëky cesty
         mov       dx,bx                    ; DX <- zaá†tek textu poloëky cesty
         dec       si                       ; zaá†tek poloëky cesty
         mov       ch,0
         mov       cl,ds:[si]               ; CX <- dÇlka textu poloëky
         inc       cx                       ; váetnà £vodn°ho bajtu dÇlky

         mov       es,ss:[bp-10]            ; adresa segmentu okna
         mov       bx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         dec       bx                       ; posledn° poloëka
HledNL6: dec       bx                       ; sn°ëen° á°sla poloëky
         mov       es,ss:[bp-10]            ; adresa segmentu okna
         call      far ptr GetPolDI         ; adresa poloëky ES:DI
         jc        HledNL8                  ; nen° dal®° poloëka
         test      byte ptr es:[di+FileAtr],ATRT ; je to cesta ?
         jnz       HledNL6                  ; nalezen° p©ede®lÇ cesty

         cld
         repe      cmpsb                    ; porovn†n° cest
         jne       HledNL8                  ; cesty nejsou shodnÇ

         mov       es,ss:[bp-10]            ; adresa segmentu okna
         dec       word ptr es:[AWinSouN]   ; zru®en° poloëky cesty
         mov       ax,dx                    ; zaá†tek textu poloëky
         dec       ax                       ; zaá†tek poloëky

HledNL8: pop       ds
         pop       es

; ------ nov† ukl†dac° adresa do seznamu

         mov       bx,ax                    ; BX <- offset ukl†dac° adresy
         mov       cx,es                    ; CX <- segment ukl†dac° adresy
         sub       cx,ss:[bp-10]            ; segment ukl†dac° adresy relativnà
         and       ax,0fh                   ; normalizace offsetu ukl†dac° adresy
         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©evod offsetu na segment
         add       cx,bx                    ; normalizace segmentu adresy
         mov       es,ss:[bp-10]            ; adresa okna
         mov       word ptr es:[AWinFndA],ax         ; offset ukl†dac° adresy
         mov       word ptr es:[AWinFndA+2],cx       ; segment ukl†dac° adresy

; ------ uloëen° poloëky souboru

         call      HlNUFil                  ; uloëen° poloëky souboru do seznamu

; ------ n†vrat registrñ

HledNL9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HledNL   ENDP

; -----------------------------------------------------------------------------
; aktualizace souborñ seznamu v aktivn°m oknà (nevypne inf.©†dek,nezobraz° okno)
; -----------------------------------------------------------------------------
; uchov†v† DS a BP !
; -----------------------------------------------------------------------------

HledAkt  PROC      NEAR

; ------ adresa okna seznamu

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr GetDat           ; adresa aktivn°ho okna
         jc        HledAkt0                 ; nen° platnÇ okno ?
         mov       dx,es                    ; DX <- £schova adresy okna
         test      byte ptr es:[AWinPrm1],bit5 ; je seznam ?
         jnz       HledAkt1                 ; je seznam OK
HledAkt0:jmp       HledAkt9                 ; nen° seznam

; ------ p©°prava ukazatele kurzoru (poáet poloëek celkem)

HledAkt1:mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         mov       word ptr ds:[InfoKMax],ax ; max. kurzoru
         mov       word ptr ds:[InfoKMax+2],0

; ------ zobrazen° hl†®en°

         call      far ptr InfoClr0         ; vymaz†n° bufferu informaán°ho ©†dku
         mov       si,offset HledAktT       ; text "Aktualizuji seznam"
         call      far ptr InfoTxt          ; dek¢dov†n° textu hl†®en°
         xor       cx,cx
         call      far ptr InfoKurz         ; p©°prava a zobrazen° kurzoru

; ------ p©°prava registrñ

         push      ds
         pop       es
         mov       si,offset AktPath
         mov       di,offset FilePath
         mov       cx,ds:[AktPathN]
         mov       ds:[FilePthN],cx
         inc       cx
         cld
         rep       movsb                    ; inicializace na aktivn° adres†©
         xor       bx,bx                    ; ukazatel poloëek okna

; ------ adresa dal®° poloëky

HledAkt2:mov       es,dx                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa dal®° poloëky
         jc        HledAkt0                 ; nen° dal®° poloëka

; ------ aktualizace cesty

         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HledAkt4                 ; nen° to cesta
         mov       ch,0
         mov       cl,es:[si]               ; dÇlka cesty
         jcxz      HledAkt7                 ; (blbost ?)
         inc       si                       ; zaá†tek cesty
         mov       di,offset FilePath       ; buffer cesty
         mov       ds:[FilePthN],cx         ; nov† dÇlka cesty
HledAkt3:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         loop      HledAkt3
         jmp       short HledAkt7

; ------ p©°prava konce cesty pro poloëku

HledAkt4:mov       di,offset FilePath       ; buffer cesty
         add       di,ds:[FilePthN]         ; konec cesty
         cmp       byte ptr ds:[di-1],"\"   ; je koncovò znak "\" ?
         je        HledAkt5                 ; je jië koncovò "\"
         mov       byte ptr ds:[di],"\"     ; koncovò znak "\"
         inc       di

; ------ dek¢dov†n° poloëky do bufferu

HledAkt5:push      es
         push      si

         push      ds
         inc       si                       ; zaá†tek jmÇna poloëky
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment bufferu
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna poloëky
         pop       ds

; ------ ovà©en° poloëky

         mov       si,offset FilePath
         call      far ptr ExisFile         ; ovà©en° poloëky

         pop       si
         pop       es
         jc        HledAkt7                 ; poloëka asi nenalezena

; ------ aktualizace parametrñ poloëky

         and       cl,not ATRO+ATRU+ATRT    ; nulov†n° nepot©ebnòch p©°znakñ
         and       byte ptr es:[si+FileAtr],ATRO+ATRU+ATRT
         or        es:[si+FileAtr],cl       ; novÇ p©°znaky
         mov       ax,word ptr ds:[BuffDTA+DTATime] ; áas
         mov       es:[si+FileTime],ax      ; áas
         mov       ax,word ptr ds:[BuffDTA+DTADate] ; datum
         mov       es:[si+FileDate],ax      ; datum
         mov       ax,word ptr ds:[BuffDTA+DTASize] ; velikost LOW
         mov       word ptr es:[si+FileSize],ax      ; velikost LOW
         mov       ax,word ptr ds:[BuffDTA+DTASize+2] ; velikost HIGH
         mov       word ptr es:[si+FileSize+2],ax    ; velikost HIGH

; ------ p©°prava pro dal®° poloëku

HledAkt7:inc       word ptr ds:[InfoKCit]   ; zvò®en° á°taáe informaán°ho kurzoru

         call      far ptr TestTDis         ; áasovanÇ zobrazen°
         jc        HledAkt8                 ; nen° pot©eba zobrazen°

         xor       cx,cx                    ; nen° p©°rustek
         call      far ptr InfoKurz         ; zobrazen° kurzoru

HledAkt8:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        HledAkt9                 ; je p©eru®en° operace
         inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       HledAkt2                 ; dal®° poloëka

HledAkt9:ret

HledAkt  ENDP

; -----------------------------------------------------------------------------
;        naáten° slova z ES:SI (á°taá znakñ CX) -> AX
; -----------------------------------------------------------------------------

HledNaZW PROC      NEAR

         push      dx
         call      HledNaZN                 ; naáten° dvouslova
         jc        HledNZW2                 ; chyba
         or        dx,dx                    ; je p©eteáen° ?
         jz        HledNZW2                 ; nen° p©eteáen°
         mov       ax,-1                    ; omezen° p©i p©eteáen°
HledNZW2:pop       dx
         ret

HledNaZW ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla z ES:SI (á°taá znakñ CX) -> DX:AX
; -----------------------------------------------------------------------------

HledNaZN PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ p©°prava registrñ

         xor       bx,bx                    ; BX <- 0 st©adaá LOW
         xor       di,di                    ; DI <- 0 st©adaá HIGH

; ------ vypu®tàn° neplatnòch znakñ p©ed á°slem

HledNZN1:call      HledNaZ                  ; naáten° znaku
         jc        HledNZN5                 ; nen° dal®° znak
         cmp       al,LF                    ; je konec ©†dku ?
         je        HledNZN5                 ; je konec ©†dku - konec
         sub       al,"0"
         jc        HledNZN1                 ; nen° á°slice - dal®° znak
         cmp       al,9
         ja        HledNZN1                 ; nen° á°slice - dal®° znak

; ------ vyn†soben° st©adaáe 10x

HledNZN2:push      ax
         mov       ax,10
         mul       bx                       ; vyn†soben° st©adaáe LOW
         xchg      ax,bx                    ; BX <- novò LOW
         xchg      dx,di                    ; DI <- novò HIGH, DX <- starò HIGH
         mov       ax,10                    
         mul       dx                       ; vyn†soben° st©adaáe HIGH
         add       di,ax                    ; DI <- novò HIGH
         adc       dx,dx                    ; st©adaá p©eteáen°
         pop       ax

; ------ p©iáten° novÇ á°slice

         mov       ah,0
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,dx                    ; p©enos (p©i OK je DX=0)
         adc       dx,dx                    ; je p©eteáen° ?
         jz        HledNZN3                 ; nen° p©eteáen°

         mov       bx,-1                    ; omezen° p©i p©eteáen°
         mov       di,bx

; ------ naáten° dal®° á°slice

HledNZN3:call      HledNaZ                  ; naáten° dal®°ho znaku
         jc        HledNZN5                 ; nen° dal®° znak
         cmp       al,LF
         je        HledNZN5                 ; je LF - konec ©†dku
         sub       al,"0"
         jc        HledNZN4                 ; nen° znak á°slice
         cmp       al,9
         jbe       HledNZN2                 ; je á°slice - OK

; ------ n†vrat neplatnÇho znaku

HledNZN4:dec       si                       ; n†vrat ukazatele znakñ
         inc       cx                       ; n†vrat á°taáe znakñ

; ------ n†vrat registrñ

HledNZN5:xchg      ax,bx                    ; AX <- á°slo LOW
         mov       dx,di                    ; DX <- á°slo HIGH

         pop       di
         pop       bx
         ret

HledNaZN ENDP

; -----------------------------------------------------------------------------
;        naáten° CX á°slic z ES:SI pro form†t DBF -> DX:AX (SI posune o CX) niá° CX
; -----------------------------------------------------------------------------

HledNaDN PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ p©°prava registrñ

         xor       bx,bx                    ; BX <- 0 st©adaá LOW
         xor       di,di                    ; DI <- 0 st©adaá HIGH

; ------ naáten° jednoho znaku

HledNDN2:mov       al,es:[si]               ; p©ipravenò znak
         inc       si                       ; zvò®en° ukazatele v bufferu
         sub       al,"0"
         jc        HledNDN4                 ; nen° á°slice
         cmp       al,9
         ja        HledNDN4                 ; nen° á°slice

; ------ vyn†soben° st©adaáe 10x

         push      ax
         mov       ax,10
         mul       bx                       ; vyn†soben° st©adaáe LOW
         xchg      ax,bx                    ; BX <- novò LOW
         xchg      dx,di                    ; DI <- novò HIGH, DX <- starò HIGH
         mov       ax,10
         mul       dx                       ; vyn†soben° st©adaáe HIGH
         add       di,ax                    ; DI <- novò HIGH
         adc       dx,dx                    ; st©adaá p©eteáen°
         pop       ax

; ------ p©iáten° novÇ á°slice

         mov       ah,0
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,dx                    ; p©enos (p©i OK je DX=0)
         adc       dx,dx                    ; je p©eteáen° ?
         jz        HledNDN4                 ; nen° p©eteáen°

         mov       bx,-1                    ; omezen° p©i p©eteáen°
         mov       di,bx

HledNDN4:loop      HledNDN2                 ; dal®° znak

; ------ n†vrat registrñ

         xchg      ax,bx                    ; AX <- á°slo LOW
         mov       dx,di                    ; DX <- á°slo HIGH

         pop       di
         pop       bx
         ret

HledNaDN ENDP

; -----------------------------------------------------------------------------
;        nedostatek pamàti k naáten° seznamu okna AX
; -----------------------------------------------------------------------------

ChybaSez PROC      NEAR

; ------ test, zda je p©eru®en° operace

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        ChybaSz9                 ; p©eru®en° operace
         call      far ptr InfoClos         ; uzav©en° reëimu operace
         call      far ptr DispAWin         ; novÇ zobrazen° okna

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna seznamu

; ------ zobrazen° hl†®en°, nen°-li ë†dn† poloëka

         test      byte ptr es:[AWinPrm1],bit5 ; je seznam ?
         jz        ChybaSz2                 ; nen° seznam
         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch souborñ
         or        ax,ax                    ; je nàco naáteno ?
         jnz       ChybaSz3                 ; je nàco naáteno
ChybaSz2:call      far ptr MemErr           ; hl†®en° - nedostatek pamàti
         jmp       short ChybaSz8

; ------ p©°prava poátu poloëek

ChybaSz3:push      ds
         pop       es                       ; ES <- datovò segment
         xor       bx,bx                    ; BX <- 0 nen° barva ani oddàlovaá
         mov       di,offset ChbRSezC+1     ; buffer k dek¢dov†n° poátu poloëek
         call      far ptr DekNumW          ; dek¢dov†n° á°sla
         sub       di,offset ChbRSezC+1     ; poáet znakñ
         xchg      ax,di
         mov       ds:[ChbRSezC],al         ; dÇlka textu

; ------ zobrazen° hl†®en° o omezen° poátu poloëek

         mov       si,offset ChybRSez
         call      far ptr Lin0MenF         ; zobrazen° hl†®en°
         call      far ptr SetEsc           ; nastaven° p©°znaku p©eru®en°

; ------ n†vrat registrñ

ChybaSz8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         stc
ChybaSz9:ret

ChybaSez ENDP

; -----------------------------------------------------------------------------
;        p©°prava menu hled†n°
; -----------------------------------------------------------------------------

HledMPre PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava znakñ p©ep°naáñ pro z†pis

         mov       ax,word ptr ds:[ZnakSwch] ; znak p©ep°naáe menu (AL=nast.)
         mov       cl,ds:[HledUloP]         ; parametry pro uloëen°
         mov       si,offset SHZUMLP1+9
         call      HledMPr0                 ; seznam
         mov       si,offset SHZUMLP2+8
         call      HledMPr0                 ; jmÇna
         mov       si,offset SHZUMLP3+6
         call      HledMPr0                 ; DBF

; ------ p©°prava znaku p©ep°naáe pro áten°

         shr       cl,1
         shr       cl,1
         shr       cl,1
         mov       si,offset SHZNMLP1+14    ; aktualizace
         call      HledMPr0

; ------ nastaven° p©°pony jmÇna souboru pro z†pis

         les       di,ds:[SHZUMLPA]         ; adresa bufferu
         mov       cx,ds:[SHZUMLPN]         ; dÇlka textu
         mov       al,ds:[HledUloP]         ; parametru pro uloëen°
         jcxz      HledMPr2                 ; nen° text

         add       di,cx                    ; adresa konce bufferu
         dec       di
         mov       word ptr es:[di-2],"NF"  ; FND
         mov       byte ptr es:[di],"D"
         test      al,bit0
         jnz       HledMPr2                 ; je "FND"
         mov       word ptr es:[di-2],"SL"  ; LST
         mov       byte ptr es:[di],"T"
         test      al,bit1
         jnz       HledMPr2                 ; je "LST"
         mov       word ptr es:[di-2],"BD"  ; jinak "DBF"
         mov       byte ptr es:[di],"F"

; ------ n†vrat registrñ

HledMPr2:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

HledMPre ENDP

; ------ nastaven° znaku jednoho p©ep°naáe

HledMPr0:mov       ds:[si],al               ; p©ep°naá nastaven
         shr       cl,1                     ; je p©ep°naá nastaven ?
         jc        HledMPr1                 ; p©ep°naá je nastaven
         mov       ds:[si],ah               ; p©ep°naá nenastaven
HledMPr1:ret

; -----------------------------------------------------------------------------
;     n†vrat kurzoru po naáten° seznamu v aktivn°m oknà (nemus° nic uchovat !)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) poá†teán° poloëka relativnà
;                   SS:[BP-14] (11) jmÇno poloëky
; -----------------------------------------------------------------------------
;˛
HledNKur PROC      NEAR

; ------ £schova registrñ

         push      bp
         mov       bp,sp

         sub       sp,FileMax+14

; ------ test, zda je okno seznamu a zda je m¢d sledov†n° kurzoru

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr GetDat           ; adresa okna
         jc        HledNKr0
         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         dec       ax                       ; á°slo posledn° poloëky
         cmp       ax,es:[AWinKurz]         ; sleduje kurzor ?
         jne       HledNKr0                 ; nesleduje kurzor
         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jnz       HledNKr1                 ; je to seznam OK
HledNKr0:jmp       HledNKr9

; ------ adresa okna adres†©e

HledNKr1:mov       ax,ds:[SegmLAdr]         ; levÇ okno
         test      byte ptr ds:[WindPar],bit0 ; je levÇ okno ?
         jnz       HledNKr2                 ; je levÇ okno
         mov       ax,ds:[SegmRAdr]         ; pravÇ okno
HledNKr2:call      far ptr GetDat           ; adresa okna
         jc        HledNKr0

; ------ £schova poá†teán° poloëky

         mov       ax,es:[AWinKurz]         ; kurzor
         sub       ax,es:[AWinFrst]         ; offset od poá†tku
         mov       ss:[bp-2],ax             ; £schova poá†tku

; ------ £schova aktivn°ho adres†©e

         mov       di,sp                    ; buffer v z†sobn°ku
         push      ds
         push      es

         push      es
         pop       ds                       ; DS <- segment okna
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e

         mov       byte ptr es:[di],cl      ; dÇlka adres†©e
         inc       di
         mov       si,AWinDir               ; buffer adres†©e
         cld
         rep       movsb                    ; £schova aktivn°ho adres†©e

         pop       es
         pop       ds

; ------ aktivn° poloëka

         mov       bx,es:[AWinKurz]         ; aktivn° poloëka
         call      far ptr GetESPol         ; adresa aktivn° poloëky -> ES:SI

; ------ £schova jmÇna poloëky

         push      ds

         push      es
         pop       ds                       ; DS <- segment poloëky
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         mov       cl,11                    ; dÇlka jmÇna poloëky
         inc       si                       ; zaá†tek jmÇna poloëky
         lea       di,ss:[bp-14]            ; buffer jmÇna poloëky
         cld
         rep       movsb                    ; £schova jmÇna poloëky

         pop       ds

; ------ adresa okna seznamu

         mov       ax,ds:[SegmAkt]
         call      far ptr GetDat           ; adresa okna seznamu
         mov       dx,es                    ; DX <- £schova adresy okna
         xor       bx,bx                    ; BX <- 0 ukazatel á°sla poloëky

; ------ nalezen° poloëky cesty

         dec       bx
HledNKr3:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         mov       es,dx                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky BX
         jc        HledNKr9                 ; nen° dal®° poloëka

; ------ test, zda to je cesta

         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       HledNKr3                 ; nen° to cesta

; ------ porovn†n°, zda to je hledan† cesta

         mov       di,si                    ; DI <- text cesty
         mov       si,sp                    ; SI <- text cesty v z†sobn°ku
         push      ds
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         mov       cl,ds:[si]               ; dÇlka textu cesty
         cld
         repe      cmpsb                    ; porovn†n° textu cesty
         pop       ds
         jne       HledNKr3                 ; nen° to hledan† cesta

; ------ p©ednastaven° kurzoru na tuto cestu

         mov       es,dx                    ; ES <- adresa okna
         push      bx
         inc       bx                       ; prvn° soubor v adres†©i
         mov       es:[AWinKurz],bx         ; p©ednastaven° kurzoru
         sub       bx,ss:[bp-2]             ; poá†tek okna
         jnc       HledNKr4
         xor       bx,bx
HledNKr4:mov       es:[AWinFrst],bx         ; poá†tek okna
         pop       bx

; ------ adresa dal®° poloëky

HledNKr5:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         mov       es,dx                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        HledNKr9                 ; nen° dal®° poloëka

; ------ test, zda to je je®tà platn† poloëka

         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        HledNKr9                 ; nen° to platn† poloëka

; ------ porovn†n°, zda to je hledan† poloëka

         mov       di,si                    ; DI <- adresa poloëky
         inc       di                       ; zaá†tek jmÇna poloëky
         push      ds
         push      ss
         pop       ds                       ; DS <- segment z†sobn°ku
         lea       si,ss:[bp-14]            ; adresa jmÇna poloëky
         cld
         mov       cl,11                    ; dÇlka jmÇna poloëky
         repe      cmpsb                    ; porovn†n° jmÇna poloëky
         pop       ds
         jne       HledNKr5                 ; nen° to hledan† poloëka

; ------ nastaven° kurzoru na tuto poloëku

         mov       es,dx                    ; ES <- adresa okna
         mov       es:[AWinKurz],bx         ; nastaven° kurzoru
         sub       bx,ss:[bp-2]             ; poá†tek okna
         jnc       HledNKr6
         xor       bx,bx
HledNKr6:mov       es:[AWinFrst],bx         ; poá†tek okna

; ------ n†vrat registrñ

HledNKr9:mov       sp,bp
         pop       bp

         push      cs
         call      near ptr AktPthAL        ; aktualizace cesty
         ret

HledNKur ENDP

; -----------------------------------------------------------------------------
;        operace hled†n° souborñ
; -----------------------------------------------------------------------------
;˛
; ------ rozbor zad†n° parametrñ

Hled:    mov       byte ptr ds:[FileTyp],bit3+bit6+bit7 ;+bit5 ; parametry hled†n°
         call      far ptr RozborZ          ; rozbor zad†n° parametrñ
         jc        Hled16                   ; p©eru®en° operace
         jz        Hled13                   ; nen° opakov†n° zad†n°
Hled12:  jmp       Hledej1                  ; opakov†n° zad†n° parametrñ operace

; ------ sestaven° plnÇ vòchoz° cesty

Hled13:  call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°
         call      far ptr RozbFPth         ; doplnàn° cesty na plnÇ jmÇno
         call      far ptr TestBEsc         ; test p©eru®en° programu
         jc        Hled16                   ; p©eru®en° operace

; ------ zapnut° seznamu okna

         call      HledOpen                 ; otev©en° okna seznamu
         jnc       Hled17                   ; operace OK
Hled16:  jmp       HledX                    ; p©eru®en° operace

Hled17:  call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

; ------ inicializace segmentu seznamu

         mov       ax,ds:[SegmAkt]          ; aktivn° okno - seznam
         call      far ptr InitLWn          ; inicializace seznamu okna
         jc        Hled16                   ; p©eru®en° operace
         call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

; ------ hl†®en° o prohled†vanÇm adres†©i (AX=á°slo okna)

Hled3:   mov       ax,ds:[FilePthN]
         mov       ds:[FileFilN],ax         ; dÇlka textu
         mov       di,offset HledTxt1       ; text "prohled†v†m"
         call      far ptr InfFile          ; zobrazen° hl†®en°

; ------ naáten° obsahu jednoho adres†©e

         mov       ax,ds:[SegmAkt]          ; aktivn° okno - seznam
         call      far ptr ReadLWn          ; naáten° jednoho adres†©e
         jc        Hled41                   ; p©eru®en° operace ESC/Break

         call      far ptr TestTDis         ; test áasovÇho zobrazen°
         jc        Hled4                    ; nen° pot©eba zobrazen°
         call      far ptr DispAAWn         ; novÇ zobrazen° okna

; ------ specifikace dal®°ho podadres†©e

Hled4:   call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe
Hled402: push      ax
         call      far ptr TestChar         ; test, zda je p©ipraven znak
         pop       ax
         jc        Hled40                   ; nen° p©ipraven znak z kl†vesnice
         call      far ptr InpChar          ; vstup znaku
         jc        Hled41                   ; p©eru®en° operace ESC
         call      far ptr EditAWin         ; ovl†d†n° oken
         jmp       short Hled402

Hled40:  call      far ptr GetAAWin         ; poskytnut° adresy okna
         call      PathLGH                  ; vyjmut° indexu k hled†n°
         jnc       Hled42                   ; nen° je®tà konec tabulky

; ------ konec hled†n°

Hled41:  call      far ptr InfoClos         ; uzav©en° reëimu operace
         mov       ax,ds:[SegmAkt]
         call      far ptr EndLWn           ; ukonáen° vyhled†v†n° souborñ
         call      far ptr FlushEsc         ; vypr†zdnàn° p©i p©eru®en° ESC

         call      HledNKur                 ; n†vrat kurzoru po naáten°

         call      far ptr DispAll
         jmp       HledX

; ------ á°slo poloëky dal®°ho adres†©e

Hled42:  jne       Hled5                    ; nen° sn°ëen° £rovnà

; ------ sn°ëen° £rovnà

         call      far ptr SubGFil          ; sn°ëen° dÇlky cesty
         jmp       short Hled4

; ------ p©id†n° textu poloëky

Hled5:   mov       di,offset FilePath
         add       di,ds:[FilePthN]         ; konec textu
         cmp       byte ptr ds:[di-1],"\"
         je        Hled52
         mov       byte ptr ds:[di],"\"
         inc       di
Hled52:  push      ds
         push      es

         push      ds
         push      es
         pop       ds
         pop       es

         inc       si                       ; zaá†tek textu poloëky
         call      far ptr FileAsc          ; dek¢dov†n° poloëky
         pop       es
         pop       ds
         sub       di,offset FilePath       ; dÇlka textu poloëky
         mov       ds:[FilePthN],di         ; dÇlka textu poloëky
         jmp       Hled3                    ; prohled†n° dal®°ho adres†©e

; *****************************************************************************
;                              InitLWn
;                  inicializace seznamu souborñ
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; VùSTUP: CY=nedostatek pamàti (nebo p©eru®en° operace; zobraz° hl†®en°)
; *****************************************************************************
;˛
InitLWn  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa datovÇho bloku

         call      far ptr GetDat           ; adresa datovÇho bloku
         jc        InitLW22                 ; chyba ?

; ------ p©°prava á°sla disku

         mov       si,offset FilePath       ; zadan† vòchoz° cesta
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         mov       bl,ds:[si]               ; zadanò disk
         cmp       bl,"A"                   ; je disk platnò ?
         jae       InitLWn1                 ; disk je OK
         mov       bl,ds:[AktPath]          ; disk aktivn°ho adres†©e
InitLWn1:sub       bl,"A"
         mov       es:[AWinDisk],bl         ; á°slo disku

; ------ £schova vòchoz°ho adres†©e pro hled†n°

         mov       di,AWinDir               ; buffer adres†©e
         mov       es:[AWinDNum],cx         ; dÇlka textu adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; kopie adres†©e

; ------ naáten° n†và®t° disku

         push      ax
         mov       al,es:[AWinDisk]         ; zadanò disk
         mov       di,AWinLab               ; buffer n†và®t° disku
         call      far ptr GetVol           ; poskytnut° n†và®t° disku
         mov       es:[AWinLabN],cl         ; dÇlka n†và®t°
         pop       ax
         call      far ptr TestBEsc         ; test p©eru®en°
         jc        InitLW22                 ; je p©eru®en° operace

; ------ naáten° informac° o disku

         call      far ptr InitDInf         ; inicializace diskovòch informac°
         call      far ptr TestBEsc         ; test p©eru®en°
         jc        InitLW22                 ; je p©eru®en° operace

; ------ p©°prava moënÇ maxim†ln° velikosti bloku

         call      far ptr GetSgSiz         ; poskytnut° velikosti bloku
         mov       cx,bx                    ; CX <- £schova velikosti bloku
         call      far ptr GetFree          ; poskytnut° volnÇ pamàti
         add       bx,cx                    ; celkov† moën† velikost bloku
         sub       bx,4000h/16              ; rezerva (pro pozdàj®° operace)
         jc        InitLWn2                 ; to je m†lo volnÇ pamàti

; ------ nastaven° inicializaán° velikosti bloku

InitLW12:cmp       bx,(AWin+200)/16         ; je dost volnÇho m°sta ?
         jb        InitLWn2                 ; je m†lo volnÇho m°sta
         call      far ptr ModiSeg          ; nastaven° velikosti bloku
         jnc       InitLWn3                 ; operace OK

; ------ chyba - nedostatek pamàti

InitLWn2:call      far ptr MemErr           ; chyba - nedostatek pamàti (-> CY)
InitLW22:jmp       InitLWn9

; ------ stanoven° maxim†ln°ho poátu poloëek -> CX

InitLWn3:mov       ax,16
         mul       bx                       ; aktu†ln° velikost bloku v bajtech
         sub       ax,AWin                  ; zbytek na data
         sbb       dx,0
         mov       di,FileSumm+1 + 3 + 3    ; poáet bajtñ na poloëku+index+index
         div       di                       ; vòpoáet max. poátu souborñ
         cmp       ax,MaxAFile              ; maxim†ln° poáet souborñ
         jb        InitLWn4
         mov       ax,MaxAFile              ; omezen° maxim†ln°ho poátu souborñ
InitLWn4:xchg      ax,cx                    ; CX <- max. poáet souborñ

; ------ adresa tabulky indexñ souborñ a indexñ n†vaznosti

         mov       ax,FileSumm+1            ; poáet bajtñ na poloëku
         mul       cx                       ; velikost pole poloëek
         add       ax,AWin                  ; adresa konce souborñ
         adc       dx,0
         mov       di,16
         div       di                       ; p©evod na odstavce
         mov       word ptr es:[AWinSouI+2],ax       ; adresa indexñ souborñ (segment)
         mov       word ptr es:[AWinSouI],0 ; adresa indexñ souborñ - offset
         mov       word ptr es:[AWinKomI+2],ax       ; adresa indexñ n†vaznosti (segment)

; ------ adresa konce tabulky indexñ n†vaznosti

         sub       bx,ax                    ; zbytek bloku (odstavcñ)
         cmp       bx,0fffh
         jb        InitLWn5
         mov       bx,0fffh
InitLWn5:shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1
         mov       word ptr es:[AWinKomI],bx         ; offset indexñ n†vaznosti

; ------ inicializace ukazatelñ

         xor       ax,ax
         mov       es:[AWinSouR],ax         ; poáet naátenòch souborñ
         mov       es:[AWinSouN],ax         ; poáet zobrazenòch souborñ
         mov       es:[AWinFilF.AWinFilN],ax         ; dÇlka filtru souborñ
         mov       es:[AWinFrst],ax         ; poá†tek seznamu
         mov       es:[AWinKurz],ax         ; kurzor seznamu
         mov       es:[AWinDFil],ax         ; zobrazenÇ soubory
         mov       word ptr es:[AWinDSum],ax         ; obsazen† kapacita souborñ
         mov       word ptr es:[AWinDSum+2],ax       ; obsazen† kapacita souborñ
         mov       es:[AWinSNum],ax         ; poáet oznaáenòch souborñ
         mov       word ptr es:[AWinSSum],ax         ; oznaáen† kapacita
         mov       word ptr es:[AWinSSum+2],ax       ; oznaáen† kapacita
         mov       es:[AWinKomN],ax         ; poáet poloëek adres†©ñ k hled†n°
         mov       word ptr es:[AWinFndA],AWinSoub AND 0fh ; ukl†dac° adresa poloëek
         mov       word ptr es:[AWinFndA+2],AWinSoub/16
;         clc

; ------ n†vrat registrñ

InitLWn9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitLWn  ENDP

; *****************************************************************************
;                                 EndLWn
;                       ukonáen° vyhled†v†n° souborñ
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; *****************************************************************************

EndLWn   PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna
         jnc       EndLWn2
EndLWn1: jmp       EndLWn9                  ; chyba
EndLWn2: test      byte ptr es:[AWinPrm1],bit5 ; je to okno seznamu ?
         jz        EndLWn1                  ; nen° okno seznamu

; ------ nov† adresa tabulky indexñ -> DX:DI (SI=segment starÇ tabulky)

         mov       si,es                    ; SI <- adresa okna
         add       si,word ptr es:[AWinSouI+2]       ; SI <- star† adresa tabulky indexñ

         mov       di,word ptr es:[AWinFndA]         ; offset konce poloëek
         mov       dx,word ptr es:[AWinFndA+2]       ; segment konce poloëek
         or        dx,dx                    ; je jië hled†n° ukonáeno ?
         jz        EndLWn1                  ; hled†n° je jië ukonáeno
         mov       word ptr es:[AWinSouI],di         ; novò offset tabulky indexñ
         mov       word ptr es:[AWinSouI+2],dx       ; novò segment tabulky indexñ

; ------ velikost tabulky indexñ -> CX

         mov       cx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         shl       cx,1                     ; * 2
         add       cx,es:[AWinSouN]         ; * 3 = velikost tabulky (bajtñ)

; ------ p©enos tabulky indexñ na novÇ m°sto

         push      es
         push      ds

         mov       ds,si                    ; DS <- segment starÇ tabulky
         xor       si,si                    ; SI <- 0 offset starÇ tabulky

         mov       bx,es                    ; BX <- segment okna
         add       bx,dx                    ; BX = segment novÇ tabulky
         mov       es,bx                    ; ES <- segment novÇ tabulky

         cld
         shr       cx,1                     ; velikost tabulky (slov)
         rep       movsw                    ; p©enos tabulky po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©enos lichÇho bajtu

         pop       ds
         pop       es

; ------ adresa indexñ koment†©ñ

         mov       word ptr es:[AWinKomI],di         ; offset adresy za indexy
         and       word ptr es:[AWinKomI],0fh ; normalizace offsetu
         shr       di,1
         shr       di,1
         shr       di,1
         shr       di,1                     ; p©evod offsetu na segment
         mov       cx,es                    ; segment okna
         sub       bx,cx                    ; segment adresy za indexy relativnà
         add       bx,di                    ; normalizace segmentu
         mov       word ptr es:[AWinKomI+2],bx       ; adresa indexñ koment†©ñ

; ------ nastaven° novÇ velikosti bloku

         inc       bx                       ; rezerva pro p©enos offsetu
         call      far ptr ModiSeg          ; nastaven° velikosti bloku
         call      far ptr GetSgSiz         ; aktu†ln° velikost bloku

; ------ nov† velikost bloku

         push      ax
         mov       ax,16                    ; poáet bajtñ na odstavec
         mul       bx                       ; p©epoáet velikosti na bajty
         mov       word ptr es:[AWinByts],ax         ; velikost bloku v bajtech
         mov       byte ptr es:[AWinByts+2],dl
         pop       ax

; ------ nulov†n° ukazatelñ

         mov       word ptr es:[AWinKomN],0 ; nulov†n° poátu poloëek k hled†n°
         mov       word ptr es:[AWinFndA],0 ; nulov†n° ukl†dac° adresy poloëek
         mov       word ptr es:[AWinFndA+2],0

; ------ n†vrat registrñ

EndLWn9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         call      far ptr AktPathL         ; aktualizace cesty okna seznamu
         ret

EndLWn   ENDP

; *****************************************************************************
;                               ReadLWn
;              naáten° souborñ seznamu v jednom podadres†©i
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo segmentu
;        DS=datovò segment
; VùSTUP: CY=p©eru®en° operace (hl†s° chybu pamàti)
; -----------------------------------------------------------------------------
; Lok†ln° promànnÇ: [BP- 1] (1)  parametry
;                                    bit 0: 1=uloëena cesta k zobrazen°
;                                    bit 1: 1=poloëka vyhovuje zad†n°
;                   [BP- 2] (1)
;                   [BP- 4] (2)  pracovn° identifik†tor pro DTA
;                   [BP- 5] (1)
;                   [BP-18] (13) jmÇno nalezenÇho souboru s p©°ponou ASCIIZ
;                   [BP-22] (4)  velikost souboru
;                   [BP-24] (2)  datum souboru
;                   [BP-26] (2)  áas souboru
;                   [BP-27] (1)  atributy souboru
;                   [BP-48] (21) pracovn° adresa DTA - zaá†tek
;                   [BP-50] (2)  adresa okna
;                   [BP-52] (2)  á°slo okna
;                   [BP-54] (2)  á°taá nalezenòch souborñ k zobrazen°
;                   [BP-56] (2)  á°taá nalezenòch adres†©ñ k prohled†n°
;                   [BP-58] (2)  uschovanÇ á°slo poá†t. poloëky k set©°dàn°
; *****************************************************************************
;˛
ReadLWn  PROC      FAR

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
         sub       sp,58                    ; buffer pro lok†ln° promànnÇ

; ------ p©°prava lok†ln°ch promànnòch

         mov       ss:[bp-52],ax            ; á°slo okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-50],es            ; adresa okna
         mov       word ptr ss:[bp-54],0    ; á°taá nalezenòch souborñ
         mov       word ptr ss:[bp-56],0    ; á°taá adres†©ñ k prohled†n°
         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch souborñ
         mov       ss:[bp-58],ax            ; poá†teán° poloëka k set©°dàn°
         mov       byte ptr ss:[bp-1],0     ; parametry

; ------ uloëen° koncovÇho indexu k hled†n° v podadres†©°ch

         mov       dx,-1                    ; -1 = znaáka konce adres†©e
         mov       bl,0fh                   ; offset konce adres†©e
         call      PathLIH                  ; uloëen° koncovÇho indexu
         jnc       ReadLW02                 ; nen° chyba pamàti
ReadLW01:jmp       ReadLWn7                 ; chyba pamàti

; ------ uloëen° prvn° cesty v oknà

ReadLW02:cmp       word ptr es:[AWinSouN],0 ; bylo jië nàco uloëeno ?
         jne       ReadLWn1                 ; bylo jië nàco uloëeno
         mov       ax,ss:[bp-52]            ; á°slo segmentu okna
         mov       bl,byte ptr es:[AWinFndA] ; ukl†dac° adresa poloëky
         mov       dx,word ptr es:[AWinFndA+2]
         call      PathLWn                  ; vloëen° cesty do seznamu
         jc        ReadLW01                 ; nedostatek pamàti
         call      PathLIZ                  ; uloëen° indexu pro zobrazen°
         jc        ReadLW01                 ; chyba - p©eteáen° pamàti
         or        byte ptr ss:[bp-1],bit0  ; p©°znak uloëen° cesty

; ------ definice bufferu DTA

ReadLWn1:push      ss
         pop       es                       ; ES <- segment bufferu v z†sobn°ku
         lea       si,[bp-48]               ; adresa bufferu DTA
         call      far ptr SetDTA           ; nastaven° adresy DTA

; ------ p©id†n° specifikace "*.*" k cestà

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset All            ; text "*.*"
         call      far ptr AddGFil          ; p©id†n° jmÇna souboru
         jc        ReadLW31                 ; neplatn† dÇlka cesty

; ------ nalezen° prvn°ho souboru

         mov       cx,SYS+HID+RO+DIR+ARC    ; specifikace - v®echny soubory
         mov       si,offset FilePath       ; specifikace souboru
         call      far ptr SrcFirst         ; nalezen° prvn°ho souboru

; ------ zru®en° textu "*.*"

         pushf
         call      far ptr SubGFil          ; odstranàn° textu "*.*"
         popf

; ------ rozli®en°, zda byl nalezen platnò soubor

ReadLWn3:jc        ReadLW31                 ; chyba operace - konec
         jz        ReadLW34                 ; je dal®° soubor OK

ReadLW31:call      far ptr SrcClose         ; uzav©en° starÇho hled†n°
         jmp       ReadLWn6                 ; dal®° soubor nenalezen - konec

ReadLW32:jmp       ReadLWn5                 ; dal®° soubor

ReadLW34:cmp       byte ptr ss:[bp-18],"."  ; je platn† poloëka ?
         je        ReadLW32                 ; poloëka "." nebo ".." se p©eskoá°

; ------ p©°prava jmÇna poloëky ve tvaru FCB

         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,[bp-48]               ; tabulka DTA
         call      far ptr GetBFCB          ; dek¢dov†n° jmÇna na FCB

; ------ test jmÇna poloëky, zda vyhovuje hled†n°

         and       byte ptr ss:[bp-27],not ATRT+ATRO+ATRU ; nulov†n° atributñ
         and       byte ptr ss:[bp-1],not bit1 ; nulov†n° p©°znaku platnÇ poloëky
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FileFCB        ; jmÇno poloëky FCB
         mov       di,offset FileMask       ; maska pro hled†n°
         mov       cx,ds:[FileMskN]         ; dÇlka masky pro hled†n°
         call      far ptr TestMask         ; test, zda poloëka vyhovuje
         jc        ReadLW41                 ; poloëka nevyhovuje

; ------ test ostatn°ch parametrñ poloëky, zda vyhovuje

         push      di
         push      ss
         pop       es                       ; ES <- segment z†sobn°ku
         lea       si,[bp-48]               ; adresa DTA
         mov       di,offset SrcInit        ; zaá†tek parametrñ
         call      far ptr GetBTest         ; test ostatn°ch parametrñ
         pop       di
         jc        ReadLW41                 ; poloëka nevyhovuje

; ------ test, zda je vyhled†n° textu v souboru

         cmp       byte ptr ds:[SrcTextN],0 ; je zad†n text k hled†n° ?
         je        ReadLW40                 ; nen° text k hled†n° - vyhovuje OK
         test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jnz       ReadLW41                 ; adres†© nevyhovuje

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        ReadLW41                 ; je p©eru®en° operace

; ------ sestaven° jmÇna souboru (ES=SS)

         lea       si,[bp-18]               ; jmÇno souboru
         call      far ptr AddGFil          ; p©id†n° jmÇna souboru
         jc        ReadLW41                 ; p©eteáen°

; ------ p©°prava velikosti souboru pro ukazatel operace

         mov       ax,ss:[bp-22]            ; velikost souboru LOW
         mov       word ptr ds:[InfoKMax],ax ; velikost ukazatele LOW
         mov       ax,ss:[bp-22+2]          ; velikost souboru HIGH
         mov       word ptr ds:[InfoKMax+2],ax ; velikost ukazatele HIGH

; ------ vyhled†n° textu v souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[FilePthN]         ; dÇlka jmÇna souboru
         mov       si,offset FilePath       ; specifikace souboru
         push      dx
         push      di
         mov       dx,ds                    ; DX <- datovò segment
         mov       di,offset SrcInit        ; tabulka parametrñ k hled†n°
         call      far ptr SrcFText         ; nalezen° textu v souboru
         pop       di
         pop       dx

; ------ obnoven° adresy okna (hled†n° textu by mohlo posunout segmenty)

         pushf
         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr GetDat           ; adresa okna
         mov       ss:[bp-50],es            ; nov† adresa okna

; ------ odstranàn° jmÇna souboru z cesty

         call      far ptr SubGFil          ; odstranàn° jmÇna souboru z cesty
         popf
         jc        ReadLW41                 ; nen° text v souboru nebo chyba

; ------ poloëka vyhovuje zad†n° OK

ReadLW40:or        byte ptr ss:[bp-1],bit1  ; p©°znak vyhovuj°c° poloëky

; ------ zaji®tàn° uloëen° cesty, pokud bude uloëena platn† poloëka

ReadLW41:mov       es,ss:[bp-50]            ; segment okna
         mov       ax,ss:[bp-52]            ; á°slo segmentu okna
         test      byte ptr ss:[bp-1],bit1  ; je to platn† poloëka ?
         jz        ReadLW42                 ; nen° to platn† poloëka
         test      byte ptr ss:[bp-1],bit0  ; byla cesta jië uloëena ?
         jnz       ReadLW43                 ; cesta jië byla uloëena
         mov       bl,byte ptr es:[AWinFndA]         ; ukl†dac° adresa poloëky
         mov       dx,word ptr es:[AWinFndA+2]
         call      PathLWn                  ; vloëen° cesty do seznamu
         jc        ReadLWn7                 ; nedostatek pamàti
         call      PathLIZ                  ; uloëen° indexu pro zobrazen°
         jc        ReadLWn7                 ; chyba - p©eteáen° pamàti
         or        byte ptr ss:[bp-1],bit0  ; p©°znak uloëen° cesty
         jmp       short ReadLW43

; ------ uloëen° nalezenÇ poloëky

ReadLW42:test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jz        ReadLWn5                 ; nen° adres†© - poloëka nebude uloëena
ReadLW43:lea       si,[bp-27]               ; offset bufferu DTA - zaá†tek dat
         mov       bl,byte ptr es:[AWinFndA]         ; ukl†dac° adresa poloëky
         mov       dx,word ptr es:[AWinFndA+2]
         call      PathLSt                  ; uloëen° poloëky
         jc        ReadLWn7                 ; chyba - p©eteáen° pamàti

; ------ uloëen° indexu nalezenÇ poloëky pro zobrazen°

         test      byte ptr ss:[bp-1],bit1  ; je to platn† poloëka ?
         jz        ReadLW45                 ; nen° to platn† poloëka
         call      PathLIZ                  ; uloëen° indexu pro zobrazen°
         jc        ReadLWn7                 ; chyba - p©eteáen° pamàti
         inc       word ptr ss:[bp-54]      ; zvò®en° á°taáe poloëek

; ------ za©azen° parametrñ souboru ES:DI do ukazatelñ okna

         push      bx
         push      dx
         push      es
         mov       bx,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         dec       bx                       ; á°slo naposledy za©azenÇho souboru
         mov       dx,es                    ; DX <- adresa okna
         call      far ptr GetPolDI         ; adresa poloëky ES:DI
         call      PathLFl                  ; za©azen° parametrñ souboru
         pop       es
         pop       dx
         pop       bx

; ------ uloëen° indexu nalezenÇ poloëky pro hled†n°

ReadLW45:test      byte ptr ss:[bp-27],DIR  ; je to adres†© ?
         jz        ReadLWn5                 ; nen° to adres†©
         test      byte ptr ds:[FileTyp],bit7 ; je moënÇ vno©en° ?
         jz        ReadLWn5                 ; nen° moënÇ vno©en° do podadres†©ñ
         call      PathLIH                  ; uloëen° indexu pro hled†n°
         jc        ReadLWn7                 ; chyba - p©eteáen° pamàti
         inc       word ptr ss:[bp-56]      ; zvò®en° á°taáe poloëek

; ------ pokus o nalezen° dal®°ho souboru

ReadLWn5:call      far ptr TestBEsc         ; test p©eru®en° operace
         jc        ReadLWn6                 ; p©eru®en° operace
         call      far ptr SrcNext          ; nalezen° dal®°ho souboru
         jmp       ReadLWn3                 ; za©azen° p©°padnÇho souboru

; ------ set©°dàn° poloëek k zobrazen°

ReadLWn6:clc                                ; p©°znak - nen° chyba pamàti
ReadLWn7:pushf                              ; CY = chyba pamàti
         mov       cx,ss:[bp-54]            ; poáet nalezenòch poloëek
         jcxz      ReadLW74                 ; nen° ë†dn† poloëka
         mov       bx,ss:[bp-58]            ; poá†teán° poloëka
         inc       bx                       ; p©eskoáen° poloëky cesty
         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr SortLWn          ; set©°dàn° okna

; ------ bude set©°dàn° poloëek k hled†n°

ReadLW74:mov       cx,ss:[bp-56]            ; poáet poloëek k hled†n°
         jcxz      ReadLWn8                 ; ë†dn† poloëka k hled†n°

; ------ adresa okna

         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr GetDat           ; adresa okna

; ------ £schova pñvodn°ch ukazatelñ okna

         mov       bl,es:[AWinPrm2]         ; £schova parametrñ okna
         push      bx
         push      word ptr es:[AWinSouI]   ; £schova adresy tabulky indexñ
         push      word ptr es:[AWinSouI+2]
         push      word ptr es:[AWinSouN]   ; £schova poátu poloëek

; ------ nastaven° novòch parametrñ okna

         and       byte ptr es:[AWinPrm2],not bit0+bit1+bit2+bit3 ; t©°dàn° podle jmÇna
         mov       bx,word ptr es:[AWinKomI]         ; tabulka indexñ k hled†n°
         mov       word ptr es:[AWinSouI],bx         ; jako tabulka indexñ k zobrazen°
         mov       bx,word ptr es:[AWinKomI+2]
         mov       word ptr es:[AWinSouI+2],bx
         mov       es:[AWinSouN],cx         ; novò poáet poloëek k zobrazen°

; ------ set©°dàn° á†sti indexñ k hled†n°

         xor       bx,bx                    ; poá†teán° poloëka = 0 (= posledn°)
         call      far ptr SortLWn          ; set©°dàn° poloëek k hled†n°

; ------ n†vrat pñvodn°ch parametrñ okna

         pop       word ptr es:[AWinSouN]   ; n†vrat poátu poloëek
         pop       word ptr es:[AWinSouI+2] ; n†vrat tabulky indexñ k zobrazen°
         pop       word ptr es:[AWinSouI]
         pop       bx
         mov       es:[AWinPrm2],bl         ; n†vrat parametrñ - t©°dàn° okna

; ------ hl†®en° - chyba pamàti

ReadLWn8:popf                               ; CY = chyba pamàti
         mov       ax,ss:[bp-52]            ; á°slo okna
         call      far ptr AktPathL         ; aktualizace cesty okna seznamu
         jnc       ReadLWn9                 ; nen° chyba pamàti
         call      ChybaSez                 ; hl†®en° chyby pamàti

; ------ n†vrat registrñ

ReadLWn9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      far ptr TestBEsc         ; test p©eru®en° operace
         ret

ReadLWn  ENDP

; -----------------------------------------------------------------------------
;        vloëen° souboru do seznamu
; -----------------------------------------------------------------------------
; VSTUP: SS:SI=poloëka k uloëen° (poloëka DTA - zaá†tek atributñ)
;        ES=segment okna
;        DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------

PathLSt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ aktu†ln° ukazatel k uloëen° poloëky -> DX:AX, CX:DI

         mov       ax,word ptr es:[AWinFndA]         ; adresa k uloëen° poloëky OFFSET
         mov       di,ax                    ; adresa k uloëen° poloëky OFFSET
         mov       dx,word ptr es:[AWinFndA+2]       ; adresa k uloëen° poloëky SEGMENT
         mov       cx,dx                    ; adresa k uloëen° poloëky SEGMENT

; ------ novò ukazatel k ukl†d†n° -> DX:AX

         add       ax,FileSumm+1            ; p©iáten° dÇlky poloëky

; ------ normalizace ukazatele -> DX:AX

         mov       bx,ax                    ; £schova offsetu
         and       ax,0fh                   ; normalizace novÇho offsetu ukazatele
         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; offset / 16
         add       dx,bx                    ; novò segment ukazatele

; ------ test, zda je volnÇ m°sto k vloëen° poloëky

         cmp       dx,word ptr es:[AWinSouI+2]       ; je p©ekryv s ukazateli ?
         jb        PathLSt0                 ; OK
         stc                                ; p©°znak chyby pamàti
         jmp       PathLSt9                 ; chyba pamàti

; ------ posun ukazatelñ

PathLSt0:mov       word ptr es:[AWinFndA],ax         ; novò offset k ukl†d†n° poloëek
         mov       word ptr es:[AWinFndA+2],dx
         inc       word ptr es:[AWinSouR]   ; zvò®en° á°taáe naátenòch souborñ

; ------ p©°prava ukazatelñ

         cld
         mov       ax,es                    ; segment okna
         add       ax,cx                    ; segment ukl†dac° adresy
         mov       es,ax                    ; segment ukl†dac° adresy
         push      ss
         pop       ds                       ; DS <- segment bufferu

; ------ uloëen° parametrñ souboru

         mov       dx,di                    ; DX <- £schova adresy poloëky
         lodsb                              ; atributy souboru
         and       al,not ATRU              ; nulov†n° nepot©ebnòch atributñ
         or        al,ATRT                  ; p©°znak platnÇ poloëky
         stosb                              ; atributy souboru
         lodsw                              ; áas souboru
         mov       es:[di+FileTime-1],ax    ; áas souboru
         lodsw                              ; datum souboru
         mov       es:[di+FileDate-1],ax    ; datum souboru
         lodsw                              ; velikost souboru - LOW
         mov       word ptr es:[di+FileSize-1],ax    ; velikost souboru - LOW
         lodsw                              ; velikost souboru - HIGH
         mov       word ptr es:[di+FileSize+2-1],ax  ; velikost souboru - HIGH

; ------ inicializace jmÇna a p©°pony na mezery

         push      di                       ; £schova zaá†tku poloëky souboru
         mov       cx,11                    ; poáet znakñ jmÇna a p©°pony
         mov       al," "                   ; inicializaán° mezera
         rep       stosb                    ; inicializace jmÇna s p©°ponou
         pop       di                       ; jmÇno souboru s p©°ponou

; ------ uloëen° speci†ln° poloëky - ".."

         cmp       word ptr ds:[si],".."    ; je adres†© ".." ?
         je        PathLSt5                 ; je adres†© ".." - uloëen°

; ------ uloëen° jmÇna souboru (po oddàlovac° teáku nebo koncovou 0)

         mov       cx,8                     ; max. poáet znakñ jmÇna souboru
         push      di                       ; zaá†tek jmÇna souboru
PathLSt1:lodsb                              ; naáten° znaku
         cmp       al,0                     ; konec jmÇna s p©°ponou ?
         je        PathLSt2                 ; konec jmÇna souboru
         cmp       al,"."                   ; oddàlovac° teáka
         je        PathLSt3                 ; oddàlovac° teáka - bude p©°pona
         jcxz      PathLSt1                 ; p©ekroáen poáet znakñ - dal®° znak
         stosb                              ; uloëen° znaku jmÇna souboru
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jmp       short PathLSt1           ; p©enos dal®°ho znaku
PathLSt2:dec       si                       ; n†vrat adresy koncovÇ 0
PathLSt3:pop       di                       ; n†vrat zaá†tku jmÇna souboru

; ------ uloëen° p©°pony souboru

         add       di,8                     ; p©°pona souboru
PathLSt5:mov       cx,3                     ; max. poáet znakñ p©°pony souboru
PathLSt6:lodsb                              ; naáten° znaku
         cmp       al,0                     ; konec jmÇna souboru ?
         je        PathLSt8                 ; konec jmÇna souboru
         stosb                              ; uloëen° znaku jmÇna souboru
         loop      PathLSt6                 ; p©enos dal®°ho znaku

; ------ uloëen° typu poloëky

PathLSt8:mov       si,dx                    ; SI <- adresa poloëky

; ------ poloëka ".."

         mov       al,FileATSb              ; p©°znak ".."
         cmp       byte ptr es:[si+FileName],"." ; jmÇno souboru
         je        PthLSt82                 ; je ".."

; ------ poloëka adres†©e

         inc       ax                       ; adres†©
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jnz       PthLSt82                 ; je to adres†©

; ------ poloëka HID/SYS

         inc       ax                       ; HID/SYS
         test      byte ptr es:[si+FileAtr],HID+SYS ; je to HID/SYS ?
         jnz       PthLSt82                 ; je to HID/SYS

; ------ nastaven° typu poloëky AL

         mov       al,FileATNo              ; jinak ostatn° poloëka
PthLSt82:mov       es:[si+FileATyp],al      ; typ poloëky
         mov       byte ptr es:[si+FileLong],0 ; nen° dlouhÇ jmÇno
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

PathLSt9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PathLSt  ENDP

; -----------------------------------------------------------------------------
;        vloëen° cesty do seznamu (ES=segment, DS=datovò segment -> CY=chyba)
; -----------------------------------------------------------------------------

PathLWn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ aktu†ln° ukazatel k uloëen° poloëky -> DX:AX, SI:DI

         mov       ax,word ptr es:[AWinFndA]         ; adresa k uloëen° poloëky OFFSET
         mov       di,ax                    ; adresa k uloëen° poloëky OFFSET
         mov       dx,word ptr es:[AWinFndA+2]       ; adresa k uloëen° poloëky SEGMENT
         mov       si,dx                    ; adresa k uloëen° poloëky SEGMENT

; ------ novò ukazatel k ukl†d†n° -> DX:AX

         mov       cx,ds:[FilePthN]         ; dÇlka cesty
         add       ax,cx                    ; p©iáten° dÇlky poloëky k offsetu
         inc       ax                       ; váetnà bajtu dÇlky

; ------ normalizace ukazatele -> DX:AX

         mov       bx,ax                    ; £schova offsetu
         and       ax,0fh                   ; normalizace novÇho offsetu ukazatele
         shr       bx,1
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; offset / 16
         add       dx,bx                    ; novò segment ukazatele

; ------ test, zda je volnÇ m°sto k vloëen° cesty

         cmp       dx,word ptr es:[AWinSouI+2]       ; je p©ekryv s ukazateli ?
         cmc
         jc        PathLWn9                 ; je p©ekryv - chyba pamàti

; ------ posun ukazatelñ

         mov       word ptr es:[AWinFndA],ax         ; novò offset k ukl†d†n° poloëek
         mov       word ptr es:[AWinFndA+2],dx
         inc       word ptr es:[AWinSouR]   ; zvò®en° á°taáe naátenòch souborñ

; ------ uloëen° textu cesty

         cld
         mov       ax,es                    ; segment okna
         add       ax,si                    ; segment adresy poloëky
         mov       es,ax                    ; segment adresy poloëky
         mov       es:[di],cl               ; dÇlka textu cesty
         inc       di
         mov       si,offset FilePath       ; buffer cesty
         rep       movsb                    ; p©enos textu cesty
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

PathLWn9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PathLWn  ENDP

; -----------------------------------------------------------------------------
;        uloëen° indexu k zobrazen°
; -----------------------------------------------------------------------------
; VSTUP: ES=segment okna
;        DX:BL=hodnota k uloëen° (normalizov†no)
;        DS=datovò segment
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------

PathLIZ  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ kontrola volnÇho m°sta

         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         shl       ax,1
         add       ax,es:[AWinSouN]         ; souáasn† velikost tabulky
         mov       si,ax                    ; SI <- adresa indexu (offset)
         add       ax,3                     ; posun o index
         cmp       word ptr es:[AWinKomI],ax         ; je p©ekryv tabulek ?
         jb        PathLIZ9                 ; je p©ekryv - chyba

; ------ posun kurzoru, pokud sleduje hled†n° (je na posledn° poloëce)

         mov       ax,es:[AWinSouN]         ; poáet zobrazenòch poloëek
         dec       ax                       ; á°slo posledn° poloëky
         cmp       ax,es:[AWinKurz]         ; sleduje kurzor hled†n° ?
         jne       PathLIZ2                 ; kurzor nesleduje hled†n°
         inc       word ptr es:[AWinKurz]   ; posun kurzoru (sleduje hled†n°)
PathLIZ2:inc       word ptr es:[AWinSouN]   ; zvò®en° á°taáe zobrazenòch poloëek

; ------ uloëen° poloëky

         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinSouI+2]       ; adresa tabulky indexñ
         mov       es,ax                    ; adresa tabulky indexñ
         mov       es:[si],bl               ; uloëen° offsetu poloëky
         mov       es:[si+1],dx             ; uloëen° segmentu poloëky
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

PathLIZ9:pop       es
         pop       si
         pop       ax
         ret

PathLIZ  ENDP

; -----------------------------------------------------------------------------
;    vyjmut° indexu k hled†n° (segment ES -> ES:SI=poloëka, CY=nen°, ZY=konec)
; -----------------------------------------------------------------------------

PathLGH  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ test, zda je dal®° poloëka

         cmp       word ptr es:[AWinKomN],0 ; je dal®° poloëka ?
         stc
         je        PathLGH9                 ; nen° dal®° poloëka

; ------ adresa indexu

         dec       word ptr es:[AWinKomN]   ; sn°ëen° á°taáe poloëek
         mov       dx,es                    ; DX <- segment okna
         mov       si,word ptr es:[AWinKomI]         ; adresa tabulky OFFSET
         mov       ax,word ptr es:[AWinKomI+2]       ; adresa tabulky SEGMENT
         add       word ptr es:[AWinKomI],3 ; posun ukazatele tabulky
         add       ax,dx                    ; segment adresy tabulky
         mov       es,ax                    ; segment adresy tabulky

; ------ test, zda je konec adres†©e

         mov       ax,es:[si+1]             ; segment poloëky
         cmp       ax,-1                    ; je konec adres†©e ?
         je        PathLGH9                 ; je konec adres†©e

; ------ adresa poloëky

         add       ax,dx                    ; segment adresy poloëky
         mov       si,es:[si]               ; offset adresy poloëky
         and       si,0fh                   ; plat° pouze bajt
         mov       es,ax                    ; segment adresy poloëky
         or        ax,ax                    ; p©°znak NZ, operace OK

; ------ n†vrat registrñ

PathLGH9:pop       dx
         pop       ax
         ret

PathLGH  ENDP

; -----------------------------------------------------------------------------
;        uloëen° indexu k hled†n°
; -----------------------------------------------------------------------------
; VSTUP: ES=segment okna
;        DX:BL=hodnota k uloëen° (normalizov†no, -1 = konec aktu†ln°ho adres†©e)
; VùSTUP: CY=nedostatek pamàti
; -----------------------------------------------------------------------------

PathLIH  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      es

; ------ kontrola volnÇho m°sta

         mov       ax,word ptr es:[AWinKomI]         ; offset tabulky indexñ hled†n°
         sub       ax,3                     ; posun o index
         jc        PathLIH9                 ; chyba
         mov       si,es:[AWinSouN]         ; poáet poloëek k zobrazen°
         shl       si,1
         add       si,es:[AWinSouN]         ; * 3 = konec tabulky indexñ
         cmp       ax,si                    ; je p©ekryv tabulek ?
         jb        PathLIH9                 ; je p©ekryv - chyba

; ------ posun ukazatele tabulky

         mov       word ptr es:[AWinKomI],ax         ; nov† adresa tabulky
         inc       word ptr es:[AWinKomN]   ; zvò®en° á°taáe poloëek

; ------ uloëen° poloëky

         xchg      ax,si                    ; SI <- adresa poloëky
         mov       ax,es                    ; segment okna
         add       ax,word ptr es:[AWinKomI+2]       ; adresa tabulky indexñ
         mov       es,ax                    ; adresa tabulky indexñ
         mov       es:[si],bl               ; offset poloëky
         mov       es:[si+1],dx             ; segment poloëky
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

PathLIH9:pop       es
         pop       si
         pop       ax
         ret

PathLIH  ENDP

; -----------------------------------------------------------------------------
;        za©azen° parametrñ souboru (DX=adresa okna, ES:DI=poloëka)
; -----------------------------------------------------------------------------

PathLFl  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      es

; ------ test, zda je poloëka oznaáen†

         test      byte ptr es:[di+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        PathLFl1                 ; nen° oznaáen†

; ------ velikost souboru -> BX:AX

         push      es                       ; segment poloëky
         mov       ax,word ptr es:[di+FileSize]      ; velikost souboru LOW
         mov       bx,word ptr es:[di+FileSize+2]    ; velikost souboru HIGH
         mov       es,dx                    ; ES <- segment okna

; ------ aktualizace st©adaáe oznaáenòch souborñ

         inc       word ptr es:[AWinSNum]   ; poáet oznaáenòch souborñ
         add       word ptr es:[AWinSSum],ax  ; souáet kapacit souborñ
         adc       word ptr es:[AWinSSum+2],bx
         pop       es                       ; segment poloëky

; ------ test, zda je to soubor

PathLFl1:test      byte ptr es:[di+FileAtr],DIR ; je to adres†© ?
         jnz       PathLFl4                 ; je to adres†© - neuloë° se

; ------ velikost souboru -> DX:AX

         push      dx
         mov       ax,word ptr es:[di+FileSize]      ; velikost souboru LOW
         mov       dx,word ptr es:[di+FileSize+2]    ; velikost souboru HIGH
         pop       es                       ; ES <- segment okna

; ------ zvò®en° á°taáe souborñ

         inc       word ptr es:[AWinDFil]   ; zvò®en° á°taáe souborñ

; ------ zaokrouhlen° velikosti souboru na alokaán° blok

         mov       bx,es:[AWinAlok]         ; poáet bajtñ na alokaán° blok disku
         test      byte ptr es:[AWinPrm0],bit6 ; je to CD-ROM ?
         jz        PathLFl2                 ; nen° CD-ROM
         mov       bx,2048                  ; blok pro CD-ROM

PathLFl2:dec       bx                       ; velikost bloku - 1
         add       ax,bx                    ; zaokrouhlen° na blok
         adc       dx,0                     ; p©enos
         inc       bx                       ; n†vrat velikosti bloku
         jc        PathLFl3                 ; p©eteáen°

; ------ kontrola, zda je p©eteáen° velikosti souboru (z©ejmà diskov† chyba)

         cmp       dx,bx                    ; je p©eteáen° velikosti ?
         jae       PathLFl3                 ; je p©eteáen° velikosti souboru

; ------ zaokrouhlen° velikosti na celÇ bloky

         div       bx                       ; vòpoáet celòch blokñ
         mul       bx                       ; vòpoáet zaokrouhlenÇ velikosti

; ------ zvò®en° kapacity souborñ

PathLFl3:add       word ptr es:[AWinDSum],ax         ; p©iáten° velikosti LOW
         adc       word ptr es:[AWinDSum+2],dx       ; p©iáten° velikosti HIGH

; ------ n†vrat registrñ

PathLFl4:pop       es
         pop       dx
         pop       bx
         pop       ax
         ret

PathLFl  ENDP

CodeFnd  ENDS

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
;        Definice ©†dkovÇho menu - volba souborñ k hled†n°
; -----------------------------------------------------------------------------

SHZMLin  label     byte                   ;* menu hled†n° souborñ

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SHZMnLPl                 ; zaá†tek definice poloëek menu
         dw        SHZMnLHl                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@StrucnaSyntaxeHledaniSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SHZMnLBl                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SHZMnLTi                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        10                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        64                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        250                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ (v®echny)
         db        0,'      '               ; zak†zanÇ znaky

         db        HistSel                  ; identifik†tor historie
         db        1                        ; poáet p©edvoleb

SHZMLinN dw        0                        ; dÇlka p©edvolby
SHZMLinA dd        0                        ; adresa p©edvolby

; ------ poloëky voleb

SHZMnLPl db        bit6,17,'Vyhledat soubory:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'Hledej'
         db        1,7,'Uloëen°'
         db        1,7,'Naáten°'
         db        1,5,'Konec'
         db        1,9,'P©eru®en°'

SHZMnLBl db        0,0,0,0,0,0              ; blokovac° tabulka

SHZMnLTi db        15,'hled†n° souborñ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SHZMnLHl db        3,1
         dw        MenuFndH
         db        42,'Vyhled†n° souborñ podle zadanÇ specifikace'
         db        42,'Uloëen° seznamu nalezenòch souborñ na disk'
         db        42,'Naáten° seznamu nalezenòch souborñ z disku'
         db        35,'Ukonáen° reëimu hled†n° (tÇë Esc)'
         db        3,1
         dw        MenuHlp1                 ; "P©eru®en° volby"
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice ©†dkovÇho menu - jmÇno souboru seznamu k uloëen°
; -----------------------------------------------------------------------------
;˛
SHZUMLin label     byte                   ;* menu hled†n° souborñ

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        SHZUMLPl                 ; zaá†tek definice poloëek menu
         dw        SHZUMLHl                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@UlozeniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SHZUMLBl                 ; adresa blokovac° tabulky
         dw        SHZUMLSw                 ; adresa tabulky p©ep°naáñ
         dw        SHZUMLTi                 ; adresa titulu okna
         dw        SHZUMLEx                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        10                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        61                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        FileMax                  ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        2,'?*    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
         db        1                        ; poáet p©edvoleb
SHZUMLPN dw        0                        ; dÇlka textu p©edvolby
SHZUMLPA dd        0                        ; adresa p©edvolby

; ------ poloëky voleb

SHZUMLPl db        bit6,32,'JmÇno souboru k uloëen° seznamu:'
         db        0,0
         db        bit6+bit7,0
         db        1,4,'Uloë'
SHZUMLP1 db        1+bit7,8,'Seznam -'
SHZUMLP2 db        1+bit7,7,'JmÇna -'
SHZUMLP3 db        1+bit7,5,'DBF -'
         db        1,9,'P©eru®en°'

SHZUMLBl db        0,0,0,0,0,0              ; blokovac° tabulka

SHZUMLSw db        0,0,0                    ; p©ep°naáe

SHZUMLTi db        15,'uloëen° seznamu'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SHZUMLHl db        58,'Zadejte jmÇno souboru k uloëen° seznamu nalezenòch souborñ'
         db        60,'Uloëen° seznamu nalezenòch souborñ do souboru zadanÇho jmÇna'
         db        80,'Seznam souborñ bude uloëen v textovÇm tvaru s parametry souborñ ($DOSMAN$.FND)'
         db        79,'Seznam souborñ bude obsahovat jen jmÇna souborñ s plnou cestou ($DOSMAN$.LST)'
         db        75,'Seznam souborñ bude uloëen v datab†zovÇm form†tu DBASE III ($DOSMAN$.DBF)'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SHZUMLEx label     dword                    ; adresy obsluh voleb
         dd        Lin0MenR                 ; ©†dky
         dd        Lin0MenR                 ; uloë
         dd        HledUS                   ; seznam
         dd        HledUJ                   ; jmÇna
         dd        HledUD                   ; DBF
         dd        Lin0MenR                 ; p©eru®en°

; -----------------------------------------------------------------------------
;     hl†®en° - existuje soubor stejnÇho jmÇna jako ukl†danò seznam
; -----------------------------------------------------------------------------

HledUEx  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        HledUExP                 ; zaá†tek definice poloëek menu
         dw        HledUExH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@UlozeniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        HledUExB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        HledUExT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        6                        ; poá†teán° ©†dek okna
         db        47                       ; ®°©ka okna
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

HledUExP db        bit6,9,0,'Varov†n°'
         db        bit6,36,'Existuje jië soubor stejnÇho jmÇna !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,7,'P©epsat'
         db        1,7,'Slouáit'
         db        1,5,'Konec'

HelpS    SEGMENT   BYTE PUBLIC
HledUExH db        55,'Existuj°c° soubor bude p©eps†n novà vytvo©enòm souborem'
         db        50,'P©id†n° novòch poloëek do jië existuj°c°ho seznamu'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

HledUExB db        0,0,0

HledUExT db        15,'soubor existuje'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba z†pisu do souboru seznamu
; -----------------------------------------------------------------------------

ChybHleU label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbHleUP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@UlozeniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbHleUB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbHleUT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
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

ChbHleUP db        bit6,6,0,'CHYBA'
         db        bit6,34,'Chyba z†pisu do souboru seznamu...'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbHleUB db        0                        ; blokovac° tabulka

ChbHleUT db        12,'chyba z†pisu'

; -----------------------------------------------------------------------------
;        Definice ©†dkovÇho menu - jmÇno souboru seznamu k naáten°
; -----------------------------------------------------------------------------
;˛
SHZNMLin label     byte                   ;* menu hled†n° souborñ

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        4                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SHZNMLPl                 ; zaá†tek definice poloëek menu
         dw        SHZNMLHl                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@NacteniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SHZNMLBl                 ; adresa blokovac° tabulky
         dw        SHZNMLSw                 ; adresa tabulky p©ep°naáñ
         dw        SHZNMLTi                 ; adresa titulu okna
         dw        SHZNMLEx                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        10                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        55                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        FileMax                  ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ - soubor
         db        2,'*?    '               ; zak†zanÇ znaky

         db        HistFile                 ; identifik†tor historie
         db        1                        ; poáet p©edvoleb
SHZNMLPN dw        0                        ; dÇlka textu p©edvolby
SHZNMLPA dd        0                        ; adresa p©edvolby

; ------ poloëky voleb

SHZNMLPl db        bit6,32,'JmÇno souboru k naáten° seznamu:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Naáti'
SHZNMLP1 db        1+bit7,13,'Aktualizace -'
         db        1,9,'P©eru®en°'

SHZNMLBl db        0,0,0,0                  ; blokovac° tabulka

SHZNMLSw db        0

SHZNMLTi db        15,'naáten° seznamu'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SHZNMLHl db        81,'Zadejte jmÇno souboru, z kterÇho bude naáten seznam souborñ (FND, LST, DBF)'
         db        80,'Naáten° seznamu souborñ ze souboru zadanÇho jmÇna ($DOSMAN$.FND, LST, DBF)'
         db        57,'Aktualizace parametrñ souborñ doplnàn°m informac° z disku'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

SHZNMLEx label     dword                    ; adresy obsluh voleb
         dd        Lin0MenR                 ; ©†dky
         dd        Lin0MenR                 ; naáti
         dd        HledNAA                  ; aktualizace
         dd        Lin0MenR                 ; p©eru®en°

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - soubor nenalezen (je vol†no i odjinud !)
; -----------------------------------------------------------------------------

ChybFndF label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbFndFP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@NacteniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbFndFB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbFndFT                 ; adresa titulu okna
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

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbFndFP db        bit6,6,0,'CHYBA'
         db        bit6,25,'Zadanò soubor nenalezen !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbFndFB db        0                        ; blokovac° tabulka

ChbFndFT db        16,'soubor nenalezen'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - soubor nem† spr†vnò form†t
; -----------------------------------------------------------------------------

ChybHleF label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbHleFP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@NacteniSeznamuNalezenychSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbHleFB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbHleFT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        47                       ; ®°©ka okna
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

ChbHleFP db        bit6,6,0,'CHYBA'
         db        bit6,34,'Nespr†vnò form†t souboru seznamu !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbHleFB db        0                        ; blokovac° tabulka

ChbHleFT db        16,'nespr†vnò form†t'

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - m†lo pamàti pro naáten° seznamu
; -----------------------------------------------------------------------------

ChybRSez label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        ChbRSezP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@HledaniSouboru       ; á°slo str†nky velkÇ n†povàdy
         dw        ChbRSezB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnMeT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        51                       ; ®°©ka okna
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

ChbRSezP db        bit6,19,'Nedostatek pamàti !'
         db        bit6,44,'Velikost seznamu omezena na ',0,1
         dw        ChbRSezC
         db        0,' poloëek...'
         db        bit6,0
         db        bit6+bit7,0
         db        2,7,' Konec '

ChbRSezC db        1,'      '

ChbRSezB db        0                        ; blokovac° tabulka

HledUlT  db        16,'Ukl†d†m seznam ',0

HledNaT  db        16,'Naá°t†m seznam ',0

HledAktT db        21,'Aktualizuji seznam...'

FindMNam db        12,'$DOSMAN$.FND'

HledTxt1 db        13,'Prohled†v†m ',0

;HledIdnt dw        0                        ; identifik†tor souboru

; ------ vzor z†hlav° DBF

HledDBF  label     byte
         db        3                        ; identifik†tor souboru
HledDRok db        0                        ; rok ve stolet° (od 1900)
HledDMes db        0                        ; màs°c
HledDDen db        0                        ; den
HledDVet dd        0                        ; poáet vàt v souboru
         dw        HledDBF0-HledDBF         ; dÇlka z†hlav° (bajtñ)
         dw        105                      ; dÇlka jednoho z†znamu (bajtñ)
         db        20 dup(0)                ; rezervov†no

         db        'DISK', 7 dup(0)
         db        'C',0,0,0,0,1,15 dup(0)

         db        'ADRESAR', 4 dup(0)
         db        'C',0,0,0,0,63,15 dup(0)

         db        'JMENO', 6 dup(0)
         db        'C',0,0,0,0,8,15 dup(0)

         db        'PRIPONA', 4 dup(0)
         db        'C',0,0,0,0,3,15 dup(0)

         db        'VELIKOST',0,0,0
         db        'N',0,0,0,0,10,15 dup(0)

         db        'DATUM', 6 dup(0)
         db        'D',0,0,0,0,8,15 dup(0)

         db        'CAS', 8 dup(0)
         db        'T',0,0,0,0,6,15 dup(0)
;         db        'C',0,0,0,0,6,15 dup(0)

         db        'ARC', 8 dup(0)
         db        'L',0,0,0,0,1,15 dup(0)

         db        'DIR', 8 dup(0)
         db        'L',0,0,0,0,1,15 dup(0)

         db        'SYS', 8 dup(0)
         db        'L',0,0,0,0,1,15 dup(0)

         db        'HID', 8 dup(0)
         db        'L',0,0,0,0,1,15 dup(0)

         db        'R_O', 8 dup(0)
         db        'L',0,0,0,0,1,15 dup(0)

         db        CR

HledDBF0 label     byte

;HledUloP db        bit0                     ; form†t pro uloëen°
;                                            ;   bit 0: 1=seznam FND
;                                            ;   bit 1: 1=jmÇna LST
;                                            ;   bit 2: 1=DBF
;                                            ;   bit 6: 1=aktualizace naá°t†n°

Data     ENDS
         END

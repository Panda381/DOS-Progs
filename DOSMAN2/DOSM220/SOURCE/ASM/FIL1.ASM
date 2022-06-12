
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              F I L E  -  1
;
;   Obsluha souborñ - Informace, Verifikace, obsluha poskytov†n° souborñ
;
; =============================================================================
;
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeFil  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeFil,ds:Data

AWSMnu0: jmp       far ptr Main0            ; n†vrat do obsluhy menu

; *****************************************************************************
;
;                          Verifikace souborñ
;
; *****************************************************************************
;˛
AWMMnuSV label     FAR

; ------ p©°prava pozice menu

         mov       ax,word ptr ds:[SMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,907h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

; ------ p©°prava blokovac° tabulky

         and       word ptr ds:[SVMnVBlk],not (bit1+HI*bit1) ; poloëky povoleny
         and       word ptr ds:[SVMnVBlk+2],not (bit1+HI*bit1)
         call      far ptr TestAAWn         ; je aktivn° okno zapnuto ?
         jnc       AWMMnSV2                 ; aktivn° okno je zapnuto
         or        word ptr ds:[SVMnVBlk],bit1+HI*bit1 ; z†kaz poloëek
         or        word ptr ds:[SVMnVBlk+2],bit1+HI*bit1 ; z†kaz poloëek

AWMMnSV2:jmp       far ptr VertMenu

AWMMnuTb db        bit0 + bit4 + bit6 + bit7; kurzor
         db        bit1 + bit4 + bit6 + bit7; oznaáenÇ
         db        bit2                     ; soubory
         db        bit2 + bit4 + bit6 + bit7; v®echny
         db        bit3 + bit4 + bit6       ; zadanÇ
         db        bit3 + bit4 + bit6 + bit7; celò disk

; ------ p©°prava k operaci

Verify:  add       sp,4                     ; zru®en° n†vratovÇ adresy

         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       al,cs:[bx+AWMMnuTb-1]    ; parametry pro vòbàr poloëek
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu
         push      cs
         call      near ptr InitFFil        ; inicializace vyhled†v†n°
         jc        Verify08                 ; nen° ë†dn† poloëka
;         call      far ptr NulBreak         ; nulov†n° p©°znaku p©eru®en°

; ------ specifikace zad†n° parametrñ, je-li poëadov†n celò disk

         cmp       word ptr ds:[si+MnuAkt],6 ; je celò disk ?
         jne       Verify01                 ; nen° celò disk

         mov       al,ds:[AktPath]          ; aktivn° disk
         mov       si,offset VerfDisk       ; text pro verifikaci disku
         mov       ds:[si],al               ; aktivn° disk
         mov       di,offset LinBuff        ; ©†dkovò buffer
         mov       cx,offset(VerfDsk0-VerfDisk)
         push      ds
         pop       es
         cld
         mov       ds:[LinNum],cl           ; poáet znakñ textu
         rep       movsb
         call      far ptr Rozbor           ; rozbor - p©°prava parametrñ
         jmp       short Verify04

; ------ zad†n° parametrñ pro specifikaci textem

Verify01:test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        Verify06                 ; nen° specifikace textem

Verify02:mov       si,offset SVZMLin        ; menu volby souborñ
         call      far ptr Lin0Menu         ; volba souborñ
         jc        Verify08                 ; p©eru®en° volby
         call      far ptr RozborZ          ; rozbor zad†n° parametrñ operace
         jc        Verify08                 ; p©eru®en° operace
         jnz       Verify02                 ; opakov†n° zad†n° parametrñ

; ------ doplnàn° cesty na plnÇ jmÇno

Verify04:mov       si,offset VerfTxt        ; text "ovà©uji áitelnost"
         push      cs
         call      near ptr InfDisp0        ; zobrazen° textu
         call      far ptr RozbFPth         ; doplnàn° na plnÇ jmÇno

; ------ vytvo©en° datovÇho bufferu pro operaci

Verify06:call      far ptr CreatBuf         ; vytvo©en° pracovn°ho bufferu
         jnc       Verify09                 ; pamàü OK
Verify08:jmp       AWSMnu0

; ------ inicializace hl†®en° o prov†dàn° verifikace

Verify09:call      far ptr HistADir         ; uloëen° adres†©e do historie
         mov       si,offset VerfTxt        ; text "ovà©uji áitelnost"
         push      cs
         call      near ptr InfDisp0        ; zobrazen° textu
         call      far ptr InitFSet         ; inicializace oznaáen° poloëek
         mov       word ptr ds:[CitVerif],0 ; nulov†n° á°taáe verif. souborñ
         mov       word ptr ds:[CitVerEr],0 ; nulov†n° á°taáe souborñ s chybou
         mov       byte ptr ds:[VerfParm],0 ; nulov†n° parametrñ verifikace

; ------ poskytnut° dal®°ho souboru k operaci

Verify1: call      far ptr DispTime         ; prñbàën† obsluha áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         push      cs
         call      near ptr GetFFil         ; poskytnut° dal®°ho souboru
         jnc       Verify2                  ; je dal®° soubor OK
         jmp       Verify8                  ; nen° dal®° soubor - konec

Verify2: call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna
         test      byte ptr ds:[FileFAtr],DIR ; je to adres†© ?
         jnz       Verify62                 ; adres†© - dal®° poloëka

; ------ zobrazen° hl†®en° o verifikaci souboru

         inc       word ptr ds:[CitVerif]   ; á°taá verifikovanòch souborñ
         mov       di,offset VerfTxt        ; text "ovà©uji áitelnost"
         push      cs
         call      near ptr InfKFile        ; zobrazen° jmÇna souboru s kurz.

; ------ otev©en° verifikovanÇho souboru ES:SI pro áten° -> AX

         call      far ptr OpenR            ; otev©en° souboru pro áten°
         mov       si,offset ChbLnV1        ; text - chyba otev©en° souboru
         jc        Verify5                  ; chybovÇ hl†®en°

; ------ test p©eru®en° bàhem operace (AX=identifik†tor souboru)

Verify3: call      far ptr DispTime         ; obsluha zobrazen° áasu
         call      far ptr DarkNul          ; nulov†n° stm°vaáe obrazovky
         call      far ptr TestBreak        ; test p©eru®en° operace
         jc        Verify4                  ; je p©eru®en° operace

; ------ naáten° bloku dat ze souboru AX

         call      far ptr GetBuff          ; poskytnut° adresy bufferu -> ES
         mov       cx,ds:[BuffSize]         ; velikost bufferu
         xor       di,di                    ; zaá†tek bufferu
         call      far ptr ReadFile         ; áten° bloku dat
         jcxz      Verify4                  ; konec souboru nebo cbyba

; ------ posun kurzoru o naáten† data

         push      cs
         call      near ptr InfoKurz        ; zobrazen° kurzoru
         jmp       short Verify3            ; dal®° blok dat

; ------ konec operace, uzav©en° souboru AX

Verify4: pushf
         call      far ptr ClosFile         ; uzav©en° souboru
         popf
         jnc       Verify6                  ; operace probàhla OK

; ------ chyba verifikace souboru - chybovÇ hl†®en°

         mov       si,offset ChbLnV2        ; text - chyba áten° souboru
Verify5: inc       word ptr ds:[CitVerEr]   ; á°taá chybnòch souborñ
         call      far ptr TestBreak        ; bylo p©eru®en° operace ?
         jc        Verify8                  ; p©eru®en° operace
         test      byte ptr ds:[VerfParm],bit0 ; nezobrazuje se hl†®en° ?
         jnz       Verify7                  ; hl†®en° se nezobrazuje
         push      cs
         call      near ptr DekFParm        ; p©°prava jmÇna souboru
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jc        Verify8                  ; p©eru®en° operace
         dec       bx                       ; je pokraáov†n° dal®°m ?
         jz        Verify7                  ; je pokraáov†n° dal®°m
         or        byte ptr ds:[VerfParm],bit0 ; dal®° chyby ignorovat
         jmp       short Verify7

; ------ nulov†n° oznaáen° poloëky p©i £spà®nÇ operaci

Verify62:test      byte ptr ds:[FileParm],bit3 ; je to adres†© p©i n†vratu ?
         jz        Verify7                  ; nen° to adres†© p©i n†vratu
Verify6: push      cs
         call      near ptr ResFFil         ; nulov†n° oznaáen° poloëky
Verify7: call      far ptr DispAAWn         ; zobrazen° aktivn°ho okna

; ------ test p©eru®en° z kl†vesnice

         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        Verify8                  ; je p©eru®en° operace
         jmp       Verify1                  ; dal®° soubor

; ------ poáet ovà©ovanòch souborñ

Verify8: mov       ax,ds:[CitVerif]         ; poáet souborñ celkem
         xor       bx,bx                    ; nen° á†rka ani barva
         push      ds
         pop       es
         mov       di,offset ChbLnVH3+1     ; buffer k dek¢dov†n° á°sla
         call      far ptr DekNumW          ; dek¢dov†n° á°sla
         xchg      ax,di
         sub       ax,offset ChbLnVH3+1
         mov       ds:[ChbLnVH3],al         ; dÇlka textu

; ------ poáet vadnòch souborñ

         mov       word ptr ds:[ChbLVHP1],offset ChbLnVH4 ; ë†dnò soubor
         or        di,di                    ; byl nàjakò soubor ?
         jz        Verify9                  ; nebyl ë†dnò soubor
         mov       word ptr ds:[ChbLVHP1],offset ChbLnVH0 ; v®echny soubory áitelnÇ
         mov       ax,ds:[CitVerEr]         ; poáet vadnòch souborñ
         or        ax,ax                    ; byly vadnÇ soubory ?
         jz        Verify9                  ; nebyly vadnÇ soubory
         mov       word ptr ds:[ChbLVHP1],offset ChbLnVH1 ; text chyby
         mov       di,offset ChbLnVH2       ; buffer k dek¢dov†n° á°sla
         call      far ptr DekNumW          ; dek¢dov†n° poátu souborñ
         xchg      ax,di
         sub       ax,offset ChbLnVH1+1
         mov       ds:[ChbLnVH1],al         ; dÇlka textu

; ------ hl†®en° o vòsledku operace

Verify9: call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         call      far ptr FlushEsc         ; vypr†zdnàn° kl†vesnice
         call      far ptr ClosFFil         ; uzav©en° hled†n° souborñ
         call      far ptr DispAll          ; zobrazen° v®eho
         mov       si,offset ChbLnVH        ; hl†®en° o ukonáen° operace
         call      far ptr Lin0Menu         ; hl†®en° o ukonáen° operace
         jmp       AWSMnu0

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Obsluha vyhled†v†n° souborñ
;
; -----------------------------------------------------------------------------
; Postup: - volba druhu operace a zdroje souborñ (kurzor, v®echny, zadanÇ)
;         - p©°prava parametrñ operace INITFFIL
;         - zad†n° textovÇho parametru pro volbu souborñ LINEMENU
;         - rozbor zad†n° textovÇho parametru ROZBOR (byl-li parametr zad†n)
;         - doplnàn° jmÇna cesty na plnÇ jmÇno ROZBFPTH (mñëe bòt p©°stup na disk)
;         - inicializace oznaáen° poloëek INITFSET
;         - poloëky jsou poskytov†ni pomoc° GETFFIL
;         - po £spà®nÇ operaci se poloëka odznaá° ResFFil (nen° nutnÇ)
;         - po operaci vyvolat CLOSFFIL (ukonáen° vyhled†v†n°)
;
; V reëimu v®ech souborñ (a adres†©ñ) se oznaá° nejd©°ve v®echny poloëky.
; V reëimu oznaáenòch a v®ech poloëek se p©ed operac° p©enese oznaáen° poloëek
; do bitu £schovy poloëek. P©i vyhled†v†n° se vyhled†vaj° poloëky s nastavenòmi
; obàma atributy ATRO i ATRU. Po nalezen° poloëky se nuluje atribut ATRU
; (£schova) jako p©°znak nalezen° poloëky k proveden° operace. Po £spà®nÇm
; dokonáen° operace se poloëk†m s nastavenòm atributem ATRO (oznaáen°) a
; s vynulovanòm atributem ATRU (£schova) vynuluje oznaáen° ATRO (oznaáen°)
; a nastav° se p©°znak ATRU (£schova) - to je p©°znak dokonáen° operace
; s minulou poloëkou. Je-li nalezen adres†© a je oznaáen ATRO+ATRU, je
; poskytnut k operaci. Je-li oznaáen z p©ede®lÇ operace, vno©° se do nàj.
; P©i zad†n° textem se vno©° i kdyë nen° oznaáen.
;
; Oznaáen° poloëek: ATRO + ATRU = poloëka oznaáen† k nalezen°
;                   ATRO        = poloëka byla nalezena k operaci
;                          ATRU = poloëka odznaáena po £spà®nÇ operaci
;                       nic     = ostatn° poloëky
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               InitFFil
;        inicializace vyhled†v†n° souborñ (rozbor provÇst aë po inicializaci !)
; -----------------------------------------------------------------------------
; VSTUP: AL=p©ep°naáe vyhled†v†n°
;                  bit 0: 1=kurzor
;                  bit 1: 1=oznaáenÇ poloëky
;                  bit 2: 1=v®echny poloëky v adres†©i
;                  bit 3: 1=specifikace textem
;                  bit 4: 1=adres†©e tÇë p©i n†vratu
;                  bit 5:    (1=implicitnà ROOT)
;                  bit 6: 1=moënÇ hled†n° adres†©ñ (a jejich poskytnut°)
;                  bit 7: 1=moënÇ vno©en° do adres†©ñ
;        DS=datovò segment
; VùSTUP: CY=nebude ë†dn† poloëka (BX nedefinov†n)
;         BX=index parametru typu operace (pro £vodn° hl†®en° operace)
;                  2 = kurzor - soubor (ve FileTxtP je jmÇno souboru)
;                  4 = kurzor - adres†© (ve FileTxtP je jmÇno adres†©e)
;                  6 = 1 oznaáen† poloëka (ve FileTxtP je poáet poloëek)
;                  8 = 2 aë 4 oznaáenÇ poloëky (ve FileTxtP je poáet poloëek)
;                 10 = 5 a v°ce oznaáenòch poloëek (ve FileTxtP je poáet poloë.)
;                 12 = v®echny soubory (FileTxtP nulov†no)
;                 14 = v®echny soubory a adres†©e (FileTxtP nulov†no)
;                 16 = zadanÇ poloëky textem (FileTxtP nulov†no)
; *****************************************************************************

InitFFil PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ korekce na zad†n° textem, nen°-li aktivn° okno zapnuto

         call      far ptr TestAAWn         ; test zapnut° aktivn°ho okna
         jnc       IniFFl11                 ; aktivn° okno je zapnuto OK
         and       al,not bit0+bit1+bit2
         or        al,bit3                  ; n†hrada zad†n°m textem

; ------ inicializace parametrñ operace

IniFFl11:mov       ds:[FileTyp],al          ; p©ep°naáe operace
         xor       ax,ax                    ; AX <- 0
         mov       ds:[FileParm],al         ; parametry operace <- 0
         mov       ds:[FileWNum],ax         ; nulov†n° poátu oken
         mov       byte ptr ds:[FileTxtP],0 ; nulov†n° parametrñ

; ------ test, zda je strom

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jnz       InitFF16                 ; je specifikace textem
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        InitFF16                 ; nen° to strom

; ------ test, zda jsou oznaáenÇ poloëky

         xor       bx,bx                    ; ukazatel na prvn° poloëku
         mov       di,es                    ; DI <- adresa okna
         test      byte ptr ds:[FileTyp],bit2 ; v®echny poloëky ?
         jnz       InitFF14                 ; jsou v®echny poloëky
         test      byte ptr ds:[FileTyp],bit1 ; jsou oznaáenÇ poloëky ?
         jz        InitFF16                 ; nejsou oznaáenÇ poloëky

; ------ nalezen° prvn° oznaáenÇ poloëky stromu

         dec       bx
InitFF12:inc       bx                       ; zvò®en° ukazatele poloëek
         mov       es,di                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        InitFF16
         test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        InitFF12                 ; nen° oznaáen† poloëka - dal®°

; ------ sestaven° cesty k poloëce BX

InitFF14:mov       es,di                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        InitFF16

         push      ds
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         mov       di,offset AktPath        ; buffer cesty
         call      far ptr GetPthTW         ; sestaven° cesty k poloëce
         pop       ds
         sub       di,offset AktPath        ; dÇlka cesty
         mov       ds:[AktPathN],di         ; dÇlka aktivn°ho adres†©e

; ------ p©°prava vòchoz° cesty

InitFF16:mov       si,offset AktPath        ; aktivn° cesta
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset FilePath       ; vòchoz° cesta
         mov       cx,ds:[AktPathN]         ; dÇlka aktivn° cesty
         mov       ds:[FilePthN],cx         ; dÇlka aktivn°ho adres†©e
         mov       ds:[FileAPtN],cx         ; vòchoz° dÇlka aktivn°ho adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         cld
         rep       movsb                    ; p©enos aktivn°ho adres†©e
         mov       ds:[FileIdnt],cx         ; zru®en° identifik†toru souboru

; ------ test, zda je strom

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jnz       InitFFl2                 ; je specifikace textem
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        InitFFl2                 ; nen° to strom

; ------ korekce dÇlky cesty pro strom

InitFFl1:dec       si                       ; posun ukazatele aktivn° cesty
         cmp       byte ptr ds:[si],"\"     ; je oddàlovaá cesty ?
         je        InitFFl2                 ; nalezen oddàlovaá cesty
         dec       byte ptr ds:[FileAPtN]   ; sn°ëen° á°taáe dÇlky
         jnz       InitFFl1

; ------ £schova jmÇna poloëky pod kurzorem (cestu nen° pot©eba = akt. adres†©)

InitFFl2:mov       di,offset FileFOld       ; buffer k uloëen° jmÇna
         mov       ds:[di],cl               ; p©ednastaven° - neplat°
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       ax,es:[AWinKurz]         ; kurzor
         mov       ds:[FileFKur],ax         ; £schova kurzoru
         sub       ax,es:[AWinFrst]         ; prvn° poloëka v oknà relativnà
         mov       ds:[FileFTop],ax         ; £schova prvn° poloëky
         call      far ptr GetAKurz         ; adresa kurzoru v oknà
         jc        InitFFl3                 ; nen° kurzor
         mov       byte ptr ds:[di],":"     ; p©°znak, ëe je cesta
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        InitFFl3                 ; nen° to platn† poloëka
         push      ds                       ; £schova DS
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         inc       si                       ; zaá†tek jmÇna poloëky
         mov       cl,11                    ; dÇlka jmÇna poloëky (CH=0)
         cld
         rep       movsb                    ; £schova jmÇna poloëky
         pop       ds                       ; n†vrat DS

; ------ index operace pro zadanÇ textem

InitFFl3:mov       bx,16                    ; index pro zadanÇ poloëky
         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jnz       InitFFl4                 ; je specifikace textem

; ------ adresa aktivn°ho okna

InitFF32:call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        InitFFl4                 ; nàjak† chyba (?)

; ------ index operace pro v®echny poloëky

         test      byte ptr ds:[FileTyp],bit2 ; jsou v®echny poloëky ?
         jz        InitFFl5                 ; nejsou v®echny poloëky
InitFF33:mov       bl,14                    ; v®echny soubory a adres†©e
         test      byte ptr ds:[FileTyp],bit6+bit7 ; jsou tÇë adres†©e ?
         jnz       InitFFl4                 ; jsou tÇë adres†©e
         mov       bl,12                    ; v®echny soubory
InitFFl4:jmp       short InitFFl9

; ------ test, zda je operace pro kurzor

InitFFl5:mov       di,offset FileTxtP+1     ; buffer k uloëen° text. parametru
         test      byte ptr ds:[FileTyp],bit0 ; je kurzor ?
         jnz       InitFFl6                 ; je kurzor
         mov       cx,es:[AWinSNum]         ; poáet oznaáenòch poloëek
         jcxz      IniFFl62                 ; nen° nic oznaáeno - je kurzor

; ------ dek¢dov†n° poátu poloëek do bufferu

         push      ds
         pop       es                       ; ES <- datovò segment
         xchg      ax,cx                    ; AX <- poáet poloëek
         xor       bx,bx                    ; nen° barva ani oddàlovac° znak
         call      far ptr DekNumW          ; dek¢dov†n° poátu poloëek

; ------ p©°prava indexu pro oznaáenÇ poloëky (BH=0)

         mov       bl,10                    ; index pro 5 a v°ce poloëek
         cmp       ax,5                     ; je 5 a v°ce poloëek ?
         jae       InitFFl8                 ; je 5 a v°ce poloëek
         mov       bl,8                     ; 2 aë 4 poloëky
         dec       ax                       ; je 1 poloëka ?
         jnz       InitFFl8                 ; nen° 1 poloëka
         mov       bl,6                     ; 1 poloëka
         jmp       short InitFFl8           ; je 1 poloëka

; ------ p©°prava parametrñ pro kurzor (ES=segment okna)

IniFFl62:and       byte ptr ds:[FileTyp],not bit1+bit2+bit3
         or        byte ptr ds:[FileTyp],bit0 ; typ operace - je kurzor

InitFFl6:mov       si,es:[AWinKurz]         ; kurzor
         cmp       si,es:[AWinSouN]         ; je to platn† poloëka ?
         cmc
         jc        InitFFl9                 ; nen° to platn† poloëka
         call      Get1FFl0                 ; adresa poloëky
         jc        InitFFl9                 ; cesta ani ".." nen° platn†
;         jnc       InitFF64                 ; je to platn† poloëka OK

; ------ kurzor na ".." nebo cesta - jsou v®echny soubory v adres†©i

;         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
;         stc                                ; p©°znak chyby
;         jnz       InitFFl9                 ; je to ".." - nepovolen† poloëka
;;         jnz       InitFF63                 ; nen° to cesta
;;         and       byte ptr ds:[FileTyp],not bit6+bit7 ; z†kaz vno©en° do adres†©ñ
;;InitFF63:and       byte ptr ds:[FileTyp],not bit0+bit1+bit3
;         and       byte ptr ds:[FileTyp],not bit0+bit1+bit3+bit6+bit7 ; z†kaz vno©en°
;         or        byte ptr ds:[FileTyp],bit2 ; v®echny soubory v adres†©i
;         jmp       short InitFF33           ; p©°znak - v®echny poloëky

; ------ rozli®en° poloëky pod kurzorem

InitFF64:mov       bl,2                     ; je kurzor - soubor
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        InitFFl7                 ; je to soubor
         mov       bl,4                     ; je to adres†©

; ------ dek¢dov†n° jmÇna souboru/adres†©e ES:SI

InitFFl7:push      ds                       ; £schova DS
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         inc       si                       ; zaá†tek jmÇna poloëky
         push      cs
         call      near ptr FileAsc         ; dek¢dov†n° jmÇna poloëky
         pop       ds                       ; n†vrat DS

; ------ nastaven° dÇlky textovÇho parametru

InitFFl8:xchg      ax,di                    ; AX <- adresa konce textu
         sub       ax,offset FileTxtP+1
         mov       ds:[FileTxtP],al         ; dÇlka textu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InitFFl9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InitFFil ENDP

; *****************************************************************************
;                                InitFSet
;      inicializace oznaáen° poloëek p©ed zah†jen°m vyhled†v†n° poloëek
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InitFSet PROC      FAR

; ------ £schova registrñ

         push      bx
         push      si
         push      bp
         push      es

; ------ adresa aktivn°ho okna

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        InitFSt9
         mov       bp,es                    ; BP <- adresa okna
         xor       bx,bx                    ; ukazatel á°sla poloëky
         or        byte ptr ds:[FileParm],bit6 ; p©°znak inicializace oznaáen°

; ------ test, zda je operace pro oznaáenÇ poloëky

         test      byte ptr ds:[FileTyp],bit1 ; jsou oznaáenÇ poloëky ?
         jz        IniFSt32                 ; nejsou oznaáenÇ poloëky

; ------ £schova oznaáen° oznaáenòch poloëek

InitFSt1:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        InitFSt9                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        InitFSt3                 ; nen° to platn† poloëka
         and       byte ptr es:[si+FileAtr],not ATRU ; nulov†n° starÇ £schovy
         test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        InitFSt3                 ; nen° to oznaáen† poloëka
         or        byte ptr es:[si+FileAtr],ATRU ; £schova oznaáen° poloëky
InitFSt3:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short InitFSt1           ; dal®° poloëka

; ------ test, zda je operace pro v®echny poloëky

IniFSt32:test      byte ptr ds:[FileTyp],bit2 ; v®echny poloëky ?
         jz        InitFSt9                 ; nejsou v®echny poloëky

; ------ oznaáen° v®ech poloëek

InitFSt4:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        InitFSt9                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        InitFSt6                 ; nen° to platn† poloëka
         cmp       byte ptr es:[si+FileName],"." ; je to platn† poloëka ?
         je        InitFSt6                 ; nen° to platn† poloëka

         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        InitFSt5                 ; nen° to adres†©
         test      byte ptr ds:[FileTyp],bit6 ; budou i adres†©e ?
         jnz       InitFSt5                 ; budou i adres†©e

         and       byte ptr es:[si+FileAtr],not ATRU ; zru®en° £schovy oznaáen°
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr ResSPol          ; zru®en° oznaáen° poloëky BX
         jmp       short InitFSt6

InitFSt5:or        byte ptr es:[si+FileAtr],ATRU ; £schova oznaáen° poloëky
         mov       es,bp                    ; ES <- adresa okna
         call      far ptr SetSPol          ; oznaáen° poloëky BX
InitFSt6:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short InitFSt4           ; dal®° poloëka

; ------ n†vrat registrñ

InitFSt9:pop       es
         pop       bp
         pop       si
         pop       bx
         ret

InitFSet ENDP

; *****************************************************************************
;                               ClosFFil
;                   uzav©en° vyhled†v†n° souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        uschov†v† registr p©°znakñ !
; *****************************************************************************

ClosFFil PROC      FAR

; ------ £schova registrñ

         pushf
         push      ax
         push      bx
         push      dx
         push      si
         push      bp
         push      es

; ------ test, zda je nàjakÇ okno

         xor       bx,bx                    ; BX <- 0
         xchg      bx,ds:[FileWNum]         ; nulov†n° poátu oken
         or        bx,bx                    ; bylo nàjakÇ okno ?
         jz        ClosFFl4                 ; nebylo ë†dnÇ okno

; ------ zru®en° souáasnÇho aktivn°ho okna

ClosFFl1:mov       ax,ds:[SegmAkt]          ; souáasnò aktivn° segment
         call      far ptr DeletAWn         ; zru®en° okna
         xchg      ax,dx                    ; DX <- ru®enÇ okno

; ------ uloëen° definice novÇho okna

         shl       bx,1                     ; ukazatel £rovnà * 2
         mov       ax,ds:[bx+FileWSeg-2]    ; n†vrat segmentu okna
         call      far ptr XchgWSeg         ; n†vrat segmentñ okna
         shr       bx,1                     ; n†vrat ukazatele £rovnà
         dec       bx                       ; sn°ëen° ukazatele £rovnà
         jnz       ClosFFl1                 ; dal®° okno
         jmp       short ClosFFl4


ClosFFl3:jmp       ClosFFl9

; ------ n†vrat kurzoru v aktivn°m oknà na pñvodn° poloëku

ClosFFl4:test      byte ptr ds:[FileParm],bit6 ; oznaáen° inicializov†no ?
         jz        ClosFFl3                 ; nebylo inicializov†no
         test      byte ptr ds:[FileTyp],bit3 ; bylo zad†n° textem ?
         jnz       ClosFFl3                 ; bylo zad†n° textem

         call      far ptr GetAAWin         ; adresa aktivn°ho okna -> ES
         jc        ClosFFl3

; ------ n†vrat kurzoru pro okno stromu

         test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        ClsFFl44                 ; nen° to strom
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         push      ds
         pop       es                       ; datovò segment
         mov       si,offset AktPath        ; aktivn° adres†©
         call      far ptr SrcPathT         ; nalezen° cesty
         call      far ptr GetDat           ; nov† adresa okna
         mov       es:[AWinKurz],bx         ; nastaven° kurzoru

         sub       bx,ds:[FileFTop]         ; uschovan† poá†teán° poloëka
         jnc       ClsFFl42
         xor       bx,bx                    ; BX <- 0
ClsFFl42:mov       es:[AWinFrst],bx         ; n†vrat poá†teán° poloëky
         jmp       short ClsFFl58

; ------ n†vrat kurzoru pro adres†©ovÇ okno

ClsFFl44:mov       si,offset FileFOld       ; jmÇno poloëky pod kurzorem
         cmp       byte ptr ds:[si],0       ; je uschovan† poloëka kurzoru ?
         je        ClosFFl6                 ; nen° uschovan†

         mov       ax,ds:[FileFKur]         ; uschovanò kurzor
         cmp       ax,es:[AWinSouN]         ; je kurzor OK ?
         jb        ClsFFl46                 ; kurzor je OK
         mov       ax,es:[AWinSouN]         ; poáet poloëek v oknà
         or        ax,ax                    ; je nàjak† poloëka ?
         jz        ClsFFl46                 ; nen° ë†dn† poloëka
         dec       ax                       ; posledn° poloëka v oknà
ClsFFl46:mov       es:[AWinKurz],ax         ; n†vrat kurzoru
         sub       ax,ds:[FileFTop]         ; uschovan† poá†teán° poloëka
         jnc       ClosFFl5
         xor       ax,ax                    ; AX <- 0
ClosFFl5:mov       es:[AWinFrst],ax         ; n†vrat poá†teán° poloëky

         cmp       byte ptr ds:[si],":"     ; je cesta ?
         je        ClsFFl58                 ; je cesta

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         call      far ptr RetWKur          ; n†vrat kurzoru v oknà
ClsFFl58:mov       byte ptr ds:[FileFOld],0 ; zru®en° jmÇna poloëky

; ------ normalizace oznaáen° poloëek

ClosFFl6:test      byte ptr ds:[FileTyp],bit1+bit2 ; oznaáenÇ nebo v®echny
         jz        ClosFFl9                 ; nejsou
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        ClosFFl9
         mov       bp,es
         xor       bx,bx
ClosFFl7:mov       es,bp                    ; ES <- adresa okna
         call      far ptr GetESPol         ; adresa poloëky
         jc        ClosFFl9                 ; nen° dal®° poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jz        ClosFFl8                 ; nen° to platn† poloëka
         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        ClosFFl8                 ; poloëka nen° oznaáen†
         or        byte ptr es:[si+FileAtr],ATRU ; je £schova oznaáen°
ClosFFl8:inc       bx                       ; zvò®en° ukazatele poloëek
         jmp       short ClosFFl7           ; dal®° poloëka

; ------ n†vrat registrñ

ClosFFl9:and       byte ptr ds:[FileParm],not bit6 ; neinicializov†no oznaáen°
         pop       es
         pop       bp
         pop       si
         pop       dx
         pop       bx
         pop       ax
         popf
         ret

ClosFFil ENDP

; *****************************************************************************
;                                 InitFCil
;             inicializace zadanÇ c°lovÇ cesty (podle zad†n° v LinBuff)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=chyba nebo p©eru®en° operace
; *****************************************************************************

InitFCil PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      es

         and       byte ptr ds:[CopyPrD2],not bit7 ; c°lovÇ jmÇno se neru®°

; ------ p©enesen° c°lovÇ cesty do bufferu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset LinBuff        ; zadan† cesta
         mov       ch,0
         mov       cl,ds:[LinNum]           ; dÇlka textu cesty
         mov       ds:[CilPathN],cx         ; dÇlka textu cesty
         mov       di,offset CilPath        ; buffer c°lovÇ cesty
         cld
         push      cx
         rep       movsb                    ; p©enesen° c°lovÇ cesty
         pop       cx

; ------ normalizace jmÇna zadanÇho adres†©e

         mov       si,offset CilPath        ; zadanÇ jmÇno adres†©e
         call      far ptr NormFile         ; normalizace jmÇna souboru
         jcxz      IniFCil1                 ; nebylo nic zad†no - konec
         call      far ptr FullFile         ; korekce na plnÇ jmÇno souboru
         mov       ds:[CilPathN],cx         ; £schova dÇlky adres†©e
         jmp       short IniFCil2

IniFCil1:stc                                ; p©°znak p©eru®en° operace
         jmp       IniFCil9

; ------ p©°prava masky - v®echny soubory

IniFCil2:cld
         mov       di,offset CilMask        ; maska c°lovÇho jmÇna
         mov       cx,11                    ; poáet znakñ
         mov       al,"?"
         rep       stosb                    ; inicializace masky jmÇna

; ------ prohled†n° zadanÇ cesty

         xor       bx,bx                    ; BH = "?" cesty, BL = "?" jmÇna
         mov       di,si                    ; DI <- adresa zaá†tku jmÇna
IniFCl22:lodsb                              ; naáten° znaku

         cmp       al,"\"                   ; oddàlovaá cesty ?
         jne       IniFCl24

         mov       di,si                    ; adresa zaá†tku jmÇna
         or        bh,bl                    ; BH <- p©°znak "?" cesty
         mov       bl,0                     ; á°taá znakñ

IniFCl24:cmp       al,"*"
         je        IniFCl26
         cmp       al,"?"
         jne       IniFCl28
IniFCl26:inc       bx                       ; zvò®en° á°taáe znakñ "*" a "?"

IniFCl28:cmp       al,0
         jne       IniFCl22

; ------ v cestà nesm° bòt znak "*" a "?"

         or        bh,bh                    ; byl v cestà znak "*" nebo "?" ?
         jz        IniFCil3                 ; nen° znak "*" ani "?"

         mov       si,offset ChbLnCl
         call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jmp       short IniFCil1

; ------ test, zda existuje adres†© zadanÇho jmÇna

IniFCil3:or        bl,bl                    ; obsahuje jmÇno znaky "*" a "?" ?
         jnz       IniFCil4                 ; obsahuje - nemñëe to bòt adres†©
         cmp       word ptr ds:[CilPathN],3 ; dÇlka c°le - je to ROOT ?
         jbe       IniFCl49                 ; je to ROOT - existuje OK
         cmp       word ptr ds:[di],".."
         je        IniFCl49                 ; je to nadadres†©
         mov       si,offset CilPath        ; c°lov† cesta
         call      far ptr ExisFile         ; test, zda existuje adres†©
         jc        IniFCil4                 ; poloëka nenalezena nebo chyba
         test      cl,DIR                   ; je to adres†© ?
         jnz       IniFCl49                 ; je adres†© zadanÇho jmÇna

; ------ zkr†cen° cesty o koncovÇ jmÇno

IniFCil4:mov       si,di                    ; SI <- adresa zaá†tku jmÇna
         sub       di,offset CilPath        ; c°lov† cesta
         cmp       di,3                     ; minim†ln° dÇlka pro "C:\"
         jbe       IniFCl42                 ; je minim†ln° dÇlka
         dec       di                       ; zkr†cen° o znak "\"
IniFCl42:mov       ds:[CilPathN],di         ; zkr†cen† dÇlka cesty

; ------ inicializaán° vymaz†n° masky FCB

         mov       di,offset CilMask        ; maska jmÇna poloëky
         cld
         mov       cx,11                    ; dÇlka jmÇna
         mov       al," "                   ; mazac° znak mezery
         push      di
         rep       stosb                    ; vymaz†n° bufferu znakem mezery
         pop       di

; ------ dek¢dov†n° jmÇna poloëky

         mov       cl,8                     ; dÇlka jmÇna
IniFCl44:lodsb                              ; znak jmÇna souboru
         cmp       al,0                     ; je to konec textu ?
         je        IniFCil5                 ; konec jmÇna souboru

; ------ maskovac° znak "*"

         cmp       al,"*"                   ; je n†hradn° znak "*" ?
         jne       IniFCl46                 ; nen° n†hradn° znak "*"
         mov       al,"?"                   ; n†hrada znakem "?"
         rep       stosb                    ; vymaz†n° zbytku jmÇna

; ------ oddàlovac° teáka p©°pony jmÇna souboru

IniFCl46:cmp       al,"."                   ; je p©°pona ?
         jne       IniFCl48                 ; nen° p©°pona
         mov       di,offset CilMask+8      ; adresa k dek¢dov†n° p©°pony
         mov       cl,3                     ; dÇlka p©°pony jmÇna
         jmp       short IniFCl44

; ------ uloëen° znaku jmÇna souboru do bufferu

IniFCl48:jcxz      IniFCl44                 ; jsou jië v®echny znaky
         stosb                              ; uloëen° znaku jmÇna souboru
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         jmp       short IniFCl44           ; dal®° znak

; ------ £schova aktu†ln° dÇlky cesty

IniFCl49:or        byte ptr ds:[CopyPrD2],bit7 ; c°lovÇ jmÇno se ru®°
IniFCil5:mov       di,ds:[CilPathN]         ; aktu†ln° dÇlka cesty
         mov       ds:[CilPthN0],di         ; £schova dÇlky cesty
         mov       byte ptr ds:[di+CilPath],0 ; oznaáen° konce cesty
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

IniFCil9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

InitFCil ENDP

; *****************************************************************************
;                                  GetFCil
;                   sestaven° c°lovÇho jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

GetFCil  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ inicializaán° konec c°lovÇ cesty -> BX

         mov       bx,ds:[CilPthN0]         ; inicializaán° dÇlka cesty
         add       bx,offset CilPath        ; BX <- konec cesty

; ------ test, zda poloëka je v podadres†©i aktivn°ho adres†©e

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset AktPath        ; aktivn° cesta
         mov       si,offset FilePath       ; jmÇno kop°rovanÇho souboru
         mov       cx,ds:[FileAPtN]         ; dÇlka aktivn° cesty
         cld
         repe      cmpsb                    ; test, zda je v podadres†©i

; ------ poloëka nen° v podadres†©i - plat° jmÇno na konci cesty

         jne       GetFCil1                 ; nen° v podadres†©i
         cmp       byte ptr ds:[si-1],"\"
         je        GetFCil2                 ; je ROOT
         cmp       byte ptr ds:[si],"\"     ; konec podadres†©e ?
         je        GetFCil2                 ; poloëka je v podadres†©i OK
GetFCil1:mov       si,offset FilePath       ; cesta
         add       si,ds:[FilePthN]         ; adresa konce adres†©e

; ------ odstranàn° poá†teán° "\" p©ed á†st° cesty

GetFCil2:cmp       byte ptr ds:[si],"\"
         jne       GetFCil3
         inc       si                       ; adresa á†sti cesty s poloëkou

; ------ zaji®tàn° "\" na konci c°lovÇ cesty

GetFCil3:cmp       byte ptr ds:[bx-1],"\"
         je        GetFCil4                 ; je jië oddàlovaá "\"
         mov       byte ptr ds:[bx],"\"
         inc       bx

; ------ test, zda se bude dek¢dovat aë jmÇno na konci

GetFCil4:test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jnz       GetFCl42                 ; je specifikace textem
         push      es
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         pop       es
         jz        GetFCl48                 ; nen° seznam

; ------ p©enesen° cesty se jmÇnem poloëky

GetFCl42:cld
         lodsb                              ; naáten° znaku
         mov       ds:[bx],al               ; uloëen° znaku
         inc       bx                       ; zvò®en° ukl†dac° adresy
         cmp       al,0                     ; je konec ?
         jne       GetFCl42                 ; p©enesen° cesty

; ------ nalezen° zaá†tku posledn° poloëky

GetFCl44:dec       bx
         dec       si
         cmp       byte ptr ds:[si-1],"\"   ; nalezen oddàlovaá ?
         jne       GetFCl44                 ; nalezen° oddàlovaáe
         jmp       short GetFCl49           ; poloëka se dek¢duje

; ------ test, zda se dek¢duje posledn° jmÇno v cestà (jinak se nemaskuje)

GetFCl48:mov       ax,si                    ; AX <- text k dek¢dov†n°
         sub       ax,offset FilePath       ; vzd†lenost od poá†tku
         cmp       ax,ds:[FilePthN]         ; je to posledn° poloëka ?
         jae       GetFCl49                 ; je to posledn° poloëka
         cmp       byte ptr ds:[bx],0       ; (to by asi nemàlo nastat ?)
         je        GetFCl49

; ------ cesta je jië v bufferu - p©eskoáen° spoleánòch £sekñ

GetFC482:inc       bx
         cmp       byte ptr ds:[bx-1],"\"
         je        GetFC483
         cmp       byte ptr ds:[bx-1],0
         jne       GetFC482
         mov       byte ptr ds:[bx-1],"\"

GetFC483:inc       si
         cmp       byte ptr ds:[si-1],"\"
         jne       GetFC483

         mov       ax,si
         sub       ax,offset FilePath       ; vzd†lenost od poá†tku
         cmp       ax,ds:[FilePthN]         ; je to posledn° poloëka ?
         jb        GetFC482
         mov       di,bx
         or        byte ptr ds:[CopyPrD2],bit6 ; dlouh† maska se neuplatn°
         jmp       short GetFCil8

; ------ dek¢dov†n° jmÇna poloëky DS:SI na tvar FCB (ES:BX=ukl†dac° adresa)

GetFCl49:push      si                       ; zaá†tek podcesty se souborem
         sub       si,DTAName               ; fiktivn° zaá†tek poloëky DTA
         call      far ptr GetBFCB          ; dek¢dov†n° na tvar FCB

; ------ maskov†n° jmÇna poloëky (nebo vòchoz° á†st cesty)

         mov       si,offset CilMask        ; maska jmÇna poloëky
         mov       di,offset FileFCB        ; jmÇno souboru/podadres†©e
         cld
         mov       cx,11                    ; dÇlka jmÇna poloëky
GetFCil5:lodsb
         cmp       al,"?"                   ; je pñvodn° znak ?
         je        GetFCil6                 ; znak nezmànàn
         cmp       al,":"                   ; je oddàlovaá za©°zen° ?
         jne       GetFCl52                 ; nen° oddàlovaá za©°zen°
         mov       al," "                   ; znak neplatnò
GetFCl52:stosb                              ; uloëen° novÇho znaku
         dec       di
GetFCil6:inc       di
         loop      GetFCil5                 ; dal®° znak

; ------ konverze z tvaru FCB na ASCIIZ

         mov       di,bx                    ; DI <- ukl†dac° adresa
         mov       si,offset FileFCB        ; jmÇno souboru ve tvaru FCB
         call      far ptr FileAsc          ; dek¢dov†n° jmÇna
         pop       si

; ------ nalezen° konce jmÇna poloëky (BX=zaá†tek/DI=konec c°lovÇ poloëky)

GetFCl72:cld
         and       byte ptr ds:[CopyPrD2],not bit6 ; bude dlouh† maska
GetFCil7:inc       si
         cmp       byte ptr ds:[si],0
         je        GetFCil9
         cmp       byte ptr ds:[si],"\"
         jne       GetFCil7
         or        byte ptr ds:[CopyPrD2],bit6 ; dlouh† maska se neuplatn°
         inc       si

; ------ p©enesen° zbytku specifikace

GetFCil8:lodsb
         stosb
         cmp       al,"\"
         jne       GetFCl82
         mov       bx,di                    ; £schova zaá†tku koncovÇ poloëky
GetFCl82:cmp       al,0
         jne       GetFCil8
         dec       di                       ; n†vrat na koncovou 0

; ------ £schova jmÇna poloëky -> FileTxtP

GetFCil9:mov       cx,di                    ; konec jmÇna poloëky
         sub       cx,bx                    ; CX <- dÇlka jmÇna poloëky
         mov       di,offset FileTxtP+1
         mov       ds:[di-1],cl
         mov       si,bx
         rep       movsb                    ; £schova jmÇna poloëky

; ------ nov† dÇlka jmÇna

         sub       si,offset CilPath        ; dÇlka jmÇna
         mov       ds:[CilPathN],si         ; dÇlka jmÇna

; ------ dÇlka adres†©e

         cmp       byte ptr ds:[bx-1],"\"
         jne       GetFCilA
         cmp       byte ptr ds:[bx-2],":"
         je        GetFCilA                 ; je ROOT
         dec       bx                       ; zru®en° koncovÇho "\"
GetFCilA:sub       bx,offset CilPath        ; dÇlka cesty
         mov       ds:[CilCilPN],bx         ; dÇlka textu adres†©e

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GetFCil  ENDP

; *****************************************************************************
;                                 GetFFil
;                    poskytnut° souboru pro operaci
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° dal®° soubor nebo chyba
;         ES:SI=adresa bufferu (FilePath)
;         CX=dÇlka jmÇna souboru (FilePthN)
; *****************************************************************************
;˛
GetFFil  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di
         push      bp

; ------ korekce, byla-li poloëka zru®ena

         test      byte ptr ds:[FileParm],bit7 ; byla poloëka zru®ena ?
         jz        GetFFil0                 ; poloëka nebyla zru®ena

         cmp       word ptr ds:[FileWNum],0 ; je to podokno ?
         jne       GetFFl02                 ; je to podokno
         test      byte ptr ds:[FileTyp],bit0 ; operace s kurzorem ?
         jz        GetFFl02                 ; nen° operace s kurzorem
         or        byte ptr ds:[FileParm],bit1 ; z†kaz vno©en° do dal®° poloëky
         jmp       short GetFFil0

GetFFl02:and       byte ptr ds:[FileParm],not bit1 ; nebylo vno©en° do adres†©e
GetFFil0:and       byte ptr ds:[FileParm],not bit7 ; nen° zru®en† poloëka

; ------ p©i zad†n° textem prvn° vno©en° do adres†©e (p©i zah†jen° operace)

         cmp       byte ptr ds:[FileWNum],0 ; jsou jië vno©enÇ adres†©e ?
         jne       GetFFil1                 ; jsou jië vno©enÇ adres†©e
         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        GetFFil1                 ; nen° specifikace textem
         mov       ax,ds:[FilePthN]         ; dÇlka cesty
         mov       ds:[FileFilN],ax         ; je to i dÇlka jmÇna souboru
         call      GetFInc                  ; vno©en° do podadres†©e
         jc        GetFFl19                 ; chyba pamàti

; ------ adresa aktivn°ho okna -> BP, ES

GetFFil1:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        GetFFl19                 ; je p©eru®en° operace
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       bp,es                    ; BP <- £schova adresy okna
         jnc       GetFFil2                 ; okno je platnÇ OK
GetFFl19:jmp       GetFFil9                 ; nàjak† chyba (konec)


; ====== operace s poloëkou pod kurzorem

; ------ test, zda je poloëka pod kurzorem

GetFFil2:mov       es,bp                    ; ES <- adresa okna
         mov       si,es:[AWinKurz]         ; poloëka s kurzorem
         cmp       word ptr ds:[FileWNum],0 ; jsou vno©enÇ adres†©e ?
         jne       GetFFil3                 ; jsou vno©enÇ adres†©e
         test      byte ptr ds:[FileTyp],bit0 ; je kurzor ?
         jz        GetFFil3                 ; nen° kurzor

; ------ adresa poloëky pod kurzorem

         call      Get1FFl0                 ; poskytnut° adresy poloëky
         jc        GetFFl19                 ; nen° to platn† poloëka

; ------ test, zda jië byla prvn° poloëka

         test      byte ptr ds:[FileParm],bit0 ; byla jië prvn° poloëka ?
         jnz       GetFFl42                 ; byla 1. poloëka - vno©en° do adres†©e
         or        byte ptr ds:[FileParm],bit0 ; teÉ jië byla prvn° poloëka
         jmp       short GetFFl34           ; nebyla je®tà prvn° poloëka = OK


; ====== vyhled†v†n° oznaáenòch poloëek

; ------ adresa p©ipravenÇ poloëky (SI=á°slo aktivn° poloëky)

GetFFil3:test      byte ptr ds:[FileParm],bit0 ; byla jië prvn° poloëka ?
         jnz       GetFFl32                 ; byla jië prvn° poloëka
         xor       si,si                    ; inicializace ukazatele poloëek
         or        byte ptr ds:[FileParm],bit0 ; teÉ jië byla prvn° poloëka
         and       byte ptr ds:[FileParm],not bit5 ; zru®en° z†kazu vno©en°
GetFFl32:call      Get1FFil                 ; poskytnut° adresy poloëky
         jnc       GetFFl33
         jmp       GetFFil5                 ; neplatn† poloëka - dal®°

; ------ test, zda to je oznaáen† poloëka k operaci

GetFFl33:test      byte ptr es:[si+FileAtr],ATRO ; je to oznaáen† poloëka ?
         jz        GetFFil4                 ; nen° to oznaáen† poloëka
         test      byte ptr es:[si+FileAtr],ATRU ; byla poloëka nalezena ?
         jz        GetFFil4                 ; poloëka jië byla nalezena
         and       byte ptr es:[si+FileAtr],not ATRU ; p©°znak nalezen° poloëky
GetFFl34:and       byte ptr ds:[FileParm],not bit3+bit5 ; nen° adres†© p©i n†vratu
         jmp       GetFFil7                 ; poloëka byla nalezena OK



; ====== vno©en° do podadres†©e ES:SI

; ------ test, zda mñëe bòt vno©en° do podadres†©e ES:SI

GetFFil4:cmp       word ptr ds:[FileWNum],0 ; jsou vno©enÇ adres†©e ?
         jne       GetFFl42                 ; jsou vno©enÇ adres†©e - v®e
         test      byte ptr ds:[FileTyp],bit2 ; jsou v®echny poloëky ?
         jnz       GetFFl42                 ; jsou v®echny poloëky
         test      byte ptr es:[si+FileAtr],ATRU+ATRO ; je oznaáen† poloëka ?
         jz        GetFFil5                 ; nen° to oznaáen† poloëka

GetFFl42:test      byte ptr ds:[FileTyp],bit7 ; je moënÇ vno©en° do adres†©ñ ?
         jz        GetFFil5                 ; nen° moënÇ vno©en° - dal®° poloëka
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        GetFFil5                 ; nen° to adres†© - dal®° poloëka
         test      byte ptr ds:[FileParm],bit1+bit4+bit5 ; je z†kaz podadres†©ñ ?
         jnz       GetFFil5                 ; jië byl nebo z†kaz vno©en°

; ------ test, zda je okno strom

         push      es
         mov       es,bp                    ; ES <- adresa okna
         test      byte ptr es:[AWinPrm1],bit4 ; je to okno stromu ?
         pop       es
         jz        GetFFl44                 ; nen° to okno stromu

; ------ test, zda je z†kaz podadres†©ñ pro strom (poloëka je rozvinuta)

         and       byte ptr ds:[FileParm],not bit4 ; nen° z†kaz podadres†©ñ
         test      byte ptr ds:[FileParm],bit2 ; jsou povoleny adres†©e ?
         jnz       GetFFl44                 ; jsou povoleny adres†©e
         test      byte ptr es:[si+FileTPar],bit2 ; podadres†©e rozvinuty ?
         jz        GetFFl44                 ; podadres†©e nerozvinuty
         or        byte ptr ds:[FileParm],bit4 ; z†kaz podadres†©ñ

; ------ sestaven° novÇ cesty k adres†©i pod kurzorem

GetFFl44:push      cs
         call      near ptr GetNFFil        ; sestaven° cesty
         mov       ax,ds:[FileFilN]         ; dÇlka cesty se souborem
         mov       ds:[FilePthN],ax         ; dÇlka cesty s adres†©em

; ------ vno©en° do podadres†©e FilePath

GetFFl46:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        GetFFl48                 ; je p©eru®en° operace
         call      GetFInc                  ; vno©en° do podadres†©e
         jc        GetFFl48                 ; chyba operace
         jmp       GetFFil2                 ; je vno©en° do podadres†©e
GetFFl48:call      far ptr SubGFil          ; p©i chybà zkr†cen° cesty



; ====== zvò®en° ukazatele na dal®° poloëku v oknà

; ------ zvò®en° ukazatele nen° povoleno pro operaci s kurzorem

GetFFil5:cmp       word ptr ds:[FileWNum],0 ; jsou vno©enÇ adres†©e ?
         jne       GetFFl52                 ; jsou vno©enÇ adres†©e
         test      byte ptr ds:[FileTyp],bit0 ; je kurzor ?
         jnz       GetFFil6                 ; je kurzor - nepovoleno

; ------ zvò®en° ukazatele poloëek v oknà na dal®° poloëku

GetFFl52:mov       es,bp                    ; ES <- adresa okna
         and       byte ptr ds:[FileParm],not bit1+bit5 ; nebylo vno©en° do adres†©e
         mov       si,es:[AWinKurz]         ; á°slo dal®° poloëky
         inc       si                       ; zvò®en° ukazatele kurzoru
         cmp       si,es:[AWinSouN]         ; je to platn† poloëka ?
         jae       GetFFil6                 ; nen° dal®° poloëka
         jmp       GetFFl32                 ; test dal®° poloëky



; ====== n†vrat z podadres†©e

; ------ nen° dal®° poloëka - n†vrat £rovnà adres†©e

GetFFil6:mov       es,bp                    ; ES <- adresa okna
         call      GetFDec                  ; vyno©en° z adres†©e
         jnc       GetFFl61
         jmp       GetFFil9                 ; nen° dal®° hladina

; ------ adres†© p©i n†vratu

GetFFl61:test      byte ptr ds:[FileTyp],bit4 ; m† bòt adres†© p©i n†vratu ?
         jz        GetFFil5                 ; dal®° poloëka
         mov       si,es:[AWinKurz]         ; poloëka s kurzorem
         call      Get1FFl0                 ; poskytnut° adresy poloëky

; ------ test, zda je to oznaáen† poloëka

         cmp       word ptr ds:[FileWNum],0 ; je to z†kladn° hladina ?
         jne       GetFFl62                 ; nen° to z†kladn° hladina
         test      byte ptr ds:[FileTyp],bit0 ; operace s kurzorem ?
         jnz       GetFFl64                 ; je operace s kurzorem - OK
GetFFl62:test      byte ptr es:[si+FileAtr],ATRO+ATRU ; je to oznaáen† poloëka ?
         jz        GetFFil5                 ; nen° to oznaáen† poloëka

GetFFl64:or        byte ptr ds:[FileParm],bit3 ; je adres†© p©i n†vratu



; ====== kontrola, zda je nalezen† poloëka ES:SI povolen†

GetFFil7:test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        GetFFil8                ; nen° to adres†©
         test      byte ptr ds:[FileParm],bit4 ; je z†kaz podadres†©ñ pro strom ?
         jnz       GetFFl72                 ; je z†kaz pro strom
         test      byte ptr ds:[FileTyp],bit6 ; je moënÇ vyhled†v†n° adres†©ñ ?
         jnz       GetFFil8                 ; je moënÇ vyhled†v†n° adres†©ñ
GetFFl72:jmp       GetFFil2                 ; dal®° test


; ====== p©°prava parametrñ nalezenÇ poloëky ES:SI

; ------ p©°prava á°taáe kurzoru, velikost souboru

GetFFil8:xor       ax,ax
         mov       word ptr ds:[InfoKCit],ax      ; á°taá kurzoru LOW
         mov       word ptr ds:[InfoKCit+2],ax    ; á°taá kurzoru HIGH
         mov       ax,word ptr es:[si+FileSize]   ; velikost souboru LOW
         mov       word ptr ds:[FileFSiz],ax      ; velikost souboru LOW
         mov       word ptr ds:[InfoKMax],ax      ; velikost souboru LOW
         mov       ax,word ptr es:[si+FileSize+2] ; velikost souboru HIGH
         mov       word ptr ds:[InfoKMax+2],ax    ; velikost souboru HIGH
         mov       word ptr ds:[FileFSiz+2],ax    ; velikost souboru HIGH

; ------ parametry souboru

         mov       al,es:[si+FileAtr]       ; atributy poloëky
         and       al,ARC+DIR+SYS+HID+RO    ; pouze platnÇ atributy
         test      al,DIR                   ; je to adres†© ?
         jz        GetFFl82                 ; nen° to adres†©
         mov       word ptr ds:[FileFSiz],0 ; zru®en° velikosti poloëky
         mov       word ptr ds:[FileFSiz+2],0
GetFFl82:mov       ds:[FileFAtr],al         ; atributy poloëky
         mov       ax,es:[si+FileDate]      ; datum poloëky
         mov       ds:[FileFDat],ax         ; datum poloëky
         mov       ax,es:[si+FileTime]      ; áas poloëky
         mov       ds:[FileFTim],ax         ; áas poloëky

; ------ dek¢dov†n° jmÇna souboru (soubor v aktivn°m oknà pod kurzorem)

         push      cs
         call      near ptr GetNFFil        ; dek¢dov†n° jmÇna souboru
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FilePath       ; jmÇno souboru
         mov       cx,ds:[FileFilN]         ; dÇlka jmÇna souboru
         clc                                ; p©°znak operace OK



; ------ n†vrat registrñ

GetFFil9:pop       bp
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

GetFFil  ENDP

; -----------------------------------------------------------------------------
;  vno©en° do adres†©e FilePath/FilePthN (neuchov†v† registry; CY=nelze se vno©it)
; -----------------------------------------------------------------------------

GetFInc  PROC      NEAR

; ------ vytvo©en° novÇho okna

         call      far ptr GetAAWin         ; ES <- adresa aktivn°ho okna
         mov       cl,es:[AWinPrm2]         ; parametry okna - t©°dàn°
         call      far ptr CreatAWn         ; vytvo©en° novÇho okna
         jnc       GetFInc1

         call      far ptr MemErr           ; chybovÇ hl†®en° - chyba pamàti
         jmp       GetFInc9

GetFInc1:mov       es:[AWinPrm2],cl         ; t©°dàn° okna
         or        byte ptr es:[AWinPrm0],bit0+bit3 ; oznaáit platnÇ poloëky

; ------ nahrazen° aktivn°ho okna novà vytvo©enòm oknem AX

         mov       bx,ds:[FileWNum]         ; poáet uschovanòch oken
         shl       bx,1                     ; poáet oken * 2
         mov       dx,ds:[SegmAkt]          ; souáasnÇ aktivn° okno
         mov       ds:[bx+FileWSeg],dx      ; £schova á°sla aktivn°ho okna
         inc       word ptr ds:[FileWNum]   ; zvò®en° ukazatele £rovnà oken
         call      far ptr XchgWSeg         ; nahrazen° DX novòm oknem AX

; ------ p©enesen° textu adres†©e do definice okna AX/ES

         mov       si,offset FilePath       ; poëadovanò adres†©
         mov       cl,ds:[si]               ; oznaáen° disku
         sub       cl,"A"                   ; á°slo disku
         mov       es:[AWinDisk],cl         ; á°slo disku
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         mov       es:[AWinDNum],cx         ; dÇlka textu adres†©e
         mov       di,AWinDir               ; adres†© okna
         cld
         rep       movsb                    ; p©enos textu adres†©e
         mov       es:[di],cl               ; koncov† 0

; ------ p©enesen° specifikace souborñ k vyhled†v†n°

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        GetFInc2                 ; nen° specifikace textem
         mov       si,offset SrcInit        ; zadanÇ parametry
         mov       di,AWinFilF              ; parametry v oknà
         mov       cx,SIZE AWinFilS         ; velikost tabulky
         cld
         rep       movsb                    ; uloëen° parametrñ
         mov       byte ptr es:[AWinFilP],bit0+bit2+bit7 ; parametry - je maska

; ------ hl†®en° o prohled†v†n°

GetFInc2:mov       di,offset SInfHled       ; text hl†®en° "Prohled†v†m"
         push      cs
         call      near ptr InfFile         ; hl†®en° o prohled†v†n°

; ------ naáten° obsahu okna

         call      far ptr ReadDir          ; naáten° obsahu okna

; ------ p©°znak vno©en° do okna

         and       byte ptr ds:[FileParm],not bit0+bit1+bit5 ; nen° 1. soubor

; ------ adresa okna

         call      far ptr GetDat           ; adresa okna -> ES
         mov       bp,es                    ; BP <- adresa okna

; ------ test, zda je adres†© platnò

         xor       bx,bx                    ; BX <- 0 ukazatel poloëek
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         cmp       cx,es:[AWinDNum]         ; byla cesta zmànàna ?
         je        GetFInc3                 ; cesta zñstala OK
         mov       es:[AWinSouN],bx         ; zru®en° poloëek v adres†©i

; ------ oznaáen° v®ech poloëek v oknà

GetFInc3:mov       es,bp                    ; ES <- adresa okna
         cmp       bx,es:[AWinSouN]         ; je to platn† poloëka ?
         jae       GetFInc9                 ; nen° to platn† poloëka
         mov       si,bx                    ; SI <- á°slo poloëky
         call      Get1FFl0                 ; adresa poloëky
         jc        GetFInc4                 ; nen° to platn† poloëka
         test      byte ptr es:[si+FileAtr],ATRU ; je poloëka oznaáen† ?
         jz        GetFInc5                 ; nen° oznaáen†
         test      byte ptr es:[si+FileAtr],DIR ; je to adres†© ?
         jz        GetFInc4                 ; nen° to adres†©
         test      byte ptr ds:[FileParm],bit4 ; je z†kaz pro strom ?
         jnz       GetFInc5                 ; je z†kaz podadres†©ñ
GetFInc4:mov       es,bp                    ; ES <- adresa okna
         call      far ptr SetSPol          ; oznaáen° poloëky
GetFInc5:inc       bx                       ; zvò®en° ukazatele á°sla poloëky
         jmp       short GetFInc3           ; dal®° poloëka

; ------ obnoven° adresy okna

GetFInc9:pushf
         call      far ptr GetAAWin         ; ES <- adresa aktivn°ho okna
         mov       bp,es                    ; BP <- £schova adresy okna
         popf
         ret

GetFInc  ENDP

; -----------------------------------------------------------------------------
;        vyno©en° z adres†©e (CY=nen° dal®° hladina)
; -----------------------------------------------------------------------------

GetFDec  PROC      NEAR

; ------ ukazatel hladiny

         mov       bx,ds:[FileWNum]         ; poáet uschovanòch oken
         dec       bx                       ; sn°ëen° ukazatele oken
         stc                                ; p©°znak, ëe jië nen° dal®° okno
         js        GetFDec9                 ; je jië z†kladn° hladina

; ------ nulov†n° z†kazu pro strom

         jnz       GetFDec2                 ; nen° z†kladn° hladina
         and       byte ptr ds:[FileParm],not bit4 ; zru®en° z†kazu pro strom

; ------ zkr†cen° cesty

GetFDec2:call      far ptr SubGFil          ; zkr†cen° cesty
         and       byte ptr ds:[FileParm],not bit5 ; zru®en° z†kazu vno©en°

; ------ zru®en° souáasnÇho aktivn°ho okna

         mov       ax,ds:[SegmAkt]          ; souáasnò aktivn° segment
         call      far ptr DeletAWn         ; zru®en° okna

; ------ n†hrada uschovanòm oknem

         xchg      ax,dx                    ; DX <- segment starÇho okna
         mov       ds:[FileWnum],bx         ; novò ukazatel £rovnà
         shl       bx,1                     ; ukazatel £rovnà * 2
         mov       ax,ds:[bx+FileWSeg]      ; n†vrat segmentu okna
         call      far ptr XchgWSeg         ; n†vrat segmentñ okna
         or        byte ptr ds:[FileParm],bit0+bit1 ; byla 1.poloëka + vno©en°

; ------ adresa novÇho aktivn°ho okna

         call      far ptr GetAAWin         ; adresa novÇho aktivn°ho okna
         mov       bp,es                    ; BP <- adresa okna
         jc        GetFDec9                 ; chyba

; ------ pro zad†n° textem nen° povolena operace v aktivn°m oknà

         test      byte ptr ds:[FileTyp],bit3 ; je zad†n° textem ?
         jz        GetFDec9                 ; nen° zad†n° textem
         cmp       word ptr ds:[FileWNum],0 ; je to posledn° hladina ?
         jne       GetFDec9                 ; nen° to posledn° hladina
         stc                                ; p©°znak z†kazu operace

GetFDec9:ret

GetFDec  ENDP

; *****************************************************************************
;                             GetNFFil
;     sestaven° jmÇna nalezenÇho souboru do FilePath (poloëka pod kurzorem)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

GetNFFil PROC      FAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ test, zda je okno seznamu

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       bp,es                    ; BP <- £schova adresy okna
         mov       bx,es:[AWinKurz]         ; kurzor
         test      byte ptr es:[AWinPrm1],bit5 ; je to seznam ?
         jz        GetNFFl4                 ; nen° to seznam

; ------ adresa p©ede®lÇ poloëky

         inc       bx
GetNFFl2:mov       es,bp                    ; ES <- adresa okna
         dec       bx                       ; p©edch†zej°c° poloëka
         call      far ptr GetESPol         ; adresa poloëky -> ES:SI
         jc        GetNFFl3                 ; nen° dal®° poloëka

; ------ test, zda je to cesta

         test      byte ptr es:[si+FileAtr],ATRT ; je to cesta ?
         jnz       GetNFFl2                 ; nen° cesta - dal®° poloëka

; ------ p©enos textu adres†©e

         push      ds                       ; £schova DS
         push      ds
         push      es
         pop       ds                       ; DS <- segment poloëky
         pop       es                       ; ES <- datovò segment
         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka textu adres†©e
         inc       si                       ; zaá†tek textu cesty
         cld
         mov       es:[FilePthN],cx         ; dÇlka textu adres†©e
         mov       di,offset FilePath       ; buffer adres†©e
         rep       movsb                    ; p©enos textu adres†©e
         mov       es:[di],cl               ; koncov† 0
         pop       ds                       ; n†vrat DS
GetNFFl3:jmp       short GetNFFl7           ; p©id†n° jmÇna poloëky

; ------ test, zda je okno stromu

GetNFFl4:test      byte ptr es:[AWinPrm1],bit4 ; je to strom ?
         jz        GetNFFl7                 ; nen° to strom

; ------ poloëka pod kurzorem -> ES:SI

         call      far ptr GetAKurz         ; poloëka pod kurzorem
         jc        GetNFFl7

; ------ dek¢dov†n° cesty k poloëce

         push      ds                       ; £schova DS
         push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         pop       ds                       ; DS <- segment poloëky
         mov       di,offset FilePath       ; buffer cesty
         call      far ptr GetPthTW         ; dek¢dov†n° poloëky
         pop       ds                       ; n†vrat DS
         sub       si,offset FilePath       ; dÇlka cesty (bez koncovÇ poloëky)
         mov       ds:[FilePthN],si         ; dÇlka cesty

; ------ zaji®tàn° koncovÇho znaku "\"

GetNFFl7:mov       di,offset FilePath       ; cesta
         add       di,ds:[FilePthN]         ; konec cesty
         cmp       byte ptr ds:[FilePthN],0 ; je to ROOT ?
         je        GetNFFl8                 ; je to ROOT
         cmp       byte ptr ds:[di-1],"\"   ; je znak "\" ?
         je        GetNFFl8                 ; je jië znak "\"
         mov       byte ptr ds:[di],"\"     ; koncovò znak "\"
         inc       di                       ; zvò®en° ukazatele textu

; ------ dek¢dov†n° jmÇna souboru ES:SI

GetNFFl8:call      far ptr GetAKurz         ; adresa poloëky -> ES:SI
         push      ds                       ; £schova DS
         push      es
         push      ds
         pop       es                       ; ES <- datovò segment
         pop       ds                       ; DS <- segment s poloëkou souboru
         inc       si                       ; zaá†tek jmÇna souboru
         push      cs
         call      near ptr FileAsc         ; p©id†n° jmÇna souboru
         pop       ds                       ; n†vrat DS

; ------ dÇlka textu jmÇna souboru

         sub       di,offset FilePath       ; dÇlka textu
         mov       ds:[FileFilN],di         ; dÇlka textu jmÇna souboru
         mov       word ptr ds:[FileIdnt],0 ; soubor nen° otev©en

; ------ n†vrat registrñ

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

GetNFFil ENDP

; -----------------------------------------------------------------------------
;        poskytnut° adresy poloëky SI (okno ES) -> ES:SI (CY=zak†zan† poloëka)
; -----------------------------------------------------------------------------

Get1FFil PROC      NEAR

; ------ £schova ukazatele kurzoru

         mov       es:[AWinKurz],si         ; ukazatel kurzoru

; ------ adresa poloëky (sem se sk†áe z procedury INITFFIL)

Get1FFl0:push      bx
         mov       bx,si                    ; á°slo poëadovanÇ poloëky
         call      far ptr GetESPol         ; adresa poloëky
         pop       bx
         jc        Get1FFl2                 ; nen° to platn† poloëka

; ------ test, zda je to povolen† poloëka

         cmp       byte ptr es:[si+FileName],"." ; je to povolen† poloëka ?
         je        Get1FFl1                 ; nen° to povolen† poloëka
         test      byte ptr es:[si+FileAtr],ATRT ; je to platn† poloëka ?
         jnz       Get1FFl2                 ; je to platn† poloëka
Get1FFl1:stc                                ; p©°znak zak†zanÇ poloëky
Get1FFl2:ret

Get1FFil ENDP

; *****************************************************************************
;                              DekFParm
;            dek¢dov†n° parametrñ souboru do textovÇho tvaru
; -----------------------------------------------------------------------------
; VSTUP: [FileFilN]=celkov† dÇlka jmÇna (i s cestou)
;        DS=datovò segment
; *****************************************************************************

DekFParm PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ zji®tàn° dÇlky jmÇna souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FilePath+1     ; buffer jmÇna poloëky
         add       si,ds:[FileFilN]         ; adresa konce jmÇna poloëky + 1
         xor       cx,cx                    ; á°taá dÇlky jmÇna poloëky
         dec       cx                       ; p©ednastaven° - 1
DekFPrm2:dec       si                       ; posun ukazatele textu
         inc       cx                       ; zvò®en° á°taáe dÇlky jmÇna
         cmp       byte ptr ds:[si-1],"\"   ; nalezen zaá†tek jmÇna poloëky ?
         jne       DekFPrm2                 ; nalezen° zaá†tku jmÇna poloëky

; ------ dek¢dov†n° jmÇna souboru

         cld
         mov       al,cl                    ; dÇlka textu jmÇna poloëky
         mov       di,offset SRMnuFil       ; buffer k dek¢dov†n° jmÇna souboru
         stosb                              ; dÇlka jmÇna souboru
         rep       movsb                    ; p©enos jmÇna souboru

; ------ dek¢dov†n° velikosti

         mov       di,offset SRMnuSiz+1
         mov       cl,13
         mov       al," "                   ; mezera k vymaz†n°
         rep       stosb                    ; vymaz†n° bufferu

         mov       ax,word ptr ds:[FileFSiz] ; velikost LOW
         mov       dx,word ptr ds:[FileFSiz+2] ; velikost HIGH
         mov       di,offset SRMnuSiz+1     ; buffer k dek¢dov†n° velikosti
         xor       bh,bh                    ; nen° atribut barvy
         mov       bl,ds:[OddelRad]         ; znak oddàlovaáe ©†dñ
         call      far ptr DekNum           ; dek¢dov†n° á°sla

; ------ dek¢dov†n° data

         mov       dx,ds                    ; DX <- datovò segment
         mov       si,offset FileFPol       ; poloëka nalezenÇho souboru
         mov       di,offset SRMnuDat+1     ; buffer k uloëen° data poloëky
         mov       ah,0                     ; barva se neukl†d†
         call      far ptr DekA4Dat         ; dek¢dov†n° data poloëky

; ------ dek¢dov†n° áasu

         mov       di,offset SRMnuTim+1     ; buffer k uloëen° áasu poloëky
         call      far ptr DekATmS          ; dek¢dov†n° áasu poloëky

; ------ dek¢dov†n° atributñ

         mov       di,offset SRMnuAtr+1     ; buffer k uloëen° atributñ
         call      far ptr DekAAtr          ; dek¢dov†n° atributñ poloëky

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekFParm ENDP

; *****************************************************************************
;                               ResFFil
;             nulov†n° oznaáen° poloëky (kurzor), je-li operace OK
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ResFFil  PROC      FAR

; ------ £schova registrñ

         push      bx
         push      si
         push      es

; ------ adresa aktivn°ho okna

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         jc        ResFFil9                 ; chyba

; ------ nulov†n° oznaáen° poloëky

         cmp       byte ptr ds:[FileWNum],0
         jne       ResFFil6
         test      byte ptr ds:[FileTyp],bit0 ; je operace s kurzorem ?
         jnz       ResFFil9                 ; je operace s kurzorem

; ------ test, zda je poloëka povolena

ResFFil6:mov       si,es:[AWinKurz]         ; poloëka s kurzorem
         call      Get1FFl0                 ; adresa poloëky
         jc        ResFFil9                 ; poloëka neplatn†
         test      byte ptr es:[si+FileAtr],ATRO ; je poloëka oznaáen† ?
         jz        ResFFil9                 ; nen° oznaáen†
         test      byte ptr es:[si+FileAtr],ATRU ; byla nalezena k operaci ?
         jnz       ResFFil9                 ; nebyla nalezena

; ------ nulov†n° oznaáen° poloëky

         or        byte ptr es:[si+FileAtr],ATRU ; p©°znak £schovy oznaáen°
         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         mov       bx,es:[AWinKurz]         ; uschovanÇ á°slo poloëky
         call      far ptr ResSPol          ; nulov†n° oznaáen° poloëky

; ------ n†vrat registrñ

ResFFil9:pop       es
         pop       si
         pop       bx
         ret

ResFFil  ENDP

; *****************************************************************************
;                               GetBFCB
;         p©evod jmÇna souboru na tvar FCB (do bufferu FILEFCB)
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poloëka DTA s nalezenòm souborem (moënÇ tÇë zakonáen° s "\")
;        DS=datovò segment
; *****************************************************************************

GetBFCB0 label     far

         push      di
         mov       di,offset FileFCB0       ; pomocnò buffer jmÇna souboru FCB
         jmp       short GetBFCB1

GetBFCB  PROC      FAR

; ------ £schova registrñ

         push      di
         mov       di,offset FileFCB        ; buffer jmÇna souboru FCB

GetBFCB1:push      si
         push      ds
         push      es

; ------ p©°prava segmentovòch registrñ

         push      ds
         push      es
         pop       ds                       ; DS <- poloëka DTA
         pop       es                       ; ES <- datovò segment

; ------ dek¢dov†n° jmÇna poloëky

         add       si,DTAName               ; jmÇno nalezenÇho souboru
         call      far ptr AsciFCB          ; dek¢dov†n° jmÇna poloëky

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       si
         pop       di
         ret

GetBFCB  ENDP

; *****************************************************************************
;                               AsciFCB
;                  p©evod jmÇna poloëky ASCIIZ na tvar FCB
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text jmÇna poloëky ASCIIZ (mñëe zaá°nat i konáit znakem "\")
;        ES:DI=buffer k dek¢dov†n° jmÇna poloëky (11 bajtñ)
; *****************************************************************************

AsciFCB  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di                       ; DI jako posledn° !

; ------ inicializaán° vymaz†n° poloëky FCB

         cld
         push      di
         mov       cx,11                    ; dÇlka jmÇna
         mov       al," "                   ; mazac° znak mezery
         rep       stosb                    ; vymaz†n° bufferu znakem mezery
         pop       di

; ------ vypu®tàn° p©°padnÇho poá†teán°ho znaku "\"

         lodsb                              ; naáten° prvn°ho znaku
         cmp       al,"\"                   ; zaá°n† znakem "\" ?
         je        AsciFCB2                 ; zaá°n† znakem "\"
         dec       si                       ; n†vrat prvn°ho znaku

; ------ dek¢dov†n° jmÇna poloëky

AsciFCB2:mov       cl,8                     ; dÇlka jmÇna
AsciFCB4:lodsb                              ; znak jmÇna souboru
         cmp       al,0                     ; je to konec textu ?
         je        AsciFCB8                 ; konec jmÇna souboru
         cmp       al,"\"
         je        AsciFCB8                 ; konec jmÇna podadres†©e

; ------ oddàlovac° teáka p©°pony jmÇna souboru

         cmp       al,"."                   ; je p©°pona ?
         jne       AsciFCB6                 ; nen° p©°pona
         pop       di                       ; DI <- adresa poá†tku bufferu
         push      di
         add       di,8                     ; adresa k dek¢dov†n° p©°pony
         mov       cl,3                     ; dÇlka p©°pony jmÇna
         jmp       short AsciFCB4

; ------ uloëen° znaku jmÇna souboru do bufferu

AsciFCB6:jcxz      AsciFCB4                 ; jsou jië v®echny znaky
         stosb                              ; uloëen° znaku jmÇna souboru
         dec       cx                       ; á°taá znakñ
         jmp       short AsciFCB4           ; dal®° znak

; ------ n†vrat registrñ

AsciFCB8:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

AsciFCB  ENDP

; *****************************************************************************
;        kontrola ostatn°ch parametrñ souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=poloëka DTA s nalezenòm souborem
;        DS:DI=tabulka parametrñ - ukazatel na poloëku atributñ
; VùSTUP:CY=poloëka neodpov°d†
; *****************************************************************************

GetBTest PROC      FAR

         push      ax

; ------ kontrola atributñ souboru

         mov       al,byte ptr es:[si+DTAAtrib]      ; atributy souboru
         and       al,byte ptr ds:[di+AWinFAtM] ; maskov†n° atributñ
         cmp       al,byte ptr ds:[di+AWinFAtr] ; odpov°daj° atributy ?
         jne       GetBTst0                 ; atributy neodpov°daj°

; ------ kontrola, zda se áas testuje vnà intervalu

         test      byte ptr ds:[di+AWinFPrm],bit0 ; áas vnà intervalu ?
         jz        GetBTst1                 ; netestuje se vnà intervalu

; ------ kontrola minim†ln°ho áasu (vnà intervalu)

         mov       ax,word ptr es:[si+DTATime]       ; áas souboru
         and       ax,word ptr ds:[di+AWinFT1M] ; maskov†n° áasu
         cmp       ax,word ptr ds:[di+AWinFT1] ; kontrola áasu
         jae       GetBTst2                 ; áas odpov°d† OK

; ------ kontrola maxim†ln°ho áasu souboru (vnà intervalu)

         mov       ax,word ptr es:[si+DTATime]       ; áas souboru
         and       ax,word ptr ds:[di+AWinFT2M] ; maskov†n° áasu
         cmp       ax,word ptr ds:[di+AWinFT2] ; kontrola áasu
         jbe       GetBTst2                 ; áas odpov°d† OK
GetBTst0:jmp       GetBTst8                 ; jinak chyba

; ------ kontrola minim†ln°ho áasu souboru

GetBTst1:mov       ax,word ptr es:[si+DTATime]       ; áas souboru
         and       ax,word ptr ds:[di+AWinFT1M] ; maskov†n° áasu
         cmp       ax,word ptr ds:[di+AWinFT1] ; kontrola áasu
         jb        GetBTst8                 ; áas neodpov°d†

; ------ kontrola maxim†ln°ho áasu souboru

         mov       ax,word ptr es:[si+DTATime]       ; áas souboru
         and       ax,word ptr ds:[di+AWinFT2M] ; maskov†n° áasu
         cmp       ax,word ptr ds:[di+AWinFT2] ; kontrola áasu
         ja        GetBTst8                 ; áas neodpov°d†

; ------ kontrola, zda se datum testuje vnà intervalu

GetBTst2:test      byte ptr ds:[di+AWinFPrm],bit1 ; datum vnà intervalu ?
         jz        GetBTst3                 ; netestuje se vnà intervalu

; ------ kontrola minim†ln°ho data souboru (vnà intervalu)

         mov       ax,word ptr es:[si+DTADate]       ; datum souboru
         and       ax,word ptr ds:[di+AWinFD1M] ; maskov†n° data
         cmp       ax,word ptr ds:[di+AWinFD1] ; kontrola data
         jae       GetBTst4                 ; datum odpov°d† OK

; ------ kontrola maxim†ln°ho data souboru (vnà intervalu)

         mov       ax,word ptr es:[si+DTADate]       ; datum souboru
         and       ax,word ptr ds:[di+AWinFD2M] ; maskov†n° data
         cmp       ax,word ptr ds:[di+AWinFD2] ; kontrola data
         jbe       GetBTst4                 ; datum odpov°d† OK
         jmp       short GetBTst8           ; jinak chyba

; ------ kontrola minim†ln°ho data souboru

GetBTst3:mov       ax,word ptr es:[si+DTADate]       ; datum souboru
         and       ax,word ptr ds:[di+AWinFD1M] ; maskov†n° data
         cmp       ax,word ptr ds:[di+AWinFD1] ; kontrola data
         jb        GetBTst8                 ; datum neodpov°d†

; ------ kontrola maxim†ln°ho data souboru

         mov       ax,word ptr es:[si+DTADate]       ; datum souboru
         and       ax,word ptr ds:[di+AWinFD2M] ; maskov†n° data
         cmp       ax,word ptr ds:[di+AWinFD2] ; kontrola data
         ja        GetBTst8                 ; datum neodpov°d†

; ------ kontrola maxim†ln° velikosti

GetBTst4:mov       ax,word ptr es:[si+DTASize+2]     ; velikost souboru HIGH
         cmp       ax,word ptr ds:[di+AWinFSz2+2] ; kontrola max. velikosti HIGH
         jne       GetBTst6                 ; li®° se ve slovu HIGH
         mov       ax,word ptr es:[si+DTASize]       ; velikost souboru LOW
         cmp       ax,word ptr ds:[di+AWinFSz2] ; kontrola max. velikosti LOW
GetBTst6:ja        GetBTst8                 ; velikost neodpov°d†

; ------ kontrola minim†ln° velikosti

         mov       ax,word ptr es:[si+DTASize+2]     ; velikost souboru HIGH
         cmp       ax,word ptr ds:[di+AWinFSz1+2] ; kontrola min. velikosti HIGH
         jne       GetBTst7
         mov       ax,word ptr es:[si+DTASize]       ; velikost souboru LOW
         cmp       ax,word ptr ds:[di+AWinFSz1] ; kontrola min. velikosti LOW
GetBTst7:jae       GetBTst9                 ; velikost odpov°d† OK

GetBTst8:stc                                ; p©°znak - poloëka neodpov°d†
GetBTst9:pop       ax
         ret

GetBTest ENDP

; *****************************************************************************
;                              SrcFText
;                test, zda soubor obsahuje hledanò text
;             P©edpokl†d† se, ëe neposouv† pamàüovÇ bloky !!!!
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=jmÇno testovanÇho souboru
;        CX=dÇlka jmÇna souboru
;        DX:DI=tabulka parametrñ - ukazatel na poloëku atributñ
;        DS=datovò segment
; VùSTUP: CY=text nenalezen (nebo p©eru®en° operace)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment jmÇna souboru
;                   SS:[BP-4] (2) offset jmÇna souboru
;                   SS:[BP-6] (2) dÇlka jmÇna souboru
;                   SS:[BP-8] (2) identifik†tor souboru (0=nen° otev©en)
;                   SS:[BP-10] (2) á°slo segmentu s bufferem (0=nen°)
;                   SS:[BP-12] (2) adresa bufferu
;                   SS:[BP-14] (2) velikost bufferu (bajtñ)
;                   SS:[BP-16] (2) poáet bajtñ v bufferu
;                   SS:[BP-18] (2) segment tabulky parametrñ
;                   SS:[BP-20] (2) offset hledanÇho textu + 1
;                   SS:[BP-22] (2) offset tabulky parametrñ
;                   SS:[BP-24] (2) dÇlka hledanÇho textu
;                   SS:[BP-25] (1) konverzn° k¢d
;                                    0 = nen° konverze
;                                    bit 0: 1=ASCII ("U")
;                                    bit 1: 1=IBM ("I")
;                                    bit 2: 1=Kamenickòch ("K")
;                                    bit 3: 1=Latin 2 ("L")
;                                    bit 4: 1=KOI 8 ("O")
;                                    bit 5: 1=WINDOWS ("W")
;                   SS:[BP-26] (1) prvn° znak hledanÇho textu
; *****************************************************************************
;˛
SrcFText PROC      FAR

; ------ test, zda je zadanò text

         push      ds
         mov       ds,dx                    ; DS <- segment tabulky parametrñ
         cmp       byte ptr ds:[di+AWinFTxN],0 ; je zad†n text k hled†n° ?
         pop       ds
         jne       SrcFTxt1                 ; je zad†n nàjakò text k hled†n°
SrcFTxt0:ret

; ------ £schova registrñ

SrcFTxt1:call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jc        SrcFTxt0                 ; je p©eru®en° operace
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,26

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],es             ; segment jmÇna souboru
         mov       ss:[bp-4],si             ; offset jmÇna souboru
         mov       ss:[bp-6],cx             ; dÇlka jmÇna souboru
         mov       word ptr ss:[bp-8],0     ; identifik†tor souboru (0=nen°)
         mov       word ptr ss:[bp-10],0    ; á°slo segmentu s bufferem (0=nen°)
         mov       word ptr ss:[bp-16],0    ; v bufferu nejsou data
         mov       ss:[bp-18],dx            ; segment tabulky parametrñ
         mov       ss:[bp-22],di            ; offset tabulky parametrñ

         push      ds
         mov       ds,dx                    ; DS <- segment tabulky parametrñ
         mov       al,ds:[di+AWinFKod]      ; konverzn° k¢d souboru
         mov       ss:[bp-25],al            ; konverzn° k¢d souboru
         mov       ax,ds:[di+AWInFTxN]      ; dÇlka hledanÇho textu
         mov       ss:[bp-24],ax            ; dÇlka hledanÇho textu
         add       di,AWinFTxt + 1
         mov       al,ds:[di-1]             ; prvn° znak textu
         mov       ss:[bp-26],al            ; prvn° znak hledanÇho textu
         pop       ds
         mov       ss:[bp-20],di            ; offset hledanÇho textu + 1

; ------ zobrazen° hl†®en° o operaci

         push      cs
         call      near ptr InfoClr0        ; vymaz†n° informaán°ho ©†dku
         push      si
         mov       si,offset SInfHled       ; text hl†®en° "Prohled†v†m"
         push      cs
         call      near ptr InfoTxt         ; dek¢dov†n° textu hl†®en°
         pop       si
         push      cs
         call      near ptr InfoDek         ; dek¢dov†n° jmÇna souboru
         xor       cx,cx                    ; CX <- á°taá kurzoru
         push      cs
         call      near ptr InfoKurz        ; kurzor + zobrazen° inform. ©†dku

; ------ otev©en° souboru ES:SI pro áten°

         call      far ptr OpenR            ; otev©en° souboru pro áten°
         jc        SrcFTx12                 ; chyba - soubor nenalezen
         mov       ss:[bp-8],ax             ; identifik†tor souboru

; ------ vytvo©en° datovÇho bufferu

         mov       bx,300                   ; asi tak velikost bufferu
         call      far ptr CreatDat         ; vytvo©en° bufferu
         jnc       SrcFTxt2                 ; operace OK
         call      far ptr MemErr           ; chyba - nedostatek pamàti
SrcFTx12:jmp       short SrcFTxt9           ; chyba - nedostatek pamàti

SrcFTxt2:mov       ss:[bp-10],ax            ; á°slo segmentu s bufferem
         mov       ss:[bp-14],bx            ; velikost bufferu (bajtñ)
         call      far ptr GetDat           ; adresa bufferu
         mov       ss:[bp-12],es            ; adresa bufferu

; ------ naáten° dal®°ho bloku dat ze souboru

SrcFTxt3:mov       cx,ss:[bp-14]            ; velikost bufferu (bajtñ)
         mov       ax,ss:[bp-8]             ; identifik†tor souboru
         mov       di,ss:[bp-16]            ; poáet bajtñ v bufferu
         sub       cx,di                    ; zbyl† velikost bufferu
         call      far ptr ReadFile         ; naáten° dal®°ch dat ze souboru
         jc        SrcFTxt9                 ; nàjak† chyba
         add       ss:[bp-16],cx            ; zvò®en° poátu bajtñ v bufferu

; ------ zobrazen° informaán°ho kurzoru

         push      cs
         call      near ptr InfoKurz        ; zobrazen° informaán°ho kurzoru

; ------ konverze naátenòch dat na velk† p°smena

         mov       si,di                    ; adresa naátenòch dat
         mov       dl,ss:[bp-25]            ; konverzn° k¢d souboru
         call      far ptr KonvUpC          ; konverze na velk† p°smena

; ------ p©°prava registrñ k hled†n° ©etàzce

         xor       di,di                    ; DI <- ukazatel dat v bufferu
         mov       cx,ss:[bp-16]            ; souáasnò poáet bajtñ v bufferu
         sub       cx,ss:[bp-24]            ; poáet pozic k testov†n°
         jc        SrcFTxt9                 ; nejsou dal®° data k testov†n°
         inc       cx                       ; poáet ©etàzcñ k testov†n°
         cld

; ------ nalezen° prvn°ho bajtu ©etàzce

         mov       al,ss:[bp-26]            ; prvn° bajt textu
SrcFTxt5:repne     scasb                    ; nalezen° prvn°ho bajtu ©etàzce
         jne       SrcFTxt7                 ; bajt nenalezen

; ------ porovn†n° ostatn°ch bajtñ ©etàzce (zde je NC pro p©°pad kr†tkÇho ©etàzce !)

         push      cx
         push      di
         push      ds

         mov       cx,ss:[bp-24]            ; dÇlka hledanÇho textu
         dec       cx                       ; bez prvn°ho bajtu (pro CX=1 je ZY)
                                          ;* p©i CX=0 je zde NC a ZY
         lds       si,ss:[bp-20]            ; adresa zbytku hledanÇho textu
         repe      cmpsb                    ; porovn†n° ©etàzce

         pop       ds
         pop       di
         pop       cx

         jne       SrcFTxt5                 ; ©etàzec nesouhlas° - dal®°
         jmp       short SrcFTxt9           ; text nalezen OK (je NC a ZY)

; ------ ©etàzec nenalezen - p©esun zbytku dat na zaá†tek bufferu

SrcFTxt7:mov       si,di                    ; SI <- zaá†tek zbytku
         xor       di,di                    ; DI <- 0
         mov       cx,ss:[bp-24]            ; dÇlka hledanÇho textu
         dec       cx                       ; dÇlka zbytku ©etàzce
         mov       ss:[bp-16],cx            ; novò poáet bajtñ v bufferu
         push      ds
         push      es
         pop       ds                       ; DS <- segment bufferu
         rep       movsb                    ; p©°sun zbytku textu
         pop       ds
         call      far ptr TestBEsc         ; je p©eru®en° operace ?
         jnc       SrcFTxt3                 ; nen° p©eru®en° - dal®° blok dat

; ------ ukonáen° reëimu hled†n°

SrcFTxt9:pushf
         mov       ax,ss:[bp-10]            ; á°slo segmentu s bufferem
         call      far ptr DelSeg           ; zru®en° segmentu bufferu
         mov       ax,ss:[bp-8]             ; identifik†tor souboru
         call      far ptr ClosFile         ; uzav©en° souboru
         call      far ptr InfoClos         ; uzav©en° informaán°ho ©†dku
         popf

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

SrcFText ENDP

; *****************************************************************************
;                             FileAsc
;              dek¢dov†n° poloëky souboru na ASCIIZ text
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel na jmÇno souboru v FCB tvaru
;        ES:DI=buffer k uloëen° rozboru
; VùSTUP:ES:DI=ukazatel na koncovou 0 textu ASCIIZ
; *****************************************************************************

FileAsc  PROC      FAR

         push      cx
         push      si

         mov       cx,8                     ; 8 znakñ jmÇna
         call      FilAsc0                  ; dek¢dov†n° jmÇna souboru
         mov       byte ptr es:[di],"."     ; oddàlovac° teáka
         inc       di                       ; zvò®en° ukl†dac° adresy
         add       si,8                     ; ukazatel na p©°ponu jmÇna souboru
         mov       cl,3                     ; 3 znaky p©°pony souboru
         call      FilAsc0                  ; dek¢dov†n° p©°pony souboru

         cmp       byte ptr es:[di-1],"."   ; byla nàjak† p©°pona ?
         jne       FileAsc2                 ; byla nàjak† p©°pona
         dec       di                       ; zru®en° znaku "." na konci
FileAsc2:mov       byte ptr es:[di],0       ; koncov† 0

         pop       si
         pop       cx
         ret

FileAsc  ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov†n° jmÇna nebo p©°pony souboru na ASCII tvar
; -----------------------------------------------------------------------------
; VSTUP: CX=dÇlka
;        DS:SI=adresa jmÇna nebo p©°pony v FCB tvaru
;        ES:DI=ukl†dac° adresa
; -----------------------------------------------------------------------------

FilAsc0  PROC      NEAR

; ------ zji®tàn° dÇlky platnÇ á†sti jmÇna/p©°pony

         push      si
         add       si,cx                    ; nastaven° ukazatele na konec + 1
FilAsc01:dec       si                       ; nastaven° na dal®° znak
         cmp       byte ptr ds:[si]," "     ; je oddàlovac° mezera ?
         jne       FilAsc02                 ; nen° mezera - je platnò znak
         loop      FilAsc01                 ; nalezen° jinÇho znaku neë mezera
FilAsc02:pop       si

; ------ p©enos platnÇ á†sti jmÇna/p©°pony

         push      si                       ; £schova zaá†tku
         cld
         rep       movsb
         pop       si
         ret

FilAsc0  ENDP

; *****************************************************************************
;                                   AddGFil
;                    p©id†n° jmÇna souboru (adres†©e) k cestà
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text jmÇna souboru ASCIIZ k p©id†n°
;        DS=datovò segment
; VùSTUP:CY=p©eteáen° dÇlky bufferu
; *****************************************************************************

AddGFil  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ stanoven° dÇlky jmÇna souboru

         mov       cx,0ffffh
         mov       di,si                    ; adresa textu
         mov       al,0                     ; hledanò bajt
         cld
         repne     scasb                    ; nalezen° konce textu
         neg       cx
         dec       cx
         dec       cx                       ; CX = dÇlka textu

; ------ kontrola, zda bude p©eteáen° bufferu

         mov       ax,cx                    ; dÇlka textu
         add       ax,ds:[FilePthN]         ; nov† dÇlka textu cesty
         cmp       al,200                   ; asi tak maxim†ln° dÇlka bufferu
         cmc
         jc        AddGFil9                 ; p©eteáen° bufferu

; ------ zaji®tàn° koncovÇho znaku "\"

         mov       di,offset FilePath       ; buffer cesty
         add       di,ds:[FilePthN]         ; konec cesty
         mov       al,"\"                   ; koncovò znak adres†©e
         cmp       ds:[di-1],al             ; koná° znakem "\" ?
         je        AddGFil3                 ; koná° znakem "\" - OK
         mov       ds:[di],al               ; oddàlovac° znak
         inc       di                       ; posun ukazatele na dal®° znak

; ------ p©enesen° textu

AddGFil3:push      ds
         push      es

         push      ds
         push      es
         pop       ds                       ; DS <- segment jmÇna souboru
         pop       es                       ; ES <- datovò segment
         rep       movsb                    ; p©enesen° textu
         mov       al,0                     ; koncov† 0
         stosb                              ; uloëen° koncovÇ 0

         pop       es
         pop       ds

; ------ nov† dÇlka textu

         sub       di,offset FilePath+1     ; nov† dÇlka textu
         mov       ds:[FilePthN],di         ; nov† dÇlka textu
                                          ;* zde je NC = operace OK
; ------ n†vrat registrñ

AddGFil9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

AddGFil  ENDP

; *****************************************************************************
;                                  SubGFil
;                   odstranàn° posledn°ho souboru z cesty
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SubGFil  PROC      FAR

; ------ £schova registrñ

         push      si

; ------ konec textu v bufferu

         mov       si,offset FilePath       ; buffer cesty
         add       si,ds:[FilePthN]         ; adresa konce textu cesty

; ------ nalezen° posledn°ho znaku "\"

SubGFil1:dec       si                       ; sn°ëen° ukazatele v bufferu
         cmp       byte ptr ds:[si],"\"     ; je konec cesty ?
         jne       SubGFil1                 ; nen° - dal®° znak

; ------ oznaáen° konce cesty

         cmp       byte ptr ds:[si-1],":"   ; je to ROOT ?
         jne       SubGFil2                 ; nen° to ROOT
         inc       si                       ; n†vrat ukazatele ("\" zñstane)
SubGFil2:mov       byte ptr ds:[si],0       ; koncov† 0

; ------ nov† dÇlka cesty

         sub       si,offset FilePath       ; dÇlka textu cesty
         mov       ds:[FilePthN],si         ; nov† dÇlka cesty

; ------ n†vrat registrñ

         pop       si
         ret

SubGFil  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                     Rozbor zad†n° parametrñ operace
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 RozborZ
;                    rozbor zad†n° parametrñ s kontrolou
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=p©eru®en° operace
;         NZ=chyba zad†n° parametrñ, opakov†n° zad†n°
;         ZY=v®e OK
; *****************************************************************************

RozborZ  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ rozbor zad†n° parametrñ operace

         push      cs
         call      near ptr Rozbor          ; rozbor zad†n° parametrñ operace
         mov       si,offset ChbLnPar       ; menu - chyba zad†n°
         jc        RozborZ6                 ; chyba zad†n° parametrñ operace

; ------ test, zda byl zad†n disk

         cmp       byte ptr ds:[FilePthN],2 ; je 2 a v°ce znakñ ?
         jb        RozborZ8                 ; je m†lo znakñ, nen° disk, v®e OK
         cmp       byte ptr ds:[FilePath+1],":" ; je zad†n disk ?
         jne       RozborZ8                 ; nen° zad†n disk

; ------ test platnosti zad†n° disku

         mov       al,ds:[FilePath]         ; disk
         mov       ds:[ChbLnDP1],al         ; zadanò disk
         sub       al,"A"                   ; á°slo disku
         call      far ptr TestDisk         ; test platnosti disku
         jnc       RozborZ8                 ; disk je zad†n OK

; ------ chyba zad†n° parametrñ operace

         mov       si,offset ChbLnDsk       ; hl†®en° - chybnÇ zad†n° disku
RozborZ6:call      far ptr Lin0MenF         ; chybovÇ hl†®en°
         jc        RozborZ9                 ; p©eru®en° operace

; ------ opakov†n° zad†n° parametrñ operace

RozborZ7:or        si,si                    ; p©°znaky NC, NZ = opakov†n° zad†n°
         jmp       short RozborZ9

; ------ n†vrat registrñ

RozborZ8:xor       cx,cx                    ; p©°znaky NC, ZY = v®e OK
RozborZ9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RozborZ  ENDP

; *****************************************************************************
;                               Rozbor
;             Rozbor zad†n° parametrñ operace (v bufferu LinBuff)
; V bufferu FilePath je uloëen zadanò adres†©. Adres†© je normovanò, ale nen°
; doplnàn na plnÇ jmÇno (aby nebyl p©°stup na disk). P©ed pouëit°m je nutno
; adres†© doplnit pomoc° RozbFPth !
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba zad†n° parametrñ (chyba syntaxe)
;        DS:SI=adresa chyby zad†n° (v editaán°m bufferu)
;        CX=poáet zbylòch znakñ textu
; *****************************************************************************

Rozbor   PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di
         push      es

; ------ nalezen° zaá†tku parametrñ

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset LinBuff        ; editaán° buffer
         mov       ch,0
         mov       cl,ds:[LinNum]           ; poáet bajtñ v bufferu
         mov       al,"/"                   ; znak parametrñ
         cld
         jcxz      Rozbor1                  ; nen° ë†dnò znak
         repne     scasb                    ; nalezen° oddàlovaáe parametrñ "/"
         jne       Rozbor1                  ; znak nebyl nalezen
         dec       di                       ; n†vrat zaá†tku parametrñ "/"
         inc       cx                       ; n†vrat á°taáe znakñ

; ------ rozbor zadanòch parametrñ (DI=adresa, CX=zbylò poáet znakñ)

Rozbor1: mov       si,di                    ; adresa zaá†tku parametrñ
         push      cs
         call      near ptr RozbParm        ; rozbor zadanòch parametrñ
         jnc       Rozbor12
         jmp       Rozbor9                  ; chyba zad†n° (DS:SI/CX chyba)

; ------ nalezen° zaá†tku masek

Rozbor12:mov       cx,di                    ; adresa konce textu masek
Rozbor2: cmp       di,offset LinBuff        ; je jië zaá†tek bufferu ?
         jbe       Rozbor3                  ; dosaëeno zaá†tku bufferu
         dec       di                       ; posun ukazatele textu
         cmp       byte ptr ds:[di],"\"     ; je konec cesty ?
         je        Rozbor23                 ; nalezen zaá†tek masky
         cmp       byte ptr ds:[di],":"     ; zad†n° disku ?
         jne       Rozbor2                  ; nen° zaá†tek masky - dal®° znak
Rozbor23:inc       di                       ; n†vrat ukazatele

; ------ dek¢dov†n° textu masek

Rozbor3: sub       cx,di                    ; dÇlka textu masek
         mov       si,di                    ; adresa masek
         push      cs
         call      near ptr RozbMask        ; rozbor zad†n° masek

; ------ implicitn° maska, nen°-li nic zad†no

         cmp       word ptr ds:[FileMskN],0 ; bylo nàco zad†no ?
         jne       Rozbor4                  ; bylo nàco zad†no OK
         push      di
         mov       si,offset All            ; text "*.*"
         mov       cx,3
         mov       di,offset FileMask       ; buffer masek
         mov       ds:[FileMskN],cx         ; dÇlka textu
         inc       cx                       ; váetnà koncovÇ 0
         cld
         rep       movsb                    ; p©enos textu "*.*"
         pop       di

; ------ p©enesen° textu adres†©e do bufferu

Rozbor4: mov       cx,di                    ; konec textu adres†©e
         mov       si,offset LinBuff        ; ©†dkovò buffer
         sub       cx,si                    ; dÇlka textu adres†©e
         ja        Rozbor5                  ; je nàco zad†no
         mov       si,offset AktPath        ; aktivn° adres†©
;         mov       cx,3                     ; vòchoz° adres†© je ROOT
;         test      byte ptr ds:[FileTyp],bit5 ; je implicitnà ROOT ?
;         jnz       Rozbor5                  ; je implicitnà ROOT
         mov       cx,ds:[AktPathN]         ; jinak je vòchoz° aktu†ln° adres†©
Rozbor5: mov       ds:[FilePthN],cx         ; dÇlka textu adres†©e
         mov       di,offset FilePath       ; buffer adres†©e
         cld
         rep       movsb                    ; p©enos textu do bufferu

; ------ vòchoz° adres†©, je-li zad†n pouze disk

;         cmp       byte ptr ds:[di-1],":"   ; byl zad†n pouze disk ?
;         jne       Rozbor6                  ; nen° jen disk
;         test      byte ptr ds:[FileTyp],bit5 ; je implicitnà ROOT ?
;         jz        Rozbor6                  ; nen° implicitnà ROOT
;         mov       al,"\"
;         stosb                              ; oznaáen° ROOT
;         inc       word ptr ds:[FilePthN]   ; zvò®en° dÇlky cesty
Rozbor6: mov       al,0
         stosb                              ; koncov† 0

; ------ normalizace textu adres†©e

         mov       si,offset FilePath       ; text zadanÇho adres†©e
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         call      far ptr NormFile         ; normalizace textu adres†©e
         mov       ds:[FilePthN],cx         ; nov† dÇlka textu adres†©e
         clc                                ; p©°znak zad†n° parametrñ OK

; ------ n†vrat registrñ

Rozbor9: pop       es
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

Rozbor   ENDP

; *****************************************************************************
;                                RozbFPth
;        doplnàn° zadanÇ cesty na plnÇ jmÇno (mus° bòt normalizov†no !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

RozbFPth PROC      FAR

; ------ £schova registrñ

         push      cx
         push      si
         push      es

; ------ p©evod zadanÇ cesty na plnou specifikaci

         test      byte ptr ds:[FileTyp],bit3 ; je specifikace textem ?
         jz        RozbFPt9                 ; nen° specifikace textem
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       si,offset FilePath       ; zadan† cesta
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         call      far ptr FullFile         ; p©evod na plnÇ jmÇno adres†©e
         mov       ds:[FilePthN],cx         ; nov† dÇlka textu adres†©e

; ------ n†vrat registrñ

RozbFPt9:pop       es
         pop       si
         pop       cx
         ret

RozbFPth ENDP

; *****************************************************************************
;                              RozbMask
;                        rozbor zad†n° masek
; -----------------------------------------------------------------------------
; VSTUP: CX=dÇlka textu
;        DS:SI=ukazatel textu
;        DS=datovò segment
; *****************************************************************************

RozbMask PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset FileMask       ; buffer k dek¢dov†n° zadanòch masek
         jcxz      RozbMsk8                 ; nejsou ë†dnÇ znaky
         cld

; ------ vypu®tàn° poá†teán°ch mezer prvn° masky

RozbMsk1:cmp       byte ptr ds:[si]," "     ; je jië platnò znak ?
         jne       RozbMsk2                 ; je platnò znak
         inc       si                       ; zvò®en° ukazatele v textu
         loop      RozbMsk1                 ; test dal®°ho znaku
         jcxz      RozbMsk8                 ; nen° ë†dn† maska

; ------ p©enos textu jednÇ masky

RozbMsk2:mov       bl,0                     ; p©°znak, ëe nen° teáka ani hvàzdiáka
RozbMsk3:jcxz      RozbMsk5                 ; konec textu
         lodsb                              ; naáten° znaku masky
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       al," "                   ; oddàlovac° mezera ?
         je        RozbMsk5                 ; konec textu jednÇ masky
         cmp       al,"*"                   ; je hvàzdiáka ?
         je        RozbMs33                 ; je hvàzdiáka
         cmp       al,":"                   ; oddàlovaá diskñ nebo za©°zen° ?
         je        RozbMsk3                 ; oddàlovaá diskñ nebo za©°zen°
         cmp       al,"."                   ; je teáka ?
         jne       RozbMsk4                 ; nen° teáka
         cmp       bl,"."                   ; byla jië teáka ?
         je        RozbMsk3                 ; byla jië teáka
RozbMs33:mov       bl,al                    ; p©°znak teáky nebo hvàzdiáky
RozbMsk4:call      far ptr UpCase           ; konverze na velkÇ p°smeno
         stosb                              ; uloëen° do bufferu
         jmp       short RozbMsk3           ; dal®° znak masky

; ------ pokud nebyla teáka ani hvàzdiáka doplnàn° znaku "*" na konec masky

RozbMsk5:or        bl,bl                    ; byla teáka nebo hvàzdiáka ?
         jnz       RozbMs55                 ; byla teáka nebo hvàzdiáka
         mov       al,"*"                   ; dopl§uj°c° znak
         stosb                              ; uloëen° znaku "*"

; ------ nalezen° zaá†tku dal®° masky

RozbMs55:jcxz      RozbMsk8                 ; nejsou dal®° znaky
         mov       al," "                   ; hledanò znak mezery
RozbMsk6:cmp       ds:[si],al               ; je jië platnò znak ?
         jne       RozbMsk7                 ; je platnò znak
         inc       si                       ; zvò®en° ukazatele v textu
         loop      RozbMsk6                 ; test dal®°ho znaku
         jmp       short RozbMsk8           ; nen° dal®° znak
RozbMsk7:stosb                              ; mezera mezi maskami
         jmp       short RozbMsk2           ; dek¢dov†n° dal®° masky

; ------ konec dek¢dov†n°

RozbMsk8:mov       byte ptr ds:[di],0       ; oznaáen° konce textu
         sub       di,offset FileMask       ; poáet znakñ v bufferu
         mov       ds:[FileMskN],di         ; poáet znakñ v bufferu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RozbMask ENDP

; *****************************************************************************
;                               RozbParm
;                    Rozbor zad†n° parametrñ souborñ
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet znakñ textu
;        DS:SI=ukazatel zaá†tku textu
;        DS=datovò segment
; VùSTUP:CY=chyba zad†n° (v ChybBuff p©ipraven text chyby k zobrazen° v menu)
;        CX=poáet zbylòch znakñ textu
;        DS:SI=adresa textu s chybou v LinBuff
; *****************************************************************************

RozbParm PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di
         push      bp
         push      es
         mov       bp,si                    ; BP <- £schova zaá†tku textu

; ------ inicializace parametrñ na standardn° hodnoty

         push      ds
         pop       es                       ; ES <- datovò segment

         push      cx
         mov       di,offset SrcInit        ; zaá†tek tabulky parametrñ hled†n°
         mov       cx,offset(SrcInit0-SrcInit) ; dÇlka tabulky
         xor       ax,ax                    ; AL <- nulovac° bajt
         cld
         rep       stosb                    ; vynulov†n° tabulky
         dec       ax                       ; AX <- 0ffffh
         mov       word ptr ds:[SrcSiz2],ax ; koncov† velikost LOW
         mov       word ptr ds:[SrcSiz2+2],ax ; koncov† velikost HIGH
         pop       cx

; ------ naáten° znaku operace

RozbPar1:call      RozbPCh                  ; naáten° dal®°ho znaku
         jnc       RozbPar2                 ; je dal®° znak
         clc
         jmp       RozbPar9                 ; nen° dal®° znak

RozbPar2:cmp       al,"/"                   ; je znak "/" ?
         je        RozbPar1                 ; znak "/" se ignoruje
         call      far ptr UpCase           ; konverze znaku na velkÇ p°smeno

; ------ zad†n° data

         cmp       al,"D"                   ; je zad†n° data ?
         jne       RozbPar3                 ; nen° zad†n° data
         call      RozbPDat                 ; rozbor zad†n° data
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° áasu

RozbPar3:cmp       al,"T"                   ; je zad†n° áasu ?
         jne       RozbPar4                 ; nen° zad†n° áasu
         call      RozbPTim                 ; rozbor zad†n° áasu
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° velikosti

RozbPar4:cmp       al,"N"                   ; je zad†n° velikosti ?
         jne       RozbPar5                 ; nen° zad†n° velikosti
         call      RozbPSiz                 ; rozbor zad†n° velikosti
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° textu

RozbPar5:cmp       al,'"'
         je        RozbPr52                 ; je zad†n text
         cmp       al,"'"
         jne       RozbPar6                 ; nen° zad†n text
RozbPr52:call      RozbPTxt                 ; rozbor zad†n° textu k hled†n°
RozbPr55:jmp       short RozbPar1           ; dal®° parametr

; ------ soubor v k¢du ASCII

RozbPar6:cmp       al,"U"                   ; je k¢d ASCII ?
         jne       RozbPr62                 ; nen° k¢d ASCII
         mov       byte ptr ds:[SrcTKod],bit0 ; je k¢d ASCII
         jmp       short RozbPr55

; ------ soubor je v k¢du IBM

RozbPr62:cmp       al,"I"                   ; je k¢d IBM ?
         jne       RozbPr63                 ; nen° k¢d IBM
         mov       byte ptr ds:[SrcTKod],bit1 ; k¢d IBM
         jmp       short RozbPr55           ; dal®° parametr

; ------ soubor v k¢du Kamenickòch

RozbPr63:cmp       al,"K"                   ; je k¢d Kamenickòch ?
         jne       RozbPr64                 ; nen° k¢d Kamenickòch
         mov       byte ptr ds:[SrcTKod],bit2 ; k¢d Kamenickòch
         jmp       short RozbPr55           ; dal®° parametr

; ------ soubor v k¢du Latin 2

RozbPr64:cmp       al,"L"                   ; je k¢d Latin 2 ?
         jne       RozbPr65                 ; nen° k¢d Latin 2
         mov       byte ptr ds:[SrcTKod],bit3 ; k¢d Latin 2
         jmp       short RozbPr55           ; dal®° parametr

; ------ soubor v k¢du KOI 8

RozbPr65:cmp       al,"O"                   ; je k¢d KOI 8 ?
         jne       RozbPr66                 ; nen° k¢d KOI 8
         mov       byte ptr ds:[SrcTKod],bit4 ; k¢d KOI 8
         jmp       short RozbPr55           ; dal®° parametr

; ------ soubor v k¢du WINDOWS

RozbPr66:cmp       al,"W"                   ; je k¢d WINDOWS ?
         jne       RozbPr69                 ; nen° k¢d WINDOWS
         mov       byte ptr ds:[SrcTKod],bit5 ; k¢d WINDOWS
         jmp       short RozbPr55           ; dal®° parametr

; ------ hled†n° probàhne v podadres†©°ch

RozbPr69:cmp       al,"X"                   ; jsou podadres†©e ?
         jne       RozbPr72                 ; nejsou podadres†©e
         or        byte ptr ds:[FileTyp],bit7 ; jsou podadres†©e
         jmp       short RozbPr55           ; dal®° parametr

; ------ hled†n° neprobàhne v podadres†©°ch

RozbPr72:cmp       al,"Z"                   ; pouze jeden adres†© ?
         jne       RozbPr74                 ; nen° pouze jeden adres†©
         and       byte ptr ds:[FileTyp],not bit7 ; zru®.p©°zn.podadres†©ñ
         jmp       short RozbPr55           ; dal®° parametr

; ------ zad†n° atributñ

RozbPr74:mov       di,offset SrcAtr         ; atributy hledanÇho souboru
         call      RozbPAtr                 ; rozbor zad†n° atributñ
         jnc       RozbPr55                 ; platnò znak atributu - OK

; ------ chybnò znak - p©enesen° textu chyby do bufferu

         call      RozbPErr                 ; £schova textu chyby do bufferu

; ------ konverze zadanÇho textu k vyhled†n°

RozbPar9:pushf
         push      cx
         mov       cx,ds:[SrcTextN]         ; dÇlka textu k hled†n°
         jcxz      RozbPr98                 ; nen° zad†n ë†dnò text
         mov       dl,ds:[SrcTKod]          ; zadanò konverzn° k¢d
         or        dl,dl                    ; je z†kaz konverze ?
         jz        RozbPr98                 ; je z†kaz konverze
         push      si                       ; p©°padn† adresa chyby
         mov       si,offset SrcText        ; buffer textu k vyhled†n°
         call      far ptr KonvUpC          ; konverze bufferu na velk† p°smena
         pop       si
RozbPr98:pop       cx
         popf

; ------ n†vrat registrñ

         pop       es
         pop       bp
         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

RozbParm ENDP

; -----------------------------------------------------------------------------
;        £schova textu chyby SI do bufferu (ES=DS, BP=zaá†tek,  niá° AX a DI !)
; -----------------------------------------------------------------------------

RozbPErr PROC      NEAR

; ------ £schova ukazatelñ m°sta chyby

         push      si
         push      cx

; ------ p©°prava registrñ

         cld
         mov       di,offset ChybBuff+1     ; buffer chybovÇho textu
         mov       bx,si                    ; BX <- adresa chyby
         sub       bx,bp                    ; BX <- dÇlka textu p©ed chybou
         cmp       bx,29                    ; maxim†ln° dÇlka textu p©ed chybou
         jb        RozbPEr2
         mov       bx,29                    ; omezen° p©edchoz° dÇlky textu

; ------ p©enesen° textu p©ed chybou

RozbPEr2:sub       si,bx                    ; posun ukazatele textu zpàt
         or        bx,bx                    ; p©edch†zel nàjakò znak ?
         jz        RozbPEr4                 ; nep©edch†zel ë†dnò znak
RozbPEr3:movsb                              ; p©esun znaku
         dec       bx
         jnz       RozbPEr3                 ; dal®° znak

; ------ p©enos chybnÇho znaku

RozbPEr4:mov       al,0                     ; znak p©ep°naáe barvy
         stosb                              ; p©ep°naá na zvòraznànou barvu
         movsb                              ; uloëen° chybnÇho znaku
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         stosb                              ; p©ep°naá zpàt na norm†ln° barvu
         jcxz      RozbPEr8                 ; nezbyl ë†dnò dal®° znak

; ------ p©enos zbytku textu za chybou

RozbPEr5:cmp       di,offset ChybBuff+1+32  ; je konec bufferu ?
         jae       RozbPEr8                 ; je jië konec bufferu
         movsb                              ; p©esun dal®°ho znaku
         loop      RozbPEr5                 ; dal®° znak

; ------ dÇlka textu

RozbPEr8:xchg      ax,di                    ; AX <- adresa konce textu v bufferu
         sub       ax,offset ChybBuff+1     ; dÇlka textu
         mov       ds:[ChybBuff],al         ; dÇlka textu

; ------ n†vrat registrñ

         pop       cx
         pop       si
         stc                                ; p©°znak cbyby zad†n° parametrñ
         ret

RozbPErr ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° textu k hled†n° (VSTUP: AL=£vodn° znak uvozovek)
; -----------------------------------------------------------------------------

RozbPTxt PROC      NEAR

         mov       di,offset SrcText        ; buffer textu k hled†n°
         mov       ah,al                    ; £schova £vodn°ho znaku parametru
         cld

; ------ naáten° znaku

RozbPTx1:jcxz      RozbPTx7                 ; konec textu
         lodsb                              ; naáten° znaku textu
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ test, zda je konec textu

         cmp       al,ah                    ; je znak konce textu ?
         jne       RozbPTx3                 ; nen° konec textu
         jcxz      RozbPTx7                 ; byl to posledn° znak - je konec
         cmp       al,ds:[si]               ; je to zdvojenò znak ?
         jne       RozbPTx7                 ; nen° zdvojenò - konec parametru
         inc       si                       ; p©eskoáen° zdvojenÇho znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ uloëen° platnÇho znaku

RozbPTx3:cmp       di,offset SrcText0       ; je buffer jië plnò ?
         jae       RozbPTx1                 ; buffer je jië plnò
         stosb                              ; uloëen° znaku
         jmp       short RozbPTx1           ; dek¢dov†n° dal®°ho znaku

; ------ konec - nastaven° dÇlky textu

RozbPTx7:sub       di,offset SrcText        ; dÇlka zadanÇho textu
         mov       ds:[SrcTextN],di         ; uloëen° dÇlky textu

RozbPTx8:ret

RozbPTxt ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° atributñ (AL=prvn° znak) (vòstup: CY=nezn†mò znak)
; -----------------------------------------------------------------------------

RozbPAtr PROC      NEAR

; ------ rozli®en° znaku atributu

         mov       ah,ARC
         cmp       al,"A"
         je        RozbPAt1
         mov       ah,DIR
         cmp       al,"C"
         je        RozbPAt1
         mov       ah,SYS
         cmp       al,"S"
         je        RozbPAt1
         mov       ah,HID
         cmp       al,"H"
         je        RozbPAt1
         mov       ah,RO
         cmp       al,"R"
         je        RozbPAt1

; ------ chyba - neplatnò znak

         dec       si                       ; n†vrat znaku
         inc       cx
         stc                                ; p©°znak chyby
         ret

; ------ nastaven° bitñ

RozbPAt1:or        ds:[di],ah               ; atribut nastaven
         or        ds:[di+1],ah             ; maska povolena
         cmp       al,ds:[si-1]             ; bylo malÇ p°smeno ?
         je        RozbPAt2                 ; bylo velkÇ p°smeno - nastaven°
         xor       ds:[di],ah               ; nulov†n° bitu
RozbPAt2:ret                                ; (nastaven p©°znak NC !)

RozbPAtr ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° data
; -----------------------------------------------------------------------------

RozbPDat PROC      NEAR

         and       byte ptr ds:[SrcIParm],not bit1 ; test uvnit© intervalu

; ------ rozbor poá†teán°ho data

         mov       di,offset SrcDat1        ; poá†teán° datum
         call      RozbPDt0                 ; rozbor poá†teán°ho data

; ------ kopie do koncovÇho data

         mov       ax,ds:[di]               ; zadan† hodnota data
         mov       dx,ds:[di+2]             ; maska
         mov       di,offset SrcDat2        ; koncovÇ datum
         mov       ds:[di],ax               ; koncovÇ datum
         mov       ds:[di+2],dx             ; maska

; ------ oddàlovac° znamÇnko "-"

         call      RozbPInt                 ; test, zda je interval "-"
         jc        RozbPDt6                 ; nen° znak intervalu

; ------ rozbor koncovÇho data

         call      RozbPDt0                 ; rozbor koncovÇho data

; ------ test, zda bylo nàco zad†no

RozbPDt6:cmp       word ptr ds:[SrcDat1M],0 ; je poá†teán° datum ?
         jne       RozbPDt8                 ; je zad†no
         cmp       word ptr ds:[di+2],0     ; je koncovÇ datum ?
         jne       RozbPDt8                 ; je zad†no

; ------ nastaven° aktu†ln°ho data

         call      far ptr GetSDate         ; poskytnut° systÇmovÇho data
         mov       ds:[SrcDat1],dx          ; poá†teán° datum
         mov       ds:[di],dx               ; koncovÇ datum
         dec       word ptr ds:[SrcDat1M]   ; maska poá†teán°ho data = -1
         dec       word ptr ds:[di+2]       ; maska koncovÇho data = -1

; ------ rozli®en°, zda je test vnà intervalu

RozbPDt8:mov       ax,ds:[SrcDat1M]         ; maska minim†ln°ho data
         cmp       ax,ds:[SrcDat2M]         ; jsou masky shodnÇ ?
         jne       RozbPDt9                 ; masky nejsou shodnÇ
         mov       ax,ds:[SrcDat1]          ; minim†ln° datum
         cmp       ax,ds:[SrcDat2]          ; je vàt®° neë maxim†ln° datum ?
         jbe       RozbPDt9                 ; po©ad° poloëek je OK
         or        byte ptr ds:[SrcIParm],bit1 ; p©°znak testu vnà intervalu
RozbPDt9:ret

RozbPDat ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° data (jeden parametr - podle n†rodn°ho k¢du)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (datum souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPDt0 PROC      NEAR

; ------ 2: japonskò form†t zad†n° data

         cmp       byte ptr ds:[FormDat],1  ; je japonskò form†t data ?
         jbe       RozbPDt1                 ; nen° japonskò form†t
         call      RozbPRok                 ; rozbor £daje roku
         call      RozbPMes                 ; rozbor £daje màs°ce
         call      RozbPDen                 ; rozbor £daje dne
         ret

; ------ 0: americkò form†t zad†n° data

RozbPDt1:je        RozbPDt2                 ; nen° americkò form†t
         call      RozbPMes                 ; rozbor £daje màs°ce
         call      RozbPDen                 ; rozbor £daje dne
         jmp       short RozbPDt3

; ------ 1: evropskò form†t zad†n° data

RozbPDt2:call      RozbPDen                 ; rozbor £daje dne
         call      RozbPMes                 ; rozbor £daje màs°ce
RozbPDt3:call      RozbPRok                 ; rozbor £daje roku
         ret

RozbPDt0 ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° áasu
; -----------------------------------------------------------------------------

RozbPTim PROC      NEAR

         and       byte ptr ds:[SrcIParm],not bit0 ; test uvnit© intervalu

; ------ rozbor poá†teán°ho áasu

         mov       di,offset SrcTim1        ; poá†teán° áas
         call      RozbPHod                 ; rozbor hodin
         call      RozbPMin                 ; rozbor minut
         call      RozbPSek                 ; rozbor sekund

; ------ kopie do koncovÇho áasu

         mov       ax,ds:[di]               ; £daj áasu
         mov       dx,ds:[di+2]             ; maska
         mov       di,offset SrcTim2        ; koncovò áas
         mov       ds:[di],ax               ; £daj áasu
         mov       ds:[di+2],dx             ; maska

; ------ oddàlovac° znamÇnko "-"

         call      RozbPInt                 ; test, zda je znak intervalu "-"
         jc        RozbPTm6                 ; nen° znak intervalu

; ------ rozbor koncovÇho áasu

         call      RozbPHod                 ; rozbor hodin
         call      RozbPMin                 ; rozbor minut
         call      RozbPSek                 ; rozbor sekund

; ------ test, zda je nàco zad†no

RozbPTm6:cmp       word ptr ds:[SrcTim1M],0 ; je poá†teán° áas ?
         jne       RozbPTm9                 ; je zad†n
         cmp       word ptr ds:[di+2],0     ; je koncovò áas ?
         jne       RozbPTm9                 ; je zad†n

; ------ nastaven° aktu†ln°ho áasu (posledn° hodina)

         call      far ptr GetSTime         ; poskytnut° systÇmovÇho áasu
         mov       ds:[di],dx               ; koncovò áas
         sub       dh,bit11/bit8            ; odeáten° 1 hodiny
         jnc       RozbPTm8                 ; hodina je OK
         add       dh,24*bit11/bit8         ; korekce na hodinu 23
RozbPTm8:mov       ds:[SrcTim1],dx          ; poá†teán° áas
         dec       word ptr ds:[SrcTim1M]   ; maska poá†teán°ho áasu = -1
         dec       word ptr ds:[di+2]       ; maska koncovÇho áasu = -1

; ------ rozli®en°, zda je test vnà intervalu

RozbPTm9:mov       ax,ds:[SrcTim1M]         ; maska minim†ln°ho áasu
         cmp       ax,ds:[SrcTim2M]         ; jsou masky shodnÇ ?
         jne       RozbPTmA                 ; masky nejsou shodnÇ
         mov       ax,ds:[SrcTim1]          ; minim†ln° áas
         cmp       ax,ds:[SrcTim2]          ; je vàt®° neë maxim†ln° áas ?
         jbe       RozbPTmA                 ; po©ad° poloëek je OK
         or        byte ptr ds:[SrcIParm],bit0 ; p©°znak testu vnà intervalu
RozbPTmA:ret

RozbPTim ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje sekund
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (áas souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPSek PROC      NEAR

; ------ inicializace hodnoty

         mov       bx,not bit0+bit1+bit2+bit3+bit4 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPDn5                 ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

         shr       ax,1                     ; korekce á°sla / 2
         jmp       short RozbPDn2           ; uloëen° £daje

RozbPSek ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje dne
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (datum souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPDen PROC      NEAR

; ------ inicializace hodnoty

         mov       bx,not bit0+bit1+bit2+bit3+bit4 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPDn5                 ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

RozbPDn2:cmp       ax,31                    ; p©eteáen° á°sla ?
         jb        RozbPDn4                 ; hodnota á°sla je OK
         mov       ax,31                    ; omezen° á°sla
RozbPDn4:or        ds:[di],ax               ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; povolen° masky dne

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbPDn5:call      RozbPOdd                 ; vypu®tàn° oddàlovaáe za á°slem
         ret

RozbPDen ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje minut
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (áas souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPMin PROC      NEAR

; ------ inicializace hodnoty

         mov       bx,not bit5+bit6+bit7+bit8+bit9+bit10 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPMs6                 ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

         cmp       ax,63                    ; p©eteáen° á°sla ?
         jb        RozbPMs4                 ; hodnota á°sla je OK
         mov       ax,63                    ; omezen° á°sla
         jmp       short RozbPMs4           ; nastaven° £daje

RozbPMin ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje màs°ce
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (datum souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPMes PROC      NEAR

; ------ inicializace hodnoty

         mov       bx,not bit5+bit6+bit7+bit8 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPMs6                 ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

         cmp       ax,15                    ; p©eteáen° á°sla ?
         jb        RozbPMs4                 ; hodnota á°sla je OK
         mov       ax,15                    ; omezen° á°sla
RozbPMs4:push      cx
         mov       cl,5                     ; poáet rotac°
RozbPMs5:shl       ax,cl                    ; rotace á°sla na pozici
         pop       cx
         or        ds:[di],ax               ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; povolen° masky màs°ce

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbPMs6:call      RozbPOdd                 ; vypu®tàn° oddàlovaáe za á°slem
         ret

RozbPMes ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (áas souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPHod PROC      NEAR

; ------ inicializace hodnoty

         mov       bx,not bit11+bit12+bit13+bit14+bit15 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPMs6                 ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

         cmp       ax,31                    ; p©eteáen° á°sla ?
         jb        RozbPHd4                 ; hodnota á°sla je OK
         mov       ax,31                    ; omezen° á°sla
RozbPHd4:push      cx
         mov       cl,11                    ; poáet rotac°
         jmp       short RozbPMs5

RozbPHod ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° £daje roku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr (datum souboru)
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbPRok PROC      NEAR

; ------ inicializace hodnoty parametru

         mov       bx,not bit9+bit10+bit11+bit12+bit13+bit14+bit15 ; maska roku
         and       ds:[di],bx               ; nulov†n° hledanÇ hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbPRk6                 ; á°slo nen° zad†no

; ------ oprava hodnoty á°sla

         cmp       ax,80                    ; £daj < 80 bude asi 20xx
         jae       RozbPRk0
         add       ax,2000                  ; oprava na rok 20xx
RozbPRk0:cmp       ax,100                   ; £daj < 100 bude asi offset od 1900
         jae       RozbPRk1                 ; nen° < 100
         add       ax,1900                  ; korekce na 19xx
RozbPRk1:cmp       ax,200                   ; £daj < 200 bude asi 2xxx
         jae       RozbPRk2                 ; nen° £daj < 200
         add       ax,2000                  ; korekce na 2xxx
RozbPRk2:cmp       ax,1000                  ; £daj < 1000 bude asi 1xxx
         jae       RozbPRk3                 ; nen° £daj < 1000
         add       ax,1000                  ; korekce na 1xxx

; ------ omezen° roku zdola

RozbPRk3:cmp       ax,1980                  ; minim†ln° rok 1980
         ja        RozbPRk4                 ; rok je OK
         mov       ax,1980                  ; omezen° na minim†ln° rok 1980

; ------ p©evod na intern° tvar

RozbPRk4:sub       ax,1980                  ; offset od roku 1980
         cmp       ax,127                   ; je p©eteáen° ?
         jb        RozbPRk5                 ; á°slo je OK
         mov       ax,127                   ; omezen° maxim†ln°ho roku

; ------ á°slo zad†no - jeho nastaven°

RozbPRk5:shl       al,1                     ; AL = rok << 1
         or        ds:[di+1],al             ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; povolen° masky roku

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbPRk6:call      RozbPOdd                 ; vypu®tàn° oddàlovaáe za á°slem
         ret

RozbPRok ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° velikosti souboru
; -----------------------------------------------------------------------------

RozbPSiz PROC      NEAR

; ------ inicializace hranic velikosti souboru

         mov       di,offset SrcSiz1        ; registr velikosti souboru
         xor       ax,ax                    ; AX <- 0
         mov       ds:[di],ax               ; minim†ln° velikost LOW
         mov       ds:[di+2],ax             ; minim†ln° velikost HIGH
         dec       ax                       ; AX <- 0ffffh
         mov       ds:[di+4],ax             ; maxim†ln° velikost LOW
         mov       ds:[di+6],ax             ; maxim†ln° velikost HIGH

; ------ rozbor minim†ln° velikosti

         call      RozbDNum                 ; rozbor minim†ln° velikosti
         jc        RozbPSz3                 ; minim†ln° velikost nen° zad†na
         mov       ds:[di],ax               ; zadan† minim†ln° velikost LOW
         mov       ds:[di+2],dx             ; zadan† minim†ln° velikost HIGH
         mov       ds:[di+4],ax             ; p©ednastaven° pro maxim†ln° velik.
         mov       ds:[di+6],dx             ; maxim†ln° velikost HIGH

; ------ oddàlovac° znamÇnko "-"

RozbPSz3:call      RozbPInt                 ; test znaku intervalu
         jc        RozbPSz9                 ; nen° interval - v®e OK

; ------ rozbor maxim†ln° velikosti

         call      RozbDNum                 ; rozbor maxim†ln° velikosti
         jnc       RozbPSz5                 ; maxim†ln° velikost zad†na OK
         mov       ax,0ffffh                ; jinak maximum
         mov       dx,ax
RozbPSz5:mov       ds:[di+4],ax             ; maxim†ln° velikost LOW
         mov       ds:[di+6],dx             ; maxim†ln° velikost HIGH

RozbPSz9:ret

RozbPSiz ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° oddàlovaáe mezi á°sly (CY=nen° oddàlovaá)
; -----------------------------------------------------------------------------

RozXPOdd PROC      FAR

         call      RozbPOdd
         ret

RozXPOdd ENDP


RozbPOdd PROC      NEAR

         call      RozbPCh                  ; naáten° dal®°ho znaku
         jc        RozbPOd9                 ; nen° dal®° znak
         cmp       al,"."
         je        RozbPOd9                 ; teáka - plat°
         cmp       al,","
         je        RozbPOd9                 ; á†rka - plat°
         cmp       al,"/"
         je        RozbPOd9                 ; lom°tko - plat°
         cmp       al,"\"
         je        RozbPOd9                 ; toto lom°tko takÇ plat°
         cmp       al,":"
         je        RozbPOd9                 ; dvojteáka - plat°
         dec       si                       ; jinak n†vrat znaku
         inc       cx                       ; n†vrat á°taáe znakñ
         stc                                ; p©°znak chyby - nen° oddàlovaá
RozbPOd9:ret

RozbPOdd ENDP

; -----------------------------------------------------------------------------
;        test zad†n° znaku intervalu "-" (CY=nen° znak "-")
; -----------------------------------------------------------------------------

RozbPInt PROC      NEAR

         call      RozbPCh                  ; naáten° dal®°ho znaku
         jc        RozbPIn9                 ; nen° dal®° znak
         cmp       al,"-"                   ; je oddàlovac° znamÇnko "-" ?
         je        RozbPIn9                 ; je oddàlovaá intervalu OK
         dec       si                       ; n†vrat znaku
         inc       cx                       ; n†vrat á°taáe znakñ
         stc                                ; p©°znak, ëe nen° znak "-"
RozbPIn9:ret

RozbPInt ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla p©i rozboru AX (CY=nen° platnÇ á°slo)
; -----------------------------------------------------------------------------

RozbPNum PROC      NEAR

         push      dx
         call      RozbDNum                 ; naáten° á°sla DX:AX
         jc        RozbPNm2                 ; nen° platnÇ á°slo
         or        dx,dx                    ; je á°slo > 1 slovo ?
         jz        RozbPNm2                 ; nen° vàt®°
         mov       ax,0ffffh                ; omezen° AX
RozbPNm2:pop       dx
         ret

RozbPNum ENDP

; -----------------------------------------------------------------------------
;        naáten° velkÇho á°sla HEX p©i rozboru DX:AX (CY=nen° platnÇ á°slo)
; -----------------------------------------------------------------------------

RozXHNum PROC      FAR

         call      RozbHNum
         ret

RozXHNum ENDP

RozbHNum PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ inicializace st©adaáe na 0

         xor       di,di                    ; HIGH <- 0
         xor       bx,bx                    ; LOW <- 0

; ------ naáten° prvn° á°slice

         call      RozbHNm                  ; naáten° jednÇ á°slice
         jc        RozbHNm6                 ; nen° platnÇ á°slo

; ------ vyn†soben° st©adaáe 16x

RozbHNm1:push      ax                       ; £schova naátenÇho á°sla
         mov       ax,16                    ; n†sobitel st©adaáe LOW
         mul       bx                       ; posun st©adaáe LOW o ©†d
         xchg      ax,bx                    ; BX <- novÇ LOW
         xchg      dx,di                    ; DI <- novÇ HIGH, DX <- starÇ HIGH
         mov       ax,16                    ; n†sobitel st©adaáe HIGH
         mul       dx                       ; posun st©adaáe HIGH o ©†d
         add       di,ax                    ; vòslednò novò st©adaá HIGH
         adc       dx,dx                    ; p©°znak p©eteáen°
         pop       ax                       ; n†vrat naátenÇho á°sla

; ------ p©iáten° novÇ á°slice ke st©adaái

         mov       ah,0                     ; AX = naátenÇ á°slo
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,dx                    ; p©enos
         adc       dx,dx                    ; st©adaá p©eteáen°
         jz        RozbHNm3                 ; nen° p©eteáen°
         mov       bx,0ffffh                ; p©eteáen° £daje - omezen° na max.
         mov       di,bx

; ------ naáten° dal®° á°slice

RozbHNm3:call      RozbHNm                  ; naáten° dal®° á°slice
         jnc       RozbHNm1                 ; je dal®° platn† á°slice
         clc                                ; p©°znak operace OK

; ------ vòslednÇ naátenÇ á°slo

RozbHNm6:xchg      ax,bx                    ; AX <- á°slo LOW
         mov       dx,di                    ; DX <- á°slo HIGH

; ------ n†vrat registrñ

         pop       di
         pop       bx
         ret

RozbHNum ENDP

; -----------------------------------------------------------------------------
;        naáten° velkÇho á°sla p©i rozboru DX:AX (CY=nen° platnÇ á°slo)
; -----------------------------------------------------------------------------

RozXDNum PROC      FAR

         call      RozbDNum
         ret

RozXDNum ENDP


RozbDNum PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ inicializace st©adaáe na 0

         xor       di,di                    ; HIGH <- 0
         xor       bx,bx                    ; LOW <- 0

; ------ naáten° prvn° á°slice

         call      RozbPNm                  ; naáten° jednÇ á°slice
         jc        RozbDNm6                 ; nen° platnÇ á°slo

; ------ vyn†soben° st©adaáe 10x

RozbDNm1:push      ax                       ; £schova naátenÇho á°sla
         mov       ax,10                    ; n†sobitel st©adaáe LOW
         mul       bx                       ; posun st©adaáe LOW o ©†d
         xchg      ax,bx                    ; BX <- novÇ LOW
         xchg      dx,di                    ; DI <- novÇ HIGH, DX <- starÇ HIGH
         mov       ax,10                    ; n†sobitel st©adaáe HIGH
         mul       dx                       ; posun st©adaáe HIGH o ©†d
         add       di,ax                    ; vòslednò novò st©adaá HIGH
         adc       dx,dx                    ; p©°znak p©eteáen°
         pop       ax                       ; n†vrat naátenÇho á°sla

; ------ p©iáten° novÇ á°slice ke st©adaái

         mov       ah,0                     ; AX = naátenÇ á°slo
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,dx                    ; p©enos
         adc       dx,dx                    ; st©adaá p©eteáen°
         jz        RozbDNm3                 ; nen° p©eteáen°
         mov       bx,0ffffh                ; p©eteáen° £daje - omezen° na max.
         mov       di,bx

; ------ naáten° dal®° á°slice

RozbDNm3:call      RozbPNm                  ; naáten° dal®° á°slice
         jnc       RozbDNm1                 ; je dal®° platn† á°slice
         clc                                ; p©°znak operace OK

; ------ vòslednÇ naátenÇ á°slo

RozbDNm6:xchg      ax,bx                    ; AX <- á°slo LOW
         mov       dx,di                    ; DX <- á°slo HIGH

; ------ n†vrat registrñ

         pop       di
         pop       bx
         ret

RozbDNum ENDP

; -----------------------------------------------------------------------------
;        naáten° á°slice HEX (CY=nen° platn† á°slice HEX)
; -----------------------------------------------------------------------------

RozbHNm  PROC      NEAR

; ------ naáten° dal®°ho znaku

         call      RozbPCh                  ; naáten° znaku
         jc        RozbHNm9                 ; nen° dal®° znak
         call      far ptr UpCase           ; konverze na velkÇ p°smeno

; ------ kontrola, zda je to platn† á°slice

         cmp       al,"F"
         ja        RozbHNm8                 ; nen° á°slice HEX
         cmp       al,"A"
         jb        RozbHNm7                 ; nen° znak HEX
         sub       al,"A"-10                ; korekce na á°slo
         ret

RozbHNm7:cmp       al,"9"
         ja        RozbHNm8                 ; nen° á°slice
         sub       al,"0"
         jnc       RozbHNm9                 ; je platn† á°slice OK

; ------ n†vrat neplatnÇho znaku

RozbHNm8:dec       si                       ; n†vrat neplatnÇho znaku
         inc       cx                       ; n†vrat á°taáe znakñ
         stc                                ; p©°znak neplatnÇho znaku
RozbHNm9:ret

RozbHNm  ENDP

; -----------------------------------------------------------------------------
;        naáten° á°slice p©i rozboru (CY=nen° platn† á°slice)
; -----------------------------------------------------------------------------

RozbPNm  PROC      NEAR

; ------ naáten° dal®°ho znaku

         call      RozbPCh                  ; naáten° znaku
         jc        RozbPNm9                 ; nen° dal®° znak

; ------ kontrola, zda je to platn† á°slice

         cmp       al,"9"
         ja        RozbPNm8                 ; nen° á°slice
         sub       al,"0"
         jnc       RozbPNm9                 ; je platn† á°slice OK

; ------ n†vrat neplatnÇho znaku

RozbPNm8:dec       si                       ; n†vrat neplatnÇho znaku
         inc       cx                       ; n†vrat á°taáe znakñ
         stc                                ; p©°znak neplatnÇho znaku
RozbPNm9:ret

RozbPNm  ENDP

; -----------------------------------------------------------------------------
;        naáten° dal®°ho znaku z bufferu p©i rozboru (CY=nen° dal®° znak)
; -----------------------------------------------------------------------------

RozXPCh  PROC      FAR

         call      RozbPCh
         ret

RozXPCh  ENDP

RozbPCh  PROC      NEAR

; ------ test, zda je p©ipraven dal®° znak

RozbPCh1:stc                                ; p©°znak konce textu
         jcxz      RozbPCh6                 ; nen° dal®° znak

; ------ naáten° dal®°ho znaku

         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ mezery, tabul†tory a otazn°ky se p©eskoá°

         cmp       al," "                   ; mezera ?
         je        RozbPCh1                 ; ignorov†n° mezery
         cmp       al,TAB
         je        RozbPCh1                 ; tabul†tor se takÇ ignoruje
         cmp       al,"?"                   ; je n†hradn° znak ?
         je        RozbPCh1                 ; n†hradn° znaky se takÇ ignoruj°
         clc                                ; p©°znak, ëe je platnò znak

RozbPCh6:ret

RozbPCh  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                        Obsluha informaán°ho ©†dku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                              InfKFile
;               zobrazen° jmÇna souboru k operaci s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=text hl†®en°
;        DS=datovò segment
; *****************************************************************************

InfKFile PROC      FAR

         push      cx
         push      si
         push      es

         push      cs
         call      near ptr InfoClr         ; vymaz†n° informaán°ho ©†dku

         mov       si,di                    ; text hl†®en°
         push      cs
         call      near ptr InfoTxt         ; dek¢dov†n° textu hl†®en°

         mov       si,offset FilePath       ; jmÇno souboru
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[FileFilN]         ; dÇlka textu jmÇna souboru
         push      cs
         call      near ptr InfoDek         ; dek¢dov†n° jmÇna souboru

         xor       cx,cx                    ; CX <- á°taá kurzoru
         push      cs
         call      near ptr InfoKurz        ; kurzor + zobrazen° inform. ©†dku

         pop       es
         pop       si
         pop       cx
         ret

InfKFile ENDP

; *****************************************************************************
;                              InfLDir
;                  zobrazen° jmÇna adres†©e na disku k operaci
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=text hl†®en°
;        DS=datovò segment
; *****************************************************************************

InfLDir  PROC      FAR

         push      cx
         push      si
         push      es

         push      cs
         call      near ptr InfoClr         ; vymaz†n° informaán°ho ©†dku

         mov       si,di                    ; text hl†®en°
         push      cs
         call      near ptr InfoTxt         ; dek¢dov†n° textu hl†®en°

         mov       si,offset DskLDir        ; jmÇno adres†©e
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[DskLDirN]         ; dÇlka textu jmÇna adres†©e
         push      cs
         call      near ptr InfoDek         ; dek¢dov†n° jmÇna adres†©e

         push      cs
         call      near ptr InfoDisp        ; zobrazen° informaán°ho ©†dku

         pop       es
         pop       si
         pop       cx
         ret

InfLDir  ENDP

; *****************************************************************************
;                              InfFile
;                  zobrazen° jmÇna souboru k operaci
; -----------------------------------------------------------------------------
; VSTUP: DS:DI=text hl†®en°
;        DS=datovò segment
; *****************************************************************************

InfFile  PROC      FAR

         push      cx
         push      si
         push      es

         push      cs
         call      near ptr InfoClr         ; vymaz†n° informaán°ho ©†dku

         mov       si,di                    ; text hl†®en°
         push      cs
         call      near ptr InfoTxt         ; dek¢dov†n° textu hl†®en°

         mov       si,offset FilePath       ; jmÇno souboru
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,ds:[FileFilN]         ; dÇlka textu jmÇna souboru
         push      cs
         call      near ptr InfoDek         ; dek¢dov†n° jmÇna souboru

         push      cs
         call      near ptr InfoDisp        ; zobrazen° informaán°ho ©†dku

         pop       es
         pop       si
         pop       cx
         ret

InfFile  ENDP

; *****************************************************************************
;                                  InfDisp0
;                  Inicializaán° zobrazen° informaán°ho textu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text k zobrazen°
;        DS=datovò segment
; *****************************************************************************

InfDisp0 PROC      FAR

         push      cs
         call      near ptr InfoClr         ; vymaz†n° bufferu hl†®en°
         push      cs
         call      near ptr InfoTxt         ; dek¢dov†n° textu do bufferu
         push      cs
         call      near ptr InfoDisp        ; zobrazen° hl†®en°
         ret

InfDisp0 ENDP

; *****************************************************************************
;                                InfoClr
;                   vymaz†n° bufferu informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InfoClr0 LABEL     FAR

         mov       word ptr ds:[InfoKCit],0 ; á°taá ukazatele kurzoru
         mov       word ptr ds:[InfoKCit+2],0


InfoClr  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz†n° bufferu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,255                   ; dÇlka ©†dku
         mov       di,offset InfoBuf        ; buffer informaán°ho ©†dku
         mov       ah,ds:[InfoCol1]         ; bàën† barva inform. ©†dku
         mov       al," "                   ; mazac° znak mezery
         cld
         rep       stosw                    ; vymaz†n° bufferu

; ------ inicializace promànnòch

         mov       word ptr ds:[InfoStor],2 ; ukl†dac° offset
         and       byte ptr ds:[InfoPar],not bit1 ; zru®en° p©°znaku zvòraznàn°

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

InfoClr  ENDP

; *****************************************************************************
;                                  InfoTxt
;                  dek¢dov†n° textu do informaán°ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice textu (1.bajt - dÇlka textu, text n†sleduje)
;        DS=datovò segment
; *****************************************************************************

InfoTxt  PROC      FAR

; ------ £schova registrñ

         push      cx
         push      si
         push      es

; ------ dek¢dov†n° textu

         mov       ch,0
         mov       cl,ds:[si]               ; dÇlka textu
         inc       si                       ; zaá†tek textu
         push      ds
         pop       es                       ; ES <- datovò segment
         push      cs
         call      near ptr InfoDek         ; dek¢dov†n° textu

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         ret

InfoTxt  ENDP

; *****************************************************************************
;                                  InfoDek
;                 dek¢dov†n° textu do informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa textu
;        CX=poáet znakñ
;        DS=datovò segment
; *****************************************************************************

InfoDek  PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava registrñ

         jcxz      InfoDek9                 ; nen° ë†dnò znak k dek¢dov†n°
         mov       di,ds:[InfoStor]         ; ukl†dac° offset do bufferu
         cld
         mov       ah,ds:[InfoCol1]         ; bàën† barva textu
         mov       dh,ds:[InfoCol2]         ; zvòraznàn† barva textu
         test      byte ptr ds:[InfoPar],bit1 ; je bàën† barva ?
         jz        InfoDek1                 ; je bàën† barva textu
         xchg      ah,dh                    ; zvòraznàn† barva textu

; ------ znak k dek¢dov†n°

InfoDek1:mov       al,es:[si]               ; znak k dek¢dov†n°
         inc       si                       ; zvò®en° ukazatele átec° adresy

; ------ zmàna barvy textu

         cmp       al,0                     ; je zmàna barvy ?
         jne       InfoDek2                 ; nen° zmàna barvy - je platnò znak
         xchg      ah,dh                    ; zmàna barvy
         xor       byte ptr ds:[InfoPar],bit1 ; zmàna p©°znaku barvy
         jmp       short InfoDek8           ; dal®° bajt

; ------ p©esmàrov†n° textu

InfoDek2:cmp       al,1                     ; je p©esmàrov†n° na buffer ?
         jne       InfoDek7

         push      cx
         push      si
         push      es

         les       si,es:[si]               ; adresa textu
         mov       ch,0
         mov       cl,es:[si]               ; dÇlka textu
InfoDek3:inc       si                       ; zvò®en° ukazatele textu
         mov       al,es:[si]               ; znak k dek¢dov†n°

         cmp       di,2*255                 ; je buffer jië plnò ?
         jae       InfoDek4                 ; buffer je jië plnò
         mov       word ptr ds:[InfoBuf+di],ax ; uloëen° znaku
         inc       di                       ; zvò®en° ukazatele textu
         inc       di
InfoDek4:loop      InfoDek3                 ; dal®° znak

         pop       es
         pop       si
         pop       cx
         add       si,4
         sub       cx,4
         jbe       InfoDk82
         jmp       short InfoDek8

; ------ uloëen° znaku

InfoDek7:cmp       di,2*255                 ; je buffer jië plnò ?
         jae       InfoDek8                 ; buffer je jië plnò
         mov       word ptr ds:[InfoBuf+di],ax ; uloëen° znaku
         inc       di
         inc       di                       ; zvò®en° ukl†dac°ho offsetu
InfoDek8:loop      InfoDek1                 ; dek¢dov†n° dal®°ho znaku
InfoDk82:mov       ds:[InfoStor],di         ; novò ukl†dac° offset do bufferu

; ------ n†vrat registrñ

InfoDek9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InfoDek  ENDP

; *****************************************************************************
;                                 InfoKurD
;                  posun kurzoru operace smàrem dolñ
; -----------------------------------------------------------------------------
; VSTUP: CX=£bytek informaán°ho kurzoru
;        DS=datovò segment
; *****************************************************************************

InfoKurD PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ zvò®en° á°taáe

         mov       ax,word ptr ds:[InfoKCit] ; á°taá LOW
         mov       dx,word ptr ds:[InfoKCit+2] ; á°taá HIGH
         sub       ax,cx                    ; sn°ëen° á°taáe LOW
         sbb       dx,0                     ; p©enos do HIGH
         jnc       InfoKur0
         xor       ax,ax
         xor       dx,dx
         jmp       short InfoKur0

InfoKurD ENDP

; *****************************************************************************
;                                 InfoKurz
;                  posun kurzoru operace v informaán°m ©†dku
; -----------------------------------------------------------------------------
; VSTUP: CX=p©°rustek informaán°ho kurzoru
;        DS=datovò segment
; *****************************************************************************

InfoKurz PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ zvò®en° á°taáe

         mov       ax,word ptr ds:[InfoKCit] ; á°taá LOW
         mov       dx,word ptr ds:[InfoKCit+2] ; á°taá HIGH
         add       ax,cx                    ; zvò®en° á°taáe LOW
         adc       dx,0                     ; p©enos do HIGH

; ------ kontrola p©eteáen° á°taáe

InfoKur0:mov       cx,word ptr ds:[InfoKMax] ; maximum LOW
         mov       bx,word ptr ds:[InfoKMax+2] ; maximum HIGH
         cmp       dx,bx                    ; p©eteáen° ?
         jne       InfoKur1
         cmp       ax,cx
InfoKur1:jb        InfoKur2                 ; nen° p©eteáen°
         mov       ax,cx                    ; omezen° na maximum
         mov       dx,bx
InfoKur2:mov       word ptr ds:[InfoKCit],ax
         mov       word ptr ds:[InfoKCit+2],dx ; uloëen° novÇho kurzoru

; ------ normalizace ukazatelñ (omezen° velikosti na 1 slovo)

InfoKur3:or        bx,bx                    ; je jië mÇnà neë 64K ?
         jz        InfoKur4                 ; á°slo je jië OK
         shr       dx,1
         rcr       ax,1                     ; kurzor / 2
         shr       bx,1
         rcr       cx,1                     ; maximum / 2
         jmp       short InfoKur3           ; dal®° test
InfoKur4:jcxz      InfoKur9                 ; dàlitel = 0 (kurzor vypnutò)

; ------ vòpoáet dÇlky novÇho kurzoru

         mov       bx,InfoKSir              ; ®°©ka informaán°ho kurzoru
         mul       bx                       ; á†st * ®°©ka kurzoru
         div       cx                       ; vydàlen° celkovou á†st°
         mov       bx,ax                    ; relativn° ®°©ka kurzoru (pozic)

; ------ dek¢dov†n° kurzoru

         cld
         mov       di,ds:[ByteRow]          ; adresa konce ©†dku
         add       di,offset InfoBuf - 2*2 - 2*InfoKSir ; adresa k dek¢d.kurzoru
         mov       ah,ds:[InfoCol1]         ; bàën† barva inform. ©†dku
         push      ds
         pop       es
         mov       al,16                    ; lev† ®ipka
         stosw                              ; uloëen° levÇ ®ipky
         mov       cx,InfoKSir              ; ®°©ka informaán°ho kurzoru
         sub       cx,bx                    ; zbytek bez kurzoru
         xchg      bx,cx                    ; CX <- dÇlka kurzoru
         mov       al,"≤"                   ; znak kurzoru
         rep       stosw                    ; uloëen° á†sti s kurzorem
         mov       cx,bx                    ; dÇlka zbytku bez kurzoru
         mov       al,"∞"                   ; znak bez kurzoru
         rep       stosw                    ; uloëen° á†sti bez kurzoru
         mov       al,17                    ; prav† ®ipka
         stosw                              ; uloëen° pravÇ ®ipky

; ------ n†vrat registrñ

InfoKur9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         push      cs
         call      near ptr InfoDisp        ; zobrazen° informaán°ho ©†dku
         ret

InfoKurz ENDP

; *****************************************************************************
;                                   InfoDisp
;                        zobrazen° informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InfoDisp PROC      FAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp

; ------ p©°prava bufferu k uloëen° textu

         mov       ch,0
         mov       cl,ds:[Pozic]            ; poáet pozic na ©†dek
         sub       sp,cx
         sub       sp,cx                    ; buffer v z†sobn°ku

; ------ p©enesen° textu do bufferu v z†sobn°ku

         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       di,sp                    ; buffer v z†sobn°ku
         push      cx
         mov       si,offset InfoBuf        ; buffer informaán°ho ©†dku
         cld
         rep       movsw                    ; uloëen° textu do bufferu
         pop       cx

; ------ zobrazen° informaán°ho ©†dku

         mov       si,sp                    ; buffer v z†sobn°ku
         mov       dl,0                     ; poá†teán° pozice
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
         mov       al,255                   ; maxim†ln° hladina zobrazen°
         call      far ptr DispKStr         ; zobrazen° informaán°ho ©†dku

; ------ zobrazen° hl†®en° "áekejte"

         test      byte ptr ds:[ParMenu],bit0 + bit1 ; je hlavn° menu ?
         jz        InfoDis1                 ; nen° hlavn° menu

         push      ss
         pop       es
         mov       si,offset InfTxt1        ; text "áekejte..."
         mov       ah,ds:[ColDate]          ; barva textu
         mov       di,sp                    ; buffer v z†sobn°ku
         call      far ptr DekTText         ; dek¢dov†n° textu do bufferu

         mov       cl,10                    ; dÇlka textu
         xor       dx,dx                    ; ©†dek a pozice k zobrazen°
         mov       si,sp                    ; buffer v z†sobn°ku
         mov       al,0                     ; hladina k zobrazen°
         call      far ptr DispKStr         ; zobrazen° textu

InfoDis1:or        byte ptr ds:[InfoPar],bit0 ; p©°znak zobrazen° inf. ©†dku

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         call      far ptr KurzOff          ; vypnut° kurzoru
         ret

InfoDisp ENDP

; *****************************************************************************
;                              InfoClos
;   uzav©en° m¢du zobrazen° informaán°ho ©†dku (uchov†v† registr p©°znakñ !)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InfoClos PROC      FAR

         pushf
         and       byte ptr ds:[InfoPar],not bit0 ; zru®en° m¢du zobrazen° textu
         popf
         ret

InfoClos ENDP

; *****************************************************************************
;                             InfoAkt
;               test zobrazen° informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=nen° zobrazen informaán° ©†dek (tj. m¢d zobrazen° vypnut)
; *****************************************************************************

InfoAkt  PROC      FAR

         test      byte ptr ds:[InfoPar],bit0 ; je informaán° ©†dek zobrazen ?
         jnz       InfoAkt2                 ; informaán° ©†dek je zobrazen
         stc                                ; p©°znak vypnut° zobrazen°
InfoAkt2:ret

InfoAkt  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Obsluha datovÇho bufferu souborñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                 CreatBuf
;        vytvo©en° pracovn°ho datovÇho bufferu pro operaci se souborem
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=nedostatek pamàti (hl†s° chybu pamàti)
; *****************************************************************************

CreatBuf PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ test, zda je buffer jië vytvo©en

         cmp       word ptr ds:[BuffSeg],0  ; je buffer vytvo©en ?
         jne       CreatBf9                 ; buffer je jië vytvo©en

; ------ vytvo©en° datovÇho bloku

         mov       bx,1000h                 ; minim†ln° velikost bufferu 4 KB
         call      far ptr CreatDat         ; vytvo©en° datovÇho bufferu
         jnc       CreatBf3                 ; buffer vytvo©en OK

; ------ chyba - nedostatek pamàti

         call      far ptr MemErr           ; chyba - nedostatek pamàti
         jmp       short CreatBf9           ; n†vrat s CY

; ------ parametry datovÇho bufferu

CreatBf3:mov       ds:[BuffSeg],ax          ; á°slo datovÇho bloku
         mov       ds:[BuffSize],bx         ; velikost bufferu

; ------ n†vrat registrñ

CreatBf9:pop       bx
         pop       ax
         ret

CreatBuf ENDP

; *****************************************************************************
;                                   GetBuff
;         poskytnut° adresy datovÇho bufferu operace (p©°p. jeho vytvo©en°)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:ES=adresa datovÇho bufferu
;        CY=datovò buffer nelze vytvo©it
; *****************************************************************************

GetBuff  PROC      FAR

         push      ax
         mov       ax,ds:[BuffSeg]          ; á°slo datovÇho bloku
         or        ax,ax                    ; je buffer vytvo©en ?
         jnz       GetBuff2                 ; buffer je jië vytvo©en
         push      cs
         call      near ptr CreatBuf        ; vytvo©en° datovÇho bufferu
         jc        GetBuff3                 ; nedostatek pamàti
         mov       ax,ds:[BuffSeg]          ; á°slo datovÇho bloku
GetBuff2:call      far ptr GetDat           ; poskytnut° adresy datovÇho bloku
GetBuff3:pop       ax
         ret

GetBuff  ENDP

; *****************************************************************************
;                                   DelBuff
;                      zru®en° datovÇho bufferu operace
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DelBuff  PROC      FAR

         push      ax
         mov       ax,ds:[BuffSeg]          ; á°slo datovÇho bloku
         or        ax,ax                    ; je vytvo©en ?
         jz        DelBuff2                 ; nen° vytvo©en
         call      far ptr DelSeg           ; zru®en° datovÇho bufferu
         mov       ds:[BuffSeg],ax          ; zru®en° ukazatele na datovò blok
DelBuff2:pop       ax
         ret

DelBuff  ENDP

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
;        Definice vertik†ln°ho menu - obsluha souborñ
; -----------------------------------------------------------------------------

SMnuVert label     byte                   ;* menu souborñ

         db        1                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        16                       ; poáet platnòch poloëek menu
         dw        16                       ; celkovò poáet poloëek menu

         dw        SMnuVPol                 ; adresa definice poloëek menu
         dw        SMnuVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuSoubory       ; á°slo str†nky velkÇ n†povàdy
         dw        SMnuVBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SMnuVTit                 ; adresa titulu okna
         dw        SMnuVExe                 ; tabulka obsluh voleb menu
         dw        SMnuVMnu                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        18                       ; vò®ka

SMnuVPol db        1,7,'Adres†©'
         db        3,17,'vòBàr           ',16
         db        1,17,'Editace         ',16
         db        1,17,'Filtr           ',16
         db        1,7,'Hled†n°'
         db        1,9,'Informace'
         db        1,17,'JmÇno/p©esun    ',16
         db        1,17,'Kopie           ',16
         db        1,17,'Modifikace      ',16
         db        1,8,'Obnoven°'
         db        1,17,'Program         ',16
         db        1,17,'Ru®en°          ',16
         db        1,8,'Srovn†n°'
         db        1,17,'Tisk            ',16
         db        1,17,'Verifikace      ',16
         db        1,17,'Zobrazen°       ',16

; Tabulka modifikov†na p©i inicializaci programu

SMnuVBlk db        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

SMnuVTit db        7,'soubory'

HelpS    SEGMENT   BYTE PUBLIC
SMnuVHlp db        32,'Vytvo©en° novÇho adres†©e (F7)'
         db        80,'Vòbàr souborñ a adres†©ñ pro n†sleduj°c° operaci (Insert, [+], [-], [*])'
         db        47,'Editace textovòch nebo bin†rn°ch souborñ (F4)'
         db        53,'Konverze textovòch a bin†rn°ch souborñ, n†hrada textñ'
         db        73,'Hled†n° souborñ a adres†©ñ na disku, hled†n° textñ v souborech (Alt-F7)'
         db        69,'Blië®° informace o souboru nebo adres†©i pod kurzorem (Ctrl-mezera)'
         db        47,'P©ejmenov†n° a p©esun souborñ a adres†©ñ (F6)'
         db        36,'Kop°rov†n° souborñ a adres†©ñ (F5)'
         db        59,'Modifikace parametrñ souborñ - atributy, datum a áas (F9)'
         db        79,'Obnoven° omylem zru®enòch souborñ (nelze obnovit nulovanÇ soubory) (Shift-F7)'
         db        65,'Start programu nebo proveden° p©°kazu (Enter, F2, Shift-F2)'
         db        32,'Ru®en° souborñ a adres†©ñ (F8)'
         db        64,'Porovn†n° obsahu souborñ se soubory v protàj®°m oknà (Ctrl-F9)'
         db        24,'Tisk souborñ na tisk†rnu'
         db        37,'Ovà©en° áitelnosti souborñ a adres†©ñ'
         db        45,'Zobrazen° obsahu souboru nebo adres†©e (F3)'
HelpS    ENDS

SMnuVExe label     dword
         dd        AWMMnuSA                 ; Adres†©
         dd        AWMMnuSB                 ; vòBàr
         dd        AWMMnuSE                 ; Editace
         dd        AWMMnuSF                 ; Filtr
         dd        AWMMnuSH                 ; Hled†n°
         dd        AWMMnuSI                 ; Informace
         dd        AWMMnuSJ                 ; JmÇno/p©esun
         dd        AWMMnuSK                 ; Kopie
         dd        AWMMnuSM                 ; Modifikace
         dd        Undelete                 ; Obnoven°
         dd        Program                  ; Program
         dd        AWMMnuSR                 ; Ru®en°
         dd        AWMMnuSS                 ; Srovn†n°
         dd        AWMMnuST                 ; Tisk
         dd        AWMMnuSV                 ; Verifikace
         dd        AWMMnuSZ                 ; Zobrazen°

SMnuVMnu label     word
         dw        0                        ; Adres†©
         dw        SBMnVert                 ; vòBàr
         dw        SEMnVert                 ; Editace
         dw        SFMnVert                 ; Filtr
         dw        0                        ; Hled†n°
         dw        0                        ; Informace
         dw        SJMnVert                 ; JmÇno/p©esun
         dw        SKMnVert                 ; Kopie
         dw        SMMnVert                 ; Modifikace
         dw        0                        ; Obnoven°
         dw        SPMnVert                 ; Program
         dw        SRMnVert                 ; Ru®en°
         dw        0                        ; Srovn†n°
         dw        STMnVert                 ; Tisk
         dw        SVMnVert                 ; Verifikace
         dw        SZMnVert                 ; Zobrazen°

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

; Syntaxe pro vyhled†v†n° souborñ:
;
; disk:cesta\maska1 maska2 .... /parametry
;
;   - vòchoz° adres†© hled†n° zad†n jako text po posledn° znak "\" v ©†dku
;   - masky jsou specifikace souborñ od posledn°ho znaku "\" v ©†dku po znak "/"
;     Jsou oddàleny mezerami, znak "-" na zaá†tku masku ud†v†, ëe poloëka
;     vyhovuj°c° tÇto masce je zak†zan†. Lze pouë°t znaky "?" a "*" libovolnà
;     uvnit© specifikace (i v°cekr†t). Bez zad†n° teáky oddàluj°c° p©°ponu
;     se maska dopln° znakem "*" (mohou n†sledovat libovolnÇ znaky).
;   - parametry jsou oddàleny znakem "/"
;         D datum - podm°nkou hled†n° je datum (nebo interval D datum1 - datum2).
;                   Bez zad†n° data za znakem D plat° dne®n° den.
;         T áas   - podm°nkou hled†n° je áas (nebo interval T áas1 - áas2). Bez
;                   zad†n° áasu plat° aktu†ln° hodina.
;         N á°slo - podm°nkou hled†n° je velikost (nebo interval N vel.1 - vel.2)
;         atributy: R=R/O, H=HID, S=SYS, A=ARC, C=DIR. VelkÇ p°smeno=nastaven.
;                   MalÇ p°smeno=nulov†n.
;         "text"  - podm°nkou hled†n° je text (nerozli®uj° se velk†/mal† p°sm.)
;         U       - nerozli®uj° se velk† a mal† p°smena (bez diakritiky)
;         I       - soubor v k¢du IBM (omezen† diakritika)
;         K       - soubor je v n†rodn°m k¢du Kamenickòch
;         L       - soubor je v n†rodn°m k¢du Latin 2
;         O       - soubor je v n†rodn°m k¢du KOI 8
;         W       - soubor je v n†rodn°m k¢du WINDOWS
;         X       - hled†n° probàhne tÇë ve v®ech podadres†©°ch
;         Z       - hled†n° probàhne pouze v jednom adres†©i (ne podadres†©e)

; -----------------------------------------------------------------------------
;        datovò buffer pro operace se soubory
; -----------------------------------------------------------------------------

BuffSeg  dw        0                        ; datovò blok s bufferem (0=nen°)
BuffSize dw        0                        ; velikost datovÇho bufferu (bajtñ)

; -----------------------------------------------------------------------------
;        informaán° ©†dek
; -----------------------------------------------------------------------------

InfoPar  db        0                        ; parametry informaán°ho ©†dku
                                            ;   bit 0: 1=zobrazen inf. ©†dek
                                            ;   bit 1: 1=zvòraznàn† barva textu

InfoStor dw        2                        ; ukl†dac° offset do bufferu inf.©.
InfoBuf  label     byte
         db        2*255 dup(0)             ; buffer informaán°ho ©†dku

;InfoCol1 db        70h                      ; bàën† barva informaán°ho ©†dku
;InfoCol2 db        74h                      ; zvòraznàn† barva inform. ©†dku

InfoKMax dd        0                        ; celkov† velikost inform. kurzoru
InfoKCit dd        0                        ; á°taá velikosti inform. kurzoru

; -----------------------------------------------------------------------------
;        obsluha hled†n° souborñ
; -----------------------------------------------------------------------------
;˛
FileTyp  db        0                        ; p©ep°naáe pro hled†n° souborñ
                                            ;    bit 0: 1=kurzor
                                            ;    bit 1: 1=oznaáenÇ poloëky
                                            ;    bit 2: 1=v®echno
                                            ;    bit 3: 1=specifikace textem
                                            ;    bit 4: 1=adres†©e tÇë p©i n†vratu
                                            ;    bit 5:      (1=implicitnà ROOT)
                                            ;    bit 6: 1=moënÇ hled†n° adres†©ñ
                                            ;    bit 7: 1=moënÇ vno©en° do adr.

FileParm db        0                        ; parametry pro hled†n° souborñ
                                            ;    bit 0: 1=byl prvn° soubor/adr.
                                            ;    bit 1: 1=bylo vno©en° do adres†©e
                                            ;    bit 2: 1=povoleny adres†©e stromu
                                            ;    bit 3: 1=je adres†© p©i n†vratu
                                            ;    bit 4: 1=z†kaz podadres†©ñ pro
                                            ;             strom (rozvinuto)
                                            ;    bit 5: 1=z†kaz vno©en° do
                                            ;             naposledy nalezenÇho
                                            ;             adres†©e (od procedur)
                                            ;    bit 6: 1=oznaáen° inicializov†no
                                            ;    bit 7: 1=poloëka byla zru®ena
                                            ;             (od procedur)

FileWNum dw        0                        ; poáet otev©enòch oken souborñ
FileWSeg label     word
         dw        35 dup(0)                ; uschovan† otev©en† okna souborñ

; ------ jmÇno prohled†vanÇho adres†©e, specifikace souboru k operaci

FileFilN dw        0                        ; dÇlka textu adres†©e + soubor
FilePthN dw        0                        ; dÇlka textu adres†©e
FilePath label     byte
         db        255 dup(0)               ; buffer adres†©e + soubor
FileIdnt dw        0                        ; identifik†tor souboru

;FileOTxN dw        0                        ; dÇlka specifikace vòstupn°ho soub.
;FileOTxt db        255 dup(0)               ; buffer specifikace vòstup. souboru

FileAPtN dw        0                        ; dÇlka vòchoz°ho aktivn°ho adres†©e

FileOPtN dw        0                        ; dÇlka jmÇna vòstupn°ho souboru
FileOPth label     byte
         db        FileMax dup(0)           ; jmÇno vòstupn°ho souboru
FileOIdn dw        0                        ; identifik†tor vòstupn°ho souboru

FileFTop dw        0                        ; uschovan† poá†teán° poloëka relativnà
FileFKur dw        0                        ; uschovan† pozice kurzoru
FileFOld label     byte
         db        11 dup(0)                ; uschovanò kurzor v aktivn°m oknà

; ------ poloëka simuluj°c° poloëku seznamu souborñ

FileFCB0 label     byte
         db        11 dup(0)                ; jmÇno pro naá°t†n° adres†©ñ ReadDir

FileFPol label     byte
FileFAtr db        0                        ; atributy nalezenÇho souboru
FileFCB  label     byte
         db        11 dup(0)                ; jmÇno souboru ve tvaru FCB
FileFSiz dd        0                        ; velikost nalezenÇho souboru
FileFDat dw        0                        ; datum nalezenÇho souboru
FileFTim dw        0                        ; áas nalezenÇho souboru

FileTxtP db        0,'              '       ; textovò parametr poloëky volby
SRMnuFil db        13,'             '       ; jmÇno vstupn°ho souboru
SRMnuSiz db        13,'             '       ; velikost poloëky
SRMnuDat db        13,'             '       ; datum poloëky
SRMnuTim db        13,'             '       ; áas poloëky
SRMnuAtr db        5,'     '                ; atributy poloëky

; ------ zadan† c°lov† cesta

CilPthN0 dw        0                        ; inicializaán° dÇlka c°lovÇ cesty
CilCilPN dw        0                        ; dÇlka c°lovÇ cesty (bez souboru)
CilPathN dw        0                        ; dÇlka c°lovÇ cesty
CilPath  label     byte
         db        255 dup(0)               ; buffer c°lovÇ cesty
CilIdent dw        0                        ; identitifk†tor c°lovÇho souboru
;CilFCB   db        11 dup(0)                ; c°lovÇ jmÇno FCB (sestavenÇ)
CilMask  label     byte
         db        11 dup(0)                ; maska c°lovÇho jmÇna FCB

ChybBuff db        1,32 dup(" ")            ; buffer chybovÇho textu pro hl†®en°

MenuFndH db        100,'Syntaxe: cesta\maska / ACSHR acshr  Ddatum  Táas  Nvelikost  ZX  "text" UIKLOW'
MenuSelH db        98,'Syntaxe:  maska  -maska  / ACSHR acshr  Ddatum  Táas  Nvelikost  "text" UIKLOW'

SInfHled db        13,'Prohled†v†m ',0      ; hl†®en° p©i prohled†v†n° adres†©e

; -----------------------------------------------------------------------------
;        podm°nky pro test nalezenÇho souboru (p©i zad†n° textem)
; -----------------------------------------------------------------------------
; Buffer masek obsahuje texty masek konvertovanÇ na velk† p°smena a navz†jem
; oddàlenÇ jednou mezerou. Je-li jako prvn° znak masky znak "-", je soubor
; vyhovuj°c° tÇto masce zak†zanò.
; -----------------------------------------------------------------------------

; Zachovat posloupnost poloëek - pouë°v† to tÇë adres†©ovÇ okno !

SrcInit  label     byte                     ; zaá†tek tabulky parametrñ hled†n°
SrcAtr   db        0                        ; atributy hledanÇho souboru
SrcAtrM  db        0                        ; maska atributñ hledanÇho souboru

SrcTim1  dw        0                        ; poá†teán° áas souboru
SrcTim1M dw        0                        ; maska poá†teán°ho áasu souboru
SrcTim2  dw        0                        ; koncovò áas souboru
SrcTim2M dw        0                        ; maska koncovÇho áasu souboru

SrcDat1  dw        0                        ; poá†teán° datum souboru
SrcDat1M dw        0                        ; maska poá†teán°ho data souboru
SrcDat2  dw        0                        ; koncovÇ datum souboru
SrcDat2M dw        0                        ; maska koncovÇho data souboru

SrcSiz1  dd        0                        ; minim†ln° velikost souboru
SrcSiz2  dd        0                        ; maxim†ln° velikost souboru

SrcTextN dw        0                        ; dÇlka hledanÇho textu (0=nen°)
SrcText  label     byte
         db        50 dup(0)                ; buffer hledanÇho textu
SrcText0 label     byte                     ; konec bufferu

SrcTKod  db        0                        ; konverzn° k¢d souboru
                                            ;    0 = nen° konverze
                                            ;    bit 0: 1=ASCII ("U")
                                            ;    bit 1: 1=IBM ("I")
                                            ;    bit 2: 1=Kamenickòch ("K")
                                            ;    bit 3: 1=Latin 2 ("L")
                                            ;    bit 4: 1=KOI 8 ("O")
                                            ;    bit 5: 1=WINDOWS ("W")

SrcIParm db        0                        ; parametry pro hled†n°
                                            ;    bit 0: 1=áas vnà intervalu
                                            ;    bit 1: 1=datum vnà intervalu

SrcInit0 label     byte                     ; konec tabulky parametrñ hled†n°

FileMskN dw        0                        ; dÇlka textu v bufferu masek
FileMask label     byte
         db        256 dup(0)               ; buffer masek

; Param.:D=datum, T=áas, N=velikost, "=text, Z=z†kaz podadres†©ñ, X=podadres†©e
;        U=ASCII rozli®en°, I=IBM, K=Kamenickòch, L=Latin 2, O=KOI 8, W=WINDOWS
;        R,H,S,C,A=atributy

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chybnÇ zad†n° parametrñ operace
; -----------------------------------------------------------------------------

ChbLnPar label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        ChbLnPaP                 ; zaá†tek definice poloëek menu
         dw        ChbLnPaH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@ParametryProVyberSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnPaB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnPaT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        46                       ; ®°©ka okna
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

ChbLnPaP db        bit6,6,0,'CHYBA'

         db        bit6,32,'ChybnÇ zad†n° parametrñ operace:'

         db        bit6,3,1
         dw        ChybBuff

         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
ChbLnPaH db        34,'Opakov†n° zad†n° parametrñ operace'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

ChbLnPaT db        12,'chyba zad†n°'

ChbLnPaB db        0,0

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chybnÇ zad†n° disku
; -----------------------------------------------------------------------------

ChbLnDsk label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ChbLnDsP                 ; zaá†tek definice poloëek menu
         dw        ChbLnPaH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VychoziCesta         ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnDsB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnDsT                 ; adresa titulu okna
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

ChbLnDsP db        bit6,6,0,'CHYBA'
         db        bit6,29,'Zadanò disk ',0
ChbLnDP1 db        'A',0,': neexistuje !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Znovu'
         db        1,8,'P©eru®it'

ChbLnDsT db        13,'neplatnò disk'

ChbLnDsB db        0,0                      ; blokovac° tabulka

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - cesta nesm° obsahovat znaky "*" a "?"
; -----------------------------------------------------------------------------

ChbLnCl  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        4                        ; celkovò poáet poloëek menu

         dw        ChbLnClP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VychoziCesta         ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnClB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnClT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        43                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ChbLnClT db        16,'nepovolen† cesta'

ChbLnClP db        bit6,6,0,'CHYBA'
         db        bit6,43,'Cesta nesm° obsahovat znaky "',0,'?',0,'" a "',0,'*',0,'" !'
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbLnClB db        0                        ; blokovac° tabulka

; -----------------------------------------------------------------------------
;        Verifikace souborñ
; -----------------------------------------------------------------------------
;˛
SVMnVert label     byte                   ;* menu verifikace souborñ

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        6                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        SVMnVPol                 ; definián° tabulka poloëek
         dw        SVMnVHlp                 ; n†povàda
         dw        Hlp@MenuVerifikaceSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        SVMnVBlk                 ; blokovac° tabulka
         dw        0                        ; p©ep°naáe
         dw        SVMnVTit                 ; adresa titulu okna
         dw        SVMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        10                       ; poá†teán° ©†dek
         db        20                       ; ®°©ka okna
         db        8                        ; vò®ka okna

SVMnVPol db        1,6,'Kurzor'
         db        1,8,'OznaáenÇ'
         db        1,7,'Soubory'
         db        1,7,'V®echny'
         db        1,6,'ZadanÇ'
         db        1,4,'Disk'

SVMnVBlk db        0,0,0,0,0,0

SVMnVTit db        10,'verifikace'

HelpS    SEGMENT   BYTE PUBLIC
SVMnVHlp db        45,'Verifikace souboru nebo adres†©e pod kurzorem'
         db        40,'Verifikace oznaáenòch souborñ a adres†©ñ'
         db        40,'Verifikace v®ech souborñ v aktivn°m oknà'
         db        59,'Verifikace v®ech souborñ v aktivn°m oknà váetnà podadres†©ñ'
         db        43,'Verifikace souborñ podle blië®° specifikace'
         db        33,'Verifikace souborñ na celÇm disku'
HelpS    ENDS

SVMnVExe label     dword                    ; obsluhy voleb
         dd        Verify                   ; kurzor
         dd        Verify                   ; oznaáenÇ
         dd        Verify                   ; soubory
         dd        Verify                   ; v®echny
         dd        Verify                   ; zadanÇ
         dd        Verify                   ; disk

VerfParm db        0                        ; parametry pro verifikaci
                                            ;   bit 0: 1=nezobrazovat hl†®en°
CitVerif dw        0                        ; á°taá verifikovanòch souborñ
CitVerEr dw        0                        ; á°taá verifik. souborñ s chybou

VerfTxt  db        19,'Ovà©uji áitelnost ',0

VerfDisk db        'A:\*.* /X'              ; zad†n° pro verifikaci celÇho disku
VerfDsk0 label     byte

; -----------------------------------------------------------------------------
;        Definice ©†dkovÇho menu - volba souborñ k verifikaci
; -----------------------------------------------------------------------------

SVZMLin  label     byte

         db        3                        ; typ menu - ©†dkovÇ podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        SVZMLPol                 ; zaá†tek definice poloëek menu
         dw        SVZMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@VyberSouboru         ; á°slo str†nky velkÇ n†povàdy
         dw        SVZMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        SVZMLTit                 ; adresa titulu okna
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

SVZMLPol db        bit6,25,'Ovà©it áitelnost souborñ:'
         db        0,0
         db        bit6+bit7,0
         db        1,6,'ProveÉ'
         db        1,6,'N†vrat'

SVZMLBlk db        0,0,0                    ; blokovac° tabulka

SVZMLTit db        6,'zadanÇ'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
SVZMLHlp db        3,1
         dw        MenuFndH
         db        51,'Ovà©en° áitelnosti souborñ podle zadanÇ specifikace'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba otev©en° souboru
; -----------------------------------------------------------------------------

ChbLnV1  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        ChbLnV1P                 ; zaá†tek definice poloëek menu
         dw        ChbLnV1H                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuVerifikaceSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnV1B                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnV1T                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        49                       ; ®°©ka okna
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

ChbLnV1T db        14,'chyba otev©en°'

ChbLnV1P db        bit6,6,0,'CHYBA'
         db        bit6,28,'Soubor ',0
         db        1
         dw        SRMnuFil                 ; jmÇno souboru
         db        0,' nelze otev©°t !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'Nehl†sit'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
ChbLnV1H db        3,1
         dw        ChbLnVHH
         db        20,1
         dw        ChbLnVHH
         db        ' bez hl†®en° chyb'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

ChbLnVHH db        38,'Pokraáov†n° verifikac° dal®°ho souboru'

ChbLnV1B db        0,0,0

; -----------------------------------------------------------------------------
;        chybovÇ hl†®en° - chyba áten° souboru
; -----------------------------------------------------------------------------

ChbLnV2  label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        ChbLnV2P                 ; zaá†tek definice poloëek menu
         dw        ChbLnV1H                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuVerifikaceSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnV1B                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnV2T                 ; adresa titulu okna
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

ChbLnV2T db        11,'chyba áten°'

ChbLnV2P db        bit6,6,0,'CHYBA'
         db        bit6,30,'Chyba áten° ze souboru ',0
         db        1
         dw        SRMnuFil                 ; jmÇno souboru
         db        0,' !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,5,'Dal®°'
         db        1,8,'Nehl†sit'
         db        1,8,'P©eru®it'

; -----------------------------------------------------------------------------
;        hl†®en° o poátu verifikovanòch souborñ
; -----------------------------------------------------------------------------

ChbLnVH  label     byte

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        1                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        ChbLnVHP                 ; zaá†tek definice poloëek menu
         dw        ChbLnMeH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@MenuVerifikaceSouboru ; á°slo str†nky velkÇ n†povàdy
         dw        ChbLnVHB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ChbLnVHT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        50                       ; ®°©ka okna
         db        12                       ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie
         db        0                        ; poáet p©edvoleb

ChbLnVHP db        bit6,0
         db        bit6,33,'Verifikace souborñ byla ukonáena.'
         db        bit6,0
         db        bit6,31,'Poáet ovà©ovanòch souborñ: ',0,1
         dw        ChbLnVH3
         db        bit6,3,1
ChbLVHP1 dw        ChbLnVH0
         db        bit6,0
         db        bit6+bit7,0
         db        1,6,'N†vrat'

ChbLnVHB db        0                        ; blokovac° tabulka

ChbLnVHT db        16,'konec verifikace'

ChbLnVH0 db        39,'V®echny soubory jsou áitelnÇ bez chyby.'
ChbLnVH1 db        29,'Poáet neáitelnòch souborñ: ',0
ChbLnVH2 db        '0     '
ChbLnVH3 db        1,'0     '
ChbLnVH4 db        0

Data     ENDS
         END

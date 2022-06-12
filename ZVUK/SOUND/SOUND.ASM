
; -----------------------------------------------------------------------------
; RAW SOUND:          0: identifikace 'Creative Voice File'
;                     1Ah: (1) identifikace 01h
;                     1Bh: (3) velikost souboru bez z hlav¡ 31 bajt–
;                     1Eh: (1) dˆlic¡ konstanta dˆli‡ky
;                             vzorkovac¡ kmito‡et = 1'000'000 / (100h-konstanta)
;                     1Fh: (1) typ komprese
;                                  0 = bez komprese
;                                  1 = komprese 4 bity (v jednom bajtu 4,4)
;                                  2 = komprese 3 bity (v jednom bajtu 3,3,2)
;                                  3 = komprese 2 bity (v jednom bajtu 2,2,2,2)
;                     P©i kompresi jsou 2 bajty norm lnˆ jako v˜choz¡ hodnota,
;                     n sleduj¡ bity inkrementac¡ - v‘dy od horn¡ch bit–,
;                     nejvy¨¨¡ bit je znam‚nkov˜ (smˆr inkrementace)
;                     20h: data
; -----------------------------------------------------------------------------
; SOUND BLASTER PRO:  0: identifikace 'Creative Voice File'
;                     1Ah: (2) identifikace 08h 04h
;                     1Fh: (1) dˆlic¡ konstanta dˆli‡ky
;                             vzorkovac¡ kmito‡et = 1'000'000 / (100h-konstanta)
;                     20h:
;                     21h: (1) 0=MONO, 1=STEREO
;                     22h: data
; -----------------------------------------------------------------------------
; Form t souboru WAV:
;    0: (4) identifikace 'RIFF'
;    4: (4) velikost souboru bez z hlav¡ 8 bajt–
;    8: (8) identifikace 'WAVEfmt ' (=definice form tu souboru)
;   16h: (1) po‡et kan l– (1=mono, 2=stereo)
;   18h: (4) vzorkovac¡ kmito‡et pro jeden kan l (stereofonn¡ p©ehr v n¡)
;   1ch: (4) vzorkovac¡ kmito‡et pro monofonn¡ p©ehr v n¡
;   20h: (2) po‡et bajt– na jeden vzorek (pro v¨echny kan ly)
;   22h: (2) po‡et bit– na vzorek (8=8 bit–, 16=16 bit–)
;   24h: (4) identifikace 'data' (=za‡ tek dat)
;   28h: (4) velikost n sleduj¡c¡ch dat (v bajtech)
;   2ch:      ... data
; -----------------------------------------------------------------------------

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov n¡ z sobn¡ku

Start:   cmp       sp,offset Konec          ; je z sobn¡k OK ?
         jb        Start1                   ; chyba - nedostatek pamˆti
         mov       sp,offset Konec          ; nov˜ ukazatel konce z sobn¡ku

; ------ zmen¨en¡ bloku programu na minimum

         mov       bx,(offset(Konec-Start)+10fh)/16 ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu
         jc        Start1                   ; chyba - nedostatek pamˆti

; ------ vytvo©en¡ datov‚ho bloku

         mov       bx,-1
         mov       ah,48h
         int       21h                      ; test velikosti max. bloku
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         jc        Start1                   ; chyba - nelze vytvo©it blok
         and       bl,not 0fh               ; zarovn n¡ velikosti na 256 bajt–
         mov       ds:[DatSeg],ax           ; adresa datov‚ho bloku
         mov       ds:[DatSize],bx          ; velikost datov‚ho bloku
         cmp       bx,100h                  ; minim ln¡ velikost bloku 4 KB
         jae       Start2                   ; blok vytvo©en OK

; ------ chyba

Start1:  mov       dx,offset MemTxt         ; text - nedostatek pamˆti
Chyba:   mov       ah,9
         int       21h
         mov       ax,4c02h                 ; p©¡znak chyby programu
         int       21h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

Start2:  mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0
         mov       bl,ds:[si-1]
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kaz. © dku

; ------ nalezen¡ za‡ tku parametru

Start3:  call      ParSpc                   ; vypu¨tˆn¡ mezer
         jnc       Start300
         jmp       Start6                   ; nen¡ dal¨¡ parametr
Start300:cmp       al,"/"                   ; je parametr
         je        Start301
         jmp       Start5                   ; nen¡ parametr - je jm‚no souboru
Start301:inc       si                       ; p©esko‡en¡ znaku "/"
Start30: call      ParChr                   ; dal¨¡ znak parametru
         jc        Start4                   ; chyba zad n¡ - nen¡ dal¨¡ znak

; ------ zad n¡ nulov‚ hladiny vzorku

         cmp       al,"L"                   ; je zad na nulov  hladina vzorku ?
         jne       Start31                  ; nen¡ zad na nulov  hladina vzorku
         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        Start4                   ; konec - chyba
         cmp       al,"!"                   ; nucen  detekce nuly ?
         jne       Start302                 ; nen¡ nucen  detekce nuly
         inc       si                       ; vypu¨tˆn¡ znaku "!"
         or        byte ptr ds:[Param],80h  ; p©¡znak nucen‚ detekce nuly
         jmp       short Start3             ; rozbor dal¨¡ho parametru
Start302:call      ParNum                   ; na‡ten¡ zadan‚ nulov‚ hladiny
         jc        Start4                   ; chyba zad n¡ parametru
         cmp       ax,255                   ; je zad n¡ OK ?
         ja        Start4                   ; chyba zad n¡ parametru
         mov       ds:[NulLev],al           ; zadan  nulov  hladina vzorku
         or        byte ptr ds:[Param],4    ; p©¡znak zad n¡ nulov‚ hladiny
         jmp       short Start3             ; rozbor dal¨¡ho parametru

; ------ zad n¡ v˜stupn¡ho kan lu

Start31: cmp       al,"C"                   ; je zad n¡ v˜stupn¡ho kan lu ?
         jne       Start32                  ; nen¡ zad n¡ v˜stupn¡ho kan lu
         call      ParNum                   ; na‡ten¡ zadan‚ho v˜stup. kan lu
         jc        Start4                   ; chyba zad n¡ parametru
         cmp       ax,4                     ; maxim ln¡ ‡¡slo kan lu
         ja        Start4                   ; chyba zad n¡ parametru
         mov       ds:[OutCan],al           ; zadan˜ v˜stupn¡ kan l
         or        byte ptr ds:[Param],8    ; p©¡znak zad n¡ v˜stupn¡ho kan lu
Start311:jmp       short Start3             ; rozbor dal¨¡ho parametru

; ------ zad n¡ zv˜¨en¡ hlasitosti vzorku

Start32: cmp       al,"V"                   ; zad na hlasitost ?
         jne       Start33                  ; nen¡ zad na hlasitost
         call      ParNum                   ; na‡ten¡ zadan‚ hlasitosti
         jc        Start4                   ; chyba zad n¡ parametru
         or        ax,ax                    ; 0 je zak zan 
         jz        Start4                   ; chyba zad n¡ parametru
         cmp       ax,100                   ; maxim ln¡ zv˜¨en¡ hlasitosti
         ja        Start4                   ; chyba zad n¡ parametru
         mov       ds:[SampVol],al          ; zv˜¨en¡ hlasitosti vzorku
         or        byte ptr ds:[Param],40h  ; p©¡znak zad n¡ hlasitosti
         jmp       short Start311           ; rozbor dal¨¡ho parametru

; ------ zad n¡ vzorkovac¡ho kmito‡tu

Start33: dec       si                       ; n vrat posledn¡ho na‡ten‚ho znaku
         call      ParNum                   ; rozbor zad n¡ vzorkov. kmito‡tu
         jc        Start4                   ; chyba zad n¡
         cmp       ax,2250                  ; minim ln¡ kmito‡et
         jb        Start4                   ; chyba zad n¡
         cmp       ax,65500                 ; maxim ln¡ kmito‡et
         ja        Start4                   ; chyba zad n¡
         mov       ds:[SampRate],ax         ; vzorkovac¡ kmito‡et
         or        byte ptr ds:[Param],2    ; p©¡znak zad n¡ vzorkovac¡ho kmit.
         jmp       short Start311           ; dal¨¡ parametr

; ------ chyba zad n¡ parametru

Start4:  mov       dx,offset HelpTxt        ; text n povˆdy
Chyba2:  jmp       Chyba                    ; chybov˜ n vrat

; ------ zad n po‘adavek zobrazen¡ n povˆdy

Start5:  cmp       al,"?"
         je        Start4                   ; je po‘adov no zobrazen¡ n povˆdy

; ------ rozbor jm‚na souboru

         mov       ds:[SoubNam],si          ; adresa jm‚na souboru
         or        byte ptr ds:[Param],1    ; p©¡znak zad n¡ jm‚na souboru
Start51: call      ParChr                   ; na‡ten¡ znaku jm‚na souboru
         jc        Start55                  ; konec jm‚na souboru
         je        Start53                  ; oddˆlovac¡ mezera - konec jm‚na
         mov       byte ptr ds:[si-1],al    ; n hrada velk˜m p¡smenem
         cmp       al,"/"
         jne       Start51                  ; nen¡ za‡ tek dal¨¡ho parametru
         mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce jm‚na souboru
         jmp       Start30                  ; dek¢dov n¡ dal¨¡ho parametru

Start53: mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce jm‚na souboru
         jmp       short Start311           ; dek¢dov n¡ dal¨¡ho parametru

Start55: mov       byte ptr ds:[si],0       ; ozna‡en¡ konce jm‚na souboru

; ------ kontrola, zda bylo zad no jm‚no souboru

Start6:  test      byte ptr ds:[Param],1    ; bylo zad no jm‚no souboru ?
         jz        Start4                   ; chyba-nebylo zad no jm‚no souboru

; ------ nalezen¡ konce jm‚na souboru

         cld
         mov       di,ds:[SoubNam]          ; jm‚no souboru
         push      ds
         pop       es
         mov       ch,1                     ; asi tak 256 bajt–
         xor       ax,ax
         repne     scasb                    ; nalezen¡ konce jm‚na souboru
         mov       ds:[SoubEnd],di          ; £schova konce jm‚na + 2

; ------ test, zda je p©¡pona 3 znaky

         mov       si,di                    ; konec jm‚na souboru
         sub       si,4                     ; p©¡padn  p©¡pona jm‚na
         cmp       byte ptr ds:[si-1],"."   ; je te‡ka p©ed p©¡ponou ?
         jne       Start616                 ; nen¡ p©¡pona 3 znaky

; ------ p©enesen¡ p©¡pony do bufferu

         mov       cx,3                     ; 3 znaky k p©enesen¡
         mov       di,offset SoubExt        ; p©¡pona jm‚na souboru
Start612:call      ParChr                   ; na‡ten¡ znaku p©¡pony
         stosb                              ; ulo‘en¡ znaku do bufferu
         loop      Start612                 ; dal¨¡ znak

; ------ p©¡prava adresy portu

Start616:mov       bl,ds:[OutCan]           ; v˜stupn¡ kan l
         mov       bh,0
         or        bx,bx                    ; je zad n reproduktor ?
         jz        Start62                  ; je zad n reproduktor
         add       byte ptr ds:[PortTxt1],bl ; ozna‡en¡ portu
         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         shl       bx,1                     ; offset v tabulce + 2
         mov       ax,es:[bx+408h-2]        ; adresa portu LPT
         mov       ds:[AdrPort],ax          ; adresa v˜stupn¡ho portu
         or        ax,ax                    ; je port instalov n ?
         mov       dx,offset PortTxt
         jz        Chyba3                   ; chyba - port LPT nen¡ instalov n

; ------ otev©en¡ zadan‚ho souboru

Start62: mov       dx,ds:[SoubNam]          ; zadan‚ jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jnc       Start63
         mov       dx,offset FndTxt         ; text - soubor nenalezen
Chyba3:  jmp       Chyba2                   ; chyba - soubor nenalezen
Start63: mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ zji¨tˆn¡ velikosti souboru

         mov       bx,ax                    ; identifik tor souboru
         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; zji¨tˆn¡ velikosti souboru
         mov       word ptr ds:[SoubSize],ax ; velikost LOW
         mov       word ptr ds:[SoubSize+2],dx ; velikost HIGH

; ------ resetov n¡ ukazatele v souboru

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h                      ; ukazatel v souboru na za‡ tek

; ------ na‡ten¡ souboru do pamˆti

Start7:  call      ReadFile                 ; na‡ten¡ souboru do pamˆti

; ------ test, zda je konec soubor

         cmp       word ptr ds:[DatNum],0   ; bylo nˆco na‡teno ze souboru ?
         jne       Start72                  ; bylo nˆco na‡teno ze souboru
         mov       ax,4c00h
         int       21h                      ; konec programu

; ------ detekce parametr– souboru

Start72: test      byte ptr ds:[Param],20h  ; byl soubor detekov n ?
         jnz       Start73                  ; soubor byl ji‘ detekov n
         call      DetFile                  ; detekce parametr– souboru
         call      InitPar                  ; inicializace parametr– souboru
         call      DispPar                  ; zobrazen¡ parametr– souboru
         or        byte ptr ds:[Param],20h  ; p©¡znak detekce parametr– souboru

; ------ korekce hlasitosti v˜stupu na reproduktor

Start73: cmp       byte ptr ds:[Kompres],0
         jne       Start75                  ; je komprese
         cmp       byte ptr ds:[OutCan],0   ; je v˜stup na reproduktor ?
         jne       Start74                  ; nen¡ v˜stup na reproduktor
         call      KorVol                   ; korekce hlasitosti pro reproduktor
         jmp       short Start75

; ------ korekce nulov‚ hladiny dat pro v˜stup na port LPT

Start74: cmp       byte ptr ds:[SampVol],1  ; mˆn¡ se hlasitost ?
         jne       Start741                 ; mˆn¡ se hlasitost
         cmp       byte ptr ds:[NulLev],80h ; je nulov  hladina 80h ?
         je        Start75                  ; nulov  hladina je OK
Start741:call      KorNul                   ; korekce nulov‚ hladiny dat

; ------ start p©ehr v n¡

Start75: call      InitPort                 ; inicializace port–

; ------ ‡ek n¡ na p©ehr t¡ vzorku

Start76: sti
         or        bp,bp
         jnz       Start76                  ; ‡ek n¡ na p©ehr t¡ obsahu pamˆti
         cli

; ------ odinstalov n¡ port–

         call      DIniPort                 ; odinstalov n¡ port–

; ------ test, zda bylo p©eru¨en¡ programu kl vesou ESC

         test      byte ptr ds:[Param],10h  ; bylo p©eru¨en¡ programu ?
         jz        Start7                   ; nebylo p©eru¨en¡ programu
         mov       ax,4c01h
         int       21h


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Obsluhy p©eru¨en¡
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        obsluha INT 09h - p©eru¨en¡ programu kl vesou ESC
; -----------------------------------------------------------------------------
; VSTUP: BP=‡¡ta‡ blok– dat 256 bajt– k zvukov‚mu v˜stupu
; zni‡en‚ registry: AL
; -----------------------------------------------------------------------------

Int09    PROC      FAR

; ------ £schova registr–

         push      cx

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡

; ------ uzam‡en¡ kl vesnice

         mov       ch,20
Int091:  in        al,[64h]
         test      al,2
         loopnz    Int091                   ; ‡ek n¡ na p©ipravenost ©adi‡e
         mov       al,0adh
         out       [64h],al                 ; vysl n¡ povelu-uzam‡en¡ kl vesnice

; ------ ‡ten¡ k¢du kl vesy

         mov       ch,20
Int092:  in        al,[64h]
         test      al,2
         loopnz    Int092                   ; ‡ek n¡ na p©ipravenost ©adi‡e
         in        al,[60h]

; ------ konec jednoho bloku TAB, p©eru¨en¡ programu ESC

         cmp       al,0fh                   ; TAB
         je        int0922
         cmp       al,1                     ; ESC
         jne       Int093
         or        byte ptr cs:[Param],10h  ; p©¡znak p©eru¨en¡ programu
Int0922: xor       bp,bp                    ; nulov n¡ ‡¡ta‡e dat

; ------ uvolnˆn¡ kl vesnice

Int093:  mov       ch,20
Int094:  in        al,[64h]
         test      al,2
         loopnz    Int094                   ; ‡ek n¡ na p©ipravenost ©adi‡e
         mov       al,0aeh
         out       [64h],al                 ; vysl n¡ povelu-uvolnˆn¡ kl vesnice

; ------ n vrat registr–

         pop       cx
         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h - vysl n¡ vzorku
; -----------------------------------------------------------------------------
; VSTUP: AH=datov˜ bajt k vysl n¡ na port
;        DX=adresa v˜stupn¡ho portu
;        SI=adresa obsluhy p©¡pravy dal¨¡ho vzorku
;        DS:BX=ukazatel dat (BH=0, po p©ekro‡en¡ BL se zv˜¨¡ DS o 16)
;        BP=‡¡ta‡ blok– dat 256 bajt– k v˜stupu
;        DI=kopie DS, ale lze jej vyu‘¡t t‚‘ internˆ
; registry AL, CX, DI a ES jsou voln‚ pro intern¡ pou‘it¡ procedurami
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ start nov‚ho impulsu na reproduktor

PORT61:  mov       al,4bh
         out       [61h],al                 ; impuls na reproduktor
         dec       ax                       ; nulov n¡ bitu 0 (spou¨tˆc¡)
         out       [61h],al                 ; konec impulsu

; ------ vysl n¡ vzorku

         mov       al,ah                    ; bajt k vysl n¡
         out       dx,al                    ; vysl n¡ bajtu na port

; ------ uvolnˆn¡ p©eru¨en¡

         mov       al,20h
         out       [41h],al                 ; impuls na ‡¡ta‡ REFRESH
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         jmp       si                       ; obsluha p©¡pravy dal¨¡ho vzorku

INT08    ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       V˜stup dat bez komprese
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        bez zmˆny frekvence
; -----------------------------------------------------------------------------

INT080   PROC      NEAR

; ------ p©¡prava datov‚ho bajtu

         mov       ah,ds:[bx]               ; dal¨¡ bajt dat

; ------ zv˜¨en¡ ukazatele vzorku

         inc       bl                       ; zv˜¨en¡ ukazatele adresy
         jz        Int0801                  ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int0801: add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int0802                  ; byl ji‘ konec dat
         iret

Int0802: xor       bp,bp                    ; n vrat BP na 0
         iret

INT080   ENDP

; -----------------------------------------------------------------------------
;        frekvence se dˆl¡ 2:3
; -----------------------------------------------------------------------------

INT08D1  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 1:1)

INT08D11:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       ah,al
         rcr       ah,1                     ; pomˆr 1:1
         mov       si,offset INT08D12
         iret


; ------ druh˜ vzorek (pouze 3. bajt)

INT08D12:mov       ah,ds:[bx+2]             ; 3. bajt dat
         mov       si,offset INT08D11

; ------ zv˜¨en¡ ukazatele vzorku

         add       bl,3                     ; zv˜¨en¡ ukazatele adresy
         jc        Int08D14                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08D14:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08D15                 ; byl ji‘ konec dat
         iret

Int08D15:xor       bp,bp                    ; n vrat BP na 0
         iret

INT08D1  ENDP

; -----------------------------------------------------------------------------
;        frekvence se dˆl¡ 1:2
; -----------------------------------------------------------------------------

INT08D2  PROC      NEAR

; ------ vzorek dat (1. bajt a 2. bajt v pomˆru 1:1)

         mov       ax,ds:[bx]               ; 2 bajty dat
         add       ah,al
         rcr       ah,1                     ; pomˆr 1:1

; ------ zv˜¨en¡ ukazatele vzorku

         add       bl,2                     ; zv˜¨en¡ ukazatele adresy
         jc        Int08D22                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08D22:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08D23                 ; byl ji‘ konec dat
         iret

Int08D23:xor       bp,bp                    ; n vrat BP na 0
         iret

INT08D2  ENDP

; -----------------------------------------------------------------------------
;        frekvence se dˆl¡ 1:3
; -----------------------------------------------------------------------------

INT08D3  PROC      NEAR

; ------ vzorek dat (aritmetick˜ st©ed 3 bajt–)

         mov       ax,ds:[bx]               ; 1. bajt a 2. bajt dat
         add       al,ah                    ; 1. bajt + 2. bajt dat
         mov       ah,0
         adc       ah,0
         add       al,ds:[bx+2]             ; 3. bajt dat
         adc       ah,0
         mov       cl,3                     ; dˆlitel
         div       cl                       ; st©ed
         mov       ah,al

; ------ zv˜¨en¡ ukazatele vzorku

         add       bl,3                     ; zv˜¨en¡ ukazatele adresy
         jc        Int08D32                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08D32:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08D33                 ; byl ji‘ konec dat
         iret

Int08D33:xor       bp,bp                    ; n vrat BP na 0
         iret

INT08D3  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 3:2
; -----------------------------------------------------------------------------

Int08N1  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 1:2)

Int08N11:mov       al,ds:[bx+1]             ; 2. bajt dat
         mov       ah,0
         shl       ax,1                     ; 2. bajt * 2
         add       al,ds:[bx]               ; p©i‡ten¡ 1. bajtu dat
         adc       ah,0
         mov       cl,3                     ; dˆlitel
         div       cl
         mov       ah,al
         mov       si,offset Int08N12
         iret


; ------ druh˜ vzorek (2. bajt a 3. bajt v pomˆru 2:1)

Int08N12:mov       al,ds:[bx+1]             ; 2. bajt dat
         mov       ah,0
         shl       ax,1                     ; 2. bajt * 2
         add       al,ds:[bx+2]             ; p©i‡ten¡ 3. bajtu
         adc       ah,0
         div       cl                       ; CL z–stalo od p©ede¨l‚ho vzorku 3
         mov       ah,al
         mov       si,offset Int08N13
         iret


; ------ t©et¡ vzorek (3. bajt)

Int08N13:mov       ah,ds:[bx+2]             ; 3. bajt dat
         mov       si,offset Int08N11

; ------ posun ukazatele dat

         add       bl,2                     ; posun ukazatele
         jc        Int08N14                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N14:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N15                 ; byl ji‘ konec dat
         iret

Int08N15:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N1  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 2:1
; -----------------------------------------------------------------------------

Int08N2  PROC      NEAR

; ------ prvn¡ vzorek

Int08N21:add       ah,ds:[bx]               ; p©edchoz¡ + 1 bajt dat
         rcr       ah,1                     ; aritmetick˜ pr–mˆr s p©ede¨l˜m
         mov       si,offset Int08N22
         iret


; ------ druh˜ vzorek

Int08N22:mov       ah,ds:[bx]               ; 1. bajt dat
         mov       si,offset Int08N21       ; p©¡¨tˆ bude prvn¡ vzorek

; ------ posun ukazatele dat

         inc       bl                       ; posun ukazatele
         jz        Int08N24                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N24:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N25                 ; byl ji‘ konec dat
         iret

Int08N25:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N2  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 3:2
; -----------------------------------------------------------------------------

Int08N3  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 2:1)

Int08N31:mov       al,ah                    ; p©edchoz¡ bajt (1. bajt dat)
         mov       ah,0
         shl       ax,1                     ; 1. bajt * 2
         add       al,ds:[bx+1]             ; p©i‡ten¡ 2. bajtu dat
         adc       ah,0                     ; p©enos
         mov       cl,3                     ; dˆlitel
         div       cl
         mov       ah,al
         mov       si,offset Int08N32
         iret


; ------ druh˜ vzorek (1. bajt a 2. bajt v pomˆru 1:2)

Int08N32:add       ah,ds:[bx+1]             ; 2/3 1.B + 1/3 2.B + 3/3 2.B
         rcr       ah,1                     ; 1/3 1.B + 2/3 2.B
         mov       si,offset Int08N33
         iret


; ------ t©et¡ vzorek (2. bajt)

Int08N33:mov       ah,ds:[bx+1]             ; 2. bajt dat
         mov       si,offset Int08N31

; ------ posun ukazatele dat

         inc       bl                       ; posun ukazatele
         jz        Int08N34                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N34:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N35                 ; byl ji‘ konec dat
         iret

Int08N35:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N3  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 4:1
; -----------------------------------------------------------------------------

Int08N4  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 3:1)

Int08N41:mov       al,ds:[bx+1]             ; 2. bajt dat
         add       al,ah                    ; 1. bajt + 2. bajt dat
         rcr       al,1                     ; st©ed 1:1
         add       ah,al                    ; vˆt¨¡ v ha pro 1. bajt dat
         rcr       ah,1                     ; pomˆr 3:1
         mov       si,offset Int08N42
         iret


; ------ druh˜ vzorek (1. bajt a 2. bajt v pomˆru 2:2)

Int08N42:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       ah,al
         rcr       ah,1                     ; pomˆr 1:1
         mov       si,offset Int08N43
         iret


; ------ t©et¡ vzorek (1. bajt a 2. bajt v pomˆru 1:3)

Int08N43:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       al,ah                    ; 1. bajt + 2. bajt dat
         rcr       al,1                     ; st©ed 1:1
         add       ah,al                    ; vˆt¨¡ v ha pro 2. bajt dat
         rcr       ah,1                     ; pomˆr 1:3
         mov       si,offset Int08N44
         iret


; ------ ‡tvrt˜ vzorek (pouze 2. bajt)

Int08N44:mov       ah,ds:[bx+1]             ; 2. bajt dat
         mov       si,offset Int08N41

; ------ posun ukazatele dat

         inc       bl                       ; posun ukazatele
         jz        Int08N45                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N45:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N46                 ; byl ji‘ konec dat
         iret

Int08N46:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N4  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 6:1
; -----------------------------------------------------------------------------

Int08N6  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 5:1)

Int08N61:mov       al,ah                    ; 1. bajt
         mov       ah,0
         mov       cx,ax                    ; £schova 1. bajtu
         shl       ax,1                     ; 1. bajt * 2
         shl       ax,1                     ; 1. bajt * 4
         add       ax,cx                    ; 1. bajt * 5
         add       al,ds:[bx+1]             ; p©i‡ten¡ 2. bajtu
         adc       ah,0                     ; p©enos
         mov       cl,6                     ; dˆlitel
         div       cl
         mov       ah,al                    ; pomˆr 5:1
         mov       si,offset Int08N62
         iret


; ------ druh˜ vzorek (1. bajt a 2. bajt v pomˆru 4:2)

Int08N62:mov       al,ds:[bx]               ; 1. bajt
         mov       ah,0
         shl       ax,1                     ; 1. bajt * 2
         add       al,ds:[bx+1]             ; p©i‡ten¡ 2. bajtu
         adc       ah,0                     ; p©enos
         mov       cl,3                     ; dˆlitel
         div       cl
         mov       ah,al                    ; pomˆr 4:2
         mov       si,offset Int08N63
         iret


; ------ t©et¡ vzorek (1. bajt a 2. bajt v pomˆru 3:3)

Int08N63:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       ah,al
         rcr       ah,1                     ; pomˆr 3:3
         mov       si,offset Int08N64
         iret


; ------ ‡tvrt˜ vzorek (1. bajt a 2. bajt v pomˆru 2:4)

Int08N64:mov       al,ds:[bx+1]             ; 2. bajt
         mov       ah,0
         shl       ax,1                     ; 2. bajt * 2
         add       al,ds:[bx]               ; p©i‡ten¡ 1. bajtu
         adc       ah,0                     ; p©enos
         mov       cl,3                     ; dˆlitel
         div       cl
         mov       ah,al                    ; pomˆr 2:4
         mov       si,offset Int08N65
         iret


; ------ p t˜ vzorek (1. bajt a 2. bajt v pomˆru 1:5)

Int08N65:mov       al,ds:[bx+1]             ; 2. bajt
         mov       ah,0
         mov       cx,ax                    ; £schova 2. bajtu
         shl       ax,1                     ; 2. bajt * 2
         shl       ax,1                     ; 2. bajt * 4
         add       ax,cx                    ; 2. bajt * 5
         add       al,ds:[bx]               ; p©i‡ten¡ 1. bajtu
         adc       ah,0                     ; p©enos
         mov       cl,6                     ; dˆlitel
         div       cl
         mov       ah,al                    ; pomˆr 1:5
         mov       si,offset Int08N66
         iret


; ------ ¨est˜ vzorek (pouze 2. bajt)

Int08N66:mov       ah,ds:[bx+1]             ; 2. bajt dat
         mov       si,offset Int08N61

; ------ posun ukazatele dat

         inc       bl                       ; posun ukazatele
         jz        Int08N67                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N67:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N68                 ; byl ji‘ konec dat
         iret

Int08N68:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N6  ENDP

; -----------------------------------------------------------------------------
;        frekvence se n sob¡ 8:1
; -----------------------------------------------------------------------------

Int08N8  PROC      NEAR

; ------ prvn¡ vzorek (1. bajt a 2. bajt v pomˆru 7:1)

Int08N81:mov       al,ah                    ; 1. bajt dat
         mov       ah,0
         mov       cx,ax                    ; £schova 1. bajtu dat
         shl       ax,1                     ; 1. bajt * 2
         add       ax,cx                    ; 1. bajt * 3
         shl       ax,1                     ; 1. bajt * 6
         add       ax,cx                    ; 1. bajt * 7
         add       al,ds:[bx+1]             ; p©i‡ten¡ 2. bajtu dat
         adc       ah,0                     ; p©enos
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       ah,al                    ; pomˆr 7:1
         mov       si,offset Int08N82
         iret


; ------ druh˜ vzorek (1. bajt a 2. bajt v pomˆru 6:2)

Int08N82:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       ah,al                    ; 1. bajt + 2. bajt dat
         rcr       ah,1                     ; st©ed 1:1
         add       ah,al                    ; vˆt¨¡ v ha pro 1. bajt dat
         rcr       ah,1                     ; pomˆr 6:2
         mov       si,offset Int08N83
         iret


; ------ t©et¡ vzorek (1. bajt a 2. bajt v pomˆru 5:3)

Int08N83:mov       al,ds:[bx]               ; 1. bajt dat
         mov       ah,0
         mov       cx,ax                    ; £schova 1. bajtu dat
         shl       ax,1                     ; 1. bajt * 2
         shl       ax,1                     ; 1. bajt * 4
         add       ax,cx                    ; 1. bajt * 5
         mov       cl,ds:[bx+1]             ; 2. bajt dat
         add       ax,cx                    ; pomˆr 5:1
         add       ax,cx                    ; pomˆr 5:2
         add       ax,cx                    ; pomˆr 5:3
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; sou‡et / 8
         mov       ah,al                    ; pomˆr 5:3
         mov       si,offset Int08N84
         iret


; ------ ‡tvrt˜ vzorek (1. bajt a 2. bajt v pomˆru 4:4)

Int08N84:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       ah,al
         rcr       ah,1                     ; pomˆr 4:4
         mov       si,offset Int08N85
         iret


; ------ p t˜ vzorek (1. bajt a 2. bajt v pomˆru 3:5)

Int08N85:mov       al,ds:[bx+1]             ; 2. bajt dat
         mov       ah,0
         mov       cx,ax                    ; £schova 2. bajtu dat
         shl       ax,1                     ; 2. bajt * 2
         shl       ax,1                     ; 2. bajt * 4
         add       ax,cx                    ; 2. bajt * 5
         mov       cl,ds:[bx]               ; 1. bajt dat
         add       ax,cx                    ; pomˆr 1:5
         add       ax,cx                    ; pomˆr 2:5
         add       ax,cx                    ; pomˆr 3:5
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; sou‡et / 8
         mov       ah,al                    ; pomˆr 3:5
         mov       si,offset Int08N86
         iret


; ------ ¨est˜ vzorek (1. bajt a 2. bajt v pomˆru 2:6)

Int08N86:mov       ax,ds:[bx]               ; 1. a 2. bajt dat
         add       al,ah                    ; 1. bajt + 2. bajt dat
         rcr       al,1                     ; st©ed 1:1
         add       ah,al                    ; vˆt¨¡ v ha pro 2. bajt dat
         rcr       ah,1                     ; pomˆr 2:6
         mov       si,offset Int08N87
         iret


; ------ sedm˜ vzorek (1. bajt a 2. bajt v pomˆru 1:7)

Int08N87:mov       al,ds:[bx+1]             ; 2. bajt dat
         mov       ah,0
         mov       cx,ax                    ; £schova 2. bajtu dat
         shl       ax,1                     ; 2. bajt * 2
         add       ax,cx                    ; 2. bajt * 3
         shl       ax,1                     ; 2. bajt * 6
         add       ax,cx                    ; 2. bajt * 7
         add       al,ds:[bx]               ; p©i‡ten¡ 1. bajtu dat
         adc       ah,0                     ; p©enos
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       ah,al                    ; pomˆr 1:7
         mov       si,offset Int08N88
         iret


; ------ osm˜ vzorek (pouze 2. bajt)

Int08N88:mov       ah,ds:[bx+1]             ; 2. bajt dat
         mov       si,offset Int08N81

; ------ posun ukazatele dat

         inc       bl                       ; posun ukazatele
         jz        Int08N89                 ; konec bloku 256 bajt–
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int08N89:add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int08N8A                 ; byl ji‘ konec dat
         iret

Int08N8A:xor       bp,bp                    ; n vrat BP na 0
         iret

Int08N8  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Obsluha INT 08h s kompres¡ 4 bity
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        bez zmˆny frekvence
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int480   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tetr da

Int4801: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int4802                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int4803                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int4803


Int4802: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int4803                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int4803: add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48031:mov       ah,ch

         shr       ah,1

;         or        ah,ah
         jnz       KORIG1
         inc       ah

KORIG1:  cmp       ah,255
         jbe       Int4804
KORIG2:  mov       ah,255
         dec       ch
Int4804:
         mov       si,offset Int4805
         iret


; ------ druh˜ vzorek - ni‘¨¡ tetr da

Int4805: mov       al,ds:[bx]               ; bajt dat
         and       al,0fh

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int4806                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int4807                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int4807

Int4806: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int4807                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int4807: add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48075:mov       ah,ch

         shr       ah,1

;         or        ah,ah
         jnz       KORIG3
         inc       ah

KORIG3:  cmp       ah,255
         jbe       Int48072
KORIG4:  mov       ah,255
         dec       ch
Int48072:

; ------ zv˜¨en¡ ukazatele vzorku

         mov       si,offset Int4801
         inc       bl
         jz        Int4808
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int4808: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int4809                  ; byl ji‘ konec dat
         iret

Int4809: xor       bp,bp                    ; n vrat BP na 0
         iret

Int480   ENDP

; -----------------------------------------------------------------------------
;        s dˆlen¡m frekvence 1:2
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int48D2   PROC      NEAR

; ------ vzorek - ni‘¨¡ tetr da

         mov       al,ds:[bx]               ; bajt dat
         and       al,0fh

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int48D26                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48D27                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int48D27

Int48D26: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48D27                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int48D27: add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48D275:mov       ah,ch

         shr       ah,1

;         or        ah,ah
         jnz       KORIG3
         inc       ah

KORIG01: cmp       ah,255
         jbe       Int48D272
KORIG02: mov       ah,255
         dec       ch
Int48D272:

; ------ zv˜¨en¡ ukazatele vzorku

         inc       bl
         jz        Int48D28
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int48D28: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int48D29                  ; byl ji‘ konec dat
         iret

Int48D29: xor       bp,bp                    ; n vrat BP na 0
         iret

Int48D2   ENDP

; -----------------------------------------------------------------------------
;        n soben¡ frekvence 2:1
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int48N2   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tetr da

Int48N21:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int48N22                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N23                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int48N23


Int48N22:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N23                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int48N23:add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48N231:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG11
         inc       ah

KORIG11: cmp       ah,255
         jbe       Int48N24
KORIG12: mov       ah,255
         dec       ch
Int48N24:
         mov       si,offset Int48N241
         iret



; ------ druh˜ vzorek - vy¨¨¡ tetr da

Int48N241:mov      ah,ch

         shr       ah,1

         or        ah,ah
         jnz       KORIG13
         inc       ah

KORIG13: cmp       ah,255
         jbe       Int48N242
KORIG14: mov       ah,255
         dec       ch
Int48N242:
         mov       si,offset Int48N25
         iret



; ------ druh˜ vzorek - ni‘¨¡ tetr da

Int48N25:mov       al,ds:[bx]               ; bajt dat
         and       al,0fh

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int48N26                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N27                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int48N27

Int48N26: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N27                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int48N27: add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48N275:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG15
         inc       ah

KORIG15:  cmp       ah,255
         jbe       Int48N272
KORIG16:  mov       ah,255
         dec       ch
Int48N272:
         mov       si,offset Int48N277
         iret


; ----- t©et¡ vzorek - ni‘¨¡ tetr da

Int48N277:mov      ah,ch

         shr       ah,1

         or        ah,ah
         jnz       KORIG17
         inc       ah

KORIG17: cmp       ah,255
         jbe       Int48N278
KORIG18: mov       ah,255
         dec       ch
Int48N278:
         mov       si,offset Int48N21

; ------ zv˜¨en¡ ukazatele vzorku

         inc       bl
         jz        Int48N28
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int48N28: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int48N29                  ; byl ji‘ konec dat
         iret

Int48N29: xor       bp,bp                    ; n vrat BP na 0
         iret

Int48N2   ENDP

; -----------------------------------------------------------------------------
;        n soben¡ frekvence 4:1
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int48N4   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tetr da

Int48N41:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int48N42                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N43                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int48N43


Int48N42:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N43                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int48N43:add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48N431:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG21
         inc       ah

KORIG21: cmp       ah,255
         jbe       Int48N44
KORIG22: mov       ah,255
         dec       ch
Int48N44:
         mov       si,offset Int48N4412
         iret


; ------ mezivzorek

Int48N4412:mov      si,offset Int48N441
         iret


; ------ druh˜ vzorek - vy¨¨¡ tetr da

Int48N441:mov      ah,ch

         shr       ah,1

         or        ah,ah
         jnz       KORIG23
         inc       ah

KORIG23: cmp       ah,255
         jbe       Int48N442
KORIG24: mov       ah,255
         dec       ch
Int48N442:
         mov       si,offset Int48N450
         iret


; ------ mezivzorek

Int48N450:
         mov       si,offset Int48N45
         iret


; ------ druh˜ vzorek - ni‘¨¡ tetr da

Int48N45:mov       al,ds:[bx]               ; bajt dat
         and       al,0fh

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,8                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab41]
         jnz       Int48N46                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N47                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int48N47

Int48N46: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int48N47                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int48N47: add       cl,cs:[di+Tab42]         ; zv˜¨en¡ p©¡rustku dat

Int48N475:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG25
         inc       ah

KORIG25:  cmp       ah,255
         jbe       Int48N472
KORIG26:  mov       ah,255
         dec       ch
Int48N472:
         mov       si,offset Int48N4772
         iret

; ------ mezivzorek

Int48N4772:mov       si,offset Int48N477
         iret


; ----- t©et¡ vzorek - ni‘¨¡ tetr da

Int48N477:mov      ah,ch

         shr       ah,1

         or        ah,ah
         jnz       KORIG27
         inc       ah

KORIG27: cmp       ah,255
         jbe       Int48N478
KORIG28: mov       ah,255
         dec       ch
Int48N478:
         mov       si,offset Int48N4782
         iret


; ------ zv˜¨en¡ ukazatele vzorku

Int48N4782:

         mov       si,offset Int48N41
         inc       bl
         jz        Int48N48
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int48N48: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int48N49                  ; byl ji‘ konec dat
         iret

Int48N49: xor       bp,bp                    ; n vrat BP na 0
         iret

Int48N4   ENDP

; -----------------------------------------------------------------------------
;        tabulky
; -----------------------------------------------------------------------------

Tab41    db        0, 1, 2, 3, 4, 5, 6, 7,0, 1, 2, 3, 4, 5, 6, 7
         db        1, 3, 5, 7, 9,11,13,15,1, 3, 5, 7, 9,11,13,15
         db        2, 6,10,14,18,22,26,30,2, 6,10,14,18,22,26,30
         db        4,12,20,28,36,44,52,60,4,12,20,28,36,44,52,60

Tab42    db          0,0,0,0,0,16,16,16,  0,0,0,0,0,16,16,16
         db        -16,0,0,0,0,16,16,16,-16,0,0,0,0,16,16,16
         db        -16,0,0,0,0,16,16,16,-16,0,0,0,0,16,16,16
         db        -16,0,0,0,0, 0, 0, 0,-16,0,0,0,0, 0, 0, 0

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Obsluha INT 08h s kompres¡ 3 bity
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        bez zmˆny frekvence
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int380   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tri da

Int3801: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 3 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int3802                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3803                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int3803


Int3802: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3803                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int3803: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38031:mov       ah,ch

         shr       ah,1

         jnz       KORIG31
         inc       ah

KORIG31: cmp       ah,255
         jbe       Int3804
KORIG32: mov       ah,255
         dec       ch
Int3804:
         mov       si,offset Int3901
         iret


; ------ druh˜ vzorek - st©edn¡ tri da

Int3901: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int3902                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3903                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int3903


Int3902: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3903                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int3903: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int39031:mov       ah,ch

         shr       ah,1

         jnz       KORIG33
         inc       ah

KORIG33: cmp       ah,255
         jbe       Int3904
KORIG34: mov       ah,255
         dec       ch
Int3904:
         mov       si,offset Int3805
         iret



; ------ t©et¡ vzorek - ni‘¨¡ tri da

Int3805: mov       al,ds:[bx]               ; bajt dat
         shl       al,1
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int3806                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3807                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int3807

Int3806: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3807                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int3807: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38075:mov       ah,ch

         shr       ah,1

         jnz       KORIG35
         inc       ah

KORIG35:  cmp       ah,255
         jbe       Int38072
KORIG36:  mov       ah,255
         dec       ch
Int38072:

; ------ zv˜¨en¡ ukazatele vzorku

         mov       si,offset Int3801
         inc       bl
         jz        Int3808
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int3808: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int3809                  ; byl ji‘ konec dat
         iret

Int3809: xor       bp,bp                    ; n vrat BP na 0
         iret

Int380   ENDP

; -----------------------------------------------------------------------------
;        s dˆlen¡m frekvence 1:2
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int38D   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tri da

Int38D1: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 3 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38D2                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38D3                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38D3


Int38D2: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38D3                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38D3: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38D31:mov       ah,ch

         shr       ah,1

         jnz       KORIG41
         inc       ah

KORIG41: cmp       ah,255
         jbe       Int38D4
KORIG42: mov       ah,255
         dec       ch
Int38D4:
         mov       si,offset Int39D1
         iret


; ------ druh˜ vzorek - st©edn¡ tri da

Int39D1: mov       al,ds:[bx+1]             ; bajt dat
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int39D2                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int39D3                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int39D3


Int39D2: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int39D3                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int39D3: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int39D31:mov       ah,ch

         shr       ah,1

         jnz       KORIG43
         inc       ah

KORIG43: cmp       ah,255
         jbe       Int39D4
KORIG44: mov       ah,255
         dec       ch
Int39D4:
         mov       si,offset Int38D5
         iret



; ------ t©et¡ vzorek - ni‘¨¡ tri da

Int38D5: mov       al,ds:[bx+1]             ; bajt dat
         shl       al,1
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38D6                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38D7                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38D7

Int38D6: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38D7                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38D7: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38D75:mov       ah,ch

         shr       ah,1

         jnz       KORIG45
         inc       ah

KORIG45:  cmp       ah,255
         jbe       Int38D72
KORIG46:  mov       ah,255
         dec       ch
Int38D72:

; ------ zv˜¨en¡ ukazatele vzorku

         mov       si,offset Int38D1
         add       bl,2
         jc        Int38D8
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int38D8: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int38D9                  ; byl ji‘ konec dat
         iret

Int38D9: xor       bp,bp                    ; n vrat BP na 0
         iret

Int38D   ENDP

; -----------------------------------------------------------------------------
;        n soben¡ frekvence 2:1
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int38N2   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tri da

Int38N21:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38N22                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N23                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38N23


Int38N22:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N23                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38N23:add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38N231:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG51
         inc       ah

KORIG51: cmp       ah,255
         jbe       Int38N24
KORIG52: mov       ah,255
         dec       ch
Int38N24:
         mov       si,offset Int38N241
         iret


; ------ druh˜ vzorek - vy¨¨¡ tri da

Int38N241:mov      ah,ch

         shr       ah,1

         jnz       KORIG53
         inc       ah

KORIG53: cmp       ah,255
         jbe       Int38N242
KORIG54: mov       ah,255
         dec       ch
Int38N242:
         mov       si,offset Int39N21
         iret



; ------ t©et¡ vzorek - st©edn¡ tri da

Int39N21:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int39N22                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int39N23                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int39N23


Int39N22:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int39N23                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int39N23:add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int39N231:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG55
         inc       ah

KORIG55: cmp       ah,255
         jbe       Int39N24
KORIG56: mov       ah,255
         dec       ch
Int39N24:
         mov       si,offset Int39N241
         iret


; ------ ‡tvrt˜ vzorek - st©edn¡ tetr da

Int39N241:mov      ah,ch

         shr       ah,1

         jnz       KORIG57
         inc       ah

KORIG57: cmp       ah,255
         jbe       Int39N242
KORIG58: mov       ah,255
         dec       ch
Int39N242:
         mov       si,offset Int38N25
         iret


; ------ p t˜ vzorek - ni‘¨¡ tri da

Int38N25:mov       al,ds:[bx]               ; bajt dat
         shl       al,1
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38N26                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N27                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38N27

Int38N26: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N27                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38N27: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38N275:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG59
         inc       ah

KORIG59:  cmp       ah,255
         jbe       Int38N272
KORIG5a:  mov       ah,255
         dec       ch
Int38N272:
         mov       si,offset Int38N277
         iret


; ----- ¨est˜ vzorek - ni‘¨¡ tetr da

Int38N277:mov      ah,ch

         shr       ah,1

         jnz       KORIG5b
         inc       ah

KORIG5b: cmp       ah,255
         jbe       Int38N278
KORIG5c: mov       ah,255
         dec       ch
Int38N278:
         mov       si,offset Int38N21

; ------ zv˜¨en¡ ukazatele vzorku

         inc       bl
         jz        Int38N28
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int38N28: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int38N29                  ; byl ji‘ konec dat
         iret

Int38N29: xor       bp,bp                    ; n vrat BP na 0
         iret

Int38N2   ENDP

; -----------------------------------------------------------------------------
;        n soben¡ frekvence 4:1
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int38N4   PROC      NEAR

; ------ prvn¡ vzorek - vy¨¨¡ tri da

Int38N41:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38N42                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N43                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38N43


Int38N42:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N43                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38N43:add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38N431:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG61
         inc       ah

KORIG61: cmp       ah,255
         jbe       Int38N44
KORIG62: mov       ah,255
         dec       ch
Int38N44:
         mov       si,offset Int38N4412
         iret


Int38N4412:mov     si,offset Int38N441
         iret


; ------ druh˜ vzorek - vy¨¨¡ tri da

Int38N441:mov      ah,ch

         shr       ah,1

         or        ah,ah
         jnz       KORIG63
         inc       ah

KORIG63: cmp       ah,255
         jbe       Int38N442
KORIG64: mov       ah,255
         dec       ch
Int38N442:
         mov       si,offset Int39N212
         iret

Int39N212:
         mov       si,offset Int3aN21
         iret


; ------ t©et¡ vzorek - st©edn¡ tri da

Int3aN21:mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 4 bity dat
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int3aN22                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3aN232                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int3aN232


Int3aN22:sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int3aN232                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int3aN232:add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int3aN231:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG65
         inc       ah

KORIG65: cmp       ah,255
         jbe       Int3aN24
KORIG66: mov       ah,255
         dec       ch
Int3aN24:
         mov       si,offset Int3aN2412
         iret

Int3aN2412:
         mov       si,offset Int3aN241
         iret



; ------ ‡tvrt˜ vzorek - st©edn¡ tetr da

Int3aN241:mov      ah,ch

         shr       ah,1

         jnz       KORIG67
         inc       ah

KORIG67: cmp       ah,255
         jbe       Int3aN242
KORIG68: mov       ah,255
         dec       ch
Int3aN242:
         mov       si,offset Int38N452
         iret


Int38N452:
         mov       si,offset Int38N45
         iret



; ------ p t˜ vzorek - ni‘¨¡ tri da

Int38N45:mov       al,ds:[bx]               ; bajt dat
         shl       al,1
         and       al,7

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,4                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab31]
         jnz       Int38N46                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N47                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int38N47

Int38N46: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int38N47                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int38N47: add       cl,cs:[di+Tab32]         ; zv˜¨en¡ p©¡rustku dat

Int38N475:mov      al,ch
         shr       al,1

         add      ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG69
         inc       ah

KORIG69:  cmp       ah,255
         jbe       Int38N472
KORIG6a:  mov       ah,255
         dec       ch
Int38N472:
         mov       si,offset Int38N4772
         iret


Int38N4772:
         mov       si,offset Int38N477
         iret



; ----- ¨est˜ vzorek - ni‘¨¡ tetr da

Int38N477:mov      ah,ch

         shr       ah,1

         jnz       KORIG6b
         inc       ah

KORIG6b: cmp       ah,255
         jbe       Int38N478
KORIG6c: mov       ah,255
         dec       ch
Int38N478:
         mov       si,offset Int38N482
         iret


Int38N482:
         mov       si,offset Int38N41

; ------ zv˜¨en¡ ukazatele vzorku

         inc       bl
         jz        Int38N48
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int38N48: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int38N49                  ; byl ji‘ konec dat
         iret

Int38N49: xor       bp,bp                    ; n vrat BP na 0
         iret

Int38N4   ENDP

; -----------------------------------------------------------------------------
;        tabulky
; -----------------------------------------------------------------------------

Tab31    db        0,1,2,3,0,1,2,3
         db        1,3,5,7,1,3,5,7
         db        2,6,10,14,2,6,10,14
         db        4,12,20,28,4,12,20,28
         db        5,15,25,35,5,15,25,35

Tab32    db        0,0,0,8,0,0,0,8
         db        -8,0,0,8,-8,0,0,8
         db        -8,0,0,8,-8,0,0,8
         db        -8,0,0,8,-8,0,0,8
         db        -8,0,0,0,-8,0,0,0


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                    Obsluha INT 08h s kompres¡ 2 bity
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        bez zmˆny frekvence
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int280   PROC      NEAR

; ------ prvn¡ vzorek - nejvy¨¨¡ 2 bity

Int2801: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 3 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int2802                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2803                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int2803


Int2802: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2803                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int2803: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int28031:mov       ah,ch

         shr       ah,1

         jnz       KORIG71
         inc       ah

KORIG71: cmp       ah,255
         jbe       Int2804
KORIG72: mov       ah,255
         dec       ch
Int2804:
         mov       si,offset Int2901
         iret


; ------ druh˜ vzorek

Int2901: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int2902                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2903                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int2903


Int2902: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2903                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int2903: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int29031:mov       ah,ch

         shr       ah,1

         jnz       KORIG73
         inc       ah

KORIG73: cmp       ah,255
         jbe       Int2904
KORIG74: mov       ah,255
         dec       ch
Int2904:
         mov       si,offset Int2a01
         iret



; ------ t©et¡ vzorek

Int2a01: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int2a02                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2a03                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int2a03


Int2a02: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2a03                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int2a03: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int2a031:mov       ah,ch

         shr       ah,1

         jnz       KORIG75
         inc       ah

KORIG75: cmp       ah,255
         jbe       Int2a04
KORIG76: mov       ah,255
         dec       ch
Int2a04:
         mov       si,offset Int2805
         iret


; ------ ‡tvrt˜ vzorek

Int2805: mov       al,ds:[bx]               ; bajt dat
         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int2806                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2807                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int2807

Int2806: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2807                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int2807: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int28075:mov       ah,ch

         shr       ah,1

         jnz       KORIG77
         inc       ah

KORIG77:  cmp       ah,255
         jbe       Int28072
KORIG78:  mov       ah,255
         dec       ch
Int28072:

; ------ zv˜¨en¡ ukazatele vzorku

         mov       si,offset Int2801
         inc       bl
         jz        Int2808
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int2808: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int2809                  ; byl ji‘ konec dat
         iret

Int2809: xor       bp,bp                    ; n vrat BP na 0
         iret

Int280   ENDP

; -----------------------------------------------------------------------------
;        n soben¡ frekvence 2:1
; -----------------------------------------------------------------------------
; VSTUP: CH=aktu ln¡ hodnota dat
;        CL=aktu ln¡ inkrement dat
; -----------------------------------------------------------------------------

Int28N   PROC      NEAR

; ------ prvn¡ vzorek - nejvy¨¨¡ 2 bity

Int28N1: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; nejvy¨¨¡ 3 bity dat

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int28N2                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int28N3                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int28N3

Int28N2: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int28N3                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int28N3: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int28N31:mov       al,ch
         shr       al,1

         add       ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG81
         inc       ah

KORIG81: cmp       ah,255
         jbe       Int28N4
KORIG82: mov       ah,255
         dec       ch
Int28N4:
         mov       si,offset Int29M1
         iret


; ------ prvn¡ vzorek znovu

Int29M1: mov       ah,ch
         shr       ah,1
         jnz       KORIG83
         inc       ah

KORIG83: cmp       ah,255
         jbe       Int28M4
KORIG84: mov       ah,255
         dec       ch
Int28M4:
         mov       si,offset Int29N1
         iret


; ------ druh˜ vzorek

Int29N1: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int29N2                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int29N3                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int29N3


Int29N2: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int29N3                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int29N3: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int29N31:
         mov       al,ch
         shr       al,1

         add       ah,al
         rcr       ah,1

         or        ah,ah

         jnz       KORIG85
         inc       ah

KORIG85: cmp       ah,255
         jbe       Int29N4
KORIG86: mov       ah,255
         dec       ch
Int29N4:
         mov       si,offset Int2aM1
         iret


; ------ druh˜ vzorek znovu

Int2aM1:
         mov       ah,ch
         shr       ah,1

         jnz       KORIG87
         inc       ah

KORIG87: cmp       ah,255
         jbe       Int29m4
KORIG88: mov       ah,255
         dec       ch
Int29m4:
         mov       si,offset Int2aN1
         iret


; ------ t©et¡ vzorek

Int2aN1: mov       al,ds:[bx]               ; bajt dat
         shr       al,1
         shr       al,1                     ; st©edn¡ 3 bity dat

         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh                  ; offset v tabulk ch

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int2aN2                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2aN3                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int2aN3


Int2aN2: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int2aN3                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int2aN3: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int2aN31:
         mov       al,ch
         shr       al,1

         add       ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG89
         inc       ah

KORIG89: cmp       ah,255
         jbe       Int2aN4
KORIG8A: mov       ah,255
         dec       ch
Int2aN4:
         mov       si,offset Int2aM31
         iret


; ------ t©et¡ vzorek znovu

Int2aM31:mov       ah,ch
         shr       ah,1

         jnz       KORIG8b
         inc       ah

KORIG8b: cmp       ah,255
         jbe       Int2aM4
KORIG8c: mov       ah,255
         dec       ch
Int2aM4:
         mov       si,offset Int28N5
         iret


; ------ ‡tvrt˜ vzorek

Int28N5: mov       al,ds:[bx]               ; bajt dat
         and       al,3

         add       al,cl                    ; p©i‡ten¡ inkrementu
         mov       di,ax
         and       di,0ffh

         test      al,2                     ; bude z porn‚ ‡¡slo ?
         mov       al,cs:[di+Tab21]
         jnz       Int28N6                  ; bude z porn‚ ‡¡slo
         add       ch,al                    ; zv˜¨en¡ dat
         jnc       Int28N7                  ; nen¡ p©ete‡en¡
         mov       ch,255                   ; omezen¡ dat
         jmp       short Int28N7

Int28N6: sub       ch,al                    ; zv˜¨en¡ dat
         jnc       Int28N7                  ; nen¡ p©ete‡en¡
         mov       ch,0                     ; omezen¡ dat

Int28N7: add       cl,cs:[di+Tab22]         ; zv˜¨en¡ p©¡rustku dat

Int28N75:
         mov       al,ch
         shr       al,1

         add       ah,al
         rcr       ah,1

         or        ah,ah
         jnz       KORIG8d
         inc       ah

KORIG8d:  cmp       ah,255
         jbe       Int28N72
KORIG8e:  mov       ah,255
         dec       ch
Int28N72:
         mov       si,offset Int28m75
         iret


; ------ ‡tvrt˜ vzorek znovu

Int28M75:mov       ah,ch
         shr       ah,1

         jnz       KORIG8f
         inc       ah

KORIG8f:  cmp       ah,255
         jbe       Int28M72
KORIG8g:  mov       ah,255
         dec       ch
Int28M72:

; ------ zv˜¨en¡ ukazatele vzorku

         mov       si,offset Int28N1

         inc       bl
         jz        Int28N8
         iret

; ------ zv˜¨en¡ adresy na dal¨¡ blok 256 bajt–

Int28N8: mov       di,ds
         add       di,16                    ; zv˜¨en¡ segmentu dat
         mov       ds,di                    ; nov˜ segment ukazatele dat
         dec       bp                       ; ‡¡ta‡ dat
         js        Int28N9                  ; byl ji‘ konec dat
         iret

Int28N9: xor       bp,bp                    ; n vrat BP na 0
         iret

Int28N   ENDP

; -----------------------------------------------------------------------------
;        tabulky
; -----------------------------------------------------------------------------

Tab21    db        0,1,0,1
         db        1,3,1,3
         db        2,6,2,6
         db        4,12,4,12
         db        8,24,8,24
         db        16,48,16,48

Tab22    db        0,4,0,4
         db        -4,4,-4,4
         db        -4,4,-4,4
         db        -4,4,-4,4
         db        -4,4,-4,4
         db        -4,0,-4,0

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Obsluha souboru, inicializace
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        inicializace port–
; -----------------------------------------------------------------------------

InitPort PROC      NEAR

; ------ vypnut¡ motor– disketov˜ch mechanik

         mov       dx,3f2h
         mov       al,0ch
         out       dx,al                    ; vypnut¡ motor– mechanik
         xor       ax,ax
         mov       es,ax
         and       byte ptr es:[43fh],not 11111b ; motory

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h
         mov       word ptr ds:[old08],bx
         mov       word ptr ds:[old08+2],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h
         mov       word ptr ds:[old09],bx
         mov       word ptr ds:[old09+2],es

; ------ £schova masky p©eru¨en¡

         in        al,[21h]
         mov       ds:[Old21],al

; ------ instalace obsluhy INT 08h

         cli
         mov       dx,offset Int08          ; adresa obsluhy INT 08h
         mov       ax,2508h
         int       21h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09
         mov       ax,2509h
         int       21h

; ------ inicializace masky p©eru¨en¡

         mov       al,not 3
         out       [21h],al

; ------ inicializace port–

         mov       al,36h
         out       [43h],al
         mov       al,ds:[Konst08]          ; dˆlic¡ konstanta hodin
         out       [40h],al
         mov       al,0
         out       [40h],al
         mov       al,92h
         out       [43h],al
         in        al,[61h]
         and       al,not 3
         cmp       byte ptr ds:[OutCan],0   ; je v˜stup na reproduktor ?
         jne       InitPrt2                 ; nen¡ v˜stup na reproduktor
         or        al,2
InitPrt2:out       [61h],al
         or        al,1
         mov       byte ptr ds:[PORT61+1],al

         mov       al,50h
         out       [43h],al

; ------ inicializace registr–

         mov       bp,ds:[DatNum]           ; po‡et odstavc– v pamˆti
         shr       bp,1
         shr       bp,1
         shr       bp,1
         shr       bp,1                     ; po‡et blok– 256 bajt–
         mov       si,ds:[Adr08]            ; adresa obsluhy INT 08h
         mov       dx,ds:[AdrPort]          ; adresa v˜stupn¡ho portu
         mov       di,ds:[DatSeg]           ; adresa bloku dat
         mov       ds,di                    ; adresa bloku dat
         mov       bx,34                    ; ukazatel dat v bloku 256 bajt–
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ p©eru¨en¡
;         mov       cx,8000h
         xor       cx,cx
         ret

InitPort ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ port–
; -----------------------------------------------------------------------------

DIniPort PROC      NEAR

         mov       al,0ffh
         out       [21h],al                 ; p©echodn˜ z kaz p©eru¨en¡

         mov       al,54h
         out       [43h],al
         mov       al,12h
         out       [41h],al
         mov       al,36h
         out       [43h],al
         mov       al,0
         out       [40h],al
         out       [40h],al
         mov       al,0b6h
         out       [43h],al
         mov       ax,533h
         out       [42h],al
         mov       al,ah
         out       [42h],al

         in        al,[61h]
         and       al,not 3
         out       [61h],al

         mov       al,20h
         out       [20h],al

         push      cs
         pop       ds
         lds       dx,ds:[Old08]
         mov       ax,2508h
         int       21h

         push      cs
         pop       ds
         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h

         push      cs
         pop       ds

         mov       al,ds:[old21]
         out       [21h],al                 ; n vrat masky p©eru¨en¡
         sti

; ------ ‡ten¡ hodin syst‚mov‚ho ‡asu (AT)

         mov       dl,8ah                   ; p©ednastaven¡ na nesmysl
         mov       ah,2
         int       1ah                      ; ‡ten¡ hodin
         cmp       dl,1                     ; p©ete‡en¡ p©es p–lnoc ?
         ja        Deinit3                  ; hodiny neplat¡

; ------ n vrat p©¡znaku p©ete‡en¡ p©es p–lnoc

         jne       DeInit2                  ; nen¡ p©ete‡en¡ p©es p–lnoc
         xor       ax,ax
         mov       es,ax
         mov       byte ptr es:[470h],dl    ; n vrat p©¡znaku p©ete‡en¡ p–lnoci

; ------ konverze z BCD form tu na bin rn¡

DeInit2: mov       al,ch                    ; hodina
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       ch,al
         mov       al,cl                    ; minuta
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       cl,al
         mov       al,dh                    ; sekunda
         call      BcdBin                   ; konverze na bin rn¡ tvar
         mov       dh,al

; ------ nastaven¡ ‡asu

         xor       dl,dl                    ; setina sekundy
         mov       ah,2dh
         int       21h                      ; nastaven¡ syst‚mov‚ho ‡asu

DeInit3:
         push      cs
         pop       ds
         ret

DIniPort ENDP

; -----------------------------------------------------------------------------
;        Konverze ‡¡sla z BCD tvaru na bin rn¡
; -----------------------------------------------------------------------------

BcdBin   PROC      NEAR

         push      cx
         mov       ch,al
         and       ch,0fh
         and       al,0f0h
         mov       cl,4
         shr       al,cl
         mov       cl,10
         mul       cl
         add       al,ch
         pop       cx
         ret

BcdBin   ENDP

; -----------------------------------------------------------------------------
;        inicializace parametr–
; -----------------------------------------------------------------------------

InitPar  PROC      NEAR

; ------ rozli¨en¡ typu komprese

         mov       al,ds:[Kompres]
         mov       si,offset TabInt08-8     ; nen¡ komprese
         cmp       al,0
         je        InitPar1
         mov       si,offset TabInt48-8     ; komprese 4 bity
         cmp       al,1
         je        InitPar1
         mov       si,offset TabInt38-8     ; komprese 3 bity
         cmp       al,2
         je        InitPar1
         mov       si,offset TabInt28-8     ; komprese 2 bity

; ------ nalezen¡ po‘adovan‚ frekvence v tabulce

InitPar1:mov       ax,ds:[SampRate]         ; frekvence vzorku
InitPar2:add       si,8                     ; zv˜¨en¡ ukazatele v tabulce
         cmp       ax,ds:[si+8]             ; n sleduj¡c¡ frekvence
         jae       InitPar2                 ; frekvence nenalezena

; ------ parametry pro obsluhu

         mov       bx,ds:[si+4]             ; n sobitel frekvence
         mul       bx                       ; vyn soben¡ frekvence
         mov       bx,ds:[si+6]             ; dˆlitel frekvence
         div       bx                       ; vydˆlen¡ frekvence
         mov       bx,ds:[si+2]             ; adresa obsluhy
         mov       ds:[Adr08],bx            ; adresa obsluhy

; ------ stanoven¡ dˆlic¡ konstanty hodin (44 a‘ 66)

         xchg      ax,cx                    ; CX <- po‘adovan  frekvence
         mov       dx,18
         mov       ax,13534                 ; frekvence 1193182 Hz
         div       cx                       ; v˜po‡et dˆlic¡ konstanty hodin
         mov       ds:[Konst08],al          ; dˆlic¡ konstanta

         dec       ax
         mov       byte ptr ds:[KORIG1+2],al
         mov       byte ptr ds:[KORIG2+1],al
         mov       byte ptr ds:[KORIG3+2],al
         mov       byte ptr ds:[KORIG4+1],al

         mov       byte ptr ds:[KORIG01+2],al
         mov       byte ptr ds:[KORIG02+1],al

         mov       byte ptr ds:[KORIG11+2],al
         mov       byte ptr ds:[KORIG12+1],al
         mov       byte ptr ds:[KORIG13+2],al
         mov       byte ptr ds:[KORIG14+1],al
         mov       byte ptr ds:[KORIG15+2],al
         mov       byte ptr ds:[KORIG16+1],al
         mov       byte ptr ds:[KORIG17+2],al
         mov       byte ptr ds:[KORIG18+1],al

         mov       byte ptr ds:[KORIG21+2],al
         mov       byte ptr ds:[KORIG22+1],al
         mov       byte ptr ds:[KORIG23+2],al
         mov       byte ptr ds:[KORIG24+1],al
         mov       byte ptr ds:[KORIG25+2],al
         mov       byte ptr ds:[KORIG26+1],al
         mov       byte ptr ds:[KORIG27+2],al
         mov       byte ptr ds:[KORIG28+1],al

         mov       byte ptr ds:[KORIG31+2],al
         mov       byte ptr ds:[KORIG32+1],al
         mov       byte ptr ds:[KORIG33+2],al
         mov       byte ptr ds:[KORIG34+1],al
         mov       byte ptr ds:[KORIG35+2],al
         mov       byte ptr ds:[KORIG36+1],al

         mov       byte ptr ds:[KORIG41+2],al
         mov       byte ptr ds:[KORIG42+1],al
         mov       byte ptr ds:[KORIG43+2],al
         mov       byte ptr ds:[KORIG44+1],al
         mov       byte ptr ds:[KORIG45+2],al
         mov       byte ptr ds:[KORIG46+1],al

         mov       byte ptr ds:[KORIG51+2],al
         mov       byte ptr ds:[KORIG52+1],al
         mov       byte ptr ds:[KORIG53+2],al
         mov       byte ptr ds:[KORIG54+1],al
         mov       byte ptr ds:[KORIG55+2],al
         mov       byte ptr ds:[KORIG56+1],al
         mov       byte ptr ds:[KORIG57+2],al
         mov       byte ptr ds:[KORIG58+1],al
         mov       byte ptr ds:[KORIG59+2],al
         mov       byte ptr ds:[KORIG5a+1],al
         mov       byte ptr ds:[KORIG5b+2],al
         mov       byte ptr ds:[KORIG5c+1],al

         mov       byte ptr ds:[KORIG61+2],al
         mov       byte ptr ds:[KORIG62+1],al
         mov       byte ptr ds:[KORIG63+2],al
         mov       byte ptr ds:[KORIG64+1],al
         mov       byte ptr ds:[KORIG65+2],al
         mov       byte ptr ds:[KORIG66+1],al
         mov       byte ptr ds:[KORIG67+2],al
         mov       byte ptr ds:[KORIG68+1],al
         mov       byte ptr ds:[KORIG69+2],al
         mov       byte ptr ds:[KORIG6a+1],al
         mov       byte ptr ds:[KORIG6b+2],al
         mov       byte ptr ds:[KORIG6c+1],al

         mov       byte ptr ds:[KORIG71+2],al
         mov       byte ptr ds:[KORIG72+1],al
         mov       byte ptr ds:[KORIG73+2],al
         mov       byte ptr ds:[KORIG74+1],al
         mov       byte ptr ds:[KORIG75+2],al
         mov       byte ptr ds:[KORIG76+1],al
         mov       byte ptr ds:[KORIG77+2],al
         mov       byte ptr ds:[KORIG78+1],al

         mov       byte ptr ds:[KORIG81+2],al
         mov       byte ptr ds:[KORIG82+1],al
         mov       byte ptr ds:[KORIG83+2],al
         mov       byte ptr ds:[KORIG84+1],al
         mov       byte ptr ds:[KORIG85+2],al
         mov       byte ptr ds:[KORIG86+1],al
         mov       byte ptr ds:[KORIG87+2],al
         mov       byte ptr ds:[KORIG88+1],al
         mov       byte ptr ds:[KORIG89+2],al
         mov       byte ptr ds:[KORIG8a+1],al
         mov       byte ptr ds:[KORIG8b+2],al
         mov       byte ptr ds:[KORIG8c+1],al
         mov       byte ptr ds:[KORIG8d+2],al
         mov       byte ptr ds:[KORIG8e+1],al
         mov       byte ptr ds:[KORIG8f+2],al
         mov       byte ptr ds:[KORIG8g+1],al

         ret

InitPar  ENDP

; -----------------------------------------------------------------------------
;        korekce nulov‚ hladiny dat pro v˜stup na port LPT
; -----------------------------------------------------------------------------

KorNul   PROC      NEAR

; ------ p©¡prava registr–

         mov       bp,ds:[DatNum]           ; po‡et odstavc– dat v bufferu
         mov       dx,ds:[DatSeg]           ; adresa datov‚ho bufferu
         mov       bl,ds:[NulLev]           ; nulov  hladina vzorku
         mov       bh,ds:[SampVol]          ; zv˜¨en¡ hlasitosti vzorku
         cld

; ------ velikost jednoho bloku dat

         push      ds

KorNul1: mov       cx,0ff0h
         cmp       cx,bp                    ; zb˜v  m‚nˆ dat ?
         jb        KorNul2                  ; po‡et dat OK
         mov       cx,bp                    ; omezen¡ velikosti bloku dat
KorNul2: sub       bp,cx                    ; sn¡‘en¡ ‡¡ta‡e dat
         mov       es,dx                    ; adresa bloku dat
         mov       ds,dx
         add       dx,cx                    ; posun adresy dat
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©epo‡et na bajty
         jcxz      KorNul7                  ; nejsou dal¨¡ data

; ------ korekce bloku dat

         xor       si,si                    ; ukazatel dat
         xor       di,di
KorNul3: lodsb                              ; vzorek dat
         sub       al,bl                    ; posun na nulu
         imul      bh                       ; zv˜¨en¡ hlasitosti vzorku
         add       ax,80h                   ; n vrat na nulovou hladinu
         jns       KorNul4
         xor       ax,ax                    ; omezen¡ zdola
KorNul4: or        ah,ah
         jz        KorNul5
         mov       al,255                   ; omezen¡ shora
KorNul5: stosb                              ; ulo‘en¡ vzorku
         loop      KorNul3                  ; dal¨¡ bajt dat
         jmp       short KorNul1            ; korekce dal¨¡ho bloku dat

KorNul7: pop       ds
         ret

KorNul   ENDP

; -----------------------------------------------------------------------------
;        korekce hlasitosti pro reproduktor
; -----------------------------------------------------------------------------

KorVol   PROC      NEAR
;þ
; ------ p©¡prava registr–

         mov       bp,ds:[DatNum]           ; po‡et odstavc– dat v bufferu
         mov       es,ds:[DatSeg]           ; adresa datov‚ho bufferu
         mov       bh,ds:[NulLev]           ; nulov  hladina vzorku
         mov       bl,ds:[SampVol]          ; zv˜¨en¡ hlasitosti vzorku

         mov       dl,ds:[Konst08]          ; korek‡n¡ konstanta hlasitosti

; ------ velikost jednoho bloku dat

         push      ds

KorVol1: mov       cx,0f00h
         cmp       cx,bp                    ; zb˜v  m‚nˆ dat ?
         jb        KorVol2                  ; po‡et dat OK
         mov       cx,bp                    ; omezen¡ velikosti bloku dat
KorVol2: sub       bp,cx                    ; sn¡‘en¡ ‡¡ta‡e dat
         push      es
         pop       ds                       ; DS <- ES
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©epo‡et na bajty
         jcxz      KorVol7                  ; nejsou dal¨¡ data

; ------ korekce bloku dat

         xor       si,si                    ; ukazatel dat
         xor       di,di

KorVol3: lodsb                              ; datov˜ bajt
         sub       al,bh                    ; posun hladiny na 0
         imul      bl                       ; zv˜¨en¡ hlasitosti vzorku
         add       ax,80h                   ; posun na po‘adovanou hladinu
         jns       KorVol4
         xor       ax,ax                    ; omezen¡ zdola
KorVol4: or        ah,ah
         jz        KorVol5
         mov       al,255                   ; omezen¡ shora
KorVol5: mul       dl                       ; korekce na v˜stupn¡ hlasitost
         mov       al,ah                    ; v˜stupn¡ hodnota
         inc       ax                       ; ochrana p©ed nulou

         stosb                              ; korigovan  hodnota
         loop      KorVol3                  ; dal¨¡ bajt dat

         mov       ax,es
         add       ax,0f00h
         mov       es,ax

         jmp       short KorVol1            ; korekce dal¨¡ho bloku dat

KorVol7: pop       ds
         ret

KorVol   ENDP

; -----------------------------------------------------------------------------
;        detekce parametr– souboru
; -----------------------------------------------------------------------------

DetFile  PROC      NEAR

; ------ test, zda je to soubor VOC

         mov       es,ds:[DatSeg]           ; datov˜ segment
         mov       si,offset TextVOC        ; identifika‡n¡ text VOC
         xor       di,di
         mov       cx,offset(TextVOC1-TextVOC) ; d‚lka textu
         cld
         repe      cmpsb                    ; porovn n¡ identifikace
         jne       DetFile2                 ; nen¡ to soubor VOC
         mov       byte ptr ds:[TypFile],1  ; typ souboru RAW SOUND
         cmp       word ptr es:[1ah],408h   ; je SOUND BLASTER PRO ?
         jne       DetFil11                 ; nen¡ - je RAW SOUND
         mov       byte ptr ds:[TypFile],2  ; p©¡znak souboru SOUND BLASTER PRO
         cmp       byte ptr es:[21h],1      ; je STEREO ?
         jne       DetFil11                 ; nen¡ STEREO
         mov       byte ptr ds:[Stereo],2   ; p©¡znak form tu STEREO

; ------ detekce vzorkovac¡ho kmito‡tu souboru VOC

DetFil11:mov       al,es:[1fh]              ; dˆlic¡ konstanta pro SB PRO
         cmp       word ptr es:[1ah],408h   ; je SOUND BLASTER PRO ?
         je        DetFile1
         mov       al,es:[1fh]              ; typ komprese souboru
         cmp       al,3
         ja        DetFil13                 ; nezn m˜ typ komprese
         mov       ds:[Kompres],al          ; typ komprese souboru
DetFil13:mov       al,es:[1eh]              ; dˆlic¡ konstanta pro RAW SOUND

DetFile1:mov       ah,0
         sub       ax,100h                  ; opraven  konstanta
         neg       ax                       ; oprava polarity
         cmp       ax,15                    ; minim ln¡ hodnota
         ja        DetFil12                 ; konstanta je OK
         mov       al,16                    ; minim ln¡ konstanta
DetFil12:xchg      ax,bx                    ; BX <- dˆlic¡ konstanta
         mov       ax,4240h
         mov       dx,0fh                   ; ‡¡slo 1000000
         div       bx                       ; v˜po‡et frekvence

         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil61                 ; vzorkovac¡ kmito‡et zad n

         mov       ds:[SampRate],ax         ; vzorkovac¡ kmito‡et
DetFil61:jmp       DetFile6

; ------ test, zda je to soubor WAV

DetFile2:mov       si,offset TextWAV        ; identifika‡n¡ text WAV
         xor       di,di
         mov       cx,offset(TextWAV1-TextWAV) ; d‚lka textu
         cld
         repe      cmpsb                    ; porovn n¡ identifikace
         jne       DetFile3                 ; nen¡ to soubor WAVE
         mov       cl,offset(TextWAV2-TextWAV1) ; d‚lka druh‚ ‡ sti textu
         mov       di,8                     ; za‡ tek druh‚ ‡ sti identifikace
         repe      cmpsb                    ; kontrola druh‚ identifikace
         jne       DetFile3                 ; nen¡ soubor WAVE
         mov       byte ptr ds:[TypFile],3  ; p©¡znak souboru WAVE
         mov       al,es:[16h]              ; po‡et kan l–
         mov       ds:[Stereo],al           ; po‡et kan l–

; ------ detekce vzorkovac¡ho kmito‡tu souboru WAV

         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil60                 ; vzorkovac¡ kmito‡et zad n
         mov       ax,es:[1ch]              ; vzorkovac¡ kmito‡et pro WAV MONO
         cmp       ax,2250                  ; minim ln¡ kmito‡et
         jae       DetFil22                 ; kmito‡et OK
         mov       ax,2250                  ; omezen¡ zdola
DetFil22:cmp       ax,65500                 ; maxim ln¡ kmito‡et
         jbe       DetFil23                 ; kmito‡et OK
         mov       ax,65500                 ; omezen¡ shora
DetFil23:mov       ds:[SampRate],ax         ; vzorkovac¡ kmito‡et
         jmp       short DetFil61

; ------ test, zda je soubor STEVE SOUND

DetFile3:mov       si,offset TextSTEV       ; identifika‡n¡ text STEVE
         xor       di,di
         mov       cx,offset(TextSTV2-TextSTEV) ; d‚lka textu
         cld
         repe      cmpsb                    ; porovn n¡ identifikace
         jne       DetFil32                 ; nen¡ to soubor STEVE SOUND
         cmp       byte ptr es:[6],"H"
         jne       DetFil32
         mov       byte ptr ds:[TypFile],8  ; p©¡znak souboru STEVE SOUND
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil60                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],8000 ; vzorkovac¡ kmito‡et pro STEVE
         jmp       short DetFil60

; ------ test, zda je soubor SAM

DetFil32:cmp       word ptr ds:[SoubExt],"AS"
         jne       DetFile4
         cmp       byte ptr ds:[SoubExt+2],"M"
         jne       DetFile4
         mov       byte ptr ds:[TypFile],4  ; p©¡znak souboru SAMPLER
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil60                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],16500 ; vzorkovac¡ kmito‡et pro SAM
DetFil60:jmp       DetFile6

; ------ test, zda je soubor NTI

DetFile4:cmp       word ptr ds:[SoubExt],"TN"
         jne       DetFile5
         cmp       byte ptr ds:[SoubExt+2],"I"
         jne       DetFile5
         mov       byte ptr ds:[TypFile],5  ; p©¡znak souboru NTI
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil60                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],8600 ; vzorkovac¡ kmito‡et pro NTI
         jmp       short DetFil60

; ------ test, zda je soubor SND

DetFile5:cmp       word ptr ds:[SoubExt],"NS"
         jne       DetFil51
         cmp       byte ptr ds:[SoubExt+2],"D"
         jne       DetFil51
         mov       byte ptr ds:[TypFile],6  ; p©¡znak souboru SOUND
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFil60                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],8600 ; vzorkovac¡ kmito‡et pro SND
         jmp       short DetFil60

; ------ test, zda je soubor SPK

DetFil51:cmp       word ptr ds:[SoubExt],"PS"
         jne       DetFil52
         cmp       byte ptr ds:[SoubExt+2],"K"
         jne       DetFil52
         mov       byte ptr ds:[TypFile],7  ; p©¡znak souboru SPEAKER
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFile6                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],9000 ; vzorkovac¡ kmito‡et pro SPK

; ------ test, zda je soubor FRQ

DetFil52:cmp       word ptr ds:[SoubExt],"RF"
         jne       DetFil53
         cmp       byte ptr ds:[SoubExt+2],"Q"
         jne       DetFil53
         mov       byte ptr ds:[TypFile],9  ; p©¡znak souboru FREQUENT
         test      byte ptr ds:[Param],2    ; byl zad n vzorkovac¡ kmito‡et ?
         jnz       DetFile6                 ; vzorkovac¡ kmito‡et zad n
         mov       word ptr ds:[SampRate],8600 ; vzorkovac¡ kmito‡et pro FRQ
         jmp       short DetFile6


DetFil53:

; ------ stanoven¡ implicitn¡ hlasitosti hlasitosti

DetFile6:test      byte ptr ds:[Param],40h  ; byla zad na hlasitost ?
         jnz       DetFil68                 ; hlasitost byla zad na
         cmp       byte ptr ds:[TypFile],8  ; je to soubor STEVE SOUND ?
         je        DetFil63                 ; je to soubor STEVE SOUND
         cmp       byte ptr ds:[TypFile],7  ; je to soubor SPEAKER ?
         jne       DetFil67                 ; je to SPEAKER
DetFil63:mov       byte ptr ds:[SampVol],2  ; zv˜¨en¡ hlasitosti 2x pro LPT
         cmp       byte ptr ds:[OutCan],0   ; je v˜stup na reproduktor ?
         jne       DetFil68                 ; je v˜stup na LPT
         mov       byte ptr ds:[SampVol],4  ; hlasitost pro reproduktor
         jmp       short DetFil68

DetFil67:cmp       byte ptr ds:[OutCan],0   ; je v˜stup na reproduktor ?
         jne       DetFil68                 ; nen¡ reprod. - je hlasitost 1
         mov       byte ptr ds:[SampVol],2  ; jinak hlasitost 2

; ------ stanoven¡ nulov‚ hladiny vzorku

DetFil68:test      byte ptr ds:[Param],4    ; byla zad na nulov  hladina ?
         jz        DetFl700
         jmp       DetFile8                 ; nulov  hladina byla zad na

; ------ nulov  hladina 80h pro zn m‚ form ty

DetFl700:test      byte ptr ds:[Param],80h  ; po‘adovan  nucen  detekce nuly ?
         jnz       DetFil70                 ; po‘adovan  nucen  detekce nuly
         mov       ah,ds:[TypFile]          ; typ souboru
         mov       al,80h
         cmp       ah,1                     ; je RAW SOUND ?
         je        DetFil79                 ; je RAW SOUND
         cmp       ah,2                     ; je SB PRO ?
         je        DetFil79                 ; je SB PRO
         cmp       ah,3                     ; je WAVE ?
         je        DetFil79                 ; je WAVE
         cmp       ah,6                     ; je SOUND ?
         je        DetFil79                 ; je SOUND
         cmp       ah,9                     ; je FREQUENT ?
         je        DetFil79
         mov       al,0
         cmp       ah,4                     ; je SAMPLER ?
         je        DetFil79                 ; je SAMPLER
         cmp       ah,5                     ; je NTI ?
         je        DetFil79                 ; je NTI
         mov       al,32
         cmp       ah,7                     ; je SPEAKER ?
         je        DetFil79                 ; je SPEAKER
         cmp       ah,8                     ; je STEVE SOUND ?
         je        DetFil79                 ; je STEVE SOUND

; ------ p©¡prava registr– k stanoven¡ st©edn¡ hladiny vzorku

DetFil70:xor       si,si
         mov       cx,ds:[DatNum]           ; po‡et odstavc– dat
         cmp       cx,0f00h
         jb        DetFil71
         mov       cx,0f00h                 ; testuje se maxim lnˆ 64 KB
DetFil71:shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; po‡et bajt– dat
         jcxz      DetFile8                 ; nejsou ‘ dn  data

; ------ stanoven¡ st©edn¡ hodnoty dat

         xor       bx,bx                    ; st©ada‡ st©edn¡ hodnoty LOW
         xor       dx,dx                    ; st©ada‡ st©edn¡ hodnoty HIGH
         xor       di,di                    ; ‡¡ta‡ bajt– 40h a‘ c0h
         mov       ah,0
         push      cx
DetFil72:mov       al,es:[si]               ; bajt dat
         cmp       al,40h
         jb        DetFil73
         cmp       al,0c0h
         jae       DetFil73
         inc       di                       ; ‡¡ta‡ bajt– 40h a‘ 0c0h
DetFil73:add       bx,ax                    ; ‡¡t n¡ st©edn¡ hodnoty
         adc       dx,0                     ; p©enos HIGH
         inc       si                       ; zv˜¨en¡ ukazatele dat
         loop      DetFil72                 ; dal¨¡ bajt dat
         pop       cx
         xchg      ax,bx                    ; AX <- sou‡et LOW
         div       cx                       ; v˜po‡et st©edn¡ hodnoty dat
         cmp       al,60h
         jb        DetFil74
         sub       cx,di                    ; po‡et bajt– mimo interval
         cmp       cx,di                    ; je z porn‚ ‡¡slo ?
         jbe       DetFil74                 ; nen¡ z porn‚ ‡¡slo
         add       al,80h                   ; oprava st©edn¡ hladiny
DetFil74:add       al,7                     ; p©¡prava pro zaokrouhlen¡
         and       al,not 0fh               ; zaokrouhlen¡ na MOD 16

DetFil79:mov       ds:[NulLev],al           ; st©edn¡ hodnota dat

DetFile8:ret

DetFile  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru do pamˆti
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ p©¡prava registr–

         mov       si,ds:[DatSize]          ; velikost datov‚ho bloku
         mov       di,ds:[DatSeg]           ; adresa datov‚ho bloku
         mov       word ptr ds:[DatNum],0   ; ‡¡ta‡ dat v bufferu
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         xor       dx,dx                    ; offset po‡ tku dat

; ------ velikost jednoho bloku dat k na‡ten¡

ReadFil1:mov       cx,0f00h                 ; velikost bloku dat
         cmp       cx,si                    ; zb˜v  dost m¡sta v bufferu ?
         jb        ReadFil2                 ; zb˜v  dost m¡sta v bufferu
         mov       cx,si                    ; omezen¡ velikosti bloku dat
ReadFil2:shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©epo‡et velikosti bloku na bajty
         jcxz      ReadFil6                 ; konec datov‚ho bloku

; ------ na‡ten¡ bloku dat do pamˆti

         push      ds
         mov       ds,di                    ; adresa datov‚ho bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ bloku dat ze souboru
         pop       ds

; ------ po‡et skute‡nˆ na‡ten˜ch dat ze souboru

         jnc       ReadFil3                 ; ‡ten¡ probˆhlo OK
         xor       ax,ax                    ; p©i chybˆ - konec souboru
ReadFil3:cmp       ax,cx                    ; nebylo navr ceno v¡ce ne‘ po‘ad. ?
         jb        ReadFil4                 ; navr ceno OK
         xchg      ax,cx                    ; omezen¡ velikosti dat
ReadFil4:shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce

; ------ posun ukazatel– v bufferu

         add       word ptr ds:[DatNum],ax  ; zv˜¨en¡ ‡¡ta‡e dat
         add       di,ax                    ; zv˜¨en¡ adresy v datov‚m bufferu
         sub       si,ax                    ; sn¡‘en¡ ‡¡ta‡e dat
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jnz       ReadFil1                 ; bylo nˆco na‡teno OK

ReadFil6:ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ parametr– souboru
; -----------------------------------------------------------------------------

DispPar  PROC      NEAR

; ------ zobrazen¡ jm‚na souboru

         mov       si,ds:[SoubEnd]          ; konec jm‚na souboru
         mov       di,ds:[SoubNam]          ; adresa za‡ tku jm‚na souboru
DispPar1:dec       si                       ; sn¡‘en¡ ukazatele jm‚na souboru
         cmp       si,di                    ; je ji‘ za‡ tek jm‚na souboru ?
         je        DispPar2                 ; je ji‘ za‡ tek jm‚na souboru
         cmp       byte ptr ds:[si-1],"\"   ; je za‡ tek jm‚na souboru ?
         jne       DispPar1                 ; nalezen¡ za‡ tku jm‚na souboru
DispPar2:call      DispTxt                  ; zobrazen¡ jm‚na souboru

; ------ oddˆlovac¡ mezera

         mov       si,offset TextPar1
         call      DispTxt

; ------ zobrazen¡ typu souboru

         mov       al,ds:[TypFile]          ; typ souboru
         mov       ah,0
         mov       si,offset TextTyp1
         dec       ax
         jz        DispPar3                 ; je RAW SOUND
         mov       si,offset TextTyp2
         dec       ax
         jz        DispPar3                 ; je SOUND BLASTER PRO
         mov       si,offset TextTyp3
         dec       ax
         jz        DispPar3                 ; je WAVE
         mov       si,offset TextTyp4
         dec       ax
         jz        DispPar3                 ; je SAMPLER
         mov       si,offset TextTyp5
         dec       ax
         jz        DispPar3                 ; je NTI
         mov       si,offset TextTyp6
         dec       ax
         jz        DispPar3                 ; je SOUND
         mov       si,offset TextTyp7
         dec       ax
         jz        DispPar3                 ; je SPEAKER
         mov       si,offset TextTyp8
         dec       ax
         jz        DispPar3                 ; je STEVE SOUND
         mov       si,offset TextTyp9
         dec       ax
         jz        DispPar3                 ; je FREQUENT
         mov       si,offset TextTyp0       ; jinak nezn m˜ form t
DispPar3:call      DispTxt                  ; zobrazen¡ typu form tu souboru

; ------ zobrazen¡, zda je stereofonn¡

         mov       si,offset TextKom1       ; komprese 4 bity
         cmp       byte ptr ds:[Kompres],1
         je        DispPar4                 ; je komprese 4 bity
         mov       si,offset TextKom2       ; komprese 3 bity
         cmp       byte ptr ds:[Kompres],2
         je        DispPar4                 ; je komprese 3 bity
         mov       si,offset TextKom3       ; komprese 2 bity
         cmp       byte ptr ds:[Kompres],3
         je        DispPar4                 ; je komprese 2 bity
         mov       si,offset TextMono       ; mono
         cmp       byte ptr ds:[Stereo],2   ; je stereo ?
         jne       DispPar4                 ; nen¡ stereo
         mov       si,offset TextSter       ; stereo
DispPar4:call      DispTxt                  ; zobrazen¡ mono/stereo

; ------ zobrazen¡ vzorkovac¡ho kmito‡tu

         mov       ax,ds:[SampRate]         ; vzorkovac¡ kmito‡et
         call      DispNum                  ; zobrazen¡ kmito‡tu
         mov       si,offset HzTxt
         call      DispTxt                  ; zobrazen¡ oddˆlovac¡ho textu

; ------ zobrazen¡ £rovnˆ nuly

         mov       al,ds:[NulLev]           ; nulov  hladina vzorku
         mov       ah,0
         call      DispNum                  ; zobrazen¡ nulov‚ hladiny

; ------ p©¡prava k zobrazen¡ d‚lky souboru

         mov       si,offset DelkTxt
         call      DispTxt                  ; zobrazen¡ oddˆlovac¡ho textu
         mov       ax,word ptr ds:[SoubSize] ; velikost souboru LOW
         mov       dx,word ptr ds:[SoubSize+2] ; velikost souboru HIGH
         mov       cx,ds:[SampRate]         ; vzorkovac¡ kmito‡et
         cmp       dx,cx                    ; bylo by p©ete‡en¡ ‡¡sla ?
         jb        DispPar5                 ; ‡¡slo je OK
         mov       dx,cx                    ; omezen¡ velikosti ‡¡sla
         dec       dx
         mov       ax,-1
DispPar5:div       cx                       ; v˜po‡et po‡tu sekund

; ------ korekce pro kompresi

         cmp       byte ptr ds:[Kompres],0
         je        DispPr54
         mov       cx,ax
         shl       ax,1
         cmp       byte ptr ds:[Kompres],1
         je        DispPr54
         add       ax,cx
         cmp       byte ptr ds:[Kompres],2
         je        DispPr54
         add       ax,cx

; ------ zobrazen¡ minut

DispPr54:xor       dx,dx
         mov       cx,60
         div       cx
         cmp       ax,10
         jae       DispPar6
         push      ax
         mov       al,"0"
         call      DispChr                  ; zobrazen¡ jedn‚ nuly
         pop       ax
DispPar6:call      DispNum                  ; zobrazen¡ po‡tu minut

; ------ zobrazen¡ sekund

         mov       al,":"
         call      DispChr
         xchg      ax,dx                    ; po‡et sekund
         cmp       ax,10
         jae       DispPar7
         push      ax
         mov       al,"0"
         call      DispChr
         pop       ax
DispPar7:call      DispNum

; ------ zobrazen¡ velikosti souboru

         mov       si,offset TextKb1
         call      DispTxt

         mov       ax,word ptr ds:[SoubSize] ; velikost souboru LOW
         mov       dx,word ptr ds:[SoubSize+2] ; velikost souboru HIGH
         mov       cx,1000                  ; dˆlitel
         cmp       dx,cx
         jb        DispPar8
         mov       dx,cx
         dec       dx
         mov       ax,-1
DispPar8:div       cx
         call      DispNum                  ; zobrazen¡ velikosti souboru

         mov       si,offset TextKb2
         call      DispTxt
         ret

DispPar  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava k dek¢dov n¡ ‡¡sla

         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic
         mov       bx,10                    ; dˆlitel ‡¡sla

; ------ v˜po‡et ‡¡slic

DispNum1:xor       dx,dx
         div       bx                       ; v˜po‡et jedn‚ ‡¡slice
         push      dx                       ; £schova ‡¡slice do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         or        ax,ax                    ; je dal¨¡ ‡¡slice ?
         jnz       DispNum1                 ; dek¢dov n¡ dal¨¡ ‡¡slice

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax                       ; n vrat ‡¡slice
         add       al,"0"                   ; korekce na znak ASCII
         call      DispChr                  ; zobrazen¡ ‡¡slice
         loop      DispNum2                 ; zobrazen¡ dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ DS:SI
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
DispTxt1:cld
         lodsb
         cmp       al,0
         je        DispTxt2
         call      DispChr
         jmp       short DispTxt1
DispTxt2:pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen¡
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                      Rozbor zadan˜ch parametr–
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; -----------------------------------------------------------------------------
;        rozbor zad n¡ ‡¡sla -> AX
; -----------------------------------------------------------------------------

ParNum   PROC      NEAR

         push      dx

         xor       dx,dx                    ; st©ada‡ ‡¡sla
         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParNm                    ; vstup prvn¡ ‡¡slice
         jc        ParNum5                  ; nen¡ zad no platn‚ ‡¡slo

ParNum1: mov       ah,0
         push      ax
         mov       ax,10
         mul       dx                       ; vyn soben¡ st©ada‡e
         or        dx,dx                    ; p©ete‡en¡ ‡¡sla ?
         jz        ParNum2                  ; nen¡ p©ete‡en¡
         mov       ax,-1                    ; omezen¡ velikosti ‡¡sla
ParNum2: pop       dx                       ; zadan‚ ‡¡slo
         add       dx,ax                    ; p©i‡ten¡ dal¨¡ ‡¡slice
         jnc       ParNum3                  ; nen¡ p©ete‡en¡
         mov       dx,-1                    ; omezen¡ velikosti ‡¡sla

ParNum3: call      ParNm                    ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       ParNum1                  ; je dal¨¡ ‡¡slice

         clc                                ; p©¡znak operace OK

ParNum5: xchg      ax,dx                    ; AX <- na‡ten‚ ‡¡slo
         pop       dx
         ret

ParNum   ENDP

; -----------------------------------------------------------------------------
;        zad n¡ jedn‚ ‡¡slice
; -----------------------------------------------------------------------------

ParNm    PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku
         jc        ParNm3                   ; nen¡ dal¨¡ znak - chyba
         cmp       al,"0"
         jb        ParNm2
         cmp       al,"9"
         ja        ParNm2
         sub       al,"0"
         ret

ParNm2:  dec       si
         stc
ParNm3:  ret

ParNm    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr
         jc        ParSpc2
         je        ParSpc
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       ParChr2
         mov       al," "

ParChr2: cmp       al,"a"
         jb        ParChr3
         cmp       al,"z"
         ja        ParChr3
         sub       al,32

ParChr3: cmp       al," "
         jae       ParChr4
         dec       si

ParChr4: ret

ParChr   ENDP

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                           Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
; ------ obsluhy p©eru¨en¡ bez komprese

TabINT08 dw        2250,INT08N8,8,1         ; (18000-27000)/8 (od 2250 Hz)
         dw        3000,INT08N6,6,1         ; (18000-27000)/6
         dw        4500,INT08N4,4,1         ; (18000-27000)/4
         dw        6000,INT08N3,3,1         ; (18000-27000)/3
         dw        9000,INT08N2,2,1         ; (18000-27000)/2
         dw        12000,INT08N1,3,2        ; (18000-27000)/1.5
         dw        18000,INT080,1,1         ; (18000-27000)
         dw        27000,INT08D1,2,3        ; (18000-27000)*1.5
         dw        36000,INT08D2,1,2        ; (18000-27000)*2
         dw        54000,INT08D3,1,3        ; (18000-27000)*3  (po 65 kHz)
         dw        65535

; ------ obsluhy p©eru¨en¡ s kompres¡ 4:1

TabInt48 dw        2250,Int48N4,4,1
         dw        7500,Int48N2,2,1
         dw        15000,Int480,1,1
         dw        30000,Int48D2,1,2
         dw        65535

; ------ obsluhy p©eru¨en¡ s kompres¡ 3:1

TabInt38 dw        2250,Int38N4,4,1
         dw        7500,Int38N2,2,1
         dw        15000,Int380,1,1
         dw        30000,Int38D,1,2
         dw        65535

; ------ obsluha p©eru¨en¡ s kompres¡ 2:1

TabInt28 dw        2250,Int28N,2,1
         dw        15000,Int280,1,1
         dw        65535

; ------ obsluha p©eru¨en¡

old08    dd        0
old09    dd        0
old21    db        0
Adr08    dw        INT080                   ; adresa obsluhy INT 08h
Konst08  db        64                       ; dˆlic¡ konstanta hodin (44-66)
;NasFrekv dw        1                        ; frekvence se n sob¡ (zvy¨uje)
;DelFrekv dw        1                        ; frekvence se dˆl¡ (sni‘uje)
;SampRat0 dw        16000                    ; korigovan  frekvence
AdrPort  dw        42h                      ; adresa v˜stupn¡ho portu

; ------ datov˜ segment

DatSeg   dw        0                        ; adresa datov‚ho bloku
DatSize  dw        0                        ; velikost datov‚ho bloku (odstavc–)
DatNum   dw        0                        ; po‡et odstavc– dat v pamˆti

; ------ pracovn¡ promˆnn‚

SoubSize dd        0                        ; velikost souboru
SoubIdnt dw        0                        ; identifik tor souboru
TypFile  db        0                        ; typ souboru
                                            ;   0 = nezn m˜
                                            ;   1 = RAW SOUND
                                            ;   2 = SOUND BLASTER PRO
                                            ;   3 = WAVE
                                            ;   4 = SAMPLER (p©¡pona SAM)
                                            ;   5 = NTI (p©¡pona NTI)
                                            ;   6 = SOUND (p©¡pona SND)
                                            ;   7 = SPEAKER (p©¡pona SPK)
                                            ;   8 = STEVE SOUND (p©¡pona SND)
                                            ;   9 = FREQUENT (p©¡pona FRQ)

Stereo   db        1                        ; po‡et kan l– (1=mono, 2=stereo)
Kompres  db        0                        ; typ komprese
                                            ;    (0=bez komprese, 1=4 bity,
                                            ;       2=3 bity, 3=2 bity)

AktDat   db        80h                      ; aktu ln¡ hodnota dat komprese
AktInc   db        0                        ; aktu ln¡ p©¡rustek dat komprese

; ------ zadan‚ £daje

SoubExt  db        3 dup(0)                 ; p©¡pona jm‚na souboru
SoubNam  dw        0                        ; adresa jm‚na souboru
SoubEnd  dw        0                        ; adresa konce jm‚na souboru
SampRate dw        8600                     ; vzorkovac¡ kmito‡et
NulLev   db        80h                      ; nulov  hladina vzorku
OutCan   db        0                        ; v˜stupn¡ kan l
SampVol  db        1                        ; zv˜¨en¡ hlasitosti vzorku
Param    db        0                        ; parametry
                                            ;    bit 0: 1=zad no jm‚no souboru
                                            ;    bit 1: 1=zad n vzork. kmitocet
                                            ;    bit 2: 1=zad na nulov  hladina
                                            ;    bit 3: 1=zad n v˜stupn¡ kan l
                                            ;    bit 4: 1=p©eru¨en¡ programu ESC
                                            ;    bit 5: 1=soubor detekov n
                                            ;    bit 6: 1=zad na hlasitost
                                            ;    bit 7: 1=nucen  detekce nuly

; ------ texty

TextVOC  db        'Creative Voice File'    ; identifik tor souboru VOC
TextVOC1 label     byte

TextWAV  db        'RIFF'                   ; identifikace souboru WAV
TextWAV1 db        'WAVE'                   ; druh  ‡ st identifikace WAV
TextWAV2 label     byte

TextSTEV db        'STEVE'                  ; identifik tor STEVE SOUND
TextSTV2 label     byte

TextPar1 db        ': ',0

TextTyp0 db        'neznamy format',0
TextTyp1 db        'RAW SOUND',0
TextTyp2 db        'SNDBLAST PRO',0
TextTyp3 db        'WAVE',0
TextTyp4 db        'SAMPLER',0
TextTyp5 db        'NTI',0
TextTyp6 db        'SOUND',0
TextTyp7 db        'SPEAKER',0
TextTyp8 db        'STEVE SOUND',0
TextTyp9 db        'FREQUENT',0

TextKom1 db        ' (KOMPRESE 2:1), ',0
TextKom2 db        ' (KOMPRESE 3:1), ',0
TextKom3 db        ' (KOMPRESE 4:1), ',0
TextMono db        ', ',0
TextSter db        ' (Stereo), ',0

TextKb1  db        ' (',0
TextKb2  db        ' KB)',13,10,0

HzTxt    db        ' Hz, nula ',0

DelkTxt  db        ', delka ',0

PortTxt  db        'Port LPT'
PortTxt1 db        '0 neni nainstalovan !',13,10,'$'
FndTxt   db        'Zadany soubor nenalezen !',13,10,'$'
MemTxt   db        'Nedostatek pameti ke spusteni programu !',13,10,'$'
HelpTxt  db        'SOUND V1.0 - prehravac zvukovych vzorku; (c) Miroslav Nemecek',13,10
         db        'Zadejte jmeno souboru a popr. parametry:',13,10
         db        '           /n  .... n=vzorkovaci kmitocet nahravky 2250 az 65500',13,10
         db        '                    (implicitne 8600 nebo detekovano)',13,10
         db        '           /Ln .... n=nulova hladina vzorku 0 az 255 (jinak detekovano)',13,10
         db        '           /L! .... nucena detekce nulove hladiny vzorku (=neurcena implicitne)',13,10
         db        '           /Vn .... n=zvyseni hlasitosti vzorku n=1 az 100 krat',13,10
         db        '                    (implicitne pro reproduktor: *.SPK /V4, ostatni /V2',13,10
         db        '                     implicitne pro LPT: *.SPK /V2, ostatni /V1)',13,10
         db        '           /Cn .... vystupni kanal (0 = reproduktor, 1 az 4 = LPT1 az 4)',13,10
         db        'Prehravani vzorku lze prerusit klavesou ESC (navratovy kod ERRORLEVEL==1).',13,10
         db        'Klavesou TAB lze ukoncit prehravani bloku v pameti a prejit na dalsi blok.',13,10
         db        '$'

         db        100h dup(?)              ; pracovn¡ z sobn¡k (v‡etnˆ textu)

Konec    label     byte

Code     ENDS
         END       Start

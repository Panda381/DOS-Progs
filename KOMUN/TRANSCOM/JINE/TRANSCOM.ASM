
; *****************************************************************************
;
;                       T R A N S   -   C O M
;
;                 P©enos soubor– p©es s‚riov˜ port
;
; *****************************************************************************

; Znaky pou‘it‚ p©i komunikaci:
;
; 00h NUL    - oddˆlovac¡ mezera (ignoruje se - pouze pro synchronizaci)
; 01h BEGIN  - za‡ tek zpr vy (n sleduje povel)
; 02h ENDS   - konec zpr vy (operace se provede)
; 03h SHS    - p©echodn  zmˆna p©esmyka‡e (zmˆna inverze znaku - provede se NOT)
; 04h SHL    - trval  zmˆna p©esmyka‡e (trval  inverze dat - NOT)
; 05h a‘ 0ffh - platn‚ znaky


; Komunika‡n¡ protokol:
;
;  BEGIN      - identifikace za‡ tku zpr vy (i znovu uprost©ed zpr vy)
;    text zpr vy
;  ENDS       - identifik tor konce zpr vy (operace se provede)
;
; P©ij¡ma‡ prov d¡ pr–bˆ‘nˆ echo k vys¡la‡i. Znakem ENDS vys¡la‡ potvrzuje, ‘e
; p©ijal zpˆtnˆ celou zpr vu a ‘e p©ij¡ma‡ m–‘e prov‚st operaci se zpr vou.

;  Zpr va:
;    D - nastaven¡ adres ©e (n sleduje text adres ©e)
;    O - otev©en¡ souboru pro z pis (jm‚no n sleduje) (otev©en˜ soub. se uzav©e)
;    W - z pis dat (n sleduje 2 bajty offset v bufferu a data)
;    C - uzav©en¡ soubor (n sleduje kontroln¡ sou‡et 2 bajty)
;    Q - ukon‡en¡ p©enosu
;  Buffer m  velikost 0f000h bajt– (=61440)


NUL      EQU       0  ; oddˆlovac¡ mezera (ignoruje se - pro synchronizaci)
BEGIN    EQU       1  ; za‡ tek zpr vy (n sleduje povel)
                      ;  (m–‘e b˜t znovu i uprost©ed zpr vy)
ENDS     EQU       2  ; konec zpr vy (operace se provede)
SHS      EQU       3  ; kr tk  zmˆna p©esmyka‡e (zmˆna inverze znaku - NOT)
SHL      EQU       4  ; dlouh  zmˆna p©esmyka‡e (trval  inverze dat - NOT)

DatByte  EQU       5  ; prvn¡ platn˜ datov˜ bajt

SizBuff  EQU       0f000h ; velikost p©enosov‚ho bufferu



code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

Start:

; ------ instalace obsluhy INT 08h

         push      es                       ; £schova ES
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; £schova offsetu adresy INT 08h
         mov       word ptr ds:[Old08+2],es ; £schova segmentu adresy INT 08h
         pop       es                       ; n vrat ES
         mov       dx,offset Int08          ; vlastn¡ obsluha INT 08h
         mov       ax,2508h
         int       21h                      ; definice vlastn¡ obsluhy INT 08h

; ------ £schova aktivn¡ho disku

         mov       ah,19h                   ; funkce poskytnut¡ akt. disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       ds:[OldDisk],al          ; £schova p–vodn¡ho aktivn¡ho disku
         add       al,"A"                   ; p©evod na ozna‡en¡ disku
         mov       byte ptr ds:[AktDisk],al ; ozna‡en¡ aktivn¡ho disku

; ------ zobrazen¡ £vodn¡ho textu

         mov       si,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ ur‡en¡ segmentu datov‚ho bufferu a kontrola voln‚ pamˆti

                                          ;* ur‡en¡ segmentu bufferu dat
         mov       ax,cs                    ; AX <- CS
         add       ax,offset(Konec-Start+100h+15)/16 ; segment datov‚ho bufferu
         mov       ds:[SegBuf],ax           ; segment datov‚ho bufferu

                                          ;* kontrola voln‚ pamˆti
         add       ax,1800h                 ; rez. 64 KB (data),32 KB (z sobn¡k)
         cmp       ax,ds:[2]                ; je dostate‡n  pamˆŸ ?
         jbe       Start2                   ; je dostatek pamˆti

                                          ;* nedostatek pamˆti
         mov       si,offset MemTxt         ; text - chyba pamˆti
Start1:  call      DispTxt                  ; zobrazen¡ textu chyby
         mov       ax,4c01h
         int       21h                      ; n vrat s chybou

; ------ inicializace z sobn¡ku

Start2:  sub       ax,1000h                 ; segment pro z sobn¡k
         mov       ss,ax                    ; segment z sobn¡ku
         xor       sp,sp                    ; offset konce z sobn¡ku

; ------ definice bodu p©eru¨en¡ INT 23h

         mov       ax,2523h                 ; vektor p©eru¨en¡ Ctrl-Break
         mov       dx,offset Start9         ; obsluha p©eru¨en¡ INT 23h
         int       21h                      ; definice obsluhy p©eru¨en¡ INT 23h

; ------ dek¢dov n¡ zad n¡ z p©¡kazov‚ho © dku

                                          ;* p©¡prava p©¡kazov‚ho © dku
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[80h]              ; d‚lka p©¡kazov‚ho © dku
         mov       byte ptr ds:[si+bx],0    ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ test, zda je v–bec nˆco zad no - chyba zad n¡

         call      LoadSpc                  ; vypustˆn¡ mezer z textu
         jnc       Start4                   ; je nˆco zad no
Start3:  mov       si,offset ErrTxt         ; text n povˆdy
         jmp       short Start1             ; chyba zad n¡

; ------ rozbor jednoho parametru

Start4:  call      LoadSpc                  ; vypustˆn¡ mezer z textu
         jnc       Start41                  ; je dal¨¡ znak
         jmp       Start5                   ; konec p©¡kazov‚ho © dku
Start41: cmp       al,"/"                   ; je zad n¡ parametru ?
         jne       Start48                  ; nen¡ zad n¡ parametru

; ------ je zad n¡ parametru "/"

         inc       si                       ; p©esko‡en¡ znaku "/"
         call      LoadChar                 ; na‡ten¡ znaku parametru
         jbe       Start3                   ; nen¡ zad n - chyba

                                          ;* parametr /S - podadres ©e
         cmp       al,"S"                   ; je p©ep¡na‡ podadres ©– ?
         jne       Start49                  ; nen¡ p©ep¡na‡ podadres ©–
         inc       byte ptr ds:[SubDirs]    ; nastaven¡ p©ep¡na‡e podadres ©–
         jmp       short Start4             ; rozbor dal¨¡ho parametru

                                          ;* parametr /n - ‡¡slo portu COM
Start49: mov       ds:[PortTxt0],al         ; port COM pro zobrazen¡ chyby
         mov       ds:[VysTxt0],al          ; port COM pro vys¡l n¡
         mov       ds:[PrijTxt0],al         ; port COM pro p©ij¡m n¡
         sub       al,"1"                   ; kontrola ‡¡sla portu COM
         jc        Start3                   ; chybn‚ zad n¡ ‡¡sla portu COM
         cmp       al,4                     ; kontrola ‡¡sla portu COM
         jae       Start3                   ; chybn‚ zad n¡ ‡¡sla portu COM

                                          ;* zji¨tˆn¡ a kontrola adresy portu
         push      ds                       ; £schova DS
         xor       bx,bx                    ; BX <- 0
         mov       ds,bx                    ; DS <- 0 segment dat BIOS
         mov       bl,al                    ; ‡¡slo portu COM
         add       bx,bx                    ; ‡¡slo portu * 2
         mov       ax,ds:[bx+400h]          ; adresa portu COM
         pop       ds
         mov       ds:[AdrPort],ax          ; £schova adresy portu
         or        ax,ax                    ; je port nainstalov n ?
         jnz       Start4                   ; port nainstalov n - dal¨¡ rozbor
         mov       si,offset PortTxt        ; chybov˜ text - port nenainstalov n
Start11: jmp       short Start1             ; port nen¡ nainstalov n

; ------ je z©ejmˆ zad n¡ soubor– k vysl n¡

Start48: cmp       byte ptr ds:[SetVys],0   ; byly ji‘ zad ny soubory ?
         jne       Start3                   ; byly ji‘ soubory - chyba zad n¡
         inc       byte ptr ds:[SetVys]     ; p©¡znak vys¡l n¡ soubor–
         push      si                       ; £schova ukazatele textu
         mov       si,offset PocetTx2       ; text "vyslanych"
         mov       di,offset PocetTx1       ; text "prijatych"
         mov       cx,offset(PocetTx3-PocetTx2) ; d‚lka textu "vyslanych"
         cld
         rep       movsb                    ; p©enos textu "vyslanych"
         pop       si                       ; n vrat ukazatele textu

; ------ test, zda je zad n jin˜ disk

         cmp       byte ptr ds:[si+1],":"   ; je zad n disk ?
         jne       Start42                  ; nen¡ zad n jin˜ disk
         add       si,2                     ; p©esko‡en¡ zad n¡ disku
         mov       byte ptr ds:[AktDisk],al ; ozna‡en¡ po‘adovan‚ho disku
         sub       al,"A"                   ; korekce na ‡¡slo disku
         mov       dl,al                    ; po‘adovan˜ disk
         mov       ah,0eh                   ; funkce v˜bˆru disku
         int       21h                      ; nastaven¡ aktivn¡ho disku
         mov       ah,19h                   ; funkce poskytnut¡ aktivn¡ho disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         cmp       al,dl                    ; byl disk £spˆ¨nˆ nastaven ?
         je        Start42                  ; disk byl £spˆ¨nˆ nastaven
         mov       si,offset DiskTxt        ; text chyby zad n¡ disku
Start12: jmp       short Start11            ; chyba zad n¡ disku

; ------ £schova aktivn¡ho adres ©e

Start42: push      si                       ; £schova ukazatele parametr–
         mov       si,offset OldPath        ; p–vodn¡ aktivn¡ adres ©
         call      LoadDir                  ; £schova p–vodn¡ho adres ©e
         pop       si                       ; n vrat ukazatele parametr–

; ------ nalezen¡ konce zadan‚ho adres ©e

         mov       dx,si                    ; £schova za‡ tku zad n¡ adres ©e
         mov       bx,si                    ; £schova konce adres ©e
Start43: call      LoadChar                 ; na‡ten¡ dal¨¡ho znaku adres ©e
         jbe       Start44                  ; konec zadan‚ho adres ©e
         cmp       al,"/"                   ; je parametr ?
         je        Start44                  ; je parametr - konec
         cmp       al,"\"                   ; je oddˆlova‡ cesty ?
         jne       Start43                  ; nen¡ oddˆlova‡ cesty - dal¨¡ znak
         mov       bx,si                    ; £schova konce cesty
         dec       bx                       ; n vrat na znak "\"
         jmp       short Start43            ; pokra‡ov n¡ v rozkladu

; ------ nastaven¡ zadan‚ho adres ©e

Start44: cmp       byte ptr ds:[bx],"\"     ; byl zad n nˆjak˜ adres © ?
         jne       Start46                  ; nebyl zad n ‘ dn˜ adres ©
         mov       byte ptr ds:[bx],0       ; ozna‡en¡ konce zad n¡ adres ©e
         cmp       bx,dx                    ; byl z kladn¡ adres © ?
         jne       Start45                  ; nebyl z kladn¡ adres ©
         mov       dx,offset Root           ; specifikace z kladn¡ho adres ©e
Start45: call      SetDir                   ; nastaven¡ po‘adovan‚ho adres ©e
         mov       si,offset PathTxt        ; text - chybn‚ zad n¡ adres ©e
         jc        Start12                  ; chybn‚ zad n¡ adres ©e
         inc       bx                       ; p©esko‡en¡ ukon‡ovac¡ho bajtu 0

; ------ £schova ozna‡en¡ adres ©e nebo soubor–

Start46: mov       di,offset NewPath        ; buffer k £schovˆ zad n¡ adres ©e
         mov       dx,di                    ; buffer se zadan˜m adres ©em
         mov       si,bx                    ; za‡ tek specifikace jm‚na
         mov       cx,12                    ; maxim ln¡ d‚lka jm‚na souboru
Start47: call      LoadChar                 ; na‡ten¡ znaku jm‚na
         jbe       Start4b                  ; konec jm‚na souboru/adres ©e
         cmp       al,"/"                   ; je oddˆlova‡ parametr– ?
         je        Start4a                  ; je oddˆlova‡ parametr– "/"
         jcxz      Start47                  ; byly ji‘ v¨echny znaky
         stosb                              ; ulo‘en¡ znaku jm‚na
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short Start47            ; dal¨¡ znak

; ------ pokus, zda jde nastavit jako adres ©

Start4a: dec       si                       ; n vrat znaku oddˆlova‡e "/"
Start4b: cmp       di,dx                    ; byl zadan˜ nˆjak˜ znak ?
         je        Start4e                  ; nebyl ‘ dn˜ znak
         call      SetDir                   ; pokus o nastaven¡ adres ©e
         jnc       Start4e                  ; byl to adres © - OK
         push      si
         mov       si,dx                    ; zadan‚ jm‚no souboru
         mov       di,offset Files          ; specifikace po‘adovan˜ch soubor–
         mov       cx,13                    ; d‚lka specifikace
         rep       movsb                    ; £schova zadan˜ch soubor–
         pop       si
Start4e: jmp       Start4                   ; pokra‡ov n¡ v rozboru

; ------ £schova aktivn¡ho adres ©e

Start5:  mov       si,offset OldPath        ; p–vodn¡ aktivn¡ adres ©
         cmp       byte ptr ds:[si],0       ; je adres © ji‘ uschov n ?
         jne       Start51                  ; adres © je ji‘ uschov n
         call      LoadDir                  ; £schova p–vodn¡ho adres ©e

; ------ inicializace portu COM

Start51: test      byte ptr ds:[PortTxt0],1 ; je port COM1 nebo COM3 ?
         jnz       Start52                  ; je port COM1 nebo COM3
         mov       byte ptr ds:[NumInt],0bh ; p©eru¨en¡ INT pro COM2 a COM4
         mov       byte ptr ds:[MaskInt],8  ; maska registru p©er. COM2, COM4
Start52: call      InitCom                  ; inicializace portu COM

; ------ rozli¨en¡, zda je p©¡jem nebo vys¡l n¡

         cmp       byte ptr ds:[setvys],0   ; je p©¡jem soubor– ?
         je        Start6                   ; je p©¡jem soubor–

; ------ vys¡l n¡ soubor–

         mov       si,offset vystxt         ; text pro vys¡l n¡
         call      DispTxt                  ; zobrazen¡ informace o vys¡l n¡

         call      SendDir                  ; vysl n¡ obsahu aktiv. adres ©e

         mov       al,"Q"                   ; povel k p©eru¨en¡ spojen¡
         xor       cx,cx                    ; nejsou ‘ dn  data
         call      WritTxt                  ; vysl n¡ povelu pro ukon‡en¡

         jmp       short StartEnd           ; ukon‡en¡ programu

; ------ p©¡jem soubor–

Start6:  mov       si,offset prijtxt        ; text pro p©¡jem soubor–
         call      DispTxt                  ; zobrazen¡ informace o p©¡jmu

         call      Prijem                   ; p©¡jem soubor– v adres ©i
         jmp       short StartEnd           ; ukon‡en¡ programu

; ------ p©eru¨en¡ programu Ctrl-Break

Start9:  mov       si,offset BreakTxt       ; text p©eru¨en¡
         push      cs
         pop       ds                       ; DS <- CS
                                          ;* zabr nˆn¡ opakovan‚mu hl ¨en¡
         mov       ax,2523h                 ; vektor p©eru¨en¡ Ctrl-Break
         mov       dx,offset StartEnd       ; nov  obsluha p©eru¨en¡ INT 23h
         int       21h                      ; definice obsluhy p©eru¨en¡ INT 23h
                                          ;* zobrazen¡ chybov‚ho hl ¨en¡
         call      DispTxt                  ; zobrazen¡ textu

; ------ n vrat obsluhy portu COM

StartEnd:mov       ds,word ptr cs:[OldInt+2] ; segment p–vodn¡ obsluhy COM
         mov       bx,ds                    ; segment p–vodn¡ obsluhy COM
         or        bx,bx                    ; byla obsluha p©edefinovan  ?
         jz        StartEn2                 ; port nebyl inicializov n

         mov       dx,cs:[AdrPort]
         in        al,dx
         inc       dx                       ; ©¡dic¡ registr p©eru¨en¡
         xor       al,al
         out       dx,al                    ; z kaz v¨ech p©eru¨en¡

         mov       dx,word ptr cs:[OldInt]  ; p–vodn¡ adresa obsluhy COM
         mov       al,cs:[NumInt]           ; ‡¡slo p©eru¨en¡
         mov       ah,25h
         int       21h                      ; n vrat adresy portu

; ------ zobrazen¡ hl ¨en¡ o p©enesen˜ch souborech

StartEn2:push      cs
         pop       ds                       ; DS <- CS
         call      Close                    ; uzav©en¡ otev©en‚ho souboru

         mov       ax,ds:[CitFile]          ; po‡et p©enesen˜ch soubor–
         mov       si,offset CRTxt-1        ; konec textu k ulo‘en¡ ‡¡sla
         call      DekNum                   ; dek¢dov n¡ ‡¡sla AX
         mov       si,offset PocetTxt       ; text - po‡et soubor–
         call      DispTxt                  ; zobrazen¡ textu

; ------ n vrat p–vodn¡ho adres ©e a disku

         mov       dx,offset OldPath        ; p–vodn¡ adres ©
         call      SetDir                   ; n vrat p–vodn¡ho adres ©e
         mov       dl,ds:[OldDisk]          ; p–vodn¡ aktivn¡ disk
         mov       ah,0eh
         int       21h                      ; nastaven¡ p–vodn¡ho aktiv. disku

; ------ n vrat p–vodn¡ obsluhy INT 08h

         lds       dx,ds:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; nastaven¡ p–vodn¡ adresy INT 08h

; ------ ukon‡en¡ programu

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;
;                     Dek¢dov n¡ p©¡kazov‚ho © dku
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        Vypustˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

PUBLIC   LoadSpc
LoadSpc  PROC      NEAR

         call      LoadChar                 ; na‡ten¡ znaku z p©¡kaz. © dku
         je        LoadSpc                  ; vypustˆn¡ oddˆlovac¡ch mezer
         jb        LoadSpc1                 ; konec © dku
         dec       si                       ; n vrat posledn¡ho znaku
LoadSpc1:ret

LoadSpc  ENDP

; -----------------------------------------------------------------------------
;        Na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

PUBLIC   LoadChar
LoadChar PROC      NEAR

         cld                                ; smˆr nahoru
         lodsb                              ; znak z p©¡kazov‚ho © dku

; ------ korekce na velk‚ p¡smeno

         cmp       al,"a"                   ; je mal‚ p¡smeno ?
         jb        LoadCh1                  ; nen¡ mal‚ p¡smeno
         cmp       al,"z"                   ; je mal‚ p¡smeno ?
         ja        LoadCh1                  ; nen¡ mal‚ p¡smeno
         sub       al,32                    ; korekce na velk‚ p¡smeno

; ------ n hrada tabel toru mezerou

LoadCh1: cmp       al,9                     ; je tabel tor ?
         jne       LoadCh2                  ; nen¡ tabel tor
         mov       al," "                   ; n hrada znakem mezery

; ------ kontrola, zda je platn˜ znak

LoadCh2: cmp       al," "                   ; je platn˜ znak ?
         jae       LoadCh3                  ; je platn˜ znak
         dec       si                       ; n vrat ukazatele znak–
LoadCh3: ret

LoadChar ENDP


; *****************************************************************************
;
;                            P©¡jem soubor–
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        P©¡jem soubor– do aktivn¡ho adres ©e
; -----------------------------------------------------------------------------

Prijem:
         ret

;Start66: call      ReadTxt
;         cmp       al,"D"                   ; zmˆna adres ©e ?
;         jne       Start67
;         call      ReadDir                  ; nastaven¡ nov‚ho adres ©e
;         jc        StartEnd                 ; chyba nastaven¡ adres ©e
;         jmp       short Start66
;
;Start67:
;         cmp       al,"O"                   ; je otev©en¡ souboru ?
;         jne       Start68
;
;         call      OpenFile                 ; otev©en¡ souboru
;         jc        StartEnd                 ; chyba operace otev©en¡ souboru
;         jmp       short Start66
;
;Start68:
;         cmp       al,"C"                   ; je uzav©en¡ souboru ?
;         jne       Start69
;
;         call      ClosFile
;         jc        StartEnd                 ; chyba uzav©en¡ souboru
;         jmp       short Start66
;
;Start69:
;         cmp       al,"W"
;         jne       Start6a
;
;         call      WritDat
;         jc        StartEnd                 ; chyba operace z pisu
;         jmp       short Start66
;
;Start6a:
;         cmp       al,"Q"                   ; p©eru¨en¡
;         je        StartEnd                 ; ukon‡en¡ p©enosu
;
;         jmp       start66
;
;





; -----------------------------------------------------------------------------
;        Z pis dat do souboru
; -----------------------------------------------------------------------------

PUBLIC   WritDat

WritDat  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      ds

         mov       bx,cs:[Ident]
         or        bx,bx
         jz        WritDat2

         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m jm‚nem souboru
         xor       dx,dx                    ; offset specifikace souboru
         mov       cx,word ptr cs:[bufchar+1]
         mov       si,dx                    ; adresa dat v bufferu
         call      CheckSum                 ; kontroln¡ sou‡et bloku dat

         mov       ah,40h
         int       21h                      ; z pis do souboru
         mov       si,offset writetxt       ; chyba z pisu
         jc        WritDat1                 ; chyba z pisu
         cmp       ax,cx                    ; je disk pln˜ ?
         je        WritDat2                 ; z pis OK
         mov       si,offset fulltxt        ; disk je pln˜

                                          ;* chyba operace z pisu
WritDat1:call      DispTxt                  ; zobrazen¡ textu chyby

                                          ;* uzav©en¡ a zru¨en¡ souboru
         mov       ah,3eh
         int       21h
         push      cs
         pop       ds
         mov       ah,41h
         mov       dx,offset jmeno
         int       21h                      ; zru¨en¡ souboru

         stc                                ; p©¡znak chyby

WritDat2:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

WritDat  ENDP


; -----------------------------------------------------------------------------
;        Otev©en¡ souboru p©ijat‚ho jm‚na
; -----------------------------------------------------------------------------
; VSTUP: CY=chyba otev©en¡ souboru
; -----------------------------------------------------------------------------

PUBLIC   OpenFile

OpenFile PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

         cmp       word ptr ds:[Ident],0    ; je ji‘ soubor otev©en ?
         jne       OpenFil2                 ; nˆjak˜ soubor je ji‘ otev©en

                                          ;* £schova na‡ten˜ch parametr–
         push      cs
         pop       es
         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m jm‚nem souboru
         xor       si,si
         mov       di,offset atrib
         cld
         mov       cx,22
         rep       movsb

                                          ;* nulov n¡ atribut– (existuje-li)
         push      cs
         pop       ds
         mov       dx,offset jmeno          ; offset specifikace souboru
         mov       ax,4301h
         xor       cx,cx                    ; po‘adovan‚ atributy
         int       21h                      ; nastaven¡ atribut– souboru

                                          ;* vytvo©en¡ souboru (neexistuje-li)
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ souboru
         jc        OpenFil1                 ; soubor nelze otev©¡t

         mov       ds:[Ident],ax            ; identifik tor souboru
         mov       word ptr ds:[ChSum],-1   ; inicializace kontroln¡ho sou‡tu

         mov       si,offset jmeno          ; jm‚no souboru
         call      ZobrFile                 ; zobrazen¡ jm‚na souboru
         clc
         jmp       short OpenFil2

                                          ;* je chyba operace
OpenFil1:mov       si,offset WriteTxt       ; text - chyba otev©en¡ souboru
         call      DispTxt                  ; zobrazen¡ chybov‚ho textu
         stc

OpenFil2:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenFile ENDP


; -----------------------------------------------------------------------------
;        Uzav©en¡ souboru p©ijat‚ho jm‚na
; -----------------------------------------------------------------------------

PUBLIC   ClosFile

ClosFile PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      ds

         mov       bx,ds:[Ident]
         or        bx,bx
         jz        ClosFil4

                                          ;* nastaven¡ data a ‡asu souboru
         mov       cx,ds:[cas]              ; ‡as souboru
         mov       dx,ds:[datum]            ; datum souboru
         mov       ax,5701h
         int       21h                      ; nastaven¡ data a ‡asu souboru
         mov       si,offset WriteTxt       ; text chyby uzav©en¡ souboru
         jc        ClosFil3                 ; chyba uzav©en¡ souboru

                                          ;* uzav©en¡ souboru
         mov       ah,3eh
         int       21h
         jc        ClosFil3                 ; chyba uzav©en¡ souboru

         mov       dx,offset jmeno
         mov       ax,4301h
         xor       cx,cx
         mov       cl,ds:[atrib]            ; atributy souboru
         int       21h                      ; nastaven¡ atribut– souboru

         mov       word ptr ds:[Ident],0
         jc        ClosFil3                 ; chyba p©i nastaven¡ atribut–

                                          ;* kontrola kontroln¡ho sou‡tu
         push      ds
         mov       ax,ds:[ChSum]            ; vypo‡ten˜ kontroln¡ sou‡et
         mov       ds,ds:[segbuf]           ; segment s na‡ten˜m adres ©em
         cmp       ax,ds:[0]                ; je kontroln¡ sou‡et OK ?
         pop       ds
         mov       si,offset chsumtxt       ; text - chyba p©enosu souboru
         stc
         jne       ClosFil3                 ; chyba kontroln¡ho sou‡tu
         clc                                ; p©¡znak operace OK

ClosFil2:inc       word ptr ds:[citfile]    ; zv˜¨en¡ ‡¡ta‡e p©enesen˜ch soubor–

                                          ;* od© dkov n¡
ClosFil3:push      si
         mov       si,offset CRTxt          ; text od© dkov n¡
         call      DispTxt                  ; od© dkov n¡ textu
         pop       si
         jnc       ClosFil4                 ; operace OK

         call      DispTxt                  ; zobrazen¡ textu chyby


ClosFil4:pop       ds
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ClosFile ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ p©ijat‚ho adres ©e
; -----------------------------------------------------------------------------

PUBLIC   ReadDir

ReadDir  PROC      NEAR

         push      ax
         push      dx
         push      si
         push      ds

                                          ;* vytvo©en¡ adres ©e (neexistuje-li)
         mov       ds,cs:[segbuf]           ; segment s na‡ten˜m adres ©em
         xor       dx,dx                    ; offset specifikace adres ©e
         mov       ah,39h                   ; AH <- 39h
         int       21h                      ; vytvo©en¡ adres ©e

                                          ;* nastaven¡ nov‚ho adres ©e
         mov       ah,3bh                   ; AH <- 3bh
         int       21h                      ; nastaven¡ nov‚ho aktiv. adres ©e
         jc        ReadDir1                 ; chyba nastaven¡ adres ©e

                                          ;* na‡ten¡ aktivn¡ho adres ©e
         push      cs
         pop       ds
         mov       si,offset AktPath        ; pracovn¡ adres ©
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         mov       ah,47h                   ; AH <- 47h
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e
         jnc       ReadDir2                 ; adres © OK

                                          ;* chyba p©¡stupu k adres ©i
ReadDir1:mov       si,offset dirtxt
         call      DispTxt

ReadDir2:pop       ds
         pop       si
         pop       dx
         pop       ax
         ret

ReadDir  ENDP


; -----------------------------------------------------------------------------
;        P©¡jem zpr vy z portu COM
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa za‡ tku zpr vy
;         AL=povel
;         CX=d‚lka zpr vy
; -----------------------------------------------------------------------------

PUBLIC   ReadTxt
ReadTxt  PROC      NEAR

                                          ;* £schova registr–
         push      di
         push      ds

         push      cs
         pop       es
         push      cs
         pop       ds

                                          ;* ‡ek n¡ na p©¡jem z hlav¡
ReadTxt1:;mov       si,offset identif        ; text identifikace

                                          ;* p©¡jem a kontrola 1 znaku
ReadTxt2:mov       di,offset bufchar        ; buffer pro p©¡jem bajtu
         mov       cx,1                     ; 1 bajt k p©¡jmu
         call      ReadCOM                  ; p©¡jem 1 znaku
         mov       al,ds:[bufchar]          ; p©ijat˜ bajt
         cmp       ds:[si],al               ; porovn n¡ 1 znaku identifikace
         jne       ReadTxt1                 ; nen¡ shoda - znovu

                                          ;* zv˜¨en¡ ukazatele identifik toru
         inc       si                       ; zv˜¨en¡ ukazatele identifikace
         cmp       si,offset povel          ; byla cel  identifikace ?
         jb        ReadTxt2                 ; nebyla je¨tˆ cel  identifikace

                                          ;* p©¡jem povelu a d‚lky zpr vy
         mov       di,offset bufchar        ; buffer pro p©¡jem z hlav¡
         mov       cx,3                     ; 3 bajty k p©¡jmu
         call      ReadCOM                  ; p©¡jem 3 bajt– z hlav¡ zpr vy

                                          ;* p©¡jem obsahu zpr vy
         mov       cx,word ptr ds:[bufchar+1] ; d‚lka zpr vy
         xor       di,di                    ; offset ukl dac¡ adresy = 0
         mov       es,ds:[segbuf]           ; segment datov‚ho bufferu
         call      ReadCOM                  ; p©¡jem obsahu zpr vy

                                          ;* nastaven¡ registr–
         xor       si,si                    ; offset za‡ tku zpr vy
         mov       al,ds:[bufchar]          ; povel zpr vy
         mov       cx,word ptr ds:[bufchar+1] ; d‚lka zpr vy

         pop       ds
         pop       di
         ret

ReadTxt  ENDP

; -----------------------------------------------------------------------------
;        P©¡jem bloku dat z portu COM od adresy ES:DI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa k ulo‘en¡ bloku dat
;        CX=po‡et bajt– k p©¡jmu
; VSTUP:ES:DI=nov  ukl dac¡ adresa dat
; -----------------------------------------------------------------------------

PUBLIC   ReadCOM
ReadCOM  PROC      NEAR

                                          ;* £schova registr–
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         jcxz      ReadCOM6                 ; nen¡ ‘ dn˜ bajt k p©¡jmu

                                          ;* inicializace registr–
         cld                                ; smˆr nahoru
         mov       bh,80h                   ; konstanta masky strobovac¡ho bitu
         mov       si,cx                    ; po‡et bajt– k p©¡jmu
         mov       dx,cs:[adrport]          ; adresa portu COM

                                          ;* ‡ek n¡ na stav bitu 0 (v klidu = 1)
ReadCOM1:mov       ch,10                    ; doba pro TIME-OUT (asi 5000)
         inc       dx                       ; vstupn¡ port COM
ReadCOM2:in        al,dx                    ; ‡ten¡ stavu portu
         test      al,bh                    ; test bitu 7
         loopnz    ReadCOM2                 ; ‡ek n¡ na bit 0
         dec       dx                       ; v˜stupn¡ port COM
         jcxz      ReadCOM7                 ; byl TIME-OUT p©¡jmu

                                          ;* potvrzen¡ p©¡jmu tetr dy
         mov       bl,al                    ; £schova ni‘¨¡ tetr dy znaku
         or        al,bh                    ; nastaven¡ strobovac¡ho bitu
         out       dx,al                    ; potvrzen¡ p©¡jmu

                                          ;* £schova ni‘¨¡ tetr dy znaku
         shr       bl,1                     ; BL >> 1 (bity 2 a‘ 5)
         shr       bl,1                     ; BL >> 1 (bity 1 a‘ 4)
         shr       bl,1                     ; BL >> 1 (bity 0 a‘ 3)

                                          ;* ‡ek n¡ na stav bitu 1
ReadCOM3:mov       ch,10                    ; doba pro TIME-OUT (asi 5000)
         inc       dx                       ; vstupn¡ port COM
ReadCOM4:in        al,dx                    ; ‡ten¡ stavu portu
         test      al,bh                    ; test bity 7
         loopz     ReadCOM4                 ; ‡ek n¡ na bit 1
         dec       dx                       ; v˜stupn¡ port COM
         jcxz      ReadCOM8                 ; byl TIME-OUT p©¡jmu

                                          ;* potvrzen¡ p©¡jmu
         xor       al,bh                    ; nulov n¡ strobovac¡ho bitu
         out       dx,al                    ; potvrzen¡ p©¡jmu

                                          ;* sestaven¡ bajtu
         add       al,al                    ; rotace na spr vnou pozici
         and       al,0f0h                  ; vy¨¨¡ tetr da bajtu
         or        al,bl                    ; slou‡en¡ s ni‘¨¡ tetr dou znaku

                                          ;* ulo‘en¡ p©ijat‚ho bajtu
         stosb                              ; ulo‘en¡ bajtu
         dec       si                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       ReadCOM1                 ; p©¡jem dal¨¡ho bajtu

                                          ;* n vrat registr–
ReadCOM6:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadCOM  ENDP

; -----------------------------------------------------------------------------

                                          ;* ‡ek n¡ na p©ipravenost 0
ReadCOM7:mov       ah,0bh                   ; AH <- 0bh
         int       21h                      ; test stavu p©eru¨en¡ BREAK
         jmp       short ReadCOM1           ; dal¨¡ ‡ek n¡ na p©ipravenost

                                          ;* ‡ek n¡ na p©ipravenost 1
ReadCOM8:mov       ah,0bh                   ; AH <- 0bh
         int       21h                      ; test stavu p©eru¨en¡ BREAK
         jmp       short ReadCOM3           ; dal¨¡ ‡ek n¡ na p©ipravenost



; *****************************************************************************
;
;                          Vys¡l n¡ soubor–
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        Vysl n¡ obsahu aktivn¡ho adres ©e
; -----------------------------------------------------------------------------

PUBLIC   SendDir
SendDir  PROC      NEAR

                                          ;* na‡ten¡ aktivn¡ho adres ©e
         mov       si,offset AktPath        ; pracovn¡ adres ©
         call      LoadDir                  ; na‡ten¡ aktivn¡ho adres ©e

                                          ;* vys¡laj¡ se i podadres ©e ?
         cmp       byte ptr ds:[SubDirs],0  ; vys¡laj¡ se i podadres ©e ?
         je        SendDir7                 ; podadres ©e se nevys¡laj¡

                                          ;* nalezen¡ prvn¡ho adres ©e
         mov       dx,offset All            ; specifikace - v¨echny adres ©e
         mov       cx,37h                   ; atributy - v¨echny polo‘ky
         mov       ah,4eh                   ; funkce nalezen¡ souboru
SendDir1:int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho adres ©e
         jc        SendDir7                 ; nen¡ dal¨¡ adres ©

                                          ;* kontrola, zda je to adres ©
         test      byte ptr ds:[95h],10h    ; byl nalezen adres © ?
         jz        SendDir6                 ; nen¡ to adres © - dal¨¡

                                          ;* ignorov n¡ adres ©– s te‡kou
         cmp       word ptr ds:[9eh],"."    ; je adres © "." ?
         je        SendDir6                 ; je adres © "." - dal¨¡ adres ©
         cmp       word ptr ds:[9eh],".."   ; je adres © ".." ?
         je        SendDir6                 ; je adres © ".." - dal¨¡ adres ©

                                          ;* £schova tabulky DTA
         mov       cx,22                    ; po‡et slov k £schovˆ
         mov       si,80h                   ; za‡ tek tabulky k £schovˆ
         cld                                ; smˆr nahoru
SendDir2:lodsw                              ; na‡ten¡ slova z tabulky DTA
         push      ax                       ; £schova slova do z sobn¡ku
         loop      SendDir2                 ; £schova dal¨¡ho slova do z sobn¡ku

                                          ;* nastaven¡ nov‚ho aktivn¡ho adres ©e
         mov       dx,9eh                   ; jm‚no nalezen‚ho adres ©e
         call      ChngDir                  ; zmˆna adres ©e
         jc        SendDir3                 ; chyba nastaven¡ adres ©e

                                          ;* vysl n¡ obsahu nov‚ho adres ©e
         call      SendDir                  ; vysl n¡ obsahu aktivn¡ho adres ©e
         jc        SendDir4                 ; byla chyba operace

                                          ;* n vrat p–vodn¡ho adres ©e
         mov       dx,offset subdir         ; specifikace podadres ©e
         call      ChngDir                  ; n vrat p–vodn¡ho adres ©e
         jc        SendDir3                 ; chyba nastaven¡ adres ©e

                                          ;* opˆtovn‚ na‡ten¡ aktivn¡ho adres ©e
         mov       si,offset AktPath        ; aktivn¡ adres ©
         call      LoadDir                  ; na‡ten¡ aktivn¡ho adres ©e
         jnc       SendDir4                 ; operace OK

                                          ;* hl ¨en¡ chyby nastaven¡ adres ©e
SendDir3:mov       si,offset dirtxt         ; chyba p©¡stupu k adres ©i
         call      DispTxt

                                          ;* n vrat tabulky DTA
SendDir4:pushf                              ; £schova registru p©¡znak–
         pop       si                       ; registr p©¡znak– do SI
         mov       cx,22                    ; po‡et slov k navr cen¡
         mov       di,80h+42                ; konec tabulky DTA
         std                                ; smˆr dol–
SendDir5:pop       ax                       ; n vrat slova ze z sobn¡ku
         stosw                              ; n vrat slova do tabulky DTA
         loop      SendDir5                 ; n vrat dal¨¡ho slova ze z sobn¡ku
         push      si                       ; uschovan˜ registr p©¡znak–
         popf                               ; n vrat registru p©¡znak–

         jc        SendDirb                 ; byla chyba operace

                                          ;* nalezen¡ dal¨¡ho adres ©e
SendDir6:mov       ah,4fh                   ; funkce nalezen¡ dal¨¡ho adres ©e
         jmp       short SendDir1           ; nalezen¡ dal¨¡ho adres ©e

; ------ vy¨lou se v¨echny soubory z aktivn¡ho adres ©e

                                          ;* nalezen¡ prvn¡ho souboru v adres ©i
SendDir7:mov       dx,offset Files          ; specifikace soubor– k vysl n¡
         mov       cx,27h                   ; atributy - v¨echny soubory
         mov       ah,4eh                   ; funkce nalezen¡ prvn¡ho souboru
SendDir8:int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         cmc
         jnc       SendDirb                 ; nenalezen dal¨¡ soubor

                                          ;* vysl n¡ souboru
         call      SendFile                 ; vysl n¡ nalezen‚ho souboru
         jc        SendDirb                 ; chyba vysl n¡ souboru

SendDir9:mov       ah,4fh                   ; funkce nalezen¡ dal¨¡ho souboru
         jmp       short SendDir8           ; nalezen¡ dal¨¡ho souboru

; ------ n vrat z procedury

SendDirb:ret

SendDir  ENDP

; -----------------------------------------------------------------------------
;        Zmˆna aktivn¡ho adres ©e na DS:DX (13 znak–)
; -----------------------------------------------------------------------------

PUBLIC   ChngDir
ChngDir  PROC      NEAR

         call      SetDir                   ; nastaven¡ nov‚ho aktiv. adres ©e
         jc        ChngDir1                 ; chyba nastaven¡ adres ©e
         mov       al,"D"                   ; p©¡kaz - zmˆna adres ©e
         mov       cx,13                    ; d‚lka zpr vy - 13 znak–
         mov       si,dx                    ; text adres ©e
         call      WritTxt                  ; vysl n¡ zpr vy DS:SI
         clc                                ; p©¡znak operace OK
ChngDir1:ret

ChngDir  ENDP

; -----------------------------------------------------------------------------
;        Vysl n¡ nalezen‚ho souboru z aktivn¡ho adres ©e
; -----------------------------------------------------------------------------
; VSTUP: CY=byla chyba operace
; -----------------------------------------------------------------------------

PUBLIC   SendFile
SendFile PROC      NEAR


         mov       word ptr ds:[ChSum],-1   ; inicializace kontroln¡ho sou‡tu

                                          ;* zobrazen¡ informace o souboru
         mov       si,9eh                   ; jm‚no souboru k vysl n¡
         call      ZobrFile                 ; zobrazen¡ p©en ¨en‚ho souboru

; ------ otev©en¡ souboru k vysl n¡

         mov       dx,9eh                   ; jm‚no souboru
         mov       ax,3d00h                 ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jc        SendFil5                 ; chyba otev©en¡ souboru
         mov       ds:[Ident],ax            ; identifik tor souboru

                                          ;* povel pro otev©en¡ souboru
         mov       si,95h                   ; atributy, ‡as, datum a jm‚no
         mov       al,"O"                   ; povel pro otev©en¡ souboru
         mov       cx,22                    ; d‚lka jm‚na souboru a atribut–
         call      WritTxt                  ; vysl n¡ povelu k otev©en¡ soub.

; ------ na‡ten¡ bloku dat k vysl n¡

SendFil2:push      ds                       ; £schova DS
         mov       bx,ds:[Ident]            ; identifik tor souboru
         mov       ds,ds:[SegBuf]           ; segment datov‚ho bufferu
         xor       dx,dx                    ; offset v datov‚m bufferu
         mov       cx,SizBuff               ; velikost bufferu
         mov       ah,3fh                   ; funkce ‡ten¡ ze souboru
         int       21h                      ; na‡ten¡ bloku dat ze souboru
         pop       ds                       ; n vrat DS
         jc        SendFil4                 ; chyba ‡ten¡ ze souboru
         mov       cx,ax                    ; po‡et na‡ten˜ch bajt–
         jcxz      SendFil4                 ; nejsou dal¨¡ data

; ------ vysl n¡ bloku dat

         push      ds                       ; £schova DS
         mov       ds,ds:[SegBuf]           ; segment datov‚ho bufferu
         xor       si,si                    ; po‡ te‡n¡ adresa v bufferu
         call      CheckSum                 ; kontroln¡ sou‡et bloku dat
         mov       al,"W"                   ; povel pro z pis dat
         call      WritTxt                  ; vysl n¡ bloku dat
         pop       ds                       ; n vrat DS
         jmp       short SendFil2           ; vysl n¡ dal¨¡ho bloku dat

; ------ uzav©en¡ souboru

SendFil4:pushf                              ; £schova p©¡znaku v˜sledku operace
         call      Close                    ; uzav©en¡ souboru
         mov       si,offset ChSum          ; kontroln¡ sou‡et
         mov       cx,2                     ; 2 bajty - kontroln¡ sou‡et
         mov       al,"C"                   ; povel k uzav©en¡ souboru
         call      WritTxt                  ; vysl n¡ povelu pro uzav©en¡ soub.
         popf
         jc        SendFil5                 ; byla chyba operace

                                          ;* ‡¡ta‡ p©enesen˜ch soubor–
         inc       word ptr ds:[CitFile]    ; zv˜¨en¡ ‡¡ta‡e p©enesen˜ch soubor–

; ------ zobrazen¡ v˜sledku p©enosu

                                          ;* od© dkov n¡ textu
SendFil5:mov       si,offset CRTxt          ; text od© dkov n¡
         jnc       SendFil6                 ; operace probˆhla OK
         mov       si,offset ChybTxt        ; text chyby
SendFil6:call      DispTxt                  ; od© dkov n¡ textu (p©¡p. chyba)
         jnc       SendFil7                 ; nebyla chyba operace

                                          ;* zobrazen¡ textu chyby
         mov       si,offset ReadxTxt       ; text - chyba ‡ten¡ ze souboru
         call      DispTxt                  ; text chyby

SendFil7:ret

SendFile ENDP

; -----------------------------------------------------------------------------
;        V˜stup zpr vy (s povelem) na port COM
; -----------------------------------------------------------------------------
; VSTUP: AL=identifik tor zpr vy
;        DS:SI=adresa obsahu zpr vy
;        CX=po‡et bajt– k vysl n¡
; VSTUP:DS:SI=nov  adresa po vysl n¡ dat
; -----------------------------------------------------------------------------

PUBLIC   WritTxt

WritTxt  PROC      NEAR

         push      cx
         push      si
         push      ds
         push      cs
         pop       ds
         mov       ds:[povel],al            ; povel
         mov       word ptr ds:[povel+1],cx ; po‡et bajt– zpr vy
         mov       cx,12
;         mov       si,offset identif0       ; z hlav¡ zpr vy
         call      WritCOM                  ; vysl n¡ zpr vy na port COM
         pop       ds
         pop       si
         pop       cx
         call      WritCOM                  ; vysl n¡ obsahu zpr vy
         ret

WritTxt  ENDP

; -----------------------------------------------------------------------------
;        V˜stup bloku dat z pamˆti na port COM
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa bloku dat
;        CX=po‡et bajt– k vysl n¡
; VSTUP:DS:SI=nov  adresa po vysl n¡ dat
; -----------------------------------------------------------------------------

PUBLIC   WritCOM
WritCOM  PROC      NEAR

                                          ;* £schova registr–
         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         jcxz      WritCOM6                 ; nen¡ ‘ dn˜ bajt k vysl n¡

                                          ;* inicializace registr–
         mov       bh,80h                   ; konstanta masky strobovac¡ho bitu
         mov       di,cx                    ; po‡et bajt– k vysl n¡
         mov       dx,cs:[adrport]          ; adresa portu COM

                                          ;* vysl n¡ ni‘¨¡ tetr dy bajtu
WritCOM1:mov       al,ds:[si]               ; bajt k vysl n¡
         add       al,al                    ; AL << 1 (bity 1 a‘ 4)
         add       al,al                    ; AL << 1 (bity 2 a‘ 5)
         add       al,al                    ; AL << 1 (bity 3 a‘ 6)
         and       al,78h                   ; nulov n¡ nepot©ebn˜ch bit–
         out       dx,al                    ; vysl n¡ ni‘¨¡ tetr dy bajtu

                                          ;* vysl n¡ strobovac¡ho impulsu
         or        al,bh                    ; nastaven¡ strobovac¡ho bitu 7
         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu

                                          ;* ‡ek n¡ na stav bitu 0 (v klidu = 1)
WritCOM2:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
         inc       dx                       ; vstupn¡ port COM
WritCOM3:in        al,dx                    ; ‡ten¡ stavu portu
         test      al,bh                    ; test bitu 7
         loopnz    WritCOM3                 ; ‡ek n¡ na bit 0
         dec       dx                       ; v˜stupn¡ port COM
         jcxz      WritCOM7                 ; byl TIME-OUT

                                          ;* vysl n¡ vy¨¨¡ tetr dy bajtu
         mov       al,ds:[si]               ; bajt k vysl n¡
         shr       al,1                     ; AL >> 1 (bity 3 a‘ 6)
         or        al,bh                    ; nastaven¡ strobovac¡ho bitu
         out       dx,al                    ; vysl n¡ ni‘¨¡ tetr dy bajtu

                                          ;* vysl n¡ strobovac¡ho impulsu
         xor       al,bh                    ; nulov n¡ strobovac¡ho bitu 7
         out       dx,al                    ; vysl n¡ strobovac¡ho impulsu

                                          ;* ‡ek n¡ na stav bitu 1
WritCOM4:mov       ch,10                    ; doba pro TIME-OUT odpovˆdi
         inc       dx                       ; vstupn¡ port COM
WritCOM5:in        al,dx                    ; ‡ten¡ stavu portu
         test      al,bh                    ; test bity 7
         loopz     WritCOM5                 ; ‡ek n¡ na bit 1
         dec       dx                       ; v˜stupn¡ port COM
         jcxz      WritCOM8                 ; byl TIME-OUT

                                          ;* zv˜¨en¡ ukazatel– bloku
         inc       si                       ; zv˜¨en¡ ukazatele bajt–
         dec       di                       ; ‡¡ta‡ bajt–
         jnz       WritCOM1                 ; je je¨tˆ dal¨¡ bajt

                                          ;* n vrat registr–
WritCOM6:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritCOM  ENDP

; -----------------------------------------------------------------------------

                                          ;* ‡ek n¡ na p©ipravenost 0
WritCOM7:mov       ah,0bh                   ; AH <- 0bh
         int       21h                      ; test stavu p©eru¨en¡ BREAK
         jmp       short WritCOM2           ; dal¨¡ ‡ek n¡ na p©ipravenost

                                          ;* ‡ek n¡ na p©ipravenost 1
WritCOM8:mov       ah,0bh                   ; AH <- 0bh
         int       21h                      ; test stavu p©eru¨en¡ BREAK
         jmp       short WritCOM4           ; dal¨¡ ‡ek n¡ na p©ipravenost



; *****************************************************************************
;
;                       Univerz ln¡ podprogramy
;
; *****************************************************************************



; -----------------------------------------------------------------------------
;        Zobrazen¡ jm‚na pracovn¡ho souboru DS:SI
; -----------------------------------------------------------------------------

ZobrFile PROC      NEAR

         push      ax
         push      si
         push      si
         push      ds
         push      cs
         pop       ds
         mov       si,offset aktdisk        ; aktu ln¡ disk a adres ©
         call      DispTxt                  ; zobrazen¡ textu disku
         mov       al,"\"
         cmp       ds:[si-2],al             ; byl posledn¡ znak "\" ?
         je        ZobrFil2                 ; posledn¡ znak byl "\"
         call      DispChar                 ; zobrazen¡ oddˆlovac¡ho znaku "\"
ZobrFil2:pop       ds
         pop       si
         call      DispTxt                  ; zobrazen¡ jm‚na souboru


         pop       si
         pop       ax
         ret

ZobrFile ENDP


; -----------------------------------------------------------------------------
;        Kontroln¡ sou‡et CRC bloku dat
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=za‡ tek bloku dat
;        CX=po‡et bajt–
; -----------------------------------------------------------------------------

PUBLIC   CheckSum

CheckSum PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di

         jcxz      CheckSm2                 ; nen¡ ‘ dn˜ bajt
         mov       dx,cs:[ChSum]            ; ‡¡ta‡ kontroln¡ho sou‡tu
         mov       di,cx                    ; po‡et bajt– pro kontroln¡ sou‡et
         cld                                ; smˆr nahoru

CheckSm1:lodsb                              ; a = fgetc(fp);
;         rol       dx,1
;         xor       dl,al

         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,4
         shr       al,cl                    ; a >>= 4;
         xor       al,dh                    ; d = a ^= d;
         mov       dh,al
         mov       cl,3
         ror       al,cl                    ; a = (a >> 3) | (a << 5);
         mov       ch,al                    ; f = a;
         and       al,1fh                   ; a &= 0x1f;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f;
         ror       al,1                     ; a = (a >> 1) | (a << 7);
         and       al,0f0h                  ; a &= 0xf0;
         xor       al,dl                    ; e = a ^= e;
         mov       dl,al
         mov       al,ch                    ; a = f & 0xe0;
         and       al,0e0h
         xor       al,dh                    ; a ^= d;
         mov       dh,dl                    ; d = e;
         mov       dl,al                    ; e = a;


;         loop      CheckSm1

         dec       di
         jnz       CheckSm1                 ; dal¨¡ bajt
         mov       cs:[ChSum],dx            ; ‡¡ta‡ kontroln¡ho sou‡tu

CheckSm2:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

CheckSum ENDP



; -----------------------------------------------------------------------------
;        Inicializace portu COM
; -----------------------------------------------------------------------------

PUBLIC   InitCom
InitCom  PROC      NEAR

         cli                                ; z kaz p©eru¨en¡
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      dx                       ; £schova DX
         push      es

                                          ;* nastaven¡ ©¡dic¡ho registru linky
         mov       dx,ds:[adrport]          ; adresa portu COM
         add       dx,3                     ; ©¡dic¡ registr linky
         mov       al,3                     ; m¢d 8 bit– bez parity, 1 stop-bit
         out       dx,al                    ; nastaven¡ m¢du portu

                                          ;* nastaven¡ ©¡dic¡ho registru modemu
         inc       dx                       ; ©¡dic¡ registr modemu
         in        al,dx                    ; sou‡asn˜ stav registru modemu
         and       al,3                     ; ponech  bity ©¡zen¡ modemu
         or        al,8                     ; nastaven¡ sign lu OUT2
         out       dx,al                    ; nastaven¡ ©¡dic¡ho registru modemu

                                          ;* nulov n¡ stavov‚ho registru linky
         inc       dx                       ; stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavku od reg. linky
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; resetov n¡ stavov‚ho registru

                                          ;* nulov n¡ stavov‚ho registru modemu
         inc       dx                       ; stavov˜ registr modemu
         in        al,dx                    ; zru¨en¡ po‘adavku od reg. modemu
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; resetov n¡ stavov‚ho registru

                                          ;* nastaven¡ ©¡dic¡ho reg. p©eru¨en¡
         sub       dx,5                     ; registr masky p©eru¨en¡
         mov       al,0fh                   ; povolena v¨echna p©eru¨en¡
         out       dx,al                    ; nastaven¡ ©¡dic¡ho reg. p©eru¨en¡

                                          ;* uvolnˆn¡ vys¡la‡e a p©ij¡ma‡e
         dec       dx                       ; datov˜ registr
         in        al,dx                    ; zru¨en¡ dat v p©ij¡mac¡m bufferu
         xor       al,al                    ; AL <- 0
         out       dx,al                    ; aktivace vys¡la‡e

                                          ;* nastaven¡ vektoru p©eru¨en¡
         mov       al,ds:[NumInt]           ; ‡¡slo p©eru¨en¡ COM
         mov       ah,35h
         int       21h
         mov       word ptr cs:[OldInt],bx
         mov       word ptr cs:[OldInt+2],es
         mov       dx,offset IntCom
         mov       al,ds:[NumInt]
         mov       ah,25h
         int       21h

                                          ;* nastaven¡ registru p©eru¨en¡
         mov       bl,ds:[MaskInt]          ; po‘adovan  maska registru p©eru¨.
         not       bl                       ; polarita - povolen¡ p©eru¨en¡
         in        al,[21h]                 ; registr p©eru¨en¡
         and       al,bl                    ; povolen¡ p©eru¨en¡ od portu COM
         out       [21h],al                 ; nov‚ nastaven¡ registru p©eru¨en¡

         pop       es
         pop       dx
         pop       bx
         pop       ax
         sti
         ret

InitCom  ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ od komunika‡n¡ho portu COM
; -----------------------------------------------------------------------------

public   IntCom
IntCom:                                   ;* obsluha p©eru¨en¡ od portu COM

; ------ £schova registr–

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      dx                       ; £schova DX
         push      ds                       ; £schova DS

; ------ test, zda je po‘adavek obsluhy p©eru¨en¡

IntCom1: push      cs
         pop       ds                       ; DS <- CS
         mov       dx,ds:[AdrPort]          ; adresa komunika‡n¡ho portu COM
         add       dx,2                     ; stavov˜ registr p©eru¨en¡
         in        al,dx                    ; ‡ten¡ stavov‚ho registru p©eru¨.
         test      al,1                     ; je po‘adavek obsluhy p©eru¨en¡ ?
         jnz       IntCom2                  ; nepo‘aduje se obsluha p©eru¨en¡

; ------ obsluha p©eru¨en¡

         sub       dx,2                     ; n vrat datov‚ho registru
         and       al,6                     ; pouze bity identifikace p©eru¨en¡
         cbw                                ; AX <- ‡¡slo p©eru¨en¡
         mov       bx,ax                    ; BX <- ‡¡slo p©eru¨en¡
         call      word ptr ds:[bx+AdrInt]  ; vyvol n¡ obsluhy p©eru¨en¡
         jmp       short IntCom1            ; dal¨¡ obsluha p©eru¨en¡

; ------ uvolnˆn¡ ©adi‡e p©eru¨en¡

IntCom2: mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡

; ------ n vrat registr–

         pop       ds
         pop       dx
         pop       bx
         pop       ax
         iret

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ stavem modemu
; -----------------------------------------------------------------------------

PUBLIC   IntModem
IntModem PROC      NEAR

         add       dx,6                     ; stavov˜ registr modemu
         in        al,dx                    ; zru¨en¡ po‘adavku od modemu
         ret

IntModem ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ stavem linky
; -----------------------------------------------------------------------------

PUBLIC   IntLinka
IntLinka PROC      NEAR

         add       dx,5                     ; stavov˜ registr linky
         in        al,dx                    ; zru¨en¡ po‘adavku od linky
         ret

IntLinka ENDP

; -----------------------------------------------------------------------------
;        obsluha p©eru¨en¡ od vys¡la‡e
; -----------------------------------------------------------------------------

PUBLIC   IntVysil
IntVysil PROC      NEAR

                                          ;* test, zda je uschovan˜ nˆjak˜ znak
         mov       al,ds:[VysZnak]          ; uschovan˜ znak k vysl n¡
         or        al,al                    ; je uschovan˜ znak k vysl n¡ ?
         mov       byte ptr ds:[VysZnak],0  ; zru¨en¡ uschovan‚ho znaku
         jnz       IntVys2                  ; byl uschovan˜ nˆjak˜ znak

                                          ;* obsluha vys¡l n¡ podle parametru
         xor       bx,bx                    ; BX <- 0
         mov       ah,ds:[VysPar]           ; parametry pro vys¡l n¡
         mov       bl,ah                    ; parametry pro vys¡l n¡
         add       bx,bx                    ; parametry pro vys¡l n¡ * 2
         call      word ptr ds:[bx+AdrVys]  ; p©¡prava znaku k vysl n¡
         mov       cs:[VysPar],ah           ; parametry pro vys¡l n¡

                                          ;* vysl n¡ znaku na port COM
IntVys2: out       dx,al                    ; vysl n¡ znaku na port
         ret

IntVysil ENDP

; -----------------------------------------------------------------------------

                                          ;* 0=vys¡la‡ neaktivn¡
                                          ;* 7=‡ek  se na echo zbytku dat
Vys0:
Vys7:    xor       al,al                    ; vys¡la‡ neaktivn¡ - znak NUL
         ret

                                          ;* 1=m  se vyslat znak BEGIN
Vys1:    inc       ah                       ; p©¡znak 2 - ‡ek  se na echo BEGIN

                                          ;* 2=‡ek  se na echo BEGIN
Vys2:    mov       al,BEGIN                 ; znak BEGIN
         ret

                                          ;* 3=m  se vyslat povel
Vys3:    mov       al,ds:[VysPovel]         ; povel zpr vy
         inc       ah                       ; p©¡znak 4 - m  se vyslat adr. LOW
         ret

                                          ;* 4=m  se vyslat adresa LOW
Vys4:    mov       al,byte ptr ds:[VysChar] ; ni‘¨¡ bajt adresy
         jmp       short VysKod0            ; k¢dov n¡ znaku k vysl n¡

                                          ;* 5=m  se vyslat adresa HIGH
Vys5:    mov       al,byte ptr ds:[VysChar+1] ; vy¨¨¡ bajt adresy
         jmp       short VysKod0            ; k¢dov n¡ znaku k vysl n¡

                                          ;* 6=vys¡laj¡ se data
Vys6:    lds       bx,ds:[ComBuf]           ; komunika‡n¡ buffer
         add       bx,cs:[VysChar]          ; adresa znaku v bufferu
         mov       al,ds:[bx]               ; znak k vysl n¡
         inc       word ptr cs:[VysChar]    ; zv˜¨en¡ adresy v bufferu
         dec       word ptr cs:[VysNum]     ; sn¡‘en¡ ‡¡ta‡e bajt– k vysl n¡
         jnz       VysKod                   ; k¢dov n¡ znaku k vysl n¡
                                            ; konec dat - ‡ek  se na echo

VysKod0: inc       ah                       ; zv˜¨en¡ ‡¡sla p©¡znaku

                                          ;* k¢dov n¡ znaku AL k vysl n¡
VysKod:  cmp       al,DatByte               ; je to zak zan˜ znak ?
         jae       VysKod1                  ; nen¡ to zak zan˜ znak
         not       al                       ; inverze znaku
         mov       byte ptr cs:[VysZnak],al ; £schova znaku k vysl n¡
         mov       al,SHS                   ; p©echodn˜ p©esmyka‡
VysKod1: ret

                                          ;* 8=m  se vyslat znak ENDS
Vys8:    mov       al,ENDS                  ; ukon‡ovac¡ znak ENDS
         xor       ah,ah                    ; p©¡znak 0 - vys¡l n¡ neaktivn¡
         ret

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ p©i p©¡jmu znaku
; -----------------------------------------------------------------------------

PUBLIC   IntPrij
IntPrij  PROC      NEAR

         in        al,dx                    ; ‡ten¡ p©ijat‚ho bajtu
         ret

IntPrij  ENDP

; -----------------------------------------------------------------------------

AdrInt   label     word                   ;* adresy obsluh p©eru¨en¡ COM
         dw        offset IntModem          ; 000: p©eru¨en¡ stavem modemu
         dw        offset IntVysil          ; 010: p©eru¨en¡ od vys¡la‡e
         dw        offset IntPrij           ; 100: p©eru¨en¡ od p©ij¡ma‡e
         dw        offset IntLinka          ; 110: p©eru¨en¡ stavem linky

; -----------------------------------------------------------------------------

AdrVys   label     word                   ;* adresy obsluh vysl n¡ znaku
         dw        offset Vys0              ;  0 = vys¡l n¡ neaktivn¡
         dw        offset Vys1              ;  1 = m  se vyslat BEGIN
         dw        offset Vys2              ;  2 = ‡ek  se na echo BEGIN
         dw        offset Vys3              ;  3 = m  se vyslat povel
         dw        offset Vys4              ;  4 = m  se vyslat adresa LOW
         dw        offset Vys5              ;  5 = m  se vyslat adresa HIGH
         dw        offset Vys6              ;  6 = vys¡laj¡ se data
         dw        offset Vys7              ;  7 = ‡ek  se na echo zbytku dat
         dw        offset Vys8              ;  8 = m  se vyslat ENDS

; -----------------------------------------------------------------------------
;        Uzav©en¡ otev©en‚ho souboru
; -----------------------------------------------------------------------------

PUBLIC   Close
Close    PROC      NEAR

         push      ax
         push      bx
         mov       bx,ds:[Ident]            ; identifik tor souboru
         or        bx,bx                    ; je otev©en nˆjak˜ soubor ?
         jz        Close1                   ; nen¡ otev©en ‘ dn˜ soubor
         mov       ah,3eh                   ; funkce uzav©en¡ souboru
         int       21h                      ; uzav©en¡ souboru
         mov       word ptr ds:[Ident],0    ; zru¨en¡ identifik toru souboru
Close1:  pop       bx
         pop       ax
         ret

Close    ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ nov‚ho adres ©e DS:DX
; -----------------------------------------------------------------------------

PUBLIC   SetDir
SetDir   PROC      NEAR

         push      ax
         mov       ah,3bh
         int       21h
         pop       ax
         ret

SetDir   ENDP

; -----------------------------------------------------------------------------
;        Na‡ten¡ aktivn¡ho adres ©e DS:SI
; -----------------------------------------------------------------------------

PUBLIC   LoadDir
LoadDir  PROC      NEAR

         push      ax
         push      dx
         push      si
         mov       byte ptr ds:[si],"\"     ; £vodn¡ znak adres ©e "\"
         inc       si
         mov       ah,47h                   ; AH <- 47h
         xor       dl,dl                    ; DL <- 0 aktivn¡ disk
         int       21h                      ; na‡ten¡ aktivn¡ho adres ©e
         pop       si
         pop       dx
         pop       ax
         ret

LoadDir  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ textu CS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispTxt
DispTxt  PROC      NEAR

         pushf
         push      ax
         cld
DispTxt1:mov       al,cs:[si]               ; znak k zobrazen¡
         inc       si                       ; zv˜¨en¡ ukazatele textu
         or        al,al                    ; je konec textu ?
         jz        DispTxt2                 ; je konec textu
         call      DispChar                 ; zobrazen¡ znaku
         jmp       short DispTxt1           ; dal¨¡ znak k zobrazen¡
DispTxt2:pop       ax
         popf
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Dek¢dov n¡ ‡¡sla AX od adresu CS:SI dol–
; -----------------------------------------------------------------------------

PUBLIC   DekNum
DekNum   PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

DekNum1: xor       dx,dx                    ; DX:AX = ‡¡slo
         mov       cx,10                    ; dˆlitel
         div       cx                       ; v˜po‡et ‡¡slice
         add       dl,"0"                   ; korekce na ‡¡slici
         mov       cs:[si],dl               ; ulo‘en¡ ‡¡slice
         dec       si                       ; sn¡‘en¡ ukazatele textu
         or        ax,ax                    ; je je¨tˆ dal¨¡ ‡¡slo ?
         jnz       DekNum1                  ; je je¨tˆ ‡¡slo
         mov       byte ptr cs:[si]," "     ; £vodn¡ mezera

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

PUBLIC   DispChar
DispChar PROC      NEAR

         push      ax
         push      dx
         mov       ah,2
         mov       dl,al                    ; znak k zobrazen¡
         int       21h                      ; zobrazen¡ znaku
         pop       dx
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;        Obsluha hodin INT 08h
; -----------------------------------------------------------------------------

PUBLIC   Int08
Int08    PROC      FAR

         jmp       dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;                                 DATA
; -----------------------------------------------------------------------------

UvTxt    db        'TransCOM V1.10; (c) Miroslav Nemecek',13,10
         db        '------------------------------------',13,10,0

MemTxt   db        'Nedostatek pameti !',13,10,0

ErrTxt   db        'Zadejte:  soubor_k_vyslani (bez zadani bude prijem)',13,10
         db        '          /1 az /4 - cislo portu COM (implicitne COM1)',13,10
         db        '          /s - vysilaji se i vsechny podadresare',13,10
         db        0

DiskTxt  db        'Chybne zadani disku - disk neexistuje !',13,10,0
PathTxt  db        'Chybne zadani adresare - adresar nenalezen !',13,10,0


PortTxt  db        'Port COM'
PortTxt0 db        '1 neni nainstalovan !',13,10,0

vystxt   db        'Vysilam soubory na port COM'
vystxt0  db        '1',13,10,13,10,0

prijtxt  db        'Prijimam soubory z portu COM'
prijtxt0 db        '1',13,10,13,10,0


WriteTxt db        ' ... CHYBA !',13,10,7,'Chyba zapisu do souboru !',13,10,0
ReadxTxt db        7,'Chyba cteni ze souboru !',13,10,0
DirTxt   db        7,'Chyba pristupu k adresari !',13,10,0
fulltxt  db        ' ... CHYBA !',13,10,7,'Disk je plny !',13,10,0
chsumtxt db        7,'Chyba pri prenosu souboru !',13,10,0

BreakTxt db        'Prenos prerusen ...',13,10,0

ChybTxt  db        ' ... CHYBA !',13,10,0

PocetTxt db        'Pocet '
PocetTx1 db        'prijatych souboru ........'
CRTxt    db        13,10,0
PocetTx2 db        'vyslanych'
PocetTx3 label     byte

ChSum    dw        -1                       ; ‡¡ta‡ kontroln¡ho sou‡tu souboru

Old08    dd        0                        ; p–vodn¡ adresa obsluhy INT 08h

OldInt   dd        0                        ; p–vodn¡ adresa obsluhy portu COM
NumInt   db        0ch                      ; ‡¡slo p©eru¨en¡ od portu COM (1,3)
MaskInt  db        10h                      ; maska p©eru¨en¡ od portu COM (1,3)

Ident    dw        0                        ; identifik tor otev©en‚ho souboru

subdir   db        '..',0                   ; specifikace podadres ©e

povel    db        0                        ; buffer pro povel
bufchar  db        3 dup(0)                 ; buffer pro p©¡jem povelu

                                          ;* £schova p©¡znak– souboru
Atrib    db        0                        ; atributy souboru
Cas      dw        0                        ; ‡as souboru
Datum    dw        0                        ; datum souboru
Velikost dd        0                        ; rezerva pro velikost souboru
Jmeno    db        13 dup(0)                ; jm‚no souboru

SetVys   db        0                        ; <> 0 = p©¡znak vys¡l n¡ soubor–
SubDirs  db        0                        ; <> 0 = p©¡znak podadres ©–

AdrPort  dw        0                        ; adresa portu COM

SegBuf   dw        0                        ; segment datov‚ho bufferu

CitFile  dw        0                        ; ‡¡ta‡ p©enesen˜ch soubor–



ComBuf   dd        0                        ; adresa komunika‡n¡ho bufferu


VysPar   db        0                        ; parametr vys¡l n¡
                                            ;  0 = vys¡l n¡ neaktivn¡
                                            ;  1 = m  se vyslat BEGIN
                                            ;  2 = ‡ek  se na echo BEGIN
                                            ;  3 = m  se vyslat povel
                                            ;  4 = m  se vyslat adresa LOW
                                            ;  5 = m  se vyslat adresa HIGH
                                            ;  6 = vys¡laj¡ se data
                                            ;  8 = ‡ek  se na echo zbytku dat
                                            ;  9 = m  se vyslat ENDS

VysZnak  db        0                        ; uschovan˜ znak k vysl n¡
VysShft0 db        0                        ; 1=trval˜ p©esmyka‡ byl nastaven
VysShft1 db        0                        ; 1=je trval˜ p©esmyka‡

VysPovel db        0                        ; povel k vysl n¡
VysNum   dw        0                        ; po‡et zbyl˜ch bajt– k vysl n¡
VysChar  dw        0                        ; ukazatel bajt– v bufferu
VysVerif dw        0                        ; ukazatel verifikovan˜ch bajt–

VerfVPar db        0                      ;* parametry pro VERIFY vys¡l n¡
                                            ; 0 = verify se neprov d¡
                                            ; 1 = ‡ek  se na p©¡jem BEGIN
                                            ; 2 = ‡ek  se na p©¡jem povelu
                                            ; 3 = ‡ek  se na p©¡jem adresy LOW
                                            ; 4 = ‡ek  se na p©¡jem adresy HIGH
                                            ; 5 = ‡ek  se na p©¡jem dat
                                            ; 6 = byl p©ijat znak ENDS


VerfPPar db        0                      ;* parametry pro VERIFY p©i p©¡jmu
                                            ; 0 = verify se neprov d¡
                                            ; 1 = m  se vyslat BEGIN
                                            ; 2 = m  se vyslat znak povelu
                                            ; 3 = m  se vyslat adresa LOW
                                            ; 4 = m  se vyslat adresa HIGH
                                            ; 5 = vys¡laj¡ se data
                                            ; 6 = m  se vyslat znak ENDS


PrijPar  db        0                      ;* parametr p©¡jmu
                                            ;  0 = p©¡jem neaktivn¡
                                            ;  1 = ‡ek  se na p©¡jem BEGIN
                                            ;  2 = ‡ek  se na p©¡jem povelu
                                            ;  3 = ‡ek  se na p©¡jem adresy LOW
                                            ;  4 = ‡ek  se na p©¡jem adresy HIGH
                                            ;  5 = p©ij¡maj¡ se data


Root     db        '\',0                    ; specifikace z kladn¡ho adres ©e
All      db        '*.*',0                  ; specifikace - v¨echny soubory

NewPath  db        13 dup(0)                ; nov˜ adres © (pro p©epnut¡)

                                          ;* uschovan˜ aktivn¡ disk a adres ©
OldDisk  db        0                        ; p–vodn¡ aktivn¡ disk
OldPath  db        70 dup(0)                ; p–vodn¡ aktivn¡ adres ©

Files    db        '????????.???',0         ; po‘adovan‚ soubory

                                          ;* cesta pro zobrazen¡ soubor–
AktDisk  db        'A:'                     ; aktivn¡ disk
AktPath  db        70 dup(0)                ; aktu ln¡ adres ©

Konec    label     byte                     ; konec programu

code     ENDS
         END       Start


bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

MAXTRACK EQU       99                       ; maxim ln¡ po‡et stop

; ------ symboly v˜stupn¡ch za©¡zen¡ (0=nen¡ zn mo)

OutPC    EQU       1                        ; PC speaker
OutMIDI  EQU       2                        ; MIDI port Sound Blaster
OutSBFM  EQU       3                        ; Sound Blaster FM
OutSBPro EQU       4                        ; Sound Blaster Pro FM
OutSB16  EQU       5                        ; Sound Blaster 16 FM
OutWave  EQU       6                        ; Wave Blaster
OutAWE32 EQU       7                        ; Sound Blaster AWE 32
OutGM    EQU       8                        ; General Midi
OutMT32  EQU       9                        ; Rolland MT-32
OutGS    EQU       10                       ; GS Midi

Code     SEGMENT
         ASSUME    cs:Code,ds:Data,ss:Zasob

; ------ inicializace registr–

Start:   mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegmPSP],es          ; segment PSP

; ------ rozbor p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor p©¡kazov‚ho © dku
         jnc       Start1                   ; rozbor je OK
         mov       si,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu
         mov       si,offset HelpTxt        ; text n povˆdy
         call      DispTxt                  ; zobrazen¡ chyby
         mov       al,1                     ; chyba syntaxe
         jmp       Konec                    ; konec programu

; ------ zobrazen¡ £vodn¡ho textu (jen nen¡-li zkr cen˜ v˜pis)

Start1:  test      byte ptr ds:[Param],bit3 ; je zkr cen˜ v˜pis ?
         jnz       Start12                  ; je zkr cen˜ v˜pis
         mov       si,offset UvTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ detekce portu (jen nen¡-li testovac¡ v˜pis)

Start12: test      byte ptr ds:[Param],bit2 ; je testovac¡ re‘im ?
         jnz       Start16                  ; je testovac¡ re‘im
         call      DetPort                  ; detekce v˜stupn¡ho portu
         jnc       Start14                  ; je to OK
Start13: mov       si,offset ErrPort
Start132:call      DispTxt                  ; chyba - port nen¡ p©¡stupn˜
         jmp       Konec

; ------ zobrazen¡ v˜stupn¡ho za©¡zen¡

Start14: mov       si,offset VystTxt
         call      DispTxt                  ; £vodn¡ ‡ st hl ¨en¡
         mov       cl,ds:[OutMid]           ; v˜stupn¡ za©¡zen¡
         mov       ch,0
Start15: inc       si
         cmp       byte ptr ds:[si-1],0
         jne       Start15
         loop      Start15
         call      DispTxt                  ; druh  ‡ st hl ¨en¡

; ------ detekce adresy portu

         call      DetAdr                   ; detekce adresy portu
         jc        Start13                  ; chyba

; ------ zobrazen¡ adresy

         mov       di,offset VystAdr1
         mov       ax,ds:[OutPort]
         call      DekHex                   ; dek¢dov n¡ adresy
         mov       si,offset VystAdr
         call      DispTxt                  ; zobrazen¡ hl ¨en¡

; ------ test v˜stupn¡ho portu

         call      TestPort                 ; test v˜stupn¡ho portu
         jc        Start13                  ; chyba

; ------ zmen¨en¡ bloku programu

Start16: mov       es,ds:[SegmPSP]          ; segment PSP
         mov       bx,SEG Zasob + 200h*2/16 + 1
         sub       bx,ds:[SegmPSP]          ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu

; ------ vytvo©en¡ bufferu

         mov       bx,-1
         mov       ah,48h
         int       21h
         mov       ah,48h
         int       21h                      ; vytvo©en¡ datov‚ho bloku
         mov       si,offset ErrMem         ; chyba - nedostatek pamˆti
         jc        Start132                 ; chyba
         cmp       bx,1000h                 ; minim lnˆ asi tak 64 KB
         jb        Start132                 ; chyba pamˆti
         mov       ds:[SegmDatA],ax         ; adresa bufferu
         add       ax,bx
         mov       ds:[SegmDatE],ax         ; konec bufferu



Start18:


Start2:

; ------ na‡ten¡ souboru MID

Start4:  call      LoadMID                  ; na‡ten¡ souboru MID
         jc        Start8                   ; chyba - dal¨¡ soubor

; ------ ovˆ©en¡ struktury souboru MID

         call      TestMID                  ; ovˆ©en¡ struktury MID






; ------ p©¡prava pro dal¨¡ soubor MID

Start8:


; ------ konec programu (AL=n vratov˜ chybov˜ k¢d)

         mov       al,0                     ; p©¡znak operace OK
Konec:   mov       ah,4ch
         int       21h

; *****************************************************************************
;
;                    Otev©en¡, na‡ten¡ a ovˆ©en¡ souboru MID
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        na‡ten¡ souboru MID do pamˆti (CY=chyba)
; -----------------------------------------------------------------------------

LoadMid  PROC      NEAR

; ------ otev©en¡ souboru MID

         mov       dx,offset SoubMidB       ; jm‚no souboru MID
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru MID
         xchg      ax,bx                    ; BX <- identifik tor souboru
         jnc       LoadMid1                 ; soubor otev©en OK
         mov       si,offset ErrFnd
LoadMid0:call      DispTxt
         stc
         ret

; ------ p©¡prava ukazatele ukl dac¡ adresy

LoadMid1:mov       di,ds:[SegmDatA]         ; segment bufferu k na‡ten¡ souboru
         xor       dx,dx                    ; offset bufferu k na‡ten¡ souboru

LoadMid2:mov       word ptr ds:[SegmDatK],dx ; konec dat v bufferu
         mov       word ptr ds:[SegmDatK+2],di

; ------ po‡et bajt– k na‡ten¡ pro dal¨¡ operaci

         mov       cx,ds:[SegmDatE]         ; adresa konce bufferu
         sub       cx,di                    ; zbytek bufferu
         cmp       cx,0ff00h/16
         jbe       LoadMid3
         mov       cx,0ff00h/16             ; omezen¡ bufferu
LoadMid3:shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; po‡et bajt– k na‡ten¡

; ------ na‡ten¡ bloku dat

         push      ds
         mov       ds,di                    ; DS <- adresa bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat
         pop       ds
         jc        LoadMid4                 ; chyba ‡ten¡
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jz        LoadMid4                 ; nebylo nic na‡teno

; ------ posun ukl dac¡ adresy

         add       dx,ax                    ; posun adresy
         and       dx,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         add       di,ax                    ; posun segmentu adresy
         jmp       short LoadMid2           ; dal¨¡ data

; ------ uzav©en¡ souboru (CY=chyba ‡ten¡)

LoadMid4:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
         mov       si,offset ErrRead        ; chyba ‡ten¡
         jc        LoadMid0                 ; chyba ‡ten¡

; ------ ovˆ©en¡ identifikace souboru

         mov       si,offset ErrIdnt        ; chybn  identifikace
         mov       es,ds:[SegmDatA]         ; adresa bufferu
         mov       ax,es                    ; AX <- segment bufferu
         cmp       ax,word ptr ds:[SegmDatK+2] ; bylo nˆco na‡teno ?
         jae       LoadMid0                 ; nebylo nic na‡teno
         xor       di,di                    ; DI <- 0
         cmp       word ptr es:[di],"TM"
LoadMid5:jne       LoadMid0
         cmp       word ptr es:[di+2],"dh"  ; identifikace souboru "MThd"
         jne       LoadMid5
         cmp       word ptr es:[di+4],0
         jne       LoadMid5
         cmp       word ptr es:[di+6],600h  ; d‚lka dat z hlav¡ mus¡ b˜t 6 Bajt–
         jne       LoadMid5
         ret

LoadMid  ENDP

; -----------------------------------------------------------------------------
;        ovˆ©en¡ struktury MID a p©¡prava parametr–
; -----------------------------------------------------------------------------

TestMid  PROC      NEAR

; ------ test typu souboru

         mov       es,ds:[SegmDatA]         ; adresa bufferu
         mov       ax,es:[8]                ; typ souboru
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         cmp       ax,1                     ; typ 0 nebo 1
         jbe       TestMid1                 ; typ souboru je OK
         mov       si,offset ErrTyp         ; chybn˜ typ souboru
         call      DispTxt

; ------ na‡ten¡ po‡tu stop

TestMid1:mov       ax,es:[10]               ; po‡et stop
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         cmp       ax,MAXTRACK              ; maxim ln¡ po‡et stop
         jbe       TestMid2                 ; po‡et stop je OK
         mov       ax,MAXTRACK              ; omezen¡ po‡tu stop
         mov       si,offset ErrTrck        ; chybn˜ po‡et stop
         call      DispTxt
TestMid2:mov       ds:[NumTrack],ax         ; po‡et stop

; ------ na‡ten¡ ‡asov‚ b ze

         mov       ax,es:[12]               ; ‡asov  b ze
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         cmp       ax,24                    ; minim ln¡ ‡asov  b ze
         jae       TestMid3                 ; b ze je OK
         mov       si,offset ErrBase        ; chybn  ‡asov  b ze
         call      DispTxt
         mov       ax,24                    ; omezen¡ ‡asov‚ b ze
TestMid3:mov       ds:[TimeBase],ax         ; ‡asov  b ze





         ret

TestMid  ENDP

; *****************************************************************************
;
;                        Obsluha za©¡zen¡ na n¡zk‚ £rovni
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        detekce v˜stupn¡ho portu (CY=nen¡ ‘ dn‚ za©¡zen¡)
; -----------------------------------------------------------------------------

DetPort  PROC      NEAR

         cmp       byte ptr ds:[OutMid],0   ; je v˜stupn¡ za©¡zen¡ definov no ?
         jne       DetPort4                 ; za©¡zen¡ je definov no
         mov       byte ptr ds:[OutMid],OutGM ; v˜stup p©es General Midi

DetPort4:clc
         ret

DetPort  ENDP

; -----------------------------------------------------------------------------
;        detekce adresy portu (CY=port nenalezen)
; -----------------------------------------------------------------------------

DetAdr   PROC      NEAR

         cmp       word ptr ds:[OutPort],0  ; je v˜stupn¡ adresa zad na ?
         jne       DetAdr4                  ; v˜stupn¡ adresa zad na
         mov       word ptr ds:[OutPort],330h ; implicitn¡ adresa

DetAdr4: clc
         ret

DetAdr   ENDP

; -----------------------------------------------------------------------------
;        test v˜stupn¡ho portu (CY=chyba)
; -----------------------------------------------------------------------------

TestPort PROC      NEAR

         call      WaitMPU                  ; test p©ipravenosti MPU
         ret

TestPort ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost MPU k p©¡jmu dat (CY=p©ete‡en¡)
; -----------------------------------------------------------------------------

WaitMPU  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ ‡ek n¡ na p©ipravenost MPU

         mov       dx,ds:[OutPort]          ; v˜stupn¡ adresa portu
         inc       dx                       ; stavov˜ registr portu
         mov       cx,10000                 ; asi tolik k ‡ek n¡ maxim lnˆ
WaitMPU2:in        al,dx                    ; ‡ten¡ stavov‚ho portu
         test      al,bit6                  ; je MPU p©ipraven ?
         loopnz    WaitMPU2                 ; ‡ek n¡ na p©ipravenost MPU
         cmp       cx,1                     ; je p©ete‡en¡ ‡ek n¡ ?

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

WaitMPU  ENDP

; *****************************************************************************
;
;                              Obsluha zobrazen¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ DS:SI na chybov‚ za©¡zen¡
; -----------------------------------------------------------------------------

DispErr  PROC      NEAR

; ------ identifik tor chybov‚ho za©¡zen¡

         push      bx
         mov       bx,2                     ; identifik tor StdErr
         jmp       short DispTxt1

DispErr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ DS:SI na v˜stupn¡ za©¡zen¡
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ identifik tor v˜stupn¡ho za©¡zen¡

         push      bx
         mov       bx,1                     ; identifik tor StdOut

; ------ £schova registr–

DispTxt1:push      ax
         push      cx
         push      dx
         push      si

; ------ stanoven¡ d‚lky textu ASCIIZ

         mov       dx,si                    ; DX <- za‡ tek textu
         xor       cx,cx                    ; CX <- ‡¡ta‡ d‚lky textu
         cld
DispTxt2:lodsb                              ; na‡ten¡ dal¨¡ho znaku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e d‚lky textu
         or        al,al                    ; je konec textu ?
         jnz       DispTxt2                 ; dal¨¡ znak
         dec       cx                       ; oprava d‚lky textu

; ------ v˜stup textu DS:DX/CX

         mov       ah,40h
         int       21h                      ; v˜stup textu na za©¡zen¡

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax

         pop       bx
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova HEX AX do bufferu DI
; -----------------------------------------------------------------------------

DekHex   PROC      NEAR

         call      DekHex4

DekHex4: xchg      al,ah
         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DekHex6
         pop       ax

DekHex6: push      ax
         and       al,0fh
         cmp       al,10
         jb        DekHex8
         add       al,7
DekHex8: add       al,"0"
         mov       ds:[di],al
         inc       di
         pop       ax
         ret

DekHex   ENDP

; *****************************************************************************
;
;                         Rozbor p©¡kazov‚ho © dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku (CY=chyba)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0                     ; BH <- 0
         push      ds
         mov       ds,ds:[SegmPSP]          ; segment PSP
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku
         pop       ds

; ------ nalezen¡ za‡ tku parametru

Rozbor1: call      ParSpc                   ; vypu¨tˆn¡ mezer
         jnc       Rozbor2                  ; je nˆjak˜ znak

; ------ konec parametr– - test, zda byl zad n nˆjak˜ soubor

         cmp       byte ptr ds:[SoubMidB],1 ; zad n nˆjak˜ soubor ? (CY=ne)
Rozbor19:ret

; ------ test, zda je to parametr

Rozbor2: cmp       al,"-"                   ; je to parametr ?
         je        Rozbor4                  ; je to parametr
         cmp       al,"/"                   ; je to parametr ?
         je        Rozbor4                  ; je to parametr

; ------ test, zda je seznam

         and       byte ptr ds:[Param],not bit0 ; nen¡ seznam
         cmp       al,"@"                   ; je to seznam ?
         jne       Rozbor3                  ; nen¡ to seznam
         or        byte ptr ds:[Param],bit0 ; je to seznam
         inc       si                       ; vypu¨tˆn¡ znaku "@"

; ------ rozbor jm‚na souboru

Rozbor3: mov       di,offset SoubMidB       ; buffer jm‚na souboru
         cmp       byte ptr ds:[di],0       ; bylo ji‘ nˆco zad no ?
         stc
         jne       Rozbor19                 ; bylo ji‘ nˆco zad no - chyba
         call      RozbFil                  ; rozbor jm‚na souboru
Rozbor39:jc        Rozbor19                 ; chyba
         jmp       short Rozbor1            ; dal¨¡ rozbor

; ------ na‡ten¡ znaku parametru

Rozbor4: inc       si                       ; p©esko‡en¡ znaku "/" nebo "-"
         call      ParChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        Rozbor39                 ; nen¡ dal¨¡ znak - chyba

; ------ testovac¡ re‘im "/T"

         cmp       al,"T"
         jne       Rozbor42
         or        byte ptr ds:[Param],bit2 ; p©¡znak testovac¡ho re‘imu
         jmp       short Rozbor39

; ------ p©emapov n¡ n stroj– YAMAHA "/Y"

Rozbor42:cmp       al,"Y"
         jne       Rozbor44
         or        byte ptr ds:[Param],bit7 ; p©emapov n¡ n stroj– pro YAMAHA
         jmp       short Rozbor39

; ------ adresa portu MIDI "/A adresa"

Rozbor44:cmp       al,"A"
         jne       Rozbor46
         call      ParHex                   ; na‡ten¡ HEX k¢du adresy
         mov       ds:[OutPort],ax          ; b zov  adresa portu MIDI
         jmp       short Rozbor39

; ------ v˜stupn¡ za©¡zen¡ "/O v˜stup"

Rozbor46:cmp       al,"O"
         jne       Rozbor5
         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParChr                   ; na‡ten¡ prvn¡ho znaku
         mov       ah,al                    ; AH <- prvn¡ znak
         call      ParChr                   ; na‡ten¡ druh‚ho znaku
         xchg      al,ah

         mov       di,offset OutMidT-2      ; tabulka jmen za©¡zen¡
         mov       byte ptr ds:[OutMid],0   ; v˜stupn¡ za©¡zen¡ nedefinov no
Rozbor48:inc       di
         inc       di                       ; zv˜¨en¡ ukazatele v tabulce
         inc       byte ptr ds:[OutMid]     ; zv˜¨en¡ ukazatele ‡¡sla portu
         cmp       byte ptr ds:[di],1       ; je konec tabulky ?
         jb        Rozbor39                 ; je konec tabulky
         cmp       ax,ds:[di]               ; je to hledan‚ za©¡zen¡ ?
         jne       Rozbor48                 ; nen¡ to hledan‚ za©¡zen¡
Rozbor49:jmp       short Rozbor39           ; dal¨¡ parametr

; ------ zkr cen˜ v˜pis "/L"

Rozbor5: cmp       al,"L"
         jne       Rozbor52
         or        byte ptr ds:[Param],bit3 ; zkr cen˜ v˜pis soubor–
         jmp       short Rozbor49

; ------ obnovit hodiny z CMOS "/C"

Rozbor52:cmp       al,"C"
         jne       Rozbor54
         or        byte ptr ds:[Param],bit4 ; obnovit hodiny z CMOS
         jmp       short Rozbor49

; ------ zobrazen¡ notov‚ho z pisu "/N"

Rozbor54:cmp       al,"N"
         jne       Rozbor56
         or        byte ptr ds:[Param],bit5 ; notov˜ z pis
         jmp       short Rozbor49

; ------ pou‘¡t banku n stroj– "/B soubor"

Rozbor56:cmp       al,"B"
         jne       Rozbor58
         mov       di,offset SoubBank       ; buffer banky n stroj–
         call      RozbFil                  ; rozbor jm‚na souboru
         jc        Rozbor49                 ; chyba
         or        byte ptr ds:[Param],bit6 ; p©¡znak extern¡ banky
         jmp       short Rozbor49

; ------ zadan‚ tempo "/S tempo"

Rozbor58:cmp       al,"S"
         jne       Rozbor6
         call      ParNum                   ; rozbor ‡¡sla
         jc        Rozbor49
         mov       word ptr ds:[Tempo],ax   ; zadan‚ tempo
         or        byte ptr ds:[Param2],bit0 ; p©¡znak zad n¡ tempa
         jmp       short Rozbor49

; ------ p©ehr vat zadan‚ stopy "/P stopy"

Rozbor6: cmp       al,"P"
         jne       Rozbor7
         mov       di,offset MaskTrck
         mov       cx,MAXTRACK
Rozbor61:or        byte ptr ds:[di],bit1    ; z kaz stopy
         inc       di
         loop      Rozbor61

Rozbor62:call      ParNum                   ; na‡ten¡ ‡¡sla dal¨¡ stopy
         jc        Rozbor68                 ; nen¡ dal¨¡ stopa
         dec       ax                       ; korekce ‡¡sla stopy
         cmp       ax,MAXTRACK              ; je ‡¡slo stopy OK ?
         jae       Rozbor62                 ; neplatn‚ ‡¡slo stopy
         xchg      ax,bx                    ; BX <- ‡¡slo stopy
         and       byte ptr ds:[bx+MaskTrck],not bit1 ; povolen¡ stopy
         jmp       short Rozbor62           ; dal¨¡ stopa

Rozbor68:clc                                ; tady se chyba ignoruje
Rozbor69:jmp       short Rozbor49

; ------ prodleva mezi skladbami "/D sekund"

Rozbor7: cmp       al,"D"
         jne       Rozbor72
         call      ParNum                   ; na‡ten¡ ‡¡sla
         mov       ds:[Delay],ax            ; zadan  prodleva
         jmp       short Rozbor69

; ------ omezen¡ d‚lky skladby "/M sekund"

Rozbor72:cmp       al,"M"
         jne       Rozbor74
         call      ParNum                   ; na‡ten¡ ‡¡sla
         mov       ds:[MaxLen],ax           ; omezen¡ d‚lky skladby
         jmp       short Rozbor69

Rozbor74:


         stc                                ; p©¡znak chybn‚ho zad n¡ parametr–
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor jm‚na souboru DI (CY=nezad no)
; -----------------------------------------------------------------------------

RozbFil  PROC      NEAR

; ------ test, zda je nˆco zad no

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        RozbFil8                 ; nen¡ dal¨¡ znak
         cmp       al,"-"
         je        RozbFil1
         cmp       al,"/"
RozbFil1:stc                                ; p©¡znak chyby - nic nezad no
         je        RozbFil8                 ; nen¡ ‘ dn˜ znak

; ------ p©enesen¡ jm‚na souboru

RozbFil2:call      ParChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        RozbFil7                 ; nen¡ dal¨¡ znak
         je        RozbFil6                 ; mezera nen¡ povolena
         cmp       al,"/"
         je        RozbFil6                 ; je dal¨¡ parametr
         mov       ds:[di],al               ; ulo‘en¡ znaku
         inc       di                       ; zv˜¨en¡ ukazatele textu
         jmp       short RozbFil2           ; dal¨¡ znak

; ------ p©¡znak konce jm‚na souboru

RozbFil6:dec       si                       ; n vrat neplatn‚ho znaku
RozbFil7:clc                                ; p©¡znak operace OK
RozbFil8:mov       byte ptr ds:[di],0       ; p©¡znak konce jm‚na souboru
         ret

RozbFil  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla do AX (CY=chyba)
; -----------------------------------------------------------------------------

ParNum   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         xor       bx,bx                    ; BX <- 0 st©ada‡

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParNm                    ; na‡ten¡ prvn¡ ‡¡slice
         jc        ParNum8                  ; chyba - nen¡ nic zad no

; ------ p©id n¡ ‡¡slice ke st©ada‡i

ParNum2: push      ax
         mov       ax,10
         mul       bx                       ; vyn soben¡ st©ada‡e * 10
         pop       bx
         mov       bh,0
         add       bx,ax                    ; p©i‡ten¡ ‡¡slice ke st©ada‡i

; ------ na‡ten¡ dal¨¡ ‡¡slice

         call      ParNm                    ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       ParNum2                  ; je dal¨¡ ‡¡slice OK
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

ParNum8: xchg      ax,bx                    ; AX <- na‡ten‚ ‡¡slo
         pop       dx
         pop       bx
         ret

ParNum   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jedn‚ ‡¡slice (CY=chyba)
; -----------------------------------------------------------------------------

ParNm    PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kaz. © dku
         jc        ParNm9                   ; nen¡ platn˜ znak

         sub       al,"0"
         jc        ParNm6                   ; neplatn˜ znak
         cmp       al,10                    ; je ‡¡slice ?
         jb        ParNm8                   ; je to platn  ‡¡slice

ParNm6:  dec       si                       ; n vrat znaku
         clc                                ; p©¡znak chyby
ParNm8:  cmc                                ; CY=p©¡znak chyby
ParNm9:  ret

ParNm    ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla HEX do AX (CY=chyba)
; -----------------------------------------------------------------------------

ParHex   PROC      NEAR

; ------ £schova registr–

         push      bx
         xor       bx,bx                    ; BX <- 0 st©ada‡

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParHx                    ; na‡ten¡ prvn¡ ‡¡slice
         jc        ParHex8                  ; chyba - nen¡ nic zad no

; ------ p©id n¡ ‡¡slice ke st©ada‡i

ParHex2: shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; rotace st©ada‡e * 16
         or        bl,al                    ; p©id n¡ ‡¡slice ke st©ada‡i

; ------ na‡ten¡ dal¨¡ ‡¡slice

         call      ParHx                    ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       ParHex2                  ; je dal¨¡ ‡¡slice OK
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

ParHex8: xchg      ax,bx                    ; AX <- na‡ten‚ ‡¡slo
         pop       bx
         ret

ParHex   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho znaku v HEX k¢du (CY=chyba)
; -----------------------------------------------------------------------------

ParHx    PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kaz. © dku
         jc        ParHx9                   ; nen¡ platn˜ znak

         sub       al,"0"
         jc        ParHx6                   ; neplatn˜ znak
         cmp       al,10                    ; je ‡¡slice ?
         jb        ParHx8                   ; je to platn  ‡¡slice
         sub       al,7                     ; korekce pro HEX p¡smeno
         cmp       al,10
         jb        ParHx6                   ; nen¡ to platn  ‡¡slice
         cmp       al,16
         jb        ParHx8                   ; je to platn˜ znak OK

ParHx6:  dec       si                       ; n vrat znaku
         clc                                ; p©¡znak chyby
ParHx8:  cmc                                ; CY=p©¡znak chyby
ParHx9:  ret

ParHx    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         je        ParSpc                   ; je mezera - vypu¨tˆn¡
         jc        ParSpc2                  ; je konec p©¡kazov‚ho © dku
         dec       si                       ; n vrat posledn¡ho znaku
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku SI (CY=nen¡) -> AL
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         push      ds
         cld
         mov       ds,ds:[SegmPSP]          ; segment PSP
         lodsb                              ; na‡ten¡ znaku
         pop       ds

; ------ konverze na velk‚ p¡smeno

         call      UpCase                   ; konverze na velk‚ p¡smeno

; ------ n hrada tabul toru mezerou

         cmp       al,9                     ; je tabul tor ?
         jne       ParChr2                  ; nen¡ tabul tor
         mov       al," "                   ; n hrada mezerou

; ------ test, zda je to platn˜ znak

ParChr2: cmp       al," "                   ; je to platn˜ znak ?
         jae       ParChr4                  ; je to platn˜ znak OK
         dec       si                       ; n vrat konce © dku
ParChr4: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        konverze znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT

; ------ obecn  data

Param    db        0                        ; parametry
                                            ;   bit 0: 1=zad n seznam
                                            ;   bit 1: 1=nalezen nˆjak˜ soubor MIDI
                                            ;   bit 2: 1=testovac¡ re‘im
                                            ;   bit 3: 1=zkr cen˜ v˜pis soubor–
                                            ;   bit 4: 1=obnovit hodiny z CMOS
                                            ;   bit 5: 1=zobrazit notov˜ z pis
                                            ;   bit 6: 1=je extern¡ banka
                                            ;   bit 7: 1=mapov n¡ n stroj– YAMAHA

Param2   db        0                        ; parametry 2
                                            ;   bit 0: 1=zad no tempo

SegmPSP  dw        0                        ; segment PSP

OutPort  dw        0                        ; b zov  adresa portu MIDI (0=nen¡)

OutMid   db        0                        ; v˜stupn¡ za©¡zen¡ MIDI (0=nen¡)

OutMidT  db        'PC'                     ;   1=PC speaker
         db        'MI'                     ;   2=MIDI port Sound Blaster
         db        'SB'                     ;   3=Sound Blaster FM
         db        'SP'                     ;   4=Sound Blaster Pro FM
         db        'S6'                     ;   5=Sound Blaster 16 FM
         db        'WA'                     ;   6=Wave Blaster
         db        'AW'                     ;   7=Sound Blaster AWE 32
         db        'GM'                     ;   8=General Midi
         db        'MT'                     ;   9=Rolland MT-32
         db        'GS'                     ;  10=GS Midi
         db        0

; ------ parametry pro p©ehr v n¡ souboru MIDI

TimeBase dw        0                        ; ‡asov  b ze
Tempo    dd        0                        ; zadan‚ tempo (‡as. jednotek na krok)
Delay    dw        0                        ; prodleva mezi skladbami (sekund)
MaxLen   dw        -1                       ; maxim ln¡ d‚lka skladeb (sekund)
NumTrack dw        0                        ; po‡et stop (omezen˜, 0 povolena !)
AktTrack dw        0                        ; aktivn¡ zpracov van  stopa
CitATrck dw        0                        ; ‡¡ta‡ je¨tˆ aktivn¡ch stop (0=konec)

; ------ maska povolen˜ch stop (0=povoleno, bit0=konec, bit1=z kaz u‘ivatele)

MaskTrck db        MAXTRACK dup(0)          ; maska povolen˜ch stop

; ------ ukazatele stop

OffsTrck dw        MAXTRACK dup(0)          ; offsety ukazatel– stop
SegmTrck dw        MAXTRACK dup(0)          ; segmenty ukazatel– stop
CitLTrck dw        MAXTRACK dup(0)          ; ‡¡ta‡ zbyl˜ch dat stop LOW
CitHTrck dw        MAXTRACK dup(0)          ; ‡¡ta‡ zbyl˜ch dat stop HIGH

; ------ datov˜ buffer k na‡ten¡ souboru MIDI

SegmDatA dw        0                        ; adresa bufferu pro na‡ten¡ MIDI
SegmDatE dw        0                        ; adresa konce bufferu
SegmDatK dd        0                        ; normalizovan˜ konec dat v bufferu

; ------ texty a hl ¨en¡

UvTxt    db        'PLAYMIDI v0.1 - prehravac MIDI; (c) Miroslav Nemecek',13,10,0
HelpTxt  db        'zadejte:  soubor ...... soubor MID k prehrati',13,10
;         db        '          @soubor ..... seznam souboru MID k prehrati',13,10
;         db        '          /T .......... testovaci rezim, jen overeni struktury',13,10
;         db        '          /Y .......... premapovani banky nastroju pro YAMAHA',13,10
;         db        '          /A adr ...... adresa portu MIDI v HEX kodu (typicky 330)',13,10
;         db        '          /O vystup ... vystup na: PC ...... PC speaker',13,10
;         db        '                                   MI ...... MIDI port Sound Blaster',13,10
;         db        '                                   SB ...... Sound Blaster FM',13,10
;         db        '                                   SP ...... Sound Blaster Pro FM',13,10
;         db        '                                   S6 ...... Sound Blaster 16 FM',13,10
;         db        '                                   WA ...... Wave Blaster',13,10
;         db        '                                   AW ...... Sound Blaster AWE 32',13,10
;         db        '                                   GM ...... General Midi',13,10
;         db        '                                   MT ...... Rolland MT-32',13,10
;         db        '                                   GS ...... GS Midi',13,10
;         db        '          /L .......... zkraceny vypis informaci k souborum (jednoradkovy)',13,10
;         db        '          /C .......... obnovit hodiny z CMOS',13,10
;         db        '          /N .......... zobrazeni notoveho zapisu a ukazatele',13,10
;         db        '          /B soubor ... pouzit banku nastroju ze zadaneho souboru',13,10
;         db        '          /S tempo .... prehravat se zadanym tempem (pocet taktu za sekundu)',13,10
;         db        '          /P stopy .... prehravat pouze vyjmenovane stopy (napr.: 1 3 7 12)',13,10
;         db        '          /D sekund ... prodleva mezi skladbami v sekundach',13,10
;         db        '          /M sekund ... omezeni maximalni delky skladby v sekundach',13,10
         db        0

SoubTxt  db        '0:00:00 ................................................................. 00:00',13,10,0
ZahlTxt  db        '    Nazev stopy              Nazev nastroje          Kanal   Nastroj   Udalosti',13,10
         db        79 dup("-"),13,10,0
TiskTxt  db        79 dup(" "),13,10,0

VystTxt  db        'Vystup na: ',0
         db        'PC speaker',0
         db        'MIDI port Sound Blaster',0
         db        'Sound Blaster FM',0
         db        'Sound Blaster Pro FM',0
         db        'Sound Blaster 16 FM',0
         db        'Wave Blaster',0
         db        'Sound Blaster AWE 32',0
         db        'General Midi',0
         db        'Rolland MT-32',0
         db        'GS Midi',0
VystAdr  db        ', adresa: '
VystAdr1 db        '0000 (hex)',13,10,0


ErrPort  db        '- Vystupni port MIDI neni pristupny.',13,10,0
ErrSezn  db        '- Zadany seznam souboru nenalezen.',13,10,0
ErrFnd   db        '- Nenalezen soubor MIDI k prehravani.',13,10,0
ErrRead  db        '- Chyba cteni souboru MIDI.',13,10,0
ErrIdnt  db        '- Chybne zahlavi souboru MIDI.',13,10,0
ErrTyp   db        '- Chybny typ souboru MIDI.',13,10,0
ErrTrck  db        '- Chybny pocet stop souboru MIDI.',13,10,0
ErrBase  db        '- Chybna casova baze souboru MIDI.',13,10,0
ErrITrck db        '- Chybna identifikace stopy.',13,10,0
ErrMem   db        '- Nedostatek pameti k nacteni souboru.',13,10,0
ErrEOF   db        '- Necekany konec souboru.',13,10,0
ErrNTrck db        '- Nespravna delka stopy.',13,10,0
ErrMETA  db        '- Neznamy typ udalosti META.',13,10,0
ErrSYSX  db        '- Neznamy typ udalosti SYSEX.',13,10,0

; ------ extern¡ banka

SoubBank db        128 dup(0)               ; soubor s bankou n stroj– (0=nen¡)

; ------ soubor seznamu (je-li zad n seznam "@soubor")

SoubSezU dd        0                        ; ukazatel souboru seznamu
SoubSezI dw        0                        ; identifik tor souboru seznamu
SoubSezB db        100 dup(0)               ; buffer souboru seznamu

; ------ soubor MIDI (ze seznamu nebo z p©¡kazov‚ho © dku)

SoubMidI dw        0                        ; identifik tor souboru MIDI
SoubMidU dd        0                        ; ukazatel ukl dac¡ adresy soub.MIDI
SoubMidB db        130 dup(0)               ; jm‚no souboru MIDI (0=nezad no)
SoubMidA dw        0                        ; adresa jm‚na souboru v cestˆ

; ------ buffer DTA pro vyhled v n¡ souboru MIDI

SoubDTA  label     byte


Data     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                Z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   Stack 'STACK'

         dw        200h dup(?)

; ------ zde je definov n konec programu !!!!

Zasob    ENDS
         END       Start

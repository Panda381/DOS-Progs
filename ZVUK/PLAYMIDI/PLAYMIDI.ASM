
; -----------------------------------------------------------------------------
;                             Form t MIDI souboru
;
;   ‡¡sla jsou ve form tu vy¨¨¡ bajt/ni‘¨¡ bajt a vy¨¨¡ slovo/ni‘¨¡ slovo
;   (tedy obr cenˆ oproti INTEL)
;
; Z hlav¡ souboru (14 bajt–):
; --------------------------
;   0: (4) identifik tor souboru = "MThd"
;   4: (4) d‚lka n sleduj¡c¡ch dat v z hlav¡ = 6 (v bajtech)
;   8: (2) typ souboru = 0 a‘ 1 (0=jedna stopa, 1=v¡ce stop)
;  10: (2) po‡et stop = 1 a‘ 64
;  12: (2) ‡asov  b ze = 24 a v¡ce (po‡et tik– na 1/4 notu)
;  14:   .... n sleduj¡ jednotliv‚ stopy postupnˆ za sebou
;
; Z hlav¡ stopy (8 bajt–):
; -----------------------
;   0: (4) identifik tor stopy = "MTrk"
;   4: (4) d‚lka n sleduj¡c¡ch dat stopy (v bajtech)
;   8:   .... n sleduj¡ data jedn‚ stopy, skl daj¡c¡ se z ud lost¡
;
; Struktura jedn‚ ud losti ve stopˆ:
; ---------------------------------
;   0: (x) d‚lka ud losti (po‡et tik– na ud losti)
;            d‚lka ud na pouze ve spodn¡ch 7 bitech bajtu
;            7. bit = 1, n sleduje dal¨¡ bajt, tˆchto 7 bit– se odrotuje
;                        nahoru k vy¨¨¡m bit–m a p©id  se 7 bit– dal¨¡ho bajtu
;   x: (1) typ ud losti
;             FF=META ud lost
;                x+1: (1) typ META ud losti
;                       03=jm‚no stopy
;                           x+2: (1) d‚lka jm‚na stopy
;                           x+3: (n) text jm‚na stopy
;                       04=jm‚no n stroje
;                           x+2: (1) d‚lka jm‚na n stroje
;                           x+3: (n) text jm‚na n stroje
;                       2F=konec stopy
;                           x+2: (1) 0 (d‚lka n sleduj¡c¡ch dat = 0)
;                       51=nastaven¡ tempa
;                           x+2: (1) d‚lka dat tempa = 4
;                           x+3: (4) po‘adovan‚ tempo (po‡et takt– za minutu)
;                    jinak=neobsluhovan  ud lost
;                           x+2: (1) d‚lka dat META ud losti
;                           x+3: (n) data META ud losti
;             F7,F0=SYSEX ud lost
;                x+1: (1) d‚lka SYSEX ud losti
;                x+2: (n) data SYSEX ud losti
;
;             80 a‘ EF=definice ‡¡sla kan lu a n stroje
;                bit 0 a‘ bit3: ‡¡slo kan lu - 1 (tj. kan l 1 a‘ 16)
;                bit 4 a‘ bit7: povel
;             Dx=
;                x+1: (1)
;             Cx=nastaven¡ ‡¡sla n stroje (programu)
;                x+1: (1) ‡¡slo n stroje (programu) - 1 (tj. 1 a‘ 128)
;             1x a‘ Bx, Ex =
;                x+1: (1)
;                x+2: (1)
; -----------------------------------------------------------------------------

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

HI       EQU       256

GMBASE   EQU       330h                     ; b zov  adresa General Midi
MAXTRACK EQU       99                       ; maxim ln¡ po‡et stop

Code     SEGMENT
         ASSUME    cs:Code,ds:Data,ss:Zasob

; ------ inicializace registr–

Start:   mov       ax,SEG Data              ; datov˜ segment
         mov       ds,ax                    ; DS <- datov˜ segment
         mov       ds:[SegmPSP],es          ; segment PSP

; ------ zobrazen¡ £vodn¡ho textu

         mov       si,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava k rozboru p©¡kazov‚ho © dku (ES=segment PSP)

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bh,0                     ; BH <- 0
         mov       bl,es:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       es:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku jm‚na souboru

         cld
Start11: mov       dx,si                    ; DX <- £schova za‡ tku jm‚na
         lods      byte ptr es:[si]         ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         cmp       al," "
         je        Start11                  ; mezera se vypust¡
         cmp       al,9
         je        Start11                  ; tabul tor se vypust¡

; ------ test, zda je nˆco zad no

         or        al,al                    ; je nˆco zad no ?
         jz        Chyba0                   ; nen¡ nic zad no - n povˆda

; ------ ozna‡en¡ konce jm‚na souboru

Start12: lods      byte ptr es:[si]         ; na‡ten¡ znaku z p©¡kazov‚ho © dku
         cmp       al," "                   ; je konec jm‚na souboru ?
         ja        Start12                  ; nalezen¡ konce jm‚na souboru
         mov       byte ptr es:[si-1],0     ; ozna‡en¡ konce jm‚na souboru

; ------ vytvo©en¡ bufferu

         call      InitMem                  ; p©¡prava bufferu pamˆti
         mov       si,offset ErrMem
         jc        Chyba                    ; chyba pamˆti

; ------ ovˆ©en¡ portu GENERAL MIDI

         call      WaitMPU                  ; test portu MIDI
         mov       si,offset ErrPort
         jc        Chyba                    ; chyba portu

; ------ otev©en¡ souboru MID

         push      ds
         mov       ds,ds:[SegmPSP]          ; segment PSP
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru MID
         pop       ds
         mov       si,offset ErrFnd
         jc        Chyba                    ; chyba - soubor nenalezen
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ souboru MID (ident. BX) do pamˆti

         call      LoadMID                  ; na‡ten¡ souboru MID
         pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru MID
         popf
         jc        Chyba                    ; chyba (SI=text chyby)

; ------ ovˆ©en¡ struktury souboru MID

         call      TestMID                  ; ovˆ©en¡ struktury MID
         jc        Chyba                    ; chybn  struktura

; ------ p©¡prava adres stop

         call      PrepTrck                 ; p©¡prava adres stop
         jc        Chyba                    ; chybn  struktura






         mov       al,0                     ; p©¡znak souboru OK
         jmp       short Konec

; ------ chybov˜ n vrat z programu (SI=adresa textu hl ¨en¡)

Chyba0:  mov       si,offset HelpTxt        ; text n povˆdy
Chyba:   call      DispTxt                  ; zobrazen¡ textu hl ¨en¡
         mov       al,1                     ; p©¡znak chyby

; ------ konec programu

Konec:   mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        inicializace pamˆti (CY=chyba) (mus¡ uchovat DX !)
; -----------------------------------------------------------------------------

InitMem  PROC      NEAR

; ------ zmen¨en¡ bloku programu

         mov       bx,ss                    ; segment z sobn¡ku
         add       bx,2*200h/16+16          ; to je velikost z sobn¡ku + nˆco
         sub       bx,ds:[SegmPSP]          ; to je velikost programu
         mov       es,ds:[SegmPSP]          ; segment PSP programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku pamˆti

; ------ vytvo©en¡ nov‚ho bloku

         mov       bx,-1
         mov       ah,48h
         int       21h                      ; poskytnut¡ maxim ln¡ho bloku
         mov       ah,48h
         int       21h                      ; vytvo©en¡ maxim ln¡ho bloku
         jc        InitMem9                 ; chyba pamˆti

; ------ ulo‘en¡ parametr– bloku

         cmp       bx,100h                  ; asi tak minim ln¡ velikost
         jb        InitMem9                 ; chyba pamˆti
         mov       ds:[SegmDatA],ax         ; adresa segmentu bufferu
         mov       word ptr ds:[SegmDatK+2],ax ; segment konce dat v bufferu
         add       ax,bx                    ; adresa konce bufferu
         mov       ds:[SegmDatE],ax         ; adresa konce bufferu
                                          ;* CY=p©ete‡en¡ pamˆti
InitMem9:ret

InitMem  ENDP

; *****************************************************************************
;
;                    Otev©en¡, na‡ten¡ a ovˆ©en¡ souboru MID
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        na‡ten¡ souboru MID (BX=identifik tor) do pamˆti (CY=chyba, SI=text)
; -----------------------------------------------------------------------------

LoadMid  PROC      NEAR

; ------ p©¡prava ukazatele ukl dac¡ adresy -> DI:DX

         mov       di,ds:[SegmDatA]         ; segment bufferu k na‡ten¡ souboru
         xor       dx,dx                    ; offset bufferu k na‡ten¡ souboru
LoadMid2:mov       word ptr ds:[SegmDatK],dx ; konec dat v bufferu
         mov       word ptr ds:[SegmDatK+2],di

; ------ po‡et bajt– k na‡ten¡ pro dal¨¡ operaci -> CX

         mov       si,offset ErrMem
         mov       cx,ds:[SegmDatE]         ; adresa konce bufferu
         dec       cx                       ; rezerva
         sub       cx,di                    ; zbytek bufferu
         jbe       LoadMid4                 ; chyba pamˆti
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
         mov       si,offset ErrRead        ; chyba ‡ten¡
         jc        LoadMid4                 ; chyba ‡ten¡
         or        ax,ax                    ; bylo nˆco na‡teno ?
         jz        LoadMid6                 ; nebylo nic na‡teno

; ------ posun (a normalizace) ukl dac¡ adresy

         add       dx,ax                    ; posun adresy
         and       dx,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epo‡et na odstavce
         add       di,ax                    ; posun segmentu adresy
         jmp       short LoadMid2           ; dal¨¡ data

LoadMid4:stc                                ; p©¡znak chyby
LoadMid6:ret

LoadMid  ENDP

; -----------------------------------------------------------------------------
;        ovˆ©en¡ struktury MID a p©¡prava parametr– (-> CY=chyba, SI=text)
; -----------------------------------------------------------------------------

TestMid  PROC      NEAR

; ------ ovˆ©en¡ identifikace souboru

         mov       si,offset ErrIdnt        ; chybn  identifikace
         mov       es,ds:[SegmDatA]         ; adresa bufferu
         mov       ax,es                    ; AX <- segment bufferu
         cmp       ax,word ptr ds:[SegmDatK+2] ; bylo nˆco na‡teno ?
         jae       TestMid8                 ; nebylo nic na‡teno
         xor       di,di                    ; DI <- 0
         cmp       word ptr es:[di],"TM"
         jne       TestMid8
         cmp       word ptr es:[di+2],"dh"  ; identifikace souboru "MThd"
         jne       TestMid8
         cmp       word ptr es:[di+4],0     ; d‚lka z hlav¡ HIGH
         jne       TestMid8
         mov       ax,es:[di+6]             ; d‚lka z hlav¡ LOW
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         cmp       ax,6                     ; minim ln¡ d‚lka z hlav¡ 6 bajt–
         jb        TestMid8                 ; chyba

; ------ test typu souboru

         mov       ax,es:[di+8]             ; typ souboru
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         mov       si,offset ErrTyp         ; chybn˜ typ souboru
         cmp       ax,1                     ; typ 0 nebo 1
         ja        TestMid8                 ; chybn˜ typ souboru

; ------ na‡ten¡ po‡tu stop

         mov       ax,es:[di+10]            ; po‡et stop
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         mov       si,offset ErrTrck        ; chybn˜ po‡et stop
         or        ax,ax                    ; je nˆjak  stopa ?
         jz        TestMid8                 ; chyba - nen¡ ‘ dn  stopa
         cmp       ax,MAXTRACK              ; maxim ln¡ po‡et stop
         ja        TestMid8                 ; chybn˜ po‡et stop
         mov       ds:[NumTrack],ax         ; po‡et stop

; ------ na‡ten¡ ‡asov‚ b ze

         mov       ax,es:[di+12]            ; ‡asov  b ze
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         mov       ds:[TimeBase],ax         ; ‡asov  b ze
         mov       si,offset ErrBase        ; chybn  ‡asov  b ze
         cmp       ax,24                    ; minim ln¡ ‡asov  b ze
         jae       TestMid9                 ; ‡asov  b ze je OK

TestMid8:stc                                ; p©¡znak chyby
TestMid9:ret

TestMid  ENDP

; -----------------------------------------------------------------------------
;        p©¡prava adres stop (-> CY=chyba, SI=text)
; -----------------------------------------------------------------------------
;þ
PrepTrck PROC      NEAR

; ------ zobrazen¡ z hlav¡ k v˜pisu

         mov       si,offset ZahlTxt        ; z hlav¡
         call      DispTxt                  ; zobrazen¡ z hlav¡

         mov       word ptr ds:[DeltaMax],0 ; maxim ln¡ d‚lka stopy
         mov       word ptr ds:[DeltaMax+2],0 ; maxim ln¡ d‚lka stopy

; ------ ukazatel adres stop

         mov       cx,ds:[NumTrack]         ; po‡et stop
         mov       ds:[PlayTrck],cx         ; po‡et p©ehr van˜ch stop
         xor       bx,bx                    ; ukazatel definice stopy
         mov       es,ds:[SegmDatA]         ; segment bufferu stop
         xor       di,di                    ; offset bufferu stop
         mov       ax,es:[di+6]             ; d‚lka dat z hlav¡ LOW
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         add       di,8                     ; za‡ tek dat z hlav¡
         add       di,ax                    ; posun o data z hlav¡
         call      NormESDI                 ; normalizace adresy dat

; ------ vymaz n¡ bufferu k dek¢dov n¡ informac¡

PrepTrc2:push      di

         push      es
         push      cx

         push      ds
         pop       es
         mov       di,offset TiskTxt        ; v˜stupn¡ buffer
         mov       cx,79                    ; d‚lka bufferu
         mov       al," "                   ; mazac¡ znak mezery
         cld
         rep       stosb                    ; vymaz n¡ bufferu

         pop       cx
         pop       es

; ------ dek¢dov n¡ ‡¡sla stopy

         mov       ax,bx                    ; AX <- ukazatel definice stop
         shr       ax,1
         shr       ax,1                     ; AX <- ‡¡slo stopy - 1
         inc       ax                       ; AX <- ‡¡slo stopy
         xor       dx,dx                    ; DX <- 0
         mov       di,offset TiskTxt+1      ; konec ‡¡sla
         call      DekNum                   ; dek¢dov n¡ ‡¡sla do bufferu

         pop       di

; ------ kontrola z hlav¡ jedn‚ stopy

         mov       si,offset ErrITrck       ; chybn‚ z hlav¡ stopy
         cmp       word ptr es:[di],"TM"
         jne       PrepTrc8
         cmp       word ptr es:[di+2],"kr"  ; identifikace souboru "MTrk"
         jne       PrepTrc8

; ------ d‚lka stopy -> DX:AX

         mov       ax,es:[di+4]             ; d‚lka stopy HIGH
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         xchg      ax,dx                    ; DX <- d‚lka stopy HIGH
         mov       ax,es:[di+6]             ; d‚lka stopy LOW
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         mov       word ptr ds:[bx+CitTrack],ax ; ‡¡ta‡ dat stopy LOW
         mov       word ptr ds:[bx+CitTrack+2],dx ; ‡¡ta‡ dat stopy HIGH
         cmp       dx,0fh                   ; maxim ln¡ ‡¡ta‡ dat HIGH
         ja        PrepTrc7                 ; chybn  d‚lka stopy

; ------ adresa za‡ tku dat stopy

         add       di,8                     ; za‡ tek dat stopy
         call      NormESDI                 ; normalizace adresy dat
         mov       word ptr ds:[bx+AdrTrack],di ; ukazatel adresy dat
         mov       word ptr ds:[bx+AdrTrack+2],es ; ukazatel adresy dat

; ------ p©¡prava obsahu stopy

         call      InfTrack                 ; informace o stopˆ
         jc        PrepTrc8                 ; chyba

; ------ adresa dal¨¡ stopy

         add       di,ax                    ; posun offsetu adresy
         adc       dx,0                     ; p©enos
         xchg      dl,dh                    ; d‚lka stopy HIGH * 256
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; p©evod na segment
         mov       ax,es                    ; AX <- segment adresy
         add       ax,dx                    ; zv˜¨en¡ segmentu adresy
         jc        PrepTrc7                 ; chyba p©ete‡en¡
         mov       es,ax                    ; ES <- nov˜ segment adresy
         call      NormESDI                 ; normalizace adresy
         jc        PrepTrc7                 ; chyba p©ete‡en¡

; ------ kontrola, zda je platn  adresa

         mov       ax,es                    ; AX <- segment adresy stopy
         cmp       ax,word ptr ds:[SegmDatK+2] ; je platn  adresa ?
         jne       PrepTrc4
         cmp       di,word ptr ds:[SegmDatK] ; je platn˜ offset ?
PrepTrc4:ja        PrepTrc7                 ; chybn  adresa

; ------ zobrazen¡ textu © dku

         mov       si,offset TiskTxt        ; v˜stupn¡ buffer
         call      DispTxt                  ; zobrazen¡ textu

; ------ p©¡prava pro dal¨¡ stopu

         add       bx,4                     ; zv˜¨en¡ ukazatele v tabulce
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e stop
         jz        PrepTrc6                 ; jsou ji‘ v¨echny stopy
         jmp       PrepTrc2                 ; dal¨¡ stopa

PrepTrc6:clc                                ; p©¡znak operace OK
         ret

; ------ chyba - ne‡ekan˜ konec souboru

PrepTrc7:mov       si,offset ErrEOF         ; chyba - p©ed‡asn˜ konec souboru
PrepTrc8:stc                                ; p©¡znak chyby
PrepTrc9:ret

PrepTrck ENDP

; -----------------------------------------------------------------------------
;        informace o stopˆ ES:DI, d‚lka dat DX:AX -> CY=chyba, SI=text chyby
; -----------------------------------------------------------------------------

InfTrack PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©¡prava registr–

         xchg      ax,cx                    ; CX <- ‡¡ta‡ dat LOW
         mov       bx,dx                    ; BX <- ‡¡ta‡ dat HIGH
         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[DeltaMax],0 ; maxim ln¡ d‚lka stopy

; ------ ukazatel adres stop

         mov       cx,ds:[NumTrack]         ; po‡et stop
         mov       ds:[PlayTrck],cx         ; po‡et p©ehr van˜ch stop
         xor       bx,bx                    ; ukazatel definice stopy
         mov       es,ds:[SegmDatA]         ; segment bufferu stop
         xor       di,di                    ; offset bufferu stop
         mov       ax,es:[di+6]             ; d‚lka dat z hlav¡ LOW
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         add       di,8                     ; za‡ tek dat z hlav¡
         add       di,ax                    ; posun o data z hlav¡
         call      NormESDI                 ; normalizace adresy dat

; ------ vymaz n¡ bufferu k dek¢dov n¡ informac¡

PrepTrc2:push      di

         push      es
         push      cx

         push      ds
         pop       es
         mov       di,offset TiskTxt        ; v˜stupn¡ buffer
         mov       cx,79                    ; d‚lka bufferu
         mov       al," "                   ; mazac¡ znak mezery
         cld
         rep       stosb                    ; vymaz n¡ bufferu

         pop       cx
         pop       es

; ------ dek¢dov n¡ ‡¡sla stopy

         mov       ax,bx                    ; AX <- ukazatel definice stop
         shr       ax,1
         shr       ax,1                     ; AX <- ‡¡slo stopy - 1
         inc       ax                       ; AX <- ‡¡slo stopy
         xor       dx,dx                    ; DX <- 0
         mov       di,offset TiskTxt+1      ; konec ‡¡sla
         call      DekNum                   ; dek¢dov n¡ ‡¡sla do bufferu

         pop       di

; ------ kontrola z hlav¡ jedn‚ stopy

         mov       si,offset ErrITrck       ; chybn‚ z hlav¡ stopy
         cmp       word ptr es:[di],"TM"
         jne       PrepTrc8
         cmp       word ptr es:[di+2],"kr"  ; identifikace souboru "MTrk"
         jne       PrepTrc8

; ------ d‚lka stopy -> DX:AX

         mov       ax,es:[di+4]             ; d‚lka stopy HIGH
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         xchg      ax,dx                    ; DX <- d‚lka stopy HIGH
         mov       ax,es:[di+6]             ; d‚lka stopy LOW
         xchg      al,ah                    ; oprava po©ad¡ bajt–
         mov       word ptr ds:[bx+CitTrack],ax ; ‡¡ta‡ dat stopy LOW
         mov       word ptr ds:[bx+CitTrack+2],dx ; ‡¡ta‡ dat stopy HIGH
         cmp       dx,0fh                   ; maxim ln¡ ‡¡ta‡ dat HIGH
         ja        PrepTrc7                 ; chybn  d‚lka stopy

; ------ adresa za‡ tku dat stopy

         add       di,8                     ; za‡ tek dat stopy
         call      NormESDI                 ; normalizace adresy dat
         mov       word ptr ds:[bx+AdrTrack],di ; ukazatel adresy dat
         mov       word ptr ds:[bx+AdrTrack+2],es ; ukazatel adresy dat

; ------ p©¡prava obsahu stopy

         call      InfTrack                 ; informace o stopˆ
         jc        PrepTrc8                 ; chyba

; ------ adresa dal¨¡ stopy

         add       di,ax                    ; posun offsetu adresy
         adc       dx,0                     ; p©enos
         xchg      dl,dh                    ; d‚lka stopy HIGH * 256
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; p©evod na segment
         mov       ax,es                    ; AX <- segment adresy
         add       ax,dx                    ; zv˜¨en¡ segmentu adresy
         jc        PrepTrc7                 ; chyba p©ete‡en¡
         mov       es,ax                    ; ES <- nov˜ segment adresy
         call      NormESDI                 ; normalizace adresy
         jc        PrepTrc7                 ; chyba p©ete‡en¡

; ------ kontrola, zda je platn  adresa

         mov       ax,es                    ; AX <- segment adresy stopy
         cmp       ax,word ptr ds:[SegmDatK+2] ; je platn  adresa ?
         jne       PrepTrc4
         cmp       di,word ptr ds:[SegmDatK] ; je platn˜ offset ?
PrepTrc4:ja        PrepTrc7                 ; chybn  adresa

; ------ zobrazen¡ textu © dku

         mov       si,offset TiskTxt        ; v˜stupn¡ buffer
         call      DispTxt                  ; zobrazen¡ textu

; ------ p©¡prava pro dal¨¡ stopu

         add       bx,4                     ; zv˜¨en¡ ukazatele v tabulce
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e stop
         jz        PrepTrc6                 ; jsou ji‘ v¨echny stopy
         jmp       PrepTrc2                 ; dal¨¡ stopa

PrepTrc6:clc                                ; p©¡znak operace OK
         ret

; ------ chyba - ne‡ekan˜ konec souboru

PrepTrc7:mov       si,offset ErrEOF         ; chyba - p©ed‡asn˜ konec souboru
PrepTrc8:stc                                ; p©¡znak chyby
PrepTrc9:ret

PrepTrck ENDP

; -----------------------------------------------------------------------------
;        informace o stopˆ ES:DI, d‚lka dat DX:AX -> CY=chyba, SI=text chyby
; -----------------------------------------------------------------------------

InfTrack PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©¡prava registr–

         xchg      ax,cx                    ; CX <- ‡¡ta‡ dat LOW
         mov       bx,dx                    ; BX <- ‡¡ta‡ dat HIGH
         xor       ax,ax                    ; AX <- 0
         mov       word ptr ds:[EventCit],ax ; ‡¡ta‡ ud lost¡ ve stopˆ
         mov       word ptr ds:[EventCit+2],ax
         mov       word ptr ds:[DeltaCit],ax ; ‡¡ta‡ celkov‚ d‚lky stopy
         mov       word ptr ds:[DeltaCit+2],ax

; ------ na‡ten¡ d‚lky dat

InfTrck2:call      InfDelta                 ; na‡ten¡ d‚lky dat






; ------ n vrat registr–

InfTrck8:clc                                ; p©¡znak operace OK
InfTrck9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InfTrack ENDP

; -----------------------------------------------------------------------------
;  na‡ten¡ d‚lky ud losti ES:DI, d‚lka dat BX:CX -> DX:AX (CY=p©ed‡asn˜ konec)
; -----------------------------------------------------------------------------

InfDelta PROC      NEAR

; ------ £schova registr–

         push      si

; ------ p©¡prava registr–

         xor       dx,dx                    ; DX <- 0 ‡¡ta‡ HIGH
         xor       ax,ax                    ; AX <- 0 ‡¡ta‡ LOW

; ------ rotace st©ada‡e

InfDelt2:mov       dh,dl
         mov       dl,ah
         mov       ah,al
         mov       al,0
         shr       dx,1
         rcr       ax,1                     ; st©ada‡ * 2^7

; ------ na‡ten¡ jednoho bajtu dat

         mov       si,ax                    ; SI <- st©ada‡ LOW
         call      InfByte                  ; na‡ten¡ bajtu -> AL
         jc        InfDelt9                 ; p©ed‡asn˜ konec

; ------ p©id n¡ bajtu ke st©ada‡i

         push      ax
         and       ax,7fh
         add       si,ax                    ; SI <- p©id n¡ ke st©ada‡i
         adc       dx,0                     ; p©enos
         pop       ax

; ------ test, zda bude dal¨¡ bajt

         or        al,al                    ; bude dal¨¡ bajt ?
         xchg      ax,si                    ; AX <- st©ada‡ LOW
         js        InfDelt2                 ; bude dal¨¡ bajt

; ------ n vrat registr–

InfDelt9:pop       si
         ret

InfDelta ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu ES:DI, d‚lka dat BX:CX -> AL, CY=nen¡ dal¨¡ bajt
; -----------------------------------------------------------------------------

InfByte  PROC      NEAR

; ------ test, zda jsou dal¨¡ data

         push      ax
         mov       ax,cx                    ; AX <- ‡¡ta‡ dat LOW
         or        ax,bx                    ; jsou dal¨¡ data ?
         pop       ax
         stc                                ; p©¡znak, ‘e nejsou dal¨¡ data
         jz        InfByte9                 ; nejsou dal¨¡ data

; ------ na‡ten¡ bajtu

         mov       al,es:[di]               ; AL <- bajt dat
         sub       cx,1                     ; sn¡‘en¡ ‡¡ta‡e dat
         sbb       bx,0

; ------ zv˜¨en¡ adresy ukazatele dat

         inc       di                       ; zv˜¨en¡ ukazatele adresy
         jns       InfByte9                 ; nen¡ velk‚ ‡¡slo
         call      NormESDI                 ; normalizace adresy dat
InfByte9:ret

InfByte  ENDP

; -----------------------------------------------------------------------------
;        normalizace adresy ES:DI (CY=p©ete‡en¡ 1 MB)
; -----------------------------------------------------------------------------

NormESDI PROC      NEAR

         push      ax
         push      bx

         mov       ax,di                    ; AX <- offset adresy
         and       di,0fh                   ; normalizace offsetu
         mov       bx,es                    ; BX <- segment adresy
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod offsetu na segment
         add       ax,bx                    ; nov˜ segment
         mov       es,ax                    ; ES <- nov˜ segment
                                          ;* zde je CY=p©ete‡en¡ 1 MB
         pop       bx
         pop       ax
         ret

NormESDI ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla DX:AX do bufferu DS:DI zprava (=posledn¡ ‡¡slice)
; -----------------------------------------------------------------------------

DekNum   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ dek¢dov n¡ ‡¡sla

         mov       cx,10                    ; dˆlitel
DekNum1: xchg      ax,bx                    ; BX <- £schova ‡¡sla LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- ‡¡slo HIGH, DX <- 0
         div       cx                       ; vydˆlen¡ ‡¡sla HIGH
         xchg      ax,bx                    ; AX <- ‡¡slo LOW, BX <- nov‚ HIGH
         div       cx                       ; vydˆlen¡ ‡¡sla LOW

         add       dl,"0"                   ; korekce na ASCII ‡¡slici
         mov       ds:[di],dl               ; ulo‘en¡ ‡¡slice
         dec       di                       ; posun adresy
         mov       dx,bx                    ; DX <- nov‚ HIGH
         or        bx,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekNum1                  ; bude dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; *****************************************************************************
;
;                        Obsluha za©¡zen¡ na n¡zk‚ £rovni
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        ‡ek n¡ na p©ipravenost MPU k p©¡jmu dat (CY=p©ete‡en¡)
; -----------------------------------------------------------------------------

WaitMPU  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ ‡ek n¡ na p©ipravenost MPU

         mov       dx,GMBASE+1              ; stavov˜ registr portu
         mov       cx,20000                 ; asi tolik k ‡ek n¡ maxim lnˆ
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
;; -----------------------------------------------------------------------------
;;        zobrazen¡ textu ASCIIZ DS:SI na chybov‚ za©¡zen¡
;; -----------------------------------------------------------------------------
;
;DispErr  PROC      NEAR
;
;; ------ identifik tor chybov‚ho za©¡zen¡
;
;         push      bx
;         mov       bx,2                     ; identifik tor StdErr
;         jmp       short DispTxt1
;
;DispErr  ENDP

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

;; -----------------------------------------------------------------------------
;;        dek¢dov n¡ slova HEX AX do bufferu DI
;; -----------------------------------------------------------------------------
;
;DekHex   PROC      NEAR
;
;         call      DekHex4
;
;DekHex4: xchg      al,ah
;         push      ax
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         call      DekHex6
;         pop       ax
;
;DekHex6: push      ax
;         and       al,0fh
;         cmp       al,10
;         jb        DekHex8
;         add       al,7
;DekHex8: add       al,"0"
;         mov       ds:[di],al
;         inc       di
;         pop       ax
;         ret
;
;DekHex   ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;þ
Data     SEGMENT

SegmPSP  dw        0                        ; segment PSP

; ------ parametry pro p©ehr v n¡ souboru MIDI

TimeBase dw        0                        ; ‡asov  b ze
Tempo    dd        120                      ; zadan‚ tempo (tik– na krok)
AktTrack dw        0                        ; aktivn¡ zpracov van  stopa
PlayTrck dw        0                        ; ‡¡ta‡ je¨tˆ aktivn¡ch stop
NumTrack dw        0                        ; po‡et stop celkem (1 a‘ MAXTRACK)

; ------ ukazatele stop

AdrTrack dd        MAXTRACK dup(0)          ; ukazatel adresy stop
CitTrack dd        MAXTRACK dup(0)          ; ‡¡ta‡ zbyl˜ch dat stop

EventCit dd        0                        ; ‡¡ta‡ ud lost¡ ve stopˆ
DeltaCit dd        0                        ; ‡¡ta‡ celkov‚ d‚lky stopy
DeltaMax dd        0                        ; maxim ln¡ d‚lka stopy

; ------ datov˜ buffer k na‡ten¡ souboru MIDI

SegmDatA dw        0                        ; segment bufferu pro na‡ten¡ MIDI
SegmDatE dw        0                        ; segment konce bufferu
SegmDatK dd        0                        ; konec dat v bufferu (normaliz.)

; ------ texty a hl ¨en¡

UvTxt    db        'PLAYMIDI v0.1 - prehravac MID; (c) Miroslav Nemecek',13,10,0
HelpTxt  db        '   Zadejte jmeno souboru MID k prehrati.',13,10
         db        '   Prehravani probiha pres port GENERAL MIDI,',13,10
         db        '   adresa portu musi byt nastavena na 330h.',13,10
         db        0

ZahlTxt  db        13,10
         db        '    Nazev stopy              Nazev nastroje          Kanal   Nastroj   Udalosti',13,10
         db        '-------------------------------------------------------------------------------',13,10
         db        0

TiskTxt  db        79 dup(" "),13,10,0

ErrMem   db        '... nedostatek pameti k nacteni souboru MID',13,10,0
ErrPort  db        '... vystupni port GENERAL MIDI neni pristupny',13,10,0
ErrFnd   db        '... nenalezen soubor MID k prehravani',13,10,0
ErrRead  db        '... chyba cteni souboru MID',13,10,0
ErrIdnt  db        '... zadany soubor nema strukturu MID',13,10,0
ErrTyp   db        '... chybny typ souboru MID',13,10,0
ErrTrck  db        '... chybny pocet stop souboru MID',13,10,0
ErrBase  db        '... chybna casova baze souboru MID',13,10,0
ErrITrck db        '... chybne zahlavi stopy',13,10,0
ErrEOF   db        '... chybna struktura MID - predcasny konec souboru',13,10,0

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

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh

; ------ test, zda je nˆco zad no

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         jc        Start04                  ; nen¡ nic zad no

; ------ inicializace pracovn¡ho disku

         call      InitDisk                 ; inicializace disku

; ------ inicializace stop disku

         call      InitTrk                  ; inicializace stop disku

; ------ rozbor p©¡kazov‚ho © dku

         call      Rozbor                   ; rozbor p©¡kazov‚ho © dku
         jnc       Start1                   ; zad n¡ OK

; ------ zobrazen¡ n povˆdy

Start04: mov       dx,offset HelpTxt
         call      DispTxt
         mov       ax,4cffh
         int       21h

; ------ v˜pis informac¡ o disku

Start1:  test      byte ptr ds:[Zadano],1
         jz        Start2
         call      DispInf                  ; zobrazen¡ informac¡ o disku
;         call      DispCop                  ; zobrazen¡ Copyright

; ------ zobrazen¡ obsahu disku

Start2:  test      byte ptr ds:[Zadano],2
         jz        Start3
         call      Vypis                    ; v˜pis obsahu disku

; ------ stop p©ehr v n¡

Start3:  test      byte ptr ds:[Zadano],4
         jz        Start32
         call      StopCD                   ; zastaven¡ p©ehr v n¡

; ------ pokra‡ov n¡ p©ehr v n¡

Start32: test      byte ptr ds:[Zadano],8
         jz        Start34
         call      ContCD                   ; pokra‡ov n¡ v p©ehr v n¡

; ------ ‡ten¡ z disku

Start34:
;test      byte ptr ds:[Zadano],10h
;         jz        Start35
;         call      ReadCD                   ; ‡ten¡ z disku

; ------ p©ehr t¡ nahr vky

Start35: test      byte ptr ds:[Zadano],20h
         jz        Start36
         call      StopCD                   ; zastaven¡ p©ehr v n¡
         call      PlayCD                   ; p©ehr t¡ nahr vky

; ------ zobrazen¡ stavu

Start36: test      byte ptr ds:[Zadano],40h
         jz        Start37
         call      DispCD                   ; zobrazen¡ stavu

Start37:


; ------ test stavu disku

Start8:  call      TestCD                   ; test stavu disku
         mov       ax,4c00h                 ; 0 = p©ehr v 
         jnc       Start9                   ; p©ehr v  OK
         inc       ax                       ; 1 = nep©ehr v 
Start9:  int       21h

; -----------------------------------------------------------------------------
;        zobrazen¡ informac¡ o disku
; -----------------------------------------------------------------------------
;þ
DispInf  PROC      NEAR

; ------ zobrazen¡ textu verze

         mov       dx,offset InfoTxt1
         call      DispTxt

; ------ detekce verze ovlada‡e

         xor       bx,bx                    ; BX <- 0
         mov       al,0ch
         call      Int2F0                   ; detekce verze ovlada‡e
         or        bh,bh                    ; MAJOR verze
         jnz       DispInf1
         mov       bx,100h                  ; je to verze 1.00

; ------ zobrazen¡ ‡¡sla verze

DispInf1:mov       al,bh                    ; MAJOR verze
         mov       ah,0
         call      DispNum                  ; zobrazen¡ ‡¡sla verze MAJOR
         mov       al,"."
         call      DispChr                  ; oddˆlovac¡ te‡ka
         mov       al,bl                    ; MINOR verze
         call      Disp2Num                 ; zobrazen¡ ‡¡sla verze MINOR

; ------ dal¨¡ ‡ st textu

         mov       dx,offset InfoTxt2
         call      DispTxt

; ------ zobrazen¡ po‡tu nahr vek na disku

         mov       al,ds:[EndTrack]         ; posledn¡ stopa
         sub       al,ds:[BegTrack]         ; po‡et nahr vek - 1
         mov       ah,0
         inc       ax                       ; po‡et nahr vek na disku
         call      DispNum                  ; zobrazen¡ po‡tu nahr vek na disku

; ------ celkov  hrac¡ doba disku

         mov       ax,word ptr ds:[KonecAdr] ; adresa koncov‚ stopy
         mov       dx,word ptr ds:[KonecAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; ode‡ten¡ po‡ tku ‡asu
         sbb       dx,word ptr ds:[BeginAdr+2]

; ------ dek¢dov n¡ d‚lky disku

         mov       di,offset InfoTx42
         call      DekHodin                 ; dek¢dov n¡ hodiny
         call      DekTimeF                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF

; ------ dal¨¡ ‡ st textu

         mov       dx,offset InfoTxt4
         call      DispTxt

; ------ velikost sektoru

         mov       word ptr ds:[ZarizBuf],7 + 0*256 ; funkce zji¨tˆn¡ sektoru
         mov       word ptr ds:[ZarizBuf+2],2048 ; p©ednastaven¡ sektoru
         mov       cx,3                     ; po‡et bajt– k na‡ten¡
         call      InpIOCTL                 ; na‡ten¡ velikosti sektoru
         mov       ax,word ptr ds:[ZarizBuf+2] ; velikost sektoru
         call      DispNum                  ; zobrazen¡ velikosti sektoru

         push      ax                       ; £schova velikosti sektoru

; ------ dal¨¡ ‡ st textu

         mov       dx,offset InfoTxt5
         call      DispTxt

; ------ po‡et sektor–

         mov       byte ptr ds:[ZarizBuf],8
         mov       cx,4
         call      InpIOCTL
         mov       ax,word ptr ds:[ZarizBuf+1] ; po‡et sektor– celkem
         mov       dx,word ptr ds:[ZarizBuf+3]
         call      DispDNum                 ; zobrazen¡ po‡tu sektor–

; ------ dal¨¡ ‡ st textu

         push      dx
         mov       dx,offset InfoTxt6
         call      DispTxt
         pop       dx

; ------ velikost disku v MB

         pop       cx                       ; CX <- velikost sektoru
         call      MulCX                    ; velikost disku v B
         xchg      ax,dx
         mov       dx,bx                    ; velikost / 2^16
         mov       cx,16                    ; je¨tˆ 4 © dy, aby bylo 2^20
         call      DivCX                    ; velikost v MB
         call      DispDNum                 ; zobrazen¡ velikosti v MB

; ------ dal¨¡ ‡ st textu

         mov       dx,offset InfoTxt7
         call      DispTxt

;; ------ na‡ten¡ UPC k¢du
;
;         push      ds
;         pop       es
;         mov       di,offset ZarizBuf
;         mov       ax,0eh + 1*256
;         cld
;         stosw
;         xor       ax,ax
;         mov       cx,10/2
;         rep       stosw
;         mov       cl,11
;         call      InpIOCTL                 ; na‡ten¡ k¢du UPC
;
;; ------ zobrazen¡ k¢du UPC
;
;         mov       si,offset ZarizBuf+2
;DispInf4:cld
;         lodsb
;         push      ax
;         mov       cl,4
;         shr       al,cl
;         add       al,"0"
;         call      DispChr
;         pop       ax
;         cmp       si,offset ZarizBuf+2+7
;         jae       DispInf5
;         and       al,0fh
;         add       al,"0"
;         call      DispChr
;         jmp       short DispInf4
;
;; ------ dal¨¡ ‡ st textu
;
;DispInf5:mov       dx,offset InfoTxt8
;         call      DispTxt


         ret

DispInf  ENDP

;; -----------------------------------------------------------------------------
;;        zobrazen¡ Copyright disku
;; -----------------------------------------------------------------------------
;;
;DispCop  PROC      NEAR
;
;         mov       dx,offset CopyrTxt
;         call      DispTxt
;;þ
;         mov       cl,ds:[Disk]
;         mov       ch,0
;         mov       al,5 ;2
;         mov       si,offset Pozadav
;         mov       byte ptr ds:[si],0
;         xor       dx,dx
;         call      Int2f
;
;         mov       cx,38
;         cld
;DispCop2:lodsb
;         cmp       al," "
;         jb        DispCop3
;         cmp       al,"$"
;         je        DispCop3
;         loop      DispCop2
;
;DispCop3:mov       word ptr ds:[si-1],'"' + 13*256
;         mov       word ptr ds:[si+1],10 + "$"*256
;
;         mov       dx,offset Pozadav
;         call      DispTxt
;         ret
;
;DispCop  ENDP
;
; -----------------------------------------------------------------------------
;        v˜pis obsahu disku
; -----------------------------------------------------------------------------
;þ
Vypis    PROC      NEAR

         mov       al,ds:[BegTrack]         ; po‡ te‡n¡ stopa
         mov       ds:[Track],al            ; aktu ln¡ stopa

; ------ parametry aktu ln¡ stopy

Vypis1:  mov       ax,word ptr ds:[NextAdr] ; adresa p©¡¨t¡ stopy
         mov       word ptr ds:[TrackAdr],ax ; je to adresa t‚to stopy
         mov       ax,word ptr ds:[NextAdr+2]
         mov       word ptr ds:[TrackAdr+2],ax
         mov       al,ds:[NextInfo]         ; informa‡n¡ bajt
         mov       ds:[TrckInfo],al

; ------ na‡ten¡ dal¨¡ stopy

         mov       al,ds:[Track]            ; aktu ln¡ stopa
         inc       ax                       ; p©¡¨t¡ stopa
         call      GetTrack                 ; na‡ten¡ dal¨¡ stopy
         mov       word ptr ds:[NextAdr],ax ; adresa dal¨¡ stopy
         mov       word ptr ds:[NextAdr+2],dx
         mov       al,ds:[ZarizBuf+6]       ; stavov˜ bajt
         mov       ds:[NextInfo],al         ; informa‡n¡ bajt

; ------ dek¢dov n¡ ‡¡sla aktivn¡ stopy

         mov       al,ds:[Track]            ; aktivn¡ stopa
         push      ds
         pop       es
         mov       di,offset StopaTxt+9
         call      DekNumB
         cmp       byte ptr ds:[StopaTxt+9],"0"
         jne       Vypis3
         mov       byte ptr ds:[StopaTxt+9]," "

; ------ po‡ te‡n¡ ‡as stopy

Vypis3:  mov       ax,word ptr ds:[TrackAdr] ; adresa t‚to stopy
         mov       dx,word ptr ds:[TrackAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; ode‡ten¡ po‡ tku ‡asu
         sbb       dx,word ptr ds:[BeginAdr+2]
         add       ax,word ptr ds:[KorTime] ; ‡as po‡ tku v˜pisu
         adc       dx,word ptr ds:[KorTime+2]

; ------ dek¢dov n¡ po‡ te‡n¡ho ‡asu stopy

         mov       di,offset StopaTxt       ; hodina
         call      DekHodin                 ; dek¢dov n¡ hodiny
         call      DekMinut                 ; dek¢dov n¡ minuty
         call      DekSeknd                 ; dek¢dov n¡ sekundy

; ------ d‚lka stopy

         mov       ax,word ptr ds:[NextAdr] ; p©¡¨t¡ stopa
         mov       dx,word ptr ds:[NextAdr+2]
         sub       ax,word ptr ds:[TrackAdr] ; d‚lka stopy
         sbb       dx,word ptr ds:[TrackADr+2]

; ------ dek¢dov n¡ d‚lky stopy

         mov       di,offset StopaTx2
         mov       byte ptr ds:[di-1],"."
         push      di
         call      DekTimeF                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF
         pop       di
         cmp       byte ptr ds:[di],"0"
         je        Vypis32
         dec       di
Vypis32: mov       byte ptr ds:[di]," "

; ------ zobrazen¡ © dku stopy

         mov       dx,offset StopaTxt
         call      DispTxt

; ------ zobrazen¡ informac¡ o stopˆ

         test      byte ptr ds:[TrckInfo],40h ; je datov  stopa ?
         jz        Vypis42                  ; nen¡ datov  stopa
         mov       dx,offset DataTxt
         call      DispTxt
         jmp       short Vypis46

Vypis42: test      byte ptr ds:[TrckInfo],80h ; quadro ?
         jz        Vypis44
         mov       dx,offset QuadTxt
         call      DispTxt

Vypis44: test      byte ptr ds:[TrckInfo],10h ; preemf ze ?
         jz        Vypis46
         mov       dx,offset PreemTxt
         call      DispTxt

Vypis46: test      byte ptr ds:[TrckInfo],20h ; z kaz digit ln¡ kopie ?
         jz        Vypis48                  ; nen¡ z kaz
         mov       dx,offset ProtTxt        ; z kaz digit ln¡ kopie
         call      DispTxt

Vypis48: mov       dx,offset CRTxt
         call      DispTxt

; ------ p©¡prava pro dal¨¡ stopu

         inc       byte ptr ds:[Track]      ; zv˜¨en¡ aktivn¡ stopy
         mov       al,ds:[Track]            ; aktivn¡ stopa
         cmp       al,ds:[EndTrack]         ; je to platn  stopa ?
         ja        Vypis6
         jmp       Vypis1                   ; dal¨¡ stopa

; ------ koncov˜ ‡as disku

Vypis6:  mov       ax,word ptr ds:[NextAdr] ; adresa dal¨¡ stopy (tj. konce)
         mov       dx,word ptr ds:[NextAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; ode‡ten¡ po‡ tku ‡asu
         sbb       dx,word ptr ds:[BeginAdr+2]
         add       ax,word ptr ds:[KorTime] ; ‡as po‡ tku v˜pisu
         adc       dx,word ptr ds:[KorTime+2]

; ------ dek¢dov n¡ koncov‚ho ‡asu disku

         mov       di,offset KonecTxt       ; hodina
         call      DekHodin                 ; dek¢dov n¡ hodiny
         call      DekMinut                 ; dek¢dov n¡ minuty
         call      DekSeknd                 ; dek¢dov n¡ sekundy

; ------ celkov  d‚lka disku

         mov       ax,word ptr ds:[NextAdr] ; adresa dal¨¡ stopy
         mov       dx,word ptr ds:[NextAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; ode‡ten¡ po‡ tku ‡asu
         sbb       dx,word ptr ds:[BeginAdr+2]

; ------ dek¢dov n¡ d‚lky disku

         mov       di,offset KonecTx2+2
;         call      DekHodin                 ; dek¢dov n¡ hodiny
         call      DekTimeH                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF
;         cmp       byte ptr ds:[KonecTx2],"0"
;         jne       Vypis7
;         mov       word ptr ds:[KonecTx2],"  "

; ------ zobrazen¡ informac¡ o disku

Vypis7:  mov       dx,offset KonecTxt
         call      DispTxt
         ret

Vypis    ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ze za©¡zen¡ CD-ROM (CX bajt–)
; -----------------------------------------------------------------------------

InpIOCTL PROC      NEAR

; ------ inicializace bufferu po‘adavku

         push      cx                       ; po‡et ‡ten˜ch bajt–

         call      NulPozad                 ; nulov n¡ bufferu po‘adavku
         mov       al,26                    ; d‚lka po‘adavku
         stosb
         mov       al,ds:[Disk]             ; aktivn¡ disk
         stosb
         mov       al,3                     ; povel pro ‡ten¡ z IOCTL
         stosb
         mov       di,offset Pozadav+0eh
         mov       ax,offset ZarizBuf       ; adresa po‘adavku
         stosw                              ; offset adresy
         mov       ax,ds
         stosw                              ; segment adresy
         pop       ax                       ; po‡et ‡ten˜ch bajt–
         push      ax
         stosw                              ; po‡et bajt– k na‡ten¡

; ------ vysl n¡ po‘adavku

         mov       al,10h                   ; podfunkce ovl d n¡ za©¡zen¡
         mov       cl,ds:[Disk]             ; aktivn¡ disk
         mov       ch,0
         call      Int2F                    ; vysl n¡ po‘adavku

; ------ kontrola navr cen‚ho stavu

         pop       ax
         test      byte ptr ds:[Zadano],40h ; zobrazen¡ ?
         jnz       InpIOCT4                 ; je zobrazen¡
         cmp       ax,word ptr ds:[Pozadav+12h] ; souhlas¡ po‡et bajt– ?
         jne       InpIOCT3                 ; po‡et bajt– nesouhlas¡
         test      byte ptr ds:[Pozadav+3+1],80h ; byla chyba ?
         jz        InpIOCT4                 ; nebyla chyba

InpIOCT3:mov       dx,offset ReadyTxt       ; text - nen¡ p©ipraven
         jmp       Chyba                    ; chyba

InpIOCT4:ret

InpIOCTL ENDP

; -----------------------------------------------------------------------------
;        test stavu CD, zda p©ehr v  (CY=nep©ehr v ) -> DX:AX
; -----------------------------------------------------------------------------

TestCD   PROC      NEAR

;; ------ stav disku
;
;         mov       byte ptr ds:[ZarizBuf],6 ; funkce zji¨tˆn¡ stavu disku
;         mov       cx,4                     ; po‡et bajt– k na‡ten¡
;         call      InpIOCTL                 ; na‡ten¡ stavu disku
;         mov       ax,word ptr ds:[ZarizBuf+1] ; stav disku
;         test      al,1                     ; jsou dv¡©ka otev©ena ?
;         jnz       TestCD1                  ; dv¡©ka jsou otev©ena
;         test      ah,4                     ; p©ehr v  se ?
;         jz        TestCD1                  ; nep©ehr v  se

; ------ stav p©ehr v n¡ audio

         mov       byte ptr ds:[ZarizBuf],0fh ; funkce zji¨tˆn¡ stavu audia
         mov       cx,10                    ; po‡et bajt– k na‡ten¡
         call      InpIOCTL                 ; na‡ten¡ velikosti sektoru
         mov       ax,word ptr ds:[ZarizBuf+3] ; p©ehr vac¡ adresa
         or        ax,word ptr ds:[ZarizBuf+5] ; prob¡h  p©ehr v n¡ ?
         jz        TestCD1                  ; neprob¡h  p©ehr v n¡

         mov       ax,word ptr ds:[ZarizBuf+1] ; stav LOW
         test      al,1                     ; p©ehr v  ?
         jz        TestCD2                  ; p©ehr v 
TestCD1: stc                                ; p©¡znak, ‘e nep©ehr v 
TestCD2: ret

TestCD   ENDP

;; -----------------------------------------------------------------------------
;;        rychlop©ehr v n¡ (AX sektor–)
;; -----------------------------------------------------------------------------
;
;; ------ inicializace bufferu po‘adavku
;
;RychlCD: push      ax
;
;         call      NulPozad                 ; nulov n¡ bufferu po‘adavku
;         mov       al,16h                   ; d‚lka po‘adavku
;         stosb
;         mov       al,ds:[Disk]             ; aktivn¡ disk
;         stosb
;         mov       al,84h
;         stosb                              ; povel
;
;         mov       di,offset Pozadav+0dh
;         mov       al,1
;         stosb
;
;         mov       ax,word ptr ds:[PlayAdr]
;         mov       dx,word ptr ds:[PlayAdr+2]
;         call      SetRBook                 ; ulo‘en¡ ‡¡sla r me‡ku
;
;         pop       ax                       ; po‡et sektor–
;
;         add       word ptr ds:[PlayAdr],ax  ; zv˜¨en¡ ukazatele
;         adc       word ptr ds:[PlayAdr+2],0
;
;         stosw                              ; po‡et sektor–
;         xor       ax,ax
;         stosw
;         jmp       short StopCD2

; -----------------------------------------------------------------------------
;        pokra‡ov n¡ v p©ehr v n¡
; -----------------------------------------------------------------------------

; ------ na‡ten¡ aktu ln¡ pozice

ContCD:  mov       word ptr ds:[ZarizBuf],1 + 1*256 ; zji¨tˆn¡ pozice hlav
         mov       cx,5
         call      InpIOCTL                 ; na‡ten¡ absolutn¡ pozice hlav
         mov       si,offset ZarizBuf+2
         call      GetRBook                 ; na‡ten¡ aktu ln¡ pozice hlav
         mov       word ptr ds:[PlayAdr],ax ; aktu ln¡ absolutn¡ pozice
         mov       word ptr ds:[PlayAdr+2],dx

; Pokra‡uje PLAYCD !!!!

; -----------------------------------------------------------------------------
;        p©ehr t¡ nahr vky
; -----------------------------------------------------------------------------

PlayCD   PROC      NEAR

; ------ inicializace bufferu po‘adavku

         call      NulPozad                 ; nulov n¡ bufferu po‘adavku
         mov       al,16h                   ; d‚lka po‘adavku
         stosb
         mov       al,ds:[Disk]             ; aktivn¡ disk
         stosb
         mov       al,84h
         stosb                              ; povel

         mov       di,offset Pozadav+0dh
         mov       al,1
         stosb

         mov       ax,word ptr ds:[PlayAdr]
         mov       dx,word ptr ds:[PlayAdr+2]
         call      SetRBook                 ; ulo‘en¡ ‡¡sla r me‡ku

         mov       ax,word ptr ds:[KonecAdr] ; adresa konce
         mov       dx,word ptr ds:[KonecAdr+2]
         sub       ax,word ptr ds:[PlayAdr] ; zb˜vaj¡c¡ po‡et sektor–
         sbb       dx,word ptr ds:[PlayAdr+2]
         jnc       PlayCD4
         mov       ax,1
         xor       dx,dx
PlayCD4: stosw                              ; po‡et sektor–
         xchg      ax,dx
         stosw
         jmp       short StopCD2

PlayCD   ENDP

;; -----------------------------------------------------------------------------
;;        pokra‡ov n¡ v p©ehr v n¡ CD-ROM
;; -----------------------------------------------------------------------------
;
;ContCD:  mov       al,88h
;         jmp       short StopCD1

; -----------------------------------------------------------------------------
;        zastaven¡ p©ehr v n¡ CD-ROM
; -----------------------------------------------------------------------------

StopCD   PROC      NEAR

         mov       al,85h                   ; STOP

; ------ inicializace bufferu po‘adavku

StopCD1: push      ax
         call      NulPozad                 ; nulov n¡ bufferu po‘adavku
         mov       al,0dh                   ; d‚lka po‘adavku
         stosb
         mov       al,ds:[Disk]             ; aktivn¡ disk
         stosb
         pop       ax
         stosb                              ; povel

; ------ vysl n¡ po‘adavku

StopCD2: mov       al,10h                   ; podfunkce ovl d n¡ za©¡zen¡
         mov       cl,ds:[Disk]             ; aktivn¡ disk
         mov       ch,0
         call      Int2F                    ; vysl n¡ po‘adavku

; ------ kontrola navr cen‚ho stavu

         test      byte ptr ds:[Zadano],40h ; zobrazen¡ ?
         jnz       StopCD9                  ; je zobrazen¡
         test      byte ptr ds:[Pozadav+3+1],80h ; byla chyba ?
         jz        StopCD9                  ; nebyla chyba
StopCD8: mov       dx,offset ReadyTxt       ; text - nen¡ p©ipraven
         jmp       Chyba                    ; chyba

StopCD9: ret

StopCD   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ ukazatele na DX:AX
; -----------------------------------------------------------------------------

SeekCD   PROC      NEAR

; ------ inicializace bufferu po‘adavku

         push      ax
         push      dx

         call      NulPozad                 ; nulov n¡ bufferu po‘adavku
         mov       al,18h                   ; d‚lka po‘adavku
         stosb
         mov       al,ds:[Disk]             ; aktivn¡ disk
         stosb
         mov       al,83h
         stosb                              ; povel

         mov       di,offset Pozadav+0dh

         mov       al,1
         stosb                              ; m¢d adresov n¡

         mov       ax,offset Buffer         ; adresa bufferu
         stosw
         mov       ax,ds
         stosw

         mov       ax,1
         stosw                              ; po‡et sektor–

         pop       dx
         pop       ax
         call      SetRBook                 ; ulo‘en¡ ‡¡sla r me‡ku
         jmp       short StopCD2

SeekCD   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ stavu CD
; -----------------------------------------------------------------------------
;þ
DispCD   PROC      NEAR

;         and       byte ptr ds:[Param],not 1     ; nen¡ rychlop©ehr v n¡

         mov       dx,offset StavTxt
         mov       ah,9
         int       21h

; ------ na‡ten¡ aktu ln¡ pozice

DispCD1: mov       word ptr ds:[ZarizBuf],1 + 1*256 ; zji¨tˆn¡ pozice hlav
         mov       cx,5
         call      InpIOCTL                 ; na‡ten¡ absolutn¡ pozice hlav
         mov       si,offset ZarizBuf+2
         call      GetRBook                 ; na‡ten¡ aktu ln¡ pozice hlav
         mov       word ptr ds:[AktAAdr],ax ; aktu ln¡ absolutn¡ pozice
         mov       word ptr ds:[AktAAdr+2],dx

         push      ax
         push      dx
         call      TestCD
         pop       dx
         pop       ax
         jnc       DispCD12                 ; je v provozu
         add       word ptr ds:[AktAAdr],30 ; p©i pauze nech v  na rozjezd
         adc       word ptr ds:[AktAAdr+2],0

; ------ p©ehr n¡ sektoru p©i rychlop©ehr v n¡

DispCD12:
;test      byte ptr ds:[Param],1
;         jz        DispCD15
;
;         cmp       dx,word ptr ds:[PlayAdr+2]
;         jne       DispCD13
;         cmp       ax,word ptr ds:[PlayAdr]
;DispCD13:jb        DispCD15
;
;         call      StopCD
;
;         add       word ptr ds:[PlayAdr],3*75-10
;         adc       word ptr ds:[PLayAdr+2],0
;
;         call      PlayCD
;
;         add       word ptr ds:[PlayAdr],75
;         adc       word ptr ds:[PlayAdr+2],0
;
;;         mov       ax,75
;;         call      RychlCD                  ; rychlop©ehr v n¡

; ------ dek¢dov n¡ aktu ln¡ absolutn¡ pozice

DispCD15:mov       ax,word ptr ds:[AktAAdr]
         mov       dx,word ptr ds:[AktAAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; ode‡ten¡ po‡ tku ‡asu
         sbb       dx,word ptr ds:[BeginAdr+2]
         mov       di,offset StavTxt2+44
         call      DekTimeH                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF

; ------ zb˜vaj¡c¡ ‡as do konce disku

         mov       ax,word ptr ds:[KonecAdr]
         mov       dx,word ptr ds:[KonecAdr+2]
         sub       ax,word ptr ds:[AktAAdr]
         sbb       dx,word ptr ds:[AktAAdr+2]
         jnc       DispCD2
         xor       ax,ax
         xor       dx,dx
DispCD2: mov       di,offset StavTxt2+55
         call      DekTimeH                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF

; ------ velikost disku

         mov       ax,word ptr ds:[KonecAdr] ; konec disku
         mov       dx,word ptr ds:[KonecAdr+2]
         sub       ax,word ptr ds:[BeginAdr] ; velikost disku
         sbb       dx,word ptr ds:[BeginAdr+2]
         mov       di,offset StavTxt2+66
         call      DekTimeH

; ------ p©¡prava k nalezen¡ stopy

         mov       ax,word ptr ds:[BeginAdr]  ; adresa stopy 1
         mov       word ptr ds:[NextAdr],ax ; adresa p©¡¨t¡ stopy
         mov       ax,word ptr ds:[BeginAdr+2]
         mov       word ptr ds:[NextAdr+2],ax
         mov       al,ds:[BegTrack]         ; po‡ te‡n¡ stopa

; ------ adresa aktu ln¡ stopy AL

DispCD3: mov       ds:[Track],al            ; nov  aktu ln¡ stopa
         mov       ax,word ptr ds:[NextAdr]
         mov       word ptr ds:[TrackAdr],ax ; adresa aktu ln¡ stopy
         mov       ax,word ptr ds:[NextAdr+2]
         mov       word ptr ds:[TrackAdr+2],ax

; ------ na‡ten¡ informac¡ p©¡¨t¡ stopy

         mov       al,ds:[Track]            ; aktu ln¡ stopa
         inc       ax                       ; p©¡¨t¡ stopa
         call      GetTrack                 ; parametry dal¨¡ stopy
         mov       word ptr ds:[NextAdr],ax ; adresa dal¨¡ stopy
         mov       word ptr ds:[NextAdr+2],dx

; ------ test, zda je ukazatel v t‚to stopˆ

         sub       ax,word ptr ds:[AktAAdr] ; offset od aktu ln¡ho ukazatele
         sbb       dx,word ptr ds:[AktAAdr+2]
         ja        DispCD5                  ; stopa nalezena
         jb        DispCD4
         or        ax,ax
         jnz       DispCD5

; ------ test, zda je dal¨¡ stopa

DispCD4: mov       al,ds:[Track]            ; aktu ln¡ stopa
         inc       ax                       ; n sleduj¡c¡ stopa
         cmp       al,ds:[EndTrack]         ; je je¨tˆ dal¨¡ stopa ?
         jbe       DispCD3                  ; stopa je je¨tˆ platn 
         xor       ax,ax                    ; nic nezb˜v 
         xor       dx,dx

; ------ dek¢dov n¡ zb˜vaj¡c¡ho ‡asu do konce stopy

DispCD5: mov       di,offset StavTxt2+22
         call      DekTimeH                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF

; ------ ‡as ve stopˆ

         mov       ax,word ptr ds:[AktAAdr] ; aktu ln¡ ‡as
         mov       dx,word ptr ds:[AktAAdr+2]
         sub       ax,word ptr ds:[TrackAdr]
         sbb       dx,word ptr ds:[TrackAdr+2]
         jnc       DispCD6
         xor       ax,ax
         xor       dx,dx

; ------ dek¢dov n¡ ‡asu ve stopˆ

DispCD6: mov       di,offset StavTxt2+11
         call      DekTimeH                 ; dek¢dov n¡ ‡asu ve tvaru MM:SS,FF

; ------ dek¢dov n¡ d‚lky stopy

         mov       ax,word ptr ds:[NextAdr]
         mov       dx,word ptr ds:[NextAdr+2]
         sub       ax,word ptr ds:[TrackAdr]
         sbb       dx,word ptr ds:[TrackAdr+2]
         mov       di,offset StavTxt2+33
         call      DekTimeH

; ------ dek¢dov n¡ ‡¡sla nahr vky

         mov       al,ds:[Track]            ; aktu ln¡ stopa
         mov       di,offset StavTxt2+4
         call      DekNumB                  ; dek¢dov n¡ ‡¡sla nahr vky
         cmp       byte ptr ds:[StavTxt2+4],"0"
         jne       DispCD7
         mov       byte ptr ds:[StavTxt2+4]," "

; ------ zobrazen¡ aktu ln¡ho stavu

DispCD7: mov       dx,offset StavTxt2
         call      DispTxt

; ------ zobrazen¡ stavu STOP

         call      TestCD
         mov       dx,offset StopTxt
         jc        DispCD70
         mov       dx,offset NStopTxt
DispCD70:call      DispTxt

; ------ korekce ‡¡sla stopy, je-li na konci

         cmp       word ptr ds:[StavTxt2+22],"00" ; zb˜vaj¡c¡ ‡as
         jne       DispCD72
         cmp       word ptr ds:[StavTxt2+22+3],"00"
         jne       DispCD72
         inc       byte ptr ds:[Track]      ; zv˜¨en¡ ‡¡sla stopy

; ------ test, zda je stisk kl vesy

DispCD72:mov       ah,1
         int       16h
         jnz       DispCD8
DispCD74:jmp       DispCD1

; ------ vstup znaku z kl vesnice

DispCD8: mov       ah,0
         int       16h

; ------ p©eru¨en¡ operace

         or        ax,ax
         jz        DspCD812
         cmp       al,27
         jne       DspCD814

; ------ od© dkov n¡

DspCD812:mov       dx,offset CRTxt
         mov       ah,9
         int       21h
         ret

; ------ p©edchoz¡ nahr vka

DspCD814:cmp       ax,4800h                 ; nahoru
         jne       DispCD82
         mov       al,ds:[Track]            ; aktu ln¡ stopa
         dec       al                       ; sn¡‘en¡ ‡¡sla stopy
         cmp       al,ds:[BegTrack]
         jae       DispCD81
         mov       al,ds:[EndTrack]         ; posledn¡ stopa
DispCD81:call      GetTrack                 ; informace o nov‚ stopˆ
DspCD818:mov       word ptr ds:[PlayAdr],ax ; adresa k p©ehr t¡
         mov       word ptr ds:[PlayAdr+2],dx
         push      ax
         push      dx
         call      TestCD                   ; p©ehr v  ?
         pop       dx
         pop       ax
         jc        DspCD819                 ; nep©ehr v 
         call      StopCD                   ; zastaven¡ p©ehr v n¡
         call      PlayCD                   ; p©ehr t¡ nahr vky
         jmp       short DispCD74

DspCD819:call      PlayCD
         call      StopCD
         jmp       short DispCD74

; ------ n sleduj¡c¡ nahr vka

DispCD82:cmp       ax,5000h
         jne       DispCD83
         mov       al,ds:[Track]
         inc       al
         cmp       al,ds:[EndTrack]
         jbe       DispCD81
         mov       al,ds:[BegTrack]
         jmp       short DispCD81

; ------ posun o 15 sekund zpˆt

DispCD83:cmp       ax,4b00h
         jne       DispCD84
         mov       ax,word ptr ds:[AktAAdr] ; aktu ln¡ ukazatel
         mov       dx,word ptr ds:[AktAAdr+2]
         sub       ax,15*75                 ; posun o 15 sekund zpˆt
         sbb       dx,0
         jnc       DspCD832
         xor       ax,ax
         xor       dx,dx
DspCD832:jmp       short DspCD818

; ------ posun o 15 sekund vp©ed

DispCD84:cmp       ax,4d00h
         jne       DispCD85
         mov       ax,word ptr ds:[AktAAdr] ; aktu ln¡ ukazatel
         mov       dx,word ptr ds:[AktAAdr+2]
         add       ax,15*75                 ; posun o 15 sekund zpˆt
         adc       dx,0
         cmp       dx,word ptr ds:[KonecAdr+2]
         jne       DspCD842
         cmp       ax,word ptr ds:[KonecAdr]
DspCD842:jb        DspCD844
         mov       ax,word ptr ds:[KonecAdr]
         mov       dx,word ptr ds:[KonecAdr+2]
         sub       ax,1
         sbb       dx,0
DspCD844:jmp       short DspCD832

; ------ pauza

DispCD85:cmp       al," "
         jne       DispCD86
         call      TestCD                   ; test, zda p©ehr v 
         jnc       DspCD852                 ; p©ehr v 
         call      ContCD                   ; pokra‡ov n¡ v p©ehr v n¡
DspCD851:jmp       DispCD1

DspCD852:call      StopCD                   ; zastaven¡ p©ehr v n¡
         jmp       short DspCD851

; ------ start od skladby 1...

DispCD86:cmp       al,"a"
         jb        DspCD861
         cmp       al,"z"
         ja        DspCD861
         sub       al,32
DspCD861:cmp       al,"1"
         jb        DispCD87
         cmp       al,"Z"
         ja        DispCD87
         cmp       al,"9"
         jbe       DspCD862
         cmp       al,"A"
         jb        DispCD87
         sub       al,7
DspCD862:sub       al,"0"                   ; AL = ‡¡slo skladby 1...
         cmp       al,ds:[EndTrack]
         ja        DispCD87
         call      GetTrack                 ; na‡ten¡ informac¡ o stopˆ
         mov       word ptr ds:[PlayAdr],ax ; adresa k p©ehr t¡
         mov       word ptr ds:[PlayAdr+2],dx
         call      StopCD                   ; zastaven¡ p©ehr v n¡
         call      PlayCD                   ; p©ehr t¡ nahr vky
         jmp       DispCD1

DispCD87:

; ------ rychlop©ehr v n¡
;cmp       al," "
;         jne       DispCD88
;
;         xor       byte ptr ds:[Param],1    ; zmˆna p©¡znaku
;         test      byte ptr ds:[Param],1
;         jz        DspCD851
;
;         mov       word ptr ds:[ZarizBuf],1 + 1*256 ; zji¨tˆn¡ pozice hlav
;         mov       cx,5
;         call      InpIOCTL                 ; na‡ten¡ absolutn¡ pozice hlav
;         mov       si,offset ZarizBuf+2
;         call      GetRBook                 ; na‡ten¡ aktu ln¡ pozice hlav
;         add       ax,75
;         adc       dx,0
;         mov       word ptr ds:[PlayAdr],ax ; aktu ln¡ absolutn¡ pozice
;         mov       word ptr ds:[PlayAdr+2],dx
;         call      StopCD
;;         mov       ax,75
;;         call      RychlCD
;         call      PlayCD
;         jmp       short DspCD851
;
DispCD88:jmp       DispCD72

DispCD   ENDP

;; -----------------------------------------------------------------------------
;;        ‡ten¡ disku CD-ROM
;; -----------------------------------------------------------------------------
;;þ
;ReadCD   PROC      NEAR
;
;         xor       bx,bx
;ReadCX1:
;         push      bx
;         mov       al,7
;         call      Int2f0
;         pop       bx
;         inc       bx
;         jnz       ReadCX1
;
;; ------ vytvo©en¡ v˜stupn¡ho souboru
;
;         mov       dx,offset ReadSoub
;         mov       ah,3ch
;         xor       cx,cx
;         int       21h
;         jnc       ReadCD2
;ReadCD0: mov       dx,offset WritTxt
;         jmp       Chyba
;
;ReadCD2: mov       word ptr ds:[ReadIdnt],ax
;
;; ------ na‡ten¡ jednoho sektoru
;
;ReadCD3:
;         mov       di,word ptr ds:[BegSektR] ; ukazatel ‡¡sla sektoru
;         mov       si,word ptr ds:[BegSektR+2]
;         mov       dx,1                     ; 1 sektor
;         mov       cl,ds:[Disk]             ; aktivn¡ disk
;         mov       ch,0
;         mov       al,8
;         call      Int2F
;
;;call      NulPozad                 ; nulov n¡ bufferu po‘adavku
;;         mov       al,27
;;         stosb                              ; d‚lka po‘adavku
;;         mov       al,ds:[Disk]             ; aktivn¡ disk
;;         stosb
;;         mov       al,80h
;;         stosb                              ; povel
;;
;;         mov       di,offset Pozadav+0dh
;;         mov       al,0
;;         stosb                              ; adresovac¡ m¢d
;;         mov       ax,offset Buffer
;;         stosw                              ; offset bufferu
;;         mov       ax,ds
;;         stosw                              ; segment bufferu
;;         mov       ax,1
;;         stosw                              ; po‡et sektor– - 1 sektor
;;         mov       ax,word ptr ds:[BegSektR] ; ukazatel ‡¡sla sektoru
;;         mov       dx,word ptr ds:[BegSektR+2]
;;;         mov       cx,75                    ; po‡et sektor– na sekundu
;;;         call      DivCX                    ; v˜po‡et ‡¡sla r me‡ku
;;;         mov       ds:[di],bl               ; ‡¡slo r me‡ku
;;;         inc       di
;;;         mov       cl,60                    ; po‡et sekund na minutu
;;;         call      DivCX                    ; v˜po‡et ‡¡sla sekundy
;;;         mov       ds:[di],bl               ; ‡¡slo sekundy
;;;         inc       di
;;;         mov       ah,0
;;         stosw                              ; ‡¡slo minuty
;;         xchg      ax,dx
;;         stosw
;;
;;         mov       al,0
;;         stosb                              ; ‡tec¡ m¢d 2048 bajt–
;;         inc       ax                       ; AL <- 1
;;         stosb                              ; po‡et sektor– na skupinu
;;         dec       ax                       ; AL <- 0
;;         stosb                              ; po‡et sektor– mezi skupinami
;;
;;; ------ vysl n¡ po‘adavku
;;
;;         mov       al,10h                   ; podfunkce ovl d n¡ za©¡zen¡
;;         mov       cl,ds:[Disk]             ; aktivn¡ disk
;;         mov       ch,0
;;         call      Int2F                    ; vysl n¡ po‘adavku
;;         test      byte ptr ds:[Pozadav+3+1],80h ; byla chyba ?
;;         jz        ReadCD4                  ; nen¡ chyba
;
;         jnc       ReadCD4
;
;         jmp       StopCD8                  ; byla chyba
;
;; ------ ulo‘en¡ sektoru do souboru
;
;ReadCD4: mov       dx,offset Pozadav
;         mov       ah,40h
;         mov       bx,ds:[ReadIdnt]         ; identifik tor souboru
;         mov       cx,2048                  ; velikost sektoru
;         int       21h                      ; z pis sektoru do souboru
;         jc        ReadCD5
;         cmp       ax,cx
;         je        ReadCD6
;ReadCD5: jmp       ReadCD0                  ; chyba
;
;; ------ zv˜¨en¡ ‡¡sla sektoru
;
;ReadCD6: add       word ptr ds:[BegSektR],1 ; zv˜¨en¡ ‡¡sla sektoru
;         adc       word ptr ds:[BegSektR+2],0
;
;; ------ test, zda jsou ji‘ v¨echny sektory
;
;         mov       ax,word ptr ds:[BegSektR+2]
;         cmp       ax,word ptr ds:[EndSektR+2]
;         jne       ReadCD7
;         mov       ax,word ptr ds:[BegSektR]
;         cmp       ax,word ptr ds:[EndSektR]
;ReadCD7: jae       ReadCD8
;         jmp       ReadCD3
;
;; ------ uzav©en¡ souboru
;
;ReadCD8: mov       ah,3eh
;         int       21h
;         ret
;
;ReadCD   ENDP

; -----------------------------------------------------------------------------
;        nulov n¡ bufferu po‘adavku pro IOCTL -> ES:DI=buffer
; -----------------------------------------------------------------------------

NulPozad PROC      NEAR

         push      ds
         pop       es
         mov       di,offset Pozadav        ; buffer po‘adavku
         mov       cx,100/2                 ; d‚lka bufferu
         xor       ax,ax
         cld
         push      di
         rep       stosw                    ; vynulov n¡ bufferu
         pop       di
         ret

NulPozad ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡asu MM:SS,FF bez omezen¡ minut
; -----------------------------------------------------------------------------

DekTimeH PROC      NEAR

         call      DekMinH                  ; dek¢dov n¡ minuty
         call      DekSeknd                 ; dek¢dov n¡ sekund
         call      DekFrame                 ; dek¢dov n¡ r me‡ku
         ret

DekTimeH ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡asu MM:SS,FF
; -----------------------------------------------------------------------------

DekTimeF PROC      NEAR

         call      DekMinut                 ; dek¢dov n¡ minuty
         call      DekSeknd                 ; dek¢dov n¡ sekund
         call      DekFrame                 ; dek¢dov n¡ r me‡ku
         ret

DekTimeF ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ hodiny z ‡asu DX:AX do bufferu ES:DI (1 ‡¡slice)
; -----------------------------------------------------------------------------

DekHodin PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡slice hodiny

         mov       cx,75                    ; pro p©epo‡et na sekundy
         call      DivCX                    ; p©epo‡et na sekundy
         mov       cx,60*60                 ; pro p©epo‡et na hodiny
         call      DivCX                    ; p©epo‡et na hodiny

; ------ p©¡prava ‡¡slice hodin

         add       al,"0"+10                ; korekce na znak ASCII + 10
DekHodn2:sub       al,10                    ; posun o © d dol–
         cmp       al,"9"                   ; je ‡¡slice OK ?
         ja        DekHodn2                 ; ‡¡slice je je¨tˆ velk 

; ------ ulo‘en¡ ‡¡slice hodiny

         cld
         stosb                              ; ulo‘en¡ ‡¡slice hodiny
         inc       di                       ; p©esko‡en¡ oddˆlova‡e ‡asu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekHodin ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ minuty (bez omezen¡) z ‡asu DX:AX do bufferu ES:DI
; -----------------------------------------------------------------------------

DekMinH  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡slice minut

         mov       cx,75*60                 ; pro p©epo‡et na minuty
         call      DivCX                    ; p©epo‡et na minuty

; ------ ulo‘en¡ ‡¡sla minut

         call      DekNumB                  ; dek¢dov n¡ ‡¡sla minut
         inc       di                       ; p©esko‡en¡ oddˆlova‡e ‡asu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekMinH  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ minuty z ‡asu DX:AX do bufferu ES:DI (2 ‡¡slice)
; -----------------------------------------------------------------------------

DekMinut PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡slice minut

         mov       cx,75*60                 ; pro p©epo‡et na minuty
         call      DivCX                    ; p©epo‡et na minuty
         mov       cx,60                    ; pro p©epo‡et na hodiny
         call      DivCX                    ; p©epo‡et na hodiny
         xchg      ax,bx                    ; AX <- zbyl  ‡ st minut v hodinˆ

; ------ ulo‘en¡ ‡¡sla minut

         call      DekNumB                  ; dek¢dov n¡ ‡¡sla minut
         inc       di                       ; p©esko‡en¡ oddˆlova‡e ‡asu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekMinut ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ sekundy z ‡asu DX:AX do bufferu ES:DI (2 ‡¡slice)
; -----------------------------------------------------------------------------

DekSeknd PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡slice sekund

         mov       cx,75                    ; pro p©epo‡et na sekundy
         call      DivCX                    ; p©epo‡et na sekundy
         mov       cx,60                    ; pro p©epo‡et na minuty
         call      DivCX                    ; p©epo‡et na minuty
         xchg      ax,bx                    ; AX <- zbyl  ‡ st sekund v minutˆ

; ------ ulo‘en¡ ‡¡sla sekund

         call      DekNumB                  ; dek¢dov n¡ ‡¡sla sekund
         inc       di                       ; p©esko‡en¡ oddˆlova‡e ‡asu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekSeknd ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ r me‡ku z ‡asu DX:AX do bufferu ES:DI (2 ‡¡slice)
; -----------------------------------------------------------------------------

DekFrame PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ v˜po‡et ‡¡sla r me‡ku

         mov       cx,75                    ; pro p©epo‡et na sekundy
         call      DivCX                    ; p©epo‡et na sekundy
         xchg      ax,bx                    ; AX <- zbyl  ‡ st r me‡ku v sekundˆ

; ------ p©epo‡et r me‡ku na setiny sekundy (tj. r me‡ek * 100 / 75)

         mov       bx,100                   ; po‡et setin sekundy
         mul       bx                       ; p©epo‡et na setiny sekundy * 75
         div       cx                       ; p©epo‡et na setiny sekundy
         cmp       dx,35
         jb        DekFram2
         inc       ax                       ; zaokrouhlen¡ nahoru

; ------ ulo‘en¡ ‡¡sla r me‡ku

DekFram2:call      DekNumB                  ; dek¢dov n¡ ‡¡sla r me‡ku
         inc       di                       ; p©esko‡en¡ oddˆlova‡e ‡asu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekFrame ENDP

; -----------------------------------------------------------------------------
;        vydˆlen¡ DX:AX / CX (nesm¡ b˜t 0 !) -> DX:AX, BX=zbytek
; -----------------------------------------------------------------------------

DivCX    PROC      NEAR

         xchg      ax,bx                    ; BX <- £schova ‡¡sla LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- ‡¡slo HIGH, DX <- 0
         div       cx                       ; vydˆlen¡ ‡¡sla HIGH
         xchg      ax,bx                    ; AX <- ‡¡slo LOW, BX <- nov‚ HIGH
         div       cx                       ; vydˆlen¡ ‡¡sla LOW
         xchg      bx,dx                    ; BX <- zbytek, DX <- nov‚ HIGH
         ret

DivCX    ENDP

; -----------------------------------------------------------------------------
;        vyn soben¡ ‡¡sla DX:AX * CX -> BX:DX:AX
; -----------------------------------------------------------------------------

MulCX    PROC      NEAR

         push      si
         xchg      ax,si                    ; SI <- £schova ‡¡sla LOW
         xchg      ax,dx                    ; AX <- ‡¡slo HIGH
         mul       cx                       ; vyn soben¡ ‡¡sla HIGH
         xchg      ax,si                    ; SI <- nov‚ HIGH, AX <- star‚ LOW
         mov       bx,dx                    ; BX <- nov‚ 2HIGH
         mul       cx                       ; vyn soben¡ ‡¡sla LOW
         add       dx,si                    ; p©i‡ten¡ ‡¡sla HIGH
         adc       bx,0                     ; p©enos 2HIGH
         pop       si
         ret

MulCX    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla AL do bufferu ES:DI
; -----------------------------------------------------------------------------

DekNumB  PROC      NEAR

         push      ax
         aam
         xchg      al,ah
         add       ax,"00"
         cld
         stosw
         pop       ax
         ret

DekNumB  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla DX:AX
; -----------------------------------------------------------------------------

DispDNum PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

         xor       di,di                    ; ‡¡ta‡ ‡¡slic
         mov       cx,10                    ; dˆlitel
DispDNm1:call      DivCX                    ; vydˆlen¡ DX:AX / CX
         push      bx                       ; £schova ‡¡sice
         inc       di                       ; ‡¡ta‡ znak–
         mov       bx,ax
         or        bx,dx                    ; je ji‘ 0 ?
         jnz       DispDNm1                 ; dal¨¡ ‡¡slice

DispDNm2:pop       ax
         add       al,"0"                   ; korekce na znak ASCII
         call      DispChr                  ; zobrazen¡ znaku
         dec       di
         jnz       DispDNm2

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispDNum ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         xor       cx,cx                    ; ‡¡ta‡ ‡¡slic
         mov       bx,10                    ; dˆlitel
DispNum1:xor       dx,dx                    ; DX <- 0
         div       bx                       ; v˜po‡et ‡¡slice
         push      dx                       ; £schova ‡¡sice
         inc       cx                       ; ‡¡ta‡ znak–
         or        ax,ax                    ; je ji‘ 0 ?
         jnz       DispNum1                 ; dal¨¡ ‡¡slice

DispNum2:pop       ax
         add       al,"0"                   ; korekce na znak ASCII
         call      DispChr                  ; zobrazen¡ znaku
         loop      DispNum2

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AL (2 ‡¡slice)
; -----------------------------------------------------------------------------

Disp2Num PROC      NEAR

         push      ax
         aam
         xchg      al,ah
         add       ax,"00"
         call      DispChr                  ; prvn¡ ‡¡slice
         xchg      al,ah
         call      DispChr                  ; druh  ‡¡slice
         pop       ax
         ret

Disp2Num ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DOS DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku DOS AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        inicializace disku
; -----------------------------------------------------------------------------

InitDisk PROC      NEAR

; ------ na‡ten¡ seznamu disk– CD-ROM

         mov       byte ptr ds:[Pozadav],-1 ; neplatn˜ disk
         mov       al,0dh
         call      Int2F                    ; na‡ten¡ seznamu disk–

; ------ test, zda je instalov n OK

         mov       al,ds:[Pozadav]          ; prvn¡ disk
         cmp       al,32                    ; je disk platn˜ ?
         jae       InitDsk8                 ; chyba - asi nen¡ ovlada‡
         mov       ds:[Disk],al             ; prvn¡ disk CD-ROM
         add       byte ptr ds:[InfoTxt3],al ; ozna‡en¡ disku
         ret

; ------ chyba - nen¡ instalov n ovlada‡ CD-ROM

InitDsk8:mov       dx,offset NicTxt
Chyba:   call      DispTxt
         mov       ax,4cffh
         int       21h

InitDisk ENDP

; -----------------------------------------------------------------------------
;        inicializace po‡tu stop disku
; -----------------------------------------------------------------------------

InitTrk  PROC      NEAR

; ------ na‡ten¡ informac¡ o disku

         mov       byte ptr ds:[ZarizBuf],0ah ; funkce parametr– disku
         mov       word ptr ds:[ZarizBuf+1],0 ; neplatn‚ hodnoty
         mov       cx,6                     ; po‡et ‡ten˜ch bajt–
         call      InpIOCTL                 ; na‡ten¡ stavu disku

; ------ kontrola prvn¡ a posledn¡ stopy

         mov       ax,word ptr ds:[ZarizBuf+1] ; prvn¡ a posledn¡ stopa
         or        al,al
         jz        InitTrk8                 ; neplatn˜ £daj
         or        ah,ah
         jz        InitTrk8                 ; neplatn˜ £daj
         cmp       ah,al                    ; po©ad¡ stop OK
         jb        InitTrk8                 ; chyba
         cmp       ah,-1
         je        InitTrk8                 ; chyba
         mov       ds:[BegTrack],al         ; prvn¡ stopa
         mov       ds:[EndTrack],ah         ; posledn¡ stopa

; ------ koncov  stopa

         mov       si,offset ZarizBuf+3     ; koncov  adresa
         call      GetRBook                 ; na‡ten¡ koncov‚ho r me‡ku
         mov       word ptr ds:[KonecAdr],ax ; r me‡ek konec
         mov       word ptr ds:[KonecAdr+2],dx

; ------ po‡ te‡n¡ stopa

         mov       al,ds:[BegTrack]         ; po‡ te‡n¡ stopa
         call      GetTrack                 ; na‡ten¡ po‡ te‡n¡ho r me‡ku
         mov       word ptr ds:[BeginAdr],ax ; r me‡ek za‡ tku
         mov       word ptr ds:[BeginAdr+2],dx
         mov       word ptr ds:[NextAdr],ax ; adresa p©¡¨t¡ stopy
         mov       word ptr ds:[NextAdr+2],dx
         mov       al,ds:[ZarizBuf+6]       ; stavov˜ bajt
         mov       ds:[NextInfo],al         ; informa‡n¡ bajt
         ret

; ------ chyba - disk nen¡ p©ipraven

InitTrk8:mov       dx,offset ReadyTxt       ; text - nen¡ p©ipraven
         jmp       Chyba

InitTrk  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ informac¡ o stopˆ AL -> DX:AX=po‡ te‡n¡ r me‡ek
; -----------------------------------------------------------------------------

GetTrack PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         push      si

; ------ ‡¡slo r me‡ku pro neplatn‚ ‡¡slo stopy

         cmp       al,ds:[EndTrack]         ; je stopa platn  ?
         jbe       GetTrck4                 ; stopa je platn  OK
         mov       ax,word ptr ds:[KonecAdr] ; adresa konce
         mov       dx,word ptr ds:[KonecAdr+2]
         jmp       short GetTrck8

; ------ na‡ten¡ informac¡ o stopˆ

GetTrck4:mov       byte ptr ds:[ZarizBuf],0bh ; funkce ‡ten¡ informac¡
         mov       byte ptr ds:[ZarizBuf+1],al ; stopa
         mov       cx,5
         call      InpIOCTL                 ; na‡ten¡ informac¡ o stopˆ

; ------ na‡ten¡ po‡ te‡n¡ho ‡asu stopy

         mov       si,offset ZarizBuf+2     ; po‡ te‡n¡ ‡as stopy
         call      GetRBook                 ; na‡ten¡ ‡¡sla r me‡ku

; ------ n vrat registr–

GetTrck8:pop       si
         pop       cx
         pop       bx
         ret

GetTrack ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ ‡¡sla r me‡ku DX:AX na adresu DS:DI (Red Book form t)
; -----------------------------------------------------------------------------

SetRBook PROC      NEAR

         push      bx
         push      cx

         cld
         mov       cx,75                    ; po‡et r me‡k– na sekundu
         call      DivCX                    ; p©epo‡et na sekundy
         mov       ds:[di],bl               ; ‡¡slo r me‡ku
         inc       di

         mov       cl,60                    ; po‡et sekund na minutu
         call      DivCX                    ; p©epo‡et na minuty
         mov       ds:[di],bl               ; ‡¡slo sekundu
         inc       di

         stosw                              ; po‡et minut

         pop       cx
         pop       bx
         ret

SetRBook ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla r me‡ku z adresy DS:SI (Red Book form t) -> DX:AX
; -----------------------------------------------------------------------------

GetRBook PROC      NEAR

         mov       al,60                    ; po‡et sekund na minutu
         mul       byte ptr ds:[si+2]       ; p©epo‡et minut na sekundy
         add       al,ds:[si+1]             ; p©i‡ten¡ sekund
         adc       ah,0
         mov       dx,75                    ; po‡et r me‡k– na sekundu
         mul       dx                       ; p©epo‡et sekund na r me‡ky
         add       al,ds:[si]               ; p©i‡ten¡ po‡tu r me‡k–
         adc       ah,0
         adc       dx,0
         ret

GetRBook ENDP

; -----------------------------------------------------------------------------
;        rozbor p©¡kazov‚ho © dku (CY=chyba)
; -----------------------------------------------------------------------------
;þ
Rozbor   PROC      NEAR

         mov       si,81h

; ------ na‡ten¡ dal¨¡ho znaku parametru

Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jnc       Rozbor11                 ; je dal¨¡ znak
         clc
         ret

; ------ "I" - v˜pis informac¡ o disku

Rozbor11:cmp       al,"I"
         jne       Rozbor12
         or        byte ptr ds:[Zadano],1   ; p©¡znak v˜pisu informac¡
         jmp       short Rozbor1

; ------ "L" - v˜pis obsahu disku

Rozbor12:cmp       al,"L"
         jne       Rozbor2
         or        byte ptr ds:[Zadano],2   ; p©¡znak v˜pisu obsahu
         call      RozbTime                 ; na‡ten¡ ‡asu po‡ tku
         mov       word ptr ds:[KorTime],ax ; ‡as po‡ tku
         mov       word ptr ds:[KorTime+2],dx
         jmp       short Rozbor1

; ------ "S" - stop p©ehr v n¡

Rozbor2: cmp       al,"S"
         jne       Rozbor22
         or        byte ptr ds:[Zadano],4   ; zastaven¡ p©ehr v n¡
         jmp       short Rozbor1

; ------ "C" - pokra‡ov n¡ v p©ehr v n¡

Rozbor22:cmp       al,"C"
         jne       Rozbor24
         or        byte ptr ds:[Zadano],8   ; pokra‡ov n¡ v p©ehr v n¡
         jmp       short Rozbor1

; ------ "R" - ‡ten¡ dat

Rozbor24:
;cmp       al,"R"
;         jne       Rozbor3
;         call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
;         jc        Rozbor9                  ; chyba
;         cmp       al,"A"                   ; absolutn¡
;         jne       Rozbor25
;         or        byte ptr ds:[Zadano],10h ; absolutn¡ ‡ten¡
;
;         call      RozbSekt                 ; na‡ten¡ ‡¡sla po‡ te‡n¡ho sektoru
;         mov       word ptr ds:[BegSektR],ax ; po‡ te‡n¡ sektor
;         mov       word ptr ds:[BegSektR+2],dx
;         mov       word ptr ds:[EndSektR],ax ; po‡ te‡n¡ sektor
;         mov       word ptr ds:[EndSektR+2],dx
;         call      RozbOdd1                 ; vypu¨tˆn¡ oddˆlova‡e
;         jc        Rozbr244
;         call      RozbSekt                 ; na‡ten¡ ‡¡sla koncov‚ho sektoru
;         jnc       Rozbr242
;         mov       dx,word ptr ds:[KonecAdr+2]
;         mov       ax,word ptr ds:[KonecAdr]
;         sub       ax,1
;         sbb       dx,0
;Rozbr242:mov       word ptr ds:[EndSektR],ax ; koncov˜ sektor
;         mov       word ptr ds:[EndSektR+2],dx
;Rozbr244:jmp       Rozbor1
;
;Rozbor25:
;
;
;
;
;Rozbor3:

; ------ "P" - p©ehr v n¡ nahr vky

         cmp       al,"P"
         jne       Rozbor4
         or        byte ptr ds:[Zadano],20h
         call      RozbNum                  ; na‡ten¡ ‡¡sla nahr vky
         or        ax,ax
         jnz       Rozbor34
         inc       ax
Rozbor34:or        ah,ah
         jz        Rozbor35
         mov       ax,0ffh
Rozbor35:cmp       al,ds:[EndTrack]
         jb        Rozbor36
         mov       al,ds:[EndTrack]
Rozbor36:call      GetTrack                 ; na‡ten¡ informac¡ o stopˆ
         mov       word ptr ds:[PlayAdr],ax ; adresa k p©ehr t¡
         mov       word ptr ds:[PlayAdr+2],dx
         jmp       short Rozbor1

; ------ "D" - zobrazen¡ stavu

Rozbor4: cmp       al,"D"
         jne       Rozbor5
         or        byte ptr ds:[Zadano],40h ; zobrazen¡ stavu
         jmp       short Rozbor1

; ------ "T" - test stavu disku

Rozbor5: cmp       al,"T"
         jne       Rozbor6
         or        byte ptr ds:[Zadano],80h ; test stavu disku
         jmp       Rozbor1

Rozbor6:

Rozbor9: stc                                ; p©¡znak chyby - neplatn˜ znak
         ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        zad n¡ ‡asu ve tvaru HH:MM:SS -> DX:AX
; -----------------------------------------------------------------------------

RozbTime PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ na‡ten¡ hodiny

         call      RozbOdd                  ; na‡ten¡ hodiny
         mov       dx,60                    ; po‡et minut na hodinu
         mul       dx                       ; p©epo‡et hodin na minuty
         xchg      ax,bx                    ; BX <- £schova minut LOW

; ------ na‡ten¡ minut

         call      RozbOdd                  ; na‡ten¡ minut
         add       ax,bx                    ; p©i‡ten¡ p©enosu z hodin
         adc       dx,0
         mov       cx,60
         call      MulCX                    ; p©epo‡et na sekundy
         xchg      ax,bx                    ; BX <- £schova sekund LOW

; ------ na‡ten¡ sekund

         call      RozbOdd                  ; na‡ten¡ sekund
         add       ax,bx                    ; p©i‡ten¡ p©enosu z minut
         adc       dx,0
         mov       cx,75
         call      MulCX                    ; p©epo‡et na r me‡ky

; ------ n vrat registr–

         pop       cx
         pop       bx
         ret

RozbTime ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla do AX s vypu¨tˆn¡m oddˆlova‡e
; -----------------------------------------------------------------------------

RozbOdd  PROC      NEAR

         call      RozbNum                  ; na‡ten¡ ‡¡sla do AX
RozbOdd1:push      ax                       ; £schova ‡¡sla v AX
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbOdd2
         cmp       al,":"
         je        RozbOdd2
         cmp       al,"-"
         je        RozbOdd2
         cmp       al,"."
         je        RozbOdd2
         cmp       al,","
         je        RozbOdd2
         dec       si
         stc
RozbOdd2:pop       ax
         ret

RozbOdd  ENDP

;; -----------------------------------------------------------------------------
;;        na‡ten¡ ‡¡sla sektoru -> DX:AX
;; -----------------------------------------------------------------------------
;
;RozbSekt PROC      NEAR
;
;         call      RozbDNum                 ; na‡ten¡ 2slova
;         jc        RozbSkt4
;
;         cmp       dx,word ptr ds:[KonecAdr+2]
;         jne       RozbSkt2
;         cmp       ax,word ptr ds:[KonecAdr]
;RozbSkt2:jb        RozbSkt3
;
;         mov       dx,word ptr ds:[KonecAdr+2]
;         mov       ax,word ptr ds:[KonecAdr]
;         sub       ax,1
;         sbb       dx,0
;
;RozbSkt3:clc
;RozbSkt4:ret
;
;RozbSekt ENDP
;
; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla do DX:AX
; -----------------------------------------------------------------------------

RozbDNum PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx
         xor       bx,bx                    ; BX = st©ada‡ LOW
         xor       dx,dx                    ; DX = st©ada‡ HIGH
         mov       cx,10                    ; n sobitel

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbNm                   ; na‡ten¡ prvn¡ ‡¡slice
         jc        RozbDNm9                 ; chyba

; ------ p©id n¡ ‡¡slice AL ke st©ada‡i

RozbDNm2:mov       ah,0
         push      ax                       ; nov  ‡¡slice
         xchg      ax,bx                    ; AX <- st©ada‡
         call      MulCX                    ; vyn soben¡ st©ada‡e
         pop       bx                       ; BX <- nov  ‡¡slice
         add       bx,ax                    ; p©i‡ten¡ ‡¡sla ke st©ada‡i
         adc       dx,0

; ------ na‡ten¡ dal¨¡ ‡¡slice

         call      RozbNm                   ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       RozbDNm2                 ; je dal¨¡ ‡¡slice OK
         clc                                ; p©¡znak zad n¡ OK

; ------ n vrat registr–

RozbDNm9:xchg      ax,bx                    ; AX <- ‡¡slo LOW
         pop       cx
         pop       bx
         ret

RozbDNum ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla do AX
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         xor       bx,bx                    ; BX <- st©ada‡

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbNm                   ; na‡ten¡ prvn¡ ‡¡slice
         jc        RozbNum9                 ; chyba

; ------ p©id n¡ ‡¡slice AL ke st©ada‡i

RozbNum2:mov       ah,0
         xchg      ax,bx                    ; BX <- nov  ‡¡slice, AX <- st©ada‡
         mov       dx,10
         mul       dx                       ; st©ada‡ * 10
         add       bx,ax                    ; p©i‡ten¡ ‡¡sla ke st©ada‡i

; ------ na‡ten¡ dal¨¡ ‡¡slice

         call      RozbNm                   ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       RozbNum2                 ; je dal¨¡ ‡¡slice OK
         clc                                ; p©¡znak zad n¡ OK

; ------ n vrat registr–

RozbNum9:xchg      ax,bx                    ; AX <- ‡¡slo
         pop       dx
         pop       bx
         ret

RozbNum  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jedn‚ ‡¡slice
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbNm9                  ; nen¡ dal¨¡ znak
         cmp       al,"0"
         jb        RozbNm8
         cmp       al,"9"+1
         cmc
         jc        RozbNm8
         sub       al,"0"
         ret

RozbNm8: dec       si
RozbNm9: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr
         jc        RozbSpc2
         je        RozbSpc
         dec       si
RozbSpc2:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       RozbChr2
         mov       al," "

RozbChr2:cmp       al,"a"
         jb        RozbChr4
         cmp       al,"z"
         ja        RozbChr4
         sub       al,32

RozbChr4:cmp       al," "
         jae       RozbChr6
         dec       si

RozbChr6:ret

RozbChr  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 2Fh s £schovou registr– (m–‘e navracet i CF !)
; -----------------------------------------------------------------------------

Int2F    PROC      NEAR

         mov       bx,offset Pozadav        ; buffer po‘adavku

Int2F0:  push      si
         push      di
         push      bp
         push      ds
         push      es

         push      ds
         pop       es                       ; segment bufferu
         mov       ah,15h
         int       2fh

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Int2F    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------
;þ
Zadano   db        0                        ; zadan‚ parametry
                                            ;   bit 0: 1=v˜pis informac¡ o disku
                                            ;   bit 1: 1=v˜pis obsahu disku
                                            ;   bit 2: 1=STOP p©ehr v n¡
                                            ;   bit 3: 1=pokra‡ov n¡ p©ehr v n¡
;                                            ;   bit 4: 1=absolutn¡ ‡ten¡
                                            ;   bit 5: 1=p©ehr v n¡ nahr vky
                                            ;   bit 6: 1=zobrazen¡ stavu
                                            ;   bit 7: 1=test stavu disku

;Param    db        0                        ; parametry
;                                            ;   bit 0: 1=rychlop©ehr v n¡

;CopyrTxt db        'Copyright disku CD-ROM: "$'

HelpTxt  db        13,10,'CDPLAY v 0.97 - prehravac audio CD disku; (c) Miroslav Nemecek',13,10
         db        'Zadejte:  I ........... zobrazeni informaci o disku',13,10
         db        '          L ........... vypis obsahu disku',13,10
         db        '          L hh:mm:ss .. vypis obsahu s prictenim casu',13,10
         db        '          S ........... STOP, pauza prehravani',13,10
         db        '          C ........... CONTINUE, pokracovani v prehravani',13,10
         db        '          P n ......... PLAY, prehravani od nahravky n (impl. n=1)',13,10
         db        '          T ........... test stavu disku - navraci navratovy kod:',13,10
         db        '                                     0 = probiha prehravani',13,10
         db        '                                     1 = neprobiha prehravani',13,10
         db        '                                   255 = chyba',13,10
;         db        '          P n1-n2 ..... PLAY, prehravani od nahravky n1 po n2',13,10
;         db        '          P ........... play, pokracovani prehravani',13,10
;         db        '          RA n1 - n2 .. absolutni cteni od sektoru n1 po n2',13,10
;         db        '                        (data se ulozi do souboru CDROM.TMP)',13,10
;         db        '          N ........... nasledujici nahravka',13,10
;         db        '          B ........... predchozi nahravka',13,10
;         db        '          P n ......... prehravani od nahravky n (n=1...)',13,10
         db        '          D ........... zobrazeni stavu prehravani',13,10
         db        13,10
         db        '$'

InfoTxt1 db        'Detekovan ovladac CD-ROM disku verze $'
InfoTxt2 db        13,10,'Disk nainstalovan jako logicky disk '
InfoTxt3 db        'A:',13,10
         db        'Pocet nahravek na disku: $'
InfoTxt4 db        13,10
         db        'Celkova hraci doba disku: '
InfoTx42 db        '0:00:00,00',13,10
         db        'Velikost jednoho sektoru: $'
InfoTxt5 db        ' bajtu',13,10
         db        'Celkova velikost disku: $'
InfoTxt6 db        ' sektoru ($'
InfoTxt7 db        ' MB)',13,10
         db        13,10
         db        '$'

ReadyTxt db        'Disk CD-ROM neni pristupny !',13,10,'$'
NicTxt   db        'Neni nainstalovan ovladac CD-ROM disku !',13,10,'$'

StavTxt  db        13,10
         db        'Ovladani:       nahoru/dolu = nahravka zpet/vpred',13,10
         db        '               vlevo/vpravo = posun o 15 sekund zpet/vpred',13,10
         db        '                     mezera = zastaveni/pokracovani prehravani',13,10
         db        '                        ESC = preruseni zobrazeni',13,10
         db        '                   1-9, A-Z = start od skladby 1...',13,10
;         db        '                     mezera = rychlop©ehr v n¡ zap/vyp',13,10
         db        13,10
StavTxt1 db           'nahravka³   cas    ³  zbyva   ³  delka   ³ cas abs. ³zbyva abs.³delka abs.³',13,10
StavTxt2 db        13,'    1   ³ 00:00,00 ³ 00:00,00 ³ 00:00,00 ³ 00:00,00 ³ 00:00,00 ³ 00:00,00 ³$'
StopTxt  db        'STOP$'
NStopTxt db        '    $'

;WritTxt  db        'Chyba zapisu do vystupniho souboru CDROM.TMP !',13,10,'$'
;ReadSoub db        'CDROM.TMP',0
;ReadIdnt dw        0

StopaTxt db        '0:00:00 ( 1) ..........................................................'
StopaTx2 db        '00:00,00$'

DataTxt  db        ' DATA$'
QuadTxt  db        ' QUADRO$'
PreemTxt db        ' PREEM$'
ProtTxt  db        ' COPY$'

CRTxt    db        13,10,'$'

KonecTxt db        '0:00:00                                                       celkem '
KonecTx2 db        '  00:00,00',13,10,'$'

BegSektR dd        0                        ; po‡ te‡n¡ sektor ‡ten¡
EndSektR dd        0                        ; koncov˜ sektor ‡ten¡

KorTime  dd        0                        ; ‡as po‡ tku v˜pisu

AktAAdr  dd        0                        ; aktu ln¡ absolutn¡ pozice hlav

PlayAdr  dd        0                        ; adresa pro p©ehr t¡ nahr vky

BeginAdr dd        0                        ; r me‡ek za‡ tku (stopa 1)
KonecAdr dd        0                        ; r me‡ek konce (v˜bˆh CD-ROM)

TrackAdr dd        0                        ; adresa aktu ln¡ stopy
TrckInfo db        0                        ; INFO bajt aktu ln¡ stopy
                                            ;  bit 4: 1=preemf ze audio stopy
                                            ;  bit 5: 1=z kaz digit ln¡ kopie
                                            ;  bit 6: 1=datov  stopa, 0=audio
                                            ;  bit 7: 1=4 kan ly, 0=2 kan ly

NextAdr  dd        0                        ; adresa p©¡¨t¡ stopy
NextInfo db        0                        ; INFO bajt p©¡¨t¡ stopy

; ------ ukazatel stop disku

Track    db        0                        ; aktu ln¡ stopa 1...
BegTrack db        0                        ; po‡ te‡n¡ stopa
EndTrack db        0                        ; koncov  stopa
Disk     db        -1                       ; aktivn¡ disk 0...

; ------ buffery

Pozadav  db        100 dup(?)               ; po‘adavek na ovlada‡ CD-ROM
ZarizBuf db        100 dup(?)               ; buffer z hlav¡ p©¡stupu k za©¡zen¡

Buffer   db        2048 dup(?)              ; buffer pro na‡ten¡ sektoru

Code     ENDS
         END       Start

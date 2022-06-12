
; *****************************************************************************
;
;                              A N I M V I E W
;
;                    Prohl¡‘e‡ sn¡mk– displeje form tu SCR
;
; *****************************************************************************

BuffSize EQU       2000h                    ; velikost diskov‚ho bufferu

code     segment
         assume    cs:code,ds:code
         org       100h

                                          ;* zobrazen¡ £vodn¡ho textu
start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         mov       ah,0fh
         call      Int10P
         mov       ds:[OldVMod],al

                                          ;* detekce parametr– displeje
         call      DetectCard               ; detekce grafick‚ karty
         call      DetTyp                   ; ur‡en¡ typu karty
         call      DetMono                  ; detekce monochromatick‚ho displeje

                                          ;* nalezen¡ za‡ tku textu souboru
         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       ch,0                     ; CH <- 0
         mov       cl,ds:[80h]              ; po‡et znak–
Start1:  jcxz      Start33                  ; chyba - nen¡ nic zad no
         lodsb
         dec       cx
         cmp       al," "                   ; je platn˜ znak ?
         jbe       Start1                   ; nen¡ platn˜ znak - dal¨¡ znak
         mov       dx,si                    ; £schova za‡ tku textu
         dec       dx

                                          ;* nalezen¡ konce textu
Start2:  jcxz      Start3                   ; konec textu
         lodsb
         dec       cx
         cmp       al," "
         ja        Start2                   ; nalezen¡ konce textu
         dec       si                       ; n vrat posledn¡ho znaku
Start3:  mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu

                                          ;* otev©en¡ souboru
         mov       ax,3d00h                 ; funkce otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jnc       Start4

Start33: jmp       Chyba                    ; chyba - soubor nenalezen

Start4:  mov       ds:[Idents],ax           ; identifik tor souboru
         mov       bx,ax                    ; identifik tor souboru

                                          ;* na‡ten¡ z hlav¡ souboru
         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ souboru
         jc        Start33                  ; chyba ‡ten¡
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         jne       Start33                  ; chyba

                                          ;* na‡ten¡ definice palet
         mov       dx,offset KonHl          ; buffer palet
         mov       cx,ds:[Palety]           ; po‡et bajt– palet
         mov       ah,3fh
         int       21h                      ; na‡ten¡ definice palet
         jc        Start33
         cmp       ax,cx
         jne       Start33

                                          ;* kontrola spr vnosti z hlav¡
         cmp       word ptr ds:[Ident],"CS" ; prvn¡ 2 znaky - SC
         jne       Start33                  ; chybn˜ soubor
         cmp       word ptr ds:[Ident+2],1*256+"R" ; t©et¡ znak a ‡¡slo verze 1
         jne       Start33                  ; chybn˜ soubor
         cmp       byte ptr ds:[Mod],19     ; maxim ln¡ videom¢d
         ja        Start33                  ; chybn˜ soubor
         cmp       word ptr ds:[Rovin],8    ; po‡et rovin
         ja        Start33                  ; chybn˜ soubor
         cmp       word ptr ds:[Vyska],480  ; maxim ln¡ v˜¨ka
         ja        Start33                  ; chybn˜ soubor
         cmp       word ptr ds:[Sirka],640  ; maxim ln¡ ¨¡©ka
         ja        Start33                  ; chybn˜ soubor


         call      SetVMod                  ; nastaven¡ po‘adovan‚ho videom¢du
         jc        Chyba2                   ; chyba - chybn  grafick  karta

                                          ;* nastaven¡ palet VGA
         cmp       byte ptr ds:[Mod],19     ; je videom¢d VGA ?
         jne       Start5
         test      byte ptr ds:[Param],10h
         jz        Start5

         mov       ax,1012h
         xor       bx,bx
         mov       cx,100h
         mov       dx,offset KonHl
         push      ds
         pop       es
         int       10h                      ; nastaven¡ palet displeje

Start5:
         call      GetMod                   ; poskytnut¡ parametr– videom¢du


                                          ;* zde je ES = segment videopamˆti
         call      Zobraz                   ; zobrazen¡ sn¡mku

         mov       dl,0
         mov       dh,byte ptr ds:[MaxVys]
         mov       ah,2
         call      Int10P                   ; nastaven¡ kurzoru mimo displej

         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy

         mov       al,ds:[OldVMod]
         mov       ah,0
         call      Int10P                   ; n vrat videom¢du

         cmp       byte ptr ds:[EgaVga],0   ; byla karta EGA/VGA ?
         je        Navrat                   ; nebyla karta EGA/VGA

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[487h],not 81h ; zru¨. p©¡znaku hust‚ho © dkov n¡
         pop       ds
         mov       ah,1
         mov       cx,607h
         call      Int10P                   ; nastaven¡ rozmˆr– kurzoru

Navrat:  mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset ErTxt
         mov       ah,9
         int       21h
chyba2:  mov       ax,4c01h
         int       21h


; *****************************************************************************
;                    Nastaven¡ videom¢du
; -----------------------------------------------------------------------------
; *****************************************************************************

SetVMod: mov       bl,ds:[TypCard]          ; typ grafick‚ karty
         mov       al,ds:[Mod]              ; videom¢d displeje

                                          ;* m  b˜t textov˜ videom¢d CGA
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         ja        SetVMod2                 ; nen¡ textov˜ videom¢d CGA
         or        bl,bl                    ; je grafick  karta CGA ?
         jz        SetVMod8                 ; je grafick  karta CGA
         cmp       bl,2                     ; je grafick  karta EGA color ?
         je        SetVMod8                 ; je grafick  karta EGA color
         cmp       bl,4                     ; je grafick  karta VGA ?
         je        SetVMod8                 ; je grafick  karta VGA
         mov       al,7                     ; n hradn¡ videom¢d 7
         jmp       short SetVMod8           ; nastaven¡ videom¢du 7

                                          ;* m  b˜t textov˜ videom¢d MDA
SetVMod2:cmp       al,7                     ; je textov˜ videom¢d 7 ?
         jne       SetVmod3                 ; nen¡ textov˜ videom¢d 7
         cmp       bl,1                     ; je karta MDA ?
         je        SetVMod8                 ; je karta MDA - OK
         cmp       bl,3                     ; je karta EGA mono ?
         je        SetVMod8                 ; je karta EGA - OK
         cmp       bl,4                     ; je karta VGA ?
         je        SetVMod8                 ; je karta VGA - OK
         mov       al,3                     ; n hradn¡ videom¢d 3
         cmp       byte ptr ds:[Monochr],0  ; je monochromatick˜ displej ?
         je        SetVMod8                 ; nen¡ monochromatick˜ displej
         mov       al,2                     ; n hradn¡ videom¢d 2
         jmp       short SetVMod8           ; nastaven¡ videom¢du

                                          ;* m  b˜t grafick˜ videom¢d CGA
SetVMod3:cmp       al,7                     ; je grafick˜ videom¢d CGA ?
         ja        SetVMod4                 ; nen¡ grafick˜ videom¢d CGA
         cmp       bl,1                     ; je grafick  karta MDA ?
         jne       SetVMod8                 ; nen¡ grafick  karta MDA
         jmp       short SetVModa           ; videom¢d nelze nastavit

                                          ;* m  b˜t grafick˜ videom¢d EGA
SetVMod4:cmp       bl,2                     ; je grafick  karta EGA nebo VGA ?
         jb        SetVModa                 ; nen¡ EGA/VGA - chyba

                                          ;* nastaven¡ videom¢du AL
SetVMod8:push      ax
         mov       ah,0
         call      Int10P                   ; nastaven¡ videom¢du displeje
         mov       ah,0fh
         call      Int10P
         mov       ds:[VMod],al             ; skute‡n¡ videom¢d
         pop       ax
         cmp       al,ds:[VMod]             ; videom¢d nastaven ?
         jne       SetVModa                 ; chyba nastaven¡ videom¢du

                                          ;* nastaven¡ hust¨¡ho © dkov n¡ textu
         cmp       al,7                     ; je videom¢d EGA ?
         ja        SetVMod9                 ; nen¡ textov˜ videom¢d
         je        SetVModb                 ; je textov˜ videom¢d
         cmp       al,3                     ; je textov˜ videom¢d CGA ?
         ja        SetVMod9                 ; je grafick˜ videom¢d
SetVModb:cmp       byte ptr ds:[EgaVga],0   ; je grafick  karta EGA/VGA ?
         je        SetVMod9                 ; nen¡ grafick  karta EGA/VGA

         cmp       word ptr ds:[Vyska],26   ; je vˆt¨¡ po‡et © dk– ?
         cmc
         jnc       SetVMod9                 ; po‡et © dk– je OK

         mov       ax,1112h                 ; funkce na‡ten¡ font– 8x8
         mov       bl,0                     ; fonty 0
         call      Int10P                   ; nastaven¡ hust¨¡ho © dkov n¡

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         or        byte ptr ds:[487h],1     ; p©¡znak hust‚ho © dkov n¡
         pop       ds

         mov       ah,1
         mov       cx,607h
         call      Int10P                   ; nastaven¡ standardn¡ho kurzoru

;         push      ds
;         xor       ax,ax
;         mov       ds,ax                    ; DS <- 0
;         or        byte ptr ds:[487h],1     ; p©¡znak hust‚ho © dkov n¡
;         pop       ds

         jmp       short SetVMod9

                                          ;* chyba - chybn  grafick  karta
SetVModa:mov       dx,offset KartTxt        ; text - chybn  karta
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         stc                                ; p©¡znak chyby

SetVMod9:ret

; *****************************************************************************
;                Poskytnut¡ parametr– videom¢du
; -----------------------------------------------------------------------------
;
; *****************************************************************************

GetMod:
                                          ;* ur‡en¡ segmentu videopamˆti
         mov       bl,ds:[Vmod]             ; nastaven˜ videom¢d
         mov       ax,0b800h                ; segment CGA
         cmp       bl,7                     ; je videom¢d CGA ?
         jb        GetMod1                  ; je videom¢d CGA
         mov       ax,0b000h                ; segment MDA
         cmp       bl,13                    ; je videom¢d MDA ?
         jb        GetMod1                  ; je videom¢d MDA
         mov       ax,0a000h                ; jinak segment EGA
GetMod1: mov       es,ax                    ; segment videopamˆti

                                          ;* ur‡en¡ rozmˆr– displeje
         mov       bh,0
         shl       bx,1
         shl       bx,1                     ; videom¢d * 4
         mov       ax,ds:[bx+TabMod]        ; ¨¡©ka displeje
         mov       ds:[MaxSir],ax           ; ¨¡©ka displeje
         mov       ax,ds:[bx+TabMod+2]      ; v˜¨ka displeje
         mov       ds:[MaxVys],ax           ; v˜¨ka displeje

         ret

; *****************************************************************************
;                  Zobrazen¡ sn¡mku
; -----------------------------------------------------------------------------
; *****************************************************************************

Zobraz:
         cld

; ------ zji¨tˆn¡ d‚lky videostr nky

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       cx,ds:[44ch]             ; d‚lka videostr nky
         shr       cx,1                     ; p©evod na d‚lku ve slovech
         pop       ds
         mov       bx,ds:[Pozadi]           ; barva pozad¡
         xor       di,di                    ; po‡ te‡n¡ adresa
         cld


         mov       al,ds:[VMod]             ; aktu ln¡ videom¢d

                                          ;* rozli¨en¡ textov‚ho videom¢du
         cmp       al,7
         je        Zobraz1                  ; videom¢d MDA
         cmp       al,3
         ja        Zobraz2                  ; nen¡ textov˜ videom¢d
Zobraz1: jmp       ZobrTxt                  ; zobrazen¡ v textov‚m m¢du

                                          ;* zobrazen¡ v grafick‚m m¢du CGA
Zobraz2: cmp       al,17                    ; grafick˜ videom¢d MCGA ?
         je        Zobraz3                  ; je MCGA mono
         cmp       al,7                     ; je grafick˜ videom¢d CGA ?
         jae       Zobraz4                  ; nen¡ grafick˜ videom¢d CGA
Zobraz3: jmp       ZobrCGA                  ; zobrazen¡ grafick‚ho m¢du CGA

                                          ;* zobrazen¡ v grafick‚m m¢du MCGA
Zobraz4: cmp       al,19                    ; grafick˜ videom¢d MCGA ?
         jne       Zobraz5                  ; nen¡ m¢d MCGA
         jmp       ZobrMCG                  ; zobrazen¡ v m¢du MCGA

Zobraz5: jmp       ZobrEGA                  ; zobrazen¡ grafick‚ho m¢du EGA

; -----------------------------------------------------------------------------
;        Zobrazen¡ sn¡mku v textov‚m m¢du
; -----------------------------------------------------------------------------

                                          ;* ur‡en¡ skute‡n‚ho po‡tu © dk–
ZobrTxt:
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA/VGA ?
         je        ZobrTxt1                 ; nen¡ karta EGA/VGA

; ------ vymaz n¡ displeje

         mov       ah,bl                    ; barva
         mov       al," "                   ; mazac¡ znak
         cld
         rep       stosw                    ; vymaz n¡ displeje

; ------ p©esko‡en¡ str nky masky

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       al,ds:[484h]             ; ‡¡slo posledn¡ho © dku
         inc       ax                       ; po‡et © dk–
         pop       ds
         mov       ds:[MaxVys],ax           ; maxim ln¡ v˜¨ka displeje

; ------ p©esko‡en¡ masky

ZobrTxt1:test      byte ptr ds:[Param],8    ; je maska ?
         jz        ZobrTx6                  ; nen¡ maska

ZobrTx1: mov       cx,ds:[Vyska]
ZobrTx2: push      cx
         mov       cx,ds:[Sirka]
ZobrTx3: call      ReadByte
         jc        ZobrTx4
         loop      ZobrTx3
ZobrTx4: pop       cx

; ------ zobrazen¡ roviny 0 (znaky)

ZobrTx6: xor       di,di
         mov       cx,ds:[Vyska]
ZobrTxt2:push      cx
         mov       cx,ds:[Sirka]
         push      di
ZobrTxt3:call      ReadByte
         jc        ZobrTxt6
         stosb
         inc       di
         loop      ZobrTxt3
ZobrTxt6:pop       di
         pop       cx
         jc        ZobrTxt8
         add       di,ds:[MaxSir]
         add       di,ds:[MaxSir]
         loop      ZobrTxt2

; ------ zobrazen¡ roviny 1 (atributy)

         mov       di,1
         mov       cx,ds:[Vyska]
ZobrTxt4:push      cx
         mov       cx,ds:[Sirka]
         push      di
ZobrTxt5:call      ReadByte
         jc        ZobrTxt7
         stosb
         inc       di
         loop      ZobrTxt5
ZobrTxt7:pop       di
         pop       cx
         jc        ZobrTxt8
         add       di,ds:[MaxSir]
         add       di,ds:[MaxSir]
         loop      ZobrTxt4
ZobrTxt8:
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ grafick‚ho m¢du CGA
; -----------------------------------------------------------------------------

ZobrCGA:

; ------- p©esko‡en¡ masky

ZobrCG1: test      byte ptr ds:[Param],8    ; je maska ?
         jz        ZobrCGA1                 ; nen¡ maska

; ------ vymaz n¡ displeje

         cld
         mov       al,bl                    ; barva
         mov       ah,bl                    ; barva
         and       ah,3
         shl       al,1
         shl       al,1
         or        al,ah
         shl       al,1
         shl       al,1
         or        al,ah
         shl       al,1
         shl       al,1
         or        al,ah                    ; barva
         cmp       byte ptr ds:[Mod],6
         jb        ZobrCG11
         test      al,1
         mov       al,0
         jz        ZobrCG11
         mov       al,0ffh
ZobrCG11:mov       ah,al                    ; barva
         rep       stosw


         cld
         mov       cx,ds:[Vyska]
ZobrCG2: push      cx
         mov       cx,ds:[Sirka]
         add       cx,3
         shr       cx,1
         shr       cx,1
         cmp       byte ptr ds:[VMod],6
         jb        ZobrCG3
         inc       cx
         shr       cx,1
ZobrCG3: call      ReadByte
         jc        ZobrCG6
         loop      ZobrCG3
ZobrCG6: pop       cx
         loop      ZobrCG2


                                          ;* zobrazen¡ roviny 0
ZobrCGA1:cld
         xor       di,di                    ; ukl dac¡ adresa
         xor       bx,bx                    ; ukazatel linek
         mov       cx,ds:[Vyska]

                                          ;* cyklus zobrazen¡ jedn‚ linky
ZobrCGA2:push      cx
         push      di
         mov       cx,ds:[Sirka]
         add       cx,3
         shr       cx,1
         shr       cx,1
         cmp       byte ptr ds:[VMod],6
         jb        ZobrCGA3
         inc       cx
         shr       cx,1

                                          ;* cyklus zobrazen¡ jednoho bajtu
ZobrCGA3:call      ReadByte
         jc        ZobrCGA6
         stosb                              ; ulo‘en¡ bajtu
         loop      ZobrCGA3


ZobrCGA6:pop       di
         pop       cx
         jc        ZobrCGA8                 ; chyba
         xor       di,2000h                 ; zmˆna linky
         test      bx,1                     ; je lich  linka ?
         jz        ZobrCG63                 ; je sud  linka
         add       di,50h
ZobrCG63:inc       bx
         loop      ZobrCGA2

ZobrCGA8:ret


; -----------------------------------------------------------------------------
;        Zobrazen¡ grafick‚ho m¢du MCGA
; -----------------------------------------------------------------------------

ZobrMCG:

                                          ;* zobrazen¡ roviny 0
         cld

ZobrMCG1:xor       di,di                    ; ukl dac¡ adresa
         mov       cx,ds:[Vyska]            ; po‡et linek

                                          ;* cyklus zobrazen¡ jedn‚ linky
ZobrMCG2:push      cx
         push      di
         mov       cx,ds:[Sirka]
                                          ;* cyklus zobrazen¡ jednoho bajtu
ZobrMCG3:call      ReadByte
         jc        ZobrMCG6
         stosb
ZobrMCG4:loop      ZobrMCG3

ZobrMCG6:pop       di
         pop       cx
         jc        ZobrMCG8                 ; chyba

         add       di,320
         loop      ZobrMCG2

ZobrMCG8:ret


; -----------------------------------------------------------------------------
;        Zobrazen¡ grafick‚ho m¢du EGA
; -----------------------------------------------------------------------------

ZobrEGA:

; ------ p©esko‡en¡ masky

         cld
         test      byte ptr ds:[Param],8    ; je maska ?
         jz        ZobrEG6                  ; nen¡ maska

; ------ vymaz n¡ displeje

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; registr 0 - volba barevn‚ roviny
         inc       dx
         mov       al,bl                    ; barva
         out       dx,al                    ; volba barevn‚ roviny

         mov       ax,0ffffh
         rep       stosw



         mov       cx,ds:[Vyska]
ZobrEG2: push      cx
         mov       cx,ds:[Sirka]
         add       cx,7
         shr       cx,1
         shr       cx,1
         shr       cx,1
ZobrEG3: call      ReadByte
         jc        ZobrEG4
         loop      ZobrEG3
ZobrEG4: pop       cx
         loop      ZobrEG2




ZobrEG6: xor       si,si                    ; ukazatel roviny
         mov       bl,1                     ; maska roviny

                                          ;* zobrazen¡ jedn‚ roviny
ZobrEGA1:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; registr 0 - volba barevn‚ roviny
         inc       dx
         mov       al,bl                    ; maska roviny
         out       dx,al                    ; volba barevn‚ roviny

         xor       di,di
         mov       cx,ds:[Vyska]
ZobrEGA2:push      cx
         mov       cx,ds:[Sirka]
         add       cx,7
         shr       cx,1
         shr       cx,1
         shr       cx,1
         push      di
ZobrEGA3:call      ReadByte
         jc        ZobrEGA6
         stosb
         loop      ZobrEGA3
ZobrEGA6:pop       di
         pop       cx
         jc        ZobrEGA8
         add       di,40
         cmp       byte ptr ds:[VMod],13
         je        ZobrEGA5
         add       di,40
ZobrEGA5:loop      ZobrEGA2

         inc       si                       ; zv˜¨en¡ ‡¡ta‡e rovin
         shl       bl,1                     ; posun masky rovin
         cmp       si,ds:[Rovin]            ; jsou ji‘ v¨echny roviny ?
         jb        ZobrEGA1                 ; zobrazen¡ dal¨¡ roviny

ZobrEGA8:
         ret

; *****************************************************************************
;                     €ten¡ bajtu ze souboru
; -----------------------------------------------------------------------------
; *****************************************************************************

; -----------------------------------------------------------------------------
;        ‡ten¡ jednoho bajtu ze souboru
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         test      byte ptr ds:[Param],1    ; je komprese ?
         jz        ReadB                    ; nen¡ komprese

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ds:[KompCit],0  ; je ‡¡ta‡ platn˜ ?
         jne       ReadByt4                 ; ‡¡ta‡ je dosud platn˜
ReadByt1:call      ReadB                    ; na‡ten¡ bajtu ‡¡ta‡e
         jc        ReadByt5                 ; chyba ‡ten¡ dat
         mov       byte ptr ds:[KompCit],al ; po‡et n sleduj¡c¡ch bajt–

; ------ p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadByt2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ds:[Param0],8   ; zmˆna p©¡znaku komprese
         jmp       short ReadByt1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadByt2:and       byte ptr ds:[Param0],not 10h ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ds:[Param0],8    ; je m¢d komprese ?
         jz        ReadByt3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[Param0],10h  ; p©¡znak komprese
         call      ReadB                    ; na‡ten¡ bajtu k opakov n¡
         jc        ReadByt5                 ; chyba ‡ten¡ dat
         mov       ds:[KompChr],al          ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadByt3:cmp       byte ptr ds:[KompCit],255 ; je zmˆna m¢du komprese ?
         je        ReadByt4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ds:[Param0],8    ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadByt4:mov       al,ds:[KompChr]          ; bajt p©i opakov n¡ dat
         test      byte ptr ds:[Param0],10h  ; je opakov n¡ dat ?
         jnz       ReadByt5                 ; je opakov n¡ dat
         call      ReadB                    ; na‡ten¡ bˆ‘n‚ho bajtu dat

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn¡‘en¡ ‡¡ta‡e komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ReadB:   push      si
         mov       si,ds:[ReadBuf]          ; ukazatel ‡ten˜ch dat z bufferu
         cmp       si,ds:[NumBuf]           ; je ji‘ konec bufferu ?
         jb        ReadB3                   ; jsou je¨tˆ nˆjak  data v bufferu

                                          ;* na‡ten¡ dal¨¡ho bloku dat
         mov       word ptr ds:[ReadBuf],0  ; vynulov n¡ ukazatele dat

         push      ax
         push      bx
         push      cx
         push      dx

         mov       ah,3fh
         mov       bx,ds:[Idents]
         mov       cx,BuffSize
         mov       dx,offset buffer
         int       21h                      ; na‡ten¡ bloku dat z buferu
         jc        ReadB2
         mov       ds:[NumBuf],ax           ; nov˜ po‡et bajt– v bufferu
         or        ax,ax
         jnz       ReadB2
         stc                                ; p©¡znak konce souboru

Readb2:  pop       dx
         pop       cx
         pop       bx
         pop       ax

         mov       si,0
         jc        ReadB4                   ; byla chyba ‡ten¡

ReadB3:  mov       al,ds:[si+buffer]        ; p©e‡ten¡ bajtu z bufferu
         inc       word ptr ds:[ReadBuf]    ; zv˜¨en¡ ukazatele dat v bufferu
         clc

ReadB4:  pop        si
         ret


; *****************************************************************************
;                   Detekce monochromatick‚ho displeje
; -----------------------------------------------------------------------------
;
; *****************************************************************************

DetMono: mov       ah,0fh
         call      Int10P
         xor       bl,bl                    ; p©¡znak - nen¡ monochrom. videom¢d
         cmp       al,15                    ; je videom¢d EGA 640x350/2 ?
         je        AktParD2                 ; je videom¢d EGA 640x350/2 (mono)
         cmp       al,12                    ; je intern¡ videom¢d EGA - mono ?
         je        AktParD2                 ; je videom¢d EGA 640x350/2 (mono)
         cmp       al,7                     ; je barevn˜ grafick˜ videom¢d ?
         ja        AktParD3                 ; nen¡ monochromatick˜ videom¢d
         mov       bl,al                    ; £schova videom¢du
         cmp       bl,4                     ; je videom¢d 4 a vy¨¨¡ ?
         jae       AktParD3                 ; nen¡ textov˜ videom¢d CGA
AktParD2:xor       bl,1                     ; zmˆna p©¡znakov‚ho bitu 0
AktParD3:and       bl,1                     ; ponech  p©¡znakov˜ bit 0
         mov       ds:[Monochr],bl          ; nastaven¡ p©¡znaku monochrom. m¢du
         ret

; *****************************************************************************
;                      Detekce typu grafick‚ karty
;        0 = CGA; 1 = MDA; 2 = EGA color; 3 = EGA mono; 4 = VGA
; *****************************************************************************

DetTyp:  mov       al,ds:[VideoCard]        ; typ grafick‚ karty
         cmp       byte ptr ds:[EgaVga],0   ; je grafick  karta EGA/VGA ?
         je        DetTyp5                  ; nen¡ grafick  karta EGA/VGA

         mov       bl,4                     ; p©ednastaven¡ - karta VGA
         cmp       al,9
         je        DetTyp9                  ; je karta VGA
         mov       bl,3                     ; p©ednastaven¡ - EGA mono
         cmp       al,5
         je        DetTyp9                  ; je EGA mono
         cmp       al,15
         je        DetTyp9                  ; je EGA mono
         mov       bl,2                     ; p©ednastaven¡ - EGA color
         jmp       short DetTyp9            ; jinak EGA color

DetTyp5: mov       bl,1                     ; p©ednastaven¡ - MDA
         cmp       al,7
         je        DetTyp9                  ; je MDA
         cmp       al,15
         je        DetTyp9                  ; je MDA
         mov       bl,0                     ; jinak CGA

DetTyp9: mov       ds:[TypCard],bl          ; typ grafick‚ karty
         ret


; *****************************************************************************
;                               DetectCard
;              Detekce videokarty - rozpozn n¡ typu videokarty
; -----------------------------------------------------------------------------
; VSTUP:  DS=datov˜ segment
;
; VSTUP: AX=1: CGA
;            2: MCGA
;            3: EGA
;            4: EGA 64kB
;            5: EGA Mono
;           (6: IBM8514)
;            7: Hercules
;           (8: ATT400)
;            9: VGA
;           10: PC3270
; *****************************************************************************

DetectCard PROC    NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         call      DetCard0                 ; detekce videokarty
         xor       ax,ax
         mov       al,ds:[VideoCard]        ; detekovan  videokarta
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

DetectCard ENDP

; -----------------------------------------------------------------------------
DetCard0:
         mov       ah,0fh
         call      Int10P                   ; dotaz na videom¢d
         cmp       al,7                     ; je monochromatick˜ videom¢d ?
         je        DetCard5                 ; je monochromatick˜ videom¢d

; ------ je barevn˜ re‘im - rozpozn n¡ EGA/VGA

         call      DetCard8                 ; test karet EGA/VGA
         jc        DetCard2                 ; nen¡ karta EGA/VGA
DetCard1:call      DetCardA                 ; rozli¨en¡ karet EGA/VGA
         ret
DetCard2:                                 ;* rozpozn n¡ karty PC3270
         call      DetCardP                 ; detekce karty PC3270
         jc        DetCard3                 ; nen¡ karta PC3270
         mov       byte ptr ds:[VideoCard],10; je videokarta PC3270
         ret

DetCard3:                                 ;* rozpozn n¡ karet CGA/MCGA
         mov       byte ptr ds:[VideoCard],1; p©ednastaven¡ karty CGA
         call      DetCardG                 ; test karty MCGA
         jc        DetCard4                 ; nen¡ karta MCGA
         mov       byte ptr ds:[VideoCard],2; je karta MCGA
DetCard4:ret

; ------ monochromatick˜ re‘im (videom¢d 7)

DetCard5:                                 ;* monochrom. re‘im - test EGA/VGA
         call      DetCard8                 ; test karty EGA/VGA
         jnc       DetCard1                 ; je EGA/VGA - rozli¨en¡ EGA a VGA
                                          ;* test karty Hercules/MDA
         call      DetCardJ                 ; test karty Hercules
         jc        DetCard6                 ; nen¡ karta Hercules
         mov       byte ptr ds:[VideoCard],7; je karta Hercules
         ret
DetCard6:                                 ;* test karty CGA (test pamˆti)
         mov       si,0b800h                ; segment videopamˆti CGA
         mov       es,si                    ; segment videopamˆti CGA
         xor       si,si                    ; po‡ te‡n¡ adresa videopamˆti CGA
         mov       ax,es:[si]               ; p–vodn¡ slovo z videopamˆti
         not       ax                       ; inverze
         not       word ptr es:[si]         ; inverze i p–vodn¡ho slova
         nop
         nop
         cmp       ax,es:[si]               ; je tam pamˆŸ RAM ?
         jne       DetCard7                 ; nen¡ pamˆŸ VRAM
         mov       byte ptr ds:[VideoCard],1; je karta CGA
DetCard7:ret
; -----------------------------------------------------------------------------
DetCard8:                                 ;* test karty EGA/VGA
         mov       ax,1200h
         mov       bl,10h                   ; podslu‘ba poskytnut¡ parametr–
         mov       bh,0ffh                  ; p©ednastaven¡
         mov       cl,0fh                   ; p©ednastaven¡
         call      Int10P                   ; dotaz na EGA kartu
         cmp       cl,0ch
         jge       DetCard9                 ; nen¡ karta EGA
         cmp       bh,1
         jg        DetCard9                 ; nen¡ karta EGA
         cmp       bl,3
         jg        DetCard9                 ; nen¡ karta EGA

                                          ;* je karta EGA/VGA
         mov       byte ptr ds:[EgaVga],1   ; p©¡znak, ‘e je karta EGA/VGA
         clc                                ; p©¡znak - je karta EGA
         ret

                                          ;* nen¡ karta EGA/VGA
DetCard9:mov       byte ptr ds:[EgaVga],0   ; zru¨en¡ p©¡znaku EGA/VGA
         stc                                ; p©¡znak - nen¡ karta EGA
         ret
; -----------------------------------------------------------------------------
DetCardA:                                 ;* rozli¨en¡ karet EGA/VGA
         mov       byte ptr ds:[VideoCard],4; p©ednastaven¡ karty EGA64
         cmp       bh,1                     ; je monochromatick˜ m¢d ?
         je        DetCardD                 ; je monochromatick˜ m¢d
         call      DetCardE                 ; test karty EGA 64
         jnc       DetCardC                 ; je karta EGA 64
         or        bl,bl                    ; je EGA 64 ?
         jz        DetCardC                 ; je EGA 64
         mov       byte ptr ds:[VideoCard],3; p©ednastaven¡ karty EGA
         call      DetCardG                 ; test karty VGA
         jnc       DetCardB                 ; je karta VGA
         mov       bx,0c000h                ; segment s ROM VGA
         mov       es,bx                    ; segment s ROM VGA
         mov       bx,39h                   ; adresa textu "Z449"
         cmp       word ptr es:[bx],"Z4"    ; je text "Z4" ?
         jne       DetCardC                 ; nen¡ karta VGA
         cmp       word ptr es:[bx+2],"49"  ; je text "49" ?
         jne       DetCardC                 ; nen¡ karta VGA
DetCardB:mov       byte ptr ds:[VideoCard],9; je karta VGA
DetCardC:ret
DetCardD:mov       byte ptr ds:[VideoCard],5; je karta EGA Mono
         ret

DetCardE:                                 ;* test karty EGA 64
         cmp       cl,2
         jb        DetCardT                 ; je karta EGA 64
         cmp       cl,6
         jb        DetCardF                 ; nen¡ karta EGA 64
         cmp       cl,8
DetCardT:cmc
DetCardF:ret
; -----------------------------------------------------------------------------
DetCardG:                                 ;* test karty VGA
         mov       ax,1a00h
         call      Int10P                   ; dotaz na po‡et linek na znak
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       DetCardI                 ; funkce nen¡ obsluhovan 
         cmp       bl,7                     ; je 7 linek na znak ?
         je        DetCardH                 ; je karta OK
         cmp       bl,8
         je        DetCardH                 ; je karta OK
         cmp       bl,11
         jb        DetCardI                 ; nen¡ karta
         cmp       bl,12
         ja        DetCardI                 ; nen¡ karta
DetCardH:clc                                ; p©¡znak - je karta
         ret
DetCardI:stc                                ; p©¡znak - nen¡ karta
         ret
; -----------------------------------------------------------------------------
DetCardJ:                                 ;* test karty Hercules
         mov       dx,03bah                 ; stavov˜ port karty
         xor       bl,bl                    ; ‡¡ta‡ doby impulsu
         in        al,dx                    ; po‡ te‡n¡ stav
         and       al,80h                   ; sign l zpˆtn‚ho bˆhu
         mov       ah,al                    ; £schova stavu registru
         mov       cx,8000h                 ; maxim ln¡ doba testu
DetCardK:                                 ;* ‡ek n¡ na zmˆnu stavu bitu 7
         in        al,dx                    ; ‡ten¡ stavov‚ho registru
         and       al,80h                   ; sign l zpˆtn‚ho bˆhu
         cmp       al,ah                    ; byla zmˆna stavu sign lu ?
         je        DetCardL                 ; nebyla zmˆna stavu sign lu
         inc       bl                       ; ‡¡ta‡ d‚lky impulsu
         cmp       bl,10                    ; je minim ln¡ doba impulsu ?
         jae       DetCardM                 ; impuls je dostate‡nˆ dlouh˜
DetCardL:loop      DetCardK                 ; dal¨¡ test impulsu
         stc                                ; p©¡znak - nen¡ karta Hercules
         ret

DetCardM:                                 ;* ‡ek n¡ na bity 5,4 -> 01
         mov       cx,8000h                 ; maxim ln¡ doba testu
DetCardN:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         and       al,30h
         cmp       al,10h
         jne       DetCardO                 ; je pouze karta MDA
         loop      DetCardN                 ; dal¨¡ test
         mov       al,2                     ; p©¡znak - je karta Hercules
         clc
         ret
DetCardO:mov       al,1                     ; p©¡znak - je karta MDA
         clc
         ret
; -----------------------------------------------------------------------------
DetCardP:                                 ;* test videokarty PC3270
         mov       al,6
         xor       cx,cx                    ; CX <- 0
         xor       dx,dx
         mov       ah,30h
         call      Int10P
         mov       ax,cx
         or        ax,dx
         jz        DetCardR                 ; nen¡ karta PC3270
         push      ds
         mov       ds,cx                    ; segment
         mov       bx,dx                    ; offset
         mov       al,ds:[bx+2]
         pop       ds
         or        al,al
         jz        DetCardQ                 ; je karta PC3270
         cmp       al,2
         jne       DetCardR                 ; nen¡ karta PC3270
DetCardQ:mov       dx,188h
         in        al,dx
         test      al,4
         jz        DetCardR                 ; nen¡ karta PC3270
         clc                                ; p©¡znak - je karta PC3270
         ret
DetCardR:stc                                ; p©¡znak - nen¡ karta PC3270
         ret

; *****************************************************************************
;                              Int10P
;                Vol n¡ INT 10h s £schovou registr–
; -----------------------------------------------------------------------------
;
; *****************************************************************************

Int10P   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

Int10P   ENDP

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------

UvTxt    db        'ANIMVIEW V1.0 - prohlizec SCR; (c) Miroslav Nemecek',13,10,'$'

ErTxt    db        'Chybne zadani souboru nebo neplatny format SCR !',13,10,'$'

KartTxt  db        'Chybna graficka karta - videomod nelze nastavit !',13,10,'$'

Idents   dw        0                        ; identifik tor souboru

; -----------------------------------------------------------------------------
                                          ;* tabulka parametr– videom¢d–
TabMod   dw        40,25                    ; 0
         dw        40,25                    ; 1
         dw        80,25                    ; 2
         dw        80,25                    ; 3
         dw        320,200                  ; 4
         dw        320,200                  ; 5
         dw        640,200                  ; 6
         dw        80,25                    ; 7
         dw        160,200                  ; 8
         dw        320,200                  ; 9
         dw        640,200                  ; 10
         dw        40,200                   ; 11
         dw        40,200                   ; 12
         dw        320,200                  ; 13
         dw        640,200                  ; 14
         dw        640,350                  ; 15
         dw        640,350                  ; 16
         dw        640,480                  ; 17
         dw        640,480                  ; 18
         dw        320,200                  ; 19

; -----------------------------------------------------------------------------
Zahlavi  label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        0                        ; ¨¡©ka v˜©ezu (pozic)
Vyska    dw        0                        ; v˜¨ka v˜©ezu (linek)
Rovin    dw        0                        ; po‡et barevn˜ch rovin
Pozadi   dw        0                        ; barva pozad¡
Palety   dw        0                        ; po‡et bajt– palet
Mod      db        0                        ; videom¢d displeje
Param    db        0                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ barvy
                                            ;  bit 3: 1=je maska
                                            ;  bit 4: 1=jsou palety
KonHl    label     byte                     ; konec z hlav¡

         db        3*256 dup(0)             ; buffer pro palety

; -----------------------------------------------------------------------------
                                          ;* aktu ln¡ parametry
MaxSir   dw        80                       ; maxim ln¡ ¨¡©ka (znak–)
MaxVys   dw        25                       ; maxim ln¡ v˜¨ka (linek)
VMod     db        0                        ; skute‡n˜ videom¢d
OldVMod  db        0                        ; p–vodn¡ videom¢d

; -----------------------------------------------------------------------------
                                          ;* parametry displeje
VideoCard db       0                        ; typ videokarty
                                            ;     0=nezn m˜ typ
                                            ;     1=CGA
                                            ;     2=Multi CGA
                                            ;     3=EGA
                                            ;     4=EGA 64kB
                                            ;     5=EGA Mono
                                            ;    (6=IBM8514)
                                            ;     7=Hercules
                                            ;    (8=ATT400)
                                            ;     9=VGA
                                            ;    10=PC3270

TypCard  db        0                        ; typ karty
                                            ;  0 = CGA
                                            ;  1 = MDA
                                            ;  2 = EGA color
                                            ;  3 = EGA mono
                                            ;  4 = VGA

EgaVga   db        0                        ; p©¡znak, ‘e je karta EGA/VGA
Monochr  db        0                        ; p©¡znak monochromatick‚ho displeje
; -----------------------------------------------------------------------------

ReadBuf  dw        0                        ; ukazatel ‡ten˜ch dat z bufferu
NumBuf   dw        0                        ; po‡et bajt– v bufferu

Param0   db        8                        ; parametry
                                            ;   bit 3: 1=bude stav komprese dat
                                            ;   bit 4: 1=nyn¡ je komprese dat

KompCit  dw        0                        ; ‡¡ta‡ pro kompresi
KompChr  db        0                        ; uschovan˜ opakovan˜ bajt komprese


buffer   label     byte                     ; diskov˜ buffer

code     ends
         end       start

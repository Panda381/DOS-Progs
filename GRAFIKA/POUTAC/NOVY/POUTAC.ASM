
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                                Pouta‡
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; pou‘it¡ barev:
;    00h: pozad¡
;    01h: p¡smo - pop©ed¡
;    02h: p¡smo
;    03h: podtitul
;    04h:
;    05h: st¡n nadpisu
;    06h: hvˆzdy
;    07h: hvˆzdy
;    08h: nadpis 1 - r m
;    09h: nadpis 2
;    0ah: nadpis 3
;    0bh: nadpis 4
;    0ch: nadpis 5
;    0dh: nadpis 6
;    0eh: nadpis 7
;    0fh: nadpis 8
;    10h a‘ 1fh - r m
;    20h a‘ 2fh - ¨achovnice

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

LINEK    EQU       65                       ; polovi‡n¡ po‡et linek ¨achovnice
MAXHVZD  EQU       60                       ; maxim ln¡ po‡et hvˆzd

; ------ kontrola pamˆti

Start:   cmp       sp,offset Buffer+200h+50 ; minim ln¡ velikost pamˆti
         jae       Start2                   ; pamˆŸ je OK

; ------ chyba

         mov       dx,offset MemTxt         ; text - chyba pamˆti
Chyba:   mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h
         int       21h

; ------ kontrola grafick‚ karty EGA

Start2:  mov       ah,12h
         mov       bx,4610h
         int       10h                      ; informace EGA/VGA
         mov       dx,offset VGATxt         ; text - nen¡ VGA
         cmp       bh,1
         ja        Chyba
         cmp       bl,5
         ja        Chyba

; ------ kontrola grafick‚ karty VGA

         mov       ax,1a00h
         int       10h                      ; dotaz na po‡et linek na znak
         mov       dx,offset VGATxt         ; text - nen¡ VGA
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       Chyba                    ; funkce nen¡ obsluhovan 
         cmp       bl,7                     ; je 7 linek na znak ?
         je        Start22                  ; je karta OK
         cmp       bl,8
         je        Start22                  ; je karta OK
         cmp       bl,11
         jb        Chyba                    ; nen¡ karta
         cmp       bl,12
         ja        Chyba                    ; nen¡ karta

; ------ vymaz n¡ tabulky hvˆzd a buffer–

Start22: push      ds
         pop       es
         mov       di,offset MazBeg         ; za‡ tek k vymaz n¡
         mov       cx,(offset(MazEnd-MazBeg)+1)/2
         xor       ax,ax
         cld
         rep       stosw                    ; vymaz n¡ tabulky

; ------ inicializace jm‚na souboru

         call      InitDat                  ; inicializace datov‚ho souboru

; ------ otev©en¡ souboru

         mov       dx,offset Soubor         ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
Start3:  mov       dx,offset DatTxt         ; text chyby - soubor nenalezen
         jc        Chyba                    ; chyba - soubor nenalezen
         mov       bx,ax                    ; identifik tor souboru

; ------ na‡ten¡ souboru do pamˆti

         mov       cx,sp                    ; ukazatel z sobn¡ku
         sub       cx,offset Buffer+200h    ; velikost voln‚ho m¡sta
         mov       ah,3fh
         mov       dx,offset Buffer         ; buffer k na‡ten¡ souboru
         int       21h                      ; na‡ten¡ souboru
         jc        Start3                   ; nˆjak  chyba
         mov       si,ax                    ; po‡et na‡ten˜ch bajt–
         or        ax,ax
         jz        Start32
         cmp       byte ptr ds:[Buffer+si-1],1ah
         jne       Start32
         dec       si                       ; zru¨en¡ koncov‚ho EOF
Start32: mov       byte ptr ds:[Buffer+si],0; ozna‡en¡ konce souboru

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

; ------ £schova videom¢du

         mov       ah,0fh
         int       10h
         mov       byte ptr ds:[OldVMod],al ; £schova videom¢du

; ------ adresa syst‚mov‚ho fontu

         mov       ax,1130h
         mov       bh,6
         int       10h
         mov       word ptr ds:[Font],bp
         mov       word ptr ds:[Font+2],es

; ------ inicializace videom¢du

         mov       ax,13h
         int       10h                      ; inicializace videom¢du
         mov       ah,0fh
         int       10h
         cmp       al,13h
         je        Start34

         mov       ax,ds:[OldVMod]          ; p–vodn¡ videom¢d
         int       10h                      ; n vrat videom¢du
         mov       dx,offset VGATxt
         jmp       Chyba

Start34: call      SetPal                   ; vynulov n¡ palet displeje

; ------ zobrazen¡ ¨achovnice a r mu

         call      DispSach                 ; zobrazen¡ ¨achovnice
         call      DispRam                  ; zobrazen¡ r mu

; ------ zobrazen¡ nadpis–

         mov       si,offset Buffer         ; buffer s na‡ten˜m textem
         call      DispNad                  ; zobrazen¡ hlavn¡ho nadpisu
         call      DispSub                  ; zobrazen¡ podtitulu
         mov       ds:[BegTxt],si           ; adresa za‡ tku textu
         mov       ds:[AdrTxt],si           ; ukazatel aktivn¡ho textu
         call      Kont                     ; kontury znak–
         call      Stin                     ; st¡ny nadpisu

; ------ rozsv¡cen¡ palet displeje

         call      Rozsvit                  ; rozsv¡cen¡ palet displeje

; ------ ‡ek n¡ na stisk kl vesy

Cekej1:  mov       ah,1
         int       16h                      ; test kl vesnice
         jnz       Cekej9

; ------ rotace palet

         call      RotPal                   ; rotace palet
         call      SetPal                   ; nastaven¡ palet

; ------ obsluha hvˆzd

         call      Hvezdy                   ; obsluha hvˆzd
         call      Text                     ; obsluha zobrazen¡ textu
         call      Cekej                    ; prodleva
         jmp       short Cekej1

Cekej9:  mov       ah,0
         int       16h

; ------ n vrat videom¢du

         mov       ax,ds:[OldVMod]          ; p–vodn¡ videom¢d
         int       10h                      ; n vrat videom¢du

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

         mov       ax,4c00h
         int       21h

; *****************************************************************************
;                                 Cekej
; *****************************************************************************

PUBLIC   Cekej

Cekej    PROC      NEAR

         push      ax
         push      ds

         xor       ax,ax
         mov       ds,ax
         sti

         mov       ax,ds:[46ch]
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2

         pop       ds
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        inicializace datov‚ho souboru
; -----------------------------------------------------------------------------

InitDat  PROC      NEAR

         push      ds
         pop       es

; ------ kontrola verze syst‚mu

         mov       ah,30h
         int       21h                      ; poskytnut¡ verze syst‚mu
         cld
         cmp       al,3
         jb        InitDat4                 ; je n¡zk  verze syst‚mu

; ------ nalezen¡ konce prost©ed¡

         mov       cx,ds:[2ch]              ; segment prost©ed¡
         jcxz      InitDat4                 ; neplatn‚ prost©ed¡
         push      ds
         mov       ds,cx                    ; segment prost©ed¡
         xor       ax,ax                    ; hledan‚ slovo
         xor       si,si                    ; ukazatel prost©ed¡
InitDat1:inc       si                       ; zv˜¨en¡ ukazatele prost©ed¡
         cmp       ds:[si-1],ax             ; nalezen konec prost©ed¡ ?
         jne       InitDat1                 ; nalezen¡ konce prost©ed¡

; ------ p©enesen¡ jm‚na souboru do bufferu

         add       si,3
         mov       di,offset Soubor         ; buffer jm‚na souboru
         mov       cx,72/2                  ; max. d‚lka
         rep       movsw                    ; p©enesen¡ jm‚na souboru do bufferu
         pop       ds

; ------ nalezen¡ konce jm‚na souboru v bufferu

InitDat4:mov       si,offset Soubor         ; buffer jm‚na souboru
InitDat5:mov       di,si                    ; konec jm‚na souboru
InitDat6:lodsb
         cmp       al,":"
         je        InitDat5                 ; oddˆlova‡ disk–
         cmp       al,"\"
         je        InitDat5                 ; oddˆlova‡ adres ©–
         cmp       al,0
         jne       InitDat6

; ------ p©enesen¡ jm‚na souboru do bufferu

         mov       si,offset SoubName
         mov       cx,11
         rep       movsb                    ; p©enesen¡ jm‚na souboru
         ret

InitDat  ENDP

; -----------------------------------------------------------------------------
;        rozsv¡cen¡ palet displeje
; -----------------------------------------------------------------------------

Rozsvit  PROC      NEAR

         mov       dx,63                    ; po‡et cykl–
         push      ds
         pop       es

; ------ zv˜¨en¡ palet o 1

Rozsvit2:cld
         mov       cx,3*30h                 ; po‡et palet
         mov       si,offset TabPal0        ; tabulka palet - kopie
         mov       di,si
         mov       bx,offset TabPal         ; vzor palet
Rozsvit3:lodsb
         cmp       al,ds:[bx]
         jae       Rozsvit4
         inc       ax
Rozsvit4:stosb
         inc       bx
         loop      Rozsvit3                 ; dal¨¡ paleta

; ------ nastaven¡ palet

         call      SetPal                   ; nastaven¡ palet displeje
         dec       dx                       ; ‡¡ta‡ cykl–
         jnz       Rozsvit2                 ; dal¨¡ cyklus
         ret

Rozsvit  ENDP

; -----------------------------------------------------------------------------
;        st¡ny nadpisu
; -----------------------------------------------------------------------------

Stin     PROC      NEAR

         xor       di,di
         mov       ax,0a000h
         mov       es,ax
Stin1:   cmp       byte ptr es:[di],8
         jne       Stin5

         cmp       byte ptr es:[di+320+1],0fh
         jne       Stin4
         mov       byte ptr es:[di+320+1],5

Stin4:

Stin5:   inc       di
         cmp       di,130*320
         jb        Stin1
         ret

Stin     ENDP

; -----------------------------------------------------------------------------
;        kontury nadpisu
; -----------------------------------------------------------------------------

Kont     PROC      NEAR

         mov       ax,0a000h
         mov       es,ax
         mov       di,4*320

Kont1:   mov       dx,es:[di-1]
         cmp       dh,0fh
         jne       Kont3

         mov       ch,es:[di+1]

         mov       bx,es:[di-320-1]
         mov       cl,es:[di-320+1]

         mov       si,es:[di+320-1]
         mov       ah,es:[di+320+1]

         cmp       bl,8
         je        Kont11
         cmp       bl,0fh
         jne       Kont2

Kont11:  cmp       bh,8
         je        Kont12
         cmp       bh,0fh
         jne       Kont2

Kont12:  cmp       cl,8
         je        Kont13
         cmp       cl,0fh
         jne       Kont2

Kont13:  cmp       dl,8
         je        Kont14
         cmp       dl,0fh
         jne       Kont2

Kont14:  cmp       ch,0fh
         jne       Kont2

         cmp       ah,0fh
         jne       Kont2
         mov       ax,si
         cmp       al,0fh
         jne       Kont2
         cmp       ah,0fh
         je        Kont3

Kont2:   mov       byte ptr es:[di],8

Kont3:   inc       di
         cmp       di,130*320
         jb        Kont1

         ret

Kont     ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ nadpisu (DS:SI=text)
; -----------------------------------------------------------------------------

DispNad  PROC      NEAR

; ------ spo‡ten¡ po‡tu znak–

         xor       bx,bx                    ; ‡¡ta‡ znak–
         push      si
DispNad1:cmp       byte ptr ds:[si],0
         je        DispNad2
         cld
         lodsb
         cmp       al,10
         je        DispNad1
         cmp       al,13
         je        DispNad2
         inc       bx
         jmp       short DispNad1
DispNad2:pop       si
         cmp       bx,9
         ja        DispNad4

; ------ stanoven¡ adresy k dek¢dov n¡ textu

DispNad3:mov       di,36*320+160+3
         mov       al,(4*8+2)/2             ; po‡et bod– na znak/2
         mul       bl                       ; p©epo‡et znak– na body
         sub       di,ax                    ; adresa k dek¢dov n¡ textu

; ------ dek¢dov n¡ textu

         mov       cx,9
DispNd12:cmp       byte ptr ds:[si],0
         je        DispNd13
         cld
         lodsb
         cmp       al,10
         je        DispNd12
         cmp       al,0dh
         je        DispNd13

         jcxz      DispNd12
         call      DispNCh
         dec       cx
         jmp       short DispNd12

DispNd13:ret

; ------ omezen¡ velk‚ho po‡tu znak–

DispNad4:cmp       bx,18
         jbe       DispNd32
         mov       bl,18                    ; omezen¡ po‡tu znak–

DispNd32:mov       word ptr ds:[TabPal+3*8],63+47*256 ; oprava barvy r mu

; ------ stanoven¡ adresy k dek¢dov n¡ textu

         mov       di,52*320+160+4
         mov       al,2*8+1                 ; po‡et bod– na znak
         mul       bl                       ; p©epo‡et znak– na body
         shr       ax,1                     ; polovi‡n¡ po‡et bod–
         sub       di,ax                    ; adresa k dek¢dov n¡ textu

; ------ zobrazen¡ textu st©edn¡ velikosti

         mov       cx,18
DispNd22:cmp       byte ptr ds:[si],0
         je        DispNd23
         cld
         lodsb
         cmp       al,10
         je        DispNd22
         cmp       al,0dh
         je        DispNd23

         jcxz      DispNd22
         call      DispN2C
         dec       cx
         jmp       short DispNd22

DispNd23:ret

DispNad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ podtitulu (DS:SI=text)
; -----------------------------------------------------------------------------

DispSub  PROC      NEAR

; ------ spo‡ten¡ po‡tu znak–

         xor       bx,bx                    ; ‡¡ta‡ znak–
         push      si
DispSub1:cmp       byte ptr ds:[si],0
         je        DispSub2
         cld
         lodsb
         cmp       al,10
         je        DispSub1
         cmp       al,13
         je        DispSub2
         inc       bx
         jmp       short DispSub1
DispSub2:cmp       bx,34
         jbe       DispSub3
         mov       bl,34                     ; omezen¡ po‡tu znak–
DispSub3:pop       si

; ------ stanoven¡ adresy k dek¢dov n¡ textu

         mov       di,103*320+160+4
         mov       al,9                     ; po‡et bod– na znak
         mul       bl                       ; p©epo‡et znak– na body
         shr       ax,1                     ; polovi‡n¡ po‡et bod–
         sub       di,ax                    ; adresa k dek¢dov n¡ textu

; ------

         mov       cx,34
DispSub4:cmp       byte ptr ds:[si],0
         je        DispSub5
         cld
         lodsb
         cmp       al,10
         je        DispSub4
         cmp       al,0dh
         je        DispSub5

         jcxz      DispSub4
         call      DispSCh
         dec       cx
         jmp       short DispSub4

DispSub5:ret

DispSub  ENDP

; -----------------------------------------------------------------------------
;        obsluha zobrazen¡ textu
; -----------------------------------------------------------------------------

Text     PROC      NEAR

; ------ obsluha ‡¡ta‡e ‡ek n¡

         cmp       word ptr ds:[CekTxt],0   ; ‡ek  se ?
         je        Text2                    ; ne‡ek  se
         dec       word ptr ds:[CekTxt]     ; ‡¡t n¡ ‡ek n¡
         jz        Text1                    ; ‡ek n¡ ukon‡eno
         ret

; ------ vymaz n¡ textu

Text1:   mov       ax,0a000h
         mov       es,ax
         mov       di,132*320
         mov       cx,(200-132)*320/2
         xor       ax,ax
         cld
         rep       stosw                    ; vymaz n¡ obrazovky
         mov       ds:[RadTxt],cl
         mov       ds:[PozTxt],cl
         ret

; ------ kontrola ‡¡sla © dku

Text2:   cmp       byte ptr ds:[RadTxt],3
         jbe       Text22
         jmp       Text9

; ------ v˜po‡et adresy znaku

Text22:  mov       al,8                     ; po‡et bajt– na pozici
         mul       byte ptr ds:[PozTxt]     ; p©epo‡et pozice na offset
         xchg      ax,bx                    ; £schova offsetu na © dku
         mov       al,16*320/32
         mul       byte ptr ds:[RadTxt]     ; p©epo‡et © dku na offset/32
         mov       cl,5
         shl       ax,cl                    ; offset © dku
         add       ax,bx                    ; offset znaku
         add       ax,132*320
         mov       di,ax                    ; adresa znaku

; ------ nalezen¡ znaku k zobrazen¡

         mov       si,ds:[AdrTxt]           ; adresa textu
Text3:   cmp       byte ptr ds:[si],0
         je        Text4                    ; konec textu
         cld
         lodsb
         mov       ds:[AdrTxt],si
         cmp       al,10
         je        Text3
         cmp       al,13
         je        Text4                    ; konec © dku
         cmp       al," "
         jne       Text32

         cmp       byte ptr ds:[PozTxt],40
         jae       Text3
         inc       byte ptr ds:[PozTxt]
         add       di,8
         jmp       short Text3

Text32:  cmp       byte ptr ds:[PozTxt],40  ; je pozice OK ?
         jae       Text3                    ; © dek je pln˜
         call      DispTCh                  ; zobrazen¡ znaku
         inc       byte ptr ds:[CitTxt]     ; ‡¡ta‡ platn˜ch znak–
         inc       byte ptr ds:[PozTxt]
         jmp       short Text9

; ------ nov˜ © dek

Text4:   mov       byte ptr ds:[PozTxt],0
         inc       byte ptr ds:[RadTxt]
         cmp       byte ptr ds:[RadTxt],3
         jbe       Text22

; ------ inicializace ‡ek n¡

         xor       ax,ax
         xchg      al,ds:[CitTxt]           ; po‡et nalezen˜ch znak–
         mov       ah,4
         mul       ah
         add       ax,80
         mov       ds:[CekTxt],ax           ; doba pro ‡ek n¡

; ------ inicializace za‡ tku textu

         cmp       byte ptr ds:[si],0
         jne       Text9
         mov       ax,ds:[BegTxt]
         mov       ds:[AdrTxt],ax

Text9:   ret

Text     ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku bˆ‘n‚ho textu
; -----------------------------------------------------------------------------

DispTCh  PROC      NEAR

         push      di
         mov       ah,2

         cmp       byte ptr ds:[PozTxt],39
         jne       DispTCh2
         call      DispCh
         inc       di
         jmp       short DispTCh3

DispTCh2:inc       di
         call      DispCh
DispTCh3:sub       di,320+1
         mov       ah,1
         call      DispCh
         pop       di
         add       di,8
         ret

DispTCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku podtitulu
; -----------------------------------------------------------------------------

DispSCh  PROC      NEAR

         push      di

         mov       ah,9
DispSCh1:call      DispCh
         inc       di
         call      DispCh
         sub       di,320+2
         inc       ah
         cmp       ah,0fh
         jne       DispSCh1

         mov       ah,3
         call      DispCh
         inc       di
         call      DispCh

         pop       di
         add       di,8+1
         ret

DispSCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ st©edn¡ho znaku nadpisu
; -----------------------------------------------------------------------------

DispN2C  PROC      NEAR

         push      di

         mov       ah,9
DispN2C1:call      DispMCh
         inc       di
         call      DispMCh
         sub       di,320+2
         inc       ah
         cmp       ah,10h
         jne       DispN2C1

         pop       di
         add       di,2*8+1
         ret

DispN2C  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ velk‚ho znaku nadpisu
; -----------------------------------------------------------------------------

DispNCh  PROC      NEAR

         push      di

         mov       ah,9
DispNCh1:call      DispHCh
         inc       di
         call      DispHCh
         inc       di
         call      DispHCh
         inc       di
         call      DispHCh
         sub       di,320+4
         inc       ah
         cmp       ah,10h
         jne       DispNCh1

         pop       di
         add       di,4*8+2
         ret

DispNCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ velk‚ho znaku (AL=znak, AH=barva, DI=adresa)
; -----------------------------------------------------------------------------

DispHCh  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava znaku

         mov       dh,ah                    ; barva
         mov       dl,ah
         call      GetZnak                  ; sestaven¡ znaku do bufferu

; ------ dek¢dov n¡ znaku

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti
         mov       cx,18                    ; po‡et linek
         cld
DispHCh1:push      di
         lodsb                              ; bajt znaku
DispHCh2:shl       al,1                     ; bit
         jnc       DispHCh3
         mov       es:[di],dx               ; barva bodu
         mov       es:[di+2],dx
         mov       es:[di+320],dx
         mov       es:[di+320+2],dx
         mov       es:[di+2*320],dx
         mov       es:[di+2*320+2],dx
         mov       es:[di+3*320],dx
         mov       es:[di+3*320+2],dx
DispHCh3:add       di,4
         or        al,al
         jnz       DispHCh2
         pop       di
         add       di,4*320
         loop      DispHCh1

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispHCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ st©edn¡ho znaku (AL=znak, AH=barva, DI=adresa)
; -----------------------------------------------------------------------------

DispMCh  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©¡prava znaku

         mov       dh,ah                    ; barva
         mov       dl,ah
         call      GetZnak                  ; sestaven¡ znaku do bufferu

; ------ dek¢dov n¡ znaku

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti
         mov       cx,18                    ; po‡et linek
         cld
DispMCh1:push      di
         lodsb                              ; bajt znaku
DispMCh2:shl       al,1                     ; bit
         jnc       DispMCh3
         mov       es:[di],dx               ; barva bodu
         mov       es:[di+320],dx
DispMCh3:inc       di
         inc       di
         or        al,al
         jnz       DispMCh2
         pop       di
         add       di,2*320
         loop      DispMCh1

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispMCh  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku (AL=znak, AH=barva, DI=adresa)
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava znaku

         mov       dh,ah                    ; barva
         call      GetZnak                  ; sestaven¡ znaku do bufferu

; ------ dek¢dov n¡ znaku

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti
         mov       cx,18                    ; po‡et linek
         cld
DispCh1: push      di
         lodsb                              ; bajt znaku
DispCh2: shl       al,1                     ; bit
         jnc       DispCh3
         mov       es:[di],dh               ; barva bodu
DispCh3: inc       di
         or        al,al
         jnz       DispCh2
         pop       di
         add       di,320
         loop      DispCh1

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        p©¡prava znaku v bufferu (AL=znak)
; -----------------------------------------------------------------------------

GetZnak  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©¡prava registr– pro bˆ‘n˜ znak

         mov       ah,0                     ; dopl¤uj¡c¡ znam‚nko - mezera
         xchg      ax,bx                    ; BL <- znak, BH <- znam‚nko
         cmp       bl,80h                   ; minim ln¡ ‡esk˜ znak
         jb        GetZnak2                 ; nen¡ ‡esk˜ znak
         cmp       bl,0abh                  ; maxim ln¡ ‡esk˜ znak
         ja        GetZnak2                 ; nen¡ ‡esk˜ znak

; ------ korekce pro ‡esk˜ znak

         shl       bx,1                     ; znak * 2
         mov       bx,word ptr ds:[TabKor+bx-2*80h]  ; znak s dopl¤uj¡c¡m znam‚nkem

; ------ v˜po‡et offsetu znaku v tabulce

GetZnak2:mov       al,16                    ; po‡et bajt– na znak
         mul       bl                       ; p©epo‡et znaku na offset

; ------ p©enesen¡ znaku do bufferu

         push      ds
         pop       es
         push      ds
         lds       si,ds:[Font]             ; syst‚mov˜ font
         add       si,ax                    ; adresa znaku
         mov       di,offset Znak           ; buffer znaku
         xor       ax,ax
         cld
         stosw                              ; vymaz n¡ 2 prvn¡ch bajt–
         mov       cx,16/2
         rep       movsw                    ; p©enos znaku do bufferu
         pop       ds

; ------ adresa k ulo‘en¡ znam‚nka

         mov       di,offset Znak           ; buffer znaku
         test      bh,80h                   ; je mal‚ p¡smeno ?
         jz        GetZnak3                 ; nen¡ mal‚ p¡smeno
         add       di,3                     ; posun pro mal‚ p¡smeno

; ------ adresa vzorku znam‚nka

GetZnak3:and       bh,7
         mov       al,bh
         add       al,bh
         add       al,bh
         mov       ah,0                     ; offset v tabulce vzork–
         mov       si,offset TabZnam        ; tabulka znam‚nek
         add       si,ax                    ; adresa znam‚nka

; ------ p©enesen¡ znam‚nka do bufferu

         lodsb
         or        ds:[di],al
         inc       di
         lodsb
         or        ds:[di],al
         inc       di
         lodsb
         or        ds:[di],al

; ------ n vrat registr–

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         mov       si,offset Znak           ; buffer znaku
         ret

GetZnak  ENDP

; -----------------------------------------------------------------------------
;        obsluha hvˆzd
; -----------------------------------------------------------------------------

Hvezdy   PROC      NEAR

; ------ p©¡prava segment–

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti

; ------ p©¡prava k obsluze hvˆzd

         mov       cx,MAXHVZD               ; po‡et polo‘ek tabulky
         mov       si,offset TabHvezd       ; tabulka definice hvˆzd

; ------ p©¡prava registr– hvˆzdy

Hvezdy1: mov       bx,ds:[si]               ; pozice hvˆzdy X
         or        bx,bx                    ; je hvˆzda definovan  ?
         jz        Hvezdy4                  ; hvˆzda nen¡ definovan 
         mov       dx,ds:[si+2]             ; pozice hvˆzdy Y

; ------ vymaz n¡ star‚ hvˆzdy

         call      HvzdAdr                  ; v˜po‡et adresy hvˆzdy
         call      HvzdMaz                  ; vymaz n¡ star‚ pozice hvˆzdy

; ------ zv˜¨en¡ sou©adnic hvˆzdy

         push      cx
         mov       cl,5
         mov       ax,ds:[si+4]             ; rychlost X
         add       bx,ax                    ; zv˜¨en¡ sou©adnice X
         mov       ds:[si],bx               ; nov  pozice X
         sar       ax,cl
         add       ds:[si+4],ax             ; zv˜¨en¡ rychlosti X

         mov       ax,ds:[si+6]             ; rychlost Y
         add       dx,ax                    ; zv˜¨en¡ sou©adnice Y
         mov       ds:[si+2],dx             ; nov  pozice Y
         sar       ax,cl
         add       ds:[si+6],ax             ; zv˜¨en¡ rychlosti Y
         pop       cx

; ------ kontrola sou©adnic hvˆzdy

         cmp       bh,-(158/2)              ; max. sou©adnice X
         jl        Hvezdy2                  ; mimo rozsah
         cmp       bh,158/2
         jg        Hvezdy2
         cmp       dh,-(LINEK-5)/2
         jl        Hvezdy2
         cmp       dh,(LINEK-5)/2
         jle       Hvezdy3                  ; sou©adnice OK

; ------ zru¨en¡ hvˆzdy

Hvezdy2: mov       word ptr ds:[si],0       ; zru¨en¡ hvˆzdy
         jmp       short Hvezdy4

; ------ zobrazen¡ hvˆzdy na nov‚ pozici

Hvezdy3: call      HvzdAdr                  ; v˜po‡et nov‚ adresy hvˆzdy
         call      HvzdDis                  ; zobrazen¡ nov‚ hvˆzdy

; ------ p©¡prava pro dal¨¡ hvˆzdu

Hvezdy4: add       si,8                     ; adresa dal¨¡ hvˆzdy
         loop      Hvezdy1                  ; dal¨¡ hvˆzda

; ------ nalezen¡ voln‚ polo‘ky pro vygenerov n¡ nov‚ hvˆzdy

         mov       cx,MAXHVZD               ; maxim ln¡ po‡et hvˆzd
         xor       ax,ax                    ; hled  se slovo 0
         mov       si,offset TabHvezd       ; tabulka hvˆzd
Hvezdy5: cmp       ds:[si],ax               ; je polo‘ka voln  ?
         je        Hvezdy6                  ; polo‘ka je voln 
         add       si,8                     ; adresa dal¨¡ polo‘ky
         loop      Hvezdy5                  ; dal¨¡ polo‘ka
         jmp       short Hvezdy9            ; voln  polo‘ka nenalezena

; ------ vygenerov n¡ sou©adnice hvˆzdy

Hvezdy6: mov       ax,80*256/2
         call      Random                   ; vygenerov n¡ pozice X
         inc       ax                       ; pozice X
         mov       bx,ax                    ; pozice X

         mov       ax,24*256
         call      Random                   ; vygenerov n¡ pozice Y
         inc       ax
         mov       dx,ax                    ; pozice Y

         mov       cl,7
         sar       ax,cl
         add       ax,25
         mov       di,ax                    ; rychlost Y

         mov       ax,bx                    ; rychlost X (1 a‘ 20)
         sar       ax,cl
         add       ax,25
         mov       cx,ax

         mov       ax,4
         call      Random                   ; vygenerov n¡ p©¡znak– smˆru
         shr       al,1
         jnc       Hvezd62
         neg       bx                       ; pozice X (-1 a‘ -20)
         neg       cx                       ; rychlost X (-1 a‘ -20)

Hvezd62: shr       al,1
         jnc       Hvezd63
         neg       dx                       ; pozice Y (-1 a‘ -10)
         neg       di                       ; rychlost Y (-1 a‘ -10)

Hvezd63: mov       ds:[si],bx               ; pozice X
         mov       ds:[si+2],dx             ; pozice Y
         mov       ds:[si+4],cx             ; rychlost X
         mov       ds:[si+6],di             ; rychlost Y
         call      HvzdAdr                  ; v˜po‡et nov‚ adresy hvˆzdy
         call      HvzdDis                  ; zobrazen¡ nov‚ hvˆzdy

Hvezdy9: ret

Hvezdy   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ hvˆzdy (adresa ES:DI)
; -----------------------------------------------------------------------------

HvzdDis  PROC      NEAR

         cmp       byte ptr es:[di],0       ; je pozice voln  ?
         jne       HvzdDis2                 ; pozice nen¡ voln 
         cmp       word ptr ds:[si+4],100
         jg        HvzdDis1
         cmp       word ptr ds:[si+4],-100
         jl        HvzdDis1
         mov       byte ptr es:[di],6
         jmp       short HvzdDis2
HvzdDis1:mov       byte ptr es:[di],7       ; zobrazen¡ hvˆzdy
HvzdDis2:ret

HvzdDis  ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ hvˆzdy (adresa ES:DI)
; -----------------------------------------------------------------------------

HvzdMaz  PROC      NEAR

         cmp       byte ptr es:[di],6
         je        HvzdMaz1
         cmp       byte ptr es:[di],7       ; je hvˆzda zobrazena ?
         jne       HvzdMaz2                 ; nen¡ zobrazena
HvzdMaz1:mov       byte ptr es:[di],0       ; vymaz n¡ hvˆzdy
HvzdMaz2:ret

HvzdMaz  ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et adresy hvˆzdy ES:DI (BX=pozice X, DX=pozice Y)
; -----------------------------------------------------------------------------

HvzdAdr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ segment videopamˆti

         mov       ax,0a000h
         mov       es,ax

; ------ p©epo‡et pozice Y na offset

         mov       al,dh                    ; pozice Y
         cbw                                ; konverze na slovo
         mov       dx,320                   ; po‡et bod– na linku
         imul      dx                       ; p©epo‡et pozice Y na offset
         mov       di,ax                    ; offset linky

; ------ p©i‡ten¡ pozice X

         mov       ax,bx                    ; pozice X
         mov       cl,7                     ; po‡et rotac¡
         sar       ax,cl                    ; pozice X
         add       di,ax                    ; offset bodu
         add       di,LINEK/2*320+160       ; adresa bodu

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

HvzdAdr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ r mu
; -----------------------------------------------------------------------------

DispRam  PROC      NEAR

; ------ p©¡prava registr–

         mov       ax,0a000h
         mov       es,ax
         xor       di,di

; ------ zobrazen¡ horn¡ linky

         cld
         xor       di,di
         call      DispHRm                  ; prvn¡ horn¡ linka

; ------ zobrazen¡ prav‚ linky

         mov       dx,318
         mov       di,318
         call      DispVRm                  ; prvn¡ prav  linka

; ------ zobrazen¡ spodn¡ linky

         std
         inc       di
         call      DispHRm

; ------ zobrazen¡ lev‚ho okraje

         mov       dx,-322
         mov       di,2*LINEK*320-320
         call      DispVRm
         ret

DispRam  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ horizont ln¡ linky (STD nebo CLD = smˆr)
; -----------------------------------------------------------------------------

DispHRm  PROC      NEAR

         mov       cx,318
         mov       al,1fh
DispHRm1:mov       es:[di+320],al
         stosb
         dec       al
         and       al,0fh
         or        al,10h
         loop      DispHRm1
         ret

DispHRm  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ vertik ln¡ linky (DX=p©¡rustek)
; -----------------------------------------------------------------------------

DispVRm  PROC      NEAR

         mov       cx,LINEK*2-2
         mov       al,1fh
         cld
DispVRm1:stosb
         stosb
         add       di,dx
         dec       al
         and       al,0fh
         or        al,10h
         loop      DispVRm1
         ret

DispVRm  ENDP

; -----------------------------------------------------------------------------
;        rotace palet
; -----------------------------------------------------------------------------

RotPal   PROC      NEAR

         push      ds
         pop       es
         cld

; ------ p©¡prava pro rotaci palet r mu

         mov       si,offset TabPal0+3*10h  ; palety r mu
RotPal1: mov       di,si

; ------ na‡ten¡ prvn¡ palety

         lodsb
         mov       bh,al
         lodsb
         mov       bl,al
         lodsb

; ------ p©esun vnit©n¡ch palet

         mov       cx,3*15
         rep       movsb

; ------ ulo‘en¡ posledn¡ palety

         xchg      al,bh
         stosb
         mov       al,bl
         stosb
         mov       al,bh
         stosb

; ------ opakov n¡ pro palety ¨achovnice

         cmp       si,offset TabPal0+3*30h  ; konec ?
         jb        RotPal1                  ; palety ¨achovnice

         ret

RotPal   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ palet displeje
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si


         mov       dx,3dah
         sti
SetPal1: in        al,dx
         test      al,8
         jz        SetPal1

         cli
         mov       dx,3c8h
         mov       al,0
         out       dx,al
         inc       dx
         mov       si,offset TabPal0
         mov       cx,30h*3
SetPal2: lodsb
         out       dx,al
         loop      SetPal2
         sti

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SetPal   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ¨achovnice
; -----------------------------------------------------------------------------

DispSach PROC      NEAR

; ------ p©¡prava registr–

         mov       ax,0a000h
         mov       es,ax
         mov       al,20h                   ; po‡ te‡n¡ barva bodu
         mov       si,160                   ; po‡ te‡n¡ adresa bodu
         mov       cx,ds:[CitY]             ; p©¡rustek barvy linky

; ------ p©¡prava k zobrazen¡ jedn‚ linky

DispSch2:push      ax                       ; barva bodu
         mov       dx,ds:[IncX]
         mov       ds:[CitX],dx             ; ‡¡ta‡ p©¡rustku X
         xor       bp,bp                    ; offset na lince

; ------ zobrazen¡ jednoho bodu na lince

DispSch3:mov       es:[LINEK*320+si+bp-320],al; ulo‘en¡ bodu vpravo dol–
         xor       al,0fh
         neg       bp
         mov       es:[LINEK*320+si+bp-1-320],al  ; ulo‘en¡ bodu vlevo dol–
         neg       bp
         xor       al,0fh

; ------ posun barvy na © dku

         dec       dh
         jnz       DispSch6                 ; nen¡ zmˆna barvy bodu

         inc       ax
         cmp       al,30h
         jne       DispSch5
         mov       al,20h
DispSch5:mov       dx,ds:[IncX]
         add       byte ptr ds:[CitX],dl
         adc       dh,0
         add       byte ptr ds:[CitX+1],dh

; ------ dal¨¡ bod na © dku

DispSch6:inc       bp                       ; zv˜¨en¡ ukazatele na © dku
         cmp       bp,160                   ; jsou ji‘ v¨echny body na lince ?
         jne       DispSch3                 ; dal¨¡ bod na lince

; ------ posun p©¡rustku barvy pro body na lince

         add       word ptr ds:[IncX],10

; ------ posun barvy linek

         pop       ax

         dec       ch
         jnz       DispSch7

         mov       cx,ds:[IncY]
         add       cx,ds:[CitY]
         mov       ds:[CitY],cx

         xor       al,8

; ------ dal¨¡ linka

DispSch7:add       si,320                   ; zv˜¨en¡ ukazatele linek
         cmp       si,320*LINEK+160            ; jsou ji‘ v¨echny linky ?
         jb        DispSch2                 ; dal¨¡ linka
         ret

DispSach ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener tor n hodn‚ho ‡¡sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datov˜ segment
; VSTUP: AX=‡¡slo 0 a‘ (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; po‘adovan˜ rozsah
         call      Random0                  ; generov n¡ n hodn‚ho ‡¡sla DX:AX
         xchg      ax,dx                    ; AX <- n hodn‚ ‡¡slo
         xor       dx,dx
         div       bx
         xchg      ax,dx
Random1: pop       dx
         pop       bx
         ret

Random   ENDP

; -----------------------------------------------------------------------------

Random0  PROC      NEAR

         push      bx
         push      cx
         mov       ax,word ptr ds:[RandomR]
         mov       bx,word ptr ds:[RandomR+2]
         mov       cx,ax
         mul       word ptr ds:[RandomD]
         shl       cx,1
         shl       cx,1
         shl       cx,1
         add       ch,cl
         add       dx,cx
         add       dx,bx
         shl       bx,1
         shl       bx,1
         add       dx,bx
         add       dh,bl
         mov       cl,5
         shl       bx,cl
         add       dh,bl
         add       ax,1
         adc       dx,0
         mov       word ptr ds:[RandomR],ax
         mov       word ptr ds:[RandomR+2],dx
         pop       cx
         pop       bx
         ret

Random0  ENDP

; *****************************************************************************
;
;                                  Data
;
; *****************************************************************************
;þ

UvTxt    db        'POUTAC - (c) Miroslav Nemecek 1993',13,10
         db        '    GOLEM Roznov pod Radhostem',13,10
         db        '           - FREEWARE -',13,10
         db        '$'

MemTxt   db        'Nedostatek pameti !',13,10,'$'
DatTxt   db        'Datovy soubor POUTAC.DAT nenalezen !',13,10,'$'
VGATxt   db        'Program vyzaduje grafickou kartu VGA !',13,10,'$'

SoubName db        'POUTAC.DAT',0           ; jm‚no souboru

BegTxt   dw        0                        ; adresa za‡ tku textu
AdrTxt   dw        0                        ; ukazatel adresy v textu
RadTxt   db        0                        ; aktivn¡ © dek (0 a‘ 3)
PozTxt   db        0                        ; aktivn¡ pozice (0 a‘ 39)
CitTxt   db        0                        ; ‡¡ta‡ znak– textu
CekTxt   dw        0                        ; ‡¡ta‡ pro ‡ek n¡

Font     dd        0                        ; adresa syst‚mov‚ho fontu

CitX     dw        0                        ; ‡¡ta‡ p©¡rustku X
IncX     dw        1c0h                     ; p©¡rustek X

CitY     dw        3*80h                    ; ‡¡ta‡ p©¡rustku Y
IncY     dw        80h                      ; p©¡rustek Y

OldVMod  dw        3

; ------ definice jmen vzork–

MEZ      EQU       0                        ; mezera
CAR      EQU       1                        ; ‡ rka
HAC      EQU       2                        ; h ‡ek
KRO      EQU       3                        ; krou‘ek
STS      EQU       4                        ; st©¡¨ka
DVJ      EQU       5                        ; dvojte‡ka

; ------ vzorky znam‚nek

TabZnam  label     byte
                                          ;* 0: mezera
         db        00000000b
         db        00000000b
         db        00000000b
                                          ;* 1: ‡ rka
         db        00000110b
         db        00001100b
         db        00011000b
                                          ;* 2: h ‡ek
         db        11000110b
         db        01101100b
         db        00111000b
                                          ;* 3: krou‘ek
         db        01111000b
         db        11001100b
         db        01111000b
                                          ;* 4: st©¡¨ka
         db        00111000b
         db        01101100b
         db        11000110b
                                          ;* 5: dvojte‡ka
         db        00000000b
         db        11001100b
         db        00000000b

; ------ tabulka korekc¡ ‡esk˜ch znak–

TabKor   db        'C',HAC                  ; 80h: "€"
         db        'u',DVJ+80h              ; 81h: ""
         db        'e',CAR+80h              ; 82h: "‚"
         db        'd',HAC                  ; 83h: "ƒ"
         db        'a',DVJ+80h              ; 84h: "„"
         db        'D',HAC                  ; 85h: "…"
         db        'T',HAC                  ; 86h: "†"
         db        'c',HAC+80h              ; 87h: "‡"
         db        'e',HAC+80h              ; 88h: "ˆ"
         db        'E',HAC                  ; 89h: "‰"
         db        'L',CAR                  ; 8ah: "Š"
         db        'I',CAR                  ; 8bh: "‹"
         db        'l',HAC                  ; 8ch: "Œ"
         db        'l',CAR                  ; 8dh: ""
         db        'A',DVJ                  ; 8eh: "Ž"
         db        'A',CAR                  ; 8fh: ""
         db        'E',CAR                  ; 90h: ""
         db        'z',HAC+80h              ; 91h: "‘"
         db        'Z',HAC                  ; 92h: "’"
         db        'o',STS+80h              ; 93h: "“"
         db        'o',DVJ+80h              ; 94h: "”"
         db        'O',CAR                  ; 95h: "•"
         db        'u',KRO+80h              ; 96h: "–"
         db        'U',CAR                  ; 97h: "—"
         db        'y',CAR+80h              ; 98h: "˜"
         db        'O',DVJ                  ; 99h: "™"
         db        'U',DVJ                  ; 9ah: "š"
         db        'S',HAC                  ; 9bh: "›"
         db        'L',HAC                  ; 9ch: "œ"
         db        'Y',CAR                  ; 9dh: ""
         db        'R',HAC                  ; 9eh: "ž"
         db        't',HAC                  ; 9fh: "Ÿ"
         db        'a',CAR+80h              ; a0h: " "
         db        '¡',MEZ                  ; a1h: "¡"
         db        'o',CAR+80h              ; a2h: "¢"
         db        'u',CAR+80h              ; a3h: "£"
         db        'n',HAC+80h              ; a4h: "¤"
         db        'N',HAC                  ; a5h: "¥"
         db        'U',KRO                  ; a6h: "¦"
         db        'O',STS                  ; a7h: "§"
         db        's',HAC+80h              ; a8h: "¨"
         db        'r',HAC+80h              ; a9h: "©"
         db        'r',CAR+80h              ; aah: "ª"
         db        'R',CAR                  ; abh: "«"
TabKor0  label     byte

; ------ gener tor n hody

RandomR  dd        21510d31h                ; promˆnn  pro gener tor n hody
RandomD  dw        8405h                    ; pomocn  konstanta

; ------ tabulka palet

TabPal   db        0,0,0                    ; 0: pozad¡

         db        63,63,10                 ; 1: p¡smo - pop©ed¡
         db        63,00,00                 ; 2: p¡smo

         db        54,00,40                 ; 3: podtitul

         db        00,00,00                 ; 4:
         db        42,00,00                 ; 5: st¡n nadpisu

         db        30,30,30                 ; 6: hvˆzdy
         db        55,55,55                 ; 7: hvˆzdy

         db        00,55,00                 ; 8: nadpis 1 - r m
         db        00,00,00                 ; 9: nadpis 2
         db        02,04,08                 ; 0ah: nadpis 3
         db        04,08,16                 ; 0bh: nadpis 4
         db        06,12,24                 ; 0ch: nadpis 5
         db        08,16,32                 ; 0dh: nadpis 6
         db        10,20,40                 ; 0eh: nadpis 7
         db        63,04,00                 ; 0fh: nadpis 8

; ------ palety r mu

         db        32,00,00                 ; 10h
         db        36,02,00
         db        40,04,00
         db        44,06,00
         db        48,08,00
         db        52,10,00
         db        56,12,00
         db        60,14,00
         db        63,16,00
         db        60,14,00
         db        56,12,00
         db        52,10,00
         db        48,08,00
         db        44,06,00
         db        40,04,00
         db        36,02,00

; ------ palety ¨achovnice

         db        00,00,40                 ; 20h
         db        00,00,40
         db        00,00,40
         db        00,00,40
         db        00,00,40
         db        00,00,40
         db        00,00,40
         db        00,00,40

         db        53,43,00
         db        53,43,00
         db        53,43,00
         db        53,43,00
         db        53,43,00
         db        53,43,00
         db        53,43,00
         db        53,43,00

Znak     db        18 dup(?)                ; buffer znaku

MazBeg   label     byte                     ; za‡ tek buffer– k vymaz n¡

TabPal0  db        3*30h dup(?)             ; kopie tabulky palet

Soubor   db        86 dup(?)                ; buffer jm‚na souboru

; ------ tabulka hvˆzd

TabHvezd db        MAXHVZD*8 dup(?)         ; Struktura:
                                            ;   0: (2) pozice hvˆzdy X (0=voln‚)
                                            ;   2: (2) pozice hvˆzdy Y
                                            ;   4: (2) p©¡rustek pozice X
                                            ;   6: (2) p©¡rustek pozice Y

MazEnd   label     byte                     ; konec buffer– k vymaz n¡

Buffer   label     byte                     ; datov˜ buffer souboru

Code     ENDS
         END       Start

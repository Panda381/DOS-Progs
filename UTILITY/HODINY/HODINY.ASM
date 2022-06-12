

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               Hodiny
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞




; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

; ------ p©edefinov†n° z†sobn°ku

Start:   cmp       sp,offset Zasob          ; je dost pamàti ?
         jb        Start00                  ; nedostatek pamàti
         mov       sp,offset Zasob          ; p©edefinov†n° z†sobn°ku

; ------ zmen®en° bloku programu

         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16 ; velikost programu
         int       21h                      ; zmen®en° bloku programu
         jc        Start00                  ; nàjak† chyba

; ------ inicializace videom¢du

         call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du

; ------ vytvo©en° bufferu pro videopamàü

         mov       al,80                    ; poáet znakñ na ©†dek
         mul       byte ptr ds:[Radku]      ; vòpoáet dÇlky videostr†nky (slov)
         mov       cx,ax                    ; dÇlka videostr†nky (slov)
         mov       bx,ax                    ; dÇlka videostr†nky (slov)
         add       bx,7                     ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; dÇlka videostr†nky (odstavcñ)
         mov       ah,48h
         int       21h                      ; vytvo©en° bufferu videostr†nky
         jnc       Start01                  ; operace OK

; ------ nedostatek pamàti

Start00: mov       dx,offset MemTxt
         mov       ah,9
         int       21h
         int       20h

; ------ £schova obsahu obrazovky

Start01: push      ds
         push      es
         mov       ds:[ObrSegm],ax          ; adresa bufferu
         mov       es,ax                    ; adresa bufferu
         xor       di,di                    ; ukl†dac° adresa
         mov       ds:[ObrSize],cx          ; £schova velikosti vieostr†nky
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       es
         pop       ds

; ------ £schova kurzoru

         call      GetKurz                  ; poskytnut° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ obsluha p©eru®en°

         mov       ax,2523h
         mov       dx,offset Main0
         int       21h

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start1

         mov       byte ptr ds:[Barva2],70h
         mov       byte ptr ds:[Barva3],7
         mov       byte ptr ds:[Barva4],70h

; ------ zobrazen° hodin

Start1:  call      DispHod                  ; zobrazen° hodin

         jmp       EditHod                  ; editace hodin


; ------ n†vrat z programu

Main0:   push      cs
         pop       ds

         call      PopScr                   ; n†vrat obsahu obrazovky

         int       20h                      ; n†vrat z programu

; -----------------------------------------------------------------------------
;        n†vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         push      ds
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       cx,ds:[ObrSize]          ; velikost videopamàti
         mov       ds,ds:[ObrSegm]          ; segment bufferu
         xor       si,si
         cld
         rep       movsw                    ; n†vrat obsahu obrazovky
         pop       ds

         mov       dx,ds:[OldKurz]          ; pñvodn° pozice kurzoru
         call      SetKurz                  ; n†vrat pozice kurzoru

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

PopScr   ENDP

; -----------------------------------------------------------------------------
;        obsluha editace hodin
; -----------------------------------------------------------------------------

AWZMRET: call      PopScr                   ; n†vrat obrazovky
         mov       ah,0
         int       16h
         call      DispHod

EditHod:

AWZMnu51:call      DispTKur                 ; zobrazen° kurzoru

AWZM5124:mov       ah,1
         int       16h
         jnz       AWZM5126
         call      DispHod
         jmp       short AWZM5124

AWZM5126:mov       ah,0
         int       16h
         mov       bx,ax

         cmp       bl,0fh
         je        AWZMRET

         cmp       bx,0
         je        AWZMnu50                 ; Ctrl-Break

         mov       ah,byte ptr ds:[MnuNum]  ; poáet poloëek
         mov       al,byte ptr ds:[MnuAkt]  ; aktivn° poloëka
         test      byte ptr ds:[HodParm],1  ; je reëim modifikace ?
         jnz       AWZMn511                 ; je reëim modifikace

         cmp       bl,1bh                   ; ESC ?
         je        AWZMnu50
         cmp       bl,0dh
         jne       AWZMnu51
         or        byte ptr ds:[HodParm],1  ; reëim modifikace
         mov       word ptr ds:[MnuHlp],offset ZHMnuLH2
         call      DispHod
         jmp       short AWZMnu51

AWZMn512:mov       byte ptr ds:[HodParm],0  ; zru®en° p©°znakñ modifikace
         mov       word ptr ds:[MnuHlp],offset ZHMnuLH1
         call      DispHod
         jmp       short AWZMnu51

AWZMn511:cmp       bl,"0"
         jb        AWZMn513
         cmp       bl,"9"
         ja        AWZMn513

; ------ zad†n° á°slice

         mov       di,ax                    ; aktivn° poloëka
         and       di,0ffh                  ; aktivn° poloëka
         mov       di,word ptr ds:[di+TKurzPoz-1] ; offset
         and       di,0ffh                  ; offset
         cmp       al,6                     ; je datum ?
         jbe       AWZMn515                 ; je áas
         inc       di
         inc       di                       ; korekce pro datum
         or        byte ptr ds:[HodParm],4  ; p©°znak modifikace data
         jmp       short AWZMn514
AWZMn515:or        byte ptr ds:[HodParm],2  ; p©°znak modifikace áasu
AWZMn514:mov       ds:[di+HodMCas],bl       ; uloëen° á°slice
         call      DispHod
         jmp       short AWZMnu52           ; posun kurzoru vpravo

AWZMnu50:jmp       Main0

AWZMn513:call      JumpBX

         dw        4d00h,AWZMnu52           ; kurzor vpravo
         dw        4b00h,AWZMnu53           ; kurzor vlevo
         dw        4700h,AWZMnu54           ; HOME
         dw        4f00h,AWZMnu55           ; END
         dw        0f09h,AWZMnu56           ; TAB
         dw        0f00h,AWZMnu56           ; *TAB
         dw        7300h,AWZMn565           ; ^VLEVO
         dw        7400h,AWZMn568           ; ^VPRAVO
         dw        0e08h,AWZMnu53           ; BS

         dw        011bh,AWZMn512           ; ESC
         dw        1c0dh,AWZMn591           ; ENTER

         dw        0,AWZMnu51

; ------ kurzor vpravo

AWZMnu52:inc       al
         cmp       al,ah
         jbe       AWZMnu58
         mov       al,1
         jmp       short AWZMnu58

; ------ kurzor vlevo

AWZMnu53:dec       al
         jnz       AWZMnu58
         mov       al,ah
         jmp       short AWZMnu58

; ------ HOME

AWZMnu54:cmp       al,7
         ja        AWZMn542
         mov       al,1
         jmp       short AWZMnu58
AWZMn542:mov       al,7
         jmp       short AWZMnu58

; ------ END

AWZMnu55:cmp       al,6
         jb        AWZMn552
         mov       al,14
         jmp       short AWZMnu58
AWZMn552:mov       al,6
         jmp       short AWZMnu58

; ------ TAB

AWZMnu56:cmp       al,12
         jbe       AWZMn561
         mov       al,12
AWZMn561:sub       al,6
         ja        AWZMn562
         add       al,12
AWZMn562:jmp       short AWZMnu58

; ------ slovo vlevo

AWZMn565:and       al,not 1
         cmp       al,12
         jbe       AWZMn566
         mov       al,12
AWZMn566:sub       al,2
         jae       AWZMn567
         mov       al,10
AWZMn567:inc       al
         jmp       short AWZMnu58

; ------ slovo vpravo

AWZMn568:dec       al
         and       al,not 1
         add       al,2
         cmp       al,10
         jbe       AWZMn567
         xor       al,al
         jmp       short AWZMn567

; ------ nastaven° novÇ pozice kurzoru

AWZMnu58:mov       byte ptr ds:[MnuAkt],al
AWZMnu59:jmp       AWZMnu51

; ------ nastaven° zadanÇho data a áasu

AWZMn591:push      si

         test      byte ptr ds:[HodParm],2  ; byl áas modifikov†n ?
         jz        AWZMn592                 ; áas nebyl modifikov†n

         mov       si,offset HodMCas        ; £daj áasu
         call      DekCas                   ; dek¢dov†n° hodiny
         mov       ch,al                    ; hodina
         call      DekCas                   ; dek¢dov†n° minuty
         mov       cl,al                    ; minuta
         call      DekCas                   ; dek¢dov†n° sekundy
         mov       dh,al                    ; dekunda
         xor       dl,dl                    ; setiny sekundy
         mov       ah,2dh
         int       21h                      ; nastaven° systÇmovÇho áasu

AWZMn592:test      byte ptr ds:[HodParm],4  ; byl datum modifikov†n ?
         jz        AWZMn593                 ; datum nebyl modifikov†n

         mov       si,offset HodMDat        ; £daj data
         call      DekCas                   ; dek¢dov†n° dne
         mov       dl,al                    ; den
         call      DekCas                   ; dek¢dov†n° màs°ce
         mov       dh,al                    ; màs°c
         call      DekCas                   ; dek¢dov†n° stolet°
         mov       cl,100                   ; n†sobek
         mul       cl                       ; p©epoáet na stolet°
         mov       cx,ax                    ; stolet°
         dec       si
         call      DekCas                   ; dek¢dov†n° jednotek roku
         xor       ah,ah
         add       cx,ax                    ; rok
         mov       ah,2bh
         int       21h                      ; nastaven° systÇmovÇho data

AWZMn593:pop       si
         jmp       AWZMn512                 ; n†vrat do bàënÇho reëimu

; -----------------------------------------------------------------------------
;        dek¢dov†n° áasu
; -----------------------------------------------------------------------------

DekCas   PROC      NEAR

         cld
         lodsb
         and       al,0fh
         mov       ah,10
         mul       ah
         mov       ah,al
         lodsb
         and       al,0fh
         add       al,ah
         inc       si
         ret

DekCas   ENDP

; *****************************************************************************
;                             DispTKur
;                    zobrazen° kurzoru hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispTKur PROC      NEAR

         push      bx
         push      dx
         mov       dx,605h + 8*256 + 20
         xor       bx,bx
         mov       bl,byte ptr ds:[MnuAkt]

         test      byte ptr ds:[HodParm],1  ; je reëim modifikace ?
         jnz       DispTKr1                 ; je reëim modifikace

         call      KurzOff                  ; vypnut° kurzoru
         jmp       short DispTKr2

DispTKr1:add       dl,ds:[bx+TKurzPoz-1]
         call      SetKurz                  ; nastaven° pozice kurzoru
DispTKr2:pop       dx
         pop       bx
         ret

DispTKur ENDP

TKurzPoz db        0,1,3,4,6,7
         db        23,24,26,27,29,30,31,32

; *****************************************************************************
;                             DispHod
;                         zobrazen° hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-20] (20) buffer pro dek¢dov†n° data a áasu
;                   SS:[BP-22] (2) ®°©ka okna
;                   SS:[BP-23] (1) ©†dek k zobrazen°
;                   SS:[BP-24] (1) pozice k zobrazen°
;                   SS:[BP-26] (2) den v tòdnu
; *****************************************************************************
;˛
DispHod  PROC      NEAR

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

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,160 + 26              ; vytvo©en° bufferu v z†sobn°ku

         mov       cx,69                    ; ®°©ka okna
         mov       ss:[bp-22],cx            ; ®°©ka okna
         mov       dx,605h                  ; poá†teán° pozice hodin
         mov       ss:[bp-24],dx            ; ©†dek a pozice k zobrazen°

         push      ss
         pop       es

; ------ zobrazen° horn°ho okraje

         cld
         mov       ah,ds:[Barva1]           ; bàën† barva okna
         mov       al,218                   ; levò horn° roh
         call      Disp1Ch                  ; zobrazen° levÇho horn°ho rohu
         mov       al,196                   ; vodorovn† linka
         dec       cx
         dec       cx
         call      DispChr                  ; zobrazen° vodorovnÇ linky
         mov       al,191                   ; pravò horn° roh
         call      Disp1Ch                  ; zobrazen° pravÇho horn°ho rohu
         inc       byte ptr ss:[bp-23]      ; zvò®en° á°sla ©†dku

; ------ dek¢dov†n° £daje systÇmovÇho áasu

         lea       di,[bp-20]               ; buffer k dek¢dov†n° áasu
         call      DekSTime                 ; dek¢dov†n° systÇmovÇho áasu

; ------ zobrazen° horn°ho okraje

         mov       dx,ss:[bp-24]
         mov       al,179                   ; levò okraj
         call      Disp1Ch                  ; zobrazen° levÇho okraje
         mov       al," "                   ; lev† mezera
         call      Disp1Ch                  ; zobrazen° mezery
         mov       ah,ds:[Barva3]           ; barva áasu
         mov       cl,65                    ; dÇlka ©†dku
         call      DispChr                  ; zobrazen° mezery
         mov       ah,ds:[Barva1]           ; bàën† barva
         call      Disp1Ch                  ; prav† mezera
         mov       al,179
         call      Disp1Ch
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku

; ------ levò okraj linky £daje áasu

         xor       bl,bl                    ; á°taá linek fontñ
DispHod1:mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         mov       ah,ds:[Barva1]           ; bàën† barva okna
         mov       al,179                   ; levò okraj
         call      Disp1Ch
         mov       al," "                   ; lev† mezera
         call      Disp1Ch
         mov       ah,ds:[Barva3]           ; barva áasu
         call      Disp1Ch

; ------ dek¢dov†n° znakñ £daje áasu

         mov       bh,8                     ; á°taá znakñ na ©†dku
         lea       si,[bp-20]               ; buffer s £dajem áasu

; ------ zobrazen° linky jednoho znaku

DispHod3:push      si
         mov       al,ss:[si]               ; jeden znak k dek¢dov†n°
         sub       al,"0"                   ; korekce na á°slo
         mov       ah,35                    ; poáet bajtñ na znak
         mul       ah                       ; offset fontu v tabulce
         add       al,bl
         adc       ah,0                     ; offset linky v tabulce
         mov       si,offset ObrCis         ; fonty á°slic
         add       si,ax                    ; adresa linky
         mov       ah,ds:[Barva3]           ; barva áasu
         mov       cx,7                     ; poáet bajtñ
DispHod4:lodsb
         call      Disp1Ch
         loop      DispHod4
         pop       si

         mov       al," "
         call      Disp1Ch

; ------ p©°prava k dek¢dov†n° dal®°ho znaku

         inc       si
         inc       si                       ; adresa dal®°ho znaku k dek¢dov†n°
         dec       bh                       ; á°taá znakñ
         jnz       DispHod3                 ; dal®° znak

; ------ pravò okraj ©†dku

         mov       ah,ds:[Barva1]
         call      Disp1Ch
         mov       al,179
         call      Disp1Ch
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku

; ------ p©°prava k dek¢dov†n° dal®° linky

         add       bl,7                     ; offset dal®° linky
         cmp       bl,35                    ; jsou jië v®echny linky ?
         jb        DispHod1                 ; dal®° linka

; ------ oddàlovac° á†ra

         mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         mov       ah,ds:[Barva1]
         mov       al,195
         call      Disp1Ch
         mov       al,196
         mov       cl,67
         call      DispChr
         mov       al,180
         call      Disp1Ch
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku

; ------ p©enos textu £daje áasu

         test      byte ptr ds:[HodParm],2  ; byla modifikace áasu ?
         jnz       DispHod8                 ; byla modifikace áasu

         lea       si,[bp-20]               ; £daj áasu
         mov       cx,8                     ; poáet znakñ
         mov       di,offset HodMCas        ; £daj áasu
DispHod5:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       si
         inc       di
         loop      DispHod5

; ------ dek¢dov†n° £daje data

DispHod8:test      byte ptr ds:[HodParm],4  ; byla modifikace data ?
         jnz       DispHod7                 ; byla modifikace data

         mov       ah,ds:[Barva2]
         lea       di,[bp-20]
         mov       si,di
         call      DekSDate                 ; dek¢dov†n° £daje data
         mov       ah,0
         mov       ss:[bp-26],ax            ; den v tòdnu

; ------ p©enos textu £daje data

         mov       cx,10                    ; poáet znakñ
         mov       di,offset HodMDat        ; £daj data
DispHod6:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       si
         inc       di
         loop      DispHod6

; ------ p©enos dne v tòdnu

         mov       di,offset HodMDen
         mov       si,offset DnyTxt
         mov       al,offset(DnyTxt0-DnyTxt)
         mov       cl,al
         mul       byte ptr ss:[bp-26]
         add       si,ax
         cld
DispHd62:lodsb
         mov       ds:[di],al
         inc       di
         loop      DispHd62

; ------ zobrazen° ©†dku s £dajem áasu a datem

DispHod7:mov       si,offset HodMTxt1       ; text ©†dku
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       dx,ss:[bp-24]            ; ©†dek a pozice k zobrazen°
         mov       cl,69                    ; dÇlka ©†dku
         call      DispTxtM                 ; zobrazen° ©†dku
         inc       byte ptr ss:[bp-23]      ; zvò®en° ukazatele ©†dku

; ------ zobrazen° doln°ho okraje

         mov       dx,ss:[bp-24]
         mov       al,192                   ; levò okraj
         mov       ah,ds:[Barva1]           ; bàën† barva
         call      Disp1Ch                  ; zobrazen° levÇho okraje
         mov       al,196
         mov       cl,67
         call      DispChr                  ; oddàlovac° á†ra
         mov       al,217
         call      Disp1Ch

; ------ zobrazen° n†povàdy

         mov       si,ds:[MnuHlp]
         push      ds
         pop       es
         mov       cx,ds:[si]
         dec       cx
         dec       cx
         inc       si
         inc       si
         mov       dl,0
         mov       dh,ds:[MaxRow]
         mov       ah,ds:[Barva4]
         call      DispTxt
         mov       bx,80
         sub       bx,cx
         mov       cx,bx
         mov       al," "
         call      DispChr

; ------ n†vrat registrñ

DispHod9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHod  ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

DispTM0  PROC      NEAR

         mov       cx,ds:[si]
         inc       si
         inc       si
DispTM01:lodsb
         stosw
         loop      DispTM01
         xchg      ah,dh
         ret

DispTM0  ENDP

; *****************************************************************************
;                               DekSTime
;             dek¢dov†n° aktu†ln°ho systÇmovÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: AH=atribut barvy
;        ES:DI=buffer (pro 8 znakñ)
; VùSTUP:ES:DI=n†sleduj°c° adresa
; *****************************************************************************

DekSTime PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         mov       ch,ah                    ; atribut barvy textu
         cld

; ------ zji®tàn° systÇmovÇho áasu

         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[046ch]            ; áten° nië®° á†sti á°taáe áasu
         mov       dx,ds:[046eh]            ; áten° vy®®° á†sti á°taáe áasu
         pop       ds

; ------ dek¢dov†n°

         mov       cl,4                     ; poáet rotac°
         shl       dx,cl                    ; vy®®° slovo * 16
         mov       bx,ax                    ; nië®° slovo á°taáe áasu
         mov       cl,12
         shr       bx,cl                    ; nejvy®®° 4 bity nië®°ho slova
         add       dx,bx                    ; p©enos 4 bitñ do vy®®°ho slova
         mov       cl,4
         shl       ax,cl                    ; nië®° slovo * 16
         mov       bx,17478
         div       bx                       ; á°taá áasu / 1092.375
         push      dx                       ; £schova zbytku v minutà
         mov       bx,60                    ; poáet minut v hodinà
         xor       dx,dx                    ; DX <- 0, AX=poáet minut
         div       bx                       ; vòpoáet hodiny a minuty
         push      dx                       ; £schova minuty
         mov       dx,69                    ; poá†teán° pozice textu

; ------ uloëen° £daje hodin

         cld
         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na ASCII k¢d
         xchg      ah,al                    ; AL <- des°tky hodin
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des°tky hodin
         pop       ax
         mov       al,ah                    ; jednotky hodin
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky hodin
         mov       al,":"                   ; oddàlovac° znak
         stosw                              ; uloëen° oddàlovac°ho znaku

; ------ uloëen° £daje minut

         pop       ax                       ; n†vrat minut
         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na BCD k¢d
         xchg      ah,al                    ; AL <- des°tky minut
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des°tky minut
         pop       ax
         mov       al,ah                    ; jednotky minut
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky minut
         mov       al,":"                   ; oddàlovac° znak
         stosw                              ; oddàlovac° znak

; ------ dek¢dov†n° £daje sekund

         pop       ax                       ; n†vrat zbytku do 1 minuty
         mov       bx,60                    ; poáet sekund v minutà
         mul       bx                       ; vòpoáet poátu sekund a setin
         mov       bx,17478                 ; p©evod na abs. £daj
         div       bx                       ; vòpoáet poátu sekund

; ------ zobrazen° £daje sekund

         aam                                ; korekce na BCD k¢d
         add       ax,"00"                  ; korekce na ASCII k¢d
         xchg      ah,al
         push      ax
         mov       ah,ch                    ; barva textu
         stosw                              ; des°tky sekund
         pop       ax
         mov       al,ah
         mov       ah,ch                    ; barva textu
         stosw                              ; jednotky sekund

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekSTime ENDP

; *****************************************************************************
;                              DekSDate
;                    dek¢dov†n° systÇmovÇho data
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        ES:DI=adresa bufferu (10 znakñ)
;        DS=datovò segment
; VùSTUP:AL=den v tòdnu (0=nedàle)
; *****************************************************************************

DekSDate PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      di

; ------ poskytnut° systÇmovÇho data

         mov       bh,ah                    ; atribut barvy
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         mov       bl,al                    ; den v tòdnu
         cld
         push      cx                       ; £schova roku
         mov       ah,bh

; ------ dek¢dov†n° dne

         mov       al,dl                    ; den
         call      DekADTS                  ; dek¢dov†n° á°sla s mezerou
         mov       al,"."
         stosw                              ; oddàlovac° teáka

; ------ dek¢dov†n° màs°ce

         mov       al,dh                    ; màs°c
         call      DekADT0                  ; dek¢dov†n° á°sla s nulou
         mov       al,"."
         stosw                              ; oddàlovac° teáka

; ------ dek¢dov†n° roku

         pop       ax                       ; rok
         push      bx
         cmp       ax,1980
         jae       DekSDat2
         mov       ax,1980
DekSDat2:cmp       ax,9999
         jbe       DekSDat3
         mov       ax,9999
DekSDat3:xor       dx,dx
         xor       bl,bl
         call      DekNum
         pop       ax                       ; barva a den v tòdnu

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

DekSDate ENDP

; *****************************************************************************
;                Dek¢dov†n° á°sla od levÇho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=ukl†dac° adresa (poá†tek k uloëen° á°sla)
;        BH=atribut barev (0=atribut barev se neukl†d†)
;        BL=znak oddàlovaáe ©†dñ (0=oddàlovaá ©†dñ se neukl†d†)
; VùSTUP:ES:DI=n†sleduj°c° adresa za á°slem
; *****************************************************************************

DekNum   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©°prava registrñ

         mov       bp,10                    ; á°seln† soustava
         xor       cx,cx                    ; á°taá znakñ v z†sobn°ku

; ------ vòpoáet jednÇ á°slice

DekNum1: mov       si,ax                    ; £schova nië®°ho slova á°sla
         mov       ax,dx                    ; vy®®° slovo á°sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydàlen° vy®®°ho slova á°sla
         xchg      ax,si                    ; n†vrat nië®°ho slova
         div       bp                       ; vydàlen° nië®°ho slova á°sla

; ------ uloëen° oddàlovaáe ©†dñ

         or        bl,bl                    ; ukl†d† se oddàlovaá ©†dñ ?
         jz        DekNum3                  ; oddàlovaá ©†dñ se neukl†d†
         cmp       cx,3                     ; jsou tis°ce ?
         jne       DekNum2                  ; nejsou tis°ce
         push      bx                       ; uloëen° oddàlovaáe tis°cñ
         inc       cx                       ; zvò®en° á°taáe znakñ
DekNum2: cmp       cx,7                     ; jsou miliony ?
         jne       DekNum3                  ; nen° ©†d milionñ
         push      bx                       ; uloëen° oddàlovaáe milionñ
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ uloëen° novÇ á°slice

DekNum3: mov       dh,bh                    ; barva textu
         add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; uloëen° á°slice
         inc       cx                       ; zvò®en° á°taáe znakñ

; ------ test, zda je je®tà nàjakÇ á°slo

         mov       dx,si                    ; n†vrat vy®®°ho slova á°sla
         or        ax,ax                    ; je á°slo jië = 0 ?
         jnz       DekNum1                  ; á°slo je®tà nen° = 0 - pokraáov†n°
         or        dx,dx                    ; je á°slo jië = 0 ?
         jnz       DekNum1                  ; á°slo je®tà nen° = 0 - pokraáov†n°

; ------ uloëen° á°sla do bufferu

         cld
         or        bh,bh                    ; ukl†d† se atribut barvy ?
         jnz       DekNum6                  ; atribut barvy se ukl†d†

DekNum5: pop       ax                       ; n†vrat znaku á°sla
         stosb                              ; uloëen° znaku
         loop      DekNum5                  ; dal®° znak á°sla
         jmp       short DekNum8

DekNum6: pop       ax                       ; n†vrat znaku á°sla
         stosw                              ; uloëen° znaku s atributem
         loop      DekNum6                  ; dal®° znak á°sla

; ------ n†vrat registrñ

DekNum8: pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNum   ENDP

; *****************************************************************************
;                             DispTxtM
;                   zobrazen° textovÇho ©†dku menu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice poloëky
;        CL=®°©ka okna menu
;        ES:DI=buffer v z†sobn°ku k dek¢dov†n° textu
;        DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
; -----------------------------------------------------------------------------
; zniáenÇ registry: AX, BX, CX, DX, SI, DI
; *****************************************************************************

DispTxtM PROC      NEAR

; ------ p©°prava k dek¢dov†n° textu

         push      cx
         push      di

         mov       bl,cl                    ; ®°©ka ©†dku okna
         mov       cx,ds:[si]               ; offset dal®° poloëky
         sub       cx,3                     ; dÇlka textu k dek¢dov†n°
         add       si,3                     ; zaá†tek textu poloëky
         mov       ah,ds:[Barva1]           ; bàën† barva textu
         mov       bh,ds:[Barva2]           ; zvòraznàn† barva textu
         sub       bl,2                     ; maxim†ln° dÇlka textu
         cld

; ------ dek¢dov†n° textu

         jcxz      DispTxM5                 ; nen° ë†dnò text k dek¢dov†n°
DispTxM2:lodsb                              ; znak textu
         or        al,al                    ; je p©ep°naá barvy ?
         jnz       DispTxM3                 ; nen° p©ep°naá barvy
         xchg      ah,bh                    ; zmàna barvy
         jmp       short DispTxM4
DispTxM3:stosw                              ; uloëen° znaku
         dec       bl                       ; sn°ëen° á°taáe znakñ
         jz        DispTxM5                 ; je jië maxim†ln° poáet znakñ
DispTxM4:loop      DispTxM2                 ; dal®° znak

; ------ zobrazen° levÇho okraje

DispTxM5:mov       ah,ds:[Barva1]           ; bàën† barva textu
         mov       al,179                   ; levò okraj
         call      Disp1Ch                  ; zobrazen° levÇho okraje

; ------ dÇlka dek¢dovanÇho textu

         mov       bx,di                    ; adresa konce textu

         pop       si                       ; zaá†tek bufferu

         sub       bx,si                    ; dÇlka textu
         shr       bx,1                     ; dÇlka textu ve znac°ch

; ------ zobrazen° levÇ mezery textu

         pop       cx                       ; ®°©ka okna

         sub       cl,2                     ; vnit©n° ®°©ka okna
         sub       cl,bl                    ; zbylÇ okraje
         shr       cl,1                     ; levò okraj
         mov       ch,cl                    ; okraj
         adc       ch,0                     ; pravò okraj
         mov       al," "                   ; mezera
         call      DispChr                  ; zobrazen° levÇho okraje

; ------ zobrazen° textu nadpisu

         mov       cl,bl                    ; dÇlka textu
         call      DispStr                  ; zobrazen° textu nadpisu

; ------ zobrazen° pravÇ mezery

         mov       cl,ch                    ; prav† mezera
         call      DispChr                  ; zobrazen° pravÇ mezery

; ------ zobrazen° pravÇho okraje

         mov       al,179                   ; pravò okraj
         call      Disp1Ch                  ; zobrazen° pravÇho okraje
         ret

DispTxtM ENDP

; *****************************************************************************
;                    skok na obsluhu podle BX
; -----------------------------------------------------------------------------
; Procedura se vol† instrukc° CALL JumpBX, za kterou n†sleduje tabulka
; skokñ. Procedura zmàn° svou n†vratovou adresu na adresu podle nalezenÇ
; poloëky v tabulce (nebo podle poloëky pro nenalezenou hodnotu).
; -----------------------------------------------------------------------------
; VSTUP: v z†sobn°ku slovo (n†vratov† adresa NEAR) = zaá†tek tabulky skokñ
;             stuktura tabulky: 1 slovo testovan† hodnota BX
;                               1 slovo adresa NEAR obsluhy
;             konec tabulky: 1 slovo = 0 (p©°znak konce tabulky)
;                            1 slovo adresa NEAR obsluhy p©i nenalezen° k¢du
; *****************************************************************************

JumpBX   PROC      NEAR

; ------ £schova registrñ

                                            ; SS:[BP+6] = IP
         push      si                       ; SS:[BP+4] = SI
         push      bp                       ; SS:[BP+2] = BP
         push      ds                       ; SS:[BP+0] = DS
         mov       bp,sp

; ------ nalezen° hodnoty v tabulce

         push      cs
         pop       ds
         mov       si,ss:[bp+6]             ; offset adresy tabulky
JumpBX1: cmp       word ptr ds:[si],0       ; je konec tabulky ?
         je        JumpBX2                  ; konec tabulky - nenalezeno
         cmp       word ptr ds:[si],bx      ; je to hledan† hodnota ?
         je        JumpBX2                  ; hodnota nalezena
         add       si,4                     ; adresa dal®° poloëky
         jmp       short JumpBX1            ; test dal®° poloëky

; ------ nastaven° n†vratovÇ adresy podle tabulky

JumpBX2: mov       si,ds:[si+2]             ; adresa skoku
         mov       ss:[bp+6],si             ; nov† n†vratov† adresa

; ------ n†vrat registrñ

         pop       ds
         pop       bp
         pop       si
         ret

JumpBX   ENDP

; *****************************************************************************
;                               DekADTS
;                    dek¢dov†n° dvojá°sl° s mezerou
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu
;        ES:DI=ukl†dac° adresa
; *****************************************************************************

DekADTS  PROC      NEAR

         push      ax
         mov       cl,10
         xor       ah,ah
         div       cl                       ; vòpoáet á°slic
         mov       cx,ax                    ; £schova á°sla
         pop       ax
         mov       al,cl                    ; prvn° á°slice
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DekADTS1                 ; nen° 0
         mov       al," "                   ; n†hrada mezerou
DekADTS1:stosw                              ; uloëen° prvn° á°slice
         mov       al,ch                    ; druhÇ á°slo
         add       al,"0"                   ; korekce na á°slici
         stosw                              ; uloëen° druhÇ á°slice
         ret

DekADTS  ENDP

; *****************************************************************************
;                               DekADT0
;                    dek¢dov†n° dvojá°sl° s nulou
; -----------------------------------------------------------------------------
; VSTUP: AL=á°slo
;        AH=barva textu
;        ES:DI=ukl†dac° adresa
; *****************************************************************************

DekADT0  PROC      NEAR

         push      ax
         mov       cl,10
         xor       ah,ah
         div       cl                       ; vòpoáet á°slic
         mov       cx,ax                    ; £schova á°sla
         pop       ax
         mov       al,cl                    ; prvn° á°slice
         add       al,"0"                   ; korekce na znak ASCII
         stosw                              ; uloëen° prvn° á°slice
         mov       al,ch                    ; druhÇ á°slo
         add       al,"0"                   ; korekce na á°slici
         stosw                              ; uloëen° druhÇ á°slice
         ret

DekADT0  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              D I S P L A Y
;
;                             Obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

;; *****************************************************************************
;;                             Clear
;;                        vymaz†n° displeje
;; -----------------------------------------------------------------------------
;; VSTUP: DS=datovò segment
;; *****************************************************************************
;
;Clear    PROC      NEAR
;
;         push      ax
;         push      cx
;         push      dx
;
;         mov       ch,ds:[Radku]            ; poáet ©†dkñ
;         mov       cl,80                    ; poáet pozic na ©†dek
;         mov       ax,720h                  ; znak pro vymaz†n°
;         mov       dh,0                     ; poá†teán° ©†dek
;
;Clear1:  mov       dl,0                     ; poá†teán° pozice
;         call      DispChr                  ; vymaz†n° ©†dku
;         inc       dh
;         dec       ch
;         jnz       Clear1                   ; dal®° ©†dek
;
;         xor       dx,dx
;         call      SetKurz                  ; nastaven° pozice kurzoru
;
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;Clear    ENDP

; *****************************************************************************
;                            KurzOff
;                        vypnut° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

KurzOff  PROC      NEAR

         push      dx
         mov       dl,0
         mov       dh,ds:[Radku]            ; prvn° ©†dek "za rohem"
         call      SetKurz                  ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzOff  ENDP

; *****************************************************************************
;                            SetKurz
;                     nastaven° pozice kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,2                     ; funkce - nastaven° pozice kurzoru
         call      Int10P                   ; nastaven° pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; *****************************************************************************
;                            GetKurz
;                     poskytnut° pozice kurzoru
; -----------------------------------------------------------------------------
; VùSTUP:DL=pozice kurzoru
;        DH=©†dek kurzoru
;        DS=datovò segment
; *****************************************************************************

GetKurz  PROC      NEAR

         push      ax
         push      bx
         push      cx
         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,3                     ; funkce - poskytnut° pozice kurzoru
         call      Int10P                   ; poskytnut° pozice kurzoru
         pop       cx
         pop       bx
         pop       ax
         ret

GetKurz  ENDP

; *****************************************************************************
;                              Disp1Chr
;                    Z†pis 1 znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         DL=pozice
;         DH=©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

Disp1Ch  PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z†pisu
         call      DispChr                  ; z†pis 1 znaku na displej
         pop       cx
         ret

Disp1Ch  ENDP

; *****************************************************************************
;                              DispChr
;                 Opakovanò z†pis znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  AX=znak k z†pisu (AL=znak, AH=atribut)
;         CL=poáet znakñ k z†pisu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispChr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispChr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispChr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         mov       bx,ax                    ; £schova znaku k z†pisu
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispChr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispChr1:les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         je        DispChr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispChr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
DispChr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispChr5                 ; prob°h† vertik†ln° impuls
DispChr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispChr3                 ; je horiz. zpàtnò bàh - áek†n°
DispChr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispChr4                 ; áek†n° na horiz. zpàtnò bàh
DispChr5:mov       ax,bx                    ; znak k zobrazen°
         stosw                              ; z†pis jednoho znaku
         loop      DispChr2                 ; z†pis dal®°ho znaku

; ------ z†pis znaku bez kontroly snàëen°

DispChr6:mov       ax,bx                    ; znak k zobrazen°
         rep       stosw                    ; z†pis znaku bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispChr7:pop       es                       ; n†vrat ES
         pop       di                       ; n†vrat DI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX

DispChr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispChr  ENDP




; *****************************************************************************
;                              DispTxt
;                  Zobrazen° textovÇho ©etàzce na obrazovce
; -----------------------------------------------------------------------------
; VSTUP:  AH=atribut barvy
;         CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (bez atributñ)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispTxt  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispTxt8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispTxt8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispTxt1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispTxt1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         push      ax
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti
         pop       ax

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         sti                                ; p©eru®en° povoleno
         cld                                ; smàr posunu ukazatele nahoru
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         jcxz      DispTxt7                 ; nen° ë†dnò znak k p©enosu
         je        DispTxt6                 ; neprov†d° se kontrola snàëen°

; ------ p©enos dat s obsluhou snàëen°

DispTxt2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispTxt5                 ; prob°h† vertik†ln° impuls
DispTxt3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispTxt3                 ; je horiz. zpàtnò bàh - áek†n°
DispTxt4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispTxt4                 ; áek†n° na horiz. zpàtnò bàh
DispTxt5:lodsb                              ; naáten° znaku k zobrazen°
         stosw                              ; p©enos jednoho znaku
         loop      DispTxt2                 ; p©enos dal®°ho znaku
         jmp       short DispTxt7

; ------ p©enos dat bez kontroly snàëen°

DispTxt6:lodsb                              ; znak k zobrazen°
         stosw                              ; uloëen° znaku
         loop      DispTxt6                 ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispTxt7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispTxt8:add       dl,cl                    ; zvò®en° pozice
         ret

DispTxt  ENDP

; *****************************************************************************
;                              DispStr
;                 Zobrazen° textovÇho ©etàzce na obrazovku
; -----------------------------------------------------------------------------
; VSTUP:  CL=poáet znakñ textu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
;         ES:SI=adresa textovÇho ©etàzce (1 znak = 2 bajty = znak a atribut)
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispStr  PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispStr8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispStr8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      ds                       ; £schova DS
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ do konce ©†dku

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispStr1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispStr1:push      es                       ; £schova segmentu zdrojovÇho textu
         les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ p©°prava dat; zji®tàn°, zda se kontroluje snàëen°

         cld                                ; smàr posunu ukazatele nahoru
         sti                                ; povolen° p©eru®en°
         mov       dx,ds:[PortCRT]          ; stavovò registr ©adiáe displeje
         cmp       byte ptr ds:[ChckSnow],0 ; prov†d° se kontrola snàëen° ?
         pop       ds                       ; segment zdrojovÇ adresy
         je        DispStr6                 ; neprov†d° se kontrola snàëen°
         jcxz      DispStr7                 ; nen° ë†dnò znak k p©enosu

; ------ p©enos dat s obsluhou snàëen°

DispStr2:in        al,dx                    ; áten° stavu video©adiáe 6845
         test      al,8                     ; prob°h† vertik†ln° impuls ?
         jnz       DispStr5                 ; prob°h† vertik†ln° impuls
DispStr3:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horizont†ln°ho zpàtnÇho bàhu
         jc        DispStr3                 ; je horiz. zpàtnò bàh - áek†n°
DispStr4:in        al,dx                    ; áten° stavu video©adiáe 6845
         rcr       al,1                     ; test horiz. zpàtnÇho bàhu
         jnc       DispStr4                 ; áek†n° na horiz. zpàtnò bàh
DispStr5:movsw                              ; p©enos jednoho znaku
         loop      DispStr2                 ; p©enos dal®°ho znaku

; ------ p©enos dat bez kontroly snàëen°

DispStr6:rep       movsw                    ; p©enos dat bez kontroly snàëen°

; ------ n†vrat registrñ, konec

DispStr7:pop       es                       ; n†vrat ES
         pop       ds                       ; n†vrat DS
         pop       di                       ; n†vrat DI
         pop       si                       ; n†vrat SI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       ax                       ; n†vrat AX

DispStr8:add       dl,cl                    ; zvò®en° pozice
         ret

DispStr  ENDP

; *****************************************************************************
;                             InitVmod
;                      Inicializace videom¢du
;             (poëaduje, aby byla rozpozn†na karta EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: CY=videom¢d byl zmànàn
;         neniá° ë†dnò registr
; *****************************************************************************

InitVMod PROC      NEAR

; ------ £schova registrñ

         push      ax

; ------ kontrola, zda je povolenò videom¢d

         call      AktPDisp                 ; aktualizace parametrñ displeje
         cmp       al,7                     ; MDA ?
         je        InitVM5                  ; povolenò videom¢d
         cmp       al,2
         je        InitVM5                  ; CGA
         cmp       al,3
         je        InitVM5                  ; CGA

; ------ stanoven° implicitn°ho videom¢du

         int       11h                      ; poskytnut° tabulky vybaven°
         and       al,30h                   ; inicializaán° videom¢d
         cmp       al,30h                   ; videom¢d 80x25 monochrom. ?
         mov       al,7                     ; videom¢d MDA
         je        InitVM1                  ; je videom¢d MDA
         mov       al,3                     ; jinak videom¢d CGA
InitVM1: call      SetVMode                 ; nastaven° poëadovanÇho videom¢du
         stc                                ; p©°znak zmàny videom¢du

; ------ n†vrat registrñ

InitVM5: pop       ax
         ret

InitVMod ENDP

; *****************************************************************************
;                               SetVMode
;                          Nastaven° videom¢du
;                (doporuáuje se rozpozn†n° videokarty EGA/VGA)
; -----------------------------------------------------------------------------
; VSTUP:  AL=poëadovanò videom¢d
;         DS=datovò segment
; VùSTUP: AL=novò aktu†ln° videom¢d
;         CY=videom¢d nenastaven
;         neniá° ë†dnò registr
; *****************************************************************************

SetVMode PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax                       ; £schova poëadovanÇho videom¢du

; ------ nastaven° videom¢du

         xor       ah,ah                    ; funkce nastaven° videom¢du
         call      Int10P                   ; nastaven° videom¢du
         call      AktPDisp                 ; poskytnut° aktivn°ho videom¢du
         mov       bl,al                    ; £schova aktu†ln°ho videom¢du

; ------ n†vrat registrñ, zhodnocen° vòsledku

         pop       ax                       ; n†vrat poëadovanÇho videom¢du
         xchg      al,bl                    ; AL <- novò videom¢d
         cmp       al,bl                    ; souhlas° videom¢d s poëadovanòm ?
         je        SetVMod1                 ; videom¢d nastaven OK
         stc                                ; p©°znak chyby nastaven° videom¢du
SetVMod1:pop       bx
         ret

SetVMode ENDP

; *****************************************************************************
;                               AktPDisp
;            Atualizace parametrñ displeje podle videom¢du
;
; Tato procedura pouë°v† k aktualizaci parametrñ pouze operace v pamàti,
; nepouë°v† ë†dnÇ p©eru®en°. Vyëaduje rozpozn†n° karty EGA/VGA.
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: AL=aktu†ln° videom¢d
;         neniá° ë†dnò registr
; *****************************************************************************

AktPDisp PROC    NEAR

; ------ £schova registrñ

         push      es
         push      bx

; ------ zji®tàn° videom¢du

         mov       bx,40h
         mov       es,bx                    ; ES <- 40h segment dat BIOS
         mov       al,es:[49h]              ; aktu†ln° videom¢d
         and       al,7fh                   ; zru®en° p©°znaku nemaz†n° displeje

; ------ zji®tàn° videostr†nky

         mov       bl,es:[62h]              ; aktivn° videostr†nka
         mov       ds:[AktPage],bl          ; £schova aktivn° videostr†nky

; ------ zji®tàn° adresy videopamàti a p©ednastaven° p©°znaku obsluhy snàëen°

         mov       byte ptr ds:[ChckSnow],0 ; zru®en° p©°znaku obsluhy snàëen°
         mov       word ptr ds:[AdrVRAM+2],0B000h ; segment videopamàti pro MDA
         cmp       al,7                     ; je videom¢d MDA ?
         je        AktParD1                 ; je videom¢d MDA
         mov       word ptr ds:[AdrVRAM+2],0B800h ; segment videopamàti pro CGA
         inc       byte ptr ds:[ChckSnow]   ; nastav. p©°znaku obsluhy snàëen°
AktParD1:mov       bx,es:[4eh]              ; poá†teán° adresa videopamàti
         mov       word ptr ds:[AdrVRAM],bx ; poá†teán° adresa videopamàti

; ------ zji®tàn° poátu ©†dkñ a up©esnàn° p©°znaku snàëen°

         mov       bl,24                    ; p©ednastaven° na 25 ©†dkñ
         cmp       byte ptr ds:[EgaVga],0   ; je karta EGA, VGA ?
         je        AktParD6                 ; nen° karta EGA/VGA
         cmp       byte ptr es:[84h],5      ; je £daj poátu ©†dkñ platnò ?
         jb        AktParD5                 ; £daj poátu ©†dkñ nen° platnò
         mov       bl,es:[84h]              ; poáet ©†dkñ displeje - 1
AktParD5:mov       bh,es:[87h]              ; p©°znak kontroly snàëen°
         shr       bh,1
         shr       bh,1
         and       bh,1                     ; p©°znak obsluhy snàëen°
         mov       ds:[ChckSnow],bh         ; nastaven° p©°znaku kontroly snàë.
AktParD6:mov       ds:[MaxRow],bl           ; maxim†ln° ©†dek na displeji
         inc       bl                       ; poáet ©†dkñ celkem
         mov       ds:[Radku],bl            ; poáet ©†dkñ celkem

; ------ zji®tàn° b†zovÇ ©°dic° adresy displeje CRT

         mov       bx,es:[63h]              ; b†zov† adresa portu ©adiáe CRT
         add       bx,6
         mov       ds:[PortCRT],bx          ; stavovò registr ©adiáe displeje

; ------ n†vrat registrñ

         pop       bx
         pop       es
         ret

AktPDisp ENDP

; *****************************************************************************
;                              DetCard
;                      detekce videokarty EGA/VGA
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
;         neniá° ë†dnò registr
; *****************************************************************************

DetCard  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; sluëba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut° informac° o EGA
         call      Int10P                   ; poskytnut° informac° o EGA/VGA
         mov       byte ptr ds:[EgaVga],0   ; zru®en° p©°znaku karty EGA/VGA
         cmp       bh,1                     ; kontrola navr†cenÇho m¢du displeje
         ja        DetectC1                 ; nen° to karta EGA/VGA
         cmp       bl,5                     ; maxim†lnà povolen 1 MB pamàti
         ja        DetectC1                 ; nen° to karta EGA/VGA
         mov       byte ptr ds:[EgaVga],1   ; p©°znak karty EGA/VGA

; ------ n†vrat registrñ

DetectC1:pop       cx
         pop       bx
         pop       ax
         ret

DetCard  ENDP

; *****************************************************************************
;                              Int10P
;                Vol†n° INT 10h s £schovou registrñ
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

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                    Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

MemTxt   db        'CHYBA - nedostatek pameti !',13,10,'$'

Barva1   db        70h                      ; bàën† barva
Barva2   db        74h                      ; zvòraznàn† barva
Barva3   db        0ah                      ; barva textu áasu
Barva4   db        30h                      ; barva textu n†povàdy

; -----------------------------------------------------------------------------
;        definice hodin
; -----------------------------------------------------------------------------

ColHod   db        0ah                      ; barva textu áasu

ZHMnuLin db        6                        ; typ menu - hodiny

MnuAkt   dw        1                        ; aktivn° poloëka - kurzor na ©†dku
MnuNum   dw        14                       ; poáet platnòch poloëek
         dw        14                       ; celkovò poáet poloëek

         dw        HodMTxt1                 ; zaá†tek definice poloëek
MnuHlp   dw        ZHMnuLH1                 ; n†povàda
         dw        0                        ; blokovac° tabulka
         dw        0                        ; p©ep°naáe

         db        (80-70)/2                ; poá†teán° pozice
         db        6                        ; poá†teán° ©†dek
         db        69                       ; ®°©ka okna
         db        10                       ; vò®ka okna

HodParm  db        0                        ; parametry:
                                            ;  bit 0: 1=reëim modifikace
                                            ;  bit 1: 1=áas zmànàn
                                            ;  bit 2: 1=datum zmànàn

HodMTxt1 dw        HodMTxt3-$
         db        40h
         db        '        Cas  ',0
HodMCas  db        '00:00:00',0
         db        '        Datum  ',0
HodMDat  db        '01.01.1980  '
HodMDen  db        'nedele '
HodMTxt3 label     word

ZHMnuLH1 dw        ZHMnuLH2-$
         db        ' HODINY V1.1; (c) Miroslav Nemecek ≥ <Enter>=nastaveni casu a data; <Esc>=konec'
ZHMnuLH2 dw        ZHMnuLH3-$
         db        ' Zadejte novy cas a datum a stisknete <Enter>; <Esc>=navrat beze zmeny.'
ZHMnuLH3 label     word

DnyTxt   db        'nedele '
DnyTxt0  db        'pondeli'
         db        'utery  '
         db        'streda '
         db        'ctvrtek'
         db        'patek  '
         db        'sobota '

ObrCis   db        '‹€ﬂﬂﬂ€‹'                ; obr†zky á°slic pro hodiny
         db        '€€   €€'
         db        '€€   €€'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '  ‹€€  '
         db        ' ﬂﬂ€€  '
         db        '   €€  '
         db        '   €€  '
         db        ' ﬂﬂﬂﬂﬂﬂ'
         db        '‹€ﬂﬂﬂ€‹'
         db        '    ‹€ﬂ'
         db        '  ‹€ﬂ  '
         db        '‹€ﬂ  ‹‹'
         db        'ﬂﬂﬂﬂﬂﬂﬂ'
         db        '‹€ﬂﬂﬂ€‹'
         db        '     €€'
         db        '  ﬂﬂﬂ€‹'
         db        '‹‹   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '   ‹€€ '
         db        ' ‹€ﬂ€€ '
         db        '€€‹‹€€‹'
         db        '    €€ '
         db        '   ﬂﬂﬂﬂ'
         db        '€€ﬂﬂﬂﬂﬂ'
         db        '€€     '
         db        'ﬂﬂﬂﬂﬂ€‹'
         db        '‹‹   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        ' ‹€ﬂﬂﬂ '
         db        '€€     '
         db        '€€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '€€ﬂﬂﬂ€€'
         db        '    ‹€ﬂ'
         db        '  ‹€ﬂ  '
         db        '  €€   '
         db        '  ﬂﬂ   '
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂﬂ '
         db        '‹€ﬂﬂﬂ€‹'
         db        '€€   €€'
         db        ' ﬂﬂﬂﬂ€€'
         db        '    ‹€ﬂ'
         db        ' ﬂﬂﬂﬂ  '
         db        '       '
         db        '   €€  '
         db        '       '
         db        '   €€  '
         db        '       '

; -----------------------------------------------------------------------------
;        Parametry displeje a videom¢du
; -----------------------------------------------------------------------------

         EVEN
AdrVRAM  dd        0b8000000h               ; adresa videostr†nky displeje
PortCRT  dw        3dah                     ; b†zov† adresa portu ©adiáe CRT
Radku    db        25                       ; poáet ©†dkñ celkem
MaxRow   db        24                       ; maxim†ln° ©†dek na displeji
EgaVga   db        0                        ; p©°znak, ëe je karta EGA/VGA
ChckSnow db        0                        ; p©°znak, ëe se kontroluje snàëen°
AktPage  db        0                        ; aktivn° videostr†nka

ObrSegm  dw        ?                        ; buffer k £schovà obrazovky
OldKurz  dw        ?                        ; uschovan† pozice kurzoru
ObrSize  dw        ?                        ; velikost bufferu obrazovky (slov)

         dw        200h dup(?)              ; z†sobn°k
Zasob    label     byte

CODE     ENDS

         END       Start

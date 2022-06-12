

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                               F L A P P Y
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;MaxStrel EQU       50                       ; maxim†ln° poáet st©el ve scÇnà
;MaxZab   EQU       20                       ; maxim†ln° poáet ë†b ve scÇnà
;MaxDuch  EQU       20                       ; maxim†ln° poáet duchñ ve scÇnà
;MaxKouli EQU       30                       ; maxim†ln° poáet koul° ve scÇnà

Scen0    EQU       1                        ; startovac° scÇna

Code     SEGMENT
         ASSUME    cs:Code,ds:Data

; ------ inicializace segmentñ

Start:   mov       ax,SEG Data
         mov       ds,ax                    ; datovò segment

; ------ £schova aktivn°ho videom¢du

         mov       ah,0fh
         int       10h                      ; poskytnut° aktivn°ho videom¢du
         mov       ds:[OldVMod],al          ; aktivn° videom¢d

; ------ test, zda je grafick† karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut° informac° EGA
         mov       bx,5810h                 ; podsluëba informac° o EGA
         int       10h                      ; poskytnut° informac° o EGA
         cmp       bh,2
         ja        Start2                   ; nen° karta EGA/VGA
         cmp       bl,5
         ja        Start2                   ; nen° karta EGA/VGA

; ------ nastaven° pracovn°ho grafickÇho m¢du

         mov       ax,16                    ; poëadovanò videom¢d 16
         int       10h                      ; nastaven° videom¢du 16
         mov       ah,0fh
         int       10h                      ; poskytnut° aktivn°ho videom¢du
         cmp       al,16                    ; je poëadovanò videom¢d ?
         je        Start3                   ; videom¢d nastaven OK

; ------ nen° grafick† karta EGA/VGA

Start2:  mov       ah,0fh
         int       10h
         cmp       al,7
         jne       Start21

         mov       byte ptr ds:[ParHerc],1
         mov       ax,7
         int       10h
         call      InitHerc
         jmp       short Start3

Start21: mov       dx,offset ErrCard        ; chybovò text - nen° EGA/VGA
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
         mov       ax,4c01h                 ; funkce n†vratu z programu
         int       21h                      ; n†vrat z programu

; ------ inicializace hodin

Start3:  call      CekInit
         call      InitRnd                  ; inicializace gener†toru n†hody

; ------ obsluha p©eru®en° INT 23h a INT 1Bh

         mov       ax,351bh
         int       21h
         mov       word ptr ds:[Old1b],bx
         mov       word ptr ds:[Old1b+2],es ; £schova adresy INT 1bh

         mov       ax,3509h
         int       21h
         mov       word ptr cs:[Old09],bx
         mov       word ptr cs:[Old09+2],es

         push      ds
         push      cs
         pop       ds
         mov       dx,offset Int23
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h
         mov       dx,offset Int23
         mov       ax,251bh
         int       21h                      ; instalace obsluhy INT 1Bh
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h                      ; instalace INT 09h

; ------ instalace obsluhy p©eru®en° INT 24h

         mov       dx,offset Int24
         mov       ax,2524h
         int       21h                      ; instalace obsluhy INT 24h
         pop       ds

; ------ inicializace hrac° plochy - nov† hra

NovaHra: mov       byte ptr ds:[Zivoty],5
         mov       word ptr ds:[Scena],Scen0

NovaHr0:

         call      InitScen

         call      DispPole
         mov       word ptr cs:[KeyBuf],0
         mov       byte ptr ds:[Sezran],0

NovaHr1:
         mov       word ptr ds:[Time],1500*2
         call      DispTime
         call      NovFlap

; -----------------------------------------------------------------------------
;        z†kladn° cyklus hry
; -----------------------------------------------------------------------------

; ------ test, zda je p©eru®en° hry Esc

Cyklus:  call      TestKey
         jc        Cyklus2
         call      InpKey
         je        Cyklus1
;         cmp       al," "
;         je        Cyklus1
         mov       al,ah
         jmp       short Cyklus3

Cyklus1: jmp       Prerus                   ; p©eru®en° hry Esc

Cyklus2: mov       al,cs:[StickBuf]
Cyklus3:
         call      Strel                    ; obsluha st©el
         call      PadKoul                  ; obsluha koul°
         call      Flappy                   ; obsluha pohybu Flappyho
         call      Duchy                    ; obsluha duchñ

; ------ test, zda je konec hry

         mov       ax,ds:[Modra]            ; pozice a ©†dek modrÇ cihly
         sub       ah,4                     ; poëadovan† pozice modrÇ koule
         cmp       ax,word ptr ds:[Koule+1] ; dosaëena pozice ?
         jne       Cyklus8                  ; nen° konec hry

; ------ £spà®nò konec hry

         mov       byte ptr ds:[FazFlap],1  ; f†ze Flappyho
         call      DispAFlp                 ; zobrazen° Flappyho
         mov       cx,200
         call      Cekej                    ; prodleva
         mov       bx,8                     ; poáet vyskoáen°
Cyklus6: xor       byte ptr ds:[FazFlap],1 XOR 2 ; zmàna f†ze
         call      DispAFlp                 ; zobrazen° Flappyho
         mov       cx,120
         call      Cekej
         dec       bx
         jnz       Cyklus6
         inc       byte ptr ds:[Zivoty]
         jmp       NovaHr0                  ; nov† hra

Cyklus8:
         dec       word ptr ds:[Time]
         jns       Cyklus86
         call      Sezrani
         inc       word ptr ds:[Time]
Cyklus86:call      DispTime

         cmp       byte ptr ds:[Sezran],0
         je        Cyklus87
         dec       byte ptr ds:[Sezran]
         jz        Cyklus89

Cyklus87:
         call      ProdlHra                 ; prodleva p©i h©e

         jmp       short Cyklus

Cyklus89:mov       dx,ds:[PozFlap]
         call      DispBMaz
         jmp       NovaHr1                  ; novò Flappy


Prerus:
         cmp       al," "
         jne       Navrat
         jmp       NovaHr1


; ------ konec - n†vrat z programu
Navrat:










; ------ n†vrat pñvodn°ho videom¢du

         mov       al,ds:[OldVMod]          ; pñvodn° vidoem¢d
         xor       ah,ah
         int       10h                      ; nastaven° pñvodn°ho videom¢du

; ------ n†vrat obsluhy INT 1Bh

         push      ds
         lds       dx,ds:[Old1b]
         mov       ax,251bh
         int       21h
         pop       ds

; ------ n†vrat obsluhy INT 09h

         push      ds
         lds       dx,cs:[Old09]
         mov       ax,2509h
         int       21h
         pop       ds

; ------ konec programu

         call      TonOff                   ; vypnut° zvukovÇho gener†toru
         mov       ax,4c00h
         int       21h                      ; n†vrat z programu


; *****************************************************************************
;
;                                Hra
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                            Obsluha Flappyho
; -----------------------------------------------------------------------------
; VSTUP: AL=k¢d ovl†dac° kl†vesy (joystick)
; -----------------------------------------------------------------------------

Flappy   PROC      NEAR

; ------ p©°prava aktu†ln° pozice a f†ze

         mov       cl,ds:[FazFlap]          ; f†ze Flappyho
         mov       dx,ds:[PozFlap]          ; pozice Flappyho

; ------ je-li na lichÇ pozici, dokonáen° pohybu vlevo nebo vpravo

         test      dl,1                     ; je lich† pozice ?
         jz        Flappy2                  ; nen° lich† pozice

; ------ dokonáen° kroku vlevo

         cmp       cl,9                     ; je mezikrok vlevo ?
         jne       Flappy1                  ; nen° mezikrok vlevo
         dec       dl                       ; nov† pozice
         mov       cl,8                     ; nov† f†ze
         jmp       short Flappy76

; ------ dokonáen° kroku vpravo

Flappy1: inc       dl                       ; nov† pozice
         mov       cl,10                    ; nov† f†ze
         jmp       short Flappy76

; ------ je-li na lichÇm ©†dku, dokonáen° pohybu nahoru nebo dolñ

Flappy2: test      dh,1                     ; je lichò ©†dek ?
         jz        Flappy36                 ; nen° lichò ©†dek

; ------ dokonáen° kroku nahoru

         cmp       cl,6                     ; krok nahoru 1
         je        Flappy32
         cmp       cl,7                     ; krok nahoru 2
         jne       Flappy34
Flappy32:dec       dh                       ; novò ©†dek
         mov       cl,5                     ; stoj°
         jmp       short Flappy76

; ------ dokonáen° kroku dolñ

Flappy34:inc       dh                       ; novò ©†dek
         mov       cl,1                     ; stoj°
Flappy76:jmp       Flappy77

; -----------------------------------------------------------------------------
;        obsluha seëranÇho Flappyho
; -----------------------------------------------------------------------------

Flappy36:cmp       byte ptr ds:[Sezran],0
         je        Flappy4

         mov       byte ptr ds:[FazFlap],0
         mov       cl,12                    ; leë° 1
         cmp       byte ptr ds:[Sezran],30
         jb        Flappy76
         test      byte ptr ds:[Sezran],1
         jz        Flappy76
         mov       cl,13
         jmp       short Flappy76

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

Flappy4: cmp       al,4bh                   ; kurzor vlevo
         jne       Flappy42

; ------ vlevo koule na £rovni Flappyho

         sub       dl,4                     ; testovan† pozice
         call      SrcKoul                  ; nalezen° koule s pozic° DX
         jc        Flapp411                 ; koule nenalezena
         call      LKoule                   ; posun koule vlevo

; ------ vlevo koule o £rove§ vò®e neë Flappy

Flapp411:mov       bx,dx                    ; £schova sou©adnic
         sub       dh,2
         call      SrcKoul                  ; je koule ?
         jc        Flapp412                 ; nen° koule
         sub       dl,2
         call      TestVPol                 ; test vertik†ln°ho pole
         jnc       Flapp412                 ; je volnÇ - nerozbije se
         add       dh,4
         add       dl,4
         call      TestCih                  ; test, zda je pod koul° cihla
         jc        Flapp412                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp412:mov       dx,bx                    ; n†vrat sou©adnic

; ------ vlevo koule o £rove§ n°ëe neë Flappy

         add       dh,2
         call      SrcKoul                  ; je koule ?
         jc        Flapp413                 ; nen° koule
         sub       dl,2
         call      TestVPol                 ; test vertik†ln°ho pole
         jnc       Flapp413                 ; je volnÇ - nerozbije se
         sub       dh,4
         add       dl,4
         call      TestCih                  ; test, zda je nad koul° cihla
         jc        Flapp413                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp413:mov       dx,bx                    ; n†vrat sou©adnic

; ------ proveden° kroku Flappyho

         add       dl,2                     ; n†vrat pozice
         call      TestPole
         mov       cl,8
         jc        Flapp419
         dec       dx
         mov       cl,9
Flapp419:add       dl,2

Flappy77:jmp       short Flappy78

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

Flappy42:cmp       al,4dh                   ; kurzoru vpravo
         jne       Flappy44

; ------ posun koule vpravo

         add       dl,4                     ; testovan† pozice
         call      SrcKoul                  ; nalezen° koule s pozic° DX
         jc        Flapp421                 ; koule nenalezena
         call      RKoule                   ; posun koule vpravo

; ------ vpravo koule o £rove§ vò®e neë Flappy

Flapp421:mov       bx,dx                    ; £schova sou©adnic
         sub       dh,2
         call      SrcKoul                  ; je koule ?
         jc        Flapp422                 ; nen° koule
         add       dl,4
         call      TestVPol                 ; test vertik†ln°ho pole
         jnc       Flapp422                 ; je volnÇ - nerozbije se
         add       dh,4
         sub       dl,4
         call      TestCih                  ; test, zda je pod koul° cihla
         jc        Flapp422                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp422:mov       dx,bx                    ; n†vrat sou©adnic

; ------ vpravo koule o £rove§ n°ëe neë Flappy

         add       dh,2
         call      SrcKoul                  ; je koule ?
         jc        Flapp423                 ; nen° koule
         add       dl,4
         call      TestVPol                 ; test vertik†ln°ho pole
         jnc       Flapp423                 ; je volnÇ - nerozbije se
         sub       dh,4
         sub       dl,4
         call      TestCih                  ; test, zda je nad koul° cihla
         jc        Flapp423                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp423:mov       dx,bx                    ; n†vrat sou©adnic

; ------ proveden° kroku Flappyho

         sub       dl,2                     ; n†vrat pozice
         call      TestPole
         mov       cl,10
         jc        Flapp424
         inc       dx
         mov       cl,11
Flapp424:sub       dl,2

Flappy78:jmp       short Flappy79

; -----------------------------------------------------------------------------
;        kurzor dolñ
; -----------------------------------------------------------------------------

Flappy44:cmp       al,50h                   ; kurzor dolñ
         jne       Flappy46

; ------ rozbit° koule pod Flappym

         add       dh,4
         call      SrcKoul                  ; nalezen° koule
         jc        Flapp442                 ; koule nenalezena
         call      XKoule                   ; rozbit° koule

; ------ rozbit° koule pod Flappym vlevo

Flapp442:mov       bx,dx                    ; £schova pozice
         sub       dl,2
         call      SrcKoul                  ; je tam koule ?
         jc        Flapp443                 ; nen° tam koule
         add       dl,4
         call      TestCih                  ; test, zda je tam cihla
         jc        Flapp443                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp443:mov       dx,bx                    ; n†vrat pozice

; ------ rozbit° koule pod Flappym vpravo

         add       dl,2
         call      SrcKoul                  ; je tam koule ?
         jc        Flapp444                 ; nen° tam koule
         sub       dl,4
         call      TestCih                  ; test, zda je tam cihla
         jc        Flapp444                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp444:mov       dx,bx                    ; n†vrat pozice

; ------ proveden° kroku Flappyho

         sub       dh,2
         call      TestPole
         mov       cl,1
         jc        Flapp445
         inc       dh
         mov       cl,3
         test      dh,2
         jz        Flapp445
         mov       cl,4
Flapp445:sub       dh,2

Flappy79:jmp       Flappy7

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

Flappy46:cmp       al,48h                   ; kurzor nahoru
         jne       Flappy47

; ------ rozbit° koule nad Flappym vlevo

         sub       dh,4                     ; koule nad Flappym
         mov       bx,dx                    ; £schova pozice
         sub       dl,2                     ; koule vlevo
         call      SrcKoul                  ; je tam koule ?
         jc        Flapp461                 ; nen° tam koule
         sub       dh,2
         call      TestHPol                 ; test horizont†ln°ho pole
         jnc       Flapp461                 ; nic tam nen° - nerozbije se
         add       dh,4
         add       dl,4
         call      TestCih                  ; test, zda je tam cihla
         jc        Flapp461                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp461:mov       dx,bx                    ; n†vrat pozice

; ------ rozbit° koule pod Flappym vpravo

         add       dl,2                     ; koule vpravo
         call      SrcKoul                  ; je tam koule ?
         jc        Flapp464                 ; nen° tam koule
         sub       dh,2
         call      TestHPol                 ; test horizont†ln°ho pole
         jnc       Flapp464                 ; nic tam nen° - nerozbije se
         add       dh,4
         sub       dl,4
         call      TestCih                  ; test, zda je tam cihla
         jc        Flapp464                 ; je tam cihla
         call      XKoule                   ; rozbit° koule
Flapp464:mov       dx,bx                    ; n†vrat pozice

; ------ proveden° kroku

         add       dh,2
         call      TestPole
         mov       cl,5
         jc        Flapp466
         dec       dh
         mov       cl,6
         test      dh,2
         jz        Flapp466
         mov       cl,7
Flapp466:add       dh,2

         jmp       short Flappy7

; -----------------------------------------------------------------------------
;        st©°len° Flappyho
; -----------------------------------------------------------------------------

Flappy47:cmp       al," "
         jne       Flappy48

; ------ vyjmut° posledn° st©ely

         push      si
         push      dx
         push      cx

         cmp       byte ptr ds:[StrelF],0
         je        Flapp473
         mov       dl,ds:[StrelF]
         dec       byte ptr ds:[StrelF]
         shl       dl,1                     ; offset v tabulce
         cmp       dl,2*13
         jbe       Flapp471
         mov       dl,2*13
Flapp471:add       dl,24
         mov       dh,4

         mov       si,offset Strely-4
Flapp472:add       si,4
         cmp       dx,ds:[si+1]
         jne       Flapp472

         mov       dx,ds:[PozFlap]
         mov       ch,ds:[FazFlap]
         add       dh,2
         mov       cl,4                     ; dolñ
         cmp       ch,4
         jbe       Flapp473
         sub       dh,2
         add       dl,2
         mov       cl,3                     ; nahoru
         cmp       ch,7
         jbe       Flapp473
         sub       dl,2
         mov       cl,1                     ; vlevo
         cmp       ch,9
         jbe       Flapp473
         add       dl,2
         mov       cl,2                     ; vpravo
Flapp473:mov       ds:[si],cl               ; typ - smàr letu
         mov       ds:[si+1],dx
         mov       byte ptr ds:[si+3],10    ; á°taá krokñ

         pop       cx
         pop       dx
         pop       si

Flappy48:


; ------ zmàna stavu Flappyho

Flappy7: cmp       cl,ds:[FazFlap]          ; je zmàna f†ze Flappyho ?
         jne       Flappy8                  ; je zmàna f†ze
         cmp       dx,ds:[PozFlap]          ; je zmàna pozice Flappyho ?
         jne       Flapp823
         jmp       short Flappy9            ; nen° ani zmàna pozice

Flappy8: push      dx
         mov       dx,ds:[PozFlap]
         call      DispBMaz                 ; vymaz†n° starÇ pozice
         pop       dx
Flapp823:mov       ds:[FazFlap],cl          ; nov† f†ze Flappyho
         mov       ds:[PozFlap],dx          ; nov† pozice Flappyho
         call      DispAFlp                 ; zobrazen° novÇho Flappyho

Flappy9: ret

Flappy   ENDP

; -----------------------------------------------------------------------------
;        seër†n° Flappyho
; -----------------------------------------------------------------------------

Sezrani  PROC      NEAR

         cmp       byte ptr ds:[Sezran],0
         jne       Sezrani1
         mov       byte ptr ds:[Sezran],50  ; p©°znak seër†n° Flappyho
Sezrani1:ret

Sezrani  ENDP
;˛

; -----------------------------------------------------------------------------
;                              obsluha duchñ
; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

Duchy    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava registrñ

         mov       si,offset Duch
         mov       ch,0
         mov       cl,ds:[DuchN]
         mov       al,1
         or        cx,cx
         jnz       Duchy1
         jmp       Duchy9

; ------ parametry

Duchy1: ; and       byte ptr ds:[si],7fh
         mov       bl,ds:[si]               ; f†ze
         and       bl,7fh
         mov       dx,ds:[si+1]             ; pozice ducha
         test      dl,1                     ; lich† pozice ?
         jz        Duchy3                   ; je sud† pozice

; ------ dokonáen° kroku vlevo

         cmp       bl,2                     ; mezikrok vlevo ?
         jne       Duchy2
         dec       dx                       ; sn°ëen° pozice
         call      TestBez                  ; test novÇ pozice
         mov       bl,1
         jnc       Duchy661                 ; nov† pozice je moën†
         add       dl,2                     ; n†vrat pozice vpravo
         jmp       short Duchy661

; ------ dokonáen° kroku vpravo

Duchy2:  inc       dx
         call      TestBez                  ; test pole bez ducha
         mov       bl,3
         jnc       Duchy661                 ; nov† pozice je moën†
         sub       dl,2
         jmp       short Duchy661

; -----------------------------------------------------------------------------
;        honàn° Flappyho
; -----------------------------------------------------------------------------

; ------ test, zda je bl°zko Flappy

Duchy3:  mov       bh,dh                    ; ©†dek
         sub       bh,byte ptr ds:[PozFlap+1] ; rozd°l od ©†dku Flappyho
         cmp       bh,-2
         jl        Duchy30                  ; nen° bl°zko
         cmp       bh,2
         jg        Duchy30                  ; nen° bl°zko
         mov       bh,dl
         sub       bh,byte ptr ds:[PozFlap] ; rozd°l od pozice Flappyho
         cmp       bh,-24
         jl        Duchy30                  ; nen° bl°zko
         cmp       bh,24
         jg        Duchy30                  ; nen° bl°zko

; ------ n†hodnà nech† Flappyho na pokoji

         push      ax
         mov       al,bh
         or        al,al
         jns       Duchy301
         neg       al
Duchy301:cmp       al,4
         jbe       Duchy302
         sub       al,4
         jmp       short Duchy303
Duchy302:cmp       byte ptr ds:[Sezran],0
         jne       Duchy306
         call      Sezrani                  ; seër†n° Flappyho
;         or        bh,bh
;         mov       bl,1
;         jns       Duchy306
;         mov       bl,3
Duchy306:;mov       bh,0
         neg       bh                       ; mus° j°t opaánà
         pop       ax
         jmp       short Duchy308

Duchy303:cmp       dh,byte ptr ds:[PozFlap+1] ; je stejnò ©†dek ?
         jne       Duchy307                 ; nen° stejnò ©†dek
         shr       al,1
         shr       al,1
         shr       al,1

Duchy307:mov       ah,0
         inc       ax
         call      Random
         or        ax,ax
         pop       ax
         jnz       Duchy30

; ------ rozli®en°, kteròm smàrem m† Flappyho honit

Duchy308:or        bh,bh
;         jnz       Duchy305
;         cmp       bl,4
;         jbe       Duchy304
;         mov       bl,3
;Duchy304:dec       bx
;         xor       bl,1
;         inc       bx

Duchy305:jns       Duchy31                  ; je vlevo - krok vlevo
         jmp       short Duchy41

Duchy661:jmp       short Duchy66

; -----------------------------------------------------------------------------
;        krok vlevo
; -----------------------------------------------------------------------------

Duchy30: cmp       bl,1
         jne       Duchy4

; ------ n†hodn† zmàna smàru

         push      ax
         mov       ax,5                     ; pravdàpodobnost zmàny
         call      Random
         or        ax,ax
         pop       ax
         jz        Duchy41                  ; zmàna

; ------ test novÇ pozice vlevo

Duchy31: sub       dl,2                     ; nov† pozice
         call      TestBez                  ; test novÇ pozice bez ducha
         jc        Duchy67                  ; krok nen° moënò
         inc       dx
         mov       bl,2                     ; mezikrok vlevo
Duchy66: jmp       short Duchy6             ; krok je moënò

Duchy67: mov       bl,ds:[si]
         or        bl,80h
         mov       dx,ds:[si+1]
         jmp       short Duchy66

; -----------------------------------------------------------------------------
;        krok vpravo
; -----------------------------------------------------------------------------

Duchy4:  cmp       bl,3
         jne       Duchy5

; ------ n†hodn† zmàna smàru

         push      ax
         mov       ax,5                     ; pravdàpodobnost zmàny
         call      Random
         or        ax,ax
         pop       ax
         jz        Duchy31                  ; zmàna

; ------ test novÇ pozice vpravo

Duchy41: add       dl,2                     ; nov† pozice
         call      TestBez                  ; test novÇ pozice bez ducha
         jc        Duchy67                  ; krok nen° moënò
         dec       dx
         mov       bl,4                     ; mezikrok vpravo
         jmp       short Duchy6             ; krok je moënò

Duchy5:

; ------ nov† pozice

Duchy6:  cmp       bl,ds:[si]
         jne       Duchy7
         cmp       dx,ds:[si+1]
         je        Duchy8
Duchy7:  push      dx
         mov       dx,ds:[si+1]
         call      DispBMaz
         pop       dx
         mov       ds:[si],bl               ; nov† f†ze
         mov       ds:[si+1],dx             ; nov† pozice
         call      DispDuch

; ------ dal®° duch

Duchy8:  inc       al
         add       si,4
         dec       cx
         jz        Duchy9
         jmp       Duchy1

; ------ n†vrat registrñ

Duchy9:  pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Duchy    ENDP

; -----------------------------------------------------------------------------
;                              Obsluha st©el
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------
;˛
Strel    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ ukazatel v tabulce st©el

         mov       al,1                     ; á°slo st©ely
         mov       si,offset Strely         ; tabulka st©el
Strel1:  cmp       al,ds:[StrelN]
         ja        Strel9

; ------ let st©ely

         mov       cl,ds:[si]               ; f†ze
         cmp       cl,0
         je        Strel2                   ; nelet°

         mov       dx,ds:[si+1]             ; pozice st©ely
         call      DispMaz
         sub       dl,2
         cmp       cl,1                     ; vlevo
         je        Strel11
         add       dl,4
         cmp       cl,2                     ; vpravo
         je        Strel11
         sub       dl,2
         sub       dh,2
         cmp       cl,3                     ; nahoru
         je        Strel11
         add       dh,4
Strel11: mov       ds:[si+1],dx
         dec       byte ptr ds:[si+3]       ; á°taá letu
         jnz       Strel12
         mov       byte ptr ds:[si],0       ; stav klidu

Strel12:




Strel2:



; ------ kontrola kolize s Flappym

         mov       dx,ds:[si+1]             ; pozice st©ely
         sub       dl,byte ptr ds:[PozFlap]
         sub       dh,byte ptr ds:[PozFlap+1]
         cmp       dl,4
         jae       Strel6
         cmp       dh,4
         jae       Strel6

; ------ Flappy na®el st©elu

Strel5:  inc       byte ptr ds:[StrelF]     ; zvò®en° poátu st©el Flappyho
         mov       dl,ds:[StrelF]
         shl       dl,1                     ; offset v tabulce
         cmp       dl,2*13
         jbe       Strel52
         mov       dl,2*13
Strel52: add       dl,24
         mov       dh,4
         mov       ds:[si+1],dx             ; nov† pozice st©ely

Strel6:

; ------ zobrazen° st©ely na aktu†ln° pozici (pokud nebyla zru®ena)

         call      DispStrl                 ; zobrazen° st©ely

; ------ dal®° st©ela

Strel8:  add       si,4
         inc       al
         jmp       short Strel1

; ------ n†vrat registrñ

Strel9:  pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Strel    ENDP


; -----------------------------------------------------------------------------
;        rozbit° koule AL
; -----------------------------------------------------------------------------

XKoule   PROC      NEAR

         push      ax
         push      si

; ------ adresa koule

         mov       ah,0
         mov       si,ax
         shl       si,1
         shl       si,1
         add       si,offset Koule-4

; ------ je-li cel† koule 2, jej° rozbit°

         cmp       byte ptr ds:[si],2       ; je cel† zelen† koule ?
         jne       XKoule2                  ; nen° cel† zelen† koule
         inc       byte ptr ds:[si]         ; zaá†tek rozpadu koule
         call      DispKoul                 ; zobrazen° koule

XKoule2: pop       si
         pop       ax
         ret

XKoule   ENDP

; -----------------------------------------------------------------------------
;        posun koule AL o pozici vpravo (CY=nebyl posun)
; -----------------------------------------------------------------------------

RKoule   PROC      NEAR

         push      ax
         push      dx
         push      si

         mov       ah,0
         mov       si,ax
         shl       si,1
         shl       si,1
         add       si,offset Koule-4

         mov       dx,ds:[si+1]
         mov       ah,ds:[si]

; ------ test, zda je nov† pozice moën†

         mov       byte ptr ds:[si+1],-10
         push      dx
         inc       dx
         inc       dx
         call      TestPole
         pop       dx
         mov       ds:[si+1],dl
         jnc       RKoule6                  ; posun je moënò

; ------ koule nelze posunout - rozm†áknut° koule

         cmp       ah,2
         jne       RKoule5
         inc       byte ptr ds:[si]
         call      DispKoul
RKoule5: stc
         jmp       short RKoule9

; ------ posun koule je moënò

RKoule6: call      DispBMaz
         inc       byte ptr ds:[si+1]
         inc       byte ptr ds:[si+1]
         call      DispKoul

; ------ n†vrat registrñ

         clc
RKoule9: pop       si
         pop       dx
         pop       ax
         ret

RKoule   ENDP

; -----------------------------------------------------------------------------
;        posun koule AL o pozici vlevo (CY=nebyl posun)
; -----------------------------------------------------------------------------

LKoule   PROC      NEAR

         push      ax
         push      dx
         push      si

         mov       ah,0
         mov       si,ax
         shl       si,1
         shl       si,1
         add       si,offset Koule-4

         mov       dx,ds:[si+1]
         mov       ah,ds:[si]

; ------ test, zda je nov† pozice moën†

         mov       byte ptr ds:[si+1],-10
         push      dx
         dec       dx
         dec       dx
         call      TestPole
         pop       dx
         mov       ds:[si+1],dl
         jnc       LKoule6                  ; posun je moënò

; ------ koule nelze posunout - rozm†áknut° koule

         cmp       ah,2
         jne       LKoule5
         inc       byte ptr ds:[si]
         call      DispKoul
LKoule5: stc
         jmp       short LKoule9

; ------ posun koule je moënò

LKoule6: call      DispBMaz
         dec       byte ptr ds:[si+1]
         dec       byte ptr ds:[si+1]
         call      DispKoul

; ------ n†vrat registrñ

         clc
LKoule9: pop       si
         pop       dx
         pop       ax
         ret

LKoule   ENDP

; -----------------------------------------------------------------------------
;        obsluha koul°
; -----------------------------------------------------------------------------

PadKoul  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

         mov       al,1
         mov       si,offset Koule

; ------ zvò®en° f†ze rozpadu

PadKoul2:mov       ah,ds:[si]
         mov       dx,ds:[si+1]
         cmp       ah,2
         jbe       PadKoul5                 ; nen° rozpad
         cmp       ah,5
         jae       PadKoul3                 ; jsou jië v®echny f†ze rozpadu
         inc       byte ptr ds:[si]         ; zvò®en° f†ze rozpadu
         call      DispKoul                 ; novÇ zobrazen° koule
         jmp       short PadKoul5

; ------ vypu®tàn° koule po rozpadu

PadKoul3:call      DispBMaz                 ; vymaz†n° koule
         push      si
         push      ax
PadKoul4:mov       ah,ds:[si+4]
         mov       dx,ds:[si+5]
         mov       ds:[si],ah
         mov       ds:[si+1],dx
         inc       al
         add       si,4
         cmp       al,ds:[KouleN]
         jbe       PadKoul4
         pop       ax
         pop       si
         dec       byte ptr ds:[KouleN]
         jmp       short PadKoul8

; ------ pad†n° koule

PadKoul5:mov       ah,dh                    ; £schova ©†dku
         add       dh,2                     ; pokusn† nov† pozice
         mov       byte ptr ds:[si+2],-10
         call      TestPole                 ; test novÇho pole
         mov       ds:[si+2],ah
         jc        PadKoul7                 ; koule nepad†
         mov       ds:[si+2],dh             ; novò ©†dek
         sub       dh,2
         call      DispBMaz                 ; maz†n° starÇ koule
         call      DispKoul                 ; zobrazen° novÇ pozice koule

; ------ p©°prava pro dal®° kouli

PadKoul7:add       si,4
         inc       ax
PadKoul8:cmp       al,ds:[KouleN]
         jbe       PadKoul2

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       ax
         ret

PadKoul  ENDP

; -----------------------------------------------------------------------------
;        nalezen° koule s pozic° DX (CY=nenalezena)
; -----------------------------------------------------------------------------

SrcKoul  PROC      NEAR

         push      si
         mov       al,1
         mov       si,offset Koule
SrcKoul1:cmp       dx,ds:[si+1]
         je        SrcKoul2
         add       si,4
         inc       ax
         cmp       al,ds:[KouleN]
         jbe       SrcKoul1
         stc
SrcKoul2:pop       si
         ret

SrcKoul  ENDP

; -----------------------------------------------------------------------------
;                        Inicializace aktivn° scÇny
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

InitScen PROC      NEAR


; ------ zobrazen° horn°ho okraje

         mov       dh,0
         call      DispRCih

; ------ zobrazen° r†mu textñ

         mov       dh,2
InitScn3:mov       dl,0
         call      DispCih
         mov       dl,2+20
         call      DispCih
         mov       dl,2+20+2+28
         call      DispCih
         mov       dl,2+20+2+28+2+24
         call      DispCih
         add       dh,2
         cmp       dh,6
         jne       InitScn3

; ------ vymaz†n° hrac° plochy

         mov       dh,6
         mov       cx,22
InitScn4:call      DispRCih                 ; zobrazen° ©ady cihel
         add       dh,2
         loop      InitScn4

; ------ zobrazen° zbòvaj°c°ch Flappy

         mov       dx,202h
         mov       cx,5
         mov       ah,ds:[Zivoty]
InitScn5:mov       al,1
         dec       ah
         jns       InitScn6
         call      DispBMaz
         jmp       short InitScn7
InitScn6:call      DispFlap
InitScn7:add       dl,4
         loop      InitScn5

; ------ zobrazen° sk¢re

         call      DispSkor                 ; zobrazen° sk¢re

; ------ zobrazen° áasu

         call      DispTime                 ; zobrazen° áasu

; ------ zobrazen° aut. pr†v

         mov       si,offset TxtLic
         mov       cx,offset(TxtLic0-TxtLic)
         mov       dx,4*256+ 2+20+2+28+2
         mov       ah,11
         call      DispTxt

; ------ zobrazen° á°sla scÇny

         mov       si,offset TxtScen
         mov       cx,offset(TxtScen0-TxtScen)
         mov       ah,14
         mov       dx,28*256+30
         call      DispTxt
         mov       bx,ds:[Scena]
         mov       ah,15
         call      DispNSc

; ------ nalezen° definice scÇny

         mov       si,offset Scena1
         mov       cx,ds:[Scena]            ; scÇna
         dec       cx
         jz        InitScn9
InitScn8:add       si,ds:[si]
         loop      InitScn8
InitScn9:
         call      GenPole

         mov       cx,400
         call      Cekej

         ret

InitScen ENDP

; -----------------------------------------------------------------------------
;                        Generov†n° pole scÇny
; -----------------------------------------------------------------------------
; VSTUP: SI=definice scÇny
;        DS=datovò segment
; -----------------------------------------------------------------------------

GenPole  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ dek¢dov†n° cihel pole

         push      ds
         pop       es
         mov       di,offset Pole
         mov       bx,10                    ; poáet ©†dkñ
         cld
         inc       si
         inc       si

; ------ naáten° masky jednoho ©†dku

GenPole1:lodsb
         mov       dh,al
         lodsb
         mov       dl,al
         lodsb
         mov       ah,al
         mov       cx,19                    ; poáet bitñ

; ------ rozli®en° jednoho pole

GenPole2:mov       al,0
         rcl       ah,1
         rcl       dx,1
         rcl       al,1

; ------ uloëen° definice pole

         mov       es:[di+38],al
         mov       es:[di+38+1],al
         stosb
         stosb

; ------ dal®° prvek

         loop      GenPole2

; ------ dal®° ©†dek

         add       di,38
         dec       bx
         jnz       GenPole1

; ------ modr† cihla

         lodsw
         mov       ds:[Modra],ax            ; sou©adnice modrÇ cihly

; ------ definice koul°

         lodsb                              ; poáet koul°
         mov       ds:[KouleN],al           ; poáet koul°
         mov       cl,al                    ; poáet koul°
         mov       ch,0
         mov       al,1                     ; typ = modr† koule
         mov       di,offset Koule          ; definián° tabulka koul°
GenPole3:stosb                              ; typ koule
         movsw                              ; sou©adnice koule
         stosb                              ; 1 bajt rezerva
         mov       al,2                     ; dal®° bude hnàd† koule
         loop      GenPole3                 ; dal®° koule

; ------ definice duchñ

         lodsb                              ; poáet duchñ
         mov       ds:[DuchN],al            ; poáet duchñ
         mov       cl,al                    ; poáet duchñ
         mov       di,offset Duch           ; definián° tabulka duchñ
         jcxz      GenPole5
GenPole4:mov       al,1                     ; typ
         stosb                              ; typ ducha
         movsw                              ; sou©adnice ducha
         mov       al,0
         stosb                              ; á°taá sp†nku
         loop      GenPole4                 ; dal®° duch

; ------ definice st©el

GenPole5:mov       byte ptr ds:[StrelF],0   ; poáet st©el Flappyho
         lodsb                              ; poáet st©el
         mov       ds:[StrelN],al           ; poáet st©el
         mov       cl,al                    ; poáet st©el
         mov       di,offset Strely         ; definián° tabulka st©el
         jcxz      GenPole7
GenPole6:mov       al,0                     ; typ - stoj° (pad†)
         stosb                              ; typ st©ely
         movsw                              ; sou©adnice st©ely
         mov       al,0
         stosb                              ; á°taá letu
         loop      GenPole6                 ; dal®° st©ela

GenPole7:








; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

GenPole  ENDP

; -----------------------------------------------------------------------------
;                      Zobrazen° pole
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispPole PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       si,offset Pole
         mov       dh,8                     ; poá†teán° ©†dek
DispPol1:mov       dl,2                     ; poá†teán° pozice
         mov       cx,38                    ; poáet pozic na ©†dek
DispPol2:cld
         lodsb
         or        al,al
         jnz       DispPol3

         call      DispMaz
         jmp       short DispPol8

DispPol3:dec       al
         jnz       DispPol4

         call      DispCih                  ; zobrazen° cihly


DispPol4:

DispPol8:inc       dl
         inc       dl
         loop      DispPol2
         inc       dh
         inc       dh
         cmp       dh,48
         jne       DispPol1

; ------ zobrazen° modrÇ cihly

         mov       dx,ds:[Modra]
         mov       ah,1                     ; barva
         mov       al,0fh                   ; roviny
         mov       si,offset ObrCih         ; obr†zek
         call      DispPic                  ; zobrazen° modrÇ cihly
         add       dl,2
         call      DispPic

; ------ zobrazen° koul°

         mov       al,ds:[KouleN]           ; poáet koul°
DispPl91:call      DispKoul                 ; zobrazen° koule á°slo AL
         dec       al
         jnz       DispPl91

; ------ zobrazen° duchñ

         mov       al,ds:[DuchN]            ; poáet duchñ
         cmp       al,0
         je        DispPl93
DispPl92:call      DispDuch
         dec       al
         jnz       DispPl92

; ------ zobrazen° st©el

DispPl93:mov       al,ds:[StrelN]           ; poáet st©el
         cmp       al,0
         je        DispPl95
DispPl94:call      DispStrl
         dec       al
         jnz       DispPl94


DispPl95:

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPole ENDP

; -----------------------------------------------------------------------------
;        zobrazen° koule AL
; -----------------------------------------------------------------------------

DispKoul PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ nalezen° definice koule AL

         mov       ah,0
         shl       ax,1
         shl       ax,1
         mov       si,ax
         add       si,offset Koule - 4      ; adresa v tabulce koul°
         mov       al,ds:[si]               ; typ koule
         mov       dx,ds:[si+1]             ; sou©adnice koule

; ------ adresa obr†zku koule

         dec       ax
         mov       ah,4*28*2
         mul       ah
         shl       ax,1
         mov       si,ax
         add       si,offset ObrKoule       ; adresa obr†zku koule

; ------ zobrazen° koule

         call      Picture                  ; zobrazen° koule

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       ax
         ret

DispKoul ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ducha AL
; -----------------------------------------------------------------------------

DispDuch PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ nalezen° definice ducha AL

         mov       ah,0
         shl       ax,1
         shl       ax,1
         mov       si,ax
         add       si,offset Duch - 4       ; adresa v tabulce duchñ
         mov       al,ds:[si]               ; typ ducha
         test      al,80h
         jz        DispDch2
         xor       al,2
         and       al,7fh
DispDch2:mov       dx,ds:[si+1]             ; sou©adnice ducha

; ------ adresa obr†zku ducha

         dec       ax
         mov       ah,4*28*2
         mul       ah
         shl       ax,1
         mov       si,ax
         add       si,offset ObrDuch        ; adresa obr†zku ducha

; ------ zobrazen° ducha

         call      Picture                  ; zobrazen° ducha

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       ax
         ret

DispDuch ENDP

; -----------------------------------------------------------------------------
;        zobrazen° st©ely AL
; -----------------------------------------------------------------------------

DispStrl PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si

; ------ nalezen° definice st©ely AL

         mov       ah,0
         shl       ax,1
         shl       ax,1
         mov       si,ax
         add       si,offset Strely - 4     ; adresa v tabulce st©el
         mov       dx,ds:[si+1]             ; sou©adnice st©ely

; ------ zobrazen° st©ely

         mov       si,offset ObrStrl
         mov       ah,1011b                 ; barva
         mov       al,1011b                 ; roviny
         call      DispPic                  ; zobrazen° st©ely - jasov†

         add       si,2*14
         mov       ah,0100b                 ; barva
         mov       al,0100b                 ; roviny
         call      DispPic                  ; zobrazen° st©ely - áerven†

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       ax
         ret

DispStrl ENDP



; -----------------------------------------------------------------------------
;        test pole (2x4) vertik†lnà, zda je volnÇ (cihla nebo koule)
; -----------------------------------------------------------------------------

TestVPol PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si

; ------ test, zda je na pozici cihla

         call      TestCih
         jc        TestVPl9
         add       dh,2
         call      TestCih
         jc        TestVPl9
         sub       dh,2

; ------ test, zda je na pozici koule

         mov       bx,dx
         sub       dh,3                     ; minim†ln° ©†dek
         sub       dl,3                     ; minim†ln° pozice
         add       bh,4                     ; maxim†ln° ©†dek
         add       bl,2                     ; maxim†ln° pozice
         mov       si,offset Koule
         mov       cl,ds:[KouleN]
         mov       ch,0
TestVPl3:cmp       ds:[si+1],dl
         jb        TestVPl4
         cmp       ds:[si+1],bl
         jae       TestVPl4
         cmp       ds:[si+2],dh
         jb        TestVPl4
         cmp       ds:[si+2],bh
         jb        TestVPl9                 ; je tam koule
TestVPl4:add       si,4
         loop      TestVPl3                 ; dal®° koule

         clc


TestVPl9:pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

TestVPol ENDP

; -----------------------------------------------------------------------------
;        test pole (4x2) horizont†lnà, zda je volnÇ (cihla nebo koule)
; -----------------------------------------------------------------------------

TestHPol PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si

; ------ test, zda je na pozici cihla

         call      TestCih
         jc        TestHPl9
         add       dl,2
         call      TestCih
         jc        TestHPl9
         sub       dl,2

; ------ test, zda je na pozici koule

         mov       bx,dx
         sub       dh,3                     ; minim†ln° ©†dek
         sub       dl,3                     ; minim†ln° pozice
         add       bh,2                     ; maxim†ln° ©†dek
         add       bl,4                     ; maxim†ln° pozice
         mov       si,offset Koule
         mov       cl,ds:[KouleN]
         mov       ch,0
TestHPl3:cmp       ds:[si+1],dl
         jb        TestHPl4
         cmp       ds:[si+1],bl
         jae       TestHPl4
         cmp       ds:[si+2],dh
         jb        TestHPl4
         cmp       ds:[si+2],bh
         jb        TestHPl9                 ; je tam koule
TestHPl4:add       si,4
         loop      TestHPl3                 ; dal®° koule

         clc

TestHPl9:pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

TestHPol ENDP

; -----------------------------------------------------------------------------
;        test pole 4x4 bez testovanÇho p©edmàtu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice
;        AL=á°slo
; -----------------------------------------------------------------------------

TestBez  PROC      NEAR

         push      word ptr ds:[si+1]
         mov       byte ptr ds:[si+1],-10
         call      TestPole                 ; je nov† pozice voln† ?
         pop       word ptr ds:[si+1]
         ret

TestBez  ENDP

; -----------------------------------------------------------------------------
;        test pole (4x4), zda je volnÇ (cihla nebo koule)
; -----------------------------------------------------------------------------

TestPole PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si

; ------ test, zda je na pozici cihla

         call      TestCih
         jc        TestPol9
         add       dl,2
         call      TestCih
         jc        TestPol9
         add       dh,2
         call      TestCih
         jc        TestPol9
         sub       dl,2
         call      TestCih
         jc        TestPol9
         sub       dh,2

; ------ test, zda je na pozici koule

         mov       bx,dx
         sub       dh,3                     ; minim†ln° ©†dek
         sub       dl,3                     ; minim†ln° pozice
         add       bh,4                     ; maxim†ln° ©†dek
         add       bl,4                     ; maxim†ln° pozice
         mov       si,offset Koule
         mov       cl,ds:[KouleN]
         mov       ch,0
TestPol3:cmp       ds:[si+1],dl
         jb        TestPol4
         cmp       ds:[si+1],bl
         jae       TestPol4
         cmp       ds:[si+2],dh
         jb        TestPol4
         cmp       ds:[si+2],bh
         jb        TestPol9                 ; je tam koule
TestPol4:add       si,4
         loop      TestPol3                 ; dal®° koule

         clc


TestPol9:pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

TestPole ENDP

; -----------------------------------------------------------------------------
;        test, zda je pozice voln† (CY=je cihla)
; -----------------------------------------------------------------------------

TestCih  PROC      NEAR

         push      ax
         push      bx

; ------ kontrola p©ekroáen° okrajñ pole

         mov       bx,dx
         sub       bl,2
         jc        TestCih4
         cmp       bl,76
         jae       TestCih4
         sub       bh,8
         jc        TestCih4
         cmp       bh,40
         jae       TestCih4

; ------ kontrola aktu†ln° pozice

         shr       bl,1
         shr       bh,1
         mov       al,38                    ; poáet pozic na ©†dek
         mul       bh                       ; p©epoáet ©†dku na offset
         add       al,bl                    ; p©iáten° pozice
         adc       ah,0
         mov       bx,ax                    ; offset v poli
         cmp       byte ptr ds:[Pole+bx],0
         je        TestCih5
;         jne       TestCih4
;
;; ------ pro lichou pozici kontrola dal®° pozice
;
;         test      dl,1
;         jz        TestCih2
;         cmp       byte ptr ds:[Pole+bx+1],0
;         jne       TestCih4
;
;; ------ pro lichò ©†dek kontrola dal®°ho ©†dku
;
;TestCih2:test      dh,1
;         jz        TestCih5
;         cmp       byte ptr ds:[Pole+bx+38],0
;         je        TestCih5

TestCih4:stc                                ; pozice nen° voln†

TestCih5:pop       bx
         pop       ax
         ret

TestCih  ENDP

; -----------------------------------------------------------------------------
;                            Novò Flappy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

NovFlap  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         dec       byte ptr ds:[Zivoty]     ; sn°ëen° á°taáe ëivotñ
         jns       NovFlap0
         inc       byte ptr ds:[Zivoty]

; ------ otev©en° cihly pod Flappym

NovFlap0:mov       dx,602h
         call      DispBMaz

; ------ pad†n° Flappyho

         mov       dx,202h
         mov       bx,7
         mov       cx,75
NovFlap1:mov       al,2
         call      DispFlap
         call      Cekej
         call      DispBMaz
         inc       dh
         dec       bx
         jnz       NovFlap1
         dec       dh
         mov       al,1
         call      DispFlap

; ------ obnoven° cihly

         mov       dx,602h
         call      DispCih
         add       dl,2
         call      DispCih
         mov       cx,100
         call      Cekej

; ------ p©°chod ostatn°ch Flappy

         cmp       byte ptr ds:[Zivoty],0
         je        NovFlap4

         mov       dx,206h
         mov       al,8
         call      NovFlp0
         mov       cx,100
         call      Cekej
         mov       bx,2

NovFlap2:mov       al,0
         call      NovFlp0
         dec       dx
         mov       al,9
         call      NovFlp0
         call      Cekej

         mov       al,0
         call      NovFlp0
         dec       dx
         mov       al,8
         call      NovFlp0
         call      Cekej

         dec       bx
         jnz       NovFlap2

; ------ otoáen° Flappy spr†vnà

         mov       ah,ds:[Zivoty]
         mov       dx,202h
         mov       al,1
NovFlap3:call      DispFlap
         mov       cx,200
         call      Cekej
         add       dl,4
         dec       ah
         jnz       NovFlap3

NovFlap4:

         mov       byte ptr ds:[FazFlap],1
         mov       word ptr ds:[PozFlap],802h

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NovFlap  ENDP

NovFlp0: push      dx
         push      cx
         mov       ah,ds:[Zivoty]
         mov       cx,4
NovFlp01:dec       ah
         jns       NovFlp02
NovFlp04:call      DispBMaz
         jmp       short NovFlp03
NovFlp02:cmp       al,0
         jz        NovFlp04
         call      DispFlap
NovFlp03:add       dl,4
         loop      NovFlp01
         pop       cx
         pop       dx
         ret

; -----------------------------------------------------------------------------
;                        Zobrazen° sk¢re
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispSkor PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° £vodn°ho textu sk¢re

         mov       si,offset TxtSkore
         mov       cx,offset(TxtSkor0-TxtSkore)
         mov       ah,12
         mov       dx,2*256 + 2+20+2
         call      DispTxt

; ------ zobrazen° sk¢re

         mov       bx,ds:[Skore]
         mov       ah,15
         call      DispNum
         mov       al,"0"
         call      DispCh
         mov       al," "
         call      DispCh

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispSkor ENDP

; -----------------------------------------------------------------------------
;                        Zobrazen° áasu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

DispTime PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ zobrazen° £vodn°ho textu áasu

         mov       si,offset TxtTime
         mov       cx,offset(TxtTime0-TxtTime)
         mov       ah,12
         mov       dx,2*256 + 2+20+2+28+2
         call      DispTxt

; ------ zobrazen° áasu

         mov       bx,ds:[Time]
         shr       bx,1
         mov       ah,15
         mov       al,"0"
         call      DispCh
         call      DispNum
         mov       al," "
         call      DispCh

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTime ENDP

; -----------------------------------------------------------------------------
;                         Zobrazen° ©ady cihel
; -----------------------------------------------------------------------------
; VSTUP: DH=©†dek
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispRCih PROC      NEAR

         push      dx
         push      cx
         mov       dl,0
         mov       cx,40
DispRCh1:call      DispCih
         inc       dl
         inc       dl
         loop      DispRCh1
         pop       cx
         pop       dx
         ret

DispRCih ENDP

; -----------------------------------------------------------------------------
;                            Zobrazen° cihly
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice (0..79)
;        DH=©†dek (0..49)
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispCih  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si

; ------ zobrazen° cihly

         mov       ah,4                     ; barva
         mov       al,0fh                   ; roviny
         mov       si,offset ObrCih         ; obr†zek
         call      DispPic                  ; zobrazen° cihly

; ------ n†vrat registrñ

         pop       si
         pop       ax
         ret

DispCih  ENDP

; -----------------------------------------------------------------------------
;                   zobrazen° aktivn°ho stavu Flappyho
; -----------------------------------------------------------------------------

DispAFlp PROC      NEAR

         push      ax
         push      dx
         mov       al,ds:[FazFlap]
         mov       dx,ds:[PozFlap]
         call      DispFlap
         pop       dx
         pop       ax
         ret

DispAFlp ENDP

; -----------------------------------------------------------------------------
;                          Zobrazen° Flappyho
; -----------------------------------------------------------------------------
; VSTUP: AL=f†ze pohybu
;        DL=pozice (0..79)
;        DH=©†dek (0..49)
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispFlap PROC      NEAR

         push      ax
;         push      bx
         push      si
;         mov       bl,al
;         and       al,7fh
;
;         or        al,al
;         jnz       DispFlp4
;         call      DispBMaz
;         jmp       short DispFlp9

DispFlp4:mov       si,offset ObrFlap
         dec       ax
         mov       ah,2*4*28
         mul       ah
         shl       ax,1
         add       si,ax
         call      Picture

DispFlp9:
         pop       si
;         pop       bx
         pop       ax
         ret

DispFlap ENDP


; *****************************************************************************
;
;                   Univerz†ln° obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                              GetAdr
;           p©epoáet sou©adnic na adresu ve videopamàti
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice (0..79) (celkem 80 pozic po 8 bodech)
;        DH=©†dek (0..49) (celkem 50 ©†dkñ po 7 link†ch)
; VùSTUP:ES:DI=adresa ve videopamàti
; -----------------------------------------------------------------------------

GetAdr   PROC      NEAR

         push      ax
         mov       al,80*7/4                ; poáet bajtñ na ©†dek/4
         mul       dh                       ; p©epoáet ©†dku
         shl       ax,1
         shl       ax,1                     ; p©epoáet ©†dku na offset
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos
         mov       di,ax                    ; adresa ve videopamàti
         mov       es,ds:[SegVRAM]          ; segment videopamàti
         pop       ax
         ret

GetAdr   ENDP

; -----------------------------------------------------------------------------
;                   Vymaz†n° velkÇho pole 32 bodñ * 28 linek
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice
;        DH=©†dek
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispBMaz PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es
         call      GetAdr                   ; poskytnut° adresy ve videopamàti

; ------ nastaven° v®ech rovin k z†pisu

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; z†pisovÇ roviny

; ------ vymaz†n° obr†zku

         mov       cx,28                    ; poáet linek
         cld
         xor       ax,ax                    ; ukl†dac° slovo
DispBMz3:stosw                              ; uloëen° slova
         stosw
         add       di,80-4                  ; adresa dal®° linky
         loop      DispBMz3

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DispBMaz ENDP



; -----------------------------------------------------------------------------
;                   Vymaz†n° pole
; -----------------------------------------------------------------------------
; VSTUP: DL=pozice
;        DH=©†dek
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispMaz  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di
         push      es
         call      GetAdr                   ; poskytnut° adresy ve videopamàti

; ------ nastaven° v®ech rovin k z†pisu

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; z†pisovÇ roviny

; ------ vymaz†n° obr†zku

         mov       cx,14                    ; poáet linek
         cld
         xor       ax,ax                    ; ukl†dac° slovo
DispMaz3:stosw                              ; uloëen° slova
         add       di,80-2                  ; adresa dal®° linky
         loop      DispMaz3

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

DispMaz  ENDP

; -----------------------------------------------------------------------------
;                 Zobrazen° obr†zku 32(®°©ka)*28(vò®ka) bodñ
; -----------------------------------------------------------------------------
; VSTUP: SI=obr†zek k zobrazen° (4 roviny, 32*28 bodñ)
;        DL=pozice k zobrazen° (0 aë 79)
;        DH=©†dek k zobrazen° (0 aë 49)
;        DS=datovò segment
; VùSTUP:SI=adresa dal®°ho obr†zku
; -----------------------------------------------------------------------------

Picture  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         call      GetAdr                   ; poskytnut° adresy ve videopamàti

; ------ p©°prava registrñ

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       bl,1                     ; ukazatel rovin
         cld

; ------ nastaven° poëadovanÇ roviny

Picture1:mov       al,bl                    ; poëadovan† rovina
         out       dx,al                    ; nastaven° roviny

; ------ zobrazen° jednÇ roviny obr†zku

         mov       cx,28                    ; poáet linek
Picture2:movsw
         movsw
         add       di,80-4                  ; adresa dal®° linky
         loop      Picture2

; ------ p©°prava pro dal®° rovinu

         sub       di,28*80
         shl       bl,1                     ; dal®° rovina
         cmp       bl,10000b                ; jsou jië v®echny roviny ?
         jne       Picture1                 ; dal®° rovina

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Picture  ENDP



;; -----------------------------------------------------------------------------
;;          Obsluha zobrazen° velkÇho obr†zku v p©echodu - jedna barva
;; -----------------------------------------------------------------------------
;; VSTUP: AH=barva
;;        AL=roviny
;;        SI=obr†zek k zobrazen° (32*28 bodñ)
;;        DL=pozice k zobrazen°
;;        DH=©†dek k zobrazen°
;;        DS=datovò segment
;; VùSTUP:SI=adresa dal®°ho obr†zku
;; -----------------------------------------------------------------------------
;
;DispSPic PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      es
;         call      GetAdr                   ; poskytnut° adresy ve videopamàti
;
;; ------ nastaven° poëadovanòch rovin k z†pisu
;
;         push      ax
;         mov       dx,3c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         pop       ax
;         out       dx,al                    ; z†pisovÇ roviny
;
;; ------ nastaven° implicitn° áernÇ barvy
;
;         mov       dx,3ceh
;         mov       al,0                     ; registr 0
;         out       dx,al                    ; volba registru 0
;         inc       dx
;         out       dx,al                    ; implicitn° barva áern†
;         dec       dx
;
;; ------ nastaven° barvy
;
;         mov       al,1                     ; registr 1
;         out       dx,al                    ; volba registru 1
;         mov       al,ah                    ; poëadovan† barva
;         not       al
;         inc       dx
;         out       dx,al                    ; volba rovin
;
;; ------ zobrazen° obr†zku
;
;         mov       cx,28                    ; poáet linek
;         cld
;DispSPc3:xor       al,al
;         stosb
;         lodsw
;         mov       dx,ax
;         lodsw
;         xchg      ah,al
;         stosw
;         mov       ax,dx
;         xchg      ah,al
;         stosw
;         xor       al,al
;         stosb
;         add       di,80-6                  ; adresa dal®° linky
;         loop      DispSPc3
;
;; ------ n†vrat videoregistrñ
;
;         mov       al,0                     ; v®echny roviny podle dat
;         out       dx,al                    ; volba rovin
;
;; ------ n†vrat registrñ
;
;         pop       es
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;DispSPic ENDP
;
;
;; -----------------------------------------------------------------------------
;;               Obsluha zobrazen° velkÇho obr†zku - jedna barva
;; -----------------------------------------------------------------------------
;; VSTUP: AH=barva
;;        AL=roviny
;;        SI=obr†zek k zobrazen° (32*28 bodñ)
;;        DL=pozice k zobrazen°
;;        DH=©†dek k zobrazen°
;;        DS=datovò segment
;; VùSTUP:SI=adresa dal®°ho obr†zku
;; -----------------------------------------------------------------------------
;
;DispBPic PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      es
;         call      GetAdr                   ; poskytnut° adresy ve videopamàti
;
;; ------ nastaven° poëadovanòch rovin k z†pisu
;
;         push      ax
;         mov       dx,3c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         pop       ax
;         out       dx,al                    ; z†pisovÇ roviny
;
;; ------ nastaven° implicitn° áernÇ barvy
;
;         mov       dx,3ceh
;         mov       al,0                     ; registr 0
;         out       dx,al                    ; volba registru 0
;         inc       dx
;         out       dx,al                    ; implicitn° barva áern†
;         dec       dx
;
;; ------ nastaven° barvy
;
;         mov       al,1                     ; registr 1
;         out       dx,al                    ; volba registru 1
;         mov       al,ah                    ; poëadovan† barva
;         not       al
;         inc       dx
;         out       dx,al                    ; volba rovin
;
;; ------ zobrazen° obr†zku
;
;         mov       cx,28                    ; poáet linek
;         cld
;DispBPc3:lodsw
;         mov       dx,ax
;         lodsw
;         xchg      ah,al
;         stosw
;         mov       ax,dx
;         xchg      ah,al
;         stosw
;         add       di,80-4                  ; adresa dal®° linky
;         loop      DispBPc3
;
;; ------ n†vrat videoregistrñ
;
;         mov       al,0                     ; v®echny roviny podle dat
;         out       dx,al                    ; volba rovin
;
;; ------ n†vrat registrñ
;
;         pop       es
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;DispBPic ENDP

; -----------------------------------------------------------------------------
;                  Obsluha zobrazen° obr†zku - jedna barva
; -----------------------------------------------------------------------------
; VSTUP: AH=barva
;        AL=roviny
;        SI=obr†zek k zobrazen° (16*14 bodñ)
;        DL=pozice k zobrazen°
;        DH=©†dek k zobrazen°
;        DS=datovò segment
; -----------------------------------------------------------------------------

DispPic  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         call      GetAdr                   ; poskytnut° adresy ve videopamàti

; ------ nastaven° poëadovanòch rovin k z†pisu

         push      ax
         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         pop       ax
         out       dx,al                    ; z†pisovÇ roviny

; ------ nastaven° implicitn° áernÇ barvy

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         out       dx,al                    ; implicitn° barva áern†
         dec       dx

; ------ nastaven° barvy

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,ah                    ; poëadovan† barva
         not       al
         inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen° obr†zku

         mov       cx,14                    ; poáet linek
         cld
DispPic3:movsw                              ; p©enos linky
         add       di,80-2                  ; adresa dal®° linky
         loop      DispPic3

; ------ n†vrat videoregistrñ

         mov       al,0                     ; v®echny roviny podle dat
         out       dx,al                    ; volba rovin

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPic  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla scÇny (3 pozice)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        BX=á°slo scÇny k zobrazen°
;        DL=poá†teán° pozice
;        DH=©†dek
;        DS=datovò segment
; VùSTUP:DL=nov† pozice
; -----------------------------------------------------------------------------

DispNSc  PROC      NEAR

; ------ £schova registrñ

         add       dl,6
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp

         mov       bp,10
         mov       ch,ah
         mov       cl,3

DispNSc1:push      dx
         xor       dx,dx
         mov       ax,bx                    ; á°slo
         div       bp                       ; vydàlen° nië®°ho slova
         mov       bx,ax                    ; novÇ á°slo
         mov       ax,dx                    ; zbytek dàlen°
         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,ch                    ; barva textu
         pop       dx
         sub       dl,2                     ; posun ukazatele
         call      DispCh                   ; zobrazen° á°slice
         sub       dl,2
         dec       cl
         jz        DispNSc4

         or        bx,bx
         jnz       DispNSc1                 ; zobrazen° dal®°ho á°sla

         mov       al," "
DispNSc2:sub       dl,2
         call      DispCh
         sub       dl,2
         dec       cl
         jnz       DispNSc2

; ------ n†vrat registrñ

DispNSc4:pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNSc  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla (5 m°st)
; -----------------------------------------------------------------------------
; VSTUP: AH=barva textu
;        BX=á°slo k zobrazen°
;        DL=poá†teán° pozice
;        DH=©†dek
;        DS=datovò segment
; VùSTUP:DL=nov† pozice
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registrñ

         add       dl,10
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp

         mov       bp,10
         mov       ch,ah
         mov       cl,5

DispNum1:push      dx
         xor       dx,dx
         mov       ax,bx                    ; á°slo
         div       bp                       ; vydàlen° nië®°ho slova
         mov       bx,ax                    ; novÇ á°slo
         mov       ax,dx                    ; zbytek dàlen°
         add       al,"0"                   ; p©evod na znak ASCII
         mov       ah,ch                    ; barva textu
         pop       dx
         sub       dl,2                     ; posun ukazatele
         call      DispCh                   ; zobrazen° á°slice
         sub       dl,2
         dec       cl
         jnz       DispNum1                 ; zobrazen° dal®°ho á°sla

; ------ n†vrat registrñ

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° textu
; -----------------------------------------------------------------------------
; VSTUP: AH=barva
;        CX=poáet znakñ textu k zobrazen°
;        SI=text k zobrazen°
;        DL=pozice
;        DH=©†dek
;        DS=datovò segment
; VùSTUP:SI=adresa n†sleduj°c°ho textu
;        DL=nov† pozice
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ zobrazen° znaku

DispTxt1:cld
         lodsb                              ; naáten° bajtu textu
         call      DispCh                   ; zobrazen° znaku
         loop      DispTxt1

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho znaku
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k zobrazen°
;        AH=barva znaku
;        DL=pozice
;        DH=©†dek
;        DS=datovò segment
; VùSTUP:DL=nov† pozice
; -----------------------------------------------------------------------------

DispCh   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         call      GetAdr                   ; adresa ve videopamàti
         mov       ch,ah                    ; barva

; ------ adresa znaku v tabulce fontñ

         sub       al," "                   ; znak v tabulce relativnà
         xor       ah,ah                    ; AX = znak
         mov       si,ax                    ; znak
         shl       si,1                     ; znak * 2
         shl       si,1                     ; znak * 4
         shl       si,1                     ; znak * 8
         sub       si,ax                    ; znak * 7
         shl       si,1                     ; znak * 14
         add       si,offset Font           ; adresa znaku
         cld

;         cmp       byte ptr ds:[ParHerc],0
;         je        DispCh0
;
;; ------ zobrazen° znaku
;
;         call      KorRAM
;
;         mov       ah,ch
;         mov       cx,14                    ; poáet linek znaku
;
;         cmp       ah,2
;         je        DispCh4
;         cmp       ah,7
;         jne       DispCh7
;
;DispCh4: lodsb                              ; bajt znaku
;         or        es:[di],al
;         add       di,2000h
;         jns       DispCh5
;         and       di,7fffh
;         add       di,80                    ; adresa dal®° linky znaku
;DispCh5: loop      DispCh4                  ; zobrazen° dal®° linky znaku
;         jmp       short DispCh9
;
;DispCh7: lodsb                              ; bajt znaku
;         not       al
;         and       es:[di],al
;         add       di,2000h
;         jns       DispCh8
;         and       di,7fffh
;         add       di,80                    ; adresa dal®° linky znaku
;DispCh8: loop      DispCh7                  ; zobrazen° dal®° linky znaku
;         jmp       short DispCh9
;

; ------ nastaven° z†pisu do v®ech rovin

DispCh0: mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° implicitn° áernÇ barvy

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,0                     ; áern† barva jako podklad
         out       dx,al                    ; nastaven° barvy znaku
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,ch                    ; poëadovan† barva
         not       al
         inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen° znaku

         mov       cx,14                    ; poáet linek znaku
         cld
DispCh1: lodsb                              ; bajt znaku
         mov       bl,al

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         shr       bl,1
         rcr       ax,1
         sar       ax,1

         xchg      ah,al
         stosw
         add       di,80-2                  ; adresa dal®° linky znaku
         loop      DispCh1                  ; zobrazen° dal®° linky znaku

; ------ n†vrat videoregistrñ

         mov       al,0                     ; v®echny roviny podle dat
         out       dx,al                    ; volba rovin

; ------ n†vrat registrñ

DispCh9: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         add       dl,2
         ret

DispCh   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° obdÇln°ku
; -----------------------------------------------------------------------------
; VSTUP: AH=barva obdÇln°ku
;        DI=offset ve videopamàti
;        BX=poáet linek obÇln°ku
;        CX=®°©ka obdÇln°ku v bajtech
; -----------------------------------------------------------------------------

DispBox  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ k zobrazen°

         mov       es,ds:[SegVRAM]          ; segment videopamàti
         cld
         sti

         cmp       byte ptr ds:[ParHerc],0
         je        DispBox0


; ------ zobrazen° obdÇln°ku

         call      KorRAM
         or        ah,ah
         mov       al,0                     ; z†pisovò bajt
         jz        DispBox4
         not       al
DispBox4:push      di
         push      cx
         rep       stosb                    ; z†pis jednÇ linky
         pop       cx
         pop       di

         add       di,2000h
         jns       DispBox5
         and       di,7fffh
         add       di,80                    ; zvò®en° adresy linky
DispBox5:dec       bx                       ; sn°ëen° á°taáe linek
         jnz       DispBox4                 ; z†pis dal®° linky

         jmp       short DispBox9


; ------ nastaven° z†pisu do v®ech rovin

DispBox0:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z†pis do v®ech rovin
         out       dx,al                    ; nastaven° v®ech rovin

; ------ nastaven° barvy obdÇln°ku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; poëadovan† barva obdÇln°ku
         out       dx,al                    ; nastaven° barvy obdÇln°ku
         dec       dx

; ------ nastaven° volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; v®echny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin

; ------ zobrazen° obdÇln°ku

         mov       al,0                     ; z†pisovò bajt (nen° dñleëitò)
DispBox1:push      di
         push      cx
         rep       stosb                    ; z†pis jednÇ linky
         pop       cx
         pop       di
         add       di,80                    ; zvò®en° adresy linky
         dec       bx                       ; sn°ëen° á°taáe linek
         jnz       DispBox1                 ; z†pis dal®° linky

; ------ n†vrat registrñ

         out       dx,al                    ; v®echny roviny podle dat
DispBox9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBox  ENDP

; -----------------------------------------------------------------------------
;        korekce adresy ve videopamàti DI pro HERCULES
; -----------------------------------------------------------------------------

KorRAM   PROC      NEAR

         push      bx
         push      dx
         push      ax

         xor       dx,dx
         mov       ax,di
         mov       bx,80
         div       bx
         mov       di,dx

         xor       dx,dx
         mov       bx,4
         div       bx

         mov       bx,dx
         mov       dx,80
         mul       dx
         add       di,ax

         mov       ax,bx
         mov       dx,2000h
         mul       dx
         add       di,ax

         pop       ax
         pop       dx
         pop       bx
         ret

KorRAM   ENDP


; *****************************************************************************
;
;                          RñznÇ procedury
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        inicializace videokarty HERCULES
; -----------------------------------------------------------------------------

InitHerc PROC      NEAR

         cli                                ; z†kaz p©eru®en°

         mov       al,3
         mov       dx,3bfh
         out       dx,al

         mov       al,2
         mov       dx,3b8h
         out       dx,al

         mov       dx,3b4h
         mov       si,offset tabinit        ; tabulka pro inicializaci
         call      inittab                  ; inicializace podle tabulky

         mov       al,0ah
         mov       dx,3b8h
         out       dx,al

         sti

         push      es
         mov       cx,4000h
         mov       ax,0b000h
         mov       ds:[SegVRAM],ax
         mov       es,ax
         xor       ax,ax
         mov       di,ax
         cld
         rep       stosw
         pop       es

         ret

InitHerc ENDP


; -----------------------------------------------------------------------------
inittab:                                  ;* inic. registrñ podle tabulky
                                            ; VSTUP: DS:SI=ukazatel tabulky
                                            ;        DX=adresa portu

         push      ax
         xor       ah,ah
         cld
inittab2:lodsb
         call      initreg                  ; inicializace registru
         inc       ah
         cmp       ah,12
         jb        inittab2                 ; dal®° registr
         pop       ax
         ret

; -----------------------------------------------------------------------------
initreg:                                  ;* inicializace jednoho registru
                                            ; VSTUP: AH=registr
                                            ;        AL=hodnota pro nastaven°
                                            ;        DX=adresa registru

         push      ax
         mov       al,ah
         out       dx,al                    ; nastaven° á°sla registru
         pop       ax
         inc       dx
         out       dx,al                    ; data pro nastaven° registru
         dec       dx
         ret

;; -----------------------------------------------------------------------------
;;        test znaku z kl†vesnice (CY=nen°)
;; -----------------------------------------------------------------------------
;
;TestKey  PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      bp
;         push      si
;         push      di
;         push      ds
;         push      es
;
;; ------ test stavu kl†vesnice
;
;         int       28h
;         mov       ah,1
;         int       16h
;         clc                                ; p©°znak - je kl†vesa
;         jnz       TestKey1                 ; je kl†vesa
;         stc                                ; p©°znak - nen° kl†vesa
;
;; ------ n†vrat registrñ
;
;TestKey1:pop       es
;         pop       ds
;         pop       di
;         pop       si
;         pop       bp
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;TestKey  ENDP

;; -----------------------------------------------------------------------------
;;        vstup znaku z kl†vesnice (CY=p©eru®en°)
;; -----------------------------------------------------------------------------
;
;InpCh    PROC      NEAR
;
;         xor       ax,ax
;         int       16h
;         or        ax,ax
;         stc
;         jz        InpCh9
;         cmp       al,27
;         stc
;         je        InpCh9
;         clc
;InpCh9:  ret
;
;InpCh    ENDP
;
; -----------------------------------------------------------------------------
;        zapnut° t¢novÇho gener†toru
; -----------------------------------------------------------------------------
; VSTUP: BX=dàlic° konstanta
;         dw        36485,34437,32505,30680,28958,27333 ; okt†va 0
;         dw        25799,24351,22984,21694,20477,19327
;         dw        18243,17219,16252,15340,14479,13667 ; okt†va 1
;         dw        12899,12175,11492,10847,10238,9664
;         dw        9121,8609,8126,7670,7240,6833       ; okt†va 2
;         dw        6450,6088,5746,5424,5119,4832
;         dw        4561,4305,4063,3835,3620,3417       ; okt†va 3
;         dw        3225,3044,2873,2712,2560,2416
;         dw        2280,2152,2032,1918,1810,1708       ; okt†va 4
;         dw        1612,1522,1437,1356,1280,1208
;         dw        1140,1076,1016,959,905,854          ; okt†va 5
;         dw        806,761,718,678,640,604
;         dw        570,538,508,479,452,427             ; okt†va 6
;         dw        403,380,359,339,320,302
;         dw        285,269,254,240,226,214             ; okt†va 7
;         dw        202,190,180,169,160,151
;         dw        143,135,127,120,113,107             ; okt†va 8
;         dw        101,95,90,85,80,75
;         dw        71,67,63,60,57,53,50,48,45,42,40,38 ; okt†va 9
; -----------------------------------------------------------------------------

Ton      PROC      NEAR

         cmp       byte ptr ds:[Sound],0    ; je zvuk zapnut ?
         je        Ton9                     ; zvuk je vypnut
         push      ax
         mov       al,0b6h
         out       [43h],al
         mov       al,bl
         out       [42h],al
         mov       al,bh
         out       [42h],al
         in        al,[61h]
         or        al,3
         out       [61h],al
         pop       ax
Ton9:    ret

Ton      ENDP

; -----------------------------------------------------------------------------
;        vypnut° zvukovÇho gener†toru
; -----------------------------------------------------------------------------

TonOff   PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al                 ; vypnut° gener†toru
         pop       ax
         ret

TonOff   ENDP

; -----------------------------------------------------------------------------
;                         InitRnd
;                  inicializace gener†toru n†hody
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

InitRnd  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; á°taá systÇmovÇho áasovaáe
         pop       ds
         mov       word ptr ds:[RandomR],ax ; inicializaán° konstanta
         pop       ax
         ret

InitRnd  ENDP

; -----------------------------------------------------------------------------
;                           Random
;                   gener†tor n†hodnÇho á°sla
; -----------------------------------------------------------------------------
; VSTUP: AX=max. hodnota
;        DS=datovò segment
; VùSTUP: AX=á°slo 0 aë (max. hodnota - 1)
; -----------------------------------------------------------------------------

Random   PROC      NEAR

         push      bx
         push      dx
         or        ax,ax
         jz        Random1
         mov       bx,ax                    ; poëadovanò rozsah
         call      Random0                  ; generov†n° n†hodnÇho á°sla DX:AX
         xchg      ax,dx                    ; AX <- n†hodnÇ á°slo
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
         mul       word ptr cs:[RandomD]
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
;                          Obsluha hodin
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                         Prodleva p©i h©e
; -----------------------------------------------------------------------------

ProdlHra PROC      NEAR

         push      cx
         mov       ch,0
         mov       cl,ds:[Rychlost]         ; rychlost hry
         add       cx,3                     ; trochu pozvolnàj®° vzestup
         shl       cx,1
         shl       cx,1
 ;        shl       cx,1
         shl       cx,1
         shl       cx,1                     ; maxim†lnà bude asi 300 ms/krok
         call      Cekej
         pop       cx
         ret

ProdlHra ENDP

; -----------------------------------------------------------------------------
;        cejchov†n° hodin (lze vyvol†vat opakovanà)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ p©°prava registrñ

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch

; ------ áek†n° na zaá†tek impulsu hodin

         mov       bx,ds:[di]
CekInit1:cmp       bx,ds:[di]
         je        CekInit1                 ; áek†n° na zaá†tek hodin

; ------ mà©en° áasu

         mov       bx,ds:[di]
         EVEN                               ; zarovn†n° na sudou adresu
CekInit2:add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       bx,ds:[di]               ; byla zmàna ?
         je        CekInit2                 ; áek†n° na zmànu hodin

; ------ vòpoáet konstanty

         mov       bx,55                    ; dàlitel
         cmp       dx,bx                    ; p©eteáen° á°sla ?
         jb        CekInit3                 ; nen° p©eteáen° á°sla
         mov       dx,54                    ; omezen° á°sla
CekInit3:div       bx                       ; vòpoáet konstanty
         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen° = 0
         inc       ax                       ; korekce na 1
CekInit4:
         pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        áek†n° na uplynut° zadanÇho áasu
; -----------------------------------------------------------------------------
; VSTUP: CX=poëadovan† doba v milisekund†ch
;        DS=datovò segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ áek†n° po zadanou dobu

         jcxz      Cekej9                   ; nen° ë†dnÇ áek†n°
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; nië®° slovo á°taáe hodin
         xor       dx,dx                    ; vy®®° slovo á°taáe hodin

; ------ á°t†n° doby 1 ms

         EVEN                               ; zarovn†n° na sudou adresu
Cekej2:  add       ax,1                     ; á°taá nië®°ho slova áasu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         cmp       ax,ds:[di]               ; dosaëeno doby 1 ms ?
         jne       Cekej2                   ; á°t†n° doby 1 ms

         loop      Cekej1                   ; áek†n° na dal®° 1 ms

; ------ n†vrat registrñ

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Cekej    ENDP


; *****************************************************************************
;
;
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

Int24    PROC      FAR

         xor       al,al                    ; chyby se budou ignorovat
Int23:   iret

Int24    ENDP

; *****************************************************************************
;
;                          Obsluha kl†vesnice
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        test, zda je p©ipraven znak z kl†vesnice (CY=nen°)
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         cmp       word ptr cs:[KeyBuf],0   ; je v bufferu p©ipraven znak ?
         jnz       TestKey2                 ; v bufferu je p©ipraven znak
         stc                                ; p©°znak chyby - nen° znak
TestKey2:ret

TestKey  ENDP

; -----------------------------------------------------------------------------
;        áek†n° na znak z kl†vesnice (ZY=p©eru®en° ESC)
; -----------------------------------------------------------------------------

InpKey   PROC      NEAR

         sti
InpKey1: xor       ax,ax                    ; AX <- 0
         xchg      ax,cs:[KeyBuf]           ; vyjmut° znaku z bufferu
         or        ax,ax                    ; byl v bufferu znak ?
         jnz       InpKey2                  ; v bufferu byl platnò znak
         mov       ah,0bh
         int       21h                      ; test p©eru®en° programu
         jmp       short InpKey1            ; dal®° áek†n°
InpKey2: cmp       al,27                    ; je p©eru®en° ESC ?
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        Obsluha kl†vesnice INT 09h
; -----------------------------------------------------------------------------

Old09    dd        0                        ; pñvodn° obsluha INT 09h

KeyBuf   dw        0                        ; buffer posledn° kl†vesy

Int09    PROC      FAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      ds

; ------ p©°prava datovÇho segmentu BIOS

         mov       bx,40h
         mov       ds,bx                    ; datovò segment BIOS

; ------ áten° k¢du stisknutÇ kl†vesy

         in        al,[60h]                 ; áten° k¢du kl†vesy
         mov       ah,al                    ; £schova kl†vesy
         and       al,7fh

; ------ rozli®en°, zda je kl†vesa pro Joystick

         cmp       al,48h                   ; kurzor nahoru
         je        Int092
         cmp       al,4bh                   ; kurzor vlevo
         je        Int092
         cmp       al,4dh                   ; kurzor vpravo
         je        Int092
         cmp       al,50h                   ; kurzor dolñ
         je        Int092
         cmp       al,39h                   ; mezera
         jne       Int097
         mov       al," "                   ; m†hrada mezery

; ------ vypu®tàn° (uvolnàn°) kl†vesy

Int092:  mov       cx,5                     ; max. poáet kl†ves
         mov       bx,offset StickBuf       ; buffer kl†ves
         test      ah,80h                   ; je uvolnàn° kl†vesy ?
         jz        Int095                   ; nen° uvolnàn°
Int093:  cmp       al,cs:[bx]               ; nalezena kl†vesa ?
         je        Int094                   ; kl†vesa nalezena
         inc       bx
         loop      Int093
         jmp       short Int097             ; kl†vesa nenalezena
Int094:  mov       al,cs:[bx+1]
         mov       cs:[bx],al
         inc       bx
         loop      Int094                   ; vypu®tàn° kl†vesy
         jmp       short Int097

; ------ vloëen° kl†vesy do bufferu

Int095:  cmp       al,cs:[bx]
         je        Int097                   ; jië v bufferu je
         inc       bx
         loop      Int095
         mov       bx,offset StickBuf+4
         mov       cl,4
Int096:  mov       ah,cs:[bx-1]
         mov       cs:[bx],ah
         dec       bx
         loop      Int096
         mov       cs:[bx],al               ; vloëen° znaku do bufferu

; ------ standardn° obsluha kl†vesnice

Int097:  mov       bx,ds:[1ch]              ; £schova ukl†dac° adresy do bufferu
         pushf
         call      dword ptr cs:[Old09]     ; vol†n° standardn° obsluhy BIOS

; ------ kontrola, zda je v bufferu nàjakò znak

         cmp       bx,ds:[1ch]              ; zmànila se ukl†dac° adresa ?
         je        Int099                   ; nezmànila se - nen° novò znak

; ------ vyjmut° novÇho znaku z bufferu

         mov       ax,ds:[bx]               ; vyjmut° novÇho znaku
         mov       cs:[KeyBuf],ax           ; £schova znaku do bufferu
         mov       ds:[1ch],bx              ; n†vrat ukl†dac° adresy
         mov       ds:[1ah],bx              ; zru®en° átec° adresy

; ------ n†vrat registrñ

Int099:  pop       ds
         pop       cx
         pop       bx
         pop       ax
         iret

Int09    ENDP
;˛

StickBuf db        6 dup(0)                 ; buffer kl†ves JoySticku
                                            ; prvn° bajt = platn† kl†vesa

Code     ENDS

; *****************************************************************************
;
;                       Datovò segment
;
; *****************************************************************************
;˛
Data     SEGMENT

Include  Obrazky.ASM

ErrCard  db        'Program vyzaduje grafickou kartu EGA, VGA nebo Hercules !',13,10,'$'

; ------ gener†tor n†hody

RandomR  dd        21510d31h                ; promànn† pro gener†tor n†hody
RandomD  dw        8405h                    ; pomocn† konstanta

tabinit  label     byte                   ;* tabulka parametrñ
         db        53                       ; 0:celkovò poáet znakñ na ©†dek-1
         db        40                       ; 1:poáet vidit. znakñ na ©†dek
         db        44                       ; 2:poá†tek horiz. zatemnàn°
         db        7                        ; 3:poáet znakñ na synchronizaci

         db        91;121                      ; 4:celk. poáet vert. ©†dkñ-1 (363)
         db        1;2                        ; 5:poáet linek + k poátu ©†dkñ
         db        88;100                      ; 6:poáet viditelnòch ©†dkñ (300)
         db        88;115                      ; 7:©†dka zpàtnÇho bàhu (345)
         db        2;1                        ; 8:1=prokl†d†n°, 2=normal
         db        3;2                        ; 9:poáet linek na znak - 1 (3)

         db        0                        ; 0a:prvn° linka kurzoru
         db        3;2                        ; 0b:koncov† linka kurzoru

TxtSkore db        ' Sk¢re '
TxtSkor0 label     byte

TxtTime  db        ' áas '
TxtTime0 label     byte

TxtLic   db        ' (c)Nàmeáek '
TxtLic0  label     byte

TxtScen  db        'ScÇna '
TxtScen0 label     byte

; ------ tabulka bodñ

TabBod   db        2,4,8,14,22,32,44,60,80,110

; ------ pracovn° adresa videopamàti

SegVRAM  dw        0a000h                   ; segment videopamàti

ParHerc  db        0                        ; p©°znak videokarty HERCULES
Sound    db        1                        ; p©°znak zapnut° zvuku

OldVMod  db        ?                        ; pñvodn° videom¢d

; ------ áasovaá

Sezran   db        0                        ; p©°znak seër†n° Flappyho (á°taá)

         EVEN                               ; zaá°n† na sudÇ adrese jako 0:46ch
Cit1ms   dw        ?                        ; konstanta pro dobu 1 ms
Rychlost db        4                        ; rychlost hry (jeden krok)

Old1b    dd        ?                        ; pñvodn° adresa INT 1Bh

Scena    dw        ?                        ; á°slo aktivn° scÇny 1 ...
Zivoty   db        ?                        ; poáet zbylòch ëivotñ
Skore    dw        ?                        ; dosaëenÇ sk¢re
Time     dw        ?                        ; á°taá zbylÇho áasu * 2
PozFlap  dw        ?                        ; pozice a ©†dek Floppyho
FazFlap  db        ?                        ; f†ze pohybu Floppyho
                                            ;     1 zep©edu stoj°
                                            ;     2 zep©edu pad†
                                            ;     3 zep©edu krok 1
                                            ;     4 zep©edu krok 2
                                            ;     5 zezadu stoj°
                                            ;     6 zezadu krok 1
                                            ;     7 zezadu krok 2
                                            ;     8 vlevo stoj°
                                            ;     9 vlevo mezikrok
                                            ;    10 vpravo stoj°
                                            ;    11 vpravo mezikrok
                                            ;    12 leë° 1
                                            ;    13 leë° 2

Pole     db        38*20 dup(?)             ; pole - hrac° plocha
                                            ;  0 = pr†zdnÇ
                                            ;  1 = cihla

Modra    dw        ?                        ; pozice a ©†dek modrÇ cihly

KouleN   db        ?                        ; poáet koul° (vëdy minim†lnà 1)
Koule    db        20 dup(4 dup(?))         ; typ, pozice a ©†dky koul° (+rez.)
                                            ;  typ: 1=modr†
                                            ;       2=zelen† koule cel†
                                            ;       3=zelen† koule rozpad 1
                                            ;       4=zelen† koule rozpad 2
                                            ;       5=zelen† koule rozpad 3
                                            ;       6=zelen† koule rozpad 4

DuchN    db        ?                        ; poáet duchñ
Duch     db        20 dup(4 dup(?))         ; typ, pozice a ©†dek, á°taá sp†nku
                                            ;       1=vlevo stoj°
                                            ;       2=vlevo mezikrok
                                            ;       3=vpravo stoj°
                                            ;       4=vpravo mezikrok

StrelF   db        ?                        ; poáet st©el Flappyho
StrelN   db        ?                        ; poáet st©el
Strely   db        40 dup(4 dup(?))         ; typ, pozice a ©†dek, á°taá letu
                                            ;       0=stoj° (pad†)
                                            ;       1=let° vlevo
                                            ;       2=let° vpravo
                                            ;       3=let° nahoru
                                            ;       4=let° dolñ

Include  SCENY.ASM

Data     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;        z†sobn°k
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

StackS   SEGMENT   STACK

         dw        400h dup(?)

StackS   ENDS

         END       Start

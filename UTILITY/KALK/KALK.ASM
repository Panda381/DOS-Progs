

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Kalkul†tor
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        konstanty
; -----------------------------------------------------------------------------

HI       EQU       256

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h
bit8     EQU       100h
bit9     EQU       200h
bit10    EQU       400h
bit11    EQU       800h
bit12    EQU       1000h
bit13    EQU       2000h
bit14    EQU       4000h
bit15    EQU       8000h

KalNumN  EQU       32                       ; poáet bajtñ celoá°selnÇ á†sti
KalNumD  EQU       32                       ; poáet bajtñ desetinnÇ á†sti
KalNumX  EQU       64                       ; poáet bajtñ celkem

Verze    EQU       '01'                     ; verze 1.0

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©echodnÇ p©edefinov†n° z†sobn°ku

Start:   cmp       sp,offset Zasob
         jb        Start01                  ; nedostatek pamàti
         mov       sp,offset Zasob

; ------ zmen®en° bloku programu

         mov       ah,4ah
         mov       bx,(offset(Zasob-Start)+10fh)/16
         int       21h                      ; zmen®en° bloku programu
         jc        Start01                  ; chyba pamàti

; ------ vytvo©en° bufferu pro z†sobn°k

         mov       ah,48h
         mov       bx,4000h/16              ; poëadovan† velikost bufferu
         int       21h                      ; vytvo©en° bufferu
         jnc       Start02                  ; buffer vytvo©en OK

; ------ chyba - nedostatek pamàti

Start01: mov       dx,offset MemTxt         ; text - nedostatek pamàti
         mov       ah,9
         int       21h                      ; zobrazen° textu chyby
         int       20h

; ------ p©edefinov†n° z†sobn°ku

Start02: mov       ss,ax                    ; segment z†sobn°ku
         mov       sp,4000h                 ; offset z†sobn°ku
         xor       ax,ax
         push      ax                       ; koncovÇ slovo 0 v z†sobn°ku

; ------ inicializace videom¢du

         call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du

; ------ vytvo©en° bufferu pro £schovu obrazovku

         mov       al,80                    ; poáet znakñ na ©†dek
         mul       byte ptr ds:[Radku]      ; vòpoáet dÇlky videostr†nky
         mov       cx,ax                    ; dÇlka videostr†nky (slov)
         mov       bx,ax                    ; dÇlka videostr†nky (slov)
         add       bx,7                     ; zaokrouhlen°
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na odstavce
         mov       ah,48h
         int       21h                      ; vytvo©en° datovÇho bloku
         jc        Start01                  ; chyba - nedostatek pamàti
         mov       ds:[ObrSegm],ax          ; adresa bufferu

; ------ £schova obsahu obrazovky

         push      ds
         mov       ds:[ObrSize],cx          ; £schova velikosti vieostr†nky
         xor       di,di                    ; ukl†dac° adresa
         mov       es,ax                    ; segment bufferu
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds
         push      ds
         pop       es

; ------ £schova kurzoru

         call      GetKurz                  ; poskytnut° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ vymaz†n° bufferñ

         mov       di,offset Cislo1
         mov       cx,3*KalNumX/2
         xor       ax,ax
         cld
         rep       stosw                    ; vymaz†n° bufferñ

; ------ obsluha p©eru®en°

         mov       ax,2523h
         mov       dx,offset INT23
         int       21h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start1

         mov       byte ptr ds:[ColKalI],7
         mov       byte ptr ds:[ColKal1],70h
         mov       byte ptr ds:[ColKal2],7
         mov       byte ptr ds:[ColKal3],7
         mov       byte ptr ds:[ColKal4],0fh
         mov       byte ptr ds:[ColKal5],0fh
         mov       byte ptr ds:[ColKal6],0fh
         mov       byte ptr ds:[HelpColH],70h

; ------ kontrola verze systÇmu

Start1:  mov       ah,30h
         int       21h
         mov       dx,offset Soubor         ; soubor v aktivn°m adres†©i
         cmp       al,3
         jb        Start5                   ; n°zk† verze systÇmu

; ------ nalezen° jmÇna souboru v prost©ed°

         cmp       word ptr ds:[2ch],0      ; je prost©ed° ?
         je        Start5                   ; nen° prost©ed°
         mov       ds,ds:[2ch]              ; segment prost©ed°
         mov       cx,7fffh
         xor       si,si
Start2:  cmp       word ptr ds:[si],0
         je        Start3
         inc       si
         loop      Start2
Start3:  add       si,4
         cmp       word ptr ds:[si-2],1
         jne       Start5                   ; neplatnò ©etàzec

; ------ p©enesen° jmÇna do bufferu

         push      cs
         pop       es
         mov       di,offset SoubBuf
         mov       cx,100
         cld
Start4:  lodsb
         stosb
         cmp       al,0
         loopne    Start4
         jne       Start5
         dec       di
         dec       di

; ------ nalezen° konce cesty

         mov       al,"\"
         sub       cx,99
         neg       cx
         std
         repne     scasb
         jne       Start5

; ------ sestaven° novÇho jmÇna

         push      cs
         pop       ds
         inc       di
         inc       di
         mov       si,offset Soubor
         mov       cx,14
         cld
         rep       movsb
         mov       dx,offset SoubBuf

; ------ pokus o otev©en° souboru

Start5:  push      cs
         pop       ds
         mov       ax,3d02h
         int       21h
         jnc       Start6
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        Start8                   ; chyba

; ------ naáten° souboru do pamàti

Start6:  mov       bx,ax
         mov       ds:[SouborI],ax          ; identifik†tor

         mov       dx,offset KalkCnf
         mov       cx,2
         mov       ah,3fh
         int       21h                      ; naáten° identifik†toru
         jc        Start8                   ; chyba
         cmp       word ptr ds:[KalkCnf],Verze
         jne       Start8

         mov       cx,offset(KalkCnf0-KalkCnf)-2
         mov       ah,3fh
         inc       dx
         inc       dx
         int       21h

; ------ zobrazen° kalkul†toru

Start8:  push      cs
         pop       ds
         push      cs
         pop       es


         call      DispFMnu                 ; zobrazen° kalkul†toru

         jmp       EditKal                  ; editace kalkul†toru


; ------ n†vrat z programu

Main0:
         push      cs
         pop       ds

         mov       word ptr ds:[KalkCnf],Verze

         mov       bx,ds:[SouborI]
         or        bx,bx
         jz        Main02

         mov       ax,4200h
         xor       cx,cx
         xor       dx,dx
         int       21h

         mov       dx,offset KalkCnf
         mov       cx,offset(KalkCnf0-KalkCnf)
         mov       ah,40h
         int       21h

         xor       cx,cx
         mov       ah,40h
         int       21h

         mov       ah,3eh
         int       21h

Main02:

; ------ n†vrat obsahu obrazovky

INT23:   push      cs
         pop       ds

         call      PopScr                   ; n†vrat obsahu obrazovky

         int       20h

INT24    PROC      FAR

         mov       al,0
         iret

INT24    ENDP

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
         mov       cx,ds:[ObrSize]          ; velikost videopamàti (slov)
         mov       ds,ds:[ObrSegm]          ; adresa bufferu
         xor       si,si                    ; offset v bufferu
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
;        obsluha editace kalkul†toru
; -----------------------------------------------------------------------------

AWZMRET: call      PopScr                   ; n†vrat obrazovky
         mov       ah,0
         int       16h
         call      DispFMnu

EditKal:

AWZMn731:call      KurzOff

         mov       ah,0
         int       16h
         mov       bx,ax
         or        ax,ax
         jnz       AWZMx023
         jmp       INT23

AWZMx023:
         cmp       bl,"a"
         jb        AWZM7320
         cmp       bl,"z"
         ja        AWZM7320
         sub       bl,32
AWZM7320:
         or        bl,bl
         jz        AWZM7321
         xor       bh,bh
AWZM7321:cmp       bl,"0"
         jb        AWZMn732
         cmp       bl,"9"
         jbe       AWZMn733
AWZMn732:call      JumpBX

         dw        0fh,AWZMRET              ; ^O
         dw        01bh,AWZMn73x
         dw        002eh,AWZMn735           ; "." teáka
         dw        0008h,AWZMn737           ; BS
         dw        5300h,AWZMn737           ; Delete
         dw        0043h,AWZMn738           ; C - vymaz†n° kalkul†toru

         dw        002bh,AWZM7382           ; +
         dw        002dh,AWZM7384           ; -
         dw        002ah,AWZM7386           ; *
         dw        002fh,AWZM7388           ; /
         dw        003ah,AWZM7388           ; :
         dw        004eh,AWZM738c           ; N
         dw        0058h,AWZM7390           ; X
         dw        0054h,AWZM7392           ; T
         dw        005ah,AWZM7394           ; Z
         dw        004dh,AWZM73a0           ; M
         dw        004fh,AWZM73b0           ; O

         dw        000dh,AWZMn736           ; Enter
         dw        003dh,AWZMn736           ; "="

         dw        0,AWZMn731


; ------ á°slice 0 aë 9

AWZMn733:
         test      byte ptr ds:[KalParm],bit1
         jnz       AWZM7330
         call      MazCis
         call      NulCis
         and       byte ptr ds:[KalParm],not bit0
         or        byte ptr ds:[KalParm],bit1
AWZM7330:
         cmp       byte ptr ds:[CisNum],31
         jae       AWZM7311

         cmp       word ptr ds:[CisBuf+30],"0 "
         jne       AWZM7331
         mov       byte ptr ds:[CisBuf+31]," "
AWZM7331:
         push      si
         push      ds
         pop       es
         mov       di,offset CisBuf
         mov       si,di
         inc       si
         mov       cx,31
         cld
         rep       movsb
         pop       si

         mov       es:[di],bl               ; uloëen° znaku do bufferu
         inc       byte ptr ds:[CisNum]

         call      KodZad                   ; k¢dov†n° á°sla do bin. tvaru

         call      DispFLin

         mov       al,10
         cmp       bl,"."
         je        AWZM7333
         mov       al,bl
         and       al,0fh
AWZM7333:call      BlikFKlv

AWZM7311:jmp       AWZMn731

; ------ teáka

AWZMn735:
         test      byte ptr ds:[KalParm],bit1
         jz        AWZM7351
         test      byte ptr ds:[KalParm],bit0
         jnz       AWZM7311                 ; teáka jië byla zadan†

         test      byte ptr ds:[KalParm],bit1
         jnz       AWZM7350
AWZM7351:call      MazCis
         call      NulCis
         or        byte ptr ds:[KalParm],bit1
AWZM7350:
         or        byte ptr ds:[KalParm],bit0
         jmp       short AWZM7331

; ------ vòpoáet Enter, =

AWZMn736:test      byte ptr ds:[KalParm],bit4 + bit5 + bit6 + bit7
         jz        AWZM7362

         call      Vypocet

         mov       al,16
         call      BlikFKlv
AWZM7362:and       byte ptr ds:[KalParm],not bit3
         jmp       short AWZM7311

; ------ vymaz†n° znaku DELETE

AWZMn737:
         cmp       byte ptr ds:[CisNum],0
         je        AWZM7311
         dec       byte ptr ds:[CisNum]
         or        byte ptr ds:[KalParm],bit1

         push      si
         push      ds
         pop       es
         mov       si,offset CisBuf + 31
         mov       al,ds:[si]
         mov       di,si
         dec       si
         mov       cx,31
         std
         rep       movsb
         pop       si
         mov       byte ptr ds:[di]," "

         cmp       byte ptr ds:[CisBuf+31]," "
         jne       AWZM7372
         mov       byte ptr ds:[CisBuf+31],"0"
AWZM7372:
         call      KodZad                   ; k¢dov†n° á°sla do bin. tvaru

         cmp       al,"."
         jne       AWZM7375
         and       byte ptr ds:[KalParm],not bit0

AWZM7375:
         call      DispFLin
         jmp       AWZM7311

; ------ vymaz†n° kalkul†toru

AWZMn738:
         call      MazCis
         call      NulCis
         and       byte ptr ds:[KalParm],not bit0+bit1+bit3+bit4+bit5+bit6+bit7
         call      NulCis
         call      DispFLin

         mov       al,17
         call      BlikFKlv

         jmp       AWZMn731

; ------ sá°t†n°

AWZM7382:mov       al,bit4
         mov       ah,12

AWZM7383:test      byte ptr ds:[KalParm],bit3
         jz        AWZM738a
         test      byte ptr ds:[KalParm],bit1
         jz        AWZM738a
         call      Vypocet
AWZM738a:call      DuplCis
         call      DispFLin
         mov       al,ah
         call      BlikFKlv
         or        byte ptr ds:[KalParm],bit3
         jmp       AWZMn731

; ------ odeá°t†n°

AWZM7384:mov       al,bit5
         mov       ah,13
         jmp       short AWZM7383

; ------ n†soben°

AWZM7386:mov       al,bit6
         mov       ah,14
         jmp       short AWZM7383

; ------ dàlen°

AWZM7388:mov       al,bit7
         mov       ah,15
         jmp       short AWZM7383

; ------ negace á°sla

AWZM738c:
         mov       di,offset CisBuf
         cmp       byte ptr ds:[di],"-"
         je        AWZM738e
AWZM738d:inc       di
         cmp       byte ptr ds:[di]," "
         je        AWZM738d
         cmp       byte ptr ds:[di],"-"
         je        AWZM738e
         mov       byte ptr ds:[di-1],"-"
         jmp       short AWZM738f
AWZM738e:mov       byte ptr ds:[di]," "
AWZM738f:call      KodZad
         call      DispFLin
         mov       al,11
         call      BlikFKlv
AWZM738g:jmp       AWZMn731

; ------ p©evr†cen† hodnota á°sla

AWZM7390:
         push      si
         push      ds
         pop       es
         mov       si,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AWZM7391
         mov       si,offset Cislo2
AWZM7391:call      KalInv                   ; p©evr†cen† hodnota á°sla
         pop       si
         call      AktCis

         and       byte ptr ds:[KalParm],not bit1 ; nen° editace
         call      DispFLin

         mov       al,19
         call      BlikFKlv
         jmp       AWZMn731

; ------ p©°znak zobrazen° tis°cñ

AWZM7392:
         xor       byte ptr ds:[KalPrep],bit7

         test      byte ptr ds:[KalParm],bit1    ; je editace ?
         jnz       AWZM7393
         call      AktCis
         call      DispFLin
AWZM7393:call      DispFPr
         jmp       AWZMn731

; ------ zaokrouhlen°

AWZM7394:push      word ptr ds:[MnuHlp]
         push      si

         mov       word ptr ds:[MnuHlp],offset FKalMLH3
         call      DispMHlp

         mov       dx,word ptr ds:[MnuPoz]
         add       dh,4
         add       dl,4 + offset(KalZaokr-FKalMLA1) + 1
         call      SetKurz

         mov       cl,ds:[KalPrep]
         and       cl,not bit7              ; £schova pñvodn° hodnoty
         xor       ch,ch                    ; £schova posledn° á°slice

AWZM7395:mov       ah,0
         int       16h
         mov       bx,ax
         cmp       bx,11bh
         je        AWZM7396
         cmp       bl,0dh
         je        AWZM7397

         cmp       bl,"0"
         jb        AWZM7395
         cmp       bl,"9"
         ja        AWZM7395

         mov       al,10
         mul       ch
         and       bl,0fh
         add       al,bl
         mov       ch,bl                    ; £schova á°slice
         and       byte ptr ds:[KalPrep],bit7
         or        ds:[KalPrep],al
         call      DispFPr
         jmp       short AWZM7395

AWZM7396:and       byte ptr ds:[KalPrep],bit7
         or        ds:[KalPrep],cl

AWZM7397:mov       al,ds:[KalPrep]
         and       al,not bit7
         cmp       al,30
         jbe       AWZM7398
         mov       al,30
AWZM7398:and       byte ptr ds:[KalPrep],bit7
         or        ds:[KalPrep],al

         call      KurzOff
         pop       si
         pop       word ptr ds:[MnuHlp]
         call      DispMHlp

         test      byte ptr ds:[KalParm],bit1    ; je editace ?
         jnz       AWZM7399
         call      AktCis
         call      DispFLin
AWZM7399:call      DispFPr
         jmp       AWZMn731

; ------ pamàü

AWZM73a0:
         push      word ptr ds:[MnuHlp]
         push      si
         mov       word ptr ds:[MnuHlp],offset FKalMLH2
         call      DispMHlp
         push      ds
         pop       es

         mov       ah,0
         int       16h
         mov       bx,ax
         xor       bh,bh
         xor       ax,ax
         call      JumpBX

         dw        0043h,AWZM73a1           ; C
         dw        0063h,AWZM73a1           ; c
         dw        0052h,AWZM73a2           ; R
         dw        0072h,AWZM73a2           ; r
         dw        002bh,AWZM73a4           ; +
         dw        002dh,AWZM73a6           ; -


         dw        0,AWZM73a9

; ------ nulov†n° pamàti

AWZM73a1:mov       di,offset CisloM
         mov       cx,KalNumX/2
         cld
         xor       ax,ax
         rep       stosw
         and       byte ptr ds:[KalParm],not bit2
         mov       al,23
         jmp       short AWZM73a9

; ------ vyvol†n° obsahu pamàti

AWZM73a2:mov       si,offset CisloM
         mov       di,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AWZM73a3
         mov       di,offset Cislo2
AWZM73a3:mov       cx,KalNumX/2
         cld
         rep       movsw
         and       byte ptr ds:[KalParm],not bit1
         call      AktCis
         call      KodZad                   ; k¢dov†n° á°sla do bin. tvaru
         mov       al,22
         jmp       short AWZM73a9

; ------ p©iáten° á°sla k pamàti

AWZM73a4:mov       si,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AWZM73a5
         mov       si,offset Cislo2
AWZM73a5:mov       di,offset CisloM
         call      Soucet
         mov       al,20
         jmp       short AWZM73a8

; ------ odeáten° á°sla od pamàti

AWZM73a6:mov       si,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AWZM73a7
         mov       si,offset Cislo2
AWZM73a7:mov       di,offset CisloM
         call      Rozdil
         mov       al,21

; ------ test, zda je pamàü pr†zdn†

AWZM73a8:and       byte ptr ds:[KalParm],not bit2 + bit1 ; zru®en° p©°zn. edit.
         mov       di,offset CisloM
         push      ax
         xor       ax,ax
         mov       cx,KalNumX/2
         cld
         repe      scasw
         pop       ax
         je        AWZM73a9
         or        byte ptr ds:[KalParm],bit2


AWZM73a9:pop       si
         pop       word ptr ds:[MnuHlp]
         call      DispMHlp
         call      DispFLin
         or        al,al
         jz        AWZM73aa
         call      BlikFKlv
AWZM73aa:jmp       AWZMn731

; ------ odmocnina

AWZM73b0:
         mov       dx,word ptr ds:[MnuPoz]
         add       dl,4
         add       dh,2
         mov       al,"!"
         mov       ah,ds:[ColKalI]
         or        ah,80h
         call      Disp1Chr

         mov       al,18
         call      BlikFKlv

         push      si
         push      ds
         pop       es
         mov       si,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AWZM73b1
         mov       si,offset Cislo2
AWZM73b1:call      KalOdm                  ; odmocnina á°sla
         pop       si
         call      AktCis

         and       byte ptr ds:[KalParm],not bit1 ; nen° editace
         call      DispFLin

         jmp       AWZMn731


AWZMn73x:jmp       Main0                    ; n†vrat

; -----------------------------------------------------------------------------
;        vòpoáet
; -----------------------------------------------------------------------------

Vypocet  PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es
         mov       di,offset Cislo1
         mov       si,offset Cislo2

         mov       cl,ds:[KalParm]
         test      cl,bit4
         jz        Vypocet1
         call      Soucet

Vypocet1:test      cl,bit5
         jz        Vypocet2
         call      Rozdil

Vypocet2:test      cl,bit6
         jz        Vypocet3
         call      Nasob

Vypocet3:test      cl,bit7
         jz        Vypocet4
         call      Vydel

Vypocet4:
         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax

         push      si
         mov       si,offset Cislo1         ; vòsledek operace
         call      DekVysl                  ; dek¢dov†n° vòsledku operace
         pop       si
         and       byte ptr ds:[KalParm],not bit1
         call      DispFLin
         ret

Vypocet  ENDP

; -----------------------------------------------------------------------------
;        duplikace operandu 1 do operandu 2
; -----------------------------------------------------------------------------

DuplCis  PROC      NEAR

         push      cx
         push      si
         push      di
         push      es

         mov       si,offset Cislo1
         mov       di,offset Cislo2
         push      ds
         pop       es
         mov       cx,KalNumX/2
         cld
         rep       movsw
         and       byte ptr ds:[KalParm],not bit0+bit1+bit4+bit5+bit6+bit7
         or        byte ptr ds:[KalParm],al

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

DuplCis  ENDP

; -----------------------------------------------------------------------------
;        k¢dov†n° zadanÇho á°sla z textovÇho tvaru do operandu 1
; -----------------------------------------------------------------------------

KodZad   PROC      NEAR

         push      cx
         push      si
         push      di
         push      es
         push      word ptr ds:[Zaklad]

         mov       word ptr ds:[Zaklad],10
         push      ds
         pop       es
         mov       di,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        KodZad2
         mov       di,offset Cislo2
KodZad2: mov       si,offset CisBuf         ; buffer s á°slem
         mov       cx,32                    ; poáet znakñ
         call      KalKod                   ; dek¢dov†n° á°sla

         pop       word ptr ds:[Zaklad]
         pop       es
         pop       di
         pop       si
         pop       cx
         ret

KodZad   ENDP

; -----------------------------------------------------------------------------
;        aktualizace á°sla
; -----------------------------------------------------------------------------

AktCis   PROC      NEAR

         push      si
         push      es

         push      ds
         pop       es
         mov       si,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        AktCis1
         mov       si,offset Cislo2
AktCis1: call      DekVysl                  ; dek¢dov†n° vòsledku do bufferu

         pop       es
         pop       si
         ret

AktCis   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° vòsledku z operandu DS:SI do textovÇho tvaru
; -----------------------------------------------------------------------------

DekVysl  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      word ptr ds:[Zaklad]
         push      word ptr ds:[OdsadRad]
         push      word ptr ds:[MaxDes]
         mov       bp,sp
         and       byte ptr ds:[KalParm],not bit0

; ------ standardn° nastaven° p©ep°naáñ

         mov       word ptr ds:[Zaklad],10
         mov       al,ds:[KalPrep]
         mov       cx,255
         test      al,bit7
         jz        DekVysl1
         mov       cx,3
DekVysl1:mov       ds:[OdsadRad],cx
         and       ax,31
         mov       ds:[MaxDes],ax

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,200                   ; rezerva pro dek¢dov†n° textu
         push      ss
         pop       es
         mov       di,sp                    ; buffer k dek¢dov†n° á°sla

; ------ dek¢dov†n° á°sla do bufferu

         call      KalDek                   ; dek¢dov†n° á°sla na textovò tvar

; ------ dÇlka textu á°sla vòsledku

         call      MazCis                   ; vymaz†n° bufferu á°sla
         mov       si,sp

         mov       cx,di
         sub       cx,sp                    ; dÇlka textu
         cmp       cx,31
         jbe       DekVysl2

         mov       cx,31
         cmp       byte ptr es:[si],"-"
         jne       DekVysl2
         inc       cx
DekVysl2:mov       ds:[CisNum],cl
         jcxz      DekVysl8

; ------ p©enesen° á°sla do bufferu

         cmp       byte ptr es:[si],"-"
         jne       DekVsl22
         dec       byte ptr ds:[CisNum]
DekVsl22:mov       di,offset CisBuf + 32
         sub       di,cx
DekVysl3:mov       al,es:[si]
         cmp       al,"."
         jne       DekVysl4
         or        byte ptr ds:[KalParm],bit0
DekVysl4:mov       ds:[di],al
         inc       si
         inc       di
         loop      DekVysl3


DekVysl8:cmp       word ptr ds:[CisBuf+30],"0-"
         jne       DekVysl9
         mov       word ptr ds:[CisBuf+30],"0 "

; ------ n†vrat registrñ

DekVysl9:mov       sp,bp
         pop       word ptr ds:[MaxDes]
         pop       word ptr ds:[OdsadRad]
         pop       word ptr ds:[Zaklad]
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekVysl  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° bufferu á°sla
; -----------------------------------------------------------------------------

MazCis   PROC      NEAR

         push      ax
         push      cx
         push      di
         push      es

         push      ds
         pop       es
         mov       al," "
         mov       di,offset CisBuf
         cld
         mov       cx,31
         rep       stosb
         mov       al,"0"
         stosb
         mov       ds:[CisNum],0

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

MazCis   ENDP

; -----------------------------------------------------------------------------
;        nulov†n° aktu†ln°ho á°sla
; -----------------------------------------------------------------------------

NulCis   PROC      NEAR

         push      ax
         push      cx
         push      di
         push      es

         push      ds
         pop       es

         mov       di,offset Cislo1
         test      byte ptr ds:[KalParm],bit3
         jz        NulCis1
         mov       di,offset Cislo2
NulCis1: mov       cx,KalNumX/2
         xor       ax,ax
         rep       stosw

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

NulCis   ENDP

; *****************************************************************************
;                               DispFMnu
;                   zobrazen° kl†vesovÇho kalkul†toru
; -----------------------------------------------------------------------------
; VSTUP:
;        DS=datovò segment
; *****************************************************************************
;˛
DispFMnu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ horn° okraj kalkul†toru

         mov       dx,word ptr ds:[MnuPoz]  ; poá†teán° pozice
         mov       cl,ds:[MnuSir]           ; ®°©ka
         mov       ah,ds:[ColKal1]          ; barva podkladu
         mov       al,218
         call      Disp1Chr                 ; levò horn° roh
         mov       al,196
         dec       cx
         dec       cx
         call      DispChr
         mov       al,191
         call      Disp1Chr                 ; pravò horn° roh

; ------ doln° okraj kalkul†toru

         add       dh,ds:[MnuSir+1]
         dec       dh
         mov       dl,ds:[MnuPoz]
         mov       al,192
         call      Disp1Chr                 ; pravò doln° roh
         mov       al,196
         call      DispChr                  ; linka
         mov       al,217
         call      Disp1Chr                 ; pravò doln° roh

; ------ zobrazen° podkladu kalkul†toru

         mov       dx,word ptr ds:[MnuPoz]  ; poá†teán° pozice
         mov       cx,word ptr ds:[MnuSir]  ; ®°©ka a vò®ka okna
         sub       ch,2
         sub       cl,2
         inc       dh
         mov       ah,ds:[ColKal1]          ; barva podkladu
DispFMn1:push      dx
         mov       al,179                   ; levò okraj
         call      Disp1Chr                 ; zobrazen° levÇho okraje
         mov       al," "                   ; mazac° znak
         call      DispChr
         mov       al,179
         call      Disp1Chr
         pop       dx
         inc       dh
         dec       ch
         jnz       DispFMn1

; ------ zobrazen° r†mu displeje

         mov       dx,word ptr ds:[MnuPoz]
         inc       dh
         add       dl,2
         sub       cl,4

         mov       ah,ds:[ColKal2]
         mov       bh,ds:[ColKal3]
         mov       bl,bh
         and       bh,0f0h
         or        bh,ah

         mov       ah,bh
         push      dx
         mov       al,219
         call      Disp1Chr
         mov       al,223
         call      DispChr
         mov       al,219
         call      Disp1Chr
         pop       dx
         inc       dh

         push      dx
         mov       ah,bh
         mov       al,219
         call      Disp1Chr
         mov       ah,bl
         mov       al," "
         call      DispChr
         mov       al,219
         mov       ah,bh
         call      Disp1Chr
         pop       dx
         inc       dh

         mov       ah,bh
         push      dx
         mov       al,219
         call      Disp1Chr
         mov       al,220
         call      DispChr
         mov       al,219
         call      Disp1Chr
         pop       dx
         inc       dh

; ------ zobrazen° p©ep°naáñ kalkul†torñ

         call      DispFPr

; ------ zobrazen° ©†dku displeje (s á°slem)

         call      DispFLin

; ------ zobrazen° v®ech kl†ves

         xor       al,al                    ; poá†teán° kl†vesa 0
DispFMn4:call      DispFKlv                 ; zobrazen° kl†vesy AL
         inc       al
         cmp       al,24
         jb        DispFMn4

; ------ zobrazen° licenán°ho textu

         push      ds
         pop       es
         mov       dx,word ptr ds:[MnuPoz]
         add       dl,4
         add       dh,ds:[MnuSir+1]
         mov       si,offset LicTxt
         mov       cl,offset(LicTxt0-LicTxt)
         mov       ah,0fh
         call      DispTxt

; ------ n†vrat registrñ

         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      DispMHlp
         ret

DispFMnu ENDP

; *****************************************************************************
;                             DispFPr
;                zobrazen° p©ep°naáñ kalkul†toru
; -----------------------------------------------------------------------------
; VSTUP:
;        DS=datovò segment
; *****************************************************************************

DispFPr  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

         push      ds
         pop       es

         mov       al,"-"
         test      byte ptr ds:[KalPrep],bit7
         jz        DispFPr1
         mov       al,251
DispFPr1:mov       byte ptr ds:[KalTis],al

         cld
         mov       al,ds:[KalPrep]
         and       al,not bit7
         mov       di,offset KalZaokr
         mov       cl,10
         xor       ah,ah
         div       cl                       ; vòpoáet á°slic
         add       al,"0"                   ; korekce na znak ASCII
         cmp       al,"0"                   ; je prvn° znak 0 ?
         jne       DispFPr2                 ; nen° 0
         mov       al," "                   ; n†hrada mezerou
DispFPr2:stosb                              ; uloëen° prvn° á°slice
         mov       al,ah                    ; druhÇ á°slo
         add       al,"0"                   ; korekce na á°slici
         stosb                              ; uloëen° druhÇ á°slice

         mov       dx,word ptr ds:[MnuPoz]
         add       dl,4
         add       dh,4
         mov       si,offset FKalMLA1
         mov       cx,offset(FKalMLA2-FKalMLA1)
         mov       ah,ds:[ColKal1]
         call      DispTxt

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispFPr  ENDP

; *****************************************************************************
;                            DispFLin
;                     zobrazen° ©†dku displeje
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice kalkul†toru
;        DS=datovò segment
; *****************************************************************************

DispFLin PROC      NEAR

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

         push      ds
         pop       es
         mov       dx,word ptr ds:[MnuPoz]
         mov       si,offset CisBuf
         add       dl,4
         add       dh,2

         mov       al,"M"
         mov       ah,ds:[ColKalI]
         test      byte ptr ds:[KalParm],bit2
         jnz       DispFLn2
         mov       al," "
DispFLn2:call      Disp1Chr

         mov       ah,ds:[ColKal3]
         mov       cl,32
         call      DispTxt

         mov       ah,ds:[ColKalI]
         mov       cl,ds:[KalParm]
         mov       al,"+"
         test      cl,bit4
         jnz       DispFLn4
         mov       al,"-"
         test      cl,bit5
         jnz       DispFLn4
         mov       al,"*"
         test      cl,bit6
         jnz       DispFLn4
         mov       al,"/"
         test      cl,bit7
         jnz       DispFLn4
         mov       al," "
DispFLn4:call      Disp1Chr

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

DispFLin ENDP

; *****************************************************************************
;                              BlikFKlv
;                       zablik†n° kl†vesy AL
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice kalkul†toru
;        AL=kl†vesa k zobrazen°
;        DS=datovò segment
; *****************************************************************************

BlikFKlv PROC      NEAR

         push      cx

         push      ax
         mov       ah,1
         int       16h
         pop       ax
         jnz       BlikFKl2

         call      NDspFKlv
         mov       cx,2
         call      Cekej
         call      DispFKlv
;         dec       cx
;         call     Cekej

BlikFKl2:pop       cx
         ret

BlikFKlv ENDP

; *****************************************************************************
;                              NDspFKlv
;                vypnut° zobrazen° kl†vesy kalkul†toru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice kalkul†toru
;        AL=kl†vesa k vypnut°
;        DS=datovò segment
; *****************************************************************************

NDspFKlv PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

         mov       dx,word ptr ds:[MnuPoz]  ; pozice kalkul†toru

         mov       si,offset KalKey         ; definice kl†ves
         mov       ah,6                     ; poáet bajtñ na kl†vesu
         mul       ah                       ; offset v tabulce kl†ves
         add       si,ax                    ; definice kl†vesy
         add       dx,ds:[si]               ; pozice kl†vesy

         mov       ch,3                     ; poáet ©†dkñ
         mov       ah,ds:[ColKal1]          ; podklad
         mov       al," "
         mov       cl,5
NDspFKl1:push      dx
         call      DispChr
         pop       dx
         inc       dh
         dec       ch
         jnz       NDspFKl1

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

NDspFKlv ENDP


; *****************************************************************************
;                              DispFKlv
;                   zobrazen° kl†vesy kalkul†toru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=definice kalkul†toru
;        AL=kl†vesa k zobrazen°
;        DS=datovò segment
; *****************************************************************************

DispFKlv PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         mov       dx,word ptr ds:[MnuPoz]  ; pozice kalkul†toru

         mov       si,offset KalKey         ; definice kl†ves
         mov       ah,6                     ; poáet bajtñ na kl†vesu
         mul       ah                       ; offset v tabulce kl†ves
         add       si,ax                    ; definice kl†vesy

         add       dx,ds:[si]               ; pozice kl†vesy
         inc       si
         inc       si

         xor       bx,bx
         mov       bl,ds:[si]               ; barva
         mov       bh,ds:[bx+ColKal4]       ; barva kl†vesy
         mov       bl,ds:[ColKal1]          ; podklad
         and       bl,0f0h                  ; pozad° podkladu
         mov       ah,bh                    ; barva kl†vesy
         shr       ah,1
         shr       ah,1
         shr       ah,1
         shr       ah,1                     ; pozad° kl†vesy
         or        bl,ah                    ; barva okrajñ kl†vesy

; ------ horn° okraj

         mov       ah,bl
         mov       al,220
         push      dx
         mov       cl,5
         call      DispChr
         pop       dx
         inc       dh

; ------ st©edn° ©†dek

         inc       si
         push      dx
         mov       ah,bh
         mov       al," "
         mov       cx,4
DispFKl4:cld
         call      Disp1Chr
         lodsb
         loop      DispFKl4
         mov       al," "
         call      Disp1Chr
         pop       dx
         inc       dh

; ------ spodn° okraj

         mov       ah,bl
         mov       al,223
         mov       cl,5
         call      DispChr

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispFKlv ENDP

; *****************************************************************************
;                               KalKod
;            k¢dov†n° á°sla z textovÇho do vnit©n°ho tvaru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text s á°slem k dek¢dov†n°
;        CX=poáet bajtñ textu
;        ES:DI=buffer k uloëen° á°sla KalNumX bajtñ
;        DS=datovò segment
; VùSTUP:CY=chybnÇ zad†n° á°sla (nen° ë†dn† á°slice)
;        DS:SI=nov† adresa textu
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-KalNumD-2]=vzorek pro dek¢dov†n° desetin
;                   SS:[BP-KalNumD-4]=adresa k uloëen° á°sla
;                   SS:[BP-KalNumD-6]=p©°znaky: bit0=bylo m°nus
; *****************************************************************************

KalKod   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      bp
         mov       bp,sp

; ------ inicializace registrñ

         sub       sp,KalNumD+6             ; vytvo©en° m°sta pro promànnÇ
         mov       ss:[bp-KalNumD-4],di     ; adresa á°sla
         mov       word ptr ss:[bp-KalNumD-6],0

; ------ inicializaán° vymaz†n° á°sla

         push      cx
         mov       cx,KalNumX/2             ; poáet slov á°sla
         xor       ax,ax
         cld
         rep       stosw                    ; vymaz†n° á°sla

; ------ inicializace vzorku pro desetiny

         push      es
         push      ss
         pop       es
         lea       di,ss:[bp-KalNumD-2]     ; vzorek pro dek¢dov†n° desetin
         cld
         xor       ax,ax                    ; nulovac° slovo
         mov       cx,KalNumD/2             ; poáet slov desetin
         rep       stosw                    ; inicializace vzorku
         inc       ax
         stosw                              ; cel† á†st = 1
         pop       es
         pop       cx

; ------ naáten° prvn° á°slice

KalKod01:call      KalCis                   ; naáten° prvn° á°slice
         jnc       KalKod2                  ; znak je OK
         cmp       al,"."                   ; jsou desetiny ?
         je        KalKod5                  ; jsou desetiny
         cmp       al,","                   ; jsou desetiny ?
         je        KalKod5                  ; jsou desetiny
         cmp       al,"-"
         je        KalKod02
         stc
         jmp       KalKod9                  ; chyba - neplatnò znak
KalKod02:inc       si
         dec       cx
         xor       byte ptr ss:[bp-KalNumD-6],bit0
         jmp       short KalKod01

; ------ naáten° jednÇ á°slice celÇ á†sti

KalKod1: call      KalCis                   ; naáten° á°slice
         jnc       KalKod2                  ; znak je OK
         cmp       al,"."                   ; jsou desetiny ?
         je        KalKod5                  ; jsou desetiny
         cmp       al,","                   ; jsou desetiny ?
         je        KalKod5                  ; jsou desetiny
         jmp       KalKod8                  ; nen° dal®° platnò znak - konec

; ------ vyn†soben° celÇ á†sti á°sla á°selnòm z†kladem

KalKod2: push      ax                       ; £schova novÇ á°slice
         push      cx
         push      si                       ; £schova adresy textu
         mov       cx,KalNumN/2             ; poáet slov k n†soben°
         xor       si,si                    ; p©ednastaven° p©enosu
         mov       di,ss:[bp-KalNumD-4]     ; adresa k uloëen° á°sla
         add       di,KalNumD               ; adresa celoá°selnÇ á†sti
         cld
KalKod3: mov       ax,es:[di]               ; slovo á°sla
         mul       word ptr ds:[Zaklad]     ; vyn†soben° á°selnòm z†kladem
         add       ax,si                    ; p©enos z p©ede®lÇho slova
         adc       dx,0                     ; p©enos pro dal®° slovo
         mov       si,dx                    ; £schova p©enosu pro dal®° slovo
         stosw                              ; uloëen° slova á°sla
         loop      KalKod3                  ; n†soben° dal®°ho slova á°sla
         pop       si
         pop       cx
         pop       ax                       ; n†vrat novÇ á°slice
         or        dx,dx                    ; je p©eteáen° á°sla ?
         stc                                ; p©°znak chyby
         jnz       KalKod9                  ; p©eteáen° á°sla

; ------ p©iáten° novÇ á°slice

         mov       di,ss:[bp-KalNumD-4]     ; adresa k uloëen° á°sla
         add       di,KalNumD               ; adresa celoá°selnÇ á†sti
         add       es:[di],ax               ; p©iáten° á°sla
         push      cx
         mov       cx,KalNumN/2-1           ; poáet slov celÇ á†sti á°sla - 1
KalKod4: inc       di
         inc       di
         adc       word ptr es:[di],0       ; p©enos do vy®®°ho slova
         loop      KalKod4                  ; dal®° slovo
         pop       cx
         jc        KalKod9                  ; p©eteáen° á°sla
         jmp       short KalKod1            ; dek¢dov†n° dal®° á°slice

; ------ bude dek¢dov†n° desetinnÇ á†sti á°sla

KalKod5: inc       si                       ; p©eskoáen° znaku desetin "."
         dec       cx

; ------ vòpoáet novÇho vzorku pro dek¢dov†n° desetin á°sla

KalKod6: push      bp
         push      cx
         mov       cx,KalNumD/2+1           ; poáet slov vzorku
         xor       dx,dx                    ; p©ednastaven° starÇho zbytku
KalKod77:dec       bp
         dec       bp
         mov       ax,ss:[bp]               ; slovo vzorku
         div       word ptr ds:[Zaklad]     ; vòpoáet novÇho slova vzorku
         mov       ss:[bp],ax               ; uloëen° novÇho slova vzorku
         loop      KalKod77                 ; dàlen° dal®°ho slova vzorku
         pop       cx
         pop       bp

; ------ p©°prava k dek¢dov†n° desetinnÇ á†sti á°sla

         call      KalCis                   ; naáten° dal®° á°slice
         jc        KalKod8                  ; konec á°sla
         push      bx
         push      cx
         push      si
         push      bp
         xor       ah,ah                    ; AX=naátenÇ á°slo
         mov       bx,ax                    ; £schova á°sla
         mov       cx,KalNumD/2             ; poáet slov desetinnÇ á†sti
         mov       di,ss:[bp-KalNumD-4]     ; adresa k uloëen° á°sla
         lea       si,ss:[bp-KalNumD-2]     ; vzorek pro dek¢dov†n° desetin
         xor       bp,bp                    ; p©ednastaven° £schovy p©enosu
         cld

; ------ dek¢dov†n° jednÇ á°slice

KalKod7: mov       ax,ss:[si]               ; vzorek pro dek¢dov†n° desetin
         mul       bx                       ; vyn†soben° á°slem
         add       ax,bp                    ; p©iáten° starÇho p©enosu
         adc       dx,0                     ; novò p©enos
         add       es:[di],ax               ; p©iáten° novÇho slova
         adc       dx,0                     ; novò p©enos
         mov       bp,dx                    ; £schova p©enosu
         inc       si
         inc       si
         inc       di
         inc       di
         loop      KalKod7                  ; vyn†soben° dal®°ho slova

         pop       bp
         pop       si
         pop       cx
         pop       bx
         jmp       short KalKod6

; ------ konec dek¢dov†n° á°sla (OK)

KalKod8: test      byte ptr ss:[bp-KalNumD-6],bit0 ; z†pornÇ á°slo ?
         jz        KalKod9                  ; nebylo z†pornÇ á°slo
         push      si
         mov       si,ss:[bp-KalNumD-4]     ; adresa á°sla
         call      KalNeg                   ; negace á°sla
         pop       si
         clc

; ------ n†vrat registrñ

KalKod9: mov       sp,bp
         pop       bp
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalKod   ENDP

; -----------------------------------------------------------------------------
;        naáten° jednÇ á°slice á°sla
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text
;        CX=á°taá znakñ
; VùSTUP:CY=chybnò znak (konec textu)
;        AL=á°slo (je-li platnò znak) nebo znak (nen°-li á°slice)
; -----------------------------------------------------------------------------

KalCis   PROC      NEAR

; ------ naáten° znaku

         cld
KalCis1: call      KalChr                   ; naáten° znaku
         jc        KalCis9                  ; konec textu

; ------ p©evod á°slice na á°slo

KalCis2: sub       al,"0"
         jb        KalCis8                  ; nen° platnò znak
         cmp       al,10
         cmc
         jnc       KalCis9                  ; je platnò znak á°slice
         sub       al,7                     ; korekce p°smene HEX
         cmp       al,10
         jb        KalCis8                  ; nen° platnò znak
         cmp       al,byte ptr ds:[Zaklad]  ; je platn† á°slice ?
         cmc
         jnc       KalCis9                  ; je platn† á°slice

; ------ p©i chybnÇm znaku n†vrat ukazatele znakñ

KalCis8: call      KalRet
         mov       al,ds:[si]               ; p©ipravenò znak
KalCis9: ret

KalCis   ENDP

; -----------------------------------------------------------------------------
;        n†vrat znaku v textu kalkul†toru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel textu
;        CX=poáet zbylòch znakñ
; VùSTUP:CY
; -----------------------------------------------------------------------------

KalRet   PROC      NEAR

         dec       si
         inc       cx
         stc
         ret

KalRet   ENDP

; -----------------------------------------------------------------------------
;        áten° znaku pro kalkul†tor
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel textu
;        CX=poáet zbylòch znakñ
; VùSTUP:CY=nen° dal®° znak
; -----------------------------------------------------------------------------

KalChr   PROC      NEAR

         stc                                ; p©°znak chyby
         jcxz      KalChr9                  ; nen° dal®° znak

         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

         cmp       al," "                   ; je mezera ?
         je        KalChr                   ; je mezera - vypu®tàn°
         cmp       al,"'"                   ; je oddàlovaá ?
         je        KalChr                   ; je oddàlovaá - vypu®tàn°
         cmp       al,"`"                   ; je oddàlovaá ?
         je        KalChr                   ; je oddàlovaá - vypu®tàn°

         cmp       al,"#"                   ; dekadick† soustava ?
         jne       KalChr3
         mov       byte ptr ds:[Zaklad],10
         mov       byte ptr ds:[OdsadRad],3
         jmp       short KalChr

KalChr3: cmp       al,"$"
         jne       KalChr4
         mov       byte ptr ds:[Zaklad],16
         mov       byte ptr ds:[OdsadRad],4
         jmp       short KalChr

KalChr4: cmp       al,"%"
         jne       KalChr5
         mov       byte ptr ds:[Zaklad],2
         mov       byte ptr ds:[OdsadRad],8
         jmp       short KalChr

KalChr5: cmp       al,"@"
         jne       KalChr6
         mov       byte ptr ds:[Zaklad],8
         mov       byte ptr ds:[OdsadRad],7
         jmp       short KalChr

KalChr6: cmp       al,"~"
         jne       KalChr7
         mov       byte ptr ds:[Zaklad],36
         mov       byte ptr ds:[OdsadRad],255
         jmp       short KalChr

KalChr7:
         cmp       al,"a"
         jb        KalChr2
         cmp       al,"z"
         ja        KalChr2
         sub       al,32                    ; korekce na velkÇ p°smeno
KalChr2: clc                                ; p©°znak operace OK

KalChr9: ret

KalChr   ENDP


; *****************************************************************************
;                               KalDek
;                 dek¢dov†n° á°sla na textovò tvar
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=á°slo k dek¢dov†n°
;        ES:DI=adresa k uloëen° textu á°sla
; VùSTUP:ES:DI=adresa za koncem á°sla
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-KalNumX]=uschovanÇ á°slo (KalNumX bajtñ)
;                   SS:[BP-KalNumX-2]=á°seln† soustava (slovo 2 aë asi 192)
;                   SS:[BP-KalNumX-4]=á°taá slov v z†sobn°ku
;                   SS:[BP-KalNumX-6]=ukl†dac° adresa DI
;                   SS:[BP-KalNumX-8]=maxim†ln° poáet desetinnòch m°st
;                   SS:[BP-KalNumX-10]=odsazen° ©†dñ (poáet cifer)
; *****************************************************************************

KalDek   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      bp
         push      ds
         mov       bp,sp

; ------ vytvo©en° m°sta pro lok†ln° promànnÇ

         sub       sp,KalNumX+10            ; m°sto pro lok†ln° promànnÇ

; ------ inicializace lok†ln°ch promànnòch

         mov       ax,ds:[Zaklad]           ; z†klad á°selnÇ soustavy
         mov       word ptr ss:[bp-KalNumX-2],ax ; á°seln† soustava
         mov       word ptr ss:[bp-KalNumX-4],0  ; á°taá slov v z†sobn°ku
         mov       word ptr ss:[bp-KalNumX-6],di ; £schova ukl†dac° adresy DI
         mov       ax,ds:[MaxDes]           ; max. poáet desetinnòch m°st
         mov       ss:[bp-KalNumX-8],ax     ; max. poáet desetinnòch m°st
         mov       ax,ds:[OdsadRad]         ; odsazen° ©†dñ
         mov       ss:[bp-KalNumX-10],ax    ; odsazen° ©†dñ (poáet cifer)

; ------ £schova á°sla do z†sobn°ku

         push      es                       ; £schova ukl†dac° adresy
         push      ss
         pop       es                       ; ES <- SS buffer v z†sobn°ku
         lea       di,ss:[bp-KalNumX]       ; buffer k £schovà á†sti á°sla
         mov       cx,KalNumX/2             ; dÇlka á°sla
         cld
         rep       movsw                    ; p©enesen° á°sla do z†sobn°ku
         pop       es                       ; segment ukl†dac° adresy
         push      ss
         pop       ds                       ; DS <- SS

; ------ dek¢dov†n° znamÇnka á°sla

         test      byte ptr ss:[bp-1],80h   ; je to z†pornÇ á°slo ?
         jz        KalDek12                 ; je to kladnÇ á°slo

         mov       di,ss:[bp-KalNumX-6]     ; ukl†dac° adresa á°sla
         mov       al,"-"                   ; znamÇnko "-"
         cld
         stosb                              ; uloëen° znamÇnka
         mov       ss:[bp-KalNumX-6],di     ; nov† ukl†dac° adresa

         push      es
         push      ss
         pop       es
         lea       si,[bp-KalNumX]          ; buffer á°sla
         call      KalNeg                   ; negace á°sla DS:SI
         pop       es

; ------ p©°prava k dek¢dov†n° celÇ á†sti á°sla

KalDek12:mov       bx,ss:[bp-KalNumX-2]     ; á°seln† soustava
KalDek1: mov       cx,KalNumN/2             ; poáet slov celÇ á†sti á°sla
         lea       si,ss:[bp-2]             ; posledn° slovo á°sla
         xor       dx,dx                    ; p©ednastaven° p©enosu na 0
         xor       di,di                    ; st©adaá kontroly 0 á°sla
         std                                ; smàr posunu ukazatele dolñ

; ------ vydàlen° celÇ á†sti á°sla z†kladem á°selnÇ soustavy

KalDek2: lodsw                              ; naáten° dal®°ho slova á°sla
         div       bx                       ; vydàlen° z†kladem á°selnÇ soustavy
         mov       ds:[si+2],ax             ; £schova novÇho pod°lu
         or        di,ax                    ; st©adaá kontroly 0 á°sla
         loop      KalDek2                  ; dàlen° dal®°ho slova

; ------ korekce dek¢dovanÇho á°sla na znak ASCII

         cmp       dl,10                    ; je > 10
         jb        KalDek3
         add       dl,7                     ; korekce na p°smeno
KalDek3: add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; £schova á°slice do z†sobn°ku
         inc       word ptr ss:[bp-KalNumX-4] ; zvò®en° á°taáe slov v z†sobn°ku

; ------ nen°-li je®tà 0, vòpoáet dal®° á°slice

         or        di,di                    ; je á°slo jië 0 ?
         jnz       KalDek1                  ; á°slo je®tà nen° 0 - dal®° á°slice

; ------ vòpoáet odsazen° ©†dñ

         mov       cx,ss:[bp-KalNumX-10]    ; odsazen°
         mov       ax,ss:[bp-KalNumX-4]     ; poáet slov v z†sobn°ku
         dec       ax
         div       cl                       ; vòpoáet zbytku v ©†du
         mov       dl,ah                    ; £schova á°taáe znakñ v ©†du
;         or        dl,dl
;         jnz       KalDek33
;         mov       dl,ss:[bp-KalNumX-10]
         inc       dl
         mov       cx,ss:[bp-KalNumX-4]     ; poáet slov v z†sobn°ku

; ------ uloëen° celÇ á†sti á°sla do bufferu

         mov       di,ss:[bp-KalNumX-6]     ; n†vrat ukl†dac° adresy do bufferu
         cld                                ; smàr nahoru
KalDek4: pop       ax                       ; n†vrat á°sla ze z†sobn°ku
         stosb                              ; uloëen° á°sla do vòstupu
         dec       dl                       ; sn°ëen° á°taáe znakñ v ©†du
         jnz       KalDek44
         mov       dl,ss:[bp-KalNumX-10]    ; odsazen°
         cmp       cx,1                     ; je jië posledn° á°slice ?
         je        KalDek44                 ; je jië posledn° á°slice
         mov       al,"'"                   ; oddàlovac° mezera
         stosb                              ; oddàlovac° mezera
KalDek44:loop      KalDek4                  ; n†vrat dal®° á°slice

; ------ uloëen° oddàlovac° teáky

         mov       al,"."                   ; oddàlovac° teáka
         stosb                              ; uloëen° oddàlovac° teáky

; ------ p©°prava k dek¢dov†n° desetinnÇ á†sti á°sla

         mov       cx,ss:[bp-KalNumX-8]     ; maxim†ln° poáet m°st
;         mov       ax,ss:[bp-KalNumX-10]    ; á°taá ©†dñ (odsazen°)
;         inc       ax                       ; p©ednastaven°
         jcxz      KalDek60

; ------ uloëen° oddàlovaáe ©†dñ

KalDek5:; dec       ax
        ; jnz       KalDek51
        ; mov       al,"'"                   ; oddàlovac° mezera
        ; stosb                              ; uloëen° mezery
        ; mov       ax,ss:[bp-KalNumX-10]    ; novò á°taá ©†dñ

; ------ dek¢dov†n°

KalDek51:;push      ax                       ; á°taá ©†dñ (odsazen°)
         push      cx                       ; á°taá maxim†ln°ho poátu á°slic
         push      bp                       ; ukazatel parametrñ v z†sobn°ku
         push      di                       ; ukl†dac° adresa na vòstup

         xor       di,di                    ; p©ednastaven° £schovy p©enosu
         xor       si,si                    ; st©adaá pro test 0
         sub       bp,KalNumX               ; nejnië®° slovo desetin
         mov       cx,KalNumD/2             ; poáet slov desetinnÇ á†sti

; ------ dek¢dov†n° jednÇ á°slice desetinnÇ á†sti á°sla

KalDek52:mov       ax,ss:[bp]               ; slovo desetinnÇ á†sti
         mul       bx                       ; vyn†soben° á°selnòm z†kladem
         add       ax,di                    ; p©iáten° p©enosu
         adc       dx,0                     ; p©enos
         mov       ss:[bp],ax               ; novÇ á°slo
         or        si,ax                    ; st©adaá pro test 0 á°sla
         mov       di,dx                    ; £schova p©enosu
         inc       bp
         inc       bp
         loop      KalDek52                 ; vyn†soben° dal®°ho slova á°sla

         pop       di                       ; ukl†dac° adresa na vòstup
         pop       bp                       ; ukazatel parametrñ v z†sobn°ku
         pop       cx                       ; á°taá max. poátu á°slic
        ; pop       ax                       ; á°taá ©†dñ (odsazen°)

; ------ uloëen° dek¢dovanÇho znaku

         cmp       dl,10                    ; p©enos p©es teáku
         jb        KalDek6
         add       dl,7                     ; korekce na p°smeno
KalDek6: add       dl,"0"                   ; korekce na znak ASCII
         mov       es:[di],dl               ; uloëen° á°slice do bufferu
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ test, zda bude dal®° á°slice

         or        si,si                    ; je á°slo jië 0 ?
         loopnz    KalDek5                   ; dek¢dov†n° dal®° á°slice

; ------ zaokrouhlen° á°sla

KalDek60:push      di
         cmp       byte ptr ss:[bp-KalNumN-1],80h ; je zbytek > 0.5 ?
         jb        KalDek66                 ; zaokrouhlen° se nedàl†
         mov       ah,ss:[bp-KalNumX-2]     ; á°seln† soustava
         add       ah,"0"-1                 ; maxim†ln° znak
         cmp       ah,"9"
         jbe       KalDek61
         add       ah,7
KalDek61:dec       di
         cmp       di,ss:[bp-KalNumX-6]     ; je jië zaá†tek textu ?
         jb        KalDek62                 ; je zaá†tek - p©eteáen°, odsun
         mov       al,es:[di]
         cmp       al,"."
         je        KalDek61                 ; p©eskoáen° teáky
         cmp       al," "
         je        KalDek61                 ; p©eskoáen° mezery
         cmp       al,"'"
         je        KalDek61                 ; p©eskoáen° oddàlovaáe
         cmp       al,"`"
         je        KalDek61                 ; p©eskoáen° oddàlovaáe
         inc       al                       ; p©enos
         cmp       al,"9"+1
         jne       KalDek63
         mov       al,"A"
KalDek63:mov       es:[di],al
         cmp       al,ah
         jbe       KalDek66                 ; nen° p©enos
         mov       byte ptr es:[di],"0"
         jmp       short KalDek61

; ------ p©eteáen° ©†du - mus° se odsunout

KalDek62:pop       di

         inc       di                       ; zvò®en° adresy konce
         push      di

         push      ds
         push      es
         pop       ds
         dec       di                       ; novò konec á°sla
         mov       cx,di                    ; konec á°sla
         sub       cx,ss:[bp-KalNumX-6]     ; poáet znakñ v bufferu
         mov       si,di
         dec       si
         std
         rep       movsb                    ; odsunut° á°sla
         mov       al,"1"
         stosb                              ; p©enesen† á°slice
         pop       ds

KalDek66:pop       di

; ------ odstranàn° koncovòch nul

KalDek7: dec       di                       ; posledn° znak
         cmp       byte ptr es:[di],"0"
         je        KalDek7                  ; nula se odstran°
         cmp       byte ptr es:[di]," "
         je        KalDek7                  ; mezera se odstran°
         cmp       byte ptr es:[di],"'"
         je        KalDek7                  ; oddàlovaá se odstran°
         cmp       byte ptr es:[di],"`"
         je        KalDek7                  ; oddàlovaá se odstran°
         cmp       byte ptr es:[di],"."
         je        KalDek9                  ; teáka - je to celÇ á°slo
         inc       di                       ; jinak n†vrat za posledn° á°slici

KalDek9: mov       byte ptr es:[di],0       ; ukonáovac° 0 á°sla

; ------ n†vrat registrñ

         mov       sp,bp
         pop       ds
         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalDek   ENDP

; *****************************************************************************
;                              KalInv
;                        p©evr†cen† hodnota á°sla
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=á°slo k p©epoátu
; *****************************************************************************

KalInv   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,KalNumX

; ------ kopie á°sla do bufferu

         mov       di,sp
         push      si
         push      es
         push      es
         pop       ds                       ; segment á°sla
         push      ss
         pop       es
         mov       cx,KalNumX/2
         cld
         rep       movsw                    ; p©enesen° á°sla do z†sobn°ku
         pop       es
         pop       si

; ------ inicializace á°sla na "1"

         mov       di,si
         mov       cx,KalNumX/2
         xor       ax,ax
         rep       stosw
         mov       byte ptr es:[si+KalNumD],1 ; nastaven° na 1

; ------ vydàlen° á°sla 1/x

         push      ss
         pop       ds
         mov       di,si
         mov       si,sp
         call      Vydel                   ; vydàlen° á°sla

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

KalInv   ENDP

; *****************************************************************************
;                             KalNeg
;                         negace á°sla
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=á°slo k negaci
; *****************************************************************************

KalNeg   PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      ds
         push      es
         pop       ds

; ------ inverze á°sla

         push      si
         mov       cx,KalNumX/2             ; poáet slov á°sla
KalNeg1: not       word ptr ds:[si]         ; inverze slova
         inc       si
         inc       si
         loop      KalNeg1
         pop       si

; ------ p©iáten° "1" k á°slu

         push      si
         add       word ptr ds:[si],1
         inc       si
         inc       si
         mov       cx,KalNumX/2-1           ; poáet slov á°sla
KalNeg2: adc       word ptr ds:[si],0
         inc       si
         inc       si
         loop      KalNeg2
         pop       si

; ------ n†vrat registrñ

         pop       ds
         pop       cx
         ret

KalNeg   ENDP

; *****************************************************************************
;                              KalOdm
;                         odmocnina á°sla
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=á°slo k p©epoátu
; lok†ln° promànnÇ: SS:[BP-2] segment pñvodn° adresy á°sla
;                   SS:[BP-4] offset pñvodn° adresy á°sla
;                   SS:[BP-KalNumX-4] uschovanÇ pñvodn° á°slo
;                   SS:[BP-2*KalNumX-4] mezivòsledek dàlen°
; *****************************************************************************

OPUVOD   EQU       SS:[BP-KalNumX-4]        ; uschovanÇ pñvodn° á°slo
OMEZIV   EQU       SS:[BP-2*KalNumX-4]      ; mezivòsledek dàlen°

KalOdm   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,KalNumX*2+4
         mov       ss:[bp-2],es
         mov       ss:[bp-4],si

; ------ absolutn° hodnota á°sla

         test      byte ptr es:[si+KalNumX-1],80h
         jz        KalOdm1
         call      KalNeg

; ------ kopie á°sla do bufferu

KalOdm1: lea       di,OPUVOD                ; buffer pñvodn°ho á°sla
         push      es
         pop       ds                       ; segment á°sla
         push      ss
         pop       es
         push      si
         mov       cx,KalNumX/2
         cld
         rep       movsw                    ; p©enesen° á°sla do z†sobn°ku
         pop       si

; ------ kopie á°sla do bufferu mezivòsledku

         lea       di,OMEZIV
         mov       cx,KalNumX/2
         rep       movsw                    ; kopie á°sla

         mov       dx,200                   ; maxim†ln° poáet prñchodñ

; ------ st©edn° hodnota mezivòsledku

KalOdm2: lea       di,OMEZIV+KalNumX-2      ; mezivòsledek
         mov       cx,KalNumX/2
         push      ss
         pop       ds
         clc
KalOdm21:rcr       word ptr ds:[di],1
         dec       di
         dec       di
         loop      KalOdm21

; ------ porovn†n°, zda se vòsledek je®tà màn°

         lea       si,OMEZIV+KalNumX-2
         mov       es,ss:[bp-2]
         mov       di,ss:[bp-4]
         add       di,KalNumX-2
         mov       cx,(KalNumX-4)/2
         std
         repe      cmpsw
         je        KalOdm9                  ; vòsledek se jië nemàn°

; ------ n†vrat pñvodn°ho á°sla

         mov       di,ss:[bp-4]
         lea       si,OPUVOD
         mov       cx,KalNumX/2
         cld
         rep       movsw

; ------ vydàlen° á°sla mezivòsledkem

         mov       di,ss:[bp-4]
         lea       si,OMEZIV
         call      Vydel

; ------ p©iáten° novÇho mezivòsledku ke starÇmu

         push      ss
         pop       es
         lea       di,OMEZIV
         mov       ds,ss:[bp-2]
         mov       si,ss:[bp-4]
         call      Soucet

         dec       dx
         jnz       KalOdm2

; ------ n†vrat registrñ

KalOdm9: mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

KalOdm   ENDP



; -----------------------------------------------------------------------------
;        p©iáten° á°sla DS:SI k á°slu ES:DI
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

Soucet   PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di

         mov       cx,KalNumX/2             ; poáet slov á°sla celkem
         cld
         clc
Soucet1: lodsw
         adc       es:[di],ax
         inc       di
         inc       di
         loop      Soucet1

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

Soucet   ENDP

; -----------------------------------------------------------------------------
;        odeáten° á°sla DS:SI od á°sla ES:DI
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

Rozdil   PROC      NEAR

         push      ax
         push      cx
         push      si
         push      di

         mov       cx,KalNumX/2             ; poáet slov á°sla celkem
         cld
         clc
Rozdil1: lodsw
         sbb       es:[di],ax
         inc       di
         inc       di
         loop      Rozdil1

         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

Rozdil   ENDP

; -----------------------------------------------------------------------------
;        vyn†soben° á°sla ES:DI á°slem DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ:SS:[BP-2] parametry
;                               bit 0: 1=DS:SI z†pornÇ
;                               bit 1: 1=vòsledek z†pornò
;                  SS:[BP-KalNumX*2 - 4] st©adaá mezivòsledku
; -----------------------------------------------------------------------------

NSTRADAC EQU       SS:[BP-KalNumX*2-4]

Nasob    PROC      NEAR

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
         sub       sp,KalNumX*2+4
         mov       byte ptr ss:[bp-2],0     ; parametry

; ------ absolutn° hodnota n†sobence

         push      si
         mov       si,di
         test      byte ptr es:[si+KalNumX-1],80h
         jz        Nasob12                  ; nen° z†pornò
         xor       byte ptr ss:[bp-2],bit1  ; znamÇnko vòsledku
         call      KalNeg
Nasob12: pop       si

; ------ absolutn° hodnota n†sobitele

         push      es
         push      ds
         pop       es
         test      byte ptr ds:[si+KalNumX-1],80h
         jz        Nasob13                  ; nen° z†pornò
         xor       byte ptr ss:[bp-2],bit0+bit1 ; znamÇnko vòsledku
         call      KalNeg
Nasob13: pop       es

; ------ vymaz†n° st©adaáe mezivòsledku

         push      di
         push      es
         push      ss
         pop       es
         lea       di,NSTRADAC
         mov       cx,(KalNumX*2+2)/2
         xor       ax,ax
         cld
         rep       stosw
         pop       es
         pop       di

; ------ p©°prava k n†soben° jedn°m slovem n†sobitele

         mov       cx,KalNumX/2             ; poáet slov n†sobitele celkem
         push      si
Nasob1:  lodsw                              ; slovo n†sobitele
         mov       bx,ax                    ; £schova slova n†sobitele

; ------ vyn†soben° n†sobence jedn°m slovem

         push      cx
         push      si
         push      di
         push      bp
         push      ds

         push      ss
         pop       ds
         lea       si,NSTRADAC+KalNumX      ; buffer k uloëen° mezivòsledku
         sub       si,cx
         sub       si,cx                    ; adresa k uloëen° n†sobku

         xor       bp,bp                    ; p©ednastaven° p©enosu
         mov       cx,KalNumX/2

Nasob2:  mov       ax,es:[di]               ; slovo n†sobence
         mul       bx                       ; vyn†soben°
         add       ax,bp                    ; p©iáten° starÇho p©enosu
         adc       dx,0                     ; p©enos do vy®®°ho slova
         add       ds:[si],ax               ; p©iáten° novÇho slova
         adc       dx,0
         mov       bp,dx                    ; £schova p©enosu

         inc       di
         inc       di
         inc       si
         inc       si
         loop      Nasob2

         add       ds:[si],bp

         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       cx

         loop      Nasob1
         pop       si

; ------ n†vrat znamÇnka n†sobitele

         push      es
         push      ds
         pop       es
         test      byte ptr ss:[bp-2],bit0  ; byl n†sobitel z†pornò ?
         jz        Nasob42                  ; nebyl z†pornò
         call      KalNeg                   ; n†vrat znamÇnka n†sobitele
Nasob42: pop       es

; ------ p©enos á°sla

         push      di
         lea       si,NSTRADAC+KalNumD
         push      ds
         push      ss
         pop       ds
         mov       cx,KalNumX/2
         rep       movsw
         pop       ds
         pop       si

; ------ oprava znamÇnka vòsledku

         test      byte ptr ss:[bp-2],bit1  ; m† bòt vòsledek z†pornò ?
         jz        Nasob44                  ; vòsledek nen° z†pornò
         call      KalNeg                   ; oprava znamÇnka vòsledku
Nasob44:

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

Nasob    ENDP

; -----------------------------------------------------------------------------
;        vydàlen° á°sla ES:DI á°slem DS:SI
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) segment k uloëen° vòsledku
;                   SS:[BP-4] (2) offset k uloëen° vòsledku
;                   SS:[BP-6] (2) bajt ve st©adaái
;                   SS:[BP-7] (1) maska bitu ve st©adaái
;                   SS:[BP-8] (1) parametry: bit0=z†pornò vòsledek
;                   SS:[BP-KalNumX*2 - 10] dàlenec
;                   SS:[BP-KalNumX*4 - 10] dàlitel
;                   SS:[BP-KalNumX*5 - 10] st©adaá
; -----------------------------------------------------------------------------

DDELENEC EQU       SS:[BP-KalNumX*2 - 10]
DDELITEL EQU       SS:[BP-KalNumX*4 - 10]
DSTRADAC EQU       SS:[BP-KalNumX*5 - 10]

Vydel    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ vytvo©en° bufferu v z†sobn°ku

         sub       sp,KalNumX*5 + 10

; ------ inicializace lok†ln°ch promànnòch

         mov       ss:[bp-2],es             ; segment k uloëen° vòsledku
         mov       ss:[bp-4],di             ; offset k uloëen° vòsledku
         mov       word ptr ss:[bp-6],KalNumX-1 ; offset bajtu ve st©adaái
         mov       byte ptr ss:[bp-7],80h   ; maska bitu st©adaáe
         mov       byte ptr ss:[bp-8],0     ; kladnò vòsledek

; ------ vymaz†n° bufferñ operandñ

         push      ss
         pop       es
         mov       di,sp
         mov       cx,5*KalNumX/2           ; dÇlka operandñ
         cld
         xor       ax,ax
         rep       stosw

; ------ p©enesen° dàlitele do bufferu

         lea       di,DDELITEL + KalNumX
         mov       cx,KalNumX/2
         rep       movsw                    ; p©enesen° dàlitele

; ------ p©enesen° dàlence do bufferu

         mov       ds,ss:[bp-2]             ; segment dàlence
         mov       si,ss:[bp-4]             ; dàlenec
         mov       cx,KalNumX/2
         lea       di,DDELENEC + KalNumD
         rep       movsw                    ; p©enesen° dàlence
         push      ss
         pop       ds

; ------ absolutn° hodnota dàlitele

         lea       si,DDELITEL + KalNumX
         test      byte ptr ss:[si+KalNumX-1],80h
         jz        Vydel03
         xor       byte ptr ss:[bp-8],bit0
         call      KalNeg

; ------ absolutn° hodnota dàlence

Vydel03: lea       si,DDELENEC + KalNumD
         test      byte ptr ss:[si+KalNumX-1],80h
         jz        Vydel04
         xor       byte ptr ss:[bp-8],bit0
         call      KalNeg

; ------ rotace dàlitele o bit vpravo

Vydel04: mov       cx,KalNumX               ; poáet slov
         lea       si,DDELITEL + KalNumX*2 - 2 ; dàlitel
         clc
Vydel1:  rcr       word ptr ds:[si],1
         dec       si
         dec       si
         loop      Vydel1

; ------ porovn†n° dàlence s dàlitelem

Vydel2:  mov       cx,KalNumX               ; max. poáet slov
         lea       si,DDELENEC+KalNumX*2-2  ; konec dàlence
         lea       di,DDELITEL+KalNumX*2-2  ; konec dàlitele
         std
         repe      cmpsw                    ; porovn†n° dàlence s dàlitelem
         jb        Vydel4                   ; dàlenec je men®° - nenastav° se 1

; ------ nastaven° masky ve st©adaái

         lea       si,DSTRADAC
         add       si,ss:[bp-6]             ; offset bajtu ve st©adaái
         mov       al,ss:[bp-7]             ; maska bitu ve st©adaái
         or        byte ptr ss:[si],al      ; nastaven° bitu ve st©adaái

; ------ odeáten° dàlitele od dàlence

         mov       cx,KalNumX               ; poáet slov
         lea       si,DDELITEL              ; dàlitel
         lea       di,DDELENEC              ; dàlenec
         cld
         clc
Vydel3:  lodsw
         sbb       word ptr ds:[di],ax
         inc       di
         inc       di
         loop      Vydel3

; ------ rotace dàlitele o bit vpravo

Vydel4:  mov       cx,KalNumX               ; poáet slov
         lea       si,DDELITEL + KalNumX*2 - 2 ; dàlitel
         clc
Vydel5:  rcr       word ptr ds:[si],1
         dec       si
         dec       si
         loop      Vydel5

; ------ posun masky o bit vpravo

         ror       byte ptr ss:[bp-7],1     ; rotace masky vpravo
         jnc       Vydel2                   ; dal®° bit
         dec       word ptr ss:[bp-6]       ; sn°ëen° offsetu
         jns       Vydel2                   ; dal®° slovo

; ------ nastaven° znamÇnka vòsledku

         lea       si,DSTRADAC
         test      byte ptr ss:[bp-8],bit0
         jz        Vydel7
         call      KalNeg

; ------ navr†cen° vòsledku operace

Vydel7:  mov       es,ss:[bp-2]
         mov       di,ss:[bp-4]
         mov       cx,KalNumX/2
         cld
         rep       movsw

; ------ n†vrat registrñ

         mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Vydel    ENDP

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
;                                 Cekej
;                      áek†n° po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet impulsñ 1/18 s
; *****************************************************************************

Cekej    PROC      NEAR

         push      ax
         push      cx
         push      ds

         xor       ax,ax
         mov       ds,ax
         jcxz      Cekej3
         sti

Cekej1:  mov       ax,ds:[46ch]
Cekej2:  cmp       ax,ds:[46ch]
         je        Cekej2
         loop      Cekej1

Cekej3:  pop       ds
         pop       cx
         pop       ax
         ret

Cekej    ENDP

; *****************************************************************************
;                      zobrazen° textu n†povàdy
; *****************************************************************************

DispMHlp PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      es

         mov       si,ds:[MnuHlp]

; ------ zobrazen° £vodn° mezery

         mov       ah,ds:[HelpColH]         ; barva textu n†povàdy
         mov       al," "                   ; znak £vodn° mezery
         mov       dl,0                     ; poá†teán° pozice textu
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
         call      Disp1Chr                 ; zobrazen° £vodn° mezery

; ------ zobrazen° textu n†povàdy

         mov       cx,ds:[si]               ; offset dal®°ho textu
         dec       cx
         dec       cx                       ; dÇlka textu n†povàdy
         cmp       cx,79
         jbe       DispHTx2
         mov       cx,79
DispHTx2:inc       si
         inc       si                       ; zaá†tek textu n†povàdy
         push      ds
         pop       es
         call      DispTxt                  ; zobrazen° textu n†povàdy

; ------ zobrazen° z†vàreánÇ mezery

         mov       cx,80
         sub       cl,dl
         call      DispChr                  ; zobrazen° zbytku ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispMHlp ENDP


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

Disp1Chr PROC      NEAR

         push      cx
         mov       cl,1                     ; 1 znak k z†pisu
         call      DispChr                  ; z†pis 1 znaku na displej
         pop       cx
         ret

Disp1Chr ENDP

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
         cmp       bl,59
         jb        AktParD5
         mov       bl,59
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

; -----------------------------------------------------------------------------
;        kl†vesovò kalkul†tor
; -----------------------------------------------------------------------------

ColKalI  db        0ch                      ; indik†tory na displeji
ColKal1  db        70h                      ; barva podkladu kalkul†toru
ColKal2  db        03h                      ; r†m displeje
ColKal3  db        0ah                      ; barva displeje
ColKal4  db        0fh                      ; bàënÇ kl†vesy
ColKal5  db        1eh                      ; speci†ln° kl†vesy
ColKal6  db        4eh                      ; kl†vesa C
HelpColH db        30h                      ; barva textu n†povàdy k volb†m

MnuPoz   db        19                       ; poá†teán° pozice okna
         db        2                        ; poá†teán° ©†dek okna
MnuSir   db        41                       ; ®°©ka okna
         db        18                       ; vò®ka okna

FKalMLA1 db        'Zaokrouhleni '
KalZaokr db        '00          Tisice '
KalTis   db        251
FKalMLA2 label     byte

FKalMLH1 dw        FKalMLH2-$
         db        'N=negace≥X=1/x≥O=odmocnina≥Z=zaokrouhleni≥T=tisice≥C=mazani≥M=pamet≥Esc=konec',0
FKalMLH2 dw        FKalMLH3-$
         db        'Pamet: ≥+=pricteni≥-=odecteni≥R=vyvolani obsahu≥C=nulovani≥'
FKalMLH3 dw        FKalMLH4-$
         db        'Zadejte pocet desetinnych mist 0 aë 30 a stisknete <Enter>; <Esc>=preruseni.'
FKalMLH4 label     word

LicTxt   db        ' KALK V1.1; (c) Miroslav Nemecek '
LicTxt0  label     byte

MemTxt   db        'Nedostatek pameti !',13,10,'$'

; ------ definice kl†ves kalkul†toru

KalKey   label     byte
         db        3+6,5+3*3,0,' 0 '        ; 0: "0" (pozice, ©†dek, barva, text)
         db        3+6,5+2*3,0,' 1 '        ; 1: "1"
         db        3+2*6,5+2*3,0,' 2 '      ; 2: "2"
         db        3+3*6,5+2*3,0,' 3 '      ; 3: "3"
         db        3+6,5+1*3,0,' 4 '        ; 4: "4"
         db        3+2*6,5+1*3,0,' 5 '      ; 5: "5"
         db        3+3*6,5+1*3,0,' 6 '      ; 6: "6"
         db        3+6,5,0,' 7 '            ; 7: "7"
         db        3+2*6,5,0,' 8 '          ; 8: "8"
         db        3+3*6,5,0,' 9 '          ; 9: "9"
         db        3+2*6,5+3*3,0,' . '      ; 10: "."
         db        3+3*6,5+3*3,0,'+/-'      ; 11: "+/-"
         db        3+4*6,5+3*3,1,' + '      ; 12: "+"
         db        3+4*6,5+2*3,1,' - '      ; 13: "-"
         db        3+4*6,5+1*3,1,' * '      ; 14: "*"
         db        3+4*6,5,1,' / '          ; 15: "/"
         db        3+5*6,5+3*3,1,' = '      ; 16: "="
         db        3+5*6,5,2,' C '          ; 17: "C"
         db        3+5*6,5+2*3,1,' ',251,' '; 18: "˚"
         db        3+5*6,5+1*3,1,'1/x'      ; 19: "1/x"
         db        3,5+3*3,1,'M +'          ; 20: "M+"
         db        3,5+2*3,1,'M -'          ; 21: "M-"
         db        3,5+1*3,1,'M R'          ; 22: "MR"
         db        3,5,1,'M C'              ; 23: "MC"

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

Soubor   db        'KALK.CNF',0             ; jmÇno souboru
SouborI  dw        0                        ; identifik†tor souboru (0=neplat°)

MnuHlp   dw        offset FKalMLH1          ; adresa tabulky textñ n†povàdy

; -----------------------------------------------------------------------------
;        buffery kalkul†toru
; -----------------------------------------------------------------------------

KalkCnf  db        '10'                     ; verze

CisBuf   db        31 dup(" "),'0'          ; buffer pro zad†n° á°sla
CisNum   db        0                        ; poáet á°slic v bufferu (max.31)

KalParm  db        0                        ; parametry kalkul†toru
                                            ;   bit 0: teáka byla zadan†
                                            ;   bit 1: zah†jena editace á°sla
                                            ;   bit 2: pamàü obsahuje data
                                            ;   bit 3: byl prvn° operand
                                            ;   bit 4: operace +
                                            ;   bit 5: operace -
                                            ;   bit 6: operace *
                                            ;   bit 7: operace /

KalPrep  db        bit7+12                  ; p©ep°naáe kalkul†toru
                                            ;   bit 0 aë bit6: zaokrouhlen°
                                            ;   bit 7: odsazen° tis°cñ

Zaklad   dw        10                       ; z†klad á°selnÇ soustavy
MaxDes   dw        30                       ; maxim†ln° poáet desetinnòch m°st
OdsadRad dw        3                        ; odsazen° ©†du (poáet cifer)

Cislo1   db        KalNumX dup(?)           ; á°slo 1 (operand 1, vòsledek)
Cislo2   db        KalNumX dup(?)           ; á°slo 2 (operand 2)
CisloM   db        KalNumX dup(?)           ; pamàü

KalkCnf0 label     byte                     ; konec historie

; ------ tohle v®echno se mñëe p©epsat z†sobn°kem p©i inicializaci !!!

SoubBuf  db        100 dup(?)               ; buffer jmÇna souboru

ObrSize  dw        ?                        ; velikost bufferu obrazovky (slov)
OldKurz  dw        ?                        ; uschovan† pozice kurzoru
ObrSegm  dw        ?                        ; segment bufferu obrazovky

                                            ; p©echodnò z†sobn°k - zñst†v† mu
                                            ; rezerva asi 400 slov
         dw        100h dup(?)
Zasob    label     word

CODE     ENDS

         END       Start

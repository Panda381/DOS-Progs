

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Hled†n° souborñ na disku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; N†vratovÇ k¢dy:
;      0 = nalezeny soubory
;      1 = ë†dnÇ soubory nenalezeny
;      2 = program p©eru®en bez zad†n° hled†n°
;      3 = chyba programu (nedostatek pamàti a jinÇ)

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

INDXSIZE EQU       5000                     ; maxim†ln° poáet indexñ

HISTSIZE EQU       400h                     ; velikost historie
MAXLINE  EQU       HISTSIZE-2               ; maxim†ln° dÇlka editovanÇho ©†dku
SIRKA    EQU       56                       ; ®°©ka okna voleb souborñ

VIEWBMAX EQU       1C00h                    ; velikost bufferu prohl°ëeáe
SRCBMAX  EQU       3000h                    ; velikost bufferu hled†n° textu

InfoKPoz EQU       62                       ; poá†teán° pozice inform. kurzoru
InfoKSir EQU       10                       ; ®°©ka informaán°ho kurzoru

; -----------------------------------------------------------------------------
;        atributy souborñ
; -----------------------------------------------------------------------------

RO       EQU       bit0                     ; R/O
HID      EQU       bit1                     ; HID
SYS      EQU       bit2                     ; SYS
VOL      EQU       bit3                     ; VOL
DIR      EQU       bit4                     ; DIR
ARC      EQU       bit5                     ; ARC

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ inicializace segmentovòch registrñ

Start:   sti
         push      cs
         pop       ds                       ; DS <- CS
         mov       ds:[SegPSP],es           ; £schova segmentu PSP
         push      cs
         pop       es                       ; ES <- CS

; ------ inicializace p©°kazovÇho ©†dku

         call      InitCom                  ; inicializace p©°kazovÇho ©†dku

; ------ inicializace pamàti

         call      InitMem                  ; inicializace pamàti
         jnc       Start3                   ; pamàü OK

; ------ chyba - nedostatek pamàti

Start1:  mov       si,offset UvTxt          ; £vodn° text
         call      StdErr                   ; zobrazen° textu
         mov       si,offset MemTxt         ; chybovò text
         call      StdErr                   ; hl†®en° - chyba pamàti
         mov       ax,4c02h                 ; chyba pamàti
         int       21h                      ; konec programu s chybou

; ------ skok na obsluhu ©†dkovÇho reëimu

Start3:  test      byte ptr ds:[Param],bit7 ; je p©°kazovò ©†dek ?
         jz        Start4                   ; nen° p©°kazovò ©†dek
         jmp       HledC                    ; hled†n° v ©†dkovÇm reëimu

; ------ inicializace videom¢du

Start4:  call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du
         call      PushScr                  ; £schova obsahu obrazovky

; ------ vypnut° p©°znaku BREAK

         mov       ax,3300h
         int       21h                      ; poskytnut° p©ep°naáe BREAK
         mov       ds:[OldBreak],dl         ; £schova p©ep°naáe BREAK
         mov       dl,0                     ; BREAK bude vypnut
         mov       ax,3301h
         int       21h                      ; vypnut° p©°znaku BREAK

; ------ obsluha p©eru®en°

         mov       ax,2523h
         mov       dx,offset INT23
         int       21h                      ; INT 23h se bude ignorovat
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h                      ; INT 24h se bude takÇ ignorovat

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start5

         mov       si,offset ColMono
         mov       di,offset ColCol
         mov       cx,offset(ColCol0-ColCol)
         cld
         rep       movsb

; ------ inicializace historie

Start5:  call      InitHist                 ; sestaven° jmÇna souboru historie
         call      OpenHist                 ; otev©en° souboru historie
         call      ReadHist                 ; naáten° souboru historie
         mov       word ptr ds:[DispNum],0  ; nen° nic zobrazeno

Start60: call      CRHist                   ; spoáten° ©†dkñ historie
         call      InitPred                 ; inicializace p©edvolby
         call      InitEdit                 ; p©°prava ukazatelñ editace

; ------ volba souborñ k vyhled†n°

Start6:  or        byte ptr ds:[Param],bit4 ; zad†v† se soubor
         call      Volba                    ; volba souborñ
         jnc       Start555

         and       byte ptr ds:[Param],not bit4 ; zru®en° p©°znaku zad†v†n°
         call      DispSezn                 ; zobrazen° seznamu
         test      byte ptr ds:[Param],bit0 ; bylo prvn° zad†n° ?
         jnz       VolEnt49                 ; n†vrat
         mov       al,1                     ; p©°znak p©eru®en° programu
         jmp       Main0                    ; p©eru®en° voleb

Start555:and       byte ptr ds:[Param],not bit4 ; zru®en° p©°znaku zad†v†n°

; ------ test, zda bylo nàco zad†no

         push      ds
         pop       es
         mov       di,offset EditBuff
         mov       cx,MAXLINE
         mov       al," "
         cld
         repe      scasb                    ; jsou samÇ mezery ?
         je        Start6                   ; samÇ mezery neplat°

; ------ rozbor zad†n° parametrñ

         call      Rozbor                   ; rozbor zad†n° parametrñ
         jnc       VolEnt4                  ; zad†n° OK

; ------ chyba zad†n° parametrñ
                                            ; zde je SI = adresa textu chyby
         sub       si,offset EditBuff       ; offset v editaán°m bufferu
         mov       ds:[EditKurz],si         ; offset kurzoru na ©†dku
         mov       ax,0e07h                 ; znak p°pnut°
         mov       bx,7
         call      Int10P                   ; p°pnut°
         jmp       short Start6             ; novÇ zobrazen° voleb

; ------ zru®en° stejnÇho ©†dku z bufferu historie

VolEnt4: call      LineLen                  ; stanoven° dÇlky ©†dku
         inc       cx
         inc       cx                       ; p©id†n° koncovÇho CR/LF
         call      LineSrc                  ; nalezen° stejnÇho ©†dku v bufferu
         jc        VolEnt2                  ; stejnò ©†dek nenalezen
         call      LineDel                  ; zru®en° stejnÇho ©†dku z bufferu

; ------ zaji®tàn° volnÇho m°sta v bufferu

VolEnt2: mov       ax,ds:[HistNum]          ; poáet bajtñ v bufferu historie
         add       ax,cx                    ; nov† dÇlka bufferu historie
         cmp       ax,HISTSIZE              ; je jië dost volnÇho m°sta ?
         jbe       VolEnt3                  ; je jië dost volnÇho m°sta
         mov       si,offset HistBuff       ; prvn° ©†dek v bufferu
         call      LineDel                  ; zru®en° prvn°ho ©†dku v bufferu
         jmp       short VolEnt2            ; dal®° ©†dek

; ------ vloëen° novÇho ©†dku do bufferu historie

VolEnt3: mov       di,offset HistBuff       ; buffer historie
         add       di,ds:[HistNum]          ; konec bufferu historie
         mov       si,offset EditBuff       ; editaán° buffer ©†dku
         add       ds:[HistNum],cx          ; zvò®en° velikosti dat v bufferu
         cld
         rep       movsb                    ; p©enos ©†dku do bufferu

; ------ vyhled†n° zadanÇho souboru

         or        byte ptr ds:[Param],bit0+bit2 ; prvn° zad†n° + hled†n°
         call      KurzOff
         call      HledFile
         and       byte ptr ds:[Param],not bit2 ; zru®en° p©°znaku hled†n°
VolEnt49:call      DispHlp                  ; zobrazen° n†povàdy

; ------ obsluha seznamu

VolEnt4b:call      KurzOff
         call      InpChr
         test      byte ptr ds:[Param],bit5 ; je zobrazen° F3 ?
         jnz       VolEnt4d                 ; je zobrazen° F3
         cmp       bx,4100h                 ; F7
         jne       VolEnt4c
         jmp       Start60                  ; novÇ hled†n° souboru
VolEnt4c:cmp       bl,13
         je        VolEnt5                  ; konec s ENTER
VolEnt4d:call      Sezn                     ; obsluha seznamu
         cmp       bl,27
         jne       VolEnt4b                 ; nen° konec ESC
         mov       al,1                     ; p©°znak p©eru®en° programu
Main000: jmp       Main0                    ; konec ESC

; ------ konec programu ENTER

VolEnt5: cmp       word ptr ds:[InsNum],0   ; je oznaáen nàjakò soubor ?
         jne       VolEnt6                  ; je oznaáen nàjakò soubor

; ------ zmàna adres†©e

         mov       bx,ds:[SeznAkt]          ; aktivn° poloëka
         call      GetKPth                  ; poskytnut° cesty pod kurzorem
         mov       al,0
         jc        Main000                  ; nen° ë†dn† poloëka
         cmp       byte ptr ds:[di-2],":"   ; je to ROOT ?
         je        VolEnt51                 ; je to ROOT
         mov       byte ptr ds:[di-1],0     ; jinak zkr†cen° o "\"
VolEnt51:mov       dl,ds:[ViewName]         ; oznaáen° disku
         sub       dl,"A"                   ; á°slo poëadovanÇho disku
         mov       ah,0eh
         int       21h                      ; nastaven° novÇho aktivn°ho disku
         mov       dx,offset ViewName+2
         mov       ah,3bh
         int       21h                      ; nastaven° poëadovanÇho adres†©e
         jmp       short Main00

; ------ otev©en° souboru vòpisu seznamu

VolEnt6: mov       dx,offset SoubList       ; soubor vòpisu
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en° souboru vòpisu
         mov       bx,ax                    ; identifik†tor souboru
         mov       al,2                     ; p©°znak chyby
         jc        Main0                    ; chyba vytvo©en° souboru

; ------ zobrazen° textu n†povàdy

         mov       ah,ds:[HelpCol]          ; barva textu n†povàdy
         mov       dl,0                     ; poá†teán° pozice textu
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
         mov       cl,80                    ; dÇlka textu n†povàdy
         mov       si,offset HelpTxt6       ; text n†povàdy
         push      ds
         pop       es
         call      DispTxt                  ; zobrazen° textu n†povàdy

; ------ adresa poloëky k vòpisu

         xor       bp,bp                    ; ukazatel v seznamu
         mov       es,ds:[SeznSegm]         ; segment seznamu
VolEnt61:mov       si,bp
         shl       si,1
         mov       si,ds:[si+DispIndx]      ; adresa poloëky
         test      byte ptr es:[si],bit7    ; je to oznaáen† poloëka ?
         jz        VolEnt63                 ; nen° to oznaáen† poloëka

; ------ sestaven° jmÇna poloëky

         push      bx
         mov       bx,bp                    ; á°slo poloëky
         call      GetKPth                  ; poskytnut° cesty souboru
         pop       bx
         jc        VolEnt62                 ; neplatn† poloëka
         add       si,9                     ; jmÇno souboru
VolEnt62:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         cmp       al,0
         jne       VolEnt62
         mov       word ptr ds:[di-1],0a0dh

; ------ z†pis ©†dku se jmÇnem souboru

         mov       cx,di
         sub       cx,offset ViewName-1     ; dÇlka jmÇna souboru
         mov       dx,offset ViewName       ; jmÇno souboru
         mov       ah,40h
         int       21h                      ; z†pis jmÇna souboru

; ------ dal®° soubor

VolEnt63:inc       bp                       ; zvò®en° á°sla poloëky
         cmp       bp,ds:[DispNum]          ; jsou jië v®echny poloëky ?
         jb        VolEnt61                 ; dal®° poloëka

; ------ uzav©en° souboru vòpisu

         mov       ah,3eh
         int       21h

Main00:  mov       al,0

; ------ n†vrat z programu

Main0:   push      ax
         push      cs
         pop       ds

         mov       bx,ds:[SouborI]
         or        bx,bx
         jz        Main02

         test      byte ptr ds:[Param],bit0 ; byl zad†n text ?
         jz        Main01                   ; text nebyl zad†n

         mov       ax,4200h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; resetov†n° souboru na zaá†tek

         mov       dx,offset HistBuff       ; buffer historie
         mov       cx,ds:[HistNum]          ; poáet bajtñ v bufferu
         mov       ah,40h
         int       21h                      ; uloëen° bufferu do souboru

         xor       cx,cx
         mov       ah,40h
         int       21h                      ; useknut° konce souboru

Main01:
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

Main02:
         push      cs
         pop       ds
         call      PopScr                   ; n†vrat obsahu obrazovky

         mov       dl,ds:[OldBreak]         ; pñvodn° p©°znak BREAK
         mov       ax,3301h
         int       21h                      ; n†vrat p©°znaku BREAK

         pop       ax

         mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;                              LineLen
;                  stanoven° dÇlky editovanÇho ©†dku
; -----------------------------------------------------------------------------
; VùSTUP: CX=dÇlka ©†dku (bez koncovÇho CR/LF)
; -----------------------------------------------------------------------------

LineLen  PROC      NEAR

         push      si
         mov       cx,MAXLINE               ; max. dÇlka textu
         mov       si,offset EditBuff+MAXLINE-1 ; konec bufferu
LineLen1:cmp       byte ptr ds:[si]," "     ; je platnò znak ?
         jne       LineLen2                 ; je platnò znak
         dec       si
         loop      LineLen1
LineLen2:mov       word ptr ds:[si+1],0a0dh ; oznaáen° konce ©†dku
         pop       si
         ret

LineLen  ENDP

; -----------------------------------------------------------------------------
;                                 LineSrc
;                  nalezen° stejnÇho ©†dku v bufferu
; -----------------------------------------------------------------------------
; VSTUP: CX=dÇlka ©†dku (s koncovòm CR/LF)
; VùSTUP:SI=adresa nalezenÇho ©†dku
;        CY=stejnò ©†dek nenalezen
; -----------------------------------------------------------------------------

LineSrc  PROC      NEAR

         push      ax
         push      bx
         push      di
         push      es

; ------ p©°prava registrñ

         mov       si,offset HistBuff
         mov       bx,ds:[HistLine]         ; poáet ©†dkñ v bufferu historie
         or        bx,bx                    ; je nàjakò ©†dek ?
         jz        LineSrc4                 ; nen° ë†dnò ©†dek
         push      ds
         pop       es
         cld

; ------ porovn†n° jednoho ©†dku

LineSrc1:push      si
         push      cx
         mov       di,offset EditBuff       ; editaán° buffer
         repe      cmpsb                    ; porovn†n° ©†dkñ
         pop       cx
         pop       si
         je        LineSrc6                 ; ©†dek nalezen OK

; ------ p©°prava pro dal®° ©†dek

         call      LineNxt                  ; nalezen° dal®°ho ©†dku
         dec       bx                       ; á°taá ©†dkñ
         jnz       LineSrc1                 ; porovn†n° dal®°ho ©†dku

; ------ n†vrat registrñ

LineSrc4:stc
LineSrc6:pop       es
         pop       di
         pop       bx
         pop       ax
         ret

LineSrc  ENDP

; -----------------------------------------------------------------------------
;                             LineNxt
;               nalezen° dal®°ho ©†dku v bufferu
; -----------------------------------------------------------------------------
; VSTUP: SI=souáasnò ukazatel (nesm° bòt konec bufferu histori° !)
; VùSTUP:SI=adresa dal®°ho ©†dku
; -----------------------------------------------------------------------------

LineNxt  PROC      NEAR

         inc       si
LineNxt1:inc       si
         cmp       word ptr ds:[si-2],0a0dh
         jne       LineNxt1
         ret

LineNxt  ENDP

; -----------------------------------------------------------------------------
;                             LineDel
;                      zru®en° ©†dku z bufferu
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa ©†dku v bufferu (nesm° bòt konec bufferu histori° !)
; -----------------------------------------------------------------------------

LineDel  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ zru®en° ©†dku z bufferu

         mov       di,si                    ; zaá†tek ©†dku
         call      LineNxt                  ; adresa dal®°ho ©†dku
         push      ds
         pop       es
         mov       cx,ds:[HistNum]          ; poáet bajtñ v bufferu historie
         add       cx,offset HistBuff       ; adresa konce historie
         sub       cx,si                    ; poáet zbylòch znakñ k p©°sunu
         cld
         rep       movsb                    ; p©°sun zbytku dat

; ------ oprava £daje dÇlky dat

         sub       si,di                    ; dÇlka ru®enÇho ©†dku
         sub       ds:[HistNum],si          ; oprava £daje dÇlky dat

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         ret

LineDel  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

INT24    PROC      FAR

         mov       al,0
INT23:   iret

INT24    ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Inicializace programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        p©°prava p©°kazovÇho ©†dku (CY=nen° nic zad†no)
; -----------------------------------------------------------------------------

InitCom  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es
         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       ds,ds:[SegPSP]           ; segment PSP
         mov       cl,ds:[si-1]             ; dÇlka p©°kazovÇho ©†dku
         mov       ch,0
         cld

; ------ nalezen° zaá†tku textu p©°kaz. ©†dku

InitCom1:stc                                ; p©°znak konce
         jcxz      InitCom9                 ; nen° nic zad†no
         lodsb                              ; naáten° dal®°ho znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; mezera ?
         je        InitCom1                 ; ignorov†n° mezery
         cmp       al,9                     ; tabel†tor ?
         je        InitCom1                 ; ignorov†n° tabel†toru

; ------ p©enesen° p©°kazovÇho ©†dku do bufferu

         or        byte ptr es:[Param],bit7 ; p©°znak zad†n° p©°kaz. ©†dku
         inc       cx
         dec       si                       ; n†vrat ukazatele
         mov       di,offset EditBuff       ; editaán° buffer
         mov       bx,MAXLINE               ; dÇlka edit. bufferu
         sub       bx,cx                    ; dÇlka zbytku
         rep       movsb                    ; £schova textu do bufferu
         mov       cx,bx                    ; dÇlka zbytku bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; doplnàn° mezerami
         clc                                ; p©°znak, ëe je nàco zad†no

; ------ n†vrat registrñ

InitCom9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

InitCom  ENDP

; -----------------------------------------------------------------------------
;        inicializace pamàti (CY=chyba pamàti)
; -----------------------------------------------------------------------------

InitMem  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      es

; ------ zmen®en° bloku programu

         mov       bx,SEG KonSegm           ; segment konce programu
         sub       bx,ds:[SegPSP]           ; velikost programu
         mov       es,ds:[SegPSP]           ; segment PSP
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku programu
         jc        InitMem9                 ; chyba - nedostatek pamàti

; ------ vytvo©en° bufferu pro seznam souborñ

         mov       ah,48h
         mov       bx,0fffh                 ; velikost bloku 64 KB
         int       21h                      ; p©idàlen° bloku 64 KB
         jnc       InitMem4                 ; blok p©idàlen OK
         mov       ah,48h
         int       21h                      ; p©idàlen° men®°ho bloku
         jc        InitMem9                 ; chyba pamàti
InitMem4:shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost bufferu v bajtech
         mov       ds:[SeznSegm],ax         ; segment adresy bufferu seznamu
         mov       ds:[SeznSize],bx         ; velikost bufferu seznamu
         cmp       bx,200h                  ; minim†ln° velikost bufferu (bajtñ)

; ------ n†vrat registrñ

InitMem9:pop       es
         pop       bx
         pop       ax
         ret

InitMem  ENDP

; -----------------------------------------------------------------------------
;        £schova obsahu obrazovky
; -----------------------------------------------------------------------------

PushScr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vytvo©en° bufferu pro £schovu obrazovky

         mov       al,160/16                ; poáet bajtñ na ©†dek/16
         mul       byte ptr ds:[Radku]      ; vòpoáet velikosti bufferu
         mov       bx,ax                    ; poëadovan† velikost bufferu
         mov       ah,48h
         int       21h                      ; vytvo©en° bufferu
         jnc       PushScr1                 ; buffer vytvo©en OK
         mov       ah,48h
         int       21h                      ; vytvo©en° men®°ho bufferu
         jnc       PushScr1                 ; buffer vytvo©en OK
         xor       bx,bx                    ; jinak velikost = 0
PushScr1:mov       ds:[ObrSegm],ax          ; adresa bufferu
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; p©epoáet na slova
         mov       ds:[ObrSize],bx          ; velikost bufferu (slov)

; ------ £schova obsahu obrazovky

         mov       es,ax                    ; adresa bufferu
         xor       di,di                    ; ukl†dac° adresa
         mov       cx,bx                    ; velikost bufferu (slov)
         push      ds
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

; ------ £schova kurzoru

         call      GetKurz                  ; poskytnut° pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PushScr  ENDP

; -----------------------------------------------------------------------------
;        n†vrat obsahu obrazovky
; -----------------------------------------------------------------------------

PopScr   PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ n†vrat obsahu obrazovky

         push      ds
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       cx,ds:[ObrSize]          ; velikost videopamàti
         xor       si,si
         mov       ds,ds:[ObrSegm]          ; adresa bufferu
         cld
         rep       movsw                    ; n†vrat obsahu obrazovky
         pop       ds

; ------ n†vrat kurzoru

         mov       dx,ds:[OldKurz]          ; pñvodn° pozice kurzoru
         call      SetKurz                  ; n†vrat pozice kurzoru

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         ret

PopScr   ENDP

; -----------------------------------------------------------------------------
;        sestaven° jmÇna souboru historie
; -----------------------------------------------------------------------------

InitHist PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kontrola verze systÇmu

         mov       ah,30h
         int       21h                      ; poskytnut° verze systÇmu
         cmp       al,3
         jb        InitHst5                 ; n°zk† verze systÇmu

; ------ kontrola, zda je platnÇ prost©ed°

         mov       es,ds:[SegPSP]           ; segment PSP
         mov       cx,es:[2ch]              ; segment prost©ed°
         jcxz      InitHst5                 ; nen° platnÇ prost©ed°

; ------ p©°prava k prohled†v†n° prost©ed°

         push      ds
         mov       ds,cx                    ; adresa prost©ed°
         xor       si,si                    ; poá†teán° ukazatel
         mov       cx,7fffh                 ; max. velikost prost©ed°

; ------ nalezen° jmÇna souboru v prost©ed°

         xor       ax,ax                    ; hledanÇ slovo
InitHst2:inc       si                       ; dal®° bajt
         cmp       word ptr ds:[si-1],ax    ; je konec prost©ed° ?
         loopne    InitHst2                 ; nalezen° konce prost©ed°
         pop       es                       ; ES <- datovò segment
         add       si,3                     ; zaá†tek jmÇna souboru

; ------ p©enesen° jmÇna do bufferu

         mov       di,offset SoubHist       ; buffer jmÇna souboru
         mov       cx,128                   ; max. dÇlka jmÇna
         cld
InitHst3:lodsb                              ; naáten° znaku
         cmp       al,"a"
         jb        InitHst4
         cmp       al,"z"
         ja        InitHst4
         sub       al,32                    ; korekce na velkÇ p°smeno
InitHst4:stosb                              ; uloëen° znaku do bufferu
         cmp       al,0                     ; je konec jmÇna ?
         loopne    InitHst3                 ; p©enos dal®°ho znaku
         push      es
         pop       ds                       ; DS <- datovò segment

; ------ nalezen° konce cesty

InitHst5:mov       si,offset SoubHist       ; buffer se souborem
         cld
InitHst6:mov       di,si                    ; konec cesty
InitHst7:lodsb                              ; naáten° znaku
         cmp       al,"\"                   ; oddàlovaá cesty ?
         je        InitHst6                 ; oddàlovaá cesty
         cmp       al,":"                   ; oddàlovaá disku ?
         je        InitHst6                 ; oddàlovaá disku
         cmp       al,0                     ; konec textu ?
         jne       InitHst7                 ; nen° konec textu - dal®° znak

; ------ p©id†n° jmÇna souboru histori°

         mov       si,offset SoubHst
         mov       cx,11                    ; dÇlka jmÇna
         rep       movsb                    ; p©enesen° jmÇna souboru

; ------ kopie do bufferu souboru vòpisu

         mov       cx,di
         mov       si,offset SoubHist
         mov       di,offset SoubList
         sub       cx,si                    ; dÇlka textu
         rep       movsb                    ; kopie do souboru vòpisu
         mov       byte ptr ds:[di-4],"L"   ; zmàna na p©°ponu LST

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitHist ENDP

; -----------------------------------------------------------------------------
;        otev©en° souboru historie
; -----------------------------------------------------------------------------

OpenHist PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ otev©en° souboru pro z†pis i áten°

         mov       dx,offset SoubHist       ; soubor historie
         mov       ax,3d02h
         int       21h                      ; otev©en° pro z†pis
         jnc       OpenHst7                 ; soubor otev©en OK

; ------ vytvo©en° novÇho souboru

         mov       ah,3ch
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en° souboru
         jnc       OpenHst7                 ; soubor vytvo©en OK

; ------ otev©en° souboru alespo§ pro áten°

         mov       ax,3d00h
         int       21h                      ; otev©en° alespo§ pro áten°
         jnc       OpenHst7                 ; soubor otev©en OK

; ------ £schova identifik†toru souboru

         xor       ax,ax                    ; soubor nen° otev©en
OpenHst7:mov       ds:[SouborI],ax          ; identifik†tor souboru

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

OpenHist ENDP

; -----------------------------------------------------------------------------
;        naáten° souboru historie
; -----------------------------------------------------------------------------

ReadHist PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ naáten° souboru historie

         mov       bx,ds:[SouborI]          ; identifik†tor souboru historie
         or        bx,bx
         jz        ReadHst1                 ; soubor nen° otev©en
         mov       dx,offset HistBuff       ; buffer historie
         mov       cx,HISTSIZE              ; velikost bufferu
         mov       ah,3fh
         int       21h                      ; naáten° historie
         jnc       ReadHst2                 ; áten° OK
ReadHst1:xor       ax,ax                    ; nen° nic naáteno
ReadHst2:mov       ds:[HistNum],ax          ; poáet bajtñ v bufferu

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadHist ENDP

; -----------------------------------------------------------------------------
;        spoáten° poátu ©†dkñ historie
; -----------------------------------------------------------------------------

CRHist   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ p©°prava ke spoáten° ©†dkñ

         mov       si,offset HistBuff       ; buffer historie
         mov       cx,ds:[HistNum]          ; poáet bajtñ v bufferu historie
         mov       dx,si                    ; £schova konce dat v historii
         xor       bx,bx                    ; á°taá ©†dkñ historie
         mov       ax,0a0dh                 ; hledanò konec ©†dku
         sub       cx,1                     ; 1 bajt rezerva
         jbe       CRHist4                  ; je 0 nebo 1 bajt - nen° ©†dek

; ------ spoáten° poátu ©†dkñ

CRHist1: cmp       ds:[si],ax               ; je konec ©†dku ?
         jne       CRHist2                  ; nen° konec ©†dku
         inc       bx                       ; zvò®en° á°taáe ©†dkñ
         mov       dx,si                    ; £schova konec dat
         inc       dx
         inc       dx                       ; oprava konce o znaky CR/LF
CRHist2: inc       si                       ; posun adresy v bufferu
         loop      CRHist1                  ; test dal®°ho znaku

; ------ uloëen° poátu ©†dkñ a oprava velikosti dat v bufferu

CRHist4: sub       dx,offset HistBuff       ; offset v bufferu historie
         mov       ds:[HistNum],dx          ; poáet bajtñ historie
         mov       ds:[HistLine],bx         ; poáet ©†dkñ historie

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

CRHist   ENDP

; -----------------------------------------------------------------------------
;        inicializace p©edvolby
; -----------------------------------------------------------------------------

InitPred PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ uloëen° oznaáen° disku

         mov       di,offset SelBuff        ; buffer p©edvolby
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         mov       dl,al                    ; aktivn° disk
         inc       dx                       ; aktivn° disk + 1
         add       al,"A"                   ; korekce na znak ASCII
         mov       ah,":"                   ; oddàlovaá jmÇna disku
         cld
         stosw                              ; uloëen° jmÇna disku a znaku ":"
         mov       ax,"\"                   ; oznaáen° ROOT "\" a koncov† 0
         stosw                              ; uloëen° "\" a koncovÇ 0
         dec       di                       ; n†vrat ukazatele na koncovou 0

; ------ naáten° aktivn°ho adres†©e disku

         mov       si,di                    ; buffer k naáten° adres†©e
         mov       ah,47h
         int       21h                      ; poskytnut° aktivn°ho adres†©e

; ------ nalezen° konce cesty

         cld
         mov       cx,80                    ; max. dÇlka textu cesty
         mov       al,0                     ; hledanò bajt 0
         repne     scasb                    ; nalezen° koncovÇ 0
         dec       di                       ; n†vrat na koncovou 0

; ------ zaji®tàn° koncovÇho znaku "\"

         mov       al,"\"                   ; koncovÇ lom°tko
         cmp       ds:[di-1],al             ; je text zakonáen znakem "\" ?
         je        InitPrd3                 ; je jië zakonáen znakem "\"
         stosb                              ; uloëen° koncovÇho znaku "\"

; ------ uloëen° specifikace "*.*"

InitPrd3:mov       ax,".*"                  ; zaá†tek specifikace
         stosw                              ; uloëen° textu "*."
         stosb                              ; uloëen° znaku "*"
         mov       ax,0a0dh                 ; koncovÇ znaky CR/LF
         stosw                              ; uloëen° znakñ CR/LF

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitPred ENDP

; -----------------------------------------------------------------------------
;        p©°prava ukazatelñ editace
; -----------------------------------------------------------------------------

InitEdit PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ aktivn° ©†dek s kurzorem

         mov       ax,ds:[HistLine]         ; poáet ©†dkñ v historii
         mov       ds:[EditKurL],ax         ; ©†dek s kurzorem

; ------ prvn° zobrazenò ©†dek

         mov       ch,0
         mov       cl,ds:[Radku]            ; poáet ©†dkñ displeje
         sub       cl,6+1                   ; odeáten° okrajñ + 1
         sub       ax,cx                    ; poá†teán° zobrazenò ©†dek
         jnc       InitEdi2                 ; je v°ce ©†dkñ neë je displej
         xor       ax,ax                    ; omezen° na 0
InitEdi2:mov       ds:[EditTopL],ax         ; poá†teán° zobrazenò ©†dek

; ------ p©°prava ostatn°ch ukazatelñ

         mov       word ptr ds:[EditKurz],0 ; offset kurzoru v ©†dku
         mov       word ptr ds:[EditTop],0  ; offset poá†tku ©†dku
         and       byte ptr ds:[Param],not bit1 ; p©°znak, ëe nebyla editace

; ------ n†vrat registrñ

         pop       cx
         pop       ax
         ret

InitEdit ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      hled†n° souborñ v ©†dkovÇm reëimu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; ------ test, zda je poëadov†no zobrazen° n†povàdy

HledC:   mov       si,offset EditBuff       ; buffer s textem
         mov       cx,MAXLINE               ; dÇlka bufferu
         cld
HledC11: lodsb
         cmp       al," "
         loope     HledC11
         je        HledC3
         cmp       al,"/"
         jne       HledC14
         lodsb
         cmp       al,"?"
         je        HledC1

; ------ rozbor zad†n° parametrñ

HledC14: call      Rozbor                   ; rozbor zad†n° parametrñ
         jnc       HledC3                   ; zad†n° souborñ OK

; ------ chyba zad†n° parametrñ

HledC1:  mov       si,offset UvTxt          ; £vodn° text - nadpis
         call      StdOut                   ; zobrazen° £vodn°ho textu

; ------ konverze n†povàdy do ©†dkovÇho tvaru

         mov       si,offset HelpTx11+2     ; zaá†tek textu
         mov       cx,(offset(HelpTx12-HelpTx11)/80) ; poáet ©†dkñ
         push      si
HledC2:  add       si,80                    ; adresa dal®°ho ©†dku
         mov       byte ptr ds:[si-3]," "
         mov       word ptr ds:[si-2],0a0dh ; od©†dkov†n°
         loop      HledC2                   ; dal®° ©†dek
         mov       byte ptr ds:[si],0       ; konec textu
         pop       si
         call      Stdout                   ; zobrazen° textu n†povàdy
         mov       ax,4c02h
         int       21h                      ; konec s chybou

; ------ vyhled†n° souborñ podle zad†n°

HledC3:  call      DispCek                  ; zobrazen° hl†®en° "Äekejte"
         or        byte ptr ds:[Param],bit2 ; p©°znak hled†n° souboru
         call      HledFile                 ; vyhled†n° v®ech souborñ
         pushf
         call      ClrCek                   ; vymaz†n° hl†®en°
         popf
         mov       al,1                     ; p©°znak p©eru®en°
         jc        HledCX                   ; p©eru®en° programu

; ------ zobrazen° hl†®en° o nalezenòch souborech

         push      ds
         pop       es
         mov       di,offset BuffNum0       ; buffer k dek¢dov†n° á°sla
         mov       ax,ds:[CitSoub]          ; poáet souborñ
         mov       si,offset FndTxt0        ; text - nic nenalezeno
         or        ax,ax                    ; bylo nàco nalezeno ?
         jz        HledCB4                  ; nebylo nic nalezeno

         mov       si,offset FndTxt1        ; text "Nalezeno"
         call      StdErr                   ; zobrazen° "Nalezeno"

         xor       dx,dx
         call      DekNum                   ; dek¢dov†n° poátu souborñ
         call      StdErr                   ; zobrazen° poátu souborñ

         mov       si,offset FndTxt2        ; text "souboru, celkem"
         call      StdErr                   ; zobrazen° textu

         mov       ax,word ptr ds:[CitCelk] ; souáet LOW
         mov       dx,word ptr ds:[CitCelk+2] ; souáet HIGH
         call      DekNum                   ; dek¢dov†n° souátu velikost°
         call      StdErr                   ; zobrazen° á°sla

         mov       si,offset FndTxt3        ; text "obsazena kapacita"
         call      StdErr                   ; zobrazen° textu

         mov       ax,word ptr ds:[CitObs]  ; kapacita LOW
         mov       dx,word ptr ds:[CitObs+2] ; kapacita HIGH
         call      DekNum                   ; dek¢dov†n° obsazenÇ kapacity
         call      StdErr                   ; zobrazen° á°sla

         mov       si,offset FndTxt4        ; text "B."
HledCB4: call      StdErr                   ; zobrazen° hl†®en°
         mov       al,0

HledCX:  mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        vòpis naátenÇ á†sti seznamu
; -----------------------------------------------------------------------------

ListSezn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ poáet souborñ k zobrazen°

         mov       cx,ds:[DispNum]          ; poáet souborñ k zobrazen°
         mov       bx,ds:[DispNumO]         ; zaá†tek - prvn° poloëka
         inc       bx
         sub       cx,bx                    ; poáet novòch poloëek
         jbe       ListSzn9                 ; nen° nic

; ------ dek¢dov†n° poloëek

         cmp       word ptr ds:[FilePthN],7
         jae       ListSzn0                 ; nemus° se mazat
         call      ClrCek                   ; maz†n° hl†®en° "Äekejte"
ListSzn0:mov       es,ds:[SeznSegm]         ; segment se seznamem
ListSzn1:mov       si,bx
         shl       si,1
         mov       si,ds:[si+DispIndx]      ; adresa poloëky
         add       si,9                     ; jmÇno souboru
         call      AddGFil                  ; p©id†n° jmÇna k cestà
         jc        ListSzn2
         mov       si,offset FilePath       ; jmÇno souboru
         call      StdOut                   ; zobrazen° textu
         mov       si,offset CRLFTxt        ; text od©†dkov†n°
         call      StdOut                   ; od©†dkov†n° textu
         call      SubGFil                  ; odstranàn° poloëky
ListSzn2:inc       bx                       ; zvò®en° á°sla poloëky
         loop      ListSzn1                 ; dal®° poloëka
         call      DispCek                  ; zobrazen° hl†®en° "áekejte"

; ------ n†vrat registrñ

ListSzn9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ListSezn ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Obsluha volby souborñ k vyhled†n°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;     volba (pokraáov†n° volby) souborñ k editaci (CY=p©eru®en° volby ESC)
; -----------------------------------------------------------------------------

Volba    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx

; ------ z†kladn° zobrazen° obrazovky

Volba1:  call      DispAll                  ; zobrazen° obrazovky
         jmp       short Volba3

; ------ novÇ zobrazen° voleb

Volba2:  call      KorVol                   ; korekce voleb
         call      DispVol                  ; novÇ zobrazen° voleb

; ------ zobrazen° editovanÇho ©†dku

Volba3:  call      KorEdit                  ; korekce editovanÇho ©†dku
         call      DispEdit                 ; zobrazen° editovanÇho ©†dku

; ------ zobrazen° kurzoru a áek†n° na znak z kl†vesnice

Volba4:  call      KurzEdit                 ; zobrazen° kurzoru edit. ©†dku
         call      InpChr                   ; vstup znaku z kl†vesnice
         call      JumpBX                   ; obsluha kl†vesy

; ------ zvl†®tn° ©°dic° funkce

         dw        11bh,VolEsc              ; p©eru®en° operace ESC
         dw        1c0dh,VolEnt             ; ENTER
         dw        3b00h,VolbaN             ; F1 n†povàda
         dw        180fh,VolbaO             ; Ctrl-O zobrazen° podkladu

; ------ posun kurzoru vertik†lnà po ©†dc°ch

         dw        4800h,VolUp              ; kurzor nahoru
         dw        5000h,VolDwn             ; kurzor dolñ
         dw        4900h,VolPgUp            ; PageUp
         dw        5100h,VolPgDn            ; PageDown
         dw        8400h,VolCPgUp           ; ^PageUp
         dw        7600h,VolCPgDn           ; ^PageDown

; ------ posun kurzoru horizont†lnà na ©†dku

         dw        4d00h,VolRght            ; kurzor vpravo
         dw        4b00h,VolLft             ; kurzor vlevo
         dw        7300h,VolCLft            ; ^vlevo
         dw        7400h,VolCRght           ; ^vpravo
         dw        4700h,VolHome            ; HOME
         dw        4f00h,VolEnd             ; END

; ------ editace ©†dku

         dw        5300h,VolDel             ; DELETE
         dw        0e08h,VolBS              ; BS
         dw        1414h,VolCDel            ; ^T
         dw        0e7fh,VolCBS             ; ^BS
         dw        0,VolbaCh                ; zad†n° znaku

; ****** editace ©†dku

; ------ zad†n° jednoho znaku

VolbaCh: cmp       bx,300h                  ; je Ctrl-@ ?
         je        VolbaCh1                 ; je Ctrl-@
         cmp       bl,0                     ; je platnò znak ?
         jne       VolbaCh1                 ; je platnò znak
         jmp       Volba4                   ; nen° platn† kl†vesa - dal®° znak
VolbaCh1:test      byte ptr ds:[Param],bit1 ; je editace zah†jena ?
         jnz       VolbaCh2                 ; editace je jië zah†jena
         call      BegEdit                  ; zah†jen° editace
         call      ClrEdit                  ; nulov†n° editaán°ho bufferu
         mov       word ptr ds:[EditKurz],0 ; pozice kurzoru na ©†dku
VolbaCh2:call      InsChr                   ; vloëen° znaku BL do bufferu
         jmp       short VolRght1           ; posun kurzoru vpravo

; ------ vymaz†n° znaku BS

VolBS:   call      BegEdit                  ; zah†jen° editace
         cmp       word ptr ds:[EditKurz],0 ; je jië zaá†tek ©†dku ?
         je        VolDel4                  ; je jië zaá†tek ©†dku
         dec       word ptr ds:[EditKurz]   ; posun kurzoru

; ------ vymaz†n° znaku DELETE

VolDel:  call      BegEdit                  ; zah†jen° editace
         mov       bx,1                     ; 1 znak ke zru®en°
VolDel3: call      DelCh                    ; zru®en° 1 znaku na pozici kurzoru
VolDel4: jmp       Volba3

; ------ zru®en° slova p©ed kurzorem

VolCBS:  mov       bx,ds:[EditKurz]         ; aktu†ln° pozice kurzoru
         call      EdiCLeft                 ; posun o slovo vlevo
         sub       bx,ds:[EditKurz]         ; rozd°l kurzoru
         jmp       short VolDel3            ; vymaz†n° znakñ

; ------ zru®en° slova za kurzorem

VolCDel: mov       bx,ds:[EditKurz]         ; aktu†ln° pozice kurzoru
         call      EdiCRght                 ; posun o slovo vpravo
         xchg      bx,ds:[EditKurz]         ; n†vrat kurzoru
         sub       bx,ds:[EditKurz]         ; rozd°l kurzoru
         jmp       short VolDel3            ; zru®en° slova za kurzorem

; ****** posun kurzoru horizont†lnà na ©†dku

; ------ posun kurzoru o pozici vpravo

VolRght: call      BegEdit                  ; zah†jen° editace
VolRght1:cmp       word ptr ds:[EditKurz],MAXLINE-1 ; je jië maxim†ln° dÇlka ?
         jae       VolRght4                 ; je jië maxim†ln° dÇlka
         inc       word ptr ds:[EditKurz]   ; posun kurzoru
VolRght4:jmp       Volba3                   ; novÇ zobrazen° editovanÇho ©†dku

; ------ posun o slovo vpravo

VolCRght:call      BegEdit                  ; zah†jen° editace
         call      EdiCRght                 ; posun o slovo vpravo
         jmp       Volba3

; ------ posun kurzoru o pozici vlevo

VolLft:  call      BegEdit                  ; zah†jen° editace
         cmp       word ptr ds:[EditKurz],0
         je        VolLft4
         dec       word ptr ds:[EditKurz]
VolLft4: jmp       Volba3

; ------ posun o slovo vlevo

VolCLft: call      BegEdit                  ; zah†jen° editace
         call      EdiCLeft                 ; posun o slovo vlevo
         jmp       Volba3

; ------ zaá†tek ©†dku HOME

VolHome: call      BegEdit                  ; zah†jen° editace
         mov       word ptr ds:[EditKurz],0 ; kurzor na zaá†tek ©†dku
         jmp       Volba3

; ------ konec ©†dku END

VolEnd:  call      BegEdit                  ; zah†jen° editace
         call      EditEnd                  ; kurzor na konec ©†dku
         jmp       Volba3

; ****** posun kurzoru vertik†lnà po ©†dc°ch

; ------ prvn° ©†dek ^PageUp

VolCPgUp:mov       bx,-1                    ; posun o maximum ©†dkñ
         jmp       short VolUp0             ; posun na zaá†tek

; ------ str†nka nahoru PageUp

VolPgUp: mov       bh,0
         mov       bl,ds:[Radku]            ; poáet ©†dkñ displeje
         sub       bl,8                     ; odeáten° okrajñ
         jmp       short VolUp0             ; posun o str†nku

; ------ kurzor nahoru

VolUp:   mov       bx,1                     ; posun o 1 ©†dek

VolUp0:  call      EndEdit                  ; ukonáen° editace ©†dku
VolUp1:  cmp       word ptr ds:[EditKurL],0 ; je jië prvn° ©†dek ?
         je        VolUp9                   ; je jië prvn° ©†dek
         dec       word ptr ds:[EditKurL]   ; posun ©†dkovÇho kurzoru
         dec       bx                       ; á°taá ©†dkñ k posunu
         jnz       VolUp1                   ; posun o dal®° ©†dek
VolUp9:  jmp       Volba2

; ------ posledn° ©†dek ^PageDown

VolCPgDn:mov       bx,-1                    ; maximum ©†dkñ
         jmp       short VolDwn0            ; posun kurzoru

; ------ str†nka dolñ PageDown

VolPgDn: mov       bh,0
         mov       bl,ds:[Radku]            ; poáet ©†dkñ displeje
         sub       bl,8                     ; odeáten° okrajñ
         jmp       short VolDwn0            ; posun kurzoru

; ------ kurzor dolñ

VolDwn:  mov       bx,1                     ; posun o 1 ©†dek

VolDwn0: call      EndEdit                  ; ukonáen° editace ©†dku
VolDwn1: mov       ax,ds:[EditKurL]         ; ©†dkovò kurzor
         cmp       ax,ds:[HistLine]         ; je jië posledn° ©†dek ?
         je        VolDwn9                  ; je jië posledn° ©†dek
         inc       word ptr ds:[EditKurL]   ; zvò®en° á°sla ©†dku
         dec       bx                       ; á°taá ©†dkñ k posunu
         jnz       VolDwn1                  ; posun o dal®° ©†dek
VolDwn9: jmp       Volba2

; ****** zvl†®tn° ©°dic° funkce

; ------ zobrazen° podkladu

VolbaO:  call      PopScr                   ; n†vrat podkladu
         call      InpChr                   ; áek†n° na stisk kl†vesnice
         jmp       short VolbaN1

; ------ n†povàda

VolbaN:  call      Napoveda                 ; obsluha n†povàdy
VolbaN1: jmp       Volba1                   ; novÇ zobrazen° obrazovky

; ------ ukonáen° volby ENTER

VolEnt:  call      BegEdit                  ; p©°padnÇ zah†jen° editace
         clc                                ; p©°znak zad†n° OK
         jmp       short VolX

; ------ p©eru®en° volby ESC, Ctrl-Break

VolEsc:  stc                                ; p©°znak p©eru®en° volby ESC
VolX:    pop       bx
         pop       ax
         ret

Volba    ENDP

; -----------------------------------------------------------------------------
;        kurzor na konec ©†dku
; -----------------------------------------------------------------------------

EditEnd  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si

; ------ p©°prava registrñ

         mov       cx,MAXLINE-1             ; ukazatel kurzoru
         mov       si,offset EditBuff+MAXLINE-1 ; adresa v bufferu

; ------ posledn° znak je platnò - kurzor bude na konci

         cmp       byte ptr ds:[si]," "     ; je posledn° znak platnò ?
         jne       EditEnd4                 ; posledn° znak je platnò

; ------ test, zda je jië dosaëeno konce textu

EditEnd2:cmp       byte ptr ds:[si-1]," "   ; je p©edchoz° znak platnò ?
         jne       EditEnd4                 ; je konec textu OK
         dec       si                       ; sn°ëen° ukazatele v textu
         loop      EditEnd2                 ; dal®° znak

; ------ uloëen° novÇ pozice kurzoru

EditEnd4:mov       ds:[EditKurz],cx         ; nov† pozice kurzoru

; ------ n†vrat registrñ

         pop       si
         pop       cx
         ret

EditEnd  ENDP

; -----------------------------------------------------------------------------
;        posun o slovo vpravo
; -----------------------------------------------------------------------------

EdiCRght PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ adresa kurzoru v bufferu

         mov       si,offset EditBuff       ; editaán° buffer
         mov       cx,ds:[EditKurz]         ; kurzor
         add       si,cx                    ; adresa znaku v bufferu

; ------ posun na dal®° znak

EdiCRgh2:cmp       cx,MAXLINE-1             ; je jië konec ©†dku ?
         jae       EdiCRgh4                 ; je jië konec ©†dku
         inc       si                       ; zvò®en° adresu v bufferu
         inc       cx                       ; zvò®en° ukazatele kurzoru

; ------ zji®tàn° znaku nad kurzorem a p©ed kurzorem

         mov       al,ds:[si-1]             ; p©ede®lò znak
         call      KonvOdd                  ; konverze na hodnotu oddàlovaáe
         mov       ah,al                    ; £schova hodnoty
         mov       al,ds:[si]               ; aktu†ln° znak
         call      KonvOdd                  ; konverze na hodnotu oddàlovaáe

; ------ test dosaëen° stavu, zda je jië zaá†tek slova

         cmp       al,ah                    ; je zaá†tek slova ?
         jbe       EdiCRgh2                 ; nen° zaá†tek slova - dal®° znak

; ------ nov† pozice kurzoru

EdiCRgh4:mov       ds:[EditKurz],cx         ; nov† pozice kurzoru

; ------ konec ©†dku - kurzor na konec ©†dku

         cmp       cx,MAXLINE-1             ; je konec ©†dku ?
         jb        EdiCRgh9                 ; nen° konec ©†dku
         call      EditEnd                  ; kurzor na konec ©†dku

; ------ n†vrat registrñ

EdiCRgh9:pop       si
         pop       cx
         pop       ax
         ret

EdiCRght ENDP

; -----------------------------------------------------------------------------
;        posun o slovo vlevo
; -----------------------------------------------------------------------------

EdiCLeft PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ adresa kurzoru v bufferu

         mov       cx,ds:[EditKurz]         ; kurzor
         jcxz      EdiCLft9                 ; je jië zaá†tek ©†dku
         mov       si,offset EditBuff       ; editaán° buffer
         add       si,cx                    ; adresa znaku

; ------ nastaven° na p©edch†zej°c° znak

EdiCLft2:dec       si                       ; adresa p©edposledn°ho znaku
         dec       cx                       ; offset p©edposledn°ho znaku
         jz        EdiCLft8                 ; je jië zaá†tek ©†dku

; ------ zji®tàn° znaku na kurzoru a p©ed kurzorem

         mov       al,ds:[si-1]             ; p©ede®lò znak
         call      KonvOdd                  ; konverze na hodnotu oddàlovaáe
         mov       ah,al                    ; £schova hodnoty
         mov       al,ds:[si]               ; aktu†ln° znak
         call      KonvOdd                  ; konverze na hodnotu oddàlovaáe

; ------ test dosaëen° stavu, zda je zaá†tek slova

         cmp       al,ah                    ; je zaá†tek slova ?
         jbe       EdiCLft2                 ; nen° zaá†tek slova - dal®° znak

; ------ nov† pozice kurzoru

EdiCLft8:mov       ds:[EditKurz],cx         ; nov† pozice kurzoru

; ------ n†vrat registrñ

EdiCLft9:pop       si
         pop       cx
         pop       ax
         ret

EdiCLeft ENDP

; -----------------------------------------------------------------------------
;        vloëen° znaku BL do bufferu (CY=buffer je jië plnò)
; -----------------------------------------------------------------------------

InsChr   PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ kontrola, zda je buffer jië plnò

         mov       di,offset EditBuff + MAXLINE - 1 ; posledn° znak v bufferu
         cmp       byte ptr ds:[di]," "     ; je buffer jië plnò ?
         stc                                ; p©°znak, ëe buffer je jië plnò
         jne       InsChr9                  ; buffer je jië plnò

; ------ odsun zbytku textu v bufferu

         mov       si,di                    ; konec bufferu
         dec       si                       ; p©edposledn° znak v bufferu
         mov       cx,MAXLINE-1             ; velikost bufferu - 1
         sub       cx,ds:[EditKurz]         ; poáet zbylòch znakñ - 1
         push      ds
         pop       es                       ; ES <- datovò segment
         std                                ; smàr dolñ
         rep       movsb                    ; odsun zbytku textu

; ------ vloëen° novÇho znaku do bufferu

         mov       ds:[di],bl               ; uloëen° novÇho znaku do bufferu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

InsChr9: pop       es
         pop       di
         pop       si
         pop       cx
         ret

InsChr   ENDP

; -----------------------------------------------------------------------------
;      zru®en° BX znakñ na pozici kurzoru (neprov†d° se kontrola p©eteáen° !)
; -----------------------------------------------------------------------------

DelCh    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ p©°sun zbytku textu

         mov       si,offset EditBuff       ; editaán° buffer
         add       si,ds:[EditKurz]         ; adresa kurzoru
         mov       di,si                    ; adresa kurzoru
         add       si,bx                    ; poá†tek textu k zkop°rov†n°
         mov       cx,offset EditBuff+MAXLINE ; konec bufferu
         sub       cx,si                    ; dÇlka zbytku textu
         cld
         rep       movsb                    ; p©°sun zbytku textu
         mov       cx,bx                    ; offset posunu
         mov       al," "
         rep       stosb                    ; vymaz†n° zbytku tetxu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

DelCh    ENDP

; -----------------------------------------------------------------------------
;                                  KonvOdd
;                          konverze znaku na oddàlovaá
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VùSTUP:AL=hodnota znaku (0=mezera, 1=jinò znak, 2=p°smeno)
; -----------------------------------------------------------------------------

KonvOdd  PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ 0: mezera

         mov       bl,0                     ; 0=mezera
         cmp       al," "
         je        KonvOdd9                 ; je mezera

; ------ 2: malÇ p°smeno

         mov       bl,2                     ; p°smeno
         cmp       al,"a"
         jb        KonvOdd3                 ; nen° malÇ p°smeno
         cmp       al,"z"
         jbe       KonvOdd9                 ; je malÇ p°smeno

; ------ 2: velkÇ p°smeno

KonvOdd3:cmp       al,"A"
         jb        KonvOdd4                 ; nen° velkÇ p°smeno
         cmp       al,"Z"
         jbe       KonvOdd9                 ; velkÇ p°smeno

; ------ 2: á°slice

KonvOdd4:cmp       al,"0"
         jb        KonvOdd5
         cmp       al,"9"
         jbe       KonvOdd9                 ; á°slice

; ------ 2: jinÇ textovÇ znaky

KonvOdd5:cmp       al,"_"
         je        KonvOdd9                 ; podtrë°tko
         cmp       al,"*"
         je        KonvOdd9
         cmp       al,"?"
         je        KonvOdd9

; ------ 1: ostatn° znaky

         mov       bl,1                     ; jinak jinò znak

; ------ n†vrat registrñ

KonvOdd9:mov       al,bl                    ; hodnota znaku
         pop       bx
         ret

KonvOdd  ENDP

; -----------------------------------------------------------------------------
;        zah†jen° editace ©†dku
; -----------------------------------------------------------------------------

BegEdit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ test, zda je jië editace zah†jena

         test      byte ptr ds:[Param],bit1 ; je jië editace ©†dku ?
         jnz       BegEdit9                 ; je jië editace ©†dku

; ------ inicializaán° vymaz†n° editaán°ho bufferu

         call      ClrEdit                  ; vymaz†n° editaán°ho bufferu

; ------ nalezen° adresy aktivn°ho ©†dku

         mov       ax,0a0dh                 ; konec ©†dku CR/LF
         mov       si,offset SelBuff        ; buffer p©edvolby
         mov       cx,ds:[EditKurL]         ; aktivn° ©†dek s kurzorem
         cmp       cx,ds:[HistLine]         ; je aktivn° p©edvolba ?
         je        BegEdit3                 ; je aktivn° ©†dek s p©edvolbou
         mov       si,offset HistBuff       ; buffer histori°
         jcxz      BegEdit3                 ; je aktivn° prvn° ©†dek
BegEdit1:inc       si                       ; zvò®en° ukazatele v bufferu
         cmp       ds:[si-1],ax             ; je konec ©†dku ?
         jne       BegEdit1                 ; nalezen° konce ©†dku
         inc       si                       ; zaá†tek dal®°ho ©†dku
         loop      BegEdit1                 ; nalezen° poëadovanÇho ©†dku

; ------ p©enesen° obsahu ©†dku do editaán°ho bufferu

BegEdit3:mov       di,offset EditBuff       ; editaán° buffer
         push      ds
         pop       es                       ; ES <- datovò segment
         mov       cx,MAXLINE               ; velikost bufferu
         cld
BegEdit4:cmp       ds:[si],ax               ; je konec ©†dku ?
         je        BegEdit5                 ; je konec ©†dku
         movsb                              ; p©enos jednoho znaku
         loop      BegEdit4                 ; dal®° znak

; ------ p©°znak zah†jen° editace ©†dku

BegEdit5:or        byte ptr ds:[Param],bit1 ; p©°znak zah†jen° editace ©†dku

; ------ n†vrat registrñ

BegEdit9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

BegEdit  ENDP

; -----------------------------------------------------------------------------
;        ukonáen° editace ©†dku
; -----------------------------------------------------------------------------

EndEdit  PROC      NEAR

         and       byte ptr ds:[Param],not bit1 ; zru®en° p©°znaku editace
         push      ax
         mov       ax,ds:[EditTop]          ; poá†tek ©†dku
         sub       ds:[EditKurz],ax         ; offset kurzoru relativnà
         pop       ax
         call      ClrEdit                  ; vymaz†n° editaán°ho bufferu
         ret

EndEdit  ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° editaán°ho bufferu
; -----------------------------------------------------------------------------

ClrEdit  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz†n° bufferu

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset EditBuff       ; editaán° buffer
         mov       al," "                   ; znak mezery k vymaz†n°
         mov       cx,MAXLINE               ; dÇlka bufferu
         cld
         rep       stosb                    ; vymaz†n° bufferu
         mov       ds:[EditTop],cx          ; poá†teán° pozice ©†dku = 0

; ------ n†vrat registstrñ

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

ClrEdit  ENDP

; -----------------------------------------------------------------------------
;        kurzor editovanÇho ©†dku
; -----------------------------------------------------------------------------

KurzEdit PROC      NEAR

         push      dx
         mov       dl,byte ptr ds:[EditKurz] ; pozice kurzoru v ©†dku
         sub       dl,byte ptr ds:[EditTop] ; offset od poá†tku ©†dku
         add       dl,(80-SIRKA)/2+1        ; pozice kurzoru
         mov       dh,ds:[KurzRad]          ; ©†dek s kurzorem
         call      SetKurz                  ; nastaven° pozice kurzoru
         pop       dx
         ret

KurzEdit ENDP

; -----------------------------------------------------------------------------
;        korekce editovanÇho ©†dku
; -----------------------------------------------------------------------------

KorEdit  PROC      NEAR

; ------ test, zda byla zah†jena editace

         test      byte ptr ds:[Param],bit1 ; byla zah†jena editace ?
         jz        KorEdit6                 ; nebyla zah†jena editace

; ------ £schova registrñ

         push      ax
         push      cx

; ------ podteáen° kurzoru p©ed poá†tek ©†dku

         mov       ax,ds:[EditKurz]         ; offset kurzoru na ©†dku
         mov       cx,ds:[EditTop]          ; poá†tek ©†dku
         cmp       ax,cx                    ; podteáen° kurzoru p©ed poá†tek ?
         jae       KorEdit1                 ; nen° podteáen° kurzoru
         mov       cx,ax                    ; omezen° poá†tku ©†dku

; ------ stanoven° maxim†ln°ho poá†tku

KorEdit1:sub       ax,SIRKA-3               ; maxim†ln° poá†tek
         jnc       KorEdit2                 ; nen° p©eteáen°
         xor       ax,ax                    ; omezen° poá†tku na 0

; ------ p©eteáen° kurzoru za konec ©†dku

KorEdit2:cmp       ax,cx                    ; je p©eteáen° kurzoru za konec ?
         jbe       KorEdit3                 ; kurzor je OK
         mov       cx,ax                    ; omezen° poá†tku ©†dku
KorEdit3:mov       ds:[EditTop],cx          ; novò poá†tek ©†dku

; ------ n†vrat registrñ

         pop       cx
         pop       ax
KorEdit6:ret

KorEdit  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° editovanÇho ©†dku
; -----------------------------------------------------------------------------

DispEdit PROC      NEAR

; ------ test, zda byla zah†jena editace

         test      byte ptr ds:[Param],bit1 ; byla zah†jena editace ?
         jz        DispEdi4                 ; nebyla zah†jena editace

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ zobrazen° editovanÇho ©†dku

         push      ds
         pop       es
         mov       si,offset EditBuff       ; editaán° buffer
         add       si,ds:[EditTop]          ; adresa zaá†tku textu
         mov       dh,ds:[KurzRad]          ; ©†dek s kurzorem na obrazovce
         mov       dl,(80-SIRKA)/2+1        ; poá†teán° pozice
         mov       ah,ds:[BarvaR3]          ; barva editovanÇho ©†dku
         mov       cx,SIRKA-2               ; dÇlka textu ©†dku
         call      DispTxt                  ; zobrazen° editovanÇho ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
DispEdi4:ret

DispEdit ENDP


; -----------------------------------------------------------------------------
;        korekce okna voleb
; -----------------------------------------------------------------------------

KorVol   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ podteáen° kurzoru pod zaá†tkem okna

         mov       ax,ds:[EditKurL]         ; á°slo aktivn°ho ©†dku
         mov       cx,ds:[EditTopL]         ; poá†tek okna
         cmp       ax,cx                    ; je pod zaá†tkem okna ?
         jae       KorVol1                  ; nen° pod zaá†tkem okna
         mov       cx,ax                    ; omezen° poá†tku okna

; ------ stanoven° minim†ln°ho poá†teán°ho ©†dku

KorVol1: mov       bh,0
         mov       bl,ds:[Radku]            ; poáet ©†dkñ displeje
         sub       bl,6+1                   ; odeáten° okrajñ + 1 = poáet ©†dkñ
         sub       ax,bx                    ; maxim†ln° poá†tek
         jnc       KorVol2                  ; nen° podteáen°
         xor       ax,ax                    ; omezen° prvn°ho ©†dku na 0

; ------ p©eteáen° kurzoru za konec okna

KorVol2: cmp       ax,cx                    ; je kurzor za koncem okna ?
         jbe       KorVol3                  ; kurzor je OK
         mov       cx,ax                    ; omezen° poá†tku okna
KorVol3: mov       ds:[EditTopL],cx         ; novò poá†teán° ©†dek okna

; ------ n†vrat registrñ

         pop       cx
         pop       bx
         pop       ax
         ret

KorVol   ENDP

; -----------------------------------------------------------------------------
;                                 DispVol
;                         zobrazen° voleb souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku na obrazovce
;                   SS:[BP-2] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-4] (2) á°taá aktivn°ho ©†dku
;                   SS:[BP-6] (2) ukazatel adresy ©†dku
;                   SS:[BP-8] (2) á°taá ©†dku p©edvolby
; -----------------------------------------------------------------------------

DispVol  PROC      NEAR

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

         sub       sp,8+SIRKA*2             ; vytvo©en° bufferu v z†sobn°ku
         push      ss
         pop       es                       ; ES <- z†sobn°k

; ------ á°taá aktivn°ho ©†dku

         mov       cx,ds:[EditTopL]         ; á°slo prvn°ho ©†dku
         mov       ax,ds:[EditKurL]         ; á°slo aktivn°ho ©†dku
         sub       ax,cx                    ; offset aktivn°ho ©†dku
         inc       ax                       ; p©ednastaven° á°taáe ©†dku
         mov       ss:[bp-4],ax             ; á°taá aktivn°ho ©†dku

; ------ á°taá ©†dku p©edvolby

         mov       ax,ds:[HistLine]         ; á°slo ©†dku p©edvolby
         sub       ax,cx                    ; offset ©†dku p©edvolby
         inc       ax                       ; p©ednastaven° á°taáe ©†dku
         mov       ss:[bp-8],ax             ; á°taá ©†dku p©edvolby

; ------ nalezen° adresy prvn°ho ©†dku

         mov       si,offset HistBuff       ; buffer historie
         jcxz      DispVol2                 ; je zobrazen prvn° ©†dek
         mov       ax,0a0dh                 ; hledanò znak CR/LF
DispVol1:inc       si                       ; zvò®en° ukazatele v bufferu
         cmp       ds:[si-1],ax             ; je CR/LF ?
         jne       DispVol1                 ; nalezen° konce ©†dku
         inc       si                       ; zaá†tek dal®°ho ©†dku
         loop      DispVol1                 ; nalezen° poëadovanÇho ©†dku
DispVol2:mov       ss:[bp-6],si             ; ukazatel adresy ©†dku

; ------ stanoven° poátu ©†dkñ k zobrazen°

         mov       cl,ds:[Radku]            ; CX=poáet ©†dkñ displeje
         sub       cl,6                     ; odeáten° okrajñ
         mov       ax,ds:[HistLine]         ; poáet ©†dkñ v historii
         inc       ax                       ; + ©†dek p©edvolby
         cmp       cx,ax                    ; je poáet ©†dkñ men®° ?
         jbe       DispVol3                 ; poáet ©†dkñ v CX je OK
         mov       cx,ax                    ; omezen° poátu ©†dkñ
DispVol3:mov       ss:[bp-2],cl             ; á°taá ©†dkñ k zobrazen°

; ------ stanoven° poá†teán°ho ©†dku na obrazovce

         mov       dh,ds:[Radku]            ; poáet ©†dkñ displeje celkem
         add       cl,2                     ; p©iáten° okrajñ = vò®ka okna
         sub       dh,cl                    ; zbytek na okraje
         shr       dh,1                     ; vyst©edàn° okna
         mov       ss:[bp-1],dh             ; ukazatel ©†dku na obrazovce

; ------ zobrazen° horn°ho okraje (horn° linka)

         mov       dl,(80-SIRKA)/2          ; poá†teán° pozice
         mov       ah,ds:[BarvaR1]          ; barva r†mu
         mov       al,218                   ; levò horn° roh
         call      Disp1Chr                 ; zobrazen° levÇho horn°ho rohu
         mov       cl,SIRKA-2               ; vnit©n° ®°©ka ©†dku
         mov       al,196                   ; horn° linka
         call      DispChr                  ; zobrazen° horn° linky
         mov       al,191                   ; pravò horn° roh
         call      Disp1Chr                 ; zobrazen° pravÇho horn°ho rohu
         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dku

; ------ p©°prava okrajñ ©†dku v bufferu

DispVol4:mov       di,sp                    ; buffer ©†dku v z†sobn°ku
         cld
         mov       ah,ds:[BarvaR1]          ; z†kladn° barva r†mu voleb
         mov       al,179                   ; lev† hrana
         stosw                              ; uloëen° levÇho okraje
         mov       es:[di+2*SIRKA-4],ax     ; uloëen° pravÇho okraje

; ------ p©°prava barvy ©†dku

         dec       word ptr ss:[bp-4]       ; á°taá aktivn°ho ©†dku
         jnz       DispVol5                 ; nen° aktivn° ©†dek
         mov       ah,ds:[BarvaR2]          ; barva kurzoru voleb
         mov       al,ss:[bp-1]             ; ©†dek na obrazovce
         mov       ds:[KurzRad],al          ; ©†dek s kurzorem

; ------ adresa ©†dku k dek¢dov†n°

DispVol5:mov       si,ss:[bp-6]             ; ukazatel adresy ©†dku
         dec       word ptr ss:[bp-8]       ; á°taá ©†dku p©edvolby
         jnz       DispVol6                 ; nen° p©edvolba
         mov       si,offset SelBuff        ; buffer p©edvolby

; ------ dek¢dov†n° textu ©†dku

DispVol6:mov       cx,SIRKA-2               ; maxim†ln° dÇlka textu
         mov       dx,0a0dh                 ; hledanò konec ©†dku CR/LF
DispVol7:cmp       ds:[si],dx               ; je konec ©†dku ?
         je        DispVol8                 ; je konec ©†dku
         lodsb                              ; znak textu
         stosw                              ; uloëen° znaku k zobrazen°
         loop      DispVol7                 ; dal®° znak

; ------ vymaz†n° zbytku ©†dku

DispVol8:mov       al," "                   ; znak mezery k vymaz†n° ©†dku
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ nalezen° zaá†tku dal®°ho ©†dku

DispVol9:inc       si                       ; zvò®en° ukazatele textu
         cmp       ds:[si-1],dx             ; je konec ©†dku ?
         jne       DispVol9                 ; nalezen° konce ©†dku
         inc       si                       ; nastaven° na zaá†tek dal®°ho ©†dku
         mov       ss:[bp-6],si             ; £schova adresy dal®°ho ©†dku

; ------ zobrazen° ©†dku z bufferu

         mov       si,sp                    ; buffer v z†sobn°ku s textem
         mov       cx,SIRKA                 ; dÇlka ©†dku
         mov       dl,(80-SIRKA)/2          ; poá†teán° pozice
         mov       dh,ss:[bp-1]             ; ©†dek k zobrazen°
         call      DispStr                  ; zobrazen° textu z bufferu
         mov       cl,2
         call      DispStin                 ; zobrazen° st°nu za ©†dkem

; ------ p©°prava pro dal®° ©†dek

         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dkñ
         dec       byte ptr ss:[bp-2]       ; sn°ëen° á°taáe ©†dkñ k zobrazen°
         jnz       DispVol4                 ; zobrazen° dal®°ho ©†dku

; ------ zobrazen° doln°ho okraje

         mov       dl,(80-SIRKA)/2          ; poá†teán° pozice
         mov       dh,ss:[bp-1]             ; ©†dek k zobrazen°
         mov       ah,ds:[BarvaR1]          ; barva r†mu
         mov       al,192                   ; levò doln° roh
         call      Disp1Chr                 ; zobrazen° levÇho doln°ho rohu
         mov       cl,SIRKA-2               ; vnit©n° ®°©ka ©†dku
         mov       al,196                   ; doln° linka
         call      DispChr                  ; zobrazen° doln° linky
         mov       al,217                   ; pravò doln° roh
         call      Disp1Chr                 ; zobrazen° pravÇho doln°ho rohu
         mov       cl,2
         call      DispStin                 ; zobrazen° st°nu
         inc       dh
         mov       dl,(80-SIRKA)/2+2
         mov       cl,SIRKA
         call      DispStin                 ; zobrazen° spodn°ho st°nu

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

DispVol  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Obsluha prohl°ëeáe souboru F3
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;        obsluha prohl°ëeáe souboru (BX=kl†vesa)
; -----------------------------------------------------------------------------

View     PROC      NEAR

; ------ otev©en° prohl°ëeáe souboru

         test      byte ptr ds:[Param],bit5 ; prob°h† zobrazen° souboru ?
         jnz       View1                    ; prohl°ëeá je jië aktivn°
         call      ViewOpen                 ; otev©en° prohl°ëeáe
         test      byte ptr ds:[Param],bit5 ; byl £spà®nà otev©en ?
         jz        View0                    ; nebyl otev©en
         call      ViewDisp                 ; zobrazen° prohl°ëeáe
View0:   xor       bx,bx
         ret

; ------ opu®tàn° prohl°ëeáe souboru

View1:   cmp       bx,3d00h                 ; F3 - opu®tàn° prohl°ëeáe
         je        View11
         cmp       bl,27                    ; ESC
         jne       View2
View11:  and       byte ptr ds:[Param],not bit5 ; zru®en° p©°znaku prohl°ëeáe
         call      DispSezn                 ; obnoven° zobrazen° seznamu
         mov       bx,ds:[ViewIdnt]         ; identifik†tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         xor       bx,bx                    ; zru®en° p©°znaku ESC
         ret

; ------ posun o ©†dek dolñ

View2:   call      ViewAkt                  ; aktualizace bufferu prohl°ëeáe
         cmp       bx,5000h                 ; dolñ
         jne       View3
         call      ViewDwn                  ; posun o ©†dek dolñ
View22:  call      ViewDisp                 ; novÇ zobrazen° str†nky
View23:  xor       bx,bx                    ; zru®en° kl†vesy
         ret

; ------ posun o ©†dek nahoru

View3:   cmp       bx,4800h                 ; nahoru
         jne       View4
         call      ViewUp
         jmp       short View22

; ------ posun na zaá†tek souboru

View4:   cmp       bx,4700h                 ; HOME
         jne       View5
         mov       word ptr ds:[ViewTop],0  ; novò poá†tek obrazovky
         mov       word ptr ds:[ViewTop+2],0
         jmp       short View22

; ------ posun na konec souboru

View5:   cmp       bx,4f00h                 ; END
         jne       View6
         mov       ax,word ptr ds:[ViewSize] ; velikost LOW
         mov       word ptr ds:[ViewTop],ax
         mov       ax,word ptr ds:[ViewSize+2] ; velikost HIGH
         mov       word ptr ds:[ViewTop+2],ax
         call      ViewAkt                  ; aktualizace bufferu
         jmp       short View62

; ------ posun o str†nku nahoru

View6:   cmp       bx,4900h                 ; Page Up
         jne       View7
View62:  mov       cx,ds:[SeznRad]          ; dÇlka str†nky (©†dkñ)
         dec       cx
View63:  call      ViewUp                   ; nahoru
         jc        View22
         loop      View63
         jmp       short View22

; ------ posun o str†nku dolñ

View7:   cmp       bx,5100h                 ; Page Down
         jne       View8
         mov       cx,ds:[SeznRad]          ; dÇlka str†nky (©†dkñ)
         dec       cx
View73:  call      ViewDwn                  ; dolñ
         jc        View22
         loop      View73
         jmp       short View22

; ------ zobrazen° podkladu ^O

View8:   cmp       bx,180fh                 ; ^O
         jne       View22
         call      PopScr
         call      InpChr
         jmp       short View22

View     ENDP

; -----------------------------------------------------------------------------
;        otev©en° prohl°ëeáe souboru
; -----------------------------------------------------------------------------

ViewOpen PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es
         test      byte ptr ds:[Param],bit5 ; je aktivn° prohl°ëeá ?
         jz        ViewOpn0                 ; nen° aktivn°
ViewOp99:jmp       ViewOpn9                 ; prohl°ëeá je jië aktivn°

; ------ p©°prava registrñ

ViewOpn0:mov       bx,ds:[SeznAkt]          ; aktivn° ©†dek
         call      GetKPTh                  ; poskytnut° cesty kurzoru
         jc        ViewOpn9                 ; nen° platnò soubor

; ------ adresa aktivn°ho souboru

         mov       es,ds:[SeznSegm]         ; segment seznamu
         mov       bx,ds:[SeznAkt]          ; aktivn° ©†dek
         shl       bx,1
         mov       si,ds:[bx+DispIndx]      ; adresa souboru

; ------ kontrola platnosti souboru

         test      byte ptr es:[si],bit6+DIR ; je to platn† poloëka ?
         jnz       ViewOpn9                 ; je to cesta nebo adres†© - neplat°

; ------ £schova velikosti souboru

         mov       ax,es:[si+5]             ; velikost LOW
         mov       word ptr ds:[ViewSize],ax ; velikost LOW
         mov       ax,es:[si+7]             ; velikost HIGH
         mov       word ptr ds:[ViewSize+2],ax ; velikost HIGH

; ------ p©id†n° jmÇna souboru

         add       si,9                     ; jmÇno souboru
ViewOpn4:mov       al,es:[si]
         mov       ds:[di],al
         inc       si
         inc       di
         cmp       al,0
         jne       ViewOpn4

; ------ otev©en° souboru

         mov       dx,offset ViewName
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         jc        ViewOpn9                 ; chyba - nenalezen

; ------ inicializace ukazatelñ

         mov       ds:[ViewIdnt],ax         ; identifik†tor souboru
         xor       ax,ax
         mov       word ptr ds:[ViewTop],ax ; adresa zaá†tku str†nky
         mov       word ptr ds:[ViewTop+2],ax
         mov       word ptr ds:[ViewBeg],ax
         mov       word ptr ds:[ViewBeg+2],ax
         mov       ds:[ViewNum],ax          ; dÇlka dat v bufferu
         or        byte ptr ds:[Param],bit5 ; p©°znak aktivn°ho prohl°ëeáe

; ------ inicializaán° naáten° souboru

         call      ViewRBuf                 ; naáten° souboru do bufferu

; ------ n†vrat registrñ

ViewOpn9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ViewOpen ENDP

; -----------------------------------------------------------------------------
;        poskytnut° cesty souboru BX (CY=neplat°, DI=konec cesty)
; -----------------------------------------------------------------------------

GetKPth  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      si
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[SeznSegm]         ; segment seznamu
         cmp       bx,ds:[DispNum]          ; je platnò ©†dek ?
         cmc
         jc        GetKPth9                 ; nen° platnò ©†dek
         shl       bx,1                     ; index * 2

         mov       si,ds:[bx+DispIndx]      ; adresa poloëky
         test      byte ptr es:[si],bit6    ; je to cesta ?
         jnz       GetKPt13                 ; je to cesta

; ------ nalezen° domovskÇho adres†©e souboru

GetKPth1:dec       bx
         dec       bx
         mov       si,ds:[bx+DispIndx]      ; adresa poloëky
         test      byte ptr es:[si],bit6    ; je to cesta ?
         jz        GetKPth1                 ; nalezen° cesty

; ------ p©enesen° domovskÇho adres†©e do bufferu

GetKPt13:mov       di,offset ViewName-1     ; buffer jmÇna souboru
GetKPth2:inc       di
         inc       si
         mov       al,es:[si]
         mov       ds:[di],al
         cmp       al,0
         jne       GetKPth2

; ------ zaji®tàn° koncovÇho znaku "\"

         cmp       byte ptr ds:[di-1],"\"
         je        GetKPth3
         mov       word ptr ds:[di],"\"
         inc       di
GetKPth3:clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

GetKPth9:pop       es
         pop       si
         pop       bx
         pop       ax
         ret

GetKPth  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° prohl°ëeáe
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1] (1) ukazatel ©†dku na displeji
;                   SS:[BP-2] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-4] (2) offset zaá†tku ©†dku v bufferu
;                   SS:[BP-6] (2) offset zaá†tku str†nky
; -----------------------------------------------------------------------------

ViewDisp PROC      NEAR

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

; ------ p©°prava registrñ

         sub       sp,160+6                 ; lok†ln° promànnÇ a buffer
         push      ss
         pop       es                       ; ES <- segment bufferu
         mov       byte ptr ss:[bp-1],1     ; ukazatel ©†dkñ na displeji
         mov       al,byte ptr ds:[SeznRad] ; poáet ©†dkñ k zobraze°
         mov       ss:[bp-2],al             ; á°taá ©†dkñ k zobrazen°
         call      ViewAkt                  ; aktualizace bufferu
         mov       ax,word ptr ds:[ViewTop] ; zaá†tek str†nky
         sub       ax,word ptr ds:[ViewBeg] ; offset v bufferu
         mov       ss:[bp-4],ax             ; offset zaá†tku ©†dku v bufferu
         mov       ss:[bp-6],ax             ; offset zaá†tku str†nky
         mov       bx,ds:[ViewNum]          ; poáet bajtñ v bufferu

; ------ dek¢dov†n° jednoho ©†dku

ViewDsp1:cld
         mov       di,sp                    ; buffer v z†sobn°ku
         mov       si,ss:[bp-4]             ; offset dat v bufferu
         mov       cx,80                    ; max. poáet znakñ
         mov       dh,ds:[Barva1]           ; z†kladn° barva textu
         mov       dl,ds:[Barva6]           ; barva ©°dic°ch znakñ textu
ViewDsp2:cmp       si,bx                    ; jsou dal®° data ?
         jae       ViewDsp5                 ; posun dat v bufferu
ViewDsp3:mov       al,ds:[si+ViewBuf]       ; znak z bufferu
         inc       si                       ; zvò®en° ukazatele
         mov       ah,dh                    ; bàën† barva textu
         cmp       al,10                    ; je novò ©†dek LF ?
         je        ViewDsp6                 ; je LF - konec ©†dku
         cmp       al,13                    ; je CR ?
         je        ViewDsp2                 ; CR se ignoruje
         cmp       al,9                     ; je tabel†tor ?
         je        ViewDsp4                 ; je tabel†tor
         cmp       al," "
         jae       ViewDs30
         mov       ah,dl                    ; barva ©°dic°ch znakñ
         cmp       al,0
         jne       ViewDs30
         mov       al,"."                   ; n†hrada znaku 0 znakem "."
ViewDs30:stosw                              ; uloëen° znaku
         loop      ViewDsp2                 ; dal®° znak

; ------ vypu®tàn° LF z konce ©†dku

ViewDs31:cmp       si,bx                    ; jsou dal®° data ?
         jb        ViewDs32                 ; jsou dal®° data
         call      ViewNxt                  ; dal®° blok dat
         cld
         jc        ViewDsp7                 ; nen° dal®° blok dat
         mov       bx,ds:[ViewNum]          ; novò poáet bajtñ v bufferu
         sub       si,VIEWBMAX/2            ; posun ukazatele v bufferu
         sub       word ptr ss:[bp-6],VIEWBMAX/2 ; posun uschovanÇho zaá†tku
ViewDs32:mov       al,ds:[si+ViewBuf]       ; znak z bufferu
         inc       si                       ; zvò®en° ukazatele
         cmp       al,13
         je        ViewDs31                 ; znak CR se ignoruje
         cmp       al,10                    ; je LF ?
         je        ViewDsp7                 ; je LF - vypust° se
         dec       si                       ; jinak n†vrat znaku
         jmp       short ViewDsp7

; ------ dek¢dov†n° tabel†toru

ViewDsp4:mov       al," "
         stosw
         dec       cx
         test      cl,7
         jnz       ViewDsp4
         jcxz      ViewDs31                 ; konec ©†dku
         jmp       short ViewDsp2

; ------ dal®° blok dat

ViewDsp5:call      ViewNxt                  ; dal®° blok dat
         cld
         jc        ViewDsp6                 ; nen° dal®° blok dat
         mov       bx,ds:[ViewNum]          ; novò poáet bajtñ v bufferu
         sub       si,VIEWBMAX/2            ; posun ukazatele v bufferu
         sub       word ptr ss:[bp-6],VIEWBMAX/2 ; posun uschovanÇho zaá†tku
         cmp       si,bx                    ; jsou dal®° data ?
         jb        ViewDsp3                 ; je dal®° znak

; ------ vymaz†n° zbytku ©†dku

ViewDsp6:mov       al," "
         mov       ah,dh
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ zobrazen° ©†dku

ViewDsp7:mov       ss:[bp-4],si             ; ukazatel dal®°ho ©†dku
         mov       si,sp
         mov       dl,0
         mov       dh,ss:[bp-1]             ; ©†dek na displeji
         mov       cl,80
         call      DispStr                  ; zobrazen° ©†dku

; ------ p©°prava pro dal®° ©†dek

         inc       byte ptr ss:[bp-1]       ; zvò®en° ukazatele ©†dkñ
         dec       byte ptr ss:[bp-2]
         jz        ViewDsp9
         jmp       ViewDsp1                 ; dek¢dov†n° dal®°ho ©†dku

; ------ dÇlka zobrazenÇ á†sti

ViewDsp9:mov       ax,ss:[bp-4]             ; adresa ©†dku
         sub       ax,ss:[bp-6]             ; poáet zobrazenòch bajtñ
         mov       ds:[ViewDis],ax          ; dÇlka zobrazenÇ á†sti

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
         call      DispNadp                 ; zobrazen° informaán°ho ©†dku
         call      DispHlp                  ; zobrazen° n†povàdy
         ret

ViewDisp ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o jeden ©†dek dolñ (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

ViewDwn  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ ukazatel dat v bufferu

         mov       si,word ptr ds:[ViewTop] ; zaá†tek obrazovky
         sub       si,word ptr ds:[ViewBeg] ; offset v bufferu
         mov       bx,ds:[ViewNum]          ; poáet bajtñ v bufferu
         mov       dx,si                    ; £schova zaá†tku dat
         mov       cx,81                    ; max. poáet znakñ

; ------ naáten° znaku z bufferu

ViewDwn1:cmp       si,bx                    ; je konec dat v bufferu ?
         jae       ViewDwn6                 ; dal®° blok dat
ViewDwn2:mov       al,ds:[si+ViewBuf]       ; znak z bufferu
         inc       si                       ; zvò®en° ukazatele dat
         cmp       al,13
         je        ViewDwn1                 ; znak CR se ignoruje

; ------ obsluha tabel†toru

         cmp       al,9                     ; je tabel†tor ?
         jne       ViewDwn3                 ; nen° tabel†tor
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jz        ViewDwn4
         dec       cx
         and       cl,not 7                 ; zarovn†n° na tabelaán° pozici
         jz        ViewDwn4                 ; konec
         inc       cx
         inc       cx

; ------ test, zda je konec ©†dku

ViewDwn3:cmp       al,10                    ; je konec ©†dku ?
         loopne    ViewDwn1                 ; dal®° znak
         je        ViewDwn4                 ; byl LF
         dec       si                       ; n†vrat posledn°ho znaku
ViewDwn4:sub       si,dx                    ; rozd°l dat
         add       word ptr ds:[ViewTop],si ; posun zaá†tku str†nky
         adc       word ptr ds:[ViewTop+2],0
         clc

; ------ n†vrat registrñ

ViewDwn9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ViewDwn  ENDP

; ------ naáten° dal®°ho bloku dat

ViewDwn6:call      ViewNxt                  ; dal®° blok dat
         jc        ViewDwn9                 ; nen° dal®° blok dat
         mov       bx,ds:[ViewNum]          ; novò poáet bajtñ v bufferu
         sub       si,VIEWBMAX/2            ; posun ukazatele v bufferu
         sub       dx,VIEWBMAX/2            ; posun pñvodn°ho ukazatele dat
         cmp       si,bx                    ; jsou dal®° data ?
         cmc
         jc        ViewDwn9                 ; konec dat
         jmp       short ViewDwn2

; -----------------------------------------------------------------------------
;        posun kurzoru o jeden ©†dek nahoru (CY=nen° dal®° ©†dek)
; -----------------------------------------------------------------------------

ViewUp   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si

; ------ ukazatel dat v bufferu

         mov       si,word ptr ds:[ViewTop] ; zaá†tek obrazovky
         sub       si,word ptr ds:[ViewBeg] ; offset v bufferu
         mov       dx,si                    ; £schova zaá†tku ©†dku
         mov       cx,80                    ; max. poáet znakñ

; ------ p©eskoáen° p©edchoz°ho znaku LF

         or        si,si                    ; je zaá†tek v bufferu ?
         jnz       ViewUp11                 ; nen° zaá†tek bufferu - je znak
         call      ViewPred                 ; dal®° blok dat
         jc        ViewUp9                  ; nen° dal®° blok dat
         mov       si,VIEWBMAX/2            ; novò offset v bufferu
ViewUp11:dec       si                       ; sn°ëen° ukazatele dat
         cmp       byte ptr ds:[si+ViewBuf],10 ; je konec ©†dku LF ?
         je        ViewUp1                  ; je konec ©†dku LF
         inc       si                       ; n†vrat platnÇho znaku

; ------ naáten° znaku z bufferu

ViewUp1: or        si,si                    ; je konec dat v bufferu ?
         jz        ViewUp6                  ; dal®° blok dat
ViewUp2: dec       si                       ; sn°ëen° ukazatele dat
         mov       al,ds:[si+ViewBuf]       ; znak z bufferu
         cmp       al,13
         je        ViewUp1                  ; znak CR se ignoruje

; ------ test, zda je konec ©†dku

ViewUp3: cmp       al,10                    ; je konec ©†dku ?
         loopne    ViewUp1                  ; dal®° znak
         jne       ViewUp5                  ; nebyl to znak LF (konec ©†dku)
         inc       si                       ; n†vrat znaku LF
ViewUp5: sub       dx,si                    ; rozd°l dat
         sub       word ptr ds:[ViewTop],dx ; posun zaá†tku str†nky
         sbb       word ptr ds:[ViewTop+2],0 ; p©enos HIGH
         clc

; ------ n†vrat registrñ

ViewUp9: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

ViewUp   ENDP

; ------ naáten° dal®°ho bloku dat

ViewUp6: call      ViewPred                 ; dal®° blok dat
         jc        ViewUp5                  ; nen° dal®° blok dat
         mov       si,VIEWBMAX/2            ; novò ukazatel dat v bufferu
         add       dx,VIEWBMAX/2            ; posun pñvodn°ho offsetu dat
         jmp       short ViewUp2

; -----------------------------------------------------------------------------
;        aktualizace bufferu prohl°ëeáe (aby zaá†tek obrazovky byl v bufferu)
; -----------------------------------------------------------------------------

ViewAkt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ vòpoáet offsetu od zaá†tku bufferu

ViewAkt1:mov       cx,VIEWBMAX/2            ; polovina bufferu
         mov       ax,word ptr ds:[ViewTop] ; offset poá†tku obrazovky
         mov       dx,word ptr ds:[ViewTop+2]
         sub       ax,word ptr ds:[ViewBeg] ; offset od zaá†tku bufferu
         sbb       dx,word ptr ds:[ViewBeg+2] ; p©enos HIGH
         jc        ViewAkt5                 ; obrazovka je pod zaá†tkem bufferu

; ------ obrazovka je nad zaá†tkem bufferu

         ja        ViewAkt4                 ; je daleko za koncem
         cmp       ax,VIEWBMAX              ; je za koncem bufferu ?
         jb        ViewAkt9                 ; je uvnit© bufferu OK
         cmp       ax,VIEWBMAX+VIEWBMAX/2   ; je daleko za bufferem ?
         jae       ViewAkt4                 ; je daleko za bufferem
         call      ViewNxt                  ; posun o blok dat vp©ed
         jmp       short ViewAkt9

; ------ obrazovka je daleko za koncem bufferu

ViewAkt4:add       word ptr ds:[ViewBeg],cx ; posun poá†tku bufferu
         adc       word ptr ds:[ViewBeg+2],0 ; p©enos HIGH
         sub       ax,cx                    ; posun ukazatele obrazovky
         sbb       dx,0                     ; p©enos HIGH
         jnz       ViewAkt4
         cmp       ax,VIEWBMAX
         jae       ViewAkt4                 ; nalezen° zaá†tku bufferu
         jmp       short ViewAkt8

; ------ obrazovka je pod zaá†tkem bufferu

ViewAkt5:cmp       dx,-1
         jne       ViewAkt7                 ; je p©°li® daleko
         cmp       ax,-VIEWBMAX/2
         jb        ViewAkt7                 ; je p©°li® daleko
         call      ViewPred                 ; posun bufferu k zaá†tku
         jmp       short ViewAkt9

; ------ obrazovka je daleko pod zaá†tkem bufferu

ViewAkt7:sub       word ptr ds:[ViewBeg],cx  ; posun poá†tku bufferu
         sbb       word ptr ds:[ViewBeg+2],0 ; p©enos HIGH
         add       ax,cx                    ; posun ukazatele obrazovky
         adc       dx,0                     ; p©enos HIGH
         jnc       ViewAkt7                 ; nalezen° zaá†tku bufferu

; ------ novÇ naáten° celÇho bufferu na aktu†ln° pozici

ViewAkt8:call      ViewRBuf                 ; novÇ naáten° obsahu bufferu

; ------ n†vrat registrñ

ViewAkt9:pop       dx
         pop       cx
         pop       ax
         ret

ViewAkt  ENDP

; -----------------------------------------------------------------------------
;        posun na dal®° blok dat (CY=nen° dal®° blok)
; -----------------------------------------------------------------------------

ViewNxt  PROC      NEAR

; ------ test, zda je jië konec souboru

         cmp       word ptr ds:[ViewNum],VIEWBMAX ; je buffer plnò ?
         jb        ViewNxt9                 ; je jië konec souboru

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ posun ukazatelñ

         mov       cx,VIEWBMAX/2            ; polovina bufferu
         sub       ds:[ViewNum],cx          ; sn°ëen° dat v bufferu
         add       word ptr ds:[ViewBeg],cx ; posun ukazatele zaá†tku bufferu
         adc       word ptr ds:[ViewBeg+2],0 ; p©enos HIGH

; ------ p©esun bloku dat o polovinu bufferu dolñ

         push      ds
         pop       es
         mov       di,offset ViewBuf        ; zaá†tek bufferu
         mov       si,offset ViewBuf+VIEWBMAX/2 ; zaá†tek druhÇ poloviny
         shr       cx,1                     ; dÇlka dat ve slovech
         cld
         rep       movsw                    ; p©enos bufferu

; ------ naáten° druhÇho bloku dat do bufferu

         mov       si,di                    ; adresa druhÇ poloviny bufferu
         call      ViewRead                 ; naáten° bloku dat
         add       word ptr ds:[ViewNum],ax ; zvò®en° á°taáe dat v bufferu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         clc                                ; p©°znak operace OK
ViewNxt9:ret

ViewNxt  ENDP

; -----------------------------------------------------------------------------
;        posun na p©edchoz° blok dat (CY=je jië zaá†tek souboru)
; -----------------------------------------------------------------------------

ViewPred PROC      NEAR

; ------ test, zda je jië zaá†tek souboru

         cmp       word ptr ds:[ViewBeg],0  ; je zaá†tek bufferu ?
         jne       ViewPrd1                 ; nen° zaá†tek bufferu
         cmp       word ptr ds:[ViewBeg+2],0
         stc
         je        ViewPrd9                 ; je jië zaá†tek bufferu

; ------ £schova registrñ

ViewPrd1:push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ posun ukazatelñ

         mov       word ptr ds:[ViewNum],VIEWBMAX ; novò poáet bajtñ v bufferu
         mov       cx,VIEWBMAX/2            ; polovina bufferu
         sub       word ptr ds:[ViewBeg],cx ; posun ukazatele zaá†tku bufferu
         sbb       word ptr ds:[ViewBeg+2],0 ; p©enos HIGH

; ------ p©esun bloku dat o polovinu bufferu vò®e

         push      ds
         pop       es
         mov       si,offset ViewBuf        ; zaá†tek bufferu
         mov       di,offset ViewBuf+VIEWBMAX/2 ; zaá†tek druhÇ poloviny
         shr       cx,1                     ; dÇlka dat ve slovech
         cld
         rep       movsw                    ; p©enos bufferu

; ------ naáten° prvn°ho bloku dat do bufferu

         mov       si,offset ViewBuf        ; adresa prvn° poloviny bufferu
         call      ViewRead                 ; naáten° bloku dat

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         clc                                ; p©°znak operace OK
ViewPrd9:ret

ViewPred ENDP

; -----------------------------------------------------------------------------
;        naáten° obsahu celÇho bufferu
; -----------------------------------------------------------------------------

ViewRBuf PROC      NEAR

         push      ax
         push      si
         mov       si,offset ViewBuf        ; datovò buffer
         call      ViewRead                 ; naáten° prvn°ho bloku dat
         mov       ds:[ViewNum],ax          ; poáet bajtñ v bufferu
         call      ViewRead                 ; naáten° druhÇho bloku dat
         add       ds:[ViewNum],ax          ; poáet bajtñ v bufferu
         pop       si
         pop       ax
         ret

ViewRBuf ENDP

; -----------------------------------------------------------------------------
;        áten° bloku dat ze souboru (polovina bufferu)
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa v bufferu
; VùSTUP:AX=poáet naátenòch bajtñ
;        SI=n†sleduj°c° adresa
; -----------------------------------------------------------------------------

ViewRead PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx

; ------ nastaven° ukazatele v souboru

         xor       cx,cx                    ; CX <- 0 offset HIGH
         mov       dx,si                    ; adresa v bufferu
         sub       dx,offset ViewBuf        ; offset v bufferu
         add       dx,word ptr ds:[ViewBeg] ; offset v souboru LOW
         adc       cx,word ptr ds:[ViewBeg+2] ; offset v souboboru HIGH
         mov       bx,ds:[ViewIdnt]         ; identifik†tor souboru
         mov       ax,4200h
         int       21h                      ; nastaven° ukazatele v souboru

; ------ áten° bloku dat ze souboru

         mov       dx,si                    ; adresa ke áten° dat
         mov       cx,VIEWBMAX/2            ; velikost dat ke áten°
         mov       ah,3fh
         int       21h                      ; naáten° bloku dat
         jnc       ViewRd2                  ; operace OK
         xor       ax,ax                    ; jinak nic naáteno
ViewRd2: add       si,ax                    ; zvò®en° adresy v bufferu

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         ret

ViewRead ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Obsluha seznamu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛

; *****************************************************************************
;                              Sezn
;                 ovl†d†n° seznamu (tÇë bàhem naá°t†n°)
; -----------------------------------------------------------------------------
; VSTUP: BX=kl†vesa
;        DS=datovò segment
; VùSTUP:BX=0 - kl†vesa obslouëena
; *****************************************************************************

Sezn     PROC      NEAR

; ------ rozli®en°, zda je prohl°ëen° souboru

         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jz        Sezn00                   ; nen° ©†dkovò reëim
         ret

Sezn00:  cmp       bx,3d00h                 ; F3 zobrazen° souboru ?
         je        Sezn0                    ; zobrazen° souboru
         test      byte ptr ds:[Param],bit5 ; je prohl°ëen° souboru ?
         jz        Sezn1
Sezn0:   jmp       View                     ; obsluha prohl°ëen° souboru

; ------ £schova registrñ

Sezn1:   push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ obsluha kl†vesy

         mov       ax,ds:[SeznTop]          ; poá†tek seznamu
         mov       cx,ds:[DispNum]          ; poáet ©†dkñ seznamu
         mov       dx,ds:[SeznAkt]          ; aktivn° poloëka

         call      JumpBX                   ; obsluha kl†vesy

         dw        4800h,SeznUp             ; kurzor nahoru
         dw        5000h,SeznDwn            ; kurzor dolñ
         dw        4700h,SeznHome           ; HOME zaá†tek seznamu
         dw        4f00h,SeznEnd            ; END konec seznamu
         dw        8400h,SeznHome           ; ^PgUp zaá†tek seznamu
         dw        7600h,SeznEnd            ; ^PgDn konec seznamu
         dw        4900h,SeznPgUp           ; PgUp str†nka nahoru
         dw        5100h,SeznPgDn           ; PgDn str†nka dolñ
         dw        5200h,SeznIns            ; INSERT oznaáen° poloëky
         dw        5300h,SeznDel            ; DELETE oznaáen° v®ech poloëek
         dw        180fh,SeznCO             ; ^O zobrazen° podkladu

         dw        0,Sezn9                  ; neobsluhovan† kl†vesa

; ------ nastaven° kurzoru

Sezn8:   mov       ds:[SeznAkt],dx          ; nov† aktivn° poloëka
         mov       ds:[SeznTop],ax          ; poá†tek seznamu
         call      NormSezn                 ; normalizace seznamu
         call      DispSezn                 ; zobrazen° seznamu

; ------ n†vrat registrñ

Sezn9:   pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Sezn     ENDP

; -----------------------------------------------------------------------------
;        oznaáen° v®ech poloëek
; -----------------------------------------------------------------------------

SeznDel  PROC      NEAR

         jcxz      SeznDel2                 ; nen° ë†dn† poloëka
         test      byte ptr ds:[Param],bit2 ; je hled†n° souboru ?
         jnz       SeznDel2                 ; je hled†n° souboru
         xor       bx,bx
SeznDel1:call      Invert                   ; zmàna oznaáen° poloëky
         inc       bx                       ; zvò®en° ukazatele poloëek
         loop      SeznDel1                 ; oznaáen° dal®° poloëky
SeznDel2:jmp       short Sezn8

SeznDel  ENDP

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

SeznUp   PROC      NEAR

         or        dx,dx                    ; je jië zaá†tek seznamu ?
         jz        SeznUp1                  ; je jië zaá†tek seznamu
         dec       dx                       ; posun kurzoru
SeznUp1: jmp       short Sezn8

SeznUp   ENDP

; -----------------------------------------------------------------------------
;        oznaáen° poloëky (mus° n†sledovat posun kurzoru dolñ)
; -----------------------------------------------------------------------------

SeznIns  PROC      NEAR

         mov       bx,dx                    ; á°slo poloëky
         call      Invert                   ; zmàna oznaáen° poloëky
                                          ;* n†sleduje kurzor dolñ

SeznIns  ENDP

; -----------------------------------------------------------------------------
;        kurzor dolñ
; -----------------------------------------------------------------------------

SeznDwn  PROC      NEAR

         inc       dx                       ; posun kurzoru
         cmp       dx,cx
         jb        SeznDwn1
         dec       dx
SeznDwn1:jmp       short Sezn8

SeznDwn  ENDP

; -----------------------------------------------------------------------------
;        zaá†tek senzamu
; -----------------------------------------------------------------------------

SeznHome PROC      NEAR

         xor       dx,dx
         jmp       short Sezn8

SeznHome ENDP

; -----------------------------------------------------------------------------
;        konec seznamu
; -----------------------------------------------------------------------------

SeznEnd  PROC      NEAR

         mov       dx,cx
         jcxz      Sezn8
         dec       dx
Sezn88:  jmp       short Sezn8

SeznEnd  ENDP

; -----------------------------------------------------------------------------
;        str†nka nahoru
; -----------------------------------------------------------------------------

SeznPgUp PROC      NEAR

         or        ax,ax                    ; zobrazen poá†tek seznamu ?
         jz        SeznHome                 ; je poá†tek seznamu
         mov       bx,ds:[SeznRad]          ; poáet ©†dkñ na str†nku
         dec       bx                       ; poáet ©†dkñ - 1
         cmp       bx,ax                    ; lze posunout o celou str†nku ?
         jbe       SeznPgU1                 ; posun je OK
         mov       bx,ax                    ; omezen° dÇlky posunu
SeznPgU1:sub       ax,bx                    ; posun poá†tku str†nky
         sub       dx,bx                    ; posun kurzoru
         jmp       short Sezn88

SeznPgUp ENDP

; -----------------------------------------------------------------------------
;        str†nka dolñ
; -----------------------------------------------------------------------------

SeznPgDn PROC      NEAR

         mov       bx,cx                    ; konec seznamu
         sub       bx,ds:[SeznRad]          ; maxim†ln° poá†tek seznamu
         jnc       SeznPgD1                 ; nen° p©eteáen°
         xor       bx,bx                    ; omezen° poá†tku
SeznPgD1:cmp       ax,bx                    ; je jië konec seznamu ?
         jae       SeznEnd                  ; je konec seznamu
         sub       bx,ax                    ; poáet zbylòch ©†dkñ k posunu
         mov       cx,ds:[SeznRad]          ; poáet ©†dkñ na str†nku
         dec       cx                       ; poáet ©†dkñ - 1
         cmp       cx,bx                    ; je poáet ©†dkñ OK ?
         jbe       SeznPgD2                 ; poáet ©†dkñ je OK
         mov       cx,bx                    ; omezen° poátu ©†dkñ
SeznPgD2:add       ax,cx                    ; posun poá†tku str†nky
         add       dx,cx                    ; posun kurzoru
         jmp       short Sezn88

SeznPgDn ENDP

; -----------------------------------------------------------------------------
;        zobrazen° podkladu ^O
; -----------------------------------------------------------------------------

SeznCO   PROC      NEAR

         call      PopScr                   ; n†vrat obsahu obrazovky
         call      InpChr
         jmp       short Sezn88

SeznCO   ENDP

; -----------------------------------------------------------------------------
;        inverze oznaáen° poloëky BX
; -----------------------------------------------------------------------------

Invert   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ kontrola platnosti poloëky

         cmp       bx,ds:[DispNum]
         jae       Invert4                  ; nen° platn† poloëka

; ------ adresa poloëky

         shl       bx,1                     ; á°slo poloëky * 2
         mov       bx,ds:[bx+DispIndx]      ; adresa poloëky
         mov       es,ds:[SeznSegm]         ; segment seznamu souborñ

; ------ test, zda je platn† poloëka

         test      byte ptr es:[bx],bit6    ; je to platn† poloëka ?
         jnz       Invert4                  ; nen° to platn† poloëka

; ------ inverze oznaáen° poloëky

         xor       byte ptr es:[bx],bit7    ; zmàna p©°znaku oznaáen° poloëky

; ------ vòpoáet obsazenÇ kapacity souborem

         mov       ax,es:[bx+5]             ; velikost poloëky LOW
         mov       dx,es:[bx+7]             ; velikost poloëky HIGH
         mov       si,ax
         mov       di,dx
         mov       cx,ds:[DiskBlok]         ; poáet bajtñ na alok. blok
         jcxz      Invert1                  ; nàjak† chyba
         cmp       dx,cx                    ; je velikost OK ?
         jae       Invert1                  ; chybn† velikost - nezaokrouhl° se
         dec       cx                       ; velikost bloku - 1
         add       ax,cx                    ; zaokrouhlen° na alok. blok
         adc       dx,0                     ; p©enos
         inc       cx                       ; velikost alok. bloku
         cmp       dx,cx                    ; je chybn† velikost ?
         jae       Invert1                  ; chybn† velikost - nezaokrouhl° se
         div       cx                       ; vòpoáet alokaán°ch blokñ
         mul       cx                       ; velikost se zaokrouhlen°m

; ------ rozli®en°, zda je oznaáen° nebo odznaáen° poloëky

Invert1: test      byte ptr es:[bx],bit7    ; je poloëka nyn° oznaáen† ?
         jz        Invert2                  ; oznaáen° se zru®ilo

; ------ p©iáten° velikosti poloëky

         add       word ptr ds:[InsSumm],si ; p©iáten° velikosti LOW
         adc       word ptr ds:[InsSumm+2],di ; p©iáten° velikosti HIGH
         add       word ptr ds:[InsObs],ax  ; p©iáten° obsaz. kapacity LOW
         adc       word ptr ds:[InsObs+2],dx ; p©iáten° obsaz. kapacity HIGH
         inc       word ptr ds:[InsNum]     ; zvò®en° á°taáe poloëek
         jmp       short Invert4

; ------ odeáten° velikosti poloëky

Invert2: sub       word ptr ds:[InsSumm],si ; odeáten° velikosti LOW
         sbb       word ptr ds:[InsSumm+2],di ; odeáten° velikosti LOW
         sub       word ptr ds:[InsObs],ax  ; odeáten° obsaz. kapacity LOW
         sbb       word ptr ds:[InsObs+2],dx ; odeáten° obsaz. kapacity HIGH
         dec       word ptr ds:[InsNum]     ; sn°ëen° á°taáe poloëek

; ------ n†vrat registrñ

Invert4: pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Invert   ENDP

; *****************************************************************************
;                                DispSezn
;                        zobrazen° seznamu souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; lok†ln° promànnÇ: SS:[BP-2] (2) á°taá aktivn°ho ©†dku
;                   SS:[BP-3] (1) barva bàënÇho ©†dku s kurzorem
;                   SS:[BP-4] (1) barva bàënÇho ©†dku
;                   SS:[BP-5] (1) barva vysv°cenÇho ©†dku s kurzorem
;                   SS:[BP-6] (1) barva vysv°cenÇho ©†dku
;                   SS:[BP-8] (2) ukazatel v indexovÇ tabulce zobrazen°
;                   SS:[BP-10] (2) poáet indexñ v indexovÇ tabulce
;                   SS:[BP-11] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-12] (1) ukazatel ©†dku na obrazovce
;                   SS:[BP-14] (2) segment seznamu
;                   SS:[BP-16] (2) datovò segment
;                   SS:[BP-18] (1) barva cesty
; *****************************************************************************

DispSezn PROC      NEAR

         test      byte ptr ds:[Param],bit5 ; je prohl°ëen° souborñ ?
         jz        DispSz01                 ; nen° prohl°ëen°
         call      DispNadp                 ; zobrazen° informaán°ho ©†dku
         call      DispHlp                  ; zobrazen° n†povàdy
         ret

; ------ £schova registrñ

DispSz01:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es
         mov       bp,sp

; ------ p©°prava registrñ

         sub       sp,18+2*80               ; m°sto pro lok†ln° promànnÇ
         mov       bx,ds:[SeznTop]          ; prvn° ©†dek
         mov       ss:[bp-8],bx             ; ukazatel á°sla ©†dku
         mov       ax,ds:[SeznAkt]          ; aktivn° ©†dek
         sub       ax,bx                    ; offset od prvn°ho ©†dku
         inc       ax                       ; p©ednastaven°
         mov       ss:[bp-2],ax             ; á°taá aktivn°ho ©†dku
         mov       ax,word ptr ds:[Barva1]  ; bàën† barva a kurzor
         mov       ss:[bp-4],ax             ; barva bàënÇho ©†dku a kurzor
         mov       ax,word ptr ds:[Barva3]  ; vysv°cen† barva a kurzor
         mov       ss:[bp-6],ax             ; barva vysv°cenÇho ©†dku a kurzor
         mov       al,ds:[Barva5]           ; barva cesty
         mov       ss:[bp-18],al            ; barva cesty
         mov       ax,ds:[DispNum]          ; poáet indexñ v tabulce
         mov       ss:[bp-10],ax            ; poáet indexñ v tabulce
         or        ax,ax                    ; je nàco zobrazeno ?
         jnz       DispSzn0                 ; je nàco zobrazeno
         dec       word ptr ss:[bp-2]       ; kurzor nen° zobrazen
DispSzn0:mov       ah,ds:[Radku]            ; poáet ©†dkñ displeje
         sub       ah,2                     ; poáet ©†dkñ k zobrazen°
         mov       al,1                     ; ukazatel ©†dku na obrazovce
         mov       ss:[bp-12],ax            ; ukazatel a á°taá ©†dku
         mov       ax,ds:[SeznSegm]         ; segment seznamu
         mov       ss:[bp-14],ax            ; segment seznamu
         mov       ss:[bp-16],ds            ; datovò segment
         push      ss
         pop       es                       ; ES <- SS

; ------ p©°prava barvy poloëky

DispSzn1:mov       ah,ss:[bp-4]             ; bàën† barva
         mov       al,ss:[bp-6]             ; vysv°cen† barva
         dec       word ptr ss:[bp-2]       ; á°taá aktivn°ho ©†dku
         jnz       DispSzn2                 ; nen° aktivn° ©†dek
         mov       ah,ss:[bp-3]             ; bàënò kurzor
         mov       al,ss:[bp-5]             ; vysv°cenò kurzor
DispSzn2:mov       si,ss:[bp-8]             ; ukazatel v indexovÇ tabulce
         cmp       si,ss:[bp-10]            ; je platnò index ?
         jae       DispSzn3                 ; nen° platnò index
         shl       si,1
         mov       ds,ss:[bp-16]            ; datovò segment
         mov       si,ds:[si+DispIndx]      ; ©†dek k zobrazen°
         mov       ds,ss:[bp-14]            ; segment seznamu
         test      byte ptr ds:[si],bit7    ; je poloëka oznaáen† ?
         jz        DispSzn3                 ; nen° oznaáen†
         mov       ah,al                    ; barva oznaáenÇ poloëky

; ------ inicializaán° vymaz†n° buferu

DispSzn3:mov       al," "                   ; znak mezery k vymaz†n° buferu
         mov       di,sp                    ; buffer ©†dku
         mov       cx,80                    ; poáet znakñ k vymaz†n°
         cld
         rep       stosw                    ; vymaz†n° bufferu
         mov       di,sp                    ; adresa bufferu

; ------ adresa poloëky v bufferu

         mov       si,ss:[bp-8]             ; ukazatel v indexovÇ tabulce
         cmp       si,ss:[bp-10]            ; je platnò index ?
         jb        DispSzn4
DispSz88:jmp       DispSzn8                 ; nen° platnò index
DispSzn4:shl       si,1
         mov       ds,ss:[bp-16]            ; datovò segment
         mov       si,ds:[si+DispIndx]      ; ©†dek k zobrazen°
         mov       ds,ss:[bp-14]            ; segment seznamu

; ------ dek¢dov†n° textu adres†©e

         test      byte ptr ds:[si],bit6    ; je to text adres†©e ?
         jz        DispSzn6                 ; nen° to text adres†©e
         and       ah,0f0h
         or        ah,ss:[bp-18]            ; barva cesty
         inc       si
DispSzn5:lodsb
         cmp       al,0
         je        DispSz88                 ; konec textu
         stosw                              ; uloëen° znaku
         jmp       short DispSzn5           ; dal®° znak

; ------ dek¢dov†n° jmÇna souboru

DispSzn6:add       di,4*2                   ; zaá†tek k dek¢dov†n° jmÇna souboru
         mov       al,"˚"
         test      byte ptr ds:[si],bit7
         jnz       DispSz61
         mov       al," "
DispSz61:stosw
         mov       al," "
         stosw
         mov       bl,ds:[si]               ; atributy
         and       bl,DIR                   ; atribut adres†©e
         shl       bl,1                     ; na hodnotu 20h
         xor       bl,20h                   ; oprava hodnoty
         push      si
         add       si,9                     ; text jmÇna
         push      di
         cld
DispSz62:lodsb
         cmp       al,0
         je        DispSz64
         cmp       al,"."
         je        DispSz64
         cmp       al,"A"
         jb        DispSz63
         cmp       al,"Z"
         ja        DispSz63
         add       al,bl                    ; korekce na malÇ p°smeno
DispSz63:stosw
         jmp       short DispSz62
DispSz64:pop       di
         add       di,2*9

; ------ dek¢dov†n° p©°pony jmÇna souboru

         push      di
         cmp       al,0
         je        DispSz68
DispSz66:lodsb
         cmp       al,0
         je        DispSz68
         cmp       al,"A"
         jb        DispSz67
         cmp       al,"Z"
         ja        DispSz67
         add       al,bl                    ; korekce na malÇ p°smeno
DispSz67:stosw
         jmp       short DispSz66
DispSz68:pop       di
         pop       si
         add       di,3*2

; ------ dek¢dov†n° velikosti souboru

         test      byte ptr ds:[si],DIR     ; je to adres†© ?
         jz        DispSz69                 ; nen° to adres†©
         push      si
         push      ds
         add       di,2*4
         mov       ds,ss:[bp-16]            ; datovò segment
         mov       cx,9
         mov       si,offset AdrTxt
DspSz682:lodsb
         stosw
         loop      DspSz682
         pop       ds
         pop       si
         jmp       short DispSz6a

DispSz69:add       di,13*2
         push      ax
         mov       bh,ah                    ; barva
         mov       bl,"."                   ; oddàlovaá ©†dñ
         mov       ax,ds:[si+5]             ; velikost LOW
         mov       dx,ds:[si+7]             ; velikost HIGH
         call      DekCNum                  ; dek¢dov†n° á°sla s barvou
         pop       ax
         cld
DispSz6a:add       di,2*2

; ------ dek¢dov†n° data souboru

         mov       bx,ds:[si+3]             ; datum souboru
         mov       al,bl                    ; den
         and       al,31                    ; den
         call      DekNm                    ; dek¢dov†n° á°sla
         mov       al,"."
         stosw                              ; odddàlovac° teáka
         mov       cl,5                     ; poáet rotac°
         shr       bx,cl                    ; rotace
         mov       al,bl
         and       al,15                    ; màs°c
         call      DekNm0                   ; dek¢dov†n° màs°ce
         mov       al,"."
         stosw                              ; oddàlovac° teáka
         mov       cl,4                     ; poáet rotac°
         shr       bx,cl                    ; rotace
         add       di,4*2
         push      ax
         mov       bh,ah                    ; barva
         mov       al,bl
         mov       bl,0                     ; nen° oddàlovaá ©†dñ
         mov       ah,0
         add       ax,1980                  ; korekce roku
         xor       dx,dx
         call      DekCNum                  ; dek¢dov†n° roku
         pop       ax
         add       di,2*2

; ------ dek¢dov†n° áasu souboru

         mov       bx,ds:[si+1]             ; áas souboru
         mov       ch,bl                    ; £schova sekundy
         mov       al,bh                    ; hodina
         mov       cl,3                     ; poáet rotac°
         shr       al,cl                    ; rotace na pozici
         call      DekNm                    ; dek¢dov†n° hodiny
         mov       al,":"
         stosw                              ; oddàlovaá áasu
         shl       bx,cl                    ; rotace na pozici
         mov       al,bh                    ; minuta
         and       al,63
         call      DekNm0                   ; dek¢dov†n° minuty
         mov       al,":"
         stosw                              ; oddàlovaá
         mov       al,ch                    ; sekunda/2
         and       al,31                    ; sekunda/2
         shl       al,1                     ; sekunda
         call      DekNm0                   ; dek¢dov†n° sekundy
         add       di,2*2

; ------ dek¢dov†n° atributñ souboru

         mov       bl,ds:[si]               ; atributy
         mov       ds,ss:[bp-16]            ; datovò segment
         mov       bh,5                     ; poáet atributñ
         mov       si,offset AtrTab
DispSz71:lodsb
         mov       cl,al                    ; poáet rotac°
         shl       bl,cl                    ; rotace atributu
         jnc       DispSz72                 ; nen° nastaven
         lodsb
         stosw
         lodsb
         stosw
         lodsb
         stosw
         jmp       short DispSz73

DispSz72:mov       al," "
         stosw
         mov       al,"-"
         stosw
         mov       al," "
         stosw
         add       si,3

DispSz73:mov       al," "
         stosw
         dec       bh
         jnz       DispSz71                 ; dal®° atribut

; ------ zobrazen° ©†dku seznamu

DispSzn8:mov       ds,ss:[bp-16]            ; datovò segment
         mov       si,sp                    ; adresa bufferu s ©†dkem
         mov       cl,80                    ; dÇlka textu
         mov       dl,0
         mov       dh,ss:[bp-12]            ; ©†dek k zobrazen°
         call      DispStr                  ; zobrazen° ©†dku seznamu

; ------ p©°prava pro dal®° ©†dek

         inc       word ptr ss:[bp-8]       ; zvò®en° á°sla ©†dku
         inc       byte ptr ss:[bp-12]      ; zvò®en° ukazatele na obrazovce
         dec       byte ptr ss:[bp-11]      ; á°taá ©†dkñ k zobrazen°
         jz        DispSzn9                 ; konec
         jmp       DispSzn1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispSzn9:mov       sp,bp
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      DispNadp                 ; zobrazen° informaán°ho ©†dku
         call      DispHlp                  ; zobrazen° n†povàdy
         ret

DispSezn ENDP

; -----------------------------------------------------------------------------
;        normalizace seznamu
; -----------------------------------------------------------------------------

NormSezn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx

; ------ p©°prava registrñ

         mov       ax,ds:[SeznAkt]          ; aktivn° poloëka
         mov       bx,ds:[SeznTop]          ; prvn° poloëka

; ------ kontrola podteáen° pod poá†tek

         cmp       ax,bx                    ; je podteáen° pod poá†tek ?
         ja        NormSzn2                 ; nen° podteáen° pod poá†tek
         mov       bx,ax                    ; omezen° poá†tku zdola
         or        bx,bx
         jz        NormSzn2                 ; je prvn° ©†dek
         dec       bx

; ------ vòpoáet maxim†ln°ho prvn°ho ©†dku

NormSzn2:mov       cx,ds:[DispNum]
         jcxz      NormSz23                 ; nen° nic
         dec       cx
         cmp       ax,cx                    ; je posledn° ©†dek ?
         mov       cx,ds:[SeznRad]          ; poáet ©†dkñ na str†nku
         jae       NormSz22                 ; je posledn° ©†dek
         dec       cx                       ; je®tà jeden ©†dek rezerva
NormSz22:dec       cx                       ; poáet ©†dkñ - 1
         sub       ax,cx                    ; maxim†ln° prvn° ©†dek
         jae       NormSzn3
NormSz23:xor       ax,ax                    ; omezen° max. prvn°ho ©†dku

; ------ kontrola p©eteáen° kurzoru za konec

NormSzn3:cmp       ax,bx                    ; je p©eteáen° za konec ?
         jbe       NormSzn4                 ; kurzor je OK
         mov       bx,ax                    ; omezen° prvn°ho ©†dku

; ------ uloëen° registrñ

NormSzn4:mov       ds:[SeznTop],bx          ; nov† prvn° poloëka

; ------ n†vrat registrñ

         pop       cx
         pop       bx
         pop       ax
         ret

NormSezn ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla 2 á°slice (AL=á°slo, AH=barva)
; -----------------------------------------------------------------------------

DekNm0:  mov       byte ptr es:[di],"0"     ; prvn° znak bude nula

DekNm    PROC      NEAR

         push      ax
         push      bx
         push      dx

         add       di,2*2
         mov       bh,ah                    ; barva
         mov       bl,0                     ; nen° oddàlovaá ©†dñ
         xor       dx,dx
         mov       ah,0
         call      DekCNum                  ; dek¢dov†n° á°sla

         pop       dx
         pop       bx
         pop       ax
         ret

DekNm    ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° textu ASCIIZ
; -----------------------------------------------------------------------------

DekTxt   PROC      NEAR

         push      ax
         push      si
         cld
DekTxt1: lodsb
         cmp       al,0
         je        DekTxt2
         stosw
         jmp       short DekTxt1
DekTxt2: pop       si
         pop       ax
         ret

DekTxt   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Rozbor zad†n° parametrñ operace
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; *****************************************************************************
;                               Rozbor
;                  Rozbor zad†n° parametrñ operace
;        Buffer editovanÇho ©†dku je doplnàn mezerami na plnou velikost
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba zad†n° parametrñ
;        SI=adresa chyby zad†n° v editaán°m bufferu
; *****************************************************************************
;˛
Rozbor   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

         push      ds
         pop       es                       ; ES <- datovò segment

         and       byte ptr ds:[Param],not bit3 ; zru®en° p©°znaku hled†n° textu
         or        byte ptr ds:[Param2],bit0 ; p©°znak podadres†©ñ

; ------ p©ednastaven° z†kladn°ho adres†©e aktivn°ho disku ("C:\")

         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         add       al,"A"                   ; korekce na znak ASCII
         mov       di,offset FilePath       ; buffer adres†©e
         cld
         mov       ah,":"                   ; oddàlovaá diskñ ":"
         stosw                              ; oznaáen° disku a oddàlovaá
         mov       ax,"\"                   ; adres†© ROOT a koncov† 0
         stosw                              ; lom°tko ROOT a koncov† 0
         mov       word ptr ds:[FilePthN],3 ; dÇlka textu

; ------ nalezen° zaá†tku parametrñ ( -> BX)

         mov       di,offset EditBuff       ; editaán° buffer
         mov       cx,MAXLINE               ; dÇlka ©†dku edit. bufferu
         mov       al,"/"                   ; znak parametrñ
         cld
         repne     scasb                    ; nalezen° oddàlovaáe parametrñ "/"
         dec       di                       ; n†vrat zaá†tku parametrñ "/"
         mov       bx,di                    ; £schova zaá†tku parametrñ

; ------ nalezen° zaá†tku textñ masek ( -> DI)

Rozbor1: cmp       di,offset EditBuff       ; je jië zaá†tek bufferu ?
         jbe       Rozbor2                  ; je jië zaá†tek bufferu
         cmp       byte ptr ds:[di-1],"\"   ; je oddàlovaá adres†©e ?
         je        Rozbor2                  ; je posledn° znak adres†©e
         cmp       byte ptr ds:[di-1],":"   ; je oddàlovaá disku ?
         je        Rozbor2                  ; je oznaáen° disku
         dec       di                       ; posun ukazatele
         jmp       short Rozbor1            ; jinak hled†n° dal®°ho znaku

; ------ nalezen° zaá†tku zadanÇ cesty ( -> SI)

Rozbor2: mov       si,offset EditBuff       ; zaá†tek edit. bufferu
Rozbor21:cmp       si,di                    ; je jië konec cesty ?
         jae       Rozbor4                  ; adres†© nen° zad†n - bude ROOT
         cmp       byte ptr ds:[si]," "     ; je platnò text ?
         jne       Rozbor3                  ; je zad†n adres†©
         inc       si                       ; p©eskoáen° znaku mezery
         jmp       short Rozbor21           ; dal®° znak

; ------ rozbor zad†n° cesty (je nàco zad†no)

Rozbor3: mov       cx,di                    ; konec textu cesty
         sub       cx,si                    ; dÇlka textu cesty (nen° = 0)
         call      RozbPth                  ; rozbor zad†n° textu adres†©e

; ------ rozbor zad†n° masek

Rozbor4: mov       si,di                    ; zaá†tek textu masek
         mov       cx,bx                    ; zaá†tek parametrñ
         sub       cx,si                    ; dÇlka textu masek
         call      RozbMsk                  ; rozbor zad†n° masek

; ------ rozbor zad†n° parametrñ

         mov       si,bx                    ; zaá†tek parametrñ (znak "/")
         mov       cx,offset EditBuff+MAXLINE ; konec bufferu + 1
         sub       cx,si                    ; dÇlka textu parametrñ
         call      RozbParm                 ; rozbor zadanòch parametrñ

; ------ n†vrat registrñ

Rozbor9: pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Rozbor   ENDP

; *****************************************************************************
;                               RozbPth
;                         rozbor zad†n° cesty
; -----------------------------------------------------------------------------
; VSTUP: SI=zadanò text (odstranàny £vodn° a z†vàreánÇ mezery)
;        CX=dÇlka textu (nen°=0)
;        DS,ES=datovò segment
; *****************************************************************************

RozbPth  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ implicitn° disk (aktivn°)

         mov       ah,19h
         int       21h                      ; poskytnut° aktivn°ho disku
         add       al,"A"                   ; korekce na p°smeno

; ------ naáten° oznaáen° disku ze zad†n°

         cld
         mov       ah,":"                   ; oddàlovaá diskñ ":"
         cmp       cx,2                     ; zbòv† dost znakñ ?
         jb        RozbPth1                 ; zbòv† m†lo znakñ
         cmp       ds:[si+1],ah             ; je zad†n disk (oznaáen° ":") ?
         jne       RozbPth1                 ; nen° zad†n disk
         lodsb                              ; zadanò disk
         inc       si                       ; p©eskoáen° oddàlovaáe disku ":"
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         call      UpCase                   ; korekce na velkÇ p°smeno

; ------ uloëen° oznaáen° disku a zaá†tku cesty (ROOT)

RozbPth1:mov       dl,al                    ; £schova oznaáen° disku ASCII
         mov       di,offset FilePath       ; buffer k uloëen° cesty
         cld
         stosw                              ; uloëen° oznaáen° disku
         mov       ax,"\"                   ; oznaáen° ROOT adres†©e a koncov† 0
         stosw                              ; uloëen° oznaáen° ROOT a koncovÇ 0
         dec       di                       ; n†vrat na koncovou 0

; ------ naáten° aktivn°ho adres†©e disku

         sub       dl,"A"-1                 ; á°slo disku 1,...
         push      si                       ; ukazatel textu
         mov       si,di                    ; adresa k naáten° adres†©e
         mov       ah,47h
         int       21h                      ; naáten° aktivn°ho adres†©e
         pop       si

; ------ nalezen° konce naátenÇ cesty

         mov       al,0                     ; hledanò bajt 0
         cld
         push      cx                       ; poáet zbylòch znakñ
         mov       cx,MAXLINE-3             ; dÇlka zbytku textu
         repne     scasb                    ; nalezen° koncovÇ 0
         pop       cx
         dec       di                       ; n†vrat na koncovou 0

; ------ zaji®tàn° koncovÇho znaku "\"

         mov       al,"\"                   ; znak "\"
         cmp       ds:[di-1],al             ; je posledn° znak "\" ?
         je        RozbPth2                 ; je posledn° znak "\"
         stosb                              ; nastaven° posledn°ho znaku "\"

; ------ je-li zad†n ROOT, nastaven° na ROOT

RozbPth2:jcxz      RozbPth3                 ; nezbyl dal®° znak
         cmp       byte ptr ds:[si],"\"     ; je zad†n ROOT ?
         jne       RozbPth3                 ; nen° zad†n ROOT
         mov       di,offset FilePath+3     ; jinak nastaven° za ROOT
         inc       si                       ; p©eskoáen° znaku "\"
         dec       cx                       ; á°taá zbylòch znakñ

; ------ test poátu zbylòch znakñ, konec zad†n°

RozbPth3:cmp       cx,1                     ; poáet zbylòch znakñ
         jb        RozbPth8                 ; konec zad†n°
         je        RozbPth5                 ; malò poáet znakñ pro ".."

; ------ sn°ëen° £rovnà o adres†© ".."

         cmp       word ptr ds:[si],".."    ; je sn°ëen° £rovnà ?
         jne       RozbPth5                 ; nen° sn°ëen° £rovnà
RozbPth4:cmp       di,offset FilePath + 3   ; je jië ROOT ?
         jbe       RozbPth7                 ; je jië ROOT
         dec       di                       ; sn°ëen° ukazatele
         cmp       byte ptr ds:[di-1],"\"   ; je jië zaá†tek podadres†©e ?
         jne       RozbPth4                 ; nen° zaá†tek - dal®° znak
         jmp       short RozbPth7           ; dal®° podadres†©

; ------ stejn† £rove§ adres†©e "."

RozbPth5:cmp       byte ptr ds:[si],"."     ; je stejnò adres†© ?
         je        RozbPth7                 ; stejn† £rove§ - ignoruje se

; ------ p©enesen° textu podadres†©e

RozbPth6:cmp       byte ptr ds:[si],"\"     ; bude jië konec adres†©e ?
         je        RozbPth7                 ; konec adres†©e
         cld
         lodsb                              ; naáten° znaku
         call      UpCase                   ; korekce na velkÇ p°smeno
         cld
         stosb                              ; uloëen° znaku do cesty
         loop      RozbPth6                 ; dal®° znak

; ------ nalezen° konce jednoho adres†©e

RozbPth7:jcxz      RozbPth8                 ; nen° dal®° znak zad†n°
         cld
         lodsb                              ; naáten° dal®°ho znaku
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       al,"\"                   ; je konec adres†©e ?
         jne       RozbPth7                 ; nen° konec - dal®° znak

; ------ oznaáen° konce podadres†©e

         cmp       es:[di-1],al             ; byl oznaáen konec podadres†©e ?
         je        RozbPth3                 ; je jië znak "\" - dal®° adres†©
         stosb                              ; uloëen° znaku "\"
         jmp       short RozbPth3           ; dal®° adres†©

; ------ zaji®tàn° koncovÇho znaku "\"

RozbPth8:mov       al,"\"
         cmp       ds:[di-1],al             ; byla cesta ukonáena "\" ?
         je        RozbPth9                 ; je jië koncovò znak "\"
         stosb                              ; oznaáen° konce cesty

; ------ nastaven° dÇlky textu

RozbPth9:mov       byte ptr ds:[di],0       ; oznaáen° konce cesty
         sub       di,offset FilePath       ; dÇlka textu v bufferu
         mov       ds:[FilePthN],di         ; dÇlka textu v bufferu

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RozbPth  ENDP

; *****************************************************************************
;                                RozbMsk
;                         rozbor zad†n° masek
; -----------------------------------------------------------------------------
; VSTUP: SI=zadanò text
;        CX=dÇlka textu (mñëe bòt i CX=0)
;        DS,ES=datovò segment
; *****************************************************************************

RozbMsk  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       di,offset FileMask       ; buffer k dek¢dov†n° zadanòch masek
         cld

; ------ vypu®tàn° poá†teán°ch mezer jednÇ masky

         jcxz      RozbMsk8                 ; nejsou ë†dnÇ znaky
RozbMsk2:mov       bl,0                     ; p©°znak, ëe nen° teáka
         cmp       byte ptr ds:[si]," "     ; je jië platnò znak ?
         jne       RozbMsk3                 ; je platnò znak
         inc       si                       ; zvò®en° ukazatele v textu
         loop      RozbMsk2                 ; test dal®°ho znaku

; ------ p©enos textu jednÇ masky

RozbMsk3:jcxz      RozbMsk8                 ; konec textu
         lodsb                              ; naáten° znaku masky
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ
         cmp       al," "                   ; oddàlovac° mezera ?
         je        RozbMsk5                 ; konec textu jednÇ masky
         cmp       al,"."                   ; je teáka ?
         jne       RozbMsk4                 ; nen° teáka
         mov       bl,al                    ; p©°znak teáky
RozbMsk4:call      UpCase                   ; konverze na velkÇ p°smeno
         cld
         stosb                              ; uloëen° do bufferu
         jmp       short RozbMsk3           ; dal®° znak masky

; ------ nalezen° zaá†tku dal®° masky

RozbMsk5:cmp       bl,0                     ; byla teáka ?
         jne       RozbMs55                 ; byla teáka
         mov       al,"*"
         cmp       byte ptr ds:[di-1],al    ; byl na konci znak "*" ?
         je        RozbMs55                 ; byl jië znak "*"
         stosb                              ; uloëen° znaku "*"
RozbMs55:jcxz      RozbMsk8                 ; nejsou dal®° znaky
         mov       al," "                   ; hledanò znak mezery
RozbMsk6:cmp       ds:[si],al               ; je jië platnò znak ?
         jne       RozbMsk7                 ; je platnò znak
         inc       si                       ; zvò®en° ukazatele v textu
         loop      RozbMsk6                 ; test dal®°ho znaku
         jmp       short RozbMsk8           ; nen° dal®° znak
RozbMsk7:stosb                              ; mezera mezi maskami
         jmp       short RozbMsk3           ; dek¢dov†n° dal®° masky

; ------ konec dek¢dov†n°

RozbMsk8:mov       byte ptr ds:[di],0       ; oznaáen° konce textu
         sub       di,offset FileMask       ; poáet znakñ v bufferu
         mov       ds:[FileMskN],di         ; poáet znakñ v bufferu

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RozbMsk  ENDP

; *****************************************************************************
;                                RozbParm
;                      rozbor zad†n° parametrñ operace
; -----------------------------------------------------------------------------
; VSTUP: SI=ukazatel zaá†tku textu
;        CX=poáet zbylòch znakñ textu
;        DS,ES=datovò segment
; VùSTUP:CY=chyba zad†n°
;        SI=adresa textu s chybou
; *****************************************************************************

RozbParm PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ inicializace parametrñ na standardn° hodnoty

         push      cx
         mov       di,offset SrcInit1       ; zaá†tek tabulky parametrñ hled†n°
         mov       cx,offset(SrcInit2-SrcInit1) ; dÇlka tabulky
         xor       ax,ax                    ; nulovac° bajt
         cld
         rep       stosb                    ; vynulov†n° tabulky
         dec       ax                       ; AX <- 0ffffh
         mov       word ptr ds:[SrcSiz2],ax ; koncov† velikost LOW
         mov       word ptr ds:[SrcSiz2+2],ax ; koncov† velikost HIGH
         pop       cx

; ------ naáten° prvn°ho znaku operace

RozbPar1:call      RozbPCh                  ; naáten° dal®°ho znaku
         cmc
         jnc       RozbPar9                 ; nen° dal®° znak
         cmp       al,"/"
         je        RozbPar1                 ; znak "/" se ignoruje
         call      UpCase                   ; p©evod na velkÇ p°smeno

; ------ zad†n° data

RozbPar2:cmp       al,"D"                   ; je zad†n° data ?
         jne       RozbPar3                 ; nen° zad†n° data
         call      RozbPDat                 ; rozbor zad†n° data
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° áasu

RozbPar3:cmp       al,"T"                   ; je zad†n° áasu ?
         jne       RozbPar4                 ; nen° zad†n° áasu
         call      RozbPTim                 ; rozbor zad†n° áasu
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° velikosti

RozbPar4:cmp       al,"N"                   ; je zad†n° velikosti ?
         jne       RozbPar5                 ; nen° zad†n° velikosti
         call      RozbPSiz                 ; rozbor zad†n° velikosti
         jmp       short RozbPar1           ; dal®° parametr

; ------ zad†n° textu

RozbPar5:cmp       al,'"'
         je        RozbPar6                 ; je zad†n text
         cmp       al,"'"
         jne       RozbPar7                 ; nen° zad†n text
RozbPar6:call      RozbPTxt                 ; rozbor zad†n° textu k hled†n°
         jmp       short RozbPar1           ; dal®° parametr

; ------ z†kaz podadres†©ñ

RozbPar7:cmp       al,"Z"
         jne       RozbPar8
         and       byte ptr ds:[Param2],not bit0
         jmp       short RozbPar1

; ------ zad†n° atributñ

RozbPar8:call      RozbPAtr                 ; rozbor zad†n° atributñ
         jnc       RozbPar1                 ; byl to platnò znak atributu

                                            ; jinak n†vrat p©i chybà zad†n°

; ------ n†vrat registrñ

RozbPar9:pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

RozbParm ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° textu k hled†n° (VSTUP: AL=£vodn° znak uvozovek)
;                          (niá° registry AX a DI)
; -----------------------------------------------------------------------------

RozbPTxt PROC      NEAR

         mov       di,offset SrcText        ; buffer textu k hled†n°
         mov       ah,al                    ; £schova £vodn°ho znaku parametru
         cld

; ------ naáten° znaku

RozbPTx1:jcxz      RozbPTx5                 ; konec ©†dku - p©edáasnÇ ukonáen°
         lodsb                              ; naáten° znaku textu
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ test, zda je konec textu

         cmp       al,ah                    ; je znak konce textu ?
         jne       RozbPTx3                 ; nen° konec textu
         jcxz      RozbPTx7                 ; byl to posledn° znak
         cmp       ds:[si],al               ; je to zdvojenò znak ?
         jne       RozbPTx7                 ; konec parametru
         lodsb                              ; naáten° zdvojenÇho znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ uloëen° platnÇho znaku

RozbPTx3:call      UpCase                   ; p©evod na velkÇ p°smeno
         cld
         stosb                              ; uloëen° znaku
         jmp       short RozbPTx1           ; dek¢dov†n° dal®°ho znaku

; ------ p©edáasnÇ ukonáen° ©†dku - odstranàn° koncovòch mezer

RozbPTx5:cmp       di,offset SrcText        ; je jië zaá†tek ©†dku ?
         je        RozbPTx7                 ; je jië zaá†tek ©†dku
         cmp       byte ptr ds:[di-1]," "   ; je mezera ?
         jne       RozbPTx7                 ; nen° mezera
         dec       di                       ; sn°ëen° ukazatele textu
         jmp       short RozbPTx5           ; dal®° znak

; ------ nastaven° parametrñ textu

RozbPTx7:sub       di,offset SrcText        ; dÇlka zadanÇho textu
         mov       ds:[SrcTextN],di         ; uloëen° dÇlky textu
         jz        RozbPTx8                 ; nebylo nic zad†no
         or        byte ptr ds:[Param],bit3 ; p©°znak zad†n° textu k hled†n°

RozbPTx8:ret

RozbPTxt ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° atributñ (AL=znak) (vòstup: CY=nezn†mò znak)
; -----------------------------------------------------------------------------

RozbPAtr PROC      NEAR

         mov       di,offset SrcAtr         ; atributy hledanÇho souboru

; ------ rozli®en°, zda bylo velkÇ nebo malÇ p°smeno

         mov       dl,1                     ; hodnota atributu + (velkÇ p°smeno)
         cmp       al,ds:[si-1]             ; zmànil se znak z malÇho na velkÇ ?
         je        RozbPAt2                 ; bylo velkÇ p°smeno
         mov       dl,0                     ; hodnota atributu - (malÇ p°smeno)

; ------ rozli®en° atributñ

RozbPAt2:mov       dh,0                     ; poáet rotac° pro bit R/O
         cmp       al,"R"                   ; je R/O ?
         je        RozbPAt3                 ; je R/O
         mov       dh,1                     ; poáet rotac° pro bit HID
         cmp       al,"H"                   ; je HID ?
         je        RozbPAt3                 ; je HID
         mov       dh,2                     ; poáet rotac° pro bit SYS
         cmp       al,"S"                   ; je SYS ?
         je        RozbPAt3                 ; je SYS
         mov       dh,4                     ; poáet rotac° pro bit DIR
         cmp       al,"C"                   ; je DIR ?
         je        RozbPAt3                 ; je DIR
         mov       dh,5                     ; poáet rotac° pro bit ARC
         cmp       al,"A"                   ; je ARC ?
         je        RozbPAt3                 ; je ARC
         dec       si                       ; n†vrat znaku
         inc       cx
         stc                                ; p©°znak chyby
         ret

; ------ naáten° znaku hodnoty bitu (+ nebo -)

RozbPAt3:call      RozbPCh                  ; naáten° dal®°ho znaku
         jc        RozbPAt6                 ; nen° dal®° znak
         cmp       al,"+"                   ; je nastaven° atributu "+" ?
         jne       RozbPAt4                 ; nen° nastaven° atributu "+"
         mov       dl,1                     ; hodnota pro nastaven°
         jmp       short RozbPAt6
RozbPAt4:cmp       al,"-"                   ; je nulov†n° atributu "-" ?
         jne       RozbPAt5                 ; nen° nulov†n° atributu "-"
         mov       dl,0                     ; hodnota pro nulov†n°
         jmp       short RozbPAt6
RozbPAt5:dec       si                       ; jinak n†vrat naátenÇho znaku
         inc       cx                       ; n†vrat á°taáe znakñ

; ------ nastaven° hodnoty bitu

RozbPAt6:push      cx
         mov       cl,dh                    ; poáet rotac°
         mov       dh,1                     ; maska pro nulov†n°
         shl       dh,cl                    ; rotace masky
         shl       dl,cl                    ; rotace hodnoty bitu
         or        ds:[di+1],dh             ; povolen° testu masky
         not       dh                       ; negace - bude se nulovat
         and       ds:[di],dh               ; nulov†n° starÇ hodnoty bitu
         or        ds:[di],dl               ; poëadovan† hodnota bitu
         pop       cx                       ; zde je p©°znak NC = operace OK
RozbPAt9:
         ret

RozbPAtr ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° data
; -----------------------------------------------------------------------------

RozbPDat PROC      NEAR

; ------ rozbor poá†teán°ho data

         mov       di,offset SrcDat1        ; poá†teán° datum
         mov       dx,0*HI + 31             ; rotace + maxim†ln° hodnota dne
         call      RozbDT                   ; rozbor dne
         mov       dx,5*HI + 15             ; rotace + maxim†ln° hodnota màs°ce
         call      RozbDT                   ; rozbor màs°ce
         call      RozbRok                  ; rozbor roku

; ------ kopie do koncovÇho data

         mov       ax,ds:[di]               ; zadan† hodnota
         mov       ds:[di+4],ax
         mov       ax,ds:[di+2]             ; maska
         mov       ds:[di+6],ax

; ------ oddàlovac° znamÇnko "-"

         call      RozbInt                  ; test znaku intervalu "-"
         jc        RozbPDt6                 ; nen° znak intervalu

; ------ rozbor koncovÇho data

RozbPDt4:mov       di,offset SrcDat2        ; koncovÇ datum
         mov       dx,0*HI + 31             ; rotace + maxim†ln° hodnota dne
         call      RozbDT                   ; rozbor dne
         mov       dx,5*HI + 15             ; rotace + maxim†ln° hodnota màs°ce
         call      RozbDT                   ; rozbor màs°ce
         call      RozbRok                  ; rozbor roku

; ------ test, zda bylo nàco zad†no

RozbPDt6:cmp       word ptr ds:[SrcDat1M],0 ; je poá†teán° datum ?
         jne       RozbPDt9                 ; je zad†no
         cmp       word ptr ds:[SrcDat2M],0 ; je koncovÇ datum ?
         jne       RozbPDt9                 ; je zad†no

; ------ nastaven° aktu†ln°ho data

         push      cx
         mov       ah,2ah
         int       21h                      ; poskytnut° systÇmovÇho data
         xchg      ax,cx                    ; rok
         sub       ax,1980                  ; offset roku od 1980
         shl       al,1                     ; rotace na pozici
         xchg      dh,al                    ; st©adaá hodnoty
         mov       cl,5                     ; poáet rotac°
         shl       ax,cl                    ; rotace màs°ce na pozici
         or        dx,ax                    ; aktu†ln° datum
         mov       ds:[SrcDat1],dx          ; poá†teán° datum
         mov       ds:[SrcDat2],dx          ; koncovÇ datum
         mov       word ptr ds:[SrcDat1M],-1 ; maska poá†teán°ho data
         mov       word ptr ds:[SrcDat2M],-1 ; maska koncovÇho data
         pop       cx

RozbPDt9:
         ret

RozbPDat ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° áasu
; -----------------------------------------------------------------------------

RozbPTim PROC      NEAR

; ------ rozbor poá†teán°ho áasu

         mov       di,offset SrcTim1        ; poá†teán° áas
         mov       dx,11*HI + 31            ; rotace + maxim†ln° hodnota hodin
         call      RozbDT                   ; rozbor hodin
         mov       dx,5*HI + 63             ; rotace + maxim†ln° hodnota minuty
         call      RozbDT                   ; rozbor minut
         call      RozbSek                  ; rozbor sekund

; ------ kopie do koncovÇho áasu

         mov       ax,ds:[di]               ; £daj
         mov       ds:[di+4],ax
         mov       ax,ds:[di+2]             ; maska
         mov       ds:[di+6],ax

; ------ oddàlovac° znamÇnko "-"

         call      RozbInt                  ; test zad†n° znaku intervalu
         jc        RozbPTm6                 ; nen° znak intervalu

; ------ rozbor koncovÇho áasu

RozbPTm4:mov       di,offset SrcTim2        ; koncovò áas
         mov       dx,11*HI + 31            ; rotace + maxim†ln° hodnota hodin
         call      RozbDT                   ; rozbor hodin
         mov       dx,5*HI + 63             ; rotace + maxim†ln° hodnota minuty
         call      RozbDT                   ; rozbor minut
         call      RozbSek                  ; rozbor sekund

; ------ test, zda bylo nàco zad†no

RozbPTm6:cmp       word ptr ds:[SrcTim1M],0 ; je poá†teán° áas ?
         jne       RozbPTm9                 ; je zad†n
         cmp       word ptr ds:[SrcTim2M],0 ; je koncovò áas ?
         jne       RozbPTm9                 ; je zad†n

; ------ nastaven° aktu†ln°ho áasu (hodina)

         push      cx
         mov       ah,2ch
         int       21h                      ; poskytnut° systÇmovÇho áasu
         shl       ch,1
         shl       ch,1
         shl       ch,1                     ; rotace hodiny na pozici
         mov       cl,0
         mov       ds:[SrcTim1],cx          ; poá†teán° áas - hodina
         mov       ds:[SrcTim2],cx          ; koncovò áas - hodina
         mov       word ptr ds:[SrcTim1M],bit11+bit12+bit13+bit14+bit15 ; maska
         mov       word ptr ds:[SrcTim2M],bit11+bit12+bit13+bit14+bit15 ; maska
         pop       cx

RozbPTm9:ret

RozbPTim ENDP

; -----------------------------------------------------------------------------
;        rozbor jednoho £daje data nebo áasu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DH=poáet rotac° £daje
;        DL=maxim†ln° hodnota £daje (maska)
;        DS:[DI+0] (2) parametr
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbDT   PROC      NEAR

         push      ax
         push      bx

; ------ sestaven° masky BX

         push      cx
         mov       cl,dh                    ; poáet rotac° £daje
         mov       bh,0
         mov       bl,dl                    ; maxim†ln° hodnota (maska)
         shl       bx,cl                    ; rotace masky
         pop       cx

; ------ inicializace hodnoty

         not       bx                       ; £daj se bude nulovat
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla AX
         jc        RozbDT5                  ; á°slo nen° zad†no

; ------ omezen° hodnoty á°sla na maximum

         cmp       ah,0                     ; je velkÇ á°slo ?
         jne       RozbDT3                  ; omezen° á°sla
         cmp       al,dl                    ; p©eteáen° á°sla ?
         jbe       RozbDT4                  ; hodnota á°sla je OK
RozbDT3: mov       al,dl                    ; omezen° á°sla
         mov       ah,0

; ------ nastaven° zadanÇho á°sla

RozbDT4: push      cx
         mov       cl,dh                    ; poáet rotac°
         shl       ax,cl                    ; rotace á°sla na pozici
         or        ds:[di],ax               ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; á°slo zad†no - povolen° masky
         pop       cx

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbDT5: call      RozbOdd                  ; vypu®tàn° oddàlovaáe mezi á°sly

         pop       bx
         pop       ax
         ret

RozbDT   ENDP

; -----------------------------------------------------------------------------
;        rozbor £daje sekund
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbSek  PROC      NEAR

         push      ax
         push      bx

; ------ inicializace hodnoty

         mov       bx,not 31                ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbSk5                  ; á°slo nen° zad†no

; ------ á°slo zad†no - jeho nastaven°

         shr       ax,1                     ; korekce á°sla / 2
         cmp       ax,31                    ; p©eteáen° á°sla ?
         jbe       RozbSk4                  ; hodnota á°sla je OK
         mov       ax,31                    ; omezen° á°sla
RozbSk4: or        ds:[di],ax               ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; povolen° masky

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbSk5: call      RozbOdd                  ; vypu®tàn° oddàlovaáñ mezi á°sly

         pop       bx
         pop       ax
         ret

RozbSek  ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° £daje roku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
;        DS:[DI+0] (2) parametr
;        DS:[DI+2] (2) maska parametru
; -----------------------------------------------------------------------------

RozbRok  PROC      NEAR

         push      ax
         push      bx

; ------ inicializace hodnoty

         mov       bx,not bit9+bit10+bit11+bit12+bit13+bit14+bit15 ; maska
         and       ds:[di],bx               ; nulov†n° hodnoty
         and       ds:[di+2],bx             ; nulov†n° masky

; ------ dek¢dov†n° á°sla

         call      RozbPNum                 ; naáten° á°sla
         jc        RozbRok5                 ; á°slo nen° zad†no

; ------ oprava hodnoty á°sla

         cmp       ax,80                    ; £daj < 80 bude asi 2000
         jae       RozbRok0
         add       ax,2000                  ; oprava na rok 20xx
RozbRok0:cmp       ax,100                   ; £daj < 100 bude asi offset od 1900
         jae       RozbRok1
         add       ax,1900                  ; asi offset od roku 1900
RozbRok1:cmp       ax,200                   ; £daj < 200 bude asi 2000
         jae       RozbRok2
         add       ax,2000
RozbRok2:cmp       ax,1000                  ; £daj < 1000 bude asi 1xxx
         jae       RozbRk22
         add       ax,1000
RozbRk22:cmp       ax,1980                  ; minim†ln° rok mus° bòt 1980
         jae       RozbRok3
         mov       ax,1980                  ; minim†ln° rok
RozbRok3:sub       ax,1980
         cmp       ax,127
         jbe       RozbRok4
         mov       ax,127                   ; omezen° na maximum

; ------ á°slo zad†no - jeho nastaven°

RozbRok4:push      cx
         mov       cl,9
         shl       ax,cl                    ; rotace á°sla na pozici
         pop       cx
         or        ds:[di],ax               ; uloëen° á°sla
         not       bx                       ; maska pro nastaven°
         or        ds:[di+2],bx             ; povolen° masky

; ------ vypu®tàn° oddàlovac°ho znaku za á°slem

RozbRok5:call      RozbOdd                  ; vypu®tàn° oddàlovaáe za á°slem

         pop       bx
         pop       ax
         ret

RozbRok  ENDP

; -----------------------------------------------------------------------------
;        rozbor zad†n° velikosti
; -----------------------------------------------------------------------------

RozbPSiz PROC      NEAR

; ------ inicializace hodnot

         mov       di,offset SrcSiz1
         xor       ax,ax
         mov       ds:[di],ax
         mov       ds:[di+2],ax             ; poá†teán° velikost
         dec       ax                       ; AX <- 0ffffh
         mov       ds:[di+4],ax
         mov       ds:[di+6],ax             ; koncov† velikost

; ------ rozbor poá†teán° velikosti

         call      RozbDNum                 ; rozbor poá†teán° velikosti
         jc        RozbPSz3                 ; poá†teán° velikost nen° zad†na
         mov       ds:[di],ax
         mov       ds:[di+2],dx             ; poá†teán° velikost
         mov       ds:[di+4],ax
         mov       ds:[di+6],dx             ; bude i koncov† velikost

; ------ oddàlovac° znamÇnko intervalu "-"

RozbPSz3:call      RozbInt                  ; test znaku intervalu
         jc        RozbPSz9                 ; nen° interval

; ------ rozbor koncovÇ velikosti

RozbPSz4:call      RozbDNum                 ; rozbor koncovÇ velikosti
         jnc       RozbPSz5                 ; koncov† velikost zad†na
         mov       ax,0ffffh                ; jinak maximum
         mov       dx,ax
RozbPSz5:mov       ds:[di+4],ax
         mov       ds:[di+6],dx             ; koncov† velikost

RozbPSz9:ret

RozbPSiz ENDP

; -----------------------------------------------------------------------------
;        vypu®tàn° oddàlovaáe mezi á°sly (CY=nen° oddàlovaá)
; -----------------------------------------------------------------------------

RozbOdd  PROC      NEAR

         call      RozbPCh                  ; naáten° dal®°ho znaku
         jc        RozbOdd9                 ; nen° dal®° znak
         cmp       al,"."
         je        RozbOdd9                 ; teáka - plat°
         cmp       al,","
         je        RozbOdd9                 ; á†rka - plat°
         cmp       al,"/"
         je        RozbOdd9                 ; lom°tko - plat°
         cmp       al,":"
         je        RozbOdd9                 ; dvojteáka - plat°
         dec       si                       ; jinak n†vrat znaku
         inc       cx                       ; n†vrat á°taáe znakñ
         stc                                ; p©°znak chyby - nen° oddàlovaá
RozbOdd9:ret

RozbOdd  ENDP

; -----------------------------------------------------------------------------
;        test zad†n° znaku intervalu "-" (CY=nen°)
; -----------------------------------------------------------------------------

RozbInt  PROC      NEAR

         call      RozbPCh                  ; naáten° dal®°ho znaku
         jc        RozbInt9                 ; nen° dal®° znak
         cmp       al,"-"                   ; je oddàlovac° znamÇnko "-" ?
         je        RozbInt9                 ; je oddàlovaá intervalu OK
         dec       si                       ; n†vrat znaku
         inc       cx
         stc                                ; p©°znak, ëe nen° znaku intervalu
RozbInt9:ret

RozbInt  ENDP

; -----------------------------------------------------------------------------
;        naáten° dal®°ho znaku z bufferu p©i rozboru (CY=nen° dal®° znak)
; -----------------------------------------------------------------------------

RozbPCh  PROC      NEAR

RozbPCh1:stc                                ; p©°znak konce textu
         jcxz      RozbPCh6                 ; nen° dal®° znak

         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al," "                   ; mezera ?
         je        RozbPCh1                 ; ignorov†n° mezery
         cmp       al,"?"                   ; n†hradn° znaky se takÇ ignoruj°
         je        RozbPCh1
         clc                                ; znak je OK

RozbPCh6:ret

RozbPCh  ENDP

; -----------------------------------------------------------------------------
;        naáten° á°sla p©i rozboru AX (CY=nen° platnÇ á°slo)
; -----------------------------------------------------------------------------

RozbPNum PROC      NEAR

         push      dx
         call      RozbDNum                 ; naáten° á°sla DX:AX
         jc        RozbPNm2                 ; nen° platnÇ á°slo
         or        dx,dx                    ; je á°slo > 64 K ?
         jz        RozbPNm2                 ; nen° vàt®°
         mov       ax,0ffffh                ; omezen° AX
RozbPNm2:pop       dx
         ret

RozbPNum ENDP

; -----------------------------------------------------------------------------
;        naáten° velkÇho á°sla p©i rozboru DX:AX (CY=nen° platnÇ á°slo)
; -----------------------------------------------------------------------------

RozbDNum PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      di

; ------ inicializace st©adaáe na 0

         xor       di,di                    ; HIGH
         xor       bx,bx                    ; LOW

; ------ naáten° prvn° á°slice

         call      RozbPNm                  ; naáten° jednÇ á°slice
         jc        RozbDNm6                 ; nen° platnÇ á°slo

; ------ vyn†soben° st©adaáe 10x

RozbDNm1:push      ax                       ; zadanÇ á°slo
         mov       ax,10
         mul       bx                       ; posun st©†danÇho á°sla LOW o ©†d
         mov       bx,ax                    ; BX<-novÇ LOW
         xchg      dx,di                    ; DI<-novÇ HIGH, DX<-starÇ HIGH
         mov       ax,10
         mul       dx                       ; posun st©†danÇho á°sla HIGH o ©†d
         add       di,ax                    ; vòslednÇ novÇ HIGH
         jc        RozbDN12                 ; p©eteáen° á°sla
         or        dx,dx                    ; je p©eteáen° ?
         jz        RozbDNm2                 ; nen° p©eteáen°
RozbDN12:mov       bx,0ffffh                ; n†hrada maxim†ln° hodnotou
         mov       di,0ffffh
RozbDNm2:pop       ax                       ; zadanÇ á°slo

; ------ p©iáten° novÇ á°slice ke st©adaái

         mov       ah,0
         add       bx,ax                    ; p©iáten° novÇ á°slice
         adc       di,0                     ; p©enos
         jnc       RozbDNm3                 ; nen° p©eteáen°
         mov       bx,0ffffh                ; p©eteáen° £daje - omezen° na max.
         mov       di,0ffffh

; ------ naáten° dal®° á°slice

RozbDNm3:call      RozbPNm                  ; naáten° dal®° á°slice
         jnc       RozbDNm1                 ; je platn† á°slice - jej° p©iáten°
         clc                                ; p©°znak operace OK

; ------ vòslednÇ naátenÇ á°slo

RozbDNm6:mov       ax,bx                    ; á°slo LOW
         mov       dx,di                    ; á°slo HIGH

; ------ n†vrat registrñ

         pop       di
         pop       bx
         ret

RozbDNum ENDP

; -----------------------------------------------------------------------------
;        naáten° á°slice p©i rozboru (CY=nen° platn† á°slice)
; -----------------------------------------------------------------------------

RozbPNm  PROC      NEAR

; ------ naáten° jednÇ á°slice

         call      RozbPCh                  ; naáten° znaku
         jc        RozbPNm9                 ; nen° dal®° znak

; ------ kontrola, zda je platn† á°slice

         cmp       al,"0"
         jb        RozbPNm8                 ; nen° á°slice
         cmp       al,"9"
         ja        RozbPNm8                 ; nen° á°slice
         sub       al,"0"
         clc                                ; p©°znak platnÇho znaku
         ret                                ; platn† á°slice

; ------ chyba - neplatn† á°slice

RozbPNm8:dec       si                       ; n†vrat neplatnÇho znaku
         inc       cx
         stc                                ; p©°znak - nen° platnò znak
RozbPNm9:ret

RozbPNm  ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                     Obsluha informaán°ho ©†dku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛

; *****************************************************************************
;                             InfoClr
;                 vymaz†n° bufferu informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InfoClr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es

; ------ vymaz†n° bufferu informaán°ho ©†dku

         push      ds
         pop       es
         mov       cx,80                    ; dÇlka ©†dku
         mov       di,offset InfoBuf        ; buffer informaán°ho ©†dku
         mov       al," "                   ; mazac° znak mezery
         mov       ah,ds:[InfoCol1]         ; bàën† barva inform. ©†dku
         cld
         rep       stosw                    ; vymaz†n° bufferu

; ------ inicializace promànnòch

         mov       ds:[InfoXCol],cl         ; 0 = p©°znak bàënÇ barvy textu
         mov       word ptr ds:[InfoStor],offset InfoBuf+2 ; ukl†dac° adresa
         mov       word ptr ds:[InfoKMax],cx ; maxim†ln° velikost kurzoru
         mov       word ptr ds:[InfoKMax+2],cx
         mov       word ptr ds:[InfoKCit],cx ; á°taá velikosti kurzoru
         mov       word ptr ds:[InfoKCit+2],cx

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       cx
         pop       ax
         ret

InfoClr  ENDP

; *****************************************************************************
;                             InfoTxt
;                dek¢dov†n° textu do informaán°ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=adresa definice textu (1.slovo - dÇlka textu + 2, text n†sleduje)
;        DS=datovò segment
; *****************************************************************************

InfoTxt  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      es

; ------ dek¢dov†n° textu

         mov       cx,ds:[si]               ; dÇlka textu + 2
         dec       cx
         dec       cx                       ; dÇlka textu
         inc       si
         inc       si                       ; zaá†tek textu
         push      ds
         pop       es                       ; ES <- DS
         call      InfoDek                  ; dek¢dov†n° textu do bufferu

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       cx
         ret

InfoTxt  ENDP

; *****************************************************************************
;                            InfoDek
;             dek¢dov†n° textu do informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa textu
;        CX=poáet znakñ
;        DS=datovò segment
; *****************************************************************************

InfoDek  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ p©°prava registrñ

         jcxz      InfoDek9                 ; nen° ë†dnò znak k dek¢dov†n°
         mov       di,ds:[InfoStor]         ; ukl†dac° adresa do bufferu
         cld
         mov       dx,word ptr ds:[InfoCol1] ; barva textu
         mov       ah,dl                    ; bàën† barva textu
         cmp       byte ptr ds:[InfoXCol],0 ; je bàën† barva ?
         je        InfoDek1                 ; je bàën† barva textu
         xchg      ah,dh                    ; zmàna barvy textu

; ------ dek¢dov†n° textu

InfoDek1:mov       al,es:[si]               ; znak k dek¢dov†n°
         inc       si                       ; zvò®en° átec° adresy
         cmp       al,0                     ; je zmàna barvy ?
         jne       InfoDek2                 ; nen° zmàna barvy - je platnò znak
         xchg      ah,dh                    ; zmàna barvy
         not       byte ptr ds:[InfoXCol]   ; zmàna p©°znaku barvy
         jmp       short InfoDek3
InfoDek2:cmp       di,offset InfoBuf + 2*80 ; je buffer jië plnò ?
         jae       InfoDek3                 ; buffer je jië plnò
         mov       ds:[di],ax               ; uloëen° znaku
         inc       di
         inc       di                       ; zvò®en° ukl†dac° adresy
InfoDek3:loop      InfoDek1                 ; dek¢dov†n° dal®°ho znaku
         mov       ds:[InfoStor],di         ; nov† ukl†dac° adresa do bufferu

; ------ n†vrat registrñ

InfoDek9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InfoDek  ENDP

; *****************************************************************************
;                             InfoKurz
;                 zobrazen° informaán°ho ©†dku s kurzorem
; -----------------------------------------------------------------------------
; VSTUP: CX=p©°rustek informaán°ho kurzoru
;        DS=datovò segment
; *****************************************************************************

InfoKurz PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es
         cld

; ------ zvò®en° á°taáe

         mov       ax,word ptr ds:[InfoKCit] ; á°taá LOW
         mov       dx,word ptr ds:[InfoKCit+2] ; á°taá HIGH
         add       ax,cx                    ; zvò®en° á°taáe LOW
         adc       dx,0                     ; p©enos do HIGH

; ------ kontrola p©eteáen° á°taáe

         mov       cx,word ptr ds:[InfoKMax] ; maximum LOW
         mov       bx,word ptr ds:[InfoKMax+2] ; maximum HIGH
         cmp       dx,bx                    ; p©eteáen° ?
         jne       InfoKur1
         cmp       ax,cx
InfoKur1:jbe       InfoKur2                 ; nen° p©eteáen°
         mov       ax,cx                    ; omezen° na maximum
         mov       dx,bx
InfoKur2:mov       word ptr ds:[InfoKCit],ax
         mov       word ptr ds:[InfoKCit+2],dx ; uloëen° novÇho kurzoru

; ------ normalizace ukazatelñ (aby byl z†klad < 64 KB)

InfoKur3:or        bx,bx                    ; je z†klad > 64 KB ?
         jz        InfoKur4                 ; nen° vàt®° neë 64 KB
         shr       dx,1
         rcr       ax,1
         shr       bx,1
         rcr       cx,1
         jmp       short InfoKur3
InfoKur4:jcxz      InfoKur9                 ; dàlitel = 0 (kurzor vypnutò)

; ------ vòpoáet dÇlky novÇho kurzoru

         mov       bx,InfoKSir              ; ®°©ka informaán°ho kurzoru
         mul       bx                       ; á†st * ®°©ka kurzoru
         div       cx                       ; vydàlen° celkovou á†st°
         mov       cx,ax                    ; relativn° ®°©ka kurzoru
         mov       bx,InfoKSir              ; ®°©ka informaán°ho kurzoru
         sub       bx,cx                    ; zbytek bez kurzoru

; ------ dek¢dov†n° kurzoru

         push      ds
         pop       es                       ; ES <- DS
         mov       di,offset InfoBuf + 2*InfoKPoz - 2; adresa k dek¢dov†n° kurzoru
         mov       ah,ds:[InfoCol1]         ; bàën† barva inform. ©†dku
         mov       al,16                    ; lev† ®ipka
         stosw
         mov       al,178                   ; znak kurzoru
         rep       stosw                    ; uloëen° á†sti s kurzorem
         mov       cx,bx                    ; dÇlka zbytku
         mov       al,176                   ; znak bez kurzoru
         rep       stosw                    ; uloëen° á†sti bez kurzoru
         mov       al,17                    ; prav† ®ipka
         stosw

; ------ n†vrat registrñ

InfoKur9:pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      InfoDisp                 ; zobrazen° informaán°ho ©†dku
         ret

InfoKurz ENDP

; *****************************************************************************
;                            InfoDisp
;                   zobrazen° informaán°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

InfoDisp PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx
         push      si
         push      es

; ------ zobrazen° informaán°ho ©†dku

         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jnz       InfoDis6                 ; je ©†dkovò reëim
         push      ds
         pop       es
         mov       cx,80                    ; dÇlka informaán°ho ©†dku
         mov       dl,0                     ; poá†teán° pozice
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
         mov       si,offset InfoBuf        ; buffer informaán°ho ©†dku
         call      DispStr                  ; zobrazen° informaán°ho ©†dku
         call      KurzOff                  ; vypnut° kurzoru

; ------ n†vrat registrñ

InfoDis6:pop       es
         pop       si
         pop       dx
         pop       cx
         ret

InfoDisp ENDP

; -----------------------------------------------------------------------------
;        zobrazen° hl†®en° "Äekejte"
; -----------------------------------------------------------------------------

DispCek  PROC      NEAR

; ------ test, zda se hl†®en° zobraz°

         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jz        DispCek9                 ; nen° ©†dkovò reëim

; ------ zobrazen° hl†®en°

         push      si
         mov       si,offset CekTxt         ; text hl†®en° "Äekejte"
         call      StdErr                   ; zobrazen° hl†®en°
         pop       si

DispCek9:ret

DispCek  ENDP

; -----------------------------------------------------------------------------
;        maz†n° hl†®en° "Äekejte"
; -----------------------------------------------------------------------------

ClrCek   PROC      NEAR

; ------ test, zda se hl†®en° vymaëe

         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jz        ClrCek9                  ; nen° ©†dkovò reëim

; ------ vymaz†n° hl†®en°

         push      si
         mov       si,offset CekTxt0        ; text k vymaz†n° hl†®en° "Äekejte"
         call      StdErr                   ; vymaz†n° hl†®en°
         pop       si

ClrCek9: ret

ClrCek   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Obsluha vyhled†v†n° souborñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; -----------------------------------------------------------------------------
;        p©iáten° souboru k á°taái souborñ
; -----------------------------------------------------------------------------

PridejF  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ zvò®en° á°taáe souborñ

         inc       word ptr ds:[CitSoub]    ; zvò®en° á°taáe souborñ

; ------ p©iáten° velikosti k celkovÇ kapacità

         mov       ax,word ptr ds:[DTASize] ; velikost LOW
         mov       dx,word ptr ds:[DTASize+2] ; velikost LOW
         add       word ptr ds:[CitCelk],ax ; á°taá celkovÇ kapacity LOW
         adc       word ptr ds:[CitCelk+2],dx ; á°taá celkovÇ kapacity HIGH

; ------ vòpoáet obsazenÇ kapacity na disku

         mov       cx,ds:[DiskBlok]         ; poáet bajtñ na alok. blok
         jcxz      PridejF5                 ; nàjak† chyba
         cmp       dx,cx                    ; je velikost OK ?
         jae       PridejF3                 ; chybn† velikost - nezaokrouhl° se
         dec       cx                       ; velikost bloku - 1
         add       ax,cx                    ; zaokrouhlen° na alok. blok
         adc       dx,0                     ; p©enos
         inc       cx                       ; velikost alok. bloku
         cmp       dx,cx                    ; je chybn† velikost ?
         jae       PridejF3                 ; chybn† velikost - nezaokrouhl° se
         div       cx                       ; vòpoáet alokaán°ch blokñ
         mul       cx                       ; velikost se zaokrouhlen°m
PridejF3:add       word ptr ds:[CitObs],ax  ; á°taá obsazenÇ kapacity LOW
         adc       word ptr ds:[CitObs+2],dx ; á°taá obsazenÇ kapacity HIGH

; ------ n†vrat registrñ

PridejF5:pop       dx
         pop       cx
         pop       ax
         ret

PridejF  ENDP

; *****************************************************************************
;                               HledFile
;                           nalezen° souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=p©eru®en° hled†n°
; *****************************************************************************

HledFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ inicializace ukazatelñ

         xor       ax,ax
         mov       word ptr ds:[CitSoub],ax ; á°taá nalezenòch souborñ
         mov       word ptr ds:[CitCelk],ax ; á°taá celkovÇ kapacity souborñ LOW
         mov       word ptr ds:[CitCelk+2],ax ; á°taá celkovÇ kapacity soub.HIGH
         mov       word ptr ds:[CitObs],ax ; á°taá obsazenÇ kapacity souborñ LOW
         mov       word ptr ds:[CitObs+2],ax ; á°taá obsaz. kapacity soub. HIGH
         mov       word ptr ds:[InsSumm],ax
         mov       word ptr ds:[InsSumm+2],ax ; souáet velikost° souborñ
         mov       ds:[InsNum],ax           ; poáet oznaáenòch souborñ
         mov       ds:[DispNum],ax          ; poáet indexñ zobrazenòch souborñ
         mov       ds:[HledNum],ax          ; poáet indexñ pro hled†n°
         mov       ds:[SeznNum],ax          ; velikost seznamu souborñ
         mov       ds:[SeznTop],ax          ; poá†teán° ©†dek
         mov       ds:[SeznAkt],ax          ; aktivn° ©†dek
         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jnz       HledFl02                 ; je ©†dkovò reëim
         call      DispSezn

; ------ stanoven° velikosti alokaán°ho bloku disku

HledFl02:mov       ah,36h
         mov       dl,ds:[FilePath]         ; oznaáen° disku
         sub       dl,"A"-1                 ; á°slo disku
         int       21h                      ; poskytnut° parametrñ disku
         cmp       ax,0ffffh
         je        HledFil1                 ; neplatnò disk
         mul       cx                       ; velikost alokaán°ho bloku
         or        dx,dx
         jnz       HledFil1
         or        ax,ax
         jnz       HledFl11
HledFil1:mov       ax,200h                  ; implicitn° velikost 1 sektor
HledFl11:mov       ds:[DiskBlok],ax         ; velikost alokaán°ho bloku

; ------ naáten° obsahu vòchoz°ho adres†©e

         call      ReadDir                  ; naáten° vòchoz°ho adres†©e
         call      SortDis                  ; t©°dàn° pro zobrazen°
         call      SortHled                 ; t©°dàn° k vyhled†v†n°
         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jz        HledFl14                 ; nen° ©†dkovò reëim
         call      ListSezn                 ; vòpis v ©†dkovÇm reëimu
         jmp       short HledFil2
HledFl14:call      DispSezn                 ; zobrazen° seznamu

; ------ test p©eru®en° programu

HledFil2:call      TestKey                  ; test kl†vesnice
         jz        HledFl22
HledFl21:call      InpChr                   ; vstup znaku z kl†vesnice
         call      Sezn                     ; obsluha seznamu
         cmp       bl,27
         stc                                ; p©°znak p©eru®en° hled†n°
         je        HledFil9                 ; je p©eru®en° hled†n°
         jmp       short HledFil2

; ------ test, zda jsou nàjakÇ dal®° adres†©e

HledFl22:mov       si,ds:[HledNum]          ; poáet indexñ pro hled†n°
         or        si,si                    ; je dal®° adres†© k hled†n° ?
         jz        HledFil9                 ; nen° dal®° adres†© - konec
         test      byte ptr ds:[Param2],bit0 ; adres†©e povoleny ?
         jz        HledFil9                 ; nejsou podadres†©e
         dec       si                       ; sn°ëen° ukazatele
         mov       ds:[HledNum],si          ; novò poáet indexñ pro hled†n°

; ------ adresa ©etàzce v bufferu

         shl       si,1                     ; offset v bufferu indexñ
         mov       si,ds:[si+HledIndx]      ; adresa ©etàzce v bufferu
         mov       es,ds:[SeznSegm]         ; adresa bufferu

; ------ inicializace, je-li specifikace celÇ cesty

         test      byte ptr es:[si],bit6    ; je to cesta ?
         jz        HledFil4                 ; nen° to cesta
         mov       di,offset FilePath       ; buffer k naáten° cesty
HledFil3:inc       si                       ; átec° adresa
         mov       al,es:[si]               ; znak cesty k p©enesen°
         mov       ds:[di],al               ; uloëen° znaku
         inc       di                       ; ukl†dac° adresa
         cmp       al,0                     ; je konec textu ?
         jne       HledFil3                 ; p©enesen° textu ASCIIZ
         sub       di,offset FilePath+1     ; offset konce v bufferu
         mov       ds:[FilePthN],di         ; dÇlka textu cesty
         jmp       short HledFil2           ; dal®° adres†©

; ------ p©id†n° novÇho adres†©e k aktivn° cestà

HledFil4:add       si,9                     ; zaá†tek jmÇna adres†©e
         call      AddGFil                  ; p©id†n° jmÇna adres†©e
         jc        HledFil2                 ; chyba p©eteáen°

; ------ naáten° obsahu novÇho adres†©e

         call      ReadDir                  ; naáten° vòchoz°ho adres†©e
         call      SortDis                  ; t©°dàn° pro zobrazen°
         call      SortHled                 ; t©°dàn° k vyhled†v†n°
         test      byte ptr ds:[Param],bit7 ; je ©†dkovò reëim ?
         jz        HledFil5                 ; nen° ©†dkovò reëim
         call      ListSezn                 ; vòpis v ©†dkovÇm reëimu
         jmp       short HledFil6
HledFil5:call      DispSezn                 ; zobrazen° seznamu

; ------ zru®en° naá°tanÇho adres†©e

HledFil6:call      SubGFil                  ; zru®en° naá°tanÇho adres†©e
         jmp       short HledFil2           ; dal®° podadres†©

; ------ n†vrat registrñ

HledFil9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

HledFile ENDP

; *****************************************************************************
;                                 SortDis
;                   set©°dàn° adres†©e - zobrazenÇ soubory
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SortDis  PROC      NEAR

; ------ test, zda je v adres†©i nàco k set©°dàn°

         push      cx
         mov       cx,ds:[DispNum]          ; poáet indexñ v adres†©i
         sub       cx,ds:[DispNumO]         ; poáet novòch indexñ v adres†©i
         sub       cx,2                     ; poáet p†rñ k set©°dàn°
         jbe       SortDis9                 ; nen° nic k set©°dàn°

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[SeznSegm]         ; adresa seznamu
         mov       bx,ds:[DispNumO]         ; á°slo prvn°ho indexu
         shl       bx,1                     ; offset v tabulce indexñ
         add       bx,offset DispIndx+2     ; adresa prvn°ho indexu
         mov       dx,bx                    ; £schova adresy prvn°ho indexu

; ------ adresy souborñ k porovn†n°

SortDis3:mov       si,ds:[bx]               ; adresa prvn°ho souboru
         mov       di,ds:[bx+2]             ; adresa druhÇho souboru

; ------ porovn†n° atributñ souborñ

         mov       al,es:[si]               ; atributy prvn°ho souboru
         mov       ah,es:[di]               ; atributy druhÇho souboru
         and       ax,DIR*HI + DIR          ; atributy adres†©ñ
         cmp       al,ah                    ; souhlas° ?
         ja        SortDis7                 ; adres†© p©ed souborem = OK
         jb        SortDis5                 ; soubor p©ed adres†©em = z†màna
         add       si,9                     ; jmÇno prvn°ho souboru
         add       di,9                     ; jmÇno druhÇho souboru

; ------ naáten° znakñ jmen

SortDis4:mov       al,es:[si]               ; znak prvn°ho jmÇna
         mov       ah,es:[di]               ; znak druhÇho jmÇna

; ------ porovn†n°, zda je shoda znakñ

         cmp       al,ah                    ; jsou znaky shodnÇ ?
         je        SortDis6                 ; znaky jsou shodnÇ

; ------ test, zda je prvn° jmÇno krat®° neë druhÇ

;         cmp       al,0                     ; prvn° jmÇno je krat®° ?
;         je        SortDis7                 ; je krat®° - to je OK
         cmp       al,"."                   ; je krat®° ?
         je        SortDis7                 ; je krat®° - to je OK

; ------ test, zda je prvn° jmÇno men®° neë druhÇ

         cmp       al,ah                    ; je prvn° jmÇno men®° ?
         jb        SortDis7                 ; je men®° - to je OK

; ------ prvn° jmÇno je vàt®° neë druhÇ - z†màna indexñ

SortDis5:mov       ax,ds:[bx]
         xchg      ax,ds:[bx+2]             ; z†màna indexñ
         mov       ds:[bx],ax

; ------ posun ukazatele smàrem dolñ

         cmp       bx,dx                    ; je jië prvn° poloëka ?
         jbe       SortDis7                 ; je jië prvn° poloëka - dal®° soub.
         dec       bx
         dec       bx                       ; posun k p©ede®lÇ dvojici
         inc       cx                       ; n†vrat á°taáe souborñ
         jmp       short SortDis3           ; porovn†n° p©ede®lÇ poloëky

; ------ znaky jsou shodnÇ - zvò®en° ukazatele a test konce jmÇna

SortDis6:inc       si
         inc       di
         cmp       al,0                     ; konec jmÇna ?
         jne       SortDis4                 ; nen° konec - dal®° znak

; ------ soubory jsou set©°dànÇ OK - p©°prava k dal®°mu souboru

SortDis7:inc       bx
         inc       bx                       ; zvò®en° adresy v tabulce indexñ
         loop      SortDis3                 ; porovn†n° dal®°ho souboru

; ------ n†vrat registrñ

SortDis8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
SortDis9:pop       cx
         ret

SortDis  ENDP

; *****************************************************************************
;                                 SortHled
;                   set©°dàn° adres†©ñ k prohled†v†n°
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SortHled PROC      NEAR

; ------ test, zda je v adres†©i nàco k set©°dàn°

         push      cx
         mov       cx,ds:[HledNum]          ; poáet indexñ v adres†©i
         sub       cx,ds:[HledNumO]         ; poáet novòch indexñ v adres†©i
         shr       cx,1                     ; poáet dvojslov
         sub       cx,1                     ; poáet p†rñ k set©°dàn°
         jbe       SortHld9                 ; nen° nic k set©°dàn°

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       es,ds:[SeznSegm]         ; adresa seznamu
         mov       bx,ds:[HledNumO]         ; á°slo prvn°ho indexu
         shl       bx,1                     ; offset v tabulce indexñ
         add       bx,offset HledIndx       ; adresa prvn°ho indexu
         mov       dx,bx                    ; £schova adresy prvn°ho indexu

; ------ adresy souborñ k porovn†n°

SortHld3:mov       si,ds:[bx]               ; adresa prvn°ho souboru
         add       si,9                     ; jmÇno prvn°ho souboru
         mov       di,ds:[bx+4]             ; adresa druhÇho souboru
         add       di,9                     ; jmÇno druhÇho souboru

; ------ naáten° znakñ jmen

SortHld4:mov       al,es:[si]               ; znak prvn°ho jmÇna
         mov       ah,es:[di]               ; znak druhÇho jmÇna

; ------ porovn†n°, zda je shoda znakñ

         cmp       al,ah                    ; jsou znaky shodnÇ ?
         je        SortHld6                 ; znaky jsou shodnÇ

; ------ test, zda je druhÇ jmÇno krat®° neë druhÇ

         cmp       ah,"."                   ; je krat®° ?
         je        SortHld7                 ; je krat®° - to je OK

; ------ test, zda je druhÇ jmÇno men®° neë druhÇ

         cmp       ah,al                    ; je druhÇ jmÇno men®° ?
         jb        SortHld7                 ; je men®° - to je OK

; ------ druhÇ jmÇno je vàt®° neë druhÇ - z†màna indexñ

SortHld5:mov       ax,ds:[bx]
         xchg      ax,ds:[bx+4]             ; z†màna indexñ
         mov       ds:[bx],ax

; ------ posun ukazatele smàrem dolñ

         cmp       bx,dx                    ; je jië prvn° poloëka ?
         jbe       SortHld7                 ; je jië prvn° poloëka - dal®° soub.
         sub       bx,4                     ; posun k p©ede®lÇ dvojici
         inc       cx                       ; n†vrat á°taáe souborñ
         jmp       short SortHld3           ; porovn†n° p©ede®lÇ poloëky

; ------ znaky jsou shodnÇ - zvò®en° ukazatele a test konce jmÇna

SortHld6:inc       si
         inc       di
         cmp       al,0                     ; konec jmÇna ?
         jne       SortHld4                 ; nen° konec - dal®° znak

; ------ soubory jsou set©°dànÇ OK - p©°prava k dal®°mu souboru

SortHld7:add       bx,4                     ; zvò®en° adresy v tabulce indexñ
         loop      SortHld3                 ; porovn†n° dal®°ho souboru

; ------ n†vrat registrñ

SortHld8:pop       es
         pop       di
         pop       si
         pop       dx
         pop       bx
         pop       ax
SortHld9:pop       cx
         ret

SortHled ENDP

; *****************************************************************************
;                                ReadDir
;                    naáten° obsahu adres†©e FILEPATH
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ReadDir  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ zobrazen° informaán°ho textu

         push      ds
         pop       es
         call      InfoClr                  ; vymaz†n° informaán°ho bufferu
         mov       si,offset HledTxt1       ; informaán° text
         call      InfoTxt                  ; dek¢dov†n° textu
         mov       si,offset FilePath       ; aktivn° cesta
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         call      InfoDek                  ; dek¢dov†n° jmÇna adres†©e
         call      InfoDisp                 ; zobrazen° informaán°ho ©†dku

; ------ p©°prava ukazatelñ

         mov       ax,ds:[DispNum]
         mov       ds:[DispNumO],ax
         mov       ax,ds:[HledNum]
         mov       ds:[HledNumO],ax
         mov       ax,ds:[SeznNum]
         mov       ds:[SeznNumO],ax

; ------ nastaven° pracovn° adresy DTA

         mov       si,offset DTA            ; buffer DTA
         call      SetDTA                   ; nastaven° pracovn° adresy DTA

; ------ p©°prava specifikace souborñ

         mov       si,offset All            ; specifikace "*.*"
         call      AddGFil                  ; p©id†n° specifikace souboru
         jnc       ReadDir1                 ; OK
         jmp       ReadDir9                 ; nàjak† chyba

; ------ nalezen° prvn°ho souboru

ReadDir1:mov       si,offset FilePath       ; specifikace souboru
         mov       cx,RO + HID + SYS + ARC + DIR ; atributy pro hled†n°
         call      SrcFirst                 ; nalezen° prvn° poloëky adres†©e

; ------ odstranàn° textu "*.*" z textu cesty

         pushf
         call      SubGFil                  ; odstranàn° specifikace "*.*"
         popf
         jmp       short ReadDir3           ; zhodnocen° vòsledku operace

; ------ ovl†d†n° seznamu

ReadDir2:call      TestKey
         jz        ReadDr23                 ; nen° kl†vesa
         or        ax,ax
         jz        ReadDr21
         cmp       al,27
         jne       ReadDr22
ReadDr21:jmp       ReadDir9
ReadDr22:call      InpChr                   ; vstup znaku z kl†vesnice
         call      Sezn                     ; obsluha seznamu
         jmp       short ReadDir2

; ------ nalezen° dal®°ho souboru

ReadDr23:call      SrcNext                  ; nalezen° dal®°ho souboru

; ------ zhodnocen° vòsledku operace hled†n°

ReadDir3:jc        ReadD300                 ; byla nàjak† chyba
         je        ReadDr30                 ; soubor nalezen OK
ReadD300:jmp       ReadDir7

; ------ adres†©e ".." a "." neplat° - p©eskoá° se

ReadDr30:cmp       word ptr ds:[DTAName],".." ; je to adres†© ".." ?
         je        ReadDir2                 ; neplatnò adres†© - dal®°
         cmp       word ptr ds:[DTAName],"." ; je to adres†© "." ?
         je        ReadDir2                 ; neplatnò adres†© - dal®°
         and       byte ptr ds:[DTAAtrib],not bit7+bit6 ; bit6 bude vëdy = 0

; ------ p©evod jmÇna souboru na tvar FCB

         call      GetBFCB                  ; p©evod jmÇna souboru na FCB

; ------ kontrola jmÇna souboru, zda odpov°d† poëadavkñm

;         mov       si,offset FileFCB        ; jmÇno souboru ve tvaru FCB
;         mov       di,offset FileMask       ; maska jmÇna souboru
;         mov       cx,ds:[FileMskN]         ; dÇlka masky jmÇna souboru
         call      TestFile                 ; test jmÇna souboru podle masky
         jc        ReadDr31                 ; jmÇno souboru neodpov°d†

; ------ kontrola ostatn°ch parametrñ souboru

         call      GetBTest                 ; kontrola ostatn°ch parametrñ
         jc        ReadDr31                 ; parametry neodpov°daj°
         call      TestText                 ; test, zda obsahuje hledanò text
         jnc       ReadDr32                 ; poloëka plnà vyhovuje OK

; ------ poloëka neodpov°d† - test, zda je alespo§ adres†©

ReadDr31:test      byte ptr ds:[DTAAtrib],DIR ; je to adres†© ?
         jz        ReadDir2                 ; nen° adres†© - neuloë° se
         stc                                ; p©°znak, ëe poloëka nevyhovuje

; ------ zaji®tàn° uloëen° aktivn° cesty

ReadDr32:lahf                               ; £schova p©°znaku CF
         mov       si,ds:[SeznNum]
         cmp       si,ds:[SeznNumO]         ; je cesta jië uloëena ?
         jne       ReadDr33                 ; cesta je jië uloëena
         call      UlozPath                 ; uloëen° cesty do seznamu
         jc        ReadDir2                 ; chyba p©eteáen°

; ------ uloëen° specifikace souboru do seznamu

ReadDr33:mov       bx,ds:[SeznNum]          ; £schova adresy souboru
         call      UlozFile                 ; uloëen° souboru do seznamu
         jc        ReadDir2                 ; chyba p©eteáen° bufferu seznamu

; ------ test, zda je poloëka platn†

         test      ah,bit0                  ; byl p©°znak CY ?
         jnz       ReadDr45                 ; byl p©°znak CY - poloëka neplatn†

; ------ test, zda byl jië uloëen index na cestu

         mov       si,ds:[DispNum]          ; poáet indexñ
         cmp       si,ds:[DispNumO]         ; byl jië index na cestu ?
         jne       ReadDr42                 ; byl jië index na cestu

; ------ uloëen° indexu na cestu

         cmp       si,INDXSIZE              ; je buffer jië plnò ?
         jae       ReadDr45                 ; buffer je jië plnò
         mov       ax,ds:[SeznNumO]         ; adresa cesty
         shl       si,1                     ; offset v bufferu
         mov       ds:[DispIndx+si],ax      ; uloëen° indexu na cestu
         inc       word ptr ds:[DispNum]    ; zvò®en° á°taáe indexñ

; ------ uloëen° indexu na soubor

ReadDr42:mov       si,ds:[DispNum]          ; poáet indexñ
         cmp       si,INDXSIZE              ; je buffer jië plnò ?
         jae       ReadDr45                 ; buffer je jië plnò
         shl       si,1                     ; offset v bufferu
         mov       ds:[DispIndx+si],bx      ; uloëen° indexu na soubor
         inc       word ptr ds:[DispNum]    ; zvò®en° á°taáe indexñ
         call      PridejF                  ; p©id†n° souboru ke st©adaái

; ------ test, zda je poloëka adres†©

ReadDr45:test      byte ptr ds:[DTAAtrib],DIR ; je to adres†© ?
         jz        ReadDr57                 ; nen° to adres†©

; ------ uloëen° indexu na adres†©

ReadDir5:mov       si,ds:[HledNum]          ; poáet indexñ pro hled†n°
         cmp       si,INDXSIZE-1            ; je buffer jië plnò ?
         jae       ReadDr57                 ; buffer je jië plnò
         test      byte ptr ds:[Param2],bit0 ; adres†©e povoleny ?
         jz        ReadDr57                 ; nejsou podadres†©e
         shl       si,1                     ; offset v bufferu
         mov       ds:[HledIndx+si],bx      ; uloëen° indexu na adres†©
         mov       ax,ds:[SeznNumO]         ; adresa cesty
         mov       ds:[HledIndx+si+2],ax    ; uloëen° indexu na cestu
         add       word ptr ds:[HledNum],2  ; zvò®en° á°taáe indexñ

ReadDr57:jmp       ReadDir2                 ; hled†n° dal®° poloëky

; ------ oprava kurzoru, pokud sleduje hled†n°

ReadDir7:cmp       word ptr ds:[DispNum],0  ; je nàco ?
         je        ReadDir9                 ; nen° nic
         mov       ax,ds:[SeznAkt]          ; aktivn° poloëka
         mov       bx,ds:[DispNumO]         ; starò poáet poloëek
         or        bx,bx                    ; bylo nàco ?
         jz        ReadDr72                 ; nebylo nic
         dec       bx                       ; á°slo posledn° poloëky
         cmp       ax,bx                    ; byl na posledn° poloëce ?
         jne       ReadDir9                 ; nebyl na posledn° poloëce
ReadDr72:mov       ax,ds:[DispNum]          ; novò poáet poloëek
         dec       ax                       ; á°slo posledn° poloëky
         mov       ds:[SeznAkt],ax          ; nov† aktivn° poloëka
         call      NormSezn                 ; normalizace seznamu

; ------ n†vrat registrñ

ReadDir9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadDir  ENDP

; -----------------------------------------------------------------------------
;        uloëen° cesty do seznamu
; -----------------------------------------------------------------------------

UlozPath PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       di,ds:[SeznNum]          ; adresa konce seznamu
         mov       cx,ds:[FilePthN]         ; dÇlka textu adres†©e
         inc       cx                       ; + 1 bajt na identifik†tor 0FFh
         inc       cx                       ; + 1 bajt na koncovou 0
         mov       es,ds:[SeznSegm]         ; adresa seznamu

; ------ kontrola p©eteáen° bufferu

         mov       si,di                    ; zaá†tek k uloëen° cesty
         add       si,cx                    ; kontrola p©eteáen° konce
         jc        UlozPth9                 ; p©eteáen° bufferu
         cmp       ds:[SeznSize],si
         jb        UlozPth9

; ------ p©enos textu cesty do bufferu seznamu

         mov       byte ptr es:[di],bit6   ; identifik†tor cesty
         inc       di                       ; zvò®en° ukazatele v bufferu
         mov       si,offset FilePath       ; text cesty
         dec       cx                       ; n†vrat dÇlky cesty
         shr       cx,1                     ; dÇlka ve slovech
         rep       movsw                    ; p©enos textu po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©enos lichÇho bajtu
         mov       ds:[SeznNum],di          ; novò konec dat v bufferu
                                            ; zde je p©°znak NC

; ------ n†vrat registrñ

UlozPth9:pop       es
         pop       di
         pop       si
         pop       cx
         ret

UlozPath ENDP


; -----------------------------------------------------------------------------
;        uloëen° nalezenÇho souboru do seznamu
; -----------------------------------------------------------------------------

UlozFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

; ------ stanoven° dÇlky jmÇna souboru

         push      ds
         pop       es                       ; ES <- datovò segment
         mov       di,offset DTAName        ; jmÇno souboru
         mov       cx,0ffffh-10+2           ; max. dÇlka - korekce
         mov       al,0                     ; hledanò bajt
         cld
         repne     scasb                    ; nalezen° konce textu
         neg       cx                       ; dÇlka jmÇna + 10

; ------ p©°prava registrñ

         mov       di,ds:[SeznNum]          ; adresa konce seznamu
         mov       es,ds:[SeznSegm]         ; adresa seznamu

; ------ kontrola p©eteáen° bufferu

         mov       si,di                    ; zaá†tek k uloëen° cesty
         add       si,cx                    ; kontrola p©eteáen° konce
         jc        UlozFil9                 ; p©eteáen° bufferu
         cmp       ds:[SeznSize],si
         jb        UlozFil9

; ------ p©enos souboru do bufferu seznamu

         mov       si,offset DTAAtrib       ; zaá†tek parametrñ
         shr       cx,1                     ; dÇlka ve slovech
         rep       movsw                    ; p©enos textu po slovech
         adc       cx,cx                    ; lichò bajt
         rep       movsb                    ; p©enos lichÇho bajtu
         mov       ds:[SeznNum],di          ; novò konec dat v bufferu
                                            ; zde je p©°znak NC

; ------ n†vrat registrñ

UlozFil9:pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

UlozFile ENDP

; -----------------------------------------------------------------------------
;        p©evod jmÇna souboru na tvar FCB
; -----------------------------------------------------------------------------
; VSTUP: DS,ES=datovò segment
; -----------------------------------------------------------------------------

GetBFCB  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      si
         push      di
         push      cx

; ------ inicializaán° vymaz†n° poloëky

         mov       di,offset FileFCB
         push      di
         cld
         mov       cx,11
         mov       al," "
         rep       stosb
         pop       di

; ------ dek¢dov†n° jmÇna poloëky

         mov       si,offset DTAName        ; jmÇno souboru
         mov       cl,8
GetBFCB2:lodsb
         cmp       al,0
         je        GetBFCB4                 ; konec jmÇna
         cmp       al,"."
         jne       GetBFCB3
         mov       di,offset FileFCB+8
         mov       cl,3
         jmp       short GetBFCB2
GetBFCB3:jcxz      GetBFCB2
         stosb
         dec       cx
         jmp       short GetBFCB2

; ------ n†vrat registrñ

GetBFCB4:pop       cx
         pop       di
         pop       si
         pop       ax
         ret

GetBFCB  ENDP

; -----------------------------------------------------------------------------
;        kontrola ostatn°ch parametrñ souboru (CY=neodpov°d†)
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

GetBTest PROC      NEAR

         push      ax

; ------ kontrola atributñ souboru

         mov       al,ds:[DTAAtrib]         ; atributy souboru
         and       al,ds:[SrcAtrM]          ; maskov†n° atributñ
         cmp       al,ds:[SrcAtr]           ; odpov°daj° atributy ?
         jne       GetBTst8                 ; atributy neodpov°daj°

; ------ kontrola minim†ln°ho áasu souboru

         mov       ax,ds:[DTATime]          ; áas souboru
         and       ax,ds:[SrcTim1M]         ; maskov†n° áasu
         cmp       ax,ds:[SrcTim1]          ; kontrola áasu
         jb        GetBTst8                 ; áas neodpov°d†

; ------ kontrola maxim†ln°ho áasu souboru

         mov       ax,ds:[DTATime]          ; áas souboru
         and       ax,ds:[SrcTim2M]         ; maskov†n° áasu
         cmp       ax,ds:[SrcTim2]          ; kontrola áasu
         ja        GetBTst8                 ; áas neodpov°d†

; ------ kontrola minim†ln°ho data souboru

         mov       ax,ds:[DTADate]          ; datum souboru
         and       ax,ds:[SrcDat1M]         ; maskov†n° data
         cmp       ax,ds:[SrcDat1]          ; kontrola data
         jb        GetBTst8                 ; datum neodpov°d†

; ------ kontrola maxim†ln°ho data souboru

         mov       ax,ds:[DTADate]          ; datum souboru
         and       ax,ds:[SrcDat2M]         ; maskov†n° data
         cmp       ax,ds:[SrcDat2]          ; kontrola data
         ja        GetBTst8                 ; datum neodpov°d†

; ------ kontrola maxim†ln° velikosti

         mov       ax,word ptr ds:[DTASize+2] ; velikost souboru HIGH
         cmp       ax,word ptr ds:[SrcSiz2+2] ; kontrola maxim†ln° velikosti HIGH
         jne       GetBTst2                 ; li®° se ve vy®®°m slovu
         mov       ax,word ptr ds:[DTASize] ; velikost souboru LOW
         cmp       ax,word ptr ds:[SrcSiz2] ; kontrola maxim†ln° velikosti LOW
GetBTst2:ja        GetBTst8                 ; velikost neodpov°d†

; ------ kontrola minim†ln° velikosti

         mov       ax,word ptr ds:[DTASize+2] ; velikost souboru HIGH
         cmp       ax,word ptr ds:[SrcSiz1+2] ; kontrola minim. velikosti HIGH
         jne       GetBTst3                 ; je rozd°l ve vy®®°m slovu
         mov       ax,word ptr ds:[DTASize] ; velikost souboru LOW
         cmp       ax,word ptr ds:[SrcSiz1] ; kontrola minim†ln° velikosti LOW
GetBTst3:jae       GetBTst9                 ; velikost je OK

GetBTst8:stc
GetBTst9:pop       ax
         ret

GetBTest ENDP

; *****************************************************************************
;                            TestText
;               test, zda soubor obsahuje hledanò text
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSUTP:CY=neobsahuje hledanò text
; *****************************************************************************

TestText PROC      NEAR

; ------ test, zda se text kontroluje

         test      byte ptr ds:[Param],bit2 ; hled† se text ?
         jz        TestTxt1                 ; text se nehled†
         cmp       word ptr ds:[SrcTextN],0 ; je nàjakò text ?
         jz        TestTxt1                 ; nen° text
         test      byte ptr ds:[DTAAtrib],DIR ; je to adres†© ?
         jz        TestTxt2                 ; nen° to adres†© - OK
         stc                                ; adres†© nevyhovuje
TestTxt1:ret

; ------ £schova registrñ

TestTxt2:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©id†n° jmÇna souboru k cestà

         push      ds
         pop       es                       ; ES <- DS
         mov       si,offset DTAName        ; jmÇno nalezenÇho souboru
         call      AddGFil                  ; p©id†n° jmÇna souboru
         jc        TestTx99                 ; nàjak† chyba

; ------ zobrazen° informaán°ho textu

         call      InfoClr                  ; vymaz†n° informaán°ho bufferu
         mov       si,offset HledTxt1       ; informaán° text
         call      InfoTxt                  ; dek¢dov†n° textu
         mov       si,offset FilePath       ; aktivn° cesta
         mov       cx,ds:[FilePthN]         ; dÇlka textu cesty
         call      InfoDek                  ; dek¢dov†n° jmÇna adres†©e
         call      InfoDisp                 ; zobrazen° informaán°ho ©†dku

; ------ otev©en° souboru pro áten°

         mov       dx,offset FilePath       ; jmÇno souboru
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru
         mov       bx,ax                    ; identifik†tor souboru

; ------ odstranàn° jmÇna souboru z cesty

         pushf
         call      SubGFil                  ; odstranàn° jmÇna souboru
         popf
TestTx99:jc        TestTxt9                 ; chyba otev©en° souboru

; ------ naáten° prvn°ho bloku dat do bufferu

         mov       bp,ds:[SrcTextN]         ; velikost dat k hled†n°
         mov       cx,SRCBMAX               ; velikost bufferu hled†n°
         mov       dx,offset SrcBuff        ; buffer k naáten° souboru
TestTxt3:mov       ah,3fh
         int       21h                      ; naáten° bloku ze souboru
         jc        TestTxt8                 ; chyba áten° - konec souboru
         mov       cx,ax                    ; velikost naátenòch dat
         stc                                ; p©°padnò p©°znak nenalezen° textu
         jcxz      TestTxt8                 ; je konec souboru - nic nenalezeno

; ------ konverze dat na velk† p°smena

         mov       si,dx                    ; zaá†tek naátenòch dat
         mov       di,dx
         cld
TestTxt4:lodsb
         cmp       al,"a"
         jb        TestTxt5
         cmp       al,"z"
         ja        TestTxt5
         sub       al,32                    ; konverze na velkÇ p°smeno
TestTxt5:stosb
         loop      TestTxt4

; ------ p©°prava pro prohled†n° jednoho bloku dat

         mov       cx,di                    ; konec dat v bufferu
         mov       di,offset SrcBuff        ; zaá†tek bufferu
         sub       cx,di                    ; poáet bajtñ v bufferu
         sub       cx,bp                    ; dÇlka zbytku dat
         jc        TestTxt8                 ; konec souboru - text nenalezen
         inc       cx                       ; poáet ©etàzcñ k porovn†n°

; ------ nalezen° prvn°ho znaku

         mov       al,ds:[SrcText]          ; prvn° znak textu
TestTxt6:repne     scasb                    ; nalezen° prvn°ho znaku
         jne       TestTxt7                 ; nenalezen - dal®° blok dat

; ------ porovn†n° ©etàzce

         mov       si,offset SrcText+1      ; hled†nò text
         push      di
         push      cx
         mov       cx,bp                    ; dÇlka ©etàzce
         dec       cx                       ; dÇlka - 1 (p©°padnò p©°znak ZY)
         repe      cmpsb                    ; porovn†n° ©etàzcñ
         pop       cx
         pop       di
         jne       TestTxt6                 ; nenalezen - dal®° blok dat
         jmp       short TestTxt8           ; ©etàzec nalezen OK

; ------ p©esun dat z konce bufferu na zaá†tek

TestTxt7:mov       si,di                    ; n†sleduj°c° data
         dec       si
         mov       cx,bp                    ; dÇlka ©etàzce
         mov       di,offset SrcBuff        ; zaá†tek bufferu
         rep       movsb                    ; p©esun dat

; ------ naáten° dal®°ho bloku dat

         mov       dx,di                    ; adresa k naáten° dat
         mov       cx,SRCBMAX               ; velikost bufferu
         sub       cx,bp                    ; velikost bez dÇlky ©etàzce
         jmp       short TestTxt3

; ------ uzav©en° souboru

TestTxt8:pushf
         mov       ah,3eh
         int       21h
         popf

; ------ n†vrat registrñ

TestTxt9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TestText ENDP

; *****************************************************************************
;                              TestFile
;              test nalezenÇho souboru, zda odpov°d† masce
; -----------------------------------------------------------------------------
; VùSTUP:NC=poloëka odpov°d†, CY=neodpov°d†
; *****************************************************************************

TestFile PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      di
         push      si

; ------ p©°prava registrñ

         mov       di,offset FileMask       ; maska jmÇna souboru
         mov       cx,ds:[FileMskN]         ; dÇlka masky jmÇna souboru

; ------ test, zda maska obsahuje teáku

TestFil1:jcxz      TestFil9
         mov       si,di
         mov       bx,cx
         cld
TestFil2:lodsb
         cmp       al,"."
         je        TestFil4                 ; obsahuje teáku
         cmp       al," "
         je        TestFil3                 ; neobsahuje teáku
         dec       bx
         jnz       TestFil2                 ; dal®° znak

; ------ kontrola jmÇna bez teáky

TestFil3:mov       bx,11                    ; dÇlka jmÇna i s p©°ponou
         mov       si,offset FileFCB
         call      TestMs                   ; kopntrola jmÇna
         jmp       short TestFl77

; ------ kontrola jmÇna poloëky

TestFil4:mov       bx,8                     ; dÇlka jmÇna
         mov       si,offset FileFCB        ; jmÇno souboru ve tvaru FCB
         call      TestMs                   ; kontrola jmÇna
         jc        TestFil8                 ; jmÇno se neshoduje

; ------ nastaven° na p©°ponu poloëky

TestFil5:jcxz      TestFil7                 ; konec jmÇna
         mov       al,ds:[di]               ; p©ipravenò znak
         cmp       al," "
         je        TestFil6                 ; konec jmÇna poloëky
         cmp       al,"."                   ; oddàlovac° teáka ?
         je        TestFil6                 ; teáka - je p©°pona
         inc       di                       ; dal®° znak
         dec       cx                       ; sn°ëen° á°taáe znakñ
         jmp       short TestFil5           ; dal®° znak

; ------ kontrola p©°pony poloëky

TestFil6:inc       di                       ; p©eskoáen° znaku "."
         dec       cx                       ; sn°ëen° á°taáe znakñ
TestFil7:mov       bl,3                     ; dÇlka p©°pony
         mov       si,offset FileFCB+8      ; jmÇno souboru ve tvaru FCB
         call      TestMs                   ; test p©°pony jmÇna
TestFl77:jnc       TestFilA                 ; poloëka vyhovuje OK

; ------ poloëka nevyhovuje - dal®° maska

TestFil8:jcxz      TestFil9                 ; nen° dal®° maska - nenalezena
         mov       al,ds:[di]               ; p©ipravenò znak
         inc       di
         dec       cx
         cmp       al," "
         jne       TestFil8                 ; nalezen° znaku mezery
         jmp       short TestFil1           ; kontrola dal®° masky

TestFil9:stc                                ; p©°znak CY=nevyhovuje

TestFilA:pop       si
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

TestFile ENDP

; *****************************************************************************
;        test jmÇna nebo p©°pony souboru na jednu masku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=jmÇno nebo p©°pona (ve tvaru FCB)
;        BX=poáet zbylòch znakñ FCB ke kontrole
;        DS:DI=ukazatel masky
;        CX=poáet zbylòch znakñ masky
; VùSTUP:NC=poloëka vyhovuje, CY=nevyhovuje
;        pokud poloëka vyhovuje (je NC), zmàn° se SI, BX, DI, CX podle operace
;        jinak zñstanou (p©i chybà CY) registry SI, BX, DI, CX zachov†ny
; -----------------------------------------------------------------------------
; neuchov†v† registry: AX
; *****************************************************************************

TestMs   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      di

; ------ konec zadanÇ á†sti jmÇna - zbytek mus° bòt mezery

TestMs1: mov       al," "                   ; porovn†vanò znak
         jcxz      TestMs4                  ; konec - zbytek mus° bòt mezery
         mov       ah,ds:[di]               ; p©ipravenò znak masky
         cmp       ah," "                   ; mezera - konec poloëky ?
         je        TestMs4                  ; konec - zbytek mus° bòt mezery
         cmp       ah,"."                   ; teáka - konec jmÇna nebo p©°pony ?
         je        TestMs4                  ; konec - zbytek mus° bòt mezery

; ------ n†hradn° znak "*" - volnò poáet znakñ

         inc       di                       ; zvò®en° ukazatele textu
         dec       cx                       ; sn°ëen° á°taáe zbylòch znakñ

         cmp       ah,"*"                   ; n†hradn° znaky - v®e vyhovuje
         jne       TestMs3

TestMs2: call      TestMs                   ; porovn†n° zbytku masky
         jnc       TestMs6                  ; zbytek masky vyhovuje
         inc       si                       ; ukazatel v FCB
         dec       bx                       ; á°taá zbylòch pozic FCB
         jnz       TestMs2                  ; dal®° test
         jmp       short TestMs6            ; vyhovuje, zbytek mus° bòt mezery

; ------ porovn†n° znaku

TestMs3: mov       al,ah                    ; znak k porovn†n°
         cmp       al,"?"                   ; n†hradn° znak
         je        TestMs5                  ; n†hradn° znak - vyhovuje
TestMs4: cmp       al,ds:[si]               ; souhlas° jmÇno ?
         jne       TestMs9                  ; poloëka nesouhlas°

; ------ znak vyhovuje - dal®° znak

TestMs5: inc       si                       ; zvò®en° ukazatele v poloëce
         dec       bx                       ; á°taá znakñ k testov†n°
         jnz       TestMs1                  ; dal®° znak

; ------ test, zda je konec textu

TestMs6: jcxz      TestMs7                  ; konec textu OK
         cmp       byte ptr ds:[di]," "
         je        TestMs7
         cmp       byte ptr ds:[di],"."
         je        TestMs7
         cmp       byte ptr ds:[di],"*"
         jne       TestMs9
         inc       di
         loop      TestMs6

; ------ poloëka vyhovuje - registry se nevracej°

TestMs7: add       sp,4*2                   ; registry se nevracej°
         clc                                ; p©°znak, ëe vyhovuje
         ret

; ------ poloëka nevyhovuje

TestMs9: stc                                ; p©°znak, ëe nevyhovuje
         pop       di
         pop       si
         pop       cx
         pop       bx
         ret

TestMs   ENDP

; *****************************************************************************
;                             AddGFil
;               p©id†n° nalezenÇho souboru k cestà
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=text souboru k p©id†n°
; VùSTUP:CY=p©eteáen° dÇlky bufferu
; *****************************************************************************

AddGFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di

; ------ stanoven° dÇlky jmÇna souboru

         mov       cx,0ffffh
         mov       di,si                    ; adresa textu
         mov       al,0                     ; hledanò bajt
         cld
         repne     scasb                    ; nalezen° konce textu
         neg       cx
         dec       cx
         dec       cx                       ; CX = dÇlka textu

; ------ kontrola, zda bude p©eteáen° bufferu

         mov       ax,cx                    ; dÇlka textu
         add       ax,ds:[FilePthN]         ; nov† dÇlka textu cesty
         cmp       ax,MAXLINE-1             ; maxim†ln° dÇlka bufferu
         cmc
         jc        AddGFil9                 ; p©eteáen° bufferu

; ------ zaji®tàn° koncovÇho znaku "\"

         mov       di,offset FilePath       ; buffer cesty
         add       di,ds:[FilePthN]         ; konec cesty
         mov       al,"\"
         cmp       ds:[di-1],al             ; koná° znakem "\" ?
         je        AddGFil3                 ; koná° znakem "\" - OK
         mov       ds:[di],al               ; oddàlovac° znak
         inc       di                       ; zvò®en° ukazatele na dal®° znak

; ------ p©enesen° textu

AddGFil3:push      ds
         push      es

         push      ds
         push      es
         pop       ds
         pop       es
         cld
         rep       movsb                    ; p©enesen° textu

         pop       es
         pop       ds

; ------ koncov† 0, dÇlka textu

         mov       byte ptr ds:[di],0       ; koncov† 0
         sub       di,offset FilePath       ; nov† dÇlka textu
         mov       ds:[FilePthN],di         ; nov† dÇlka textu
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

AddGFil9:pop       di
         pop       si
         pop       cx
         pop       ax
         ret

AddGFil  ENDP

; *****************************************************************************
;                            SubGFil
;             odstranàn° posledn°ho souboru z cesty
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

SubGFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ konec textu v bufferu

         mov       si,offset FilePath       ; cesta
         add       si,ds:[FilePthN]         ; konec textu cesty

; ------ nalezen° posledn°ho znaku "\"

         mov       al,"\"                   ; hledanò znak "\"
SubGFil1:dec       si                       ; sn°ëen° ukazatele v bufferu
         cmp       ds:[si],al               ; je konec cesty ?
         jne       SubGFil1                 ; nen° - dal®° znak

; ------ oznaáen° konce cesty

         cmp       byte ptr ds:[si-1],":"   ; je to ROOT ?
         jne       SubGFil2                 ; nen° to ROOT
         inc       si                       ; zvò®en° ukazatele - ponech† se "\"
SubGFil2:mov       byte ptr ds:[si],0       ; koncov† 0

; ------ nov† dÇlka cesty

         sub       si,offset FilePath       ; dÇlka textu cesty
         mov       ds:[FilePthN],si         ; nov† dÇlka cesty

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       ax
         ret

SubGFil  ENDP

; *****************************************************************************
;                             SetDTA
;                      Nastaven° adresy DTA
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa DTA
; *****************************************************************************

SetDTA   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      ds

; ------ nastaven° adresy DTA

         push      es
         pop       ds                       ; segment adresy DTA
         mov       dx,si                    ; offset adresy DTA
         mov       ah,1ah                   ; funkce nastaven° adresy DTA
         int       21h                      ; nastaven° adresy DTA

; ------ n†vrat registrñ

         pop       ds
         pop       dx
         pop       ax
         ret

SetDTA   ENDP

; *****************************************************************************
;                               SrcFirst
;                   Nalezen° prvn°ho vyhovuj°c°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: CX=atributy souboru
;        ES:SI=specifikace souboru
;        DS=datovò segment
; VùSTUP:CY=chyba
;        ZY=soubor nalezen
;        NZ=soubor nenalezen
; *****************************************************************************

SrcFirst PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ nalezen° souboru nebo adres†©e

         push      ds
         push      es
         pop       ds                       ; segment adresy se jmÇnem souboru
         mov       dx,si                    ; offset adresy se jmÇnem souboru
         mov       ah,4eh                   ; funkce nalezen° souboru
SrcFrst1:int       21h                      ; nalezen° prvn°ho souboru
         pop       ds
         jnc       SrcFrst3                 ; operace OK - soubor nalezen

; ------ rozli®en° chyby - zda soubor nebyl nalezen nebo jin† chyba

         cmp       ax,2                     ; soubor nenalezen ?
         je        SrcFrst2                 ; soubor nenalezen
         cmp       ax,3                     ; cesta nenalezena ?
         je        SrcFrst2                 ; cesta nenalezena
         cmp       ax,12h                   ; nejsou dal®° soubory ?
         stc                                ; p©°znak chyby operace
         jne       SrcFrst4                 ; byla jin† chyba

; ------ soubor nenalezen (k¢dy chyb 2, 3 nebo 12h)

SrcFrst2:or        ax,ax                    ; nastaven° p©°znakñ NC, NZ
         jmp       short SrcFrst4

; ------ soubor nalezen OK

SrcFrst3:cmp       ax,ax                    ; nastaven° p©°znakñ NC, ZY
SrcFrst4:pop       dx
         pop       ax
         ret

SrcFirst ENDP


; *****************************************************************************
;                               SrcNext
;                   Nalezen° dal®°ho vyhovuj°c°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba
;        ZY=soubor nalezen
;        NZ=soubor nenalezen
; *****************************************************************************

SrcNext  PROC      NEAR

         push      ax
         push      dx

         push      ds
         mov       ah,4fh                   ; funkce nalezen° dal®°ho souboru
         jmp       short SrcFrst1           ; nalezen° dal®°ho souboru

SrcNext  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha velkÇ n†povàdy
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛
; *****************************************************************************
;                                 Napoveda
;                             hlavn° n†povàda
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

Napoveda PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ p©°prava registrñ

         or        byte ptr ds:[Param],bit6 ; p©°znak zobrazen° n†povàdy
         push      ds
         pop       es                       ; ES <- datovò segment
         call      DispHlp                  ; zobrazen° n†povàdy k n†povàdà
         call      DispNadp                 ; zobrazen° licenán°ho textu
         call      KurzOff                  ; vypnut° kurzoru

         mov       bp,offset(HelpTxt0-HelpTxt)/80 ; poáet ©†dkñ n†povàdy celkem

; ------ zobrazen° n†povàdy

Napoved1:mov       si,ds:[HelpTop]          ; adresa textu n†povàdy
         mov       bh,0
         mov       bl,ds:[MaxRow]           ; poáet ©†dkñ displeje - 1
         dec       bx
         cmp       bx,bp
         jbe       Napoved2
         mov       bx,bp                    ; omezen° poátu ©†dkñ
Napoved2:mov       dh,1
         mov       cl,80
         mov       ah,ds:[HelpColM]         ; barva textu
Napoved3:mov       dl,0
         call      DispTxt                  ; zobrazen° jednoho ©†dku n†povàdy
         inc       dh
         add       si,80
         dec       bx
         jnz       Napoved3

Napoved4:
         call      InpChr

         mov       ch,0
         mov       cl,ds:[MaxRow]           ; poáet ©†dkñ displeje - 1
         dec       cx                       ; poáet ©†dkñ na n†povàdu
         sub       cx,bp                    ; poáet p©esahuj°c°ch ©†dkñ
         jc        Napov42                  ; nezobraz° se cel† n†povàda
         xor       cx,cx                    ; omezen° - bude cel† n†povàda
Napov42: neg       cx                       ; maxim†ln° poá†teán° ©†dek

         call      JumpBX

         dw        5000h,Napov51            ; kurzor dolñ
         dw        4f00h,Napov52            ; END
         dw        5100h,Napov53            ; Page Down

         dw        4800h,Napov61            ; kurzor nahoru
         dw        4700h,Napov62            ; HOME
         dw        4900h,Napov63            ; Page Up

         dw        3b00h,Napoved9           ; F1 konec n†povàdy
         dw        11bh,Napoved9            ; ESC
         dw        1c0dh,Napoved9           ; ENTER
         dw        0,Napoved4

; ------ kurzor dolñ

Napov51: mov       bx,1                     ; poáet ©†dkñ k posunu

Napov50: cmp       cx,ds:[HelpTopN]         ; je jië maxim†ln° ©†dek ?
         jbe       Napoved1                 ; je jië maxim†ln° ©†dek
         inc       word ptr ds:[HelpTopN]   ; zvò®en° á°sla ©†dku
         add       word ptr ds:[HelpTop],80 ; adresa dal®°ho ©†dku
         dec       bx
         jnz       Napov50
Napov11: jmp       short Napoved1

; ------ END

Napov52: mov       bx,-1
         jmp       short Napov50

; ------ PAGE DOWN

Napov53: mov       bh,0
         mov       bl,ds:[MaxRow]
         dec       bx
         dec       bx
         jmp       short Napov50

; ------ kurzor nahoru

Napov61: mov       bx,1

Napov60: cmp       word ptr ds:[HelpTopN],0
         je        Napov11
         dec       word ptr ds:[HelpTopN]
         sub       word ptr ds:[HelpTop],80
         dec       bx
         jnz       Napov60
         jmp       short Napov11

; ------ HOME

Napov62: mov       bx,-1
         jmp       short Napov60

; ------ Page Up

Napov63: mov       bh,0
         mov       bl,ds:[MaxRow]
         dec       bx
         dec       bx
         jmp       short Napov60

; ------ n†vrat registrñ

Napoved9:and       byte ptr ds:[Param],not bit6
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Napoveda ENDP


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Univerz†ln° procedury
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;        dek¢dov†n° á°sla
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo
;        ES:DI=adresa konce bufferu (n†sleduj°c° adresa za koncem bufferu)
; VùSTUP:SI=adresa zaá†tku textu á°sla
; *****************************************************************************

DekNum   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©°prava registrñ

         xor       cx,cx                    ; á°taá ©†du
         mov       si,10                    ; dàlitel

; ------ dek¢dov†n° jednÇ á°slice

DekNum1: xchg      ax,bx                    ; BX <- £schova á°sla LOW
         xchg      ax,dx                    ; AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla HIGH
         xchg      ax,bx                    ; AX <- n†vrat LOW, BX<-£schova HIGH
         div       si                       ; vydàlen° á°sla LOW

; ------ oddàlovaá ©†dñ

         cmp       cl,3
         jne       DekNum2
         dec       di                       ; sn°ëen° ukazatele textu
         mov       byte ptr es:[di],"."     ; oddàlovaá ©†dñ
         xor       cx,cx                    ; á°taá ©†dñ
DekNum2: inc       cx                       ; zvò®en° á°taáe ©†dñ

; ------ uloëen° á°sla

         add       dl,"0"                   ; korekce na znak ASCII
         dec       di                       ; sn°ëen° ukazatele textu
         mov       es:[di],dl               ; uloëen° znaku
         mov       dx,bx                    ; n†vrat á°sla HIGH

; ------ test, zda bude dal®° á°slice

         or        bx,ax                    ; je á°slo jië = 0 ?
         jnz       DekNum1                  ; dek¢dov†n° dal®° á°slice
         mov       si,di                    ; adresa zaá†tku textu

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekNum   ENDP

; *****************************************************************************
;        dek¢dov†n° á°sla s barvou
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo
;        ES:DI=adresa konce bufferu (n†sleduj°c° adresa za koncem bufferu)
;        BH=atribut barvy
;        BL=oddàlovaá ©†dñ (0=nen° nic)
; *****************************************************************************

DekCNum  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ p©°prava registrñ

         mov       cl,0                     ; á°taá ©†du
         mov       si,10                    ; dàlitel

; ------ dek¢dov†n° jednÇ á°slice

DekCNum1:xchg      ax,bp                    ; BP <- £schova á°sla LOW
         xchg      ax,dx                    ; AX <- á°slo HIGH
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vydàlen° á°sla HIGH
         xchg      ax,bp                    ; AX <- n†vrat LOW, BX<-£schova HIGH
         div       si                       ; vydàlen° á°sla LOW

; ------ oddàlovaá ©†dñ

         cmp       cl,6
         je        DekCNm21
         cmp       cl,9
         je        DekCNm21
         cmp       cl,3
         jne       DekCNum2
DekCNm21:cmp       bl,0
         je        DekCNum2
         dec       di                       ; sn°ëen° ukazatele textu
         dec       di
         mov       es:[di],bx               ; oddàlovaá ©†dñ
DekCNum2:inc       cx                       ; zvò®en° á°taáe ©†dñ

; ------ uloëen° á°sla

         add       dl,"0"                   ; korekce na znak ASCII
         dec       di                       ; sn°ëen° ukazatele textu
         mov       es:[di],bh               ; uloëen° barvy
         dec       di
         mov       es:[di],dl               ; uloëen° znaku
         mov       dx,bp                    ; n†vrat á°sla HIGH

; ------ test, zda bude dal®° á°slice

         or        bp,ax                    ; je á°slo jië = 0 ?
         jnz       DekCNum1                 ; dek¢dov†n° dal®° á°slice

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekCNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° celÇ obrazovky
; -----------------------------------------------------------------------------

DispAll  PROC      NEAR

         push      si
         call      DispSezn
         call      DispHlp                  ; zobrazen° spodn°ho ©†dku
         call      DispNadp                 ; zobrazen° nadpisu
         call      KorVol                   ; korekce voleb
         call      DispVol                  ; zobrazen° voleb
         pop       si
         ret

DispAll  ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku AL na velkÇ p°smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; -----------------------------------------------------------------------------
;                                 InpChr
;                        vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; VùSTUP: BX=k¢d kl†vesy
;         CY=p©eru®en° ESC, BREAK
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

         push      ax

InpChr0: call      TestKey
         jz        InpChr0

         mov       ah,0
         int       16h

         or        ax,ax
         jnz       InpChr1
         mov       ax,11bh                  ; n†hrada Ctrl-Break znakem ESC

InpChr1: cmp       al,1bh
         clc
         jne       InpChr2
         stc                                ; p©°znak p©eru®en° Esc, Break

InpChr2: mov       bx,ax
         pop       ax
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

TestKey  PROC      NEAR

         push      ds
         xor       ax,ax
         mov       ds,ax
         and       byte ptr ds:[418h],not 80h
         pop       ds

         mov       ah,1
         int       16h
         ret

TestKey  ENDP

; -----------------------------------------------------------------------------
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
; -----------------------------------------------------------------------------

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

; -----------------------------------------------------------------------------
;                                 Cekej
;                        áek†n° po zadanou dobu
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet impulsñ 1/18 s
; -----------------------------------------------------------------------------

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

; -----------------------------------------------------------------------------
;                    zobrazen° textu n†povàdy DS:SI
; -----------------------------------------------------------------------------

DispHlp  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      es

; ------ stanoven° textu n†povàdy

         mov       dl,ds:[Param]
         test      dl,bit2                  ; prob°h† hled†n° souboru ?
         jnz       DispHlp9                 ; prob°h† hled†n° souboru

         mov       si,offset HelpTxt2       ; n†povàda k n†povàdà
         test      dl,bit6                  ; je velk† n†povàda ?
         jnz       DispHlp1                 ; je velk† n†povàda

         mov       si,offset HelpTxt1       ; n†povàda k zad†n° souborñ
         test      dl,bit4                  ; je zad†n° souborñ ?
         jnz       DispHlp1                 ; je zad†n° souborñ

         mov       si,offset HelpTxt5       ; zobrazen° souboru F3
         test      dl,bit5                  ; je zobrazen° souboru F3 ?
         jnz       DispHlp1                 ; je zobrazen° souboru F3

         mov       si,offset HelpTxt3       ; seznam bez oznaáen°
         cmp       word ptr ds:[InsNum],0   ; je nàco oznaáeno ?
         je        DispHlp1                 ; nen° nic oznaáeno
         mov       si,offset HelpTxt4       ; jinak n†povàda p©i oznaáen°


DispHlp1:

; ------ zobrazen° textu n†povàdy

         mov       ah,ds:[HelpCol]          ; barva textu n†povàdy
         mov       dl,0                     ; poá†teán° pozice textu
         mov       dh,ds:[MaxRow]           ; posledn° ©†dek displeje
         push      ds
         pop       es
         mov       cl,80                    ; dÇlka textu n†povàdy
         call      DispTxt                  ; zobrazen° textu n†povàdy

; ------ n†vrat registrñ

DispHlp9:pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispHlp  ENDP

; -----------------------------------------------------------------------------
;                      zobrazen° horn°ho ©†dku
; -----------------------------------------------------------------------------

DispNadp PROC      NEAR

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

; ------ zobrazen° licenán°ho textu

         mov       ah,ds:[InfoCol1]         ; barva textu n†povàdy
         test      byte ptr ds:[Param],bit0 ; bylo prvn° zad†n° ?
         jnz       DispNad2                 ; nylo prvn° zad†n°
         xor       dx,dx                    ; poá†teán° pozice textu
         push      ds
         pop       es
         mov       si,offset LicTxt
         mov       cl,80                    ; dÇlka textu n†povàdy
         call      DispTxt                  ; zobrazen° textu n†povàdy
         jmp       DispNad9

; ------ vymaz†n° bufferu ©†dku

DispNad2:sub       sp,2*80                  ; rezerva pro ©†dek
         push      ss
         pop       es
         mov       di,sp
         cld
         mov       al," "
         mov       cx,80
         rep       stosw                    ; vymaz†n° ©†dku

; ------ dek¢dov†n° poátu souborñ

         mov       di,sp
         push      di
         mov       si,offset TxtSou1
         call      DekTxt
         mov       cx,ds:[InsNum]           ; poáet oznaáenòch souborñ
         mov       bx,ds:[CitSoub]          ; poáet nalezenòch souborñ
         jcxz      DispNd22                 ; neoznaáen ë†dnò soubor
         mov       bx,cx                    ; poáet oznaáenòch souborñ
DispNd22:mov       ah,ds:[InfoCol2]         ; zvòraznàn† barva
         xor       dx,dx
         call      DekXNum                  ; á°slo zarovnanÇ vpravo
         pop       di
         add       di,2*16

; ------ dek¢dov†n° souátu velikost° souborñ

         push      di
         mov       si,offset TxtSou2
         mov       ah,ds:[InfoCol1]
         call      DekTxt
         mov       dx,word ptr ds:[CitCelk+2]
         mov       bx,word ptr ds:[CitCelk]
         jcxz      DispNd23                 ; nen° nic oznaáeno
         mov       dx,word ptr ds:[InsSumm+2]
         mov       bx,word ptr ds:[InsSumm]
DispNd23:mov       ah,ds:[InfoCol2]
         call      DekXNum
         pop       di
         add       di,2*21

; ------ dek¢dov†n° obsazenÇ kapacity soubory

         push      di
         mov       si,offset TxtSou3
         mov       ah,ds:[InfoCol1]
         call      DekTxt
         mov       dx,word ptr ds:[CitObs+2]
         mov       bx,word ptr ds:[CitObs]
         jcxz      DispNd24                 ; nen° nic oznaáeno
         mov       dx,word ptr ds:[InsObs+2]
         mov       bx,word ptr ds:[InsObs]
DispNd24:mov       ah,ds:[InfoCol2]
         call      DekXNum
         pop       di
         add       di,2*21

; ------ dek¢dov†n° kurzoru

         mov       bx,word ptr ds:[ViewTop]
         mov       cx,word ptr ds:[ViewTop+2]
         mov       dx,word ptr ds:[ViewSize]
         mov       ax,word ptr ds:[ViewSize+2]

         or        ax,ax
         jnz       DispNd25
         jcxz      DispNd26

DispNd25:shr       ax,1
         rcr       dx,1
         shr       cx,1
         rcr       bx,1

         or        ax,ax
         jnz       DispNd25
         or        cx,cx
         jnz       DispNd25

DispNd26:mov       cx,ds:[ViewDis]          ; zobrazen† á†st souboru

         mov       ah,ds:[InfoCol1]         ; barva textu
         mov       si,sp
         add       si,2*80-4
         sub       si,di
         shr       si,1                     ; celkov† dÇlka ukazatele

         test      byte ptr ds:[Param],bit5 ; je prohl°ëen° souboru ?
         jnz       DispNd27                 ; je prohl°ëen° souboru

         mov       bx,ds:[SeznTop]          ; zaá†tek str†nky
         mov       cx,ds:[SeznRad]          ; dÇlka str†nky
         mov       dx,ds:[DispNum]          ; celkovò poáet ©†dkñ

DispNd27:call      DekKurz                  ; dek¢dov†n° kurzoru

; ------ zobrazen° ©†dku

DispNd4: mov       si,sp
         mov       cl,80
         xor       dx,dx
         call      DispStr

; ------ n†vrat registrñ

DispNad9:mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNadp ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukl†dac° adresa
;        AH=barva textu
;        BX=poá†tek (jednotek)
;        CX=dÇlka (jednotek)
;        DX=celkov† dÇlka (jednotek)
;        SI=celkov† dÇlka kurzoru (pozic)
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) zobrazenò poá†tek (jednotek)
;                   SS:[BP-4] (2) zobrazen† dÇlka (jednotek)
;                   SS:[BP-5] (1) barva textu
;                   SS:[BP-6] (1)
; -----------------------------------------------------------------------------

DekKurz  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         mov       bp,sp

; ------ lok†ln° promànnÇ

         sub       sp,6                     ; lok†ln° promànnÇ
         mov       ss:[bp-2],bx             ; zobrazenò poá†tek (jednotek)
         mov       ss:[bp-4],cx             ; zobrazen† dÇlka (jednotek)
         mov       ss:[bp-6],ax             ; AH=barva textu

; ------ lev† oddàlovac° á†ra kurzoru

         cld
         mov       al,179                   ; oddàlovac° á†ra
         stosw                              ; uloëen° oddàlovac° á†ry

; ------ vòpoáet dÇlky kurzoru

         mov       ax,cx                    ; zobrazen† dÇlka (jednotek)
         mov       cx,dx                    ; celkov† dÇlka (jednotek)
         cmp       ax,cx                    ; je dÇlka OK ?
         jbe       DekKurz1                 ; dÇlka je OK
         mov       ax,cx                    ; omezen° dÇlky kurzoru
DekKurz1:jcxz      DekKurz8                 ; nen° ë†dnò soubor
         mul       si                       ; * celkov† dÇlka kurzoru (pozic)
         div       cx                       ; vòpoáet dÇlky kurzoru
         mov       bx,ax                    ; dÇlka kurzoru
         cmp       bl,0                     ; vy®la dÇlka kurzoru = 0 ?
         jne       DekKurz2                 ; dÇlka kurzoru je OK
         inc       bx                       ; minim†ln° dÇlka kurzoru = 1
DekKurz2:cmp       bx,si                    ; m† kurzor dÇlku OK ?
         jbe       DekKurz3                 ; dÇlka kurzoru je OK
         mov       bx,si                    ; omezen° dÇlky kurzoru

; ------ vòpoáet poá†tku kurzoru

DekKurz3:mov       ax,ss:[bp-2]             ; zobrazenò poá†tek (jednotek)
         or        ax,ax                    ; je poá†tek = 0 ?
         jz        DekKurz4                 ; poá†tek je = 0
         mov       ax,ss:[bp-4]             ; zobrazen† dÇlka (jednotek)
;         sub       ax,3                     ;
         shr       ax,1                     ; polovina dÇlky
;         add       ax,ss:[bp-4]             ; to je 1.5 dÇlky
;         shr       ax,1                     ; to je 3/4 dÇlky
         add       ax,ss:[bp-2]             ; + poá†tek = pozice st©edu
         mul       si                       ; * celkov† dÇlka kurzoru
         div       cx                       ; vòpoáet konce kurzoru
DekKurz4:mov       bh,al                    ; poá†tek kurzoru
         add       al,bl                    ; konec kurzoru
         cmp       ax,si                    ; p©ekroáen konec ?
         jbe       DekKurz5                 ; konec OK
         mov       ax,si                    ; celkov† dÇlka ukazatele
         sub       al,bl                    ; odeáten° dÇlky kurzoru
         mov       bh,al                    ; zaá†tek kurzoru

; ------ dek¢dov†n° kurzoru

DekKurz5:mov       ah,ss:[bp-5]             ; barva textu
         mov       al,176                   ; znak p©ed kurzorem
         mov       ch,0
         mov       cl,bh                    ; poá†tek kurzoru
         rep       stosw                    ; zaá†tek kurzoru
         mov       al,178                   ; znak kurzoru
         mov       cl,bl                    ; dÇlka kurzoru
         rep       stosw                    ; kurzor
         mov       al,176                   ; znak za kurzorem
         mov       cx,si                    ; celkov† dÇlka ukazatele
         sub       cl,bl                    ; odeáten° dÇlky kurzoru
         sub       cl,bh                    ; odeáten° poá†tku kurzoru
         rep       stosw                    ; konec kurzoru

; ------ n†vrat registrñ

DekKurz8:mov       sp,bp
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DekKurz  ENDP

;; -----------------------------------------------------------------------------
;;        zobrazen° n†povàdy DS:SI
;; -----------------------------------------------------------------------------
;
;DispHlp  PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      cx
;         push      dx
;         push      si
;         push      es
;
;; ------ zobrazen° n†povàdy
;
;         push      ds
;         pop       es
;         mov       cl,80
;         mov       dh,ds:[MaxRow]
;         mov       dl,0
;         mov       ah,ds:[InfoCol1]
;         call      DispTxt                  ; zobrazen° textu n†povàdy
;
;; ------ n†vrat registrñ
;
;         pop       es
;         pop       si
;         pop       dx
;         pop       cx
;         pop       ax
;         ret
;
;DispHlp  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° á°sla DX:BX zarovnanÇho vlevo
; -----------------------------------------------------------------------------

DekXNum  PROC      NEAR

         push      si

         push      di
         push      es
         xchg      ax,bx                    ; á°slo LOW
         push      ds
         pop       es
         mov       di,offset BuffNum0       ; buffer k dek¢dov†n° á°sla
         call      DekNum                   ; dek¢dov†n° á°sla
         pop       es
         pop       di

         xchg      ax,bx                    ; n†vrat á°sla a barvy
         call      DekTxt                   ; dek¢dov†n° textu
         pop       si
         ret

DekXNum  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                     Univerz†ln° obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;                               StdErr
;              vòstup textu ASCIIZ na standardn° chybovÇ za©°zen°
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text ASCIIZ k vòstupu
; *****************************************************************************

StdErr   PROC      NEAR

; ------ identifik†tor standardn°ho chybovÇho za©°zen°

         push      bx
         mov       bx,2                     ; identifik†tor chybovÇho za©°zen°
         jmp       short StdOut1            ; vòstup textu

StdErr   ENDP

; *****************************************************************************
;                              StdOut
;                vòstup textu ASCIIZ na standardn° vòstupn° za©°zen°
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text ASCIIZ k vòstupu
; *****************************************************************************

StdOut   PROC      NEAR

; ------ identifik†tor standardn°ho vòstupn°ho za©°zen°

         push      bx
         mov       bx,1                     ; identifik†tor vòstupn°ho za©°zen°

; ------ £schova registrñ

StdOut1: push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es
         mov       di,si                    ; zaá†tek textu
         mov       dx,si                    ; zaá†tek textu

; ------ stanoven° dÇlky textu

         mov       cx,0ffffh
         cld
         mov       al,0                     ; hledanò znak konce
         repne     scasb                    ; nalezen° konce textu
         neg       cx                       ; dÇlka textu + 2
         dec       cx
         dec       cx                       ; dÇlka textu

; ------ zobrazen° textu

         mov       ah,40h
         int       21h                      ; zobrazen° textu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax

         pop       bx
         ret

StdOut   ENDP

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
;         sub       ch,2
;         mov       cl,80                    ; poáet pozic na ©†dek
;         mov       al," "                   ; znak pro vymaz†n°
;         mov       ah,ds:[Barva1]           ; z†kladn° barva
;         mov       dh,1                     ; poá†teán° ©†dek
;
;Clear1:  mov       dl,0                     ; poá†teán° pozice
;         call      DispChr                  ; vymaz†n° ©†dku
;         inc       dh
;         dec       ch
;         jnz       Clear1                   ; dal®° ©†dek
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
;                              DispStin
;                           Zobrazen° st°nu
; -----------------------------------------------------------------------------
; VSTUP:  CL=poáet pozic k zobrazen° st°nu
;         DL=poá†teán° pozice
;         DH=poá†teán° ©†dek
;         DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispStin PROC      NEAR

; ------ kontrola maxim†ln° pozice

         cmp       dl,79                    ; kontrola maxim†ln° pozice
         ja        DispStn8                 ; pozice p©ekroáena
         cmp       dh,ds:[MaxRow]           ; kontrola maxim†ln°ho ©†dku
         ja        DispStn8                 ; ©†dek p©ekroáen

; ------ £schova registrñ

         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      di                       ; £schova DI
         push      es                       ; £schova ES
         xor       ch,ch                    ; CX = poáet znakñ

; ------ omezen° poátu znakñ (do konce ©†dku)

         mov       al,80                    ; poáet pozic na ©†dku
         sub       al,dl                    ; zbylò poáet moënòch pozic
         cmp       al,cl                    ; p©ekroáen poáet znakñ ?
         jae       DispStn1                 ; nen° p©ekroáen poáet znakñ
         mov       cl,al                    ; omezen° poátu znakñ

; ------ vòpoáet adresy ve videopamàti

DispStn1:les       di,ds:[AdrVRAM]          ; adresa zaá†tku VRAM
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dkñ na pozice
         xor       dh,dh                    ; DX=pozice
         add       ax,dx                    ; p©iáten° pozice
         shl       ax,1                     ; * 2 = offset ve videostr†nce
         add       di,ax                    ; adresa ve videopamàti

; ------ zobrazen° st°nu

         jcxz      DispStn7
         mov       al,7
         inc       di
DispStn6:mov       byte ptr es:[di],al
         inc       di
         inc       di
         loop      DispStn6

; ------ n†vrat registrñ, konec

DispStn7:pop       es                       ; n†vrat ES
         pop       di                       ; n†vrat DI
         pop       dx                       ; n†vrat DX
         pop       cx                       ; n†vrat CX
         pop       bx                       ; n†vrat BX
         pop       ax                       ; n†vrat AX

DispStn8:add       dl,cl                    ; zvò®en° pozice
         ret

DispStin ENDP

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
         cmp       byte ptr es:[84h],15     ; je £daj poátu ©†dkñ platnò ?
         jb        AktParD5                 ; £daj poátu ©†dkñ nen° platnò
         cmp       byte ptr es:[84h],59     ; maxim†ln° ©†dek displeje
         ja        AktParD5
         mov       bl,es:[84h]              ; poáet ©†dkñ displeje - 1
AktParD5:mov       bh,es:[87h]              ; p©°znak kontroly snàëen°
         shr       bh,1
         shr       bh,1
         and       bh,1                     ; p©°znak obsluhy snàëen°
         mov       ds:[ChckSnow],bh         ; nastaven° p©°znaku kontroly snàë.
AktParD6:mov       ds:[MaxRow],bl           ; maxim†ln° ©†dek na displeji
         inc       bx                       ; poáet ©†dkñ celkem
         mov       ds:[Radku],bl            ; poáet ©†dkñ celkem
         sub       bl,2
         mov       byte ptr ds:[SeznRad],bl ; poáet ©†dkñ str†nky seznamu

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

; ------ texty

HelpTxt  db        '…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ HLEDEJ  verze 1.12 ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª'
HelpTx11 db        '∫                                                                              ∫'
         db        '∫ SYNTAXE zadani souboru k hledani:   ADRESAR\maska1 maska2 ..... / PARAMETRY  ∫'
         db        '∫ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ∫'
         db        '∫                                                                              ∫'
         db        '∫ ADRESAR   je vychozi adresar hledani. K sestaveni plne specifikace vychoziho ∫'
         db        '∫           adresare  se  pouzije  aktivni  adresar.  Pouze v pripade, ze neni ∫'
         db        '∫           adresar ani disk zadan vubec  (jsou  zadany  pouze  soubory), bude ∫'
         db        '∫           prohledavan cely disk. Pri vyhledavani se  postupuje  z  vychoziho ∫'
         db        '∫           adresare do vsech podadresaru.  Za  jmeno  vychoziho  adresare  se ∫'
         db        '∫           povazuje text od zacatku radku po posledni znak "\"  pred zacatkem ∫'
         db        '∫           parametru v radku (resp. ":", je-li zadan pouze disk).             ∫'
         db        '∫                                                                              ∫'
         db        '∫ maska     maska specifikace souboru.  V zadani  masky pro hledani lze pouzit ∫'
         db        '∫           nahradni znaky "?" (=na pozici muze byt libovolny zmak) a "*" (=na ∫'
         db        '∫           pozici muze byt skupina libovolnych znaku).  Znak "*" muze byt (na ∫'
         db        '∫           rozdil od bezne konvence v DOS) uveden i uprostred jmena vicekrat. ∫'
         db        '∫           Neni-li  zadana  pripona jmena souboru (=neni zadana tecka), mohou ∫'
         db        '∫           se  zadane  znaky  vyskytovat jak ve jmene, tak i v pripone jmena. ∫'
         db        '∫           Masek specifikace souboru  lze  uvest  vice  najednou. Masky se od ∫'
         db        '∫           sebe navzajem oddeluji znakem mezery. Prvni maska muze byt uvedena ∫'
         db        '∫           bezprostredne za koncovym znakem cesty "\".                        ∫'
         db        '∫                                                                              ∫'
         db        '∫                                                                              ∫'
         db        '∫                  PARAMETRY - nasleduji za oddelovacim znakem "/"             ∫'
         db        '∫               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ           ∫'
         db        '∫ D datum   podminkou hledani bude datum souboru (adresare).  Datum je  zadano ∫'
         db        '∫           ve tvaru DEN.MESIC.ROK (jako oddelovaci znaky lze pouzit tez znaky ∫'
         db        '∫           ":", "/" nebo ","). Rok lze zadat bud dvojciferne  (posledni dvoj- ∫'
         db        '∫           cisli) nebo plnym zadanim  4 cislic.  Kterykoliv  z udaju data lze ∫'
         db        '∫           vypustit (nebo nahradit znakem "?"), tento udaj se nebude porovna- ∫'
         db        '∫           vat. Bude-li zadan pouze parametr  D  bez zadani data,  pouzije se ∫'
         db        '∫           dnesni den. Datum lze zadat  tez  jako  interval  DATUM1 - DATUM2. ∫'
         db        '∫           Kteroukoliv stranu intervalu lze vynechat.                         ∫'
         db        '∫                                                                              ∫'
         db        '∫ T cas     podminkou hledani  bude  cas  souboru.  Cas  se  zadava  ve  tvaru ∫'
         db        '∫           HODINA:MINUTA:SEKUNDA. Vse  ostatni  plati  stejne  jako  u  data. ∫'
         db        '∫           Uvedenim parametru T bez zadani casu se pouzije aktualni hodina.   ∫'
         db        '∫                                                                              ∫'
         db        '∫ N cislo   podminkou hledani bude velikost souboru  (v bajtech). Velikost lze ∫'
         db        '∫           zadat bud jako urcitou hodnotu nebo jako interval OD - DO.         ∫'
         db        '∫                                                                              ∫'
         db        '∫ R R+ r+   podminkou hledani je, ze soubor ma nastaven atribut R/O.           ∫'
         db        '∫ r R- r-   podminkou hledani je, ze soubor ma vynulovan atribut R/O.          ∫'
         db        '∫ H H+ h+   podminkou hledani je, ze soubor ma nastaven atribut HID.           ∫'
         db        '∫ h H- h-   podminkou hledani je, ze soubor ma vynulovan atribut HID           ∫'
         db        '∫ S S+ s+   podminkou hledani je, ze soubor ma nastaven atribut SYS.           ∫'
         db        '∫ s S- s-   podminkou hledani je, ze soubor ma vynulovan atribut SYS.          ∫'
         db        '∫ A A+ a+   podminkou hledani je, ze soubor ma nastaven atribut ARC.           ∫'
         db        '∫ a A- a-   podminkou hledani je, ze soubor ma vynulovan atribut ARC.          ∫'
         db        '∫ C C+ c+   budou vyhledavany jen adresare (nastaven atribut DIR).             ∫'
         db        '∫ c C- c-   budou vyhledavany jen soubory (vynulovan atribut DIR).             ∫'
         db        '∫ z Z       nebudou prohledavany podadresare.                                  ∫'
         db        '∫                                                                              ∫'
         db        '∫ "text"    podminkou hledani bude text obsazeny  v souboru.  Pri  vyhledavani ∫'
         db        '∫           textu se nerozlisuji velka a mala pismena  (to neplati o narodnich ∫'
         db        '∫           znacich s diakritikou). V textu lze pouzit jakekoliv znaky s kodem ∫'
         db        '∫           od 0 do 255 (lze zadavat dekadicky metodou Alt-cislo, znak s kodem ∫'
         db        '∫           0 lze zadat jako Ctrl-@).  Obsahuje-li text znak uvozovek ",  musi ∫'
         db        '∫           byt  tento  znak  uvnitr  textu  zadan  jako  dva  znaky  uvozovek ∫'
         db        '∫           besprostredne za sebou. Nebude-li text  ukoncen  znakem  uvozovek, ∫'
         db        '∫           budou koncove mezery ignorovany.                                   ∫'
         db        '∫                                                                              ∫'
         db        '∫ Priklady:                                                                    ∫'
         db        '∫ ƒƒƒƒƒƒƒƒƒ                                                                    ∫'
         db        '∫ *.exe *.com /D ?.4.92     - vsechny programy EXE a COM z dubna 1992          ∫'
         db        '∫ juk /D - 12.5.            - soubory do 12.5. kazdeho roku, zacinajici "JUK"  ∫'
         db        '∫ *mac*                     - soubory obsahujici text "MAC" ve jmene           ∫'
         db        '∫ *.EXE *.COM /"Runtime error" - vsechny programy napsane v Pascalu            ∫'
         db        '∫ *.* /C d12.3.             - adresare vytvorene dne 12.3.                     ∫'
         db        '∫ *.BAK /d                  - zalozni soubory BAK dnes vytvorene               ∫'
         db        '∫ *.TXT /"DOS"              - textove soubory obsahujici text "DOS"            ∫'
         db        '∫ *.* /h+ c+                - vsechny skryte (uzamcene) adresare               ∫'
         db        '∫ *.zip *.arj /n362000-     - archivni soubor vetsi nez disketa 360K           ∫'
HelpTx12 db        '∫                                                                              ∫'
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº'
HelpTxt0 label     byte

HelpTop  dw        offset HelpTxt           ; adresa zaá†tku zobrazenÇ n†povàdy
HelpTopN dw        0                        ; á°slo poá†teán°ho ©†dku

LicTxt   db        '  HLEDEJ V 1.12 - vyhledavani souboru                     (c) Miroslav Nemecek  '

MemTxt   db        'Nedostatek pameti !',13,7,10,0

HelpTxt1 db        ' ESC=navrat ≥ ENTER=zahajeni hledani ≥ F1=napoveda k syntaxi zadani             '
HelpTxt2 db        ' ESC=navrat ≥ listovani napovedou: sipky nahoru/dolu, Home/End, PageUp/PageDown '
HelpTxt3 db        ' ESC=konec ≥ ENTER=zmena adresare ≥ INSERT,DELETE=oznac ≥ F3=zobraz ≥ F7=hledej '
HelpTxt4 db        ' ESC=konec ≥ ENTER=vypis seznamu  ≥ INSERT,DELETE=oznac ≥ F3=zobraz ≥ F7=hledej '
HelpTxt5 db        ' ESC,F3=navrat z funkce zobrazeni souboru                                       '
HelpTxt6 db        ' Cekejte, ukladam vypis oznacenych souboru ...                                  '

SegPSP   dw        0                        ; segment PSP

UvTxt    db        'HLEDEJ V1.12 - vyhledavani souboru; (c) Miroslav Nemecek'
CRLFTxt  db        13,10,0

; -----------------------------------------------------------------------------
;        barvy
; -----------------------------------------------------------------------------

ColCol   label     byte

; ------ n†povàda

HelpColM db        1fh ; 0fh                ; barva hlavn° n†povàdy
HelpCol  db        30h ; 70h                ; barva malÇ n†povàdy

; ------ poloëky seznamu (zachovat po©ad° !)

Barva1   db        1bh ; 07h                ; z†kladn° barva
Barva2   db        30h ; 70h                ; barva kurzoru
Barva3   db        1eh ; 0fh                ; barva vysv°cenÇ poloëky
Barva4   db        3eh ; 70h                ; kurzor na vysv°cenÇ poloëce
Barva5   db        0fh ; 0fh                ; barva cesty (jenom text)
Barva6   db        1dh ; 07h                ; barva ©°dic°ch znakñ textu

; ------ okno voleb

BarvaR1  db        70h ; 70h                ; z†kladn° barva r†mu voleb
BarvaR2  db        30h ; 07h                ; barva kurzoru voleb
BarvaR3  db        71h ; 70h                ; barva editovanÇho ©†dku

; ------ informaán° ©†dek

InfoCol1 db        70h ; 70h                ; bàën† barva informaán°ho ©†dku
InfoCol2 db        74h ; 70h                ; zvòraznàn† barva inform. ©†dku

ColCol0  label     byte

; -----------------------------------------------------------------------------
;        barvy pro monochrom. displej
; -----------------------------------------------------------------------------

ColMono  label     byte

; ------ n†povàda

         db        0fh                      ; barva hlavn° n†povàdy
         db        70h                      ; barva malÇ n†povàdy

; ------ poloëky seznamu (zachovat po©ad° !)

         db        07h                      ; z†kladn° barva
         db        70h                      ; barva kurzoru
         db        0fh                      ; barva vysv°cenÇ poloëky
         db        70h                      ; kurzor na vysv°cenÇ poloëce
         db        0fh                      ; barva cesty
         db        07h                      ; barva ©°dic°ch znakñ textu

; ------ okno voleb

         db        70h                      ; z†kladn° barva r†mu voleb
         db        07h                      ; barva kurzoru voleb
         db        70h                      ; barva editovanÇho ©†dku

; ------ informaán° ©†dek

         db        70h                      ; bàën† barva informaán°ho ©†dku
         db        70h                      ; zvòraznàn† barva inform. ©†dku

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

; -----------------------------------------------------------------------------
;        obsluha hled†n° souborñ
; -----------------------------------------------------------------------------

                                          ;* obsluhovanò soubor/adres†©
FilePthN dw        0                        ; dÇlka textu adres†©e + soubor
FilePath db        MAXLINE dup(0)           ; buffer adres†©e + soubor

FileFCB  db        11 dup(0)                ; jmÇno souboru ve tvaru FCB

; ------ podm°nky pro vyhled†n° souboru

                                          ;* buffer masek obsahuje texty masek
                                          ;* konvertovanÇ na velk† p°smena a
                                          ;* navz†jem oddàlenÇ jednou mezerou
         EVEN
FileMskN dw        0                        ; dÇlka textu v bufferu masek
FileMask db        MAXLINE dup(0)           ; buffer masek

         EVEN                               ; pro zrychlen° sud† adresa
SrcInit1 label     byte                     ; zaá†tek tabulky parametrñ hled†n°

SrcAtr   db        0                        ; atributy hledanÇho souboru
SrcAtrM  db        0                        ; maska atributñ hledanÇho souboru

SrcTim1  dw        0                        ; poá†teán° áas souboru
SrcTim1M dw        0                        ; maska poá†teán°ho áasu souboru
SrcTim2  dw        0                        ; koncovò áas souboru
SrcTim2M dw        0                        ; maska koncovÇho áasu souboru

SrcDat1  dw        0                        ; poá†teán° datum souboru
SrcDat1M dw        0                        ; maska poá†teán°ho data souboru
SrcDat2  dw        0                        ; koncovÇ datum souboru
SrcDat2M dw        0                        ; maska koncovÇho data souboru

SrcSiz1  dd        0                        ; poá†teán° velikost souboru
SrcSiz2  dd        0                        ; koncov† velikost souboru

SrcTextN dw        0                        ; dÇlka hledanÇho textu
SrcText  db        MAXLINE dup(0)           ; buffer hledanÇho textu

SrcInit2 label     byte                     ; konec tabulky parametrñ hled†n°

HledTxt1 dw        HledTxt2-$
         db        'Prohledavam ',0
HledTxt2 label     word

CekTxt   db        'Hledam...',13,0
CekTxt0  db        '         ',13,0

FndTxt0  db        'Nenalezen zadny zadany soubor !',13,10,0
FndTxt1  db        'nalezeno celkem  : ',0
FndTxt2  db        ' souboru/adresaru',13,10
         db        'soucet velikosti : ',0
FndTxt3  db        ' bajtu',13,10
         db        'obsazena kapacita: ',0
FndTxt4  db        ' bajtu',13,10,0


TxtSou1  db        ' Souboru: ',0
TxtSou2  db        179,'Soucet: ',0
TxtSou3  db        179,'Zabira: ',0

BuffNum  db        '              '         ; buffer k dek¢dov†n° á°sla
BuffNum0 db        0

All      db        '*.*',0

AdrTxt   db        '<ADRESAR>'

AtrTab   db        3,'Arc'
         db        1,'Dir'
         db        2,'Sys'
         db        1,'Hid'
         db        1,'R/O'

; -----------------------------------------------------------------------------
;        informaán° ©†dek
; -----------------------------------------------------------------------------

InfoXCol db        0                        ; p©°znak zvòraznànÇ barvy textu
InfoStor dw        0                        ; ukl†dac° adresa do bufferu
InfoBuf  dw        80 dup(0)                ; buffer informaán°ho ©†dku

InfoKMax dd        0                        ; celkov† velikost inform. kurzoru
InfoKCit dd        0                        ; á°taá velikosti inform. kurzoru

; -----------------------------------------------------------------------------
;        seznam nalezenòch souborñ
; -----------------------------------------------------------------------------

; Struktura:
;        cesta:   0: (1) (atribut) bit6: je nastaven na 1 (=p©°znak)
;                 1: (N) plnò text cesty ASCIIZ
;       soubor:   0: (1) atributy
;                          bit 6: je vëdy 0
;                          bit 7: 1=poloëka oznaáena
;                 1: (2) áas
;                 3: (2) datum
;                 5: (4) velikost
;                 9: (n) jmÇno ASCIIZ

SeznSegm dw        0                        ; segment seznamu souborñ
SeznSize dw        0                        ; velikost seznamu souborñ

SeznNumO dw        0                        ; pñvodn° velikost dat v seznamu
SeznNum  dw        0                        ; velikost dat v seznamu (bajtñ)

SeznTop  dw        0                        ; á°slo prvn°ho ©†dku
SeznAkt  dw        0                        ; á°slo aktivn°ho ©†dku

SeznRad  dw        23                       ; dÇlka str†nky seznamu (©†dkñ)

InsNum   dw        0                        ; poáet oznaáenòch souborñ
InsSumm  dd        0                        ; souáet oznaáenòch souborñ
InsObs   dd        0                        ; obsazen† kapacita soubory

CitSoub  dw        0                        ; á°taá nalezenòch souborñ
CitCelk  dd        0                        ; á°taá kapacity celkem
CitObs   dd        0                        ; á°taá obsazenÇ kapacity
DiskBlok dw        0                        ; velikost alokaán°ho bloku disku

; -----------------------------------------------------------------------------
;        historie hled†n°
; -----------------------------------------------------------------------------

Param    db        0                        ; parametry
                                            ;  bit 0: 1=bylo prvn° zad†n° param.
                                            ;  bit 1: 1=zah†jena editace ©†dku
                                            ;  bit 2: 1=prob°h† hled†n° souboru
                                            ;  bit 3: 1=hled† se text v souboru
                                            ;  bit 4: 1=zad†v† se specifikace
                                            ;  bit 5: 1=je prohl°ëen° souboru F3
                                            ;  bit 6: 1=je zobrazena n†povàda
                                            ;  bit 7: 1=zad†n p©°kazovò ©†dek

Param2   db        0                        ; parametry 2
                                            ;  bit 0: 1=prohled†vaj° se podadr.

SouborI  dw        0                        ; identifik†tor souboru (0=neplat°)
SoubHst  db        'HLEDEJ.HST',0           ; jmÇno souboru histori°

SoubHist db        128+11 dup(0)            ; buffer jmÇna souboru histori°
SoubList db        128+11 dup(0)            ; buffer jmÇna souboru vòpisu

HistNum  dw        0                        ; poáet bajtñ v bufferu historie
HistLine dw        0                        ; poáet ©†dkñ v bufferu historie

         EVEN                               ; zarovn†n° na sudou adresu

HistBuff db        HISTSIZE dup(?)          ; buffer historie


SelBuff  db        90 dup(?)                ; buffer p©edvolby (ukonáenò CR/LF)

EditTop  dw        ?                        ; offset poá†tku ©†dku
EditKurz dw        ?                        ; offset kurzoru v ©†dku

KurzRad  db        ?                        ; ©†dek s kurzorem na obrazovce
         db        ?                        ; zarovn†n° na sudou adresu

EditTopL dw        ?                        ; á°slo poá†teán°ho ©†dku
EditKurL dw        ?                        ; á°slo aktivn°ho ©†dku

EditBuff db        MAXLINE dup(?)           ; editaán° buffer (doplnànò mezer.)
         dw        ?                        ; rezerva pro uloëen° znakñ CR/LF

; -----------------------------------------------------------------------------
;        tabulka DTA - funkce nalezen° souboru
; -----------------------------------------------------------------------------

;         EVEN
DTA      label     byte
         db        15h dup(?)
DTAAtrib db        ?                        ; (1) atributy nalezenÇho souboru
DTATime  dw        ?                        ; (2) áas nalezenÇho souboru
DTADate  dw        ?                        ; (2) datum nalezenÇho souboru
DTASize  dd        ?                        ; (4) velikost nalezenÇho souboru
DTAName  db        13 dup(?)                ; (13) jmÇno nalez. souboru ASCIIZ
         db        ?                        ; zarovn†n° na sudou adresu

; -----------------------------------------------------------------------------
;        obsluha prohl°ëeáe souboru
; -----------------------------------------------------------------------------

ViewIdnt dw        ?                        ; identifik†tor souboru
ViewBeg  dd        ?                        ; adresa poá†tku bufferu
ViewTop  dd        ?                        ; adresa poá†tku obrazovky
ViewNum  dw        ?                        ; poáet bajtñ v bufferu
ViewName db        128 dup(?)               ; buffer jmÇna souboru
ViewSize dd        ?                        ; velikost souboru
ViewDis  dw        ?                        ; zobrazen† á†st souboru

;         EVEN
ViewBuf  db        VIEWBMAX dup(?)          ; buffer prohl°ëeáe

; -----------------------------------------------------------------------------
;        £schova obrazovky a stavu poá°taáe
; -----------------------------------------------------------------------------

OldBreak db        ?                        ; uschovanò p©°znak BREAK
         db        ?                        ; zarovn†n° na sudou adresu

OldKurz  dw        ?                        ; uschovan† pozice kurzoru
ObrSize  dw        ?                        ; velikost bufferu obrazovky (slov)
ObrSegm  dw        ?                        ; adresa bufferu displeje

; -----------------------------------------------------------------------------
;        indexovÇ tabulky seznamu
; -----------------------------------------------------------------------------

SrcIdnt  dw        ?                        ; identifik†tor souboru
SrcBNum  dw        ?                        ; poáet bajtñ v bufferu hled†n°
SrcBuff  db        SRCBMAX dup(?)           ; buffer pro hled†n° textu

DispNum  dw        ?                        ; poáet indexñ zobrazen° (=poá. ©.)
DispNumO dw        ?                        ; pñvodn° poáet indexñ zobrazen°
DispIndx dw        INDXSIZE dup(?)          ; indexy pro zobrazen°

HledNum  dw        ?                        ; poáet indexñ pro hled†n°
HledNumO dw        ?                        ; pñvodn° poáet indexñ
HledIndx dw        INDXSIZE dup(?)          ; indexy pro hled†n°

CODE     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                              Z†sobn°k
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Zasob    SEGMENT   STACK

         dw        300h dup(?)

Zasob    ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Konec programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

KonSegm  SEGMENT
KonSegm  ENDS

         END       Start

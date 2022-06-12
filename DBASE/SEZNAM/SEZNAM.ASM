

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         seznam (jednoduch† datab†ze)
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Start programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

CR       EQU       13                       ; znak CR
LF       EQU       10                       ; znak LF
EOF      EQU       26                       ; znak konce souboru EOF

MAXHLED  EQU       26                       ; maxim†ln° dÇlka textu k hled†n°

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ zmen®en° segmentu programu na minimum

Start:   mov       cs:[SegPSP],ds           ; £schova segmentu PSP
         mov       bx,SEG KonSegm           ; segment konce programu
         mov       ax,es                    ; segment PSP
         sub       bx,ax                    ; velikost programu v odstavc°ch
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku pamàti
         mov       dx,offset MemErr
         jc        Start1                   ; chyba pamàti

; ------ vytvo©en° datovÇho bloku pro data

         mov       ah,48h
         mov       bx,0ffffh                ; max. velikost
         int       21h
         mov       ah,48h
         int       21h                      ; p©idàlen° alok. bloku
         jc        Start1                   ; nedostatek pamàti
         cmp       bx,80h                   ; minimum pamàti
         jb        Start1                   ; nedostatek pamàti
         mov       es,ax                    ; adresa datovÇho bloku
         mov       byte ptr es:[0fh],EOF    ; oznaáen° zaá†tku textu
         inc       ax                       ; zvò®en° adresy
         mov       cs:[SegDat],ax           ; adresa datovÇho bloku
         mov       word ptr cs:[AdrTop+2],ax ; adresa poá†tku str†nky
         mov       word ptr cs:[AdrKurz+2],ax ; adresa kurzoru
         sub       bx,8                     ; rezerva pro p©esuny atd.
         mov       cs:[SizDat],bx           ; velikost datovÇho bloku

; ------ implicitn° jmÇno datovÇho souboru

         push      ds
         mov       ds,cs:[SegPSP]           ; segment PSP
         mov       ds,ds:[2ch]              ; segmemt prost©ed°
         xor       si,si
Start102:inc       si
         cmp       word ptr ds:[si-1],0
         jne       Start102                 ; nalezen° konce prost©ed°
         add       si,3                     ; text jmÇna souboru
         mov       cx,128
         mov       di,offset Soubor1        ; soubor seznamu
         push      cs
         pop       es
         cld
         rep       movsb                    ; p©enos do bufferu
         pop       ds
         mov       di,offset Soubor1
         mov       bx,offset ExtDat
         call      SetExt                   ; nastaven° p©°pony DAT

; ------ dek¢dov†n° jmÇna souboru seznamu

Start108:mov       si,81h                   ; zaá†tek textu p©°kazovÇho ©†dku
         mov       cl,ds:[si-1]             ; dÇlka textu
         and       cx,7fh                   ; dÇlka textu

         push      cs
         pop       es
         mov       di,offset Soubor1        ; soubor seznamu
         call      DekFile                  ; dek¢dov†n° jmÇna souboru
         jmp       short Start12

;         jnc       Start12                  ; soubor zad†n OK
;         mov       dx,offset SoubErr        ; chyba - nen° nic zad†no

; ------ chyba programu (chyba pamàti nebo chyba zad†n° souboru)

Start1:  push      cs
         pop       ds
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; ------ implicitn° p©°pona datovÇho souboru

Start12: mov       di,offset Soubor1
         call      TestExt                  ; test, zda je zad†na p©°pona
         jnc       Start13                  ; p©°pona je zad†na
         mov       bx,offset ExtDat         ; p©°pona DAT
         call      SetExt                   ; nastaven° p©°pony CS:BX

; ------ implicitn° jmÇno definián°ho souboru

Start13: push      ds
         push      cs
         pop       ds
         push      si
         push      cx
         mov       si,offset Soubor1
         mov       di,offset Soubor2
         mov       cx,128
         cld
         rep       movsb                    ; kopie do jmÇna definián°ho souboru
         pop       cx
         pop       si
         pop       ds
         mov       di,offset Soubor2
         mov       bx,offset ExtDef         ; p©°pona DEF
         call      SetExt                   ; nastaven° implicitn° p©°pony

; ------ dek¢dov†n° jmÇna souboru popisovaáe seznamu

         mov       di,offset Soubor2        ; soubor popisovaáe seznamu
         call      DekFile                  ; dek¢dov†n° jmÇna popisovaáe
         jc        Start14                  ; soubor nebyl zad†n
         or        byte ptr cs:[Param],20h  ; p©°znak zad†n° definián°ho souboru

; ------ nen°-li p©°pona zad†na, nastaven° implicitn° p©°pony DEF

Start14: mov       di,offset Soubor2
         call      TestExt                  ; m† definián° soubor p©°ponu ?
         jnc       Start15                  ; m† zadanou p©°ponu
         mov       bx,offset ExtDef         ; p©°pona DEF
         call      SetExt                   ; nastaven° implicitn° p©°pony

; ------ pokus o otev©en° souboru seznamu

Start15: push      cs
         pop       ds
         mov       dx,offset Soubor1        ; jmÇno souboru seznamu
         mov       ax,3d02h
         int       21h                      ; otev©en° souboru i pro z†pis
         jnc       Start2                   ; soubor otev©en OK
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru jen pro áten°
         jnc       Start20                  ; pro áten° jej lze otev©°t
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; pokus o vytvo©en° souboru
         jnc       Start2
         mov       dx,offset SoubErr2       ; chybnÇ zad†n° souboru
Start11: jmp       short Start1             ; soubor nelze ani vytvo©it

; ------ soubor otev©en OK

Start20: or        byte ptr cs:[Param],1    ; soubor nelze editovat (je R/O)
Start2:  mov       bx,ax                    ; identifik†tor souboru

; ------ naáten° souboru do pamàti

         mov       ds,cs:[SegDat]           ; adresa datovÇho bloku
         mov       bp,cs:[SizDat]           ; velikost datovÇho bloku

; ------ stanoven° velikosti bloku

Start32: mov       cx,0f00h                 ; velikost bloku v odstavc°ch
         cmp       cx,bp                    ; je vàt®° neë volnÇ m°sto ?
         jbe       Start33                  ; velikost je OK
         mov       cx,bp                    ; omezen° na volnÇ m°sto
Start33: mov       di,cx                    ; £schova velikosti bloku
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod velikosti na bajty

; ------ naáten° bloku dat do pamàti

         xor       dx,dx                    ; poá†teán° offset adresy
         mov       ah,3fh
         int       21h                      ; naáten° bloku do pamàti
         jc        Start36                  ; byla nàjak† chyba
         or        ax,ax                    ; jsou dal®° data ?
         jz        Start37                  ; nejsou dal®° data - konec souboru

; ------ nalezen° znaku EOF

         mov       dx,cx                    ; £schova poëadovanÇho poátu dat
         mov       cx,ax                    ; poáet naátenòch bajtñ
         xor       si,si                    ; ukazatel dat
         cld
Start34: lodsb                              ; naáten° znaku dat
         cmp       al,EOF                   ; je konec dat ?
         loopne    Start34                  ; nen° konec dat - dal®° znak
         jne       Start35                  ; nenalezen konec dat
         dec       si                       ; jinak je znak jië neplatnò
Start35: mov       byte ptr ds:[si],EOF     ; oznaáen° p©°padnÇho konce dat
         mov       ax,si                    ; skuteánò poáet naátenòch dat

; ------ zvò®en° á°taáe velikosti souboru

         add       word ptr cs:[SizFile],ax ; p©iáten° naátenòch dat LOW
         adc       word ptr cs:[SizFile+2],0 ; p©enos
         cmp       ax,dx                    ; budou je®tà dal®° data ?
         jb        Start38                  ; soubor je jië celò

; ------ zvò®en° adresy v datovÇm bloku

         mov       ax,ds                    ; segment datovÇho bloku
         add       ax,di                    ; zvò®en° adresy v datovÇm bloku
         mov       ds,ax
         sub       bp,di                    ; sn°ëen° ukazatele volnÇho m°sta
         jnz       Start32                  ; je je®tà m°sto - dal®° blok

; ------ chyba - soubor nelze editovat

Start36: or        byte ptr cs:[Param],1    ; nelze editovat - velkò nebo chyba
Start37: mov       byte ptr ds:[0],EOF      ; oznaáen° konce dat

; ------ uzav©en° souboru

Start38: mov       ah,3eh
         int       21h                      ; uzav©en° souboru
         push      cs
         pop       ds
         push      cs
         pop       es

; ------ otev©en° definián°ho souboru

         mov       ax,3d00h
         mov       dx,offset Soubor2
         int       21h                      ; otev©en° definián°ho souboru
         jnc       Start382
         test      byte ptr ds:[Param],20h  ; je definián° soubor zad†n ?
         jz        Start384                 ; definián° soubor nen° zad†n
         mov       dx,offset SoubErr3
         jmp       Start1                   ; chyba - soubor nenalezen
Start382:mov       bx,ax                    ; identifik†tor souboru

; ------ naáten° ©†dkñ definián°ho souboru

                                          ;* ©†dek nadpisu
         xor       si,si                    ; ukazatel dat ve vstupn°m bufferu
         mov       di,offset NadpBuff       ; buffer nadpisu
         call      DefLine                  ; naáten° ©†dku z definián°ho soub.
         mov       ds:[NadpNum],cl          ; poáet bajtñ nadpisu

                                          ;* ©†dek masky
         mov       di,offset MaskBuff       ; buffer masky
         call      DefLine                  ; naáten° ©†dku z definián°ho soub.
         mov       ds:[MaskNum],cl          ; poáet bajtñ masky

;                                          ;* inicializaán° data
;         mov       di,offset InitBuff       ; buffer inicializace ©†dku
;         call      DefLine                  ; naáten° ©†dku z definián°ho soub.
;         mov       ds:[InitNum],cl          ; poáet znakñ inicializaán°ch dat

; ------ uzav©en° definián°ho souboru

         mov       ah,3eh
         int       21h

; ------ oprava masky, nen°-li maska zad†na

Start384:cmp       byte ptr ds:[MaskNum],0  ; je maska zadan† ?
         jne       Start386                 ; maska je zadan†
         mov       di,offset MaskBuff       ; buffer masky
         mov       al,"#"                   ; inicializaán° bajt
         mov       cx,255                   ; dÇlka bufferu masky
         mov       ds:[MaskNum],cl          ; pln† dÇlka masky
         cld
         rep       stosb                    ; inicializace masky

; ------ stanoven° maxim†ln° poá†teán° pozice ©†dku

Start386:mov       cl,ds:[MaskNum]          ; dÇlka ©†dku dan† dÇlkou masky
         cmp       cl,ds:[NadpNum]          ; je nadpis del®° ?
         jae       Start387                 ; nadpis nen° del®°
         mov       cl,ds:[NadpNum]          ; dÇlku ©†dku uráuje nadpis
Start387:sub       cl,80                    ; maxim†ln° poá†teán° pozice
         jnc       Start388                 ; nen° podteáen°
         mov       cl,0                     ; jinak omezen°
Start388:mov       ds:[TopMax],cl           ; maxim†ln° poá†tek ©†dku

; ------ poá†teán° pozice kurzoru pro editaci

         mov       cx,255
         mov       di,offset MaskBuff       ; buffer masky
         cld
         mov       al,"#"                   ; hledanò znak
         repne     scasb                    ; nalezen° znaku
         jne       Start389                 ; nenalezen
         sub       di,offset MaskBuff+1     ; pozice prvn°ho znaku na ©†dku
         mov       ds:[EditPozL],di         ; pozice kurzoru na ©†dku
Start389:

; ------ spoáten° platnòch znakñ masky

;         mov       si,offset MaskBuff       ; buffer masky
;         mov       ch,0
;         mov       cl,ds:[MaskNum]          ; poáet znakñ ke kontrole
;         cld
;Start389:lodsb                              ; naáten° znaku
;         cmp       al,"#"                   ; je datovò symbol ?
;         jne       Start38a                 ; nen° datovò symbol
;         inc       byte ptr ds:[MaskChar]   ; zvò®en° poátu znakñ masky
;Start38a:loop      Start389                 ; test dal®°ho znaku

; ------ odmaz†n° zbytku textu n†povàdy, nen°-li moënost editace

         test      byte ptr ds:[Param],1    ; je z†kaz editace ?
         jz        Start4                   ; editace je povolena
         mov       di,offset HlpTxt0
         mov       cx,offset(HlpTxt1-HlpTxt0)
         cld
         mov       al," "
         rep       stosb                    ; vymaz†n° n†povàdy k editaci

; ------ instalace obsluh p©eru®en°

Start4:  mov       ax,2523h
         mov       dx,offset INT23
         int       21h                      ; obsluha INT 23h
         mov       ax,2524h
         mov       dx,offset INT24
         int       21h                      ; obsluha INT 24h
         mov       ax,3509h
         int       21h                      ; pñvodn° adresa obsluhy INT 09h
         mov       word ptr ds:[Old09],bx
         mov       word ptr ds:[Old09+2],es
         mov       dx,offset Int09
         mov       ax,2509h
         int       21h                      ; obsluha INT 09h

; ------ inicializace videom¢du

         call      DetCard                  ; detekce videokarty
         call      InitVMod                 ; inicializace videom¢du

; ------ oprava barev pro monochromatickò displej

         cmp       byte ptr ds:[AdrVRAM+3],0b8h
         je        Start5

         mov       byte ptr ds:[Barva1],7   ; bàën† barva textu
         mov       byte ptr ds:[Barva2],70h ; barva ©†dku s kurzorem
         mov       byte ptr ds:[Barva4],70h ; barva n†povàdy
         mov       byte ptr ds:[Barva5],0fh ; barva editovanÇho ©†dku

; ------ editace

Start5:
         jmp       Seznam


; ------ n†vrat z programu

INT23:
Main0:

         push      cs
         pop       ds

         call      Clear

         mov       dx,offset LicTxt
         mov       ah,9
         int       21h                      ; zobrazen° licenán°ho textu

         mov       ah,49h
         mov       es,ds:[SegDat]           ; datovò blok
         int       21h                      ; uvolnàn° datovÇho bloku

         lds       dx,ds:[Old09]
         mov       ax,2509h
         int       21h                      ; n†vrat INT 09h

         mov       ax,4c00h
         int       21h

INT24    PROC      FAR

         mov       al,0
         iret

INT24    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

Old09    dd        0                        ; pñvodn° obsluha INT 09h

Int09    PROC      FAR

; ------ p©°prava registrñ

         push      ax
         push      bx
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; datovò segment BIOS
         mov       bx,ds:[1ch]              ; ukazatel ukl†dac° adresy

; ------ ochrana p©ed zahlcen°m kl†vesnice

         mov       ax,bx                    ; souáasn† ukl†dac° adresa
         inc       ax
         inc       ax                       ; n†sleduj°c° ukl†dac° kl†vesa
         cmp       ax,3eh                   ; je konec bufferu ?
         jne       Int0901                  ; nen° konec bufferu
         mov       ax,1eh                   ; oprava na zaá†tek bufferu
Int0901: cmp       ax,ds:[1ah]              ; je rovno átec° adrese ?
         jne       Int090                   ; nebude je®tà zahlcen°
         cmp       bx,1eh                   ; je zaá†tek bufferu ?
         jne       Int0902                  ; nen° zaá†tek bufferu
         mov       bx,3eh                   ; oprava na konec bufferu
Int0902: dec       bx
         dec       bx                       ; sn°ëen° ukl†dac° adresy
         mov       ds:[1ch],bx              ; nov† ukl†dac° adresa

; ------ pñvodn° obsluha kl†vesnice

Int090:  pushf                              ; simulace vol†n° INT xx
         call      dword ptr cs:[Old09]     ; pñvodn° obsluha INT 09h

; ------ n†vrat registrñ

Int099:  pop       ds
         pop       bx
         pop       ax
         iret

Int09    ENDP

; *****************************************************************************
;
;                          z†kladn° obsluha
;
; *****************************************************************************
;˛
Seznam:
         push      cs
         pop       es
         push      cs
         pop       ds

; ------ zobrazen° z†kladn° n†povàdy

Seznam1: mov       si,offset HlpTxt
         call      DispHlp                  ; zobrazen° z†kladn° n†povàdy

; ------ zobrazen° nadpisu a editovanÇ obrazovky

Seznam2: call      DispNadp                 ; zobrazen° nadpisu
         call      DispAll                  ; zobrazen° celÇ str†nky

; ------ vstup znaku z kl†vesnice

Seznam3: call      KurzOff                  ; vypnut° kurzoru
         call      InpChr                   ; vstup z kl†vesnice

         call      JumpBX

         dw        5000h,SDolu              ; dolñ
         dw        4800h,SNahoru            ; nahoru
         dw        4700h,SHome              ; HOME
         dw        4f00h,SEnd               ; END
         dw        8400h,SCPgUp             ; ^Page Up
         dw        7600h,SCPgDn             ; ^Page Down
         dw        4900h,SPgUp              ; Page Up
         dw        5100h,SPgDn              ; Page Down
         dw        32,Hledej                ; MEZERA
         dw        4b00h,SLeft              ; kurzor vlevo
         dw        4d00h,SRght              ; kurzor vpravo
         dw        0ch,HledDale             ; dal®° hled†n° textu ^L
         dw        7300h,SCLeft             ; ^vlevo
         dw        7400h,SCRght             ; ^vpravo

         dw        0dh,EditEnt              ; ENTER editace
         dw        5200h,EditIns            ; INSERT vkl†d†n°
         dw        5300h,SDelete            ; DELETE zru®en° ©†dku
         dw        19h,SDelete              ; ^Y zru®en° ©†dku

         dw        1bh,Main0                ; ESC
         dw        0,Seznam3

; -----------------------------------------------------------------------------
;        zru®en° aktivn°ho ©†dku DELETE
; -----------------------------------------------------------------------------

SDelete: test      byte ptr ds:[Param],1    ; z†kaz editace ?
         jnz       SDelete2                 ; je z†kaz editace
         call      DelLine                  ; zru®en° ©†dku
         call      UlozFil                  ; uloëen° souboru
SDelete2:jmp       Seznam1

; -----------------------------------------------------------------------------
;        zru®en° ©†dku (CY=operace p©eru®ena)
; -----------------------------------------------------------------------------

DelLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      si

; ------ zobrazen° vòzvy

         mov       si,offset HlpDel
         call      DispHlp                  ; zobrazen° n†povàdy

; ------ vypr†zdnàn° bufferu kl†vesnice a vstup znaku

         call      FlushChr                 ; vypr†zdnàn° bufferu kl†vesnice
         call      InpChr                   ; áek†n° na vstup znaku
         cmp       bl,"a"
         je        DelLine1
         cmp       bl,"A"
         stc
         jne       DelLine9

; ------ zji®tàn° dÇlky ©†dku

DelLine1:push      ds
         mov       si,word ptr ds:[AdrKurz] ; offset ©†dku
         mov       ds,word ptr ds:[AdrKurz+2] ; segment ©†dku
         xor       cx,cx                    ; á°taá dÇlky ©†dku
DelLine2:mov       al,ds:[si]               ; znak
         cmp       al,EOF                   ; konec souboru ?
         je        DelLine5                 ; je konec souboru
         cmp       al,LF
         je        DelLine4                 ; konec ©†dku
         inc       si                       ; zvò®en° ukazatele v souboru
         jnz       DelLine3                 ; nen° p©eteáen° segmentu
         mov       ax,ds
         add       ax,1000h                 ; posun adresy segmentu
         mov       ds,ax
DelLine3:inc       cx                       ; zvò®en° á°taáe dÇlky ©†dku
         jmp       short DelLine2           ; dal®° znak
DelLine4:inc       cx                       ; p©iáten° posledn°ho znaku LF
DelLine5:pop       ds

; ------ zru®en° ©†dku z bufferu

         clc
         jcxz      DelLine9                 ; nen° nic k ru®en°
         push      di
         push      es
         mov       di,word ptr ds:[AdrKurz] ; offset ©†dku
         mov       es,word ptr ds:[AdrKurz+2] ; segment ©†dku
         call      DelDat                   ; zru®en° dat z bufferu
         pop       es
         pop       di
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru
         call      DispAll

; ------ n†vrat registrñ

DelLine9:pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DelLine  ENDP

; -----------------------------------------------------------------------------
;        zaá†tek ©†dku HOME
; -----------------------------------------------------------------------------

SHome:   mov       byte ptr ds:[TopPoz],0
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        konec ©†dku END
; -----------------------------------------------------------------------------

SEnd:    mov       al,ds:[TopMax]
         mov       ds:[TopPoz],al
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

SLeft:   cmp       byte ptr ds:[TopPoz],0
         je        SLeft2
         dec       byte ptr ds:[TopPoz]
SLeft2:  jmp       Seznam2

; -----------------------------------------------------------------------------
;        ^kurzor vlevo
; -----------------------------------------------------------------------------

SCLeft:  cmp       byte ptr ds:[TopPoz],0
         je        SCLeft9

SCLeft1: dec       byte ptr ds:[TopPoz]
         cmp       byte ptr ds:[TopPoz],0
         je        SCLeft9
         mov       bl,ds:[TopPoz]
         mov       bh,0
         cmp       byte ptr ds:[bx+MaskBuff-1],"#"
         je        SCLeft1
         cmp       byte ptr ds:[bx+MaskBuff],"#"
         jne       SCLeft1

SCLeft9: jmp       Seznam2

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

SRght:   mov       al,ds:[TopMax]
         cmp       al,ds:[TopPoz]
         jbe       SRght2
         inc       byte ptr ds:[TopPoz]
SRght2:  jmp       Seznam2

; -----------------------------------------------------------------------------
;        ^kurzor vpravo
; -----------------------------------------------------------------------------

SCRght:  mov       al,ds:[TopMax]
         cmp       al,ds:[TopPoz]
         jbe       SCRght9

         inc       byte ptr ds:[TopPoz]

         mov       bl,ds:[TopPoz]
         mov       bh,0
         cmp       byte ptr ds:[bx+MaskBuff-1],"#"
         je        SCRght
         cmp       byte ptr ds:[bx+MaskBuff],"#"
         jne       SCRght

SCRght9: jmp       Seznam2

; -----------------------------------------------------------------------------
;        zaá†tek ^Page Up
; -----------------------------------------------------------------------------

SCPgUp:  mov       byte ptr ds:[TopPoz],0
         call      CPageUp
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        zaá†tek ^Page Up
; -----------------------------------------------------------------------------

CPageUp: push      si
         push      dx

         mov       dx,ds:[SegDat]
         xor       si,si
         mov       word ptr ds:[AdrTop],si
         mov       word ptr ds:[AdrTop+2],dx
         mov       ds:[TopRad],si
         mov       word ptr ds:[AdrKurz],si
         mov       word ptr ds:[AdrKurz+2],dx
         mov       ds:[Kurzor],si

         pop       dx
         pop       si
         ret

; -----------------------------------------------------------------------------
;        konec ^Page Down
; -----------------------------------------------------------------------------

SCPgDn:
         mov       byte ptr ds:[TopPoz],0
         call      CPageDn
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        konec ^Page Down
; -----------------------------------------------------------------------------

CPageDn: push      si
         push      dx
         push      bx

CPageDn1:call      NextKurz                 ; nalezen° dal®°ho ©†dku kurzoru
         jnc       CPageDn1                 ; dal®° ©†dek
         mov       word ptr ds:[AdrTop],si ; je to tÇë poá†tek str†nky
         mov       word ptr ds:[AdrTop+2],dx
         mov       bx,ds:[Kurzor]
         mov       ds:[TopRad],bx

         xor       cx,cx
         mov       cl,ds:[MaxRow]
         dec       cx
         dec       cx                       ; poáet posunñ
CPageDn2:call      PredTop                  ; p©edch†zej°c° ©†dek
         loop      CPageDn2

         pop       bx
         pop       dx
         pop       si
         ret

; -----------------------------------------------------------------------------
;        str†nka dolñ
; -----------------------------------------------------------------------------

SPgDn:   call      PageDn
         jmp       Seznam2                  ; v®echny ©†dky OK

; -----------------------------------------------------------------------------
;        str†nka dolñ
; -----------------------------------------------------------------------------

PageDn:  push      cx

         xor       cx,cx
         mov       cl,ds:[MaxRow]
         dec       cx
         dec       cx                       ; poáet posunñ

PageDn1: call      NextTop                  ; posun poá†tku
         jc        PageDn2                  ; je konec - udàl† se funkce END
         call      NextKurz                 ; posun kurzoru
         loop      PageDn1                  ; dal®° ©†dek

         call      NextTop
         jc        PageDn2

         call      PredTop
         jmp       short PageDn3

PageDn2: call      CPageDn                  ; konec seznamu

PageDn3: pop       cx
         ret

; -----------------------------------------------------------------------------
;        str†nka nahoru
; -----------------------------------------------------------------------------

SPgUp:   call      PageUp
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        str†nka nahoru
; -----------------------------------------------------------------------------

PageUp:  push      cx
         push      di

         xor       cx,cx
         mov       cl,ds:[MaxRow]
         dec       cx
         dec       cx                       ; poáet posunñ
         mov       di,cx                    ; £schova dÇlky str†nky
PageUp1: call      PredTop                  ; posun poá†tku
         jc        PageUp2
         call      PredKurz                 ; posun kurzoru
         loop      PageUp1

PageUp2: cmp       cx,di                    ; byl nàjakò posun ?
         jne       PageUp3
         call      CPageUp                  ; nebyl posun - je zaá†tek seznamu

PageUp3: pop       di
         pop       cx
         ret

; -----------------------------------------------------------------------------
;        kurzor dolñ
; -----------------------------------------------------------------------------

SDolu:   call      NextKurz                 ; nalezen° dal®°ho ©†dku kurzoru
         jc        SDolu9                   ; nen° dal®° ©†dek

; ------ kontrola p©eteáen° konce displeje

         mov       bx,ds:[Kurzor]
         sub       bx,ds:[TopRad]
         mov       al,ds:[Radku]
         sub       al,2
         cmp       bl,al
         jb        SDolu9
         call      NextTop                  ; dal®° ©†dek poá†tku
SDolu9:
         jmp       Seznam2

; -----------------------------------------------------------------------------
;        kurzor nahoru
; -----------------------------------------------------------------------------

SNahoru: call      PredKurz                 ; p©edchoz° ©†dek kurzoru
         jc        SNahoru9                 ; nen° dal®° ©†dek

; ------ kontrola p©eteáen° zaá†tku displeje

         mov       bx,ds:[Kurzor]
         cmp       bx,ds:[TopRad]
         jae       SNahoru9

         mov       word ptr ds:[AdrTop],si ; je to tÇë poá†tek displeje
         mov       word ptr ds:[AdrTop+2],dx
         mov       word ptr ds:[TopRad],bx

SNahoru9:
         jmp       Seznam2


; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek dolñ (vòstup DX:SI=souáasn† adresa, CY=nen°)
; -----------------------------------------------------------------------------

NextKurz PROC      NEAR

         mov       si,word ptr ds:[AdrKurz]
         mov       dx,word ptr ds:[AdrKurz+2]
         call      NextLine                 ; nalezen° dal®°ho ©†dku
         jc        NxtKurz2                 ; nen° dal®° ©†dek
         mov       word ptr ds:[AdrKurz],si
         mov       word ptr ds:[AdrKurz+2],dx
         inc       word ptr ds:[Kurzor]
NxtKurz2:ret

NextKurz ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek nahoru (vòstup DX:SI=souáasnò ukazatel, CY=nen°)
; -----------------------------------------------------------------------------

PredKurz PROC      NEAR

         mov       si,word ptr ds:[AdrKurz]
         mov       dx,word ptr ds:[AdrKurz+2]
         call      PredLine                 ; nalezen° dal®°ho ©†dku
         jc        PreKurz2                 ; nen° dal®° ©†dek
         mov       word ptr ds:[AdrKurz],si
         mov       word ptr ds:[AdrKurz+2],dx
         dec       word ptr ds:[Kurzor]
PreKurz2:ret

PredKurz ENDP

; -----------------------------------------------------------------------------
;        posun poá†tku o ©†dek dolñ (vòstup DX:SI=souáasnò ukazatel, CY=nen°)
; -----------------------------------------------------------------------------

NextTop  PROC      NEAR

         mov       si,word ptr ds:[AdrTop]
         mov       dx,word ptr ds:[AdrTop+2]
         call      NextLine                 ; nalezen° dal®°ho ©†dku
         jc        NextTop2                 ; nen° dal®° ©†dek
         mov       word ptr ds:[AdrTop],si
         mov       word ptr ds:[AdrTop+2],dx
         inc       word ptr ds:[TopRad]
NextTop2:ret

NextTop  ENDP

; -----------------------------------------------------------------------------
;        posun poá†tku o ©†dek nahoru (vòstup DX:SI=souáasnò ukazatel, CY=nen°)
; -----------------------------------------------------------------------------

PredTop  PROC      NEAR

         mov       si,word ptr ds:[AdrTop]
         mov       dx,word ptr ds:[AdrTop+2]
         call      PredLine                 ; nalezen° dal®°ho ©†dku
         jc        PredTop2                 ; nen° dal®° ©†dek
         mov       word ptr ds:[AdrTop],si
         mov       word ptr ds:[AdrTop+2],dx
         dec       word ptr ds:[TopRad]
PredTop2:ret

PredTop  ENDP

; -----------------------------------------------------------------------------
;        nalezen° dal®°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=adresa v bufferu
; VùSTUP:DX:SI=adresa dal®°ho ©†dku v bufferu
;        CY=nen° dal®° ©†dek (je jië konec textu)
; -----------------------------------------------------------------------------
; zniáenò registr: AL
; -----------------------------------------------------------------------------

NextLine PROC      NEAR

; ------ £schova registrñ

         push      ds

; ------ kontrola, zda je jië konec souboru (tj. zda bude dal®° ©†dek)

         mov       ds,dx                    ; segment adresy
         cmp       byte ptr ds:[si],EOF     ; je konec souboru ?
         stc                                ; p©°znak konce souboru
         je        NextLin9                 ; konec - nen° dal®° ©†dek

; ------ kontrola, zda je jië konec souboru

NextLin2:mov       al,ds:[si]               ; n†sleduj°c° p©ipravenò znak
         cmp       al,EOF                   ; je jië konec souboru ?
         je        NextLin9                 ; je jië konec souboru

; ------ zvò®en° adresy v souboru

         inc       si                       ; zvò®en° adresy v souboru
         jnz       NextLin3                 ; nen° p©eteáen° segmentu
         add       dx,1000h                 ; zvò®en° adresy segmentu
         mov       ds,dx                    ; nov† adresa segmentu

; ------ kontrola, zda je jië konec ©†dku

NextLin3:cmp       al,LF                    ; byl to konec ©†dku ?
         jne       NextLin2                 ; nen° konec ©†dku - dal®° znak

; ------ n†vrat registrñ

NextLin9:pop       ds
         ret

NextLine ENDP

; -----------------------------------------------------------------------------
;        nalezen° p©edchoz°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=adresa v souboru
; VùSTUP:DX:SI=adresa p©edchoz°ho ©†dku
;        CY=nen° dal®° ©†dek (je jië zaá†tek textu)
; -----------------------------------------------------------------------------

PredLine PROC      NEAR

; ------ £schova registrñ

         push      ds

; ------ kontrola, zda je jië zaá†tek souboru (tj. zda bude dal®° ©†dek)

         or        si,si
         jnz       PredLin1                 ; ukazatel nen° 0
         sub       dx,100h
         mov       si,1000h
PredLin1:mov       ds,dx                    ; segment adresy
         dec       si
         cmp       byte ptr ds:[si],EOF     ; je jië zaá†tek souboru ?
         stc                                ; p©°znak zaá†tku souboru
         je        PredLin8                 ; je jië zaá†tek souboru

; ------ kontrola, zda je zaá†tek souboru

PredLin2:cmp       byte ptr ds:[si],EOF     ; je zaá†tek souboru ?
         je        PredLin8                 ; je jië zaá†tek souboru

; ------ sn°ëen° ukazatele v souboru

         or        si,si                    ; bude p©eteáen° segmentu ?
         jnz       PredLin3                 ; nebude p©eteáen° segmentu
         sub       dx,100h                  ; posun segmentu adresy
         mov       si,1000h
         mov       ds,dx                    ; novò segment adresy
PredLin3:dec       si                       ; sn°ëen° ukazatele v souboru

; ------ kontrola, zda je jië zaá†tek p©edchoz°ho ©†dku

         cmp       byte ptr ds:[si],LF      ; je jië zaá†tek ©†dku ?
         jne       PredLin2                 ; nen° zaá†tek - dal®° znak

; ------ n†vrat posledn° adresy

PredLin8:pushf
         inc       si                       ; n†vrat posledn° adresy
         jnz       PredLin9
         add       dx,1000h                 ; posun segmentovÇ adresy
PredLin9:popf

; ------ n†vrat registrñ

         pop       ds
         ret

PredLine ENDP

; *****************************************************************************
;
;                             Obsluha hled†n°
;
; *****************************************************************************
;˛
Hledej:
         push      ds
         pop       es
         mov       di,offset HledBuf
         mov       cx,MAXHLED
         cld
         mov       al," "
         rep       stosb
         mov       byte ptr ds:[HledNum],0

Hledej0: call      DispNadp                 ; zobrazen° nadpisu
         call      DispAll

; ------ zobrazen° textu

Hledej1: mov       si,offset HlpTxt2
         call      DispHlp                  ; zobrazen° ©†dku s n†povàdou

; ------ zobrazen° kurzoru

         mov       dl,offset(HledBuf-HlpTxt2)
         add       dl,byte ptr ds:[HledNum]
         mov       dh,ds:[MaxRow]
         call      SetKurz                  ; nastaven° pozice kurzoru

; ------ áek†n° na zad†n° dal®°ho znaku

Hledej2: call      InpChr

         call      JumpBX

         dw        8,Hledej4                ; BS
         dw        4b00h,Hledej5            ; kurzor vlevo
         dw        4d00h,Hledej6            ; kurzor vpravo
         dw        5300h,Hledej4            ; DELETE
         dw        1bh,Seznam1              ; p©eru®en° hled†n° ESC
         dw        0dh,Hledej7              ; vyhled†n° textu ENTER
         dw        5000h,Hledej8            ; hled†n° textu vp©ed
         dw        4800h,Hledej9            ; hled†n° textu zpàt
         dw        8400h,HledejA            ; ^Page Up
         dw        7600h,HledejB            ; ^Page Down
         dw        5100h,HledejC            ; Page Down
         dw        4900h,HledejD            ; Page Up

         dw        0,Hledej3

; ------ zad†n dal®° znak

Hledej3: cmp       bl,0
         je        Hledej2
         cmp       bl,10
         je        Hledej2                  ; LF
         cmp       bl,1ah
         je        Hledej2                  ; EOF

; ------ uloëen° znaku BL do bufferu

         mov       si,ds:[HledNum]          ; poáet znakñ v bufferu
         cmp       si,MAXHLED               ; je jië maxim†ln° poáet znakñ ?
         jae       Hledej2                  ; je jië maxim†ln° poáet znakñ
         cmp       bl,"a"
         jb        Hledej11
         cmp       bl,"z"
         ja        Hledej11
         sub       bl,32
Hledej11:mov       ds:[si+HledBuf],bl       ; uloëen° znaku do bufferu
         inc       byte ptr ds:[HledNum]    ; zvò®en° poátu znakñ v bufferu
Hledej14:jmp       short Hledej1            ; dal®° znak

; ------ zru®en° posledn°ho znaku v bufferu

Hledej4: mov       si,ds:[HledNum]          ; poáet znakñ v bufferu
         or        si,si                    ; je nàco v bufferu ?
         jz        Hledej2                  ; v bufferu nic nen°
         mov       byte ptr ds:[si+HledBuf-1]," " ; vymaz†n° znaku
         dec       byte ptr ds:[HledNum]    ; sn°ëen° poátu znakñ v bufferu
         jmp       short Hledej14

; ------ kurzor vlevo

Hledej5: cmp       byte ptr ds:[TopPoz],0
         je        Hledej14
         dec       byte ptr ds:[TopPoz]
Hledej52:jmp       Hledej0

; ------ kurzor vpravo

Hledej6: mov       al,ds:[TopMax]
         cmp       al,ds:[TopPoz]
         jbe       Hledej14
         inc       byte ptr ds:[TopPoz]
         jmp       short Hledej52

; ------ pokraáov†n° v hled†n° ^L

HledDale:mov       si,word ptr ds:[AdrKurz]
         mov       dx,word ptr ds:[AdrKurz+2]
         mov       bx,ds:[Kurzor]
         call      NextLine
         jc        Hledej79
         inc       bx
         jmp       short Hledej72

; ------ hled†n° textu ENTER

Hledej7: xor       si,si
         mov       dx,ds:[SegDat]
         xor       bx,bx
Hledej72:cmp       byte ptr ds:[HledNum],0
         je        Hledej79
         call      KurzOff
         call      HledInd
         call      HledNxt                  ; hled†n° textu
         jnc       Hledej76

         call      FlushChr
         jmp       short Hledej79

Hledej76:call      HledSet                  ; nastaven° kurzoru po hled†n°

Hledej79:jmp       Seznam1

; ------ hled†n° textu vp©ed

Hledej8: mov       si,word ptr ds:[AdrKurz]
         mov       dx,word ptr ds:[AdrKurz+2]
         mov       bx,ds:[Kurzor]
         call      NextLine
         jc        Hledej87
         inc       bx
         cmp       byte ptr ds:[HledNum],0
         je        Hledej86

         call      KurzOff
         call      HledInd
         call      HledNxt                  ; hled†n° textu
         jc        Hledej87
Hledej86:call      HledSet                  ; nastaven° kurzoru po hled†n°
         jmp       short Hledej88

Hledej87:call      FlushChr
Hledej88:jmp       Hledej0

; ------ hled†n° textu zpàt

Hledej9: mov       si,word ptr ds:[AdrKurz]
         mov       dx,word ptr ds:[AdrKurz+2]
         mov       bx,ds:[Kurzor]

         cmp       byte ptr ds:[HledNum],0
         jne       Hledej92

         call      PredLine
         jc        Hledej97
         dec       bx
         jmp       short Hledej94

Hledej92:call      KurzOff
         call      HledInd
         call      HledPre                  ; hled†n° textu
         jc        Hledej97

Hledej94:call      HledSet                  ; nastaven° kurzoru po hled†n°
         jmp       short Hledej98

Hledej97:call      FlushChr
Hledej98:jmp       Hledej0

; -----------------------------------------------------------------------------
;        zaá†tek ^Page Up
; -----------------------------------------------------------------------------

HledejA: mov       byte ptr ds:[TopPoz],0
         call      CPageUp
         jmp       Hledej0

; -----------------------------------------------------------------------------
;        konec ^Page Down
; -----------------------------------------------------------------------------

HledejB: mov       byte ptr ds:[TopPoz],0
         call      CPageDn
         jmp       Hledej0

; -----------------------------------------------------------------------------
;        str†nka dolñ
; -----------------------------------------------------------------------------

HledejC: call      PageDn
         jmp       Hledej0                  ; v®echny ©†dky OK

; -----------------------------------------------------------------------------
;        str†nka nahoru
; -----------------------------------------------------------------------------

HledejD: call      PageUp
         jmp       Hledej0

; *****************************************************************************
;                              HledInd
;                          indikace hled†n°
; -----------------------------------------------------------------------------
; *****************************************************************************

HledInd  PROC      NEAR

         push      ax
         push      dx
         mov       dh,ds:[MaxRow]
         mov       dl,79
         mov       ah,ds:[Barva4]
         mov       al,"*"
         call      Disp1Chr
         pop       dx
         pop       ax
         ret

HledInd  ENDP

; *****************************************************************************
;                                HledSet
;                     nastaven° kurzoru po hled†n°
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=nov† pozice kurzoru
;        BX=novò ©†dek kurzoru
; *****************************************************************************

HledSet  PROC      NEAR

; ------ nastaven° novòch parametrñ kurzoru

         mov       word ptr ds:[AdrKurz],si
         mov       word ptr ds:[AdrKurz+2],dx
         mov       ds:[Kurzor],bx

; ------ kontrola, zda je kurzor uvnit© obrazovky

         mov       cx,bx                    ; kurzor
         sub       cx,ds:[TopRad]           ; vzd†lenost od poá†tku
         jae       HledSet1                 ; kurzor je OK za poá†tkem
         xor       cx,cx
HledSet1:cmp       ch,0
         je        HledSet2
         mov       cl,100
HledSet2:mov       ch,ds:[Radku]
         sub       ch,3
         cmp       cl,ch
         jbe       HledSet3
         mov       cl,ch

; ------ uráenò poá†tek obrazovky

HledSet3:mov       word ptr ds:[AdrTop],si
         mov       word ptr ds:[AdrTop+2],dx
         mov       ds:[TopRad],bx
         mov       ch,0
         jcxz      HledSet9
HledSet4:call      PredTop
         loop      HledSet4
HledSet9:
         ret

HledSet  ENDP

; *****************************************************************************
;                              HledNxt
;         hled†n° dal®°ho ©†dku (dÇlka hledanÇho textu nesm° bòt = 0 !)
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=adresa poá†teán°ho ©†dku k hled†n°
;        BX=souáasnÇ á°slo ©†dku
; VùSTUP:DX:SI=ukazatel nalezenÇho ©†dku (nebo konce souboru)
;        BX=á°slo nalezenÇho ©†dku
;        CY=dal®° ©†dek nenalezen
; *****************************************************************************

HledNxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       es
         mov       ds,dx
         mov       ch,0
         mov       ah,byte ptr cs:[HledNum] ; poáet bajtñ textu
         cld

; ------ kontrola, zda je jië konec souboru

HledNxt1:cmp       byte ptr ds:[si],EOF     ; je jië konec souboru ?
         stc                                ; p©°znak - text nenalezen
         je        HledNxt9                 ; je jië konec souboru

; ------ normalizace adresy

         cmp       si,0f000h                ; maxim†ln° adresa
         jbe       HledNxt2                 ; adresa je OK
         sub       si,0e000h                ; posun offsetu
         add       dx,0e00h                 ; posun segmentu
         mov       ds,dx

; ------ porovn†n° jednÇ adresy

HledNxt2:push      si

         mov       di,offset HledBuf        ; buffer s textem
         mov       cl,ah                    ; poáet bajtñ textu
HledNxt3:lodsb                              ; naáten° znaku textu
         cmp       al,"a"
         jb        HledNxt4
         cmp       al,"z"
         ja        HledNxt4
         sub       al,32                    ; korekce na velkÇ p°smeno
HledNxt4:scasb                              ; porovn†n° s hledanòm znakem
         loope     HledNxt3                 ; test dal®°ho znaku

         pop       si
         je        HledNxt7                 ; ©†dek nalezen OK

; ------ zvò®en° adresy v souboru

         lodsb                              ; zvò®en° ukazatele v textu
         cmp       al,10                    ; je novò ©†dek ?
         jne       HledNxt1                 ; nen° novò ©†dek
         inc       bx                       ; zvò®en° á°sla ©†dku
         jmp       short HledNxt1

; ------ ©†dek nalezen - nalezen° zaá†tku ©†dku

HledNxt7:or        si,si
         jnz       HledNxt8                 ; nebude p©eteáen° segmentu
         add       si,200h
         sub       dx,20h
         mov       ds,dx
HledNxt8:cmp       byte ptr ds:[si-1],LF
         je        HledNxt9                 ; je zaá†tek ©†dku
         dec       si
         jmp       short HledNxt7

; ------ n†vrat registrñ

HledNxt9:pop       es
         pop       ds
         pop       di
         pop       cx
         pop       ax
         ret

HledNxt  ENDP

; *****************************************************************************
;                              HledPre
;         hled†n° p©edchoz°ho ©†dku (dÇlka hledanÇho textu nesm° bòt = 0 !)
; -----------------------------------------------------------------------------
; VSTUP: DX:SI=ukazatel poá†teán°ho ©†dku k hled†n°
;        BX=souáasnÇ á°slo ©†dku
;        DS=datovò segment
; VùSTUP:DX:SI=ukazatel nalezenÇho ©†dku
;        BX=á°slo nalezenÇho ©†dku
;        CY=dal®° ©†dek nenalezen
; *****************************************************************************

HledPre  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       es
         mov       ds,dx                    ; segment adresy v bufferu
         mov       ah,byte ptr cs:[HledNum] ; poáet bajtñ textu
         mov       ch,0
         cld

; ------ £vodn° normalizace adresy

         cmp       si,0f000h                ; maxim†ln° adresa
         jbe       HledPre1                 ; adresa je OK
         sub       si,2000h                 ; posun offsetu
         add       dx,200h                  ; posun segmentu
         mov       ds,dx

; ------ normalizace adresy

HledPre1:cmp       si,1000h
         jae       HledPre2
         add       si,1000h
         sub       dx,100h
         mov       ds,dx

; ------ kontrola, zda je jië zaá†tek souboru

HledPre2:cmp       byte ptr ds:[si-1],EOF   ; je jië zaá†tek souboru ?
         stc
         je        HledPre9                 ; je jië zaá†tek souboru

; ------ nastaven° na dal®° znak

         dec       si                       ; sn°ëen° ukazatele v textu
         cmp       byte ptr ds:[si],10      ; je novò ©†dek ?
         jne       HledPre3                 ; nen° novò ©†dek
         dec       bx                       ; sn°ëen° á°sla ©†dku

; ------ porovn†n° jednÇ adresy

HledPre3:push      si

         mov       di,offset HledBuf        ; buffer s textem
         mov       cl,ah                    ; poáet bajtñ textu
HledPre4:lodsb                              ; naáten° znaku textu
         cmp       al,"a"
         jb        HledPre5
         cmp       al,"z"
         ja        HledPre5
         sub       al,32
HledPre5:scasb                              ; porovn†n° s hledanòm znakem
         loope     HledPre4                 ; test dal®°ho znaku

         pop       si
         jne       HledPre1                 ; nen° shoda - dal®° znak

; ------ ©†dek nalezen - nalezen° zaá†tku ©†dku

HledPre7:or        si,si
         jnz       HledPre8                 ; nebude p©eteáen° segmentu
         add       si,200h
         sub       dx,20h
         mov       ds,dx
HledPre8:cmp       byte ptr ds:[si-1],LF
         je        HledPre9                 ; je zaá†tek ©†dku
         cmp       byte ptr ds:[si-1],EOF
         je        HledPre9                 ; je zaá†tek souboru
         dec       si
         jmp       short HledPre7

; ------ n†vrat registrñ

HledPre9:pop       es
         pop       ds
         pop       di
         pop       cx
         pop       ax
         ret

HledPre  ENDP

; *****************************************************************************
;
;                              Obsluha editace
;
; *****************************************************************************

EditIns: test      byte ptr ds:[Param],1    ; povolena editace ?
         jz        EditIns0                 ; editace je povolena OK
         jmp       Seznam
EditIns0:or        byte ptr ds:[Param],10h  ; reëim vkl†d†n°
         mov       di,word ptr ds:[AdrKurz] ; offset ©†dku
         mov       es,word ptr ds:[AdrKurz+2] ; segment ©†dku
         mov       cx,2                     ; poáet vkl†danòch bajtñ
         call      InsDat                   ; vloëen° 2 bajtñ
         jc        Edit                     ; je nàjak† chyba
         mov       byte ptr es:[di],CR
         inc       di
         jnz       EditIns1
         mov       ax,es
         add       ax,1000h
         mov       es,ax
EditIns1:mov       byte ptr es:[di],LF
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru
         jmp       short Edit

EditEnt: test      byte ptr ds:[Param],1    ; povolena editace ?
         jz        EditEnt0                 ; editace je povolena OK
         jmp       Seznam
EditEnt0:and       byte ptr ds:[Param],not 10h ; zru®en° reëimu vkl†d†n°

;˛

Edit:    and       byte ptr ds:[Param],not 8 ; zru®en° p©°znaku modifikace ©†dku

; ------ oprava kurzoru, je-li p©ed zaá†tkem ©†dku

Edit012: mov       al,ds:[TopPoz]           ; poá†teán° pozice ©†dku
         cmp       al,byte ptr ds:[EditPozL] ; je kurzor OK ?
         jbe       Edit016                  ; kurzor je OK
         call      EdRight                  ; posun kurzoru vpravo
         jnc       Edit012

; ------ oprava kurzoru, je-li za koncem ©†dku

Edit016: mov       al,ds:[TopPoz]           ; poá†teán° pozice ©†dku
         add       al,80                    ; koncov† pozice ©†dku
         cmp       al,byte ptr ds:[EditPozL] ; je kurzor OK ?
         ja        Edit018                  ; kurzor je OK
         call      EdLeft                   ; posun kurzoru vlevo
         jnc       Edit016

; ------ vymaz†n° editaán°ho bufferu

Edit018: push      cs
         pop       es
         mov       di,offset EditBuff       ; editaán° buffer
         mov       cx,255                   ; dÇlka editaán°ho bufferu
         cld
         mov       al," "                   ; mazac° znak
         rep       stosb                    ; vymaz†n° bufferu

; ------ kopie editovanÇho ©†dku do bufferu

         push      ds
         mov       di,offset EditBuff       ; editaán° buffer
         mov       cl,255                   ; maxim†ln° dÇlka ©†dku
         mov       si,word ptr ds:[AdrKurz] ; adresa aktivn°ho ©†dku
         mov       ds,word ptr ds:[AdrKurz+2] ; segment adresy aktivn°ho ©†dku
Edit12:  lodsb                              ; znak k p©enosu
         or        si,si                    ; je p©eteáen° segmentu ?
         jnz       Edit13                   ; nen° p©eteáen° segmentu
         mov       dx,ds
         add       dx,1000h                 ; posun segmentu adresy
         mov       ds,dx
Edit13:  cmp       al,CR
         je        Edit12                   ; znak CR se ignoruje
         cmp       al,LF                    ; konec ©†dku ?
         je        Edit14                   ; konec ©†dku
         cmp       al,EOF
         je        Edit14                   ; konec souboru
         stosb                              ; uloëen° znaku do bufferu
         loop      Edit12                   ; p©enos dal®°ho znaku
Edit14:  pop       ds
         or        byte ptr ds:[Param],4    ; p©°znak editace ©†dku

; ------ zobrazen° v®eho

Edit2:   call      EdKor                    ; korekce poá†tku ©†dku
         call      DispAll
         call      DispNadp                 ; zobrazen° nadpisu
         mov       si,offset HlpTxt3
         call      DispHlp

; ------ zobrazen° pozice kurzoru

         push      dx
         mov       dl,byte ptr ds:[EditPozL] ; pozice kurzoru na ©†dku
         sub       dl,byte ptr ds:[TopPoz]  ; odeáten° poá†tku ©†dku
         mov       dh,byte ptr ds:[Kurzor]  ; ©†dek s kurzorem
         sub       dh,byte ptr ds:[TopRad]  ; offset od poá†tku
         inc       dh
         call      SetKurz                  ; zobrazen° kurzoru
         pop       dx

; ------ vstup znaku z kl†vesnice

Edit28:  call      InpChr
         call      JumpBX

         dw        4b00h,EditLft            ; kurzor vlevo
         dw        4d00h,EditRgh            ; kurzor vpravo
         dw        4700h,EditHome           ; HOME
         dw        4f00h,EditEnd            ; END
         dw        5000h,EdiDolu            ; dolñ
         dw        4800h,EdiNah             ; nahoru
         dw        9,EditTab                ; TAB - dal®° poloëka
         dw        0f00h,EditSTab           ; *TAB - p©edchoz° poloëka
         dw        4900h,EditPgUp           ; PGUP str†nka nahoru
         dw        5100h,EditPgDn           ; PGDN str†nka dolñ
         dw        8400h,EdiCPgUp           ; ^PGUP zaá†tek
         dw        7600h,EdiCPgDn           ; ^PGDN konec
         dw        7700h,EdiCHome           ; ^HOME
         dw        7500h,EdiCEnd            ; ^END

         dw        7300h,EdiCLft            ; ^LEFT slovo vlevo
         dw        7400h,EdiCRgh            ; ^RGHT slovo vpravo

         dw        5300h,EditDel            ; DELETE zru®en° znaku
         dw        5200h,EdiIns             ; INSERT vloëen° mezery
         dw        8,EditBS                 ; BS maz†n° znaku p©ed kurzorem

         dw        19h,EditDelL             ; ^Y - zru®en° ©†dku

         dw        EOF,Edit28               ; nepovolenò znak
         dw        LF,Edit                  ; ^Enter - n†vrat ©†dku
         dw        27,EdiEsc                ; ESC
         dw        13,EdiEnt                ; ENTER
         dw        0,Edit29

         jmp       Seznam1

; ------ vstup znaku

Edit29:  cmp       bl," "
         jb        Edit28
         or        byte ptr ds:[Param],8    ; p©°znak modifikace ©†dku
         mov       si,ds:[EditPoz]          ; pozice kurzoru v edit. bufferu
         mov       es:[EditBuff+si],bl      ; uloëen° znaku do bufferu

; ------ posun kurzoru vpravo

EditRgh: call      EdRight                  ; posun kurzoru o pozici vpravo
         jmp       Edit2

; ------ posun kurzoru vlevo

EditLft: call      EdLeft                   ; posun kurzoru o pozici vlevo
         jmp       Edit2

; ------ konec editace ENTER

EdiEnt:  call      EdLeft                   ; posun kurzoru o pozici vlevo
         jnc       EdiEnt                   ; posun aë na prvn° pozici
         call      EdKor                    ; korekce poá†tku ©†dku

; ------ posun kurzoru o ©†dek dolñ

EdiEnt1: call      UlozEdi                  ; uloëen° ©†dku do textu
EdiEnt2: call      NextKurz                 ; nalezen° dal®°ho ©†dku kurzoru
         jc        EdiEnt3                  ; nen° dal®° ©†dek

; ------ kontrola p©eteáen° konce displeje

         mov       bx,ds:[Kurzor]
         sub       bx,ds:[TopRad]
         mov       al,ds:[Radku]
         sub       al,2
         cmp       bl,al
         jb        EdiEnt3
         call      NextTop                  ; dal®° ©†dek poá†tku
EdiEnt3: test      byte ptr ds:[Param],10h  ; je reëim vkl†d†n° ?
         jz        EdiEnt4                  ; nen° reëim vkl†d†n°
         jmp       EditIns
EdiEnt4: jmp       EditEnt




; ------ posun kurzoru o ©†dek dolñ

EdiDolu: call      UlozEdi                  ; uloëen° ©†dku do textu
EdiDolu1:call      NextKurz                 ; nalezen° dal®°ho ©†dku kurzoru
         jc        EdiDolu3                 ; nen° dal®° ©†dek

; ------ kontrola p©eteáen° konce displeje

         mov       bx,ds:[Kurzor]
         sub       bx,ds:[TopRad]
         mov       al,ds:[Radku]
         sub       al,2
         cmp       bl,al
         jb        EdiDolu3
         call      NextTop                  ; dal®° ©†dek poá†tku
EdiDolu3:jmp       Edit

; ------ ukonáen° editace ESC

EdiEsc:  call      KurzOff                  ; vypnut° kurzoru
         call      UlozEdi                  ; uloëen° ©†dku do bufferu
         and       byte ptr ds:[Param],not 4    ; p©°znak editace ©†dku
         call      DispAll                  ; novÇ zobrazen° obrazovky
         call      UlozFil                  ; uloëen° souboru na disk
         jmp       Seznam

; ------ posun kurzoru o ©†dek nahoru

EdiNah:  call      UlozEdi                  ; uloëen° ©†dku do textu
         call      PredKurz                 ; p©edchoz° ©†dek kurzoru
         jc        EdiNah9                  ; nen° dal®° ©†dek

; ------ kontrola p©eteáen° zaá†tku displeje

         mov       bx,ds:[Kurzor]
         cmp       bx,ds:[TopRad]
         jae       EdiNah9

         mov       word ptr ds:[AdrTop],si ; je to tÇë poá†tek displeje
         mov       word ptr ds:[AdrTop+2],dx
         mov       word ptr ds:[TopRad],bx

EdiNah9:
         jmp       Edit

; ------ zaá†tek prvn° poloëky ^HOME

EdiCHome:call      EdLeft
         jnc       EdiCHome
         jmp       Edit2

; ------ zaá†tek poloëky HOME

EditHome:call      EdHome                   ; zaá†tek aktivn° poloëky
         jnc       EditHom4                 ; byl jië zaá†tek poloëky
         call      EdLeft                   ; posun kurzoru vlevo
         jc        EditHom4                 ; nen° dal®° pozice
         call      EdHome                   ; zaá†tek novÇ poloëky
EditHom4:jmp       Edit2

; ------ konec posledn° poloëky ^END

EdiCEnd: call      EdRight
         jnc       EdiCEnd
         call      EdEndT                   ; konec aktivn° poloëky
         jmp       Edit2

; ------ konec poloëky END

                                          ;* kontrola, zda jië je konec poloëky
EditEnd: call      EdEndT                   ; posun na konec v aktivn° poloëce
         jnc       EditEnd4                 ; nebyl konec poloëky
         call      EdNext                   ; posun na n†sleduj°c° poloëku
         call      EdEndT                   ; zde posun na konec poloëky2
EditEnd4:jmp       Edit2

; ------ n†sleduj°c° poloëka TAB

EditTab: mov       bx,ds:[EditPozL]
         mov       cx,ds:[EditPoz]
         call      EdNext                   ; posun na n†sleduj°c° poloëku
         jc        EditSTb1                 ; nen° - n†vrat pozice
         call      EdHome                   ; zaá†tek poloëky
         jmp       Edit2

; ------ p©edchoz° poloëka *TAB

EditSTab:mov       bx,ds:[EditPozL]
         mov       cx,ds:[EditPoz]          ; £schova pozice
         call      EdPred                   ; p©edchoz° poloëka
         jnc       EditSTb2                 ; je p©edchoz° poloëka
EditSTb1:mov       ds:[EditPozL],bx
         mov       ds:[EditPoz],cx
         jmp       Edit2
EditSTb2:call      EdHome                   ; zaá†tek poloëky
         jmp       Edit2

; ------ str†nka nahoru PGUP

EditPgUp:call      UlozEdi                  ; uloëen° ©†dku do textu
         call      PageUp
         jmp       Edit

; ------ str†nka dolñ PGDN

EditPgDn:call      UlozEdi                  ; uloëen° ©†dku do textu
         call      PageDn
         jmp       Edit

; ------ zaá†tek seznamu ^Page Up

EdiCPgUp:
         call      UlozEdi                  ; uloëen° ©†dku do textu
         call      CPageUp
         jmp       Edit

; ------ konec seznamu ^Page Down

EdiCPgDn:
         call      UlozEdi                  ; uloëen° ©†dku do textu
         call      CPageDn
         jmp       Edit

; ------ zru®en° ©†dku ^Y

EditDelL:call      DelLine                  ; zru®en° ©†dku
         jnc       EditDlL2                 ; operace OK
         jmp       Edit2
EditDlL2:jmp       Edit

; ------ zru®en° znaku p©ed kurzorem

EditBS:  call      EdLeft                   ; posun kurzoru vlevo
         jc        EditDel2

; ------ zru®en° znaku DELETE

EditDel: call      EdDel                    ; zru®en° znaku nad kurzorem
         jc        EditDel2                 ; nebyl ë†dnò znak
         or        byte ptr ds:[Param],8    ; p©°znak modifikace ©†dku
EditDel2:jmp       Edit2

; ------ vloëen° mezery INSERT

EdiIns:  call      EdIns                    ; vloëen° mezery nad kurzor
         jc        EdiIns2                  ; nebyl ë†dnò znak
         or        byte ptr ds:[Param],8    ; p©°znak modifikace ©†dku
EdiIns2: jmp       Edit2

; ------ posun o slovo vlevo

EdiCLft: call      EdCLeft                  ; posun o slovo vlevo
         jmp       Edit2

; ------ posun o slovo vpravo

EdiCRgh: call      EdCRght                  ; posun o slovo vpravo
         jmp       Edit2

; -----------------------------------------------------------------------------
;        uloëen° editovanÇho ©†dku do textu
; -----------------------------------------------------------------------------

UlozEdi  PROC      NEAR

; ------ test modifikace ©†dku

         test      byte ptr ds:[Param],8    ; byl ©†dek modifikov†n ?
         jnz       UlozEdi0                 ; ©†dek byl modifikov†n
         ret

; ------ stanoven° dÇlky ©†dku

UlozEdi0:mov       cx,255                   ; max. dÇlka ©†dku
         mov       si,offset EditBuff+255   ; konec editaán°ho bufferu + 1
UlozEdi1:dec       si                       ; sn°ëen° adresy v bufferu
         cmp       byte ptr ds:[si]," "     ; je mezera ?
         loope     UlozEdi1                 ; nalezen° platnÇho znaku
         je        UlozEdi2                 ; nebyl nalezen ë†dnò platnò znak
         inc       cx                       ; oprava - byl platnò znak
UlozEdi2:mov       dx,cx                    ; £schova dÇlky textu
         inc       dx                       ; 1 znak se rezervuje pro CR

; ------ stanoven° starÇ dÇlky ©†dku

         push      ds
         mov       si,word ptr ds:[AdrKurz] ; offset ©†dku
         mov       ds,word ptr ds:[AdrKurz+2] ; segment ©†dku
         xor       cx,cx                    ; á°taá dÇlky ©†dku
UlozEdi3:mov       al,ds:[si]               ; znak
         cmp       al,EOF                   ; konec souboru ?
         je        UlozEdi5                 ; je konec souboru
         cmp       al,LF
         je        UlozEdi5                 ; konec ©†dku
         inc       si                       ; zvò®en° ukazatele v souboru
         jnz       UlozEdi4                 ; nen° p©eteáen° segmentu
         mov       ax,ds
         add       ax,1000h                 ; posun adresy segmentu
         mov       ds,ax
UlozEdi4:inc       cx                       ; zvò®en° á°taáe dÇlky ©†dku
         jmp       short UlozEdi3           ; dal®° znak
UlozEdi5:pop       ds

; ------ rozli®en°, zda se vkl†daj° data nebo ru®°

         mov       di,word ptr ds:[AdrKurz] ; offset ©†dku
         mov       es,word ptr ds:[AdrKurz+2] ; segment ©†dku
         sub       cx,dx                    ; rozd°l oproti novÇmu ©†dku
         je        UlozEdi7                 ; ©†dek je stejnà dlouhò
         ja        UlozEdi6                 ; ©†dek je del®°

; ------ ©†dek je krat®° - vloëen° dat

         neg       cx                       ; poáet vkl†danòch bajtñ
         call      InsDat                   ; vloëen° CX bajtñ na adresu ES:DI
         jnc       UlozEdi7                 ; operace OK
         sub       dx,cx                    ; jinak sn°ëen° dÇlky textu
         jmp       short UlozEdi7           ; p©epis ©†dku do bufferu

; ------ ©†dek je del®° - vypu®tàn° dat

UlozEdi6:call      DelDat                   ; zru®en° CX bajtñ z adresy ES:DI

; ------ dÇlka ©†dku je OK - p©enos ©†dku do bufferu

UlozEdi7:mov       si,offset EditBuff       ; editaán° buffer
         mov       cx,dx                    ; poáet p©en†®enòch bajtñ
         dec       cx                       ; kromà koncovÇho CR
         mov       ax,di
         and       di,0fh
         mov       bx,es
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       bx,ax
         mov       es,bx
         cld
         rep       movsb                    ; p©enos dat do bufferu
         mov       al,CR
         stosb                              ; ukonáovac° CR
         cmp       byte ptr es:[di],EOF
         jne       UlozEdi8
         mov       cx,1
         call      InsDat
         jc        UlozEdi8
         mov       al,LF
         stosb                              ; ukonáovac° LF
UlozEdi8:
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru
         ret

UlozEdi  ENDP

; -----------------------------------------------------------------------------
;        zru®en° dat z bufferu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa v bufferu
;        CX=poáet bajtñ ke zru®en°
;        DS=datovò segment
; -----------------------------------------------------------------------------

DelDat   PROC      NEAR

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

; ------ stanoven° segmentu konce souboru

         mov       ax,word ptr ds:[SizFile] ; velikost souboru LOW
         mov       dx,word ptr ds:[SizFile+2] ; velikost souboru HIGH
         add       ax,15                    ; zaokrouhlen° nahoru
         adc       dx,0                     ; p©enos
         mov       bx,16                    ; vydàl° se 16
         div       bx                       ; velikost souboru v odstavc°ch
         mov       bp,ax                    ; £schova velikosti souboru
         add       bp,ds:[SegDat]           ; segment konce souboru

; ------ normalizace poá†teán° adresy v bufferu

         mov       ax,di                    ; offset adresy
         and       di,0fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       bx,es                    ; segment adresy
         add       bx,ax                    ; segment
         mov       es,bx                    ; normalizovanò segment

; ------ zdrojov† adresa k p©esunu

         mov       si,di
         add       si,cx                    ; zdrojov† adresa p©esunu
         mov       ax,si
         and       si,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         add       bx,ax                    ; segment
         mov       ds,bx                    ; normalizovanò segment

; ------ uráen° dÇlky dat k p©esunu

         jcxz      DelDat9                  ; nejsou ë†dn† data k vypu®tàn°
         mov       dx,cx                    ; £schova velikosti dat

         sub       bp,bx                    ; rozd°l segmentñ
         jnc       DelDat2                  ; nen° p©eteáen°
         xor       bp,bp                    ; oprava
DelDat2: cmp       bp,cs:[SizDat]           ; je vàt®° neë buffer ?
         jbe       DelDat3                  ; je OK
         mov       bp,cs:[SizDat]           ; omezen°
DelDat3: add       bp,2                     ; asi takov† rezerva pro nep©esnost

; ------ uráen° dÇlky bloku k p©esunu

         cld
DelDat4: mov       cx,0f00h                 ; velikost bloku v odstavc°ch
         cmp       cx,bp                    ; zbòv† men®° blok ?
         jbe       DelDat5                  ; velikost bloku je OK
         mov       cx,bp                    ; omezen° velikosti
DelDat5: sub       bp,cx                    ; sn°ëen° zbylòch dat
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod na slova

; ------ p©esun jednoho bloku dat

         rep       movsw                    ; p©esun jednoho bloku dat

; ------ normalizace c°lovÇ adresy

         mov       ax,di                    ; offset adresy
         and       di,0fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       bx,es                    ; segment adresy
         add       bx,ax                    ; segment
         mov       es,bx                    ; normalizovanò segment

; ------ normalizace zdrojovÇ adresy

         mov       ax,si
         and       si,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       bx,ds
         add       bx,ax                    ; segment
         mov       ds,bx                    ; normalizovanò segment

; ------ kontrola, zda je dal®° blok k p©esunu

         or        bp,bp                    ; jsou dal®° data ?
         jnz       DelDat4                  ; p©esun dal®°ch dat

; ------ sn°ëen° velikosti souboru

         sub       word ptr cs:[Sizfile],dx
         sbb       word ptr cs:[SizFile+2],0

; ------ n†vrat registrñ

DelDat9: pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DelDat   ENDP

; -----------------------------------------------------------------------------
;        vloëen° dat do bufferu
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa v bufferu
;        CX=poáet bajtñ k vloëen°
;        DS=datovò segment
; VùSTUP:CY=nedostatek pamàti
; -----------------------------------------------------------------------------

InsDat   PROC      NEAR

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

; ------ stanoven° segmentu konce souboru

         mov       ax,word ptr ds:[SizFile] ; velikost souboru LOW
         mov       dx,word ptr ds:[SizFile+2] ; velikost souboru HIGH
         add       ax,15                    ; zaokrouhlen° nahoru
         adc       dx,0                     ; p©enos
         mov       bx,16                    ; vydàl° se 16
         div       bx                       ; velikost souboru v odstavc°ch
         mov       bp,ax                    ; £schova velikosti souboru
         add       bp,ds:[SegDat]           ; segment konce souboru

; ------ normalizace poá†teán° adresy v bufferu

         mov       si,di
         mov       ax,si                    ; offset adresy
         and       si,0fh
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       bx,es                    ; segment adresy
         add       bx,ax                    ; segment
         mov       ds,bx                    ; normalizovanò segment

; ------ c°lov† adresa k p©esunu

         mov       di,si
         add       di,cx                    ; zdrojov† adresa p©esunu
         mov       ax,di
         and       di,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©evod na odstavce
         mov       dx,ds
         add       dx,ax                    ; segment
         mov       es,dx                    ; normalizovanò segment

; ------ uráen° dÇlky dat k p©esunu

         clc
         jcxz      InsDat9                  ; nejsou ë†dn† data k vypu®tàn°
         mov       dx,cx                    ; £schova velikosti dat

         sub       bp,bx                    ; rozd°l segmentñ
         jnc       InsDat2                  ; nen° p©eteáen°
         xor       bp,bp                    ; oprava
InsDat2: add       bp,2                     ; asi takov† rezerva pro nep©esnost
         cmp       bp,cs:[SizDat]           ; je v bufferu dost m°sta ?
         cmc
         jb        InsDat9                  ; nen° dost m°sta

; ------ oprava segmentñ adres

         mov       ax,ds
         add       ax,bp
         mov       ds,ax
         mov       ax,es
         add       ax,bp
         mov       es,ax

; ------ uráen° dÇlky bloku k p©esunu

         std
InsDat4: mov       cx,0f00h                 ; velikost bloku v odstavc°ch
         cmp       cx,bp                    ; zbòv† men®° blok ?
         jbe       InsDat5                  ; velikost bloku je OK
         mov       cx,bp                    ; omezen° velikosti
InsDat5: sub       bp,cx                    ; sn°ëen° zbylòch dat
         mov       ax,ds
         sub       ax,cx
         mov       ds,ax
         mov       ax,es
         sub       ax,cx
         mov       es,ax
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod na slova
         shl       cx,1
         add       si,cx
         add       di,cx
         shr       cx,1

; ------ p©esun jednoho bloku dat

         sub       di,2
         sub       si,2
         rep       movsw                    ; p©esun jednoho bloku dat
         add       di,2
         add       si,2

; ------ kontrola, zda je dal®° blok k p©esunu

         or        bp,bp                    ; jsou dal®° data ?
         jnz       InsDat4                  ; p©esun dal®°ch dat

; ------ zvò®en° velikosti souboru

         add       word ptr cs:[Sizfile],dx
         adc       word ptr cs:[SizFile+2],0
         clc

; ------ n†vrat registrñ

InsDat9: pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InsDat   ENDP

; -----------------------------------------------------------------------------
;        zru®en° znaku nad kurzorem (CY=nebyl ë†dnò znak)
; -----------------------------------------------------------------------------

EdDel    PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      si

         xor       cx,cx                    ; á°taá znakñ
         mov       bx,ds:[EditPozL]
         mov       si,ds:[EditPoz]
EdDel1:  cmp       bl,255
         je        EdDel4                   ; je konec bufferu
         cmp       byte ptr ds:[bx+MaskBuff+1],"#" ; je konec poloëky ?
         jne       EdDel4                   ; je jië konec poloëky
         cmp       byte ptr ds:[si+EditBuff]," "
         je        EdDel2
         inc       cx
EdDel2:  mov       al,ds:[si+EditBuff+1]    ; p©°®t° znak
         mov       ds:[si+EditBuff],al
         inc       bx
         inc       si
         jmp       short EdDel1

EdDel4:  cmp       byte ptr ds:[si+EditBuff]," "
         je        EdDel5
         inc       cx                       ; á°taá modifikovanòch znakñ
EdDel5:  mov       byte ptr ds:[si+EditBuff]," " ; vymaz†n° posledn°ho znaku
         stc
         jcxz      EdDel6                   ; nebylo nic modifikov†no
         clc
EdDel6:
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EdDel    ENDP

; -----------------------------------------------------------------------------
;        vloëen° mezery pod kurzor
; -----------------------------------------------------------------------------

EdIns    PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      si

         xor       cx,cx                    ; á°taá modifikovanòch znakñ
         mov       bx,ds:[EditPozL]
         mov       si,ds:[EditPoz]
         mov       al," "
EdIns1:  xchg      ds:[si+EditBuff],al
         cmp       al," "
         je        EdIns2
         inc       cx                       ; á°taá znakñ
EdIns2:  cmp       bl,255
         je        EdIns4                   ; je konec bufferu
         cmp       byte ptr ds:[bx+MaskBuff+1],"#" ; je konec poloëky ?
         jne       EdIns4                   ; je jië konec poloëky
         inc       bx
         inc       si
         jmp       short EdIns1

EdIns4:  stc
         jcxz      EdIns5                   ; nebyla modifikace
         clc
EdIns5:  pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

EdIns    ENDP

; -----------------------------------------------------------------------------
;        posun o slovo vlevo
; -----------------------------------------------------------------------------

EdCLeft  PROC      NEAR

         push      bx

EdCLeft2:call      EdLeft                   ; posun o znak vlevo
         jc        EdCLeft4
         mov       bx,ds:[EditPozL]
         cmp       bl,0
         je        EdCLeft4
         cmp       byte ptr ds:[bx+MaskBuff-1],"#" ; je zaá†tek poloëky ?
         jne       EdCLeft4                  ; je jië zaá†tek poloëky
         mov       bx,ds:[EditPoz]
         cmp       bx,0
         je        EdCLeft4
         cmp       byte ptr ds:[bx+EditBuff-1]," " ; je zaá†tek slova ?
         jne       EdCLeft2                  ; nen° - dal®° slovo
         cmp       byte ptr ds:[bx+EditBuff]," "
         je        EdCLeft2

EdCLeft4:pop       bx
         ret

EdCLeft  ENDP

; -----------------------------------------------------------------------------
;        posun o slovo vpravo
; -----------------------------------------------------------------------------

EdCRght  PROC      NEAR

         push      bx
EdCRght2:call      EdRight                  ; posun o pozici vpravo
         jc        EdCRght4                 ; nen° dal®° voln† pozice
         mov       bx,ds:[EditPozL]
         cmp       bl,255
         je        EdCRght4
         cmp       byte ptr ds:[bx+MaskBuff-1],"#" ; je zaá†tek dal®° poloëky ?
         jne       EdCRght4                  ; je zaá†tek dal®° poloëky
         mov       bx,ds:[EditPoz]
         cmp       bx,255
         je        EdCRght4
         cmp       byte ptr ds:[bx+EditBuff-1]," " ; je zaá†tek slova ?
         jne       EdCRght2                  ; nen° - dal®° slovo
         cmp       byte ptr ds:[bx+EditBuff]," "
         je        EdCRght2

EdCRght4:pop       bx
         ret

EdCRght  ENDP

; -----------------------------------------------------------------------------
;        posun na konec textu v aktivn° poloëce (CY=byl jië konec textu)
; -----------------------------------------------------------------------------

EdEndT   PROC      NEAR

         push      bx
         push      cx

; ------ posun na konec poloëky

         mov       cx,ds:[EditPozL]         ; souáasn† pozice
         call      EdEnd                    ; posun na konec poloëky

; ------ posun na konec textu v poloëce

EdEndT2: mov       bx,ds:[EditPoz]
         cmp       byte ptr ds:[bx+EditBuff]," " ; je konec textu ?
         jne       EdEndT4                  ; je jië konec textu
         cmp       bl,0
         je        EdEndT4                  ; je jië zaá†tek ©†dku
         cmp       byte ptr ds:[bx+EditBuff-1]," "
         jne       EdEndT4                  ; je jië konec textu
         mov       bx,ds:[EditPozL]
         cmp       byte ptr ds:[bx+MaskBuff-1],"#" ; je jië zaá†tek poloëky ?
         jne       EdEndT4                  ; je jië zaá†tek poloëky
         call      EdLeft                   ; posun kurzoru vlevo
         jnc       EdEndT2

; ------ rozli®en° stavu

EdEndT4: cmp       cx,ds:[EditPozL]         ; byla pozice zmànàna ?
         clc
         jne       EdEndT5                  ; byla zmànàna - OK
         stc

EdEndT5: pop       cx
         pop       bx
         ret

EdEndT   ENDP

; -----------------------------------------------------------------------------
;        posun na konec p©edchoz° poloëky (CY=nen° dal®° poloëka)
; -----------------------------------------------------------------------------

EdPred   PROC      NEAR

         call      EdHome                   ; zaá†tek aktivn° poloëky
         call      EdLeft                   ; posun kurzoru vlevo
         ret

EdPred   ENDP

; -----------------------------------------------------------------------------
;        posun na zaá†tek n†sleduj°c° poloëky (CY=nen° dal®° poloëka)
; -----------------------------------------------------------------------------

EdNext   PROC      NEAR

         call      EdEnd                    ; konec aktivn° poloëky
         call      EdRight                  ; posun kurzoru vpravo
         ret

EdNext   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na zaá†tek poloëky (CY=byl jië zaá†tek poloëky)
; -----------------------------------------------------------------------------

EdHome   PROC      NEAR

         push      bx
         push      cx
         xor       cx,cx                    ; á°taá krokñ
EdHome1: mov       bx,ds:[EditPozL]
         cmp       bl,0                     ; je jië zaá†tek bufferu ?
         je        EdHome4                  ; je jië zaá†tek bufferu
         cmp       byte ptr ds:[bx+MaskBuff-1],"#" ; je poá†tek poloëky ?
         jne       EdHome4                  ; je jië poá†tek poloëky
         call      EdLeft                   ; posun kurzoru vlevo
         jc        EdHome4                  ; nen° dal®° pozice
         inc       cx                       ; á°taá krokñ
         jmp       short EdHome1
EdHome4: stc
         jcxz      EdHome5                  ; nebyl posun
         clc
EdHome5: pop       cx
         pop       bx
         ret

EdHome   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru na konec poloëky
; -----------------------------------------------------------------------------

EdEnd    PROC      NEAR

         push      bx
         push      cx
         xor       cx,cx                    ; á°taá krokñ
EdEnd1:  mov       bx,ds:[EditPozL]
         cmp       bl,255                   ; je jië konec bufferu ?
         je        EdEnd3                   ; je jië konec bufferu
         cmp       byte ptr ds:[bx+MaskBuff+1],"#" ; je konec poloëky ?
         jne       EdEnd3                   ; je jië konec poloëky
         call      EdRight                  ; posun vpravo
         jc        EdEnd3                   ; nen° dal®° pozice
         inc       cx                       ; á°taá posuvñ
         jmp       short EdEnd1
EdEnd3:  stc
         jcxz      EdEnd4                   ; nebyl posun
         clc
EdEnd4:  pop       cx
         pop       bx
         ret

EdEnd    ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o pozici vpravo (CY=nen° dal®° pozice)
; -----------------------------------------------------------------------------

EdRight  PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ nalezen° dal®° pozice na ©†dku

         mov       bx,ds:[EditPozL]         ; pozice kurzoru na ©†dku
EdRight2:inc       bx
         cmp       bl,1
         jb        EdRight9                 ; nen° dal®° pozice
         cmp       byte ptr ds:[bx+MaskBuff],"#" ; je to datov† pozice ?
         jne       EdRight2                 ; nen° to datov† pozice
         mov       ds:[EditPozL],bx         ; nov† pozice na ©†dku
         inc       word ptr ds:[EditPoz]    ; zvò®en° pozice v textu

; ------ n†vrat registrñ

EdRight9:pop       bx
         ret

EdRight  ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o pozici vlevo (CY=nen° dal®° pozice)
; -----------------------------------------------------------------------------

EdLeft   PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ nalezen° dal®° pozice na ©†dku

         mov       bx,ds:[EditPozL]         ; pozice kurzoru na ©†dku
EdLeft2: or        bx,bx
         stc                                ; p©°znak zaá†tku ©†dku
         jz        EdLeft9                  ; nen° dal®° pozice
         dec       bx
         cmp       byte ptr ds:[bx+MaskBuff],"#" ; je to datov† pozice ?
         jne       EdLeft2                  ; nen° to datov† pozice
         mov       ds:[EditPozL],bx         ; nov† pozice na ©†dku
         dec       byte ptr ds:[EditPoz]    ; sn°ëen° pozice v textu

; ------ n†vrat registrñ

EdLeft9: pop       bx
         ret

EdLeft   ENDP

; -----------------------------------------------------------------------------
;        korekce poá†tku ©†dku
; -----------------------------------------------------------------------------

EdKor    PROC      NEAR

         push      ax

; ------ oprava, pokud je kurzor p©ed poá†tkem ©†dku

         mov       al,byte ptr ds:[EditPozL] ; pozice na ©†dku
         cmp       al,ds:[TopPoz]           ; je p©ed poá†tkem ©†dku ?
         jae       EdKor2                   ; nen° p©ed poá†tkem ©†dku
         mov       ds:[TopPoz],al

; ------ oprava, pokud je kurzor za koncem ©†dku

EdKor2:  sub       al,79                    ; minim†ln° pozice poá†tku
         jae       EdKor3
         xor       ax,ax
EdKor3:  cmp       al,ds:[TopPoz]
         jbe       EdKor4
         mov       ds:[TopPoz],al

EdKor4:  pop       ax

         ret

EdKor    ENDP

; -----------------------------------------------------------------------------
;        uloëen° souboru
; -----------------------------------------------------------------------------

UlozFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds

; ------ test, zda byl soubor modifikov†n

         test      byte ptr cs:[Param],2    ; byl soubor nodifikov†n ?
         jnz       UlozFil0
         jmp       UlozFil9                 ; soubor nebyl modifikov†n

; ------ vytvo©en° c°lovÇho souboru

UlozFil0:push      cs
         pop       ds
         mov       si,offset HlpUklad
         call      DispHlp                  ; zobrazen° n†povàdy
         mov       dx,offset Soubor1        ; jmÇno souboru
         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en° souboru
         jnc       UlozFl02
         mov       si,offset HlpWrit
         jmp       short UlozFil4
UlozFl02:mov       bx,ax

; ------ p©°prava registrñ

         mov       si,word ptr cs:[SizFile] ; velikost souboru LOW
         mov       di,word ptr cs:[SizFile+2] ; velikost souboru HIGH
         add       si,1                     ; 1 bajt se p©id† na konec (EOF)
         adc       di,0
         mov       ds,cs:[SegDat]           ; segment zaá†tku souboru

; ------ stanoven° velikosti bloku k uloëen°

UlozFil1:mov       cx,0f000h
         or        di,di
         jnz       UlozFil2                 ; je vàt®° neë 64 KB
         cmp       cx,si
         jbe       UlozFil2
         mov       cx,si                    ; omezen°

; ------ uloëen° bloku dat

UlozFil2:xor       dx,dx
         jcxz      UlozFil8                 ; konec dat
         mov       ah,40h
         int       21h                      ; z†pis
         jnc       UlozFl22
         mov       si,offset HlpWrit        ; chyba z†pisu
         jmp       short UlozFil3
UlozFl22:cmp       ax,cx                    ; byla uloëena v®echna data ?
         je        UlozFil5                 ; ukl†d†n° je OK

; ------ chyba - disk je plnò

         mov       si,offset HlpFull
UlozFil3:mov       ah,3eh
         int       21h
UlozFil4:push      cs
         pop       ds
         call      DispHlp                  ; zobrazen° textu chyby
         call      FlushChr
         call      InpChr                   ; vstup znaku
         stc
         jmp       short UlozFil9

; ------ zvò®en° adresy

UlozFil5:mov       ax,ds
         add       ax,0f00h
         mov       ds,ax

; ------ sn°ëen° á°taáe dat

         sub       si,cx
         sbb       di,0
         jmp       short UlozFil1           ; z†pis dal®°ho bloku dat

; ------ uzav©en° souboru

UlozFil8:mov       ah,3eh
         int       21h
         and       byte ptr cs:[Param],not 2 ; zru®en° p©°znaku modifikace

; ------ n†vrat registrñ

UlozFil9:pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UlozFil  ENDP

; *****************************************************************************
;                             DispNadp
;                         zobrazen° nadpisu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispNadp PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ poá†teán° adresa a dÇlka textu k zobrazen°

         mov       ch,0
         mov       cl,ds:[TopPoz]
         mov       si,offset NadpBuff       ; buffer nadpisu
         add       si,cx                    ; p©iáten° poá†teán° pozice
         mov       cl,ds:[NadpNum]          ; dÇlka textu nadpisu
         sub       cl,ds:[TopPoz]           ; odeáten° poá†tku
         jae       DispNdp1                 ; zbòv† nàjakò text
         xor       cx,cx                    ; nen° dal®° text
DispNdp1:mov       bx,80                    ; dÇlka ©†dku
         cmp       cx,bx                    ; je del®° neë ©†dek ?
         jbe       DispNdp2                 ; nen° del®° neë ©†dek
         mov       cx,bx                    ; omezen° dÇlky textu
DispNdp2:sub       bx,cx                    ; poáet zbylòch znakñ za textem

; ------ zobrazen° textu nadpisu

         cld
         mov       ah,ds:[Barva3]           ; barva nadpisu
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         jcxz      DispNdp5                 ; nezbyl ë†dnò text
DispNdp3:lodsb
         stosw
         loop      DispNdp3

; ------ zobrazen° zbylòch mezer

DispNdp5:mov       al," "
         mov       cx,bx                    ; poáet zbylòch mezer
         rep       stosw                    ; vymaz†n° zbytku ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNadp ENDP

; *****************************************************************************
;                               DispAll
;                    zobrazen° celÇ str†nky
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-2] (2) á°taá ©†dku pro kurzor
;                   SS:[BP-4] (1) á°taá ©†dkñ k zobrazen°
;                   SS:[BP-6] (2) uschovanò offset ©†dku
;                   SS:[BP-8] (2) uschovanò segment ©†dku (0=nen° uschov†n)
; *****************************************************************************
;˛
DispAll  PROC      NEAR

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
         sub       sp,8                     ; m°sto pro lok†ln° promànnÇ

; -----------------------------------------------------------------------------
;        p©°prava registrñ
; -----------------------------------------------------------------------------

; ------ adresa poá†tku textu v pamàti

         mov       si,word ptr cs:[AdrTop] ; offset poá†tku
         mov       dx,word ptr cs:[AdrTop+2] ; segment poá†tku
         mov       ds,dx                    ; segment poá†tku

; ------ á°taá ©†dkñ pro kurzor

         mov       ax,cs:[Kurzor]           ; ©†dek s kurzorem
         sub       ax,cs:[TopRad]           ; offset od poá†teán°ho ©†dku
         inc       ax                       ; p©ednastaven°
         mov       ss:[bp-2],ax             ; á°taá ©†dku kurzoru

; ------ p©°prava ostatn°ch registrñ

         mov       word ptr ss:[bp-8],0     ; p©°znak, ëe nen° nic uschov†no
         mov       ch,cs:[Radku]            ; poáet ©†dkñ
         sub       ch,2
         mov       ss:[bp-4],ch             ; á°taá ©†dkñ k zobrazen°
         les       di,cs:[AdrVRAM]          ; adresa videopamàti
         add       di,160                   ; adresa druhÇho ©†dku
         cld

; -----------------------------------------------------------------------------
;        zobrazen° pr†zdnÇho ©†dku
; -----------------------------------------------------------------------------

; ------ p©°prava barvy ©†dku

DispAll1:mov       ah,cs:[Barva1]           ; bàën† barva textu
         dec       word ptr ss:[bp-2]       ; á°taá ©†dku s kurzorem
         jnz       DispAll2                 ; nen° ©†dek s kurzorem
         mov       ah,cs:[Barva2]           ; barva kurzoru

; ------ rozli®en°, zda je editovanò ©†dek

         test      byte ptr cs:[Param],4    ; je editace ©†dku ?
         jz        DispAll2                 ; nen° editace ©†dku
         mov       ah,cs:[Barva5]           ; barva editovanÇho ©†dku
         mov       ss:[bp-6],si             ; £schova offsetu adresy
         mov       ss:[bp-8],ds             ; £schova segmentu adresy
         push      cs
         pop       ds                       ; plat° adresa editaán°ho bufferu
         mov       si,offset EditBuff       ; editaán° buffer

; ------ kontrola, zda je konec souboru

DispAll2:cmp       byte ptr ds:[si],EOF     ; je konec souboru ?
         jne       DispAll3                 ; nen° konec souboru

; ------ vymaz†n° pr†zdnÇho ©†dku

         mov       cx,80
         mov       al," "
         rep       stosw                    ; vymaz†n° ©†dku
         jmp       DispAll8                 ; dal®° ©†dek

; -----------------------------------------------------------------------------
;        nalezen° zaá†tku ©†dku
; -----------------------------------------------------------------------------

; ------ nalezen° zaá†tku textu k zobrazen°

DispAll3:mov       bx,offset MaskBuff       ; buffer masky
         mov       ch,0
         mov       cl,cs:[TopPoz]           ; poá†teán° pozice ©†dku
         jcxz      DispAll4                 ; je poá†tek ©†dku

; ------ znak z bufferu masky

DispAl32:mov       al,cs:[bx]               ; znak masky
         inc       bx                       ; zvò®en° ukazatele v masce
         cmp       al,"#"                   ; je datovò znak ?
         jne       DispAl38                 ; nen° datovò znak

; ------ kontrola, zda je dal®° datovò znak na ©†dku

DispAl33:cmp       byte ptr ds:[si],EOF     ; je konec souboru ?
         je        DispAl38                 ; je konec souboru
         cmp       byte ptr ds:[si],LF      ; je konec ©†dku LF ?
         je        DispAl38                 ; je konec ©†dku

; ------ naáten° datovÇho znaku z bufferu

         lodsb                              ; naáten° znaku z bufferu
         or        si,si                    ; p©eteáen° segmentu ?
         jnz       DispAl34                 ; nen° p©eteáen° segmentu
         add       dx,1000h                 ; posun segmentu
         mov       ds,dx                    ; novò segment adresy
DispAl34:cmp       al,CR                    ; znak CR se ignoruje
         je        DispAl33                 ; ignorov†n° znaku CR

; ------ p©°prava pro dal®° znak

DispAl38:loop      DispAl32                 ; dal®° pozice na ©†dku

; -----------------------------------------------------------------------------
;        zobrazen° textu ©†dku
; -----------------------------------------------------------------------------

DispAll4:mov       cx,80                    ; poáet bajtñ na ©†dek

; ------ znak z bufferu masky

DispAl42:mov       al,cs:[bx]               ; znak masky
         inc       bx                       ; zvò®en° ukazatele v masce
         cmp       al,"#"                   ; je datovò znak ?
         jne       DispAl48                 ; nen° datovò znak

; ------ kontrola, zda je dal®° datovò znak na ©†dku

DispAl43:mov       al," "                   ; nahrad° se p©°padnà mezerou
         cmp       byte ptr ds:[si],EOF     ; je konec souboru ?
         je        DispAl48                 ; nejsou dal®° data
         cmp       byte ptr ds:[si],LF      ; je konec ©†dku LF ?
         je        DispAl48                 ; je konec ©†dku

; ------ naáten° datovÇho znaku z bufferu

         lodsb                              ; naáten° znaku z bufferu
         or        si,si                    ; p©eteáen° segmentu ?
         jnz       DispAl44                 ; nen° p©eteáen° segmentu
         add       dx,1000h                 ; posun segmentu adresy
         mov       ds,dx                    ; novò segment adresy
DispAl44:cmp       al,CR                    ; znak CR se ignoruje
         je        DispAl43                 ; ignorov†n° znaku CR

; ------ zobrazen° znaku

DispAl48:stosw                              ; z†pis znaku na ©†dek
         loop      DispAl42                 ; dek¢dov†n° dal®°ho znaku

; -----------------------------------------------------------------------------
;        nalezen° zaá†tku dal®°ho ©†dku
; -----------------------------------------------------------------------------

; ------ n†vrat uschovanÇ adresy ©†dku

DispAll5:cmp       word ptr ss:[bp-8],0     ; je uschovan† adresa ©†dku ?
         je        DispAl51                 ; nen° uschovan† adresa ©†dku
         mov       ds,ss:[bp-8]             ; n†vrat segmentu adresy
         mov       si,ss:[bp-6]             ; n†vrat offsetu adresy
         mov       word ptr ss:[bp-8],0     ; zru®en° p©°znaku £schovy adresy

; ------ kontrola, zda je jië konec souboru

DispAl51:cmp       byte ptr ds:[si],EOF     ; je konec souboru ?
         je        DispAll8                 ; nejsou dal®° data

; ------ naáten° datovÇho znaku z bufferu

DispAl52:lodsb                              ; naáten° znaku z bufferu
         or        si,si                    ; bylo p©eteáen° segmentu ?
         jnz       DispAl54                 ; nen° p©eteáen° segmentu
         add       dx,1000h                 ; posun segmentu adresy
         mov       ds,dx                    ; novò segment adresy
DispAl54:cmp       al,LF                    ; byl to konec ©†dku ?
         jne       DispAl51                 ; nebyl konec ©†dku - dal®° znak

; ------ p©°prava pro dal®° ©†dek

DispAll8:dec       byte ptr ss:[bp-4]       ; sn°ëen° á°taáe ©†dkñ
         jz        DispAll9                 ; jsou jië v®echny ©†dky
         jmp       DispAll1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

DispAll9:mov       sp,bp
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

DispAll  ENDP

; *****************************************************************************
;                               FlushChr
;                       vypr†zdnàn° bufferu kl†vesnice
; -----------------------------------------------------------------------------
; *****************************************************************************

FlushChr PROC      NEAR

         push      ax
FlshChr1:mov       ah,1
         int       16h
         jz        FlshChr2
         mov       ah,0
         int       16h
         jmp       short FlshChr1

FlshChr2:pop       ax
         ret

FlushChr ENDP

; *****************************************************************************
;                           InpChr
;                   vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; *****************************************************************************
;˛

InpChr   PROC      NEAR

         push      ax

InpChr0: call      TestKey
         jz        InpChr0

InpChr1: mov       ah,0
         int       16h

         mov       bx,ax

         or        bx,bx
         jnz       InpChr2
         mov       bl,1bh

InpChr2: cmp       bl,0
         je        InpChr3
         mov       bh,0

InpChr3:
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
;                             DispHlp
;                       zobrazen° n†povàdy DS:SI
; -----------------------------------------------------------------------------
; *****************************************************************************

DispHlp  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si
         push      es

         push      ds
         pop       es
         mov       dl,0
         mov       dh,ds:[MaxRow]
         mov       ah,ds:[Barva4]
         mov       cl,80
         call      DispTxt

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispHlp  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                          Dek¢dov†n° p©°kazovÇho ©†dku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; *****************************************************************************
;                              DefLine
;                naáten° ©†dku z definián°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: BX=identifik†tor souboru
;        SI=ukazatel dat ve vstupn°m bufferu
;        ES:DI=adresa bufferu ©†dku
;        DS=datovò segment
; VùSTUP:CX=poáet bajtñ ©†dku (max. 255)
; -----------------------------------------------------------------------------
; zniáenÇ registry: AL, DX, DI
; *****************************************************************************

DefLine  PROC      NEAR

; ------ naáten° jednoho znaku

         xor       cx,cx                    ; á°taá znakñ ©†dku
DefLine2:call      DefChar                  ; áten° znaku ze souboru
         jc        DefLine6                 ; konec souboru
         cmp       al,CR                    ; je znak CR ?
         je        DefLine2                 ; je CR - ignoruje se

; ------ kontrola, zda je konec souboru EOF

         cmp       al,EOF                   ; konec souboru ?
         jne       DefLine3                 ; nen° konec souboru
         dec       si                       ; n†vrat posledn°ho znaku
         jmp       short DefLine6

; ------ kontrola, zda je konec ©†dku

DefLine3:cmp       al,LF                    ; je LF ?
         je        DefLine6                 ; LF - konec ©†dku

; ------ uloëen° znaku (nen°-li p©ekroáena dÇlka ©†dku)

         cmp       cl,255                   ; je buffer jië plnò ?
         je        DefLine2                 ; je jië plnò - neukl†d† se
         cld
         stosb                              ; uloëen° znaku do bufferu
         inc       cx                       ; zvò®en° á°taáe znakñ
         jmp       short DefLine2           ; vstup dal®°ho znaku

DefLine6:
         ret

DefLine  ENDP

; *****************************************************************************
;                               DefChar
;                    vstup znaku z definián°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: BX=identifik†tor souboru
;        SI=ukazatel dat ve vstupn°m bufferu
;        DS=datovò segment
; VùSTUP:AL=znak
;        CY=nen° dal®° znak
; *****************************************************************************

DefChar  PROC      NEAR

; ------ kontrola, zda je dal®° znak v bufferu

         cmp       ds:[InpNum],si           ; jsou jië v®echna data z bufferu ?
         ja        DefChar8                 ; jsou je®tà dal®° data

; ------ novÇ naáten° bufferu

         push      ax
         push      cx
         push      dx
         mov       ah,3fh
         mov       cx,512                   ; velikost bufferu
         mov       dx,offset InpBuff        ; vstupn° buffer
         int       21h                      ; naáten° dat ze souboru
         jnc       DefChar2                 ; operace OK
         xor       ax,ax                    ; nejsou ë†dn† data
DefChar2:mov       ds:[InpNum],ax           ; novò poáet bajtñ v bufferu
         cmp       ax,1                     ; jsou nàjak† data ?
         pop       dx
         pop       cx
         pop       ax
         jc        DefChar9                 ; nejsou dal®° data
         xor       si,si                    ; ukazatel dat v bufferu

; ------ vstup znaku z bufferu

DefChar8:mov       al,ds:[si+InpBuff]       ; naáten° znaku z bufferu
         inc       si                       ; zvò®en° ukazatele v bufferu

DefChar9:ret

DefChar  ENDP

; *****************************************************************************
;                                 TestExt
;                test zad†n° p©°pony souboru ES:DI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=jmÇno souboru
; VùSTUP:CY=p©°pona nen° zadan†
; *****************************************************************************

TestExt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      di

; ------ nalezen° konce jmÇna souboru

         cld
         mov       dx,di                    ; £schova zaá†tku jmÇna
         mov       al,0                     ; hledanò bajt
         mov       cx,128
         repne     scasb                    ; nalezen° konce jmÇna souboru
         dec       di                       ; ukazatel na koncovou 0

; ------ test, zda je zad†na p©°pona

TestExt2:dec       di                       ; sn°ëen° ukazatele ve jmÇnu souboru
         cmp       di,dx                    ; je to platnò znak ?
         jb        TestExt9                 ; neplatnò znak - nen° jmÇno
         mov       al,es:[di]               ; p©ipravenò znak
         cmp       al,"."                   ; je p©°pona ?
         je        TestExt9                 ; je p©°pona
         cmp       al,":"                   ; je oddàlovaá diskñ ?
         je        TestExt8                 ; nen° p©°pona
         cmp       al,"\"                   ; oddàlovaá adres†©ñ ?
         jne       TestExt2                 ; ne - dal®° znak

; ------ n†vrat registrñ

TestExt8:stc                                ; p©°znak - nen° p©°pona
TestExt9:pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

TestExt  ENDP

; *****************************************************************************
;                                 SetExt
;                nastaven° p©°pony souboru ES:DI na CS:BX
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=jmÇno souboru
;        CS:BX=adresa p©°pony
; VùSTUP:CY=p©°pona nen° zadan†
; *****************************************************************************

SetExt   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di

; ------ nalezen° konce jmÇna souboru

         cld
         mov       dx,di                    ; £schova zaá†tku jmÇna
         mov       al,0                     ; hledanò bajt
         mov       cx,128
         repne     scasb                    ; nalezen° konce jmÇna souboru
         dec       di                       ; ukazatel na koncovou 0
         mov       si,di                    ; moënò ukazatel pro p©°ponu

; ------ test, zda je zad†na p©°pona

SetExt2: dec       di                       ; sn°ëen° ukazatele ve jmÇnu souboru
         cmp       di,dx                    ; je to platnò znak ?
         jb        SetExt3                  ; neplatnò znak - nen° jmÇno
         mov       al,es:[di]               ; p©ipravenò znak
         cmp       al,"."                   ; je p©°pona ?
         je        SetExt4                  ; je p©°pona
         cmp       al,":"                   ; je oddàlovaá diskñ ?
         je        SetExt3                  ; nen° p©°pona
         cmp       al,"\"                   ; oddàlovaá adres†©ñ ?
         jne       SetExt2                  ; ne - dal®° znak

; ------ p©enesen° p©°pony

SetExt3: mov       di,si                    ; p©°pona nebyla - konec jmÇna
SetExt4: mov       al,"."
         stosb                              ; oddàlovac° teáka
         mov       ax,cs:[bx]
         stosw                              ; 2 znaky p©°pony
         mov       ax,cs:[bx+2]
         stosw                              ; dal®° znak + koncov† 0

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

SetExt   ENDP

; *****************************************************************************
;                       dek¢dov†n° jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
;        ES:DI=buffer k uloëen° jmÇna souboru
;        CX=poáet zbylòch znakñ p©°kazovÇho ©†dku
; VùSTUP:CY=jmÇno nen° zad†no
; *****************************************************************************

DekFile  PROC      NEAR

; ------ nalezen° zaá†tku jmÇna

         call      DekSpc                   ; nalezen° zaá†tku jmÇna souboru
         jc        DekFile9                 ; nen° nic zad†no

; ------ p©enos jmÇna aë po oddàlovaá

DekFile1:call      DekChr                   ; naáten° dal®°ho znaku jmÇna
         jc        DekFile8                 ; nen° dal®° znak jmÇna souboru
         je        DekFile8                 ; je oddàlovaá - konec jmÇna
         cld
         stosb                              ; uloëen° znaku jmÇna
         jmp       short DekFile1           ; dek¢dov†n° dal®°ho jmÇna souboru

DekFile8:clc                                ; p©°znak jmÇna souboru OK
         cld
         mov       al,0
         stosb                              ; uloëen° koncovÇ 0 jmÇna
DekFile9:ret

DekFile  ENDP

; *****************************************************************************
;                   p©eskoáen° oddàlovaáñ v textu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
;        CX=poáet zbylòch znakñ p©°kazovÇho ©†dku
; VùSTUP:CY=nen° dal®° znak
;        AL=p©ichystanò dal®° znak
; *****************************************************************************

DekSpc   PROC      NEAR

DekSpc1: call      DekChr                   ; naáten° znaku
         jc        DekSpc2                  ; nen° dal®° znak
         je        DekSpc1                  ; je oddàlovaá - dal®° znak
         dec       si                       ; n†vrat posledn°ho znaku
         inc       cx                       ; n†vrat á°taáe znakñ
DekSpc2: ret

DekSpc   ENDP

; *****************************************************************************
;                  Naáten° jednoho znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
;        CX=poáet zbylòch znakñ p©°kazovÇho ©†dku
; VùSTUP:AL=znak z p©°kazovÇho ©†dku
;        ZY=je to oddàlovaá
;        CY=nen° dal®° znak
; *****************************************************************************

DekChr   PROC      NEAR

         stc
         jcxz      DekChr9                  ; nen° dal®° znak
         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ
         cmp       al,9                     ; tabel†tor ?
         je        DekChr9                  ; oddàlovaá tabel†tor
         cmp       al,","                   ; á†rka ?
         je        DekChr9                  ; oddàlovaá á†rka
         cmp       al,";"
         je        DekChr9                  ; oddàlovac° st©edn°k
         cmp       al," "                   ; mezera (nebo konec ©†dku) ?

DekChr9: ret

DekChr   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                             Obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

;˛

; *****************************************************************************
;                             Clear
;                       vymaz†n° obrazovky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

Clear    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ vymaz†n° obrazovky

         mov       ax,7*256 + " "
         xor       dx,dx
         call      SetKurz
         mov       ch,ds:[Radku]
         mov       cl,80
Clear1:  mov       dl,0
         call      DispChr
         inc       dh
         dec       ch
         jnz       Clear1

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

Clear    ENDP

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
         ja        DispChr9                 ; pozice p©ekroáena
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
DispChr9:ret

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

HlpTxt   db        ' ESC=konec ≥ MEZERA,^L=hledej ≥'
HlpTxt0  db        ' ENTER=edituj ≥ INSERT=vkladani ≥ DELETE,^Y=zrus '
HlpTxt1  label     byte

HlpTxt2  db        ' ESC=konec ≥ ENTER=hledej ≥ ',24,'=zpet ≥ ',25,'=vpred ≥ TEXT: '
HledBuf  db        MAXHLED+1 dup(" ")       ; buffer textu k hled†n°
HledNum  dw        0                        ; poáet znakñ textu k hled†n°

HlpTxt3  db        ' ESC=konec ≥ ENTER=dalsi radek ≥ ^ENTER=obnoveni ≥ INSERT/DELETE=vloz/zrus znak '

HlpUklad db        ' CEKEJTE - ukladam provedene zmeny v editovanem seznamu ...                     '

HlpFull  db        ' CHYBA - DISK JE PLNY !  Vymente disk(etu) a volbou editace ENTER ulozte znovu. '

HlpWrit  db        ' CHYBA ZAPISU SOUBORU NA DISK !  Nastavenim rezimu editace ENTER ulozte znovu.  '

HlpDel   db        ' Opravdu chcete zrusit cely radek pod kurzorem (potvrdte A=ano) ?               '

MemErr   db        'Chyba - nedostatek pameti !',13,10,'$'
SoubErr2 db        'Chybne zadani souboru seznamu !',13,10,'$'
SoubErr3 db        'Chybne zadani souboru popisovace seznamu !',13,10,'$'

LicTxt   db        'SEZNAM V1.13; (c) Miroslav Nemecek',13,10,'$'

ExtDAT   db        'DAT',0                  ; implicitn° p©°pona DAT
ExtDEF   db        'DEF',0                  ; implicitn° p©°pona DEF

Barva1   db        1bh                      ; bàën† barva textu
Barva2   db        30h                      ; barva kurzoru
Barva3   db        70h                      ; barva nadpisu
Barva4   db        30h                      ; barva textu n†povàdy
Barva5   db        1fh                      ; barva editovanÇho ©†dku

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
;        popis souboru v pamàti
; -----------------------------------------------------------------------------

         EVEN
SegPSP   dw        0                        ; segment PSP
SegDat   dw        0                        ; adresa datovÇho bloku
SizDat   dw        0                        ; velikost datovÇho bloku (odstavcñ)

SizFile  dd        0                        ; velikost souboru (bajtñ)

AdrTop   dd        0                        ; adresa zobrazenÇho zaá†tku
TopRad   dw        0                        ; á°slo poá†teán°ho zobraz. ©†dku

AdrKurz  dd        0                        ; adresa ©†dku s kurzorem
Kurzor   dw        0                        ; á°slo ©†dku s kurzorem

TopPoz   db        0                        ; poá†teán° pozice ©†dku
TopMax   db        255-80                   ; maxim†ln° pozice poá†tku ©†dku

Param    db        0                        ; parametry
                                            ;  bit 0: 1=soubor nelze editovat
                                            ;  bit 1: 1=soubor byl modifikov†n
                                            ;  bit 2: 1=prob°h† editace poloëky
                                            ;  bit 3: 1=©†dek byl modifikov†n
                                            ;  bit 4: 1=reëim vkl†d†n° ©†dkñ
                                            ;  bit 5: 1=definián° soubor zad†n

; -----------------------------------------------------------------------------
;        buffery
; -----------------------------------------------------------------------------

         EVEN
Soubor1  db        128 dup(0)               ; jmÇno souboru 1
Soubor2  db        128 dup(0)               ; jmÇno souboru 2

EditPoz  dw        0                        ; pozice kurzoru v edit. bufferu
EditPozL dw        0                        ; pozice kurzoru na ©†dku
EditBuff db        255 dup(" ")             ; editaán° buffer

NadpNum  db        0                        ; poáet bajtñ v bufferu nadpisu
NadpBuff db        255 dup(" ")             ; buffer nadpisu

MaskNum  db        0                        ; poáet bajtñ v bufferu masky
MaskBuff db        255 dup(" ")             ; buffer masky

;InitNum  db        0                        ; poáet bajtñ v inicializaán°m ©†dku
;InitBuff db        255 dup(" ")             ; buffer inicializaán°ho ©†dku

         EVEN
InpNum   dw        0                        ; poáet bajtñ ve vstupn°m bufferu
InpBuff  db        512 dup(?)               ; vstupn° buffer

CODE     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                z†sobn°k
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Zasob    SEGMENT   STACK

         dw        100h dup(?)

Zasob    ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            oznaáen° konce programu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

KonSegm  SEGMENT
KonSegm  ENDS

         END       Start

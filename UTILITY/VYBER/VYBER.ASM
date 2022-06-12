
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;               Vòbàr souborñ pro operaci s archivn°m souborem
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

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

MASKDELK EQU       not bit14+bit15          ; maska dÇlky ©†dku

HelpSir  EQU       54                       ; ®°©ka okna n†povàdy
HelpVys  EQU       17                       ; vò®ka okna n†povàdy

REZERVA  EQU       5                        ; rezerva ©†dkñ nad a pod kurzorem

         ORG       100h


; ====== £vodn° inicializace programu

; ------ p©edefinov†n° z†sobn°ku

Start:   cmp       sp,offset Zasobnik
         jb        ErrMem                   ; chyba pamàti
         mov       sp,offset Zasobnik

; ------ zmen®en° bloku programu na minimum

         mov       bx,offset(Zasobnik-Start+10fh)/16 ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen®en° bloku na minimum
         jnc       Start1                   ; v®e OK

; ------ chyba - nedostatek pamàti

ErrMem:  mov       dx,offset MemTxt         ; text - nedostatek pamàti
Chyba:   mov       ah,9
         int       21h                      ; hl†®en° - nedostatek pamàti
         mov       ax,4cffh
         int       21h                      ; konec programu

; ------ dek¢dov†n° parametrñ z p©°kazovÇho ©†dku

Start1:  call      Dekod                    ; dek¢dov†n° parametrñ z p©°kaz. ©.
         mov       dx,offset HelpTxt        ; text n†povàdy
         jc        Chyba                    ; zobrazen° chyby

; ------ alternativn° pozice

         cmp       word ptr ds:[APozSoub],0 ; zad†na ?
         jne       Start2                   ; zad†na
         mov       ax,ds:[PozSoub]
         mov       ds:[APozSoub],ax         ; alternativn° pozice

; ------ p©°prava cesty ke COMMAND.COM

Start2:  call      ComIni                   ; p©°prava cesty ke COMMAND.COM

; ------ vytvo©en° datovÇho bufferu

         mov       bx,-1
         mov       ah,48h
         int       21h
         cmp       bx,200h                  ; asi tak minimum pamàti
         jb        ErrMem                   ; m†lo pamàti
         mov       ds:[DatSize],bx          ; velikost bufferu
         mov       ah,48h
         int       21h                      ; vytvo©en° max. bufferu
         jc        ErrMem                   ; chyba pamàti
         mov       ds:[DatSegm],ax          ; adresa bufferu

; ------ naáten° souboru seznamu

         call      ReadSezn                 ; naáten° souboru seznamu
         mov       dx,offset SeznTxt        ; text - soubor seznamu nenalezen
         jc        Chyba                    ; chyba áten° souboru

; ------ inicializace textu seznamu

         call      InitSezn                 ; inicializace seznamu souborñ

; ------ £schova obsahu obrazovky

         call      PushScr                  ; £schova obsahu obrazovky



; ====== opakovanò start po n†vratu ze zobrazovaáe

; ------ inicializace videom¢du

Start3:  call      InitVMod                 ; inicializace videom¢du

; ------ instalace obsluhy p©eru®en°

         mov       ax,2523h
         mov       dx,offset Int23
         int       21h                      ; instalace INT 23h


; ====== obsluha vòbàru souborñ

; ------ p©°prava ©†dku s kurzorem

Vyber:   mov       bx,ds:[AktSoub]          ; aktivn° ©†dek
         call      GetSoubr                 ; á°slo skuteánÇho ©†dku
         jc        Vyber0
         mov       ds:[AktRadek],bx         ; skuteánò aktivn° ©†dek

; ------ inicializaán° zobrazen° celÇ obrazovky

Vyber0:  mov       ah,0bh
         int       21h
         call      DispTop                  ; zobrazen° horn°ho ©†dku
         call      DispSezn                 ; zobrazen° seznamu
         call      DispRad                  ; zobrazen° á°sla ©†dku

; ------ vypnut° kurzoru

         call      KurzOff                  ; vypnut° kurzoru

; ------ vstup znaku z kl†vesnice

Vyber1:  xor       ax,ax
         mov       es,ax                    ; ES <- 0
         and       byte ptr es:[418h],not bit7 ; nulov†n° p©°znaku stisku Insert
         mov       ah,1
         int       16h
         jz        Vyber1                   ; áek†n° na stisk kl†vesy
         mov       ah,0
         int       16h                      ; vstup znaku z kl†vesnice

; ------ F1: zobrazen° n†povàdy

         cmp       ah,3bh                   ; F1
         jne       Vyber2
         call      DispHlp                  ; zobrazen° n†povàdy
         mov       ah,0
         int       16h                      ; áek†n° na stisk kl†vesy
         jmp       short Vyber

; ------ p©eru®en° programu ESC

Vyber2:  cmp       al,27
         jne       Vyber3

; ------ p©eru®en° programu Ctrl-Break

         mov       al,255                   ; n†vratovò k¢d
         push      cs
         pop       ds

; ------ n†vrat z programu (AL=n†vratovò k¢d)

Navrat:  push      ax                       ; £schova n†vratovÇho k¢du
         mov       ah,0bh
         int       21h                      ; test p©eru®en° BREAK
         call      PopScr                   ; n†vrat obsahu obrazovky
         pop       ax                       ; n†vratovò k¢d

; ------ p©i ©†dnÇm ukonáen° uloëen° seznamu souborñ

         cmp       al,255                   ; je chyba ?
         je        Navrat3                  ; byla chyba

         push      ax
         call      Uloz                     ; uloëen° souboru
         pop       ax
         jnc       Navrat3                  ; v®e je OK

         mov       dx,offset WritTxt        ; text - soubor nelze uloëit
         mov       ah,9
         int       21h
         mov       al,255                   ; n†vratovò k¢d

; ------ n†vrat z programu (AL=n†vratovò k¢d)

Navrat3: mov       ah,4ch
         int       21h                      ; konec programu OK

; ------ ukonáen° programu ENTER

Vyber3:  cmp       al,13                    ; ukonáen° programu ENTER ?
         jne       Vyber4                   ; nen° ukonáen° programu ENTER

         cmp       byte ptr ds:[Soubor2],0  ; je vòstupn° soubor ?
         je        Vyber31                  ; nen° vòstupn° soubor
         cmp       word ptr ds:[NumOznac],0 ; je nàco oznaáeno ?
         jne       Vyber32                  ; je nàco oznaáeno

Vyber31: mov       si,offset Prikaz2        ; zadanò p©°kaz ENTER
         mov       cx,ds:[Prikaz2N]         ; dÇlka zadanÇho p©°kazu ENTER
         jcxz      Vyber32                  ; nen° ë†dnò p©°kaz
         call      Zobraz                   ; zobrazen° souboru
         jmp       Start3                   ; n†vrat z funkce

Vyber32: mov       al,0                     ; p©°znak - nen° ë†dnò soubor
         cmp       ds:[Soubor2],al          ; je zad†n vòstupn° soubor ?
         jne       Navrat                   ; vòstupn° soubor zad†n
         cmp       word ptr ds:[NumSoub],0  ; je nàjakò soubor ?
         je        Navrat                   ; nen° ë†dnò soubor
         mov       ax,ds:[AktSoub]          ; aktivn° ©†dek
         inc       ax
         cmp       ax,254                   ; maxim†ln° á°slo souboru
         jbe       Navrat                   ; á°slo je OK
         mov       al,254                   ; omezen° á°sla souboru
         jmp       short Navrat             ; n†vrat z programu


; ====== ovl†d†n° seznamu

; ------ dolñ

Vyber4:  mov       cx,ds:[AktSoub]          ; BX <- aktivn° soubor
         cmp       ax,5000h
         jne       Vyber43

Vyber4A: inc       cx                       ; zvò®en° á°sla ©†dku
Vyber40: cmp       cx,ds:[NumSoub]          ; je dal®° ©†dek ?
         jb        Vyber42                  ; je dal®° ©†dek OK
Vyber41: jmp       Vyber                    ; neplatnò povel - dal®° kl†vesa

Vyber42: mov       ds:[AktSoub],cx          ; novò aktivn° soubor
         jmp       Vyber                    ; p©°prava novÇho kurzoru

; ------ nahoru

Vyber43: dec       cx                       ; posun kurzoru nahoru
         cmp       ax,4800h
         je        Vyber40                  ; nahoru

; ------ prvn° ©†dek Home

         xor       cx,cx                    ; prvn° ©†dek
         cmp       ax,4700h                 ; Home
         je        Vyber40
         cmp       ax,7700h                 ; Ctrl-Home
         je        Vyber40
         cmp       ax,8400h                 ; Ctrl-PageUp
         je        Vyber40

; ------ posledn° ©†dek End

         mov       cx,ds:[NumSoub]          ; poáet souborñ
         dec       cx                       ; posledn° ©†dek
         cmp       ax,4f00h
         je        Vyber40                  ; End
         cmp       ax,7500h
         je        Vyber40                  ; Ctrl-End
         cmp       ax,7600h
         je        Vyber40                  ; Ctrl-PageDown

; ------ str†nka dolñ PageDown

         cmp       ax,5100h
         jne       Vyber5

         mov       cx,ds:[MaxRow]           ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; bez jednoho ©†dku
         mov       bx,ds:[AktSoub]          ; aktivn° ©†dek
         push      bx
         call      GetSoubr                 ; adresa ©†dku
         pop       bx
         jc        Vyber58

Vyber46: inc       word ptr ds:[TopRadek]   ; zvò®en° poá†teán°ho ©†dku
         call      NxtRadek                 ; dal®° ©†dek
         test      byte ptr es:[di+1],bit14/bit8 ; je to platnò soubor ?
         jz        Vyber47                  ; nen° platnò soubor
         inc       bx                       ; zvò®en° á°sla ©†dku
         cmp       bx,ds:[NumSoub]          ; je je®tà dal®° soubor ?
         jae       Vyber58                  ; nen° dal®° soubor
         inc       word ptr ds:[AktSoub]    ; zvò®en° aktivn°ho souboru
Vyber47: loop      Vyber46                  ; dal®° posun
         jmp       short Vyber58            ; jsou jië v®echny posuny

; ------ str†nka nahoru PageUp

Vyber5:  cmp       ax,4900h
         jne       Vyber6

         mov       cx,ds:[MaxRow]           ; poáet zobrazenòch ©†dkñ
         dec       cx                       ; bez jednoho ©†dku
         mov       bx,ds:[AktSoub]          ; aktivn° ©†dek
         push      bx
         call      GetSoubr                 ; adresa ©†dku
         mov       dx,bx
         pop       bx
         jc        Vyber58

Vyber54: cmp       word ptr ds:[TopRadek],0
         je        Vyber55
         dec       word ptr ds:[TopRadek]   ; sn°ëen° poá†teán°ho ©†dku
Vyber55: sub       dx,1                     ; sn°ëen° ©†dku s kurzorem
         jc        Vyber58
         xchg      bx,dx
         call      GetRadek                 ; adresa ©†dku
         xchg      bx,dx
         test      byte ptr es:[di+1],bit14/bit8 ; je to platnò soubor ?
         jz        Vyber57                  ; nen° platnò soubor
         or        bx,bx                    ; je jië poá†teán° ©†dek ?
         jz        Vyber58                  ; nen° dal®° soubor
         dec       bx                       ; sn°ëen° á°sla ©†dku
         dec       word ptr ds:[AktSoub]    ; sn°ëen° aktivn°ho souboru
Vyber57: loop      Vyber54                  ; dal®° posun
Vyber58: jmp       short Vyber76            ; jsou jië v®echny posuny

; ------ zmàna oznaáen° jednoho souboru Mezera a Insert

Vyber6:  cmp       al," "                   ; mezera
         je        Vyber62
         cmp       ax,5200h                 ; Insert
         jne       Vyber7
Vyber62: mov       bx,ds:[AktSoub]          ; aktivn° soubor
         call      GetSoubr                 ; adresa ©†dku
         jc        Vyber64
         mov       ax,80ffh                 ; AH=XOR, AL=AND
         call      Oznac                    ; oznaáen° souboru
         mov       cx,ds:[AktSoub]          ; BX <- aktivn° soubor
Vyber64: jmp       Vyber4A                  ; posun kurzoru dolñ

; ------ inverze oznaáen° v®ech souborñ Delete a [*]

Vyber7:  cmp       al,"*"
         je        Vyber71
         cmp       ax,5300h                 ; Delete
         jne       Vyber8
Vyber71: mov       ax,80ffh                 ; AH=XOR, AL=AND
Vyber72: mov       cx,ds:[NumRadku]         ; poáet ©†dkñ celkem
         xor       bx,bx                    ; ukazatel á°sla ©†dku
         call      GetRadek                 ; adresa prvn°ho ©†dku
         jc        Vyber76                  ; nen° ë†dnò ©†dek
Vyber73: call      Oznac                    ; oznaáen° souboru
         call      NxtRadek                 ; dal®° ©†dek
         loop      Vyber73                  ; dal®° ©†dek
Vyber76: jmp       Vyber                    ; novÇ zobrazen° v®eho

; ------ oznaáen° v®ech [+]

Vyber8:  cmp       al,"+"
         jne       Vyber82
         mov       ax,807fh                 ; AH=XOR, AL=AND
         jmp       short Vyber72

; ------ nulov†n° v®ech [-]

Vyber82: cmp       al,"-"
         jne       Vyber9
         mov       ax,07fh                  ; AH=XOR, AL=AND
         jmp       short Vyber72

; ------ kurzor vlevo

Vyber9:  cmp       ax,4b00h
         jne       VyberA
         cmp       word ptr ds:[TopPozic],0 ; je poá†teán° pozice ?
         je        VyberX
         dec       word ptr ds:[TopPozic]
         jmp       short Vyber76

; ------ kurzor vpravo

VyberA:  cmp       ax,4d00h
         jne       VyberB
         cmp       word ptr ds:[TopPozic],500
         jae       VyberX
         inc       word ptr ds:[TopPozic]
         jmp       short Vyber76

; ------ 40 pozic vlevo

VyberB:  cmp       ax,7300h
         jne       VyberC
         sub       word ptr ds:[TopPozic],40
         jnc       Vyber76
         mov       word ptr ds:[TopPozic],0
         jmp       short Vyber76

; ------ 40 pozic vpravo

VyberC:  cmp       ax,7400h
         jne       VyberD
         add       word ptr ds:[TopPozic],40
         cmp       word ptr ds:[TopPozic],500
         jbe       Vyber76
         mov       word ptr ds:[TopPozic],500
         jmp       short Vyber76

; ------ zobrazen° souboru TAB

VyberD:  cmp       al,9
         jne       VyberE
         cmp       byte ptr ds:[Prikaz1N],0  ; je nàjakò p©°kaz ?
         je        VyberX                   ; nen° ë†dnò p©°kaz

         push      word ptr ds:[PozSoub]    ; £schova pozice jmÇna souboru
         mov       ax,ds:[APozSoub]         ; alternativn° pozice jmÇna souboru
         mov       ds:[PozSoub],ax
         mov       si,offset Prikaz1        ; zadanò p©°kaz TAB
         mov       cx,ds:[Prikaz1N]         ; dÇlka zadanÇho p©°kazu TAB
         call      Zobraz                   ; zobrazen° souboru
         pop       word ptr ds:[PozSoub]    ; n†vrat pozice jmÇna souboru
         jmp       Start3                   ; n†vrat z funkce

; ------ Alt-F5 systÇmov† obrazovka

VyberE:  cmp       ax,6c00h
         jne       VyberX
         call      PopScr                   ; n†vrat systÇmovÇ obrazovky
         mov       ah,0
         int       16h                      ; áek†n° na stisk kl†vesy
         jmp       Vyber

VyberX:  jmp       Vyber1

int23:   iret

; *****************************************************************************
;                               Oznac
;                         oznaáen° souboru
; -----------------------------------------------------------------------------
; VSTUP: AL=operace AND (0ffh nebo 7fh)
;        AH=operace XOR (0 nebo 80h)
;        ES:DI=adresa ©†dku
;        DS=datovò segment
; *****************************************************************************

Oznac    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      dx

; ------ test, zda je ©†dek platnò

         test      byte ptr es:[di+1],bit14/bit8 ; je to platnò ©†dek ?
         jz        Oznac9                   ; nen° to platnò ©†dek

; ------ test, zda je soubor oznaáen

         test      byte ptr es:[di+1],bit15/bit8 ; je oznaáen ?
         jz        Oznac3                   ; nen° oznaáen

         push      ax
         call      CtiVel                   ; naáten° velikosti souboru
         sub       word ptr ds:[VelOznac],ax
         sbb       word ptr ds:[VelOznac+2],dx
         dec       word ptr ds:[NumOznac]   ; sn°ëen° á°taáe oznaáenòch souborñ
         jnz       Oznac2
         mov       word ptr ds:[VelOznac],0
         mov       word ptr ds:[VelOznac+2],0
Oznac2:  pop       ax

; ------ proveden° operace oznaáen° souboru

Oznac3:  and       byte ptr es:[di+1],al    ; AND
         xor       byte ptr es:[di+1],ah    ; XOR

; ------ test, zda je po operaci soubor oznaáen

         test      byte ptr es:[di+1],bit15/bit8 ; je oznaáen ?
         jz        Oznac9                   ; nen° oznaáen
         inc       word ptr ds:[NumOznac]   ; zvò®en° á°taáe oznaáenòch souborñ
         call      CtiVel
         add       word ptr ds:[VelOznac],ax
         adc       word ptr ds:[VelOznac+2],dx

; ------ n†vrat registrñ

Oznac9:  pop       dx
         pop       bx
         pop       ax
         ret

Oznac    ENDP

; *****************************************************************************
;                                 CtiVel
;                   naáten° velikosti souboru z ©†dku
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=©†dek
;        DS=datovò segment
; VùSTUP: DX:AX=naátenÇ á°slo
; *****************************************************************************

CtiVel   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      si
         push      bp

; ------ p©°prava st©adaáe á°sla

         xor       cx,cx                    ; st©adaá á°sla LOW
         xor       bx,bx                    ; st©adaá á°sla HIGH

; ------ ukazatele ©†dku

         mov       bp,es:[di]
         and       bp,MASKDELK              ; dÇlka textu ©†dku
         mov       si,di
         inc       si
         add       bp,si                    ; adresa konce ©†dku - 1
         inc       bp                       ; adresa konce ©†dku
         add       si,ds:[PozVel]           ; adresa velikosti
         jc        CtiVel9

; ------ nalezen° zaá†tku á°sla

         mov       dx,12                    ; maxim†ln° poáet znakñ
CtiVel1: call      CtiChr                   ; naáten° dal®°ho znaku
         jc        CtiVel9                  ; je za koncem ©†dku
         cmp       al," "
         je        CtiVel2
         cmp       al,9
         jne       CtiVel3
CtiVel2: dec       dx
         jnz       CtiVel1
CtiVel3: dec       si                       ; n†vrat znaku

; ------ vypu®tàn° znakñ oddàlovaáñ

CtiVel4: call      CtiChr                   ; naáten° dal®°ho znaku
         jc        CtiVel9
         cmp       al,"."
         je        CtiVel4
         cmp       al,","
         je        CtiVel4
         cmp       al,"'"
         je        CtiVel4
         cmp       al,"`"
         je        CtiVel4
         dec       si

; ------ naáten° znaku á°slice

         call      Cti0Num                  ; naáten° á°slice
         jc        CtiVel9

; ------ p©id†n° á°slice ke st©adaái

         push      ax
         mov       ax,10
         mul       bx                       ; vyn†soben° á°sla HIGH
         xchg      ax,bx                    ; BX <- novÇ á°slo HIGH
         mov       ax,10
         mul       cx                       ; vyn†soben° á°sla LOW
         xchg      ax,cx                    ; CX <- novÇ á°slo LOW
         pop       ax
         mov       ah,0
         add       cx,ax                    ; p©iáten° á°sla k LOW
         adc       bx,dx                    ; novÇ á°slo HIGH
         jmp       short CtiVel4            ; dal®° znak

; ------ n†vrat registrñ

CtiVel9: xchg      ax,cx
         mov       dx,bx
         pop       bp
         pop       si
         pop       cx
         pop       bx
         ret

CtiVel   ENDP

; -----------------------------------------------------------------------------
;        naáten° jednÇ á°slice z bufferu ES:SI (konec ©†dku BP)
; -----------------------------------------------------------------------------

Cti0Num  PROC      NEAR

         call      CtiChr                   ; naáten° jednoho znaku z bufferu
         jc        Cti0Num9                 ; nen° dal®° znak
         cmp       al,"9"
         ja        Cti0Num8                 ; nen° platnò znak
         sub       al,"0"
         jae       Cti0Num9                 ; je platn† á°slice OK
Cti0Num8:dec       si                       ; n†vrat neplatnÇho znaku
         stc
Cti0Num9:ret

Cti0Num  ENDP

; -----------------------------------------------------------------------------
;        naáten° jednoho znaku z bufferu ES:SI (konec ©†dku BP)
; -----------------------------------------------------------------------------

CtiChr   PROC      NEAR

         cmp       si,bp                    ; je konec ©†dku ?
         cmc
         jc        CtiChr9                  ; je konec ©†dku
         mov       al,es:[si]               ; naáten° znaku
         inc       si                       ; zvò®en° ukazatele textu
CtiChr9: ret

CtiChr   ENDP

; *****************************************************************************
;                                 Zobraz
;                 vyvol†n° funkce extern°ho zobrazovaáe
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=zadanò p©°kaz
;        CX=dÇlka p©°kazu
;        DS=datovò segment
; niá° v®echny registry kromà DS
; *****************************************************************************

Zobraz   PROC      NEAR

; ------ p©°prava p©°kazovÇho ©†dku

         mov       byte ptr ds:[80h],3      ; p©°prava p©°kazovÇho ©†dku
         mov       word ptr ds:[81h],"c/"
         mov       byte ptr ds:[81h+2]," "

; ------ p©°prava k dek¢dov†n° p©°kazu

         mov       bx,ds:[AktSoub]          ; aktivn° ©†dek
         call      GetSoubr                 ; adresa souboru ES:DI
         jc        Zobraz9                  ; nen° soubor

; ------ naáten° znaku

Zobraz1: jcxz      Zobraz4                  ; konec p©°kazu
         cld
         lodsb                              ; naáten° znaku
         dec       cx                       ; sn°ëen° á°taáe znakñ

; ------ dek¢dov†n° jmÇna souboru

         cmp       al,"@"                   ; je soubor ?
         jne       Zobraz2
         call      UlozFil                  ; uloëen° jmÇna souboru ES:DI
         jmp       short Zobraz1

; ------ uloëen° bàënÇho znaku

Zobraz2: call      UlozChr                  ; uloëen° znaku
         jmp       short Zobraz1

; ------ ukonáen° textu v p©°kazovÇm ©†dku

Zobraz4: mov       bl,ds:[80h]              ; dÇlka p©°kazovÇho ©†dku
         mov       bh,0
         mov       byte ptr ds:[bx+81h],0dh ; oznaáen° konce p©°kaz. ©†dku

         mov       ah,0bh
         int       21h

; ------ zobrazen° systÇmovÇ obrazovky

         call      PopScr                   ; n†vrat obsahu obrazovky

; ------ p©°prava paketu programu

         mov       bx,offset Paket
         mov       ax,ds:[2ch]              ; segment prost©ed°
         mov       ds:[bx],ax               ; segment prost©ed°
         mov       ds:[bx+2+2],ds           ; segment p©°kazovÇho ©†dku
         mov       ds:[bx+6+2],ds           ; segment FCB 1
         mov       ds:[bx+10+2],ds          ; segment FCB 2

; ------ £schova ukazatele z†sobn°ku

         mov       word ptr ds:[Zasob],sp
         mov       word ptr ds:[Zasob+2],ss

; ------ proveden° p©°kazu

         push      ds
         pop       es
         mov       dx,offset ComSpec        ; jmÇno COMMAND.COM
         mov       ax,4b00h
         int       21h                      ; proveden° p©°kazu

; ------ n†vrat ukazatele z†sobn°ku

         mov       ss,word ptr cs:[Zasob+2]
         mov       sp,word ptr cs:[Zasob]
         push      cs
         pop       ds
Zobraz9: ret

Zobraz   ENDP

Zasob    dd        0                        ; uschovanò z†sobn°k

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                      Uloëen° seznamu oznaáenòch souborñ
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                            Uloz
;                uloëen° seznamu do vòstupn°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=chyba z†pisu
; -----------------------------------------------------------------------------
; niá° v®echny registry kromà DS
; *****************************************************************************

Uloz     PROC      NEAR

; ------ test, zda je zad†n vòstupn° soubor

         cmp       byte ptr ds:[Soubor2],0  ; zad†n vòstupn° soubor ?
         jne       Uloz2                    ; vòstupn° soubor zad†n
Uloz1:   ret

; ------ test, zda je oznaáen nàjakò soubor

Uloz2:   cmp       word ptr ds:[NumOznac],0 ; je nàco oznaáeno ?
         jne       Uloz3                    ; je nàco oznaáeno

; ------ nen° nic oznaáeno - adresa aktivn°ho souboru

         mov       bx,ds:[AktSoub]          ; aktivn° ©†dek se souborem
         call      GetSoubr                 ; poskytnut° adresy souboru
         cmc
         jnc       Uloz1                    ; nen° platnò ©†dek

; ------ uloëen° aktivn°ho souboru

         xor       bx,bx                    ; p©°znak, ëe soubor nen° otev©en
         call      UlozDek                  ; uloëen° souboru
         jmp       short Uloz8

; ------ adresa prvn°ho souboru

Uloz3:   xor       di,di                    ; adresa ©†dku
         mov       es,ds:[DatSegm]          ; datovò segment
         xor       bx,bx                    ; p©°znak, ëe soubor nen° otev©en
         mov       cx,ds:[NumRadku]         ; celkovò poáet ©†dkñ

; ------ test, zda je ©†dek oznaáen

Uloz4:   test      byte ptr es:[di+1],bit15/bit8 ; je ©†dek oznaáen ?
         jz        Uloz5                    ; ©†dek nen° oznaáen

; ------ oznaáenò soubor - uloëen° jeho jmÇna

         call      UlozDek                  ; dek¢dov†n° jmÇna souboru

; ------ p©°prava pro dal®° ©†dek

Uloz5:   call      NxtRadek                 ; adresa dal®°ho ©†dku
         loop      Uloz4                    ; dal®° ©†dek

; ------ uzav©en° souboru

Uloz8:   pushf
         or        bx,bx
         jz        Uloz9                    ; soubor nen° otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru
Uloz9:   popf
         ret

Uloz     ENDP

; -----------------------------------------------------------------------------
;                             UlozDek
;                  uloëen° jmÇna jednoho souboru
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa ©†dku k uloëen° jmÇna souboru
;        BX=identifik†tor souboru (0=nen° vytvo©en)
; -----------------------------------------------------------------------------

UlozDek  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ p©°prava jmÇna souboru

         mov       byte ptr ds:[80h],0      ; v bufferu nic nen°
         call      UlozFil                  ; dek¢dov†n° jmÇna souboru

; ------ ukonáen° ©†dku

         push      bx
         mov       bh,0
         mov       bl,ds:[80h]              ; dÇlka textu v bufferu
         mov       word ptr ds:[81h+bx],0a0dh ; konec ©†dku CR/LF
         pop       bx

; ------ vytvo©en° souboru

         or        bx,bx                    ; je soubor jië vytvo©en ?
         jnz       UlozDek3                 ; soubor je jië vytvo©en
         mov       dx,offset Soubor2        ; jmÇno vòstupn°ho souboru
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en° souboru
         jc        UlozDek9                 ; chyba vytvo©en° souboru
         xchg      ax,bx                    ; BX <- identifik†tor souboru

; ------ z†pis ©†dku do souboru

UlozDek3:mov       ch,0
         mov       cl,ds:[80h]              ; dÇlka ©†dku
         inc       cx
         inc       cx                       ; váetnà koncovÇho CR/LF
         mov       dx,81h                   ; zaá†tek textu ©†dku
         mov       ah,40h
         int       21h                      ; z†pis ©†dku do bufferu
         jc        UlozDek9                 ; chyba operace
         cmp       ax,cx                    ; bylo zaps†no v®e ?

; ------ n†vrat registrñ

UlozDek9:pop       dx
         pop       cx
         pop       ax
         ret

UlozDek  ENDP

; -----------------------------------------------------------------------------
;        uloëen° jmÇna souboru z ©†dku ES:DI
; -----------------------------------------------------------------------------

UlozFil  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ adresa konce ©†dku

         mov       si,di                    ; SI <- zaá†tek ©†dku
         mov       dx,es:[si]
         and       dx,MASKDELK              ; dÇlka textu ©†dku
         inc       si
         add       dx,si                    ; adresa konce ©†dku - 1
         inc       dx                       ; adresa konce ©†dku

; ------ adresa zaá†tku jmÇna souboru

         add       si,ds:[PozSoub]          ; adresa jmÇna souboru na ©†dku
         jc        UlozFil9                 ; nen° platnÇ jmÇno

; ------ vypu®tàn° mezer p©ed jmÇnem souboru

         dec       si
UlozFil2:inc       si
         cmp       si,dx                    ; je dal®° znak ?
         jae       UlozFil9                 ; nen° dal®° znak
         mov       al,es:[si]               ; p©ipravenò znak
         cmp       al," "                   ; mezera ?
         je        UlozFil2                 ; vypu®tàn° mezery
         cmp       al,9
         je        UlozFil2

; ------ dek¢dov†n° jmÇna souboru do bufferu

UlozFil3:cmp       si,dx
         jae       UlozFil9                 ; konec textu
         mov       al,es:[si]
         call      TestFile                 ; test, zda je to platnò znak
         jc        UlozFil4                 ; nen° to platnò znak
         inc       si                       ; zvò®en° ukazatele textu
         call      UlozChr                  ; uloëen° znaku do bufferu
         jmp       short UlozFil3           ; dal®° znak

; ------ p©°prava adresy p©°pony jmÇna souboru

UlozFil4:mov       bx,di                    ; zaá†tek ©†dku
         inc       bx                       ; zaá†tek textu ©†dku - 1
         add       bx,ds:[PozExt]           ; adresa p©°pony
         jc        UlozFil9                 ; nen° platn† p©°pona
         cmp       bx,si                    ; je za koncem jmÇna souboru ?
         jbe       UlozFil9                 ; nen° za koncem jmÇna souboru
         mov       si,bx                    ; SI <- novò ukazatel textu

; ------ test, zda je p©°pona

         cmp       si,dx
         jae       UlozFil9                 ; nen° dal®° znak
         mov       al,es:[si]               ; p©ipravenò znak
         call      TestFile                 ; test znaku
         jc        UlozFil9                 ; nen° dal®° platnò znak
         mov       al,"."
         call      UlozChr                  ; uloëen° oddàlovac° teáky

; ------ dek¢dov†n° jmÇna souboru do bufferu

UlozFil6:cmp       si,dx
         jae       UlozFil9                 ; konec textu
         mov       al,es:[si]
         call      TestFile                 ; test, zda je to platnò znak
         jc        UlozFil9                 ; nen° to platnò znak
         inc       si                       ; zvò®en° ukazatele textu
         call      UlozChr                  ; uloëen° znaku do bufferu
         jmp       short UlozFil6           ; dal®° znak

; ------ n†vrat registrñ

UlozFil9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

UlozFil  ENDP

; -----------------------------------------------------------------------------
;        test znaku AL, zda je to platnò znak jmÇna souboru (CY=nen°)
; -----------------------------------------------------------------------------

TestFile PROC      NEAR

         cmp       al,'"'
         je        TestFil8
         cmp       al,","
         je        TestFil8
         cmp       al,";"
         je        TestFil8
         cmp       al,"<"
         je        TestFil8
         cmp       al,"="
         je        TestFil8
         cmp       al,">"
         je        TestFil8
         cmp       al,"["
         je        TestFil8
         cmp       al,"]"
         je        TestFil8
         cmp       al,"≥"
         je        TestFil8
         cmp       al,"∫"
         je        TestFil8
         cmp       al,"∞"
         je        TestFil8
         cmp       al,"±"
         je        TestFil8
         cmp       al,"≤"
         je        TestFil8
         cmp       al," "+1
         jae       TestFil9
TestFil8:stc                                ; p©°znak - nen° platnò znak
TestFil9:ret

TestFile ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku AL do p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------

UlozChr  PROC      NEAR

         push      bx
         mov       bh,0
         mov       bl,ds:[80h]              ; poáet znakñ v p©°kazovÇm ©†dku
         cmp       bl,127-2                 ; je jië buffer plnò ?
         jae       UlozChr6                 ; buffer je jië plnò
         mov       ds:[bx+81h],al           ; uloëen° znaku do bufferu
         inc       byte ptr ds:[80h]        ; zvò®en° dÇlky p©°kazovÇho ©†dku
UlozChr6:pop       bx
         ret

UlozChr  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                         Obsluha vstupn°ho seznamu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                              ReadSezn
;                    naáten° vstupn°ho seznamu souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=soubor nenalezen nebo chyba áten°
; -----------------------------------------------------------------------------
; niá° v®echny registry kromà DS
; *****************************************************************************

ReadSezn PROC      NEAR

; ------ otev©en° zadanÇho souboru seznamu

         mov       dx,offset Soubor1        ; text souboru seznamu
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        ReadSzn9                 ; chyba - soubor nenalezen
         xchg      ax,bx                    ; BX <- identifik†tor souboru

; ------ p©°prava ukazatelñ k naáten° souboru

         mov       si,ds:[DatSize]          ; velikost segmentu dat
         mov       di,ds:[DatSegm]          ; segment dat seznamu
         mov       dx,2                     ; poá†teán° offset v bufferu

; ------ p©°prava velikosti jednoho bloku k naáten°

ReadSzn2:mov       cx,0e00h                 ; velikost jednoho bloku (odstavcñ)
         cmp       cx,si                    ; zbòv† mÇnà m°sta ?
         jbe       ReadSzn3                 ; zbòv† dost m°sta
         mov       cx,si                    ; omezen° velikosti m°sta
ReadSzn3:jcxz      ReadSzn6                 ; je plnò buffer (zde je NC)
         shl       cx,1
         shl       cx,1
         shl       cx,1
         shl       cx,1                     ; p©evod na bajty
         sub       cx,dx                    ; bez poá†teán°ho offsetu

; ------ naáten° jednoho bloku dat

         push      ds
         mov       ds,di                    ; DS <- segment bufferu
         mov       ah,3fh
         int       21h                      ; naáten° bloku dat
         pop       ds
         jc        ReadSzn6                 ; nàjak† chyba

; ------ zvò®en° á°taáe dat

         or        ax,ax                    ; bylo nàco naáteno ?
         jz        ReadSzn6                 ; je konec souboru
         add       word ptr ds:[DatByte],ax ; zvò®en° á°taáe dat v bufferu
         adc       word ptr ds:[DatByte+2],0

; ------ zvò®en° ukazatele v bufferu

         add       dx,ax                    ; zvò®en° offsetu ukazatele dat
         mov       ax,dx                    ; AX <- offset ukazatele dat
         and       dx,0fh                   ; normalizace offsetu
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; normalizace segmentu
         add       di,ax                    ; zvò®en° ukazatele segmentu
         sub       si,ax                    ; sn°ëen° ukazatele zbytku bufferu
         jmp       short ReadSzn2           ; dal®° blok dat

; ------ uzav©en° souboru

ReadSzn6:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ zmen®en° bufferu na minimum

         mov       es,ds:[DatSegm]          ; datovò segment
         sub       di,ds:[DatSegm]          ; velikost bufferu
         or        dx,dx                    ; je p©esah ?
         jz        ReadSzn7                 ; nen° p©esah
         inc       di                       ; zvò®en° velikosti
ReadSzn7:mov       bx,di                    ; BX <- velikost bufferu
         mov       ds:[DatSize],bx          ; nov† velikost bufferu
         mov       ah,4ah
         int       21h                      ; zmen®en° datovÇho bloku
         popf

ReadSzn9:ret

ReadSezn ENDP

; *****************************************************************************
;                            InitSezn
;                    inicializace seznamu souborñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------
; niá° v®echny registry kromà DS
; *****************************************************************************

InitSezn PROC      NEAR

; ------ p©°prava registrñ k adresaci ©†dkñ textu

         xor       di,di                    ; DI <- adresa poá†tku ©†dku
         mov       es,ds:[DatSegm]          ; ES <- segment poá†tku ©†dku
         mov       cx,word ptr ds:[DatByte] ; poáet bajtñ v bufferu LOW - 1
         mov       bx,word ptr ds:[DatByte+2] ; poáet bajtñ v bufferu HIGH

; ------ normalizace adresy poá†tku ©†dku

InitSzn1:call      NormESDI                 ; normalizace adresy ES:DI

; ------ p©°prava ukazatele textu ©†dku

         mov       si,di
         inc       si
         inc       si                       ; SI <- zaá†tek textu ©†dku
         sub       cx,2                     ; sn°ëen° á°taáe dat
         sbb       bx,0
         jc        InitSzn5                 ; konec dat souboru
         xor       ax,ax                    ; AX <- 0 ukazatel dÇlky ©†dku

; ------ zvò®en° á°taáe ©†dkñ

         inc       word ptr ds:[NumRadku]   ; zvò®en° á°taáe ©†dkñ
         jnz       InitSzn2                 ; dal®° ©†dek
         dec       word ptr ds:[NumRadku]   ; oprava p©i p©eteáen° ©†dkñ
         jmp       short InitSzn5           ; p©eteáen° - konec

; ------ test, zda je konec ©†dku

InitSzn2:cmp       word ptr es:[si],0a0dh   ; CR/LF ?
         je        InitSzn3                 ; konec ©†dku
         cmp       word ptr es:[si],0d0ah   ; LF/CR ?
         je        InitSzn3                 ; konec ©†dku

; ------ zvò®en° ukazatele adresy textu ©†dku

         inc       ax                       ; zvò®en° á°taáe dÇlky ©†dku
         inc       si                       ; nen° konec - zvò®en° ukazatele
         sub       cx,1                     ; sn°ëen° á°taáe zbylòch dat
         sbb       bx,0
         jc        InitSzn4                 ; konec dat v bufferu

; ------ kontrola maxim†ln° dÇlky ©†dku

         cmp       ax,MASKDELK-2            ; maxim†ln° dÇlka ©†dku
         jb        InitSzn2                 ; dÇlka je je®tà OK
         dec       ax
         dec       ax
         dec       si                       ; rezerva 2 znaky
         dec       si
         add       cx,2                     ; oprava á°taáe dat
         adc       bx,0

; ------ uloëen° dÇlky ©†dku

InitSzn3:mov       es:[di],ax               ; nastaven° offsetu dal®°ho ©†dku
         mov       di,si                    ; DI <- adresa dal®°ho ©†dku
         jmp       short InitSzn1           ; dal®° ©†dek

InitSzn4:mov       es:[di],ax               ; dÇlka posledn°ho ©†dku

; ------ p©°prava k testu ©†dkñ

InitSzn5:xor       di,di                    ; DI <- adresa poá†tku ©†dku
         mov       es,ds:[DatSegm]          ; ES <- segment poá†tku ©†dku
         mov       bx,ds:[NumRadku]         ; celkovò poáet ©†dkñ
         sub       bx,ds:[PatSoub]          ; odeáten° ©†dkñ paty
         jbe       InitSzn9                 ; nezbyly ë†dnÇ ©†dky
         xor       bp,bp                    ; BP <- 0 ukazatel á°sla ©†dku

; ------ p©°prava ukazatelñ ©†dku

InitSzn6:mov       si,di                    ; SI <- zaá†tek ©†dku
         mov       cx,es:[si]
         and       cx,MASKDELK              ; CX <- dÇlka ©†dku
         inc       si
         inc       si                       ; zaá†tek textu ©†dku

; ------ test, zda je ©†dek platnò

         cmp       bp,ds:[TopSoub]          ; je to platnò ©†dek ?
         jb        InitSzn8                 ; nen° to platnò ©†dek

; ------ test, zda se prov†d° test ©†dkñ

         cmp       word ptr ds:[PozDat],0   ; zad†na pozice data ?
         je        InitSz64                 ; pozice data nezad†na
         cmp       cx,ds:[PozDat]           ; vyhovuje dÇlka ©†dku ?
         jbe       InitSzn8                 ; dÇlka ©†dku nevyhovuje
         call      TestDat                  ; test data
         jc        InitSzn8                 ; datum nevyhovuje

InitSz64:cmp       word ptr ds:[PozTim],0   ; zad†na pozice áasu ?
         je        InitSz66                 ; pozice áasu nezad†na
         cmp       cx,ds:[PozTim]           ; vyhovuje dÇlka ©†dku ?
         jbe       InitSzn8                 ; dÇlka ©†dku nevyhovuje
         call      TestTim                  ; test áasu
         jc        InitSzn8                 ; áas nevyhovuje

InitSz66:cmp       cx,ds:[PozSoub]          ; vyhovuje pro jmÇno souboru ?
         jbe       InitSzn8                 ; dÇlka ©†dku nevyhovuje

; ------ oznaáen° platnÇho ©†dku

InitSzn7:or        byte ptr es:[di+1],bit14/bit8 ; je to platnò ©†dek
         inc       word ptr ds:[NumSoub]    ; zvò®en° á°taáe platnòch ©†dkñ
         cmp       word ptr ds:[AktRadek],-1 ; byl jië aktivn° ©†dek uráen ?
         jne       InitSzn8                 ; byl jië uráen
         mov       ds:[AktRadek],bp         ; aktivn° ©†dek

; ------ adresa dal®°ho ©†dku

InitSzn8:mov       ax,es:[di]               ; dÇlka ©†dku
         inc       di
         inc       di
         and       ax,MASKDELK              ; dÇlka ©†dku
         add       di,ax                    ; adresa dal®°ho ©†dku

; ------ normalizace adresy ©†dku

         mov       ax,di                    ; offset ©†dku
         and       di,0fh                   ; normalizace offsetu ©†dku
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         mov       dx,es
         add       ax,dx
         mov       es,ax                    ; ES <- segment adresy ©†dku

; ------ á°t†n° ©†dkñ

         inc       bp                       ; zvò®en° ukazatele á°sla ©†dku
         dec       bx                       ; á°t†n° ©†dkñ
         jnz       InitSzn6                 ; test dal®°ho ©†dku

InitSzn9:ret

InitSezn ENDP

; -----------------------------------------------------------------------------
;        test data ©†dku ES:SI/dÇlka CX
; -----------------------------------------------------------------------------

TestDat  PROC      NEAR

         push      ax
         push      cx
         push      si

         dec       si
         inc       cx
         add       si,ds:[PozDat]
         sub       cx,ds:[PozDat]
         jb        TestDat9

;         call      TestSpc                  ; vypu®tàn° mezery

         call      Test2Nm                  ; test 2 á°slic
         jc        TestDat9
         call      Test2Nm                  ; vypu®tàn° p©°padnòch 2 á°slic roku
         call      TestOdd                  ; test oddàlovaáe
         jc        TestDat9
         call      Test2Nm                  ; test 2 á°slic

TestDat9:pop       si
         pop       cx
         pop       ax
         ret

TestDat  ENDP

; -----------------------------------------------------------------------------
;        test áasu ©†dku ES:SI/dÇlka CX
; -----------------------------------------------------------------------------

TestTim  PROC      NEAR

         push      ax
         push      cx
         push      si

         dec       si
         inc       cx
         add       si,ds:[PozTim]
         sub       cx,ds:[PozTim]
         jb        TestTim9

;         call      TestSpc                  ; vypu®tàn° mezery

         call      Test2Nm                  ; test 2 á°slic
         jc        TestTim9
         call      TestOdd                  ; test oddàlovaáe
         jc        TestTim9
         call      Test2Nm                  ; test 2 á°slic

TestTim9:pop       si
         pop       cx
         pop       ax
         ret

TestTim  ENDP

; -----------------------------------------------------------------------------
;        test á°sla 1 aë 2 znaky
; -----------------------------------------------------------------------------

Test2Nm  PROC      NEAR

         call      TestSpc                  ; test mezery
         jnc       Test2Nm2                 ; je mezera
         call      Test0Nm                  ; test 1. á°slice
         jc        Test2Nm4
Test2Nm2:call      Test0Nm                  ; test 2. á°slice
Test2Nm4:ret

Test2Nm  ENDP

; -----------------------------------------------------------------------------
;        test 1 á°slice ES:SI
; -----------------------------------------------------------------------------

Test0Nm  PROC      NEAR

         stc
         jcxz      Test0Nm2
         mov       al,es:[si]
         cmp       al,"0"
         jb        Test0Nm2
         cmp       al,"9"+1
         cmc
         jc        Test0Nm2
         inc       si
         dec       cx
Test0Nm2:ret

Test0Nm  ENDP

; -----------------------------------------------------------------------------
;        test jednÇ mezery (CY=nen° mezera)
; -----------------------------------------------------------------------------

TestSpc  PROC      NEAR

         stc
         jcxz      TestSpc9
         cmp       byte ptr es:[si],9
         je        TestSpc4
         cmp       byte ptr es:[si]," "
         stc
         jne       TestSpc9
TestSpc4:inc       si
         dec       cx
         clc
TestSpc9:ret

TestSpc  ENDP

; -----------------------------------------------------------------------------
;        test oddàlovaáe v datu nebo áasu
; -----------------------------------------------------------------------------

TestOdd  PROC      NEAR

         stc
         jcxz      TestOdd9

         mov       al,es:[si]
         cmp       al,"."
         je        TestOdd8
         cmp       al,":"
         je        TestOdd8
         cmp       al,"/"
         je        TestOdd8
         cmp       al,"\"
         je        TestOdd8
         cmp       al,"-"
         je        TestOdd8
         cmp       al,";"
         je        TestOdd8
         cmp       al,","
         stc
         jne       TestOdd9
TestOdd8:inc       si
         dec       cx
         clc
TestOdd9:ret

TestOdd  ENDP

; *****************************************************************************
;                               GetSoubr
;                      poskytnut° adresy ©†dku souboru
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo ©†dku souboru
;        DS=datovò segment
; VùSTUP: ES:DI=adresa ©†dku
;         BX=á°slo skuteánÇho ©†dku
;         CY=nen° platnò ©†dek
; *****************************************************************************

GetSoubr PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ adresa prvn°ho ©†dku

         xor       di,di                    ; adresa prvn°ho ©†dku
         mov       es,ds:[DatSegm]          ; segment bufferu
         mov       cx,bx                    ; CX <- á°slo poëadovanÇho ©†dku

; ------ test, zda to je platnò ©†dek

         xor       bx,bx                    ; ukazatel á°sla skuteánÇho ©†dku
         cmp       cx,ds:[NumSoub]          ; je to platnò ©†dek ?
         cmc
         jc        GetSoub9                 ; nen° to platnò ©†dek

; ------ nalezen° adresy ©†dku

GetSoub2:test      byte ptr es:[di+1],bit14/bit8 ; je to platnò ©†dek ?
         jz        GetSoub3                 ; nen° platnò ©†dek
         jcxz      GetSoub9                 ; ©†dek nalezen
         dec       cx                       ; sn°ëen° á°taáe souborñ
GetSoub3:call      NxtRadek                 ; adresa dal®°ho ©†dku
         inc       bx                       ; zvò®en° ukazatele ©†dkñ
         jmp       short GetSoub2           ; nalezen° adresy ©†dku

; ------ n†vrat registrñ

GetSoub9:pop       cx
         pop       ax
         ret

GetSoubr ENDP

; *****************************************************************************
;                               GetRadek
;                        poskytnut° adresy ©†dku
; -----------------------------------------------------------------------------
; VSTUP: BX=á°slo ©†dku
;        DS=datovò segment
; VùSTUP: ES:DI=adresa ©†dku
;         CY=nen° platnò ©†dek
; *****************************************************************************

GetRadek PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ adresa prvn°ho ©†dku

         xor       di,di                    ; adresa prvn°ho ©†dku
         mov       es,ds:[DatSegm]          ; segment bufferu
         mov       cx,bx                    ; CX <- á°slo poëadovanÇho ©†dku

; ------ test, zda to je platnò ©†dek

         cmp       cx,ds:[NumRadku]         ; je to platnò ©†dek ?
         cmc
         jc        GetRadk9                 ; nen° to platnò ©†dek

; ------ nalezen° adresy ©†dku

         jcxz      GetRadk9                 ; je to prvn° ©†dek
GetRadk2:call      NxtRadek                 ; adresa dal®°ho ©†dku
         loop      GetRadk2                 ; nalezen° adresy ©†dku
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

GetRadk9:pop       cx
         pop       ax
         ret

GetRadek ENDP

; *****************************************************************************
;                               NxtRadek
;                    adresa dal®°ho ©†dku (bez kontroly p©eteáen°)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=adresa poá†tku ©†dku
; VùSTUP: ES:DI=adresa dal®°ho ©†dku
; *****************************************************************************

NxtRadek PROC      NEAR

         push      ax
         mov       ax,es:[di]
         and       ax,MASKDELK              ; maska dÇlky
         inc       di
         inc       di
         add       di,ax                    ; adresa dal®°ho ©†dku
         pop       ax
                                          ;* n†sleduje NormESDI !!!
NxtRadek ENDP

; *****************************************************************************
;                                 NormESDI
;                    normalizace ukazatele ES:DI
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=ukazatel k normalizaci
; *****************************************************************************

NormESDI PROC      NEAR

         push      ax
         push      bx

         mov       ax,di                    ; AX <- offset
         and       di,0fh                   ; normalizace offset
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; normalizace segmentu
         mov       bx,es                    ; DX <- segment
         add       ax,bx
         mov       es,ax                    ; ES <- novò segment

         pop       bx
         pop       ax
         ret

NormESDI ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                   Zobrazen° jednotlivòch á†st°
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                            DispHlp
;                       zobrazen° n†povàdy
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispHlp  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

; ------ p©°prava registrñ

         push      ds
         pop       es                       ; ES <- DS
         mov       si,offset Help           ; text n†povàdy
         mov       dl,(80 - HelpSir)/2      ; poá†teán° pozice
         mov       dh,byte ptr ds:[MaxRow]  ; posledn° ©†dek
         mov       bx,HelpVys               ; poáet ©†dkñ n†povàdy
         sub       dh,bl                    ; odeáten° vò®ky
         shr       dh,1                     ; poá†teán° ©†dek
         mov       ah,ds:[Col5]             ; bàën† barva n†povàdy

; ------ zobrazen° textu n†povàdy

DispHlp1:mov       cx,HelpSir               ; poáet pozic na ©†dek
         call      DispTxt                  ; zobrazen° jednoho ©†dku n†povàdy

; ------ zobrazen° st°nu za oknem vpravo (na dal®° ©†dek)

         inc       dh                       ; zvò®en° á°sla ©†dku
         add       si,cx                    ; adresa dal®°ho ©†dku
         mov       cl,2                     ; ®°©ka st°nu
         call      DispStin                 ; zobrazen° st°nu

; ------ p©°prava pro dal®° ©†dek

         sub       dl,HelpSir               ; n†vrat pozice
         dec       bx                       ; sn°ëen° á°taáe ©†dkñ
         jnz       DispHlp1                 ; zobrazen° dal®°ho ©†dku

; ------ zobrazen° st°nu pod oknem

         add       dl,2                     ; poá†teán° pozice
         mov       cl,HelpSir-2             ; ®°©ka
         call      DispStin                 ; zobrazen° st°nu

; ------ n†vrat registrñ

         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispHlp  ENDP

; *****************************************************************************
;                            DispTop
;                    zobrazen° horn°ho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispTop  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava oznaáenÇ kapacity souborñ

         push      ds
         pop       es                       ; ES <- DS
         mov       cx,12
         mov       al," "
         mov       di,offset InfTxt1        ; buffer k dek¢dov†n° velikosti
         cld
         rep       stosb                    ; vymaz†n° bufferu
         mov       ax,word ptr ds:[VelOznac] ; oznaáen† kapacita
         mov       dx,word ptr ds:[VelOznac+2]
         call      DispNum                  ; dek¢dov†n° á°sla do bufferu

; ------ zobrazen° textu n†povàdy v levÇm horn°m rohu

         mov       si,offset InfTxt         ; informaán° text
         or        ax,dx                    ; jsou oznaáenÇ soubory ?
         jz        DispTop1                 ; nejsou oznaáenÇ soubory
         mov       si,offset InfTxt1        ; buffer s oznaáenou kapacitou
DispTop1:mov       cx,offset(InfTxt0-InfTxt) ; dÇlka informaán°ho textu
         mov       ah,ds:[Col5]             ; bàën† barva n†povàdy
         xor       dx,dx                    ; poá†teán° pozice
         call      DispTxt                  ; zobrazen° informaán°ho ©†dku

; ------ zobrazen° textu vòzvy (n†povàdy)

         mov       si,offset Vyzva          ; text vòzvy
         mov       cx,ds:[VyzvaN]           ; dÇlka textu vòzvy
         cmp       cl,80 - offset(InfTxt3-InfTxt2) - offset(InfTxt0-InfTxt)
         jb        DispTop2                 ; dÇlka textu je OK
         mov       cl,80 - offset(InfTxt3-InfTxt2) - offset(InfTxt0-InfTxt)
DispTop2:or        cx,cx                    ; je nàjakò text ?
         jnz       DispTop3                 ; je nàjakò text
         mov       si,offset InfTxt0        ; implicitn° n†povàda
         mov       cl,offset(InfTxt1-InfTxt0) ; dÇlka textu n†povàdy
DispTop3:mov       ah,ds:[Col6]             ; zvòraznàn† n†povàda
         call      DispTxt                  ; zobrazen° textu vòzvy

; ------ vymaz†n° zbytku ©†dku

         mov       cl,80 - offset(InfTxt3-InfTxt2) ; dÇlka ©†dku
         sub       cl,dl                    ; poáet zbylòch znakñ
         mov       al," "                   ; znak mezery
         call      DispChr                  ; vymaz†n° zbytku ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispTop  ENDP

; *****************************************************************************
;                                DispRad
;                        zobrazen° á°sla ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispRad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ inicializaán° vymaz†n° bufferu

         cld
         push      ds
         pop       es
         mov       di,offset InfTxt2+1      ; buffer k dek¢dov†n° á°sla
         mov       al," "
         mov       cx,offset(InfTxt3-InfTxt2)-1
         rep       stosb                    ; vymaz†n° bufferu

; ------ dek¢dov†n° ukazatele ©†dku

         xor       dx,dx
         mov       ax,ds:[AktSoub]          ; aktivn° ©†dek seznamu
         inc       ax                       ; korekce á°sla souboru
         call      DispNum                  ; dek¢dov†n° á°sla souboru

; ------ oddàlovac° znak

         dec       di
         mov       byte ptr es:[di],"/"

; ------ dek¢dov†n° poátu oznaáenòch ©†dkñ

         mov       ax,ds:[NumOznac]         ; poáet oznaáenòch ©†dkñ
         call      DispNum                  ; dek¢dov†n° poátu souborñ

; ------ zobrazen° textu

         mov       si,offset InfTxt2        ; buffer s textem
         mov       ah,ds:[Col5]             ; bàën† barva n†povàdy
         mov       cl,offset(InfTxt3-InfTxt2) ; poáet znakñ k zobrazen°
         mov       dx,80 - offset(InfTxt3-InfTxt2) ; pozice k zobrazen° textu
         call      DispTxt                  ; zobrazen° textu

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DispRad  ENDP

; *****************************************************************************
;                               DispNum
;                     dek¢dov†n° á°sla do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=á°slo k dek¢dov†n°
;        ES:DI=konec za bufferem k dek¢dov†n° á°sla
; VSTUP: ES:DI=ukazatel na prvn° znak á°sla v bufferu
; *****************************************************************************

DispNum  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ dek¢dov†n° jednÇ á°slice

         xor       cx,cx                    ; ukazatel á°sla ©†du
         mov       bx,10
DispNum1:xchg      ax,si                    ; SI <- £schova á°sla LOW
         xor       ax,ax                    ; AX <- 0
         xchg      ax,dx                    ; AX <- á°slo HIGH, DX <- 0
         div       bx                       ; á°slo HIGH / 10
         xchg      ax,si                    ; AX <- á°slo LOW, SI <- novÇ HIGH
         div       bx                       ; á°slo LOW / 10

; ------ uloëen° á°slice do bufferu

         dec       di                       ; sn°ëen° ukazatele bufferu
         cmp       cl,3
         je        DispNum2
         cmp       cl,6
         jne       DispNum3
DispNum2:mov       byte ptr es:[di],"."     ; oddàlovaá ©†dñ
         dec       di
DispNum3:add       dl,"0"                   ; korekce na znak ASCII
         mov       es:[di],dl               ; uloëen° znaku do bufferu
         inc       cx                       ; zvò®en° á°taáe ©†dñ

; ------ test, zda je á°slo jië = 0

         mov       dx,si                    ; DX <- novÇ HIGH
         or        si,ax                    ; je á°slo jië = 0 ?
         jnz       DispNum1                 ; á°slo je®tà nen° = 0

; ------ n†vrat registrñ

DispNum9:pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; *****************************************************************************
;                               DispSezn
;                         zobrazen° seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

DispSezn PROC      NEAR

; ------ normalizace seznamu p©ed zobrazen°m

         call      NormSezn                 ; normalizace seznamu

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         mov       dh,1                     ; poá†teán° ©†dek k zobrazen°
         mov       bx,ds:[TopRadek]         ; prvn° zobrazenò ©†dek
         mov       es,ds:[DatSegm]          ; segment se souborem
         call      GetRadek                 ; nalezen° adresy ©†dku -> ES:DI

; ------ p©°prava barvy ©†dku podle kurzoru

DispSzn1:mov       ax,word ptr ds:[Col1]    ; bàën† barva
         cmp       bx,ds:[AktRadek]         ; je to ©†dek s kurzorem ?
         jne       DispSzn2                 ; nen° ©†dek s kurzorem
         mov       ax,word ptr ds:[Col3]    ; kurzor

; ------ rozli®en°, zda je ©†dek oznaáenò

DispSzn2:test      byte ptr es:[di+1],bit15/bit8 ; je ©†dek oznaáenò ?
         jnz       DispSzn3                 ; ©†dek je oznaáenò
         mov       ah,al                    ; barva pro neoznaáenò ©†dek

; ------ kontrola, zda je platnò ©†dek

DispSzn3:mov       dl,0                     ; poá†teán° pozice na ©†dku
         cmp       bx,ds:[NumRadku]         ; p©ekroáen posledn° ©†dek ?
         jae       DispSzn6                 ; p©ekroáen posledn° ©†dek

; ------ stanoven° dÇlky ©†dku

         mov       si,di
         mov       cx,es:[di]               ; dÇlka ©†dku
         and       cx,MASKDELK              ; maskov†n° dÇlky textu ©†dku
         sub       cx,ds:[TopPozic]         ; odeáten° poá†teán° pozice
         jbe       DispSzn5                 ; nic se nezobraz°
         add       si,ds:[TopPozic]         ; posun adresy ©†dku
         cmp       cx,80                    ; p©ekroáena dÇlka ©†dku ?
         jbe       DispSzn4                 ; dÇlka ©†dku je OK
         mov       cx,80                    ; omezen° dÇlky ©†dku

; ------ zobrazen° textu ©†dku

DispSzn4:inc       si
         inc       si                       ; zaá†tek textu
         call      DispTxt                  ; zobrazen° textu ©†dku

; ------ adresa dal®°ho ©†dku

DispSzn5:call      NxtRadek                 ; adresa dal®°ho ©†dku
         inc       bx                       ; zvò®en° á°sla ©†dku

; ------ doplnàn° zbytku ©†dku mezerou

DispSzn6:mov       cx,80                    ; dÇlka ©†dku obrazovky
         sub       cl,dl                    ; zbytek do konce ©†dku
         mov       al," "                   ; znak mezery k vymaz†n°
         call      DispChr                  ; vymaz†n° zbytku ©†dku

; ------ p©°prava pro dal®° ©†dek

         inc       dh                       ; zvò®en° ukazatele ©†dku
         cmp       dh,byte ptr ds:[MaxRow]  ; je jië posledn° ©†dek ?
         jbe       DispSzn1                 ; zobrazen° dal®°ho ©†dku

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispSezn ENDP

; *****************************************************************************
;                                NormSezn
;                           normalizace seznamu
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

NormSezn PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx

; ------ parametry seznamu

         mov       ax,ds:[AktRadek]         ; aktivn° ©†dek s kurzorem
         mov       bx,ds:[TopRadek]         ; prvn° zobrazenò ©†dek
         mov       cx,ds:[MaxRow]           ; poáet zobrazenòch ©†dkñ
         mov       dx,ds:[NumRadku]         ; celkovò poáet ©†dkñ seznamu

; ------ jsou zobrazeny v®echny soubory

         sub       dx,cx                    ; maxim†ln° zaá†tek okna
         jbe       NormSzn3                 ; je malò poáet ©†dkñ

; ------ ohraniáen° shora

         sub       ax,REZERVA               ; rezerva na horn°m okraji
         jbe       NormSzn3                 ; je zaá†tek
         cmp       ax,bx                    ; je nad horn°m okrajem ?
         jb        NormSzn4                 ; je nad horn°m okrajem

; ------ ohraniáen° zdola

         add       ax,2*REZERVA+1           ; n†vrat pozice + okraj
         sub       ax,cx                    ; korekce, pokud je pod doln°m okr.
         jbe       NormSzn2                 ; nen° je®tà pod doln°m okrajem
         cmp       ax,bx                    ; je pod doln°m okrajem ?
         jae       NormSzn4                 ; je pod doln°m okrajem
NormSzn2:mov       ax,bx                    ; poá†tek
         jmp       short NormSzn4           ; je konec okna

; ------ je zaá†tek okna

NormSzn3:xor       ax,ax                    ; n†hradn° zaá†tek okna
         xor       dx,dx                    ; maxim†ln° zaá†tek okna

; ------ kontrola maxim†ln°ho zaá†tku

NormSzn4:cmp       ax,dx                    ; p©ekroáen maxim†ln° zaá†tek ?
         jbe       NormSzn6                 ; nen° p©ekroáen maxim†ln° zaá†tek
         mov       ax,dx                    ; maxim†ln° zaá†tek

; ------ novò poá†tek okna

NormSzn6:mov       ds:[TopRadek],ax           ; novò poá†tek okna

; ------ n†vrat registrñ

NormSzn9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

NormSezn ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                 Inicializace a obsluha displeje
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                               PopScr
;                        n†vrat obsahu obrazovky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PopScr   PROC      NEAR

; ------ p©°prava velikosti videopamàti (ve slovech)

         mov       al,80                    ; poáet znakñ na ©†dek
         mul       byte ptr ds:[MaxRow]     ; poáet znakñ na obrazovku
         add       ax,80                    ; + 1 ©†dek

; ------ n†vrat obsahu obrazovky

         push      ds
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       cx,ds:[SizDisp]          ; velikost bufferu/2
         mov       ds,ds:[SegDisp]          ; segment bufferu
         xor       si,si
         cld
         sub       ax,cx                    ; zbytek obrazovky (slov)
         rep       movsw                    ; n†vrat obsahu obrazovky
         pop       ds

; ------ vymaz†n° zbytku videopamàti

         jbe       PopScr2                  ; nen° co mazat
         xchg      ax,cx                    ; CX <- poáet zbylòch pozic
         mov       ax,720h                  ; mazac° znak
         rep       stosw                    ; vymaz†n° zbytku obrazovky

; ------ n†vrat pozice kurzoru

PopScr2: mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,2
         mov       dx,ds:[OldKurz]          ; pñvodn° kurzor
         cmp       dh,byte ptr ds:[MaxRow]  ; je ©†dek OK ?
         jbe       PopScr3                  ; ©†dek je OK
         mov       dh,byte ptr ds:[MaxRow]  ; omezen° ©†dku
PopScr3: call      Int10                    ; n†vrat pozice kurzoru
         ret

PopScr   ENDP

; *****************************************************************************
;                             PushScr
;                    £schova obsahu obrazovky
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

PushScr  PROC      NEAR

; ------ p©°prava parametrñ displeje

         call      DetPDisp                 ; detekce parametrñ displeje
         jc        PushScr9                 ; nepovolenò videom¢d

; ------ £schova pozice kurzoru

         mov       bh,ds:[AktPage]          ; aktivn° videostr†nka
         mov       ah,3
         call      Int10                    ; poskytnut° parametrñ kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru

; ------ p©°prava poëadovanÇ velikosti bufferu

         mov       al,160/16                ; poáet bajtñ na ©†dek/16
         mul       byte ptr ds:[MaxRow]     ; velikost bufferu / 16 - ©†dek
         add       ax,160/16                ; + 1 ©†dek
         xchg      ax,bx                    ; BX <- poëadovan† velikost

; ------ vytvo©en° bufferu pro £schovu videopamàti

         mov       ah,48h
         int       21h                      ; vytvo©en° novÇho bloku
         jnc       PushScr3                 ; buffer vytvo©en OK
         mov       ah,48h
         int       21h                      ; vytvo©en° alespo§ men®°ho bufferu
         jc        PushScr9                 ; chyba - nedostatek pamàti
PushScr3:mov       ds:[SegDisp],ax          ; adresa bufferu videopamàti
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost bufferu ve slovech
         mov       ds:[SizDisp],bx          ; velikost bufferu ve slovech

; ------ £schova videopamàti

         push      ds
         mov       cx,bx                    ; CX <- velikost dat k £schovà
         mov       es,ax                    ; adresa bufferu videopamàti
         lds       si,ds:[AdrVRAM]          ; adresa videopamàti
         cld
         xor       di,di
         rep       movsw                    ; £schova obsahu obrazovky
         pop       ds

PushScr9:ret

PushScr  ENDP

; *****************************************************************************
;                              InitVMod
;                        inicializace videom¢du
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP:CY=videom¢d nelze nastavit
; -----------------------------------------------------------------------------
; zniáenÇ registry: v®echny kromà DS
; *****************************************************************************

InitVMod PROC      NEAR

; ------ test, zda je nastaven textovò videom¢d

         call      DetPDisp                 ; detekce parametrñ displeje
         jnc       InitVMd9                 ; videom¢d je jië nastaven OK

; ------ nastaven° textovÇho videom¢du

         mov       ax,3                     ; implicitn° videom¢d 3
         call      Int10                    ; inicializace videom¢du
         call      DetPDisp                 ; detekce parametrñ displeje
InitVMd9:ret

InitVMod ENDP

; *****************************************************************************
;                              DetPDisp
;                     detekce parametrñ displeje
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; VùSTUP: CY=neobsluhovanò videom¢d
; *****************************************************************************

DetPDisp PROC      NEAR

; ------ test videom¢du a adresa videopamàti

         mov       ah,0fh
         call      Int10                    ; poskytnut° videom¢du

         mov       byte ptr ds:[AdrVRAM+2+1],0b8h ; videopamàü CGA
         mov       byte ptr ds:[Col1],1bh   ; bàën† barva
         mov       byte ptr ds:[Col2],1eh   ; vysv°cen† barva
         mov       byte ptr ds:[Col3],30h   ; kurzor
         mov       byte ptr ds:[Col4],3eh   ; vysv°cenò kurzor
         mov       byte ptr ds:[Col5],70h   ; barva n†povàdy
         mov       byte ptr ds:[Col6],74h   ; zvòraznàn† n†povàda

         cmp       al,2
         je        DetPDis2                 ; m¢d 2 - OK
         cmp       al,3
         je        DetPDis2                 ; m¢d 3 - OK
         cmp       al,7
         stc
         jne       DetPDis9                 ; nepovolenò videom¢d

         mov       byte ptr ds:[AdrVRAM+2+1],0b0h ; videopamàü MDA
         mov       byte ptr ds:[Col1],7     ; bàën† barva
         mov       byte ptr ds:[Col2],0fh   ; vysv°cen† barva
         mov       byte ptr ds:[Col3],70h   ; kurzor
         mov       byte ptr ds:[Col4],70h   ; vysv°cenò kurzor
         mov       byte ptr ds:[Col5],70h   ; barva n†povàdy
         mov       byte ptr ds:[Col6],70h   ; zvòraznàn† n†povàda

DetPDis2:mov       ds:[AktPage],bh          ; aktivn° videostr†nka

; ------ stanoven° parametrñ videopamàti

         push      ds
         mov       di,40h
         mov       ds,di                    ; DS <- 40h
         mov       ax,ds:[di+0eh]           ; adresa videopamàti
         mov       bl,ds:[di+44h]           ; poáet ©†dkñ displeje
         pop       ds
         mov       word ptr ds:[AdrVRAM],ax ; adresa videopamàti

         cmp       bl,22                    ; minim†ln° ©†dek
         jb        DetPDis6                 ; chybnò £daj
         cmp       bl,65
         jae       DetPDis6                 ; chybnò £daj
         mov       byte ptr ds:[MaxRow],bl  ; posledn° ©†dek displeje

; ------ oprava posledn°ho ©†dku, nen°-li EGA/VGA

         mov       ah,12h
         mov       bx,5e10h
         call      Int10                    ; informace o EGA
         cmp       bh,2
         ja        DetPDis6                 ; nen° EGA/VGA
         cmp       bl,5
         jbe       DetPDis8                 ; je EGA/VGA

DetPDis6:mov       byte ptr ds:[MaxRow],24  ; implicitn° poáet ©†dkñ

DetPDis8:clc                                ; p©°znak operace OK
DetPDis9:ret

DetPDisp ENDP

; *****************************************************************************
;                               KurzOff
;                      vypnut° zobrazen° kurzoru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

KurzOff  PROC      NEAR

         push      ax
         push      bx
         push      dx

         mov       dh,byte ptr ds:[MaxRow]
         inc       dh
         mov       dl,0
         mov       ah,2
         mov       bh,ds:[AktPage]          ; aktivn° str†nka
         int       10h                      ; vypnut° kurzoru

         pop       dx
         pop       bx
         pop       ax
         ret

KurzOff  ENDP

; *****************************************************************************
;                                 Int10
;                    obsluha INT 10h s £schovou registrñ
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

Int10    PROC      NEAR

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

Int10    ENDP

; *****************************************************************************
;                                DispTxt
;                    zobrazen° textu na obrazovku
; -----------------------------------------------------------------------------
; VSTUP: ES:SI=adresa textu
;        AH=barva textu
;        CX=poáet znakñ textu
;        DL=pozice k zobrazen° textu
;        DH=©†dek k zobrazen° textu
;        DS=datovò segment
; VùSTUP: DL=nov† pozice
; *****************************************************************************

DispTxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es
         jcxz      DispTxt9                 ; nen° ë†dnò text

; ------ vòpoáet adresy ve videopamàti -> ES:DI

         push      es                       ; segment bufferu s textem
         push      ax
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dku na pozice
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos
         shl       ax,1                     ; offset v bajtech
         add       di,ax                    ; adresa ve videopamàti
         pop       ax
         pop       ds                       ; DS <- segment bufferu s textem

; ------ p©enesen° textu na displej

         cld
DispTxt1:lodsb                              ; znak k p©enesen°
         stosw                              ; uloëen° znaku
         loop      DispTxt1                 ; dal®° znak

; ------ n†vrat registrñ

DispTxt9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         add       dl,cl                    ; zvò®en° ukazatele pozice
         ret

DispTxt  ENDP

; *****************************************************************************
;                                DispChr
;                    zobrazen° znaku na obrazovku
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k zobrazen°
;        AH=barva znaku
;        CX=poáet znakñ
;        DL=pozice k zobrazen° znaku
;        DH=©†dek k zobrazen° znaku
;        DS=datovò segment
; VùSTUP: DL=nov† pozice na ©†dku
; *****************************************************************************

DispChr  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es
         jcxz      DispChr9                 ; nen° ë†dnò znak

; ------ vòpoáet adresy ve videopamàti

         push      ax
         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dku na znaky
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos
         shl       ax,1                     ; offset v bajtech
         add       di,ax                    ; adresa ve videopamàti
         pop       ax

; ------ zobrazen° znaku

         cld
         rep       stosw                    ; zobrazen° znaku

; ------ n†vrat registrñ

DispChr9:pop       es
         pop       di
         pop       cx
         pop       ax
         add       dl,cl                    ; zvò®en° ukazatele pozice
         ret

DispChr  ENDP

; *****************************************************************************
;                                DispStin
;                    zobrazen° st°nu na obrazovku
; -----------------------------------------------------------------------------
; VSTUP: CX=poáet znakñ
;        DL=pozice k zobrazen° st°nu
;        DH=©†dek k zobrazen° st°nu
;        DS=datovò segment
; *****************************************************************************

DispStin PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         push      es
         jcxz      DispStn9                 ; nen° ë†dnò st°n

; ------ vòpoáet adresy ve videopamàti

         les       di,ds:[AdrVRAM]          ; adresa videopamàti
         mov       al,80                    ; poáet znakñ na ©†dek
         mul       dh                       ; p©epoáet ©†dku na bajty
         add       al,dl                    ; p©iáten° pozice
         adc       ah,0                     ; p©enos
         shl       ax,1                     ; offset v bajtech
         add       di,ax                    ; adresa ve videopamàti

; ------ zobrazen° st°nu

         mov       al,7                     ; barva st°nu k ukl†d†n°
         cld
DispStn2:inc       di                       ; p©eskoáen° znaku
         stosb
         loop      DispStn2

; ------ n†vrat registrñ

DispStn9:pop       es
         pop       di
         pop       cx
         pop       ax
         ret

DispStin ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                    Dek¢dov†n° p©°kazovÇho ©†dku
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; *****************************************************************************
;                                  Dekod
;                   dek¢dov†n° zad†n° z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
; VùSTUP:CY=chyba zad†n°
; *****************************************************************************

Dekod    PROC      NEAR

; ------ p©°prava p©°kazovÇho ©†dku

         mov       si,81h                   ; zaá†tek p©°kazovÇho ©†dku
         mov       bh,0
         mov       bl,ds:[si-1]             ; poáet znakñ v p©°kazovÇm ©†dku
         mov       ds:[bx+si],bh            ; oznaáen° konce p©°kaz. ©†dku
         push      ds
         pop       es                       ; ES <- DS

; ------ zaá†tek parametru

Dekod1:  call      DekSpc                   ; prvn° znak
         jnc       Dekod14                  ; je dal®° znak

; ------ konec ©†dku - kontrola zad†n°

Dekod11: cmp       byte ptr ds:[Soubor1],0  ; byly zad†n alespo§ 1 soubor ?
         jne       Dekod13                  ; je zad†n vstupn° soubor OK
Dekod12: stc                                ; p©°znak chyby
Dekod13: ret

; ------ dek¢dov†n° textu vòzvy

Dekod14: mov       di,offset Vyzva          ; text vòzvy
         call      DekTxt                   ; dek¢dov†n° textu vòzvy
         jc        Dekod2                   ; nen° text vòzvy
         mov       ds:[VyzvaN],cx           ; dÇlka textu vòzvy
         jmp       short Dekod1             ; dal®° parametr

; ------ test, zda je parametr

Dekod2:  cmp       al,"/"                   ; je parametr ?
         je        Dekod3                   ; je parametr

; ------ dek¢dov†n° jmÇna souboru

         mov       di,offset Soubor1        ; vstupn° soubor
         cmp       byte ptr ds:[di],0       ; je jië vstupn° soubor ?
         je        Dekod22                  ; nen° vstupn° soubor
         mov       di,offset Soubor2        ; jinak vòstupn° soubor
Dekod22: call      DekFile                  ; dek¢dov†n° jmÇna prvn°ho souboru
         jc        Dekod13                  ; chyba - nen° jmÇno souboru
         jmp       short Dekod1             ; dal®° parametr

; ------ naáten° znaku parametru

Dekod3:  call      DekChr                   ; vypu®tàn° znaku "/"
         call      DekSpc                   ; vypu®tàn° mezer
         call      DekChr                   ; znak parametru
         jc        Dekod13                  ; nen° znak - chyba zad†n°
         call      UpCase                   ; konverze na velkÇ p°smeno

; ------ parametr "/Hn" - z†hlav° seznamu

         cmp       al,"H"
         jne       Dekod32                  ; nen° z†hlav°
         call      DekNum                   ; dek¢dov†n° poátu ©†dkñ hlavy
         jc        Dekod13                  ; chyba zad†n°
         mov       ds:[TopSoub],ax          ; poáet ©†dkñ hlavy
         jmp       short Dekod1             ; dal®° parametr

; ------ parametr "/Pn" - pata seznamu

Dekod32: cmp       al,"P"
         jne       Dekod34                  ; nen° pata
         call      DekNum                   ; dek¢dov†n° poátu ©†dkñ paty
         jc        Dekod13                  ; chyba zad†n°
         mov       ds:[PatSoub],ax          ; poáet ©†dkñ paty
         jmp       short Dekod1             ; dal®° parametr

; ------ parametr "/Jn" - pozice jmÇna na ©†dku

Dekod34: cmp       al,"J"
         jne       Dekod36                  ; nen° pozice
         call      DekNum                   ; dek¢dov†n° pozice jmÇna souboru
         jc        Dekod13                  ; chyba zad†n°
         or        ax,ax
         jnz       Dekod33
         inc       ax                       ; pozice minim†lnà 1
Dekod33: mov       ds:[PozSoub],ax          ; pozice jmÇna souboru
Dekod35: jmp       short Dekod1             ; dal®° parametr

; ------ parametr "/Kn" - alternativn° pozice jmÇna na ©†dku

Dekod36: cmp       al,"K"
         jne       Dekod37
         call      DekNum
         jc        Dekod13
         mov       ds:[APozSoub],ax         ; alternativn° pozice
         jmp       short Dekod35

; ------ parametr "/En" - pozice p©°pony na ©†dku

Dekod37: cmp       al,"E"
         jne       Dekod38                  ; nen° pozice
         call      DekNum                   ; dek¢dov†n° pozice p©°pony
         jc        Dekod13                  ; chyba zad†n°
         mov       ds:[PozExt],ax           ; pozice p©°pony
         jmp       short Dekod35            ; dal®° parametr

; ------ parametr "/Vn" - pozice velikosti na ©†dku

Dekod38: cmp       al,"V"
         jne       Dekod4
         call      DekNum                   ; dek¢dov†n° pozice velikosti
         jc        Dekod9                   ; chyba
         mov       ds:[PozVel],ax           ; pozice velikosti
         jmp       short Dekod35            ; dal®° parametr

; ------ parametr "/Dn" - pozice data na ©†dku

Dekod4:  cmp       al,"D"
         jne       Dekod42
         call      DekNum                   ; dek¢dov†n° pozice data
         jc        Dekod9                   ; chyba
         mov       ds:[PozDat],ax           ; pozice data
         jmp       short Dekod35            ; dal®° parametr

; ------ parametr "/Cn" - pozice áasu na ©†dku

Dekod42: cmp       al,"C"
         jne       Dekod44
         call      DekNum                   ; dek¢dov†n° pozice áasu
         jc        Dekod9                   ; chyba
         mov       ds:[PozTim],ax           ; pozice áasu
Dekod43: jmp       short Dekod35            ; dal®° parametr

; ------ parametr "/Xp©°kaz", "/X1p©°kaz", "/X2p©°kaz"

Dekod44: cmp       al,"X"
         jne       Dekod5
         call      DekSpc                   ; dal®° znak
         jc        Dekod46                  ; nen° dal®° znak

         cmp       al,"1"
         jne       Dekod45
         inc       si                       ; p©eskoáen° znaku "1"
         mov       di,offset Prikaz1        ; buffer p©°kazu "X" TAB
         call      DekTxt                   ; dek¢dov†n° p©°kazu
         jc        Dekod9                   ; chyba
         mov       ds:[Prikaz1N],cx         ; dÇlka p©°kazu TAB
         jmp       short Dekod43

Dekod45: cmp       al,"2"
         jne       Dekod46
         inc       si                       ; p©eskoáen° znaku "2"
         mov       di,offset Prikaz2        ; buffer p©°kazu "X" ENTER
         call      DekTxt                   ; dek¢dov†n° p©°kazu
         jc        Dekod9                   ; chyba
         mov       ds:[Prikaz2N],cx         ; dÇlka p©°kazu ENTER
         jmp       short Dekod43            ; dal®° p©°kaz

Dekod46: mov       di,offset Prikaz1        ; buffer p©°kazu "X" TAB
         call      DekTxt                   ; dek¢dov†n° p©°kazu
         jc        Dekod9                   ; chyba
         mov       ds:[Prikaz1N],cx         ; dÇlka p©°kazu TAB
         mov       ds:[Prikaz2N],cx         ; dÇlka p©°kazu ENTER
         push      si
         mov       si,offset Prikaz1
         mov       di,offset Prikaz2
         cld
         inc       cx                       ; váetnà koncovÇ 0
         rep       movsb                    ; kopie p©°kazu pro ENTER
         pop       si
         jmp       short Dekod43            ; dal®° parametr

Dekod5:
Dekod9:  jmp       Dekod12                  ; neplatnò parametr

Dekod    ENDP

; *****************************************************************************
;                             DekTxt
;                 dek¢dov†n° textu v uvozovk†ch do bufferu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
;        ES:DI=buffer k uloëen° textu
; VùSTUP: CY=chyba, nen° text (CX=0)
;         AL=p©ipravenò znak
;         CX=dÇlka textu
; *****************************************************************************

DekTxt   PROC      NEAR

; ------ vypu®tàn° £vodn°ch mezer

         xor       cx,cx                    ; CX <- 0 ukazatel dÇlky textu
         call      DekSpc                   ; vypu®tàn° mezer
         jc        DekTxt9                  ; nic nen†sleduje

; ------ test, zda je prvn° znak znak uvozovek

         cmp       al,'"'                   ; jednoduchÇ uvozovky ?
         je        DekTxt1
         cmp       al,'"'
         stc
         jne       DekTxt9                  ; nen° text
DekTxt1: mov       ah,al                    ; AH <- £schova £vodn°ho znaku
         inc       si                       ; vypu®tàn° £vodn°ch uvozovek

; ------ naáten° dal®°ho znaku

DekTxt2: call      DekChr                   ; naáten° dal®°ho znaku
         jc        DekTxt8                  ; je konec textu

; ------ test, jestli jsou uvozovky

         cmp       al,ah                    ; jsou uvozovky ?
         jne       DekTxt5                  ; nejsou uvozovky - je platnò znak

; ------ test, zda je zdvojenò znak uvozovek

         call      DekChr                   ; naáten° dal®°ho znaku
         jc        DekTxt8                  ; je konec textu
         cmp       al,ah                    ; je zdvojenò znak ?
         jne       DekTxt7                  ; nen° zdvojenò znak - konec

; ------ uloëen° platnÇho znaku

DekTxt5: stosb
         inc       cx                       ; zvò®en° á°taáe dÇlky textu
         jmp       short DekTxt2            ; dal®° znak

; ------ konec textu

DekTxt7: dec       si                       ; n†vrat posledn°ho znaku
DekTxt8: clc                                ; p©°znak operace OK
DekTxt9: ret

DekTxt   ENDP

; *****************************************************************************
;                              DekNum
;                         dek¢dov†n° á°sla
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
; VùSTUP:AX=á°slo (p©i chybà je AX=0)
;        CY=neplatnÇ á°slo
; *****************************************************************************

DekNum   PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      dx

; ------ p©°prava registrñ

         xor       cx,cx                    ; CX <- 0 st©adaá á°sla

; ------ naáten° prvn° á°slice

         call      DekSpc                   ; vypu®tàn° mezer z textu
         call      Dek0Nm                   ; naáten° jednÇ á°slice
         jc        DekNum9                  ; nen° platn† á°slice

; ------ p©id†n° ke st©adaái

DekNum1: mov       ah,0
         push      ax                       ; naátenÇ á°slo
         mov       ax,10                    ; n†sobitel
         mul       cx                       ; vyn†soben° * 10
         pop       cx                       ; CX <- naátenÇ á°slo
         add       cx,ax                    ; st©adaá + naátenÇ á°slo
         adc       dx,dx                    ; je p©eteáen° ?
         jz        DekNum2                  ; nen° p©eteáen°
         mov       cx,-1                    ; omezen° p©i p©eteáen°

; ------ naáten° dal®° á°slice

DekNum2: call      Dek0Nm                   ; naáten° dal®° á°slice
         jnc       DekNum1                  ; je platn† dal®° á°slice
         clc                                ; p©°znak operace OK

; ------ n†vrat registrñ

DekNum9: xchg      ax,cx                    ; AX <- naátenÇ á°slo
         pop       dx
         pop       cx
         ret

DekNum   ENDP

; *****************************************************************************
;                            Dek0Nm
;                    naáten° jednÇ á°slice
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel textu
; VùSTUP:AL=á°slo
;        CY=nen° platn† á°slice
; *****************************************************************************

Dek0Nm   PROC      NEAR

; ------ naáten° znaku

         call      DekChr                   ; naáten° znaku á°slice
         jc        Dek0Nm9                  ; konec textu

; ------ kontrola, zda je á°slice

         cmp       al,"9"
         ja        Dek0Nm8                  ; nen° platn† á°slice
         sub       al,"0"                   ; korekce na á°slo
         jae       Dek0Nm9                  ; je á°slice OK

; ------ p©i chybà n†vrat znaku

Dek0Nm8: dec       si                       ; n†vrat ukazatele textu
         stc                                ; p©°znak neplatnÇ á°slice
Dek0Nm9: ret

Dek0Nm   ENDP

; *****************************************************************************
;                             DekFile
;                    dek¢dov†n° jmÇna souboru
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
;        ES:DI=buffer k dek¢dov†n° jmÇna souboru
; VùSTUP:CY=nen° jmÇno souboru
;        AL=p©ipravenò znak
; *****************************************************************************

DekFile  PROC      NEAR

; ------ nalezen° zaá†tku jmÇna souboru

         call      DekSpc                   ; vypu®tàn° mezer
         jc        DekFile9                 ; konec textu - nen° soubor
         cmp       al,"/"
         je        DekFile1                 ; to nen° jmÇno souboru
         cmp       al,"?"
DekFile1:stc
         je        DekFile9                 ; to takÇ nen° jmÇno souboru

; ------ uloëen° jmÇna souboru

DekFile2:call      DekChr                   ; naáten° znaku
         jc        DekFile6                 ; konec jmÇna souboru
         je        DekFile4                 ; je mezera - konec
         call      UpCase                   ; konverze na velkÇ p°smeno
         stosb                              ; uloëen° znaku
         cmp       al,"/"
         jne       DekFile2                 ; nen° parametr - dal®° znak
         dec       di                       ; n†vrat ukl†dac° adresy
DekFile4:dec       si                       ; n†vrat znaku parametru

DekFile6:mov       byte ptr ds:[di],0       ; uloëen° koncovÇ 0 jmÇna souboru
         clc                                ; p©°znak operace OK

DekFile9:ret

DekFile  ENDP

; *****************************************************************************
;                               DekSpc
;                   vypu®tàn° mezer z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
; VùSTUP:AL=p©ipravenò znak
;        CY=konec textu
;        CLD
; *****************************************************************************

DekSpc   PROC      NEAR

DekSpc1: call      DekChr                   ; vstup jednoho znaku
         je        DekSpc1                  ; mezera - vypu®tàn°
         jb        DekSpc2                  ; konec textu
         dec       si                       ; n†vrat posledn°ho znaku
DekSpc2: ret

DekSpc   ENDP

; *****************************************************************************
;                               DekChr
;                    vstup znaku z p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=ukazatel p©°kazovÇho ©†dku
; VùSTUP:AL=znak
;        CY=nen° dal®° znak
;        ZY=je mezera
;        CLD
; *****************************************************************************

DekChr   PROC      NEAR

; ------ naáten° dal®°ho znaku

         cld
         lodsb                              ; znak z p©°kazovÇho ©†dku

; ------ n†hrada tabul†toru mezerou

         cmp       al,9
         jne       DekChr1
         mov       al," "                   ; n†hrada tabul†toru mezerou

; ------ test, zda je jië konec ©†dku

DekChr1: cmp       al," "                   ; konec textu ?
         jae       DekChr9                  ; nen° konec textu
         dec       si                       ; n†vrat ukazatele
DekChr9: ret

DekChr   ENDP

; *****************************************************************************
;                                UpCase
;                   konverze znaku na velkÇ p°smeno
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VùSTUP: AL=znak
; *****************************************************************************

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; *****************************************************************************
;                               ComIni
;                   inicializace cesty ke COMMAND.COM
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; *****************************************************************************

ComIni   PROC      NEAR

; ------ adresa prost©ed°

         mov       es,ds:[2ch]              ; segment prost©ed°
         xor       di,di                    ; ukazatel parametrñ v bufferu

; ------ test, zda je konec prost©ed°

         cld
ComIni2: cmp       byte ptr es:[di],0       ; je konec prost©ed° ?
         je        ComIni9                  ; je konec prost©ed°

; ------ test, zda je parametr COMSPEC

         push      di
         mov       cx,8                     ; dÇlka textu parametru
         mov       si,offset ComSpecT       ; text jmÇna parametru
         repe      cmpsb                    ; porovn†n° jmÇna parametru
         pop       di
         je        ComIni5

; ------ nalezen° dal®°ho ©etàzce

ComIni3: inc       di
         jz        ComIni9
         cmp       byte ptr es:[di-1],0
         jne       ComIni3
         jmp       short ComIni2

; ------ p©enesen° textu parametru do bufferu

ComIni5: add       di,8                     ; zaá†tek textu parametru
         mov       si,offset ComSpec        ; buffer textu parametru
ComIni6: mov       al,es:[di]
         inc       di
         cmp       al,0
         je        ComIni8
         cmp       si,offset ComSpec0-1
         jae       ComIni6
         mov       ds:[si],al
         inc       si
         jmp       short ComIni6

ComIni8: mov       ds:[si],al               ; oznaáen° konce textu

ComIni9: ret

ComIni   ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                                   Data
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
MemTxt   db        'Nedostatek pameti !',13,10,'$'
SeznTxt  db        'Vstupni soubor seznamu nenalezen !',13,10,'$'
WritTxt  db        'Chyba zapisu do vystupniho souboru !',13,10,'$'

HelpTxt  db        'VYBER V1.21 - vyber souboru ze seznamu; (c) Miroslav Nemecek',13,10
         db        13,10
         db        'Zadejte: VYBER seznam [vystup] [parametry] ["text"]',13,10
         db        '           seznam  - jmeno vstupniho seznamu souboru (textovy soubor)',13,10
         db        '           vystup  - jmeno vystupniho seznamu vybranych souboru',13,10
         db        '           "text"  - text vyzvy v hornim radku',13,10
         db        'Parametry: /Hn     - pocet radku zahlavi seznamu',13,10
         db        '           /Pn     - pocet radku paty seznamu',13,10
         db        '           /Jn     - pozice jmena souboru na radku (1..)',13,10
         db        '           /Kn     - altern. pozice jmena souboru pro TAB (1..)',13,10
         db        '           /En     - pozice pripony na radku (1..)',13,10
         db        '           /Vn     - pozice velikosti souboru (1..) pro oznacovani',13,10
         db        '           /Dn     - pozice data souboru (1..) pro test platnosti',13,10
         db        '           /Cn     - pozice casu souboru (1..) pro test platnosti',13,10
         db        '           /X1"prikaz" - provedeni prikazu pri stisku TAB',13,10
         db        '                        znak @ v prikazu = soubor pod kurzorem',13,10
         db        '           /X2"prikaz" - provedeni prikazu pri stisku ENTER',13,10
         db        '                         Vystupni soubor (je-li zadan) se vygeneruje',13,10
         db        '                         pouze v pripade oznaceni souboru',13,10
         db        '           /X"prikaz" - provedeni prikazu pri stisku TAB nebo ENTER',13,10
         db        'Neni-li udan vystupni soubor, lze jako vystup volby pouzit navratovy kod:',13,10
         db        '1 az 254 = poradove cislo souboru (s omezenim do 254, 0=neni zadny soubor),',13,10
         db        '255=preruseni programu nebo chyba',13,10
         db        '$'

InfTxt   db        ' F1=napoveda ≥ '
InfTxt0  db        '<Enter>=volba souboru, <Esc>=preruseni...'
InfTxt1  db        '             ≥ '        ; buffer k dek¢dov†n° velikosti
InfTxt2  db        '≥             '         ; buffer á°sla ©†dku
InfTxt3  label     byte

Help     db        ' …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ VYBER V 1.21 ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª '
         db        ' ∫  nahoru, dolu     posun o radek nahoru, dolu     ∫ '
         db        ' ∫  vlevo, vpravo    posun o pozici vlevo, vpravo   ∫ '
         db        ' ∫  Ctrl-vlevo       posun o 40 pozic vlevo         ∫ '
         db        ' ∫  Ctrl-vpravo      posun o 40 pozic vpravo        ∫ '
         db        ' ∫  Home, End        posun na prvni, posledni radek ∫ '
         db        ' ∫  PageUp, PageDwn  posun o stranku nahoru, dolu   ∫ '
         db        ' ∫  Alt-F5           systemova obrazovka            ∫ '
         db        ' ∫ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∫ '
         db        ' ∫  mezera, Insert   oznaceni jednoho souboru       ∫ '
         db        ' ∫  Delete           inverze oznaceni vsech souboru ∫ '
         db        ' ∫  +, -, *          vsechny, zadny, inverze vsech  ∫ '
         db        ' ∫ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∫ '
         db        ' ∫  Enter            provedeni volby                ∫ '
         db        ' ∫  TAB              funkce zobrazeni souboru       ∫ '
         db        ' ∫  Esc              preruseni volby, navrat        ∫ '
         db        ' »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕ (c) Miroslav Nemecek ÕÕÕÕÕÕÕÕÕÕÕÕÕÕº '

Col1     db        1bh                      ; bàën† barva textu
Col2     db        1eh                      ; vysv°cenò text
Col3     db        30h                      ; kurzor
Col4     db        3eh                      ; vysv°cenò kurzor
Col5     db        70h                      ; barva n†povàdy
Col6     db        74h                      ; zvòraznàn† n†povàda

; ------ £daje z p©°kazovÇho ©†dku

Soubor1  db        128 dup(0)               ; vstupn° soubor
Soubor2  db        128 dup(0)               ; vòstupn° soubor (0=nezad†n)

Prikaz1N dw        0                        ; dÇlka p©°kazu k proveden° TAB
Prikaz1  db        128 dup(0)               ; p©°kaz k proveden° TAB

Prikaz2N dw        0                        ; dÇlka p©°kazu k proveden° ENTER
Prikaz2  db        128 dup(0)               ; p©°kaz k proveden° ENTER

VyzvaN   dw        0                        ; dÇlka textu vòzvy
Vyzva    db        128 dup(0)               ; text vòzvy

TopSoub  dw        0                        ; poáet ©†dkñ z†hlav°
PatSoub  dw        0                        ; poáet ©†dkñ paty
PozSoub  dw        1                        ; pozice souboru na ©†dku
PozExt   dw        1                        ; pozice p©°pony na ©†dku
PozVel   dw        0                        ; pozice velikosti na ©†dku
PozDat   dw        0                        ; pozice data souboru na ©†dku
PozTim   dw        0                        ; pozice áasu souboru na ©†dku

APozSoub dw        0                        ; alternat. pozice souboru pro TAB

; ------ paket parametrñ pro zobrazen° souboru

Paket    label     word
PaketEnv dw        0                        ; adresa prost©ed°
PaketCom dd        80h                      ; adresa p©°kazovÇho ©†dku
PaketFC1 dd        5ch                      ; adresa prvn°ho FCB
PaketFC2 dd        6ch                      ; adresa druhÇho FCB

ComSpecT db        'COMSPEC='               ; hledanò text
ComSpec  db        'C:\COMMAND.COM',114 dup(0) ; jmÇno programu COMMAND.COM
ComSpec0 label     byte

; ------ parametry displeje

AktPage  db        0                        ; aktivn° videostr†nka
AdrVRAM  dd        0b8000000h               ; adresa videopamàti
OldKurz  dw        0                        ; pñvodn° pozice kurzoru
MaxRow   dw        0                        ; maxim†ln° ©†dek na displeji

SegDisp  dw        0                        ; segment s uschovanou obrazovkou
SizDisp  dw        0                        ; dÇlka uschovanÇ obrazovky (slov)

; ------ definice seznamu souboru
; Struktura seznamu:
;         0: (2) bit0 aë bit13: dÇlka textu ©†dku (0 aë 16380)
;                bit14: 1=platnò ©†dek
;                bit15: 1=oznaáenò ©†dek
;         2: (x) text ©†dku

DatSegm  dw        0                        ; segment dat seznamu
DatSize  dw        0                        ; velikost segmentu dat (odstavce)
DatByte  dd        2-1                      ; poáet naátenòch bajtñ v bufferu

NumRadku dw        0                        ; celkovò poáet ©†dkñ (skuteánòch)
NumSoub  dw        0                        ; poáet platnòch ©†dkñ se soubory

AktRadek dw        -1                       ; aktivn° ©†dek (skuteánò)
AktSoub  dw        0                        ; aktivn° platnò ©†dek se souborem

TopRadek dw        0                        ; prvn° zobrazen° ©†dek (skuteánò)
TopPozic dw        0                        ; poá†teán° zobrazen† pozice

NumOznac dw        0                        ; poáet oznaáenòch souborñ
VelOznac dd        0                        ; souáet kapacit oznaáenòch souborñ

         dw        200h dup(0)              ; z†sobn°k
Zasobnik label     word

Code     ENDS

         end       start

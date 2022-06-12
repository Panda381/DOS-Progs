; Pouze pro p©eklad do .COM!
code     segment
         assume    cs:code, ds:code
         org       100h

Korig    equ  5Ch-103h                      ; Posun rezidentn° á†sti

VelRedT  equ  32768                         ; Maxim†ln° velikost definián° tabulky
VelDBuf  equ  512                           ; Velikost datovÇho bufferu


; ******************************************************************************
; Konstanty syntaktickÇho analyz†toru
;
; Syntaxe:    V®e za st©edn°kem je aë po konec ©†dku koment†©
;             Znak zaps†n buÉ jako dvà hexa cifry
;             ûETâZEC=ûETâZEC.
;
; ûetàzec:    'Text ''=apostrof'
;             $Ä°slo_Hexa : $XX / $X
;             #Ä°slo_Dek  : #XXX / #XX / #X
; Mezi n†và®t°m typu á°sla a ciframi NESMã BùT ODDâLOVAÄE.
;
;
VelCBuf  equ  1024                          ; Velikost átec°ho bufferu
VelRBuf  equ  255                           ; Velikost bufferu pro ©etàzce
;
CommCh   equ  ';'                           ; N†và®t° koment†©e
HexNumCh equ  '$'                           ; N†và®t° hex. á°sla
DekNumCh equ  '#'                           ; N†và®t° dek. á°sla
;
PriradCh equ  '='                           ; N†và®t° p©i©azen°
KonecPCh equ  '.'                           ; N†và®t° konce p©i©azen°
;
; ******************************************************************************



start:   jmp  Instal

ZacRez   label     near                     ; Zaá†tek rezidentn° á†sti

; ==============================================================================
;                           Obsluha p©eru®en° INT 17
; ==============================================================================
New17:   cmp  ax,6056h                      ; Sluëba FILTPRN?
         jne  Ne00a

; ------ Kontrola instalace
         cmp  bx,0                          ; Kontrola instalace?
         jne  FiP171
FiP1709: mov  ax,3141h
         mov  bx,5927h                      ; P©°znak instalace
         mov  dl,byte ptr cs:LPTx+Korig     ; Ä°slo portu
         mov  dh,cs:Aktiv+Korig             ; P©°znak aktivity
         iret

; ------ Zmàna LPT portu
FiP171:  cmp  bx,1                          ; Zmàna LPT portu?
         jne  FiP172
         mov  byte ptr cs:LPTx+Korig,dl
         jmp  short FiP1709

; ------ Aktivace/deaktivace
FiP172:  cmp  bx,2                          ; Aktivace/deaktivace?
         jne  FiP173
         mov  cs:Aktiv+Korig,dl             ; Nastaven° p©°znaku aktivn°/neaktivn°

; ------ Odinstalace
FiP173:  cmp  bx,3                          ; Odinstalace?
         jne  Ne00

         push dx
         push ds
         push es

; ------ Kontrola vektoru INT 17h
         mov  ax,3517h                      ; Zji®tàn° vektoru INT 17h
         int  21h
         cmp  bx,offset New17+Korig         ; Sed° offset?
         je   FiP1721

; ------ Vektor je zmànànò - nelze odinstalovat
FiP1720: mov  ax,-1
         pop  es
         pop  ds
         pop  dx
         iret

; ------ Kontrola segmentñ
FiP1721: mov  ax,es
         mov  bx,cs
         cmp  ax,bx                         ; Sed° segment?
         jne  FiP1720                       ; Ne, vraü chybovò k¢d

; ------ Nastaven° pñvodn°ho vektoru INT 17
         lds  dx,dword ptr cs:Old17o+Korig  ; Pñvodn° vektor INT 17
         mov  ax,2517h                      ; Nastaven° vektoru
         int  21h

; ------ Uvolnàn° bloku pamàti
         mov  ah,49h                        ; Freemem
         push cs
         pop  es
         int  21h

         pop  es
         pop  ds
         pop  dx
         jmp  short FiP1709                 ; N†vrat s k¢dem OK


; ------ O®et©en° tisku znaku
Ne00a:   cmp  cs:Aktiv+Korig,1              ; Je program aktivn°?
         jne  Ne00
         or   ah,ah                         ; Tisk znaku?
         jne  Ne00
         cmp  dx,cs:LPTx+Korig              ; Na spr†vnò port?
         je   Ne01

Ne00:    db   0EAh
Old17o   dw   00h
Old17s   dw   00h

; ------------------------------------------------------------------------------
; ------ Sluëba tisk znaku
Ne01:    push bx
         push cx
         push dx
         push si
         push ds
         push cs
         pop  ds

; ------ Uschov†n° znaku do bufferu
         mov  bx,word ptr PlatDBuf+Korig    ; Aktu†ln° pozice v bufferu
         mov  DBuf[bx+Korig],al             ; óschova znaku do bufferu
         inc  PlatDBuf+Korig                ; Aktualizace pozice v bufferu

; ------ Prohled†n° p©edefinov†vac° tabulky
         mov  cx,PocRPol+Korig              ; Poáet poloëek tabulky
         mov  bx,offset RedefT+Korig        ; BX<- Zaá†tek tabulky
         xor  dl,dl                         ; DÇlka nejdel®°ho shodnÇho ©etàzce

; ------ Prohled†n° jednÇ poloëky tabulky
HlRe01:  mov  si,bx                         ; SI<- Ukazatel na aktu†ln° poloëku tabulky
         add  bl,[si+1]
         adc  bh,0                          ; BX<= Aktu†ln° znak ©etàzce
         cmp  [bx+3],al                     ; Shoduje se dal®° znak?
         je   HlRe02                        ; Shoduje, aktualizuj ukazatele

; ------ Znak se neshoduje - nulov†n° ukazatele v ©etàzci
         mov  byte ptr [si+1],0             ; Nulov†n° ukazatele pozice v ©etàzci
         jmp  short HlRe03                  ; Hledej d†l

; ------ Znak se shoduje
HlRe02:  inc  byte ptr [si+1]               ; Aktualizace ukazatele
         mov  ah,[si+1]                     ; AH<- Ukazatel do ©etàzce
         cmp  ah,dl                         ; Kandid†t na nejdel®° zat°m shodnò?
         jbe  HlRe02a
         mov  dl,ah                         ; DL<- Nejdel®° shodnò
HlRe02a: cmp  ah,byte ptr [si+2]            ; Uë je ©etàzec celò?
         jne  HlRe03                        ; Je®tà nen° celò, hledej d†l

; ------ ûetàzec byl nalezen celò
         mov  ah,[si]                       ; AH<- DÇlka X+Y
         sub  ah,[si+2]                     ; AH<= DÇlka Y
         jz   HlRe02b                       ; Je dÇlka Y = 0?

         add  bx,4                          ; BX<= ûetàzec Y
         call PrintStr                      ; Tisk ©etàzce
HlRe02b: call InitRedT                      ; Inicializace tabulky
         mov  PlatDBuf+Korig,0              ; Zru®en° dat v bufferu
         jmp  short HlRe10

; ------ ûetàzec je®tà nebyl celò - hled†n° v dal®°m
HlRe03:  mov  bx,si                         ; BX<- Ukazatel na aktu†ln° poloëku tabulky
         add  bl,[si]
         adc  bh,0
         add  bx,3                          ; BX<= Ukazatel na novou poloëku

         loop HlRe01                        ; Prohled†n° dal®° poloëky

; ------ Nebyl nalezen celò shodnò ©etàzec - minimalizace dat v bufferu
         mov  bx,offset DBuf+Korig
         mov  si,bx
         mov  ah,PlatDBuf+Korig             ; AH<- DÇlka dat v bufferu
         sub  ah,dl                         ; AH<- DÇlka p©ebyteánòch dat
         mov  cl,ah
         jz   HlRe10                        ; Nejsou ë†dn† p©ebyteán† data
         call PrintStr                      ; Tisk p©ebyteánòch dat

; ------ Postráen° dat v bufferu doleva
         push di
         push es
         push cs
         pop  es

         xor  ch,ch                         ; CX<= DÇlka p©ebyteánòch dat
         mov  di,si                         ; DI<- Zaá†tek bufferu
         add  si,cx                         ; SI<- Zaá†tek uëiteánòch dat
         sub  PlatDBuf+Korig,cl
         mov  cl,PlatDBuf+Korig             ; CX<- DÇlka uëiteánòch dat

         cld
         rep  movsb

         pop  es
         pop  di

; ------ Asi uë konec
HlRe10:  pop  ds
         pop  si
         pop  dx
         pop  cx
         pop  bx

; ------ Nastaven° p©°znakñ podle paraleln°ho portu
         mov  ah,02                         ; Zji®tàn° stavu tisk†rny
         jmp  Ne00                          ; Vykon†n° pñv. obsluhy INT 17


; ------------------------------------------------------------------------------
; Tisk ©etàzce
; ------------------------------------------------------------------------------
; Vstup: DS:BX - ©etàzec
;        AH - dÇlka
;        DS=CS
; Niá°:  AX,BX
; ------------------------------------------------------------------------------
PrintStr proc near

         push cx

         xchg bx,si                         ; SI<- Adresa ©etàzce
         mov  cl,ah
         xor  ch,ch                         ; CX<- DÇlka ©etàzce

PrSt01:  lodsb                              ; Znak ©etàzce
PrSt02:  mov  ah,0                          ; Tisk znaku
         mov  dx,LPTx+Korig                 ; Ä°slo printer-portu
         pushf
         call dword ptr Old17o+Korig        ; Pñvodn° obsluha INT 17

;         or   ah,ah
;         jnz  PrSt02

         loop PrSt01

         xchg bx,si
         pop  cx
         ret
PrintStr endp


; ------------------------------------------------------------------------------
; Inicializace vyhled†vac° tabulky
; ------------------------------------------------------------------------------
; Vstup: DS=CS
; Niá°:  BX,CX
; ------------------------------------------------------------------------------
InitRedT proc near

         mov  cx,PocRPol+Korig              ; Poáet poloëek tabulky
         mov  bx,offset RedefT+Korig        ; Zaá†tek tabulky

; ------ Inicializace jednÇ poloëky tabulky
InRe01:  mov  byte ptr [bx+1],0             ; Nulov†n° 'pozice v ©etàzci'
         add  bl,[bx]
         adc  bh,0
         add  bx,3                          ; BX<= Ukazatel na dal®° poloëku

         loop InRe01

         ret
InitRedT endp

; ------ StavovÇ promànnÇ rezidentu
Aktiv    db   1                             ; P©°znak aktivity programu
LPTx     dw   0                             ; Printer port

; ------ Buffer pro data
PlatDBuf db   0,0                           ; DÇlka platnòch dat v bufferu
DBuf     db   VelDBuf dup (0)               ; Datovò buffer

; ------ P©edefinov†vac° tabulka - posledn° rezidentn° kousek
PocRPol  dw   0                             ; Poáet poloëek tabulky
RedefT   db   VelRedT dup (0)

; P©edefinov†vac° tabulka:
;
;          db   DÇlka ©etàzcñ X+Y+3
;          db   Aktu†ln° pozice v ©etàzci X 0
;          db   DÇlka ©etàzce X
;          db   ûetàzec X 0 dup (?)
;          db   ûetàzec Y 0 dup (?)


; ------------------------------------------------------------------------------
; ==============================================================================
; ------------------------------------------------------------------------------
; ==============================================================================
; ==============================================================================
;                           Instalaán° á†st programu
; ==============================================================================
; ==============================================================================
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
; ------------------------------------------------------------------------------
UvTxt    db   13,10
         db   'FILTPRN V1.00 [940804] (c) J.Tejkl                Z†màna ©°d°c°ch k¢dñ tisk†ren',13,10
         db   '-------------------------------------------------------------------------------',13,10,'$'
HlpTxt   db   'Pouëit°:  FILTPRN /Ä°slo_LPT_Portu_1-3',13,10
         db   '                  /! = Deaktivace',13,10
         db   'Spu®tàn°m programu bez parametru bude provedena instalace pro LPT 1.',13,10
         db   'Jako definián° soubor je pouëit soubor JMENO.DEF z domovskÇho adres†©e.',13,10,7,'$'

CtuRedT0 db   'Ätu definián° soubor $'
CtuRedT1 db   '...',13,10,'$'

JeInstT0 db   'Program jië byl instalov†n pro LPT $'
JeInstT1 db   '. Do tÇto chv°le byl $'
JeInstT2 db   'ne$'
JeInstT3 db   'aktivn°.',13,10,'$'
PInstTx0 db   'Nyn° je program instalov†n pro LPT $'
PInstTx1 db   '.',13,10,'$'
NastavT0 db   'Program je nyn° nastaven na LPT $'
NastavT1 db   ' a je aktivn°.',13,10,'$'

NeInstTx db   'Program nelze odinstalovat, protoëe nebyl instalov†n!',13,10,7,'$'
OdinstTx db   'Program byl £spà®nà odinstalov†n.',13,10,'$'
ZakazTxt db   'Program nen° moëno bezpeánà odinstalovat. Jeho funkce byla vypnuta,',13,10
         db   'ale program je st†le v pamàti.',13,10,'$'

BylInst  db   0                             ; P©echodn† promànn† - p©°znak instalace

; ------------------------------------------------------------------------------
Instal:  cld
         mov  dx,offset UvTxt               ; óvodn° text
         call PisTxt                        ; Vòpis textu

; ------ Kontrola verze DOSu
         mov  ah,30h                        ; Zji®tàn° verze DOSu
         int  21h
         cmp  al,3
         mov  dx,offset ChVerDOS            ; ChybovÇ hl†®en°
         call Chyba

; ------ Kontrola instalace
         mov  ax,6056h                      ; Sluëba programu:
         xor  bx,bx                         ; Identifikuj se!
         int  17h
         cmp  ax,3141h
         jne  Instal00
         cmp  bx,5927h
         jne  Instal00

; ------ Vòpis informac° o instalaci
         mov  bx,dx                         ; BX<- Parametry aktivity
         mov  BylInst,1                     ; P©echodnò p©°znak instalace pro Odinst
         mov  dx,offset JeInstT0            ; Prvn° info text
         call PisTxt                        ; Vòpis textu
         mov  dl,bl                         ; DL<- LPTx
         add  dl,'1'                        ; DL<- ASCII á°slice
         mov  ah,2                          ; Vòpis znaku
         int  21h
         mov  dx,offset JeInstT1            ; Druhò info text
         call PisTxt                        ; Vòpis textu
         or   bh,bh
         jnz  Info00xx
         mov  dx,offset JeInstT2            ; Text 'ne' aktivn°
         call PisTxt                        ; Vòpis textu
Info00xx:mov  dx,offset JeInstT3            ; Text 'aktivn°'
         call PisTxt                        ; Vòpis textu

; ------ Vyhodnocen° parametrñ
Instal00:mov  di,81h
         xor  al,al                         ; Implicitn° á°slo LPTx
         mov  cl,byte ptr ds:[80h]
         or   cl,cl                         ; Nejsou parametry?
         jz   Instal01
         xor  ch,ch                         ; CX<- DÇlka ©etàzce

         mov  ah,' '
         repe scasb                         ; Prvn° nemezerovò znak
         je   Instal01                      ; Jsou samÇ mezery?
         cmp  byte ptr es:[di],0Dh          ; Nejsou parametry?
         je   Instal01

         mov  al,es:[di]                    ; AL<- Parametr programu
         cmp  al,'/'                        ; Kontrola oddàlovaáñ parametru
         je   Param02
         cmp  al,'-'
         jne  Param03

Param02: mov  al,es:[di+1]                  ; Parametr programu
Param03: cmp  al,'!'                        ; Odinstalace?
         je   Odinst01

         sub  al,'1'                        ; Korekce na á°slo
         jc   JustHelp                      ; Nebylo to á°slo?
         cmp  al,3                          ; Je to v normà (0-2)?
         jc   Instal01

; ------ Vòpis n†povàdy a konec
JustHelp:mov  dx,offset HlpTxt              ; Text n†povàdy
ChyKon00:call PisTxt                        ; Vòpis textu
ChyKon01:mov  ax,4C01h                      ; N†vratovò k¢d
         int  21h


; ------------------------------------------------------------------------------
; Odinstalace
; ------------------------------------------------------------------------------
Odinst01:cmp  BylInst,1                     ; Byl jië program instalov†n?
         mov  dx,offset NeInstTx            ; Hl†®en° - nebyl instalov†n
         jne  ChyKon00                      ; Nebyl, chyba

; ------ Poëadavek odinstalace
         mov  ax,6056h                      ; Sluëba programu:
         mov  bx,3                          ; Zmiz!
         int  17h
         cmp  ax,3141h                      ; Odinstalov†n £spà®nà?
         jne  Odin00

; ------ Hl†®en° - odinstalov†no OK
         mov  dx,offset OdinstTx            ; Hl†®en°
OKKon00: call PisTxt                        ; Vòpis textu
OKKon01: mov  ax,4C00h                      ; N†vratovò k¢d = 0
         int  21h

; ------ Nelze odinstalovat - pouze zak†zat
Odin00:  mov  ax,6056h                      ; Sluëba programu:
         mov  bx,2                          ; Tak se aspo§ otoá!
         mov  dl,0                          ; Zak†z†n° áinnosti
         int  17h

         mov  dx,offset ZakazTxt            ; Hl†®en° - pouze zak†z†no
         jmp  short OKKon00                 ; Vòpis textu a konec


; ------------------------------------------------------------------------------
; Instalace
; ------------------------------------------------------------------------------
Instal01:mov  byte ptr LPTx,al              ; óschova á°sla LPT portu
         cmp  BylInst,0                     ; Je®tà nebyl instalov†n
         je   PInst00                       ; Ne, je to prvn° instalace

; ------ P©enastaven° parametrñ
NInst00: mov  dl,al                         ; DL<- novÇ á°slo LPT portu
         mov  ax,6056h                      ; Sluëba programu:
         mov  bx,1                          ; Zmà§ vòhled!
         int  17h
         push dx                            ; óschova á°sla LPT portu

         mov  ax,6056h                      ; Sluëba programu:
         mov  bx,2                          ; ProbuÉ se!
         mov  dl,1
         int  17h

; ------ Hl†®en° o p©enastaven°
         pop  bx                            ; Ä°slo LPT portu
         mov  dx,offset NastavT0            ; Hl†®en°
         call PisTxt                        ; Vòpis textu
         mov  dl,bl                         ; DL<- LPTx
         add  dl,'1'                        ; DL<- ASCII á°slice
         mov  ah,2                          ; Vòpis znaku
         int  21h
         mov  dx,offset NastavT1            ; Z†vàr hl†®en°
         jmp  short OKKon00                 ; Vòpis hl†®en° a konec

; ------ Prvn° instalace
PInst00: call MakeRTab                      ; Tvorba p©edefinov†vac° tabulky

; ------ P©esun programu dolñ
         push si                            ; óschova konce rezid. á†sti
         mov  cx,si                         ; CX<- Konec p©edefinov†vac° tabulky
         sub  cx,offset ZacRez              ; CX<= DÇlka rezidentu
         mov  si,offset ZacRez              ; Zaá†tek rezidentn° á†sti
         mov  di,offset ZacRez+Korig        ; Novò zaá†tek
         rep  movsb

; ------ óschova vektoru INT 17
         mov  ax,3517h                      ; Zji®tàn° vektoru p©eru®en° 17h
         int  21h
         mov  Old17o+Korig,bx
         mov  Old17s+Korig,es

; ------ Nastaven° vektoru INT 17
         mov  ax,2517h                      ; Nastaven° vektoru p©eru®en°
         mov  dx,offset New17+Korig
         int  21h

; ------ Uvolnàn° segmentu prost©ed°
         mov  es,ds:[2Ch]                   ; Segment prost©ed°
         mov  ah,49h                        ; Uvolnàn° bloku pamàti
         int  21h

; ------ Informace o nainstalov†n°
         mov  dx,offset PInstTx0            ; Hl†®en°
         call PisTxt                        ; Vòpis textu
         mov  dl,byte ptr LPTx+Korig        ; DL<- LPTx
         add  dl,'1'                        ; DL<- ASCII á°slice
         mov  ah,2                          ; Vòpis znaku
         int  21h
         mov  dx,offset PInstTx1            ; Z†vàr hl†®en°
         call PisTxt                        ; Vòpis textu

; ------ Instalace jako rezident
         pop  dx
         add  dx,Korig                      ; DX<= Konec rezidentn° á†sti
         int  27h                           ; Terminate & Stay rezident

; ==============================================================================
; Syntaktickò analyz†tor
; ==============================================================================




; ==============================================================================
; Vytvo©en° p©ek¢dovac° tabulky RedefT
; Volat p©ed p©esunem programu nahoru
; V programu by màla leëet min. 255+3 bajty za koncem p©edefinov†vac° tabulky,
; chybovÇ rutiny takÇ (kvñli p©eteáen° p©edefinov†vac° tabulky).
; ------------------------------------------------------------------------------
; Vstup: ES=DS=CS
; Vòstup:SI=Posledn° pouëitò bajt p©edefinov†vac° tabulky+1
; ==============================================================================
MakeRTab proc near

         push ax
         push bx
         push cx
         push dx
         push di

; ------ Vòpis prvn° á†sti textu 'Ätu definice ze souboru...'
         mov  dx,offset CtuRedT0            ; Hl†®en°
         call PisTxt                        ; Vòpis textu

; ------ Zji®tàn° jmÇna souboru s p©edefinov†vac° tabulkou
         mov  ds,es:[2Ch]                   ; DS<- Segment prost©ed° z PSP
         xor  si,si                         ; Ukazatel na jmÇno programu
HlPr01:  inc  si
         cmp  word ptr [si],0               ; Ukonáovac° word 0?
         jnz  HlPr01
         add  si,4
         mov  dx,si                         ; DX<- Adresa jmÇna spu®tànÇho programu

; ------ Vyhled†n° konce jmÇna souboru
HlPr02:  inc  si
         cmp  byte ptr [si],0               ; Konec jmÇna (ASCIIZ)?
         jne  HlPr02

; ------ Modifikace na dolarovò ©etàzec a vòpis jmÇna souboru
         mov  word ptr [si-3],'ED'          ; óprava p©°pony na DEF
         mov  word ptr [si-1],'$F'          ; A koncov† znaáka '$'
         call PisTxt                        ; Vòpis textu

; ------ Vòpis zbytku textu
         push dx
         push ds
         push cs
         pop  ds
         mov  dx,offset CtuRedT1            ; Hl†®en°
         call PisTxt                        ; Vòpis textu
         pop  ds
         pop  dx

; ------ Modifikace na ASCIIZ
         mov  byte ptr [si],0

; ------ Otev©en° definián°ho souboru pro áten°
         mov  ax,3D00h
         int  21h
         push cs
         pop  ds
         mov  dx,offset ChOpnF
         call Chyba
         mov  FHandle,ax

         mov  si,offset RedefT              ; SI<- Zaá†tek p©edefinov†vac° tabulky

; ------ Naáten° prvn°ho znaku ze souboru
         call XOddel
         jc   Ma89                          ; Chyba - nen° nic zad†no

; ------------------------------------------------------------------------------
; ------ Naáten° jednoho p©i©azovac°ho p©°kazu ze souboru

; ------ Äten° levÇ á†sti p©i©azovac°ho p©°kazu
Ma01:    mov  ah,PriradCh                   ; Zakonáovac° znak ©etàzce
         mov  di,offset RBuf1               ; Buffer pro vytv†©enò ©etàzec
         call RetPoOdd
         jc   Ma89                          ; Je jië konec souboru?
         mov  dx,offset SChPrazR            ; Hl†®en°: Pr†zdnò ©etàzec
         cmp  ch,1
         call SChyba                        ; CF=CY -> ûetàzec je pr†zdnò
         mov  DelR1,ch                      ; óschova dÇlky ©etàzce

; ------ Äten° pravÇ á†sti p©i©azovac°ho p©°kazu
         call XOddel
         mov  dx,offset SChKonS             ; ChybovÇ hl†®en° - p©edáasnò konec souboru
         call SChyba

         mov  ah,KonecPCh                   ; Zakonáovac° znak ©etàzce
         mov  di,offset RBuf2               ; Buffer pro vytv†©enò ©etàzec
         call RetPoOdd
         mov  dx,offset SChKonS             ; Hl†®en°: Ne£plnò p©i©. p©°kaz
         call SChyba                        ; Konec souboru?
         mov  DelR2,ch                      ; óschova dÇlky ©etàzce

; ------------------------------------------------------------------------------
; ------ Za©azen° naátenòch ©etàzcñ do tabulky

         mov  di,si                         ; DI<- Akt. pozice v redefinián° tabulce
         mov  si,offset RBuf1               ; SI<- Naátenò ©etàzec X

         xor  ch,ch
         mov  cl,DelR1                      ; CX<- DÇlka X
         mov  al,DelR2
         add  al,cl                         ; AL<- Souhrnn† dÇlka ©etàzcñ X+Y
         mov  dx,offset SChSouhD            ; Hl†®en° 'Celkov† dÇlka...'
         call SChyba                        ; O®et©en° chyby

         stosb                              ; Uloëen° dÇlky X+Y
         xor  al,al
         stosb                              ; Uloëen° akt. pozice v ©etàzci
         mov  al,cl
         stosb                              ; Uloëen° dÇlky X
         rep  movsb                         ; P©enos ©etàzce X
         mov  si,offset RBuf2               ; SI<- Naátenò ©etàzec Y
         mov  cl,DelR2                      ; CL<- DÇlka Y
         rep  movsb                         ; P©enos ©etàzce Y

; ------ Kontrola p©eteáen° tabulky
         mov  si,offset RedefT+VelRedT -1;? ; SI<- Konec p©edef. tabulky
         cmp  si,di
         mov  dx,offset ChPriVel            ; Hl†®en°: 'Soubor definic p©°li® velkò...'
         call Chyba

         mov  si,di                         ; óschova ukazatele do tabulky
         inc  PocRPol                       ; Aktualizace poátu poloëek tabulky

; ------ Naáten° prvn°ho znaku dal®°ho p©i©azen°
         call XOddel
         jnc  short Ma01                    ; Zpracov†n° dal®°ho p©i©azen°

; ------------------------------------------------------------------------------
; ------ Konec souboru p©i áten° levÇ á†sti p©i©azen° (=OK)
Ma89:    mov  dx,offset ChNezad             ; Hl†®en°: Nic nen° zad†no
         cmp  PocRPol,1                     ; Je-li 0, nastav° se CF=CY
         call Chyba

; ------ Zav©en° definián°ho souboru
Ma99:    mov  ah,3Eh
         mov  bx,FHandle
         int  21h

         pop  di
         pop  dx
         pop  cx
         pop  bx
         pop  ax
         ret
MakeRTab endp


; ==============================================================================
; Naáten° ©etàzce aë po ukonáovac° znak (znak v AH) na ES:DI
; ------------------------------------------------------------------------------
; Vstup: AL - prvn° znak ©etàzce naátenò ze souboru
;        AH - ukonáovac° znak
;        ES:DI - buffer pro ©etàzec
;        DS=CS
; Vòstup:CH - dÇlka ©etàzce
;        CF=CY -> Konec souboru
; Je-li ©etàzec del®°, neë maxim†ln° dÇlka, je vyvol†na syntaktick† chyba
; ==============================================================================
RetPoOdd proc near

         push ax
         push bx
         push dx
         push si
         push di

         mov  RePoOdd,ah                    ; óschova ukonáovac°ho znaku
         xor  ch,ch                         ; Inicializace poá°tadla dÇlky ©etàzce

; ------------------------------------------------------------------------------
; P©°kazovò m¢d    ********

; ------------------------------------------------------------------------------
; ------ Zad†n° hexadecim†ln°ho á°sla
RpPM0:   cmp  al,HexNumCh                   ; Bude zad†no hex. á°slo?
         jne  RpPM1                         ; Nebude

; ------ Naáten° prvn° á°slice
         call CtiZn2                        ; Äten° znaku s kontrolou konce souboru
         call JeHexNum                      ; P©evod hexa á°slice
         mov  dx,offset SChNeHex            ; Hl†®en°: Nen° hexa znak
         call SChyba
         mov  ah,al                         ; óschova hodnoty hexa á°slice

; ------ Naáten° druhÇ á°slice
         call CtiZn2                        ; Äten° znaku s kontrolou konce souboru
         call JeHexNum                      ; P©evod hexa á°slice
         jc   RpPM01                        ; Nen° hexa? Pak je v AH p©evedenÇ á°slo

; ------ Byly 2 á°slice - fin†ln° tvorba á°sla
         mov  cl,4
         shl  ah,cl
         or   al,ah                         ; AL<= P©evedenÇ á°slo
         call UlozZn                        ; Uloëen° p©evedenÇho znaku do ©etàzce
         jmp  RePo80                        ; Äten° a zpracov†n° dal®°ho znaku

; ------ Byla 1 á°slice
RpPM01:  mov  es:[di],ah                    ; óschova p©evedenÇho á°sla
         inc  di
         call UlozZn2                       ; Kontrola dÇlky ©etàzce
         call JeOddel                       ; Je znak v AL oddàlovaá?
         jne  RpPM0                         ; Ne, zpracuj ho jako p©°kaz
         jmp  RePo80                        ; Ano, norm†lnà áti dal®° znak


; ------------------------------------------------------------------------------
; ------ Zad†n° dekadickÇho á°sla
RpPM1:   cmp  al,DekNumCh                   ; Bude zad†no dek. á°slo?
         jne  RpPM2                         ; Nebude

; ------ Naáten° prvn° á°slice
         call CtiZn2                        ; Naáten° znaku s kontrolou konce souboru
         call JeDekNum                      ; Kontrola, zda je dekadick† á°slice
         mov  dx,offset SChNeDek
         call SChyba

         xor  bh,bh
         mov  bl,al                         ; BX<- P©ev†dànÇ á°slo

; ------ Naáten° druhÇ á°slice
         call CtiZn2                        ; Naáten° znaku s kontrolou konce souboru
         call JeDekNum                      ; Kontrola, zda je dekadick† á°slice
         jc   RpPM19                        ; Nen°, pak je v BX jië vòsledek

         xchg bl,al
         mul  byte ptr Rada10[6]
         add  bx,ax                         ; BX<= BL*10+AL

; ------ Naáten° t©et° á°slice
         call CtiZn2                        ; Naáten° znaku s kontrolou konce souboru
         call JeDekNum                      ; Kontrola, zda je dekadick† á°slice
         jc   RpPM19                        ; Nen°, pak je v BX jië vòsledek

         xchg bl,al
         mul  byte ptr Rada10[6]
         add  bx,ax                         ; BX<= BL*10+AL

; ------ Kontrola velikosti 3 cifernÇho á°sla
         or   bh,bh                         ; Nen° vàt®° neë 255?
         jz   RpPM18
         mov  dx,offset SChNeDek
         jmp  SChyba01
RpPM18:  call CtiZn2                        ; Naáten° znaku s kontrolou konce souboru

; ------ Uloëen° á°sla do bufferu
RpPM19:  mov  es:[di],bl
         inc  di
         call UlozZn2                       ; Kontrola dÇlky ©etàzce

; ------ Zpracov†n° znaku za posledn° cifrou
         jmp  short DoPMO


; ------------------------------------------------------------------------------
; ------ P©echod do textovÇho m¢du
RpPM2:   cmp  al,''''                       ; Bude p©echod do textovÇho reëimu?
         je   RpPMT

; ------------------------------------------------------------------------------
; ------ Konec ©etàzce
RpPM9:   cmp  al,RePoOdd                    ; Uë je konec ©etàzce?
         je   RePo99                        ; Ano

; ------ Nezn†mÇ n†và®t°
         mov  dx,offset SChRidZn
         jmp  SChyba01                      ; ChybovÇ hl†®en°

; ------------------------------------------------------------------------------
; Textovò m¢d      ********
RpPMT:   call CtiZn2                        ; Äten° znaku s kontrolou konce souboru

; ------ O®et©en° dvojice znakñ 13,10
RpPMT0:  cmp  al,13
         jne  RpPMT1

         call CtiZn2                        ; Naáten° dal®°ho znaku
         cmp  al,10                         ; Byla dvojice 13,10?
         je   RpPMT01                       ; Ano, to je chyba

         mov  byte ptr es:[di],13           ; Ne, uloëen° znaku 13 do ©etàzce
         inc  di
         call UlozZn2                       ; Kontrola dÇlky ©etàzce
         jmp  short RpPMT0

RpPMT01: mov  dx,offset SChReNoR            ; Chyba - novò ©†dek v ©etàzci
         jmp  SChyba01

; ------ O®et©en° dvojice apostrofñ
RpPMT1:  cmp  al,''''
         jne  RpPMT2

         call CtiZn2                        ; Naáten° dal®°ho znaku
         cmp  al,''''                       ; Je dvojice apostrofñ?
         je   RpPMT2                        ; Ano, apostrof je norm†ln° znak

; ------ Byl jen jeden apostrof - p©echod do p©°kazovÇho m¢du
DoPMO:   call JeOddel                       ; Je znak v AL oddàlovaá?
         je   RePo80                        ; Ano, norm†lnà áti dal®° znak
         jmp  RpPM0                         ; Ne, zpracuj ho jako p©°kaz

; ------ Standardn° znak
RpPMT2:  call UlozZn                        ; Uloëen° znaku do ©etàzce a kontrola dÇlky
         jmp  short RpPMT


; ------------------------------------------------------------------------------
; ------ Naáten° dal®°ho znaku
RePo80:  call XOddel
         mov  dx,offset SChKonS              ; ChybovÇ hl†®en° - p©edáasnò konec souboru
         call SChyba

         jmp  RpPM0

RePo99:  pop  di
         pop  si
         pop  dx
         pop  bx
         pop  ax
         ret

RePoOdd  db   0                             ; Oddàlovaá - konec ©etàzce
RetPoOdd endp


; ------------------------------------------------------------------------------
; Uloëen° znaku AL do ©etàzce ES:[DI], kontrola dÇlky v CH, p©°padnÇ hl†®en°
; ------------------------------------------------------------------------------
; Vstup: AL=Znak
; ------------------------------------------------------------------------------
UlozZn   proc near

         stosb
UlozZn2: inc  ch
         cmp  ch,VelRBuf
         ja   UlZn01
         ret

; ------ Chyba - ©etàzec je p©°li® dlouhò
UlZn01:  mov  dx,offset SChDlouR
         jmp  SChyba01

UlozZn   endp


; ------------------------------------------------------------------------------
; Kontrola, zda je AL dekadick† á°slice, p©evod na á°slo
; ------------------------------------------------------------------------------
; Vstup: AL=Znak '0'-'9'
; Vòstup:CF=CY -> Nen° á°slice
; ------------------------------------------------------------------------------
JeDekNum proc near

; ------ Test, zda je á°slo '0'-'9'
         cmp  al,'0'
         jb   JeHe99                        ; Konec s CF=CY (nen° dek.)
         cmp  al,'9'
         ja   JeHe88
         sub  al,'0'                        ; P©evod na á°slo 00h-09h
         ret
JeDekNum endp


; ------------------------------------------------------------------------------
; Kontrola, zda je AL hexadecim†ln° á°slice, p©evod na á°slo
; ------------------------------------------------------------------------------
; Vstup: AL=Znak '0'-'9', 'A'-'F', 'a'-'f'
; Vòstup:CF=CY -> Nen° á°slice, jinak AL=Ä°slo 00h-0Fh
; ------------------------------------------------------------------------------
JeHexNum proc near

; ------ Test, zda je malÇ p°smeno 'a'-'f'
         cmp  al,'a'
         jb   JeHe01
         cmp  al,'f'
         ja   JeHe88                        ; Je vàt®° => nen° hexa
         sub  al,'a'-0Ah                    ; P©evod na á°slo 0Ah-0Fh
         jmp  short JeHe99                  ; Konec s CF=NC

 ; ------ Test, zda je velkÇ p°smeno 'A'-'F'
JeHe01:  cmp  al,'A'
         jb   JeHe02
         cmp  al,'F'
         ja   JeHe88                        ; Je vàt®° => nen° hexa
         sub  al,'A'-0Ah                    ; P©evod na á°slo 0Ah-0Fh
         jmp  short JeHe99                  ; Konec s CF=NC

; ------ Test, zda je á°slo '0'-'9'
JeHe02:  cmp  al,'0'
         jb   JeHe99                        ; Konec s CF=CY (nen° hexa)
         cmp  al,'9'
         ja   JeHe88
         sub  al,'0'                        ; P©evod na á°slo 00h-09h
         jmp  short JeHe99

; ------ Chyba - nen° hexa
JeHe88:  stc
JeHe99:  ret
JeHexNum endp


; ------------------------------------------------------------------------------
; Zji®tàn°, zda je znak v AL oddàlovaá
; ------------------------------------------------------------------------------
; Vstup: AL=Znak
;        DS=ES=CS
; Vòstup:ZF=1 -> AL je oddàlovaá
; ------------------------------------------------------------------------------
JeOddel  proc near

         push cx
         push di

         mov  cx,PocOdd
         mov  di,offset OddelX
         repne scasb

         pop  di
         pop  cx
         ret
JeOddel  endp

OddelX   db   9,10,13,32,255
PocOdd   equ  $-offset OddelX


; ------------------------------------------------------------------------------
; Vyhled†n° zaá†tku novÇho ©†dku (+vyhozen° koment†©ñ)
; ------------------------------------------------------------------------------
; Vstup: DS=CS
; Vòstup:CF=CY -> Konec souboru, jinak AL=Prvn° znak novÇho ©†dku
; ------------------------------------------------------------------------------
NovyR    proc near

; ------ Vyhled†n° CR nebo LF
NovR01:  call CtiZn                         ; Jeden znak ze souboru
         jc   NovR99
         cmp  al,13                         ; CR?
         je   XOddel
         cmp  al,10                         ; LF?
         jne  NovR01

         inc  CAktR                         ; Poá°tadlo ©†dkñ

; ------------------------------------------------------------------------------
; Vyhozen° oddàlovaáñ a koment†©ñ
; ------------------------------------------------------------------------------
; Vstup: DS=CS
; Vòstup:CF=CY -> Konec souboru, jinak AL=Prvn° uëiteánò znak
; ------------------------------------------------------------------------------
XOddel:  call CtiZn
         jc   NovR99
         cmp  al,10                         ; LF?
         jne  XOdd01
         inc  CAktR                         ; Poá°tadlo ©†dkñ
         jmp  short XOddel

XOdd01:  call JeOddel
         je   XOddel

; ------ Kontrola koment†©e
         cmp  al,CommCh                     ; Je dal®° ©†dek koment†©em?
         je   NovR01                        ; Hledej dal®° ©†dek

         clc

NovR99:  ret
NovyR    endp


; ------------------------------------------------------------------------------
; Äten° znaku s kontrolou konce souboru a p©°padnou syntaktickou chybou
; 'P©edáasnò konec souboru'. Parametry jako u CtiZn
; ------------------------------------------------------------------------------
CtiZn2:  call CtiZn
         jc   CtZ201
         ret
; ------ Chyba - konec souboru
CtZ201:  mov  dx,offset SChKonS
         jmp  SChyba01


; ------------------------------------------------------------------------------
; Äten° znaku ze souboru do AL
; ------------------------------------------------------------------------------
; Vstup: DS=CS
; Vòstup:CF=CY -> Je konec souboru, jinak AL=Znak
; ------------------------------------------------------------------------------
CtiZn    proc near

         push bx

         mov  bx,PozCBuf
         cmp  bx,PlatCBuf                   ; Jsou data v bufferu?
         jb   CtZn70

; ------ Naáten° bloku dat do bufferu
         push ax
         push cx
         push dx

         mov  ah,3Fh
         mov  bx,FHandle
         mov  cx,VelCBuf
         mov  dx,offset CBuf
         int  21h
         mov  dx,offset ChRdF               ; ChybovÇ hl†®en°
         call Chyba                         ; O®et©en° p©°padnÇ chyby

; ------ Aktualizace bufferovòch promànnòch
         mov  PlatCBuf,ax                   ; DÇlka naátenòch dat
         xor  bx,bx                         ; Pozice v bufferu

; ------ Kontrola, zda bylo nàco p©eáteno
         cmp  ax,1

         pop  dx
         pop  cx
         pop  ax

         jb   CtZn89                        ; Konec, CF=CY

; ------ Vyjmut° bajtu z bufferu
CtZn70:  mov  al,CBuf[bx]
         inc  bx
         mov  PozCBuf,bx
         clc                                ; Konec, CF=NC

CtZn89:  pop  bx
         ret
CtiZn    endp


FHandle  dw   0                             ; Handle def. souboru

PozCBuf  dw   0                             ; Pozice ve átec°m bufferu
PlatCBuf dw   0                             ; DÇlka platnòch dat ve átec°m bufferu
CBuf     db   VelCBuf dup (0)               ; Ätec° buffer

DelR1    db   0                             ; DÇlka ©etàzce v 1. bufferu
RBuf1    db   VelRBuf dup (0)               ; 1. buffer pro ©etàzec
DelR2    db   0                             ; DÇlka ©etàzce v 2. bufferu
RBuf2    db   VelRBuf dup (0)               ; 2. buffer pro ©etàzec



; ------------------------------------------------------------------------------
; O®et©en° fat†ln°ch chyb
; ------------------------------------------------------------------------------
; Vstup: CS:DX - ChybovÇ hl†®en°
;        CF=CY -> Chyba
;        DS=CS
; ------------------------------------------------------------------------------
Chyba:   jc   Chyba01
         ret

Chyba01: call PisTxt                        ; Vòpis koment†©e chyby
         mov  dx,offset ChybaT9             ; Z†vàr chyb. hl†®en°
         call PisTxt                        ; Vòpis textu

; ------ Ukonáen° programu
Chyba99: mov  ax,4C01h                      ; Navratovò k¢d=1
         int  21h


; ------------------------------------------------------------------------------
; O®et©en° syntaktickòch chyb
; Vstup: CS:DX - Text p©°áiny chyby
;        CF=CY -> Chyba
;        DS=CS
; ------------------------------------------------------------------------------
SChyba:  jc   SChyba01
         ret

; ------ P©evod á°sla ©†dku na text
SChyba01:push dx

         mov  ax,CAktR
         mov  di,offset SChybaC             ; C°lovò ©etàzec pro p©evod
         xor  bx,bx                         ; BX - Poá°tadlo cifer

PiWo01:  xor  dx,dx                         ; AX:DX<- Ä°slo k dàlen° mocninou 10
         div  Rada10[bx]                    ; AX<- Aktu†ln° cifra
         add  al,'0'                        ; AL<- ASCII znak
         stosb                              ; óschova znaku
         mov  ax,dx                         ; P©enos zbytku do dal®°ho kola

         add  bx,2
         cmp  bx,10
         jb   PiWo01

         mov  byte ptr [di],'$'             ; Zakonáovac° znak

; ------ Vòpis chybovÇho hl†®en° textñ
         mov  dx,offset SChybaT0            ; Okec a á°slo ©†dku
         call PisTxt                        ; Vòpis textu
         mov  dx,offset SChybaT1            ; Novò ©†dek
         call PisTxt                        ; Vòpis textu
         pop  dx                            ; P©°áina chyby
         call PisTxt                        ; Vòpis textu
         mov  dx,offset SChybaT9            ; Z†vàr a p°pnut°
         call PisTxt                        ; Vòpis textu

         jmp  short Chyba99                 ; Ukonáen° programu


; ------ Chybov† hl†®en° - fat†ln° chyby
ChybaT9  db   13,10,7,'$'

ChVerDOS db   'Program vyëaduje pro svoji áinnost MS-DOS verze 3.0 a vy®®°!$'
ChOpnF   db   'Definián° soubor nelze otev©°t!$'
ChRdF    db   'Chyba áten° definián°ho souboru.$'
ChPriVel db   'Soubor definic je p©°li® velkò (max. 32kB áistòch dat)!$'
ChNezad  db   'Nejsou zad†ny ë†dnÇ definice - program nebude instalov†n.$'

; ------ Chybov† hl†®en° - syntaktickÇ chyby
SChybaT0 db   'Syntaktick† chyba v definián°m souboru na ©†dku '
SChybaC  db   7 dup (0)
SChybaT1 db   13,10,'$'
SChybaT9 db   '.',13,10,7,'$'

SChRidZn db   'Nep©°pustnò ©°d°c° znak$'
SChDlouR db   'Byla p©ekroáena maxim†ln° dÇlka ©etàzce$'
SChPrazR db   'Na levÇ stranà p©i©azovac°ho p©°kazu chyb° ©etàzec$'
SChNeHex db   'Nep©°pustnÇ hexadecim†ln° á°slo$'
SChNeDek db   'Nep©°pustnÇ dekadickÇ á°slo$'
SChReNoR db   'ûetàzec p©esahuje konec ©†dku$'
SChKonS  db   'Neoáek†vanò konec souboru$'

SChSouhD db   'Souhrnn† dÇlka oubou ©etàzcñ p©i©azen° nesm° p©es†hnout 255 znakñ$'

Rada10   dw   10000,1000,100,10,1           ; ûada mocnin 10ti
CAktR    dw   1                             ; Ä°slo aktu†ln°ho ©†dku

; ------------------------------------------------------------------------------
; Vòpis ©etàzce zakonáenÇho '$'
; ------------------------------------------------------------------------------
; Vstup: DS:DX - ûetàzec zakonáenò znakem '$'
; Niá°:  AX
; ------------------------------------------------------------------------------
PisTxt   proc near
         mov  ah,9
         int  21h
         ret
PisTxt   endp


code     ends
         end  start

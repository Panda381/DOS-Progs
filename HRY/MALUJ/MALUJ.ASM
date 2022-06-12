
; *****************************************************************************
;
;                         M A L U J
;
;                      grafickò editor
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

;DEMO     EQU       1                        ; p©°znak demonstraán° verze

Zasob    EQU       400h                     ; rezerva pro z†sobn°k

Maska    EQU       8000h                    ; offset masky obr†zku

start:
         sti

; ------ test, zda je karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut° informac° EGA
         mov       bx,05e10h                ; podfunkce informac°
         int       10h                      ; poskytnut° informac° EGA/VGA
         cmp       bh,2                     ; m¢d displeje 0 nebo 1
         jae       Inst1                    ; chyba - neplatnò obsah registru
         cmp       bl,5                     ; maxim†ln° velikost pamàti 1 MB
         jbe       Inst2                    ; velikost pamàti OK

; ------ chyba - nen° karta EGA/VGA

Inst1:   mov       dx,offset EgaErr
Inst11:  mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
Inst12:  int       20h

; ------ test, zda je dostatek pamàti

Inst2:   mov       dx,offset MemErr         ; test - nedostatek pamàti
         cmp       sp,offset Buffer + 1000h + Zasob ; kontrola konce pamàti
         jb        Inst11                   ; nedostatek pamàti

; ------ kontrola, zda je my®

;         mov       dx,offset MouseErr
         xor       ax,ax
         call      Mouse
         inc       ax
;         jnz       inst11                   ; chyba - nen° my®

; ------ v®e OK - zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ áek†n° na stisk kl†vesy

         mov       ah,8
         int       21h
         cmp       al,27
         je        Inst12
         or        al,al
         jnz       Inst22
         mov       ah,8
         int       21h

; ------ instalace obsluhy INT 24h

Inst22:  mov       ax,2524h
         mov       dx,offset Int24
         int       21h                      ; instalace INT 24h

; ------ £schova videom¢du

         mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al

; ------ nastaven° videom¢du

         mov       ax,16
         int       10h
         mov       ah,0fh
         int       10h
         cmp       al,16
         jne       Inst1                    ; chyba - videom¢d nelze nastavit

; ------ zobrazen° okna

         call      Podklad                  ; podklad kreslic° plochy
         call      DispMenu                 ; zobrazen° menu

; ------ instalace obsluhy p©eru®en°

         mov       ax,2523h
         mov       dx,offset Konec
         int       21h

; ------ definice okna pro my®

         xor       cx,cx
         mov       dx,ds:[MaxX]
         mov       ax,7
         call      Mouse
         xor       cx,cx
         mov       dx,ds:[MaxY]
         mov       ax,8
         call      Mouse

; ------ definice kurzoru my®i

         mov       dx,offset Kurzor1
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse

; ------ naáten° prvn°ho obr†zku

         and       byte ptr ds:[Param],not 4 + 1
         xor       ax,ax
         call      FindFile
         jc        St1111
         call      SetSoub
         call      ReadFile
         inc       ax
         call      FindFile
         jc        st1111
         or        byte ptr ds:[Param],4
st1111:  call      DispMenu                 ; novÇ zobrazen° menu

; ------ zapnut° kurzoru my®i

st111:   call      MouseOn

; ------ nastaven° kurzoru na novou pozici

st56:    call      MouseOld
st5:
         mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jnz       st5002                   ; nen° p©ipraven znak

         mov       ah,8
         int       21h                      ; vstup znaku z konzoly
         or        al,al                    ; je ©°dic° kl†vesa ?
         jnz       st5002                   ; nen° ©°dic° kl†vesa
         mov       ah,8
         int       21h                      ; vstup SCAN k¢du kl†vesy

         cmp       al,73h
         jne       st5x01                   ; Ctrl-Left
         jmp       ObrLeft

st5x01:  cmp       al,74h
         jne       st5x02                   ; Ctrl-Rght
         jmp       ObrRght

st5x02:  cmp       al,65h                   ; Ctrl-F8
         jne       st5x03
         call      Tisk                     ; vyti®tàn° na tisk†rnu
         jmp       short st5002

st5x03:
         or        byte ptr ds:[Param],20h  ; obrysy rozhran° barev
         cmp       al,67h
         je        st5001                   ; je Ctrl-F10
         and       byte ptr ds:[Param],not 20h ; nejsou obrsysy rozhran° barev
         cmp       al,66h
         jne       st500101                 ; nen° Ctrl-F9

st5001:
         call      MouseOff
         call      Obrys                    ; vytvo©en° obrysu obr†zku
         call      MouseOn
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru

st500101:cmp       al,64h                   ; Ctrl-F7
         jne       st5002

         call      ZrusMsk                  ; zru®en° masky obr†zku

st5002:
         call      MouseGet
         jc        st5

         test      bl,7
         jz        st56                     ; nen° nic stisknuto

; ------ obsluha voleb

         cmp       dx,350-32
         jae       st502

         jmp       st58                     ; nen° v ikon†ch - plat°

st502:
         test      bl,ds:[OldKey]           ; je prvn° stisk ?
         jnz       st5                      ; nen° prvn° stisk

         cmp       cx,16*32                 ; je volba barvy ?
         jae       st59                     ; nen° volba barvy

         mov       ax,cx
         mov       cl,5
         shr       ax,cl                    ; stanoven° á°sla barvy
         cmp       byte ptr ds:[Barva],al   ; byla barva zmànàna ?
         je        st5                      ; barva nebyla zmànàna
         mov       ds:[Barva],al            ; nastaven† barva
         call      MouseOff
         call      DispMenu
         call      MouseOn
st5x00:  jmp       st5


st59:    cmp       cx,16*32+32              ; je pero 1 ?
         jae       st5a                     ; nen° pero 1

         cmp       byte ptr ds:[Pero],2     ; je jië pero 1 ?
         je        st5x00                   ; je jië pero 1
         mov       byte ptr ds:[Pero],2     ; á†ra pro pero 1
         mov       dx,offset Kurzor1
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
         jmp       short st5555

st5a:    cmp       cx,16*32 + 32 + 32       ; je pero 2 ?
         jae       st5b

         cmp       byte ptr ds:[Pero],10    ; je jië pero 2 ?
         je        st5555                   ; je jië pero 2
         mov       byte ptr ds:[Pero],10    ; á†ra pro pero 2
         mov       dx,offset Kurzor2
         mov       ax,9
         mov       bx,6
         mov       cx,6
         call      Mouse
st5555:  jmp       st5

st5b:    cmp       cx,16*32 + 3 * 32        ; posun vlevo
         jae       st5c

ObrLeft: test      byte ptr ds:[Param],1    ; je platnò soubor ?
         jz        st5b21                   ; nen° platnò soubor
         test      byte ptr ds:[Param],2    ; byl obraz modifikov†n ?
         jz        st5b21                   ; obraz nebyl modifikov†n

         call      MouseOff
         call      WritFile                 ; z†pis obr†zku do souboru
         call      MouseOn

st5b21:
         cmp       word ptr ds:[AktSoub],0
         je        st5555

         call      MouseOff
         call      Podklad                  ; podklad kreslic° plochy
         mov       ax,ds:[AktSoub]
         or        ax,ax
         jz        st5b22
         dec       ax
st5b22:
         and       byte ptr ds:[Param],not 1 ; nen° platnò soubor
         call      FindFile
st5b23:  call      SetSoub
         call      ReadFile

         and       byte ptr ds:[Param],not 4
         inc       ax
         call      FindFile
         jc        st5b26
         or        byte ptr ds:[Param],4
st5b26:  call      DispMenu                 ; novÇ zobrazen° menu
         call      MouseOn
         jmp       short st5555

st5c:
         cmp       cx,16*32 + 4*32          ; posun vpravo
         jae       st5d

ObrRght: test      byte ptr ds:[Param],1    ; je platnò soubor ?
         jz        st5c1                    ; nen° platnò soubor
         test      byte ptr ds:[Param],2    ; byl obraz modifikov†n ?
         jz        st5c1                    ; obraz nebyl modifikov†n
         call      MouseOff
         call      WritFile                 ; z†pis obr†zku do souboru
         call      MouseOn
st5c1:
         test      byte ptr ds:[Param],4
         jz        st5555

         call      MouseOff
         call      Podklad                  ; podklad kreslic° plochy
         mov       ax,ds:[AktSoub]
         inc       ax
         call      FindFile
         jnc       st5b23
         dec       ax
         jmp       short st5b22

st5d:
         jmp       st5

; ------ p©i prvn°m stisku uloëen° sou©adnic

st58:    or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru
         test      bl,ds:[OldKey]           ; je prvn° stisk ?
         jnz       st584

         call      MouseOld                 ; je prvn° stisk
         call      MouseOff
         push      bx
         push      cx
         mov       al,ds:[Barva]
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jz        st58301                  ; nen° pravÇ tlaá°tko
         mov       al,7                     ; barva pro maz†n°
st58301: mov       bx,cx
         mov       si,dx
         cmp       byte ptr ds:[Pero],5
         jbe       st583
         inc       cx
         inc       cx
st583:   call      Line0                    ; zobrazen° jendoho bodu
         pop       cx
         pop       bx
         call      MouseOn
         jmp       st56                     ; je prvn° stisk
st584:
         mov       ds:[OldKey],bl

; ------ zobrazen° á†ry

         call      MouseOff                 ; vypnut° my®i
         mov       si,dx
         mov       al,ds:[Barva]            ; aktivn° barva
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jz        st58401                  ; nen° pravÇ tlaá°tko
         mov       al,7                     ; barva pro maz†n°
st58401: mov       bx,ds:[OldX]
         mov       dx,ds:[OldY]
         call      Line0
         mov       ds:[OldX],cx
         mov       ds:[OldY],si
         call      MouseOn                  ; opàt zapnut° my®i
         jmp       st5                      ; áek†n° na dal®° á†ru



Konec:
         push      cs
         pop       ds

         xor       ah,ah
         mov       al,ds:[OldVMod]
         int       10h                      ; pñvodn° videom¢d

         int       20h

; *****************************************************************************
;
;                              Obsluha INT 24h
;
; *****************************************************************************

Int24    PROC      NEAR

         xor       al,al                    ; ignorov†n° chyby
         iret

Int24    ENDP

; *****************************************************************************
;
;                     vyti®tàn° obr†zku na tisk†rnu
;
; *****************************************************************************

Tisk     PROC      NEAR

ifndef   DEMO
         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si

; ------ inicializace tisk†rny

         mov       si,offset TiskKod1
         mov       cx,3
         call      TiskTxt                  ; inicializace tisk†rny
         jc        Tisk9                    ; chyba tisk†rny
         xor       dx,dx                    ; ukazatel ©†dkñ

; ------ test, zda je p©eru®en° operace

Tisk1:   mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jnz       Tisk2                    ; nen° p©ipraven znak
         mov       ah,8
         int       21h                      ; vstup znaku
         cmp       al,27
         je        Tisk9                    ; p©eru®en° operace
         or        al,al
         jnz       Tisk2
         mov       ah,8
         int       21h

; ------ £vodn° k¢d pro tisk ©†dku

Tisk2:   mov       si,offset TiskKod2
         mov       cx,5
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk9                    ; chyba vòstupu na tisk†rnu
         xor       bx,bx                    ; ukazatel pozice na ©†dku

; ------ generov†n° bajtu k¢du

Tisk3:   push      dx
         mov       cx,8                     ; poáet bajtñ
         xor       ah,ah                    ; st©adaá bitñ
Tisk4:   cmp       dx,350-32
         jae       Tisk6                    ; p©ekroáen° hranice
         call      GetPoint                 ; poskytnut° barvy bodu
         or        al,al                    ; je áern† barva ?
         jnz       Tisk5                    ; nen° áern† barva
         stc                                ; p©°znak áernÇ barvy
Tisk5:   rcl       ah,1                     ; rotace bitu
Tisk6:   inc       dx                       ; zvò®en° ukazatele linky
         loop      Tisk4                    ; dal®° bit
         pop       dx
         mov       al,ah                    ; bajt k vysl†n° na tisk†rnu
         call      TiskByte                 ; vysl†n° bajtu na tisk†rnu
         jc        Tisk9                    ; chyba

; ------ dal®° bajt na ©†dku

         inc       bx                       ; zvò®en° ukazatele bodñ
         cmp       bx,640
         jb        Tisk3                    ; dal®° bajt

; ------ dal®° ©†dek

         mov       al,13                    ; znak CR
         call      TiskByte                 ; vysl†n° znaku CR
         jc        Tisk9
         mov       al,10                    ; znak LF
         call      TiskByte
         jc        Tisk9
         add       dx,8                     ; zvò®en° á°sla ©†dku
         cmp       dx,350-32
         jb        Tisk1                    ; dal®° ©†dek

; ------ n†vrat registrñ

Tisk9:   pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn
endif
         ret

Tisk     ENDP

; *****************************************************************************
;                             TiskTxt
;                   vysl†n° textu na tisk†rnu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text k vyti®tàn°
;        CX=poáet bajtñ
; VùSTUP:CY=chyba vòstupu na tisk†rnu
; *****************************************************************************

TiskTxt  PROC      NEAR

TiskTxt1:cld
         lodsb
         call      TiskByte
         jc        TiskTxt2
         loop      TiskTxt1
TiskTxt2:ret

TiskTxt  ENDP

; *****************************************************************************
;                             TiskByte
;                    vysl†n° bajtu na tisk†rnu
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k vysl†n° na tisk†rnu
; VùSTUP:CY=chyba vòstupu na tisk†rnu
; *****************************************************************************

TiskByte PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ test p©ipravenosti tisk†rny

         push      ax
         mov       ah,2
         xor       dx,dx
         int       17h                      ; test stavu portu
         xor       ah,10h
         test      ah,20h + 10h + 8         ; tisk†rna p©ipravena ?
         pop       ax
         stc                                ; p©°znak chyby
         jnz       TiskByt9                 ; chyba

; ------ vysl†n° bajtu na tisk†rnu

         mov       ah,0
         xor       dx,dx
         int       17h
         test      ah,20h+8+1               ; operace OK ?
         jz        TiskByt9                 ; v®e je OK
         stc                                ; p©°znak chyby vòstupu

; ------ n†vrat registrñ

TiskByt9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

TiskByte ENDP

; *****************************************************************************
;
;                     vytvo©en° obrysñ obr†zku
;
; *****************************************************************************

Obrys    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ prvn° vymaz†n° bufferu linky

         mov       di,offset Buffer
         mov       cx,350-32
         cld
         xor       al,al
         rep       stosb

; ------ p©°prava registrñ k dek¢dov†n°

         mov       cx,640                   ; poáet sloupcñ
         mov       bx,639                   ; ukazatel sloupce

; ------ dek¢dov†n° jednoho sloupce

Obrys1:  xor       ah,ah                    ; p©ednastaven° minulÇho bodu
         push      cx                       ; £schova á°taáe sloupcñ
         xor       dx,dx                    ; poá†teán° linka bodu
         mov       cx,350-32                ; poáet linek na sloupec
         mov       di,offset Buffer         ; buffer minulÇho sloupce

; ------ vysv°cen° kurzoru

         push      dx
         mov       al,0                     ; áern†
         mov       dx,350-32
         call      Point                    ; zobrazen° kurzoru
         pop       dx

Obrys2:  call      GetPoint                 ; poskytnut° barvy bodu

; ------ nyn° je áern† barva - zñstane áern†

         or        al,al                    ; je áern† barva ?
         jz        Obrys22                  ; bude áern† barva

; ------ nejsou-li obrysy podle rozhran° barev, jsou ostatn° barvy b°lÇ

         test      byte ptr ds:[Param],20h  ; obrysy rozhran° barev ?
         jz        Obrys24                  ; n†hrada b°lou barvou

; ------ jsou odli®nÇ barvy a nebyla to minule áern† - bude teÉ áern†

Obrys21: cmp       al,ah                    ; jsou shodnÇ barvy ?
         je        Obrys23                  ; jsou shodnÇ barvy
         or        ah,ah                    ; byla minule áern† ?
         jz        Obrys23                  ; minule byla áern†
Obrys22: mov       ah,al                    ; £schova barvy
         xor       al,al                    ; teÉ bude áern†
         jmp       short Obrys3

; ------ jsou odli®nÇ barvy se staròm sloupcem a nebyla áern† - bude áern†

Obrys23: cmp       al,ds:[di]               ; byla stejn† barva ?
         je        Obrys24                  ; byla shodn† barva
         cmp       byte ptr ds:[di],0       ; byla minule áern† barva ?
         jne       Obrys22                  ; nebyla áern† - bude teÉ áern†

; ------ jinak bude n†hradn° b°l† barva

Obrys24: mov       ah,al                    ; £schova barvy
         mov       al,7                     ; nahrad° se b°lou barvou

; ------ nastaven° novÇ barvy

Obrys3:  mov       ds:[di],ah               ; £schova barvy bodu
         call      Point                    ; nastaven° barvy bodu
         inc       di                       ; zvò®en° adresy v bufferu bodñ
         inc       dx                       ; zvò®en° linky
         loop      Obrys2

; ------ zru®en° kurzoru

         mov       al,15                    ; b°l†
         call      Point                    ; zobrazen° kurzoru

         pop       cx
         dec       bx                       ; sn°ëen° ukazatele linky

; ------ test, zda je p©eru®en° operace

         push      ax
         mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jnz       Obrys4                   ; nen° p©ipraven znak
         mov       ah,8
         int       21h                      ; vstup znaku
         cmp       al,27
         je        Obrys4
         or        al,al
         jnz       Obrys4
         mov       ah,8
         int       21h
         or        al,al
Obrys4:  pop       ax

         loopnz    Obrys1                   ; dal®° linka

         call      DispMenu                 ; novÇ zobrazen° menu

; ------ n†vrat registrñ

         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Obrys    ENDP


; *****************************************************************************
;
;              Obsluha zobrazen° jednotlivòch á†st° displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        zru®en° masky obr†zku
; -----------------------------------------------------------------------------

ZrusMsk  PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace masky

         call      DeIniReg                 ; inicializace registrñ
         push      es
         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; z†pis do v®ech rovin
         mov       di,Maska
         mov       ax,0a000h
         mov       es,ax
         mov       ax,0ffffh
         mov       cx,(350-32)*80/2
         cld
         rep       stosw
         pop       es

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       ax
         ret

ZrusMsk  ENDP

; -----------------------------------------------------------------------------
;                          zobrazen° podkladu
; -----------------------------------------------------------------------------

Podklad  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         call      ZrusMsk                  ; zru®en° masky obr†zku

; ------ podkladovò obdÇln°k

         xor       bx,bx
         xor       dx,dx
         mov       cx,ds:[RozmerX]
         mov       si,350-32
         mov       al,7
         call      Box

; ------ n†vrat registrñ

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Podklad  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° menu
; -----------------------------------------------------------------------------

DispMenu PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ inicializace masky

         call      DeIniReg                 ; inicializace registrñ
         push      es
         mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al                    ; z†pis do v®ech rovin
         mov       di,80*(350-32) + Maska
         mov       ax,0a000h
         mov       es,ax
         mov       ax,0ffffh
         mov       cx,32*80/2
         cld
         rep       stosw
         pop       es

; ------ zobrazen° obdÇln°kñ barev

         xor       al,al                    ; poá†teán° barva
         xor       bx,bx                    ; poá†teán° pozice
         mov       dx,350-32
         inc       dx
         inc       bx
         mov       cx,30
         mov       si,30
DispMen1:call      Box
         add       bx,32
         inc       al
         cmp       al,15
         jbe       DispMen1

; ------ zobrazen° obrysñ obdÇln°kñ

         xor       bx,bx
         dec       dx
         mov       cx,16*32
         mov       si,dx
         mov       al,15
         call      Line
         add       dx,31
         add       si,31
         call      Line
         xor       cx,cx
         sub       si,31
         call      Line
         add       bx,16*32-1
         add       cx,16*32-1
         call      Line

; ------ menu

         mov       bx,16*32
         mov       dx,350-32
         mov       di,offset ObrPero1
         mov       si,32
         mov       cx,32
         call      Pict

         mov       di,offset ObrPero2
         add       bx,32
         call      Pict

         mov       di,offset ObrZpet
         add       bx,32
         mov       al,15
         cmp       word ptr ds:[AktSoub],0
         jne       DispMen4
         mov       al,7
DispMen4:call      Pict

         mov       di,offset ObrTam
         add       bx,32
         mov       al,15
         test      byte ptr ds:[Param],4
         jnz       DispMen5
         mov       al,7
DispMen5:call      Pict

; ------ sou©adnice aktivn° barvy

         mov       al,ds:[Barva]            ; aktivn° barva
         mov       ah,32                    ; poáet bajtñ na poloëku
         mul       ah                       ; offset zaá†tku barvy
         add       ax,4                     ; poá†teán° pozice kurzoru
         mov       bx,ax
         add       dx,4                     ; poá†teán° linka kurzoru

; ------ barva kurzoru aktivn° barvy

         mov       al,0                     ; barva áern†
         mov       ah,ds:[Barva]            ; aktivn° barva
         cmp       ah,14
         jae       DispMen6                 ; je barva ëlut† nebo b°l†
         cmp       ah,11
         je        DispMen6                 ; svàtle modrozelen† barva
         cmp       ah,10
         je        DispMen6                 ; svàtle zelen† barva
         cmp       ah,7
         je        DispMen6                 ; tmavà b°l† barva
         mov       al,15                    ; jinak barva b°l†

; ------ zobrazen° kurzoru aktivn° barvy

DispMen6:mov       cx,24
         mov       si,2
         call      Box                      ; zobrazen° obdÇln°ku naho©e
         add       dx,22
         call      Box
         sub       dx,22
         mov       cx,2
         mov       si,24
         call      Box
         add       bx,22
         call      Box

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispMenu ENDP


; *****************************************************************************
;
;                             obsluha my®i
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        vypnut° kurzoru my®i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         push      ax
         mov       ax,2
         jmp       short MouseOn1

MouseOff ENDP

; -----------------------------------------------------------------------------
;        zapnut° kurzoru my®i
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

         push      ax
         mov       ax,1
MouseOn1:push      bx
         push      cx
         push      dx

         call      Mouse

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        nastaven° pozice my®i
; -----------------------------------------------------------------------------

MouseSet PROC      NEAR

         push      ax
         mov       ax,4
         call      Mouse
         pop       ax
         ret

MouseSet ENDP

; -----------------------------------------------------------------------------
;        navr†cen° pozice a stavu my®i
; -----------------------------------------------------------------------------
; VSTUP:  DS=datovò segment
; VùSTUP: BX=bit 0: levÇ tlaá°tko
;            bit 1: pravÇ tlaá°tko
;            bit 2: prost©edn° tlaá°tko
;         CX=sloupec
;         DX=©†dek
;         CY=nebyla zmàna
; -----------------------------------------------------------------------------

MouseGet PROC      NEAR

         push      ax
         mov       ax,3
         call      Mouse
         and       bl,7
         cmp       cx,ds:[OldX]
         jne       MouseGt2
         cmp       dx,ds:[OldY]
         jne       MouseGt2
         cmp       bl,ds:[OldKey]
         stc
         je        MouseGt3
MouseGt2:clc
MouseGt3:pop       ax
         ret

MouseGet ENDP

; -----------------------------------------------------------------------------
;        £schova stavu my®i (BX, CX a DX po n†vratu z MouseGet)
; -----------------------------------------------------------------------------

MouseOld PROC      NEAR

         mov       ds:[OldX],cx
         mov       ds:[OldY],dx
         mov       ds:[OldKey],bl
         ret

MouseOld ENDP

; -----------------------------------------------------------------------------
;        obsluha my®i
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Mouse    ENDP


; *****************************************************************************
;
;                            obsluha displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                          zobrazen° obr†zku (2 barvy)
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=®°©ka obr†zku (bodñ)
;        DX=poá†teán° linka
;        SI=vò®ka obr†zku
;        DI=adresa obr†zku
;        DS=datovò segment
; -----------------------------------------------------------------------------

Pict     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,ds:[RozmerB]          ; poáet bajtñ na linku
         mul       dx                       ; poá†teán° offset linky
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet pozice na bajty
         add       bx,ax                    ; adresa ve videopamàti
         xchg      bx,di                    ; DI<-adresa videopamàti, BX<-obraz
         xchg      si,bx                    ; BX <- vò®ka, SI <- obraz
         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti

; ------ inicializace registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; maska - v®echny bity

; ------ korekce poátu bajtñ na linku

         add       cx,7                     ; zaokrouhlen° na bajty
         shr       cx,1
         shr       cx,1
         shr       cx,1

; ------ zobrazen° jednÇ linky obr†zku

         cld
Pict1:   push      di                       ; £schova ukl†dac° adresy
         push      cx                       ; £schova ®°©ky linky obr†zku
Pict2:   lodsb                              ; bajt k zobrazen°
         xchg      al,es:[di]
         inc       di
         loop      Pict2
         pop       cx
         pop       di
         add       di,ds:[RozmerB]
         dec       bx                       ; á°taá linek
         jnz       Pict1                    ; dal®° linka

; ------ n†vrat registrñ

         call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Pict     ENDP

; -----------------------------------------------------------------------------
;                  Zobrazen° obdÇln°ku zadanÇho sou©adnicemi
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=koncov† pozice
;        DX=poá†teán° linka
;        SI=koncov† linka
;        DS=datovò segment
; -----------------------------------------------------------------------------

Box0     PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx
         push      si

; ------ oprava poá†teán° pozice

         cmp       bx,cx
         jle       Box01
         xchg      bx,cx

; ------ oprava poá†teán°ho ©†dku

Box01:   cmp       dx,si
         jle       Box02
         xchg      dx,si

; ------ vòpoáet ®°©ky a vò®ky obdÇln°ku

Box02:   sub       cx,bx
         sub       si,dx
         inc       cx
         inc       si

; ------ zobrazen° obdÇln°ku

         call      Box

; ------ n†vrat registrñ

         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Box0     ENDP

; -----------------------------------------------------------------------------
;                       Zobrazen° obdÇln°ku
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        CX=®°©ka
;        DX=linka
;        SI=vò®ka
;        DS=datovò segment
; -----------------------------------------------------------------------------
; lok†ln° promànnÇ: SS:[BP-1]=poá†teán° maska
;                   SS:[BP-2]=koncov† maska
;                   SS:[BP-4]=poáet vnit©n°ch bajtñ
; -----------------------------------------------------------------------------

Box      PROC      NEAR

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

; ------ vytvo©en° bufferu pro lok†ln° promànnÇ

         sub       sp,4

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,dx                    ; hodn° okraj poá†tku k zobrazen°
         mul       word ptr ds:[RozmerB]    ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       ax,bx                    ; levò okraj zaá†tku zobrazen°
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; p©epoáet na offset v bajtech
         add       di,ax                    ; poá†teán° adresa k zobrazen°
         mov       ax,0a000h                ; segment videopamàti
         mov       es,ax                    ; segment videopamàti

; ------ vòpoáet prvn° masky objektu (levò okraj)

         xchg      cx,bx                    ; CL<-levò okraj zaá†tku zobrazen°
         and       cl,7                     ; poá†teán° bitov† pozice (0 aë 7)
         mov       al,0ffh                  ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (FF aë 01)
         mov       ss:[bp-1],al             ; maska prvn°ho bajtu

; ------ vòpoáet poátu zbylòch bodñ

         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet necelòch bodñ vlevo (1 aë 8)
         mov       ah,0                     ; BX=poáet bodñ zobrazenòch vlevo
         sub       bx,ax                    ; poáet zbylòch bodñ
         js        Box1                     ; je malò poáet bodñ

; ------ vòpoáet poátu celòch bajtñ

         mov       dx,bx                    ; £schova poátu zbylòch bodñ
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; poáet celòch vnit©n°ch bajtñ
         mov       ss:[bp-4],bx             ; poáet vnit©n°ch bajtñ

; ------ vòpoáet masky pravÇho okraje

         and       dl,7                     ; poáet zbylòch bodñ vpravo (0 aë 7)
         mov       cl,8                     ; poáet bodñ na bajt
         sub       cl,dl                    ; poáet nezobraz. bodñ vpravo (1-8)
         mov       al,0ffh                  ; maska pravÇho okraje
         shl       al,cl                    ; vòpoáet masky pravÇho okr. (00-FE)
         mov       ss:[bp-2],al             ; maska pravÇho okraje (00 - FE)
         jmp       short Box2

; ------ oprava prvn° masky pro malò poáet bodñ

Box1:    add       bx,ax
         add       cl,bl                    ; koncov† bitov† pozice+1 (1 aë 6)
         mov       al,8                     ; poáet bodñ na bajt
         sub       al,cl                    ; poáet nezobrazenòch bodñ vpravo
         mov       cl,al                    ; poáet nezobrazenòch bodñ vpravo
         mov       al,0ffh                  ; maska
         shl       al,cl                    ; rotace korekán° masky
         and       ss:[bp-1],al             ; oprava prvn° masky
         mov       byte ptr ss:[bp-2],0     ; nen° prav† maska
         mov       word ptr ss:[bp-4],0     ; nen° ë†dnò vnit©n° bajt

; ------ nastaven° registry masky

Box2:    mov       dx,3ceh                  ; ©°dic° registr
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky

; ------ z†pis obdÇln°ku

         mov       bx,ss:[bp-2]             ; poá†teán° a koncov† maska
         mov       cx,ss:[bp-4]             ; poáet vnit©n°ch bajtñ
Box4:    call      FilLine                  ; z†pis jednÇ linky
         add       di,ds:[RozmerB]          ; zvò®en° adresy ve videopamàti
         dec       si                       ; á°taá linek
         jnz       Box4                     ; zobrazen° dal®° linky

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

Box      ENDP

; -----------------------------------------------------------------------------
;                         z†pis linky
; -----------------------------------------------------------------------------
; VSTUP: BH=poá†teán° maska
;        BL=koncov† maska
;        CX=poáet vnit©n°ch bajtñ
;        ES:DI=ukl†dac° adresa
;        DX=adresa registru 3cfh (nastaven registr 8)
; -----------------------------------------------------------------------------

FilLine  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      di
         mov       ah,0ffh

; ------ zobrazen° prvn°ho bajtu linky

         mov       al,bh                    ; maska prvn°ho bajtu
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vzorek
         xchg      al,es:[di]               ; z†pis prvn°ho bajtu linky
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky

         cld                                ; smàr nahoru
         jcxz      FilLine2
FilLine1:mov       al,0ffh                  ; maska - v®echny bity
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; povolen° z†pisu pro v®echny bity
         mov       al,ah                    ; vòpl§
         xchg      al,es:[di]
         inc       di
         loop      FilLine1                 ; z†pis vnit©n°ch bajtñ linky

; ------ zobrazen° posledn°ho bajtu linky

FilLine2:mov       al,bl                    ; maska posledn°ho bajtu
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vòpl§
         xchg      al,es:[di]               ; z†pis posledn°ho bajtu linky

; ------ n†vrat registrñ

         pop       di
         pop       cx
         pop       ax
         ret

FilLine  ENDP

; -----------------------------------------------------------------------------
;              Inicializace registrñ videokarty pro z†pis
; -----------------------------------------------------------------------------
; VSTUP: AL=barva k z†pisu
;        DS=datovò segment
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         mov       ah,al                    ; £schova poëadovanÇ barvy

; ------ volba z†pisovòch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z†pis do v®ech rovin

; ------ nastaven° registru m¢du pro z†pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z†pisovò m¢d 0
         dec       dx

; ------ átec° registr

         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al
         dec       dx

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

         mov       al,7
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

; ------ nastaven° registru barvy

         mov       al,0
         out       dx,al
         inc       dx
;         mov       al,ah                    ; poëadovan† barva
         mov       al,0
;         mov       al,0fh
         out       dx,al                    ; barva
         dec       dx

; ------ nastaven° registru rovin

         mov       al,1
         out       dx,al
         inc       dx
;         mov       al,0ffh
         mov       al,ah
         not       al
;         mov       al,0
         out       dx,al                    ; v®echny roviny poëadovanou barvou
         dec       dx

; ------ nastaven° z†pisovÇho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0                     ; reëim "beze zmàny"
         out       dx,al                    ; funkce z†pisu beze zmàny dat

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;              n†vrat nastaven° registrñ videokarty
; -----------------------------------------------------------------------------

DeIniReg PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ nastaven° z†pisovòch rovin

         mov       dx,3c4h
         mov       al,2
         out       dx,al
         mov       al,0fh
         inc       dx
         out       dx,al                    ; z†pis do v®ech rovin

; ------ nastaven° registru m¢du pro z†pis

         mov       dx,3ceh
         mov       al,5
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; z†pisovò m¢d 0
         dec       dx

; ------ nastaven° z†pisovÇho m¢du

         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; funkce z†pisu beze zmàny dat
         dec       dx

; ------ nastaven° registru masky

         mov       al,8
         out       dx,al
         inc       dx
         mov       al,0ffh                  ; maska - v®echny bity
         out       dx,al                    ; povolen° masky pro v®echny bity
         dec       dx

; ------ átec° m¢d

         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh
         out       dx,al
         dec       dx

; ------ registr p©ep°naáe rovin

         mov       al,1
         out       dx,al
         inc       dx
         xor       al,al
         out       dx,al                    ; v®echny roviny podle dat
         dec       dx

; ------ átec° rovina

         mov       al,4
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
         dec       dx

; ------ maskov†n° rovin

         mov       al,7
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al
;         dec       dx

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

DeIniReg ENDP

; -----------------------------------------------------------------------------
;        zobrazen° zes°lenÇ á†ry
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=koncov† pozice
;        DX=poá†teán° linka
;        SI=koncov† linka
; -----------------------------------------------------------------------------

Line0    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

; ------ oprava po©ad° sou©adnic (mus° platit Y2 >= Y1)

         cmp       si,dx                    ; koncov† linka pod poá†teán° ?
         jge       Line01                   ; po©ad° sou©adnic je OK
         xchg      si,dx                    ; z†màna sou©adnic Y
         xchg      bx,cx                    ; z†màna sou©adnic X
Line01:  mov       di,si
         sub       di,dx                    ; rozd°l sou©adnic Y

; ------ zobrazen° zes°lenÇho bodu poá†tku a konce

         call      Point0                   ; zes°lenò bod poá†tku
         push      bx
         push      dx
         mov       bx,cx
         mov       dx,si
         call      Point0                   ; zes°lenò bod konce
         pop       dx
         pop       bx

; ------ absolutn° hodnota rozd°lu sou©adnic X

         mov       bp,bx                    ; poá†teán° pozice
         sub       bp,cx                    ; rozd°l sou©adnic X2-X1
         jns       Line02                   ; jde smàrem vpravo
         neg       bp                       ; absolutn° hodnota p©°rustku

; ------ stanoven° p©°rustku sou©adnic

Line02:  cmp       bp,di                    ; je vàt®° p©°rustek ve smàru X ?
         mov       di,1                     ; p©°rustek pro Y
         mov       bp,0                     ; p©°rustek pro X
         jae       Line03                   ; jde m°rnà dolñ
         xchg      bp,di                    ; bude p©°rustek ve smàru X

; ------ nastaven° na vòchoz° pozici

Line03:  mov       ah,ds:[Pero]             ; poáet áar pera
         shr       ah,1
         or        ah,ah
         jz        Line05
Line04:  sub       dx,di
         sub       si,di
         sub       bx,bp
         sub       cx,bp
         dec       ah
         jnz       Line04

; ------ zobrazen° áar

Line05:  mov       ah,ds:[Pero]
Line06:  call      LineC                    ; zobrazen° á†ry
         add       dx,di
         add       si,di
         add       bx,bp
         add       cx,bp
         dec       ah
         jnz       Line06

; ------ n†vrat registrñ

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Line0    ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á†ry s kontrolou
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

LineC    PROC      NEAR

         cmp       bx,ds:[MaxX]
         ja        LineC9
         cmp       cx,ds:[MaxX]
         ja        LineC9
         cmp       dx,ds:[IkonY]
         jae       LineC9
         cmp       si,ds:[IkonY]
         jae       LineC9
         call      Line
LineC9:  ret

LineC    ENDP

; -----------------------------------------------------------------------------
;        Zobrazen° á†ry
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=poá†teán° pozice
;        CX=koncov† pozice
;        DX=poá†teán° linka
;        SI=koncov† linka
; -----------------------------------------------------------------------------

Line     PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       ah,al

; ------ oprava po©ad° sou©adnic (mus° platit Y2 >= Y1)

         cmp       si,dx                    ; koncov† linka pod poá†teán° ?
         jge       Line1                    ; po©ad° sou©adnic je OK
         xchg      si,dx                    ; z†màna sou©adnic Y
         xchg      bx,cx                    ; z†màna sou©adnic X
Line1:   sub       si,dx                    ; rozd°l sou©adnic Y2-Y1

; ------ inicializace registrñ videokarty

         call      InitReg                  ; inicializace registrñ videokarty

; ------ nastaven° registru barvy

         push      dx
         mov       dx,3ceh
         mov       al,0
         out       dx,al
         inc       dx
         mov       al,ah
         out       dx,al
         dec       dx

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al
         pop       dx

; ------ vòpoáet poá†teán° adresy ve videopamàti

         push      bx
         push      cx
         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,ds:[RozmerB]          ; ®°©ka linky v bajtech
         mul       dx                       ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ maskovac° bit zaá†tku

         mov       dx,03ceh
         and       cl,7                     ; poá†teán° bitov† pozice v bajtu
         mov       al,8
         out       dx,al
         inc       dx
         mov       al,80h
         shr       al,cl
         pop       bx
         pop       cx

; ------ rozd°l sou©adnic X a rozli®en°, zda jde shora vlevo nebo vpravo

         sub       bx,cx                    ; rozd°l sou©adnic X2-X1
         jns       lin1ega0
         jmp       Lin3EGA                  ; jde smàrem vlevo

; ------ á†ra jde shora vpravo


; ------ rozli®en°, zda jde strmà vpravo

lin1ega0:cmp       bx,si                    ; je vàt®° p©°rustek ve smàru X ?
         jb        Lin2EGA                  ; jde strmà vpravo dolñ

; ------ á†ra jde m°rnà vpravo dolñ

         mov       cx,bx                    ; uráuj°c° je p©°rustek X
         inc       cx                       ; poáet krokñ á†ry
         shl       si,1                     ; rozd°l sou©adnic dY*2
         mov       bp,si                    ; £schova dY*2
         sub       bp,bx                    ; dY*2 - dX
         shl       bx,1                     ; dX*2
         sub       si,bx                    ; dY*2 - dX*2
         add       bx,si                    ; dX*2 + dY*2 - dX*2 = dY*2
         mov       ah,al                    ; maska poá†teán°ho bitu
Lin1EGA1:or        al,ah
         or        bp,bp
         jns       Lin1EGA2
         add       bp,bx
         jmp       short Lin1EGA3
Lin1EGA2:and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[RozmerB]
         add       bp,si
         ror       ah,1
         adc       di,0
         jmp       short Lin1EGA4
Lin1EGA3:ror       ah,1
         jnc       Lin1EGA4
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         inc       di
         xor       al,al
Lin1EGA4:loop      Lin1EGA1
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vpravo dolñ

Lin2EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
Lin2EGA1:push      ax
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         pop       ax
         xchg      ah,es:[di]
         or        bp,bp
         jns       Lin2EGA3
         add       bp,si
         jmp       short Lin2EGA4
Lin2EGA3:ror       al,1
         adc       di,0
;         out       dx,al
         add       bp,bx
Lin2EGA4:add       di,ds:[RozmerB]
         loop      Lin2EGA1
         jmp       LinEGA9

; ------ á†ra jde shora vlevo

Lin3EGA: neg       bx
         cmp       bx,si
         jb        Lin4EGA

; ------ á†ra jde m°rnà vlevo

         mov       cx,bx
         inc       cx
         shl       si,1
         mov       bp,si
         sub       bp,bx
         shl       bx,1
         sub       si,bx
         add       bx,si
         mov       ah,al
Lin3EGA1:or        al,ah
         or        bp,bp
         jns       Lin3EGA3
         add       bp,bx
         jmp       short Lin3EGA4
Lin3EGA3:and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,ds:[RozmerB]
         add       bp,si
         rol       ah,1
         sbb       di,0
         jmp       short Lin3EGA5
Lin3EGA4:rol       ah,1
         jnb       Lin3EGA5
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         dec       di
         xor       al,al
Lin3EGA5:loop      Lin3EGA1
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         jmp       LinEGA9

; ------ á†ra jde strmà vlevo

Lin4EGA: mov       cx,si
         inc       cx
         shl       bx,1
         mov       bp,bx
         sub       bp,si
         shl       si,1
         sub       bx,si
         add       si,bx
Lin4EGA1:push      ax
         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         pop       ax
         xchg      ah,es:[di]
         or        bp,bp
         jns       Lin4EGA2
         add       bp,si
         jmp       short Lin4EGA3
Lin4EGA2:rol       al,1
         sbb       di,0
         and       al,es:[di+Maska]         ; maskov†n°
;         out       dx,al
         add       bp,bx
Lin4EGA3:add       di,ds:[RozmerB]
         loop      Lin4EGA1

; ------ konec - n†vrat registrñ

LinEGA9: call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Line     ENDP

; -----------------------------------------------------------------------------
;        zobrazen° zes°lenÇho bodu
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

Point0   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ kontrola sou©adnic

         cmp       bx,ds:[MaxX]
         ja        Point09
         cmp       dx,ds:[IkonY]
         jae       Point09

; ------ rozmàry n†hradn°ho átverce

         mov       di,word ptr ds:[Pero]
         and       di,0ffh
         shr       di,1
         adc       di,0
         jz        Point08
         mov       cx,di
         mov       si,di
         shr       di,1
         sub       bx,di
         sub       dx,di

; ------ kontrola sou©adnic

         cmp       bx,ds:[MaxX]
         ja        Point09
         mov       di,cx
         add       di,bx
         cmp       di,ds:[MaxX]
         ja        Point09
         cmp       dx,ds:[IkonY]
         jae       Point09
         mov       di,si
         add       di,dx
         cmp       di,ds:[IkonY]
         jae       Point09

         call      Box
         jmp       short Point09

; ------ je m†lo bodñ

Point08: call      Point

; ------ n†vrat registrñ

Point09: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Point0   ENDP

; -----------------------------------------------------------------------------
;                       Zobrazen° bodu
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

Point    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ inicializace registrñ videokarty

;         mov       ch,al
         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,dx                    ; linka bodu
         mul       word ptr ds:[RozmerB]    ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° registru barvy

;         mov       dx,3ceh
;         mov       al,0
;         out       dx,al
;         inc       dx
;         mov       al,ch
;         out       dx,al
;         dec       dx
;
;         mov       al,1
;         out       dx,al
;         inc       dx
;         mov       al,0ffh
;         out       dx,al

; ------ nastaven° registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky
         and       cl,7                     ; bitov† pozice (0 aë 7)
         mov       al,80h                   ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (80h aë 01h)

; ------ z†pis bodu

         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; nastaven° masky bodu
         xchg      al,es:[di]               ; z†pis bodu do roviny

; ------ n†vrat registrñ

         call      DeIniReg                 ; n†vrat registrñ videokarty
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Point    ENDP

; -----------------------------------------------------------------------------
;        poskytnut° barvy bodu BX/DX -> AL
; -----------------------------------------------------------------------------

GetPoint PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

;; ------ áten° bodu
;
;         mov       ah,0dh
;         mov       cx,bx                    ; pozice bodu
;         xor       bh,bh                    ; videostr†nka
;         int       10h                      ; áten° barvy bodu

; ------ inicializace registrñ videokarty

;         xor       al,al
;         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,dx                    ; linka bodu
         mul       word ptr ds:[RozmerB]    ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu - nië®° slovo
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° átec°ho m¢du

         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du
         inc       dx
         mov       al,0
         out       dx,al                    ; m¢d áten° 0
         dec       dx
                                           ;* nastaven° átec° roviny

         mov       al,4
         out       dx,al                    ; registr átec° mapy
         inc       dx

; ------ nastaven° registru masky

         and       cl,7                     ; bitov† pozice (0 aë 7)
         mov       bh,80h                   ; inicializaán° maska
         shr       bh,cl                    ; rotace masky vpravo (80h aë 01h)

; ------ áten° bodu

         xor       ah,ah                    ; st©adaá bajtu
         mov       cl,1
         xor       bl,bl                    ; ukazatel roviny

GetPo1:
         mov       al,bl
         out       dx,al
         mov       al,es:[di]
         and       al,bh
         jz        GetPo2
         or        ah,cl
GetPo2:  shl       cl,1
         inc       bl
         cmp       bl,4
         jb        GetPo1
         mov       al,ah

; ------ n†vrat registrñ

         call      DeIniReg                 ; n†vrat registrñ videokarty

; ------ n†vrat registrñ

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         mov       bl,al
         pop       ax
         mov       al,bl
         pop       bx
         ret

GetPoint ENDP


; *****************************************************************************
;
;                      Obsluha souborñ
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        uloëen° obr†zku do souboru
; -----------------------------------------------------------------------------
; VSTUP: DS=datovò segment
; -----------------------------------------------------------------------------

WritFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      es

IFNDEF   DEMO

; ------ test, zda se m† obr†zek uloëit

         test      byte ptr ds:[Param],1    ; je platnò soubor ?
         jz        WritFil9                 ; nen° platnò soubor
         test      byte ptr ds:[Param],2    ; byl obraz modifikov†n ?
         jz        WritFil9                 ; obraz nebyl modifikov†n

; ------ otev©en° souboru pro z†pis

         mov       dx,offset Soubor         ; jmÇno aktivn°ho souboru
         mov       ax,3d01h
         int       21h                      ; otev©en° souboru pro z†pis
         jc        WritFil9                 ; chyba otev©en° souboru - asi R/O
         mov       ds:[Idents],ax           ; identifik†tor souboru

; ------ p©°prava registrñ

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         or        byte ptr ds:[Param],10h  ; nastaven° p©°znaku komprese
         mov       word ptr ds:[KompCit],0  ; nulov†n° á°taáe shodnòch bajtñ
         mov       word ptr ds:[KompBNum],0 ; nulov†n° bufferu dat
         mov       word ptr ds:[NumBuff],0  ; zru®en° z†pisovÇho bufferu
         xor       ax,ax                    ; poá†teán° rovina k z†pisu

; ------ z†pis jednÇ roviny do souboru

WritFil2:xor       si,si                    ; adresa videopamàti
         call      ReadEGA                  ; z†pis roviny okna
         inc       ax                       ; zvò®en° á°sla roviny
         cmp       ax,4                     ; jsou jië v®echny roviny ?
         jb        WritFil2                 ; z†pis dal®° roviny

; ------ vypr†zdnàn° bufferñ

         call      FlushQ                   ; vypr†zdnàn° bufferu shody
         call      FlushB                   ; vypr†zdnàn° bàënÇho bufferu
         call      WritBuff                 ; z†pis bufferu na disk

; ------ useknut° konce souboru

         mov       dx,offset buffer
         xor       cx,cx                    ; ë†dnò bajt k z†pisu
         mov       ah,40h
         mov       bx,ds:[Idents]           ; identifik†tor souboru
         int       21h                      ; useknut° souboru

; ------ uzav©en° souboru

         mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik†tor vòstupn°ho souboru
         int       21h                      ; uzav©en° souboru

; ------ n†vrat registrñ

ENDIF

WritFil9:and       byte ptr ds:[Param],not 2 ; zru®en° p©°znaku modifikace
         pop       es
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritFile ENDP

; -----------------------------------------------------------------------------
;        Äten° skupiny bajtñ z videopamàti EGA do vòstupn°ho bufferu
;              (ES:SI=VRAM, AX=rovina)
; -----------------------------------------------------------------------------

ReadEGA:

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       di,ax                    ; rovina

                                          ;* nastaven° átec°ho m¢du
         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du
         inc       dx
         mov       al,0
         out       dx,al                    ; m¢d áten° 0
         dec       dx

                                          ;* nastaven° átec° roviny
         mov       al,4
         out       dx,al                    ; registr átec° mapy
         inc       dx
         mov       ax,di                    ; rovina ke áten°
         out       dx,al

; ------ z†pis obsahu obrazovky do souboru

         mov       cx,80*(350-32)           ; poáet bajtñ roviny k z†pisu
ReadEGA2:mov       al,es:[si]
         call      WritB
         inc       si
         loop      ReadEGA2

; ------ standardn° nastaven° registrñ

         mov       dx,3ceh
         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        z†pis bajtu do souboru s kompres°
; -----------------------------------------------------------------------------
; Syntaxe komprese:
;    bajt - poáet n†sleduj°c°ch bajtñ dat 0 aë 255 (0=pouze p©ep°naá m¢du)
;         - kromà bajtu 255 se p©epne p©°znak komprese/data
;    za bajtem n†sleduje buÉ bajt, kterò se m† opakovat, nebo data o danÇm poátu
;    Na zaá†tku souboru je nastaven p©°znak komprese, prvn° bajt rñznò
;    od 255 tedy ud†v† poáet n†sleduj°c°ch dat v bàënÇm m¢du
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

         cmp       al,ds:[KompChr]          ; je bajt shodnò ?
         je        WritB1                   ; bajt je shodnò
         call      FlushQ                   ; vypr†zdnàn° bufferu shody
WritB1:  mov       ds:[KompChr],al          ; uloëen° shodnÇho znaku
         inc       byte ptr ds:[KompCit]    ; zvò®en° á°taáe shodnòch znakñ
         cmp       byte ptr ds:[KompCit],255; je buffer jië plnò ?
         jne       WritB9                   ; buffer je®tà nen° plnò
         call      FlushQ                   ; vypr†zdnàn° bufferu shody
WritB9:  ret

WritB    ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bufferu shody
; -----------------------------------------------------------------------------

FlushQ   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx

; ------ kontrola, zda je dostateánò poáet opakovanòch bajtñ

         mov       cx,ds:[KompCit]          ; poáet shodnòch bajtñ
         jcxz      FlushQ9                  ; v bufferu nic nen°
         cmp       cl,3                     ; dostateánò poáet bajtñ ?
         jb        FlushQ7                  ; je malò poáet bajtñ

; ------ dostateánò poáet bajtñ - vypr†zdnàn° bàënÇho bufferu

         call      FlushB                   ; vypr†zdnàn° bàënÇho bufferu

; ------ p©°padnÇ p©epnut° do kompresn°ho m¢du

         test      byte ptr ds:[Param],10h  ; je kompresn° m¢d ?
         jnz       FlushQ3                  ; je kompresn° m¢d - OK
         xor       al,al                    ; bajt pro p©epnut° m¢du
         call      WritB0                   ; p©epnut° do kompresn°ho m¢du
         or        byte ptr ds:[Param],10h  ; p©°znak kompresn°ho m¢du

; ------ z†pis bajtu dÇlky a opakovanÇho bajtu

FlushQ3: mov       al,cl                    ; poáet opakov†n° bajtu
         call      WritB0                   ; z†pis poátu bajtñ
         mov       al,ds:[KompChr]          ; opakovanò znak
         call      WritB0                   ; z†pis opakovanÇho bajtu

; ------ nastaven° p©°znaku m¢du komprese

         inc       cl                       ; je 255 znakñ ?
         je        FlushQ9                  ; je 255 znakñ - m¢d se nep©epne
         and       byte ptr ds:[Param],not 10h ; p©°znak nekompresn°ho m¢du
         jmp       short FlushQ9

; ------ malò poáet bajtñ - vypr†zdnàn° p©es bàënò buffer

FlushQ7: mov       al,ds:[KompChr]          ; shodnò znak
FlushQ8: call      StorBuf                  ; uloëen° do bàënÇho bufferu
         loop      FlushQ8                  ; uloëen° dal®°ho bajtu

; ------ n†vrat registrñ

FlushQ9: mov       word ptr ds:[KompCit],0  ; zru®en° á°taáe bajtñ v bufferu
         pop       cx
         pop       ax
         ret

FlushQ   ENDP

; -----------------------------------------------------------------------------
;        uloëen° bajtu AL do bàënÇho bufferu
; -----------------------------------------------------------------------------

StorBuf  PROC      NEAR

; ------ £schova registrñ

         push      bx

; ------ uloëen° bajtu do bufferu

         mov       bx,ds:[KompBNum]         ; poáet bajtñ v kompresn°m bufferu
         inc       word ptr ds:[KompBNum]   ; zvò®en° á°taáe dat v bufferu
         mov       ds:[bx+KompBuff],al      ; uloëen° bajtu do bufferu

; ------ p©i zaplnàn° bufferu jeho vypr†zdnàn°

         cmp       bl,254                   ; je buffer jië plnò ?
         jne       StorBuf2                 ; buffer je®tà nen° plnò
         call      FlushB                   ; vypr†zdnàn° bufferu

; ------ n†vrat registrñ

StorBuf2:pop       bx
         ret

StorBuf  ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bàënÇho bufferu
; -----------------------------------------------------------------------------

FlushB   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ kontrola, zda v bufferu nàco je

         mov       cx,ds:[KompBNum]         ; poáet bajtñ v kompresn°m bufferu
         jcxz      FlushB9                  ; v bufferu nic nen°

; ------ p©°padnÇ p©epnut° do nekompresn°ho m¢du

         test      byte ptr ds:[Param],10h  ; je kompresn° m¢d ?
         jz        FlushB3                  ; nen° kompresn° m¢d - OK
         xor       al,al                    ; bajt pro p©epnut° m¢du
         call      WritB0                   ; p©epnut° do norm†ln°ho m¢du
         and       byte ptr ds:[Param],not 10h; p©°znak bàënÇho m¢du

; ------ vysl†n° bajtu dÇlky ©etàzce

FlushB3: mov       al,cl                    ; poáet bajtñ textu
         call      WritB0                   ; vysl†n° bajtu dÇlky

; ------ nastaven° p©°znaku p©epnut° m¢du

         inc       al                       ; je 255 bajtñ ?
         jz        FlushB4                  ; je 255 znakñ - m¢d se nep©epne
         or        byte ptr ds:[Param],10h  ; p©°znak kompresn°ho m¢du

; ------ vysl†n° dat

FlushB4: mov        si,offset KompBuff      ; buffer s daty
         cld
FlushB5: lodsb                              ; bajt dat k vysl†n°
         call      WritB0                   ; vysl†n° bajtu
         loop      FlushB5                  ; vysl†n° dal®°ho bajtu
         mov       word ptr ds:[KompBNum],0 ; zru®en° á°taáe bajtñ v bufferu

; ------ n†vrat registrñ

FlushB9: pop       si
         pop       cx
         pop       ax
         ret

FlushB   ENDP

; -----------------------------------------------------------------------------
;        Z†pis bajtu do diskovÇho bufferu
; -----------------------------------------------------------------------------

WritB0:  push      si
         mov       si,sp                    ; ukazatel z†sobn°ku
         sub       si,offset Buffer + Zasob ; volnÇ m°sto v bufferu
         jc        WritB4                   ; p©eteáen° bufferu
         cmp       ds:[NumBuff],si          ; buffer je jië zaplnàn ?
         jb        WritB2                   ; buffer je®tà nen° zaplnàn
WritB4:  call      WritBuff                 ; z†pis bufferu na disk
         jc        WritB3                   ; byla chyba z†pisu
WritB2:  mov       si,ds:[NumBuff]          ; poáet bajtñ v bufferu
         mov       ds:[si+Buffer],al        ; z†pis novÇho bajtu do bufferu
         inc       word ptr ds:[NumBuff]    ; zvò®en° á°taáe bajtñ v bufferu
WritB3:  pop       si
         ret

; -----------------------------------------------------------------------------
;        Z†pis diskovÇho bufferu do souboru (CY=chyba)
; -----------------------------------------------------------------------------

WritBuff:push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,offset buffer
         mov       cx,ds:[NumBuff]          ; poáet bajtñ v diskovÇm bufferu
         jcxz      WritBff2                 ; nen° ë†dnò bajt k z†pisu
         mov       ah,40h
         mov       bx,ds:[Idents]           ; identifik†tor souboru
         int       21h                      ; z†pis souboru
         mov       word ptr ds:[NumBuff],0  ; vynulov†n° bufferu
         jc        WritBff2                 ; byla chyba
         cmp       ax,cx                    ; souhlas° poáet bajtñ ?
         je        WritBff2                 ; poáet bajtñ souhlas°
         stc                                ; chyba - plnò disk

WritBff2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret






; -----------------------------------------------------------------------------
;        naáten° aktivn°ho souboru
; -----------------------------------------------------------------------------
; -----------------------------------------------------------------------------

ReadFile PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds

; ------ otev©en° aktivn°ho souboru

         mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h                      ; otev©en° souboru pro áten°
         jc        ReadFil9                 ; soubor nenalezen
         mov       bx,ax
         and       byte ptr ds:[Param],not 2 ; zru®en° p©°znaku modifikace
         mov       word ptr ds:[NumBuff],0  ; zru®en° dat v bufferu
         or        byte ptr ds:[Param],8    ; nastaven° p©°znaku komprese
         mov       word ptr ds:[KompCit],0  ; nulov†n° á°taáe shodnòch bajtñ

         xor       si,si                    ; ukazatel dat v bufferu
         mov       bp,1                     ; ukazatel rovin
         call      DeIniReg                 ; standardn° nastaven° registrñ

; ------ nastaven° videoregistrñ

ReadFil1:mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       ax,bp
         out       dx,al

; ------ p©°prava registrñ

         xor       di,di
         mov       ax,0a000h
         mov       es,ax
         mov       cx,80*(350-32)           ; dÇlka jednÇ roviny

; ------ naáten° jednÇ roviny

ReadFil5:call      ReadByte                 ; naáten° jednoho bajtu
         jc        ReadFil8                 ; chyba - konec
         cld
         stosb                              ; uloëen° bajtu na displej
         loop      ReadFil5

; ------ p©°prava pro dal®° rovinu

         shl       bp,1
         cmp       bp,10000b
         jne       ReadFil1                 ; dal®° rovina

; ------ uzav©en° souboru

ReadFil8:mov       ah,3eh
         int       21h                      ; uzav©en° souboru

; ------ registr z†pisu pro generov†n° masky

ReadFil9:mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0fh                   ; v®echny roviny
         out       dx,al

; ------ p©°prava registrñ pro generov†n° masky

         mov       ax,0a000h
         mov       ds,ax
         xor       si,si
         mov       di,Maska
         mov       cx,80*(350-32)

; ------ registr volby átec° roviny

         mov       dx,3ceh
         mov       al,4
         out       dx,al
         inc       dx

; ------ generov†n° masky

ReadFilA:mov       al,0
         out       dx,al
         mov       ah,ds:[si]
         inc       al
         out       dx,al
         or        ah,ds:[si]
         inc       al
         out       dx,al
         or        ah,ds:[si]
         inc       al
         out       dx,al
         or        ah,ds:[si]
         mov       ds:[di],ah
         inc       si
         inc       di
         loop      ReadFilA

; ------ n†vrat registrñ

         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadFile ENDP

; -----------------------------------------------------------------------------
;        áten° jednoho bajtu ze souboru (SI=ukazatel, BX=identifik†tor)
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ naáten° bajtu poátu dat komprese

         cmp       byte ptr ds:[KompCit],0  ; je á°taá platnò ?
         jne       ReadByt4                 ; á°taá je dosud platnò
ReadByt1:call      ReadByt0                 ; naáten° bajtu á°taáe
         jc        ReadByt5                 ; chyba áten° dat
         mov       byte ptr ds:[KompCit],al ; poáet n†sleduj°c°ch bajtñ

; ------ p©ep°naá m¢du komprese

         or        al,al                    ; je to jen p©ep°naá ?
         jnz       ReadByt2                 ; nen° to p©ep°naá
         xor       byte ptr ds:[Param],8    ; zmàna p©°znaku komprese
         jmp       short ReadByt1           ; novÇ áten° bajtu

; ------ naáten° bajtu k opakov†n°

ReadByt2:and       byte ptr ds:[Param],not 10h ; zru®en° p©°znaku komprese
         test      byte ptr ds:[Param],8    ; je m¢d komprese ?
         jz        ReadByt3                 ; nen° m¢d komprese
         or        byte ptr ds:[Param],10h  ; p©°znak komprese
         call      ReadByt0                 ; naáten° bajtu k opakov†n°
         jc        ReadByt5                 ; chyba áten° dat
         mov       ds:[KompChr],al          ; bajt k opakov†n°

; ------ zmàna p©°znaku m¢du komprese

ReadByt3:cmp       byte ptr ds:[KompCit],255 ; je zmàna m¢du komprese ?
         je        ReadByt4                 ; nen° zmàna m¢du komprese
         xor       byte ptr ds:[Param],8    ; zmàna p©°znaku komprese

; ------ naáten° dal®°ho bajtu

ReadByt4:mov       al,ds:[KompChr]          ; bajt p©i opakov†n° dat
         test      byte ptr ds:[Param],10h  ; je opakov†n° dat ?
         jnz       ReadByt5                 ; je opakov†n° dat
         call      ReadByt0                 ; naáten° bàënÇho bajtu dat

; ------ sn°ëen° á°taáe bajtñ

ReadByt5:dec       byte ptr ds:[KompCit]    ; sn°ëen° á°taáe komprese
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        áten° bajtu z bufferu (SI=ukazatel, BX=identifik†tor)
; -----------------------------------------------------------------------------

ReadByt0 PROC      NEAR

         cmp       word ptr ds:[NumBuff],0
         jne       ReadByt8

; ------ naáten° dal®°ho bloku

         push      ax
         push      cx
         push      dx
         mov       ah,3fh
         mov       cx,sp                    ; konec bufferu
         sub       cx,offset Buffer + Zasob ; volnÇ m°sto v bufferu
         mov       dx,offset Buffer
         int       21h
         jc        ReadByt6
         or        ax,ax
         stc
         jz        ReadByt6
         clc
         mov       ds:[NumBuff],ax
ReadByt6:pop       dx
         pop       cx
         pop       ax
         mov       si,0
         jc        ReadByt9

ReadByt8:mov       al,ds:[si+Buffer]
         inc       si
         dec       word ptr ds:[NumBuff]
         clc
ReadByt9:ret

ReadByt0 ENDP

; -----------------------------------------------------------------------------
;        nastaven° novÇho aktivn°ho souboru
; -----------------------------------------------------------------------------
; VSTUP: AX=á°slo souboru
; -----------------------------------------------------------------------------

SetSoub  PROC      NEAR

         push      si
         push      di
         push      cx
         push      cs
         pop       es
         mov       ds:[AktSoub],ax          ; £schova á°sla souboru
         mov       si,9eh                   ; jmÇno souboru
         mov       cx,13
         mov       di,offset Soubor
         cld
         rep       movsb                    ; £schova jmÇna souboru
         or        byte ptr ds:[Param],1    ; p©°znak platnÇho souboru
         pop       cx
         pop       di
         pop       si
         ret

SetSoub  ENDP

; -----------------------------------------------------------------------------
;        nalezen° souboru zadanÇho á°sla
; -----------------------------------------------------------------------------
; VSTUP: AX=poëadovanÇ á°slo souboru
;        CY=nenalezen
; -----------------------------------------------------------------------------

FindFile PROC      NEAR

         push      cx
         mov       cx,ax                    ; á°slo poëadovanÇho souboru

; ------ nalezen° prvn°ho souboru

         call      FindFrst                 ; nalezen° prvn°ho souboru
         jc        FindF9                   ; nenalezen ë†dnò soubor
         jcxz      FindF9                   ; je to poëadovanò soubor

; ------ nalezen° dal®°ho souboru

FindF2:  call      FindNxt                  ; nalezen° dal®°ho souboru
         jc        FindF9                   ; dal®° soubor nenalezen
         loop      FindF2                   ; nalezen° dal®°ho souboru

FindF9:  pop       cx
         ret

FindFile ENDP

; -----------------------------------------------------------------------------
;        nalezen° prvn°ho souboru
; -----------------------------------------------------------------------------
; VùSTUP: CY=nenalezen
; -----------------------------------------------------------------------------

FindFrst PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      dx

; ------ nastaven° adresy DTA

         mov       dx,80h
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ nalezen° pvn°ho souboru

         xor       cx,cx
         mov       ah,4eh
         mov       dx,offset Soubory
         int       21h                      ; nalezen° prvn°ho souboru

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       ax
         ret

FindFrst ENDP

; -----------------------------------------------------------------------------
;        nalezen° dal®°ho souboru
; -----------------------------------------------------------------------------
; VùSTUP: CY=nenalezen
; -----------------------------------------------------------------------------

FindNxt  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx

; ------ nastaven° adresy DTA

         mov       dx,80h
         mov       ah,1ah
         int       21h                      ; nastaven° adresy DTA

; ------ nalezen° dal®°ho souboru

         mov       ah,4fh
         int       21h                      ; nalezen° prvn°ho souboru

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

FindNxt  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

TiskKod1 db        27,"3",24                ; ©†dkov†n° 8/72 palce
TiskKod2 db        27,"*",5                 ; zah†jen° grafickÇho tisku
         dw        640

RozmerX  dw        640                      ; maxim†ln° rozmàr X
RozmerB  dw        80                       ; dÇlka linky v bajtech
RozmerY  dw        350                      ; maxim†ln° rozmàr Y
MaxX     dw        639
MaxY     dw        349

Param    db        0                        ; parametry
                                            ;   bit 0: 1=je platnò soubor
                                            ;   bit 1: 1=obraz modifikov†n
                                            ;   bit 2: 1=bude dal®° soubor
                                            ;   bit 3: 1=bude stav komprese dat
                                            ;   bit 4: 1=nyn° je komprese dat
                                            ;   bit 5: 1=obrysy rozhran° barev
                                            ;   bit 6: 1=pravÇ tlaá°tko - maz†n°

KompCit  dw        0                        ; á°taá pro kompresi
KompChr  db        0                        ; uschovanò opakovanò bajt komprese

IkonY    dw        350-32

OldX     dw        0                        ; pñvodn° pozice my®i X
OldY     dw        0                        ; pñvodn° pozice my®i Y
OldKey   db        0                        ; pñvodn° tlaá°tka my®i

Barva    db        14                       ; aktivn° barva
Pero     db        2                        ; tlou®üka á†ry

OldVMod  db        3

NumBuff  dw        0                        ; poáet bajtñ v bufferu

AktSoub  dw        0                        ; á°slo aktivn°ho souboru

Soubor   db        13 dup(0)                ; jmÇno aktivn°ho souboru

Soubory  db        '*.MAL',0                ; identifikace souborñ

; ------ z†pis do souboru

Idents   dw        0                        ; identifikace vòstupn°ho souboru

KompBNum dw        0                        ; poáet bajtñ v kompresn°m bufferu
KompBuff db        256 dup(0)               ; kompresn° buffer

; -----------------------------------------------------------------------------
;        definice ikon
; -----------------------------------------------------------------------------


ObrPero1 db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10001000b,00000000b,00000000b,00000001b
         db        10001110b,00000000b,00000000b,00000001b
         db        10001111b,00000000b,00000000b,00000001b
         db        10000111b,00000000b,00000000b,00000001b
         db        10000101b,10000000b,00000000b,00000001b
         db        10000010b,11000000b,00000000b,00000001b
         db        10000011b,11000000b,00000000b,00000001b
         db        10000001b,11100000b,00000000b,00000001b
         db        10000000b,01010000b,00000000b,00000001b
         db        10000000b,00111100b,00000000b,00000001b
         db        10000000b,00011110b,00000000b,00000001b
         db        10000000b,00001111b,00000000b,00000001b
         db        10000000b,00000111b,10000000b,00000001b
         db        10000000b,00000011b,11000000b,00000001b
         db        10000000b,00000001b,11100000b,00000001b
         db        10000000b,00000000b,11110000b,00000001b
         db        10000000b,00000000b,01111000b,00000001b
         db        10000000b,00000000b,00111100b,00000001b
         db        10000000b,00000000b,00011110b,00000001b
         db        10000000b,00000000b,00001111b,00000001b
         db        10000000b,00000000b,00000111b,00000001b
         db        10000000b,00000000b,00000011b,10000001b
         db        10000000b,00000000b,00000001b,11000001b
         db        10000000b,00000000b,00000000b,01100001b
         db        10000000b,00000000b,00000000b,00110001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b


ObrPero2 db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000110b,00000000b,00000000b,00000001b
         db        10001111b,00000000b,00000000b,00000001b
         db        10011111b,00000000b,00000000b,00000001b
         db        10011101b,10000000b,00000000b,00000001b
         db        10011111b,10000000b,00000000b,00000001b
         db        10010111b,11000000b,00000000b,00000001b
         db        10001011b,11000000b,00000000b,00000001b
         db        10001101b,11100000b,00000000b,00000001b
         db        10000111b,11000000b,00000000b,00000001b
         db        10000001b,10111000b,00000000b,00000001b
         db        10000000b,01111100b,00000000b,00000001b
         db        10000000b,01111110b,00000000b,00000001b
         db        10000000b,00111111b,00000000b,00000001b
         db        10000000b,00011111b,10000000b,00000001b
         db        10000000b,00001111b,11000000b,00000001b
         db        10000000b,00000111b,11100000b,00000001b
         db        10000000b,00000011b,11110000b,00000001b
         db        10000000b,00000001b,11111000b,00000001b
         db        10000000b,00000000b,11111100b,00000001b
         db        10000000b,00000000b,01111110b,00000001b
         db        10000000b,00000000b,00111111b,00000001b
         db        10000000b,00000000b,00011111b,00000001b
         db        10000000b,00000000b,00001111b,00000001b
         db        10000000b,00000000b,00000111b,10000001b
         db        10000000b,00000000b,00000011b,11000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

ObrZpet  db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000010b,00000000b,00000001b
         db        10000000b,00000110b,00000000b,00000001b
         db        10000000b,00001110b,00000000b,00000001b
         db        10000000b,00011110b,00000000b,00000001b
         db        10000000b,00111110b,00000000b,00000001b
         db        10000000b,01111110b,00000000b,00000001b
         db        10000000b,11111110b,00000000b,00000001b
         db        10000001b,11111110b,00000000b,00000001b
         db        10000011b,11111110b,00000000b,00000001b
         db        10000111b,11111111b,11111111b,11111001b
         db        10001111b,11111111b,11111111b,11110001b
         db        10011111b,11111111b,11111111b,11110001b
         db        10111111b,11111111b,11111111b,11110001b
         db        10011111b,11111111b,11111111b,11110001b
         db        10001111b,11111111b,11111111b,11110001b
         db        10000111b,11111111b,11111111b,11111001b
         db        10000011b,11111110b,00000000b,00000001b
         db        10000001b,11111110b,00000000b,00000001b
         db        10000000b,11111110b,00000000b,00000001b
         db        10000000b,01111110b,00000000b,00000001b
         db        10000000b,00111110b,00000000b,00000001b
         db        10000000b,00011110b,00000000b,00000001b
         db        10000000b,00001110b,00000000b,00000001b
         db        10000000b,00000110b,00000000b,00000001b
         db        10000000b,00000010b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

ObrTam   db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,01000000b,00000001b
         db        10000000b,00000000b,01100000b,00000001b
         db        10000000b,00000000b,01110000b,00000001b
         db        10000000b,00000000b,01111000b,00000001b
         db        10000000b,00000000b,01111100b,00000001b
         db        10000000b,00000000b,01111110b,00000001b
         db        10000000b,00000000b,01111111b,00000001b
         db        10000000b,00000000b,01111111b,10000001b
         db        10000000b,00000000b,01111111b,11000001b
         db        10011111b,11111111b,11111111b,11100001b
         db        10001111b,11111111b,11111111b,11110001b
         db        10001111b,11111111b,11111111b,11111001b
         db        10001111b,11111111b,11111111b,11111101b
         db        10001111b,11111111b,11111111b,11111001b
         db        10001111b,11111111b,11111111b,11110001b
         db        10011111b,11111111b,11111111b,11100001b
         db        10000000b,00000000b,01111111b,11000001b
         db        10000000b,00000000b,01111111b,10000001b
         db        10000000b,00000000b,01111111b,00000001b
         db        10000000b,00000000b,01111110b,00000001b
         db        10000000b,00000000b,01111100b,00000001b
         db        10000000b,00000000b,01111000b,00000001b
         db        10000000b,00000000b,01110000b,00000001b
         db        10000000b,00000000b,01100000b,00000001b
         db        10000000b,00000000b,01000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

Kurzor1  dw        1111111111111111b
         dw        1011111111111111b
         dw        1001111111111111b
         dw        1000011111111111b
         dw        1000000111111111b
         dw        1000000001111111b
         dw        1100000000111111b
         dw        1100000000011111b
         dw        1100000000001111b
         dw        1110000000000111b
         dw        1110000000000011b
         dw        1111000000000001b
         dw        1111100000000001b
         dw        1111110000000000b
         dw        1111111110000000b
         dw        1111111111110000b

         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0010000000000000b
         dw        0011100000000000b
         dw        0011111000000000b
         dw        0001111110000000b
         dw        0001111111000000b
         dw        0001111111100000b
         dw        0000111111110000b
         dw        0000101111111000b
         dw        0000010001111100b
         dw        0000001100001100b
         dw        0000000011111110b
         dw        0000000000001111b
         dw        0000000000000110b

Kurzor2  dw        1111111111111111b
         dw        1111000111111111b
         dw        1110000001111111b
         dw        1100000000111111b
         dw        1000000000011111b
         dw        1000000000001111b
         dw        1000000000000111b
         dw        1000000000000011b
         dw        1000000000000001b
         dw        1100000000000001b
         dw        1100000000000001b
         dw        1110000000000000b
         dw        1111000000000000b
         dw        1111100000000000b
         dw        1111110000000000b
         dw        1111111111110000b

         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000111000000000b
         dw        0001011110000000b
         dw        0011101111000000b
         dw        0001111111100000b
         dw        0010111011110000b
         dw        0011011111111000b
         dw        0011111111111100b
         dw        0001111111111100b
         dw        0001101111111100b
         dw        0000110011111100b
         dw        0000011100111010b
         dw        0000001111111011b
         dw        0000000000001111b
         dw        0000000000000111b

buffer   label     byte                     ; buffer pro diskovÇ operace

; ------ £vodn° text

UvTxt    db        '…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª',13,10
         db        '∫               M A L U J        v 1.21∫',13,10
         db        '∫     graficky editor pro nejmensi     ∫',13,10
         db        '∫         (c) Miroslav Nemecek         ∫',13,10
ifdef    DEMO
         db        '∫    !!!!  DEMONSTRACNI VERZE !!!!     ∫',13,10
         db        '∫    (neuklada na disk a netiskne)     ∫',13,10
endif
         db        'ÃÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ',13,10
         db        '∫ Program  edituje  obrazky  jmeno.MAL ∫',13,10
         db        '∫ v aktivnim adresari ........... novy ∫',13,10
         db        '∫ obrazek vytvorite  zalozenim souboru ∫',13,10
         db        '∫ jmeno.MAL s nulovou delkou.          ∫',13,10
         db        '∫ƒƒƒƒƒƒƒƒƒƒ Ovladani programu ƒƒƒƒƒƒƒƒƒ∫',13,10
         db        '∫ CTRL-BREAK .. ukonceni programu      ∫',13,10
         db        '∫ CTRL-F7 ..... zruseni obrysu obrazku ∫',13,10
         db        '∫ CTRL-F8 ..... vytisteni na tiskarnu  ∫',13,10
         db        '∫ CTRL-F9 ..... odbarveni obrazku      ∫',13,10
         db        '∫ CTRL-F10 .... odbarveni obrazku,     ∫',13,10
         db        '∫               vytvoreni obrysu ploch ∫',13,10
         db        '∫ CTRL- <- .... predchozi obrazek      ∫',13,10
         db        '∫ CTRL- -> .... dalsi obrazek          ∫',13,10
         db        '∫ ESC ......... preruseni operace      ∫',13,10
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',13,10
         db        'Stisknete: ESC=preruseni, jinak pokracuj',13,10
         db        '$'

; ------ chybovÇ texty

EgaErr   db        'Program vyzaduje grafickou kartu EGA/VGA !',13,10,'$'
MemErr   db        'Nedostatek pameti !',13,10,'$'
;MouseErr db        'Nenainstalovan ovladac mysi !',13,10,'$'

code     ends
         end       start

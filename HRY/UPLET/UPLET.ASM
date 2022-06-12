
; *****************************************************************************
;
;                             U P L E T
;
;            grafickò editor pro vzory na pleten° a vy®°v†n°
;
; -----------------------------------------------------------------------------
; Mapa obrazovky: - (349) vpravo obr†zek vò®ka 116 bodñ, ®°©ka 128 bodñ (1 bod
;                               obr†zku = vò®ka 3 body, ®°©ka 4 body)
;                 - vlevo sloupec ®irokò 128 bodñ (=176 bajtñ)
;                     - (1) linka
;                     - (116) zmen®enò obr†zek
;                     - (1) linka
;                     - (14) texty "Uloë Tisk Konec"
;                     - (1) linka
;                     - (14) volba ®tàtce
;                     - (1) linka
;                     - (128) volby barev - 2 sloupce po 16 pol°ák†ch = 16*8
;                     - (1) linka
;                     - (71) palety aktivn° barvy - 2*3 sloupeáky/4 £rovnà
;                                                 - (1) okraj
;                                                 - (2) modr† M
;                                                 - (2) zelen† Z
;                                                 - (2) áerven† R
;                                                 - (1) okraj
;                     - (1) linka
; *****************************************************************************

;DEMO     EQU       0                        ; p©ep°naá - demonstraán° verze

;GRAF1    EQU       0                        ; p©ep°naá - grafika 60 bodñ/palec
GRAF2    EQU       0                        ; p©ep°naá - grafika 72 bodñ/palec

code     segment
         assume    cs:code,ds:code
         org       100h

Sirka    EQU       128                      ; ®°©ka obr†zku
Vyska    EQU       116                      ; vò®ka obr†zku

Zasob    EQU       400h                     ; rezerva pro z†sobn°k
BuffSize EQU       4000h                    ; velikost bufferu pro soubor

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
Inst11:  push      dx
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         pop       dx
         mov       ah,9
         int       21h                      ; zobrazen° chybovÇho textu
Inst12:  int       20h

; ------ test, zda je dostatek pamàti

Inst2:   mov       dx,offset MemErr         ; test - nedostatek pamàti
         cmp       sp,offset Buffer + BuffSize + Zasob ; kontrola konce pamàti
         jb        Inst11                   ; nedostatek pamàti

; ------ dek¢dov†n° jmÇna souboru

         mov       di,81h
         mov       bh,0
         mov       bl,ds:[di-1]
         mov       al," "
         mov       ds:[di+bx],al
         mov       cx,bx
         mov       dx,offset SoubErr
         jcxz      Inst11                   ; nezad†n soubor
         cld
         repe      scasb
         je        Inst11
         mov       dx,di
         dec       dx
         repne     scasb
         mov       byte ptr ds:[di],0
         mov       ds:[Soubor],dx           ; adresa jmÇna souboru

; ------ inicializaán° vymaz†n° bufferu souboru

         mov       ax,0ffffh                ; b°l† barva
         mov       cx,Sirka*Vyska/4         ; velikost bufferu ve slovewch
         cld
         mov       di,offset Obrazek
         rep       stosw                    ; vymaz†n° obr†zku

; ------ otev©en° a naáten° souboru

         mov       ax,3d00h
         int       21h
         jc        Inst203                  ; soubor nenalezen
         mov       bx,ax

         mov       ah,3fh
         mov       dx,offset Buffer
         mov       cx,2
         int       21h                      ; naáten° identifik†toru
         jc        Inst1102
         cmp       ax,cx
         jne       Inst205                  ; m† asi nulovou dÇlku
         cmp       word ptr ds:[Buffer],"PU" ; identifik†tor OK ?
         jne       Inst1102                 ; neplatnò soubor

         mov       dx,offset Palety
         mov       cx,offset(ZahlEnd-ZahlBeg)-2
         mov       ah,3fh
         int       21h                      ; naáten° z†hlav°
         jc        Inst1102
         and       word ptr ds:[BarvaL],0f0fh

         mov       cx,BuffSize
         mov       dx,offset Buffer
         mov       ah,3fh
         int       21h
         jc        Inst1102
         mov       ds:[NumBuff],ax          ; poáet bajtñ v bufferu

         call      Dekod                    ; dek¢dov†n° bufferu
         jmp       short Inst205


Inst203: mov       ah,3ch
         xor       cx,cx
         int       21h
         mov       bx,ax
         jnc       Inst205
         jmp       short Inst1101

Inst1102:mov       ah,3eh
         int       21h

Inst1101:mov       dx,offset SoubErr2
         jmp       Inst11                   ; chybnÇ zad†n° souboru

Inst205: mov       ah,3eh
         int       21h

; ------ £vod demonstraán° verze

IFDEF    DEMO
         mov       ah,9
         mov       dx,offset UvTxt
         int       21h
         mov       ah,9
         mov       dx,offset DemoTxt
         int       21h
         mov       ah,8
         int       21h
         or        al,al
         jnz       Demon1
         mov       ah,8
         int       21h
Demon1:
ENDIF

; ------ inicializace my®i

         xor       ax,ax
         call      Mouse
         inc       ax
         jz        inst22                   ; je my®
         and       byte ptr ds:[Param],not 80h ; nen° my®

; ------ £schova videom¢du

Inst22:  mov       ah,0fh
         int       10h
         mov       ds:[OldVMod],al

; ------ nastaven° videom¢du

         mov       ax,16
         int       10h
         mov       ah,0fh
         int       10h
         cmp       al,16
         je        Inst23

         jmp       Inst1                    ; chyba - videom¢d nelze nastavit

; ------ instalace obsluhy p©eru®en°

Inst23:  mov       ax,2523h
         mov       dx,offset Konec
         int       21h

; ------ definice okna pro my®

         xor       cx,cx
         mov       dx,639
         mov       ax,7
         call      Mouse
         xor       cx,cx
         mov       dx,347
         mov       ax,8
         call      Mouse

; ------ definice kurzoru my®i

         mov       dx,offset Kurzor1
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
         mov       cx,(640-128)/2+128-2
         mov       dx,348/2-1
         call      MouseSet

; ------ zobrazen° okna

st1111:  call      DispMenu                 ; novÇ zobrazen° menu
         call      SetPal                   ; nastaven° palet displeje
         call      DispObr

; ------ zapnut° kurzoru my®i

st111:   call      MouseOn

; ------ nastaven° kurzoru na novou pozici

st56:    call      MouseOld
st5:
         mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jz        st5z000
         jmp       st5002                   ; nen° p©ipraven znak

st5z000:
         mov       ah,8
         int       21h                      ; vstup znaku z konzoly

         cmp       al,"a"
         jb        st5z001
         cmp       al,"z"
         ja        st5z001
         sub       al,32

st5z001: cmp       al,"K"
         je        st5z002
         cmp       al,27
         jne       st5z003
st5z002: jmp       Konec0

st5z003: cmp       al,"T"
         jne       st5z004

         jmp       st50205                  ; tisk

st5z004:
         cmp       al,"P"                   ; pero
         jne       st5z005
         jmp       st50207

st5z005: cmp       al,"G"                   ; guma
         jne       st5z006
         jmp       st50209

st5z006: cmp       al,13
         jne       st5z061

         mov       bl,2
         jmp       st502x1

st5z061: cmp       al," "
         jne       st5z062

         mov       bl,1
         jmp       st502x1

; ------ volba barvy

st5z062: cmp       al,"0"
         jb        st5z064
         cmp       al,"9"
         jbe       st5z063
         cmp       al,"A"
         jb        st5z064
         cmp       al,"F"
         ja        st5z064
         sub       al,7
st5z063: sub       al,"0"
         mov       dl,al
         jmp       st5903                   ; nastaven° barvy


st5z064:



         or        al,al                    ; je ©°dic° kl†vesa ?
         jz        st5z069
         jmp       st5002                   ; nen° ©°dic° kl†vesa

st5z069:
         mov       ah,8
         int       21h                      ; vstup SCAN k¢du kl†vesy

         cmp       al,4bh                   ; vlevo
         jne       st5z007

         call      MouseGet
         sub       cx,4
         call      MouseSet

st5z007: cmp       al,4dh                   ; vpravo
         jne       st5z008

         call      MouseGet
         add       cx,4
         call      MouseSet

st5z008: cmp       al,48h                   ; nahoru
         jne       st5z009

         call      MouseGet
         sub       dx,3
         call      MouseSet

st5z009: cmp       al,50h                   ; dolñ
         jne       st5z00a

         call      MouseGet
         add       dx,3
         call      MouseSet

st5z00a: cmp       al,73h
         jne       st5x01                   ; Ctrl-Left

         call      MouseGet
         sub       cx,40
         call      MouseSet

st5x01:  cmp       al,74h
         jne       st5x02                   ; Ctrl-Rght

         call      MouseGet
         add       cx,40
         call      MouseSet

st5x02:  cmp       al,51h                   ; PageDown
         jne       st5x021

         call      MouseGet
         add       dx,30
         call      MouseSet

st5x021: cmp       al,49h                   ; PageUp
         jne       st5x022

         call      MouseGet
         sub       dx,30
         call      MouseSet

st5x022:


st5x03:
         or        byte ptr ds:[Param],20h  ; obrysy rozhran° barev
         cmp       al,67h
         je        st5001                   ; je Ctrl-F10
         and       byte ptr ds:[Param],not 20h ; nejsou obrsysy rozhran° barev
         cmp       al,66h
         jne       st5002                   ; nen° Ctrl-F9

st5001:
         call      MouseOff
;         call      Obrys                    ; vytvo©en° obrysu obr†zku
         call      MouseOn
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru

st5002:
         call      MouseGet
         jc        st5x00

         test      bl,7
         jnz       st502x1
         jmp       st56                     ; nen° nic stisknuto

; ------ obsluha voleb


st502x1: cmp       cx,128
         jbe       st502

         jmp       st58                     ; nen° v ikon†ch - plat°

st502:
         test      bl,ds:[OldKey]           ; je prvn° stisk ?
         jnz       st5x00                   ; nen° prvn° stisk

         cmp       dx,117                   ; je platn† linka ?
         jb        st5x00                   ; nen° platn† linka

         cmp       dx,149
         ja        st59                     ; nen° volba ikony

; ------ ikona "Konec"

         cmp       cx,32
         jae       st50204

         jmp       konec0

; ------ ikona "Tisk"

st50204: cmp       cx,2*32
         jae       st50206

st50205: call      Tisk

st5x00:  jmp       st5

; ------ ikona "Pero"

st50206: cmp       cx,3*32
         jae       st50208

st50207: cmp       byte ptr ds:[Pero],1     ; je jië pero 1 ?
         je        st5x00                   ; je jië pero 1
         mov       byte ptr ds:[Pero],1     ; á†ra pro pero 1
         mov       dx,offset Kurzor1
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
         jmp       short st5x00

; ------ ikona "Guma"

st50208: cmp       byte ptr ds:[Pero],4     ; je jië pero 2 ?
         je        st5555                   ; je jië pero 2
st50209: mov       byte ptr ds:[Pero],4     ; á†ra pro pero 2
         mov       dx,offset Kurzor2
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
st5555:  jmp       st5

; ------ volba barvy

st59:    cmp       dx,278
         jae       st5a                     ; nen° volba barvy

         sub       dx,150
         shr       dx,1
         shr       dx,1
         shr       dx,1
         shr       dx,1
         and       dl,7
         cmp       cx,65
         jb        st5902
         add       dl,8
st5902:  test      bl,1                     ; levÇ tlaá°tko ?
         jnz       st5903                   ; je levÇ tlaá°tko

         cmp       byte ptr ds:[BarvaR],dl
         je        st5555
         mov       ds:[BarvaR],dl

         jmp       short st5904

st5903:  cmp       byte ptr ds:[BarvaL],dl  ; byla barva zmànàna ?
         je        st5555                   ; barva nebyla zmànàna
         mov       ds:[BarvaL],dl            ; nastaven† barva
st5904:
         call      MouseOff
         call      DispMenu
         call      MouseOn
         jmp       short st5555

; ------ volba palet

st5a:
                                          ;* poëadovan† hodnota palety
         mov       bl,1001b
         sub       dx,276 + 15 + 9
;         sub       dx,276 + 15
         jc        st5a1
         mov       bl,1
         sub       dl,16
         jc        st5a1
         mov       bl,1000b
         sub       dl,16
         jc        st5a1
         mov       bl,0

                                          ;* stanoven° ukazatele barvy
st5a1:   mov       al,ds:[BarvaL]
         cmp       cx,65
         jb        st5a2
         sub       cx,64
         mov       al,ds:[BarvaR]
st5a2:   mov       ah,0
         mov       si,ax

                                          ;* stanoven° rotace
         mov       bh,0
         cmp       cl,20
         jb        st5a3                    ; modr†
         mov       bh,1
         cmp       cl,40                    ; zelen†
         jb        st5a3
         mov       bh,2                     ; áerven†
st5a3:   mov       cl,bh                    ; rotace

                                          ;* nastaven° barvy
         mov       bh,ds:[si+Palety]
         mov       ch,1001b
         shl       ch,cl                    ; maska
         shl       bl,cl                    ; poëadovan† barva
         and       bh,ch
         cmp       bl,bh
         je        st5a9                    ; je jië nastavena
         not       ch
         and       ds:[si+Palety],ch
         or        ds:[si+Palety],bl
         or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru

         call      MouseOff
         call      SetPal                   ; nastaven° palet displeje
         call      DispMenu
         call      MouseOn
st5a9:   jmp       st5



st58:    or        byte ptr ds:[Param],2    ; p©°znak modifikace souboru
         call      MouseOld
         call      MouseOff
         mov       al,ds:[BarvaL]
         test      bl,2                     ; je pravÇ tlaá°tko ?
         jz        st58301                  ; nen° pravÇ tlaá°tko
         mov       al,ds:[BarvaR]           ; barva pro maz†n°
st58301:
         sub       cx,128
         jnc       st583011
         xor       cx,cx
st583011:sub       dx,2
         jnc       st583012
         xor       dx,dx
st583012:
         push      ax
         mov       ax,cx
         shr       ax,1
         shr       ax,1
         mov       bx,ax                    ; pozice bodu
         mov       ax,dx
         xor       dx,dx
         mov       di,3
         div       di
         mov       dx,ax
         pop       ax

         cmp       byte ptr ds:[Pero],1
         je        st58303

         mov       cx,5
st58302: push      bx
         call      SetBod
         call      DispBod
         inc       bx
         call      SetBod
         call      DispBod
         inc       bx
         call      SetBod
         call      DispBod
         inc       bx
         call      SetBod
         call      DispBod
         inc       bx
         call      SetBod
         call      DispBod
         pop       bx
         inc       dx
         loop      st58302
         jmp       short st58304

st58303:
         call      SetBod
         call      DispBod

st58304: call      MouseOn
         jmp       st5                      ; áek†n° na dal®° á†ru

; ------ uloëen° souboru

Konec0:  test      byte ptr ds:[Param],2
         jz        Konec


IFNDEF   DEMO

         mov       dx,ds:[Soubor]
         mov       ah,3ch
         xor       cx,cx
         int       21h
         mov       bx,ax
         jc        Konec

         call      Zakod

         mov       dx,offset ZahlBeg
         mov       cx,offset(ZahlEnd-ZahlBeg)
         mov       ah,40h
         int       21h

         mov       dx,offset Buffer
         mov       cx,ds:[NumBuff]
         mov       ah,40h
         int       21h

         mov       ah,3eh
         int       21h

ENDIF

Konec:
         push      cs
         pop       ds

         xor       ah,ah
         mov       al,ds:[OldVMod]
         int       10h                      ; pñvodn° videom¢d

         mov       ah,9
         mov       dx,offset UvTxt
         int       21h

         int       20h

; *****************************************************************************
;
;                     vyti®tàn° obr†zku na tisk†rnu
;
; *****************************************************************************
;˛

IFDEF    GRAF1

Tisk     PROC      NEAR

IFNDEF   DEMO

         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ inicializace tisk†rny

         mov       si,offset TiskKod1
         call      TiskTxt                  ; inicializace tisk†rny
         jc        Tisk11                   ; chyba tisk†rny

; ------ tisk ©†dku s dekadickòm mà©°tkem

         mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk11
         mov       cl,30-3                  ; á°taá bodñ
         mov       si,3*128 + 3 + 3 + 1       ; poáet bajtñ
Tisk13:  mov       al,0
         cmp       cl,0
         jne       Tisk14
         mov       al,11100b
Tisk14:  call      TiskByte
         jc        Tisk11
         inc       cl
         cmp       cl,30
         jne       Tisk15
         mov       cl,0
Tisk15:  dec       si
         jne       Tisk13
         call      TiskCR
         jc        Tisk11

; ------ p©°prava k tisku ©†dkñ

         xor       di,di                    ; ukazatel ©†dkñ
         mov       ch,0                     ; á°taá ©†dkñ

; ------ zaá†tek ©†dku - test, zda je p©eru®en° operace

Tisk1:   mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jnz       Tisk2                    ; nen° p©ipraven znak
         mov       ah,8
         int       21h                      ; vstup znaku
         cmp       al,27
         jne       Tisk12
Tisk11:  jmp       Tisk9                    ; p©eru®en° operace
Tisk12:  or        al,al
         jnz       Tisk2
         mov       ah,8
         int       21h

; ------ £vodn° k¢d pro tisk ©†dku

Tisk2:   mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk11                   ; chyba vòstupu na tisk†rnu
         xor       si,si                    ; ukazatel pozice na ©†dku

; ------ £vod ©†dku

         mov       cl,3
         mov       al,80h
         cmp       ch,0
         je        Tisk22
         mov       al,0
Tisk22:  call      TiskByte
         jc        Tisk11
         dec       cl
         jnz       Tisk22

; ------ prvn° sloupeáek je linka

Tisk3:   mov       al,11111100b             ; linka
         call      TiskByte                 ; tisk bajtu
         jc        Tisk11

; ------ stanoven° bajtu barvy

         mov       al,10010000b
         call      GetBod                   ; poskytnut° barvy bodu
         cmp       dl,0
         jne       Tisk32
         or        al,11100000b
Tisk32:  mov       bl,dl                    ; £schova bajtu
         inc       di
         call      GetBod                   ; poskytnut° barvy nië®°ho bodu
         cmp       dl,0
         jne       Tisk33
         or        al,00011100b
Tisk33:  mov       bh,dl                    ; £schova bajtu
         cmp       dl,bl                    ; je zmàna barvy ?
         je        Tisk34                   ; nen° zmàna barvy
         cmp       dl,0
         je        Tisk34
         or        al,00100000b             ; p©°znak zmàny barvy
Tisk34:  inc       di
         call      GetBod                   ; dal®° bod
         dec       di
         dec       di                       ; n†vrat adresy bodu
         cmp       dl,bh                    ; je zmàna barvy ?
         je        Tisk35                   ; nen° zmàna barvy
         cmp       dl,0
         je        Tisk35
         or        al,00000100b             ; p©°znak zmàny barvy

; ------ vysl†n° druhÇho a t©et°ho sloupeáku

Tisk35:  call      TiskByte                 ; vysl†n° druhÇho sloupeáku
         jc        Tisk92
;         call      TiskByte                 ; vysl†n° t©et°ho sloupeáku
;         jc        Tisk92

; ------ vysl†n° átvrtÇho sloupeáky

         inc       si
         call      GetBod
         cmp       dl,bl                    ; bude zmàna barvy ?
         je        Tisk38                   ; nebude zmàna barvy
         cmp       dl,0
         je        Tisk38
         or        al,11100000b             ; p©°znak zmàny barvy
Tisk38:  inc       di
         call      GetBod
         cmp       dl,bh                    ; bude zmàna barvy ?
         je        Tisk39                   ; nebude zmàna barvy
         cmp       dl,0
         je        Tisk39
         or        al,00011100b             ; p©°znak zmàny barvy
Tisk39:  cmp       dl,bl
         je        Tisk391
         cmp       dl,0
         je        Tisk391
         or        al,00100000b
Tisk391: inc       di
         call      GetBod
         cmp       dl,bh
         je        Tisk392
         cmp       dl,0
         je        Tisk392
         or        al,00000100b
Tisk392: call      TiskByte                 ; vysl†n° átvrtÇho sloupeáku
Tisk92:  jc        Tisk9
         dec       di
         dec       di

; ------ dal®° bod na ©†dku

Tisk3a:  cmp       si,128
         jae       Tisk3b
         jmp       Tisk3                    ; dal®° bajt

; ------ konec ©†dku

Tisk3b:  mov       al,11111100b
         call      TiskByte
         jc        Tisk9
         mov       cl,3
         mov       al,10000000b
         cmp       ch,0
         je        Tisk3d
         mov       al,00000000b
Tisk3d:  call      TiskByte
         jc        Tisk9
         dec       cl
         jnz       Tisk3d

; ------ dal®° ©†dek

         call      TiskCR
         jc        Tisk9
         inc       ch
         cmp       ch,5
         jne       Tisk3e
         mov       ch,0
Tisk3e:  inc       di
         inc       di                       ; zvò®en° á°sla linky
         cmp       di,Vyska
         jae       Tisk4
         jmp       Tisk1                    ; dal®° ©†dek

; ------ koncov† linka

Tisk4:   mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk9
         mov       cl,30-3                  ; á°taá bodñ
         mov       si,3*128 + 3 + 3 + 1       ; poáet bajtñ
Tisk43:  mov       al,00000000b
         cmp       si,3*128 + 3 + 1
         ja        Tisk44
         cmp       si,3
         jbe       Tisk44
         mov       al,10000000b
         cmp       cl,0
         jne       Tisk44
         mov       al,11100000b
Tisk44:  call      TiskByte
         jc        Tisk9
         inc       cl
         cmp       cl,30
         jne       Tisk45
         mov       cl,0
Tisk45:  dec       si
         jne       Tisk43
         call      TiskCR

; ------ n†vrat registrñ

Tisk9:   pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn

ENDIF

         ret

Tisk     ENDP

ENDIF

;˛

IFDEF    GRAF2

Tisk     PROC      NEAR

IFNDEF   DEMO

         call      MouseOff
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ inicializace tisk†rny

         mov       si,offset TiskKod1
         call      TiskTxt                  ; inicializace tisk†rny
         jc        Tisk11                   ; chyba tisk†rny

; ------ tisk ©†dku s dekadickòm mà©°tkem

         mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk11
         mov       cl,40-4                  ; á°taá bodñ
         mov       si,512 + 4 + 4 + 1       ; poáet bajtñ
Tisk13:  mov       al,0
         cmp       cl,0
         jne       Tisk14
         mov       al,7
Tisk14:  call      TiskByte
         jc        Tisk11
         inc       cl
         cmp       cl,40
         jne       Tisk15
         mov       cl,0
Tisk15:  dec       si
         jne       Tisk13
         call      TiskCR
         jc        Tisk11

; ------ p©°prava k tisku ©†dkñ

         xor       di,di                    ; ukazatel ©†dkñ
         mov       ch,0                     ; á°taá ©†dkñ

; ------ zaá†tek ©†dku - test, zda je p©eru®en° operace

Tisk1:   mov       ah,0bh
         int       21h
         inc       al                       ; je p©ipraven znak ?
         jnz       Tisk2                    ; nen° p©ipraven znak
         mov       ah,8
         int       21h                      ; vstup znaku
         cmp       al,27
         jne       Tisk12
Tisk11:  jmp       Tisk9                    ; p©eru®en° operace
Tisk12:  or        al,al
         jnz       Tisk2
         mov       ah,8
         int       21h

; ------ £vodn° k¢d pro tisk ©†dku

Tisk2:   mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk11                   ; chyba vòstupu na tisk†rnu
         xor       si,si                    ; ukazatel pozice na ©†dku

; ------ £vod ©†dku

         mov       cl,4
         mov       al,80h
         cmp       ch,0
         je        Tisk22
         mov       al,0
Tisk22:  call      TiskByte
         jc        Tisk11
         dec       cl
         jnz       Tisk22

; ------ prvn° sloupeáek je linka

Tisk3:   mov       al,0ffh                  ; jinak linka pro dekadickou pozici
         call      TiskByte                 ; tisk bajtu
         jc        Tisk11

; ------ stanoven° bajtu barvy

         mov       al,88h
         call      GetBod                   ; poskytnut° barvy bodu
         cmp       dl,0
         jne       Tisk32
         or        al,0f0h
Tisk32:  mov       bl,dl                    ; £schova bajtu
         inc       di
         call      GetBod                   ; poskytnut° barvy nië®°ho bodu
         cmp       dl,0
         jne       Tisk33
         or        al,0fh
Tisk33:  mov       bh,dl                    ; £schova bajtu
         cmp       dl,bl                    ; je zmàna barvy ?
         je        Tisk34                   ; nen° zmàna barvy
         cmp       dl,0
         je        Tisk34
         or        al,10h                   ; p©°znak zmàny barvy
Tisk34:  inc       di
         call      GetBod                   ; dal®° bod
         dec       di
         dec       di                       ; n†vrat adresy bodu
         cmp       dl,bh                    ; je zmàna barvy ?
         je        Tisk35                   ; nen° zmàna barvy
         cmp       dl,0
         je        Tisk35
         or        al,1                     ; p©°znak zmàny barvy

; ------ vysl†n° druhÇho a t©et°ho sloupeáku

Tisk35:  call      TiskByte                 ; vysl†n° druhÇho sloupeáku
         jc        Tisk92
         call      TiskByte                 ; vysl†n° t©et°ho sloupeáku
         jc        Tisk92

; ------ vysl†n° átvrtÇho sloupeáky

         inc       si
         call      GetBod
         cmp       dl,bl                    ; bude zmàna barvy ?
         je        Tisk38                   ; nebude zmàna barvy
         cmp       dl,0
         je        Tisk38
         or        al,0f0h                  ; p©°znak zmàny barvy
Tisk38:  inc       di
         call      GetBod
         cmp       dl,bh                    ; bude zmàna barvy ?
         je        Tisk39                   ; nebude zmàna barvy
         cmp       dl,0
         je        Tisk39
         or        al,0fh                   ; p©°znak zmàny barvy
Tisk39:  cmp       dl,bl
         je        Tisk391
         cmp       dl,0
         je        Tisk391
         or        al,10h
Tisk391: inc       di
         call      GetBod
         cmp       dl,bh
         je        Tisk392
         cmp       dl,0
         je        Tisk392
         or        al,1
Tisk392: call      TiskByte                 ; vysl†n° átvrtÇho sloupeáku
Tisk92:  jc        Tisk9
         dec       di
         dec       di

; ------ dal®° bod na ©†dku

Tisk3a:  cmp       si,128
         jae       Tisk3b
         jmp       Tisk3                    ; dal®° bajt

; ------ konec ©†dku

Tisk3b:  mov       al,0ffh
         call      TiskByte
         jc        Tisk9
         mov       cl,4
         mov       al,80h
         cmp       ch,0
         je        Tisk3d
         mov       al,0
Tisk3d:  call      TiskByte
         jc        Tisk9
         dec       cl
         jnz       Tisk3d

; ------ dal®° ©†dek

         call      TiskCR
         jc        Tisk9
         inc       ch
         cmp       ch,5
         jne       Tisk3e
         mov       ch,0
Tisk3e:  inc       di
         inc       di                       ; zvò®en° á°sla linky
         cmp       di,Vyska
         jae       Tisk4
         jmp       Tisk1                    ; dal®° ©†dek

; ------ koncov† linka

Tisk4:   mov       si,offset TiskKod2
         call      TiskTxt                  ; £vodn° k¢d pro grafiku
         jc        Tisk9
         mov       cl,40-4                  ; á°taá bodñ
         mov       si,512 + 4 + 4 + 1       ; poáet bajtñ
Tisk43:  mov       al,0
         cmp       si,512 + 4 + 1
         ja        Tisk44
         cmp       si,4
         jbe       Tisk44
         mov       al,80h
         cmp       cl,0
         jne       Tisk44
         mov       al,0f0h
Tisk44:  call      TiskByte
         jc        Tisk9
         inc       cl
         cmp       cl,40
         jne       Tisk45
         mov       cl,0
Tisk45:  dec       si
         jne       Tisk43
         call      TiskCR

; ------ n†vrat registrñ

Tisk9:   pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         call      MouseOn

ENDIF

         ret

Tisk     ENDP

ENDIF


; *****************************************************************************
;                             TiskCR
;                     od©†dkov†n° tisk†rny
; -----------------------------------------------------------------------------
;
; *****************************************************************************

TiskCR   PROC      NEAR

         push      ax
         mov       al,13
         call      TiskByte
         jc        TiskCR2
         mov       al,10
         call      TiskByte
TiskCR2: pop       ax
         ret

TiskCR   ENDP

; *****************************************************************************
;                             TiskTxt
;                   vysl†n° textu na tisk†rnu
; -----------------------------------------------------------------------------
; VSTUP: DS:SI=text k vyti®tàn° (prvn° bajt = dÇlka textu)
; VùSTUP:CY=chyba vòstupu na tisk†rnu
; *****************************************************************************

TiskTxt  PROC      NEAR

         push      cx
         mov       ch,0
         mov       cl,ds:[si]
         inc       si
TiskTxt1:cld
         lodsb
         call      TiskByte
         jc        TiskTxt2
         loop      TiskTxt1
TiskTxt2:pop       cx
         ret

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
;              Obsluha zobrazen° jednotlivòch á†st° displeje
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                 zobrazen° celÇho obr†zku
; -----------------------------------------------------------------------------

DispObr  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      cx
         push      dx

; ------ zobrazen° obr†zku

         call      DispMal                  ; zobrazen° malÇho obr†zku
         call      DispVel                  ; zobrazen° velkÇho obr†zku

; ------ zobrazen° s°tà - vodorovnÇ á†ry

         xor       dx,dx
         mov       bx,128
         mov       al,1
         mov       cx,639
DispObr1:mov       si,dx
         call      Line
         add       dx,30
         cmp       dx,350
         jb        DispObr1

; ------ zobrazen° s°tà - vertik†ln° á†ry

         xor       dx,dx
         mov       bx,128
         mov       si,347
DispObr2:mov       cx,bx
         call      Line
         add       bx,40
         cmp       bx,640
         jb        DispObr2

;         xor       dx,dx
;DispObr4:xor       bx,bx                    ; pozice
;         mov       cx,Sirka                 ; ®°©ka obr†zku
;DispObr5:;call      DispBod                  ; zobrazen° bodu obr†zku
;         inc       bx
;         loop      DispObr5
;         inc       dx
;         cmp       dx,Vyska
;         jne       DispObr4

; ------ n†vrat registrñ

         pop       dx
         pop       cx
         pop       bx
         ret

DispObr  ENDP

; -----------------------------------------------------------------------------
;                        zobrazen° celÇho malÇho obr†zku
; -----------------------------------------------------------------------------

DispMal  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         call      DeiniReg                 ; standardn° nastaven° registrñ
         mov       ax,0a000h
         mov       es,ax

         mov       ch,1                     ; rovina k z†pisu
         mov       cl,0                     ; á°slo roviny
         cld

; ------ nastaven° barevnÇ roviny

DispMal2:mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,ch
         out       dx,al

; ------ p©°prava k dek¢dov†n° jednÇ roviny

         mov       si,offset Obrazek
         mov       di,80

; ------ dek¢dov†n° jednÇ linky

DispMal3:mov       dx,Sirka/8               ; poáet bajtñ na linku

; ------ dek¢dov†n° jednoho bajtu

DispMal4:lodsb
         ror       al,cl
         mov       bl,al

         and       al,1
         ror       al,1
         mov       ah,al                    ; bit 7

         and       bl,10h
         rol       bl,1
         rol       bl,1
         or        ah,bl                    ; bit 6

         lodsb
         ror       al,cl
         mov       bl,al

         and       al,1
         ror       al,1
         ror       al,1
         ror       al,1
         or        ah,al                    ; bit 5

         and       bl,10h
         or        ah,bl                    ; bit 4

         lodsb
         ror       al,cl
         mov       bl,al

         and       al,1
         rol       al,1
         rol       al,1
         rol       al,1
         or        ah,al                    ; bit 3

         and       bl,10h
         ror       bl,1
         ror       bl,1
         or        ah,bl                    ; bit 2

         lodsb
         ror       al,cl
         mov       bl,al

         and       al,1
         rol       al,1
         or        ah,al                    ; bit 1

         and       bl,10h
         ror       bl,1
         ror       bl,1
         ror       bl,1
         ror       bl,1
         or        ah,bl                    ; bit 0

         mov       al,ah
         stosb

         dec       dx
         jnz       DispMal4                 ; dal®° bajt linky

; ------ p©°prava pro dal®° linku

         add       di,80-Sirka/8
         cmp       di,80+Vyska*80
         jb        DispMal3

; ------ p©°prava pro dal®° rovinu

         inc       cl                       ; zvò®en° á°sla roviny
         rol       ch,1                     ; maska roviny
         cmp       cl,4
         je        DispMal9
         jmp       DispMal2                 ; dal®° rovina

; ------ n†vrat registrñ

DispMal9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispMal  ENDP

; -----------------------------------------------------------------------------
;                   zobrazen° celÇho velkÇho obr†zku
; -----------------------------------------------------------------------------

DispVel  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©°prava registrñ

         call      DeiniReg                 ; standardn° nastaven° registrñ
         mov       ax,0a000h
         mov       es,ax

         mov       ch,1                     ; rovina k z†pisu
         mov       cl,0                     ; á°slo roviny
         cld

; ------ nastaven° barevnÇ roviny

DispVel2:mov       dx,3c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,ch
         out       dx,al

; ------ p©°prava k dek¢dov†n° jednÇ roviny

         mov       si,offset Obrazek
         mov       di,80+Sirka/8            ; poá†teán° adresa

; ------ dek¢dov†n° jednÇ linky

DispVel3:mov       dx,Sirka/2               ; poáet bajtñ na linku

; ------ dek¢dov†n° jednoho bajtu

DispVel4:lodsb
         ror       al,cl
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1
         and       al,11h
         mov       bl,al
         shl       bl,1
         or        al,bl
         shl       bl,1
         or        al,bl
         mov       es:[di+80],al
         stosb

         dec       dx
         jnz       DispVel4                 ; dal®° bajt linky

; ------ p©°prava pro dal®° linku

         add       di,3*80-Sirka/2
         cmp       di,80+Vyska*3*80
         jb        DispVel3

; ------ p©°prava pro dal®° rovinu

         inc       cl                       ; zvò®en° á°sla roviny
         rol       ch,1                     ; maska roviny
         cmp       cl,4
         jb        DispVel2                 ; dal®° rovina

; ------ n†vrat registrñ

DispVel9:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispVel  ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho bodu obr†zku
; -----------------------------------------------------------------------------
; VSTUP: BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

DispBod  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cmp       bx,Sirka
         jae       DispBod9
         cmp       dx,Vyska
         jae       DispBod9

; ------ uráen° barvy bodu

         push      dx
         mov       ax,Sirka                 ; ®°©ka obr†zku
         mul       dx                       ; p©epoáet linky na offset
         add       ax,bx                    ; p©iáten° pozice
         mov       si,ax
         shr       si,1                     ; offset v mapà
         mov       al,ds:[si+Obrazek]       ; barva
         jnc       DispBod1                 ; byl sudò bod
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; pro lichò bod rotace o 4 bity
DispBod1:and       al,0fh                   ; barva bodu
         pop       dx

; ------ zobrazen° bodu ve zmen®enÇm obr†zku

         inc       dx
         call      Point                    ; zobrazen° bodu ve zmen®enÇm obr.
         dec       dx

; ------ vòpoáet pozice bodu ve zvàt®enÇm obr†zku

         shl       bx,1
         shl       bx,1
         add       bx,129                   ; pozice bodu
         push      ax
         mov       ax,3
         mul       dx
         mov       dx,ax                    ; linka bodu
         inc       dx
         pop       ax

; ------ zobrazen° bodu

         call      Point
         inc       bx
         call      Point
         inc       bx
         call      Point
         dec       bx
         dec       bx
         inc       dx
         call      Point
         inc       bx
         call      Point
         inc       bx
         call      Point

; ------ n†vrat registrñ

DispBod9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBod  ENDP

; -----------------------------------------------------------------------------
;        nastaven° jednoho bodu obr†zku
; -----------------------------------------------------------------------------
; VSTUP: AL=barva bodu
;        BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

SetBod   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cmp       bx,Sirka
         jae       SetBod9
         cmp       dx,Vyska
         jae       SetBod9

         mov       ah,0f0h                  ; maska starÇ barvy
         mov       cl,4

; ------ nastaven° barvy bodu

         push      dx

         push      ax
         mov       ax,Sirka                 ; ®°©ka obr†zku
         mul       dx                       ; p©epoáet linky na offset
         add       ax,bx                    ; p©iáten° pozice
         mov       si,ax
         pop       ax

         shr       si,1                     ; offset v mapà
         jnc       SetBod1                  ; byl sudò bod
         rol       ah,cl
         rol       al,cl
SetBod1: and       ds:[si+Obrazek],ah       ; maska starÇ barvy
         or        ds:[si+Obrazek],al
         pop       dx

; ------ n†vrat registrñ

SetBod9: pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetBod   ENDP

; -----------------------------------------------------------------------------
;        poskytnut° bodu obr†zku
; -----------------------------------------------------------------------------
; VSTUP: SI=pozice
;        DI=linka
; VùSTUP:DL=barva (mimo rozsah je DL=15 b°l†)
; -----------------------------------------------------------------------------

GetBod   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      si
         push      di

; ------ kontrola rozsahu

         mov       al,15                    ; barva mimo rozsah
         cmp       si,Sirka
         jb        GetBod3
         mov       si,Sirka-1
GetBod3: cmp       di,Vyska
         jb        GetBod4
         mov       di,Vyska-1

; ------ uráen° barvy bodu

GetBod4: mov       ax,Sirka                 ; ®°©ka obr†zku
         mul       di                       ; p©epoáet linky na offset
         add       ax,si                    ; p©iáten° pozice
         mov       si,ax
         shr       si,1                     ; offset v mapà
         mov       al,ds:[si+Obrazek]       ; barva
         jnc       GetBod1                  ; byl sudò bod
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1                     ; pro lichò bod rotace o 4 bity
GetBod1: and       al,0fh                   ; barva bodu

; ------ n†vrat registrñ

GetBod9: pop       di
         pop       si
         pop       dx
         mov       dl,al                    ; barva
         pop       ax
         ret

GetBod   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° menu
; -----------------------------------------------------------------------------
;˛
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
;         push      es
;         mov       dx,3c4h
;         mov       al,2
;         out       dx,al
;         inc       dx
;         mov       al,0fh
;         out       dx,al                    ; z†pis do v®ech rovin
;         mov       di,80*(350-32) + Maska
;         mov       ax,0a000h
;         mov       es,ax
;         mov       ax,0ffffh
;         mov       cx,32*80/2
;         cld
;         rep       stosw
;         pop       es

; ------ zobrazen° voleb

         mov       dx,118                   ; poá†teán° linka
         xor       bx,bx                    ; poá†teán° pozice
         mov       al,15                    ; barva
         mov       di,offset ObrKonec       ; ikona "Konec"
         mov       si,30
         mov       cx,32
         call      Pict
         mov       di,offset ObrTisk        ; ikona "Tisk"
         add       bx,32
         call      Pict
         mov       di,offset ObrPero        ; ikona "Pero"
         add       bx,32
         call      Pict
         mov       di,offset ObrGuma        ; ikona "Guma"
         add       bx,32
         call      Pict

; ------ zobrazen° barev

         xor       al,al                    ; poá†teán° barva
         xor       bx,bx                    ; poá†teán° pozice
DispMen1:mov       dx,150                   ; poá†teán° linka

DispMen2:mov       cx,64                    ; ®°©ka obdÇln°ku
         mov       si,16                    ; vò®ka obdÇln°ku
         call      Box                      ; zobrazen° obdÇln°ku barvy

         push      ax
         push      bx
         push      dx

         mov       ah,8
         mul       ah
         mov       di,ax
         add       di,offset Font0
         mov       al,0fh
         add       bx,8
         add       dx,4
         mov       si,8
         mov       cx,8
         call      Pict

         pop       dx
         pop       bx
         pop       ax

         add       dx,16                    ; zvò®en° linky

         inc       al                       ; zvò®en° á°sla barvy
         test      al,7
         jnz       DispMen2
         add       bx,64
         cmp       al,10h
         jb        DispMen1

; ------ zobrazen° palet

         mov       al,ds:[BarvaL]           ; lev† barva
         xor       bx,bx                    ; pozice
         mov       dx,276                   ; linka
         call      DispPal                  ; zobrazen° palety
         mov       al,ds:[BarvaR]           ; prav† barva
         mov       bx,64                    ; pozice
         call      DispPal                  ; zobrazen° palety

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

; -----------------------------------------------------------------------------
;         nastaven° palet
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

         mov       dx,offset Palety
         push      ds
         pop       es
         mov       ax,1002h
         int       10h

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetPal   ENDP

; -----------------------------------------------------------------------------
;                       Zobrazen° nastaven° palet
; -----------------------------------------------------------------------------
; VSTUP: AL=barva
;        BX=pozice
;        DX=linka
; -----------------------------------------------------------------------------

DispPal  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si

         add       bx,2

; ------ zobrazen° r†meáku s barvou

         push      ax
         push      bx
         push      dx

         add       dx,5
         mov       al,15
         mov       cx,bx
         add       cx,59
         mov       si,dx
         call      Line                     ; horn° linka

         mov       cx,bx
         mov       si,dx
         add       si,66
         call      Line                     ; levò okraj

         add       bx,59
         mov       cx,bx
         call      Line                     ; pravò okraj

         sub       bx,59
         mov       dx,si
         call      Line                     ; spodn° linka

         sub       dx,14
         mov       si,dx
         call      Line                     ; oddàlovac° linka

         pop       dx
         pop       bx
         pop       ax

         add       dx,58

         inc       bx
         mov       cx,58
         mov       si,13
         call      Box                      ; zobrazen° barvy

; ------ zobrazen° palet barvy

         sub       dx,2
         mov       si,ax
         and       si,0fh                   ; barva
         mov       ah,ds:[Palety+si]        ; palety
         mov       al,9                     ; modr† barva
         call      DispPal0
         mov       al,10                    ; zelen†
         call      DispPal0
         mov       al,12                    ; áerven†
         call      DispPal0

         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispPal  ENDP

DispPal0 PROC      NEAR

         push      dx

         add       bx,2

         push      ax
         mov       al,ah
         shl       al,1
         shr       ah,1
         shr       ah,1
         shr       ah,1
         and       ax,102h
         or        al,ah                    ; paleta
         mov       ah,16                    ; linek na stupe§
         mul       ah                       ; vò®ka sloupce
         mov       si,ax                    ; vò®ka obdÇln°ku
         pop       ax

         sub       dx,si
         mov       cx,15                    ; ®°©ka
         or        si,si
         jz        DispPl04
         call      Box                      ; barva
DispPl04:
         sub       si,3*16
         jz        DispPl05
         neg       si
         sub       dx,si
         mov       al,0
         call      Box
DispPl05:
         pop       dx

         add       bx,17
         shr       ah,1
         ret

DispPal0 ENDP

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
         cmp       cx,640
         jae       MouseSt2
         cmp       dx,348
         jae       MouseSt2
         mov       ax,4
         call      Mouse
MouseSt2:pop       ax
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

; ------ pomocnò kurzor

         push      ax
         push      bx
         push      cx
         push      dx

         cmp       cx,128
         jae       MouseG11
         test      byte ptr ds:[Param],40h  ; je pomocnò kurzor ?
         jnz       MouseGt1                 ; je jië pomocnò kurzor

         mov       dx,offset Kurzor3
         mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
         or        byte ptr ds:[Param],40h

         jmp       short MouseGt1

; ------ bàënò kurzor

MouseG11:test      byte ptr ds:[Param],40h
         jz        MouseGt1                 ; je bàënò

         mov       dx,offset Kurzor1
         cmp       byte ptr ds:[Pero],1
         je        MouseG12
         mov       dx,offset Kurzor2
MouseG12:mov       ax,9
         mov       bx,1
         mov       cx,1
         call      Mouse
         and       byte ptr ds:[Param],not 40h

MouseGt1:pop       dx
         pop       cx
         pop       bx
         pop       ax


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

         sti
         test      byte ptr ds:[Param],80h
         jnz       Mouse03                  ; nen° my®
         int       33h

Mouse03: pop       es
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

         mov       ax,80                    ; poáet bajtñ na linku
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
         rep       movsb
;Pict2:   lodsb                              ; bajt k zobrazen°
;         xchg      al,es:[di]
;         inc       di
;         loop      Pict2
         pop       cx
         pop       di
         add       di,80
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
         mov       di,80
         mul       di                       ; vòpoáet poá†teán°ho offsetu linky
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
         add       di,80                    ; zvò®en° adresy ve videopamàti
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
;         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; nastaven° masky pro z†pis
         mov       al,ah                    ; vzorek
         xchg      al,es:[di]               ; z†pis prvn°ho bajtu linky
         inc       di                       ; zvò®en° ukl†dac° adresy

; ------ zobrazen° vnit©n°ch bajtñ linky

         cld                                ; smàr nahoru
         jcxz      FilLine2
FilLine1:mov       al,0ffh                  ; maska - v®echny bity
;         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al                    ; povolen° z†pisu pro v®echny bity
         mov       al,ah                    ; vòpl§
         xchg      al,es:[di]
         inc       di
         loop      FilLine1                 ; z†pis vnit©n°ch bajtñ linky

; ------ zobrazen° posledn°ho bajtu linky

FilLine2:mov       al,bl                    ; maska posledn°ho bajtu
;         and       al,es:[di+Maska]         ; maskov†n°
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
         mov       al,0
         out       dx,al
         dec       dx

; ------ nastaven° registru rovin

         mov       al,1
         out       dx,al
         inc       dx
         mov       al,ah
         not       al
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

; ------ n†vrat registrñ

         pop       dx
         pop       ax
         ret

DeIniReg ENDP

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

         call      InitReg                  ; inicializace registrñ videokarty

; ------ vòpoáet adresy ve videopamàti

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamàti
         mov       ax,80
         mul       dx                       ; vòpoáet poá†teán°ho offsetu linky
         mov       di,ax                    ; poá†teán° adresa linky
         mov       cl,bl                    ; pozice bodu LOW
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epoáet na offset v bajtech
         add       di,bx                    ; poá†teán° adresa k zobrazen°

; ------ nastaven° registru masky

         mov       dx,3ceh
         mov       al,8
         out       dx,al                    ; volba registru 8 - reg. masky
         inc       dx                       ; 3cfh - adresa registru masky
         and       cl,7                     ; bitov† pozice (0 aë 7)
         mov       al,80h                   ; inicializaán° maska
         shr       al,cl                    ; rotace masky vpravo (80h aë 01h)

; ------ z†pis bodu

;         and       al,es:[di+Maska]         ; maskov†n°
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
         mov       ax,80                    ; ®°©ka linky v bajtech
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
Lin1EGA2:;and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,80
         add       bp,si
         ror       ah,1
         adc       di,0
         jmp       short Lin1EGA4
Lin1EGA3:ror       ah,1
         jnc       Lin1EGA4
;         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         inc       di
         xor       al,al
Lin1EGA4:loop      Lin1EGA1
;         and       al,es:[di+Maska]         ; maskov†n°
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
;         and       al,es:[di+Maska]         ; maskov†n°
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
Lin2EGA4:add       di,80
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
Lin3EGA3:;and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         xor       al,al
         add       di,80
         add       bp,si
         rol       ah,1
         sbb       di,0
         jmp       short Lin3EGA5
Lin3EGA4:rol       ah,1
         jnb       Lin3EGA5
;         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         xchg      al,es:[di]
         dec       di
         xor       al,al
Lin3EGA5:loop      Lin3EGA1
;         and       al,es:[di+Maska]         ; maskov†n°
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
;         and       al,es:[di+Maska]         ; maskov†n°
         out       dx,al
         pop       ax
         xchg      ah,es:[di]
         or        bp,bp
         jns       Lin4EGA2
         add       bp,si
         jmp       short Lin4EGA3
Lin4EGA2:rol       al,1
         sbb       di,0
;         and       al,es:[di+Maska]         ; maskov†n°
;         out       dx,al
         add       bp,bx
Lin4EGA3:add       di,80
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


; *****************************************************************************
;
;                      Obsluha souborñ
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        zak¢dov†n° obr†zku do bufferu
; -----------------------------------------------------------------------------

Zakod    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si

; ------ p©°prava registrñ

         or        byte ptr ds:[Param],10h  ; nastaven° p©°znaku komprese
         mov       word ptr ds:[KompCit],0  ; nulov†n° á°taáe shodnòch bajtñ
         mov       word ptr ds:[KompBNum],0 ; nulov†n° bufferu dat
         mov       word ptr ds:[NumBuff],0  ; zru®en° z†pisovÇho bufferu

; ------ zak¢dov†n° bufferu

         mov       cx,Sirka*Vyska/2
         mov       si,offset Obrazek
Zakod2:  cld
         lodsb
         call      WritB
         loop      Zakod2

; ------ vypr†zdnàn° bufferñ

         call      FlushQ                   ; vypr†zdnàn° bufferu shody
         call      FlushB                   ; vypr†zdnàn° bàënÇho bufferu

; ------ n†vrat registrñ

         pop       si
         pop       cx
         pop       ax
         ret

Zakod    ENDP

; -----------------------------------------------------------------------------
;        z†pis bajtu do bufferu s kompres°
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
         mov       si,ds:[NumBuff]          ; poáet bajtñ v bufferu
         mov       ds:[si+Buffer],al        ; z†pis novÇho bajtu do bufferu
         inc       word ptr ds:[NumBuff]    ; zvò®en° á°taáe bajtñ v bufferu
         pop       si
         ret

; -----------------------------------------------------------------------------
;        dek¢dov†n° buffer do obr†zku (po naáten°)
; -----------------------------------------------------------------------------

Dekod    PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      cx
         push      si
         push      di
         push      es

         push      ds
         pop       es

         or        byte ptr ds:[Param],8    ; nastaven° p©°znaku komprese
         mov       word ptr ds:[KompCit],0  ; nulov†n° á°taáe shodnòch bajtñ

         xor       si,si
         mov       di,offset Obrazek
Dekod2:  call      ReadByte                 ; naáten° jednoho bajtu
         jc        Dekod4                   ; chyba - konec
         cld
         stosb                              ; uloëen° bajtu na displej
         loop      Dekod2

; ------ n†vrat registrñ

Dekod4:  pop       es
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

Dekod    ENDP

; -----------------------------------------------------------------------------
;        áten° jednoho bajtu z bufferu (SI=ukazatel)
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
;        áten° bajtu z bufferu (SI=ukazatel)
; -----------------------------------------------------------------------------

ReadByt0 PROC      NEAR

         cmp       si,ds:[NumBuff]
         cmc
         jc        ReadByt9

         mov       al,ds:[si+Buffer]
         inc       si
         clc
ReadByt9:ret

ReadByt0 ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

IFDEF    GRAF1

TiskKod1 db        6
         db        27,"3",18                ; ©†dkov†n° 6/72 palce
         db        27,"O",0                 ; zru®en° p©eskoku p©elomu str†nek
TiskKod2 db        4
         db        27,"K"                   ; zah†jen° grafickÇho tisku
         dw        3*128 + 1 + 3 + 3        ; poáet bodñ

ENDIF


IFDEF    GRAF2

TiskKod1 db        6
         db        27,"3",24                ; ©†dkov†n° 8/72 palce
         db        27,"O",0                 ; zru®en° p©eskoku p©elomu str†nek
TiskKod2 db        5
         db        27,"*",5                 ; zah†jen° grafickÇho tisku
         dw        512 + 1 + 4 + 4          ; tiskne se 512 bodñ + okraje

ENDIF


Param    db        0                        ; parametry
                                            ;   bit 0: 1=je platnò soubor
                                            ;   bit 1: 1=obraz modifikov†n
                                            ;   bit 2: 1=bude dal®° soubor
                                            ;   bit 3: 1=bude stav komprese dat
                                            ;   bit 4: 1=nyn° je komprese dat
                                            ;   bit 5: 1=obrysy rozhran° barev
                                            ;   bit 6: 1=je ®ipka jako kurzor
                                            ;   bit 7: 1=nen° my®

KompCit  dw        0                        ; á°taá pro kompresi
KompChr  db        0                        ; uschovanò opakovanò bajt komprese

IkonY    dw        350-32

OldX     dw        0                        ; pñvodn° pozice my®i X
OldY     dw        0                        ; pñvodn° pozice my®i Y
OldKey   db        0                        ; pñvodn° tlaá°tka my®i

Pero     db        1                        ; tlou®üka á†ry

OldVMod  db        3


; ------ z†pis do souboru

Idents   dw        0                        ; identifikace vòstupn°ho souboru

KompBNum dw        0                        ; poáet bajtñ v kompresn°m bufferu
KompBuff db        256 dup(0)               ; kompresn° buffer

; -----------------------------------------------------------------------------
;        definice ikon
; -----------------------------------------------------------------------------

ObrKonec db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000010b,00000000b,00000000b,10000001b
         db        10000001b,00000000b,00000001b,00000001b
         db        10000000b,10000000b,00000010b,00000001b
         db        10000000b,01000000b,00000100b,00000001b
         db        10000000b,00100000b,00001000b,00000001b
         db        10000000b,00010000b,00010000b,00000001b
         db        10000000b,00001000b,00100000b,00000001b
         db        10000000b,00000100b,01000000b,00000001b
         db        10000000b,00000010b,10000000b,00000001b
         db        10000000b,00000001b,00000000b,00000001b
         db        10000000b,00000010b,10000000b,00000001b
         db        10000000b,00000100b,01000000b,00000001b
         db        10000000b,00001000b,00100000b,00000001b
         db        10000000b,00010000b,00010000b,00000001b
         db        10000000b,00100000b,00001000b,00000001b
         db        10000000b,01000000b,00000100b,00000001b
         db        10000000b,10000000b,00000010b,00000001b
         db        10000001b,00000000b,00000001b,00000001b
         db        10000010b,00000000b,00000000b,10000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10100100b,00000000b,00000000b,00000001b
         db        10101000b,11100101b,10001110b,00111001b
         db        10110001b,00010110b,01010001b,01000101b
         db        10110001b,00010100b,01011111b,01000001b
         db        10101001b,00010100b,01010000b,01000101b
         db        10100100b,11100100b,01001111b,00111001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

ObrTisk  db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00111111b,11111100b,00000001b
         db        10000000b,00100000b,00000100b,00000001b
         db        10000000b,01100000b,00000110b,00000001b
         db        10000000b,01010000b,00001010b,00000001b
         db        10000000b,01010000b,00001010b,00000001b
         db        10000000b,01010000b,00001010b,00000001b
         db        10000111b,11010000b,00001011b,11100001b
         db        10000100b,01010000b,00001010b,00100001b
         db        10000111b,11010000b,00001011b,11100001b
         db        10000100b,01100000b,00000110b,00100001b
         db        10000100b,01100000b,00000110b,00100001b
         db        10000111b,11111111b,11111111b,11100001b
         db        10000100b,00000000b,00000000b,00100001b
         db        10000100b,00000000b,00000000b,00100001b
         db        10000100b,00000000b,00000000b,00100001b
         db        10000100b,00000000b,00011111b,11100001b
         db        10000100b,00000000b,00010000b,00100001b
         db        10000111b,11111111b,11111111b,11100001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000100b,00000000b,00000001b
         db        10000001b,11110000b,00000100b,00000001b
         db        10000000b,01000100b,11100100b,10000001b
         db        10000000b,01000101b,00000101b,00000001b
         db        10000000b,01000100b,11100110b,00000001b
         db        10000000b,01000100b,00010101b,00000001b
         db        10000000b,01000100b,11100100b,10000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

ObrPero  db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000100b,00111111b,00000000b,00000001b
         db        10000011b,10000000b,11000000b,00000001b
         db        10000010b,01000000b,00100000b,00000001b
         db        10000010b,10100000b,00010000b,00000001b
         db        10000001b,00100000b,00001000b,00010001b
         db        10000000b,11010000b,00001000b,00001001b
         db        10000000b,00101000b,00001000b,00001001b
         db        10000000b,00011100b,00000100b,00001001b
         db        10000000b,00001110b,00000010b,00010001b
         db        10000000b,00000111b,00000001b,11100001b
         db        10000000b,00000011b,10000000b,00000001b
         db        10000000b,00000001b,11000000b,00000001b
         db        10000000b,00000000b,11100000b,00000001b
         db        10000000b,00000000b,01110000b,00000001b
         db        10000000b,00000000b,00111000b,00000001b
         db        10000000b,00000000b,00011100b,00000001b
         db        10000000b,00000000b,00001110b,00000001b
         db        10000000b,00000000b,00000110b,00000001b
         db        10000000b,00000000b,00000010b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000111b,10000000b,00000000b,00000001b
         db        10000100b,01001110b,01011100b,11100001b
         db        10000100b,01010001b,01100001b,00010001b
         db        10000111b,10011111b,01000001b,00010001b
         db        10000100b,00010000b,01000001b,00010001b
         db        10000100b,00001110b,01000000b,11100001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b


ObrGuma  db        11111111b,11111111b,11111111b,11111111b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000111b,11111111b,11111111b,10000001b
         db        10001000b,00000000b,00000000b,01000001b
         db        10001000b,00000000b,11110000b,01100001b
         db        10001000b,00000000b,11111000b,01010001b
         db        10001000b,00011111b,11111000b,01010001b
         db        10001000b,00111111b,11111000b,01010001b
         db        10001000b,01011111b,11001000b,01010001b
         db        10001000b,01011111b,10000100b,01010001b
         db        10001000b,01011001b,10000000b,01010001b
         db        10001000b,00011001b,10000000b,01010001b
         db        10001000b,00011001b,10000000b,01010001b
         db        10001000b,00000000b,00000000b,01010001b
         db        10000111b,11111111b,11111111b,11010001b
         db        10000010b,00000000b,00000000b,00110001b
         db        10000001b,11111111b,11111111b,11100001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000000b,00000000b,00000000b,00000001b
         db        10000011b,10000000b,00000000b,00000001b
         db        10000100b,01010001b,01111001b,11000001b
         db        10000100b,00010001b,01010100b,00100001b
         db        10000101b,11010001b,01010100b,11100001b
         db        10000100b,01010001b,01010101b,00100001b
         db        10000011b,10001111b,01010100b,11010001b
         db        10000000b,00000000b,00000000b,00000001b
         db        11111111b,11111111b,11111111b,11111111b

Kurzor1  dw        1111111111111111b
         dw        1000111111111111b
         dw        1000000111111111b
         dw        1000000001111111b
         dw        1000000000111111b
         dw        1100000000001111b
         dw        1100000000000111b
         dw        1100000000000011b
         dw        1100000000000011b
         dw        1110000000000001b
         dw        1110000000000001b
         dw        1111000000000001b
         dw        1111100000000001b
         dw        1111110000000000b
         dw        1111111110000000b
         dw        1111111111110000b

         dw        0000000000000000b
         dw        0000000000000000b
         dw        0011000000000000b
         dw        0011111000000000b
         dw        0011011110000000b
         dw        0001101111000000b
         dw        0001110111100000b
         dw        0001111001110000b
         dw        0001111001111000b
         dw        0000111111111100b
         dw        0000111111111100b
         dw        0000011111111100b
         dw        0000001111111000b
         dw        0000000011110110b
         dw        0000000000001111b
         dw        0000000000000110b

Kurzor2  dw        1000000000000111b
         dw        0000000000000011b
         dw        0000000000000001b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        1000000000000000b
         dw        1100000000000000b
         dw        1110000000000001b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b

         dw        0000000000000000b
         dw        0111111111111000b
         dw        0111111111111000b
         dw        0111111000111010b
         dw        0111000000011010b
         dw        0110000000011010b
         dw        0101000011101010b
         dw        0111000011111010b
         dw        0111011011111010b
         dw        0111111111111010b
         dw        0000000000000010b
         dw        0001111111111100b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b

Kurzor3  dw        1111111111111111b
         dw        0001111111111111b
         dw        0000000111111111b
         dw        1000000000111111b
         dw        1000000001111111b
         dw        1000000011111111b
         dw        1100000011111111b
         dw        1100010001111111b
         dw        1110111000111111b
         dw        1111111100011111b
         dw        1111111110011111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b

         dw        0000000000000000b
         dw        0110000000000000b
         dw        0111111000000000b
         dw        0011111110000000b
         dw        0011111100000000b
         dw        0011111000000000b
         dw        0001101100000000b
         dw        0001000110000000b
         dw        0000000011000000b
         dw        0000000001100000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b

Font0    db        00000000b
         db        00111100b
         db        01000110b
         db        01001010b
         db        01010010b
         db        01100010b
         db        00111100b
         db        00000000b

Font1    db        00000000b
         db        00000100b
         db        00001100b
         db        00010100b
         db        00000100b
         db        00000100b
         db        00001110b
         db        00000000b

Font2    db        00000000b
         db        00111100b
         db        01000010b
         db        00000010b
         db        00011100b
         db        00100000b
         db        01111110b
         db        00000000b

Font3    db        00000000b
         db        00111100b
         db        01000010b
         db        00001110b
         db        00000010b
         db        01000010b
         db        00111100b
         db        00000000b

Font4    db        00000000b
         db        00010000b
         db        00100000b
         db        01001000b
         db        01111110b
         db        00001000b
         db        00001000b
         db        00000000b

Font5    db        00000000b
         db        01111110b
         db        01000000b
         db        01111100b
         db        00000010b
         db        01000010b
         db        00111100b
         db        00000000b

Font6    db        00000000b
         db        00111100b
         db        01000000b
         db        01111100b
         db        01000010b
         db        01000010b
         db        00111100b
         db        00000000b

Font7    db        00000000b
         db        01111110b
         db        01000010b
         db        00000010b
         db        00000100b
         db        00001000b
         db        00010000b
         db        00000000b

Font8    db        00000000b
         db        00111100b
         db        01000010b
         db        00111100b
         db        01000010b
         db        01000010b
         db        00111100b
         db        00000000b

Font9    db        00000000b
         db        00111100b
         db        01000010b
         db        01000010b
         db        00111110b
         db        00000010b
         db        00111100b
         db        00000000b

FontA    db        00000000b
         db        00011000b
         db        00100100b
         db        01000010b
         db        01111110b
         db        01000010b
         db        01000010b
         db        00000000b

FontB    db        00000000b
         db        01111100b
         db        01000010b
         db        01111100b
         db        01000010b
         db        01000010b
         db        01111100b
         db        00000000b

FontC    db        00000000b
         db        00111100b
         db        01000010b
         db        01000000b
         db        01000000b
         db        01000010b
         db        00111100b
         db        00000000b

FontD    db        00000000b
         db        01111100b
         db        01000010b
         db        01000010b
         db        01000010b
         db        01000010b
         db        01111100b
         db        00000000b

FontE    db        00000000b
         db        01111110b
         db        01000000b
         db        01111000b
         db        01000000b
         db        01000000b
         db        01111110b
         db        00000000b

FontF    db        00000000b
         db        01111110b
         db        01000000b
         db        01111000b
         db        01000000b
         db        01000000b
         db        01000000b
         db        00000000b

; ------ texty

IFDEF    DEMO
DemoTxt  db        'DEMONSTRACNI VERZE - neuklada na disk a netiskne !!!',13,10,'$'
ENDIF

IFDEF    DEMO
UvTxt    db        'UPLET V1.3 demo - editor vzoru; (c) Miroslav Nemecek',13,10,'$'
ELSE
UvTxt    db        'UPLET V1.3 - (c) Miroslav Nemecek 1993',13,10
         db        '    GEMA Soft Roznov pod Radhostem',13,10
         db        '             - FREEWARE -',13,10,'$'
ENDIF

EgaErr   db        'Program vyzaduje grafickou kartu EGA nebo VGA !',13,10,'$'
MemErr   db        'Nedostatek pameti !',13,10,'$'
SoubErr  db        'Zadejte soubor k editaci !',13,10,'$'
SoubErr2 db        'Chybne zadani souboru k editaci !',13,10,'$'

NumBuff  dw        0                        ; poáet bajtñ v bufferu
Soubor   dw        ?                        ; adresa jmÇna souboru

ZahlBeg  label     byte                     ; zaá†tek z†hlav°
Identif  db        'UP'                     ; identifik†tor
Palety   db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0 ; palety
BarvaL   db        0                        ; aktivn° barva - lev†
BarvaR   db        15                       ; aktivn° barva - prav†
ZahlEnd  label     byte                     ; konec z†hlav°

Obrazek  db        128/2 * 116 dup(0)       ; buffer s uschovanòm obr†zkem

Buffer   db        BuffSize dup(0)          ; buffer pro soubor

code     ends
         end       start

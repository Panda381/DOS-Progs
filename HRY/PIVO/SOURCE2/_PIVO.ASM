
BuffSize EQU       1024                     ; velikost bufferu souboru

;DEBUG    EQU       1                        ; p©¡znak testovac¡ho m¢du

DELKOBR  EQU       (16*16/8)*4              ; d‚lka jednoho obr zku

POCVECI  EQU       20                       ; po‡et vˆc¡

LOK      EQU       1                        ; lokomotiva
LO1      EQU       LOK + 0                  ; lokomotiva VLEVO
LO2      EQU       LOK + 1                  ; lokomotiva NAHORU
LO3      EQU       LOK + 2                  ; lokomotiva VPRAVO
LO4      EQU       LOK + 3                  ; lokomotiva DOL¦

LO5      EQU       LOK + 4                  ; lokomotiva VLEVO
LO6      EQU       LOK + 5                  ; lokomotiva NAHORU
LO7      EQU       LOK + 6                  ; lokomotiva VPRAVO
LO8      EQU       LOK + 7                  ; lokomotiva DOL¦

LO9      EQU       LOK + 8                  ; lokomotiva VLEVO
LOA      EQU       LOK + 9                  ; lokomotiva NAHORU
LOB      EQU       LOK + 10                 ; lokomotiva VPRAVO
LOC      EQU       LOK + 11                 ; lokomotiva DOL¦

SRAZKA   EQU       LOK+12                   ; sr ‘ka (10 f z¡)
SR1      EQU       SRAZKA+0
SR2      EQU       SRAZKA+1
SR3      EQU       SRAZKA+2
SR4      EQU       SRAZKA+3
SR5      EQU       SRAZKA+4
SR6      EQU       SRAZKA+5
SR7      EQU       SRAZKA+6
SR8      EQU       SRAZKA+7
SR9      EQU       SRAZKA+8
SRA      EQU       SRAZKA+9

ZED      EQU       SRAZKA+10                ; zeƒ

VRA      EQU       ZED+1                    ; vrata (6 f z¡)

VAGONY   EQU       VRA+6                    ; vagony (ka‘d˜ vagon 4 smˆry)

VECI     EQU       VAGONY + 4*POCVECI       ; vˆci

KRY      EQU       0  * 3 + VECI            ; 1: krystal
KOR      EQU       1  * 3 + VECI            ; 2: koruna
STO      EQU       2  * 3 + VECI            ; 3: strom
JAB      EQU       3  * 3 + VECI            ; 4: jablko
KRA      EQU       4  * 3 + VECI            ; 5: kr va
TRE      EQU       5  * 3 + VECI            ; 6: t©e¨nˆ
RYB      EQU       6  * 3 + VECI            ; 7: rybn¡k
ZIR      EQU       7  * 3 + VECI            ; 8: ‘irafa
ZMR      EQU       8  * 3 + VECI            ; 9: zmrzlina
DOR      EQU       9  * 3 + VECI            ; 10: dort
POC      EQU       10 * 3 + VECI            ; 11: po‡¡ta‡
AUT      EQU       11 * 3 + VECI            ; 12: auto
BAL      EQU       12 * 3 + VECI            ; 13: bal¢n
BUD      EQU       13 * 3 + VECI            ; 14: bud¡k
SLO      EQU       14 * 3 + VECI            ; 15: slon
VIN      EQU       15 * 3 + VECI            ; 16: v¡no
PEN      EQU       16 * 3 + VECI            ; 17: pen¡ze
LET      EQU       17 * 3 + VECI            ; 18: letadlo
RZ1      EQU       18 * 3 + VECI            ; 19: ... rezerva 1
RZ2      EQU       19 * 3 + VECI            ; 20: ... rezerva 2

Code     SEGMENT
         ASSUME    cs:Code,ds:Data

; ------ inicializace registr–

Start:   mov       ax,SEG Data
         mov       ds,ax
         mov       ds:[SegmPSP],es          ; segment PSP

; ------ zmen¨en¡ bloku programu

         mov       bx,ss                    ; segment z sobn¡ku
         add       bx,(2*200h + 100h)/ 16   ; p©i‡ten¡ velikosti z sobn¡ku
         mov       ax,es
         sub       bx,ax                    ; velikost programu
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ aloka‡n¡ho bloku

; ------ na‡ten¡ souboru obr zk– PCX

         call      ReadPCX                  ; na‡ten¡ souboru obr zk– PCX
         mov       dx,offset ErrTxt         ; chybov‚ hl ¨en¡
;         mov       dx,offset PCXTxt         ; text - chyba PCX
         jc        Start11                  ; chyba PCX

; ------ na‡ten¡ souboru sc‚n SCN

         call      ReadSCN                  ; na‡ten¡ souboru sc‚n SCN
         mov       dx,offset ErrTxt         ; chybov‚ hl ¨en¡
;         mov       dx,offset PCXTxt         ; text - chyba SCN
         jc        Start11                  ; chyba SCN

; ------ test karty EGA/VGA

         mov       ah,12h
         mov       bx,7a10h
         call      Int10                    ; test informac¡ o EGA/VGA
         cmp       bh,1
         ja        Start10                  ; chyba
         cmp       bl,3
         jbe       Start1                   ; OK

; ------ chyba - nen¡ karta EGA/VGA

Start10: mov       dx,offset CardTxt        ; text - nen¡ karta EGA/VGA
Start11: mov       ah,9
         int       21h                      ; zobrazen¡ textu DOS
         mov       ax,4c01h
         int       21h

; ------ inicializace videom¢du VGA

Start1:  mov       ax,13
         call      Int10                    ; nastaven¡ videom¢du 320x200
         mov       ah,0fh
         call      Int10                    ; test aktu ln¡ho videom¢du
         cmp       al,13                    ; videom¢d spr vnˆ nastaven ?
         jne       Start10                  ; chyba nastaven¡ videom¢du

; ------ inicializace hodin

         call      CekInit                  ; inicializace hodin

; ------ inicializace adres obr zk–

         call      InitObr                  ; inicializace adres obr zk–

; ------ inicializace demonstrace (sc‚na 0)

Start2:  mov       al,0                     ; sc‚na 0 = DEMO
         call      InitScen                 ; inicializace sc‚ny AL (0=DEMO)
         mov       byte ptr ds:[Demon],1    ; p©¡znak, ‘e je demonstrace

; ------ vymaz n¡ informa‡n¡ho © dku
;þ
         call      ClearInf                 ; vymaz n¡ informa‡n¡ho © dku
         call      DispScen                 ; zobrazen¡ sc‚ny
         mov       byte ptr ds:[CitTit],0   ; ‡¡ta‡ titulku

         mov       si,offset DemoPos
Start23: call      TestTime                 ; inicializace ‡¡ta‡e ‡asu
         jc        Start3                   ; nen¡ krok
         call      IncFaze                  ; zv˜¨en¡ f ze

         call      OpenVrat                 ; otev©en¡ vrat

         cmp       byte ptr ds:[Faze],0
         jne       Start3

;         cmp       word ptr ds:[MapVlak+1],11*256 + 9
;         je        Start2                   ; nov˜ start DEMO

         mov       dx,ds:[si]
         or        dx,dx                    ; je konec ?
         jz        Start4

;         jz        Start2                   ; je konec

         inc       si
         inc       si
         call      PosVlak                  ; posun vlaku

         mov       al,ds:[MapVlak+1]
         shl       al,1
         sub       al,2
         jbe       Start25
         cmp       al,34
         ja        Start25
         cmp       byte ptr ds:[CitTit],34
         jae       Start25
         mov       ds:[CitTit],al
         call      DispTit
Start25:

Start3:  mov       ah,1
         int       16h
         jz        Start23

Start302:mov       ah,0
         int       16h
         or        ax,ax
         jz        Start38
         cmp       al,27
         jne       Start4

Start38: call      SoundOff
         mov       ax,3
         int       10h

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         mov       ax,4c00h
         int       21h

; ------ start sc‚ny

Start4:
         mov       byte ptr ds:[Demon],0    ; nen¡ demonstrace
         mov       al,ds:[AktScen]
         call      InitScen                 ; inicializace sc‚ny AL (0=DEMO)
         call      DispScen
         call      DispInf                  ; zobrazen¡ informa‡n¡ho © dku

Start41: call      FlushKey

Start5:  call      TestTime                 ; inicializace ‡¡ta‡e ‡asu
         jc        Start5                   ; nen¡ krok

         mov       ah,1
         int       16h
         jz        Start532

         cmp       ax,3e00h
         jne       Start530
         mov       ah,0
         int       16h
         jmp       Heslo

Start530:
         or        ax,ax
         jz        Start531
         cmp       al,27
         jne       Start532

Start531:mov       ah,0
         int       16h
         jmp       short Start61

Start532:

         call      IncFaze                  ; zv˜¨en¡ f ze

         call      OpenVrat                 ; otev©en¡ vrat

         cmp       byte ptr ds:[Faze],0
         jne       Start5


STart60: mov       ah,1
         int       16h
         jz        Start69                  ; nen¡ kl vesa

Start603:mov       ah,0
         int       16h

         cmp       ax,3e00h
         jne       Start606
         jmp       Heslo                    ; zad n¡ hesla

Start606:
         or        ax,ax
         jz        Start61
         cmp       al,27
         jne       Start62

Start61: call      SoundOff
         jmp       Start2

Start62: cmp       ah,48h
         jne       Start63
         mov       dx,0ff00h                ; nahoru
         jmp       short Start652

Start63: cmp       ah,4bh
         jne       Start64
         mov       dx,0ffh                  ; vlevo
         jmp       short Start652

Start64: cmp       ah,4dh
         jne       Start65
         mov       dx,1                     ; vpravo
         jmp       short Start652

Start65: cmp       ah,50h
         jne       Start60
         mov       dx,1*256                 ; dol–

Start652:cmp       dx,word ptr ds:[Smer]
         je        Start60                  ; smˆr je ji‘ nastaven
         mov       ds:[Smer],dx             ; nov˜ smˆr

Start69: mov       dx,ds:[Smer]
         or        dx,dx
         jz        Start6

; ------ test, zda vlak do nˆ‡eho naraz¡

         push      dx
         add       dl,ds:[MapVlak+1]
         add       dh,ds:[MapVlak+2]
         mov       al,20                    ; po‡et pozic
         mul       dh                       ; p©epo‡et © dku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,si                    ; SI <- adresa v poli
         mov       al,ds:[si]               ; prvek na nov‚ pozici
         pop       dx

         cmp       al,0
         je        Start6A
         cmp       al,VECI
         jae       Start6A1
         cmp       al,VRA
         jbe       Start6a2
         cmp       al,VRA+6
         jb        Start6A
Start6a2:jmp       Start8                   ; hav rie

Start6A1:mov       word ptr ds:[AdrSound],offset TabSVec
         mov       word ptr ds:[CitSound],offset(TabSVec0-TabSVec) + 1
         jmp       short Start6a4

Start6A:
         mov       word ptr ds:[AdrSound],offset TabSLok
         mov       word ptr ds:[CitSound],offset(TabSLok0-TabSLok) + 1
;þ
Start6a4:call      PosVlak

         mov       dx,word ptr ds:[MapVlak+1]
         cmp       dx,ds:[PozVrat]
         je        Start7                   ; konec hry

Start6:  jmp       Start5

; ------ £spˆ¨n‚ ukon‡en¡ sc‚ny

Start7:
         mov       word ptr ds:[CitSound],0

         mov       bx,2200
         mov       ax,800
         mov       dx,250
         mov       cx,2
Start711:call      SetSound
         xchg      ax,bx
         call      Cekej
         call      SetSound
         xchg      ax,bx
         call      Cekej
         sub       bx,8
         dec       dx
         jnz       Start711

         call      SoundOff

         call      ClosScen

         cmp       byte ptr ds:[AktScen],1  ; byla to 1. sc‚na ?
         jne       Start712
         call      Exec                     ; start programu

         mov       ax,13
         call      Int10                    ; nastaven¡ videom¢du 320x200
         call      ClosScen

Start712:
         call      ClearInf

         inc       byte ptr ds:[AktScen]
         mov       ax,ds:[NumScen]          ; po‡et sc‚n
         cmp       ds:[AktScen],al
         jbe       Start72
         mov       byte ptr ds:[AktScen],1
         jmp       Absol                    ; absolutn¡ v¡tˆz hry

Start72:
         mov       dx,(24/2-1)*256+(40-10)/2
         mov       si,offset ScenTxt
         mov       ah,10
         call      DispTxt

         mov       al,ds:[AktScen]
         mov       ah,0
         mov       ch,14
         call      DispNum

         mov       al," "
         call      DispChr

         mov       dx,(24/2+1)*256+(40-13)/2
         mov       ah,10
         mov       si,offset Hes2Txt
         call      DispTxt

         mov       al,5
         mul       byte ptr ds:[AktScen]
         add       ax,offset TabHesel
         xchg      ax,si
         mov       ah,14
         mov       cx,5
Start73: cld
         lodsb
         call      DispChr
         loop      Start73

         mov       al," "
         call      DispChr

         call      FlushKey

         mov       ah,0
         int       16h

         mov       al,ds:[AktScen]
         call      InitScen                 ; inicializace sc‚ny AL

         call      OpenScen

         call      DispInf                  ; zobrazen¡ informa‡n¡ho © dku

         jmp       Start41


; ------ hav rie

Start8:  mov       byte ptr ds:[MapVlak],0  ; p©¡znak sr ‘ky

         call      DispKec                  ; zobrazen¡ hl ¨en¡ p©i sr ‘ce

         mov       word ptr ds:[CitVyb],120  ; ‡¡ta‡ v˜buchu

         mov       al,SR1                   ; sr ‘ka
Start80: mov       dx,word ptr ds:[MapVlak+1]
         call      DispObr

Start81:
         cmp       word ptr ds:[CitVyb],0
         je        Start86
         dec       word ptr ds:[CitVyb]
         jnz       Start85
         call      SoundOff
         jmp       short Start86

Start85: push      ax
         mov       bx,ds:[CitVyb]
         mov       ax,420
         sub       ax,ds:[CitVyb]
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         mov       bx,word ptr cs:[bx+cs:Start]
         and       bx,0fffh
         add       ax,bx
         call      SetSound
         pop       ax

Start86:
         mov       cx,9
         call      Cekej

         call      TestTime
         jc        Start81

         call      IncFaze

         inc       ax
         cmp       al,SRA+1
         jb        Start80

         mov       al,SR8

         push      ax
         mov       ah,1
         int       16h
         pop       ax
         jz        Start80

         call      SoundOff

Start82: call      FlushKey
Start83: jmp       Start4

; -----------------------------------------------------------------------------
;        start programu po 1. sc‚nˆ
; -----------------------------------------------------------------------------

Exec     PROC      NEAR

         pushf
         push      ds
         mov       cs:[RegSS],ss
         mov       cs:[RegSP],sp

         mov       dx,offset FilePlay
         push      ds
         pop       es
         mov       bx,offset BlokPlay
         mov       ax,4b00h
         int       21h                      ; start programu

         mov       ss,cs:[RegSS]
         mov       sp,cs:[RegSP]

         pop       ds
         popf
         ret

Exec     ENDP

RegSS    dw        0                        ; uschovan˜ registr SS
RegSP    dw        0                        ; uschovan˜ registr SP

; *****************************************************************************
;
;                          Obsluha soubor–
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        sestaven¡ jm‚na k domovsk‚mu souboru (p©¡pona DS:BX) -> DS:DX
; -----------------------------------------------------------------------------

HomeFile PROC      NEAR

; ------ nalezen¡ jm‚na souboru

         push      ds
         push      ds
         pop       es                       ; ES <- datov˜ segment
         mov       ds,ds:[SegmPSP]          ; DS <- segment PSP
         mov       ds,ds:[2ch]              ; segment prost©ed¡
         mov       es:[BlokPlay],ds         ; adresa prost©ed¡
         xor       si,si
HomeFil1:inc       si
         cmp       word ptr ds:[si-1],0
         jne       HomeFil1
         inc       si                       ; p©esko‡en¡ koncov‚ 0
         inc       si
         inc       si                       ; p©esko‡en¡ po‡tu ©etˆzc–

; ------ p©enesen¡ jm‚na souboru

         cld
         mov       di,offset FileName       ; buffer jm‚na souboru
         mov       dx,di                    ; DX <- jm‚no souboru
         xor       cx,cx                    ; CX <- 0 nen¡ p©¡pona
HomeFil2:lodsb                              ; na‡ten¡ znaku
         cmp       al,"."
         jne       HomeFil3
         mov       cx,di                    ; adresa p©¡pony
HomeFil3:cmp       di,offset FileName+120
         jae       HomeFil4
         stosb
         cmp       al,0
         jne       HomeFil2
         dec       di

; ------ p©id n¡ p©¡pony

HomeFil4:jcxz      HomeFil5                 ; nenalezena p©¡pona
         mov       di,cx                    ; DI <- nalezen  p©¡pona
HomeFil5:mov       al,"."
         stosb
         pop       ds
         mov       si,bx
         movsw
         movsw
         ret

HomeFile ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru obr zk– PCX (CY=chyba)
; -----------------------------------------------------------------------------

ReadPCX  PROC      NEAR

; ------ otev©en¡ souboru PCX

         mov       bx,offset FilePCX        ; jm‚no souboru PCX
         call      HomeFile                 ; sestaven¡ jm‚na souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jc        ReadPCX9                 ; chyba otev©en¡ souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ p©¡prava k na‡ten¡ souboru

         mov       ax,SEG ObrSegm           ; segment obr zk–
         mov       es,ax                    ; ES <- segment obr zk–
         mov       ax,100h                  ; AH <- 1 nen¡ dal¨¡ bajt
         cld
         xor       di,di                    ; ukl dac¡ adresa do bufferu

; ------ na‡ten¡ bufferu

         call      ReadBuff                 ; na‡ten¡ bufferu
         jc        ReadPCX8                 ; chyba
         add       si,128                   ; p©esko‡en¡ z hlav¡
         sub       cx,128                   ; ode‡ten¡ z hlav¡
         jb        ReadPCX8                 ; chyba

; ------ ovˆ©en¡ z hlav¡ PCX

         cmp       byte ptr ds:[Buffer],10
         stc
         jne       ReadPCX8

; ------ na‡ten¡ souboru

         mov       dx,40*200*4              ; po‡et bajt– k na‡ten¡
ReadPCX2:call      ReadByte                 ; na‡ten¡ dal¨¡ho bajtu
         jc        ReadPCX8                 ; chyba
         stosb                              ; ulo‘en¡ bajtu
         dec       dx                       ; ‡¡ta‡ bajt–
         jnz       ReadPCX2                 ; dal¨¡ bajt

; ------ uzav©en¡ souboru

ReadPCX8:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
ReadPCX9:ret

ReadPCX  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho bajtu ze vstupn¡ho bufferu (je CLD !)
; -----------------------------------------------------------------------------
; VSTUP: AL=star  hodnota bajtu
;        AH=‡¡ta‡ opakov n¡ bajtu (1=bude dal¨¡ bajt)
;        DS:SI=adresa bufferu
;        CX=po‡et zbyl˜ch bajt–
;        CLD=smˆr nahoru
; VSTUP: CY=chyba
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

; ------ dal¨¡ opakov n¡ bajtu AL

         dec       ah                       ; ‡¡ta‡ opakov n¡ bajtu
         jnz       ReadByt6                 ; je dal¨¡ opakov n¡ bajtu

; ------ na‡ten¡ dal¨¡ho bajtu z bufferu

ReadByt0:jcxz      ReadByt8                 ; je ji‘ konec bufferu
ReadByt1:lodsb                              ; na‡ten¡ dal¨¡ho bajtu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e bajt–

; ------ test, zda je opakov n¡ bajtu

         mov       ah,1                     ; bajt se nebude opakovat
         cmp       al,0c0h                  ; je platn˜ datov˜ bajt ?
         jb        ReadByt6                 ; je platn˜ datov˜ bajt

; ------ £schova po‡tu opakov n¡ bajtu

         and       al,3fh                   ; po‡et opakov n¡ bajtu
         mov       ah,al                    ; po‡et opakov n¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

         jcxz      ReadByt9                 ; je ji‘ konec bufferu
ReadByt2:lodsb                              ; na‡ten¡ bajtu k opakov n¡
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         or        ah,ah                    ; je nˆjak˜ bajt ?
         jz        ReadByt0                 ; nen¡ bajt
ReadByt6:clc                                ; p©¡znak operace OK
ReadByt7:ret

; ------ na‡ten¡ dal¨¡ch dat ze souboru do bufferu - ‡ st 1

ReadByt8:call      ReadBuff                 ; na‡ten¡ dal¨¡ ‡ sti souboru
         jc        ReadByt7                 ; chyba
         stc
         jcxz      ReadByt7                 ; chyba
         jmp       short ReadByt1

; ------ na‡ten¡ dal¨¡ch dat ze souboru do bufferu - ‡ st 2

ReadByt9:call      ReadBuff                 ; na‡ten¡ dal¨¡ ‡ sti souboru
         jc        ReadByt7
         stc
         jcxz      ReadByt7                 ; chyba
         jmp       short ReadByt2

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bufferu ze souboru BX -> SI=adresa, CX=bajt–, CY chyba
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      dx

         mov       dx,offset Buffer         ; vstupn¡ buffer souboru
         mov       si,dx                    ; ukazatel na za‡ tek bufferu
         mov       ah,3fh
         mov       cx,BuffSize              ; velikost bufferu
         int       21h                      ; na‡ten¡ bufferu
         xchg      ax,cx                    ; CX <- po‡et bajt–
         cld

         pop       dx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru sc‚n SCN
; -----------------------------------------------------------------------------
;þ
ReadSCN  PROC      NEAR

; ------ otev©en¡ souboru SCN

         mov       bx,offset FileSCN        ; jm‚no souboru SCN
         call      HomeFile                 ; sestaven¡ jm‚na souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jc        ReadSCN9                 ; chyba otev©en¡ souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ souboru definice sc‚n

         push      ds
         mov       ax,SEG ScenSegm          ; segment definice sc‚n
         mov       ds,ax                    ; DS <- segment definice sc‚n
         mov       ah,3fh
         xor       dx,dx
         mov       cx,-1                    ; max. velikost souboru
         int       21h                      ; na‡ten¡ souboru
         pop       ds
         jc        ReadSCN8                 ; chyba
         xchg      ax,cx                    ; CX <- po‡et na‡ten˜ch bajt–

; ------ inicializace adres sc‚n

         cld
         xor       si,si
         mov       di,offset AdrScen        ; adresy sc‚n
         mov       bx,offset TabHesel       ; tabulka hesel
ReadScn2:call      ReadScnL                 ; nalezen¡ prvn¡ho © dku
         jc        ReadScn7                 ; nen¡ dal¨¡ © dek

         mov       dl,5                     ; d‚lka hesla
ReadSc21:call      ReadScnC                 ; na‡ten¡ znaku
         jc        ReadScn7                 ; nen¡ dal¨¡ znak
         cmp       al," "
         ja        ReadSc22
         dec       si
         mov       al," "
ReadSc22:cmp       al,"a"
         jb        ReadSc23
         cmp       al,"z"
         ja        ReadSc23
         sub       al,32
ReadSc23:mov       ds:[bx],al
         inc       bx
         dec       dl
         jnz       ReadSc21

ReadSc24:mov       ds:[di],si               ; adresa sc‚ny
         inc       di
         inc       di

         mov       dl,12                    ; po‡et po‘adovan˜ch © dk–

ReadScn3:call      ReadScnL                 ; nalezen¡ za‡ tku © dku
         jc        ReadScn7                 ; nen¡ dal¨¡ © dek

         mov       dh,20                    ; po‡et po‘adovan˜ch pozic
ReadScn4:call      ReadScnC                 ; na‡ten¡ dal¨¡ho znaku
         jc        ReadScn7                 ; nen¡ dal¨¡ znak
         cmp       al," "
         jbe       ReadScn4
         dec       dh                       ; ‡¡ta‡ platn˜ch znak–
         jnz       ReadScn4                 ; dal¨¡ znak

         dec       dl                       ; ‡¡ta‡ © dk–
         jnz       ReadScn3                 ; dal¨¡ © dek

         inc       word ptr ds:[NumScen]    ; sc‚na je platn 
         jmp       short ReadScn2           ; dal¨¡ sc‚na

; ------ uzav©en¡ souboru

ReadScn7:cmp       byte ptr ds:[NumScen],3  ; minim lnˆ 1 DEMO + 1 sc‚na
         dec       word ptr ds:[NumScen]    ; bez DEMO sc‚ny
ReadSCN8:pushf
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         popf
ReadSCN9:ret

ReadSCN  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ za‡ tku platn‚ho © dku definice sc‚ny -> CY=nen¡
; -----------------------------------------------------------------------------

ReadScnL:call      ReadScnC                 ; na‡ten¡ znaku
         jc        ReadScL4                 ; nen¡ dal¨¡ znak
         cmp       al," "
         jbe       ReadScnL
         cmp       al,";"
         jne       ReadScL2

ReadScL1:call      ReadScnC                 ; na‡ten¡ znaku
         jc        ReadScL4                 ; nen¡ dal¨¡ znak
         cmp       al,10
         jne       ReadScL1                 ; nalezen¡ znaku LF
         jmp       short ReadScnL

ReadScL2:dec       si                       ; n vrat znaku
         inc       cx                       ; n vrat ‡¡ta‡e znak–
         clc                                ; p©¡znak platnosti znaku
ReadScL4:ret

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z definice sc‚n -> CY chyba
; -----------------------------------------------------------------------------

ReadScnC:stc
         jcxz      ReadScC2

         push      ds

         push      ax
         mov       ax,SEG ScenSegm          ; segment sc‚n
         mov       ds,ax
         pop       ax

         lodsb
         dec       cx
         pop       ds
         clc

ReadScC2:ret

; -----------------------------------------------------------------------------
;        celkov‚ ukon‡en¡ hry - absolutn¡ v¡tˆz
; -----------------------------------------------------------------------------
;þ
Absol    PROC      NEAR

         mov       dx,9*256+5
         mov       si,offset Bla1Txt
         mov       ah,14
         call      DispTxt
         mov       dx,10*256+5
         call      DispTxt
         mov       dx,11*256+5
         push      si
         mov       si,offset Bla1Txt
         call      DispTxt
         pop       si
         mov       ah,10
         mov       dx,12*256+5
         call      DispTxt
         mov       dx,13*256+5
         call      DispTxt
         mov       si,offset Bla1Txt
         mov       dx,14*256+5
         call      DispTxt

         call      FlushKey
         mov       ah,0
         int       16h
         jmp       Start2                   ; n vrat k demonstraci

Absol    ENDP

; -----------------------------------------------------------------------------
;        zad n¡ hesla
; -----------------------------------------------------------------------------
;þ
Heslo    PROC      NEAR

         push      ds
         pop       es

; ------ na‡ten¡ aktivn¡ho hesla

         mov       al,5
         mul       byte ptr ds:[AktScen]
         add       ax,offset TabHesel
         xchg      ax,si
         mov       cx,5
         mov       di,offset BuffHes
         cld
         rep       movsb

; ------ zobrazen¡ hesla

         mov       di,offset BuffHes        ; ukazatel v bufferu hesla

Heslo2:  mov       dx,24*256+14
         mov       ah,12
         mov       si,offset Hes2Txt
         call      DispTxt

         mov       si,offset BuffHes
         mov       cx,5
Heslo23: mov       ah,14
         cmp       si,di
         jne       Heslo232

         mov       ah,9
         mov       al,"Û"
         call      DispChr
         dec       dx

         mov       ah,14 XOR 9 + 80h

Heslo232:cld
         lodsb
         call      DispChr
         loop      Heslo23

; ------ ‡ek n¡ na zad n¡ kl vesy

Heslo24: call      TestTime                 ; inicializace ‡¡ta‡e ‡asu
         jc        Heslo25                  ; nen¡ krok
         call      IncFaze                  ; zv˜¨en¡ f ze
         call      OpenVrat                 ; otev©en¡ vrat

Heslo25: mov       ah,1
         int       16h
         jz        Heslo24
         mov       ah,0
         int       16h

         cmp       al,13
         je        Heslo5

; ------ p©eru¨en¡ zad n¡ ESC (nebo neplatn‚ heslo)

         or        ax,ax
         jz        Heslo27
         cmp       al,27
         jne       Heslo3

Heslo27:
         call      DispInf
         jmp       Start60                  ; p©eru¨en¡ bez dal¨¡ funkce

; ------ kurzor vpravo

Heslo3:  cmp       ax,4d00h
         je        Heslo42

; ------ kurzor vlevo

         cmp       al,8
         je        Heslo31
         cmp       al,7fh
         je        Heslo31
         cmp       ax,5300h
         je        Heslo31
         cmp       ax,4b00h
         jne       Heslo32
Heslo31: cmp       di,offset BuffHes
         jbe       Heslo43
         dec       di
         jmp       short Heslo43

; ------ vlo‘en¡ znaku

Heslo32: cmp       al,"a"
         jb        Heslo33
         cmp       al,"z"
         ja        Heslo33
         sub       al,32
Heslo33: cmp       al," "
         jb        Heslo24
;         je        Heslo34
;         cmp       al,"0"
;         jb        Heslo24
;         cmp       al,"9"
;         jbe       Heslo34
;         cmp       al,"A"
;         jb        Heslo24
;         cmp       al,"Z"
;         ja        Heslo24
Heslo34: mov       ds:[di],al

Heslo42: cmp       di,offset BuffHes+4
         jae       Heslo43
         inc       di
Heslo43: jmp       Heslo2

; ------ ukon‡en¡ zad n¡ hesla ENTER

Heslo5:  mov       si,offset TabHesel+5
         mov       dx,1                     ; ukazatel ‡¡sla sc‚ny
         cld
Heslo52: mov       di,offset BuffHes
         mov       cx,5
         push      si
         repe      cmpsb
         pop       si
         je        Heslo55
         add       si,5
         inc       dx
         cmp       dx,ds:[NumScen]
         jbe       Heslo52
         jmp       short Heslo27

Heslo55: mov       ds:[AktScen],dl
         jmp       Start4

Heslo    ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ sc‚ny
; -----------------------------------------------------------------------------

ClosScen PROC      NEAR

         mov       dh,0
         mov       al,ZED
ClosScn1:mov       cx,20
         mov       dl,0
ClosScn2:call      DispObr
         inc       dx
         loop      ClosScn2
         mov       cx,60
         call      Cekej
         inc       dh
         cmp       dh,12
         jne       ClosScn1
         ret

ClosScen ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ sc‚ny
; -----------------------------------------------------------------------------

OpenScen PROC      NEAR

         mov       si,offset Pole+12*20-20
         mov       dh,11
OpenScn1:mov       cx,20
         mov       dl,0
OpenScn2:cld
         lodsb
         call      DispObr
         inc       dx
         loop      OpenScn2
         sub       si,2*20
         mov       cx,60
         call      Cekej
         dec       dh
         jns       OpenScn1
         ret

OpenScen ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ sc‚ny
; -----------------------------------------------------------------------------

DispScen PROC      NEAR

         mov       si,offset Pole
         mov       dh,0
DispScn1:mov       cx,20
         mov       dl,0
DispScn2:cld
         lodsb
         cmp       al,LO1
         jne       DispScn3
         mov       al,LO3
DispScn3:call      DispObr
         inc       dx
         loop      DispScn2
         inc       dh
         cmp       dh,12
         jne       DispScn1
         ret

DispScen ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ informa‡n¡ho © dku
; -----------------------------------------------------------------------------

ClearInf PROC      NEAR

         mov       dx,24*256                ; pozice - lev˜ doln¡ roh
         mov       ax,15*256+" "            ; znak a barva k vymaz n¡
         mov       cx,40                    ;
ClearIn1:call      DispChr
         loop      ClearIn1
         ret

ClearInf ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ informa‡n¡ho © dku
; -----------------------------------------------------------------------------

DispInf  PROC      NEAR

         call      ClearInf                 ; vymaz n¡ informa‡n¡ho © dku

; ------ £vodn¡ text

         mov       dx,24*256
         mov       ah,10
         mov       si,offset SkorTxt
         call      DispTxt

         mov       dl,40-6-3
         call      DispTxt

         mov       dl,16
         mov       ah,12
         call      DispTxt

         mov       ch,14
         mov       al,ds:[AktScen]
         mov       ah,0
         mov       dl,40-2
         call      DispNum

         call      DispSkor                 ; zobrazen¡ sk¢re
         ret

DispInf  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ sk¢re
; -----------------------------------------------------------------------------

DispSkor PROC      NEAR

         push      ax
         push      cx
         push      dx

         cmp       byte ptr ds:[Demon],0
         jne       DispSko6

         mov       dx,24*256+6
         mov       ch,14
;         mov       cl,5
         mov       ax,ds:[Skore]
         or        ax,ax
         jz        DispSko4
;         jnz       DispSko3
;         mov       cl,6
DispSko3:call      DispNum
DispSko4:mov       al,"0"
         mov       ah,14
;         mov       dl,6+5
         call      DispChr

DispSko6:pop       dx
         pop       cx
         pop       ax
         ret

DispSkor ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ vrat
; -----------------------------------------------------------------------------

OpenVrat PROC      NEAR

         push      ax
         push      cx
         push      dx
         push      si

         cmp       word ptr ds:[CitVeci],0
         jne       OpenVr8

         mov       dx,ds:[PozVrat]
         mov       al,20                    ; po‡et pozic
         mul       dh                       ; p©epo‡et © dku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,si                    ; SI <- adresa v poli
         mov       al,ds:[si]
         cmp       al,VRA
         jb        OpenVr8
         cmp       al,VRA+5
         jae       OpenVr8

         inc       ax
         mov       ds:[si],al               ; nov  f ze vrat
         call      DispObr

OpenVr8: pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

OpenVrat ENDP

; -----------------------------------------------------------------------------
;        zv˜¨en¡ f ze objekt–
; -----------------------------------------------------------------------------

IncFaze  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si

; ------ obsluha objekt–

         mov       dh,0
         mov       si,offset Pole
         inc       byte ptr ds:[Faze]       ; ‡¡ta‡ f z¡
         cmp       byte ptr ds:[Faze],3
         jb        IncFaze1
         mov       byte ptr ds:[Faze],0
IncFaze1:mov       dl,0
IncFaze2:cld
         lodsb
         cmp       al,VECI
         jae       IncFaze3
         cmp       al,LO1
         jb        IncFaze5
         cmp       al,LOC
         ja        IncFaze5
         cmp       byte ptr ds:[MapVlak],0
         je        IncFaze5
         sub       al,LO1
         and       al,3
         mov       ah,ds:[Faze]
         shl       ah,1
         shl       ah,1
         add       al,ah
         add       al,LO1
         jmp       short IncFaze4
IncFaze3:inc       ax                       ; zv˜¨en¡ f ze
         cmp       byte ptr ds:[Faze],0
         jne       IncFaze4
         sub       al,3
IncFaze4:mov       ds:[si-1],al
         call      DispObr
IncFaze5:inc       dx
         cmp       dl,20
         jne       IncFaze2
         inc       dh
         cmp       dh,12
         jne       IncFaze1

; ------ n vrat registr–

         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

IncFaze  ENDP

; -----------------------------------------------------------------------------
;        ‡¡t n¡ ‡asu pro jeden krok (CY=nen¡ krok)
; -----------------------------------------------------------------------------
;þ
TestTime PROC      NEAR

         sti

         push      cx
         mov       cx,1
         call      Cekej
         pop       cx

         cmp       word ptr ds:[CitSound],0
         je        TestTim1

         dec       word ptr ds:[CitSound]
         jnz       TestTim0
TestT05: call      SoundOff
         jmp       short TestTim1

TestTim0:
         push      ax
         push      si
         mov       si,ds:[AdrSound]
         cld
         lodsw
         mov       ds:[AdrSound],si
         call      SetSound

         pop       si
         pop       ax

TestTim1:

         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]
         pop       ds
         sub       ax,ds:[LastTime]

IFDEF    DEBUG
         cmp       ax,3                     ; krok
ELSE
         cmp       ax,2                     ; krok
ENDIF

         jb        TestTim3                 ; nen¡ krok
         add       ds:[LastTime],ax         ; zv˜¨en¡ ‡¡ta‡e ‡asu
         clc                                ; p©¡znak kroku
TestTim3:pop       ax
         ret

TestTime ENDP

; -----------------------------------------------------------------------------
;        posun vlaku ve smˆru DX (DH=0,1,-1, DL=0,1,-1)
; -----------------------------------------------------------------------------
;þ
PosVlak  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ p©¡prava registr–

         mov       si,offset MapVlak
         add       dl,ds:[si+1]             ; nov  sou©adnice lokomotivy
         add       dh,ds:[si+2]

; ------ posun sou©adnic objektu

PosVlak2:mov       cx,ds:[si+1]             ; £schova star˜ch sou©adnic
         mov       ds:[si+1],dx             ; nov  sou©adnice objektu

; ------ stanoven¡ nov‚ f ze objektu

         mov       al,ds:[si]               ; b ze objektu
         cmp       cl,-1                    ; je pozice zn m  ?
         jne       PosVlk22                 ; pozice je zn m 
         add       al,bh                    ; posun f ze
         jmp       short PosVlak4
PosVlk22:mov       ah,dl                    ; nov  pozice
         mov       bh,0                     ; vlevo
         sub       ah,cl                    ; posun pozice
         je        PosVlak3                 ; pozice se nezmˆnila
         js        PosVlak4                 ; posun vlevo
         mov       bh,2                     ; vpravo
         add       al,2
         jmp       short PosVlak4           ; posun vpravo
PosVlak3:inc       ax                       ; posun nahoru
         mov       bh,1                     ; nahoru
         mov       ah,dh                    ; nov˜ © dek
         sub       ah,ch                    ; posun © dku
         js        PosVlak4                 ; je posun nahoru
         add       al,2                     ; jinak posun dol–
         mov       bh,3                     ; dol–

; ------ zobrazen¡ objektu na nov‚ pozici

PosVlak4:call      DispObr                  ; zobrazen¡ obr zku

; ------ ulo‘en¡ objektu do mapy

         push      ax
         mov       al,20                    ; po‡et pozic
         mul       dh                       ; p©epo‡et © dku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,di                    ; DI <- adresa v poli
         pop       ax
         xchg      al,ds:[di]               ; ulo‘en¡ objektu do mapy

; ------ p©i zru¨en¡ vˆci vytvo©en¡ nov‚ho vagonu

         sub       al,VECI                  ; byla to vˆc ?
         jb        PosVlak6                 ; nebyla to vˆc

         dec       word ptr ds:[CitVeci]    ; ‡¡t n¡ vˆc¡
         cmp       byte ptr ds:[Demon],0
         jne       PosVla42
         cmp       word ptr ds:[Skore],-1
         je        PosVla41
         inc       word ptr ds:[Skore]
PosVla41:call      DispSkor                 ; zobrazen¡ sk¢re
PosVla42:mov       ah,0
         mov       bl,3
         div       bl                       ; ‡¡slo vˆci
         shl       al,1
         shl       al,1                     ; vagon * 4
         add       al,VAGONY                ; ‡¡slo vagonu
         push      si
PosVlak5:add       si,3
         cmp       byte ptr ds:[si],0
         jne       PosVlak5
         mov       ds:[si],al
         mov       word ptr ds:[si+1],-1
         mov       byte ptr ds:[si+3],0
         pop       si

; ------ p©¡prava pro dal¨¡ objekt

PosVlak6:add       si,3                     ; adresa dal¨¡ho objektu
         mov       dx,cx                    ; star  pozice p©ede¨l‚ho objektu
         mov       al,0
         cmp       ds:[si],al               ; je ji‘ konec vlaku ?
         je        PosVlak7
         jmp       PosVlak2                 ; nen¡ konec - dal¨¡ vagon

; ------ vymaz n¡ posledn¡ho vagonu

PosVlak7:cmp       dl,-1
         je        PosVlak8
         call      DispObr                  ; vymaz n¡ posledn¡ho vagonu
         mov       al,20                    ; po‡et pozic
         mul       dh                       ; p©epo‡et © dku na offset
         add       al,dl
         adc       ah,0
         add       ax,offset Pole
         xchg      ax,di                    ; DI <- adresa v poli
         mov       byte ptr ds:[di],0

; ------ n vrat registr–

PosVlak8:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

PosVlak  ENDP

; -----------------------------------------------------------------------------
;        inicializace sc‚ny AL pro hru
; -----------------------------------------------------------------------------

InitScen PROC      NEAR

; ------ nov  inicializace hodin (kdyby nˆkdo p©epnul TURBO)

         call      CekInit                  ; inicializace hodin

; ------ £schova registr–

         push      ax
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ p©enesen¡ definice sc‚ny

         cld
         push      ds
         pop       es                       ; ES <- datov˜ segment

         push      ds
         mov       ah,0
         shl       ax,1                     ; AX = offset adresy
         xchg      ax,si
         mov       si,ds:[si+AdrScen]       ; adresa sc‚ny
         mov       ax,SEG ScenSegm          ; AX <- segment sc‚n
         mov       ds,ax                    ; DS <- segment sc‚n
         mov       di,offset Pole           ; za‡ tek pole
         mov       cx,12*20                 ; velikost pole
InitScn1:lodsb
         cmp       al," "
         jbe       InitScn1
         cmp       al,";"
         jne       InitScn3
InitScn2:lodsb
         cmp       al,10
         jne       InitScn2
         jmp       short InitScn1

InitScn3:mov       ah,LO1
         cmp       al,"$"
         je        InitSc38
         mov       ah,VRA
         cmp       al,"@"
         je        InitSc38
         mov       ah,ZED
         cmp       al,"#"
         je        InitSc38

         cmp       al,"a"
         jb        InitSc32
         cmp       al,"z"
         ja        InitSc32
         sub       al,32
InitSc32:sub       al,"A"
         jb        InitSc37
         cmp       al,POCVECI
         jae       InitSc37
         mov       ah,3
         mul       ah
         add       al,VECI
         jmp       short InitSc39

InitSc37:mov       ah,0                     ; jinak neplatn˜

InitSc38:mov       al,ah
InitSc39:stosb
         loop      InitScn1
         pop       ds

; ------ inicializace sc‚ny

         mov       word ptr ds:[CitVeci],0  ; ‡¡ta‡ vˆc¡ - nen¡ ‘ dn  vˆc
         mov       dh,0                     ; ukazatel ‡¡sla © dku
         mov       si,offset Pole           ; definice hrac¡ho pole
InitScn4:mov       dl,0                     ; ukazatel ‡¡sla pozice
InitScn5:lodsb                              ; na‡ten¡ bajtu definice
         cmp       al,VRA                   ; jsou to zav©en  vrata ?
         jne       InitSc52                 ; nejsou to vrata
         mov       ds:[PozVrat],dx          ; pozice vrat
InitSc52:cmp       al,VECI                  ; je to vˆc ?
         jb        InitScn6                 ; nen¡ to vˆc
         inc       word ptr ds:[CitVeci]    ; ‡¡ta‡ vˆc¡
InitScn6:cmp       al,LO1                   ; je to lokomotiva ?
         jne       InitScn7
         mov       ds:[MapVlak],al
         mov       byte ptr ds:[si-1],LO3
         mov       word ptr ds:[MapVlak+1],dx ; sou©adnice lokomotivy
InitScn7:inc       dx                       ; zv˜¨en¡ pozice na © dku
         cmp       dl,20                    ; je ji‘ konec © dku ?
         jne       InitScn5                 ; nen¡ je¨tˆ konec © dku
         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         cmp       dh,12                    ; je ji‘ posledn¡ © dek ?
         jne       InitScn4                 ; nen¡ je¨tˆ posledn¡ © dek

         mov       byte ptr ds:[MapVlak+3],0  ; ozna‡en¡ konce vlaku
         mov       byte ptr ds:[Faze],0     ; ukazatel f ze
         mov       word ptr ds:[Smer],0     ; smˆr pohybu (= stoj¡)

; ------ n vrat registr–

         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

InitScen ENDP

; -----------------------------------------------------------------------------
;        inicializace adres obr zk–
; -----------------------------------------------------------------------------
;þ
InitObr  PROC      NEAR

DELLO    EQU       16*40*4                  ; d‚lka jednoho © dku obr zk–

; ------ ukl dac¡ adresa do bufferu

         cld
         mov       di,offset AdrObr         ; buffer adres obr zk–
         push      ds
         pop       es

; ------ adresa tmy

         mov       ax,9*DELLO + 38          ; tma je za n pisem
         stosw

; ------ lokomotiva - f ze 1 a f ze 2

         mov       ax,10*DELLO
         mov       cx,2*4                   ; 2 f ze po 4 obr zc¡ch
         call      InitObrA                 ; ulo‘en¡ adres

; ------ lokomotiva - f ze 3

         mov       ax,11*DELLO
         mov       cl,4
         call      InitObrA                 ; ulo‘en¡ adres

; ------ sr ‘ka - 10 f z¡

         mov       ax,10*DELLO + 8*2
         mov       cl,10
         call      InitObrA                 ; ulo‘en¡ adres

; ------ zeƒ

         inc       ax
         stosw

; ------ vrata - 6 f z¡

         mov       ax,11*DELLO + 14*2
         mov       cl,6
         call      InitObrA                 ; ulo‘en¡ adres

; ------ vagony

         mov       ax,3*16*4*40
         mov       cx,POCVECI               ; po‡et vˆc¡
InitObr4:push      ax
         stosw
         add       ax,16*4*40
         stosw
         add       ax,16*4*40
         stosw
         add       ax,16*4*40
         stosw
         pop       ax
         inc       ax
         inc       ax
         loop      InitObr4

; ------ vˆci

         xor       ax,ax
         mov       cx,POCVECI               ; po‡et vˆc¡
InitObr6:push      ax
         stosw
         add       ax,16*4*40
         stosw
         add       ax,16*4*40
         stosw
         pop       ax
         inc       ax
         inc       ax
         loop      InitObr6
         ret

InitObr  ENDP

; ------ ulo‘en¡ CX adres vedle sebe

InitObrA:stosw
         inc       ax
         inc       ax
         loop      InitObrA
         ret

; -----------------------------------------------------------------------------
;        zobrazen¡ obr zku AL na pozici DL, © dek DH
; -----------------------------------------------------------------------------

DispObr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ adresa obr zku -> DS:SI

         mov       ah,0
         shl       ax,1                     ; obr zek * 2
         xchg      ax,bx                    ; BX <- offset v tabulce
         mov       si,ds:[bx+AdrObr]        ; adresa obr zku
         mov       ax,SEG ObrSegm
         mov       ds,ax                    ; DS <- segment obr zk–

; ------ adresa k ulo‘en¡ obr zku

         mov       cx,dx                    ; £schova DX
         mov       dl,dh
         mov       dh,0
         mov       ax,16*40                 ; offset © dku
         mul       dx                       ; p©epo‡et © dku na offset
         mov       ch,0
         shl       cx,1                     ; p©epo‡et pozice na offset
         add       ax,cx                    ; adresa ve videopamˆti
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       ax,0a000h
         mov       es,ax                    ; ES <- adresa ve videopamˆti

; ------ p©¡prava k zobrazen¡ obr zku

         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru z pisov˜ch rovin
         mov       ah,1                     ; ukazatel z pisov‚ roviny
         inc       dx
         cld

; ------ zobrazen¡ jedn‚ roviny obr zku

DispObr8:mov       al,ah
         out       dx,al                    ; volba z pisov‚ roviny
         mov       cx,16                    ; po‡et linek
         push      si
         push      di
DispObr9:movsw                              ; p©enos jedn‚ linky
         add       di,40-2
         add       si,4*40-2
         loop      DispObr9
         pop       di
         pop       si

; ------ p©¡prava pro dal¨¡ rovinu

         add       si,40
         shl       ah,1
         cmp       ah,10h
         jne       DispObr8                 ; dal¨¡ rovina

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispObr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ titulku
; -----------------------------------------------------------------------------

DispTit  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava k zobrazen¡ titulku

         mov       bl,ds:[CitTit]           ; ‡¡ta‡ titulku
         mov       ax,SEG ObrSegm
         mov       ds,ax
         mov       si,8*16*4*40
         mov       ax,0a000h
         mov       es,ax                    ; ES <- adresa ve videopamˆti
         mov       di,9*16*40 + 2
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru z pisov˜ch rovin
         mov       ah,1                     ; ukazatel z pisov‚ roviny
         inc       dx
         cld

; ------ zobrazen¡ jedn‚ roviny titulku

DispTit2:mov       al,ah
         out       dx,al                    ; volba z pisov‚ roviny
         mov       cx,16                    ; po‡et linek

         push      di
         push      si

DispTit3:push      cx
         push      si
         push      di

         mov       cl,bl                    ; ‡¡ta‡ titulku
         rep       movsb                    ; p©enos jedn‚ linky

         pop       di
         pop       si
         pop       cx
         add       si,40*4
         add       di,40

         loop      DispTit3

         pop       si
         pop       di

; ------ p©¡prava pro dal¨¡ rovinu

         add       si,40
         shl       ah,1
         cmp       ah,10h
         jne       DispTit2                 ; dal¨¡ rovina

; ------ n vrat registr–

         pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispTit  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX (pozice DL, © dek DH, barva CH)
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      si
         push      di

         mov       bx,dx                    ; £schova pozice
         xor       di,di                    ; ‡¡ta‡ znak–

; ------ dek¢dov n¡ ‡¡sla do z sobn¡ku

         mov       si,10
DispNum1:xor       dx,dx
         div       si
         push      dx
         inc       di
         mov       dx,bx
         or        ax,ax
         jnz       DispNum1

; ------ zobrazen¡ ‡¡sla

DispNum3:pop       ax
         add       al,"0"
         mov       ah,ch
         call      DispChr
         dec       di
         jnz       DispNum3

; ------ n vrat registr–

         pop       di
         pop       si
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ hl ¨en¡ p©i sr ‘ce
; -----------------------------------------------------------------------------
;þ
DispKec  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

;; ------ n hodn‚ ‡¡slo
;
;         sti
;DispKec1:push      ds
;         xor       dx,dx
;         mov       ds,dx
;         mov       dx,ds:[46ch]             ; ‡asova‡
;         pop       ds
;         xor       dx,ds:[CitKec]
;         rol       dx,1
;         mov       ds:[CitKec],dx
;         and       dx,3fh                   ; asi tak omezen¡
;         inc       dx
;
;; ------ nalezen¡ textu -> DS:SI, d‚lka CX
;
;         cld
;         mov       di,offset TabKec         ; tabulka text–
;DispKec2:mov       si,di                    ; SI <- adresa dal¨¡ho textu
;         xor       cx,cx                    ; CX <- 0 ‡¡ta‡ d‚lky textu
;         cmp       byte ptr ds:[si],0       ; je dal¨¡ text ?
;         je        DispKec1                 ; nen¡ dal¨¡ text
;DispKec3:mov       al,ds:[di]
;         inc       di
;         inc       cx
;         cmp       al,0
;         jne       DispKec3
;         dec       dx                       ; ‡¡ta‡ text–
;         jnz       DispKec2                 ; dal¨¡ text

; ------ zobrazen¡ textu (CX=d‚lka textu + 1)

         mov       cx,offset(TabKec0-TabKec)
         mov       si,offset TabKec

         mov       dx,1*256 + 40 - 1       ; © dek k zobrazen¡ textu
         sub       dl,cl                    ; zbytek na okraje
         shr       dl,1                     ; polovi‡n¡ pozice
         mov       ax,10*256 + " "
         call      DispChr                  ; £vodn¡ mezera
         call      DispTxt                  ; zobrazen¡ textu hl ¨en¡
         mov       al," "
         call      DispChr                  ; z vˆre‡n  mezera

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispKec  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu SI (barva AH, pozice DL, © dek DH)
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

DispTxt1:cld
         lodsb
         cmp       al,0
         je        DispTxt2
         call      DispChr
         jmp       short DispTxt1

DispTxt2:ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AX (pozice DL, © dek DH)
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

; ------ nastaven¡ kurzoru

         push      ax
         mov       bh,0
         mov       ah,2
         int       10h                      ; nastaven¡ kurzoru
         pop       ax

; ------ zobrazen¡ znaku

         mov       bl,ah
         mov       bh,0
         mov       ah,9
         mov       cx,1
         int       10h                      ; zobrazen¡ znaku

; ------ n vrat registr–

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       dx
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ zvukov‚ho gener toru na AX
; -----------------------------------------------------------------------------

SetSound PROC      NEAR

         push      ax
         cli
         mov       al,0b6h
         out       [43h],al
         pop       ax
         push      ax
         out       [42h],al                 ; LOW
         xchg      ah,al
         out       [42h],al                 ; HIGH
         in        al,[61h]
         or        al,3
         out       [61h],al
         sti
         pop       ax
         ret

SetSound ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ zvukov‚ho gener toru
; -----------------------------------------------------------------------------

SoundOff PROC      NEAR

         push      ax
         in        al,[61h]
         and       al,not 3
         out       [61h],al
         pop       ax
         ret

SoundOff ENDP

; -----------------------------------------------------------------------------
;        cejchov n¡ hodin
; -----------------------------------------------------------------------------
; VSTUP: DS=datov˜ segment
; -----------------------------------------------------------------------------

CekInit  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      dx
         push      di

         push      ds

; ------ p©¡prava registr–

         sti
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         xor       dx,dx                    ; DX <- 0
         mov       di,46ch                  ; adresa ‡asova‡e BIOS

; ------ ‡ek n¡ na za‡ tek impulsu hodin

         mov       bx,ds:[di]               ; aktu ln¡ stav hodin
CekInit1:cmp       bx,ds:[di]               ; zmˆnily se hodiny ?
         je        CekInit1                 ; ‡ek n¡ na za‡ tek hodin

; ------ mˆ©en¡ ‡asu

         mov       bx,ds:[di]               ; nov˜ aktu ln¡ stav hodin
         EVEN                               ; zarovn n¡ na sudou adresu
CekInit2:add       ax,1                     ; ‡¡ta‡ ni‘¨¡ho slova ‡asu
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova
         cmp       bx,ds:[di]               ; byla zmˆna ?
         je        CekInit2                 ; ‡ek n¡ na zmˆnu hodin

; ------ v˜po‡et konstanty

         mov       bx,55                    ; dˆlitel
         cmp       dx,bx                    ; p©ete‡en¡ ‡¡sla ?
         jb        CekInit3                 ; nen¡ p©ete‡en¡ ‡¡sla
         mov       dx,54                    ; omezen¡ ‡¡sla
CekInit3:div       bx                       ; v˜po‡et konstanty

; ------ ulo‘en¡ konstanty pro 1 ms

         or        ax,ax                    ; je = 0 ?
         jnz       CekInit4                 ; nen¡ = 0
         inc       ax                       ; korekce na 1
CekInit4:pop       ds
         mov       ds:[Cit1ms],ax           ; konstanta hodin pro 1 ms

; ------ n vrat registr–

         pop       di
         pop       dx
         pop       bx
         pop       ax
         ret

CekInit  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na uplynut¡ zadan‚ho ‡asu
; -----------------------------------------------------------------------------
; VSTUP: CX=po‘adovan  doba v milisekund ch
;        DS=datov˜ segment
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ ‡ek n¡ po zadanou dobu

         jcxz      Cekej9                   ; nen¡ ‘ dn‚ ‡ek n¡
         mov       di,offset Cit1ms         ; konstanta hodin
Cekej1:  xor       ax,ax                    ; AX <- 0 ni‘¨¡ slovo ‡¡ta‡e hodin
         xor       dx,dx                    ; DX <- 0 vy¨¨¡ slovo ‡¡ta‡e hodin

; ------ ‡¡t n¡ doby 1 ms

         EVEN                               ; zarovn n¡ na sudou adresu
Cekej2:  add       ax,1                     ; ‡¡ta‡ ni‘¨¡ho slova ‡asu
         adc       dx,0                     ; p©enos do vy¨¨¡ho slova
         cmp       ax,ds:[di]               ; dosa‘eno doby 1 ms ?
         jne       Cekej2                   ; ‡¡t n¡ doby 1 ms

         loop      Cekej1                   ; ‡ek n¡ na dal¨¡ 1 ms

; ------ n vrat registr–

Cekej9:  pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

FlushKey PROC      NEAR

         push      ax
FlushKe2:mov       ah,1
         int       16h
         jz        FlushKe3
         mov       ah,0
         int       16h
         jmp       short FlushKe2
FlushKe3:pop       ax
         ret

FlushKey ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

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

Code     ENDS

; *****************************************************************************
;
;                               Data
;
; *****************************************************************************

Data     SEGMENT
;þ
CardTxt  db        'Lituji, ale program vyzaduje grafikou kartu EGA nebo VGA !',13,10,'$'
ErrTxt   db        'POZOR - hru spustite zadanim prikazu PIVO v adresari s nainstalovanou hrou !',13,10,'$'

;PCXTxt   db        'CHYBA - nenalezen (nebo poskozen) soubor _PIVO.PCX !',13,10,'$'
;ScnTxt   db        'CHYBA - nenalezen (nebo poskozen) soubor _PIVO.SCN !',13,10,'$'

UvTxt    db        'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»',13,10
         db        'º                                                       º',13,10
         db        'º            Toto miniosvezeni Vam poskytnul            º',13,10
         db        'º                                                       º',13,10
         db        'º                          ÄÄÄ                          º',13,10
         db        'º                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    º',13,10
         db        'º              ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ              º',13,10
         db        'º                                                       º',13,10
         db        'º         CESKY SVAZ MALYCH NEZAVISLYCH PIVOVARU        º',13,10
         db        'º                                                       º',13,10
         db        'º              ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ              º',13,10
         db        'º                    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ                    º',13,10
         db        'º                          ÄÄÄ                          º',13,10
         db        'º                                                       º',13,10
         db        'º     Algoritmus a programovy kod: Miroslav Nemecek     º',13,10
         db        'º             Produkce: Burson-Marsteller CS            º',13,10
         db        'º                          1995                         º',13,10
         db        'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼',13,10
         db        '$'

BuffHes  db        '     '                  ; buffer hesla

                                            ; posun p©i demonstraci
DemoPos  db        19 dup(1,0)
         db        8 dup(0,-1)
         db        3 dup( 19 dup(-1,0), 0,1, 19 dup(1,0), 0,1)
         db        19 dup(-1,0)
         db        0,1, 0,1, 0,1
         db        9 dup(1,0), 0,1
         db        0,0                      ; ukon‡en¡

SkorTxt  db        'SKORE',0
ScenTxt  db        ' SCENA ',0
HeslTxt  db        'F4 HESLO',0
Hes2Txt  db        ' heslo ',0

Bla1Txt  db        '                              ',0
Bla2Txt  db        '  B L A H O P R E J E M E  !  ',0
         db        '   Stal jste se absolutnim    ',0
         db        '      vitezem teto hry !      ',0

; ------ hl ¨en¡ p©i sr ‘ce

TabKec   label     byte
         db        'Kdo jinemu jamu kopa...',0
;         db        'A zase vedle....',0
;         db        'Tak uz to konecne vzdejte!',0
;         db        'Uz moc nechybelo!',0
;         db        'A uz zase?',0
;         db        'To snad delate schvalne?',0
;         db        'Co takhle se trochu soustredit?',0
;         db        'Dejte si radeji pauzu.',0
;         db        'Nezoufejte, to se stane.',0
;         db        'Netlucte pocitac, nemuze za to!',0
;         db        'Nevolal nekdo o pomoc?',0
;         db        'Priznejte si, ze na to jiz nemate!',0
;         db        'I vyvalily se vlny zdola...',0
;         db        'Zivot je zivot...',0
;         db        'To vite, je to jako v zivote.',0
;         db        'Nebrecte, mohlo to byt i horsi!',0
;         db        'HA, HA, HA. DOSTAL JSEM TE!',0
;         db        'A mas co sis zaslouzil!',0
;         db        'Na to jsem se jiz dlouho tesil!',0
;         db        'Nema tady nekdo naplast?',0
;         db        'A l a r m  !   H O R I  !',0
;         db        'Takhle to asi nemelo byt, ze?',0
;         db        'Tak kudy to asi bude?',0
;         db        'Tudy tedy cesta nevede.',0
;         db        'Chtelo to jen o kousek vedle.',0
;         db        'Neni to k zblazneni?',0
;         db        'Me nenadavejte, ja za to nemohu.',0
;         db        'Snad priste.',0
;         db        'Co takhle to zkusit trochu jinak?',0
;         db        'Neni skoda vse takhle nicit?',0
;         db        'Zkuste si nechat zmerit vase IQ!',0
;         db        'Pozor na krevni tlak!',0
;         db        'A nedate si pokoj a nedate!',0
;         db        'Necitite kour?',0
;         db        'Zkuste pouzit tlacitko RESET!',0
;         db        0
TabKec0  label     byte

CitKec   dw        2356h                    ; ‡¡ta‡ n hody pro hl ¨en¡

; ------ ‡asova‡

         EVEN                               ; za‡¡n  na sud‚ adrese jako 0:46ch
Cit1ms   dw        0                        ; konstanta pro dobu 1 ms

AdrSound dw        0                        ; adresa zvuku
CitSound dw        0                        ; ‡¡ta‡ d‚lky zvuku (0=nen¡)

CitVyb   dw        0                        ; ‡¡ta‡ v˜buchu

TabSLok  dw        166,254,365              ; zvuk lokomotivy
TabSLok0 label     byte

TabSVec  dw        400,600,800,1000,1200,1400,1600,1800,2000,1800,1600,1400,1200,1000,800,600,400,200 ; zvuk vˆci
TabSVec0 label     byte

FileName db        128 dup(0)               ; buffer jm‚na souboru
FilePCX  db        'PCX',0                  ; jm‚no souboru obr zk– PCX
FileSCN  db        'SCN',0                  ; jm‚no souboru definice sc‚n SCN

FilePlay db        '_PLAYSCR.COM',0         ; jm‚no programu GDEMO ke spu¨tˆn¡

BlokPlay dw        0                        ; adresa segmentu prost©ed¡
         dd        BlokPlCm                 ; adresa p©¡kazov‚ho © dku
         dw        5ch                      ; adresa FCB1
         dw        SEG Code - 1             ; adresa PSP
         dw        6ch                      ; adresa FCB2
         dw        SEG Code - 1             ; adresa PSP

BlokPlCm db        0                        ; p©¡kazov˜ © dek (pr zdn˜)
         db        13

SegmPSP  dw        0                        ; segment PSP

Smer     dw        0                        ; smˆr pohybu

Demon    db        0                        ; 1=p©¡znak demonstrace

CitTit   db        0                        ; ‡¡ta‡ ¨¡©ky titulku
CitVeci  dw        0                        ; ‡¡ta‡ vˆc¡
PozVrat  dw        0                        ; pozice vrat
Skore    dw        0                        ; ‡¡ta‡ sk¢re

LastTime dw        0                        ; uschovan˜ posledn¡ ‡as

Faze     db        0                        ; ‡¡ta‡ f ze

NumScen  dw        0                        ; po‡et definovan˜ch sc‚n (s DEMO)
AktScen  db        1                        ; aktivn¡ sc‚na

TabHesel db        5*256 dup(?)             ; tabulka hesel

MapVlak  db        3 * 12*20 dup(?)         ; mapa cel‚ho vlaku
                                            ;  0: (1) b ze objektu (0=konec)
                                            ;  1: (1) sou©adnice X
                                            ;  2: (1) sou©adnice Y

Pole     db        12*20 dup(?)             ; hrac¡ pole

Buffer   db        BuffSize dup(?)          ; vstupn¡ buffer souboru

AdrObr   dw        256 dup(?)               ; adresy obr zk–

AdrScen  dw        256 dup(?)               ; adresy sc‚n

Data     ENDS

; *****************************************************************************
;
;                               Buffer sc‚n
;
; *****************************************************************************

ScenSegm SEGMENT   PARA
         db        0ffffh dup(?)            ; buffer definice sc‚n
ScenSegm ENDS

; *****************************************************************************
;
;                          Buffer obr zk–
;
; *****************************************************************************

ObrSegm  SEGMENT   PARA
         db        (320/8)*200*4 dup(?)     ; buffer obr zk–
ObrSegm  ENDS

; *****************************************************************************
;
;                              Z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   'STACK' stack
         dw        200h dup(?)
Zasob    ENDS
         END       Start

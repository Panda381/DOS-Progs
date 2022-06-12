
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               EPS24CS
;            program pro tisk ‡e¨tiny na tisk rny EPSON 24 jehel
;
; -----------------------------------------------------------------------------
; Ovˆ©eno pro tisk rny:
;   FUJITSU DL900 - mus¡ b˜t nastaven m¢d emulace LQ2500/LQ2550
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; -----------------------------------------------------------------------------
;        p©ep¡na‡e funkce programu
; -----------------------------------------------------------------------------

TimeOut  EQU       4*18                     ; max. povolen  prodleva v˜stupu

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


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init                     ; start a inicializace

; *****************************************************************************
;
;                         data rezidentn¡ ‡ sti
;
; *****************************************************************************

; ------ identifikace programu v pamˆti

Ident    db        'EPS24CS V1.0'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn¡ ‡ sti

; ------ p–vodn¡ adresy obsluh p©eru¨en¡

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old17    dd        0                        ; p–vodn¡ adresa INT 17h
Old28    dd        0                        ; p–vodn¡ adresa INT 28h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; ‡¡slo portu LPT
Param0   dw        0                        ; parametry - stav zn mosti
                                            ; (p©i TIME-OUT se vynuluj¡)
                                            ;   bit 9: 1=tabulka DownLoad plat¡
                                            ;   bit 10: 1=tisk rna inicializov.

Param    dw        bit15+bit10              ; parametry
                                            ;   bit 10: 1=je stav LQ
                                            ;   bit 15: 1=funkce je zapnuta

; ------ ‡¡ta‡ ‡asu

CitOut   dw        0ffffh                   ; ‡¡ta‡ ‡asu od posledn¡ho v˜stupu

; ------ obsluha ESC sekvenc¡

EscAdr   dw        0                        ; adresa obsluhy ESC (0=nen¡ nic)
EscCit   dw        0                        ; ‡¡ta‡ pro ignorov n¡ dat
EscStack db        0,0                      ; £schova 2 bajt– dat

; ------ v˜stupn¡ buffer

OutMax   EQU       100h                     ; velikost v˜stupn¡ho bufferu
OutNum   dw        0                        ; po‡et znak– ve v˜stupn¡m bufferu
OutBuff  db        OutMax dup(0)            ; v˜stupn¡ buffer

; ------ definice znak– DownLoad (po‘aduje se mo‘nost p©edefinovat 10 znak–)

CarM     EQU       58                       ; mal  ‡ rka
CarV     EQU       59                       ; velk  ‡ rka
CarR     EQU       60                       ; ‡ rka vpravo
CarI     EQU       61                       ; ‡ rka nad mal˜m i
HacM     EQU       62                       ; mal˜ h ‡ek
HacV     EQU       63                       ; velk˜ h ‡ek
KroM     EQU       64                       ; mal˜ krou‘ek
KroV     EQU       65                       ; velk˜ krou‘ek
StrV     EQU       66                       ; velk  st©¡¨ka
Para     EQU       67                       ; paragraf

; *****************************************************************************
;
;                  obsluha komunikace s tisk rnou
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ zv˜¨en¡ ‡¡ta‡e v˜stupu

         pushf
         cmp       word ptr cs:[CitOut],0ffffh ; p©ete‡en¡ ?
         je        Int081                   ; p©ete‡en¡ ‡¡ta‡e
         inc       word ptr cs:[CitOut]     ; zv˜¨en¡ ‡¡ta‡e doby
         cmp       word ptr cs:[CitOut],TimeOut ; je TIME-OUT v˜stupu ?
         jne       Int081                   ; nen¡ TIME-OUT v˜stupu

; ------ obsluha TIME-OUT v˜stupu

         mov       word ptr cs:[Param0],0   ; p©¡znak, ‘e stav nen¡ zn m˜

Int081:  popf

; ------ pokra‡ov n¡ v p–vodn¡ obsluze

         jmp       dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h

Int08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      OutByte                  ; mˆkk  obsluha v˜stupu na tisk rnu
         jmp       dword ptr cs:[Old28]     ; p–vodn¡ obsluha INT 28h

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 17h
; -----------------------------------------------------------------------------


Int17    PROC      FAR

; ------ kontrola, zda je obsluhovan  tisk rna

         cmp       dx,cs:[PortLPT]          ; je to obsluhovan  tisk rna ?
         jne       Int179                   ; nen¡ to obsluhovan  tisk rna

; ------ obsluha funkce 0 - vysl n¡ bajtu na tisk rnu

         or        ah,ah                    ; vysl n¡ znaku na tisk rnu ?
         jnz       Int175                   ; nen¡ vysl n¡ znaku na tisk rnu
         call      Vystup                   ; vypr zdnˆn¡ v˜stupn¡ho bufferu
         jc        Int177                   ; chyba v˜stupu (AH=stavov˜ bajt)
         test      word ptr cs:[Param],bit15 ; je funkce zapnuta ?
         jz        Int179                   ; funkce je vypnuta
         call      Konvert                  ; dek¢dov n¡ bajtu AL
         jc        Int177                   ; chyba v˜stupu (AH=stavov˜ bajt)
         mov       ah,2                     ; funkce - dotaz na stav tisk rny
         jmp       short Int176             ; dotaz na stav tisk rny

; ------ obsluha funkce 2 - dotaz na stav tisk rny

Int175:  cmp       ah,2                     ; je dotaz na stav tisk rny ?
         jne       Int178                   ; nen¡ dotaz na stav tisk rny
         call      TestInst                 ; test instalace programu
Int176:  call      OutByte                  ; mˆkk  obsluha v˜stupu na tisk rnu
         call      Int17I                   ; poskytnut¡ stavu tisk rny
         cmp       word ptr cs:[OutNum],0   ; v bufferu nˆjak˜ znak ?
         je        Int177                   ; v bufferu nen¡ p©ipraven znak
         and       ah,not 80h               ; p©¡znak zanepr zdnˆn¡ tisk rny
Int177:  iret                               ; n vrat z obsluhy p©eru¨en¡

; ------ obsluha funkce 1 - inicializace tisk rny

Int178:  cmp       ah,1                     ; inicializace tisk rny ?
         jne       Int179                   ; nezn m  funkce - pokra‡uje
         call      InitDrv                  ; inicializace ovlada‡e tisk rny

; ------ p–vodn¡ obsluha tisk rny

Int179:  call      OutByte                  ; obsluha v˜stupu na tisk rnu
         jmp       dword ptr cs:[Old17]     ; p–vodn¡ obsluha INT 17h

Int17    ENDP

; -----------------------------------------------------------------------------
;        test instalace programu (ES:DI=adresa identifika‡n¡ho textu)
; -----------------------------------------------------------------------------

TestInst PROC      NEAR

         cmp       di,offset Ident          ; adresa identifika‡n¡ho textu
         jne       TestIns5                 ; nen¡ dotaz na instalaci

; ------ £schova registr–

         push      si
         push      di
         push      cx
         push      ds

; ------ porovn n¡ text–

         push      cs
         pop       ds                       ; DS <- CS
         mov       si,di                    ; adresa identifika‡n¡ho textu
         mov       cx,offset(Ident0-Ident)  ; d‚lka textu
         cld                                ; smˆr nahoru
         repe      cmpsb                    ; porovn n¡ text–
         jne       TestIns2                 ; nen¡ shoda text–
         mov       es:[SegRez],cs           ; rezidentn¡ segment

; ------ n vrat registr–

TestIns2:pop       ds
         pop       cx
         pop       di
         pop       si
TestIns5:ret

TestInst ENDP

; -----------------------------------------------------------------------------
;        vol n¡ p–vodn¡ obsluhy INT 17h
; -----------------------------------------------------------------------------

Int17I   PROC      NEAR

         push      dx

         mov       dx,cs:[PortLPT]          ; port LPT
         pushf
         call      dword ptr cs:[Old17]     ; p–vodn¡ obsluha INT 17h

         pop       dx
         ret

Int17I   ENDP

; -----------------------------------------------------------------------------
;        inicializace ovlada‡e tisk rny
; -----------------------------------------------------------------------------

InitDrv  PROC      NEAR

         mov       word ptr cs:[OutNum],0   ; zru¨en¡ dat ve v˜stupn¡m bufferu
         mov       word ptr cs:[EscAdr],0   ; zru¨en¡ po‘adavku obsluhy ESC
         mov       word ptr cs:[EscCit],0   ; zru¨en¡ ‡¡ta‡e ESC bajt–
         mov       word ptr cs:[CitOut],-1  ; maxim ln¡ doba od v˜stupu
         mov       word ptr cs:[Param0],0   ; p©¡znak, ‘e stav nen¡ zn m˜
         ret

InitDrv  ENDP

; -----------------------------------------------------------------------------
;                              Vystup
;              vysl n¡ v˜stupn¡ho bufferu na tisk rnu
; -----------------------------------------------------------------------------
; VSTUP: NC=operace OK (AH se uchov )
;         CY=chyba TIME-OUT (AH=stavov˜ bajt tisk rny)
; -----------------------------------------------------------------------------

Vystup   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax

; ------ test, zda jsou nˆjak  data k v˜stupu

Vystup1: cmp       word ptr cs:[OutNum],0   ; je nˆco v bufferu ?
         je        Vystup8                  ; nen¡ nic v bufferu

; ------ vysl n¡ bajtu na tisk rnu

         mov       al,cs:[OutBuff]          ; znak p©ipraven˜ k v˜stupu
         xor       ah,ah                    ; funkce v˜stupu na tisk rnu
         call      Int17I                   ; vysl n¡ znaku na tisk rnu
         test      ah,1                     ; byla chyba TIME-OUT ?
         stc
         jnz       Vystup8                  ; byla chyba TIME-OUT

; ------ znak vysl n OK

         call      ClrByte                  ; vypu¨tˆn¡ znaku z bufferu
         jmp       short Vystup1            ; vysl n¡ dal¨¡ho znaku

; ------ n vrat registr–

Vystup8: mov       bh,ah                    ; £schova AH
         pop       ax
         jnc       Vystup9                  ; operace OK
         mov       ah,bh                    ; n vratov˜ chybov˜ k¢d AH
Vystup9: pop       bx
         ret

Vystup   ENDP

; -----------------------------------------------------------------------------
;     vypu¨tˆn¡ bajtu z v˜stupn¡ho bufferu (nekontroluje se, zda tam nˆco je)
; -----------------------------------------------------------------------------

ClrByte  PROC      NEAR

; ------ £schova registr–

         pushf
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         cld
         push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,offset OutBuff
         mov       si,offset OutBuff+1
         dec       word ptr ds:[OutNum]     ; sn¡‘en¡ po‡tu dat v bufferu
         mov       cx,ds:[OutNum]           ; po‡et bajt– v bufferu

; ------ vypu¨tˆn¡ bajtu z bufferu

         rep       movsb                    ; vypu¨tˆn¡ dat z bufferu
         mov       word ptr ds:[CitOut],0   ; nulov n¡ ‡¡ta‡e ‡asu TIME-OUT

; ------ n vrat registr–

ClrByte9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         popf
         ret

ClrByte  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: CY=chyba v˜stupu (AH=stavov˜ bajt tisk rny)
;         NC=operace OK (AH uchov )
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      bx
         mov       bx,cs:[OutNum]           ; po‡et znak– ve v˜stupn¡m bufferu
         cmp       bx,OutMax                ; je buffer pln˜ ?
         jb        WritByt1                 ; buffer nen¡ pln˜
         call      Vystup                   ; vysl n¡ bufferu na tisk rnu
         jc        WritByt2                 ; chyba v˜stupu na tisk rnu
         xor       bx,bx                    ; BX <- 0 nen¡ nic v bufferu
WritByt1:mov       cs:[OutBuff+bx],al       ; bajt do v˜stupn¡ho bufferu
         inc       word ptr cs:[OutNum]     ; zv˜¨en¡ ‡¡ta‡e dat
         clc                                ; p©¡znak operace OK
WritByt2:pop       bx
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ textu CS:SI na tisk rnu (1. slovo - po‡et bajt–)
; -----------------------------------------------------------------------------
; VSTUP: CS:SI=adresa textu k vysl n¡
; VSTUP:CY=chyba v˜stupu (AH=stavov˜ bajt)
;        NC=operace OK (AH uchov )
; -----------------------------------------------------------------------------

WritTxt  PROC      NEAR

         push      cx
         push      ax
         push      si

         mov       cx,cs:[si]               ; po‡et bajt– k vysl n¡
         jcxz      WritTxt2                 ; nen¡ ‘ dn˜ text
         inc       si
WritTxt1:inc       si                       ; adresa bajtu k vysl n¡
         mov       al,cs:[si]               ; znak k vysl n¡
         call      WritByte                 ; z pis znaku na v˜stup
         jc        WritTxt2                 ; chyba v˜stupu na tisk rnu
         loop      WritTxt1                 ; vysl n¡ dal¨¡ho znaku

WritTxt2:pop       si
         mov       ch,ah
         pop       ax
         mov       ah,ch
         pop       cx
         ret

WritTxt  ENDP

; -----------------------------------------------------------------------------
;        mˆkk˜ v˜stup bajtu na tisk rnu
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

; ------ £schova registr–

         pushf
         push      ax

; ------ test, zda je nˆjak˜ bajt k v˜stupu

OutByte1:cmp       word ptr cs:[OutNum],0   ; je nˆco ve v˜stupn¡m bufferu ?
         je        OutByte9                 ; nen¡ nic ve v˜stupn¡m bufferu

; ------ test, zda je tisk rna p©ipravena

         mov       ah,2
         call      Int17I                   ; dotaz na stav tisk rny
         test      ah,bit7                  ; je tisk rna p©ipravena ?
         jz        OutByte9                 ; tisk rna nen¡ p©ipravena

; ------ vysl n¡ znaku na tisk rnu

         mov       al,cs:[OutBuff]          ; znak k vysl n¡
         xor       ah,ah                    ; funkce vysl n¡ bajtu na tisk rnu
         call      Int17I                   ; vysl n¡ znaku na tisk rnu
         test      ah,1                     ; je chyba TIME-OUT ?
         jnz       OutByte9                 ; p©ete‡en¡ TIME-OUT v˜stupu

; ------ vypu¨tˆn¡ znaku z bufferu

         call      ClrByte                  ; vypu¨tˆn¡ bajtu z bufferu
         jmp       short OutByte1           ; vysl n¡ dal¨¡ho znaku

; ------ n vrat registr–

OutByte9:pop       ax
         popf
         ret

OutByte  ENDP


; *****************************************************************************
;
;                        P©ek¢dov n¡ pr–choz¡ch dat
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        konverze bajtu AL (v˜stupn¡ buffer je pr zdn˜)
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k dek¢dov n¡
; VSTUP:CY=chyba v˜stupu
;        AH=stavov˜ bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR


; ------ kontrola, zda se ignoruj¡ data

         cmp       word ptr cs:[EscCit],0   ; ignoruj¡ se data ?
         je        Konvert1                 ; neignoruj¡ se
         call      WritByte                 ; nepodm¡nˆn˜ z pis bajtu
         jc        Konvert0                 ; chyba z pisu
         dec       word ptr cs:[EscCit]     ; sn¡‘en¡ ‡¡ta‡e dat
Konvert0:ret

; ------ pokra‡ov n¡ v obsluze ESC posloupnosti (monitorov n¡)

Konvert1:cmp       word ptr cs:[EscAdr],0   ; po‘aduje se obsluha ESC posloupn.?
         je        Konvert2                 ; nepo‘aduje se obsluha
         push      bx
         push      dx
         mov       bx,cs:[EscAdr]           ; zru¨en¡ adresy obsluhy
         xor       dx,dx                    ; DX <- 0
         call      bx                       ; obsluha ESC
         mov       cs:[EscAdr],dx           ; adresa pokra‡ov n¡ ESC
         pop       dx
         pop       bx
         call      WritByte                 ; z pis bajtu
         jmp       short Konvert9

; ------ inicializace tisk rny

Konvert2:test      word ptr cs:[Param0],bit10; vy‘aduje se inicializace tisk. ?
         jnz       Konvert4                 ; tisk rna inicializov na
         push      si
         mov       byte ptr cs:[SetLQ0],1   ; je stav LQ
         test      word ptr cs:[Param],bit10; je stav LQ ?
         jnz       Konvert3                 ; je stav LQ
         mov       byte ptr cs:[SetLQ0],0   ; nen¡ stav LQ
Konvert3:mov       si,offset SetLQ          ; k¢d pro nastaven¡ LQ, inicializace
         call      WritTxt                  ; z pis textu na tisk rnu
         pop       si
         jc        Konvert9                 ; byla chyba v˜stupu
         or        word ptr cs:[Param0],bit10 ; p©¡znak inicializace tisk rny

; ------ kontrola, zda je za‡ tek ESC posloupnosti

Konvert4:cmp       al,27                    ; je znak ESC ?
         jne       Konvert6                 ; nen¡ znak ESC
         mov       word ptr cs:[EscAdr],offset Esc1 ; obsluha prvn¡ho znaku
         call      WritByte                 ; z pis znaku ESC
         jmp       short Konvert9

; ------ vysl n¡ znaku s p©ek¢dov n¡m

Konvert6:call      OutZnak

Konvert9:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        obsluha prvn¡ho znaku ESC posloupnosti
; -----------------------------------------------------------------------------

Esc1     PROC      NEAR

; ------ k¢dy s ignorov n¡m 1 bajtu

         push      cx
         mov       bx,offset Tab1Parm-1
         mov       cx,offset(Tab1Prm0-Tab1Parm) ; po‡et bajt–
Esc101:  inc       bx
         cmp       al,cs:[bx]
         loopne    Esc101
         pop       cx
         jne       Esc10                    ; nenalezen
         inc       word ptr cs:[EscCit]     ; ignoruje se 1 bajt
         ret

; ------ "ESC x n" - kvalita p¡sma

Esc10:   cmp       al,"x"                   ; nastaven¡ LQ ?
         jne       Esc11
         mov       dx,offset Esc1X
         ret

; ------ "ESC @" - reset tisk rny

Esc11:   cmp       al,"@"
         jne       Esc12
         mov       word ptr cs:[Param0],0   ; nic neplat¡
         ret

; ------ "ESC C 0 n" - d‚lka str nky

Esc12:   cmp       al,"C"
         jne       Esc13
         mov       dx,offset Esc1C
         ret

; ------ "ESC B n ... 0", "ESC D n ... 0" - vertik ln¡ a horizont ln¡ tabel tor

Esc13:   cmp       al,"D"
         je        Esc132
         cmp       al,"B"
         jne       Esc14
Esc132:  mov       dx,offset EscTab
         ret

; ------ "ESC $ n n", "ESC \ n n" - horizont ln¡ a vertik ln¡ pozice

Esc14:   cmp       al,"\"
         je        Esc142
         cmp       al,"$"
         jne       Esc15
Esc142:  mov       word ptr cs:[EscCit],2   ; ignoruj¡ se 2 bajty
         ret

; ------ "ESC & nnn" - download

Esc15:   cmp       al,"&"
         jne       Esc16
         and       word ptr cs:[Param],not bit15 ; vypnut¡ funkce
         ret

; ------ "ESC : 0 n 0" - kop¡rov n¡ ROM do RAM

Esc16:   cmp       al,":"
         jne       Esc17
         and       word ptr cs:[Param0],not bit9 ; fonty jsou nezn m‚
         mov       word ptr cs:[EscCit],3   ; ignoruj¡ se 3 bajty
         ret

; ------ "ESC * m n1 n2" - grafika

Esc17:   cmp       al,"*"
         jne       Esc18
         mov       dx,offset EscGraf
         ret

; ------ grafika

Esc18:   cmp       al,"K"
         je        Esc182
         cmp       al,"L"
         je        Esc182
         cmp       al,"Y"
         je        Esc182
         cmp       al,"Z"
         jne       Esc19
Esc182:  mov       byte ptr cs:[EscStack],0 ; grafick˜ m¢d asi tak 0
         mov       dx,offset EscGrf1        ; vstup po‡tu bajt– dat
         ret




Esc19:


         ret

Esc1     ENDP

Tab1Parm label     byte                     ; tabulka k¢d– s 1 parametrem
         db        'U'                      ; ESC U n - jednosmˆrn˜ tisk
         db        25                       ; ESC EM n - podava‡ pap¡ru
         db        'N'                      ; ESC N n - p©esko‡en¡ perforace
         db        '3'                      ; ESC 3 n - nastaven¡ © dkov n¡
         db        'A'                      ; ESC A n - nastaven¡ © dkov n¡
         db        '+'                      ; ESC + n - nastaven¡ © dkov n¡
         db        'J'                      ; ESC J n - vertik ln¡ posun
         db        'j'                      ; ESC j n - vertik ln¡ posun
         db        'l'                      ; ESC l n - lev˜ okraj
         db        'Q'                      ; ESC Q n - prav˜ okraj
         db        'k'                      ; ESC k n - typ font–
         db        '!'                      ; ESC ! n - nastaven¡ p¡sma
         db        'p'                      ; ESC p n - proporcion ln¡ p¡smo
         db        'W'                      ; ESC W n - dvojn sobn  ¨¡©ka
         db        'w'                      ; ESC w n - dvojn sobn  v˜¨ka
         db        'S'                      ; ESC S n - podsazen¡/nadsazen¡
         db        '-'                      ; ESC - n - podtr‘en¡
         db        'q'                      ; ESC q n - typ p¡sma
         db        ' '                      ; ESC SP n - mezerov n¡
         db        't'                      ; ESC t n - tabulka znak–
         db        'R'                      ; ESC R n - n rodn¡ sada znak–
         db        '%'                      ; ESC % n - volba DownLoad
         db        'a'                      ; ESC a n - nastaven¡ centrov n¡
         db        's'                      ; ESC s n - sn¡‘en  rychlost tisku
Tab1Prm0 label     byte

; -----------------------------------------------------------------------------
;        grafika "ESC * m n1 n2"
; -----------------------------------------------------------------------------

EscGraf  PROC      NEAR

         mov       byte ptr cs:[EscStack],al ; £schova m¢du grafiky
         mov       dx,offset EscGrf1        ; p©¡jem 1. bajtu
         ret

EscGraf  ENDP

EscGrf1  PROC      NEAR

         mov       byte ptr cs:[EscStack+1],al ; £schova prvn¡ho bajtu dat
         mov       dx,offset EscGrf2        ; p©¡jem 2. bajtu
         ret

EscGrf1  ENDP

EscGrf2  PROC      NEAR

         push      ax
         push      dx
         mov       ah,al                    ; vy¨¨¡ bajt po‡tu sloupc–
         mov       al,byte ptr cs:[EscStack+1] ; uschovan˜ ni‘¨¡ bajt
         cmp       byte ptr cs:[EscStack],12 ; je sloupec 3 bajty ?
         jb        EscGrf3                  ; je jen 1 bajt
         mov       dx,3
         mul       dx                       ; po‡et bajt–
EscGrf3: mov       cs:[EscCit],ax           ; po‡et bajt– k ignorov n¡
         pop       dx
         pop       ax
         ret

EscGrf2  ENDP

; -----------------------------------------------------------------------------
;        tabel tory "ESC B n ... 0"
; -----------------------------------------------------------------------------

EscTab   PROC      NEAR

         or        al,al                    ; konec ?
         jz        EscTab2                  ; je konec
         mov       dx,offset EscTab         ; znovu tato obsluha
EscTab2: ret

EscTab   ENDP

; -----------------------------------------------------------------------------
;        parametr "ESC C 0 n" a "ESC C n"
; -----------------------------------------------------------------------------

Esc1C    PROC      NEAR

         or        al,al                    ; je 0 ?
         jnz       Esc1C2                   ; nen¡ 0
         inc       word ptr cs:[EscCit]     ; 1 bajt se ignoruje
Esc1C2:  ret

Esc1C    ENDP

; -----------------------------------------------------------------------------
;        druh˜ znak k¢du "ESC x n"
; -----------------------------------------------------------------------------

Esc1X    PROC      NEAR

         and       word ptr cs:[Param0],not bit9; zru¨en¡ p©¡znaku DownLoad
         and       word ptr cs:[Param],not bit10 ; nen¡ LQ
         test      al,1                     ; je LQ ?
         jz        Esc1X1                   ; nen¡ LQ
         or        word ptr cs:[Param],bit10 ; p©¡znak LQ
Esc1X1:  ret

Esc1X    ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ znaku AL s p©ek¢dov n¡m
; -----------------------------------------------------------------------------

OutZnak  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax
         push      cx
         push      si

; ------ rozli¨en¡, zda se znak bude dek¢dovat

         cmp       al,128                   ; minim ln¡ znak 128 €
         jb        OutZnak8                 ; znak se nekonvertuje
         cmp       al,173                   ; maxim ln¡ znak 173 ­
         ja        OutZnak8                 ; znak se nekonvertuje

; ------ nastaven¡ adresy znaku v tabulce

         xor       bx,bx
         mov       bl,al
         sub       bl,128                   ; znak relativnˆ
         shl       bx,1                     ; offset v tabulce
         add       bx,offset DekTab         ; adresa v dek¢dovac¡ tabulce

; ------ znak interpunkce

         mov       al,cs:[bx+1]             ; interpunk‡n¡ znak
         or        al,al                    ; zapisuje se znak interpunkce ?
         jz        OutZnak7                 ; znak se nezapisuje

; ------ zaji¨tˆn¡ definice tabulky DownLoad

         test      word ptr cs:[Param0],bit9; je tabulka DownLoad nadefinovan  ?
         jnz       OutZnak4                 ; tabulka DownLoad je nadefinovan 
         mov       si,offset InitLQ         ; inicializa‡n¡ ©etˆzec tisk rny LQ
         test      word ptr cs:[Param],bit10; je stav LQ ?
         jnz       OutZnak2                 ; je stav LQ
         mov       si,offset InitDrft       ; inicializa‡n¡ ©etˆzec Draft
OutZnak2:call      WritTxt                  ; z pis textu na tisk rnu
         jc        OutZnak9                 ; byla chyba v˜stupu
         or        word ptr cs:[Param0],bit9 ; p©¡znak nadefinov n¡ DownLoad

; ------ vysl n¡ znaku interpunkce DownLoad

OutZnak4:mov       si,offset SetDwn         ; k¢d pro nastaven¡ DownLoad
         call      WritTxt                  ; v˜stup na tisk rnu
         jc        OutZnak9                 ; chyba v˜stupu
         call      WritByte                 ; z pis znaku interpunkce
         jc        OutZnak9                 ; chyba v˜stupu
         mov       si,offset ResDwn         ; k¢d pro zru¨en¡ stavu DownLoad
         call      WritTxt                  ; v˜stup na tisk rnu
         cmp       byte ptr cs:[bx],0       ; je z kladn¡ znak ?
         je        OutZnak9                 ; nen¡ z kladn¡ znak
         mov       al,8                     ; krok zpˆt
         call      WritByte                 ; krok zpˆt

; ------ v˜stup z kladn¡ho znaku

OutZnak7:mov       al,cs:[bx]               ; z kladn¡ znak

; ------ vysl n¡ platn‚ho znaku nebo ekvivalentu

OutZnak8:call      WritByte                 ; ulo‘en¡ znaku do bufferu

; ------ n vrat registr–

OutZnak9:pop       si
         pop       cx
         mov       bh,ah                    ; £schova n vratov‚ho k¢du
         pop       ax
         mov       ah,bh
         pop       bx
         ret

OutZnak  ENDP

; *****************************************************************************
;
;                   Tabulky ©¡dic¡ch k¢d–
;
; *****************************************************************************

SetDwn   dw        3
         db        27,'%',1                 ; zapnut¡ DownLoad

ResDwn   dw        3
         db        27,'%',0                 ; vypnut¡ DownLoad

SetLQ    dw        SetLQ0-$-2+1             ; nastaven¡ LQ nebo Draft, inicial.
         db        27,'6'                   ; povolen tisk znak– 128 a‘ 159
         db        27,'t',1                 ; tabulka znak– IBM
         db        27,'%',0                 ; vypnut¡ DownLoad
         db        27,'x'                   ; nastaven¡ stavu LQ
SetLQ0   db        1

; -----------------------------------------------------------------------------
;        tabulka pro p©ek¢dov n¡ znak–
; -----------------------------------------------------------------------------

DekTab   label     byte
         db        'C',HacV                 ; 128 €
         db        129,0                    ; 129 
         db        'e',CarM                 ; 130 ‚
         db        'd',CarR                 ; 131 ƒ
         db        132,0                    ; 132 „
         db        'D',HacV                 ; 133 …
         db        'T',HacV                 ; 134 †
         db        'c',HacM                 ; 135 ‡
         db        'e',HacM                 ; 136 ˆ
         db        'E',HacV                 ; 137 ‰
         db        'L',CarV                 ; 138 Š
         db        'I',CarV                 ; 139 ‹
         db        'l',CarR                 ; 140 Œ
         db        'l',CarV                 ; 141 
         db        142,0                    ; 142 Ž
         db        'A',CarV                 ; 143 
         db        'E',CarV                 ; 144 
         db        'z',HacM                 ; 145 ‘
         db        'Z',HacV                 ; 146 ’
         db        147,0                    ; 147 “
         db        148,0                    ; 148 ”
         db        'O',CarV                 ; 149 •
         db        'u',KroM                 ; 150 –
         db        'U',CarV                 ; 151 —
         db        'y',CarM                 ; 152 ˜
         db        153,0                    ; 153 ™
         db        154,0                    ; 154 š
         db        'S',HacV                 ; 155 ›
         db        'L',CarR                 ; 156 œ
         db        'Y',CarV                 ; 157 
         db        'R',HacV                 ; 158 ž
         db        't',CarR                 ; 159 Ÿ
         db        'a',CarM                 ; 160  
         db        0,CarI                 ; 161 ¡
         db        'o',CarM                 ; 162 ¢
         db        'u',CarM                 ; 163 £
         db        'n',HacM                 ; 164 ¤
         db        'N',HacV                 ; 165 ¥
         db        'U',KroV                 ; 166 ¦
         db        'O',StrV                 ; 167 §
         db        's',HacM                 ; 168 ¨
         db        'r',HacM                 ; 169 ©
         db        'r',CarM                 ; 170 ª
         db        'R',HacV                 ; 171 «
         db        171,0                    ; 172 ¬
         db        0,Para                   ; 173 ­

; -----------------------------------------------------------------------------
;        inicializace tisk rny v re‘imu Draft
; -----------------------------------------------------------------------------

InitDrft label     byte                     ; inicializa‡n¡ tabulka LQ
         dw        InitDrf0-$-2             ; d‚lka tabulky
         db        27,'6',27,'t',1,27,'x',0 ; inicializa‡n¡ ©etˆzec
         db        27,':',0,0,0             ; kopie z ROM do RAM
         db        27,'%',1                 ; zapnut¡ DownLoad
;þ
; ------ mal  ‡ rka

         db        27,'&',0,CarM,CarM       ; z hlav¡ definice znaku
         db        0,4,0
         db        00000000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b

; ------ velk  ‡ rka

         db        27,'&',0,CarV,CarV       ; z hlav¡ definice znaku
         db        0,4,0
         db        00000000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b

; ------ ‡ rka vpravo

         db        27,'&',0,CarR,CarR       ; z hlav¡ definice znaku
         db        0,12,0
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        01110000b,00000000b,00000000b

; ------ ‡ rka nad mal˜m i

         db        27,'&',0,CarI,CarI       ; z hlav¡ definice znaku
         db        0,6,0
         db        00000001b,00000000b,00000000b
         db        00000010b,00000000b,00100000b
         db        00010001b,00000000b,01000000b
         db        00100010b,10101010b,10100000b
         db        01000000b,00000000b,01000000b
         db        00000000b,00000000b,00100000b

; ------ mal˜ h ‡ek

         db        27,'&',0,HacM,HacM       ; z hlav¡ definice znaku
         db        0,8,0
         db        00000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ velk˜ h ‡ek

         db        27,'&',0,HacV,HacV       ; z hlav¡ definice znaku
         db        0,8,0
         db        00000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ mal˜ krou‘ek

         db        27,'&',0,KroM,KroM       ; z hlav¡ definice znaku
         db        0,5,0
         db        00011000b,00000000b,00000000b
         db        00100100b,00000000b,00000000b
         db        00011000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ velk˜ krou‘ek

         db        27,'&',0,KroV,KroV       ; z hlav¡ definice znaku
         db        0,4,0
         db        01100000b,00000000b,00000000b
         db        10010000b,00000000b,00000000b
         db        01100000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ velk  st©¡¨ka

         db        27,'&',0,StrV,StrV       ; z hlav¡ definice znaku
         db        0,8,0
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ paragraf

         db        27,'&',0,Para,Para       ; z hlav¡ definice znaku
         db        0,6,0
         db        00000000b,01111100b,00000000b
         db        00111100b,10000010b,00000110b
         db        01000011b,00000001b,00000001b
         db        10000000b,10000000b,11000010b
         db        01100000b,01000001b,00111100b
         db        00000000b,00111110b,00000000b

         db        27,'%',0                 ; vypnut¡ DownLoad

InitDrf0 label     byte

; -----------------------------------------------------------------------------
;        inicializace tisk rny v re‘imu LQ
; -----------------------------------------------------------------------------

InitLQ   label     byte                     ; inicializa‡n¡ tabulka LQ
         dw        InitLQ0-$-2              ; d‚lka tabulky
         db        27,'6',27,'t',1,27,'x',1 ; inicializa‡n¡ ©etˆzec
         db        27,':',0,0,0             ; kopie z ROM do RAM
         db        27,'%',1                 ; zapnut¡ DownLoad
;þ
; ------ mal  ‡ rka

         db        27,'&',0,CarM,CarM       ; z hlav¡ definice znaku
         db        11,13,12
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01100000b,00000000b,00000000b
         db        11100000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b

; ------ velk  ‡ rka

         db        27,'&',0,CarV,CarV       ; z hlav¡ definice znaku
         db        7,23,6
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b

; ------ ‡ rka vpravo

         db        27,'&',0,CarR,CarR       ; z hlav¡ definice znaku
         db        0,33,3
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00001000b,00000000b,00000000b
         db        11001000b,00000000b,00000000b
         db        11110000b,00000000b,00000000b
         db        11110000b,00000000b,00000000b

; ------ ‡ rka nad mal˜m i

         db        27,'&',0,CarI,CarI       ; z hlav¡ definice znaku
         db        2,17,2
         db        00000010b,00000000b,01000000b
         db        00000010b,00000000b,01000000b
         db        00000010b,00000000b,01000000b
         db        00000010b,00000000b,01000000b
         db        00000010b,00000000b,01000000b
         db        00000010b,00000000b,01000000b
         db        00010010b,00000000b,01000000b
         db        00010011b,11111111b,11000000b
         db        00100011b,11111111b,11000000b
         db        00100011b,11111111b,11000000b
         db        01100000b,00000000b,01000000b
         db        11100000b,00000000b,01000000b
         db        11000000b,00000000b,01000000b
         db        11000000b,00000000b,01000000b
         db        11000000b,00000000b,01000000b
         db        10000000b,00000000b,01000000b
         db        10000000b,00000000b,01000000b

; ------ mal˜ h ‡ek

         db        27,'&',0,HacM,HacM       ; z hlav¡ definice znaku
         db        9,16,11
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        00110000b,00000000b,00000000b
         db        00110000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00011000b,00000000b,00000000b
         db        00011000b,00000000b,00000000b
         db        00010000b,00000000b,00000000b
         db        00110000b,00000000b,00000000b
         db        00110000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b

; ------ velk˜ h ‡ek

         db        27,'&',0,HacV,HacV       ; z hlav¡ definice znaku
         db        10,16,10
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01100000b,00000000b,00000000b
         db        01100000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b

; ------ mal˜ krou‘ek

         db        27,'&',0,KroM,KroM       ; z hlav¡ definice znaku
         db        12,13,11
         db        00011000b,00000000b,00000000b
         db        00111100b,00000000b,00000000b
         db        01100110b,00000000b,00000000b
         db        01000010b,00000000b,00000000b
         db        01000010b,00000000b,00000000b
         db        01000010b,00000000b,00000000b
         db        01000010b,00000000b,00000000b
         db        01000010b,00000000b,00000000b
         db        01100110b,00000000b,00000000b
         db        00111100b,00000000b,00000000b
         db        00011000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

; ------ velk˜ krou‘ek

         db        27,'&',0,KroV,KroV       ; z hlav¡ definice znaku
         db        17,9,10
         db        00100000b,00000000b,00000000b
         db        01110000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        01110000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b

; ------ velk  st©¡¨ka

         db        27,'&',0,StrV,StrV       ; z hlav¡ definice znaku
         db        6,25,5
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        10000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b

; ------ paragraf

         db        27,'&',0,Para,Para       ; z hlav¡ definice znaku
         db        4,17,10
         db        00000000b,00111100b,00000000b
         db        00000000b,01111110b,00000000b
         db        01111000b,01111110b,00000000b
         db        01111100b,10001111b,00000010b
         db        11111110b,10000111b,00000110b
         db        11111111b,00000011b,00000111b
         db        10001111b,10000011b,10000101b
         db        10000111b,10000011b,10000001b
         db        10000011b,10000001b,11000001b
         db        10000001b,11000001b,11100001b
         db        10100001b,11000001b,11110001b
         db        11100000b,11000000b,11111111b
         db        01100000b,11100001b,01111111b
         db        01000000b,11110001b,00111110b
         db        00000000b,01111110b,00011110b
         db        00000000b,01111110b,00000000b
         db        00000000b,00111100b,00000000b

         db        27,'%',0                 ; vypnut¡ DownLoad

InitLQ0  label     byte

; *****************************************************************************
;
;                         start programu (instalace)
;
; *****************************************************************************

Init:

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava k dek¢dov n¡ zadan˜ch parametr–

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       cx,cx                    ; CX <- 0
         mov       cl,ds:[si-1]             ; po‡et znak– textu
         cld

; ------ nalezen¡ platn‚ho znaku

Init1:   jcxz      Init4                    ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ jednoho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al,13                    ; je konec © dku CR ?
         je        Init4                    ; je konec © dku CR
         cmp       al,"/"                   ; je oddˆlova‡ parametr– ?
         je        Init1                    ; oddˆlova‡ parametr– se ignoruje
         cmp       al," "                   ; je mezera ?
         je        Init1                    ; mezera se ignoruje
         cmp       al,9                     ; je tabel tor ?
         je        Init1                    ; tabel tor se ignoruje

; ------ po‘adavek odinstalov n¡ programu

         cmp       al,"!"                   ; po‘adavek odinstalov n¡ ?
         jne       Init2                    ; nen¡ po‘adavek odinstalov n¡
         mov       byte ptr ds:[OdIns],1    ; p©¡znak po‘adavku odinstalov n¡
         jmp       short Init1              ; dek¢dov n¡ dal¨¡ho parametru

; ------ po‘adavek vypnut¡ funkce programu

Init2:   cmp       al,"0"                   ; po‘aduje se vypnut¡ funkce ?
         jne       Init3                    ; nen¡ po‘adavek vypnut¡ funkce
         and       byte ptr ds:[Param+1],not bit15/HI ; vypnut¡ funkce
         jmp       short Init1              ; dek¢dov n¡ dal¨¡ho parametru

; ------ zad no ‡¡slo portu

Init3:   cmp       al,"1"                   ; je zad no ‡¡slo portu ?
         jb        ChybZad                  ; chyba zad n¡ parametr–
         cmp       al,"4"
         ja        ChybZad                  ; chyba zad n¡ parametr–
         sub       al,"1"                   ; ‡¡slo portu LPT
         mov       byte ptr ds:[PortLPT],al ; ‡¡slo portu
         jmp       short Init1              ; dek¢dov n¡ dal¨¡ho parametru


; ------ chyba zad n¡ parametr–

ChybZad: mov       dx,offset HelpTxt        ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         int       20h                      ; konec programu



; ------ ozna‡en¡ ‡¡sla portu do text–

Init4:   mov       al,byte ptr ds:[PortLPT] ; instalovan˜ port
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[InstTxt0],al         ; ‡¡slo portu LPT
         mov       ds:[DeInsTx0],al
         mov       ds:[DInsTxt0],al
         mov       ds:[InstDTx0],al

; ------ test stavu instalace programu CSPRINT (mus¡ b˜t ES=CS)

         mov       ds:[SegRez],ds           ; tento program
         mov       di,offset Ident          ; identifika‡n¡ text
         mov       dx,ds:[PortLPT]          ; port LPT
         mov       ah,2                     ; funkce dotazu na stav
         int       17h                      ; dotaz na stav - test instalace
         mov       es,ds:[SegRez]           ; rezidentn¡ instalace

; ------ vypnut¡ rezidentn¡ho ovlada‡e

         cli
         mov       al,byte ptr ds:[Param+1] ; po‘adovan˜ stav
         and       al,bit15/hi              ; ponech  po‘adovan˜ p©¡znak
         and       byte ptr es:[Param+1],not bit15/hi ; vypnut¡ rezid. ovlada‡e
         or        byte ptr es:[Param+1],al ; nov˜ stav ovlada‡e
         sti

; ------ resetov n¡ stavu ovlada‡e

         mov       word ptr es:[OutNum],0   ; zru¨en¡ dat ve v˜stupn¡m bufferu
         mov       word ptr es:[EscAdr],0   ; zru¨en¡ po‘adavku obsluhy ESC
         mov       word ptr es:[EscCit],0   ; zru¨en¡ ‡¡ta‡e ESC bajt–
         mov       word ptr es:[CitOut],-1  ; maxim ln¡ doba od v˜stupu
         mov       word ptr es:[Param0],0   ; p©¡znak, ‘e stav nen¡ zn m˜

; ------ p©¡padn‚ odinstalov n¡ programu

         cmp       byte ptr ds:[OdIns],0    ; po‘aduje se odinstalov n¡ ?
         jne       OdInst                   ; odinstalov n¡ programu

; ------ nen¡-li program nainstalov n, jeho nainstalov n¡

         mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]           ; je nainstalov n ?
         jne       Init7                    ; je nainstalov n
         jmp       Instal                   ; prvn¡ instalace programu

Init7:   int       20h

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu (DS=CS)
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

         cli

; ------ kontrola, zda byl program nainstalov n

         mov       dx,offset InstDTxt       ; hl ¨en¡ - nebyl dosud nainstalov n
         mov       ax,ds                    ; tento segment
         cmp       ax,ds:[SegRez]           ; byl nainstalov n ?
         je        OdInst8                  ; program nebyl nainstalov n

; ------ kontrola INT 08h

         mov       dx,offset DInsTxt        ; hl ¨en¡ - nelze odinstalovat
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ kontrola INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut¡ adresy INT 17h
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8                  ; nelze navr tit

; ------ kontrola INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8                  ; nelze navr tit

; ------ n vrat adresy INT 08h

         push      ds
         lds       dx,es:[Old08]            ; p–vodn¡ adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h

; ------ n vrat adresy INT 17h

         lds       dx,es:[Old17]            ; p–vodn¡ adresa INT 17h
         mov       ax,2517h
         int       21h                      ; n vrat adresy INT 17h

; ------ n vrat adresy INT 28h

         lds       dx,es:[Old28]            ; p–vodn¡ adresa INT 28h
         mov       ax,2528h
         int       21h                      ; n vrat adresy INT 28h
         pop       ds

; ------ uvolnˆn¡ segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu programu
         mov       dx,offset DeInsTxt       ; hl ¨en¡ - byl odinstalov n

; ------ chybov‚ hl ¨en¡

OdInst8: sti
         mov       ah,9
         int       21h                      ; zobrazen¡ textu chybov‚ho hl ¨en¡
         int       20h

OdInst   ENDP

; -----------------------------------------------------------------------------
;        instalace programu (DS=CS)
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

         cli

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; offset INT 08h
         mov       word ptr ds:[Old08+2],es ; segment INT 08h

; ------ £schova adresy INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut¡ adresy INT 17h
         mov       word ptr ds:[Old17],bx   ; offset INT 17h
         mov       word ptr ds:[Old17+2],es ; segment INT 17h

; ------ £schova adresy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr ds:[Old28],bx   ; offset INT 28h
         mov       word ptr ds:[Old28+2],es ; segment INT 28h

; ------ instalace INT 08h

         mov       dx,offset Int08
         mov       ax,2508h
         int       21h                      ; instalace INT 08h

; ------ instalace INT 17h

         mov       dx,offset Int17
         mov       ax,2517h
         int       21h                      ; instalace INT 17h

; ------ instalace INT 28h

         mov       dx,offset Int28
         mov       ax,2528h
         int       21h                      ; instalace INT 28h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

         sti

; ------ hl ¨en¡ o instalaci

         mov       dx,offset InstTxt        ; hl ¨en¡ o instalaci
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡ o instalaci

; ------ instalace programu

         mov       dx,offset Init           ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

Instal   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

OdIns    db        0                        ; p©¡znak po‘adavku odinstalov n¡

UvTxt    db        'EPS24CS V1.0 - cs. ovladac tiskarny 24 jehel; (c) Miroslav Nemecek'
         db        13,10,'$'

InstTxt  db        'EPS24CS byl nainstalovan pro port LPT'
InstTxt0 db        '1.',13,10,'$'

DeInsTxt db        'EPS24CS byl odinstalovan z portu LPT'
DeInsTx0 db        '1.',13,10,'$'

DInsTxt  db        'EPS24CS nelze odinstalovat z portu LPT'
DInsTxt0 db        '1 !',13,10,'$'

InstDTxt db        'EPS24CS nebyl dosud pro port LPT'
InstDTx0 db        '1 nainstalovan !',13,10,'$'

HelpTxt  db        'zadejte:  1 az 4 - instalace pro port LPT1 az LPT4',13,10
         db        '          0      - vypnut¡ funkce ovlada‡e',13,10
         db        '          !      - odinstalovani programu',13,10
         db        '$'

Code     ENDS
         END       Start

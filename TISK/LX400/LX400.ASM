
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                               CSPRINT
;               program pro tisk ‡e¨tiny na tisk rnu
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; -----------------------------------------------------------------------------
;        p©ep¡na‡e funkce programu
; -----------------------------------------------------------------------------

TimeOut  EQU       10*18                   ; max. povolen  prodleva v˜stupu

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

Ident    db        'LX400 V1.0'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn¡ ‡ sti

; ------ p–vodn¡ adresy obsluh p©eru¨en¡

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old17    dd        0                        ; p–vodn¡ adresa INT 17h
Old28    dd        0                        ; p–vodn¡ adresa INT 28h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; ‡¡slo portu LPT
Param0   dw        0                        ; parametry - stav zn mosti
                                            ;   bit 8: 1=stav DownLoad zn m˜
                                            ;   bit 9: 1=tabulka DownLoad zn m 
                                            ;   bit 10: 1=stav NLQ zn m˜
Param    dw        bit10                   ; parametry
                                            ;   bit 8: 1=p©epnuto na DownLoad
                                            ;   bit 10: 1=je stav NLQ

; ------ ‡¡ta‡ ‡asu

CitOut   dw        0                        ; ‡¡ta‡ ‡asu od posledn¡ho v˜stupu

; ------ buffer pro uchov n¡ ESC sekvenc¡

EscNum   dw        0                        ; po‡et znak– v ESC bufferu
EscBuff  db        10 dup(0)                ; buffer ESC sekvenc¡

; ------ v˜stupn¡ buffer

OutMax   EQU       120                      ; velikost v˜stupn¡ho bufferu
OutNum   dw        0                        ; po‡et znak– ve v˜stupn¡m bufferu
OutBuff  db        OutMax dup(0)            ; v˜stupn¡ buffer

; ------ definice pro DownLoad

MaxDwn   EQU       220                      ; velikost bufferu DownLoad
FirstDwn db        58                       ; prvn¡ znak pro DownLoad
LastDwn  db        63;88                    ; posledn¡ znak pro DownLoad

NumDwn   dw        0                        ; po‡et nadefinovan˜ch znak– DwnL
         EVEN
BuffDwn  dw        MaxDwn dup(0)            ; buffer definic znak– DownLoad
                                            ;  1.bajt - definovan˜ znak
                                            ;  2.bajt - ekvivalent znaku

TabFont  dw        offset KamNlq            ; aktu ln¡ tabulka indexu font–


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

         call      OutByte                  ; mˆk  obsluha v˜stupu na tisk rnu
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

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp

         mov       dx,cs:[PortLPT]          ; port LPT
         pushf
         call      dword ptr cs:[Old17]     ; p–vodn¡ obsluha INT 17h

         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

Int17I   ENDP

; -----------------------------------------------------------------------------
;                              Vystup
;              vysl n¡ v˜stupn¡ho bufferu na tisk rnu
; -----------------------------------------------------------------------------
; VSTUP: NC=operace OK
;         CY=chyba TIME-OUT, AH=stavov˜ bajt tisk rny
;         (ostatn¡ registry uchov v  !)
; -----------------------------------------------------------------------------

Vystup   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax

; ------ test, zda jsou nˆjak  data k v˜stupu

Vystup1: cmp       word ptr cs:[OutNum],0   ; je nˆco v bufferu ?
         je        Vystup9                  ; nen¡ nic v bufferu

; ------ vysl n¡ bajtu na tisk rnu

         mov       al,cs:[OutBuff]          ; znak p©ipraven˜ k v˜stupu
         xor       ah,ah                    ; funkce v˜stupu na tisk rnu
         call      Int17I                   ; vysl n¡ znaku na tisk rnu
         test      ah,1                     ; byla chyba TIME-OUT ?
         stc
         jnz       Vystup9                  ; byla chyba TIME-OUT

; ------ znak vysl n OK

         call      ClrByte                  ; vypu¨tˆn¡ znaku z bufferu
         jmp       short Vystup1            ; vysl n¡ dal¨¡ho znaku

; ------ n vrat registr–

Vystup9: mov       bh,ah                    ; £schova AH
         pop       ax
         mov       ah,bh                    ; n vratov˜ k¢d AH
         pop       bx
         ret

Vystup   ENDP


; -----------------------------------------------------------------------------
;        inicializace ovlada‡e tisk rny
; -----------------------------------------------------------------------------

InitDrv  PROC      NEAR

         mov       word ptr cs:[OutNum],0   ; zru¨en¡ dat ve v˜stupn¡m bufferu
         mov       word ptr cs:[EscNum],0   ; zru¨en¡ dat v Esc bufferu
         mov       word ptr cs:[CitOut],-1  ; maxim ln¡ doba od v˜stupu
         mov       word ptr cs:[Param0],0   ; p©¡znak, ‘e stav nen¡ zn m˜
         mov       word ptr cs:[NumDwn],0   ; nulov n¡ tabulky DownLoad
         ret

InitDrv  ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu AL do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------
; VSTUP: CY=chyba v˜stupu (AH=stavov˜ bajt tisk rny)
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
;        z pis textu CS:SI do bufferu (1. bajt = d‚lka textu)
; -----------------------------------------------------------------------------
; VSTUP: CS:SI=adresa textu k vysl n¡
; VSTUP:CY=chyba v˜stupu
;        AH=stavov˜ bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

WritTxt  PROC      NEAR

         push      cx
         push      ax
         push      si

         xor       cx,cx
         mov       cl,cs:[si]
         jcxz      WritTxt2
WritTxt1:inc       si
         mov       al,cs:[si]
         call      WritByte                 ; z pis znaku do bufferu
         jc        WritTxt2                 ; chyba v˜stupu na tisk rnu
         loop      WritTxt1

WritTxt2:pop       si
         mov       ch,ah
         pop       ax
         mov       ah,ch
         pop       cx
         ret

WritTxt  ENDP

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
         test      ah,80h                   ; je tisk rna p©ipravena ?
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
;                       Obsluha DownLoad tisk rny
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                    nalezen¡ znaku v tabulce DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VSTUP:SI=adresa definice znaku (NC)
;        CY=znak v tabulce nenalezen
; -----------------------------------------------------------------------------

SrcDown  PROC      NEAR

         push      cx
         mov       si,offset BuffDwn        ; buffer definic znak– DownLoad
         mov       cx,cs:[NumDwn]           ; po‡et definovan˜ch znak–
         jcxz      SrcDown3                 ; nen¡ nic nadefinov no
SrcDown1:cmp       byte ptr cs:[si],al      ; je to hledan˜ znak ?
         je        SrcDown4                 ; znak nalezen OK
         inc       si
         inc       si
         loop      SrcDown1                 ; test dal¨¡ho znaku
SrcDown3:stc                                ; chyba
SrcDown4:pop       cx
         ret

SrcDown  ENDP

; -----------------------------------------------------------------------------
;                    vypu¨tˆn¡ znaku z bufferu DownLoad
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa vypou¨tˆn‚ho znaku
; -----------------------------------------------------------------------------

DelDown  PROC      NEAR

; ------ £schova registr–

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©¡prava registr–

         push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,si                    ; adresa znaku
         inc       si
         inc       si                       ; adresa zbytku
         mov       cx,ds:[NumDwn]           ; po‡et definovan˜ch znak–
         jcxz      DelDown4
         shl       cx,1                     ; d‚lka tabulky
         add       cx,offset BuffDwn        ; konec tabulky definice
         sub       cx,si                    ; d‚lka zbytku tabulky k p©¡sunu
         jb        DelDown4

; ------ p©¡sun zbytku dat

         cld                                ; smˆr nahoru
         shr       cx,1                     ; d‚lka zbytku ve slovech
         rep       movsw                    ; p©¡sun zbytku tabulky

; ------ sn¡‘en¡ po‡tu znak– v tabulce

DelDown3:dec       word ptr ds:[NumDwn]     ; sn¡‘en¡ po‡tu znak–

; ------ n vrat registr–

DelDown4:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

DelDown  ENDP

; -----------------------------------------------------------------------------
;                nalezen¡ ekvivalentu v tabulce
; -----------------------------------------------------------------------------
; VSTUP: AH=ekvivalent znaku
; VSTUP:SI=adresa definice znaku (NC)
;        CY=znak v tabulce nenalezen
; -----------------------------------------------------------------------------

SrcEkvi  PROC      NEAR

         push      cx
         mov       si,offset BuffDwn        ; buffer definic znak– DownLoad
         mov       cx,cs:[NumDwn]           ; po‡et definovan˜ch znak–
         jcxz      SrcEkvi3                 ; nen¡ nic nadefinov no
SrcEkvi1:cmp       byte ptr cs:[si+1],ah    ; je to hledan˜ ekvivalent ?
         je        SrcEkvi4                 ; znak nalezen OK
         inc       si
         inc       si
         loop      SrcEkvi1                 ; test dal¨¡ho znaku
SrcEkvi3:stc                                ; chyba
SrcEkvi4:pop       cx
         ret

SrcEkvi  ENDP

; -----------------------------------------------------------------------------
;                  ulo‘en¡ nov‚ definice znaku na konec tabulky
; -----------------------------------------------------------------------------
; VSTUP: AL=definovan˜ znak
;        AH=ekvivalent znaku
; VSTUP:SI=adresa definice znaku
; -----------------------------------------------------------------------------

NewDown  PROC      NEAR

         mov       si,offset BuffDwn        ; buffer definic DownLoad
         add       si,cs:[NumDwn]
         add       si,cs:[NumDwn]           ; adresa k ulo‘en¡ definice znaku
         mov       cs:[si],ax               ; ulo‘en¡ definice na konec tabulky
         inc       word ptr cs:[NumDwn]     ; zv˜¨en¡ po‡tu definic
         ret

NewDown  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ znaku DownLoad do bufferu DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VSTUP:AH=ekvivalent znaku
;        CY=znak nebyl dosud nadefinov n (byl ulo‘en do tabulky)
; -----------------------------------------------------------------------------

StorDown PROC      NEAR

; ------ £schova registr–

         push      si

; ------ nalezen¡ znaku v tabulce DownLoad

         call      SrcDown                  ; nalezen¡ znaku v tabulce DownLoad
         jc        StorDwn3                 ; znak nebyl dosud nadefinov n

; ------ zru¨en¡ star‚ definice znaku

         mov       ax,cs:[si]               ; star  definice znaku
         call      DelDown                  ; zru¨en¡ definice znaku z tabulky

; ------ ulo‘en¡ definice na konec tabulky

         call      NewDown                  ; ulo‘en¡ definice AX do tabulky
         clc                                ; p©¡znak, ‘e znak ji‘ byl definov n
         jmp       short StorDwn9           ; konec

; ------ nalezen¡ voln‚ho ekvivalentu

StorDwn3:mov       ah,cs:[FirstDwn]         ; prvn¡ znak ekvivalentu DownLoad
StorDwn4:call      SrcEkvi                  ; nalezen¡ ekvivalentu v tabulce
         jc        StorDwn8                 ; nenalezen - lze jej pou‘¡t
StorDwn5:inc       ah                       ; zv˜¨en¡ ‡¡sla ekvivalentu
         cmp       ah,7fh
         je        StorDwn5                 ; zak zan˜ znak

StorDwn7:cmp       ah,cs:[LastDwn]          ; je to ji‘ posledn¡ ekvivalent ?
         jbe       StorDwn4                 ; dal¨¡ pokus o nalezen¡

; ------ zru¨en¡ nejstar¨¡ definice znaku

         mov       si,offset BuffDwn        ; buffer definice DownLoad znak–
         mov       ah,cs:[si+1]             ; ekvivalent p–vodn¡ho znaku
         call      DelDown                  ; zru¨en¡ star‚ho znaku

; ------ definice nov‚ho znaku

StorDwn8:call      NewDown                  ; ulo‘en¡ nov‚ definice do tabulky
         stc                                ; p©¡znak, ‘e znak nebyl definov n

; ------ n vrat registr–

StorDwn9:pop       si
         ret

StorDown ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn  definice znaku DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=po‘adovan˜ znak
; VSTUP:AH=ekvivalent znaku (NC) nebo stavov˜ bajt (chyba CY)
;        CY=chyba v˜stupu na tisk rnu
; -----------------------------------------------------------------------------

DefDown  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax
         push      si

; ------ test, zda je znak ji‘ nadefinov n

         call      StorDown                 ; ulo‘en¡ znaku do defini‡n¡ tabulky
         jnc       DefDown9                 ; znak je ji‘ nadefinov n

; ------ zapnut¡ re‘imu DownLoad

         push      ax
         mov       si,offset KDefDwn        ; k¢d pro definici DownLoad
         mov       cs:[si+4],ah
         mov       cs:[si+5],ah             ; ekvivalent znaku
         call      DownOn                   ; zapnut¡ re‘imu DownLoad
         jc        DefDown8                 ; byla chyba operace

; ------ vysl n¡ z hlav¡ definice znaku

         call      WritTxt                  ; vysl n¡ z hlav¡ definice znaku
         jc        DefDown8                 ; chyba v˜stupu na tisk rnu

; ------ vysl n¡ definice DownLoad

         xor       ah,ah                    ; AX = po‘adovan˜ znak
         mov       si,ax                    ; po‘adovan˜ znak
         shl       si,1                     ; offset v tabulce index–
         add       si,cs:[TabFont]          ; aktu ln¡ tabulka font–
         mov       si,cs:[si]               ; adresa fontu
         call      WritTxt                  ; vysl n¡ definice znaku
         jc        DefDown8                 ; chyba v˜stupu na tisk rnu
         pop       ax                       ; n vrat k¢du (ekvivalentu)
         jmp       short DefDown9

; ------ chyba definice znaku

DefDown8:pop       bx                       ; zru¨en¡ AX ze z sobn¡ku
         dec       word ptr cs:[NumDwn]     ; zru¨en¡ definice znaku

; ------ n vrat registr–

DefDown9:pop       si
         mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
         ret

DefDown  ENDP

; -----------------------------------------------------------------------------
;        vysl n¡ znaku s podm¡nˆn˜m DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k vysl n¡
; VSTUP:CY=chyba v˜stupu (AH=stavov˜ bajt tisk rny)
; -----------------------------------------------------------------------------
;þ
OutZnak  PROC      NEAR

; ------ £schova registr–

         push      bx
         push      ax

; ------ test, zda znak bude vysl n bˆ‘n˜m zp–sobem

         xor       bx,bx
;         mov       bl,cs:[LastDwn]
;         inc       bl
;         sub       bl,cs:[FirstDwn]
;         cmp       bx,cs:[NumDwn]
;         jbe       OutZNak2                 ; buffer je ji‘ pln˜
         mov       bl,al                    ; po‘adovan˜ znak
         shl       bx,1                     ; offset v tabulce font–
         add       bx,cs:[TabFont]          ; aktu ln¡ tabulka font–
         cmp       word ptr cs:[bx],0       ; dˆl  se DownLoad znaku ?
         jne       OutZnak3                 ; dˆl  se DownLoad znaku

; ------ vysl n¡ znaku bˆ‘n˜m zp–sobem

OutZnak2:call      DownOff                  ; vypnut¡ re‘imu DownLoad
         jc        OutZnak9                 ; chyba v˜stupu na tisk rnu
         call      WritByte                 ; vysl n¡ znaku na tisk rnu
         jmp       short OutZnak9

; ------ vysl n¡ znaku jako DownLoad

OutZnak3:call      DefDown                  ; definice znaku DownLoad
         jc        OutZnak9                 ; chyba v˜stupu na tisk rnu
         mov       al,ah                    ; ekvivalent znaku
         call      DownOn                   ; zapnut¡ re‘imu DownLoad
         jc        OutZnak9                 ; chyba v˜stupu na tisk rnu
         call      WritByte                 ; vysl n¡ ekvivalentu znaku

; ------ n vrat registr–

OutZnak9:mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
         ret

OutZnak  ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn‚ zapnut¡ tisk rny do re‘imu DownLoad
; -----------------------------------------------------------------------------
; VSTUP:CY=chyba v˜stupu na tisk rnu
;        AH=stavov˜ bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

DownOn   PROC      NEAR

         push      si
         test      word ptr cs:[Param0],bit8; je zn m˜ stav DownLoad ?
         jz        DownOn2                  ; stav DownLoad nen¡ zn m˜
         test      word ptr cs:[Param],bit8 ; je zapnut re‘im DownLoad ?
         jnz       DownOn3                  ; re‘im DownLoad je ji‘ zapnut
DownOn2: mov       si,offset KSetDwn        ; k¢d pro zapnut¡ DownLoad
         call      WritTxt                  ; zapnut¡ re‘imu DownLoad
         jc        DownOn3                  ; chyba v˜stupu na tisk rnu
         or        word ptr cs:[Param0],bit8; p©¡znak zn mosti stavu DownLoad
         or        word ptr cs:[Param],bit8 ; p©¡znak stavu DownLoad
DownOn3: pop       si
         ret

DownOn   ENDP

; -----------------------------------------------------------------------------
;        podm¡nˆn‚ vypnut¡ tisk rny z re‘imu DownLoad
; -----------------------------------------------------------------------------
; VSTUP:CY=chyba v˜stupu na tisk rnu
;        AH=stavov˜ bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

DownOff  PROC      NEAR

         push      si
         test      word ptr cs:[Param0],bit8; je zn m˜ stav DownLoad ?
         jz        DownOff2                 ; stav DownLoad nen¡ zn m˜
         test      word ptr cs:[Param],bit8 ; je zapnut re‘im DownLoad ?
         jz        DownOff3                 ; re‘im DownLoad je ji‘ vypnut
DownOff2:mov       si,offset KResDwn        ; k¢d pro vypnut¡ DownLoad
         call      WritTxt                  ; zapnut¡ re‘imu DownLoad
         jc        DownOff3                 ; chyba v˜stupu na tisk rnu
         or        word ptr cs:[Param0],bit8; p©¡znak zn mosti stavu DownLoad
         and       word ptr cs:[Param],not bit8 ; p©¡znak vyp. stavu DownLoad
DownOff3:pop       si
         ret

DownOff  ENDP

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

         mov       byte ptr cs:[KInitNLQ],0
         mov       byte ptr cs:[KInitNL2],0
         mov       word ptr cs:[TabFont],offset KamDraft
         test      word ptr cs:[Param],bit10
         jz        Konv1
         mov       byte ptr cs:[KInitNLQ],1
         mov       byte ptr cs:[KInitNL2],1
         mov       word ptr cs:[TabFont],offset KamNLQ
Konv1:

; ------ zaji¨tˆn¡ zn mosti tabulky DownLoad

         test      word ptr cs:[Param0],bit9 ; je zn m  tabulka DownLoad ?
         jnz       Konvert1                 ; tabulka je zn m 

         mov       word ptr cs:[NumDwn],0   ; nulov n¡ tabulky DownLoad
         mov       word ptr cs:[OutNum],0
         mov       word ptr cs:[EscNum],0
         or        word ptr cs:[Param0],bit9 ; p©¡znak zn mosti tabulky DownLoad

         call      DownOff
         jc        Konver88
         push      si
         mov       si,offset KInit
         call      WritTxt
         pop       si


         push      bx
         push      ax
         push      cx
         push      si

         mov       cl,cs:[LastDwn]          ; posledn¡ znak DownLoad
         inc       cl
         sub       cl,cs:[FirstDwn]         ; po‡et znak– DownLoad
         xor       ch,ch
         mov       si,offset KamInit
         cmp       cx,offset(KamInit0-KamInit)
         jbe       Konv2
         mov       cx,offset(KamInit0-KamInit)

Konv2:   mov       al,cs:[si]
         inc       si
         xor       bx,bx
         mov       bl,al
         shl       bx,1
         add       bx,cs:[TabFont]          ; tabulka indexu fontu
         cmp       word ptr cs:[bx],0       ; m  znak DownLoad ?
         je        Konv4                    ; nem  DownLoad
         call      DefDown                  ; definice znaku DownLoad
         jc        Konv5                    ; chyba
Konv4:   loop      Konv2                    ; definice dal¨¡ho znaku

Konv5:   pop       si
         pop       cx
         mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
Konver88:jc        Konvert8                 ; chyba

Konvert1:

; ------ je platn˜ znak (nen¡ sou‡ st ESC posloupnosti)

         cmp       word ptr cs:[EscNum],0   ; je nˆco v ESC bufferu ?
         jne       Konvert4                 ; je nˆco v bufferu
         cmp       al,27                    ; je ESC ?
         je        Konvert2                 ; je ESC znak
         call      OutZnak                  ; vysl n¡ znaku s podm¡nˆn˜m DownLd
         jmp       short Konvert8

; ------ je prvn¡ ESC

Konvert2:call      StorEsc                  ; ulo‘en¡ do ESC bufferu
Konvert3:call      DownOff
         jc        Konvert8
         call      WritByte                 ; ulo‘en¡ bez dek¢dov n¡
         jmp       short Konvert8

; ------ je druh˜ znak ESC

Konvert4:cmp       word ptr cs:[EscNum],1   ; je to 2. znak ESC posloupnosti ?
         jne       Konvert5                 ; nen¡ to 2. znak
         cmp       al,"x"                   ; nastaven¡ kvality ?
         je        Konvert2
         jmp       short Konvert6

; ------ p©epnut¡ re‘imu DRAFT/NLQ

Konvert5:or        word ptr cs:[Param0],bit10 ; stav NLQ je zn m˜
         and       word ptr cs:[Param0],not bit9 ; tabulka DownLoad nedefinovan 
         and       word ptr cs:[Param],not bit10 ; p©¡znak DRAFT
         test      al,1                     ; je vy¨¨¡ kvalita p¡sma ?
         jz        Konvert6                 ; je DRAFT
         or        word ptr cs:[Param],bit10
Konvert6:call      WritByte
Konvert7:mov       word ptr cs:[EscNum],0   ; zru¨en¡ dat v ESC bufferu
Konvert8:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ znaku do ESC bufferu
; -----------------------------------------------------------------------------

StorESC  PROC      NEAR

         push      bx
         mov       bx,cs:[EscNum]           ; po‡et bajt– v ESC bufferu
         mov       cs:[bx+EscBuff],al       ; ulo‘en¡ znaku do ESC bufferu
         inc       word ptr cs:[EscNum]     ; zv˜¨en¡ ‡¡ta‡e dat
         pop       bx
         ret

StorESC  ENDP


; *****************************************************************************
;
;                   Tabulky ©¡dic¡ch k¢d–
;
; *****************************************************************************

KamInit  db        'ˆ¨‡©Ÿ‘'
KamInit0 label     byte

KInit    db        14,27,'T',1,27,'R',0,27,'6',27,'x'
KInitNLQ db        1,27,'U'
KInitNL2 db        1

KSetDwn  db        3,27,'%1'               ; zapnut¡ DownLoad
KResDwn  db        3,27,'%0'               ; vypnut¡ DownLoad
KDefDwn  db        5,27,'&',0,33,33         ; definice DownLoad

; *****************************************************************************
;
;                         Tabulka font– DRAFT
;
; *****************************************************************************

; Symboly: V=velk‚, M=mal‚, H=h ‡ek, C=‡ rka, D=dvojte‡ka, S=st©¡¨ka, K=krou‘ek


; ------ tabulka index– - Kamenick˜ch DRAFT

KamDraft label     word
         dw        105 dup(0)

         dw        0;DrftI                    ; 105 i

         dw        111-106 dup(0)

         dw        0;DrftO                    ; 111 o

         dw        128-112 dup(0)

         dw        DrftCVH                  ; 128 €
         dw        0;DrftUMD                  ; 129 
         dw        0;DrftEMC                  ; 130 ‚
         dw        DrftDMH                  ; 131 ƒ
         dw        0;DrftAMD                  ; 132 „
         dw        DrftDVH                  ; 133 …
         dw        DrftTVH                  ; 134 †
         dw        DrftCMH                  ; 135 ‡
         dw        DrftEMH                  ; 136 ˆ
         dw        DrftEVH                  ; 137 ‰
         dw        DrftLVC                  ; 138 Š
         dw        DrftIVC                  ; 139 ‹
         dw        DrftLMH                  ; 140 Œ
         dw        DrftLMC                  ; 141 
         dw        0;DrftAVD                  ; 142 Ž
         dw        DrftAVC                  ; 143 
         dw        0;DrftEVC                  ; 144 
         dw        DrftZMH                  ; 145 ‘
         dw        DrftZVH                  ; 146 ’
         dw        0;DrftOMS                  ; 147 “
         dw        0;DrftOMD                  ; 148 ”
         dw        DrftOVC                  ; 149 •
         dw        DrftUMK                  ; 150 –
         dw        DrftUVC                  ; 151 —
         dw        DrftYMC                  ; 152 ˜
         dw        0;DrftOVD                  ; 153 ™
         dw        0;DrftUVD                  ; 154 š
         dw        DrftUVH                  ; 155 ›
         dw        DrftLVH                  ; 156 œ
         dw        DrftYVC                  ; 157 
         dw        DrftRVH                  ; 158 ž
         dw        DrftTMH                  ; 159 Ÿ
         dw        0;DrftAMC                  ; 160  
         dw        0;DrftIMC                  ; 161 ¡
         dw        0;DrftOMC                  ; 162 ¢
         dw        0;DrftUMC                  ; 163 £
         dw        DrftNMH                  ; 164 ¤
         dw        DrftNVH                  ; 165 ¥
         dw        DrftUVK                  ; 166 ¦
         dw        DrftOVS                  ; 167 §
         dw        DrftSMH                  ; 168 ¨
         dw        DrftRMH                  ; 169 ©
         dw        DrftRMC                  ; 170 ª
         dw        DrftRVC                  ; 171 «
         dw        DrftXX1                  ; 172 ¬
         dw        DrftXX2                  ; 173 ­
         dw        0;DrftXX3                  ; 174 ®
         dw        0;DrftXX4                  ; 175 ¯
         dw        0;DrftG01                  ; 176 °
         dw        0;DrftG02                  ; 177 ±
         dw        0;DrftG03                  ; 178 ²
         dw        0;DrftG04                  ; 179 ³
         dw        0;DrftG05                  ; 180 ´
         dw        0;DrftG06                  ; 181 µ
         dw        0;DrftG07                  ; 182 ¶
         dw        0;DrftG08                  ; 183 ·
         dw        0;DrftG09                  ; 184 ¸
         dw        0;DrftG10                  ; 185 ¹
         dw        0;DrftG11                  ; 186 º
         dw        0;DrftG12                  ; 187 »
         dw        0;DrftG13                  ; 188 ¼
         dw        0;DrftG14                  ; 189 ½
         dw        0;DrftG15                  ; 190 ¾
         dw        0;DrftG16                  ; 191 ¿
         dw        0;DrftG17                  ; 192 À
         dw        0;DrftG18                  ; 193 Á
         dw        0;DrftG19                  ; 194 Â
         dw        0;DrftG20                  ; 195 Ã
         dw        0;DrftG21                  ; 196 Ä
         dw        0;DrftG22                  ; 197 Å
         dw        0;DrftG23                  ; 198 Æ
         dw        0;DrftG24                  ; 199 Ç
         dw        0;DrftG25                  ; 200 È
         dw        0;DrftG26                  ; 201 É
         dw        0;DrftG27                  ; 202 Ê
         dw        0;DrftG28                  ; 203 Ë
         dw        0;DrftG29                  ; 204 Ì
         dw        0;DrftG30                  ; 205 Í
         dw        0;DrftG31                  ; 206 Î
         dw        0;DrftG32                  ; 207 Ï
         dw        0;DrftG33                  ; 208 Ð
         dw        0;DrftG34                  ; 209 Ñ
         dw        0;DrftG35                  ; 210 Ò
         dw        0;DrftG36                  ; 211 Ó
         dw        0;DrftG37                  ; 212 Ô
         dw        0;DrftG38                  ; 213 Õ
         dw        0;DrftG39                  ; 214 Ö
         dw        0;DrftG40                  ; 215 ×
         dw        0;DrftG41                  ; 216 Ø
         dw        0;DrftG42                  ; 217 Ù
         dw        0;DrftG43                  ; 218 Ú
         dw        0;DrftG44                  ; 219 Û
         dw        0;DrftG45                  ; 220 Ü
         dw        0;DrftG46                  ; 221 Ý
         dw        0;DrftG47                  ; 222 Þ
         dw        0;DrftG48                  ; 223 ß
         dw        0;DrftR01                  ; 224 à
         dw        0;DrftR02                  ; 225 á
         dw        0;DrftR03                  ; 226 â
         dw        0;DrftR04                  ; 227 ã
         dw        0;DrftR05                  ; 228 ä
         dw        0;DrftR06                  ; 229 å
         dw        0;DrftR07                  ; 230 æ
         dw        0;DrftR08                  ; 231 ç
         dw        0;DrftR09                  ; 232 è
         dw        0;DrftR10                  ; 233 é
         dw        0;DrftR11                  ; 234 ê
         dw        0;DrftR12                  ; 235 ë
         dw        0;DrftR13                  ; 236 ì
         dw        0;DrftR14                  ; 237 í
         dw        0;DrftR15                  ; 238 î
         dw        0;DrftR16                  ; 239 ï
         dw        0;DrftR17                  ; 240 ð
         dw        0;DrftR18                  ; 241 ñ
         dw        0;DrftR19                  ; 242 ò
         dw        0;DrftR20                  ; 243 ó
         dw        0;DrftR21                  ; 244 ô
         dw        0;DrftR22                  ; 245 õ
         dw        0;DrftR23                  ; 246 ö
         dw        0;DrftR24                  ; 247 ÷
         dw        0;DrftR25                  ; 248 ø
         dw        0;DrftR26                  ; 249 ù
         dw        0;DrftR27                  ; 250 ú
         dw        0;DrftR28                  ; 251 û
         dw        0;DrftR29                  ; 252 ü
         dw        0;DrftR30                  ; 253 ý
         dw        0;DrftR31                  ; 254 þ
         dw        0;DrftR32                  ; 255

; ------ tabulka index– - Latin 2 DRAFT

LatDraft label     word
         dw        256 dup(0)

; ------ tabulka index– - KOI 8 DRAFT

KoiDraft label     word
         dw        256 dup(0)

; ------ definice fontu DRAFT
;þ
FontDrft label     byte

DrftI    db        12,bit7+27h                                       ; 105 i
         db        00000000b
         db        00000000b
         db        00100010b
         db        00000000b
         db        10111110b
         db        00000000b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftO    db        12,bit7+09h                                       ; 111 o
         db        00011100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00011100b
         db        00000000b
         db        00000000b

DrftCVH  db        12,bit7+09h                                       ; 128 €
         db        00111100b
         db        01000010b
         db        10000000b
         db        01000010b
         db        00000000b
         db        01000010b
         db        10000000b
         db        01000010b
         db        00100100b
         db        00000000b
         db        00000000b

DrftUMD  db        12,bit7+1ah                                       ; 129 
         db        00000000b
         db        00111100b
         db        10000010b
         db        00000000b
         db        00000010b
         db        00000000b
         db        00000010b
         db        10000000b
         db        00111100b
         db        00000010b
         db        00000000b

DrftEMC  db        12,bit7+09h                                       ; 130 ‚
         db        00011100b
         db        00100010b
         db        00001000b
         db        00100010b
         db        01001000b
         db        00100010b
         db        10001000b
         db        00100010b
         db        00011000b
         db        00000000b
         db        00000000b

DrftDMH  db        12,bit7+0bh                                       ; 131 ƒ
         db        00001000b
         db        00010100b
         db        00000000b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00000000b
         db        01111110b
         db        10000000b
         db        00100000b
         db        11000000b

DrftAMD  db        12,bit7+09h                                       ; 132 „
         db        00000100b
         db        00001010b
         db        10100000b
         db        00001010b
         db        00100000b
         db        00001010b
         db        10100000b
         db        00011100b
         db        00000010b
         db        00000000b
         db        00000000b

DrftDVH  db        12,bit7+09h                                       ; 133 …
         db        01000010b
         db        00000000b
         db        11111110b
         db        00000000b
         db        01000010b
         db        00000000b
         db        11000010b
         db        00100100b
         db        00011000b
         db        00000000b
         db        00000000b

DrftTVH  db        12,bit7+09h                                       ; 134 †
         db        01000000b
         db        00000000b
         db        11000000b
         db        00000000b
         db        01111110b
         db        00000000b
         db        11000000b
         db        00000000b
         db        01000000b
         db        00000000b
         db        00000000b

DrftCMH  db        12,bit7+19h                                       ; 135 ‡
         db        00000000b
         db        00011100b
         db        00100010b
         db        10000000b
         db        00100010b
         db        01000000b
         db        00100010b
         db        10000000b
         db        00100010b
         db        00000000b
         db        00000000b

DrftEMH  db        12,bit7+09h                                       ; 136 ˆ
         db        00011100b
         db        00100010b
         db        10001000b
         db        00100010b
         db        01001000b
         db        00100010b
         db        10001000b
         db        00100010b
         db        00011000b
         db        00000000b
         db        00000000b

DrftEVH  db        12,bit7+09h                                       ; 137 ‰
         db        01111110b
         db        00000000b
         db        11010010b
         db        00000000b
         db        01010010b
         db        00000000b
         db        11010010b
         db        00000000b
         db        01000010b
         db        00000000b
         db        00000000b

DrftLVC  db        12,bit7+09h                                       ; 138 Š
         db        11111110b
         db        00000000b
         db        00000010b
         db        00100000b
         db        01000010b
         db        10000000b
         db        00000010b
         db        00000000b
         db        00000010b
         db        00000000b
         db        00000000b

DrftIVC  db        12,bit7+27h                                       ; 139 ‹
         db        00000000b
         db        00000000b
         db        01000010b
         db        00000000b
         db        11111110b
         db        00000000b
         db        11000010b
         db        00000000b
         db        10000000b
         db        00000000b
         db        00000000b

DrftLMH  db        12,bit7+2bh                                       ; 140 Œ
         db        00000000b
         db        00000000b
         db        10000010b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00000010b
         db        10000000b
         db        01000000b
         db        00000000b
         db        10000000b

DrftLMC  db        12,bit7+28h                                       ; 141 
         db        00000000b
         db        00000000b
         db        10000010b
         db        00000000b
         db        11111110b
         db        00000000b
         db        00100010b
         db        11000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftAVD  db        12,bit7+09h                                       ; 142 Ž
         db        00001110b
         db        10010000b
         db        00101000b
         db        01000000b
         db        00001000b
         db        01000000b
         db        00101000b
         db        10010000b
         db        00001110b
         db        00000000b
         db        00000000b

DrftAVC  db        12,bit7+09h                                       ; 143 
         db        00001110b
         db        00010000b
         db        00101000b
         db        01000000b
         db        00001000b
         db        01000000b
         db        00101000b
         db        01010000b
         db        10001110b
         db        00000000b
         db        00000000b

DrftEVC  db        12,bit7+09h                                       ; 144 
         db        01111110b
         db        00000000b
         db        01010010b
         db        10000000b
         db        01010010b
         db        10000000b
         db        01010010b
         db        10000000b
         db        01000010b
         db        00000000b
         db        00000000b

DrftZMH  db        12,bit7+18h                                       ; 145 ‘
         db        00000000b
         db        00100010b
         db        10000100b
         db        00100010b
         db        01001000b
         db        00100010b
         db        10010000b
         db        00100010b
         db        00000000b
         db        00000000b
         db        00000000b

DrftZVH  db        12,bit7+09h                                       ; 146 ’
         db        01000010b
         db        00000100b
         db        11000010b
         db        00001000b
         db        01000010b
         db        00010000b
         db        11000010b
         db        00100000b
         db        01000010b
         db        00000000b
         db        00000000b

DrftOMS  db        12,bit7+09h                                       ; 147 “
         db        00011100b
         db        10100010b
         db        00000000b
         db        10100010b
         db        00000000b
         db        10100010b
         db        00000000b
         db        10100010b
         db        00011100b
         db        00000000b
         db        00000000b

DrftOMD  db        12,bit7+09h                                       ; 148 ”
         db        00011100b
         db        00100010b
         db        10000000b
         db        00100010b
         db        00000000b
         db        00100010b
         db        10000000b
         db        00100010b
         db        00011100b
         db        00000000b
         db        00000000b

DrftOVC  db        12,bit7+09h                                       ; 149 •
         db        00111100b
         db        01000010b
         db        00000000b
         db        11000010b
         db        00000000b
         db        11000010b
         db        00000000b
         db        11000010b
         db        00111000b
         db        00000000b
         db        00000000b

DrftUMK  db        12,bit7+1ah                                       ; 150 –
         db        00111100b
         db        00000000b
         db        00000010b
         db        01000000b
         db        10100010b
         db        01000000b
         db        00000010b
         db        00000000b
         db        00111100b
         db        00000010b
         db        00000000b

DrftUVC  db        12,bit7+09h                                       ; 151 —
         db        01111100b
         db        00000010b
         db        00000000b
         db        00000010b
         db        01000000b
         db        10000010b
         db        00000000b
         db        00000010b
         db        01111100b
         db        00000000b
         db        00000000b

DrftYMC  db        12,09h                                            ; 152 ˜
         db        01000000b
         db        00100000b
         db        00010001b
         db        00001010b
         db        01000100b
         db        10001000b
         db        00010000b
         db        00100000b
         db        01000000b
         db        00000000b
         db        00000000b

DrftOVD  db        12,bit7+09h                                       ; 153 ™
         db        00111100b
         db        01000010b
         db        10000000b
         db        01000010b
         db        00000000b
         db        01000010b
         db        10000000b
         db        01000010b
         db        00111100b
         db        00000000b
         db        00000000b

DrftUVD  db        12,bit7+09h                                       ; 154 š
         db        01111100b
         db        00000010b
         db        10000000b
         db        00000010b
         db        00000000b
         db        00000010b
         db        10000000b
         db        00000010b
         db        01111100b
         db        00000000b
         db        00000000b

DrftUVH  db        12,bit7+09h                                       ; 155 ›
         db        00100100b
         db        01010010b
         db        10000000b
         db        01010010b
         db        00000000b
         db        01001010b
         db        10000000b
         db        01001010b
         db        00100100b
         db        00000000b
         db        00000000b

DrftLVH  db        12,bit7+0ah                                       ; 156 œ
         db        11111110b
         db        00000000b
         db        00000010b
         db        10000000b
         db        00000010b
         db        01000000b
         db        00000010b
         db        10000000b
         db        00000010b
         db        00000000b
         db        00000000b

DrftYVC  db        12,bit7+09h                                       ; 157 
         db        10000000b
         db        01000000b
         db        00100000b
         db        00010000b
         db        01001110b
         db        10010000b
         db        00100000b
         db        01000000b
         db        10000000b
         db        00000000b
         db        00000000b

DrftRVH  db        12,bit7+09h                                       ; 158 ž
         db        01111110b
         db        00000000b
         db        11001000b
         db        00000000b
         db        01001000b
         db        00000000b
         db        11001000b
         db        00000100b
         db        00110010b
         db        00000000b
         db        00000000b

DrftTMH  db        12,bit7+1ah                                       ; 159 Ÿ
         db        00000000b
         db        00100000b
         db        00000000b
         db        11111100b
         db        00000010b
         db        00100000b
         db        10000010b
         db        00000100b
         db        01000000b
         db        10000000b
         db        00000000b

DrftAMC  db        12,bit7+09h                                       ; 160  
         db        00000100b
         db        00001010b
         db        00100000b
         db        00001010b
         db        01100000b
         db        00001010b
         db        10100000b
         db        00011100b
         db        00000010b
         db        00000000b
         db        00000000b

DrftIMC  db        12,bit7+28h                                       ; 161 ¡
         db        00000000b
         db        00000000b
         db        00100010b
         db        00000000b
         db        00111110b
         db        01000000b
         db        00000010b
         db        10000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftOMC  db        12,bit7+09h                                       ; 162 ¢
         db        00011100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        01000000b
         db        00100010b
         db        10000000b
         db        00100010b
         db        00011100b
         db        00000000b
         db        00000000b

DrftUMC  db        12,bit7+1ah                                       ; 163 £
         db        00000000b
         db        00111100b
         db        00000010b
         db        00000000b
         db        01000010b
         db        00000000b
         db        10000010b
         db        00000000b
         db        00111100b
         db        00000010b
         db        00000000b

DrftNMH  db        12,bit7+09h                                       ; 164 ¤
         db        00100000b
         db        00011110b
         db        10000000b
         db        00100000b
         db        01000000b
         db        00100000b
         db        10000000b
         db        00100000b
         db        00011110b
         db        00000000b
         db        00000000b

DrftNVH  db        12,bit7+09h                                       ; 165 ¥
         db        01111110b
         db        00000000b
         db        10100000b
         db        00010000b
         db        01000000b
         db        00001000b
         db        10000100b
         db        00000000b
         db        01111110b
         db        00000000b
         db        00000000b

DrftUVK  db        12,bit7+09h                                       ; 166 ¦
         db        01111100b
         db        00000010b
         db        00000000b
         db        01000010b
         db        10100000b
         db        01000010b
         db        00000000b
         db        00000010b
         db        01111100b
         db        00000000b
         db        00000000b

DrftOVS  db        12,bit7+09h                                       ; 167 §
         db        10111100b
         db        01000010b
         db        10000000b
         db        01000010b
         db        10000000b
         db        01000010b
         db        10000000b
         db        01000010b
         db        10111100b
         db        00000000b
         db        00000000b

DrftSMH  db        12,bit7+09h                                       ; 168 ¨
         db        00010000b
         db        00101010b
         db        10000000b
         db        00101010b
         db        01000000b
         db        00101010b
         db        10000000b
         db        00101010b
         db        00000100b
         db        00000000b
         db        00000000b

DrftRMH  db        12,bit7+09h                                       ; 169 ©
         db        00000000b
         db        00111110b
         db        10000000b
         db        00010000b
         db        01000000b
         db        00100000b
         db        10000000b
         db        00100000b
         db        00010000b
         db        00000000b
         db        00000000b

DrftRMC  db        12,bit7+09h                                       ; 170 ª
         db        00000000b
         db        00111110b
         db        00000000b
         db        00010000b
         db        01000000b
         db        00100000b
         db        10000000b
         db        00100000b
         db        00010000b
         db        00000000b
         db        00000000b

DrftRVC  db        12,bit7+09h                                       ; 171 «
         db        01111110b
         db        00000000b
         db        01001000b
         db        00000000b
         db        11001000b
         db        00000000b
         db        11001000b
         db        00000100b
         db        10110010b
         db        00000000b
         db        00000000b

DrftXX1  db        12,bit7+0ah                                       ; 172 ¬
         db        11110000b
         db        00000100b
         db        00001000b
         db        00010000b
         db        00100000b
         db        01000110b
         db        10001000b
         db        00000010b
         db        00011101b
         db        00000010b
         db        00000000b

DrftXX2  db        12,bit7+29h                                       ; 173 ­
         db        00000000b
         db        00000000b
         db        01011000b
         db        10100101b
         db        00000000b
         db        10100101b
         db        00000000b
         db        10100101b
         db        00011010b
         db        00000000b
         db        00000000b

DrftXX3  db        12,bit7+19h                                       ; 174 ®
         db        00000000b
         db        00010000b
         db        00101000b
         db        01000100b
         db        10000010b
         db        00010000b
         db        00101000b
         db        01000100b
         db        10000010b
         db        00000000b
         db        00000000b

DrftXX4  db        12,bit7+19h                                       ; 175 ¯
         db        00000000b
         db        10000010b
         db        01000100b
         db        00101000b
         db        00010000b
         db        10000010b
         db        01000100b
         db        00101000b
         db        00010000b
         db        00000000b
         db        00000000b

DrftG01  db        12,bit7+0bh                                       ; 176 °
         db        10101010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        10101010b
         db        00000000b
         db        00000000b
         db        00000000b
         db        10101010b
         db        00000000b
         db        00000000b

DrftG02  db        12,bit7+0bh                                       ; 177 ±
         db        10101010b
         db        00000000b
         db        01010101b
         db        00000000b
         db        10101010b
         db        00000000b
         db        01010101b
         db        00000000b
         db        10101010b
         db        00000000b
         db        01010101b

DrftG03  db        12,bit7+0bh                                       ; 178 ²
         db        10101010b
         db        01010101b
         db        00000000b
         db        10101010b
         db        01010101b
         db        00000000b
         db        10101010b
         db        01010101b
         db        00000000b
         db        10101010b
         db        01010101b

DrftG04  db        12,bit7+45h                                       ; 179 ³
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG05  db        12,bit7+05h                                       ; 180 ´
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG06  db        12,bit7+05h                                       ; 181 µ
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG07  db        12,bit7+07h                                       ; 182 ¶
         db        00001000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG08  db        12,07h                                            ; 183 ·
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG09  db        12,05h                                            ; 184 ¸
         db        00101000b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG10  db        12,bit7+07h                                       ; 185 ¹
         db        00010100b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG11  db        12,bit7+27h                                       ; 186 º
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG12  db        12,07h                                            ; 187 »
         db        00101000b
         db        00000000b
         db        00101111b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG13  db        12,bit7+07h                                       ; 188 ¼
         db        00010100b
         db        00000000b
         db        11110100b
         db        00000000b
         db        00000100b
         db        00000000b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG14  db        12,bit7+07h                                       ; 189 ½
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG15  db        12,bit7+05h                                       ; 190 ¾
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        11111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG16  db        12,05h                                            ; 191 ¿
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG17  db        12,bit7+4bh                                       ; 192 À
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG18  db        12,bit7+0bh                                       ; 193 Á
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG19  db        12,0bh                                            ; 194 Â
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b

DrftG20  db        12,bit7+4bh                                       ; 195 Ã
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG21  db        12,bit7+0bh                                       ; 196 Ä
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG22  db        12,bit7+0bh                                       ; 197 Å
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG23  db        12,bit7+4bh                                       ; 198 Æ
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG24  db        12,bit7+2bh                                       ; 199 Ç
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG25  db        12,bit7+2bh                                       ; 200 È
         db        00000000b
         db        00000000b
         db        11111100b
         db        00000000b
         db        00000100b
         db        00000000b
         db        11110100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG26  db        12,2bh                                            ; 201 É
         db        00000000b
         db        00000000b
         db        00111111b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00101111b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b

DrftG27  db        12,bit7+0bh                                       ; 202 Ê
         db        00010100b
         db        00000000b
         db        11110100b
         db        00000000b
         db        00000100b
         db        00000000b
         db        11110100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG28  db        12,0bh                                            ; 203 Ë
         db        00101000b
         db        00000000b
         db        00101111b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00101111b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b

DrftG29  db        12,bit7+2bh                                       ; 204 Ì
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11110111b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG30  db        12,bit7+0bh                                       ; 205 Í
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG31  db        12,bit7+09h                                       ; 206 Î
         db        00010100b
         db        00000000b
         db        11110111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11110111b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG32  db        12,bit7+0bh                                       ; 207 Ï
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        11110100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG33  db        12,bit7+0bh                                       ; 208 Ð
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG34  db        12,0bh                                            ; 209 Ñ
         db        00101000b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101111b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b

DrftG35  db        12,0bh                                            ; 210 Ò
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b

DrftG36  db        12,bit7+2bh                                       ; 211 Ó
         db        00000000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG37  db        12,bit7+4bh                                       ; 212 Ô
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG38  db        12,4bh                                            ; 213 Õ
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00111111b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b
         db        00000000b
         db        00101000b

DrftG39  db        12,2bh                                            ; 214 Ö
         db        00000000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b

DrftG40  db        12,bit7+0bh                                       ; 215 ×
         db        00001000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00001000b
         db        00000000b
         db        00001000b

DrftG41  db        12,bit7+0bh                                       ; 216 Ø
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b
         db        00000000b
         db        00010100b

DrftG42  db        12,bit7+05h                                       ; 217 Ù
         db        00001000b
         db        00000000b
         db        00001000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG43  db        12,4bh                                            ; 218 Ú
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011111b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b

DrftG44  db        12,bit7+0bh                                       ; 219 Û
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b

DrftG45  db        12,bit7+0bh                                       ; 220 Ü
         db        00000111b
         db        00000000b
         db        00000111b
         db        00000000b
         db        00000111b
         db        00000000b
         db        00000111b
         db        00000000b
         db        00000111b
         db        00000000b
         db        00000111b

DrftG46  db        12,bit7+05h                                       ; 221 Ý
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftG47  db        12,bit7+6bh                                       ; 222 Þ
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b
         db        00000000b
         db        11111111b

DrftG48  db        12,bit7+0bh                                       ; 223 ß
         db        11111000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        11111000b
         db        00000000b
         db        11111000b

DrftR01  db        12,bit7+09h                                       ; 224 à
         db        00011100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00010100b
         db        00001000b
         db        00010100b
         db        00100010b
         db        00000100b
         db        00000000b
         db        00000000b

DrftR02  db        12,bit7+19h                                       ; 225 á
         db        00000000b
         db        00111111b
         db        01000000b
         db        00000000b
         db        10000000b
         db        00010010b
         db        10000000b
         db        01101010b
         db        00000100b
         db        00000000b
         db        00000000b

DrftR03  db        12,bit7+09h                                       ; 226 â
         db        10000000b
         db        01111110b
         db        10000000b
         db        00000000b
         db        10000000b
         db        00000000b
         db        10000000b
         db        00000000b
         db        11000000b
         db        00000000b
         db        00000000b

DrftR04  db        12,bit7+09h                                       ; 227 ã
         db        00100000b
         db        00000000b
         db        00111110b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00111110b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00000000b

DrftR05  db        12,bit7+09h                                       ; 228 ä
         db        10000010b
         db        01000100b
         db        10000010b
         db        00101000b
         db        10000010b
         db        00010000b
         db        10000010b
         db        00000000b
         db        11000110b
         db        00000000b
         db        00000000b

DrftR06  db        12,bit7+09h                                       ; 229 å
         db        00011100b
         db        00000010b
         db        00100000b
         db        00000010b
         db        00100000b
         db        00011100b
         db        00100000b
         db        00000000b
         db        00100000b
         db        00000000b
         db        00000000b

DrftR07  db        12,09h                                            ; 230 æ
         db        00000011b
         db        01111100b
         db        00000000b
         db        00000100b
         db        00000000b
         db        00000100b
         db        00000000b
         db        01111000b
         db        00000100b
         db        00000000b
         db        00000000b

DrftR08  db        12,bit7+09h                                       ; 231 ç
         db        00010000b
         db        00100000b
         db        00000000b
         db        00100000b
         db        00011100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        01000100b
         db        00000000b
         db        00000000b

DrftR09  db        12,bit7+09h                                       ; 232 è
         db        00011000b
         db        10100101b
         db        00000000b
         db        10100101b
         db        01011010b
         db        10100101b
         db        00000000b
         db        10100101b
         db        00011000b
         db        00000000b
         db        00000000b

DrftR10  db        12,bit7+09h                                       ; 233 é
         db        00111000b
         db        01000100b
         db        00000000b
         db        10010010b
         db        00000000b
         db        10010010b
         db        00000000b
         db        01000100b
         db        00111000b
         db        00000000b
         db        00000000b

DrftR11  db        12,bit7+09h                                       ; 234 ê
         db        00110010b
         db        01001000b
         db        00000110b
         db        10000000b
         db        00000000b
         db        10000000b
         db        00000110b
         db        01001000b
         db        00110010b
         db        00000000b
         db        00000000b

DrftR12  db        12,bit7+0ah                                       ; 235 ë
         db        00001100b
         db        00010010b
         db        00000000b
         db        01010010b
         db        10100000b
         db        00010010b
         db        10001100b
         db        00000000b
         db        10000000b
         db        01000000b
         db        00000000b

DrftR13  db        12,bit7+0bh                                       ; 236 ì
         db        00011100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00010100b
         db        00001000b
         db        00010100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        00011100b

DrftR14  db        12,bit7+0bh                                       ; 237 í
         db        00011101b
         db        00100010b
         db        00000100b
         db        00100010b
         db        00011100b
         db        00000000b
         db        00011100b
         db        00100010b
         db        00010000b
         db        00100010b
         db        01011100b

DrftR15  db        12,bit7+18h                                       ; 238 î
         db        00000000b
         db        00111000b
         db        00000000b
         db        01010100b
         db        00000000b
         db        10010010b
         db        00000000b
         db        10010010b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR16  db        12,bit7+09h                                       ; 239 ï
         db        00111110b
         db        01000000b
         db        00000000b
         db        10000000b
         db        00000000b
         db        10000000b
         db        00000000b
         db        01000000b
         db        00111110b
         db        00000000b
         db        00000000b

DrftR17  db        12,bit7+09h                                       ; 240 ð
         db        00101010b
         db        00000000b
         db        00101010b
         db        00000000b
         db        00101010b
         db        00000000b
         db        00101010b
         db        00000000b
         db        00101010b
         db        00000000b
         db        00000000b

DrftR18  db        12,bit7+09h                                       ; 241 ñ
         db        00010001b
         db        00000000b
         db        00010001b
         db        00000000b
         db        01111101b
         db        00000000b
         db        00010001b
         db        00000000b
         db        00010001b
         db        00000000b
         db        00000000b

DrftR19  db        12,bit7+18h                                       ; 242 ò
         db        00000000b
         db        00000010b
         db        10001000b
         db        00000010b
         db        01010000b
         db        00000010b
         db        00100000b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR20  db        12,bit7+18h                                       ; 243 ó
         db        00000000b
         db        00000010b
         db        00100000b
         db        00000010b
         db        01010000b
         db        00000010b
         db        10001000b
         db        00000010b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR21  db        12,49h                                            ; 244 ô
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        01111111b
         db        10000000b
         db        00000000b
         db        10000000b
         db        01100000b
         db        00000000b
         db        00000000b

DrftR22  db        12,bit7+05h                                       ; 245 õ
         db        00000110b
         db        00000001b
         db        00000000b
         db        00000001b
         db        11111110b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR23  db        12,bit7+09h                                       ; 246 ö
         db        00010000b
         db        00000000b
         db        00010000b
         db        11000110b
         db        00010000b
         db        11000110b
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00000000b

DrftR24  db        12,bit7+09h                                       ; 247 ÷
         db        01000100b
         db        10001000b
         db        00000000b
         db        10001000b
         db        01000100b
         db        00100010b
         db        00000000b
         db        00100010b
         db        01000100b
         db        00000000b
         db        00000000b

DrftR25  db        12,bit7+27h                                       ; 248 ø
         db        00000000b
         db        00000000b
         db        01100000b
         db        10010000b
         db        00000000b
         db        10010000b
         db        01100000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR26  db        12,bit7+36h                                       ; 249 ù
         db        00000000b
         db        00000000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00011000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR27  db        12,bit7+36h                                       ; 250 ú
         db        00000000b
         db        00000000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00010000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR28  db        12,bit7+0bh                                       ; 251 û
         db        00001000b
         db        00000100b
         db        00000010b
         db        00000001b
         db        00000010b
         db        00000100b
         db        00001000b
         db        00010000b
         db        00100000b
         db        01000000b
         db        10000000b

DrftR29  db        12,bit7+28h                                       ; 252 ü
         db        00000000b
         db        00000000b
         db        11110000b
         db        00000000b
         db        10000000b
         db        00000000b
         db        10000000b
         db        01110000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR30  db        12,bit7+27h                                       ; 253 ý
         db        00000000b
         db        00000000b
         db        01001000b
         db        10010000b
         db        00001000b
         db        10100000b
         db        01001000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR31  db        12,bit7+27h                                       ; 254 þ
         db        00000000b
         db        00000000b
         db        00111100b
         db        00000000b
         db        00111100b
         db        00000000b
         db        00111100b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

DrftR32  db        12,bit7+45h                                       ; 255
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b
         db        00000000b

; *****************************************************************************
;
;                          Tabulka font– NLQ
;
; *****************************************************************************

; ------ tabulka index– - Kamenick˜ch NLQ
;þ
KamNLQ   label     word
         dw        128 dup(0)

         dw        NlqCVH                                            ; 128 €
         dw        0;NlqUMD                                            ; 129 
         dw        0;NlqEMC                                            ; 130 ‚
         dw        NlqDMH                                            ; 131 ƒ
         dw        0;NlqAMD                                            ; 132 „
         dw        NlqDVH                                            ; 133 …
         dw        NlqTVH                                            ; 134 †
         dw        NlqCMH                                            ; 135 ‡
         dw        NlqEMH                                            ; 136 ˆ
         dw        NlqEVH                                            ; 137 ‰
         dw        NlqLVC                                            ; 138 Š
         dw        NlqIVC                                            ; 139 ‹
         dw        NlqLMH                                            ; 140 Œ
         dw        NlqLMC                                            ; 141 
         dw        0;NlqAVD                                            ; 142 Ž
         dw        NlqAVC                                            ; 143 
         dw        0;NlqEVC                                            ; 144 
         dw        NlqZMH                                            ; 145 ‘
         dw        NlqZVH                                            ; 146 ’
         dw        0;NlqOMS                                            ; 147 “
         dw        0;NlqOMD                                            ; 148 ”
         dw        NlqOVC                                            ; 149 •
         dw        NlqUMK                                            ; 150 –
         dw        NlqUVC                                            ; 151 —
         dw        NlqYMC                                            ; 152 ˜
         dw        0;NlqOVD                                            ; 153 ™
         dw        0;NlqUVD                                            ; 154 š
         dw        NlqSVH                                            ; 155 ›
         dw        NlqLVH                                            ; 156 œ
         dw        NlqYVC                                            ; 157 
         dw        NlqRVH                                            ; 158 ž
         dw        NlqTMH                                            ; 159 Ÿ
         dw        0;NlqAMC                                            ; 160  
         dw        0;NlqIMC                                            ; 161 ¡
         dw        0;NlqOMC                                            ; 162 ¢
         dw        0;NlqUMC                                            ; 163 £
         dw        NlqNMH                                            ; 164 ¤
         dw        NlqNVH                                            ; 165 ¥
         dw        NlqUVK                                            ; 166 ¦
         dw        NlqOVS                                            ; 167 §
         dw        NlqSMH                                            ; 168 ¨
         dw        NlqRMH                                            ; 169 ©
         dw        NlqRMC                                            ; 170 ª
         dw        NlqRVC                                            ; 171 «
         dw        NlqXX1                                            ; 172 ¬
         dw        NlqXX2                                            ; 173 ­
         dw        0;NlqXX3                                            ; 174 ®
         dw        0;NlqXX4                                            ; 175 ¯
         dw        0;NlqG01                                            ; 176 °
         dw        0;NlqG02                                            ; 177 ±
         dw        0;NlqG03                                            ; 178 ²
         dw        0;NlqG04                                            ; 179 ³
         dw        0;NlqG05                                            ; 180 ´
         dw        0;NlqG06                                            ; 181 µ
         dw        0;NlqG07                                            ; 182 ¶
         dw        0;NlqG08                                            ; 183 ·
         dw        0;NlqG09                                            ; 184 ¸
         dw        0;NlqG10                                            ; 185 ¹
         dw        0;NlqG11                                            ; 186 º
         dw        0;NlqG12                                            ; 187 »
         dw        0;NlqG13                                            ; 188 ¼
         dw        0;NlqG14                                            ; 189 ½
         dw        0;NlqG15                                            ; 190 ¾
         dw        0;NlqG16                                            ; 191 ¿
         dw        0;NlqG17                                            ; 192 À
         dw        0;NlqG18                                            ; 193 Á
         dw        0;NlqG19                                            ; 194 Â
         dw        0;NlqG20                                            ; 195 Ã
         dw        0;NlqG21                                            ; 196 Ä
         dw        0;NlqG22                                            ; 197 Å
         dw        0;NlqG23                                            ; 198 Æ
         dw        0;NlqG24                                            ; 199 Ç
         dw        0;NlqG25                                            ; 200 È
         dw        0;NlqG26                                            ; 201 É
         dw        0;NlqG27                                            ; 202 Ê
         dw        0;NlqG28                                            ; 203 Ë
         dw        0;NlqG29                                            ; 204 Ì
         dw        0;NlqG30                                            ; 205 Í
         dw        0;NlqG31                                            ; 206 Î
         dw        0;NlqG32                                            ; 207 Ï
         dw        0;NlqG33                                            ; 208 Ð
         dw        0;NlqG34                                            ; 209 Ñ
         dw        0;NlqG35                                            ; 210 Ò
         dw        0;NlqG36                                            ; 211 Ó
         dw        0;NlqG37                                            ; 212 Ô
         dw        0;NlqG38                                            ; 213 Õ
         dw        0;NlqG39                                            ; 214 Ö
         dw        0;NlqG40                                            ; 215 ×
         dw        0;NlqG41                                            ; 216 Ø
         dw        0;NlqG42                                            ; 217 Ù
         dw        0;NlqG43                                            ; 218 Ú
         dw        0;NlqG44                                            ; 219 Û
         dw        0;NlqG45                                            ; 220 Ü
         dw        0;NlqG46                                            ; 221 Ý
         dw        0;NlqG47                                            ; 222 Þ
         dw        0;NlqG48                                            ; 223 ß
         dw        0;NlqG49                                            ; 224 à

         dw        128 dup(0)

; ------ tabulka index– - Latin 2 NLQ

LatNLQ   label     word
         dw        256 dup(0)

; ------ tabulka index– - KOI 8 NLQ

KoiNLQ   label     word
         dw        256 dup(0)

; ------ definice fontu NLQ

FontNLQ  label     byte
;þ

NlqCVH   db        30,1,9,2                                          ; 128 €
         db        00000111b,11100000b,00000000b
         db        00001000b,00010000b,00000000b
         db        10010000b,00001000b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10010000b,00000100b,00000000b
         db        00001000b,00001000b,00000000b
         db        00111100b,00010000b,00000000b

NlqUMD   db        30,1,9,2                                          ; 129 
         db        00001000b,00000000b,00000000b
         db        01001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        01001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b

NlqEMC   db        30,1,9,2                                          ; 130 ‚
         db        00000011b,11110000b,00000000b
         db        00000100b,10001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00000100b,10001000b,00000000b
         db        00000011b,10000000b,00000000b

NlqDMH   db        39,0,12,0                                         ; 131 ƒ
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        10000100b,00000100b,00000000b
         db        10000010b,00001000b,00000000b
         db        11111111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b
         db        11110000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b

NlqAMD   db        30,1,9,2                                          ; 132 „
         db        00000000b,00110000b,00000000b
         db        01000100b,01001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        01000100b,10001000b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqDVH   db        30,1,9,2                                          ; 133 …
         db        00100000b,00000100b,00000000b
         db        10111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00010000b,00001000b,00000000b
         db        00001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqTVH   db        30,1,9,2                                          ; 134 †
         db        00111000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        10100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00100000b,00000000b,00000000b
         db        00111000b,00000000b,00000000b

NlqCMH   db        30,1,9,2                                          ; 135 ‡
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        10001000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00001100b,00001000b,00000000b
         db        00001110b,00010000b,00000000b

NlqEMH   db        30,1,9,2                                          ; 136 ˆ
         db        00000001b,11100000b,00000000b
         db        00000110b,10011000b,00000000b
         db        10001000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00000110b,10001000b,00000000b
         db        00000011b,10000000b,00000000b

NlqEVH   db        30,1,9,2                                          ; 137 ‰
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100011b,10000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00111000b,00011100b,00000000b

NlqLVC   db        30,1,9,2                                          ; 138 Š
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00011000b,00000100b,00000000b
         db        11100000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b

NlqIVC   db        21,3,6,3                                          ; 139 ‹
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        01111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10000000b,00000000b,00000000b

NlqLMH   db        24,3,7,2                                          ; 140 Œ
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        00000000b,00000100b,00000000b
         db        11110000b,00000100b,00000000b
         db        00100000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b

NlqLMC   db        24,3,7,2                                          ; 141 
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00011000b,00000000b,00000000b
         db        11100000b,00000000b,00000000b

NlqAVD   db        36,0,11,1                                         ; 142 Ž
         db        00000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b
         db        10000000b,11100100b,00000000b
         db        00000111b,10000100b,00000000b
         db        00111000b,10000000b,00000000b
         db        11000000b,10000000b,00000000b
         db        00111000b,10000000b,00000000b
         db        00000111b,10000100b,00000000b
         db        10000000b,11100100b,00000000b
         db        00000000b,00011100b,00000000b
         db        00000000b,00000100b,00000000b

NlqAVC   db        36,0,11,1                                         ; 143 
         db        00000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b
         db        00000000b,11100100b,00000000b
         db        00000111b,10000100b,00000000b
         db        00111000b,10000000b,00000000b
         db        11000000b,10000000b,00000000b
         db        00111000b,10000000b,00000000b
         db        00000111b,10000100b,00000000b
         db        00100000b,11100100b,00000000b
         db        01000000b,00011100b,00000000b
         db        10000000b,00000100b,00000000b

NlqEVC   db        30,1,9,2                                          ; 144 
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100001b,00000100b,00000000b
         db        00100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100011b,10000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00111000b,00011100b,00000000b

NlqZMH   db        27,1,8,3                                          ; 145 ‘
         db        00001110b,00001100b,00000000b
         db        10001000b,00010100b,00000000b
         db        01001000b,00100100b,00000000b
         db        00101000b,01000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001001b,00000100b,00000000b
         db        00001010b,00000100b,00000000b
         db        00001100b,00011100b,00000000b

NlqZVH   db        27,1,8,3                                          ; 146 ’
         db        00111100b,00011100b,00000000b
         db        10100000b,00100100b,00000000b
         db        01100000b,01000100b,00000000b
         db        01100000b,10000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        10100010b,00000100b,00000000b
         db        00100100b,00000100b,00000000b
         db        00111000b,00111100b,00000000b

NlqOMS   db        30,1,9,2                                          ; 147 “
         db        00000011b,11110000b,00000000b
         db        00100100b,00001000b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00100100b,00001000b,00000000b
         db        00000011b,11110000b,00000000b

NlqOMD   db        30,1,9,2                                          ; 148 ”
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        10001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00000100b,00001000b,00000000b
         db        00000011b,11110000b,00000000b

NlqOVC   db        30,1,9,2                                          ; 149 •
         db        00000111b,11100000b,00000000b
         db        00001000b,00010000b,00000000b
         db        00010000b,00001000b,00000000b
         db        00100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10010000b,00001000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqUMK   db        30,1,9,2                                          ; 150 –
         db        00001000b,00000000b,00000000b
         db        00001111b,11110000b,00000000b
         db        01000000b,00001000b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b

NlqUVC   db        33,1,10,1                                         ; 151 —
         db        01000000b,00000000b,00000000b
         db        01111111b,11100000b,00000000b
         db        01000000b,00010000b,00000000b
         db        00000000b,00001000b,00000000b
         db        00100000b,00000100b,00000000b
         db        01000000b,00000100b,00000000b
         db        10000000b,00001000b,00000000b
         db        00000000b,00010000b,00000000b
         db        01111111b,11100000b,00000000b
         db        01000000b,00000000b,00000000b

NlqYMC   db        36,0,11,1                                         ; 152 ˜
         db        00001000b,00000000b,00000000b
         db        00001110b,00000000b,01000000b
         db        00001001b,10000000b,01000000b
         db        00001000b,01100000b,11000000b
         db        00000000b,00011011b,01000000b
         db        00100000b,00001100b,00000000b
         db        01000000b,00011000b,00000000b
         db        10001000b,01100000b,00000000b
         db        00001001b,10000000b,00000000b
         db        00001110b,00000000b,00000000b
         db        00001000b,00000000b,00000000b

NlqOVD   db        30,1,9,2                                          ; 153 ™
         db        00000111b,11100000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00010000b,00001000b,00000000b
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00010000b,00001000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqUVD   db        33,1,10,1                                         ; 154 š
         db        00100000b,00000000b,00000000b
         db        00111111b,11110000b,00000000b
         db        00100000b,00001000b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00100000b,00001000b,00000000b
         db        00111111b,11110000b,00000000b
         db        00100000b,00000000b,00000000b

NlqSVH   db        30,1,9,2                                          ; 155 ›
         db        00001110b,00011100b,00000000b
         db        00010001b,00001000b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        10100001b,00000100b,00000000b
         db        00010001b,00001000b,00000000b
         db        00111000b,11110000b,00000000b

NlqLVH   db        30,1,9,2                                          ; 156 œ
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        11110000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        11000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b

NlqYVC   db        36,0,11,1                                         ; 157 
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01110000b,00000000b,00000000b
         db        00001100b,00000000b,00000000b
         db        00100011b,00000100b,00000000b
         db        01000000b,11111100b,00000000b
         db        10000011b,00000100b,00000000b
         db        00001100b,00000000b,00000000b
         db        01110000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b
         db        01000000b,00000000b,00000000b

NlqRVH   db        30,1,9,2                                          ; 158 ž
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,10000000b,00000000b
         db        01100001b,01000000b,00000000b
         db        01100001b,00100000b,00000000b
         db        10100001b,00010000b,00000000b
         db        00010010b,00001100b,00000000b
         db        00001100b,00000100b,00000000b

NlqTMH   db        30,1,9,2                                          ; 159 Ÿ
         db        00001000b,00000000b,00000000b
         db        01111111b,11110000b,00000000b
         db        00001000b,00001000b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        11101000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        11000000b,00001000b,00000000b
         db        00000000b,00000000b,00000000b

NlqAMC   db        30,1,9,2                                          ; 160  
         db        00000000b,00110000b,00000000b
         db        00000100b,01001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00000100b,10001000b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqIMC   db        30,1,9,2                                          ; 161 ¡
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00101111b,11111100b,00000000b
         db        01000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000000b,00000000b
         db        00000000b,00000000b,00000000b

NlqOMC   db        30,1,9,2                                          ; 162 ¢
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00000100b,00001000b,00000000b
         db        00000011b,11110000b,00000000b

NlqUMC   db        30,1,9,2                                          ; 163 £
         db        00001000b,00000000b,00000000b
         db        00001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b

NlqNMH   db        30,1,9,2                                          ; 164 ¤
         db        00001000b,00000100b,00000000b
         db        00001111b,11111100b,00000000b
         db        10000100b,00000100b,00000000b
         db        01001000b,00000000b,00000000b
         db        00101000b,00000000b,00000000b
         db        01001000b,00000000b,00000000b
         db        10000100b,00000100b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqNVH   db        30,1,9,2                                          ; 165 ¥
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10011000b,00000100b,00000000b
         db        01000110b,00000000b,00000000b
         db        01000001b,10000000b,00000000b
         db        10000000b,01100000b,00000000b
         db        00100000b,00011000b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100000b,00000000b,00000000b

NlqUVK   db        33,1,10,1                                         ; 166 ¦
         db        00100000b,00000000b,00000000b
         db        00111111b,11110000b,00000000b
         db        00000000b,00001000b,00000000b
         db        01000000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        01000000b,00000100b,00000000b
         db        00000000b,00001000b,00000000b
         db        00111111b,11110000b,00000000b
         db        00100000b,00000000b,00000000b

NlqOVS   db        30,1,9,2                                          ; 167 §
         db        00000111b,11100000b,00000000b
         db        01001000b,00010000b,00000000b
         db        10010000b,00001000b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10010000b,00001000b,00000000b
         db        01001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqSMH   db        27,1,8,3                                          ; 168 ¨
         db        00000011b,00010000b,00000000b
         db        10000100b,10001000b,00000000b
         db        01001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,01000100b,00000000b
         db        10001000b,01000100b,00000000b
         db        00000100b,01001000b,00000000b
         db        00000000b,00110000b,00000000b

NlqRMH   db        30,1,9,2                                          ; 169 ©
         db        00001000b,00000100b,00000000b
         db        00001111b,11111100b,00000000b
         db        10000010b,00000100b,00000000b
         db        01000100b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        00001000b,00000000b,00000000b
         db        00000100b,00000000b,00000000b

NlqRMC   db        30,1,9,2                                          ; 170 ª
         db        00001000b,00000100b,00000000b
         db        00001111b,11111100b,00000000b
         db        00000010b,00000100b,00000000b
         db        00000100b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        00001000b,00000000b,00000000b
         db        00000100b,00000000b,00000000b

NlqRVC   db        30,1,9,2                                          ; 171 «
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100001b,00000100b,00000000b
         db        00100001b,10000000b,00000000b
         db        01100001b,01000000b,00000000b
         db        01100001b,00100000b,00000000b
         db        10100001b,00010000b,00000000b
         db        10010010b,00001100b,00000000b
         db        00001100b,00000100b,00000000b

NlqXX1   db        30,1,9,2                                          ; 172 ¬
         db        01000010b,00000000b,11000000b
         db        11111110b,00000011b,00000000b
         db        00000010b,00001100b,00000000b
         db        00000000b,00110000b,00000000b
         db        00000000b,11000000b,00000000b
         db        00000011b,00011110b,00000000b
         db        00001100b,00000010b,00000000b
         db        00110000b,11111111b,10000000b
         db        11000000b,00000010b,00000000b

NlqXX2   db        24,2,7,3                                          ; 173 ­
         db        00111000b,11100000b,10000000b
         db        01000101b,00010000b,01000000b
         db        10000010b,00010000b,01000000b
         db        10000010b,00001000b,01000000b
         db        10000001b,00001000b,01000000b
         db        10000001b,00010100b,01000000b
         db        01000000b,11100011b,10000000b

NlqXX3   db        30,1,9,2                                          ; 174 ®
         db        00000000b,11000000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000110b,00011000b,00000000b
         db        00001100b,11001100b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000110b,00011000b,00000000b
         db        00001100b,00001100b,00000000b

NlqXX4   db        30,1,9,2                                          ; 175 ¯
         db        00001100b,00001100b,00000000b
         db        00000110b,00011000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00001100b,11001100b,00000000b
         db        00000110b,00011000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000000b,11000000b,00000000b

NlqG01   db        39,0,12,0                                         ; 176 °
         db        10001000b,10001000b,10001000b
         db        00000000b,00000000b,00000000b
         db        00100010b,00100010b,00100010b
         db        00000000b,00000000b,00000000b
         db        10001000b,10001000b,10001000b
         db        00000000b,00000000b,00000000b
         db        00100010b,00100010b,00100010b
         db        00000000b,00000000b,00000000b
         db        10001000b,10001000b,10001000b
         db        00000000b,00000000b,00000000b
         db        00100010b,00100010b,00100010b
         db        00000000b,00000000b,00000000b

NlqG02   db        39,0,12,0                                         ; 177 ±
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b
         db        10001000b,10001000b,10001000b
         db        00100010b,00100010b,00100010b

NlqG03   db        39,0,12,0                                         ; 178 ²
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b
         db        10101010b,10101010b,10101010b
         db        01010101b,01010101b,01010101b

NlqG04   db        6,5,1,6                                           ; 179 ³
         db        11111111b,11111111b,11111111b

NlqG05   db        21,0,6,6                                          ; 180 ´
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG06   db        21,0,6,6                                          ; 181 µ
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG07   db        24,0,7,5                                          ; 182 ¶
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG08   db        24,0,7,5                                          ; 183 ·
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b

NlqG09   db        21,0,6,6                                          ; 184 ¸
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,11111111b,11111111b

NlqG10   db        24,0,7,5                                          ; 185 ¹
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG11   db        12,4,3,5                                          ; 186 º
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG12   db        24,0,7,5                                          ; 187 »
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10000000b,00000000b
         db        00000000b,11111111b,11111111b

NlqG13   db        24,0,7,5                                          ; 188 ¼
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,00100000b,00000000b
         db        11111111b,11100000b,00000000b

NlqG14   db        24,0,7,5                                          ; 189 ½
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b

NlqG15   db        21,0,6,6                                          ; 190 ¾
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,11100000b,00000000b

NlqG16   db        21,0,6,6                                          ; 191 ¿
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b

NlqG17   db        24,5,7,0                                          ; 192 À
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG18   db        39,0,12,0                                         ; 193 Á
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG19   db        39,0,12,0                                         ; 194 Â
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG20   db        24,5,7,0                                          ; 195 Ã
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG21   db        39,0,12,0                                         ; 196 Ä
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG22   db        39,0,12,0                                         ; 197 Å
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG23   db        24,5,7,0                                          ; 198 Æ
         db        11111111b,11111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG24   db        27,4,8,0                                          ; 199 Ç
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG25   db        27,4,8,0                                          ; 200 È
         db        11111111b,11100000b,00000000b
         db        00000000b,00100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG26   db        27,4,8,0                                          ; 201 É
         db        00000000b,11111111b,11111111b
         db        00000000b,10000000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG27   db        39,0,12,0                                         ; 202 Ê
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,00100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG28   db        39,0,12,0                                         ; 203 Ë
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10000000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG29   db        27,4,8,0                                          ; 204 Ì
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG30   db        39,0,12,0                                         ; 205 Í
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG31   db        39,0,12,0                                         ; 206 Î
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG32   db        39,0,12,0                                         ; 207 Ï
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG33   db        39,0,12,0                                         ; 208 Ð
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG34   db        39,0,12,0                                         ; 209 Ñ
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG35   db        39,0,12,0                                         ; 210 Ò
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG36   db        27,4,8,0                                          ; 211 Ó
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG37   db        24,5,7,0                                          ; 212 Ô
         db        11111111b,11100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG38   db        24,5,7,0                                          ; 213 Õ
         db        00000000b,11111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG39   db        27,4,8,0                                          ; 214 Ö
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG40   db        39,0,12,0                                         ; 215 ×
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG41   db        39,0,12,0                                         ; 216 Ø
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG42   db        21,0,6,6                                          ; 217 Ù
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b

NlqG43   db        24,5,7,0                                          ; 218 Ú
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG44   db        39,0,12,0                                         ; 219 Û
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

NlqG45   db        39,0,12,0                                         ; 220 Ü
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b
         db        00000000b,01111111b,11111111b

NlqG46   db        21,0,6,6                                          ; 221 Ý
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

NlqG47   db        21,6,6,0                                          ; 222 Þ
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

NlqG48   db        39,0,12,0                                         ; 223 ß
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b
         db        11111111b,10000000b,00000000b

NlqG49   db        39,0,12,0                                         ; 224 à
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


; *****************************************************************************
;
;                         Tabulka font– LQ
;
; *****************************************************************************

; ------ tabulka index– - Kamenick˜ch LQ

KamLQ    label     word
         dw        256 dup(0)

; ------ tabulka index– - Latin 2 LQ

LatLQ    label     word
         dw        256 dup(0)

; ------ tabulka index– - KOI 8 LQ

KoiLQ    label     word
         dw        256 dup(0)

; ------ definice fontu LQ

FontLQ   label     byte



; *****************************************************************************
;
;                         start programu (instalace)
;
; *****************************************************************************

Init:
         mov       ds:[SegRez],ds           ; tento program

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ nalezen¡ parametru - ‡¡slo portu

         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; po‡et znak– textu
         cld
Init1:   jcxz      Init4                    ; nen¡ dal¨¡ znak
         lodsb
         dec       cx
         cmp       al,"/"
         jne       Init1
         jcxz      Init2
         lodsb
         dec       cx
         cmp       al,"!"
         jne       Init2
         mov       byte ptr ds:[OdIns],1    ; p©¡znak po‘adavku odinstalov n¡
         jmp       short Init1

Init2:   sub       al,"1"
         jb        Init1
         cmp       al,4
         ja        Init1
         mov       byte ptr ds:[PortLPT],al ; ‡¡slo portu
         jmp       short Init1

; ------ ozna‡en¡ ‡¡sla portu do text–

Init4:   mov       al,byte ptr ds:[PortLPT] ; instalovan˜ port
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[InstTxt0],al         ; ‡¡slo portu LPT
         mov       ds:[DeInsTx0],al
         mov       ds:[DInsTxt0],al
         mov       ds:[InstDTx0],al

; ------ test stavu instalace programu CSPRINT

         mov       di,offset Ident          ; identifika‡n¡ text
         mov       dx,ds:[PortLPT]          ; port LPT
         mov       ah,2                     ; funkce dotazu na stav
         int       17h                      ; dotaz na stav - test instalace

; ------ p©¡padn‚ odinstalov n¡ programu

         cmp       byte ptr ds:[OdIns],0    ; po‘aduje se odinstalov n¡ ?
         je        Init5                    ; nepo‘aduje se odinstalov n¡
         jmp       OdInst                   ; odinstalov n¡ programu

; ------ nen¡-li program nainstalov n, jeho nainstalov n¡

Init5:   mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init6
         jmp       Instal                   ; prvn¡ instalace programu

Init6:   int       20h

; -----------------------------------------------------------------------------
;        test, zda se po‘aduje odinstalov n¡
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu (DS=CS)
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

; ------ kontrola, zda byl program nainstalov n

         mov       dx,offset InstDTxt       ; hl ¨en¡ - nebyl dosud nainstalov n
         mov       ax,ds                    ; tento segment
         cmp       ax,ds:[SegRez]           ; byl nainstalov n ?
         je        OdInst8                  ; program nebyl nainstalov n

; ------ kontrola INT 08h

         mov       dx,offset DInsTxt        ; hl ¨en¡ - nelze odinstalovat
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         cmp       bx,offset INT08
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ kontrola INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut¡ adresy INT 17h
         cmp       bx,offset INT17
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ kontrola INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut¡ adresy INT 28h
         cmp       bx,offset INT28
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

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

OdInst8: mov       ah,9
         int       21h                      ; zobrazen¡ textu chybov‚ho hl ¨en¡
         int       20h

OdInst   ENDP

; -----------------------------------------------------------------------------
;        instalace programu (DS=CS)
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

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

; ------ hl ¨en¡ o instalaci

         mov       dx,offset InstTxt        ; hl ¨en¡ o instalaci
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡ o instalaci

; ------ instalace programu

         mov       dx,ds:[DelkaRez]         ; d‚lka rezidentn¡ ‡ sti
         int       27h                      ; instalace programu

Instal   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

OdIns    db        0                        ; p©¡znak po‘adavku odinstalov n¡

DelkaRez dw        offset Init              ; konec rezidentn¡ ‡ sti

UvTxt    db        'LX400 V1.0 - ovladac tiskarny LX400; (c) Miroslav Nemecek'
         db        13,10,'$'

InstTxt  db        'LX400 byl nainstalovan pro LPT '
InstTxt0 db        '1.',13,10,'$'

DeInsTxt db        'LX400 byl odinstalovan z portu LPT '
DeInsTx0 db        '1.',13,10,'$'

DInsTxt  db        'LX400 nelze odinstalovat z portu LPT '
DInsTxt0 db        '1 !',13,10,'$'

InstDTxt db        'LX400 nebyl dosud pro port LPT '
InstDTx0 db        '1 nainstalovan !',13,10,'$'

Code     ENDS
         END       Start

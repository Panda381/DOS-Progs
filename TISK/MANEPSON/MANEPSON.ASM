
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               CSPRINT
;               program pro tisk áe®tiny na tisk†rnu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

; -----------------------------------------------------------------------------
;        p©ep°naáe funkce programu
; -----------------------------------------------------------------------------

TimeOut  EQU       10*18                   ; max. povolen† prodleva vòstupu

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
;                         data rezidentn° á†sti
;
; *****************************************************************************

; ------ identifikace programu v pamàti

Ident    db        'MANEPSON V1.0'
Ident0   label     byte
SegRez   dw        0                        ; segment rezidentn° á†sti

; ------ pñvodn° adresy obsluh p©eru®en°

Old08    dd        0                        ; pñvodn° adresa INT 08h
Old17    dd        0                        ; pñvodn° adresa INT 17h
Old28    dd        0                        ; pñvodn° adresa INT 28h

; ------ stav tisku, konfigurace

PortLPT  dw        0                        ; á°slo portu LPT
Param0   dw        0                        ; parametry - stav zn†mosti
                                            ;   bit 8: 1=stav DownLoad zn†mò
                                            ;   bit 9: 1=tabulka DownLoad zn†m†
                                            ;   bit 10: 1=stav NLQ zn†mò
Param    dw        0                        ; parametry
                                            ;   bit 8: 1=p©epnuto na DownLoad
                                            ;   bit 10: 1=je stav NLQ

; ------ á°taá áasu

CitOut   dw        0                        ; á°taá áasu od posledn°ho vòstupu

; ------ buffer pro uchov†n° ESC sekvenc°

EscNum   dw        0                        ; poáet znakñ v ESC bufferu
EscBuff  db        10 dup(0)                ; buffer ESC sekvenc°

; ------ vòstupn° buffer

OutMax   EQU       120                      ; velikost vòstupn°ho bufferu
OutNum   dw        0                        ; poáet znakñ ve vòstupn°m bufferu
OutBuff  db        OutMax dup(0)            ; vòstupn° buffer

; ------ definice pro DownLoad

MaxDwn   EQU       220                      ; velikost bufferu DownLoad
FirstDwn db        33                       ; prvn° znak pro DownLoad
LastDwn  db        88                       ; posledn° znak pro DownLoad

NumDwn   dw        0                        ; poáet nadefinovanòch znakñ DwnL
         EVEN
BuffDwn  dw        MaxDwn dup(0)            ; buffer definic znakñ DownLoad
                                            ;  1.bajt - definovanò znak
                                            ;  2.bajt - ekvivalent znaku

TabFont  dw        offset KamNLQ            ; aktu†ln° tabulka indexu fontñ


; *****************************************************************************
;
;                  obsluha komunikace s tisk†rnou
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

Int08    PROC      FAR

; ------ zvò®en° á°taáe vòstupu

         pushf
         cmp       word ptr cs:[CitOut],0ffffh ; p©eteáen° ?
         je        Int081                   ; p©eteáen° á°taáe
         inc       word ptr cs:[CitOut]     ; zvò®en° á°taáe doby
         cmp       word ptr cs:[CitOut],TimeOut ; je TIME-OUT vòstupu ?
         jne       Int081                   ; nen° TIME-OUT vòstupu

; ------ obsluha TIME-OUT vòstupu

         mov       word ptr cs:[Param0],0   ; p©°znak, ëe stav nen° zn†mò

Int081:  popf

; ------ pokraáov†n° v pñvodn° obsluze

         jmp       dword ptr cs:[Old08]     ; pñvodn° obsluha INT 08h

Int08    ENDP


;Lad:     pushf
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      ds
;         push      es
;
;         mov       ah,0eh
;         mov       bx,7
;         int       10h
;
;         pop       es
;         pop       ds
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         popf
;         ret

; -----------------------------------------------------------------------------
;        obsluha INT 28h
; -----------------------------------------------------------------------------

Int28    PROC      FAR

         call      OutByte                  ; màkk† obsluha vòstupu na tisk†rnu
         jmp       dword ptr cs:[Old28]     ; pñvodn° obsluha INT 28h

Int28    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 17h
; -----------------------------------------------------------------------------


Int17    PROC      FAR

; ------ kontrola, zda je obsluhovan† tisk†rna

         cmp       dx,cs:[PortLPT]          ; je to obsluhovan† tisk†rna ?
         jne       Int179                   ; nen° to obsluhovan† tisk†rna

; ------ obsluha funkce 0 - vysl†n° bajtu na tisk†rnu

         or        ah,ah                    ; vysl†n° znaku na tisk†rnu ?
         jnz       Int175                   ; nen° vysl†n° znaku na tisk†rnu

         call      Vystup                   ; vypr†zdnàn° vòstupn°ho bufferu
         jc        Int177                   ; chyba vòstupu (AH=stavovò bajt)
         call      Konvert                  ; dek¢dov†n° bajtu AL
         jc        Int177                   ; chyba vòstupu (AH=stavovò bajt)
         mov       ah,2                     ; funkce - dotaz na stav tisk†rny
         jmp       short Int176             ; dotaz na stav tisk†rny

; ------ obsluha funkce 2 - dotaz na stav tisk†rny

Int175:  cmp       ah,2                     ; je dotaz na stav tisk†rny ?
         jne       Int178                   ; nen° dotaz na stav tisk†rny
         call      TestInst                 ; test instalace programu
Int176:  call      OutByte                  ; màkk† obsluha vòstupu na tisk†rnu
         call      Int17I                   ; poskytnut° stavu tisk†rny
         cmp       word ptr cs:[OutNum],0   ; v bufferu nàjakò znak ?
         je        Int177                   ; v bufferu nen° p©ipraven znak
         and       ah,not 80h               ; p©°znak zanepr†zdnàn° tisk†rny
Int177:  iret                               ; n†vrat z obsluhy p©eru®en°

; ------ obsluha funkce 1 - inicializace tisk†rny

Int178:  cmp       ah,1                     ; inicializace tisk†rny ?
         jne       Int179                   ; nezn†m† funkce - pokraáuje
         call      InitDrv                  ; inicializace ovladaáe tisk†rny

; ------ pñvodn° obsluha tisk†rny

Int179:  call      OutByte                  ; obsluha vòstupu na tisk†rnu
         jmp       dword ptr cs:[Old17]     ; pñvodn° obsluha INT 17h

Int17    ENDP

; -----------------------------------------------------------------------------
;        test instalace programu (ES:DI=adresa identifikaán°ho textu)
; -----------------------------------------------------------------------------

TestInst PROC      NEAR

         cmp       di,offset Ident          ; adresa identifikaán°ho textu
         jne       TestIns5                 ; nen° dotaz na instalaci

; ------ £schova registrñ

         push      si
         push      di
         push      cx
         push      ds

; ------ porovn†n° textñ

         push      cs
         pop       ds                       ; DS <- CS
         mov       si,di                    ; adresa identifikaán°ho textu
         mov       cx,offset(Ident0-Ident)  ; dÇlka textu
         cld                                ; smàr nahoru
         repe      cmpsb                    ; porovn†n° textñ
         jne       TestIns2                 ; nen° shoda textñ
         mov       es:[SegRez],cs           ; rezidentn° segment

; ------ n†vrat registrñ

TestIns2:pop       ds
         pop       cx
         pop       di
         pop       si
TestIns5:ret

TestInst ENDP

; -----------------------------------------------------------------------------
;        vol†n° pñvodn° obsluhy INT 17h
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
         call      dword ptr cs:[Old17]     ; pñvodn° obsluha INT 17h

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
;              vysl†n° vòstupn°ho bufferu na tisk†rnu
; -----------------------------------------------------------------------------
; VùSTUP: NC=operace OK
;         CY=chyba TIME-OUT, AH=stavovò bajt tisk†rny
;         (ostatn° registry uchov†v† !)
; -----------------------------------------------------------------------------

Vystup   PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax

; ------ test, zda jsou nàjak† data k vòstupu

Vystup1: cmp       word ptr cs:[OutNum],0   ; je nàco v bufferu ?
         je        Vystup9                  ; nen° nic v bufferu

; ------ vysl†n° bajtu na tisk†rnu

         mov       al,cs:[OutBuff]          ; znak p©ipravenò k vòstupu
         xor       ah,ah                    ; funkce vòstupu na tisk†rnu
         call      Int17I                   ; vysl†n° znaku na tisk†rnu
         test      ah,1                     ; byla chyba TIME-OUT ?
         stc
         jnz       Vystup9                  ; byla chyba TIME-OUT

; ------ znak vysl†n OK

         call      ClrByte                  ; vypu®tàn° znaku z bufferu
         jmp       short Vystup1            ; vysl†n° dal®°ho znaku

; ------ n†vrat registrñ

Vystup9: mov       bh,ah                    ; £schova AH
         pop       ax
         mov       ah,bh                    ; n†vratovò k¢d AH
         pop       bx
         ret

Vystup   ENDP


; -----------------------------------------------------------------------------
;        inicializace ovladaáe tisk†rny
; -----------------------------------------------------------------------------

InitDrv  PROC      NEAR

         mov       word ptr cs:[OutNum],0   ; zru®en° dat ve vòstupn°m bufferu
         mov       word ptr cs:[EscNum],0   ; zru®en° dat v Esc bufferu
         mov       word ptr cs:[CitOut],-1  ; maxim†ln° doba od vòstupu
         mov       word ptr cs:[Param0],0   ; p©°znak, ëe stav nen° zn†mò
         mov       word ptr cs:[NumDwn],0   ; nulov†n° tabulky DownLoad
         ret

InitDrv  ENDP

; -----------------------------------------------------------------------------
;        z†pis bajtu AL do vòstupn°ho bufferu
; -----------------------------------------------------------------------------
; VùSTUP: CY=chyba vòstupu (AH=stavovò bajt tisk†rny)
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      bx
         mov       bx,cs:[OutNum]           ; poáet znakñ ve vòstupn°m bufferu
         cmp       bx,OutMax                ; je buffer plnò ?
         jb        WritByt1                 ; buffer nen° plnò
         call      Vystup                   ; vysl†n° bufferu na tisk†rnu
         jc        WritByt2                 ; chyba vòstupu na tisk†rnu
         xor       bx,bx                    ; BX <- 0 nen° nic v bufferu
WritByt1:mov       cs:[OutBuff+bx],al       ; bajt do vòstupn°ho bufferu
         inc       word ptr cs:[OutNum]     ; zvò®en° á°taáe dat
         clc                                ; p©°znak operace OK
WritByt2:pop       bx
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z†pis textu CS:SI do bufferu (1. bajt = dÇlka textu)
; -----------------------------------------------------------------------------
; VSTUP: CS:SI=adresa textu k vysl†n°
; VùSTUP:CY=chyba vòstupu
;        AH=stavovò bajt (pokud je chyba CY)
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
         call      WritByte                 ; z†pis znaku do bufferu
         jc        WritTxt2                 ; chyba vòstupu na tisk†rnu
         loop      WritTxt1

WritTxt2:pop       si
         mov       ch,ah
         pop       ax
         mov       ah,ch
         pop       cx
         ret

WritTxt  ENDP

; -----------------------------------------------------------------------------
;     vypu®tàn° bajtu z vòstupn°ho bufferu (nekontroluje se, zda tam nàco je)
; -----------------------------------------------------------------------------

ClrByte  PROC      NEAR

; ------ £schova registrñ

         pushf
         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         cld
         push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,offset OutBuff
         mov       si,offset OutBuff+1
         dec       word ptr ds:[OutNum]     ; sn°ëen° poátu dat v bufferu
         mov       cx,ds:[OutNum]           ; poáet bajtñ v bufferu

; ------ vypu®tàn° bajtu z bufferu

         rep       movsb                    ; vypu®tàn° dat z bufferu
         mov       word ptr ds:[CitOut],0   ; nulov†n° á°taáe áasu TIME-OUT

; ------ n†vrat registrñ

ClrByte9:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         popf
         ret

ClrByte  ENDP

; -----------------------------------------------------------------------------
;        màkkò vòstup bajtu na tisk†rnu
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

; ------ £schova registrñ

         pushf
         push      ax

; ------ test, zda je nàjakò bajt k vòstupu

OutByte1:cmp       word ptr cs:[OutNum],0   ; je nàco ve vòstupn°m bufferu ?
         je        OutByte9                 ; nen° nic ve vòstupn°m bufferu

; ------ test, zda je tisk†rna p©ipravena

         mov       ah,2
         call      Int17I                   ; dotaz na stav tisk†rny
         test      ah,80h                   ; je tisk†rna p©ipravena ?
         jz        OutByte9                 ; tisk†rna nen° p©ipravena

; ------ vysl†n° znaku na tisk†rnu

         mov       al,cs:[OutBuff]          ; znak k vysl†n°
         xor       ah,ah                    ; funkce vysl†n° bajtu na tisk†rnu
         call      Int17I                   ; vysl†n° znaku na tisk†rnu
         test      ah,1                     ; je chyba TIME-OUT ?
         jnz       OutByte9                 ; p©eteáen° TIME-OUT vòstupu

; ------ vypu®tàn° znaku z bufferu

         call      ClrByte                  ; vypu®tàn° bajtu z bufferu
         jmp       short OutByte1           ; vysl†n° dal®°ho znaku

; ------ n†vrat registrñ

OutByte9:pop       ax
         popf
         ret

OutByte  ENDP

; *****************************************************************************
;
;                       Obsluha DownLoad tisk†rny
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;                    nalezen° znaku v tabulce DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VùSTUP:SI=adresa definice znaku (NC)
;        CY=znak v tabulce nenalezen
; -----------------------------------------------------------------------------

SrcDown  PROC      NEAR

         push      cx
         mov       si,offset BuffDwn        ; buffer definic znakñ DownLoad
         mov       cx,cs:[NumDwn]           ; poáet definovanòch znakñ
         jcxz      SrcDown3                 ; nen° nic nadefinov†no
SrcDown1:cmp       byte ptr cs:[si],al      ; je to hledanò znak ?
         je        SrcDown4                 ; znak nalezen OK
         inc       si
         inc       si
         loop      SrcDown1                 ; test dal®°ho znaku
SrcDown3:stc                                ; chyba
SrcDown4:pop       cx
         ret

SrcDown  ENDP

; -----------------------------------------------------------------------------
;                    vypu®tàn° znaku z bufferu DownLoad
; -----------------------------------------------------------------------------
; VSTUP: SI=adresa vypou®tànÇho znaku
; -----------------------------------------------------------------------------

DelDown  PROC      NEAR

; ------ £schova registrñ

         push      cx
         push      si
         push      di
         push      ds
         push      es

; ------ p©°prava registrñ

         push      cs
         pop       ds
         push      cs
         pop       es
         mov       di,si                    ; adresa znaku
         inc       si
         inc       si                       ; adresa zbytku
         mov       cx,ds:[NumDwn]           ; poáet definovanòch znakñ
         jcxz      DelDown4
         shl       cx,1                     ; dÇlka tabulky
         add       cx,offset BuffDwn        ; konec tabulky definice
         sub       cx,si                    ; dÇlka zbytku tabulky k p©°sunu
         jb        DelDown4

; ------ p©°sun zbytku dat

         cld                                ; smàr nahoru
         shr       cx,1                     ; dÇlka zbytku ve slovech
         rep       movsw                    ; p©°sun zbytku tabulky

; ------ sn°ëen° poátu znakñ v tabulce

DelDown3:dec       word ptr ds:[NumDwn]     ; sn°ëen° poátu znakñ

; ------ n†vrat registrñ

DelDown4:pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         ret

DelDown  ENDP

; -----------------------------------------------------------------------------
;                nalezen° ekvivalentu v tabulce
; -----------------------------------------------------------------------------
; VSTUP: AH=ekvivalent znaku
; VùSTUP:SI=adresa definice znaku (NC)
;        CY=znak v tabulce nenalezen
; -----------------------------------------------------------------------------

SrcEkvi  PROC      NEAR

         push      cx
         mov       si,offset BuffDwn        ; buffer definic znakñ DownLoad
         mov       cx,cs:[NumDwn]           ; poáet definovanòch znakñ
         jcxz      SrcEkvi3                 ; nen° nic nadefinov†no
SrcEkvi1:cmp       byte ptr cs:[si+1],ah    ; je to hledanò ekvivalent ?
         je        SrcEkvi4                 ; znak nalezen OK
         inc       si
         inc       si
         loop      SrcEkvi1                 ; test dal®°ho znaku
SrcEkvi3:stc                                ; chyba
SrcEkvi4:pop       cx
         ret

SrcEkvi  ENDP

; -----------------------------------------------------------------------------
;                  uloëen° novÇ definice znaku na konec tabulky
; -----------------------------------------------------------------------------
; VSTUP: AL=definovanò znak
;        AH=ekvivalent znaku
; VùSTUP:SI=adresa definice znaku
; -----------------------------------------------------------------------------

NewDown  PROC      NEAR

         mov       si,offset BuffDwn        ; buffer definic DownLoad
         add       si,cs:[NumDwn]
         add       si,cs:[NumDwn]           ; adresa k uloëen° definice znaku
         mov       cs:[si],ax               ; uloëen° definice na konec tabulky
         inc       word ptr cs:[NumDwn]     ; zvò®en° poátu definic
         ret

NewDown  ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku DownLoad do bufferu DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak
; VùSTUP:AH=ekvivalent znaku
;        CY=znak nebyl dosud nadefinov†n (byl uloëen do tabulky)
; -----------------------------------------------------------------------------

StorDown PROC      NEAR

; ------ £schova registrñ

         push      si

; ------ nalezen° znaku v tabulce DownLoad

         call      SrcDown                  ; nalezen° znaku v tabulce DownLoad
         jc        StorDwn3                 ; znak nebyl dosud nadefinov†n

; ------ zru®en° starÇ definice znaku

         mov       ax,cs:[si]               ; star† definice znaku
         call      DelDown                  ; zru®en° definice znaku z tabulky

; ------ uloëen° definice na konec tabulky

         call      NewDown                  ; uloëen° definice AX do tabulky
         clc                                ; p©°znak, ëe znak jië byl definov†n
         jmp       short StorDwn9           ; konec

; ------ nalezen° volnÇho ekvivalentu

StorDwn3:mov       ah,cs:[FirstDwn]         ; prvn° znak ekvivalentu DownLoad
StorDwn4:call      SrcEkvi                  ; nalezen° ekvivalentu v tabulce
         jc        StorDwn8                 ; nenalezen - lze jej pouë°t
StorDwn5:inc       ah                       ; zvò®en° á°sla ekvivalentu
         cmp       ah,7fh
         je        StorDwn5                 ; zak†zanò znak

StorDwn7:cmp       ah,cs:[LastDwn]          ; je to jië posledn° ekvivalent ?
         jbe       StorDwn4                 ; dal®° pokus o nalezen°

; ------ zru®en° nejstar®° definice znaku

         mov       si,offset BuffDwn        ; buffer definice DownLoad znakñ
         mov       ah,cs:[si+1]             ; ekvivalent pñvodn°ho znaku
         call      DelDown                  ; zru®en° starÇho znaku

; ------ definice novÇho znaku

StorDwn8:call      NewDown                  ; uloëen° novÇ definice do tabulky
         stc                                ; p©°znak, ëe znak nebyl definov†n

; ------ n†vrat registrñ

StorDwn9:pop       si
         ret

StorDown ENDP

; -----------------------------------------------------------------------------
;        podm°nàn† definice znaku DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=poëadovanò znak
; VùSTUP:AH=ekvivalent znaku (NC) nebo stavovò bajt (chyba CY)
;        CY=chyba vòstupu na tisk†rnu
; -----------------------------------------------------------------------------

DefDown  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax
         push      si

; ------ test, zda je znak jië nadefinov†n

         call      StorDown                 ; uloëen° znaku do definián° tabulky
         jnc       DefDown9                 ; znak je jië nadefinov†n

; ------ zapnut° reëimu DownLoad

         push      ax
         mov       si,offset KDefDwn        ; k¢d pro definici DownLoad
         mov       cs:[si+4],ah
         mov       cs:[si+5],ah             ; ekvivalent znaku
         call      DownOn                   ; zapnut° reëimu DownLoad
         jc        DefDown8                 ; byla chyba operace

; ------ vysl†n° z†hlav° definice znaku

         call      WritTxt                  ; vysl†n° z†hlav° definice znaku
         jc        DefDown8                 ; chyba vòstupu na tisk†rnu

; ------ vysl†n° definice DownLoad

         xor       ah,ah                    ; AX = poëadovanò znak
         mov       si,ax                    ; poëadovanò znak
         shl       si,1                     ; offset v tabulce indexñ
         add       si,cs:[TabFont]          ; aktu†ln° tabulka fontñ
         mov       si,cs:[si]               ; adresa fontu
         call      WritTxt                  ; vysl†n° definice znaku
         jc        DefDown8                 ; chyba vòstupu na tisk†rnu
         pop       ax                       ; n†vrat k¢du (ekvivalentu)
         jmp       short DefDown9

; ------ chyba definice znaku

DefDown8:pop       bx                       ; zru®en° AX ze z†sobn°ku
         dec       word ptr cs:[NumDwn]     ; zru®en° definice znaku

; ------ n†vrat registrñ

DefDown9:pop       si
         mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
         ret

DefDown  ENDP

; -----------------------------------------------------------------------------
;        vysl†n° znaku s podm°nànòm DownLoad
; -----------------------------------------------------------------------------
; VSTUP: AL=znak k vysl†n°
; VùSTUP:CY=chyba vòstupu (AH=stavovò bajt tisk†rny)
; -----------------------------------------------------------------------------
;˛
OutZnak  PROC      NEAR

; ------ £schova registrñ

         push      bx
         push      ax

; ------ test, zda znak bude vysl†n bàënòm zpñsobem

         xor       bx,bx
         mov       bl,cs:[LastDwn]
         inc       bl
         sub       bl,cs:[FirstDwn]
         cmp       bx,cs:[NumDwn]
         jbe       OutZNak2                 ; buffer je jië plnò

         mov       bl,al                    ; poëadovanò znak
         shl       bx,1                     ; offset v tabulce fontñ
         add       bx,cs:[TabFont]          ; aktu†ln° tabulka fontñ
         cmp       word ptr cs:[bx],0       ; dàl† se DownLoad znaku ?
         jne       OutZnak3                 ; dàl† se DownLoad znaku

; ------ vysl†n° znaku bàënòm zpñsobem

OutZnak2:call      DownOff                  ; vypnut° reëimu DownLoad
         jc        OutZnak9                 ; chyba vòstupu na tisk†rnu
         call      WritByte                 ; vysl†n° znaku na tisk†rnu
         jmp       short OutZnak9

; ------ vysl†n° znaku jako DownLoad

OutZnak3:call      DefDown                  ; definice znaku DownLoad
         jc        OutZnak9                 ; chyba vòstupu na tisk†rnu
         mov       al,ah                    ; ekvivalent znaku
         call      DownOn                   ; zapnut° reëimu DownLoad
         jc        OutZnak9                 ; chyba vòstupu na tisk†rnu
         call      WritByte                 ; vysl†n° ekvivalentu znaku

; ------ n†vrat registrñ

OutZnak9:mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
         ret

OutZnak  ENDP

; -----------------------------------------------------------------------------
;        podm°nànÇ zapnut° tisk†rny do reëimu DownLoad
; -----------------------------------------------------------------------------
; VùSTUP:CY=chyba vòstupu na tisk†rnu
;        AH=stavovò bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

DownOn   PROC      NEAR

         push      si
         test      word ptr cs:[Param0],bit8; je zn†mò stav DownLoad ?
         jz        DownOn2                  ; stav DownLoad nen° zn†mò
         test      word ptr cs:[Param],bit8 ; je zapnut reëim DownLoad ?
         jnz       DownOn3                  ; reëim DownLoad je jië zapnut
DownOn2: mov       si,offset KSetDwn        ; k¢d pro zapnut° DownLoad
         call      WritTxt                  ; zapnut° reëimu DownLoad
         jc        DownOn3                  ; chyba vòstupu na tisk†rnu
         or        word ptr cs:[Param0],bit8; p©°znak zn†mosti stavu DownLoad
         or        word ptr cs:[Param],bit8 ; p©°znak stavu DownLoad
DownOn3: pop       si
         ret

DownOn   ENDP

; -----------------------------------------------------------------------------
;        podm°nànÇ vypnut° tisk†rny z reëimu DownLoad
; -----------------------------------------------------------------------------
; VùSTUP:CY=chyba vòstupu na tisk†rnu
;        AH=stavovò bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

DownOff  PROC      NEAR

         push      si
         test      word ptr cs:[Param0],bit8; je zn†mò stav DownLoad ?
         jz        DownOff2                 ; stav DownLoad nen° zn†mò
         test      word ptr cs:[Param],bit8 ; je zapnut reëim DownLoad ?
         jz        DownOff3                 ; reëim DownLoad je jië vypnut
DownOff2:mov       si,offset KResDwn        ; k¢d pro vypnut° DownLoad
         call      WritTxt                  ; zapnut° reëimu DownLoad
         jc        DownOff3                 ; chyba vòstupu na tisk†rnu
         or        word ptr cs:[Param0],bit8; p©°znak zn†mosti stavu DownLoad
         and       word ptr cs:[Param],not bit8 ; p©°znak vyp. stavu DownLoad
DownOff3:pop       si
         ret

DownOff  ENDP

; *****************************************************************************
;
;                        P©ek¢dov†n° prñchoz°ch dat
;
; *****************************************************************************


; -----------------------------------------------------------------------------
;        konverze bajtu AL (vòstupn° buffer je pr†zdnò)
; -----------------------------------------------------------------------------
; VSTUP: AL=bajt k dek¢dov†n°
; VùSTUP:CY=chyba vòstupu
;        AH=stavovò bajt (pokud je chyba CY)
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

         mov       byte ptr cs:[KInitNLQ],0
         mov       word ptr cs:[TabFont],offset KamDraft
         test      word ptr cs:[Param],bit10
         jz        Konv1
         mov       byte ptr cs:[KInitNLQ],1
         mov       word ptr cs:[TabFont],offset KamNLQ
Konv1:

; ------ zaji®tàn° zn†mosti tabulky DownLoad

         test      word ptr cs:[Param0],bit9 ; je zn†m† tabulka DownLoad ?
         jnz       Konvert1                 ; tabulka je zn†m†

         mov       word ptr cs:[NumDwn],0   ; nulov†n° tabulky DownLoad
         mov       word ptr cs:[OutNum],0
         mov       word ptr cs:[EscNum],0
         or        word ptr cs:[Param0],bit9 ; p©°znak zn†mosti tabulky DownLoad

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

         mov       cl,cs:[LastDwn]          ; posledn° znak DownLoad
         inc       cl
         sub       cl,cs:[FirstDwn]         ; poáet znakñ DownLoad
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
         cmp       word ptr cs:[bx],0       ; m† znak DownLoad ?
         je        Konv4                    ; nem† DownLoad
         call      DefDown                  ; definice znaku DownLoad
         jc        Konv5                    ; chyba
Konv4:   loop      Konv2                    ; definice dal®°ho znaku

Konv5:   pop       si
         pop       cx
         mov       bh,ah
         pop       ax
         mov       ah,bh
         pop       bx
Konver88:jc        Konvert8                 ; chyba

Konvert1:

; ------ je platnò znak (nen° souá†st ESC polsoupnosti)

         cmp       word ptr cs:[EscNum],0   ; je nàco v ESC bufferu ?
         jne       Konvert4                 ; je nàco v bufferu
         cmp       al,27                    ; je ESC ?
         je        Konvert2                 ; je ESC znak
         call      OutZnak                  ; vysl†n° znaku s podm°nànòm DownLd
         jmp       short Konvert8

; ------ je prvn° ESC

Konvert2:call      StorEsc                  ; uloëen° do ESC bufferu
Konvert3:call      DownOff
         jc        Konvert8
         call      WritByte                 ; uloëen° bez dek¢dov†n°
         jmp       short Konvert8

; ------ je druhò znak ESC

Konvert4:cmp       word ptr cs:[EscNum],1   ; je to 2. znak ESC posloupnosti ?
         jne       Konvert5                 ; nen° to 2. znak
         cmp       al,"x"                   ; nastaven° kvality ?
         je        Konvert2
         jmp       short Konvert6

; ------ p©epnut° reëimu DRAFT/NLQ

Konvert5:or        word ptr cs:[Param0],bit10 ; stav NLQ je zn†mò
         and       word ptr cs:[Param0],not bit9 ; tabulka DownLoad nedefinovan†
         and       word ptr cs:[Param],not bit10 ; p©°znak DRAFT
         test      al,1                     ; je vy®®° kvalita p°sma ?
         jz        Konvert6                 ; je DRAFT
         or        word ptr cs:[Param],bit10
Konvert6:call      WritByte
Konvert7:mov       word ptr cs:[EscNum],0   ; zru®en° dat v ESC bufferu
Konvert8:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku do ESC bufferu
; -----------------------------------------------------------------------------

StorESC  PROC      NEAR

         push      bx
         mov       bx,cs:[EscNum]           ; poáet bajtñ v ESC bufferu
         mov       cs:[bx+EscBuff],al       ; uloëen° znaku do ESC bufferu
         inc       word ptr cs:[EscNum]     ; zvò®en° á°taáe dat
         pop       bx
         ret

StorESC  ENDP


; *****************************************************************************
;
;                   Tabulky ©°dic°ch k¢dñ
;
; *****************************************************************************

KamInit  db        'à®á©üëò†°Ç¢£ñ§ìåçÉ'
KamInit0 label     byte

KInit    db        7,27,'@',27,'6',27,'x'
KInitNLQ db        1
;,27,':',0,0,0

KSetDwn  db        3,27,'%',1               ; zapnut° DownLoad
KResDwn  db        3,27,'%',0               ; vypnut° DownLoad
KDefDwn  db        5,27,'&',0,33,33         ; definice DownLoad

; *****************************************************************************
;
;                         Tabulka fontñ DRAFT
;
; *****************************************************************************

; Symboly: V=velkÇ, M=malÇ, H=h†áek, C=á†rka, D=dvojteáka, S=st©°®ka, K=krouëek


; ------ tabulka indexñ - Kamenickòch DRAFT

KamDraft label     word
         dw        105 dup(0)

         dw        DrftI                    ; 105 i

         dw        111-106 dup(0)

         dw        DrftO                    ; 111 o

         dw        128-112 dup(0)

         dw        DrftCVH                  ; 128 Ä
         dw        DrftUMD                  ; 129 Å
         dw        DrftEMC                  ; 130 Ç
         dw        DrftDMH                  ; 131 É
         dw        DrftAMD                  ; 132 Ñ
         dw        DrftDVH                  ; 133 Ö
         dw        DrftTVH                  ; 134 Ü
         dw        DrftCMH                  ; 135 á
         dw        DrftEMH                  ; 136 à
         dw        DrftEVH                  ; 137 â
         dw        DrftLVC                  ; 138 ä
         dw        DrftIVC                  ; 139 ã
         dw        DrftLMH                  ; 140 å
         dw        DrftLMC                  ; 141 ç
         dw        DrftAVD                  ; 142 é
         dw        DrftAVC                  ; 143 è
         dw        DrftEVC                  ; 144 ê
         dw        DrftZMH                  ; 145 ë
         dw        DrftZVH                  ; 146 í
         dw        DrftOMS                  ; 147 ì
         dw        DrftOMD                  ; 148 î
         dw        DrftOVC                  ; 149 ï
         dw        DrftUMK                  ; 150 ñ
         dw        DrftUVC                  ; 151 ó
         dw        DrftYMC                  ; 152 ò
         dw        DrftOVD                  ; 153 ô
         dw        DrftUVD                  ; 154 ö
         dw        DrftUVH                  ; 155 õ
         dw        DrftLVH                  ; 156 ú
         dw        DrftYVC                  ; 157 ù
         dw        DrftRVH                  ; 158 û
         dw        DrftTMH                  ; 159 ü
         dw        DrftAMC                  ; 160 †
         dw        DrftIMC                  ; 161 °
         dw        DrftOMC                  ; 162 ¢
         dw        DrftUMC                  ; 163 £
         dw        DrftNMH                  ; 164 §
         dw        DrftNVH                  ; 165 •
         dw        DrftUVK                  ; 166 ¶
         dw        DrftOVS                  ; 167 ß
         dw        DrftSMH                  ; 168 ®
         dw        DrftRMH                  ; 169 ©
         dw        DrftRMC                  ; 170 ™
         dw        DrftRVC                  ; 171 ´
         dw        DrftXX1                  ; 172 ¨
         dw        DrftXX2                  ; 173 ≠
         dw        DrftXX3                  ; 174 Æ
         dw        DrftXX4                  ; 175 Ø
         dw        DrftG01                  ; 176 ∞
         dw        DrftG02                  ; 177 ±
         dw        DrftG03                  ; 178 ≤
         dw        DrftG04                  ; 179 ≥
         dw        DrftG05                  ; 180 ¥
         dw        DrftG06                  ; 181 µ
         dw        DrftG07                  ; 182 ∂
         dw        DrftG08                  ; 183 ∑
         dw        DrftG09                  ; 184 ∏
         dw        DrftG10                  ; 185 π
         dw        DrftG11                  ; 186 ∫
         dw        DrftG12                  ; 187 ª
         dw        DrftG13                  ; 188 º
         dw        DrftG14                  ; 189 Ω
         dw        DrftG15                  ; 190 æ
         dw        DrftG16                  ; 191 ø
         dw        DrftG17                  ; 192 ¿
         dw        DrftG18                  ; 193 ¡
         dw        DrftG19                  ; 194 ¬
         dw        DrftG20                  ; 195 √
         dw        DrftG21                  ; 196 ƒ
         dw        DrftG22                  ; 197 ≈
         dw        DrftG23                  ; 198 ∆
         dw        DrftG24                  ; 199 «
         dw        DrftG25                  ; 200 »
         dw        DrftG26                  ; 201 …
         dw        DrftG27                  ; 202  
         dw        DrftG28                  ; 203 À
         dw        DrftG29                  ; 204 Ã
         dw        DrftG30                  ; 205 Õ
         dw        DrftG31                  ; 206 Œ
         dw        DrftG32                  ; 207 œ
         dw        DrftG33                  ; 208 –
         dw        DrftG34                  ; 209 —
         dw        DrftG35                  ; 210 “
         dw        DrftG36                  ; 211 ”
         dw        DrftG37                  ; 212 ‘
         dw        DrftG38                  ; 213 ’
         dw        DrftG39                  ; 214 ÷
         dw        DrftG40                  ; 215 ◊
         dw        DrftG41                  ; 216 ÿ
         dw        DrftG42                  ; 217 Ÿ
         dw        DrftG43                  ; 218 ⁄
         dw        DrftG44                  ; 219 €
         dw        DrftG45                  ; 220 ‹
         dw        DrftG46                  ; 221 ›
         dw        DrftG47                  ; 222 ﬁ
         dw        DrftG48                  ; 223 ﬂ
         dw        DrftR01                  ; 224 ‡
         dw        DrftR02                  ; 225 ·
         dw        DrftR03                  ; 226 ‚
         dw        DrftR04                  ; 227 „
         dw        DrftR05                  ; 228 ‰
         dw        DrftR06                  ; 229 Â
         dw        DrftR07                  ; 230 Ê
         dw        DrftR08                  ; 231 Á
         dw        DrftR09                  ; 232 Ë
         dw        DrftR10                  ; 233 È
         dw        DrftR11                  ; 234 Í
         dw        DrftR12                  ; 235 Î
         dw        DrftR13                  ; 236 Ï
         dw        DrftR14                  ; 237 Ì
         dw        DrftR15                  ; 238 Ó
         dw        DrftR16                  ; 239 Ô
         dw        DrftR17                  ; 240 
         dw        DrftR18                  ; 241 Ò
         dw        DrftR19                  ; 242 Ú
         dw        DrftR20                  ; 243 Û
         dw        DrftR21                  ; 244 Ù
         dw        DrftR22                  ; 245 ı
         dw        DrftR23                  ; 246 ˆ
         dw        DrftR24                  ; 247 ˜
         dw        DrftR25                  ; 248 ¯
         dw        DrftR26                  ; 249 ˘
         dw        DrftR27                  ; 250 ˙
         dw        DrftR28                  ; 251 ˚
         dw        DrftR29                  ; 252 ¸
         dw        DrftR30                  ; 253 ˝
         dw        DrftR31                  ; 254 ˛
         dw        DrftR32                  ; 255

; ------ tabulka indexñ - Latin 2 DRAFT

LatDraft label     word
         dw        256 dup(0)

; ------ tabulka indexñ - KOI 8 DRAFT

KoiDraft label     word
         dw        256 dup(0)

; ------ definice fontu DRAFT
;˛
FontDrft label     byte

;$b4 0 0 0 $79 0 0 0 0 0 0 0   ; 33 "!"
;$96 0 $e0 0 0 0 $e0 0 0 0 0 0   ; 34  "
;$89 $14 0 $7f 0 $14 0 $7f 0 $14 0 0  ; 35 "#"
;$89 $10 $2a 0 $2a $55 $2a 0 $2a 4 0 0  ; 36 "$"
;$89 $20 $51 $22 4 8 $10 $22 $45 2 0 0  ; 37 "%"
;$89 $22 $54 9 $50 $25 0 2 4 9 0 0  ; 38 "&"
;$a5 0 0 0 $20 $c0 0 0 0 0 0 0   ; 39 "'"
;$b6 0 0 0 $1c $22 $41 0 0 0 0 0   ; 40 "("
;$b6 0 0 0 $41 $22 $1c 0 0 0 0 0   ; 41 ")"
;$89 8 0 $2a $14 8 $14 $2a 0 8 0 0  ; 42 "*"
;$89 8 0 8 0 $3e 0 8 0 8 0 0   ; 43 "+"
;$25 0 0 $c 1 $e 0 0 0 0 0 0   ; 44 ","
;$89 8 0 8 0 8 0 8 0 8 0 0   ; 45 "-"
;$a5 0 0 3 0 3 0 0 0 0 0 0   ; 46 "."
;$98 0 1 2 4 8 $10 $20 $40 0 0 0   ; 47 "/"
;$89 $1c $22 4 $41 8 $41 $10 $22 $1c 0 0  ; 48 "0"
;$a7 0 0 $21 0 $7f 0 1 0 0 0 0   ; 49 "1"
;$89 $23 $40 5 $48 1 $48 1 $48 $31 0 0  ; 50 "2"
;$89 $22 $41 0 $49 0 $49 0 $49 $36 0 0  ; 51 "3"
;$89 $c $10 $24 $40 4 0 $7f 0 4 0 0  ; 52 "4"
;$89 $72 0 $51 0 $51 0 $51 0 $4e 0 0  ; 53 "5"
;$89 $1e $20 9 $40 9 $40 9 $40 6 0 0  ; 54 "6"
;$89 $40 0 $40 0 $43 4 $48 $10 $60 0 0  ; 55 "7"
;$89 $36 $49 0 $49 0 $49 0 $49 $36 0 0  ; 56 "8"
;$89 $30 1 $48 1 $48 1 $48 2 $3c 0 0  ; 57 "9"
;$a5 0 0 $36 0 $36 0 0 0 0 0 0   ; 58 ":"
;$25 0 0 $6c 1 $6e 0 0 0 0 0 0   ; 59 ";"
;$98 0 8 0 $14 0 $22 0 $41 0 0 0   ; 60 "<"
;$89 $14 0 $14 0 $14 0 $14 0 $14 0 0  ; 61 "="
;$98 0 $41 0 $22 0 $14 0 8 0 0 0   ; 62 ">"
;$87 $20 $40 0 $45 8 $40 $30 0 0 0 0  ; 63 "?"
;$89 $3e $41 0 $49 $14 $41 $14 $41 $38 0 0 ; 64 "@"
;$89 $f $10 $24 $40 4 $40 $24 $10 $f 0 0  ; 65 "A"
;$89 $41 $3e $41 8 $41 8 $41 8 $36 0 0  ; 66 "B"
;$89 $3e $41 0 $41 0 $41 0 $41 $22 0 0  ; 67 "C"
;$89 $41 $3e $41 0 $41 0 $41 0 $3e 0 0  ; 68 "D"
;$89 $7f 0 $49 0 $49 0 $49 0 $41 0 0  ; 69 "E"
;$89 $7f 0 $48 0 $48 0 $48 0 $40 0 0  ; 70 "F"
;$89 $3e $41 0 $41 8 $41 8 $41 $2e 0 0  ; 71 "G"
;$89 $7f 0 8 0 8 0 8 0 $7f 0 0   ; 72 "H"
;$a7 0 0 $41 0 $7f 0 $41 0 0 0 0   ; 73 "I"
;$89 0 6 1 0 $41 0 $41 $3e $40 0 0  ; 74 "J"
;$89 $7f 0 8 0 $14 0 $22 0 $41 0 0  ; 75 "K"
;$a9 0 0 $7f 0 1 0 1 0 1 0 0   ; 76 "L"
;$89 $7f 0 $20 $10 8 $10 $20 0 $7f 0 0  ; 77 "M"
;$89 $7f 0 $20 $10 8 4 2 0 $7f 0 0  ; 78 "N"
;$89 $3e $41 0 $41 0 $41 0 $41 $3e 0 0  ; 79 "O"
;$89 $7f 0 $48 0 $48 0 $48 0 $30 0 0  ; 80 "P"
;$89 $3e $41 0 $41 4 $41 2 $40 $3d 0 0  ; 81 "Q"
;$89 $7f 0 $48 0 $48 4 $48 2 $31 0 0  ; 82 "R"
;$89 $32 $49 0 $49 0 $49 0 $49 $26 0 0  ; 83 "S"
;$89 $40 0 $40 0 $7f 0 $40 0 $40 0 0  ; 84 "T"
;$89 $7e 1 0 1 0 1 0 1 $7e 0 0   ; 85 "U"
;$89 $70 8 4 2 1 2 4 8 $70 0 0   ; 86 "V"
;$89 $7e 1 2 4 $18 4 2 1 $7e 0 0   ; 87 "W"
;$89 $41 $22 0 $14 8 $14 0 $22 $41 0 0  ; 88 "X"
;$89 $40 $20 $10 8 7 8 $10 $20 $40 0 0  ; 89 "Y"
;$89 $43 0 $45 0 $49 0 $51 0 $61 0 0  ; 90 "Z"
;$b8 0 0 0 $7f 0 $41 0 $41 0 0 0   ; 91 "["
;$98 0 $40 $20 $10 8 4 2 1 0 0 0   ; 92 "\"
;$96 0 $41 0 $41 0 $7f 0 0 0 0 0   ; 93 "]"
;$a7 0 0 $20 $40 $80 $40 $20 0 0 0 0  ; 94 "^"
;$b 1 0 1 0 1 0 1 0 1 0 1   ; 95 "_"
;$b6 0 0 0 $80 $40 $20 0 0 0 0 0   ; 96 "`"
;$89 2 5 $10 5 $10 5 $10 $e 1 0 0  ; 97 "a"
;$99 0 $7f 0 $11 0 $11 0 $11 $e 0 0  ; 98 "b"
;$99 0 $e $11 0 $11 0 $11 0 $11 0 0  ; 99 "c"
;$88 $e $11 0 $11 0 $11 0 $7f 0 0 0  ; 100 "d"
;$89 $e $11 4 $11 4 $11 4 $11 $c 0 0  ; 101 "e"
;$99 0 8 0 8 $37 $48 0 $48 $20 0 0  ; 102 "f"
;8 $18 $24 1 $24 1 $24 1 $3e 0 0 0  ; 103 "g"
;$99 0 $7f 0 $10 0 $10 0 $10 $f 0 0  ; 104 "h"
;$a7 0 0 $11 $40 $1f 0 1 0 0 0 0   ; 105 "i"
;$16 0 2 1 $20 $81 $3e 0 0 0 0 0   ; 106 "j"
;$98 0 $7f 0 4 0 $a 0 $11 0 0 0   ; 107 "k"
;$a7 0 0 $41 0 $7f 0 1 0 0 0 0   ; 108 "l"
;$89 $f $10 0 $10 $f $10 0 $10 $f 0 0  ; 109 "m"
;$89 $10 $f 0 $10 0 $10 0 $10 $f 0 0  ; 110 "n"
;$89 $e $11 0 $11 0 $11 0 $11 $e 0 0  ; 111 "o"
;$19 0 $3f 0 $24 0 $24 0 $24 $18 0 0  ; 112 "p"
;8 $18 $24 0 $24 0 $24 0 $3f 0 0 0  ; 113 "q"
;$89 0 $1f 0 8 0 $10 0 $10 8 0 0   ; 114 "r"
;$89 $8 $15 0 $15 0 $15 0 $15 2 0 0  ; 115 "s"
;$98 0 $10 0 $7e 1 $10 1 $12 0 0 0  ; 116 "t"
;$9a 0 $1e 1 0 1 0 1 0 $1e 1 0   ; 117 "u"
;$89 $10 8 4 2 1 2 4 8 $10 0 0   ; 118 "v"
;$89 $1e 1 2 4 8 4 2 1 $1e 0 0   ; 119 "w"
;$98 0 $11 $a 0 4 0 $a $11 0 0 0   ; 120 "x"
;9 0 $20 $10 9 2 4 8 $10 $20 0 0   ; 121 "y"
;$98 0 $11 2 $11 4 $11 8 $11 0 0 0  ; 122 "z"
;$87 8 0 8 $36 $41 0 $41 0 0 0 0   ; 123 "{"
;$c5 0 0 0 0 $77 0 0 0 0 0 0   ; 124 "|"
;$a9 0 0 $41 0 $41 $36 8 0 8 0 0   ; 125 "}"
;$89 8 $10 0 $10 8 4 0 4 8 0 0   ; 126 "~"
;$89 $1c $22 0 $45 8 $51 0 $22 $1c 0 0  ; 127 ""
;
;



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

DrftCVH  db        12,bit7+09h                                       ; 128 Ä
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

DrftUMD  db        12,bit7+1ah                                       ; 129 Å
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

DrftEMC  db        12,bit7+09h                                       ; 130 Ç
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

DrftDMH  db        12,bit7+0bh                                       ; 131 É
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

DrftAMD  db        12,bit7+09h                                       ; 132 Ñ
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

DrftDVH  db        12,bit7+09h                                       ; 133 Ö
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

DrftTVH  db        12,bit7+09h                                       ; 134 Ü
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

DrftCMH  db        12,bit7+19h                                       ; 135 á
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

DrftEMH  db        12,bit7+09h                                       ; 136 à
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

DrftEVH  db        12,bit7+09h                                       ; 137 â
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

DrftLVC  db        12,bit7+09h                                       ; 138 ä
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

DrftIVC  db        12,bit7+27h                                       ; 139 ã
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

DrftLMH  db        12,bit7+2bh                                       ; 140 å
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

DrftLMC  db        12,bit7+28h                                       ; 141 ç
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

DrftAVD  db        12,bit7+09h                                       ; 142 é
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

DrftAVC  db        12,bit7+09h                                       ; 143 è
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

DrftEVC  db        12,bit7+09h                                       ; 144 ê
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

DrftZMH  db        12,bit7+18h                                       ; 145 ë
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

DrftZVH  db        12,bit7+09h                                       ; 146 í
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

DrftOMS  db        12,bit7+09h                                       ; 147 ì
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

DrftOMD  db        12,bit7+09h                                       ; 148 î
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

DrftOVC  db        12,bit7+09h                                       ; 149 ï
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

DrftUMK  db        12,bit7+1ah                                       ; 150 ñ
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

DrftUVC  db        12,bit7+09h                                       ; 151 ó
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

DrftYMC  db        12,09h                                            ; 152 ò
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

DrftOVD  db        12,bit7+09h                                       ; 153 ô
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

DrftUVD  db        12,bit7+09h                                       ; 154 ö
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

DrftUVH  db        12,bit7+09h                                       ; 155 õ
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

DrftLVH  db        12,bit7+0ah                                       ; 156 ú
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

DrftYVC  db        12,bit7+09h                                       ; 157 ù
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

DrftRVH  db        12,bit7+09h                                       ; 158 û
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

DrftTMH  db        12,bit7+1ah                                       ; 159 ü
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

DrftAMC  db        12,bit7+09h                                       ; 160 †
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

DrftIMC  db        12,bit7+28h                                       ; 161 °
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

DrftNMH  db        12,bit7+09h                                       ; 164 §
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

DrftNVH  db        12,bit7+09h                                       ; 165 •
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

DrftUVK  db        12,bit7+09h                                       ; 166 ¶
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

DrftOVS  db        12,bit7+09h                                       ; 167 ß
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

DrftSMH  db        12,bit7+09h                                       ; 168 ®
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

DrftRMC  db        12,bit7+09h                                       ; 170 ™
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

DrftRVC  db        12,bit7+09h                                       ; 171 ´
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

DrftXX1  db        12,bit7+0ah                                       ; 172 ¨
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

DrftXX2  db        12,bit7+29h                                       ; 173 ≠
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

DrftXX3  db        12,bit7+19h                                       ; 174 Æ
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

DrftXX4  db        12,bit7+19h                                       ; 175 Ø
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

DrftG01  db        12,bit7+0bh                                       ; 176 ∞
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

DrftG03  db        12,bit7+0bh                                       ; 178 ≤
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

DrftG04  db        12,bit7+45h                                       ; 179 ≥
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

DrftG05  db        12,bit7+05h                                       ; 180 ¥
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

DrftG07  db        12,bit7+07h                                       ; 182 ∂
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

DrftG08  db        12,07h                                            ; 183 ∑
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

DrftG09  db        12,05h                                            ; 184 ∏
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

DrftG10  db        12,bit7+07h                                       ; 185 π
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

DrftG11  db        12,bit7+27h                                       ; 186 ∫
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

DrftG12  db        12,07h                                            ; 187 ª
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

DrftG13  db        12,bit7+07h                                       ; 188 º
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

DrftG14  db        12,bit7+07h                                       ; 189 Ω
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

DrftG15  db        12,bit7+05h                                       ; 190 æ
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

DrftG16  db        12,05h                                            ; 191 ø
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

DrftG17  db        12,bit7+4bh                                       ; 192 ¿
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

DrftG18  db        12,bit7+0bh                                       ; 193 ¡
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

DrftG19  db        12,0bh                                            ; 194 ¬
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

DrftG20  db        12,bit7+4bh                                       ; 195 √
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

DrftG21  db        12,bit7+0bh                                       ; 196 ƒ
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

DrftG22  db        12,bit7+0bh                                       ; 197 ≈
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

DrftG23  db        12,bit7+4bh                                       ; 198 ∆
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

DrftG24  db        12,bit7+2bh                                       ; 199 «
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

DrftG25  db        12,bit7+2bh                                       ; 200 »
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

DrftG26  db        12,2bh                                            ; 201 …
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

DrftG27  db        12,bit7+0bh                                       ; 202  
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

DrftG28  db        12,0bh                                            ; 203 À
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

DrftG29  db        12,bit7+2bh                                       ; 204 Ã
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

DrftG30  db        12,bit7+0bh                                       ; 205 Õ
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

DrftG31  db        12,bit7+09h                                       ; 206 Œ
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

DrftG32  db        12,bit7+0bh                                       ; 207 œ
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

DrftG33  db        12,bit7+0bh                                       ; 208 –
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

DrftG34  db        12,0bh                                            ; 209 —
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

DrftG35  db        12,0bh                                            ; 210 “
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

DrftG36  db        12,bit7+2bh                                       ; 211 ”
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

DrftG37  db        12,bit7+4bh                                       ; 212 ‘
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

DrftG38  db        12,4bh                                            ; 213 ’
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

DrftG39  db        12,2bh                                            ; 214 ÷
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

DrftG40  db        12,bit7+0bh                                       ; 215 ◊
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

DrftG41  db        12,bit7+0bh                                       ; 216 ÿ
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

DrftG42  db        12,bit7+05h                                       ; 217 Ÿ
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

DrftG43  db        12,4bh                                            ; 218 ⁄
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

DrftG44  db        12,bit7+0bh                                       ; 219 €
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

DrftG45  db        12,bit7+0bh                                       ; 220 ‹
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

DrftG46  db        12,bit7+05h                                       ; 221 ›
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

DrftG47  db        12,bit7+6bh                                       ; 222 ﬁ
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

DrftG48  db        12,bit7+0bh                                       ; 223 ﬂ
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

DrftR01  db        12,bit7+09h                                       ; 224 ‡
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

DrftR02  db        12,bit7+19h                                       ; 225 ·
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

DrftR03  db        12,bit7+09h                                       ; 226 ‚
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

DrftR04  db        12,bit7+09h                                       ; 227 „
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

DrftR05  db        12,bit7+09h                                       ; 228 ‰
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

DrftR06  db        12,bit7+09h                                       ; 229 Â
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

DrftR07  db        12,09h                                            ; 230 Ê
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

DrftR08  db        12,bit7+09h                                       ; 231 Á
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

DrftR09  db        12,bit7+09h                                       ; 232 Ë
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

DrftR10  db        12,bit7+09h                                       ; 233 È
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

DrftR11  db        12,bit7+09h                                       ; 234 Í
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

DrftR12  db        12,bit7+0ah                                       ; 235 Î
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

DrftR13  db        12,bit7+0bh                                       ; 236 Ï
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

DrftR14  db        12,bit7+0bh                                       ; 237 Ì
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

DrftR15  db        12,bit7+18h                                       ; 238 Ó
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

DrftR16  db        12,bit7+09h                                       ; 239 Ô
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

DrftR17  db        12,bit7+09h                                       ; 240 
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

DrftR18  db        12,bit7+09h                                       ; 241 Ò
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

DrftR19  db        12,bit7+18h                                       ; 242 Ú
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

DrftR20  db        12,bit7+18h                                       ; 243 Û
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

DrftR21  db        12,49h                                            ; 244 Ù
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

DrftR22  db        12,bit7+05h                                       ; 245 ı
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

DrftR23  db        12,bit7+09h                                       ; 246 ˆ
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

DrftR24  db        12,bit7+09h                                       ; 247 ˜
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

DrftR25  db        12,bit7+27h                                       ; 248 ¯
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

DrftR26  db        12,bit7+36h                                       ; 249 ˘
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

DrftR27  db        12,bit7+36h                                       ; 250 ˙
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

DrftR28  db        12,bit7+0bh                                       ; 251 ˚
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

DrftR29  db        12,bit7+28h                                       ; 252 ¸
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

DrftR30  db        12,bit7+27h                                       ; 253 ˝
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

DrftR31  db        12,bit7+27h                                       ; 254 ˛
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
;                          Tabulka fontñ NLQ
;
; *****************************************************************************

; ------ tabulka indexñ - Kamenickòch NLQ
;˛
KamNLQ   label     word
         dw        128 dup(0)

         dw        NlqCVH                                            ; 128 Ä
         dw        NlqUMD                                            ; 129 Å
         dw        NlqEMC                                            ; 130 Ç
         dw        NlqDMH                                            ; 131 É
         dw        NlqAMD                                            ; 132 Ñ
         dw        NlqDVH                                            ; 133 Ö
         dw        NlqTVH                                            ; 134 Ü
         dw        NlqCMH                                            ; 135 á
         dw        NlqEMH                                            ; 136 à
         dw        NlqEVH                                            ; 137 â
         dw        NlqLVC                                            ; 138 ä
         dw        NlqIVC                                            ; 139 ã
         dw        NlqLMH                                            ; 140 å
         dw        NlqLMC                                            ; 141 ç
         dw        NlqAVD                                            ; 142 é
         dw        NlqAVC                                            ; 143 è
         dw        NlqEVC                                            ; 144 ê
         dw        NlqZMH                                            ; 145 ë
         dw        NlqZVH                                            ; 146 í
         dw        NlqOMS                                            ; 147 ì
         dw        NlqOMD                                            ; 148 î
         dw        NlqOVC                                            ; 149 ï
         dw        NlqUMK                                            ; 150 ñ
         dw        NlqUVC                                            ; 151 ó
         dw        NlqYMC                                            ; 152 ò
         dw        NlqOVD                                            ; 153 ô
         dw        NlqUVD                                            ; 154 ö
         dw        NlqSVH                                            ; 155 õ
         dw        NlqLVH                                            ; 156 ú
         dw        NlqYVC                                            ; 157 ù
         dw        NlqRVH                                            ; 158 û
         dw        NlqTMH                                            ; 159 ü
         dw        NlqAMC                                            ; 160 †
         dw        NlqIMC                                            ; 161 °
         dw        NlqOMC                                            ; 162 ¢
         dw        NlqUMC                                            ; 163 £
         dw        NlqNMH                                            ; 164 §
         dw        NlqNVH                                            ; 165 •
         dw        NlqUVK                                            ; 166 ¶
         dw        NlqOVS                                            ; 167 ß
         dw        NlqSMH                                            ; 168 ®
         dw        NlqRMH                                            ; 169 ©
         dw        NlqRMC                                            ; 170 ™
         dw        NlqRVC                                            ; 171 ´
         dw        NlqXX1                                            ; 172 ¨
         dw        NlqXX2                                            ; 173 ≠
         dw        NlqXX3                                            ; 174 Æ
         dw        NlqXX4                                            ; 175 Ø
         dw        NlqG01                                            ; 176 ∞
         dw        NlqG02                                            ; 177 ±
         dw        NlqG03                                            ; 178 ≤
         dw        NlqG04                                            ; 179 ≥
         dw        NlqG05                                            ; 180 ¥
         dw        NlqG06                                            ; 181 µ
         dw        NlqG07                                            ; 182 ∂
         dw        NlqG08                                            ; 183 ∑
         dw        NlqG09                                            ; 184 ∏
         dw        NlqG10                                            ; 185 π
         dw        NlqG11                                            ; 186 ∫
         dw        NlqG12                                            ; 187 ª
         dw        NlqG13                                            ; 188 º
         dw        NlqG14                                            ; 189 Ω
         dw        NlqG15                                            ; 190 æ
         dw        NlqG16                                            ; 191 ø
         dw        NlqG17                                            ; 192 ¿
         dw        NlqG18                                            ; 193 ¡
         dw        NlqG19                                            ; 194 ¬
         dw        NlqG20                                            ; 195 √
         dw        NlqG21                                            ; 196 ƒ
         dw        NlqG22                                            ; 197 ≈
         dw        NlqG23                                            ; 198 ∆
         dw        NlqG24                                            ; 199 «
         dw        NlqG25                                            ; 200 »
         dw        NlqG26                                            ; 201 …
         dw        NlqG27                                            ; 202  
         dw        NlqG28                                            ; 203 À
         dw        NlqG29                                            ; 204 Ã
         dw        NlqG30                                            ; 205 Õ
         dw        NlqG31                                            ; 206 Œ
         dw        NlqG32                                            ; 207 œ
         dw        NlqG33                                            ; 208 –
         dw        NlqG34                                            ; 209 —
         dw        NlqG35                                            ; 210 “
         dw        NlqG36                                            ; 211 ”
         dw        NlqG37                                            ; 212 ‘
         dw        NlqG38                                            ; 213 ’
         dw        NlqG39                                            ; 214 ÷
         dw        NlqG40                                            ; 215 ◊
         dw        NlqG41                                            ; 216 ÿ
         dw        NlqG42                                            ; 217 Ÿ
         dw        NlqG43                                            ; 218 ⁄
         dw        NlqG44                                            ; 219 €
         dw        NlqG45                                            ; 220 ‹
         dw        NlqG46                                            ; 221 ›
         dw        NlqG47                                            ; 222 ﬁ
         dw        NlqG48                                            ; 223 ﬂ
         dw        NlqG49                                            ; 224 ‡

         dw        128 dup(0)

; ------ tabulka indexñ - Latin 2 NLQ

LatNLQ   label     word
         dw        256 dup(0)

; ------ tabulka indexñ - KOI 8 NLQ

KoiNLQ   label     word
         dw        256 dup(0)

; ------ definice fontu NLQ

FontNLQ  label     byte
;˛

NlqCVH   db        30,1,9,2                                          ; 128 Ä
         db        00000111b,11100000b,00000000b
         db        00001000b,00010000b,00000000b
         db        10010000b,00001000b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10010000b,00000100b,00000000b
         db        00001000b,00001000b,00000000b
         db        00111100b,00010000b,00000000b

NlqUMD   db        30,1,9,2                                          ; 129 Å
         db        00001000b,00000000b,00000000b
         db        01001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        01001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b

NlqEMC   db        30,1,9,2                                          ; 130 Ç
         db        00000011b,11110000b,00000000b
         db        00000100b,10001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00000100b,10001000b,00000000b
         db        00000011b,10000000b,00000000b

NlqDMH   db        39,0,12,0                                         ; 131 É
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

NlqAMD   db        30,1,9,2                                          ; 132 Ñ
         db        00000000b,00110000b,00000000b
         db        01000100b,01001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        00001000b,10000100b,00000000b
         db        01000100b,10001000b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqDVH   db        30,1,9,2                                          ; 133 Ö
         db        00100000b,00000100b,00000000b
         db        10111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00010000b,00001000b,00000000b
         db        00001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqTVH   db        30,1,9,2                                          ; 134 Ü
         db        00111000b,00000000b,00000000b
         db        00100000b,00000000b,00000000b
         db        10100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00100000b,00000000b,00000000b
         db        00111000b,00000000b,00000000b

NlqCMH   db        30,1,9,2                                          ; 135 á
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        10001000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00001100b,00001000b,00000000b
         db        00001110b,00010000b,00000000b

NlqEMH   db        30,1,9,2                                          ; 136 à
         db        00000001b,11100000b,00000000b
         db        00000110b,10011000b,00000000b
         db        10001000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00000110b,10001000b,00000000b
         db        00000011b,10000000b,00000000b

NlqEVH   db        30,1,9,2                                          ; 137 â
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100011b,10000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00111000b,00011100b,00000000b

NlqLVC   db        30,1,9,2                                          ; 138 ä
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00011000b,00000100b,00000000b
         db        11100000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b

NlqIVC   db        21,3,6,3                                          ; 139 ã
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        01111111b,11111100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10000000b,00000000b,00000000b

NlqLMH   db        24,3,7,2                                          ; 140 å
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        00000000b,00000100b,00000000b
         db        11110000b,00000100b,00000000b
         db        00100000b,00000000b,00000000b
         db        11000000b,00000000b,00000000b

NlqLMC   db        24,3,7,2                                          ; 141 ç
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        00011000b,00000000b,00000000b
         db        11100000b,00000000b,00000000b

NlqAVD   db        36,0,11,1                                         ; 142 é
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

NlqAVC   db        36,0,11,1                                         ; 143 è
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

NlqEVC   db        30,1,9,2                                          ; 144 ê
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100001b,00000100b,00000000b
         db        00100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100011b,10000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        00111000b,00011100b,00000000b

NlqZMH   db        27,1,8,3                                          ; 145 ë
         db        00001110b,00001100b,00000000b
         db        10001000b,00010100b,00000000b
         db        01001000b,00100100b,00000000b
         db        00101000b,01000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001001b,00000100b,00000000b
         db        00001010b,00000100b,00000000b
         db        00001100b,00011100b,00000000b

NlqZVH   db        27,1,8,3                                          ; 146 í
         db        00111100b,00011100b,00000000b
         db        10100000b,00100100b,00000000b
         db        01100000b,01000100b,00000000b
         db        01100000b,10000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        10100010b,00000100b,00000000b
         db        00100100b,00000100b,00000000b
         db        00111000b,00111100b,00000000b

NlqOMS   db        30,1,9,2                                          ; 147 ì
         db        00000011b,11110000b,00000000b
         db        00100100b,00001000b,00000000b
         db        01001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00100100b,00001000b,00000000b
         db        00000011b,11110000b,00000000b

NlqOMD   db        30,1,9,2                                          ; 148 î
         db        00000011b,11110000b,00000000b
         db        00000100b,00001000b,00000000b
         db        10001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        10001000b,00000100b,00000000b
         db        00000100b,00001000b,00000000b
         db        00000011b,11110000b,00000000b

NlqOVC   db        30,1,9,2                                          ; 149 ï
         db        00000111b,11100000b,00000000b
         db        00001000b,00010000b,00000000b
         db        00010000b,00001000b,00000000b
         db        00100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        01100000b,00000100b,00000000b
         db        10010000b,00001000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqUMK   db        30,1,9,2                                          ; 150 ñ
         db        00001000b,00000000b,00000000b
         db        00001111b,11110000b,00000000b
         db        01000000b,00001000b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        01001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001111b,11111000b,00000000b
         db        00000000b,00000100b,00000000b

NlqUVC   db        33,1,10,1                                         ; 151 ó
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

NlqYMC   db        36,0,11,1                                         ; 152 ò
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

NlqOVD   db        30,1,9,2                                          ; 153 ô
         db        00000111b,11100000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00010000b,00001000b,00000000b
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        00010000b,00001000b,00000000b
         db        10001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqUVD   db        33,1,10,1                                         ; 154 ö
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

NlqSVH   db        30,1,9,2                                          ; 155 õ
         db        00001110b,00011100b,00000000b
         db        00010001b,00001000b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        01100001b,00000100b,00000000b
         db        10100001b,00000100b,00000000b
         db        00010001b,00001000b,00000000b
         db        00111000b,11110000b,00000000b

NlqLVH   db        30,1,9,2                                          ; 156 ú
         db        10000000b,00000100b,00000000b
         db        11111111b,11111100b,00000000b
         db        10000000b,00000100b,00000000b
         db        10000000b,00000100b,00000000b
         db        00000000b,00000100b,00000000b
         db        11110000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        11000000b,00000100b,00000000b
         db        00000000b,00011100b,00000000b

NlqYVC   db        36,0,11,1                                         ; 157 ù
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

NlqRVH   db        30,1,9,2                                          ; 158 û
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10100001b,00000100b,00000000b
         db        01100001b,10000000b,00000000b
         db        01100001b,01000000b,00000000b
         db        01100001b,00100000b,00000000b
         db        10100001b,00010000b,00000000b
         db        00010010b,00001100b,00000000b
         db        00001100b,00000100b,00000000b

NlqTMH   db        30,1,9,2                                          ; 159 ü
         db        00001000b,00000000b,00000000b
         db        01111111b,11110000b,00000000b
         db        00001000b,00001000b,00000000b
         db        00001000b,00000100b,00000000b
         db        00001000b,00000100b,00000000b
         db        11101000b,00000100b,00000000b
         db        00100000b,00000100b,00000000b
         db        11000000b,00001000b,00000000b
         db        00000000b,00000000b,00000000b

NlqAMC   db        30,1,9,2                                          ; 160 †
         db        00000000b,00110000b,00000000b
         db        00000100b,01001000b,00000000b
         db        00001000b,10000100b,00000000b
         db        00101000b,10000100b,00000000b
         db        01001000b,10000100b,00000000b
         db        10001000b,10000100b,00000000b
         db        00000100b,10001000b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqIMC   db        30,1,9,2                                          ; 161 °
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

NlqNMH   db        30,1,9,2                                          ; 164 §
         db        00001000b,00000100b,00000000b
         db        00001111b,11111100b,00000000b
         db        10000100b,00000100b,00000000b
         db        01001000b,00000000b,00000000b
         db        00101000b,00000000b,00000000b
         db        01001000b,00000000b,00000000b
         db        10000100b,00000100b,00000000b
         db        00000011b,11111100b,00000000b
         db        00000000b,00000100b,00000000b

NlqNVH   db        30,1,9,2                                          ; 165 •
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        10011000b,00000100b,00000000b
         db        01000110b,00000000b,00000000b
         db        01000001b,10000000b,00000000b
         db        10000000b,01100000b,00000000b
         db        00100000b,00011000b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100000b,00000000b,00000000b

NlqUVK   db        33,1,10,1                                         ; 166 ¶
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

NlqOVS   db        30,1,9,2                                          ; 167 ß
         db        00000111b,11100000b,00000000b
         db        01001000b,00010000b,00000000b
         db        10010000b,00001000b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10100000b,00000100b,00000000b
         db        10010000b,00001000b,00000000b
         db        01001000b,00010000b,00000000b
         db        00000111b,11100000b,00000000b

NlqSMH   db        27,1,8,3                                          ; 168 ®
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

NlqRMC   db        30,1,9,2                                          ; 170 ™
         db        00001000b,00000100b,00000000b
         db        00001111b,11111100b,00000000b
         db        00000010b,00000100b,00000000b
         db        00000100b,00000100b,00000000b
         db        00101000b,00000100b,00000000b
         db        01001000b,00000000b,00000000b
         db        10001000b,00000000b,00000000b
         db        00001000b,00000000b,00000000b
         db        00000100b,00000000b,00000000b

NlqRVC   db        30,1,9,2                                          ; 171 ´
         db        00100000b,00000100b,00000000b
         db        00111111b,11111100b,00000000b
         db        00100001b,00000100b,00000000b
         db        00100001b,10000000b,00000000b
         db        01100001b,01000000b,00000000b
         db        01100001b,00100000b,00000000b
         db        10100001b,00010000b,00000000b
         db        10010010b,00001100b,00000000b
         db        00001100b,00000100b,00000000b

NlqXX1   db        30,1,9,2                                          ; 172 ¨
         db        01000010b,00000000b,11000000b
         db        11111110b,00000011b,00000000b
         db        00000010b,00001100b,00000000b
         db        00000000b,00110000b,00000000b
         db        00000000b,11000000b,00000000b
         db        00000011b,00011110b,00000000b
         db        00001100b,00000010b,00000000b
         db        00110000b,11111111b,10000000b
         db        11000000b,00000010b,00000000b

NlqXX2   db        24,2,7,3                                          ; 173 ≠
         db        00111000b,11100000b,10000000b
         db        01000101b,00010000b,01000000b
         db        10000010b,00010000b,01000000b
         db        10000010b,00001000b,01000000b
         db        10000001b,00001000b,01000000b
         db        10000001b,00010100b,01000000b
         db        01000000b,11100011b,10000000b

NlqXX3   db        30,1,9,2                                          ; 174 Æ
         db        00000000b,11000000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000110b,00011000b,00000000b
         db        00001100b,11001100b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000110b,00011000b,00000000b
         db        00001100b,00001100b,00000000b

NlqXX4   db        30,1,9,2                                          ; 175 Ø
         db        00001100b,00001100b,00000000b
         db        00000110b,00011000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00001100b,11001100b,00000000b
         db        00000110b,00011000b,00000000b
         db        00000011b,00110000b,00000000b
         db        00000001b,11100000b,00000000b
         db        00000000b,11000000b,00000000b

NlqG01   db        39,0,12,0                                         ; 176 ∞
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

NlqG03   db        39,0,12,0                                         ; 178 ≤
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

NlqG04   db        6,5,1,6                                           ; 179 ≥
         db        11111111b,11111111b,11111111b

NlqG05   db        21,0,6,6                                          ; 180 ¥
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

NlqG07   db        24,0,7,5                                          ; 182 ∂
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG08   db        24,0,7,5                                          ; 183 ∑
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b

NlqG09   db        21,0,6,6                                          ; 184 ∏
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,11111111b,11111111b

NlqG10   db        24,0,7,5                                          ; 185 π
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG11   db        12,4,3,5                                          ; 186 ∫
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b

NlqG12   db        24,0,7,5                                          ; 187 ª
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10000000b,00000000b
         db        00000000b,11111111b,11111111b

NlqG13   db        24,0,7,5                                          ; 188 º
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,00100000b,00000000b
         db        11111111b,11100000b,00000000b

NlqG14   db        24,0,7,5                                          ; 189 Ω
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b

NlqG15   db        21,0,6,6                                          ; 190 æ
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        11111111b,11100000b,00000000b

NlqG16   db        21,0,6,6                                          ; 191 ø
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b

NlqG17   db        24,5,7,0                                          ; 192 ¿
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG18   db        39,0,12,0                                         ; 193 ¡
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

NlqG19   db        39,0,12,0                                         ; 194 ¬
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

NlqG20   db        24,5,7,0                                          ; 195 √
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG21   db        39,0,12,0                                         ; 196 ƒ
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

NlqG22   db        39,0,12,0                                         ; 197 ≈
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

NlqG23   db        24,5,7,0                                          ; 198 ∆
         db        11111111b,11111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG24   db        27,4,8,0                                          ; 199 «
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,11111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG25   db        27,4,8,0                                          ; 200 »
         db        11111111b,11100000b,00000000b
         db        00000000b,00100000b,00000000b
         db        11111111b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG26   db        27,4,8,0                                          ; 201 …
         db        00000000b,11111111b,11111111b
         db        00000000b,10000000b,00000000b
         db        00000000b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG27   db        39,0,12,0                                         ; 202  
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

NlqG28   db        39,0,12,0                                         ; 203 À
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

NlqG29   db        27,4,8,0                                          ; 204 Ã
         db        11111111b,11111111b,11111111b
         db        00000000b,00000000b,00000000b
         db        11111111b,10111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG30   db        39,0,12,0                                         ; 205 Õ
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

NlqG31   db        39,0,12,0                                         ; 206 Œ
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

NlqG32   db        39,0,12,0                                         ; 207 œ
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

NlqG33   db        39,0,12,0                                         ; 208 –
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

NlqG34   db        39,0,12,0                                         ; 209 —
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

NlqG35   db        39,0,12,0                                         ; 210 “
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

NlqG36   db        27,4,8,0                                          ; 211 ”
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG37   db        24,5,7,0                                          ; 212 ‘
         db        11111111b,11100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG38   db        24,5,7,0                                          ; 213 ’
         db        00000000b,11111111b,11111111b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b
         db        00000000b,10100000b,00000000b

NlqG39   db        27,4,8,0                                          ; 214 ÷
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG40   db        39,0,12,0                                         ; 215 ◊
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

NlqG41   db        39,0,12,0                                         ; 216 ÿ
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

NlqG42   db        21,0,6,6                                          ; 217 Ÿ
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        11111111b,11000000b,00000000b

NlqG43   db        24,5,7,0                                          ; 218 ⁄
         db        00000000b,01111111b,11111111b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b
         db        00000000b,01000000b,00000000b

NlqG44   db        39,0,12,0                                         ; 219 €
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

NlqG45   db        39,0,12,0                                         ; 220 ‹
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

NlqG46   db        21,0,6,6                                          ; 221 ›
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

NlqG47   db        21,6,6,0                                          ; 222 ﬁ
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b
         db        11111111b,11111111b,11111111b

NlqG48   db        39,0,12,0                                         ; 223 ﬂ
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

NlqG49   db        39,0,12,0                                         ; 224 ‡
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
;                         Tabulka fontñ LQ
;
; *****************************************************************************

; ------ tabulka indexñ - Kamenickòch LQ

KamLQ    label     word
         dw        256 dup(0)

; ------ tabulka indexñ - Latin 2 LQ

LatLQ    label     word
         dw        256 dup(0)

; ------ tabulka indexñ - KOI 8 LQ

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

; ------ zobrazen° £vodn°ho textu

         mov       dx,offset UvTxt          ; £vodn° text
         mov       ah,9
         int       21h                      ; zobrazen° £vodn°ho textu

; ------ nalezen° parametru - á°slo portu

         mov       si,81h
         xor       cx,cx
         mov       cl,ds:[si-1]             ; poáet znakñ textu
         cld
Init1:   jcxz      Init4                    ; nen° dal®° znak
         lodsb
         dec       cx
         cmp       al,"/"
         jne       Init1
         jcxz      Init2
         lodsb
         dec       cx
         cmp       al,"!"
         jne       Init2
         mov       byte ptr ds:[OdIns],1    ; p©°znak poëadavku odinstalov†n°
         jmp       short Init1

Init2:   sub       al,"1"
         jb        Init1
         cmp       al,4
         ja        Init1
         mov       byte ptr ds:[PortLPT],al ; á°slo portu
         jmp       short Init1

; ------ oznaáen° á°sla portu do textñ

Init4:   mov       al,byte ptr ds:[PortLPT] ; instalovanò port
         add       al,"1"                   ; korekce na znak ASCII
         mov       ds:[InstTxt0],al         ; á°slo portu LPT
         mov       ds:[DeInsTx0],al
         mov       ds:[DInsTxt0],al
         mov       ds:[InstDTx0],al

; ------ test stavu instalace programu CSPRINT

         mov       di,offset Ident          ; identifikaán° text
         mov       dx,ds:[PortLPT]          ; port LPT
         mov       ah,2                     ; funkce dotazu na stav
         int       17h                      ; dotaz na stav - test instalace

; ------ p©°padnÇ odinstalov†n° programu

         cmp       byte ptr ds:[OdIns],0    ; poëaduje se odinstalov†n° ?
         je        Init5                    ; nepoëaduje se odinstalov†n°
         jmp       OdInst                   ; odinstalov†n° programu

; ------ nen°-li program nainstalov†n, jeho nainstalov†n°

Init5:   mov       ax,cs                    ; tento program
         cmp       ax,ds:[SegRez]
         jne       Init6
         jmp       Instal                   ; prvn° instalace programu

Init6:   int       20h

; -----------------------------------------------------------------------------
;        test, zda se poëaduje odinstalov†n°
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
;        odinstalov†n° programu (DS=CS)
; -----------------------------------------------------------------------------

OdInst   PROC      NEAR

; ------ kontrola, zda byl program nainstalov†n

         mov       dx,offset InstDTxt       ; hl†®en° - nebyl dosud nainstalov†n
         mov       ax,ds                    ; tento segment
         cmp       ax,ds:[SegRez]           ; byl nainstalov†n ?
         je        OdInst8                  ; program nebyl nainstalov†n

; ------ kontrola INT 08h

         mov       dx,offset DInsTxt        ; hl†®en° - nelze odinstalovat
         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         cmp       bx,offset INT08
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ kontrola INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut° adresy INT 17h
         cmp       bx,offset INT17
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ kontrola INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut° adresy INT 28h
         cmp       bx,offset INT28
         jne       OdInst8
         mov       ax,es
         cmp       ax,ds:[SegRez]
         jne       OdInst8

; ------ n†vrat adresy INT 08h

         push      ds
         lds       dx,es:[Old08]            ; pñvodn° adresa INT 08h
         mov       ax,2508h
         int       21h                      ; n†vrat adresy INT 08h

; ------ n†vrat adresy INT 17h

         lds       dx,es:[Old17]            ; pñvodn° adresa INT 17h
         mov       ax,2517h
         int       21h                      ; n†vrat adresy INT 17h

; ------ n†vrat adresy INT 28h

         lds       dx,es:[Old28]            ; pñvodn° adresa INT 28h
         mov       ax,2528h
         int       21h                      ; n†vrat adresy INT 28h
         pop       ds

; ------ uvolnàn° segmentu programu

         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu programu
         mov       dx,offset DeInsTxt       ; hl†®en° - byl odinstalov†n

; ------ chybovÇ hl†®en°

OdInst8: mov       ah,9
         int       21h                      ; zobrazen° textu chybovÇho hl†®en°
         int       20h

OdInst   ENDP

; -----------------------------------------------------------------------------
;        instalace programu (DS=CS)
; -----------------------------------------------------------------------------

Instal   PROC      NEAR

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut° adresy INT 08h
         mov       word ptr ds:[Old08],bx   ; offset INT 08h
         mov       word ptr ds:[Old08+2],es ; segment INT 08h

; ------ £schova adresy INT 17h

         mov       ax,3517h
         int       21h                      ; poskytnut° adresy INT 17h
         mov       word ptr ds:[Old17],bx   ; offset INT 17h
         mov       word ptr ds:[Old17+2],es ; segment INT 17h

; ------ £schova adresy INT 28h

         mov       ax,3528h
         int       21h                      ; poskytnut° adresy INT 28h
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

; ------ uvolnàn° segmentu prost©ed°

         mov       es,ds:[2ch]              ; segment prost©ed°
         mov       ah,49h
         int       21h                      ; uvolnàn° segmentu prost©ed°

; ------ hl†®en° o instalaci

         mov       dx,offset InstTxt        ; hl†®en° o instalaci
         mov       ah,9
         int       21h                      ; zobrazen° hl†®en° o instalaci

; ------ instalace programu

         mov       dx,ds:[DelkaRez]         ; dÇlka rezidentn° á†sti
         int       27h                      ; instalace programu

Instal   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

OdIns    db        0                        ; p©°znak poëadavku odinstalov†n°

DelkaRez dw        offset Init              ; konec rezidentn° á†sti

UvTxt    db        'MANEPSON V1.0 - ovladac tiskarny MANESMANN; (c) Miroslav Nemecek'
         db        13,10,'$'

InstTxt  db        'MANEPSON byl nainstalovan pro LPT '
InstTxt0 db        '1.',13,10,'$'

DeInsTxt db        'MANEPSON byl odinstalovan z portu LPT '
DeInsTx0 db        '1.',13,10,'$'

DInsTxt  db        'MANEPSON nelze odinstalovat z portu LPT '
DInsTxt0 db        '1 !',13,10,'$'

InstDTxt db        'MANEPSON nebyl dosud pro port LPT '
InstDTx0 db        '1 nainstalovan !',13,10,'$'

Code     ENDS
         END       Start

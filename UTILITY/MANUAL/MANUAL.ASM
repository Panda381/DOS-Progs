
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                Konverze textov‚ho souboru na prohl¡‘e‡
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

IBSIZE   EQU       2000h                    ; velikost vtupn¡ho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       si,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ nalezen¡ za‡ tku jm‚na souboru

         mov       si,offset HelpTxt        ; text n povˆdy
         mov       di,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       ch,0
         mov       cl,ds:[di-1]             ; d‚lka p©¡kazov‚ho © dku
Start1:  jcxz      Chyba                    ; nen¡ nic zad no - zobraz. n povˆdy
         mov       dx,di                    ; £schova za‡ tku p©¡padn‚ho jm‚na
         inc       di                       ; zv˜¨en¡ ukazatele v textu
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       byte ptr ds:[di-1]," "   ; byl to platn˜ znak jm‚na ?
         jbe       Start1                   ; nebyl - dal¨¡ znak

; ------ nalezen¡ konce jm‚na

         jcxz      Start3                   ; konec textu
Start2:  cmp       byte ptr ds:[di]," "     ; je konec textu ?
         jbe       Start3                   ; je konec textu
         inc       di
         loop      Start2
Start3:  mov       byte ptr ds:[di],0       ; ozna‡en¡ konce jm‚na souboru

; ------ otev©en¡ vstupn¡ho souboru

         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jnc       Start4                   ; soubor otev©en OK
         mov       si,offset FndTxt         ; text - soubor nenalezen

; ------ chyba

Chyba:   call      DispTxt
         jmp       Konec


Start4:  mov       cs:[InpId],ax            ; identifik tor vstupn¡ho souboru

; ------ nalezen¡ za‡ tku jm‚na souboru

         push      di
Start43: cmp       di,dx
         je        Start44
         cmp       byte ptr ds:[di-1],"\"
         je        Start44
         cmp       byte ptr ds:[di-1],":"
         je        Start44
         dec       di
         jmp       short Start43

; ------ p©enesen¡ jm‚na do prohl¡‘e‡e

Start44: mov       si,offset cs:VSoubor
Start45: mov       al,ds:[di]
         inc       di
         cmp       al,"a"
         jb        Start46
         cmp       al,"z"
         ja        Start46
         sub       al,32
Start46: mov       cs:[si],al
         inc       si
         cmp       al,0
         jne       Start45
         pop       di

; ------ nalezen¡ p©¡pony jm‚na zdrojov‚ho souboru

         mov       bx,di                    ; £schova p©¡padn‚ho konce
Start5:  dec       di                       ; sn¡‘en¡ ukazatele v textu
         cmp       di,dx                    ; je ji‘ pod za‡ tkem ?
         jb        Start6                   ; je pod za‡ tkem - nenalezen
         cmp       byte ptr ds:[di],"\"
         je        Start6                   ; nenalezen
         cmp       byte ptr ds:[di],"."
         jne       Start5                   ; nen¡ oddˆlova‡
         mov       bx,di                    ; m¡sto k ulo‘en¡ p©¡pony

; ------ dosazen¡ p©¡pony EXE

Start6:  cld
         mov       word ptr ds:[di],"E."
         mov       word ptr ds:[di+2],"EX"
         mov       byte ptr ds:[di+4],0

; ------ otev©en¡ c¡lov‚ho souboru

         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ c¡lov‚ho souboru
         mov       si,offset OpnTxt
         jc        Chyba                    ; chyba - soubor nelze otev©¡t
         mov       cs:[OutId],ax            ; identifik tor souboru

; ------ z pis z hlav¡ EXE do v˜stupn¡ho souboru

         mov       bx,cs                    ; segment adresy
         mov       dx,offset ExeH           ; z hlav¡ EXE souboru
         mov       cx,32
         call      Zapis                    ; z pis dat do v˜stupn¡ho souboru

; ------ zji¨tˆn¡ velikosti textov‚ho souboru

         mov       bx,cs:[InpId]
         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; p©esun na konec souboru
         mov       word ptr cs:[VSize],ax
         mov       word ptr cs:[VSize+2],dx ; velikost souboru

; ------ resetov n¡ ukazatele vstupn¡ho souboru

         mov       ax,4200h
         xor       dx,dx
         xor       cx,cx
         int       21h

; ------ z pis programu prohl¡‘e‡e

         mov       bx,SEG View
         xor       dx,dx
         mov       cx,offset(ViewEnd-ViewBeg)
         call      Zapis

; -----------------------------------------------------------------------------
;        zak¢dov n¡ dat textov‚ho souboru
; -----------------------------------------------------------------------------

; ------ na‡ten¡ bloku ze vstupn¡ho souboru

Kod1:    mov       bx,cs:[InpId]
         mov       ax,SEG InpBuf            ; vstupn¡ buffer
         mov       ds,ax
         xor       dx,dx
         mov       cx,8000h                 ; velikost bufferu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat
         jnc       Kod2

         mov       si,offset ReadTxt
         jmp       Chyba

Kod2:    mov       cx,ax
         jcxz      Kod9                     ; konec souboru

; ------ dek¢dov n¡ bufferu s textem


         mov       bx,SEG InpBuf
         xor       dx,dx
         call      Zapis

         jmp       short Kod1               ; dal¨¡ blok dat


Kod9:



; ------ zji¨tˆn¡ nov‚ velikosti souboru

         mov       bx,cs:[OutId]
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h

; ------ oprava £daje velikosti programu

         mov       cx,ax
         and       cx,511                   ; d‚lka posledn¡ str nky
         mov       cs:[ExeHLst],cx          ; d‚lka posledn¡ str nky
         add       ax,511                   ; zaokrouhlen¡
         adc       dx,0
         mov       al,ah
         mov       ah,dl                    ; velikost / 256
         shr       ax,1                     ; velikost souboru / 512
         mov       cs:[ExeHPag],ax          ; velikost souboru ve str nk ch

; ------ resetov n¡ ukazatele na za‡ tek

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h

; ------ z pis nov‚ho z hlav¡ EXE

         mov       bx,cs                    ; segment adresy
         mov       dx,offset ExeH           ; z hlav¡ EXE souboru
         mov       cx,32
         call      Zapis                    ; z pis dat do v˜stupn¡ho souboru

; ------ konec programu

Konec:   mov       ax,cs:[InpId]
         or        ax,ax
         jz        Konec1
         mov       ah,3eh
         int       21h

Konec1:  mov       ax,cs:[OutId]
         or        ax,ax
         jz        Konec2
         mov       ah,3eh
         int       21h

Konec2:  mov       ax,4c00h
         int       21h


; *****************************************************************************
;                               Zapis
;                   Z pis dat do v˜stupn¡ho souboru
; -----------------------------------------------------------------------------
; VSTUP: BX:DX=adresa
;        CX=po‡et bajt–
; *****************************************************************************

Zapis    PROC      NEAR

         push      ax
         push      bx
         push      ds

         mov       ds,bx
         mov       bx,cs:[OutId]
         mov       ah,40h
         int       21h
         jc        Zapis2                   ; chyba
         cmp       ax,cx
         je        Zapis3

Zapis2:  mov       si,offset WrtTxt
         call      DispTxt                  ; chyba z pisu
         jmp       Konec

Zapis3:  pop       ds
         pop       bx
         pop       ax
         ret

Zapis    ENDP

; *****************************************************************************
;                            DispTxt
;                        zobrazen¡ textu
; -----------------------------------------------------------------------------
; VSTUP: CS:SI=adresa textu
; *****************************************************************************

DispTxt  PROC      NEAR

         push      ax
         push      dx
         push      ds

         push      cs
         pop       ds
         mov       dx,si
         mov       ah,9
         int       21h

         pop       ds
         pop       dx
         pop       ax
         ret

DispTxt  ENDP


; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Data
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

InpId    dw        0                        ; identifik tor vstupn¡ho souboru
OutId    dw        0                        ; identifik tor v˜stupn¡ho souboru

UvTxt    db        'MANUAL V1.10 - elektronicky manual; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte jmeno textoveho souboru !',13,10,'$'
FndTxt   db        'Chybne zadani vstupniho textoveho souboru !',13,10,'$'
OpnTxt   db        'Vystupni soubor nelze vytvorit !',13,10,'$'
WrtTxt   db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'

; -----------------------------------------------------------------------------
;        z hlav¡ souboru EXE
; -----------------------------------------------------------------------------

ExeH     label     byte
         db        'MZ'                     ; identifik tor z hlav¡ programu EXE
ExeHLst  dw        offset(ViewEnd-ViewBeg) AND 511 ; d‚lka posledn¡ str nky v B
ExeHPag  dw        (offset(ViewEnd-ViewBeg) + 511)/512 ; d‚lka ve str nk ch 512B
         dw        0                        ; po‡et polo‘ek reloka‡n¡ tabulky
         dw        2                        ; velikost z hlav¡ v odstavc¡ch 16 B
ExeHMin  dw        0                        ; minimum pamˆti v odstavc¡ch 16 B
ExeHMax  dw        100                      ; maximum pamˆti v odstavc¡ch 16 B
ExeHSS   dw        0fff0h                   ; segment z sobn¡ku SS
ExeHSP   dw        100h                     ; offset z sobn¡ku SP
         dw        0                        ; kontroln¡ sou‡et
ExeHIP   dw        offset(VStart-ViewBeg)   ; offset startovac¡ adresy IP
ExeHCS   dw        0                        ; segment startovac¡ adresy CS
         dw        1ch                      ; offset 1. polo‘ky relok. tabulky
         dw        0                        ; ‡¡slo OVL
         dd        0                        ; 1. polo‘ka relok. tabulky

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                        Program prohl¡‘e‡e
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

View     SEGMENT
         ASSUME    cs:View,ds:View

ViewBeg  label     byte                     ; za‡ tek prohl¡‘e‡e

; -----------------------------------------------------------------------------
;        ulo‘en¡ v˜stupn¡ho souboru
; -----------------------------------------------------------------------------

; ------ kontrola, zda je nˆco na © dku

VStart:  cmp       byte ptr ds:[80h],0      ; je nˆco na © dku ?
         push      cs
         pop       ds
         je        VStart2

; ------ test, zda v˜stupn¡ soubor ji‘ existuje

         mov       dx,offset VSoubor
         mov       ah,4eh
         mov       cx,7
         int       21h                      ; pokus o nalezen¡ souboru
         jnc       VStart2                  ; soubor ji‘ existuje

; ------ vytvo©en¡ souboru

         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         jc        VStart2                  ; soubor nelze vytvo©it
         mov       bx,ax                    ; identifik tor souboru

; ------ p©¡prava registr–

         mov       si,word ptr ds:[VSize]   ; velikost LOW
         mov       di,word ptr ds:[VSize+2] ; velikost HIGH
         mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16
         mov       ds,ax                    ; segment adresy
         xor       dx,dx                    ; offset adresy

; ------ stanoven¡ velikosti bloku k z pisu

VStart13:mov       cx,0f000h                ; max. velikost bloku
         or        di,di
         jnz       VStart14                 ; je > 64 KB
         cmp       cx,si
         jbe       VStart14
         mov       cx,si                    ; omezen¡ velikosti dat

; ------ z pis jednoho bloku na disk

VStart14:mov       ah,40h
         int       21h                      ; z pis jednoho bloku na disk
         jc        VStart19                 ; byla nˆjak  chyba

; ------ zv˜¨en¡ adresy

         mov       ax,ds
         add       ax,0f00h
         mov       ds,ax

; ------ sn¡‘en¡ po‡tu zbyl˜ch dat

         sub       si,0f000h
         sbb       di,0
         jnc       VStart13                 ; z pis dal¨¡ho bloku

; ------ uzav©en¡ souboru

VStart19:mov       ah,3eh
         int       21h
         jmp       VKonec2

; -----------------------------------------------------------------------------
;        p©¡prava k zobrazen¡
; -----------------------------------------------------------------------------

; ------ inicializace videom¢du

VStart2: mov       ah,0fh
         int       10h
         mov       bx,0b000h
         cmp       al,7
         je        VStart3
         mov       bh,0b8h
         mov       byte ptr ds:[Barva],1bh  ; barva - barevn˜ videom¢d
         mov       al,3
VStart3: mov       es,bx                    ; segment videopamˆti
         mov       ah,0
         int       10h                      ; inicializace videom¢du

; ------ vypnut¡ kurzoru

         mov       dx,25*256
         mov       ah,2
         mov       bh,0
         int       10h                      ; vypnut¡ kurzoru

; ------ p©¡prava k obsluze prohl¡‘e‡e - za‡ tek textu

VHome:   mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16
         mov       ds,ax
         xor       si,si
         mov       bx,word ptr cs:[VSize]   ; velikost textu LOW
         mov       dx,word ptr cs:[VSize+2] ; velikost textu HIGH

; -----------------------------------------------------------------------------
;        zobrazen¡ str nky
; -----------------------------------------------------------------------------

; ------ zobrazen¡ str nky

VZac:    cld
         xor       di,di                    ; po‡ tek videopamˆti
         mov       ah,cs:[Barva]            ; barva textu
         mov       bp,25                    ; po‡et © dk– k zobrazen¡

; ------ £schova registr–

         push      bx                       ; po‡et zbyl˜ch znak– LOW
         push      dx                       ; po‡et zbyl˜ch znak– HIGH
         push      si
         push      ds

; ------ zobrazen¡ jednoho © dku

VDisp1:  mov       cx,80                    ; po‡et znak– na © dek

; ------ na‡ten¡ jednoho znaku textu

VDisp2:  call      VNextCh                  ; na‡ten¡ dal¨¡ho znaku
         jc        VDisp8                   ; nen¡ dal¨¡ znak

; ------ kontrola, zda je konec © dku

         cmp       al,13
         je        VDisp2                   ; bajt CR se ignoruje
         cmp       al,1ah
         je        VDisp2                   ; EOF se ignoruje
         cmp       al,10                    ; konec © dku ?
         je        VDisp8                   ; konec © dku

; ------ ulo‘en¡ znaku na obrazovku

         jcxz      VDisp2                   ; je ji‘ pln˜ © dek
         stosw                              ; ulo‘en¡ znaku na displej
         dec       cx
         jmp       short VDisp2             ; dal¨¡ znak

; ------ vymaz n¡ zbytku © dku

VDisp8:  mov       al," "
         rep       stosw                    ; vymaz n¡ zbytku © dku

; ------ p©¡prava k zobrazen¡ dal¨¡ho © dku

         dec       bp
         jnz       VDisp1

; ------ n vrat registr–

         pop       ds
         pop       si
         pop       dx
         pop       bx

; -----------------------------------------------------------------------------
;        obsluha prohl¡‘e‡e
; -----------------------------------------------------------------------------

; ------ vstup znaku z kl vesnice

View1:   mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ str nka dol–

         mov       cx,24
         cmp       ax,5100h
         je        View2

; ------ kurzor dol–

         cmp       ax,5000h
         jne       View3
         mov       cx,1                     ; po‡et © dk– k posunu

View2:   call      VNextCh                  ; na‡ten¡ dal¨¡ho znaku
         jc        View29                   ; nen¡ dal¨¡ znak
         cmp       al,10
         jne       View2
         loop      View2

View29:  jmp       short VZac

; ------ str nka nahoru

View3:   mov       cx,24
         cmp       ax,4900h
         je        View30

; ------ kurzor nahoru

         cmp       ax,4800h
         jne       View4
         mov       cx,1                     ; po‡et © dk– k posunu

View30:  inc       cx                       ; prvn¡ LF se bude ignorovat
View31:  call      VPredCh                  ; na‡ten¡ dal¨¡ho znaku
         jc        View39                   ; je ji‘ za‡ tek
         cmp       al,10
         jne       View31                   ; nalezen¡ dal¨¡ho LF
         loop      View31                   ; dal¨¡ © dek
         call      VNextCh                  ; p©esko‡en¡ posledn¡ho LF

View39:  jmp       short View29

; ------ za‡ tek seznamu HOME

View4:   cmp       ax,4700h
         jne       View5

         jmp       VHome

; ------ konec seznamu END

View5:   cmp       ax,4f00h
         jne       ViewA

         mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16 ; segment po‡ tku textu
         mov       bx,word ptr cs:[VSize+2] ; velikost textu HIGH
         mov       cl,12
         shl       bx,cl
         add       ax,bx
         mov       ds,ax
         mov       si,word ptr cs:[VSize]   ; velikost textu LOW
         xor       bx,bx
         xor       dx,dx

         mov       cx,24
         jmp       View30                   ; posun o str nku zpˆt

; ------ n vrat z prohl¡‘e‡e ESC nebo CTRL-BREAK

ViewA:   cmp       al,27
         je        VKonec
         or        ax,ax
         jz        VKonec
         jmp       View1                    ; neobsluhovan˜ znak

; ------ vymaz n¡ obrazovky

VKonec:  mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h

VKonec2: mov       ax,4c00h
         int       21h                      ; konec prohl¡‘e‡e

; -----------------------------------------------------------------------------
;        na‡ten¡ dal¨¡ho znaku z bufferu (CY=nen¡)
; -----------------------------------------------------------------------------

VNextCh  PROC      NEAR

; ------ kontrola, zda je dal¨¡ znak

         or        dx,dx                    ; jsou dal¨¡ data ?
         jnz       VNextCh1                 ; jsou dal¨¡ data
         or        bx,bx
         stc
         jz        VNextCh9                 ; nejsou dal¨¡ data

; ------ na‡ten¡ jednoho znaku textu

VNextCh1:mov       al,ds:[si]               ; na‡ten¡ dal¨¡ho znaku

; ------ zv˜¨en¡ adresy

         inc       si                       ; je p©ekro‡en¡ segmentu ?
         jnz       VNextCh2                 ; nen¡ p©ekro‡en¡ segmentu
         push      ax
         mov       ax,ds
         add       ax,1000h                 ; posun o 64 KB
         mov       ds,ax
         pop       ax

; ------ sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–

VNextCh2:sub       bx,1                     ; sn¡‘en¡ ‡¡ta‡e zbyl˜ch znak–
         sbb       dx,0                     ; p©enos

VNextCh9:ret

VNextCh  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ p©edchoz¡ho znaku (CY=nen¡)
; -----------------------------------------------------------------------------

VPredCh  PROC      NEAR

; ------ kontrola, zda je ji‘ za‡ tek

         cmp       dx,word ptr cs:[VSize+2]
         jne       VPredCh1                 ; nen¡ za‡ tek
         cmp       bx,word ptr cs:[VSize]
         stc                                ; p©¡znak chyby
         je        VPredCh9                 ; je ji‘ za‡ tek textu

; ------ sn¡‘en¡ ukazatele textu

VPredCh1:or        si,si
         jnz       VPredCh2                 ; nen¡ za‡ tek segmentu
         push      ax
         mov       ax,ds
         sub       ax,1000h
         mov       ds,ax
         pop       ax
VPredCh2:dec       si                       ; sn¡‘en¡ adresy

; ------ na‡ten¡ znaku

         mov       al,ds:[si]               ; znak na nov‚ adrese

; ------ zv˜¨en¡ ‡¡ta‡e zb˜vaj¡c¡ch znak–

         add       bx,1
         adc       dx,0

VPredCh9:ret

VPredCh  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Barva    db        7                        ; barva textu

         EVEN
VSize    dd        0                        ; velikost textu (v bajtech)

VSoubor  db        13 dup(0)                ; jm‚no souboru

         db        16 - (($-ViewBeg) AND 0fh) dup(0) ; zarovn n¡ na odstavec

                                          ;* tato adresa je odstavcem !
ViewEnd  label     byte                     ; konec prohl¡‘e‡e

View     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                       Vstupn¡ buffer (64 KB)
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

InpBuf   SEGMENT

         db        8000h dup(?)
         db        7fffh dup(?)

InpBuf   ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             V˜stupn¡ buffer
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

OutBuf   SEGMENT

         db        IBSIZE dup(?)            ; v˜stupn¡ buffer

OutBuf   ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             z sobn¡k
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Zasob    SEGMENT   STACK

         dw        512 dup(?)

Zasob    ENDS


         END       START

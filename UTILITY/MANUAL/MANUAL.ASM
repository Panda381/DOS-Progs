
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                Konverze textov괿o souboru na prohl죷e�
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

IBSIZE   EQU       2000h                    ; velikost vtupn죋o bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ zobrazen� 즪odn죋o textu

Start:   mov       si,offset UvTxt          ; 즪odn� text
         call      DispTxt                  ; zobrazen� 즪odn죋o textu

; ------ nalezen� za뇿tku jm굈a souboru

         mov       si,offset HelpTxt        ; text n쟰ov늕y
         mov       di,81h                   ; za뇿tek pækazov괿o 찤dku
         mov       ch,0
         mov       cl,ds:[di-1]             ; d굃ka pækazov괿o 찤dku
Start1:  jcxz      Chyba                    ; nen� nic zad쟮o - zobraz. n쟰ov늕y
         mov       dx,di                    ; 즧chova za뇿tku pæpadn괿o jm굈a
         inc       di                       ; zv삩en� ukazatele v textu
         dec       cx                       ; sn죷en� 눀ta놽 znak�
         cmp       byte ptr ds:[di-1]," "   ; byl to platn� znak jm굈a ?
         jbe       Start1                   ; nebyl - dalÆ znak

; ------ nalezen� konce jm굈a

         jcxz      Start3                   ; konec textu
Start2:  cmp       byte ptr ds:[di]," "     ; je konec textu ?
         jbe       Start3                   ; je konec textu
         inc       di
         loop      Start2
Start3:  mov       byte ptr ds:[di],0       ; ozna놽n� konce jm굈a souboru

; ------ otev쯥n� vstupn죋o souboru

         mov       ax,3d00h
         int       21h                      ; otev쯥n� souboru
         jnc       Start4                   ; soubor otev쯥n OK
         mov       si,offset FndTxt         ; text - soubor nenalezen

; ------ chyba

Chyba:   call      DispTxt
         jmp       Konec


Start4:  mov       cs:[InpId],ax            ; identifik쟴or vstupn죋o souboru

; ------ nalezen� za뇿tku jm굈a souboru

         push      di
Start43: cmp       di,dx
         je        Start44
         cmp       byte ptr ds:[di-1],"\"
         je        Start44
         cmp       byte ptr ds:[di-1],":"
         je        Start44
         dec       di
         jmp       short Start43

; ------ p쯥nesen� jm굈a do prohl죷e놽

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

; ------ nalezen� pæpony jm굈a zdrojov괿o souboru

         mov       bx,di                    ; 즧chova pæpadn괿o konce
Start5:  dec       di                       ; sn죷en� ukazatele v textu
         cmp       di,dx                    ; je ji� pod za뇿tkem ?
         jb        Start6                   ; je pod za뇿tkem - nenalezen
         cmp       byte ptr ds:[di],"\"
         je        Start6                   ; nenalezen
         cmp       byte ptr ds:[di],"."
         jne       Start5                   ; nen� odd늢ova�
         mov       bx,di                    ; m죛to k ulo멷n� pæpony

; ------ dosazen� pæpony EXE

Start6:  cld
         mov       word ptr ds:[di],"E."
         mov       word ptr ds:[di+2],"EX"
         mov       byte ptr ds:[di+4],0

; ------ otev쯥n� c죐ov괿o souboru

         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo쯥n� c죐ov괿o souboru
         mov       si,offset OpnTxt
         jc        Chyba                    ; chyba - soubor nelze otevæt
         mov       cs:[OutId],ax            ; identifik쟴or souboru

; ------ z쟰is z쟦lav� EXE do v쁲tupn죋o souboru

         mov       bx,cs                    ; segment adresy
         mov       dx,offset ExeH           ; z쟦lav� EXE souboru
         mov       cx,32
         call      Zapis                    ; z쟰is dat do v쁲tupn죋o souboru

; ------ zji쮝늧� velikosti textov괿o souboru

         mov       bx,cs:[InpId]
         mov       ax,4202h
         xor       cx,cx
         xor       dx,dx
         int       21h                      ; p쯥sun na konec souboru
         mov       word ptr cs:[VSize],ax
         mov       word ptr cs:[VSize+2],dx ; velikost souboru

; ------ resetov쟮� ukazatele vstupn죋o souboru

         mov       ax,4200h
         xor       dx,dx
         xor       cx,cx
         int       21h

; ------ z쟰is programu prohl죷e놽

         mov       bx,SEG View
         xor       dx,dx
         mov       cx,offset(ViewEnd-ViewBeg)
         call      Zapis

; -----------------------------------------------------------------------------
;        zak줰ov쟮� dat textov괿o souboru
; -----------------------------------------------------------------------------

; ------ na뇍en� bloku ze vstupn죋o souboru

Kod1:    mov       bx,cs:[InpId]
         mov       ax,SEG InpBuf            ; vstupn� buffer
         mov       ds,ax
         xor       dx,dx
         mov       cx,8000h                 ; velikost bufferu
         mov       ah,3fh
         int       21h                      ; na뇍en� dat
         jnc       Kod2

         mov       si,offset ReadTxt
         jmp       Chyba

Kod2:    mov       cx,ax
         jcxz      Kod9                     ; konec souboru

; ------ dek줰ov쟮� bufferu s textem


         mov       bx,SEG InpBuf
         xor       dx,dx
         call      Zapis

         jmp       short Kod1               ; dalÆ blok dat


Kod9:



; ------ zji쮝늧� nov� velikosti souboru

         mov       bx,cs:[OutId]
         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h

; ------ oprava 즔aje velikosti programu

         mov       cx,ax
         and       cx,511                   ; d굃ka posledn� str쟮ky
         mov       cs:[ExeHLst],cx          ; d굃ka posledn� str쟮ky
         add       ax,511                   ; zaokrouhlen�
         adc       dx,0
         mov       al,ah
         mov       ah,dl                    ; velikost / 256
         shr       ax,1                     ; velikost souboru / 512
         mov       cs:[ExeHPag],ax          ; velikost souboru ve str쟮k쟠h

; ------ resetov쟮� ukazatele na za뇿tek

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h

; ------ z쟰is nov괿o z쟦lav� EXE

         mov       bx,cs                    ; segment adresy
         mov       dx,offset ExeH           ; z쟦lav� EXE souboru
         mov       cx,32
         call      Zapis                    ; z쟰is dat do v쁲tupn죋o souboru

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
;                   Z쟰is dat do v쁲tupn죋o souboru
; -----------------------------------------------------------------------------
; VSTUP: BX:DX=adresa
;        CX=po놽t bajt�
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
         call      DispTxt                  ; chyba z쟰isu
         jmp       Konec

Zapis3:  pop       ds
         pop       bx
         pop       ax
         ret

Zapis    ENDP

; *****************************************************************************
;                            DispTxt
;                        zobrazen� textu
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


; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                              Data
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

InpId    dw        0                        ; identifik쟴or vstupn죋o souboru
OutId    dw        0                        ; identifik쟴or v쁲tupn죋o souboru

UvTxt    db        'MANUAL V1.10 - elektronicky manual; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte jmeno textoveho souboru !',13,10,'$'
FndTxt   db        'Chybne zadani vstupniho textoveho souboru !',13,10,'$'
OpnTxt   db        'Vystupni soubor nelze vytvorit !',13,10,'$'
WrtTxt   db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
ReadTxt  db        'Chyba cteni ze vstupniho souboru !',13,10,'$'

; -----------------------------------------------------------------------------
;        z쟦lav� souboru EXE
; -----------------------------------------------------------------------------

ExeH     label     byte
         db        'MZ'                     ; identifik쟴or z쟦lav� programu EXE
ExeHLst  dw        offset(ViewEnd-ViewBeg) AND 511 ; d굃ka posledn� str쟮ky v B
ExeHPag  dw        (offset(ViewEnd-ViewBeg) + 511)/512 ; d굃ka ve str쟮k쟠h 512B
         dw        0                        ; po놽t polo멷k reloka뇆� tabulky
         dw        2                        ; velikost z쟦lav� v odstavc죅h 16 B
ExeHMin  dw        0                        ; minimum pam늯i v odstavc죅h 16 B
ExeHMax  dw        100                      ; maximum pam늯i v odstavc죅h 16 B
ExeHSS   dw        0fff0h                   ; segment z쟳obn죏u SS
ExeHSP   dw        100h                     ; offset z쟳obn죏u SP
         dw        0                        ; kontroln� sou놽t
ExeHIP   dw        offset(VStart-ViewBeg)   ; offset startovac� adresy IP
ExeHCS   dw        0                        ; segment startovac� adresy CS
         dw        1ch                      ; offset 1. polo멾y relok. tabulky
         dw        0                        ; 눀slo OVL
         dd        0                        ; 1. polo멾a relok. tabulky

Code     ENDS

; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                        Program prohl죷e놽
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

View     SEGMENT
         ASSUME    cs:View,ds:View

ViewBeg  label     byte                     ; za뇿tek prohl죷e놽

; -----------------------------------------------------------------------------
;        ulo멷n� v쁲tupn죋o souboru
; -----------------------------------------------------------------------------

; ------ kontrola, zda je n늓o na 찤dku

VStart:  cmp       byte ptr ds:[80h],0      ; je n늓o na 찤dku ?
         push      cs
         pop       ds
         je        VStart2

; ------ test, zda v쁲tupn� soubor ji� existuje

         mov       dx,offset VSoubor
         mov       ah,4eh
         mov       cx,7
         int       21h                      ; pokus o nalezen� souboru
         jnc       VStart2                  ; soubor ji� existuje

; ------ vytvo쯥n� souboru

         mov       ah,3ch
         xor       cx,cx
         int       21h                      ; vytvo쯥n� v쁲tupn죋o souboru
         jc        VStart2                  ; soubor nelze vytvo쯫t
         mov       bx,ax                    ; identifik쟴or souboru

; ------ pæprava registr�

         mov       si,word ptr ds:[VSize]   ; velikost LOW
         mov       di,word ptr ds:[VSize+2] ; velikost HIGH
         mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16
         mov       ds,ax                    ; segment adresy
         xor       dx,dx                    ; offset adresy

; ------ stanoven� velikosti bloku k z쟰isu

VStart13:mov       cx,0f000h                ; max. velikost bloku
         or        di,di
         jnz       VStart14                 ; je > 64 KB
         cmp       cx,si
         jbe       VStart14
         mov       cx,si                    ; omezen� velikosti dat

; ------ z쟰is jednoho bloku na disk

VStart14:mov       ah,40h
         int       21h                      ; z쟰is jednoho bloku na disk
         jc        VStart19                 ; byla n늞ak� chyba

; ------ zv삩en� adresy

         mov       ax,ds
         add       ax,0f00h
         mov       ds,ax

; ------ sn죷en� po뇍u zbyl쁟h dat

         sub       si,0f000h
         sbb       di,0
         jnc       VStart13                 ; z쟰is dalÆho bloku

; ------ uzav쯥n� souboru

VStart19:mov       ah,3eh
         int       21h
         jmp       VKonec2

; -----------------------------------------------------------------------------
;        pæprava k zobrazen�
; -----------------------------------------------------------------------------

; ------ inicializace videom줰u

VStart2: mov       ah,0fh
         int       10h
         mov       bx,0b000h
         cmp       al,7
         je        VStart3
         mov       bh,0b8h
         mov       byte ptr ds:[Barva],1bh  ; barva - barevn� videom줰
         mov       al,3
VStart3: mov       es,bx                    ; segment videopam늯i
         mov       ah,0
         int       10h                      ; inicializace videom줰u

; ------ vypnut� kurzoru

         mov       dx,25*256
         mov       ah,2
         mov       bh,0
         int       10h                      ; vypnut� kurzoru

; ------ pæprava k obsluze prohl죷e놽 - za뇿tek textu

VHome:   mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16
         mov       ds,ax
         xor       si,si
         mov       bx,word ptr cs:[VSize]   ; velikost textu LOW
         mov       dx,word ptr cs:[VSize+2] ; velikost textu HIGH

; -----------------------------------------------------------------------------
;        zobrazen� str쟮ky
; -----------------------------------------------------------------------------

; ------ zobrazen� str쟮ky

VZac:    cld
         xor       di,di                    ; po뇿tek videopam늯i
         mov       ah,cs:[Barva]            ; barva textu
         mov       bp,25                    ; po놽t 찤dk� k zobrazen�

; ------ 즧chova registr�

         push      bx                       ; po놽t zbyl쁟h znak� LOW
         push      dx                       ; po놽t zbyl쁟h znak� HIGH
         push      si
         push      ds

; ------ zobrazen� jednoho 찤dku

VDisp1:  mov       cx,80                    ; po놽t znak� na 찤dek

; ------ na뇍en� jednoho znaku textu

VDisp2:  call      VNextCh                  ; na뇍en� dalÆho znaku
         jc        VDisp8                   ; nen� dalÆ znak

; ------ kontrola, zda je konec 찤dku

         cmp       al,13
         je        VDisp2                   ; bajt CR se ignoruje
         cmp       al,1ah
         je        VDisp2                   ; EOF se ignoruje
         cmp       al,10                    ; konec 찤dku ?
         je        VDisp8                   ; konec 찤dku

; ------ ulo멷n� znaku na obrazovku

         jcxz      VDisp2                   ; je ji� pln� 찤dek
         stosw                              ; ulo멷n� znaku na displej
         dec       cx
         jmp       short VDisp2             ; dalÆ znak

; ------ vymaz쟮� zbytku 찤dku

VDisp8:  mov       al," "
         rep       stosw                    ; vymaz쟮� zbytku 찤dku

; ------ pæprava k zobrazen� dalÆho 찤dku

         dec       bp
         jnz       VDisp1

; ------ n쟶rat registr�

         pop       ds
         pop       si
         pop       dx
         pop       bx

; -----------------------------------------------------------------------------
;        obsluha prohl죷e놽
; -----------------------------------------------------------------------------

; ------ vstup znaku z kl쟶esnice

View1:   mov       ah,0
         int       16h                      ; vstup znaku z kl쟶esnice

; ------ str쟮ka dol�

         mov       cx,24
         cmp       ax,5100h
         je        View2

; ------ kurzor dol�

         cmp       ax,5000h
         jne       View3
         mov       cx,1                     ; po놽t 찤dk� k posunu

View2:   call      VNextCh                  ; na뇍en� dalÆho znaku
         jc        View29                   ; nen� dalÆ znak
         cmp       al,10
         jne       View2
         loop      View2

View29:  jmp       short VZac

; ------ str쟮ka nahoru

View3:   mov       cx,24
         cmp       ax,4900h
         je        View30

; ------ kurzor nahoru

         cmp       ax,4800h
         jne       View4
         mov       cx,1                     ; po놽t 찤dk� k posunu

View30:  inc       cx                       ; prvn� LF se bude ignorovat
View31:  call      VPredCh                  ; na뇍en� dalÆho znaku
         jc        View39                   ; je ji� za뇿tek
         cmp       al,10
         jne       View31                   ; nalezen� dalÆho LF
         loop      View31                   ; dalÆ 찤dek
         call      VNextCh                  ; p쯥sko놽n� posledn죋o LF

View39:  jmp       short View29

; ------ za뇿tek seznamu HOME

View4:   cmp       ax,4700h
         jne       View5

         jmp       VHome

; ------ konec seznamu END

View5:   cmp       ax,4f00h
         jne       ViewA

         mov       ax,cs
         add       ax,offset(ViewEnd-ViewBeg)/16 ; segment po뇿tku textu
         mov       bx,word ptr cs:[VSize+2] ; velikost textu HIGH
         mov       cl,12
         shl       bx,cl
         add       ax,bx
         mov       ds,ax
         mov       si,word ptr cs:[VSize]   ; velikost textu LOW
         xor       bx,bx
         xor       dx,dx

         mov       cx,24
         jmp       View30                   ; posun o str쟮ku zp늯

; ------ n쟶rat z prohl죷e놽 ESC nebo CTRL-BREAK

ViewA:   cmp       al,27
         je        VKonec
         or        ax,ax
         jz        VKonec
         jmp       View1                    ; neobsluhovan� znak

; ------ vymaz쟮� obrazovky

VKonec:  mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h

VKonec2: mov       ax,4c00h
         int       21h                      ; konec prohl죷e놽

; -----------------------------------------------------------------------------
;        na뇍en� dalÆho znaku z bufferu (CY=nen�)
; -----------------------------------------------------------------------------

VNextCh  PROC      NEAR

; ------ kontrola, zda je dalÆ znak

         or        dx,dx                    ; jsou dalÆ data ?
         jnz       VNextCh1                 ; jsou dalÆ data
         or        bx,bx
         stc
         jz        VNextCh9                 ; nejsou dalÆ data

; ------ na뇍en� jednoho znaku textu

VNextCh1:mov       al,ds:[si]               ; na뇍en� dalÆho znaku

; ------ zv삩en� adresy

         inc       si                       ; je p쯥kro놽n� segmentu ?
         jnz       VNextCh2                 ; nen� p쯥kro놽n� segmentu
         push      ax
         mov       ax,ds
         add       ax,1000h                 ; posun o 64 KB
         mov       ds,ax
         pop       ax

; ------ sn죷en� 눀ta놽 zbyl쁟h znak�

VNextCh2:sub       bx,1                     ; sn죷en� 눀ta놽 zbyl쁟h znak�
         sbb       dx,0                     ; p쯥nos

VNextCh9:ret

VNextCh  ENDP

; -----------------------------------------------------------------------------
;        na뇍en� p쯥dchoz죋o znaku (CY=nen�)
; -----------------------------------------------------------------------------

VPredCh  PROC      NEAR

; ------ kontrola, zda je ji� za뇿tek

         cmp       dx,word ptr cs:[VSize+2]
         jne       VPredCh1                 ; nen� za뇿tek
         cmp       bx,word ptr cs:[VSize]
         stc                                ; pæznak chyby
         je        VPredCh9                 ; je ji� za뇿tek textu

; ------ sn죷en� ukazatele textu

VPredCh1:or        si,si
         jnz       VPredCh2                 ; nen� za뇿tek segmentu
         push      ax
         mov       ax,ds
         sub       ax,1000h
         mov       ds,ax
         pop       ax
VPredCh2:dec       si                       ; sn죷en� adresy

; ------ na뇍en� znaku

         mov       al,ds:[si]               ; znak na nov� adrese

; ------ zv삩en� 눀ta놽 zb쁵aj죅죅h znak�

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

VSoubor  db        13 dup(0)                ; jm굈o souboru

         db        16 - (($-ViewBeg) AND 0fh) dup(0) ; zarovn쟮� na odstavec

                                          ;* tato adresa je odstavcem !
ViewEnd  label     byte                     ; konec prohl죷e놽

View     ENDS

; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                       Vstupn� buffer (64 KB)
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

InpBuf   SEGMENT

         db        8000h dup(?)
         db        7fffh dup(?)

InpBuf   ENDS

; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                             V쁲tupn� buffer
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

OutBuf   SEGMENT

         db        IBSIZE dup(?)            ; v쁲tupn� buffer

OutBuf   ENDS

; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                             z쟳obn죏
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

Zasob    SEGMENT   STACK

         dw        512 dup(?)

Zasob    ENDS


         END       START


KLIC1    EQU       'BR'                     ; kl�� 1 (AX)
KLIC2    EQU       'AI'                     ; kl�� 2 (BX)
KLIC3    EQU       'LE'                     ; kl�� 3 (CX)
KLIC4    EQU       'OK'                     ; kl�� 4 (CX v�stup)

; *****************************************************************************
;
;                            Braille
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Instal                   ; instalace programu

ZacRez   label     near                     ; za��tek rezidentn� ��sti

Old10    dd        0                        ; p�vodn� adresa obsluhy INT 10h

RegMap   db        0                        ; nastaven� registru pro mapov�n�

; -----------------------------------------------------------------------------
;        Obsluha p�eru�en� INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      FAR

; ------ test instalace programu

         pushf
         cmp       ax,KLIC1
         jne       Int101
         cmp       bx,KLIC2
         jne       Int101
         cmp       cx,KLIC3
         jne       Int101
         call      dword ptr cs:[Old10] ; vol�n� p�vodn� funkce
         push      cs
         pop       es
         mov       cx,KLIC4                 ; v�stupn� identifik�tor
         iret

; ------ rozli�en�, zda se maj� p�einstalovat fonty

Int101:  or        ah,ah                    ; je nastaven� m�du displeje ?
         jz        Int103                   ; je nastaven� videom�du
         cmp       ax,4f02h                 ; je nastaven� m�du VESA ?
         je        Int103                   ; je nastaven� m�du VESA
         cmp       ah,11h                   ; je slu�ba obsluhy font� ?
         jne       Int102                   ; nen� operace s fonty

; ------ kontrola, zda je nastaven� font� slu�by 11h

         test      al,0fh                   ; jsou u�iv. fonty nebo informace ?
         jz        Int102                   ; u�ivatelsk� fonty nebo informace
         cmp       al,3                     ; je nastaven� bloku font� ?
         jne       Int103                   ; nen� nastaven� bloku
Int102:  popf
         jmp       dword ptr cs:[Old10]; skok na p�vodn� obsluhu INT 10h

; ------ fonty se p�einstaluj�

Int103:  call      dword ptr cs:[Old10] ; vol�n� p�vodn� funkce

; ------ �schova registr� (sem se sk��e z instalace !)

Int1032: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ kontrola, zda je standardn� textov� videom�d

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0 datov� segment BIOS
         mov       al,ds:[449h]             ; aktu�ln� videom�d
         and       al,7fh                   ; zru�en� p��znaku nemaz�n� displeje
         mov       ah,0eh                   ; registr mapov�n� pro CGA
         cmp       al,3                     ; je textov� videom�d CGA ?
         jbe       Int104                   ; je textov� m�d CGA - OK
         mov       ah,0ah                   ; registr mapov�n� pro MDA
         cmp       al,7                     ; je videom�d MDA ?
         je        Int104                   ; je videom�d MDA
         cmp       al,19
         jbe       Int109                   ; je standardn� grafick� m�d

; ------ test, zda je textov� m�d SVGA

         mov       dx,3ceh
         mov       al,6
         out       dx,al                    ; ��dic� registr
         inc       dx
         in        al,dx
         mov       ah,al                    ; �schova registru m�du
         and       al,0fh
         cmp       al,0eh                   ; textov� m�d CGA
         je        Int104                   ; je textov� m�d CGA
         cmp       al,0ah                   ; textov� m�d MDA
         jne       Int109                   ; nen� textov� m�d
Int104:  mov       cs:[RegMap],ah     ; �schova registru pro mapov�n�

; ------ nastaven� video�adi�e do re�imu definice znak�

         call      InitRegF                 ; inicializace registr� pro fonty

; ------ p�edefinov�n� font�

         mov       ax,ds:[485h]             ; po�et linek na znak
         call      Defin                    ; definov�n� n�rodn�ch font�

; ------ zp�tn� nastaven� videom�du

         call      InitRegT                 ; inicializace registr� pro text

; ------ n�vrat registr�

Int109:  pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         iret

Int10    ENDP

; -----------------------------------------------------------------------------
;     Inicializace registr� videokarty na re�im definice font�
; -----------------------------------------------------------------------------

InitRegF PROC      NEAR

         mov       ah,2                     ; �tec� rovina
         mov       cx,4                     ; nastaven� mapov�n� pro fonty
         mov       bx,407h                  ; BH=roviny, BL=prokl�d�n�
         jmp       short InitReg            ; inicializace registr�

InitRegF ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr� videokarty na textov� videom�d
; -----------------------------------------------------------------------------

InitRegT PROC      NEAR

         mov       ah,0                     ; �tec� rovina
         mov       cl,cs:[RegMap]     ; registr pro mapov�n�
         mov       ch,10h                   ; registr m�du - prokl�d�n�
         mov       bx,303h                  ; BH=roviny, BL=prokl�d�n�

InitRegT ENDP

; -----------------------------------------------------------------------------
;        Inicializace registr� videokarty
; -----------------------------------------------------------------------------
; VSTUP: AH=�tec� rovina (0=text, 1=atributy, 2=fonty)
;        BH=roviny k z�pisu (bit 0 = text, bit 1 = atributy, bit 2 = fonty)
;        BL=nastaven� prokl�d�n� (3=je prokl�d�n� rovin, 7=sekven�n� adresy)
;        CL=nastaven� mapov�n� (04h=A000h, 0Ah=B000h, 0Eh=B800h)
;        CH=registr m�du (0=sekven�n� adresov�n�, 10h=prokl�dan� adresov�n�)
; -----------------------------------------------------------------------------
; zni�en� registry: AX, DX
; -----------------------------------------------------------------------------

InitReg  PROC      NEAR

; ------ volba rovin pro z�pis (maska)

         mov       dx,3c4h                  ; b�zov� adresa 03c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,bh                    ; roviny k z�pisu
         out       dx,al                    ; nastaven� rovin pro z�pis

; ------ nastav. prokl�d�n� bajt� sud�/lich�

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,bl                    ; prokl�d�n�
         out       dx,al                    ; nastaven� prokl�d�n� bajt�

; ------ nastaven� mapov�n� videopam�ti (adresa)

         mov       dl,0ceh                  ; port 03ceh/03cfh
         mov       al,6
         out       dx,al                    ; volba registru 6
         inc       dx
         mov       al,cl                    ; nastaven� mapov�n�
         out       dx,al                    ; nastaven� mapov�n� videopam�ti

; ------ nastaven� registru m�du (�ten� i z�pis - M�D 0)

         dec       dx
         mov       al,5
         out       dx,al                    ; volba registru 5
         inc       dx
         mov       al,ch                    ; registr m�du
         out       dx,al

; ------ volba roviny pro �ten�

         dec       dx
         mov       al,4
         out       dx,al                    ; volba registru 4
         inc       dx
         mov       al,ah                    ; rovina ke �ten�
         out       dx,al                    ; nastaven� roviny ke �ten�
         ret

InitReg  ENDP

; -----------------------------------------------------------------------------
;        p�edefinov�n� znak� (AX=po�et linek na znak)
; -----------------------------------------------------------------------------

Defin    PROC      NEAR

         sub       ax,8
         jnc       Defin0
         xor       ax,ax
Defin0:  shr       ax,1
         xchg      ax,bx                    ; BX <- po��tek

         mov       ax,0a000h
         mov       es,ax
         push      cs
         pop       ds

         cld
         mov       si,offset Fonty
         lodsb
Defin1:  cmp       al,255
         je        Defin9

         mov       ah,32
         mul       ah
         xchg      ax,di

         push      di
         mov       cx,32/2
         xor       ax,ax
         rep       stosw
         pop       di

Defin2:  lodsb
         cmp       al,6
         ja        Defin1

         push      di

         cmp       al,3
         mov       ah,01100000b
         jbe       Defin3
         sub       al,3
         mov       ah,00001100b
Defin3:  cmp       al,2
         jb        Defin5
         je        Defin4
         inc       di
         inc       di
         inc       di
Defin4:  inc       di
         inc       di
         inc       di
Defin5:  or        es:[di+bx],ah
         or        es:[di+1+bx],ah

         pop       di
         jmp       short Defin2

Defin9:  ret

Defin    ENDP

; -----------------------------------------------------------------------------
;        defini�n� tabulka
; -----------------------------------------------------------------------------

Fonty    label     byte
         db        'a',1
         db        'A',1
         db        '�',1,6
         db        '�',1,6
         db        'b',1,2
         db        'B',1,2
         db        'c',1,4
         db        'C',1,4
         db        '�',1,4,6
         db        '�',1,4,6
         db        'd',1,4,5
         db        'D',1,4,5
         db        '�',1,4,5,6
         db        '�',1,4,5,6
         db        'e',1,5
         db        'E',1,5
         db        '�',3,4,5
         db        '�',3,4,5
         db        '�',1,2,6
         db        '�',1,2,6
         db        'f',1,2,4
         db        'F',1,2,4
         db        'g',1,2,4,5
         db        'G',1,2,4,5
         db        'h',1,2,5
         db        'H',1,2,5
;         db        'ch',1,2,4,5,6
         db        'i',2,4
         db        'I',2,4
         db        '�',3,4
         db        '�',3,4
         db        'j',2,4,5
         db        'J',2,4,5
         db        'k',1,3
         db        'K',1,3
         db        'l',1,2,3
         db        'L',1,2,3
         db        'm',1,3,4
         db        'M',1,3,4
         db        'n',1,3,4,5
         db        'N',1,3,4,5
         db        '�',1,2,4,6
         db        '�',1,2,4,6
         db        'o',1,3,5
         db        'O',1,3,5
         db        '�',2,4,6
         db        '�',2,4,6
         db        '�',1,2,3,5,6           ; (n�hradn� symbol nam�sto OU)
         db        '�',1,2,3,5,6           ; (n�hradn� symbol nam�sto OU)
         db        'p',1,2,3,4
         db        'P',1,2,3,4
         db        'q',1,2,3,4,5
         db        'Q',1,2,3,4,5
         db        'r',1,2,3,5
         db        'R',1,2,3,5
         db        '�',2,4,5,6
         db        '�',2,4,5,6
         db        's',2,3,4
         db        'S',2,3,4
         db        '�',1,5,6
         db        '�',1,5,6
         db        't',2,3,4,5
         db        'T',2,3,4,5
         db        '�',1,2,5,6
         db        '�',1,2,5,6
         db        'u',1,3,6
         db        'U',1,3,6
         db        '�',3,4,6
         db        '�',3,4,6
         db        '�',2,3,4,5,6
         db        '�',2,3,4,5,6
         db        'v',1,2,3,6
         db        'V',1,2,3,6
         db        'w',1,2,4,5,6           ; (n�hradn� symbol nam�sto CH)
         db        'W',1,2,4,5,6           ; (n�hradn� symbol nam�sto CH)
         db        'x',1,3,4,6
         db        'X',1,3,4,6
         db        'y',1,3,4,5,6
         db        'Y',1,3,4,5,6
         db        '�',1,2,3,4,6
         db        '�',1,2,3,4,6
         db        'z',1,3,5,6
         db        'Z',1,3,5,6
         db        '�',2,3,4,6
         db        '�',2,3,4,6
;         db        'ou',1,2,3,5,6

         db        '+',3,4,5,6             ; ��seln� znak (n�hradn� symbol)
         db        ',',2
         db        ':',2,5
         db        '?',2,6
         db        '(',2,3,5,6
         db        ')',2,3,5,6
         db        '*',3,5
         db        '-',3,6
         db        '@',4,6                 ; velk� p�smeno (n�hradn� symbol)
         db        ';',2,3
         db        '.',2,5,6
         db        '!',2,3,5
         db        '`',2,3,6               ; doln� uvozovka (n�hradn� symbol)
         db        '"',3,5,6               ; horn� uvozovka
         db        '''',3                 ; apostrof

         db        '1',1                   ; 'a'
         db        '2',1,2                 ; 'b'
         db        '3',1,4                 ; 'c'
         db        '4',1,4,5               ; 'd'
         db        '5',1,5                 ; 'e'
         db        '6',1,2,4               ; 'f'
         db        '7',1,2,4,5             ; 'g'
         db        '8',1,2,5               ; 'h'
         db        '9',2,4                 ; 'i'
         db        '0',2,4,5               ; 'j'


         db        '#',3,5                  ; (n�hradn� symbol)
         db        '$',4,6                  ; (n�hradn� symbol)
         db        '%',4,6                 ; (n�hradn� symbol)
         db        '&',4,6                 ; (n�hradn� symbol)
         db        '/',3,6                  ; (n�hradn� symbol) "-"
         db        '\',3,6                  ; (n�hradn� symbol) "-"
         db        '=',3,6                  ; (n�hradn� symbol) "-"
         db        '<',2,3,5,6              ; (n�hradn� symbol) "()"
         db        '>',2,3,5,6              ; (n�hradn� symbol) "()"
         db        '[',2,3,5,6              ; (n�hradn� symbol) "()"
         db        ']',2,3,5,6              ; (n�hradn� symbol) "()"
         db        '{',2,3,5,6              ; (n�hradn� symbol) "()"
         db        '}',2,3,5,6              ; (n�hradn� symbol) "()"
         db        '_',3,6
         db        '^',3,6
         db        '|',3,6
         db        '~',3,6
         db        '�',2,3,4,5,6
         db        '�',2,3,4,5,6
         db        '�',1,6
         db        '�',1,6
         db        '�',1,2,3
         db        '�',1,2,3
         db        '�',1,2,3
         db        '�',1,2,3
         db        '�',1,2,3,5,6           ; (n�hradn� symbol nam�sto OU)
         db        '�',1,2,3,5,6           ; (n�hradn� symbol nam�sto OU)
         db        '�',2,4,5,6
         db        '�',2,4,5,6
         db        '�',3,5

         db        255

; *****************************************************************************
;                         Instalace programu
; *****************************************************************************
;�
; ------ instalace INT 23h

Instal:  mov       dx,offset Int23          ; obsluha INT 23h
         mov       ax,2523h
         int       21h                      ; instalace obsluhy INT 23h

; ------ test, zda je program ji� nainstalov�n

         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         int       10h                      ; test instalace programu
         cmp       cx,KLIC4
         je        Inst11                   ; program je jiz nainstalovan
         push      cs
         pop       es
         or        byte ptr ds:[ParamIns],1 ; p��znak prvn� instalace
Inst11:  mov       ds:[SegRez],es           ; rezidentn� segment

; ------ test karty EGA/VGA

         mov       ah,12h                   ; funkce informac� EGA
         mov       bx,3e10h                 ; podfunkce - test instalace
         int       10h                      ; informace o kart� EGA
         cmp       bh,1
         ja        Chyba1                   ; nen� karta EGA/VGA
         cmp       bl,6                     ; kontrola navr�cen�ho �daje
         jb        Instal1                  ; je displej EGA/VGA

; ------ chyba - nen� karta EGA/VGA

Chyba1:  mov       dx,offset ErrTxt         ; chyba - nen� karta EGA/VGA

; ------ zobrazen� �vodn�ho textu a chybov�ho hl��en�

Chyba:   push      dx
         mov       dx,offset UvTxt          ; �vodn� text
         mov       ah,9
         int       21h                      ; zobrazen� �vodn�ho textu
         pop       dx

         mov       ah,9
         int       21h                      ; zobrazen� chybov�ho hl��en�
         int       20h

; ------ odinstalov�n�

Instal1: test      byte ptr ds:[ParamIns],1 ; je to prvn� instalace ?
         jnz       Instal6                  ; je to prvn� instalace

; ------ test, zda lze odinstalovat

         mov       ax,3510h
         int       21h                      ; poskytnut� adresy INT 10h
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         mov       ax,es
         cmp       ax,ds:[SegRez]           ; souhlas� adresa ?
         jne       Chyba                    ; chyba - nelze odinstalovat

; ------ n�vrat vektoru INT 10h

         push      ds
         lds       dx,es:[Old10]      ; p�vodn� adresa INT 10h
         mov       ax,2510h
         int       21h                      ; n�vrat adresy INT 10h
         pop       ds

; ------ uvoln�n� segmentu programu

         mov       ah,49h
         int       21h                      ; uvoln�n� segmentu ES

; ------ inicializace videom�du

         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h

; ------ hl��en� o odinstalov�n�

         mov       dx,offset OdInsTxt       ; text - byl odinstalov�n
         jmp       short Chyba              ; hl��en� o odindstalov�n�

; ------ �schova p�vodn� adresy INT 10h

Instal6: push      es
         mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10],bx ; �schova offsetu INT 10h
         mov       word ptr ds:[Old10+2],es ; �schova segmentu INT 10h

; ------ instalace nov� obsluhy INT 10h

         mov       dx,offset Int10    ; vlastn� obsluha INT 10h
         mov       ax,2510h
         int       21h                      ; instalace vlastn� obsluhy INT 10h

; ------ uvoln�n� pam��ov�ho bloku segmentu prost�ed�

         mov       es,ds:[2ch]              ; segment prost�ed�
         mov       ah,49h                   ; funkce uvoln�n� pam�ti
         int       21h                      ; uvoln�n� bloku pam�ti
         pop       es

; ------ inicializace videom�du

         call      Inform                   ; inicializace videom�du + hl��en�

; ------ instalace programu

         mov       dx,offset Instal         ; konec rezidentn� ��sti
         int       27h                      ; instalace programu

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

Int23    PROC      FAR

         iret

Int23    ENDP

; -----------------------------------------------------------------------------
;        zobrazen� informa�n�ho textu (ES=segment programu)
; -----------------------------------------------------------------------------

Inform   PROC      NEAR

         pushf
         push      cs
         call      near ptr Int1032   ; instalace font�

; ------ zobrazen� �vodn�ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen� �vodn�ho textu

; ------ hl��en�, �e byl nainstalov�n

         mov       dx,offset InstTxt        ; text - byl nainstalov�n
         mov       ah,9
         int       21h                      ; hl��en� o nainstalov�n� programu
         ret

Inform   ENDP

; -----------------------------------------------------------------------------
;                                  data
; -----------------------------------------------------------------------------
;�
SegRez   dw        0                        ; sezidentn� segment

ParamIns db        0                        ; parametry pro instalaci
                                            ;   bit 0: 1=je prvn� instalace

ErrTxt   db        'Neni nainstalovana karta EGA/VGA !',13,10,'$'

UvTxt    db        'BRAILLE V1.00 - Brailleova soustava; (c) Miroslav Nemecek',13,10,'$'

InstTxt  db        'BRAILLE byl nainstalovan.',13,10,'$'
OdInsTxt db        'BRAILLE byl odinstalovan z pameti.',13,10,'$'
NelzeTxt db        'BRAILLE nelze odinstalovat !',13,10,'$'

Code     ENDS
         END       Start

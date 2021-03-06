
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                   FLIP-FLOP z쟭늧a disketov쁟h mechanik A a B
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; -----------------------------------------------------------------------------
;        instala뇆� 뇿st
; -----------------------------------------------------------------------------

; ------ zobrazen� v쁹vy

Start:   mov       dx,offset VyzvaTxt
         mov       ah,9
         int       21h

; ------ 놽k쟮� na zad쟮� znaku

         mov       ah,0
         int       16h

; ------ konverze znaku na velk� p죛meno

         cmp       al,"a"
         jb        Start1
         cmp       al,"b"
         ja        Start1
         and       al,not 20h               ; konverze na velk� p죛meno

; ------ 눀slo mechaniky

Start1:  sub       al,"A"                   ; 눀slo mechaniky
         jc        Start9
         cmp       al,2
         jae       Start9                   ; nen� ozna놽n� disku
         xchg      ax,dx                    ; DL <- zadan� 눀slo mechaniky

; ------ na뇍en� BOOT sektoru

         mov       ah,2
         call      int13                    ; na뇍en� sektoru
         jnc       Start3                   ; sektor na뇍en OK
         mov       dx,offset ReadTxt        ; text - chyba 뇍en�
         jmp       short Start8

; ------ modifikace BOOT sektoru

Start3:  mov       si,offset Boot           ; nov� BOOT sektor
         mov       di,offset Buffer         ; buffer s na뇍en쁬 BOOT sektorem
         mov       cx,11                    ; d굃ka 즪odn� 뇿sti
         cld
         rep       movsb                    ; p쯥nos 즪odn� 뇿sti

         mov       di,offset Buffer + 3eh   ; za뇿tek druh� 뇿sti
         mov       cx,offset(RezEnd-Boot1)  ; d굃ka druh� 뇿sti
         rep       movsb                    ; p쯥nos druh� 뇿sti

         mov       word ptr ds:[Buffer + 512 - 2],0aa55h ; identifik쟴or BOOT

; ------ z쟰is BOOT sektoru

         mov       ah,3
         call      int13                    ; z쟰is sektoru
         jnc       Start9                   ; sektor zaps쟮 OK
         mov       dx,offset WritTxt        ; text - chyba z쟰isu

; ------ chybov� hl젴en�

Start8:  mov       ah,9
         int       21h                      ; zobrazen� chybov괿o hl젴en�
Start9:  int       20h

; ------ texty

VyzvaTxt db        'FlipFlop V1.0 - zamena disketovych mechanik A: a B:; (c) Miroslav Nemecek',13,10
         db        '  Program ulozi na disketu novy zavadeci (BOOT) sektor. Startem pocitace',13,10
         db        '  z teto diskety bude zamenena disketova mechanika A: a B:,',13,10
         db        '  takze zavedeni systemu probehne z disketove mechaniky B:.',13,10
         db        13,10
         db        'Stisknete A nebo B = disketa, kam se novy BOOT sektor ulozi.',13,10,'$'

ReadTxt  db        'Chyba cteni z diskety !',13,10,'$'
WritTxt  db        'Chyba zapisu na disketu !',13,10,'$'

; ------ obsluha INT 13h

Int13:   mov       bp,3                     ; 눀ta� pokus�

Int131:  push      ax
         push      dx
         push      ds
         push      es
         push      bp

         mov       dh,0                     ; strana 0
         mov       cx,1                     ; v쟫ec 0, sektor 1
         mov       al,1                     ; 1 sektor
         mov       bx,offset Buffer         ; buffer se sektorem

         int       13h

         pop       bp
         pop       es
         pop       ds
         pop       dx
         pop       ax

         jnc       Int134                   ; operace OK
         dec       bp                       ; 눀ta� pokus�
         jnz       Int131                   ; dalÆ pokus
Int134:  ret

; -----------------------------------------------------------------------------
;        BOOT sektor (adresa 7C00h)
; -----------------------------------------------------------------------------

BootKor  EQU       7C3Eh - offset(Boot1-Start) - 100h ; korekce adresy BOOT

Boot     db        0ebh,3ch,90h             ; instrukce JMP 7C3Eh, NOP
         db        'FlipFlop'

; Adresa 7C3Eh

; ------ inicializace registr�

Boot1:   xor       ax,ax                    ; AX <- 0
         mov       ss,ax                    ; SS <- 0
         mov       sp,7c00h                 ; z쟳obn죏 pod zavad늾em
         mov       ds,ax                    ; DS <- 0
         mov       es,ax                    ; ES <- 0

; ------ 즧chova vektoru p쯥ru쮍n� INT 13h

         cld
         mov       si,13h*4                 ; p뻱odn� adresa INT 13h
         mov       di,offset Old13 + BootKor ; buffer k 즧chov� adresy INT 13h
         movsw                              ; 즧chova p뻱odn� adresy INT 13h
         movsw

; ------ sn죷en� konce voln� pam늯i

         mov       ax,ds:[413h]             ; velikost pam늯i v KB
         dec       ax                       ; rezerva 1 KB v pam늯i
         mov       ds:[413h],ax             ; nov� velikost pam늯i

; ------ adresa rezidentn� 뇿sti programu

         mov       cl,6                     ; po놽t rotac� pro p쯥po놽t
         shl       ax,cl                    ; p쯥po놽t na adresu
         mov       es,ax                    ; ES <- adresa rezidentu
         xor       di,di                    ; DI <- offset rezidentu

; ------ nadefinov쟮� nov� adresy INT 13h

         mov       ds:[4*13h],di            ; offset nov� adresy rezidentu
         mov       ds:[4*13h+2],ax          ; segment nov� adresy rezidentu

; ------ p쯥nos rezidentn� 뇿sti na vrchol pam늯i

         mov       si,offset RezBeg + BootKor ; za뇿tek rezidentn� 뇿sti
         mov       cx,offset(RezEnd-RezBeg) ; d굃ka rezidentn� 뇿sti
         rep       movsb                    ; p쯥nos rezidentn� 뇿sti nahoru

; ------ zobrazen� informa뇆죋o textu

         mov       si,offset BootTxt + BootKor ; informa뇆� text
Boot2:   cld
         lodsb                              ; znak k zobrazen�
         cmp       al,0                     ; je konec textu ?
         je        Boot3                    ; je konec textu
         mov       bx,7                     ; b죐� barva
         mov       ah,0eh
         int       10h                      ; zobrazen� znaku
         jmp       short Boot2

; ------ 놽k쟮� na stisk kl쟶esy

Boot3:   xor       ax,ax                    ; AX <- 0
         int       16h                      ; 놽k쟮� na stisk kl쟶esy

; ------ pokra뇇v쟮� v zav쟡늧� syst굆u

         int       19h

; ------ informa뇆� text

BootTxt  db        13,10
         db        'Disketove mechaniky A: a B: byly zameneny.',13,10
         db        'Vlozte systemovou disketu do druhe mechaniky',13,10
         db        'a stisknete libovolnou klavesu ...',13,10,0

; ------ rezidentn� modul

RezBeg   label     byte

         or        dl,dl                    ; je to disketa ?
         js        RezBeg1                  ; nen� to disketa
         cmp       ah,8                     ; je poskytnut� disket. parametr� ?
         jne       RezBeg2                  ; nen� poskytnut� parametr�

         xor       dl,1                     ; z쟭늧a disketov쁟h mechanik
RezBeg1: jmp       dword ptr cs:[Old13-RezBeg] ; pokra뇇v쟮� v p뻱odn� obsluze

RezBeg2: push      dx
         xor       dl,1                     ; z쟭늧a disketov쁟h mechanik
         pushf
         call      dword ptr cs:[Old13-RezBeg] ; vol쟮� po멲dovan� funkce
         pop       dx                       ; n쟶rat 눀sla disku v DL
         retf      2

Old13    dd        0                        ; p뻱odn� adresa INT 13h

RezEnd   label     byte                     ; konec rezidentn� 뇿sti

Buffer   label     byte                     ; buffer k na뇍en� sektoru

Code     ENDS
         END       Start

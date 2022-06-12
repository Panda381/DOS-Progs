
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                   FLIP-FLOP z mˆna disketov˜ch mechanik A a B
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; -----------------------------------------------------------------------------
;        instala‡n¡ ‡ st
; -----------------------------------------------------------------------------

; ------ zobrazen¡ v˜zvy

Start:   mov       dx,offset VyzvaTxt
         mov       ah,9
         int       21h

; ------ ‡ek n¡ na zad n¡ znaku

         mov       ah,0
         int       16h

; ------ konverze znaku na velk‚ p¡smeno

         cmp       al,"a"
         jb        Start1
         cmp       al,"b"
         ja        Start1
         and       al,not 20h               ; konverze na velk‚ p¡smeno

; ------ ‡¡slo mechaniky

Start1:  sub       al,"A"                   ; ‡¡slo mechaniky
         jc        Start9
         cmp       al,2
         jae       Start9                   ; nen¡ ozna‡en¡ disku
         xchg      ax,dx                    ; DL <- zadan‚ ‡¡slo mechaniky

; ------ na‡ten¡ BOOT sektoru

         mov       ah,2
         call      int13                    ; na‡ten¡ sektoru
         jnc       Start3                   ; sektor na‡ten OK
         mov       dx,offset ReadTxt        ; text - chyba ‡ten¡
         jmp       short Start8

; ------ modifikace BOOT sektoru

Start3:  mov       si,offset Boot           ; nov˜ BOOT sektor
         mov       di,offset Buffer         ; buffer s na‡ten˜m BOOT sektorem
         mov       cx,11                    ; d‚lka £vodn¡ ‡ sti
         cld
         rep       movsb                    ; p©enos £vodn¡ ‡ sti

         mov       di,offset Buffer + 3eh   ; za‡ tek druh‚ ‡ sti
         mov       cx,offset(RezEnd-Boot1)  ; d‚lka druh‚ ‡ sti
         rep       movsb                    ; p©enos druh‚ ‡ sti

         mov       word ptr ds:[Buffer + 512 - 2],0aa55h ; identifik tor BOOT

; ------ z pis BOOT sektoru

         mov       ah,3
         call      int13                    ; z pis sektoru
         jnc       Start9                   ; sektor zaps n OK
         mov       dx,offset WritTxt        ; text - chyba z pisu

; ------ chybov‚ hl ¨en¡

Start8:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho hl ¨en¡
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

Int13:   mov       bp,3                     ; ‡¡ta‡ pokus–

Int131:  push      ax
         push      dx
         push      ds
         push      es
         push      bp

         mov       dh,0                     ; strana 0
         mov       cx,1                     ; v lec 0, sektor 1
         mov       al,1                     ; 1 sektor
         mov       bx,offset Buffer         ; buffer se sektorem

         int       13h

         pop       bp
         pop       es
         pop       ds
         pop       dx
         pop       ax

         jnc       Int134                   ; operace OK
         dec       bp                       ; ‡¡ta‡ pokus–
         jnz       Int131                   ; dal¨¡ pokus
Int134:  ret

; -----------------------------------------------------------------------------
;        BOOT sektor (adresa 7C00h)
; -----------------------------------------------------------------------------

BootKor  EQU       7C3Eh - offset(Boot1-Start) - 100h ; korekce adresy BOOT

Boot     db        0ebh,3ch,90h             ; instrukce JMP 7C3Eh, NOP
         db        'FlipFlop'

; Adresa 7C3Eh

; ------ inicializace registr–

Boot1:   xor       ax,ax                    ; AX <- 0
         mov       ss,ax                    ; SS <- 0
         mov       sp,7c00h                 ; z sobn¡k pod zavadˆ‡em
         mov       ds,ax                    ; DS <- 0
         mov       es,ax                    ; ES <- 0

; ------ £schova vektoru p©eru¨en¡ INT 13h

         cld
         mov       si,13h*4                 ; p–vodn¡ adresa INT 13h
         mov       di,offset Old13 + BootKor ; buffer k £schovˆ adresy INT 13h
         movsw                              ; £schova p–vodn¡ adresy INT 13h
         movsw

; ------ sn¡‘en¡ konce voln‚ pamˆti

         mov       ax,ds:[413h]             ; velikost pamˆti v KB
         dec       ax                       ; rezerva 1 KB v pamˆti
         mov       ds:[413h],ax             ; nov  velikost pamˆti

; ------ adresa rezidentn¡ ‡ sti programu

         mov       cl,6                     ; po‡et rotac¡ pro p©epo‡et
         shl       ax,cl                    ; p©epo‡et na adresu
         mov       es,ax                    ; ES <- adresa rezidentu
         xor       di,di                    ; DI <- offset rezidentu

; ------ nadefinov n¡ nov‚ adresy INT 13h

         mov       ds:[4*13h],di            ; offset nov‚ adresy rezidentu
         mov       ds:[4*13h+2],ax          ; segment nov‚ adresy rezidentu

; ------ p©enos rezidentn¡ ‡ sti na vrchol pamˆti

         mov       si,offset RezBeg + BootKor ; za‡ tek rezidentn¡ ‡ sti
         mov       cx,offset(RezEnd-RezBeg) ; d‚lka rezidentn¡ ‡ sti
         rep       movsb                    ; p©enos rezidentn¡ ‡ sti nahoru

; ------ zobrazen¡ informa‡n¡ho textu

         mov       si,offset BootTxt + BootKor ; informa‡n¡ text
Boot2:   cld
         lodsb                              ; znak k zobrazen¡
         cmp       al,0                     ; je konec textu ?
         je        Boot3                    ; je konec textu
         mov       bx,7                     ; b¡l  barva
         mov       ah,0eh
         int       10h                      ; zobrazen¡ znaku
         jmp       short Boot2

; ------ ‡ek n¡ na stisk kl vesy

Boot3:   xor       ax,ax                    ; AX <- 0
         int       16h                      ; ‡ek n¡ na stisk kl vesy

; ------ pokra‡ov n¡ v zav dˆn¡ syst‚mu

         int       19h

; ------ informa‡n¡ text

BootTxt  db        13,10
         db        'Disketove mechaniky A: a B: byly zameneny.',13,10
         db        'Vlozte systemovou disketu do druhe mechaniky',13,10
         db        'a stisknete libovolnou klavesu ...',13,10,0

; ------ rezidentn¡ modul

RezBeg   label     byte

         or        dl,dl                    ; je to disketa ?
         js        RezBeg1                  ; nen¡ to disketa
         cmp       ah,8                     ; je poskytnut¡ disket. parametr– ?
         jne       RezBeg2                  ; nen¡ poskytnut¡ parametr–

         xor       dl,1                     ; z mˆna disketov˜ch mechanik
RezBeg1: jmp       dword ptr cs:[Old13-RezBeg] ; pokra‡ov n¡ v p–vodn¡ obsluze

RezBeg2: push      dx
         xor       dl,1                     ; z mˆna disketov˜ch mechanik
         pushf
         call      dword ptr cs:[Old13-RezBeg] ; vol n¡ po‘adovan‚ funkce
         pop       dx                       ; n vrat ‡¡sla disku v DL
         retf      2

Old13    dd        0                        ; p–vodn¡ adresa INT 13h

RezEnd   label     byte                     ; konec rezidentn¡ ‡ sti

Buffer   label     byte                     ; buffer k na‡ten¡ sektoru

Code     ENDS
         END       Start

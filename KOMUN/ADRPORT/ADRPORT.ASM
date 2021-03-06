Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen� �vodn�ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ p��prava p��kazov�ho ��dku

         mov       si,81h
         mov       bl,ds:[si-1]             ; d�lka textu
         mov       bh,0
         mov       byte ptr ds:[si+bx],0    ; ozna�en� konce textu

; ------ dek�dov�n� parametr�

Start1:  call      ParSpc                   ; vypu�t�n� mezer
         call      ParChr                   ; na�ten� prvn�ho znaku
         jc        Start8                   ; nen� nic dal��ho zad�no
         cmp       al,","
         je        Start1

; ------ parametr "COM"

         mov       bx,"OM"
         xor       di,di
         cmp       al,"C"                   ; COM
         je        Start2                   ; je COM

; ------ parametr "LPT"

         mov       bx,"PT"
         mov       di,2*4
         cmp       al,"L"
         je        Start2                   ; je LPT

; ------ zobrazen� n�pov�dy

Chyba:   mov       dx,offset HelpTxt        ; text n�pov�dy
         mov       ah,9
         int       21h                      ; zobrazen� textu n�pov�dy
         int       20h

; ------ druh� znak

Start2:  call      ParChr
         cmp       al,bh
         jne       Chyba

; ------ t�et� znak

         call      ParChr
         cmp       al,bl
         jne       Chyba

; ------ ��slo portu

         call      ParChr
         cmp       al,"1"
         jb        Chyba
         cmp       al,"4"
         ja        Chyba
         dec       ax
         and       ax,3
         shl       ax,1
         add       di,ax

; ------ odd�lova�

Start3:  call      ParSpc
         call      ParChr
         jc        Start32
         cmp       al,":"
         je        Start3
         cmp       al,"="
         je        Start3
         cmp       al,"$"
         je        Start3
         dec       si

; ------ na�ten� ��sla HEX

Start32: call      ParHex
         push      ds
         mov       ax,40h
         mov       ds,ax
         mov       ds:[di],dx
         pop       ds

; ------ vypu�t�n� dal��ch znak�

Start4:  call      ParSpc
         jc        Start8
         cmp       al,"H"
         je        Start5
         cmp       al,"$"
         je        Start5
         cmp       al,"-"
         jne       Start1
Start5:  call      ParChr
         jmp       short Start4

; ------ dek�dov�n� stavu port�

Start8:  push      ds
         mov       ax,40h
         mov       ds,ax
         xor       si,si
         mov       di,offset PortTxt1+9
         mov       cx,8
Start82: cld
         lodsw
         or        ax,ax
         jz        Start83                  ; port nedefinov�n
         push      di
         call      DekWord
         mov       al,"h"
         stosb
         pop       di
Start83: add       di,14
         cmp       cl,5
         jne       Start84
         add       di,4
Start84: loop      Start82
         pop       ds

; ------ zobrazen� stavu port�

         mov       dx,offset PortTxt
         mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        dek�dov�n� slova AX do bufferu ES:DI
; -----------------------------------------------------------------------------

DekWord  PROC      NEAR

         xchg      ah,al
         call      DekByte
         xchg      ah,al

DekByte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DekHex
         pop       ax

DekHex:  push      ax
         and       al,0fh
         cmp       al,10
         jb        DekHex1
         add       al,7
DekHex1: add       al,"0"
         cld
         stosb
         pop       ax
         ret

DekWord  ENDP

; -----------------------------------------------------------------------------
;        na�ten� ��sla HEX -> DX
; -----------------------------------------------------------------------------

ParHex   PROC      NEAR

         xor       dx,dx

ParHex1: call      ParChr
         jc        ParHex5
         cmp       al,"0"
         jb        ParHex4
         cmp       al,"9"
         jbe       ParHex3
         cmp       al,"A"
         jb        ParHex4
         cmp       al,"F"
         ja        ParHex4
         sub       al,7
ParHex3: sub       al,"0"
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         or        dl,al
         jmp       short ParHex1

ParHex4: dec       si
ParHex5: ret

ParHex   ENDP

; -----------------------------------------------------------------------------
;        na�ten� znaku s vypu�t�n�m mezer
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr
         jc        ParSpc2
         je        ParSpc
         cmp       al,"/"
         je        ParSpc
         cmp       al,"-"
         je        ParSpc
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p��kazov�ho ��dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
         lodsb

         cmp       al,9
         jne       ParChr2
         mov       al," "

ParChr2: cmp       al,"a"
         jb        ParChr3
         cmp       al,"z"
         ja        ParChr3
         sub       al,32

ParChr3: cmp       al," "
         jae       ParChr4
         dec       si

ParChr4: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'ADRPORT V1.0 - nastaveni adres COM a LPT; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte: COMn=xxxx, LPTn=xxxx (n=1 az 4, xxxx=adresa HEX, 0=neni)',13,10,'$'

PortTxt  db        ' �������������������������������������������������������ͻ',13,10
PortTxt1 db        ' � COM1:   -   � COM2:   -   � COM3:   -   � COM4:   -   �',13,10
         db        ' � LPT1:   -   � LPT2:   -   � LPT3:   -   � LPT4:   -   �',13,10
         db        ' �������������������������������������������������������ͼ',13,10
         db        '$'

Code     ENDS
         END       Start

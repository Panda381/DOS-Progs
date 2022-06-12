Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       ah,9
         mov       dx,offset UvTxt
         int       21h

; ------ dek¢dov n¡ parametru

         mov       si,81h
         mov       ch,0
         mov       cl,ds:[si-1]             ; d‚lka parametr–
Start1:  jcxz      Start5
         cld
         lodsb
         dec       cx
         cmp       al," "
         jbe       Start1
         cmp       al,"/"
         je        Start1

         cmp       al,"a"
         jb        Start2
         cmp       al,"z"
         ja        Start2
         sub       al,32

; ------ parametr "L"

Start2:  xor       bx,bx
         cmp       al,"L"
         je        Start3

; ------ parametr "H"

         cmp       al,"H"
         mov       al,-1
         mov       dx,offset HelpTxt
         jne       Start8                   ; chyba zad n¡ parametr–
         inc       bx

; ------ nastaven¡ strategie zav dˆn¡

Start3:  mov       ax,5803h
         int       21h
         jmp       short Start1

; ------ stav strategie

Start5:  mov       ax,5802h
         int       21h

         cmp       al,1
         mov       dx,offset HighTxt
         je        Start8
         mov       dx,offset LowTxt
         mov       al,0

; ------ zobrazen¡ textu stavu

Start8:  push      ax
         mov       ah,9
         int       21h

         mov       ax,cs                    ; segment programu SETLH
         mov       di,offset AdrTxt0
         call      HexWord                  ; dek¢dov n¡ adresy
         mov       dx,offset AdrTxt
         mov       ah,9
         int       21h

         pop       ax
         mov       ah,4ch
         int       21h


; -----------------------------------------------------------------------------
;        dek¢dov n¡ slova HEX
; -----------------------------------------------------------------------------

HexWord  PROC      NEAR

         push      ax
         mov       al,ah
         call      HexByte
         pop       ax

HexByte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      HexChr
         pop       ax

HexChr:  push      ax
         and       al,0fh
         add       al,90h
         daa
         adc       al,40h
         daa
         cld
         stosb
         pop       ax
         ret

HexWord  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

AdrTxt   db        'Program SETLH byl zaveden od segmentu '
AdrTxt0  db        '0000h.',13,10,'$'
UvTxt    db        'SETLH V1.0 - priznak zavadeni programu LH; (c) Miroslav Nemecek',13,10,'$'
HighTxt  db        'Programy se nyni zavadeji prednostne do HORNI casti pameti.',13,10,'$'
LowTxt   db        'Programy se nyni zavadeji prednostne do DOLNI casti pameti.',13,10,'$'
HelpTxt  db        'Zadejte: L ... zavadeni do DOLNI casti pameti',13,10
         db        '         H ... zavadeni do HORNI casti pameti',13,10
         db        '$'

Code     ENDS
         END       Start

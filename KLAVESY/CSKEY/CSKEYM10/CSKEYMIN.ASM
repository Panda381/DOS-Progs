
; *****************************************************************************
;
;                         Ovlada� �esk� kl�vesnice
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h

start:   jmp       init                     ; instalace programu

old09    dd        0                        ; p�vodn� obsluha INT 09h

switch   db        00000000b                ; p��znaky kl�vesnice
                                            ; bit 0 = byl prefix

int09:                                      ; program obsluhy kl�vesnice

         push      ax
         push      bx                       ; �schova registru BX
         push      cx
         push      si
         push      ds                       ; �schova registru DS
         mov       bx,40h                   ; segment dat BIOS
         mov       ds,bx                    ; DS <- segment dat BIOS 0040h
         mov       bx,word ptr ds:[1ch]     ; ukl�dac� adresa znak�
         pushf                              ; simulace vol�n� INT
         call      dword ptr cs:[old09]     ; p�vodn� obsluha kl�vesnice
         cmp       bx,word ptr ds:[1ch]     ; byl p�ijat znak ?
         je        konec                    ; nebyl p�ijat znak z kl�vesnice
         mov       ax,ds:[bx]               ; p�ijat� kl�vesa

                                          ;* obsluha zadani prefixu
         test      byte ptr cs:[switch],1   ; byl ji� n�kter� prefix ?
         jnz       int092                   ; byl zadan prefix
         cmp       al,"`"                   ; je prefix ` (��rka vlevo) ?
         je        int091                   ; je prefix `
         cmp       al,"'"                   ; je prefix ' (��rka vpravo) ?
         jne       konec                    ; nen� ani prefix ' - znak se necha
int091:  or        byte ptr cs:[switch],1   ; nastaven� prefixu ` nebo '
         mov       word ptr ds:[1ch],bx     ; zru�en� kl�vesy z bufferu
         jmp       short konec

                                          ;* zru�en� prefixu kl�vesou <Delete>
int092:  cmp       ah,0eh                   ; je kl�vesa <BS> ?
         je        int093                   ; je kl�vesa <BS>
         cmp       ah,53h                   ; je kl�vesa <Delete> ?
         jne       int094                   ; nebyla kl�vesa <Delete>
int093:  mov       ds:[1ch],bx              ; zru�en� kl�vesy
         jmp       short konec1             ; zruseni priznaku prefixu

                                          ;* prekodovani klavesy
int094:  mov       si,offset dektab-2       ; dek�dovac� tabulka
         mov       cx,offset(dektab0-dektab)/2 ; d�lka tabulky
int095:  add       si,2                     ; nastaven� na dal�� znak v tabulce
         cmp       al,cs:[si]               ; je to hledan� znak ?
         loopne    int095                   ; nen� to hledan� znak - dal�� pokus
         jne       konec1                   ; znak nenalezen
                                          ;* p�ek�dov�van� znak nalezen
         mov       al,cs:[si+1]             ; nov� k�d znaku
         mov       [bx],ax                  ; n�hrada nov�m znakem

konec1:  and       byte ptr cs:[switch],not 1; zru�en� p��znaku prefixu

konec:   pop       ds
         pop       si
         pop       cx
         pop       bx
         pop       ax
         iret


dektab   label     byte                   ;* dek�dovac� tabulka - Kamenick�ch

         db        "q�"                     ; "�"
         db        "Q�"                     ; "�"
         db        "w�"                     ; "�"
         db        "W�"                     ; "�"
         db        "e�"                     ; "�"
         db        "E�"                     ; "�"
         db        "r�"                     ; "�"
         db        "R�"                     ; "�"
         db        "t�"                     ; "�"
         db        "T�"                     ; "�"
         db        "y�"                     ; "�"
         db        "Y�"                     ; "�"
         db        "u�"                     ; "�"
         db        "U�"                     ; "�"
         db        "i�"                     ; "�"
         db        "I�"                     ; "�"
         db        "o�"                     ; "�"
         db        "O�"                     ; "�"
         db        "p�"                     ; "�"
         db        "P�"                     ; "�"
         db        "a�"                     ; "�"
         db        "A�"                     ; "�"
         db        "s�"                     ; "�"
         db        "S�"                     ; "�"
         db        "d�"                     ; "�"
         db        "D�"                     ; "�"
         db        "f�"                     ; "�"
         db        "F�"                     ; "�"
         db        "h�"                     ; "�"
         db        "H�"                     ; "�"
         db        "j�"                     ; "�"
         db        "J�"                     ; "�"
         db        "k�"                     ; "�"
         db        "K�"                     ; "�"
         db        "l�"                     ; "�"
         db        "L�"                     ; "�"
         db        "z�"                     ; "�"
         db        "Z�"                     ; "�"
         db        "c�"                     ; "�"
         db        "C�"                     ; "�"
         db        "n�"                     ; "�"
         db        "N�"                     ; "�"
         db        "m�"                     ; "�"
         db        "M�"                     ; "�"
         db        ",�"                     ; "�"
         db        ".�"                     ; "�"
         db        "\�"                     ; "�"

dektab0  label     byte

; *****************************************************************************
;
;                        Instalace programu
;
; *****************************************************************************
init:                                     ;* instalace programu

         mov       dx,offset uvtxt          ; hl��en� o instalaci programu
         mov       ah,9                     ; funkce tisku textu
         int       21h                      ; tisk �vodn�ho textu

                                          ;* nalezen� parametru
         cld
         xor       cx,cx
         mov       cl,ds:[80h]
         mov       si,81h
         jcxz      error
init1:   lodsb
         and       al,not 20h               ; prevod na velke pismeno
         cmp       al,"K"
         je        init5                    ; je kod Kamenickych
         cmp       al,"L"
         je        init4                    ; je kod Latin 2
         loop      init1                    ; dalsi znak

                                          ;* chyba zadani parametru
error:   mov       dx,offset errtxt
         mov       ah,9
         int       21h                      ; zobrazeni chyboveho textu
         int       20h                      ; konec programu

init4:   mov       si,offset dektabl        ; tabulka Latin 2
         mov       di,offset dektab         ; tabulka klavesnice
         mov       cx,offset(dektab0-dektab); delka tabulky
         rep       movsb                    ; prenos tabulky

init5:                                    ;* instalace programu
         mov       ax,3509h                 ; p�e�ten� vektoru p�eru�en� 09h
         int       21h
         mov       word ptr [old09],bx      ; ulo�en� p�vodn�ho vekt. p�eru�en�
         mov       word ptr [old09+2],es    ; segment nad�azen� instalace
         mov       dx,offset int09          ; adresa vlastn� obsluhy INT 09h
         mov       ax,2509h
         int       21h                      ; nastaven� nov� adresy INT 09H
         mov       dx,offset init           ; konec rezidentn� ��sti
         int       27h                      ; instalace do pam�ti


dektabl  label     byte                   ;* dek�dovac� tabulka - Latin 2

         db        "q�"                     ; "�"
         db        "Q�"                     ; "�"
         db        "w�"                     ; "�"
         db        "W�"                     ; "�"
         db        "e�"                     ; "�"
         db        "E�"                     ; "�"
         db        "r�"                     ; "�"
         db        "R�"                     ; "�"
         db        "t�"                     ; "�"
         db        "T�"                     ; "�"
         db        "y�"                     ; "�"
         db        "Y�"                     ; "�"
         db        "u�"                     ; "�"
         db        "U�"                     ; "�"
         db        "i�"                     ; "�"
         db        "I�"                     ; "�"
         db        "o�"                     ; "�"
         db        "O�"                     ; "�"
         db        "p�"                     ; "�"
         db        "P�"                     ; "�"
         db        "a�"                     ; "�"
         db        "A�"                     ; "�"
         db        "s�"                     ; "�"
         db        "S�"                     ; "�"
         db        "d�"                     ; "�"
         db        "D�"                     ; "�"
         db        "f�"                     ; "�"
         db        "F�"                     ; "�"
         db        "h�"                     ; "�"
         db        "H�"                     ; "�"
         db        "j�"                     ; "�"
         db        "J�"                     ; "�"
         db        "k�"                     ; "�"
         db        "K�"                     ; "�"
         db        "l�"                     ; "�"
         db        "L�"                     ; "�"
         db        "z�"                     ; "�"
         db        "Z�"                     ; "�"
         db        "c�"                     ; "�"
         db        "C�"                     ; "�"
         db        "n�"                     ; "�"
         db        "N�"                     ; "�"
         db        "m�"                     ; "�"
         db        "M�"                     ; "�"
         db        ",�"                     ; "�"
         db        ".�"                     ; "�"
         db        "\�"                     ; "�"

uvtxt    db        'CS klavesnice Mini;  (c) Miroslav Nemecek',13,10,'$'

errtxt   db        'Zadejte: K - kod Kamenickych, L - Latin 2',13,10,'$'

code     ENDS

         END       start                    ; startovac� adresa

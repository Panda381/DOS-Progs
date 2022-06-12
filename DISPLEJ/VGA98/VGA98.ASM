
KORIG    EQU       5ch-103h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   jmp       Init

RezBeg   label     byte

Old10    dd        0                        ; p–vodn¡ adresa

; -----------------------------------------------------------------------------
;        obsluha INT 10h
; -----------------------------------------------------------------------------

Int10:   pushf
         cmp       ah,0
         je        Int101
         cmp       ah,11h
         je        Int101
Int100:  popf
         jmp       dword ptr cs:[Old10+KORIG]

; ------ vyvol n¡ p–vodn¡ funkce

Int101:  popf
         pushf
         call      dword ptr cs:[Old10+KORIG]

; ------ £schova registr–

         cli
         push      ax
         push      bx
         push      dx

; ------ p©¡prava registru hodin

         mov       dx,3cch
         in        al,dx
         xor       al,4
         test      al,8+4
         jnz       Int109
         mov       bl,al

; ------ p©¡prava registru po‡tu bod–

         mov       dl,0c4h
         mov       al,1
         out       dx,al
         jmp       short $+2
         inc       dx
         in        al,dx
         test      al,21h
         jnz       Int109
         xor       al,1
         mov       bh,al

; ------ kontrola registru posunu PANNING

         call      Pan
         out       dx,al
         jmp       short $+2
         inc       dx
         in        al,dx
         cmp       al,8
         jne       Int108

; ------ nastaven¡ registru posunu PANNING

         dec       dx
         mov       al,0
         out       dx,al

; ------ nastaven¡ registru po‡tu bod–

         mov       al,bh
         mov       dl,0c5h
         out       dx,al

; ------ nastaven¡ registru hodin

         mov       al,bl
         mov       dl,0c2h
         out       dx,al

; ------ zapnut¡ displeje

Int108:  call      Pan
         mov       al,20h
         out       dx,al

; ------ n vrat registr–

Int109:  pop       dx
         pop       bx
         pop       ax
         iret

Pan:     mov       dl,0dah
         in        al,dx
         mov       dl,0bah
         in        al,dx
         mov       dl,0c0h
         mov       al,13h
         ret

RezEnd   label     byte

; -----------------------------------------------------------------------------
;        instalace
; -----------------------------------------------------------------------------

; ------ posun dol–

Init:    mov       si,offset RezBeg
         mov       di,offset RezBeg+KORIG
         mov       cx,offset(RezEnd-RezBeg)
         cld
         rep       movsb

; ------ £vodn¡ text

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ £schova INT 10h

         mov       ax,3510h
         int       21h
         mov       word ptr ds:[Old10+KORIG],bx
         mov       word ptr ds:[Old10+KORIG+2],es

; ------ instalace INT 10h

         mov       ax,2510h
         mov       dx,offset Int10 + KORIG
         int       21h

; ------ uvolnˆn¡ segmentu prost©ed¡

         mov       es,ds:[2ch]
         mov       ah,49h
         int       21h

; ------ zmˆna font–

         mov       bh,0
         mov       ax,1130h
         int       10h

; ------ instalace do pamˆti

         mov       dx,offset RezEnd+KORIG
         int       27h

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'VGA98 V1.0 - 9 bodu VGA na 8 bodu; (c) Miroslav Nemecek',13,10
         db        ' Program byl nainstalovan do pameti.',13,10,'$'

Code     ENDS
         END       Start

COMMENT %

        %

;------------------------------------------------------------------------------
;                             Segment z�sobn�ku
;------------------------------------------------------------------------------

stack    SEGMENT   stack

         DW        256 DUP(?)               ; z�sobn�k

stack    ENDS

;------------------------------------------------------------------------------
;                             Programov� segment
;------------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:data,ss:stack

start:                                      ; hlavn� t�lo programu
         mov       ax,SEG data              ; segment dat
         mov       ds,ax                    ; nastaven� datov�ho segmentu
                                          ;* inicializace portu
         mov       dx,302h                  ; ��dic� registr
         lea       si,[inidat]              ; inicializa�n� data
         mov       cx,offset(inidend-inidat) ; po�et bajt� inic. dat
bdt1:    lodsb
         out       dx,al                    ; vysl�n� bajtu
         loop      bdt1                     ; dal�� bajt
         lea       di,[buffer]              ; adresa bufferu
bdt2:
         call      prijem
         jc        konec                    ; p�eru�en�

         mov       ds:[di],al               ; ulo�en� p�ijat�ho bajtu
         inc       di

         jmp       short bdt2



konec:   xor       ax,ax
         int       16h


         mov       ah,4ch                   ; ukon�en� programu
         int       21h



prijem:                                   ;* p��jem 1 znaku
                                            ; V�STUP: AL=znak
                                            ;         CY=p�eru�en�

         mov       cx,10                  ; TIME-OUT
prijem1: mov       ah,1
         int       16h
         stc
         jnz       prijem2                  ; je znak
         mov       dx,302h
         in        al,dx
         test      al,1
         jnz       prijem3

         loop      prijem1                  ; dal�� test

                                          ;* zobrazen� obsahu bufferu
         mov       cx,di                    ; adresa konce dat
         lea       di,[buffer]              ; adresa bufferu
         mov       si,di
         sub       cx,si                    ; po�et dat v bufferu
         jcxz      prijem

;         push      si
;         push      cx
prijem5: lodsb
;        and       al,7fh
;         push      ax
         call      outbyte
;         pop       ax
;         mov       al," "
;         call      outch
         mov       al," "
         call      outch
         loop      prijem5
;         mov       al," "
;         call      outch2
;         call      outch2
;         call      outch2
;         pop       cx
;         pop       si
;prijem6: lodsb
;         call      outch
;         loop      prijem6

         mov       al,13
         call      outch2
         mov       al,10
         call      outch2
         jmp       short prijem

prijem3: mov       dx,300h
         in        al,dx
;         OUT       DX,AL
prijem2: ret


outbyte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      outhx
         pop       ax

outhx:   and       al,0fh
         cmp       al,10
         jb        outhx2
         add       al,7
outhx2:  add       al,"0"

outch:                                    ;* zobrazen� znaku
         and       al,7fh
         cmp       al," "
         ja        outch2
;         cmp       al,7
;         je        outch1
;         cmp       al,8
;         je        outch1
;         cmp       al,13
;         je        outch1
;         cmp       al,10
;         jne       outch2
outch1:  mov       al," "
outch2:  push      ax
         push      cx
         push      si
         mov       ah,0eh
         mov       bx,7
         int       10h
         pop       si
         pop       cx
         pop       ax
         ret



code     ENDS

;------------------------------------------------------------------------------
;                             Datov� segment
;------------------------------------------------------------------------------

data     SEGMENT

inidat   label     byte                     ; inicializa�n� data
         db        18h
         db        4,00100000b
         db        5,01100000b
         db        3,11000001b
         db        6,11111111b
         db        7,01111110b
         db        1,0

inidend  label     byte

buffer   label     byte

data     ENDS
         END       start               ; startovac� adresa

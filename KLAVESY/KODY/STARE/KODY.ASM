COMMENT %

        %

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:code,ss:stack

start:                                      ; hlavn¡ tˆlo programu
         mov       ax,cs
         mov       ds,ax                    ; nastaven¡ datov‚ho segmentu
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h
         mov       ax,3509h
         int       21h
         mov       word ptr [old9],bx
         mov       word ptr [old9+2],es
         mov       ax,2509h
         mov       dx,offset int09
         int       21h
         mov       ax,3515h
         int       21h
         mov       word ptr [old15],bx
         mov       word ptr [old15+2],es
         mov       ax,2515h
         mov       dx,offset int15
         int       21h

cyklus:
         cmp       word ptr [citpok],0
         jz        cyklus3
         dec       word ptr [citpok]
         jnz       cyklus3
         mov       al,10
         int       29h
cyklus3: mov       bx,word ptr cs:[ctikod]  ; ukl dac¡ adresa
         cmp       bx,word ptr cs:[uklkod]
         jz        cyklus                   ; nen¡ ‘ dn˜ znak
         mov       word ptr [citpok],65000  ; ‡¡ta‡ pokus–
         add       bx,offset kod
         mov       al,cs:[bx]
         inc       byte ptr cs:[ctikod]
         push      ax
         and       al,7fh
         cmp       al,1
         pop       ax
         jnz       konec1
         dec       byte ptr [citesc]
         jz        konec
         jmp       short konec2
konec1:  mov       byte ptr [citesc],3
konec2:  call      bajt
         mov       al,32
         int       29h
         mov       bx,word ptr cs:[ctikod2] ; ukl dac¡ adresa
         cmp       bx,word ptr cs:[uklkod2]
         jz        cyklus2                  ; nen¡ ‘ dn˜ znak
         add       bx,offset kod2
         mov       al,cs:[bx]
         inc       byte ptr cs:[ctikod2]
         call      bajt
cyklus2: mov       al,13
         int       29h
         mov       al,10
         int       29h
         jmp       cyklus

citesc   db        3                        ; ‡¡ta‡ ESC
citpok   dw        65000                    ; ‡¡ta‡ pokus–

konec:
         mov       ax,2509h
         mov       dx,word ptr [old9]
         mov       ds,word ptr [old9+2]
         int       21h
         mov       ax,2515h
         mov       dx,word ptr cs:[old15]
         mov       ds,word ptr cs:[old15+2]
         int       21h
         mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

bajt:    push      ax                       ; znak k v˜stupu
         ror       al,1                     ; rotace AL o 4 bity vpravo
         ror       al,1
         ror       al,1
         ror       al,1
         call      hex                      ; tisk znaku HEX
         pop       ax                       ; n vrat znaku k tisku
hex:     and       al,0fh                   ; ni‘¨¡ tetr da znaku
         add       al,90h                   ; p©evod na znak HEX
         daa
         adc       al,40h
         daa
         int       29H
         ret

uklkod   db        0                        ; ukl dac¡ adresa do KOD
         db        0
ctikod   db        0                        ; ‡tec¡ adresa z KOD
         db        0
kod      db        256 dup(0)               ; k¢d kl vesy

old9     dd        0                        ; star  adresa INT 09

int09:
         push      ds
         push      ax
         in        al,[60h]
         push      bx
         mov       bx,word ptr cs:[uklkod]  ; ukl dac¡ adresa
         add       bx,offset kod
         mov       cs:[bx],al
         inc       byte ptr cs:[uklkod]
         pop       bx
         mov       ax,40h
         mov       ds,ax
         mov       ax,ds:[1ch]
         pushf
         call      dword ptr cs:[old9]
         mov       ds:[1ch],ax
         pop       ax
         pop       ds
         iret


uklkod2  db        0                        ; ukl dac¡ adresa do KOD2
         db        0
ctikod2  db        0                        ; ‡tec¡ adresa z KOD2
         db        0
kod2     db        256 dup(0)

old15:   dd        0                        ; star  adresa INT 15h

int15:
         pushf
         cmp       ah,4fh
         je        int150
         popf
         jmp       dword ptr cs:[old15]

int150:  popf
         push      bx
         mov       bx,word ptr cs:[uklkod2] ; ukl dac¡ adresa
         add       bx,offset kod2
         mov       cs:[bx],al
         inc       byte ptr cs:[uklkod2]
         pop       bx
         clc
int151   proc      far
         ret       2
int151   endp


uvtxt    db        'V˜pis k¢d– kl ves: port 60h, slu‘ba INT 15/4fh.',13,10
         db        'P©eru¨en¡ - dvakr t <Esc>.',13,10,'$'

code     ENDS

;------------------------------------------------------------------------------
;                             Segment z sobn¡ku
;------------------------------------------------------------------------------

stack    SEGMENT   stack

         DW        256 DUP(?)               ; z sobn¡k

stack    ENDS


         END       start               ; startovac¡ adresa

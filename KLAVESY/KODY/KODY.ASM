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

cyklus:  mov       bx,word ptr cs:[ctikod]  ; ukl dac¡ adresa
         cmp       bx,word ptr cs:[uklkod]
         jz        cyklus                   ; nen¡ ‘ dn˜ znak
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
konec2:  push      ax
         cmp       al,0e0h
         jz        konec3
         cmp       al,0e1h
         jz        konec3
         and       al,7fh
         cmp       al,[oldkey]
         mov       [oldkey],al
         jz        konec3
         mov       al,13
         int       29H         
         mov       al,10
         int       29H         
konec3:  mov       al,' '
         int       29h
konec4:  pop       ax
         call      bajt
         jmp       cyklus

citesc   db        3                        ; ‡¡ta‡ ESC

konec:
         mov       ax,2509h
         mov       dx,word ptr [old9]
         mov       ds,word ptr [old9+2]
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
hex:     push      ax
         and       al,0fh                   ; ni‘¨¡ tetr da znaku
         add       al,90h                   ; p©evod na znak HEX
         daa
         adc       al,40h
         daa
         int       29H
         pop       ax
         ret

uklkod   db        0                        ; ukl dac¡ adresa do KOD
         db        0
ctikod   db        0                        ; ‡tec¡ adresa z KOD
         db        0
kod      db        256 dup(0)               ; k¢d kl vesy

oldkey   db        0                        ; stara klavesa
old9     dd        0                        ; star  adresa INT 09

int09:
         push      ds
         push      ax
         in        al,[60h]
         cmp       al,0fah                  ; potvrzeni prijmu povelu se ignoruje
         jz        int092
         cmp       al,0aah                  ; inicializace klavesnice se ignoruje
         jz        int092
         push      bx
         mov       bx,word ptr cs:[uklkod]  ; ukl dac¡ adresa
         add       bx,offset kod
         mov       cs:[bx],al
         inc       byte ptr cs:[uklkod]
         pop       bx
int092:  mov       ax,40h
         mov       ds,ax
         mov       ax,ds:[1ch]
         pushf
         call      dword ptr cs:[old9]
         mov       ds:[1ch],ax
         pop       ax
         pop       ds
         iret

uvtxt    db        'Vypis kodu klaves z portu 60h. Preruseni - dvakrat <Esc>.',13,10,'$'

code     ENDS

;------------------------------------------------------------------------------
;                             Segment z sobn¡ku
;------------------------------------------------------------------------------

stack    SEGMENT   stack

         DW        256 DUP(?)               ; z sobn¡k

stack    ENDS


         END       start               ; startovac¡ adresa

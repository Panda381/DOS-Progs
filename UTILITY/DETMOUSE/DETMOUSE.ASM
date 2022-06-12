
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ test adresy INT 33h

Start:   mov       ax,3533h
         int       21h                      ; adresa INT 33h
         mov       ax,es                    ; AX <- segment adresy
         cmp       ax,60h
         jb        NeniMys                  ; nen¡ my¨
         cmp       ax,0ffe0h
         jae       NeniMys                  ; nen¡ my¨
         cmp       bx,0fff8h                ; kontrola offsetu adresy
         jae       NeniMys

; ------ test instalace my¨i

         xor       ax,ax                    ; AX <- 0 funkce testu my¨i
         push      ds
         int       33h                      ; je nainstalov na my¨ ?
         pop       ds
         mov       dx,offset JeMysTxt       ; hl ¨en¡
         inc       ax                       ; pokud je AX=-1, je my¨
         jz        JeMys                    ; je my¨ (nyn¡ je -> AX=0)
NeniMys: mov       dx,offset NeMysTxt       ; hl ¨en¡
         mov       al,1                     ; p©¡znak, ‘e nen¡ my¨

; ------ zobrazen¡ hl ¨en¡ DX

JeMys:   push      ax
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡
         pop       ax

; ------ konec programu (AL=n vratov˜ k¢d)

         mov       ah,4ch
         int       21h

JeMysTxt db        'Mys JE nainstalovana.',13,10,'$'
NeMysTxt db        'Mys NENI nainstalovana.',13,10,'$'

Code     ENDS
         END       Start

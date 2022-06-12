Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

POCATLIN EQU       144                      ; po‡ te‡n¡ linka panelu

Start:   mov       dx,offset Soubor
         mov       ax,3d00h
         int       21h
         xchg      ax,bx
         jc        chyba

         mov       dx,offset Buffer
         mov       cx,offset(Buffer0-Buffer)
         mov       ah,3fh
         int       21h
         jc        chyba

         mov       ah,3eh
         int       21h

         mov       dx,offset panpaltx
         mov       ah,9
         int       21h

         mov       si,offset buffer + 16

start13: mov       cx,200-POCATLIN

start2:  mov       bp,20

start22: mov       di,16

         mov       dx,offset textdb
         mov       ah,9
         int       21h

start3:  mov       al,"0"
         call      dispchr
         cld
         lodsb
         call      hexbyte
         mov       al,"h"
         call      Dispchr
         dec       di
         jz        start4
         mov       al,","
         call      dispchr
         jmp       short start3

start4:  cmp       si,offset buffer + 16 + 3*256
         jne       start42

         mov       si,offset buffer + 16 + 3*256 + POCATLIN*320
         mov       dx,offset paneltxt
         mov       ah,9
         int       21h
         jmp       short start13

start42: dec       bp
         jnz       start22

         mov       dx,offset kontxt
         mov       ah,9
         int       21h

start5:  loop      start2

         mov       dx,offset kontxt
         mov       ah,9
         int       21h

chyba:   int       20h


hexbyte: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      disphex
         pop       ax

disphex: push      ax
         and       al,0fh
         cmp       al,9
         jbe       disphex1
         add       al,7
disphex1:add       al,"0"
         call      dispchr
         pop       ax
         ret

dispchr: push      dx
         push      ax

         mov       ah,2
         mov       dl,al
         int       21h

         pop       ax
         pop       dx
         ret

Soubor   db        'GDEMO000.SCR',0

panpaltx db        13,10,'PanelPal label     byte',13,10,'$'
paneltxt db        13,10,13,10,13,10,'PanelObr label     byte',13,10,'$'
textdb   db        13,10,'db $'

kontxt   db        13,10,'$'

Buffer   db        16 + 3*255 + 320*200 + 10 dup(0)
Buffer0  label     byte

Code     ENDS
         END       Start

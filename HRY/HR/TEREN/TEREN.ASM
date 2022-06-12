
code     segment
         assume    cs:code,ds:code
         org       100h

start:

         mov       dx,offset soubor2
         xor       cx,cx
         mov       ah,3ch
         int       21h
         jc        konec
         mov       di,ax

start1:  mov       dx,offset soubor1
         mov       ax,3d00h
         int       21h
         jc        konec1
         mov       bx,ax

         mov       dx,offset buffer
         mov       cx,16
         mov       ah,3fh
         int       21h
         mov       cx,2*16*4
         mov       ah,3fh
         int       21h

         mov       ah,3eh
         int       21h

         mov       bx,di
         mov       ah,40h
         int       21h

         mov       si,offset soubor10 - 1
start2:  inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"+1
         jne       start1
         mov       byte ptr ds:[si],"0"
         dec       si
         jmp       short start2

konec1:  mov       bx,di
         mov       ah,3eh
         int       21h

konec:
         int       20h


soubor1  db        'TEREN000'
Soubor10 db        '.SCR',0
soubor2  db        'TEREN.DAT',0

buffer   label     byte

code     ends
         end       start

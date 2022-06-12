code     segment
         assume    cs:code,ds:code
         org       100h

start:   mov       si,81h
         mov       bh,0
         mov       bl,ds:[si-1]
         mov       byte ptr ds:[si+bx],0

         mov       dx,82h
         mov       ax,3d00h
         int       21h
         jc        konec
         mov       ds:[soub1],ax

         mov       word ptr ds:[si+bx-3],"XE"
         mov       byte ptr ds:[si+bx-1],"$"

         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        konec
         mov       ds:[soub2],ax

start2:  mov       dx,offset buffer
         mov       ah,3fh
         mov       bx,ds:[soub1]
         mov       cx,4000h
         int       21h
         jc        konec
         mov       cx,ax
         jcxz      konec

         mov       ah,40h
         mov       bx,ds:[soub2]
         int       21h
         jnc       start2

konec:   int       20h

soub1    dw        0
soub2    dw        0

buffer   label     byte

code     ends
         end       start

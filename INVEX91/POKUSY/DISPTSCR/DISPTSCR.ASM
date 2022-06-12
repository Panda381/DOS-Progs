
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       ax,10h
         int       10h

         mov       dx,offset soubor
         mov       ax,3d00h
         int       21h
         jnc       start0

         jmp       konec

start0:
         mov       bx,ax
         mov       cx,9
         mov       dx,offset buffer
         mov       ah,3fh
         int       21h

         mov       cx,2 * 80 * 25
         mov       ah,3fh
         int       21h

         mov       si,offset buffer
         mov       cx,25                    ; po‡et © dk–
         xor       dx,dx

start1:
         push      cx
         push      dx

         mov       dl,0
         mov       cl,80
start2:
         push      si
         push      dx
         push      cx
         mov       ah,2
         xor       bx,bx
         int       10h                      ; nastaven¡ pozice kurzoru
         pop       cx
         pop       dx
         pop       si

         push      dx
         push      cx
         push      si
         mov       ah,9
         mov       al,219
         mov       bl,ds:[si+80*25]
         shr       bl,1
         shr       bl,1
         shr       bl,1
         shr       bl,1
         xor       bh,bh
         mov       cx,1
         int       10h
         pop       si
         pop       cx
         pop       dx

         push      dx
         push      cx
         push      si
         mov       ah,9
         mov       al,ds:[si]
         mov       bl,ds:[si+80*25]
         mov       bh,bl
         shr       bh,1
         shr       bh,1
         shr       bh,1
         shr       bh,1
         and       bl,0fh
         xor       bl,bh
         or        bl,80h
         xor       bh,bh
         mov       cx,1
         int       10h
         pop       si
         pop       cx
         pop       dx

         inc       si
         inc       dl
         loop      start2

         pop       dx
         pop       cx
         inc       dh

         loop      start1

         xor       ax,ax
         int       16h

konec:   mov       ax,3
         int       10h

         int       20h


soubor   db        'DISPTSCR.SCR',0

buffer   label     byte

code     ends
         end       start

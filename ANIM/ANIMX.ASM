
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       dx,offset soub
         mov       ax,3d02h
         int       21h                      ; otev©en¡
         jc        konec
         mov       bx,ax

         xor       cx,cx
         xor       dx,dx
         mov       ax,4202h
         int       21h

         mov       cx,512
         div       cx                       ; po‡et str nek
         or        dx,dx
         jz        STart3
         inc       ax
Start3:  mov       ds:[size],dx
         mov       ds:[size+2],ax

         mov       dx,2
         mov       cx,0
         mov       ax,4200h
         int       21h

         mov       dx,offset size
         mov       ah,40h
         mov       cx,4
         int       21h                      ; z pis nov‚ velikosti

         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru

konec:   int       20h

soub     db        'ANIM.EXE',0

size     dw        0
         dw        0

code     ends
         end       start

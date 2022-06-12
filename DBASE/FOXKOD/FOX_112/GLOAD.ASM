
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       dx,offset soub1
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       bx,ax

         mov       dx,offset buffer
         mov       ah,3fh
         mov       cx,400h
         int       21h
         jc        chyba

         mov       dx,word ptr ds:[buffer+200h]
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         add       dx,200h
         xor       cx,cx
         mov       ax,4200h
         int       21h
         jc        chyba

         mov       dx,offset buffer
         mov       cx,0c000h
         mov       ah,3fh
         int       21h
         jc        chyba

         push      ax
         mov       ah,3ch
         mov       dx,offset soub2
         xor       cx,cx
         int       21h
         pop       cx
         jc        chyba
         mov       bx,ax

         mov       ah,40h
         mov       dx,offset buffer
         int       21h
         jnc       konec

chyba:   mov       dx,offset txtchyb
         mov       ah,9
         int       21h

konec:   int       20h

txtchyb  db        7,'Chyba !',13,10,'$'

soub1    db        'FOXKOD.EXE',0
soub2    db        'LOAD.EXE',0

buffer   label     byte

code     ends
         end       start

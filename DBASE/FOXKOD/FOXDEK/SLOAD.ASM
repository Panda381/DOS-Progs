
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       dx,offset soub1
         mov       ax,3d02h
         int       21h
         jc        chyba1
         mov       bx,ax
         mov       ds:[soub1i],ax

         mov       dx,offset buffer
         mov       ah,3fh
         mov       cx,400h
         int       21h
         jc        chyba1

         mov       dx,word ptr ds:[buffer+200h]
         shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         add       dx,200h
         xor       cx,cx
         mov       ax,4200h
         int       21h
         jc        chyba1

         mov       ax,3d00h
         mov       dx,offset soub2
         int       21h
         jc        chyba1
         mov       bx,ax

         mov       ah,3fh
         mov       dx,offset buffer
         mov       cx,0c000h
         int       21h
         jc        chyba1
         mov       cx,ax

         mov       bx,ds:[soub1i]
         mov       ah,40h
         int       21h
chyba1:  jc        chyba

         xor       cx,cx
         mov       ah,40h
         int       21h
         jc        chyba

         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         int       21h
         jc        chyba

         mov       ds:[exes1],ax
         and       word ptr ds:[exes1],511
         add       ax,511
         adc       dx,0
         mov       al,ah
         mov       ah,dl
         shr       ax,1
         mov       ds:[exes2],ax

         mov       dx,2
         xor       cx,cx
         mov       ax,4200h
         int       21h
         jc        chyba

         mov       dx,offset exes1
         mov       cx,4
         mov       ah,40h
         int       21h
         jnc       konec

chyba:   mov       dx,offset txtchyb
         mov       ah,9
         int       21h

konec:   int       20h

exes1    dw        0                        ; str nky
exes2    dw        0

txtchyb  db        7,'Chyba !',13,10,'$'

soub1    db        'FOXDEK.EXE',0
soub1i   dw        0

soub2    db        'LOAD.EXE',0

buffer   label     byte

code     ends
         end       start

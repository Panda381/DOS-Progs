


code     segment
         assume    cs:code,ds:code
         org       100h

sizbuf   equ       2000h
buffer1  equ       offset kon
buffer2  equ       buffer1+sizbuf
buffer3  equ       buffer2+sizbuf

start:   mov       dx,offset soub1
         mov       ax,3d00h
         int       21h
         mov       dx,offset errs1
         jc        chyba
         mov       ds:[ident1],ax

         mov       dx,offset soub2
         mov       ax,3d00h
         int       21h
         mov       dx,offset errs2
         jc        chyba
         mov       ds:[ident2],ax

         mov       dx,offset soub3
         xor       cx,cx
         mov       ah,3ch
         int       21h
         mov       dx,offset errs3
         jc        chyba
         mov       ds:[ident3],ax

start1:  mov       dx,buffer1
         mov       ah,3fh
         mov       cx,sizbuf
         mov       bx,ds:[ident1]
         int       21h
         jc        konec

         mov       dx,buffer2
         mov       ah,3fh
         mov       cx,sizbuf
         mov       bx,ds:[ident2]
         int       21h
         jc        konec

         push      ax
         xor       si,si
         mov       cx,sizbuf
start2:  mov       ax,ds:[si+buffer1]
         and       ax,ds:[si+buffer2]
         mov       ds:[si+buffer3],ax
         add       si,2
         loop      start2
         pop       cx
         jcxz      konec

         mov       dx,buffer3
         mov       ah,40h
         mov       bx,ds:[ident3]
         int       21h
         jc        konec
         jmp       start1


chyba:   mov       ah,9
         int       21h
konec:   int       20h


ident1   dw        0
ident2   dw        0
ident3   dw        0

soub1    db        'DUHA.SCR',0
soub2    db        'MASKA.SCR',0
soub3    db        'POUTAC.SCR',0

errs1    db        'Nenalezen soubor DUHA.SCR !',13,10,'$'
errs2    db        'Nenalezen soubor MASKA.SCR !',13,10,'$'
errs3    db        'Chyba zapisu do souboru POUTAC.SCR !',13,10,'$'

kon      label     byte

code     ends
         end       start

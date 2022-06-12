code     segment
         assume    cs:code,ds:code
         org       100h

start:   mov       dx,offset uvtxt
         mov       ah,9
         int       21h

         cli

         mov       bh,10

start0:  mov       cx,10000
         clc

start1:  REPT      1000
         jc        $+2
         ENDM

start11: pushf
         dec       cx
         jz        Start2
         popf
         jmp       start1

start2:  dec       bh
         jz        start3
         popf
         jmp       start0

start3:
         popf
         sti
         mov       dx,offset uvtxt3
         mov       ah,9
         int       21h
         int       20h

UvTxt    db        'Test rychlosti instrukce JC; delka instrukce '
UvTxt2   db        offset(start11-start1)/1000 + "0", ' B',13,10
         db        'celkova_doba_v_[s] / 100 = doba_v_[us]',13,10,
         db        'cekejte: START ... $'

uvtxt3   db        'STOP',13,10,'$'

code     ends
         end       start

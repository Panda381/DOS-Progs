
Code     SEGMENT
         ASSUME    cs:Code,ds:Code,ss:Zasob

Start:   push      cs
         pop       ds
         mov       dx,offset ErrTxt
         mov       ah,9
         int       21h
         mov       ax,4cffh
         int       21h

ErrTxt   db        'Program vyzaduje ke svemu spusteni WINDOWS !',13,10,'$'

Code     ENDS

Zasob    SEGMENT 'STACK' stack
         dw        200h dup(?)
Zasob    ENDS
         END       Start

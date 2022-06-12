code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h
start2:  mov       ah,1
         int       21h
         sub       al,"1"
         jb        start2
         cmp       al,9
         jae       start2

         xor       bx,bx
         mov       bl,al
         add       bx,bx
         mov       bx,ds:[bx+tab]

         mov       al,36h
         out       [43h],al
         mov       al,bl
         out       [40h],al
         mov       al,bh
         out       [40h],al
         int       20h

uvtxt    db        'Nastaveni systemovych hodin',13,10
         db        '---------------------------',13,10
         db        'Zadejte koeficient zrychleni:',13,10
         db        ' 1 ...   1x',13,10
         db        ' 2 ...   2x',13,10
         db        ' 3 ...   5x',13,10
         db        ' 4 ...  10x',13,10
         db        ' 5 ...  20x',13,10
         db        ' 6 ...  50x',13,10
         db        ' 7 ... 100x',13,10
         db        ' 8 ... 200x',13,10
         db        ' 9 ... 500x',13,10
         db        '$'

tab      label     word
         dw        0                        ; 1
         dw        32768                    ; 2
         dw        13107                    ; 3
         dw        6554                     ; 4
         dw        3277                     ; 5
         dw        1311                     ; 6
         dw        655                      ; 7
         dw        328                      ; 8
         dw        131                      ; 9

code     ends
         end       start

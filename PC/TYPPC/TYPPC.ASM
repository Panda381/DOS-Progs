; ************************ zobrazen¡ typu po‡¡ta‡e ****************************
code     SEGMENT   page
         ASSUME    cs:code,ds:code
         org       100h
start:                                      ; hlavn¡ tˆlo programu
         lea       dx,[uvtxt]
         mov       ah,9
         int       21h
         mov       ax,0f000h
         mov       es,ax
         mov       al,es:[0fffeh]

         lea       dx,[txtkonv]
         cmp       al,0f9h
         je        tisk

         lea       dx,[txtat]
         cmp       al,0fch
         je        tisk

         lea       dx,[txtpcjr]
         cmp       al,0fdh
         je        tisk

         lea       dx,[txtxt]
         cmp       al,0fbh
         je        tisk

         lea       dx,[txtpcxt]
         cmp       al,0feh
         je        tisk

         lea       dx,[txtpc]

tisk:    mov       ah,9
         INT       21H

         lea       dx,[txtdat]
         mov       ah,9
         int       21h

         mov       si,0fff5h
         mov       cx,8
tisk2:   mov       dl,es:[si]
         inc       si
         mov       ah,2
         int       21h
         loop      tisk2

         lea       dx,[zavtxt]
         mov       ah,9
         int       21h
         int       20h

uvtxt    db        'Typ Vaseho pocitace: $'
txtpc    db        'PC$'
txtpcxt  db        'PC XT$'
txtxt    db        'XT$'
txtpcjr  db        'PCjr$'
txtat    db        'AT (XT-286)$'
txtkonv  db        'Konvertabilni PC$'

txtdat   db        ', verze BIOS: $'

zavtxt   db        13,10,'$'

code     ENDS
         END       start               ; startovac¡ adresa

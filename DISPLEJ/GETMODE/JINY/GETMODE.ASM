code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

start:                                      ; hlavn� t�lo programu
         lea       dx,[text]
         mov       ah,9
         int       21h

         mov       ah,0fh
         int       10h

zobraz2: mov       bl,100
         call      zobraz5
         mov       bl,10
         call      zobraz5
         add       al,"0"
         mov       dl,al
         mov       ah,2
         int       21h
         lea       dx,[text2]

navrat2: mov       ah,9
         int       21h
navrat:  mov       ah,0fh
         int       10h
         mov       ah,4ch                   ; ukon�en� programu
         int       21h

zobraz5: xor       ah,ah
zobraz6: inc       ah
         sub       al,bl
         jnc       zobraz6
         add       al,bl
         dec       ah
         jz        zobraz7
         push      ax
         mov       dl,ah
         add       dl,"0"
         mov       ah,2
         int       21h
         pop       ax
zobraz7: ret

text     db        'Aktivni videomod = $'
text2    db        13,10,'$'

code     ENDS
         END       start               ; startovac� adresa

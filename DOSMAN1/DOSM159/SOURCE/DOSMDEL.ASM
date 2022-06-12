
code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

start:                                      ; hlavn¡ tˆlo programu

         mov       ax,3d02h
         lea       dx,[soub]
         int       21h                      ; otev©en¡ souboru
         jc        konec
         mov       bx,ax                    ; identifik tor souboru
                                          ;* na‡ten¡ informac¡
         mov       ah,3fh
         lea       dx,[buffer]
         mov       cx,10
         int       21h
         jc        konec1
                                          ;* nastaven¡ ukazatele na konec
         mov       ax,4200h
         xor       cx,cx
         mov       dx,word ptr ds:[buffer+3] ; nov˜ konec
         sub       dx,100h                  ; ode‡ten¡ adresy za‡ tku programu
         int       21h
         jc        konec1
                                          ;* zkr cen¡ souboru
         mov       ah,40h
         xor       cx,cx
         int       21h
konec1:                                   ;* uzav©en¡ souboru
         mov       ah,3eh
         int       21h

konec:
         mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

soub     db        'DOSMAN.COM',0

buffer   db        10 dup(?)



code     ENDS

         END       start               ; startovac¡ adresa

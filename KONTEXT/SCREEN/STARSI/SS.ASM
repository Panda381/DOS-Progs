Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         org       100h

Start:

         mov       ax,1003h
         mov       bl,0                     ; p©¡znak - intezivn¡ podklad
         int       10h                      ; nastaven¡ atributu s jasem

         xor       ax,ax
         mov       es,ax
         mov       dx,es:[463h]             ; port CRT
         add       dl,4                     ; ©¡dic¡ port
         mov       al,9
         out       dx,al                    ; vypnut¡ blik n¡


         int       20h

Code     ENDS
         END       STart

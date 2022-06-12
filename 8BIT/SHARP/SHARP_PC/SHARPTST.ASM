code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         xor       ax,ax
         mov       es,ax
         mov       dx,es:[408h]

         inc       dx
         inc       dx
         mov       al,4
         out       dx,al
         dec       dx
cyk:
         in        al,dx
         test      al,8
         pushf
         in        al,[61h]
         and       al,not 2
         popf
         jz        cyk2
         or        al,2
cyk2:    out       [61h],al

         mov       ah,1
         int       16h
         jz        cyk

         int       20h

UvTxt    db        'Echo vstupu na reproduktor.',13,10,'$'

code     ends
         end       start

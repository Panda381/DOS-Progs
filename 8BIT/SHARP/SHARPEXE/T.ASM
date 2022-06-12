code     segment
         assume    cs:code,ds:code
         org       100h
start:

         mov       dx,37ah
         mov       al,4
         out       dx,al
cyk:
         mov       dx,379h
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

code     ends
         end       start

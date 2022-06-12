
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       ah,2ah
         int       21h                      ; aktu ln¡ den

         xchg      ax,cx                    ; AX <- rok
         sub       ax,1900
         cmp       al,100
         jc        Rok1900
         sub       al,100
Rok1900: call      DispNum

         mov       al,dh
         call      DispNum

         mov       al,dl
         call      DispNum

         int       20h

DispNum: aam
         add       ax,"00"
         xchg      al,ah
         call      DispCh
         mov       al,ah

DispCh:  push      ax
         push      dx
         mov       dl,al
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

Code     ENDS
         END       Start

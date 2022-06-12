
Code     segment
         assume    cs:code,ds:code
         org       100h

Start:
                                          ;* reset diskov‚ho syst‚mu
         mov       ah,0dh
         int       21h                      ; reset diskov‚ho syst‚mu DOS

         xor       ax,ax
         mov       ds,ax
         mov       word ptr ds:[472h],1234h
         jmp       dword ptr cs:[Adr]

Adr      dd        0f000fff0h

Code     ENDS
         END       Start

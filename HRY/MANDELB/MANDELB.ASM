
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       ax,5
         int       10h

         mov       word ptr ds:[PozY],0
         mov       di,190h

Mand1:   mov       word ptr ds:[PozX],0
         mov       si,0fda2h

Mand2:   mov       bx,si
         mov       cx,di
         mov       byte ptr ds:[Cit],18h

Mand3:   mov       ax,bx
         imul      ax
         mov       al,ah
         mov       ah,dl
         mov       bp,ax
         mov       ax,cx
         imul      cx
         mov       al,ah
         mov       ah,dl
         mov       es,ax
         add       ax,bp
         sub       ax,800h
         jnc       Mand5
         mov       ax,es
         sub       bp,ax
         add       bp,si
         xchg      bp,bx
         mov       ax,cx
         imul      bp
         mov       cl,ah
         mov       ch,dl
         test      dh,80h
         jz        Mand4
         cmp       al,1
         cmc
         adc       cx,0
Mand4:   add       cx,cx
         add       cx,di
         dec       byte ptr ds:[Cit]
         jnz       Mand3
Mand5:   mov       ah,0ch
         mov       al,ds:[Cit]
         and       al,3
         mov       cx,ds:[PozX]
         mov       dx,ds:[PozY]
         int       10h
         add       si,3
         inc       cx
         mov       ds:[PozX],cx
         cmp       cx,140h
         jnz       Mand2
         sub       di,4
         inc       dx
         mov       ds:[PozY],dx
         cmp       dx,0c8h
         jnz       Mand1
         xor       ax,ax
         int       16h
         mov       ax,2
         int       10h
         int       20h

PozX     dw        0                        ; pozice bodu X
PozY     dw        0                        ; pozice bodu Y
Cit      db        0

code     ends
         end       start

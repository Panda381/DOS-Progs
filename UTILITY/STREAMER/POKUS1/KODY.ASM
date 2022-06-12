
DELKAK   EQU       11
BITUK    EQU       4

code     segment
         assume    cs:Code,ds:Code
         org       100h

Start:

         mov       cl,byte ptr ds:[Delka]
         mov       ax,1
         shl       ax,cl
         mov       ds:[slov],ax

start2:  mov       ax,ds:[slovo]
         push      ax
         mov       cx,ds:[delka]
         xor       bx,bx
start21: shr       ax,1
         jnc       start22
         inc       bx
start22: loop      start21
         pop       ax
         cmp       bl,byte ptr ds:[bitu]
         jne       start3

         inc       word ptr ds:[kody]

         mov       cl,16
         sub       cl,byte ptr ds:[delka]
         shl       ax,cl
         mov       cx,ds:[delka]
start23: shl       ax,1
         push      ax
         mov       dl,"0"
         jnc       start24
         mov       dl,"1"
start24: mov       ah,2
         int       21h
         pop       ax
         loop      start23

         mov       dl,13
         mov       ah,2
         int       21h
         mov       dl,10
         mov       ah,2
         int       21h

start3:  inc       word ptr ds:[slovo]
         dec       word ptr ds:[slov]
         jnz       start2

         mov       ax,ds:[kody]
         call      dispnum

         int       20h

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

         xor       cx,cx

DispNum1:xor       dx,dx
         mov       bx,10
         div       bx
         push      dx
         inc       cx
         or        ax,ax
         jnz       DispNum1

DispNum2:pop       dx
         add       dl,"0"
         mov       ah,2
         int       21h
         loop      dispnum2
         ret

DispNum  ENDP

kody     dw        0

slovo    dw        0
slov     dw        0

Delka    dw        DELKAK                   ; d‚lka k¢du
bitu     dw        BITUK                    ; po‡et bit– "1"

Code     ENDS
         END       Start


Code            segment
                assume  cs:code,ds:Code
                org     100h

start:          mov     ax,3514h
                int     21h
                mov     word ptr ds:[old14],bx
                mov     word ptr ds:[old14+2],es

                mov     dx,offset int14
                mov     ax,2514h
                int     21h

                mov     dx,offset konec
                int     27h

old14           dd      0

int14           PROC    FAR

                cmp     ah,2
                jne     int142

                push    cx
                mov     cx,10
                mov     word ptr cs:[int141+1],ax

int141:         mov     ax,1234h

                push    cx
                pushf
                call    dword ptr cs:[old14]
                pop     cx

                test    ah,80h
                jz      int1411
                loop    int141

int1411:        pop     cx
                iret

int142:         jmp     dword ptr cs:[Old14]

int14           ENDP


konec:

Code            ENDS
                end     Start

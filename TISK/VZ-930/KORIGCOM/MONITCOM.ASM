
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

                cmp     ah,3
                jne     int140
                dec     byte ptr cs:[citac]
                jnz     int140

                mov     ax,61b0h
                retf    2

int140:         cmp     ah,1
                jne     int141

                push    ax
                push    dx

                mov     ah,0
                xor     dx,dx
                int     17h

                pop     dx
                pop     ax

int141:         cmp     ah,2
                jne     int142

                pushf
                call    dword ptr cs:[old14]

                pushf

                test    ah,80h
                jnz     int1413

                push    ax
                push    dx

                test    ah,80h
                jnz     int1412

                push    ax
                mov     ax,254
                xor     dx,dx
                int     17h
                pop     ax

                mov     ah,0
                xor     dx,dx
                int     17h

int1412:        pop     dx
                pop     ax
;                jmp     short int1414

int1413:        mov     al,1
                mov     ah,61h

int1414:        popf
                retf    2

int142:
                jmp     dword ptr cs:[Old14]

int14           ENDP

citac           db      0

konec:

Code            ENDS
                end     Start

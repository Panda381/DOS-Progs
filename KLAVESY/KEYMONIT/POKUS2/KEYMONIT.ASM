COMMENT %

 Monitorovac¡ program pro p©eru¨en¡ kl vesnice INT09

%
code    SEGMENT page
        ASSUME  cs:code,ds:code

        org     100h

start:
        jmp     init

adrkey  dd      0                               ; adresa driveru kl vesnice

key:                                            ; program obsluhy kl vesnice
        push    bx
        push    ds
        push    cx
        push    di
        mov     bx,40h
        mov     ds,bx
        mov     bx,word ptr ds:[1ch]            ; ukazatel bufferu znak–
        pushf
        call    dword ptr cs:[adrkey]           ; vyvol n¡ p©eru¨en¡ kl vesnice
        cli                                     ; z kaz p©eru¨en¡
        push    ax
        cmp     bx,word ptr ds:[1ch]            ; byl p©ijat znak ?
        jnz     key1                            ; byl p©ijat
keynul: jmp     konec1                          ; konec programu
key1:   mov     ax,word ptr ds:[17h]            ; status
        call    pword
        mov     al,"/"
        call    pznak
        mov     ax,[bx]
        cmp     al,32
        jnz     key2
        inc     cs:[prerus]
        jmp     short key3
key2:   mov     cs:[prerus],0
key3:   call    pword
key4:   mov     al,13
        call    pznak
        mov     al,10
        call    pznak
        jmp     konec

pword:  push    ax
        mov     al,ah
        call    pbyte
        pop     ax
pbyte:  push    ax
        mov     cl,4
        ror     al,cl
        call    phex
        pop     ax
phex:   and     al,15
        add     al,30h
        cmp     al,3ah
        jc      pznak
        add     al,7
pznak:  mov     dl,al
        mov     di,cs:[buffer]          ; po‡et znak– k v˜stupu
        cmp     di,10000
        jnc     pznak1
        inc     word ptr cs:[buffer]    ; zv˜¨en¡ ‡¡ta‡e znak–
        mov     byte ptr cs:[buffer+di+2],al    ; ulo‘en¡ znaku k v˜stupu
pznak1: ret

konec1: mov     ax,word ptr ds:[17h]            ; status
        call    pword
        mov     al,"/"
        call    pznak
        jmp     key4

konec:  mov     word ptr ds:[1ch],bx
        pop     ax
        pop     di
        pop     cx
        pop     ds
        pop     bx
        iret

init:   push    cs
        pop     ds
        mov     dx,offset text1
        mov     ah,9
        int     21h
        mov     ax,3509h                ; p©e‡ten¡ vektoru p©eru¨en¡ 09h
        int     21h
        mov     word ptr [adrkey],bx    ; nastaven¡ vektoru p©eru¨en¡ kl vesnice
        mov     word ptr [adrkey+2],es
        mov     dx,offset key
        mov     ax,2509h
        int     21h                     ; nastaven¡ nov‚ adresy p©eru¨en¡
cyklus:
        cmp     word ptr cs:[buffer],0  ; jsou znaky ?
        jz      cykl2                   ; nen¡ znak k v˜stupu

        mov     dl,byte ptr cs:[buffer+2] ; ‡ten¡ znaku k v˜stupu
        mov     ah,6
        int     21h                     ; v˜stup znaku

        cli                             ; z kaz p©eru¨en¡
        mov     cx,cs:[buffer]          ; po‡et znak– k v˜stupu
        mov     di,2                    ; ukazatel znak–
        dec     word ptr cs:[buffer]    ; sn¡‘en¡ ukazatele znak–
cykl1:  mov     al,byte ptr cs:[buffer+di+1]
        mov     byte ptr cs:[buffer+di],al ; p©enos znaku
        inc     di
        loop    cykl1
        sti                             ; povolen¡ p©eru¨en¡

cykl2:  ;mov    ah,6
        ;mov    dl,255
        ;int    21h                     ; vstup znaku z kl vesnice

cykl3:  cmp     cs:[prerus],2           ; kontrola ‡¡ta‡e mezer
        jnz     cyklus

        mov     dx,word ptr cs:[adrkey+2] ; n vrat p–vodn¡ adresy p©eru¨en¡
        mov     ds,dx
        mov     dx,word ptr cs:[adrkey]
        mov     ax,2509h
        int     21h
        mov     ah,4ch
        int     21h


buffer  dw      0               ; po‡et znak– k v˜stupu
        db      10000 dup(0)    ; z sobn¡k znak– pro v˜stup
        db      0

prerus  db      0               ; ‡¡ta‡ p©eru¨en¡ mezerami

text1   db      'Monitorovac¡ program p©eru¨en¡ kl vesnice INT09.'
        db      13,10,'P©eru¨en¡ programu je mo‘n‚ dvojnasobnym stiskem mezery.'
        db      13,10,'$'

code    ENDS

stack   SEGMENT stack
        DW      256 DUP(?)              ; z sobn¡k 256 slov
stack   ENDS



        END     start           ; startovac¡ adresa

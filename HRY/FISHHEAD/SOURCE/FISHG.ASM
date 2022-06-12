code     segment
         assume    cs:Code,ds:Code
         org       100h

start:

         mov       dx,offset s2
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jnc       j01

j00:     int       20h

j01:     mov       ds:[i2],ax
         mov       bx,ax

         mov       dx,offset Hlava
         mov       ah,40h
         mov       cx,32
         int       21h                      ; z pis z hlav¡ EXE

         mov       dx,offset s3
         mov       ax,3d00h
         int       21h
         jc        j00
         mov       bx,ax
         mov       dx,offset buff
         mov       cx,0c000h
         mov       ah,3fh
         int       21h
         mov       cx,ax
         mov       bx,ds:[i2]
         mov       ah,40h
         int       21h


         mov       dx,offset s1
         mov       ax,3d00h
         int       21h
j000:    jc        j00
         mov       ds:[i1],ax


j1:      mov       dx,offset buff
         mov       bx,ds:[i1]
         mov       cx,0c000h
         mov       ah,3fh
         int       21h

         shr       ax,1
         jz        j3
         mov       cx,ax

         mov       si,dx
         mov       di,dx

         push      cx
         cld
j2:      lodsw

         sub       al,cs:[Old]
         jc        j21

         cmp       al,7
         jb        j22
         mov       al,7
         jmp       short j22

j21:     cmp       al,-8
         jae       j22
         mov       al,-8

j22:     add       cs:[Old],al
         add       al,8

         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1

         xchg      ah,al


         sub       al,cs:[Old]
         jc        j23

         cmp       al,8
         jb        j24
         mov       al,8
         jmp       short j24

j23:     cmp       al,-7
         jae       j24
         mov       al,-7

j24:     add       cs:[Old],al
         add       al,7

         or        al,ah

         stosb
         loop      j2
         pop       cx

         mov       ah,40h
         mov       dx,offset buff
         mov       bx,ds:[i2]
         int       21h
         jmp       j1


j3:
         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         mov       bx,ds:[i2]
         int       21h
         and       ax,0fh
         mov       cx,16
         sub       cx,ax
         mov       ah,40h
         mov       dx,offset Buff
         int       21h

j32:     mov       dx,offset s4
         mov       ax,3d00h
         int       21h
         jnc       j322
         jmp       kon

j322:    mov       bx,ax

         mov       dx,offset buff
         mov       ah,3fh
         mov       cx,32016
         int       21h

         mov       ah,3eh
         int       21h

         mov       bx,ds:[i2]
         mov       ah,40h
         int       21h

         dec       byte ptr ds:[s41]
         cmp       byte ptr ds:[s41],"0"
         ja        j32

         mov       ax,4201h
         xor       cx,cx
         xor       dx,dx
         mov       bx,ds:[i2]
         int       21h
         mov       word ptr ds:[siz],ax
         mov       word ptr ds:[siz+2],dx

         add       ax,511
         mov       cx,512
         div       cx
         mov       word ptr ds:[NumPage],ax
         mov       ax,word ptr ds:[siz]
         and       ax,511
         mov       ds:[LastPg],ax

;         mov       ax,word ptr ds:[siz]
;         mov       dx,word ptr ds:[siz+2]
;         mov       cx,16
;         div       cx
;         add       ax,100h
;         mov       ds:[RegSS],ax

         xor       cx,cx
         xor       dx,dx
         mov       ax,4200h
         int       21h

         mov       dx,offset Hlava
         mov       cx,32
         mov       ah,40h
         int       21h

         mov       dx,23h
         xor       cx,cx
         mov       ax,4200h
         int       21h

         mov       dx,offset siz
         mov       cx,4
         mov       ah,40h
         int       21h

kon:     int       20h

i1       dw        0
i2       dw        0

Hlava    label     byte
         db        'MZ'
LastPg   dw        0                        ; d‚lka posledn¡ str nky v bajtech
NumPage  dw        0                        ; d‚lka souboru ve str nk ch 512 B
NumRelok dw        0                        ; po‡et polo‘ek reloka‡n¡ tabulky
HeadSize dw        2                        ; velikost z hlav¡ v odstavc¡ch
MinMem   dw        0                        ; minim ln¡ pamˆŸ
MaxMem   dw        0                        ; maxim ln¡ pamˆŸ
RegSS    dw        0fff0h                   ; registr SS
RegSP    dw        306h                     ; registr SP
Summ     dw        0                        ; kontroln¡ sou‡et
RegIP    dw        100h                     ; registr IP
RegCS    dw        0fff0h                   ; registr CS
BegRel   dw        1ch                      ; za‡ tek reloka‡n¡ tabulky
         dw        0                        ; ‡¡slo OVL
         dd        0                        ; reloka‡n¡ tabulka

s1       db        'FISH.VOC',0
s2       db        'FISHHEAD.EXE',0
s3       db        'FISH.COM',0

Old      db        0                        ; p–vodn¡ hodnota dat

s4       db        'FISH'
s41      db        '8.SCR',0

siz      dd        0                        ; velikost souboru

buff     db        0c000h dup(?)

code     ends
         end       start

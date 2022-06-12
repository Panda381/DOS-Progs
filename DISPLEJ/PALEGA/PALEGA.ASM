
;                    zobrazen¡ palet displeje EGA

code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       ax,3
         call      int10

         mov       ah,0fh
         call      int10
         cmp       al,3
         je        starte2

starte1: mov       dx,offset errtxt
         mov       ah,9
         int       21h
         int       20h

starte2:
         push      ds
         xor       ax,ax
         mov       ds,ax
         cmp       word ptr ds:[463h],3d4h
         pop       ds
         jne       starte1

         mov       dx,3dah
         in        al,dx
         mov       dx,3c0h
         mov       al,10h
         out       dx,al
         mov       al,2
         out       dx,al

         cld
         mov       ah,0e0h
         mov       si,offset nadpis
         xor       dx,dx
         mov       cx,offset(nadpis0-nadpis)
start9:  lodsb
         call      disp1ch
         loop      start9

         call      barvy

         mov       dx,25*256
         xor       ax,ax
         call      disp1ch


         cli
         call      waitv                    ; konec vert. impulsu

         xor       cx,cx
startc:  call      waith
         inc       cx
         mov       dx,3dah
         in        al,dx
         test      al,8
         jz        startc                   ; ‡ek n¡ na vert. impuls
         sti

         xor       dx,dx
         mov       ax,cx
         mov       cx,25
         div       cx                       ; po‡et linek na © dek
         mov       cx,3
         mul       cx                       ; po‡et linek na paletu

         cmp       ax,3*3
         jb        startd
         cmp       ax,3*32
         jb        starte
startd:  mov       ax,3*14
starte:  sub       ax,9
         mov       ds:[delay],al
;         mov       cx,8
;         div       cx
;         mov       ds:[delay2],al

start1:

                                            ; ‡ek n¡ na za‡ tek sn¡mku
         sti

         mov       ah,1
         int       16h
         jnz       navrat

         call      waitv

         cli

         mov       cx,4

         mov       al,1

start4:  mov       bl,ds:[delay]
         call      waitnum

         mov       ah,8
         call      palety

         mov       bl,ds:[delay]
         call      waitnum

         cmp       cx,1
         jne       start3
         xor       al,al
start3:  xor       ah,ah
         call      palety

         loop      start4

         jmp       start1


navrat:  xor       ax,ax
         int       16h
         mov       ax,3
         call      int10
         int       20h




palety:  and       al,3fh
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         mov       cx,8

         mov       bl,al
         mov       bh,20h

         mov       si,3c0h
         mov       di,3dah

         mov       dx,di
palet4:  in        al,dx                    ; 8 takt–
         shr       al,1                     ; 2 takty
         jnc       palet4                   ; 16/4 takty

palet5:  in        al,dx
         shr       al,1
         jc        palet5


palet1:
                                          ;* ‡ek n¡ na za‡ tek synchroimpulsu

         mov       dx,di
palet2:  in        al,dx                    ; 8 takt–
         shr       al,1                     ; 2 takty
         jnc       palet2                   ; 16/4 takty

                                          ;* nastaven¡ paletov‚ho registru
         mov       dx,si                    ; 2 takty - adresa portu
         mov       al,ah                    ; 2 takty - ‡¡slo registru
         out       dx,al                    ; 8 takt– - nastaven¡ ‡¡sla registru
         mov       al,bl                    ; 2 takty - po‘adovan‚ nastaven¡
         out       dx,al                    ; 8 takt– - definice palety
         mov       al,bh                    ; 2 takty - bajt 20h
         out       dx,al                    ; 8 takt– - zapnut¡ videosign lu

         inc       ah                       ; zv˜¨en¡ ‡¡sla registru
         add       bl,8                     ; zv˜¨en¡ hodnoty palety

         mov       dx,di
palet3:  in        al,dx
         shr       al,1
         jc        palet3

         loop      palet1

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       al
         ret


waitnum: push      cx
         xor       cx,cx
         mov       cl,bl
         jcxz      waitnm2
waitnm1: call      waith
         loop      waitnm1
waitnm2: pop       cx
         ret


waith:   push      ax
         push      dx
         mov       dx,3dah

waith1:  in        al,dx
         test      al,8
         jnz       waith3
         test      al,1
         jnz       waith1

waith2:  in        al,dx
         test      al,1
         jz        waith2

waith3:  pop       dx
         pop       ax
         ret


waitv:   push      ax
         push      dx
         mov       dx,3dah

waitv1:  in        al,dx
         test      al,8
         jz        waitv1

waitv2:  in        al,dx
         test      al,8
         jnz       waitv2

         pop       dx
         pop       ax
         ret


barvy:   mov       cx,8
         mov       dh,1
         xor       ax,ax
barvy1:
         call      radek
         call      cisla
         inc       dh
         call      radek
         inc       dh
         call      radek
         inc       dh
         xor       ah,80h
         inc       al
         loop      barvy1
         ret

cisla:   push      ax
         push      bx
         push      cx
         push      dx
         and       ah,0f0h
         mov       bl,ah
         mov       dl,4
         mov       cl,4
         rol       ah,cl
         or        ah,bl
         xor       ah,0fh
cisla2:  mov       cx,8
cisla1:  call      dispnum
         add       dl,10
         add       al,8
         add       ah,10h
         dec       ah
         loop      cisla1
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


radek:   push      ax
         push      cx
         push      dx
         xor       dl,dl
         mov       cx,8
radek1:  push      cx
         mov       cx,10
         mov       al," "
         call      dispch
         pop       cx
         add       ah,10h
         loop      radek1
         pop       dx
         pop       cx
         pop       ax
         ret


dispnum: push      ax
         push      bx
         push      dx
         mov       bl,ah
         mov       bh,10
         xor       ah,ah
         div       bh
         inc       dl
         xchg      ah,al
         or        ah,ah
         jz        dispnm1
         dec       dl
         mov       bh,al
         mov       al,ah
         add       al,"0"
         mov       ah,bl
         call      disp1ch
         mov       al,bh

dispnm1: add       al,"0"
         mov       ah,bl
         call      disp1ch

         pop       dx
         pop       bx
         pop       ax
         ret



disp1ch: push      cx
         mov       cl,1
         call      dispch
         pop       cx
         ret

DispCh:  push      ax
         push      bx
         push      cx
         push      dx

         xor       bh,bh
         push      ax
         mov       ah,2
         call      int10
         pop       ax

         mov       bl,ah
         mov       ah,9
         xor       ch,ch
         call      int10

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         add       dl,cl
         ret


Int10:   push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

nadpis   db        ' > ÍÍÍÍÍÍÍÍÍÍÍÍÍ Palety displeje EGA/VGA;  (c) Miroslav Nemecek '
         db        'ÍÍÍÍÍÍÍÍÍÍÍÍÍ < '
nadpis0  label     byte

errtxt   db        'Program vyzaduje kompatibilni kartu EGA/VGA !',13,10,'$'

delay    db        3*14-8

code     ends
         end       start

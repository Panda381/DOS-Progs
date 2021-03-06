COMMENT %

 Driver pro obsluhu kl�vesnice s �esk�m fontem znak�

%
code     SEGMENT   page
         ASSUME    cs:code,ds:code

         db        "Driver pro �eskou kl�vesnici CSKEY V1.32",13,10
         db        "(C) MNS leden 1990",13,10

start:
         jmp       init

adrkey   dd        0                        ; adresa driveru kl�vesnice
adrtim   dd        0                        ; adresa �asova�e INT 8
partim   db        1                        ; parametr stmavovani displeje
status   db        0
swtab    db        0
extab    dw        0
parins   db        0                        ; ��ta� znak� INSERT
znakz    dw        32                       ; posledn� vlo�en� znak
count    dw        5455                     ; ��ta� ztmavnut�
                                            ; tabulka norm. �e�tiny
tab1     db        "1�"
         db        "2�"
         db        "3�"
         db        "4�"
         db        "5�"
         db        "6�"
         db        "7�"
         db        "8�"
         db        "9�"
         db        "0�"
         db        0

tab2     db        "1�"                     ; tabulka velk�ch p�smen
         db        "2�"
         db        "3�"
         db        "4�"
         db        "5�"
         db        "6�"
         db        "7�"
         db        "8�"
         db        "9�"
         db        "0�"
         db        0


                                            ; tabulka pro `
tab3     db        "+�"
         db        "=�"
         db        "q�"
         db        "Q�"
         db        "w�"
         db        "W�"
         db        "e�"
         db        "E�"
         db        "r�"
         db        "R�"
         db        "t�"
         db        "T�"
         db        "y�"
         db        "Y�"
         db        "u�"
         db        "U�"
         db        "i�"
         db        "I�"
         db        "o�"
         db        "O�"
         db        "p�"
         db        "P�"
         db        "a�"
         db        "A�"
         db        "s�"
         db        "S�"
         db        "d�"
         db        "D�"
         db        "f�"
         db        "F�"
         db        "h�"
         db        "H�"
         db        "j�"
         db        "J�"
         db        "k�"
         db        "K�"
         db        "l�"
         db        "L�"
         db        "z�"
         db        "Z�"
         db        "c�"
         db        "C�"
         db        "n�"
         db        "N�"
         db        "m�"
         db        "M�"
         db        ",�"
         db        "<�"
         db        ".�"
         db        ">�"
         db        "\�"
         db        0

tab4     db        "0",205
         db        "1",200
         db        "2",202
         db        "3",188
         db        "4",204
         db        "5",206
         db        "6",185
         db        "7",201
         db        "8",203
         db        "9",187
         db        ".",186

         db        52h,205
         db        4fh,212
         db        50h,207
         db        51h,190
         db        4bh,198
         db        4ch,216
         db        4dh,181
         db        47h,213
         db        48h,209
         db        49h,184
         db        53h,179
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0


tab5     db        "0",196
         db        "1",192
         db        "2",193
         db        "3",217
         db        "4",195
         db        "5",197
         db        "6",180
         db        "7",218
         db        "8",194
         db        "9",191
         db        ".",179

         db        52h,196
         db        4fh,211
         db        50h,208
         db        51h,189
         db        4bh,199
         db        4ch,215
         db        4dh,182
         db        47h,214
         db        48h,210
         db        49h,183
         db        53h,186
         db        "/",176
         db        "*",177
         db        "-",178
         db        "+",219
         db        0

paloff   db        0,0,0,0,0,0,38h,38h,0,0,38h,38h,38h,38h,38h,38h,0
palon    db        0,1,2,3,4,5,14h,7,38h,39h,3ah,3bh,3ch,3dh,3eh,3fh,0

intbuf   db        16*4 DUP (0)             ; buffer pro z�znam p�eru�en�

timer:                                      ; program obsluhy �asova�e
         pushf
         call      dword ptr cs:[adrtim]    ; obsluha �asova�e INT 08h
         cli
         cmp       cs:[partim],0
         jz        kontim                   ; neni stmavovani
         cmp       cs:[count],0             ; ��ta� ztmavnut�
         jz        kontim0
         dec       cs:[count]
         jnz       kontim
         call      ztmav

kontim0: mov       cs:[count],4
kontim:  iret

ztmav:   push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bx,cs
         mov       es,bx
         mov       ax,1002h
         mov       dx,offset paloff         ; paleta ztmavnut�
         cli
         int       10h
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

key:                                        ; program obsluhy kl�vesnice
         push      bx
         push      es
         push      si
         push      bp
         push      ds
         push      cx
         push      di
         mov       bx,40h
         mov       ds,bx
         mov       bx,cs
         mov       es,bx
         mov       bx,word ptr ds:[1ch]     ; ukazatel bufferu znak�
         pushf
         call      dword ptr cs:[adrkey]    ; vyvol�n� p�eru�en� kl�vesnice
         cli
         push      ax
         cmp       cs:[partim],0
         jz        palon80

         cmp       cs:[count],10
         jnc       palon8
         cmp       cs:[count],5             ; ��ta� ztmavnut�
         jnc       palon80
palon81: mov       word ptr ds:[1ch],bx     ; zru�en� znaku
         mov       ax,1002h
         mov       dx,offset palon          ; norm�ln� barvy
         cli
         int       10h
palon8:  mov       cs:[count],5455          ; ��ta� 5 minut

palon80: mov       al,byte ptr ds:[17h]     ; p�e�ten� statusu kl�vesnice
         mov       byte ptr cs:[status],al  ; ulo�en� statusu
         mov       ax,[bx]                  ; p�e�ten� znaku z bufferu
         cmp       bx,word ptr ds:[1ch]     ; byl p�ijat znak ?
         jnz       key1                     ; byl p�ijat
keynul:                                     ; nebyl p�ijat znak
         mov       al,byte ptr ds:[18h]     ; status kl�vesnice
         cmp       al,80h                   ; je kl�vesa INS ?
         jnz       keynl1                   ; nen� kl�vesa INS
         mov       al,cs:[parins]
         xor       al,1
         mov       cs:[parins],al           ; zm�na p��znaku INS
         jz        keynl1                   ; je sud� znak
         mov       ax,52e0h                 ; k�d INS
         call      inskey                   ; vlo�en� znaku INS
keynl1:  jmp       konec                    ; konec programu
key1:
         cmp       ax,52e0h                 ; je znak INS ?
         jnz       keynl2
         mov       al,1
         mov       cs:[parins],al
         jmp       short keynl1

keynl2:
         mov       al,cs:[status]
         and       al,3                     ; p��znaky SHIFT
         mov       al,cs:[status]
         jnz       keyes1                   ; je SHIFT
         jmp       keyes9                   ; neni SHIFT
keyes1:  and       al,0ch                   ; p��znaky CTRL a ALT
         cmp       al,8                     ; je ALT ?
         mov       ax,[bx]                  ; znak
         jz        keyes0                   ; je ALT
         jmp       keynl9                   ; nen� pouze ALT

keyes0:  cmp       ax,9800h                 ; �ipka nahoru
         jnz       keynl3
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,48e0h
         jmp       short keynl7
keynl3:  cmp       ax,0a000h                ; �ipka dol�
         jnz       keynl4
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,50e0h
         jmp       short keynl7
keynl4:  cmp       ax,9d00h                 ; �ipka vpravo
         jnz       keynl5
         mov       ax,cs:[znakz]
         mov       [bx],ax
         jmp       short keynl8
keynl5:  cmp       ax,9b00h                 ; �ipka vlevo
         jnz       keynl90
         mov       ax,cs:[znakz]
         mov       [bx],ax
         mov       ax,4be0h
         call      inskey
         mov       ax,4be0h
keynl7:  call      inskey
keynl8:  jmp       konec
keynl90: jmp       keynl9
keyes9:
         and       al,0ch                   ; p��znak CTRL a ALT
         cmp       al,0ch                   ; je CTRL i ALT ?
         mov       ax,[bx]
         jnz       keynl90                  ; nen� CTRL i ALT
         cmp       ax,01f0h                 ; kl�vesa <Esc>
         jnz       keyesc                   ; nen� <Esc>
         cli
         cld                                ; sm�r p�enosu nahoru

         mov       cx,2*4                   ; po�et bajt� k p�enosu
         mov       di,8*4                   ; adresa vektoru 09h
         mov       ax,0
         mov       es,ax                    ; segment tabulky p�eru�en�
         lea       si,intbuf                ; adresa bufferu tabulky p�eru�en�
         mov       ax,cs                    ; programov� segment
         mov       ds,ax                    ; segment bufferu vektoru
         rep       movsb                    ; p�enos tabulky vektor�
         mov       cx,1*4
         mov       di,16*4
         rep       movsb
         mov       cx,1*4
         mov       di,22*4
         rep       movsb
         mov       cx,3*4
         mov       di,26*4
         rep       movsb
         mov       cx,8*4
         mov       di,32*4
         rep       movsb
         mov       cx,1*4
         mov       di,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         mov       ax,0003                  ; textov� re�im
         int       10h                      ; nastaven� displeje
         mov       ah,4ch
         int       21h                      ; p�eru�en� aktivn�ho programu

keyesc:
         cmp       ax,9800h                 ; �ipka nahoru
         jnz       keyes2
         mov       ax,48e0h
         jmp       short keyes8
keyes2:  cmp       ax,0a000h                ; �ipka dol�
         jnz       keyes3
         mov       ax,50e0h
         jmp       short keyes8
keyes3:  cmp       ax,9d00h                 ; �ipka vpravo
         jnz       keyes4
         mov       ax,4de0h
         jmp       short keyes8
keyes4:  cmp       ax,9b00h                 ; �ipka vlevo
         jnz       keynl9
         mov       ax,4be0h
keyes8:  mov       [bx],ax
         mov       cx,9
keyes7:  call      inskey
         loop      keyes7
         jmp       konec

keynl9:
         cmp       ah,0                     ; je to znak s ALT ?
         jnz       key5                     ; je ALT - konec
key10:   mov       cs:[extab],0             ; zru�en� tabulky
         jmp       keynul                   ; konec programu
key5:    cmp       al,60h                   ; je znak ` (�arka) ?
         jnz       key3                     ; nen�
         cmp       cs:[extab],0
         jnz       key3                     ; je podruh�
         mov       cs:[extab],offset tab3   ; nastaven� tabulky 2
zrus:    mov       word ptr ds:[1ch],bx     ; n�vrat ukazatele znak�
konec1:  jmp       konec
key3:    cmp       cs:[extab],0             ; je roz���en� tabulka ?
         mov       di,word ptr cs:[extab]
         jnz       key4                     ; ano
         cmp       cs:[swtab],0             ; je p�ep�na� tabulek ?
         jz        konec1                   ; tabulka IBM
         cmp       cs:[swtab],1
         jnz       key30
         cmp       ah,2
         jc        konec1
         cmp       ah,12
         jnc       konec1
         mov       di,offset tab1
         test      cs:[status],40h          ; p��znak CAPS LOCK
         jz        key320
         mov       di,offset tab2           ; jsou velk� p�smena
         jmp       short key320
key30:   mov       di,offset tab4
         cmp       cs:[swtab],2
         jz        key33
         mov       di,offset tab5
key33:   cmp       ax,4e2bh
         jz        key320
         cmp       ax,4a2dh
         jz        key320
         cmp       ax,372ah
         jz        key320
         cmp       ax,0e02fh
         jz        key320
         cmp       ax,532eh
         jz        key320
         cmp       al,0f0h
         jz        key32
         cmp       al,0
         jnz       key31
key32:   mov       al,ah
key320:  jmp       key7
key31:   cmp       ah,13
         jc        gokon
         cmp       al,30h
         jc        gokon
         cmp       al,3ah
         jc        key320
gokon:   jmp       short konec1
key4:                                       ; p�ek�dov�n� podle tabulky DI
         cmp       ax,0e08h
         jz        key43
         cmp       ax,53e0h
         jz        key43
         cmp       ax,0231h                 ; 1
         jnz       key41
         mov       cs:[swtab],0
         jmp       short key43
key41:   cmp       ax,0332h                 ; 2
         jnz       key42
         mov       cs:[swtab],1
key43:   mov       word ptr ds:[1ch],bx
         jmp       key6
key42:   cmp       ax,0433h                 ; 3
         jnz       key44
         mov       cs:[swtab],2
         jmp       short key43
key44:   cmp       ax,0534h                 ; 4
         jnz       key401
         mov       cs:[swtab],3
         jmp       short key43
key401:  cmp       ax,0938h                 ; 8
         jnz       key40
         call      ztmav
         mov       cs:[count],9
         mov       cs:[partim],1
         jmp       short key43
key40:   cmp       ax,0a39h                 ; 9
         jnz       key402
         mov       cs:[partim],1
         jmp       short key43
key402:  cmp       ax,0b30h                 ; 0
         jnz       key403
         mov       cs:[partim],0
         jmp       short key43
key403:  cmp       ax,011bh                 ; <Esc>
         jnz       key7
         call      loadint                  ; ulo�en� vektor� p�eru�en�
         jmp       short key43
key7:    cmp       al,cs:[di]
         jz        key8
         inc       di
         inc       di
         cmp       byte ptr cs:[di],0
         jnz       key7
         jmp       short key6
key8:    inc       di
         mov       al,cs:[di]
         mov       ah,0
         mov       [bx],ax
key6:    mov       cs:[extab],0             ; zru�en� p�echodn� tabulky

konec:                                      ; konec se z�znamem znaku
         mov       ax,[bx]                  ; p�e�ten� znaku z bufferu
         cmp       bx,word ptr ds:[1ch]     ; byl p�ijat znak ?
         jz        konec3                   ; nebyl p�ijat
         test      ah,ah
         jz        konec2
         cmp       al,32
         jc        konec3
         cmp       al,7fh
         jz        konec3
         cmp       al,0e0h
         jz        konec3
         cmp       al,0f0h
         jz        konec3
konec2:  mov       cs:[znakz],ax            ; ulo�en� posledn� zadan�ho znaku
konec3:  pop       ax
         pop       di
         pop       cx
         pop       ds
         pop       bp
         pop       si
         pop       es
         pop       bx
         iret



inskey:                                     ; vlo�en� znaku AX do bufferu
         mov       bx,word ptr ds:[1ch]     ; ukazatel pro ulo�en� znaku
         push      bx
         inc       bx
         inc       bx                       ; zv��en� pozice
         cmp       bx,3eh                   ; je p�ekro�en� konce bufferu ?
         jc        insk1                    ; nen�
         mov       bx,1eh                   ; za��tek bufferu
insk1:   cmp       bx,word ptr ds:[1ah]     ; ukazatel pro �ten� znaku
         jz        insk2                    ; nen� voln� m�sto v bufferu
         mov       word ptr ds:[1ch],bx     ; nov� ukazatel
         pop       bx                       ; p�vodn� ukazatel
         mov       ds:[bx],ax               ; ulo�en� znaku
         mov       bx,word ptr ds:[1ch]
         ret
insk2:   pop       bx                       ; n�vrat ukazatele znak�
         ret


loadint:
         push      ax
         push      cx
         push      si
         push      di
         push      ds
         push      es
         cld                                ; sm�r p�enosu nahoru
         cli                                ; z�kaz p�eru�en�
         mov       cx,2*4                   ; po�et bajt� k p�enosu
         mov       si,8*4                   ; adresa vektoru 03h
         mov       ax,0
         mov       ds,ax                    ; segment tabulky p�eru�en�
         lea       di,intbuf                ; adresa bufferu tabulky p�eru�en�
         mov       ax,cs                    ; programov� segment
         mov       es,ax                    ; p��jmov� segment
         rep       movsb                    ; p�enos vektor� 03h az 27h
         mov       cx,1*4
         mov       si,16*4
         rep       movsb
         mov       cx,1*4
         mov       si,22*4
         rep       movsb
         mov       cx,3*4
         mov       si,26*4
         rep       movsb
         mov       cx,8*4
         mov       si,32*4
         rep       movsb
         mov       cx,1*4
         mov       si,298*4
         rep       movsb                    ; ukazatel na parametry EGA
         pop       es
         pop       ds
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret


; zde je konec rezidentn� ��sti programu


init:    push      cs
         pop       ds
         mov       ax,3509h                 ; p�e�ten� vektoru p�eru�en� 09h
         int       21h
         cmp       bx,offset key            ; obsluha kl�vesnice
         je        nainst                   ; hl��en�, �e je ji� nainstalov�n
         mov       word ptr [adrkey],bx     ; nastaven� vektoru p�eru�en� kl�vesnice
         mov       word ptr [adrkey+2],es
         mov       dx,offset key
         mov       ax,2509h
         int       21h                      ; nastaven� nov� adresy p�eru�en�

         mov       ax,3508h                 ; precteni vektoru preruseni 08h
         int       21h
         mov       word ptr [adrtim],bx     ; ulozeni vektoru preruseni casovace
         mov       word ptr [adrtim+2],es
         mov       dx,offset timer
         mov       ax,2508h                 ; nov� adresa p�eru�en� �asova�e
         int       21h
         call      loadint                  ; ulo�en� vektor� p�eru�en�
         sti                                ; povolen� p�eru�en�
         mov       ax,cs
         mov       ds,ax
         mov       dx,offset text1          ; �vodn� text
         mov       ah,9
         int       21h                      ; tisk �vodn�ho textu
         mov       dx,word ptr init         ; konec programu
         int       27h                      ; ukon�en� programu jako rezidentn�

nainst:  mov       dx,offset text2          ; hl��en�, �e je ji� nainstalov�n
         mov       ah,9
         int       21h
         mov       ah,4ch                   ; norm�ln� ukon�en� programu
         int       21h

text1    db        'Driver pro �eskou kl�vesnici CSKEY V 1.32 byl nainstalov�n.'
         db        13,10,'$'

text2    db        'Driver pro �eskou kl�vesnici je ji� nainstalov�n v pam�ti !'
         db        13,10,'$'

code     ENDS

stack    SEGMENT   stack
         DW        256 DUP(?)               ; z�sobn�k 256 slov
stack    ENDS

         END       start                    ; startovac� adresa

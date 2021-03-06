COMMENT %

 Driver pro obsluhu kl�vesnice s �esk�m fontem znak�

%
code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

start:
         jmp       init                     ; instalace programu

ident    db        "CSKEY V 2.00 - driver pro �eskou kl�vesnici",13,10
         db        "(C) NMS �ervenec 1990",13,10
ident0:

; -----------------------------------------------------------------------------
;               Obsluha p�eru�en� kl�vesnic� INT 09H
; -----------------------------------------------------------------------------

         dw        128 dup (0)              ; z�sobn�k pro p�eru�en� kl�vesnic�
stackk   dd        0                        ; �schova ukazatele z�sobn�ku
parrk    db        0                        ; parametr prob�haj�c�ho p�eru�en�

key:                                        ; program obsluhy kl�vesnice
         test      cs:[parrk],0ffh          ; prob�h� p�eru�en� od kl�vesnice ?
;         jz        keyno                    ; neprob�h� p�eru�en� od kl�vesnice
         pushf                              ; ignorov�n� po�adavku p�eru�en�
         jmp       dword ptr cs:[adrkey]    ; vyvol�n� p�eru�en� kl�vesnice

keyno:                                      ; za��tek obsluhy - �schova stavu
         mov       cs:[parrk],0ffh          ; nastaven� p��znaku p�eru�en�
         mov       word ptr cs:[stackk],sp  ; �schova ukazatele z�sobn�ku
         mov       word ptr cs:[stackk+2],ss
         mov       sp,ax                    ; �schova registru AX
         mov       ax,cs                    ; segment programu
         mov       ss,ax                    ; nastaven� segmentu z�sobn�ku
         mov       ax,sp                    ; n�vrat registru AX
         mov       sp,offset stackk         ; adresa vlastn�ho z�sobn�ku
         push      ax
         push      bx
         push      cx
         push      es
         push      si
         push      bp
         push      ds
         push      di

         mov       bx,40h
         mov       ds,bx                    ; datov� segment 0040h
         mov       bx,cs
         mov       es,bx
         mov       bx,word ptr ds:[1ch]     ; ukl�dac� adresa znak�
                                            ; standardn� obsluha p�eru�en�
         pushf
         call      dword ptr cs:[adrkey]    ; vyvol�n� p�eru�en� kl�vesnice
                                            ; obsluha ztmavova�e
         cmp       byte ptr cs:[partim],0
         jz        palon80                  ; nen� zapnuta funkce �asova�e
         cmp       cs:[count],10            ; nebylo je�t� ztmaven� displeje
         jnc       palon8
         cmp       cs:[count],5             ; ��ta� ztmavnut�
         jnc       palon80
palon81: mov       word ptr ds:[1ch],bx     ; zru�en� znaku
         call      seton                    ; nastaven� palet
palon8:  mov       cs:[count],5455          ; ��ta� 5 minut

palon80: mov       al,byte ptr ds:[17h]     ; p�e�ten� statutu kl�vesnice
         mov       byte ptr cs:[status],al  ; ulo�en� statutu
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
key10:   mov       word ptr cs:[extab],0    ; zru�en� tabulky
         jmp       keynul                   ; konec programu
key5:    cmp       al,60h                   ; je znak ` (�arka) ?
         jnz       key3                     ; nen�
         cmp       word ptr cs:[extab],0
         jnz       key3                     ; je podruh�
         mov       word ptr cs:[extab],offset tab3 ; nastaven� tabulky 2
zrus:    mov       word ptr ds:[1ch],bx     ; n�vrat ukazatele znak�
konec1:  jmp       konec
key3:    cmp       word ptr cs:[extab],0    ; je roz���en� tabulka ?
         mov       di,word ptr cs:[extab]
         jnz       key4                     ; ano
         cmp       byte ptr cs:[swtab],0    ; je p�ep�na� tabulek ?
         jz        konec1                   ; tabulka IBM
         cmp       byte ptr cs:[swtab],1
         jnz       key30
         cmp       ah,2
         jc        konec1
         cmp       ah,12
         jnc       konec1
         mov       di,offset tab1
         test      byte ptr cs:[status],40h ; p��znak CAPS LOCK
         jz        key320
         mov       di,offset tab2           ; jsou velk� p�smena
         jmp       short key320
key30:   mov       di,offset tab4
         cmp       byte ptr cs:[swtab],2
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
         mov       byte ptr cs:[swtab],0
         jmp       short key43
key41:   cmp       ax,0332h                 ; 2
         jnz       key42
         mov       byte ptr cs:[swtab],1
key43:   mov       word ptr ds:[1ch],bx
         jmp       key6
key42:   cmp       ax,0433h                 ; 3
         jnz       key44
         mov       byte ptr cs:[swtab],2
         jmp       short key43
key44:   cmp       ax,0534h                 ; 4
         jnz       key401
         mov       byte ptr cs:[swtab],3
         jmp       short key43
key401:  cmp       ax,0938h                 ; 8
         jnz       key40
         cli
         mov       byte ptr cs:[partim],1
         mov       cs:[count],9
         call      setoff
         jmp       short key43
key40:   cmp       ax,0a39h                 ; 9
         jnz       key402
         mov       byte ptr cs:[partim],1
         jmp       short key43
key402:  cmp       ax,0b30h                 ; 0
         jnz       key403
         mov       byte ptr cs:[partim],0
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
key6:    mov       word ptr cs:[extab],0    ; zru�en� p�echodn� tabulky

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
konec3:
         pop       di
         pop       ds
         pop       bp
         pop       si
         pop       es
         pop       cx
         pop       bx
         pop       ax
         mov       ss,word ptr cs:[stackk+2]
         mov       sp,word ptr cs:[stackk]  ; n�vrat z�sobn�ku
         mov       cs:[parrk],0             ; ukon�en� p��znaku p�eru�en�
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

         dw        64 dup (0)
stack1   dd        0                        ; pracovn� z�sobn�k pro �asova�

segmint  dw        0                        ; segment programu

timer:                                      ; program obsluhy �asova�e

;         mov       word ptr cs:[stack1],sp  ; �schova z�sobn�ku
;         mov       word ptr cs:[stack1+2],ss
;         mov       sp,offset stack1
;         mov       ss,cs:[segmint]          ; segment pro p�eru�en�
         pushf
         call      dword ptr cs:[adrtim]    ; obsluha �asova�e INT 08h
;         cmp       byte ptr cs:[partim],0
;         jz        kontim                   ; nen� ztmavov�n�
;         cmp       cs:[count],0             ; ��ta� ztmavnut�
;         jz        kontim0
;         dec       cs:[count]
;         jnz       kontim
;         mov       cs:[count],4
;         call      setoff

;kontim0: mov       cs:[count],4
;kontim:  mov       ss,word ptr cs:[stack1+2]
;         mov       sp,word ptr cs:[stack1]  ; n�vrat z�sobn�ku
         iret

setoff:  push      ax
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



;setoff:  push      ds
;         push      dx
;         push      ax
;         xor       ax,ax
;         mov       ds,ax
;         mov       dx,word ptr ds:[0463h]
;         add       dx,4
;         mov       al,byte ptr ds:[0465h]
;         and       al,0f7h
;         out       dx,al
;         mov       byte ptr ds:[0465h],al
;         pop       ax
;         pop       dx
;         pop       ds
;         ret
;

seton:   push      ax
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
         mov       dx,offset palon          ; paleta rozsv�cen�
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

;seton:   push      ds
;         push      dx
;         push      ax
;         xor       ax,ax
;         mov       ds,ax
;         mov       dx,word ptr ds:[0463h]
;         add       dx,4
;         mov       al,byte ptr ds:[0465h]
;         or        al,8
;         out       dx,al
;         mov       byte ptr ds:[0465h],al
;         pop       ax
;         pop       dx
;         pop       ds
;         ret


setpal:  push      ax
         push      bx
         push      cx
         push      dx
         cli
         mov       dx,3dah
         in        al,dx                    ; nastaven� adresov�ho m�du
         mov       dx,3c0h                  ; ��d�c� port EGA
         mov       cx,16                    ; po�et registr� palet
         mov       bl,0                     ; ��ta� registr�
setpal1: mov       al,bl
         out       dx,al                    ; registr palety
         mov       al,cs:[si]               ; barva palety
         out       dx,al                    ; nov� barva
         inc       si                       ; nov� barva
         inc       bl                       ; nov� registr
         loop      setpal1                  ; dal�� paleta
         mov       al,11h
         out       dx,al
         mov       al,cs:[si]               ; barva okol�
         out       dx,al                    ; barva registru okol�
         mov       al,20h
         out       dx,al
         out       dx,al
         sti                                ; povolen� p�eru�en�
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


loadint:                                    ; ulo�en� vektor� p�eru�en�
                                            ; tento podprogram uschov� vektory
                                            ; p�eru�en� pro funkci p�eru�en�
                                            ; programu <Ctrl>-<Alt>-<Esc>
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



control:                                    ; ��d�c� ��st programu
;         cmp       ah,63h                   ; funkce pro driver
         pushf
         jmp       dword ptr cs:[adrid]      ; p�vodn� obsluha
;         jz        contr1                   ; je tato funkce
;         iret                               ; n�vrat z p�eru�en�
;contr1:  mov       ax,cs
;         mov       bx,ax
;         mov       ax,4321h
;         mov       cx,0fedch
;         iret



adrid    dd        0                        ; adresa identifika�n� ��sti
adrkey   dd        0                        ; adresa obsluhy kl�vesnice INT 09
adrtim   dd        0                        ; adresa obsluhy �asova�e INT 08

partim   db        0                        ; parametr ztmavov�n� displeje EGA
                                            ; (1=ztmavov�n� zapnuto, 0=vypnuto)
status   db        0                        ;
swtab    db        0
extab    dw        0
parins   db        0                        ; ��ta� znak� INSERT
znakz    dw        32                       ; posledn� vlo�en� znak
count    dw        1091                     ; ��ta� ztmavnut�
                                            ; tabulka norm. �e�tiny



; zde je konec rezidentn� ��sti programu

; ===========================================================================

                                            ; instalace rezid. ��sti programu

init:   ; mov       cs:[datseg],ds           ; datov� segment programu
        ; mov       cs:[segmint],cs
        ; mov       ax,cs
        ; mov       ds,ax                    ; nastaven� DS shodn� jako CS


                                            ; kontrola instalace programu
         clc                                ; vynulov�n� p��znaku p�enosu CF
         mov       ax,6300h                 ; funkce 63h/00h - dotaz o stavu
         mov       cx,0abcdh                ; identifika�n� slovo
         int       16h                      ; dotaz na instalaci programu
         jc        init1                    ; nen� nainstalov�n OK
         cmp       ax,4321h                 ; identifika�n� slovo
         jnz       init1                    ; nen� nainstalov�n
         cmp       cx,0fedch                ; identifika�n� slovo
         jnz       init1                    ; nen� nainstalov�n

;         push      bx                       ; segment rezidentn�ho programu
;         mov       ax,3509h                 ; p�e�ten� vektoru p�eru�en� 09h
;         int       21h
;         mov       word ptr [adrkey],bx     ; ulo�en� p�vodn�ho vekt. p�eru�en�
;         mov       word ptr [adrkey+2],es   ; segment nad�azen� instalace
;         pop       es                       ; segment rezidentn�ho programu

;         mov       cx,ident0 - ident        ; d�lka identifika�n� ��sti programu
;         xor       di,di                    ; c�lov� �et�zec
;         xor       si,si                    ; zdrojov� �et�zec
;         cld                                ; sm�r operace nahoru
;         repe      cmpsb                    ; porovn�n� identifika�n�ho �et�zce
init1:   pushf                              ; �schova p��znaku ZF
         jz        init2                    ; program je nainstalov�n
;         mov       ax,cs
;         mov       es,ax                    ; segment tohoto programu

init2:                                      ; test zad�n� p��kazov�ho ��dku
;         mov       ds,cs:[datseg]           ; datov� segment programu
;         mov       si,81h                   ; za��tek p��kazov�ho ��dku
;         mov       cl,ds:[80h]              ; po�et znak� p��kazov�ho ��dku
;         xor       ch,ch
;         or        cl,cl                    ; je n�jak� znak ?
;         jnz       init4                    ; je zad�n n�jak� znak v p��kazu
init3:   popf                               ; n�vrat p��znaku instalace ZF
         jz        init31
         jmp       instal0                  ; je instalace programu
init31:  mov       ax,cs
         mov       ds,ax
         mov       dx,offset textins        ; text, �e je ji� v pam�ti
         mov       ah,9
         int       21h                      ; tisk textu
         mov       ax,4c01h                 ; n�vratov� k�d 1
         int       21h                      ; ukon�en� programu s chybou 01

;init4:                                      ; nastaven� p��kazov�m ��dkem
;         jcxz      instal                   ; konec ��dku - instalace
;         lodsb                              ; na�ten� znaku
;         dec       cx                       ; ��ta� znak�
;         cmp       al," "                   ; je mezera ?
;         jbe       init4                    ; je ��d�c� znak nebo mezera
;         cmp       al,"0"                   ; je men�� ne� "0" ?
;         jb        init5                    ; chyba - men�� znak ne� "0"
;         cmp       al,"9"                   ; je v�t�� ne� "9" ?
;         ja        init5                    ; chyba - v�t�� znak ne� "9"
;         jnz       init41                   ; nen� "9"
;         mov       al,1
;         mov       es:[partim],al           ; zapnut� ztmavov�n�
;         jmp       short init4              ; dal�� znak
;init41:  cmp       al,"0"                   ; je znak "0" ?
;         jnz       init42
;         cli
;         xor       al,al
;         mov       es:[partim],al           ; vypnut� ztmavov�n�
;         cmp       cs:[count],10
;         jnc       init412
;         cmp       cs:[count],5             ; ��ta� ztmavnut�
;         jnc       init413
;         call      seton                    ; nastaven� palet
;init412: mov       cs:[count],5455          ; ��ta� 5 minut
;init413: sti
;         jmp       short init4              ; dal�� znak
;init42:  cmp       al,"8"
;         jnz       init43
;         cli
;         mov       es:[partim],1            ; zapnut� ztmavov�n�
;         mov       es:[count],9             ; nastaven� kr�tk� ��tac� konstanty
;         call      setoff
;         sti
;         jmp       short init4
;init43:
;         jmp       short init4
;
;init5:                                      ; chyba zad�n� parametr� programu
;         popf
;         sti                                ; povolen� p�eru�en�
;         mov       ax,cs
;         mov       ds,ax
;         mov       dx,offset texterr        ; text chyby zad�n� parametr�
;         mov       ah,9
;         int       21h                      ; tisk textu chyby
;         mov       ax,4c02h                 ; n�vratov� k�d 2
;         int       21h                      ; ukon�en� programu s chybou 02
;
instal:                                     ; instalace programu
         popf
         jnz       instal0                  ; nen� je�t� nainstalov�n
                                            ; n�vrat p�i spr�vn�ch parametrech
         mov       ax,4c00h
         int       21h                      ; ukon�en� programu bez chyby

instal0: cli                                ; z�kaz p�eru�en�
         mov       ax,3516h
         int       21h                      ; p�e�ten� star� adresy INT 16h
         mov       word ptr cs:[adrid],bx   ; ulo�en� star� adresy INT 16H
         mov       word ptr cs:[adrid+2],es
;         mov       ax,cs
;         mov       ds,ax
         mov       dx,offset control        ; ��d�c� ��st programu
         mov       ax,2516h
         int       21h                      ; nastaven� nov� adresy INT 16H

;         mov       dx,offset key            ; adresa vlastn� obsluhy INT 09h
;         mov       ax,2509h
;         int       21h                      ; nastaven� nov� adresy INT 09H
;         mov       ax,3508h                 ; p�e�ten� vektoru p�eru�en� 08h
;         int       21h
;         mov       word ptr [adrtim],bx     ; ulo�en� vektoru p�eru�en� 08h
;         mov       word ptr [adrtim+2],es
;         mov       dx,offset timer          ; adresa vlastn� obsluhy INT 08H
;         mov       ax,2508h
;         int       21h                      ; nastaven� nov� adresy INT 08H
;         call      loadint                  ; �schova vektor� p�eru�en�
         sti                                ; povolen� p�eru�en�
         mov       dx,offset textuv         ; �vodn� text
         mov       ah,9
         int       21h                      ; tisk �vodn�ho textu
         mov       ax,3100h                 ; n�vratov� k�d
         mov       dx,(init-start+110H)/16  ; d�lka programu (v segmentech)
         int       21h                      ; ukon�en� programu jako rezidentn�


textuv   db        'Driver pro ceskou klavesnici CSKEY V 2.00 byl nainstalovan.'
         db        13,10,'$'

textins  db        'Driver pro ceskou klavesnici CSKEY je jiz v pameti !'
         db        13,10,'$'

texterr  db        'CHYBA-zadejte:   CSKEY <seznam parametru>',13,10,10
         db        'parametry -  * 1 = normalni klavesnice',13,10
         db        '               2 = ceska klavesnice programatora',13,10
         db        '               3 = ceska klavesnice uplna',13,10
         db        '               4 = graficke pole - jednoducha cara',13,10
         db        '               5 = graficke pole - dvojita cara',13,10
         db        '             * 6 = cestina Kamenickych',13,10
         db        '               7 = cestina Latin 2',13,10
         db        '               8 = nucene ztmaveni displeje (EGA)',13,10
         db        '               9 = zapnuti funkce ztmavovani displeje',13,10
         db        '             * 0 = vypnuti funkce ztmavovani displeje',13,10
         db        10,'Pro rucni ovladani pouzijte klavesu <`> jako prefix.'
         db        13,10,10,'$'

datseg   dw        0                        ; datov� segment programu

code     ENDS

         END       start                    ; startovac� adresa

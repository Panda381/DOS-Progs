
; *****************************************************************************
;
;                      Zaparkov�n� pevn�ch disk�
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
start:
                                          ;* reset diskov�ho syst�mu
         mov       ah,0dh
         int       21h                      ; reset diskov�ho syst�mu DOS
                                          ;* z�sk�n� po�tu disk�
         mov       ah,8
         mov       dl,80h                   ; ��slo pevn�ho disku 0
         int       13h                      ; poskytnut� po�tu disk�
         jc        error                    ; chyba - nen� ��dn� pevn� disk
         and       dx,3                     ; po�et pevn�ch disk�
         jz        error                    ; nen� ani 1 pevn� disk
         mov       ds:[disku],dl            ; �schova po�tu pevn�ch disk�
         dec       dx                       ; je 1 pevn� disk ?
         jz        getd0                    ; je pouze 1 pevn� disk
                                          ;* zji�t�n� parkovac� stopy disku 1
         mov       dl,81h                   ; ��slo pevn�ho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji�t�n� parkovac� stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac� stopa disku 1
getd0:                                    ;* zji�t�n� parkovac� stopy disku 0
         mov       dl,80h                   ; ��slo pevn�ho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji�t�n� parkovac� stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac� stopa disku 0
                                          ;* test spr�vnosti stop
         mov       ax,ds:[parkc0]           ; parkovac� stopa disku 0
         or        ax,ds:[parkc1]           ; je alespo� 1 pevn� disk ?
         jnz       parkuj                   ; je alespo� 1 pevn� disk
                                          ;* chyba - nen� ani 1 disk
error:   mov       dx,offset errtxt
         call      outtxt                   ; zobrazen� chybov�ho textu
         int       20h

parkuj:                                   ;* zaparkov�n� disk�
         mov       dl,80h                   ; ��slo pevn�ho disku 0
         mov       bx,ds:[parkc0]           ; parkovac� stopa disku 0
         call      park                     ; zaparkov�n� pevn�ho disku 0
         inc       dl                       ; ��slo pevn�ho disku 1
         mov       bx,ds:[parkc1]           ; parkovac� stopa disku 1
         call      park                     ; zaparkov�n� pevn�ho disku 1
                                          ;* zobrazen� hl��en�
         mov       dx,offset parktxt1       ; hl��en� pro 1 pevn� disk
         or        bx,bx                    ; je platn� disk 1 ?
         jz        zobrhl                   ; je pouze pevn� disk 1
         cmp       word ptr ds:[parkc0],0   ; je platn� disk 0 ?
         je        zobrhl                   ; je pouze pevn� disk 0
         mov       dx,offset parktxt2       ; hl��en� pro 2 pevn� disky
zobrhl:  call      outtxt                   ; zobrazen� prvn� ��sti hl��en�
         mov       dx,offset parktxt3       ; druh� ��st hl��en�
         call      outtxt                   ; zobrazen� druh� ��sti hl��en�
flush:                                    ;* vypr�zdn�n� bufferu kl�vesnice
         mov       ah,1
         int       16h                      ; poskytnut� stavu kl�vesnice
         jz        cekej                    ; nen� p�ipraven dal�� znak
         xor       ax,ax
         int       16h                      ; vyjmut� znaku z bufferu
         jmp       short flush              ; zru�en� dal��ho znaku

cekej:                                    ;* �ek�n� na p�eru�en�
         xor       ax,ax
         int       16h                      ; vstup znaku z kl�vesnice
         cmp       al,27                    ; je <Esc> ?
         jne       cekej
                                          ;* je p�eru�en� operace
prerus:  mov       dx,offset parktxt4       ; hl��en� pro 1 pevny disk
         dec       byte ptr ds:[disku]      ; je 1 pevn� disk ?
         jz        prerus2                  ; je 1 pevn� disk
         mov       dx,offset parktxt5       ; hl��en� pro 2 pevn� disky
prerus2: call      outtxt                   ; hl��en� o zru�en� parkov�n�
         int       20h
; -----------------------------------------------------------------------------
getdisk:                                  ;* zji�t�n� parkovac� stopy
                                            ; VSTUP: DL=��slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; V�STUP: DX=parkovac� stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         mov       al,dl                    ; �schova ��sla disku
         les       bx,es:[bx]               ; adresa tabulky popisova�e
         mov       dx,es:[bx]               ; po�et v�lc� disku
         dec       dx                       ; ��slo posledn� stopy
         call      testat                   ; je po��ta� AT ?
         jc        getdisk2                 ; nen� po��ta� AT
         mov       dx,es:[bx+0ch]           ; parkovac� z�na pevn�ho disku
getdisk2:or        dx,dx                    ; je platn� stopa ?
         jnz       getdisk4                 ; je platn� stopa

         mov       dl,al                    ; ��slo disku
         mov       ah,8
         int       13h                      ; poskytnut� posledn� stopy
         jc        getdisk4                 ; nen� platn� disk
         xchg      ch,cl                    ; CL <- ni��� bajt ��sla stopy
         rol       ch,1
         rol       ch,1                     ; bity 8 a 9 ��sla stopy
         and       ch,3                     ; bity 8 a 9 ��sla stopy
         shr       dh,1
         shr       dh,1
         shr       dh,1
         shr       dh,1                     ; bity 10 a 11 ��sla stopy
         and       dh,0ch                   ; bity 10 a 11 ��sla stopy
         xor       dl,dl
         or        dx,cx                    ; DX = ��slo posledn� stopy
         inc       dx                       ; DX = ��slo parkovac� stopy

getdisk4:pop       es
         ret
; -----------------------------------------------------------------------------
park:                                     ;* zaparkov�n� jednoho pevn�ho disku
                                            ; VSTUP: DL=��slo disku
                                            ;        BX=��slo stopy

         or        bx,bx                    ; je disk zad�n ?
         jz        park2                    ; neplatn� disk
         push      dx
         xor       ax,ax
         int       13h                      ; reset disku
         pop       dx
         mov       cx,68                    ; po�et pokus� o parkov�n�
park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; ni��� bajt ��sla v�lce
         mov       cl,bh                    ; vy��� bajt ��sla v�lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bit� 6 a 7
         and       cl,0c0h                  ; ponech� bity 6 a 7 (= 8 a 9)
         inc       cl                       ; -> sektor 1
         mov       dh,bh                    ; vy��� bajt ��sla v�lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bit� 6 a 7
         and       dh,0c0h                  ; ponech� bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven� hlav
         int       13h                      ; vystaven� na parkovac� stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; nov� zaparkov�n� disku
park2:   ret
; -----------------------------------------------------------------------------
outtxt:                                   ;* zobrazen� textu
         push      ax
         push      dx
         mov       ah,9
         int       21h
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
testat:                                   ;* je po��ta� AT ?
                                            ; V�STUP: CY=nen� AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p��znak, �e nen� AT
testat2: pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
errtxt   db        'Neni nainstalovan zadny pevny disk !',13,10,'$'
parktxt1 db        '������ Pevny disk byl zaparkovan �����ͻ',13,10,'$'
parktxt2 db        '��� Oba pevne disky byly zaparkovany �ͻ',13,10,'$'
parktxt3 db        '� Nyni muzete pocitac vypnout. Stiskem �',13,10
         db        '� klavesy <Esc> se muzete vratit zpet. �',13,10
         db        '��������������������������������������ͼ',13,10,'$'
parktxt4 db        '*** Parkovani pevneho disku zruseno ***',13,10,'$'
parktxt5 db        '*** Parkovani pevnych disku zruseno ***',13,10,'$'

parkc0   dw        0                        ; parkovac� stopa disku 0
parkc1   dw        0                        ; parkovac� stopa disku 1

disku    db        0                        ; po�et pevn�ch disk�

copyrght db        13,10,'Parkov�n� pevn�ch disk�; (c) Miroslav N�me�ek',13,10

code     ENDS
         END       start

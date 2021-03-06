
; *****************************************************************************
;
;                   Zv��en� kapacity disket 360 KB
;
; *****************************************************************************

Code     SEGMENT
         ASSUME    cs:Code,ds:Code

; ------ zobrazen� �vodn�ho textu

Start:   push      cs
         pop       ds
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ nalezen� ozna�en� disku s disketou

         mov       si,81h                   ; za��tek p��kazov�ho ��dku
         xor       cx,cx
         mov       cl,es:[si-1]             ; po�et znak� p��kazov�ho ��dku
Start1:  jcxz      Start4                   ; nen� nic zad�no
         mov       al,es:[si]               ; na�ten� dal��ho znaku
         inc       si
         dec       cx                       ; sn��en� ��ta�e znak�
         cmp       al," "                   ; odd�lova� ?
         jbe       Start1                   ; je odd�lova�
         and       al,not 20h               ; p�evod na velk� p�smeno
         mov       ds:[TextDisk],al         ; disk

; ------ chyba zad�n� parametr�

         mov       dx,offset HelpTxt
         cmp       al,"A"
         jb        Start2
         cmp       al,"B"
         jbe       Start4
Start2:  mov       ah,9
         int       21h
Start3:  mov       ax,4c01h
         int       21h

; ------ zobrazen� v�zvy

Start4:  mov       dx,offset VyzvaTxt
         mov       ah,9
         int       21h                      ; zobrazen� v�zvy

; ------ �ek�n� na stisk kl�vesy

         mov       ax,0c08h
         int       21h                      ; vstup s vypr�zdn�n�m
         cmp       al,13
         jne       Start3                   ; p�eru�en� programu

; ------ zobrazen� v�zvy k �ek�n�

         mov       dx,offset CekTxt         ; v�zva k �ek�n�
         mov       ah,9
         int       21h

; ------ na�ten� p�vodn�ho BOOT sektoru

         call      GetBuff                  ; v�po�et adresy BOOT sektoru
         xor       bx,bx                    ; sektor 0
         call      Read                     ; na�ten� p�vodn�ho BOOT sektoru

; ------ kontrola, zda je to platn� disk 360 KB

         mov       dx,offset No360Txt       ; text - nen� 360 KB
         cmp       word ptr es:[0bh],200h   ; d�lka sektoru 512 bajt� ?
         jne       Start2                   ; neplatn� disketa
         cmp       word ptr es:[0eh],1      ; 1 rezerv. sektor ?
         jne       Start2                   ; neplatn� disketa
         cmp       byte ptr es:[10h],2      ; jsou 2 FAT ?
         jne       Start2                   ; neplatn� disketa
         cmp       word ptr es:[13h],720    ; spr�vn� po�et sektor� celkem ?
         jne       Start2                   ; neplatn� disketa
         cmp       byte ptr es:[15h],0fdh   ; spr�vn� popisova� m�dia ?
         jne       Start2                   ; neplatn� disketa



; ------ nastaven� nov�ho form�tu diskety

                                            ; 1 sektor ROOT
                                            ; 2*3 sektory FAT
                                            ; 3 sektory ROOT
                                            ; 710 datov�ch sektor�

         mov       byte ptr es:[0dh],1      ; velikost bloku - 1 sektor
         mov       word ptr es:[11h],30h    ; max. polo�ek ROOT = 48
         mov       byte ptr es:[16h],3      ; 3 sektory na FAT

; ------ z�pis BOOT sektoru op�t na disk

         xor       bx,bx                    ; sektor 0
         call      Write                    ; z�pis sektoru na disk

; ------ inicializace tabulky FAT - 1. sektor

         mov       word ptr es:[0],0fffdh   ; inicializa�n� slovo
         mov       byte ptr es:[2],0ffh     ;
         mov       cx,512-3
         mov       di,3
         xor       al,al
         cld
         rep       stosb                    ; vymaz�n� zbytku FAT

; ------ z�pis 1. sektoru tabulky FAT

         inc       bx                       ; 1. sektor 1. FAT
         call      Write                    ; z�pis 1. sektoru 1. FAT
         mov       bx,4                     ; 1. sektor 2. FAT
         call      Write                    ; z�pis 1. sektoru 2. FAT

; ------ z�pis ostatn�ch sektor� FAT

         mov       word ptr es:[0],0
         mov       byte ptr es:[2],0
         mov       bx,2                     ; 2. sektor 1. FAT
         call      Write                    ; z�pis 2. sektoru 1. FAT
         inc       bx                       ; 3. sektor 1. FAT
         call      Write                    ; z�pis 3. sektoru 1. FAT
         mov       bx,5                     ; 2. sektor 2. FAT

; ------ z�pis zbytku FAT a z�pis ROOT

         mov       cx,2+3                   ; 2 sektory FAT a 3 sektory ROOT
Start7:  call      Write                    ; z�pis sektoru
         inc       bx                       ; zv��en� ��sla sektoru
         loop      Start7                   ; z�pis dal��ho sektoru

; ------ reset diskov�ho syst�mu, konec programu

         mov       ah,0dh
         int       21h                      ; resetov�n� diskov�ho syst�mu
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;        poskytnut� adresy bufferu
; -----------------------------------------------------------------------------
; V�STUP: ES=segment s bufferem
; -----------------------------------------------------------------------------

GetBuff  PROC      NEAR

         push      ax
         mov       ax,cs
         add       ax,offset(Konec-Start+15)/16 ; segment za programem
         mov       es,ax
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1
         add       ax,400h
         jnc       GetBuff2
         mov       ax,es
         add       ax,40h
         mov       es,ax
GetBuff2:pop       ax
         ret

GetBuff  ENDP

; -----------------------------------------------------------------------------
;        z�pis sektoru na disk
; -----------------------------------------------------------------------------
; VSTUP: BX=��slo sektoru
; V�STUP:CY=chyba z�pisu
; -----------------------------------------------------------------------------

Write    PROC      NEAR

         push      ax
         mov       ah,3                     ; operace z�pisu na disk
         jmp       short Read2

Write    ENDP

; -----------------------------------------------------------------------------
;        �ten� sektoru z disku
; -----------------------------------------------------------------------------
; VSTUP: BX=��slo sektoru
;        ES=segment se sektorem
; V�STUP:CY=chyba �ten�
; -----------------------------------------------------------------------------

Read     PROC      NEAR

         push      ax
         mov       ah,2                     ; operace �ten� z disku

; ------ �schova registr�

Read2:   push      bx
         push      cx
         push      dx
         push      si

; ------ v�po�et parametr� disku

         push      ax
         mov       ax,bx                    ; ��slo sektoru
         xor       dx,dx
         mov       cx,9                     ; 9 sektor� na stopu
         div       cx                       ; v�po�et stopy a sektoru
         mov       cl,dl                    ; ��slo sektoru - 1
         inc       cl                       ; ��slo sektoru
         mov       ch,al                    ; ��slo stopy
         xor       dx,dx                    ; DX <- 0
         shr       ch,1                     ; ��slo v�lce
         adc       dh,0                     ; ��slo strany
         pop       ax
         mov       dl,ds:[TextDisk]         ; disk pro operaci
         sub       dl,"A"                   ; ��slo disku

; ------ z�pis sektoru na disk

         mov       si,3                     ; po�et pokus� o z�pis
         xor       bx,bx                    ; offset sektoru
Read3:   push      ax
         mov       al,1
         int       13h                      ; z�pis sektoru na disk
         pop       ax
         jnc       Read9                    ; operace OK

; ------ resetov�n� disku

         push      ax
         xor       ax,ax
         int       13h                      ; resetov�n� disku
         pop       ax
         dec       si                       ; sn��en� ��ta�e pokus�
         jnz       Read3                    ; dal�� pokus o z�pis

; ------ chyba operace

         add       sp,12                    ; zru�en� obsahu z�sobn�ku
         mov       dx,offset ReadErr
         cmp       ah,2
         je        Read8
         mov       dx,offset WritErr
Read8:   mov       ah,9
         int       21h                      ; zobrazen� textu chyby
         mov       ax,4c01h
         int       21h                      ; n�vrat z programu

; ------ n�vrat registr�

Read9:   pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Read     ENDP


; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'High360K V1.10 - zvyseni kapacity disket 360K; '
         db        '(c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        'Zadejte disk A: nebo B: !',13,10,'$'

VyzvaTxt db        'Varovani: veskera data na diskete v mechanice '
TextDisk db        'A:',13,10
         db        '          budou znicena (<Enter>=pokracovani) !',13,10,'$'

ReadErr  db        'Chyba cteni z diskety !',13,10,'$'
WritErr  db        'Chyba zapisu na disketu !',13,10,'$'

CekTxt   db        'Cekejte ...',13,'$'

No360Txt db        'Neni disketa s formatem 360 KB !',13,10,'$'

Konec    label     near                     ; konec programu

Buff     db        0f000h dup(?)            ; rezerva pro buffery

Code     ENDS

zasob    segment   stack
         dw        1000h dup(?)
zasob    ends

         END       Start

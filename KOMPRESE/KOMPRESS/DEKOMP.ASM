
; *****************************************************************************
;                                Dekomprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhov�ho bufferu
matchlim equ       18                       ; maxim�ln� d�lka shody
threshld equ       2                        ; minim�ln� d�lka shody

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:
         jmp       komp1                    ; skok na start programu

         dw        offset konec             ; konec programu

komp1:                                    ;* vstupn� souboru
         mov       di,offset commbuf        ; buffer p��kazov�ho ��dku
         call      parnorm                  ; normalizace zadan�ch parametr�
         jc        chyba                    ; nen� ��dn� parametr
         mov       si,offset commbuf        ; buffer p��kazov�ho ��dku
         xor       cx,cx                    ; ��slo parametru = 0
         call      parget                   ; poskytnut� adresy parametru 0
         jc        chyba                    ; nen� prvn� parametr
         mov       dx,si                    ; specifikace vstupn�ho souboru
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax
                                          ;* v�stupn� soubor
         mov       si,offset commbuf        ; buffer p��kazov�ho ��dku
         mov       cx,1                     ; ��slo parametru = 1
         call      parget                   ; poskytnut� adresy parametru 1
         jc        chyba                    ; nen� druh� parametr
         mov       dx,si                    ; druh� parametr
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax

         call      dekode                   ; rozk�dov�n� souboru LZSS


navrat:  call      writefbuf                ; vypr�zdn�n� v�stupn�ho bufferu
         mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;                      Dek�dov�n� LZSS - kruhov� buffer
; -----------------------------------------------------------------------------
public   dekode
dekode:                                   ;* dek�dov�n� spakovan�ho souboru

                                          ;* inicializace
         cld                                ; sm�r dol�
         mov       di,offset textbuf        ; kruhov� buffer
         mov       cx,buffsize              ; velikost kruhov�ho bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; vymaz�n� kruhov�ho bufferu

         mov       di,offset(textbuf+buffsize-matchlim) ; adresa ke �ten� dat
         xor       dx,dx                    ; p��znaky

dekode1: shr       dx,1                     ; rotace p��znak�
                                          ;* na�ten� identifika�n� masky
         test      dx,100h                  ; jsou je�t� n�jak� data ?
         jnz       dekode3                  ; jsou je�t� data
         call      rbyte                    ; �ten� bajtu dat
         jbe       dekodex                  ; je konec souboru
         mov       dh,0ffh                  ; p��znaky
         mov       dl,al                    ; maska p��znak�
dekode3:                                  ;* jsou komprimovan� data
         test      dl,1                     ; jsou komprimovan� data ?
         jnz       dekode7                  ; nejsou komprim. data
         call      rbyte                    ; na�ten� prvn�ho bajtu
         jbe       dekodex                  ; je konec souboru
         mov       bl,al                    ; ni��� bajt adresy
         call      rbyte                    ; na�ten� druh�ho bajtu adresy
         jbe       dekodex                  ; konec souboru
         mov       bh,al                    ; vy��� bajt adresy
         mov       cl,4
         shr       bh,cl                    ; BX=pozice v bufferu
         and       al,0fh                   ; d�lka shody v bufferu
         add       al,threshld +1           ; minim�ln� d�lka
         xor       cx,cx
         mov       cl,al                    ; d�lka dat
dekode4: mov       al,ds:[bx+textbuf]       ; znak z bufferu
         inc       bx                       ; zv��en� adresy v bufferu
         cmp       bx,buffsize
         jb        dekode6
         sub       bx,buffsize
dekode6: call      wbyte                    ; z�pis bajtu do souboru
         stosb                              ; ulo�en� bajtu do souboru
         cmp       di,offset(textbuf+buffsize) ; je konec bufferu ?
         jb        dekode5
         sub       di,buffsize
dekode5: loop      dekode4                  ; dal�� znak
         jmp       short dekode1

dekode7:                                  ;* nejsou komprimovan� data
         call      rbyte                    ; �ten� bajtu dat
         mov       cx,1
         ja        dekode6                  ; z�pis bajtu

dekodex: ret

; -----------------------------------------------------------------------------
;                       Rozbor p��kazov�ho ��dku
; -----------------------------------------------------------------------------
public   parnorm
parnorm:                                  ;* normalizace zadan�ch parametr�
                                            ; VSTUP: ES:DI=ukl�dac� adresa
                                            ;        DS=segment PSP
                                            ; V�STUP: CX=po�et parametr�
                                            ;         ZY=nen� ��dn� parametr

         push      ax
         push      si
         push      di
         cld                                ; sm�r nahoru
         xor       cx,cx                    ; ��ta� parametr�
         mov       si,81h                   ; za��tek parametr�
         push      si
         add       si,ds:[si-1]             ; konec parametr�
         and       si,0ffh                  ; adresa konce textu
         mov       byte ptr ds:[si],0       ; ozna�en� konce textu
         pop       si
                                          ;* nalezen� za��tku parametru
parnorm1:call      parread                  ; na�ten� znaku parametr�
         jc        parnorm2                 ; je konec textu
         jz        parnorm1                 ; je odd�lova� - dal�� znak
         inc       cx                       ; zv��en� ��ta�e parametr�
parnorm3:                                 ;* p�enesen� textu
         stosb                              ; ulo�en� platn�ho znaku
         call      parread                  ; na�ten� dal��ho znaku
         ja        parnorm3                 ; je platn� znak - dal�� znak
         xor       al,al                    ; ukon�ovac� znak
         stosb                              ; ozna�en� konce textu
         jmp       short parnorm1           ; dal�� parametr

parnorm2:xor       al,al                    ; koncov� bajt parametr�
         stosb                              ; ozna�en� konce parametr�
         or        cx,cx                    ; je n�jak� parametr ?
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parget
parget:                                   ;* poskytnut� adresy parametru
                                            ; VSTUP: CX=��slo parametru
                                            ;        DS:SI=adresa bufferu
                                            ; V�STUP: DS:SI=adresa parametru
                                            ;         CY=neplatn� parametr
         push      ax
         push      cx
parget1:                                  ;* nalezen� za��tku dal��ho parametru
         cmp       byte ptr ds:[si],0       ; je platn� parametr ?
         stc                                ; p��znak - nen� dal�� parametr
         je        parget3                  ; nen� dal�� parametr
         clc
         jcxz      parget3                  ; nalezen parametr
parget2: lodsb                              ; na�ten� dal��ho znaku
         or        al,al
         jnz       parget2
         dec       cx
         jmp       short parget1            ; dal�� parametr
parget3:
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parrozb
parrozb:                                  ;* rozbor zad�n� souboru
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        ES:DI=adresa rozboru
                                            ;           1 B: jm�no disku
                                            ;           1 B: odd�lova� ":"
                                            ;          64 B: cesta ASCIIZ
                                            ;          13 B: jm�no soub. ASCIIZ
         push      ax
         push      si
         push      di
parrozb1:call      parread                  ; �ten� znaku textu
         jc        parrozb3                 ; konec textu





parrozb3:
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
parread:                                  ;* �ten� bajtu z p��kaz. ��dku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ; V�STUP: AL=znak
                                            ;         CY=nen� dal�� znak
                                            ;         ZY=je odd�lova�

         mov       al,ds:[si]               ; znak
         or        al,al
         jz        parread1                 ; je konec textu
         cmp       al,13
         je        parread1                 ; konec textu
         inc       si                       ; zv��en� adresy
         cmp       al,9                     ; je tabel�tor ?
         je        parread2                 ; je tabel�tor
         cmp       al," "                   ; je mezera ?
         je        parread2                 ; je mezera
         stc                                ; p��znak - znak OK
parread1:cmc
parread2:ret
; -----------------------------------------------------------------------------
;                              Diskov� operace
; -----------------------------------------------------------------------------
public   wbyte
wbyte:                                    ;* z�pis bajtu do v�stupn�ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; po�et bajt� ve v�stupn�m bufferu
         cmp       bx,1000h-1               ; je ji� konec bufferu ?
         jb        writefb3                 ; nen� je�t� konec bufferu
         call      writefbuf                ; z�pis bufferu do souboru
         jc        writefb4                 ; chyba z�pisu
writefb3:mov       bx,ds:[outnum]           ; ukazatel konce dat v bufferu
         mov       ds:[bx+outbuf],al        ; ulo�en� bajtu do bufferu
         inc       bx                       ; zv��en� ukl�dac� adresy
         mov       ds:[outnum],bx           ; nov� po�et bajt� v bufferu


         clc
writefb4:pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   writefbuf
writefbuf:                                ;* z�pis bufferu do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       cx,ds:[outnum]           ; po�et bajt� v souboru
         or        cx,cx                    ; p��znak operace OK
         jz        writefb2                 ; v bufferu nen� ��dn� bajt
         mov       bx,ds:[outid]            ; identifik�tor v�stupn�ho souboru
         mov       dx,offset outbuf         ; v�stupn� buffer
         mov       ah,40h
         int       21h                      ; z�pis dat do souboru
         jc        writefb2                 ; chyba z�pisu
         cmp       ax,cx                    ; souhlas� po�et zapsan�ch bajt� ?
writefb2:mov       word ptr ds:[outnum],0   ; vynulov�n� v�stupn�ho bufferu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   rbyte
rbyte:                                    ;* �ten� bajtu ze souboru
                                            ; V�STUP: CY=chyba operace �ten�
                                            ;         ZY=je konec souboru
                                            ;         AL=na�ten� znak

         push      bx
         mov       al,27
         mov       bx,ds:[inpuk]            ; ukazatel �ten�ch dat
         inc       bx                       ; zv��en� ukazatele �ten�ch dat
         mov       ds:[inpuk],bx
         cmp       ds:[inpnum],bx           ; je ji� konec dat ?
         ja        readfb2                  ; nen� je�t� konec dat v bufferu
         call      readfbuf                 ; na�ten� dal��ho bloku dat
         mov       al,27
         jbe       readfb3                  ; chyba �ten� nebo konec souboru
readfb2: mov       bx,ds:[inpuk]            ; ukazatel �ten�ch dat
         mov       al,ds:[bx+inpbuf]        ; bajt z bufferu
readfb3:
;         pushf
;         dec       byte ptr ds:[citac]
;         jnz       zobrfb5
;         push      ax
;         push      dx
;         mov       dl,"."
;         mov       ah,2
;         int       21h
;         pop       dx
;         pop       ax
;zobrfb5: popf

         pop       bx
         ret
; -----------------------------------------------------------------------------
public   readfbuf
readfbuf:                                 ;* na�ten� bufferu vstupn�ho souboru
                                            ; V�STUP: CY=chyba operace �ten�
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov�n� vstupn�ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov�n� ukazatele �ten�ch dat
         mov       cx,1000h                 ; d�lka vstupn�ho bufferu
         mov       bx,ds:[inpid]            ; identifik�tor vstupn�ho souboru
         mov       dx,offset inpbuf         ; vstupn� buffer
         mov       ah,3fh
         int       21h                      ; na�ten� dat ze souboru
         jc        readfbf2                 ; je chyba �ten�
         mov       ds:[inpnum],ax           ; ulo�en� po�tu na�ten�ch dat
         or        ax,ax                    ; nastaven� p��znaku ZF

readfbf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
;                                 Data
; -----------------------------------------------------------------------------
public   inpid,outid,inpnum,inpuk,outnum

errtxt   db        'Dekomprese metodou LZSS;  (c) Miroslav Nemecek',13,10
         db        'Zadejte: DEKOMP vstupni_soubor vystupni_soubor',13,10,'$'

inpid    dw        0                        ; identifik�tor vstupn�ho souboru
outid    dw        0                        ; identifik�tor v�stupn�ho souboru

inpnum   dw        0                        ; po�et bajt� ve vstupn�m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn�m souboru
outnum   dw        0                        ; po�et bajt� ve v�stupn�m souboru

konec    label     near                     ; konec programu

; ----------------------------- buffery dat -----------------------------------

public   inpbuf,outbuf,textbuf

commbuf  db        128 dup(?)               ; buffer p��kazov�ho ��dku
inpbuf   db        1000h dup(?)              ; buffer vstupn�ho souboru
outbuf   db        1000h dup(?)              ; buffer v�stupn�ho souboru

textbuf  db        buffsize dup(?)          ; kruhov� buffer

code     ENDS
         END       komp

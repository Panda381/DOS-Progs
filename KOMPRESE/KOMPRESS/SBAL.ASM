
; *****************************************************************************
;                                  Komprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhov�ho bufferu
matchlim equ       18                       ; maxim�ln� d�lka shody
threshld equ       2                        ; minim�ln� d�lka shody

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:

         mov       dx,offset soubori
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax

         mov       dx,offset souboro
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax


         call      kode                     ; zak�dov�n� souboru LZSS



navrat:  call      writefbuf                ; vypr�zdn�n� v�stupn�ho bufferu

chyba:
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;                      K�dov�n� LZSS - kruhov� buffer
; -----------------------------------------------------------------------------
kode:                                     ;* zak�dov�n� jednoho souboru


         mov       cx,matchlim              ; max. d�lka �et�zce
         mov       di,offset(textbuf+buffsize-matchlim) ; adresa p�ed koncem
         mov       si,di
         mov       bx,di                    ; adresa textu

kode2:   call      rbyte                    ; �ten� bajtu
         jbe       kode3                    ; konec souboru
         stosb
         loop      kode2                    ; dal�� bajt
kode3:                                   ;* za��tek zak�dov�n� textu
         mov       di,offset codebuf +1     ; buffer k�du
         mov       dl,1                     ; d�lka shody
         mov       dh,1                     ; maska
kode4:                                    ;* je nezkompresovan� bajt
         cmp       dl,threshld              ; je minim�ln� d�lka shody ?
         ja        kode5                    ; nedostate�n� d�lka
         mov       dl,1                     ; d�lka shody = 1
         or        byte ptr ds:[codebuf],dh ; maska - norm�ln� bajt
         mov       al,ds:[si]               ; ukl�dan� bajt
         stosb                              ; ulo�en� do bufferu k�du
         jmp       short kode7
kode5:                                    ;* je komprese dat
         mov       ax,bx                    ; shodn� �et�zec
         sub       ax,offset textbuf        ; offset v text. buffeu
         stosb                              ; ulo�en� ni���ho bajtu offsetu
         mov       cl,4
         shl       ah,cl
         mov       al,dl                    ; d�lka shody
         sub       al,threshld+1
         or        al,ah
         stosb                              ; ulo�en� vy���ho bajtu
kode7:                                    ;* vypr�zdn�n� bufferu
         shl       dh,1                     ; rotace masky o bit vlevo
         or        dh,dh                    ; je ji� maska = 0 ?
         jnz       kode9                    ; maska nen� je�t� = 0
         push      si
         mov       cx,di                    ; adresa konce dat v bufferu
         mov       si,offset codebuf        ; za��tek bufferu k�du
         sub       cx,si                    ; po�et bajt� k z�pisu
kode8:   lodsb                              ; bajt k z�pisu
         call      wbyte                    ; z�pis bajtu do souboru
         loop      kode8                    ; z�pis dal��ho bajtu
         pop       si
         mov       di,offset codebuf+1
         mov       byte ptr ds:[di-1],0     ; zru�en� masky
         mov       dh,1                     ; maska

kode9:                                    ;* na�ten� dal��ch dat
         xor       cx,cx
         mov       cl,dl                    ; po�et zapsan�ch bajt�
kodea:   call      rbyte                    ; �ten� dal��ho bajtu
         jbe       kodee                    ; konec dat
         mov       ds:[si+matchlim],al      ; ulo�en� na�ten�ho znaku
         cmp       si,offset textbuf+buffsize-matchlim ; bude duplikace ?
         jb        kodeb                    ; nebude duplikace
         mov       ds:[si-buffsize+matchlim],al; duplikace dat
kodeb:   inc       si
         cmp       si,offset textbuf+buffsize ; je za koncem ?
         jb        kodec                    ; nen� za koncem
         sub       si,buffsize              ; posun na za��tek
kodec:   loop      kodea                    ; na�ten� dal��ho znaku
kodee:   cmp       cl,dl                    ; byl n�jak� znak ?
         je        kodef                    ; je ji� konec dat

         mov       ah,1
         int       16h
         jnz       kodef

         call      hledkod                  ; nalezen� k�du
         jmp       kode4


kodef:
         ret


hledkod:                                  ;* hled�n� shodn�ho �et�zce
                                            ; VSTUP: SI=hledan� �et�zec
                                            ; V�STUP: BX=shodn� �et�zec
                                            ;         DL=d�lka �et�zce
                                            ;         CY=�et�zec nenalezen
         push      ax
         push      cx
         push      si
         push      di
         cld
         xor       dl,dl                    ; d�lka �et�zce = 0
         mov       al,ds:[si]               ; prvn� hledan� znak
                                          ;* hled�n� v ��sti p�ed textem
         mov       di,offset textbuf        ; za��tek textov�ho bufferu
         mov       cx,si                    ; adresa hledan�ho �et�zce
         sub       cx,di                    ; po�et bajt� p�ed �et�zcem
hledk1:  jcxz      hledk3                   ; nen� dal�� bajt
         repne     scasb                    ; pokus o nalezen� �et�zce
         jne       hledk3                   ; znak nenalezen
         call      compkod                  ; porovn�n� �et�zc�
         jmp       short hledk1             ; nalezen� dal��ho znaku

hledk3:                                   ;* hled�n� v ��sti za textem
         lea       di,[si+matchlim]         ; adresa za hledan�m �et�zcem
         mov       cx,offset(textbuf+buffsize) ; adresa konce bufferu
         sub       cx,di                    ; po�et bajt� do konce bufferu
hledk4:  jcxz      hledk5                   ; nen� dal�� bajt
         repne     scasb                    ; pokus o nalezen� �et�zce
         jne       hledk3                   ; znak nenalezen
         call      compkod                  ; porovn�n� �et�zc�
         jmp       short hledk4             ; nalezen� dal��ho znaku
hledk5:  or        dl,dl                    ; d�lka nalezen� shody
         jnz       hledk6                   ; nalezen �et�zec
         stc                                ; p��znak - �et�zec nenalezen
hledk6:
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

compkod:                                  ;* porovn�n� hledan�ho �et�zce
                                            ; VSTUP: SI=hledan� �et�zec
                                            ;        DI=porovn�van� adresa
                                            ;        DL=d�lka shody �et�zce
                                            ; V�STUP: DL=d�lka shody
                                            ;         BX=adresa shodn�ho �et.
         push      ax
         push      si
         push      di
         push      cx
         mov       cx,matchlim              ; max. d�lka pro porovn�n�
         mov       al,cl
         cld
         repe      cmpsb                    ; porovn�n� �et�zc�
         sub       al,cl                    ; po�et shodn�ch bajt�
         cmp       al,dl                    ; je to del�� �et�zec ?
         jbe       compkod2                 ; nen� to del�� �et�zec
         mov       dl,al                    ; d�lka nov�ho �et�zce
compkod2:pop       cx
         pop       di
         pop       si
         pop       ax
         jbe       compkod3                 ; nen� nov� �et�zec
         mov       bx,di                    ; adresa nov�ho �et�zce
compkod3:ret

; -----------------------------------------------------------------------------
;                              Diskov� operace
; -----------------------------------------------------------------------------
wbyte:                                    ;* z�pis bajtu do v�stupn�ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; po�et bajt� ve v�stupn�m bufferu
         cmp       bx,4095                  ; je ji� konec bufferu ?
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
readfb3: pop       bx
         ret
; -----------------------------------------------------------------------------
readfbuf:                                 ;* na�ten� bufferu vstupn�ho souboru
                                            ; V�STUP: CY=chyba operace �ten�
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov�n� vstupn�ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov�n� ukazatele �ten�ch dat
         mov       cx,4096                  ; d�lka vstupn�ho bufferu
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
soubori  db        'KOMPTEST.TXT',0
souboro  db        'KOMPTEST.PAK',0

inpid    dw        0                        ; identifik�tor vstupn�ho souboru
outid    dw        0                        ; identifik�tor v�stupn�ho souboru

inpnum   dw        0                        ; po�et bajt� ve vstupn�m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn�m souboru
outnum   dw        0                        ; po�et bajt� ve v�stupn�m souboru

; ----------------------------- buffery dat -----------------------------------

codebuf  db        17 dup(?)                ; buffer k�d�
inpbuf   db        4096 dup(?)              ; buffer vstupn�ho souboru
outbuf   db        4096 dup(?)              ; buffer v�stupn�ho souboru
textbuf  db        buffsize + matchlim dup(?) ; kruhov� buffer

code     ENDS
         END       komp

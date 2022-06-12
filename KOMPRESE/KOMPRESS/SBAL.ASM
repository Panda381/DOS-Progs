
; *****************************************************************************
;                                  Komprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhovÇho bufferu
matchlim equ       18                       ; maxim†ln° dÇlka shody
threshld equ       2                        ; minim†ln° dÇlka shody

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


         call      kode                     ; zak¢dov†n° souboru LZSS



navrat:  call      writefbuf                ; vypr†zdnàn° vòstupn°ho bufferu

chyba:
         mov       ax,4c00h
         int       21h

; -----------------------------------------------------------------------------
;                      K¢dov†n° LZSS - kruhovò buffer
; -----------------------------------------------------------------------------
kode:                                     ;* zak¢dov†n° jednoho souboru


         mov       cx,matchlim              ; max. dÇlka ©etàzce
         mov       di,offset(textbuf+buffsize-matchlim) ; adresa p©ed koncem
         mov       si,di
         mov       bx,di                    ; adresa textu

kode2:   call      rbyte                    ; áten° bajtu
         jbe       kode3                    ; konec souboru
         stosb
         loop      kode2                    ; dal®° bajt
kode3:                                   ;* zaá†tek zak¢dov†n° textu
         mov       di,offset codebuf +1     ; buffer k¢du
         mov       dl,1                     ; dÇlka shody
         mov       dh,1                     ; maska
kode4:                                    ;* je nezkompresovanò bajt
         cmp       dl,threshld              ; je minim†ln° dÇlka shody ?
         ja        kode5                    ; nedostateán† dÇlka
         mov       dl,1                     ; dÇlka shody = 1
         or        byte ptr ds:[codebuf],dh ; maska - norm†ln° bajt
         mov       al,ds:[si]               ; ukl†danò bajt
         stosb                              ; uloëen° do bufferu k¢du
         jmp       short kode7
kode5:                                    ;* je komprese dat
         mov       ax,bx                    ; shodnò ©etàzec
         sub       ax,offset textbuf        ; offset v text. buffeu
         stosb                              ; uloëen° nië®°ho bajtu offsetu
         mov       cl,4
         shl       ah,cl
         mov       al,dl                    ; dÇlka shody
         sub       al,threshld+1
         or        al,ah
         stosb                              ; uloëen° vy®®°ho bajtu
kode7:                                    ;* vypr†zdnàn° bufferu
         shl       dh,1                     ; rotace masky o bit vlevo
         or        dh,dh                    ; je jië maska = 0 ?
         jnz       kode9                    ; maska nen° je®tà = 0
         push      si
         mov       cx,di                    ; adresa konce dat v bufferu
         mov       si,offset codebuf        ; zaá†tek bufferu k¢du
         sub       cx,si                    ; poáet bajtñ k z†pisu
kode8:   lodsb                              ; bajt k z†pisu
         call      wbyte                    ; z†pis bajtu do souboru
         loop      kode8                    ; z†pis dal®°ho bajtu
         pop       si
         mov       di,offset codebuf+1
         mov       byte ptr ds:[di-1],0     ; zru®en° masky
         mov       dh,1                     ; maska

kode9:                                    ;* naáten° dal®°ch dat
         xor       cx,cx
         mov       cl,dl                    ; poáet zapsanòch bajtñ
kodea:   call      rbyte                    ; áten° dal®°ho bajtu
         jbe       kodee                    ; konec dat
         mov       ds:[si+matchlim],al      ; uloëen° naátenÇho znaku
         cmp       si,offset textbuf+buffsize-matchlim ; bude duplikace ?
         jb        kodeb                    ; nebude duplikace
         mov       ds:[si-buffsize+matchlim],al; duplikace dat
kodeb:   inc       si
         cmp       si,offset textbuf+buffsize ; je za koncem ?
         jb        kodec                    ; nen° za koncem
         sub       si,buffsize              ; posun na zaá†tek
kodec:   loop      kodea                    ; naáten° dal®°ho znaku
kodee:   cmp       cl,dl                    ; byl nàjakò znak ?
         je        kodef                    ; je jië konec dat

         mov       ah,1
         int       16h
         jnz       kodef

         call      hledkod                  ; nalezen° k¢du
         jmp       kode4


kodef:
         ret


hledkod:                                  ;* hled†n° shodnÇho ©etàzce
                                            ; VSTUP: SI=hledanò ©etàzec
                                            ; VùSTUP: BX=shodnò ©etàzec
                                            ;         DL=dÇlka ©etàzce
                                            ;         CY=©etàzec nenalezen
         push      ax
         push      cx
         push      si
         push      di
         cld
         xor       dl,dl                    ; dÇlka ©etàzce = 0
         mov       al,ds:[si]               ; prvn° hledanò znak
                                          ;* hled†n° v á†sti p©ed textem
         mov       di,offset textbuf        ; zaá†tek textovÇho bufferu
         mov       cx,si                    ; adresa hledanÇho ©etàzce
         sub       cx,di                    ; poáet bajtñ p©ed ©etàzcem
hledk1:  jcxz      hledk3                   ; nen° dal®° bajt
         repne     scasb                    ; pokus o nalezen° ©etàzce
         jne       hledk3                   ; znak nenalezen
         call      compkod                  ; porovn†n° ©etàzcñ
         jmp       short hledk1             ; nalezen° dal®°ho znaku

hledk3:                                   ;* hled†n° v á†sti za textem
         lea       di,[si+matchlim]         ; adresa za hledanòm ©etàzcem
         mov       cx,offset(textbuf+buffsize) ; adresa konce bufferu
         sub       cx,di                    ; poáet bajtñ do konce bufferu
hledk4:  jcxz      hledk5                   ; nen° dal®° bajt
         repne     scasb                    ; pokus o nalezen° ©etàzce
         jne       hledk3                   ; znak nenalezen
         call      compkod                  ; porovn†n° ©etàzcñ
         jmp       short hledk4             ; nalezen° dal®°ho znaku
hledk5:  or        dl,dl                    ; dÇlka nalezenÇ shody
         jnz       hledk6                   ; nalezen ©etàzec
         stc                                ; p©°znak - ©etàzec nenalezen
hledk6:
         pop       di
         pop       si
         pop       cx
         pop       ax
         ret

compkod:                                  ;* porovn†n° hledanÇho ©etàzce
                                            ; VSTUP: SI=hledanò ©etàzec
                                            ;        DI=porovn†van† adresa
                                            ;        DL=dÇlka shody ©etàzce
                                            ; VùSTUP: DL=dÇlka shody
                                            ;         BX=adresa shodnÇho ©et.
         push      ax
         push      si
         push      di
         push      cx
         mov       cx,matchlim              ; max. dÇlka pro porovn†n°
         mov       al,cl
         cld
         repe      cmpsb                    ; porovn†n° ©etàzcñ
         sub       al,cl                    ; poáet shodnòch bajtñ
         cmp       al,dl                    ; je to del®° ©etàzec ?
         jbe       compkod2                 ; nen° to del®° ©etàzec
         mov       dl,al                    ; dÇlka novÇho ©etàzce
compkod2:pop       cx
         pop       di
         pop       si
         pop       ax
         jbe       compkod3                 ; nen° novò ©etàzec
         mov       bx,di                    ; adresa novÇho ©etàzce
compkod3:ret

; -----------------------------------------------------------------------------
;                              DiskovÇ operace
; -----------------------------------------------------------------------------
wbyte:                                    ;* z†pis bajtu do vòstupn°ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; poáet bajtñ ve vòstupn°m bufferu
         cmp       bx,4095                  ; je jië konec bufferu ?
         jb        writefb3                 ; nen° je®tà konec bufferu
         call      writefbuf                ; z†pis bufferu do souboru
         jc        writefb4                 ; chyba z†pisu
writefb3:mov       bx,ds:[outnum]           ; ukazatel konce dat v bufferu
         mov       ds:[bx+outbuf],al        ; uloëen° bajtu do bufferu
         inc       bx                       ; zvò®en° ukl†dac° adresy
         mov       ds:[outnum],bx           ; novò poáet bajtñ v bufferu
         clc
writefb4:pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
writefbuf:                                ;* z†pis bufferu do souboru
         push      ax
         push      bx
         push      cx
         push      dx
         mov       cx,ds:[outnum]           ; poáet bajtñ v souboru
         or        cx,cx                    ; p©°znak operace OK
         jz        writefb2                 ; v bufferu nen° ë†dnò bajt
         mov       bx,ds:[outid]            ; identifik†tor vòstupn°ho souboru
         mov       dx,offset outbuf         ; vòstupn° buffer
         mov       ah,40h
         int       21h                      ; z†pis dat do souboru
         jc        writefb2                 ; chyba z†pisu
         cmp       ax,cx                    ; souhlas° poáet zapsanòch bajtñ ?
writefb2:mov       word ptr ds:[outnum],0   ; vynulov†n° vòstupn°ho bufferu
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret
; -----------------------------------------------------------------------------
rbyte:                                    ;* áten° bajtu ze souboru
                                            ; VùSTUP: CY=chyba operace áten°
                                            ;         ZY=je konec souboru
                                            ;         AL=naátenò znak

         push      bx
         mov       al,27
         mov       bx,ds:[inpuk]            ; ukazatel átenòch dat
         inc       bx                       ; zvò®en° ukazatele átenòch dat
         mov       ds:[inpuk],bx
         cmp       ds:[inpnum],bx           ; je jië konec dat ?
         ja        readfb2                  ; nen° je®tà konec dat v bufferu
         call      readfbuf                 ; naáten° dal®°ho bloku dat
         mov       al,27
         jbe       readfb3                  ; chyba áten° nebo konec souboru
readfb2: mov       bx,ds:[inpuk]            ; ukazatel átenòch dat
         mov       al,ds:[bx+inpbuf]        ; bajt z bufferu
readfb3: pop       bx
         ret
; -----------------------------------------------------------------------------
readfbuf:                                 ;* naáten° bufferu vstupn°ho souboru
                                            ; VùSTUP: CY=chyba operace áten°
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov†n° vstupn°ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov†n° ukazatele átenòch dat
         mov       cx,4096                  ; dÇlka vstupn°ho bufferu
         mov       bx,ds:[inpid]            ; identifik†tor vstupn°ho souboru
         mov       dx,offset inpbuf         ; vstupn° buffer
         mov       ah,3fh
         int       21h                      ; naáten° dat ze souboru
         jc        readfbf2                 ; je chyba áten°
         mov       ds:[inpnum],ax           ; uloëen° poátu naátenòch dat
         or        ax,ax                    ; nastaven° p©°znaku ZF

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

inpid    dw        0                        ; identifik†tor vstupn°ho souboru
outid    dw        0                        ; identifik†tor vòstupn°ho souboru

inpnum   dw        0                        ; poáet bajtñ ve vstupn°m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn°m souboru
outnum   dw        0                        ; poáet bajtñ ve vòstupn°m souboru

; ----------------------------- buffery dat -----------------------------------

codebuf  db        17 dup(?)                ; buffer k¢dñ
inpbuf   db        4096 dup(?)              ; buffer vstupn°ho souboru
outbuf   db        4096 dup(?)              ; buffer vòstupn°ho souboru
textbuf  db        buffsize + matchlim dup(?) ; kruhovò buffer

code     ENDS
         END       komp

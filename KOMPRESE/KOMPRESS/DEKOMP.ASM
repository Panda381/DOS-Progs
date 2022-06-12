
; *****************************************************************************
;                                Dekomprese dat
; *****************************************************************************

buffsize equ       4096                     ; velikost kruhovÇho bufferu
matchlim equ       18                       ; maxim†ln° dÇlka shody
threshld equ       2                        ; minim†ln° dÇlka shody

code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
komp:
         jmp       komp1                    ; skok na start programu

         dw        offset konec             ; konec programu

komp1:                                    ;* vstupn° souboru
         mov       di,offset commbuf        ; buffer p©°kazovÇho ©†dku
         call      parnorm                  ; normalizace zadanòch parametrñ
         jc        chyba                    ; nen° ë†dnò parametr
         mov       si,offset commbuf        ; buffer p©°kazovÇho ©†dku
         xor       cx,cx                    ; á°slo parametru = 0
         call      parget                   ; poskytnut° adresy parametru 0
         jc        chyba                    ; nen° prvn° parametr
         mov       dx,si                    ; specifikace vstupn°ho souboru
         mov       ax,3d00h
         int       21h
         jc        chyba
         mov       ds:[inpid],ax
                                          ;* vòstupn° soubor
         mov       si,offset commbuf        ; buffer p©°kazovÇho ©†dku
         mov       cx,1                     ; á°slo parametru = 1
         call      parget                   ; poskytnut° adresy parametru 1
         jc        chyba                    ; nen° druhò parametr
         mov       dx,si                    ; druhò parametr
         mov       ah,3ch
         xor       cx,cx
         int       21h
         jc        chyba
         mov       ds:[outid],ax

         call      dekode                   ; rozk¢dov†n° souboru LZSS


navrat:  call      writefbuf                ; vypr†zdnàn° vòstupn°ho bufferu
         mov       ax,4c00h
         int       21h

chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;                      Dek¢dov†n° LZSS - kruhovò buffer
; -----------------------------------------------------------------------------
public   dekode
dekode:                                   ;* dek¢dov†n° spakovanÇho souboru

                                          ;* inicializace
         cld                                ; smàr dolñ
         mov       di,offset textbuf        ; kruhovò buffer
         mov       cx,buffsize              ; velikost kruhovÇho bufferu
         mov       al," "                   ; znak mezery
         rep       stosb                    ; vymaz†n° kruhovÇho bufferu

         mov       di,offset(textbuf+buffsize-matchlim) ; adresa ke áten° dat
         xor       dx,dx                    ; p©°znaky

dekode1: shr       dx,1                     ; rotace p©°znakñ
                                          ;* naáten° identifikaán° masky
         test      dx,100h                  ; jsou je®tà nàjak† data ?
         jnz       dekode3                  ; jsou je®tà data
         call      rbyte                    ; áten° bajtu dat
         jbe       dekodex                  ; je konec souboru
         mov       dh,0ffh                  ; p©°znaky
         mov       dl,al                    ; maska p©°znakñ
dekode3:                                  ;* jsou komprimovan† data
         test      dl,1                     ; jsou komprimovan† data ?
         jnz       dekode7                  ; nejsou komprim. data
         call      rbyte                    ; naáten° prvn°ho bajtu
         jbe       dekodex                  ; je konec souboru
         mov       bl,al                    ; nië®° bajt adresy
         call      rbyte                    ; naáten° druhÇho bajtu adresy
         jbe       dekodex                  ; konec souboru
         mov       bh,al                    ; vy®®° bajt adresy
         mov       cl,4
         shr       bh,cl                    ; BX=pozice v bufferu
         and       al,0fh                   ; dÇlka shody v bufferu
         add       al,threshld +1           ; minim†ln° dÇlka
         xor       cx,cx
         mov       cl,al                    ; dÇlka dat
dekode4: mov       al,ds:[bx+textbuf]       ; znak z bufferu
         inc       bx                       ; zvò®en° adresy v bufferu
         cmp       bx,buffsize
         jb        dekode6
         sub       bx,buffsize
dekode6: call      wbyte                    ; z†pis bajtu do souboru
         stosb                              ; uloëen° bajtu do souboru
         cmp       di,offset(textbuf+buffsize) ; je konec bufferu ?
         jb        dekode5
         sub       di,buffsize
dekode5: loop      dekode4                  ; dal®° znak
         jmp       short dekode1

dekode7:                                  ;* nejsou komprimovan† data
         call      rbyte                    ; áten° bajtu dat
         mov       cx,1
         ja        dekode6                  ; z†pis bajtu

dekodex: ret

; -----------------------------------------------------------------------------
;                       Rozbor p©°kazovÇho ©†dku
; -----------------------------------------------------------------------------
public   parnorm
parnorm:                                  ;* normalizace zadanòch parametrñ
                                            ; VSTUP: ES:DI=ukl†dac° adresa
                                            ;        DS=segment PSP
                                            ; VùSTUP: CX=poáet parametrñ
                                            ;         ZY=nen° ë†dnò parametr

         push      ax
         push      si
         push      di
         cld                                ; smàr nahoru
         xor       cx,cx                    ; á°taá parametrñ
         mov       si,81h                   ; zaá†tek parametrñ
         push      si
         add       si,ds:[si-1]             ; konec parametrñ
         and       si,0ffh                  ; adresa konce textu
         mov       byte ptr ds:[si],0       ; oznaáen° konce textu
         pop       si
                                          ;* nalezen° zaá†tku parametru
parnorm1:call      parread                  ; naáten° znaku parametrñ
         jc        parnorm2                 ; je konec textu
         jz        parnorm1                 ; je oddàlovaá - dal®° znak
         inc       cx                       ; zvò®en° á°taáe parametrñ
parnorm3:                                 ;* p©enesen° textu
         stosb                              ; uloëen° platnÇho znaku
         call      parread                  ; naáten° dal®°ho znaku
         ja        parnorm3                 ; je platnò znak - dal®° znak
         xor       al,al                    ; ukonáovac° znak
         stosb                              ; oznaáen° konce textu
         jmp       short parnorm1           ; dal®° parametr

parnorm2:xor       al,al                    ; koncovò bajt parametrñ
         stosb                              ; oznaáen° konce parametrñ
         or        cx,cx                    ; je nàjakò parametr ?
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parget
parget:                                   ;* poskytnut° adresy parametru
                                            ; VSTUP: CX=á°slo parametru
                                            ;        DS:SI=adresa bufferu
                                            ; VùSTUP: DS:SI=adresa parametru
                                            ;         CY=neplatnò parametr
         push      ax
         push      cx
parget1:                                  ;* nalezen° zaá†tku dal®°ho parametru
         cmp       byte ptr ds:[si],0       ; je platnò parametr ?
         stc                                ; p©°znak - nen° dal®° parametr
         je        parget3                  ; nen° dal®° parametr
         clc
         jcxz      parget3                  ; nalezen parametr
parget2: lodsb                              ; naáten° dal®°ho znaku
         or        al,al
         jnz       parget2
         dec       cx
         jmp       short parget1            ; dal®° parametr
parget3:
         pop       cx
         pop       ax
         ret
; -----------------------------------------------------------------------------
public   parrozb
parrozb:                                  ;* rozbor zad†n° souboru
                                            ; VSTUP: DS:SI=adresa textu
                                            ;        ES:DI=adresa rozboru
                                            ;           1 B: jmÇno disku
                                            ;           1 B: oddàlovaá ":"
                                            ;          64 B: cesta ASCIIZ
                                            ;          13 B: jmÇno soub. ASCIIZ
         push      ax
         push      si
         push      di
parrozb1:call      parread                  ; áten° znaku textu
         jc        parrozb3                 ; konec textu





parrozb3:
         pop       di
         pop       si
         pop       ax
         ret
; -----------------------------------------------------------------------------
parread:                                  ;* áten° bajtu z p©°kaz. ©†dku
                                            ; VSTUP: DS:SI=ukazatel textu
                                            ; VùSTUP: AL=znak
                                            ;         CY=nen° dal®° znak
                                            ;         ZY=je oddàlovaá

         mov       al,ds:[si]               ; znak
         or        al,al
         jz        parread1                 ; je konec textu
         cmp       al,13
         je        parread1                 ; konec textu
         inc       si                       ; zvò®en° adresy
         cmp       al,9                     ; je tabel†tor ?
         je        parread2                 ; je tabel†tor
         cmp       al," "                   ; je mezera ?
         je        parread2                 ; je mezera
         stc                                ; p©°znak - znak OK
parread1:cmc
parread2:ret
; -----------------------------------------------------------------------------
;                              DiskovÇ operace
; -----------------------------------------------------------------------------
public   wbyte
wbyte:                                    ;* z†pis bajtu do vòstupn°ho souboru
         push      ax
         push      bx
         mov       bx,ds:[outnum]           ; poáet bajtñ ve vòstupn°m bufferu
         cmp       bx,1000h-1               ; je jië konec bufferu ?
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
public   writefbuf
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
public   rbyte
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
readfbuf:                                 ;* naáten° bufferu vstupn°ho souboru
                                            ; VùSTUP: CY=chyba operace áten°
                                            ;         ZY=je konec souboru

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[inpnum],0   ; vynulov†n° vstupn°ho bufferu
         mov       word ptr ds:[inpuk],0    ; vynulov†n° ukazatele átenòch dat
         mov       cx,1000h                 ; dÇlka vstupn°ho bufferu
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
public   inpid,outid,inpnum,inpuk,outnum

errtxt   db        'Dekomprese metodou LZSS;  (c) Miroslav Nemecek',13,10
         db        'Zadejte: DEKOMP vstupni_soubor vystupni_soubor',13,10,'$'

inpid    dw        0                        ; identifik†tor vstupn°ho souboru
outid    dw        0                        ; identifik†tor vòstupn°ho souboru

inpnum   dw        0                        ; poáet bajtñ ve vstupn°m souboru
inpuk    dw        0                        ; ukazatel dat ve vstupn°m souboru
outnum   dw        0                        ; poáet bajtñ ve vòstupn°m souboru

konec    label     near                     ; konec programu

; ----------------------------- buffery dat -----------------------------------

public   inpbuf,outbuf,textbuf

commbuf  db        128 dup(?)               ; buffer p©°kazovÇho ©†dku
inpbuf   db        1000h dup(?)              ; buffer vstupn°ho souboru
outbuf   db        1000h dup(?)              ; buffer vòstupn°ho souboru

textbuf  db        buffsize dup(?)          ; kruhovò buffer

code     ENDS
         END       komp

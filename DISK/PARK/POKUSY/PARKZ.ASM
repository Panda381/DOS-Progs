
; *****************************************************************************
;
;                      Zaparkov†n° pevnòch diskñ
;
; *****************************************************************************
code     SEGMENT
         ASSUME    cs:code,ds:code
         ORG       100h
start:
                                          ;* reset diskovÇho systÇmu
         mov       ah,0dh
         int       21h                      ; reset diskovÇho systÇmu DOS
                                          ;* z°sk†n° poátu diskñ
         mov       ah,8
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         int       13h                      ; poskytnut° poátu diskñ
         jc        error                    ; chyba - nen° ë†dnò pevnò disk
         and       dx,3                     ; poáet pevnòch diskñ
         jz        error                    ; nen° ani 1 pevnò disk
         mov       ds:[disku],dl            ; £schova poátu pevnòch diskñ
         dec       dx                       ; je 1 pevnò disk ?
         jz        getd0                    ; je pouze 1 pevnò disk
                                          ;* zji®tàn° parkovac° stopy disku 1
         mov       dl,81h                   ; á°slo pevnÇho disku 1
         mov       bx,118h                  ; offset adresy INT 46h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 1
         mov       ds:[parkc1],dx           ; parkovac° stopa disku 1
getd0:                                    ;* zji®tàn° parkovac° stopy disku 0
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,104h                  ; offset adresy INT 41h
         call      getdisk                  ; zji®tàn° parkovac° stopy disku 0
         mov       ds:[parkc0],dx           ; parkovac° stopa disku 0
                                          ;* test spr†vnosti stop
         mov       ax,ds:[parkc0]           ; parkovac° stopa disku 0
         or        ax,ds:[parkc1]           ; je alespo§ 1 pevnò disk ?
         jnz       parkuj                   ; je alespo§ 1 pevnò disk
                                          ;* chyba - nen° ani 1 disk
error:   mov       dx,offset errtxt
         call      outtxt                   ; zobrazen° chybovÇho textu
         int       20h

parkuj:                                   ;* zaparkov†n° diskñ
         mov       dl,80h                   ; á°slo pevnÇho disku 0
         mov       bx,ds:[parkc0]           ; parkovac° stopa disku 0
         call      park                     ; zaparkov†n° pevnÇho disku 0
         inc       dl                       ; á°slo pevnÇho disku 1
         mov       bx,ds:[parkc1]           ; parkovac° stopa disku 1
         call      park                     ; zaparkov†n° pevnÇho disku 1
                                          ;* zobrazen° hl†®en°
         mov       dx,offset parktxt1       ; hl†®en° pro 1 pevnò disk
         or        bx,bx                    ; je platnò disk 1 ?
         jz        zobrhl                   ; je pouze pevnò disk 1
         cmp       word ptr ds:[parkc0],0   ; je platnò disk 0 ?
         je        zobrhl                   ; je pouze pevnò disk 0
         mov       dx,offset parktxt2       ; hl†®en° pro 2 pevnÇ disky
zobrhl:  call      outtxt                   ; zobrazen° prvn° á†sti hl†®en°
         mov       dx,offset parktxt3       ; druh† á†st hl†®en°
         call      outtxt                   ; zobrazen° druhÇ á†sti hl†®en°
flush:                                    ;* vypr†zdnàn° bufferu kl†vesnice
         mov       ah,1
         int       16h                      ; poskytnut° stavu kl†vesnice
         jz        cekej                    ; nen° p©ipraven dal®° znak
         xor       ax,ax
         int       16h                      ; vyjmut° znaku z bufferu
         jmp       short flush              ; zru®en° dal®°ho znaku

cekej:                                    ;* áek†n° na p©eru®en°
         xor       ax,ax
         int       16h                      ; vstup znaku z kl†vesnice
         cmp       al,27                    ; je <Esc> ?
         jne       cekej
                                          ;* je p©eru®en° operace
prerus:  mov       dx,offset parktxt4       ; hl†®en° pro 1 pevny disk
         dec       byte ptr ds:[disku]      ; je 1 pevnò disk ?
         jz        prerus2                  ; je 1 pevnò disk
         mov       dx,offset parktxt5       ; hl†®en° pro 2 pevnÇ disky
prerus2: call      outtxt                   ; hl†®en° o zru®en° parkov†n°
         int       20h
; -----------------------------------------------------------------------------
getdisk:                                  ;* zji®tàn° parkovac° stopy
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=offset ukazatele tabulky
                                            ; VùSTUP: DX=parkovac° stopa disku
         push      es
         xor       ax,ax
         mov       es,ax                    ; segment 0
         les       bx,es:[bx]               ; adresa tabulky popisovaáe
         mov       dx,es:[bx]               ; poáet v†lcñ disku
         call      testat                   ; je poá°taá AT ?
         jc        getdisk2                 ; nen° poá°taá AT
         mov       dx,es:[bx+0ch]           ; parkovac° z¢na pevnÇho disku
getdisk2:pop       es
         ret
; -----------------------------------------------------------------------------
park:                                     ;* zaparkov†n° jednoho pevnÇho disku
                                            ; VSTUP: DL=á°slo disku
                                            ;        BX=á°slo stopy

         or        bx,bx                    ; je disk zad†n ?
         jz        park2                    ; neplatnò disk
         push      dx
         xor       ax,ax
         int       13h                      ; reset disku
         pop       dx
         mov       cx,68                    ; poáet pokusñ o parkov†n°
park1:   push      bx
         push      cx
         push      dx

         mov       ch,bl                    ; nië®° bajt á°sla v†lce
         mov       cl,bh                    ; vy®®° bajt á°sla v†lce
         ror       cl,1
         ror       cl,1                     ; bity 8 a 9 do bitñ 6 a 7
         and       cl,0c0h                  ; ponech† bity 6 a 7 (= 8 a 9)
         inc       cl                       ; -> sektor 1
         mov       dh,bh                    ; vy®®° bajt á°sla v†lce
         shl       dh,1
         shl       dh,1
         shl       dh,1
         shl       dh,1                     ; bity 10 a 11 do bitñ 6 a 7
         and       dh,0c0h                  ; ponech† bity 6 a 7 (= 10 a 11)
         mov       ah,0ch                   ; funkce vystaven° hlav
         int       13h                      ; vystaven° na parkovac° stopu

         pop       dx
         pop       cx
         pop       bx
         loop      park1                    ; novÇ zaparkov†n° disku
park2:   ret
; -----------------------------------------------------------------------------
outtxt:                                   ;* zobrazen° textu
         push      ax
         push      dx
         mov       ah,9
         int       21h
         pop       dx
         pop       ax
         ret
; -----------------------------------------------------------------------------
testat:                                   ;* je poá°taá AT ?
                                            ; VùSTUP: CY=nen° AT
         push      ax
         push      ds
         mov       ax,0f000h                ; segment modulu BIOS
         mov       ds,ax                    ; segment modulu BIOS
         cmp       byte ptr ds:[0fffeh],0fch; je AT nebo XT-286 ?
         je        testat2                  ; je AT nebo XT-286
         stc                                ; p©°znak, ëe nen° AT
testat2: pop       ds
         pop       ax
         ret
; -----------------------------------------------------------------------------
errtxt   db        'Neni nainstalovan zadny pevny disk !',13,10,'$'
parktxt1 db        '…ÕÕÕÕÕ Pevny disk byl zaparkovan ÕÕÕÕÕÕª',13,10,'$'
parktxt2 db        '…ÕÕ Oba pevne disky byly zaparkovany ÕÕª',13,10,'$'
parktxt3 db        '∫ Nyni muzete pocitac vypnout. Stiskem ∫',13,10
         db        '∫ klavesy <Esc> se muzete vratit zpet. ∫',13,10
         db        '»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº',13,10,'$'
parktxt4 db        '*** Parkovani pevneho disku zruseno ***',13,10,'$'
parktxt5 db        '*** Parkovani pevnych disku zruseno ***',13,10,'$'

parkc0   dw        0                        ; parkovac° stopa disku 0
parkc1   dw        0                        ; parkovac° stopa disku 1

disku    db        0                        ; poáet pevnòch diskñ

copyrght db        13,10,'Parkov†n° pevnòch diskñ; (c) Miroslav Nàmeáek',13,10

code     ENDS
         END       start

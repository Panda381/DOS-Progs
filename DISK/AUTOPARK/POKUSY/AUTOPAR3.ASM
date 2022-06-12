; *****************************************************************************
;                      automatick‚ parkov n¡ pevn˜ch disk–
; *****************************************************************************

code     segment
         assume    cs:code,ds:code

         org       100h

autopark:jmp       instal                   ; instalace programu

         db        'Program pro automaticke parkovani pevnych disku',13,10
         db        '(c) Miroslav Nemecek 1991',13,10
         db        'Doba pro automaticke parkovani se udava v 1/18 sekundy.',13,10

doba     dw        18*2                     ; doba pro parkov n¡ disku v 1/18 s
citac    dw        18*2                     ; ‡¡ta‡ doby pro autoparkov n¡
old13    dd        0                        ; adresa p–vodn¡ obsluhy INT 13h
old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
inter    db        80h                      ; p©¡znaky prob¡haj¡c¡ obsluhy
                                            ;     bit 0: prob¡h  obsluha INT 13h
                                            ;     bit 1: prob¡h  obsluha parkov n¡
                                            ;     bit 7: nen¡ po‘adov no parkov n¡

int13:                                    ;* obsluha p©eru¨en¡ INT 13h
         or        byte ptr cs:[inter],1    ; p©¡znak obsluhy INT 13h
         test      dl,80h                   ; je p©¡stup na pevn˜ disk ?
         jz        int131                   ; nen¡ p©¡stup na pevn˜ disk
         push      word ptr cs:[doba]       ; doba pro parkov n¡
         pop       word ptr cs:[citac]      ; inicializace ‡¡ta‡e
int131:  pushf
         call      dword ptr cs:[old13]
         pushf
         and       byte ptr cs:[inter],not 1; zru¨en¡ p©¡znaku obsluhy INT 13h
         popf
int132   proc      far
         ret       +2
int132   endp


int08:                                    ;* obsluha p©eru¨en¡ INT 08h
         pushf
         call      dword ptr cs:[old08]     ; p–vodn¡ obsluha INT 08h
         cmp       word ptr cs:[citac],0    ; je ‡¡ta‡ ji‘ 0 ?
         je        int081                   ; je ji‘ dosa‘eno 0 ‡¡ta‡e
         dec       word ptr cs:[citac]      ; sn¡‘en¡ ‡¡ta‡e
         jnz       int083                   ; nen¡ je¨tˆ 0 ‡¡ta‡e
         and       byte ptr cs:[inter],7fh  ; p©¡znak po‘adavku parkov n¡
int081:  test      byte ptr cs:[inter],83h  ; je mo‘n‚ parkov n¡ ?
         jnz       int083                   ; nen¡ mo‘n‚ parkov n¡
         or        byte ptr cs:[inter],82h  ; zru¨en¡ po‘adavku parkov n¡
         sti                                ; povolen¡ p©eru¨en¡
         push      dx
         mov       dl,80h                   ; prvn¡ disk
         call      park                     ; parkov n¡ prvn¡ho disku
         cmp       dl,2                     ; jsou 2 pevn‚ disky ?
         jne       int082                   ; nejsou 2 pevn‚ disky
         mov       dl,81h                   ; druh˜ disk
         call      park                     ; parkov n¡ druh‚ho disku
int082:  pop       dx
         and       byte ptr cs:[inter],not 2; zru¨en¡ p©¡znaku obsluhy parkov n¡
int083:  iret

park:                                     ;* parkov n¡ jednoho disku (DL)
         push      ax
         push      bx
         push      cx
         push      di
         push      es
         mov       ah,8
         push      dx                       ; £schova ‡¡sla disku
         pushf
         call      dword ptr cs:[old13]     ; poskytnut¡ parametr– disku
         pop       ax                       ; n vrat ‡¡sla disku
         push      dx                       ; £schova po‡tu disk–
         add       ch,1                     ; zv˜¨en¡ ‡¡sla stopy o 1
         jnc       park1                    ; nen¡ p©enos
         add       cl,40h                   ; p©enos do bit– 8 a 9
park1:   mov       dl,al                    ; ‡¡slo disku
         mov       ah,0ch
         xor       dh,dh
         pushf
         call      dword ptr cs:[old13]     ; zaparkov n¡ disku
         pop       dx
         pop       es
         pop       di
         pop       cx
         pop       bx
         pop       ax
         ret

; ----------------------  instalace programu ----------------------------------
instal:                                   ;* instalace programu

                                          ;* na‡ten¡ parametru z p©¡kaz. © dku
         mov       si,81h                   ; ukazatel textu parametr–
         mov       bx,si                    ; za‡ tek textu
         add       bl,ds:[80h]              ; po‡et znak– parametru
         mov       byte ptr ds:[bx],0       ; koncov˜ znak 0
instal1: lodsb                              ; na‡ten¡ znaku
         or        al,al
         jz        instal4                  ; je konec textu
         cmp       al," "
         jbe       instal1                  ; vypu¨tˆn¡ po‡ te‡n¡ch mezer
         dec       si                       ; n vrat ukazatele
         xor       dx,dx                    ; st©ada‡ ‡¡sla
instal2: lodsb                              ; na‡ten¡ dal¨¡ho znaku
         cmp       al," "                   ; je konec textu ?
         jbe       instal3                  ; konec ‡¡sla
         and       al,0fh                   ; p©evod na ‡¡slo
         mov       bl,al                    ; £schova ‡¡sla
         mov       ax,10
         mul       dx                       ; vyn soben¡ ‡¡sla DX 10*
         mov       dx,ax                    ; nov  hodnota
         xor       bh,bh
         add       dx,bx                    ; p©i‡ten¡ dal¨¡ ‡¡slice
         jmp       short instal2            ; dal¨¡ ‡¡slice

instal3: mov       ds:[doba],dx             ; nov  doba vypnut¡
         mov       ds:[citac],dx
instal4:                                  ;* instalace obsluhy INT 13h
         mov       ax,3513h
         int       21h                      ; poskytnut¡ adresy INT 13h
         mov       word ptr ds:[old13],bx   ; offset adresy
         mov       word ptr ds:[old13+2],es ; segment adresy
         mov       ax,2513h
         lea       dx,[int13]               ; adresa obsluhy INT 13h
         int       21h                      ; nastaven¡ adresy obsluhy INT 13h
                                          ;* instalace obsluhy INT 08h
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[old08],bx   ; offset adresy
         mov       word ptr ds:[old08+2],es ; segment adresy
         mov       ax,2508h
         lea       dx,[int08]               ; adresa obsluhy INT 08h
         int       21h                      ; nastaven¡ adresy obsluhy INT 08h
                                          ;* informa‡n¡ text, instalace
         lea       dx,[uvtxt]               ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu
         lea       dx,[instal]              ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace jako rezidentn¡

uvtxt    db        'Automaticke parkovani pevnych disku nainstalovano.',13,10,'$'

code     ends
         end       autopark

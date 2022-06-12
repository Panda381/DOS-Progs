COMMENT %
                   Zobrazen¡ souboru ve form tu displeje
        %

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:code

         ORG       100h

start:
                                          ;* p©¡prava p©¡kazov‚ho © dku
         cld
         xor       bx,bx
         mov       bl,ds:[80h]              ; po‡et znak–
         mov       si,81h                   ; za‡ tek textu parametru
         mov       byte ptr ds:[bx+si],0    ; ozna‡en¡ konce textu

                                          ;* nalezen¡ za‡ tku jm‚na souboru
cut1:    lodsb
         cmp       al,9
         je        cut1                     ; tabel tor - ignorov n¡
         cmp       al," "
         je        cut1                     ; mezera - ignorov n¡
         jb        cuterr                   ; konec textu
         mov       dx,si
         dec       dx                       ; za‡ tek jm‚na souboru

                                          ;* ozna‡en¡ konce jm‚na souboru
         xor       di,di                    ; adresa p©¡pony
cut2:    lodsb
         cmp       al,"."
         jne       cut20
         mov       di,si
         dec       di                       ; ukazatel na te‡ku
cut20:   cmp       al,"/"
         jne       cut21
         xor       di,di                    ; byl to adres © - te‡ka neplat¡
cut21:   cmp       al," "
         ja        cut2                     ; nen¡ konec jm‚na - dal¨¡ znak
         dec       si                       ; n vrat posledn¡ho znaku
         or        di,di                    ; byla nalezena te‡ka ?
         jnz       cut22                    ; byla nalezena te‡ka
         mov       di,si                    ; adresa konce jm‚na
cut22:   mov       byte ptr ds:[si],0       ; ozna‡en¡ konce jm‚na

                                          ;* otev©en¡ zdrojov‚ho souboru
cut3:    mov       ax,3d00h                 ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ zdrojov‚ho souboru
         mov       bx,ax                    ; identifik tor souboru
         jnc       cut4                     ; soubor otev©en OK

                                          ;* chyba - soubor nenalezen

cuterr:
chyba:   mov       dx,offset errtxt
         mov       ah,9
         int       21h
         int       20h


cut4:

         mov       dx,9
         xor       cx,cx
         mov       ax,4200h
         int       21h
         jc        chyba

         mov       cx,0e000h
         mov       dx,offset buffer
         mov       ah,3fh
         int       21h
         jc        chyba

         mov       ah,3eh
         int       21h
         jc        chyba

         mov       ax,18
         int       10h

         mov       si,offset buffer
         xor       dx,dx
         mov       cx,25

d1:      push      cx
         push      dx
         mov       cx,80

d2:      push      cx
         push      dx

         mov       ah,2
         xor       bx,bx
         int       10h

         xor       bx,bx
         mov       bl,ds:[si+80*25]
         shr       bl,1
         shr       bl,1
         shr       bl,1
         shr       bl,1
         mov       cx,1
         mov       al,219
         mov       ah,9
         push      si
         push      bx
         int       10h
         pop       dx
         pop       si

         xor       bx,bx
         mov       al,ds:[si]
         mov       bl,ds:[si+80*25]
         inc       si
         xor       bl,dl
         or        bl,80h
         mov       cx,1
         push      si
         int       10h
         pop       si

         pop       dx
         pop       cx
         inc       dl

         loop      d2

         pop       dx
         pop       cx
         inc       dh
         loop      d1


         xor       ax,ax
         int       16h


konec:   mov      ax,3
         int       10h
         int       20h

errtxt   db        'Soubor nenalezen nebo chyba.',13,10,'$'

buffer   label     byte

code     ENDS


         END       start                    ; startovac¡ adresa

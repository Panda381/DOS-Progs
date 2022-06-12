code     SEGMENT
         assume    cs:code,ds:code
         org       100h
start:
                                          ;* zad n¡ ‡¡sla portu
         mov       dx,offset zadport
         mov       ah,9
         int       21h
         mov       ah,1
         int       21h                      ; vstup znaku z kl vesnice
         push      ax
         mov       dx,offset textcr
         mov       ah,9
         int       21h                      ; od© dkov n¡
         pop       ax
         cmp       al,27
         je        konec
         cmp       al,3
         je        konec
         cmp       al,"4"
         ja        start
         sub       al,"1"
         jc        start
         mov       byte ptr ds:[port],al    ; ‡¡slo portu

         mov       dx,offset text2
         mov       ah,9
         int       21h

test1:                                    ;* v˜stup znaku
         mov       ah,1
         int       16h                      ; test znaku z kl vesnice
         jz        test2                    ; nen¡ ‘ dn˜ znak

         cmp       ax,0
         je        konec1
         cmp       ax,4400h
         je        konec1

         mov       ah,3
         mov       dx,ds:[port]
         int       14h                      ; test p©ipravenosti vys¡l n¡
         test      ah,20h                   ; je vys¡la‡ p©ipraven ?
         jz        test2                    ; vys¡la‡ nen¡ p©ipraven

         xor       ax,ax
         int       16h

         push      ax
         mov       dx,ds:[port]
         mov       ah,1
         int       14h                      ; vysl n¡ znaku
         pop       ax
         mov       bl,7                     ; barva vyslan‚ho znaku
         jmp       short test3              ; zobrazen¡ znaku

test2:                                    ;* p©¡jem znaku
         mov       ah,3
         mov       dx,ds:[port]
         int       14h
         test      ah,1                     ; jsou data p©ipravena ?
         jz        test1                    ; data nejsou p©ipravena

         mov       ah,2
         mov       dx,ds:[port]
         int       14h                      ; p©¡jem znaku

         mov       bl,0fh                   ; barva p©ijat‚ho znaku
test3:   mov       ah,0eh
         mov       bh,0
         int       10h                      ; zobrazen¡ znaku
         jmp       short test1

konec1:  xor       ax,ax
         int       16h                      ; zru¨en¡ kl vesy F10
konec:
         int       20h

port     dw        0
zadport  db        'Zadejte cislo portu COM (1 az 4): $'
textcr   db        13,10,'$'
text2    db        '(F10=konec)',13,10,'$'

code     ENDS
         end       start

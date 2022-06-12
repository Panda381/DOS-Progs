code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

start:                                      ; hlavn¡ tˆlo programu

         mov       al,0                     ; po‡ te‡n¡ znak
         call      Zobr                     ; zobrazen¡ jedn‚ str nky
         cmp       al,27
         je        konec                    ; ESC = konec
         cmp       al,3
         je        konec                    ; Ctrl-C = konec
         or        ax,ax
         jz        konec                    ; Ctrl-Break = konec
         mov       al,128
         call      zobr
konec:   call      clear

         mov       dx,offset Lictxt
         mov       ah,9
         int       21h

         int       20h


; ------ p©¡prava displeje (AL=‡¡slo znaku)

Zobr:    call      clear

; ------ zobrazen¡ horn¡ linky

         mov       si,offset lin1
         call      zobrlin
         mov       bh,17                    ; ‡¡ta‡ © dk– tabulky

; ------ zobrazen¡ oddˆlovac¡ linky

zobr1:   dec       bh
         jz        zobr9                    ; konec
         cmp       bh,8
         jne       zobr2
         mov       si,offset lin2
         call      zobrlin

; ------ p©¡prava k zobrazen¡ sloupc–

zobr2:   mov       ch,8                     ; po‡et sloupc–
         mov       dl,0
         push      ax

; ------ zobrazen¡ lev‚ho okraje sloupce

zobr3:   push      ax

         push      ax
         mov       al,186
         call      zobrch
         pop       ax

         call      zobrhex
         call      ZobrSpc
         call      zobrdek
         call      zobrspc
         call      zobrch

         pop       ax
         add       al,16
         dec       ch
         jnz       zobr3                    ; dal¨¡ sloupec

; ------ konec © dku

         mov       al,186
         call      zobrch
         pop       ax
         inc       ax                       ; zv˜¨en¡ ‡¡sla polo‘ky
         inc       dh
         jmp       short zobr1

; ------ zobrazen¡ spodn¡ linky

zobr9:   mov       si,offset lin3
         call      zobrlin

         mov       dx,25*256
         call      zobrch

; ------ ‡ek n¡ na stisk kl vesy

         xor       ax,ax
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         ret

zobrdek: push      ax
         push      bx

         cmp       al,10
         jae       zobrdk12
         call      zobrspc
         call      zobrspc
         jmp       short zobrdk13

zobrdk12:mov       bh,100
         call      zobrdek1
         mov       bh,10
         call      zobrdek2
zobrdk13:mov       bh,1
         call      zobrdek2
         pop       bx
         pop       ax
         ret

zobrdek1:cmp       al,bh
         jae       zobrdek2
         call      zobrspc
         ret

zobrdek2:mov       ah,0
         div       bh
         add       al,"0"
         call      zobrch
         xchg      al,ah
         ret


zobrhex: push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      zobrhex1
         pop       ax

zobrhex1:push      ax
         and       al,0fh
         cmp       al,10
         jb        zobrhex2
         add       al,7
zobrhex2:add       al,"0"
         call      zobrch
         pop       ax
         ret


zobrlin: push      ax
         mov       dl,0
         mov       al,ds:[si]
         call      zobrch
         mov       bl,8
zobrlin1:mov       al,ds:[si+1]
         mov       cx,8
zobrlin2:call      zobrch
         loop      zobrlin2
         mov       al,ds:[si+2]
         cmp       bl,1
         jne       zobrlin3
         mov       al,ds:[si+3]
zobrlin3:call      zobrch
         dec       bl
         jnz       zobrlin1
         pop       ax
         inc       dh
         ret

ZobrSpc: push      ax
         mov       al," "
         call      ZobrCh
         pop       ax
         ret

zobrch:  push      bx
         push      cx
         push      dx
         push      si

         push      ax
         mov       bh,0
         mov       ah,2
         int       10h                      ; nastaven¡ pozice kurzoru
         pop       ax

         push      ax
         mov       ah,9
         mov       bx,0fh
         mov       cx,1
         int       10h
         pop       ax

         pop       si
         pop       dx
         pop       cx
         pop       bx
         inc       dl
         ret

clear:   push      ax
         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h
         pop       ax
         xor       dx,dx                    ; po‡ te‡n¡ pozice
         ret

lin1     db        'ÉÍË»'
lin2     db        'ºÄºº'
lin3     db        'ÈÍÊ¼'

lictxt   db        'ASCII V1.10 - tabulka ASCII; (c) Miroslav Nemecek',13,10,'$'

code     ends
         end       start

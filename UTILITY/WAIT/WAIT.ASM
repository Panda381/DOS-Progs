code     segment
         assume    cs:code,ds:code
         org       100h

; ------ p©edefinov n¡ INT 23h

start:   mov       dx,offset INT23
         mov       ax,2523h
         int       21h

; ------ vypr zdnˆn¡ bufferu kl vesnice

wait1:   mov       ah,0bh
         int       21h
         inc       al
         jnz       wait2
         mov       ah,8
         int       21h
         jmp       short wait1

; ------ p©¡prava p©¡kazov‚ho © dku

wait2:   mov       bl,ds:[80h]
         mov       bh,0
         mov       byte ptr ds:[bx+81h],"$"

; ------ test, zda je nˆjak˜ text zad n

         mov       dx,offset text
         mov       cx,offset(text2-text)
         cmp       bl,2
         jb        wait4                    ; nen¡ nic zad no
         mov       dx,82h
         dec       bx
         mov       cx,bx

; ------ vypu¨tˆn¡ znak– uvozovek

         cmp       byte ptr ds:[82h],'"'
         jne       wait4
         inc       dx
         dec       cx
         cmp       byte ptr ds:[81h+bx],'"'
         jne       wait4
         mov       byte ptr ds:[81h+bx],'$'
         dec       cx

; ------ zobrazen¡ textu v˜zvy

wait4:   mov       ah,9
         int       21h

; ------ ‡ek n¡ na stisk kl vesy

         mov       ah,8
         int       21h
         cmp       al,0
         jne       wait5
         mov       ah,8
         int       21h
         mov       al,0

; ------ rozli¨en¡, zda je p©eru¨en¡ ESC

wait5:   cmp       al,27
         mov       al,0
         jne       wait6
INT23:   mov       al,1

; ------ vymaz n¡ zobrazen‚ho textu

wait6:   push      ax
wait7:   mov       ah,2
         mov       dl,8
         int       21h
         mov       ah,2
         mov       dl," "
         int       21h
         mov       ah,2
         mov       dl,8
         int       21h
         loop      wait7
         pop       ax

; ------ n vrat z programu

         mov       ah,4ch
         int       21h

text     db        'Stiskni libovolnou kl vesu ... $'
text2    label     byte

code     ends
         end       start

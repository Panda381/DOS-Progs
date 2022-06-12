
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ nastaven¡ rychlosti pomoc¡ portu

Start:   cli
         mov       al,0f3h                  ; povel pro nastaven¡ rychlosti
         call      Vysli                    ; vysl n¡ povelu pro nastaven¡
         mov       al,0                     ; maxim ln¡ rychlost
         call      Vysli                    ; nastaven¡ maxim ln¡ rychlosti
         sti

; ------ nastaven¡ rychlosti pomoc¡ BIOS

         mov       ax,305h
         xor       bx,bx
         int       16h

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

         int       20h

; -----------------------------------------------------------------------------
;        vysl n¡ bajtu AL na kl vesnici
; -----------------------------------------------------------------------------

Vysli    PROC      NEAR

; ------ p©¡prava registr–

         mov       ah,al                    ; £schova bajtu k vysl n¡
         in        al,[60h]                 ; zru¨en¡ bajtu z datov‚ho portu

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

         xor       cx,cx                    ; ‡¡ta‡ prodlevy
Vysli1:  in        al,[64h]                 ; ‡ten¡ stavov‚ho portu
         test      al,2                     ; je ©adi‡ p©ipraven k p©¡jmu ?
         loopnz    Vysli1                   ; ‡ek n¡ na p©ipravenost ©adi‡e

; ------ vysl n¡ bajtu na datov˜ port

         mov       al,ah                    ; bajt ur‡en˜ k vysl n¡
         out       [60h],al                 ; vysl n¡ bajtu na port
         ret

Vysli    ENDP

UvTxt    db        'Klavesnice nastavena na maximalni rychlost.',13,10,'$'

Code     ENDS
         END       Start

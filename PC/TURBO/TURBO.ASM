Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ nalezen¡ zadan‚ho parametru

         cld
         mov       si,81h
Start1:  lodsb
         cmp       al,9
         je        Start1
         cmp       al," "
         je        Start1
         jb        Start8                   ; chyba zad n¡ parametr–

; ------ vypnut¡ TURBO

         cli
         xor       cx,cx                    ; CX <- 0
         cmp       al,"1"
         jne       Start2
         call      TurVyp                   ; vypnut¡ re‘imu TURBO
         mov       ah,0b4h
         jmp       short Start3

; ------ zapnut¡ TURBO

Start2:  cmp       al,"2"
         jne       Start8
         call      TurZap                   ; zapnut¡ re‘imu TURBO
         mov       ah,0bch
Start3:  call      WritKey                  ; z pis na port kl vesnice
         jmp       short Start9

; ------ chyba - zobrazen¡ n povˆdy

Start8:  mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
Start9:  sti
         int       20h

; -----------------------------------------------------------------------------
;        z pis AL na port kl vesnice, vstup dat z kl vesnice (adr. F000:8D28)
; -----------------------------------------------------------------------------

WritKey  PROC      NEAR

; ------ ‡ek n¡ na p©ipravenost ©adi‡e kl vesnice p©evz¡t data

WritKey1:jcxz      $+2
         in        al,[64h]                 ; stavov˜ port kl vesnice
         test      al,2
         loopnz    WritKey1
         jnz       WritKey3                 ; TIME-OUT

; ------ vysl n¡ bajtu na kl vesnici

         mov       al,ah
         out       [64h],al

; ------ ‡ek n¡ na p©ipravenost dat od ©adi‡e

         xor       cx,cx
WritKey2:jcxz      $+2
         in        al,[64h]
         test      al,1
         loopz     WritKey2

         in        al,[60h]                 ; ‡ten¡ datov‚ho bajtu
WritKey3:ret

WritKey  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ re‘imu TURBO (adr. F000:8E2A)
; -----------------------------------------------------------------------------

TurZap   PROC      NEAR

         mov       ax,2020h                 ; registr 20h
         call      ReadReg                  ; ‡ten¡ registru 20h
         and       al,not 10h               ; vypnut¡ p©¡znaku NORMAL
         xchg      ah,al                    ; AL <- hodnota, AH <- registr 20h
         call      WritReg                  ; z pis registru 20h
         ret

TurZap   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ re‘imu TURBO (adr. F000:8E3B)
; -----------------------------------------------------------------------------

TurVyp   PROC      NEAR

         mov       ax,2020h                 ; registr 20h
         call      ReadReg                  ; ‡ten¡ registru 20h
         or        al,10h                   ; zapnut¡ p©¡znaku NORMAL
         xchg      ah,al                    ; AL <- hodnota, AH <- registr 20h
         call      WritReg                  ; z pis registru 20h
         ret

TurVyp   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ registru AL ©adi‡e sbˆrnice -> AL (adr. F000:8E4C)
; -----------------------------------------------------------------------------

ReadReg  PROC      NEAR

         out       [22h],al                 ; nastaven¡ ‡¡sla registru
         jcxz      $+2
         jcxz      $+2
         in        al,[24h]                 ; ‡ten¡ hodnoty registru ©adi‡e
         jcxz      $+2
         jcxz      $+2
         ret

ReadReg  ENDP

; -----------------------------------------------------------------------------
;        z pis AH do registru AL ©adi‡e sbˆrnice (adr. F000:8E59)
; -----------------------------------------------------------------------------

WritReg  PROC      NEAR

         out       [22h],al                 ; nastaven¡ ‡¡sla registru
         jcxz      $+2
         jcxz      $+2
         xchg      ah,al
         out       [24h],al                 ; nastaven¡ hodnoty registru
         jcxz      $+2
         jcxz      $+2
         xchg      ah,al
         ret

WritReg  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'TURBO V1.0 - nastaveni TURBO procesoru; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:     1 .... nastaveni rychlosti 1 (zpravidla NORMAL)',13,10
         db        '             2 .... nastaveni rychlosti 2 (zpravidla TURBO)',13,10
         db        '$'

Code     ENDS
         END       Start

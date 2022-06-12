
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zastaven¡ ‡asova‡– T1 a T2

Start:   mov       dx,388h                  ; b zov  adresa portu ADLIB
         mov       ax,6004h
         call      OutByte                  ; resetov n¡ ‡asova‡–

; ------ resetov n¡ p©¡znaku p©eru¨en¡ IRQ

         mov       ax,8004h
         call      OutByte                  ; resetov n¡ p©¡znaku p©eru¨en¡

; ------ £schova stavov‚ho registru -> BL

         in        al,dx                    ; ‡ten¡ stavov‚ho registru
         and       al,0e0h                  ; maskov n¡ registru
         xchg      ax,bx                    ; BL <- £schova stavov‚ho registru

; ------ nastaven¡ konstanty ‡asova‡e 2 na FFh

         mov       ax,0ff03h
         call      OutByte                  ; nastaven¡ konstanty pro ‡¡ta‡ 1

; ------ start ‡¡t n¡ ‡asova‡e 2

         mov       ax,4204h
         call      OutByte                  ; start ‡asova‡e 2

; ------ ‡ek n¡ po dobu 55 a‘ 110 ms

         call      Cekej                    ; ‡ek n¡ na za‡ tek impulsu 55 ms
         call      Cekej                    ; ‡ek n¡ na konec impulsu 55 ms

; ------ opˆtovn‚ na‡ten¡ stavov‚ho registru -> BH

         in        al,dx                    ; na‡ten¡ stavov‚ho registru
         and       al,0e0h                  ; maskov n¡ registru
         mov       bh,al                    ; BH <- £schova registru

; ------ zastaven¡ ‡asova‡– T1 a T2

         mov       ax,6004h
         call      OutByte                  ; resetov n¡ ‡asova‡–

; ------ resetov n¡ p©¡znaku p©eru¨en¡ IRQ

         mov       ax,8004h
         call      OutByte                  ; resetov n¡ p©¡znaku p©eru¨en¡

; ------ test, zda je karta ADLIB nainstalov na

         mov       dx,offset JeText         ; text - je
         mov       al,0                     ; n vratov˜ k¢d pro JE
         cmp       bx,0a000h                ; je navr cen˜ stav OK ?
         je        Hlaseni                  ; je karta OK
         mov       dx,offset NeniTxt        ; text - nen¡
         mov       al,1                     ; n vratov˜ k¢d pro NEN‹

; ------ zobrazen¡ hl ¨en¡

Hlaseni: push      ax
         mov       ah,9
         int       21h                      ; zobrazen¡ hl ¨en¡
         mov       dx,offset ZavText        ; z vˆre‡n˜ text
         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         pop       ax

; ------ konec programu (n vratov˜ k¢d AL)

         mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        vysl n¡ bajtu AH na registr AL karty Adlib (DX=adresa portu ADLIB)
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

; ------ nastaven¡ ‡¡sla registru AL

         out       dx,al                    ; mastaven¡ ‡¡sla registru

; ------ prodleva po nastaven¡ ‡¡sla registru (vy‘aduje 3.3 us, lze t‚‘ 6x ‡¡st)

         mov       cx,10                    ; po‡et ‡ten¡ stavov‚ho registru
OutByte2:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         loop      OutByte2                 ; prodleva

; ------ nastaven¡ dat

         inc       dx                       ; datov˜ registr
         mov       al,ah                    ; AL <- po‘adovan  data k nastaven¡
         out       dx,al                    ; z pis dat na port Adlib
         dec       dx                       ; stavov˜ registr

; ------ prodleva po z pisu dat na port (vy‘aduje 23 us, lze t‚‘ 35x ‡¡st)

         mov       cl,50                    ; po‡et cykl– ke ‡ten¡
OutByte4:in        al,dx                    ; ‡ten¡ stavov‚ho registru
         loop      OutByte4                 ; prodleva
         ret

OutByte  ENDP

; -----------------------------------------------------------------------------
;        ‡ek n¡ na hranu hodin INT 08h
; -----------------------------------------------------------------------------

Cekej    PROC      NEAR

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       cx,es:[46ch]             ; aktu ln¡ stav ‡¡ta‡e hodin
Cekej1:  sti
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ programu
         cmp       cx,es:[46ch]             ; je zmˆna hodin ?
         je        Cekej1                   ; ‡ek n¡ na hranu hodin
         ret

Cekej    ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

JeText   db        'JE$'
NeniTxt  db        'NENI$'
ZavText  db        ' nainstalovana zvukova karta kompatibilni s ADLIB.',13,10,'$'

Code     ENDS
         END       Start

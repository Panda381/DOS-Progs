
; -----------------------------------------------------------------------------
;        Test sign lu v˜mˆny disketov‚ mechaniky
; -----------------------------------------------------------------------------

code     segment
         assume    cs:code,ds:code
         org       100h

start:
                                          ;* nalezen¡ ozna‡en¡ mechaniky
         mov       si,81h
         mov       ch,0
         mov       cl,ds:[80h]              ; po‡et znak–
         cld
start1:  jcxz      chyba
         lodsb
         cmp       al," "
         ja        start2
         loop      start1
         jmp       short chyba

                                          ;* dek¢dov n¡ ‡¡sla mechaniky
start2:  and       al,not 20h               ; p©evod na velk‚ p¡smeno
         sub       al,"A"                   ; p©evod na ‡¡slo disku
         cmp       al,1                     ; kontrola ‡¡sla mechaniky
         ja        chyba                    ; chybn‚ ‡¡slo mechaniky
         mov       al,1ch                   ; k¢d pro mechaniku A
         jb        start3                   ; je mechanika A
         mov       al,2dh                   ; k¢d pro mechaniku B

                                          ;* zapnut¡ motor– a v˜bˆr mechaniky
start3:
         mov       ds:[disk],al             ; £schova k¢du disku

         call      Chng
         jz        navrat                   ; nen¡ aktivn¡

;         mov       ah,0dh
;         int       21h

         mov       al,ds:[disk]
         and       al,1
         mov       dx,0
         mov       cx,1
         mov       bx,offset help
         int       25h

         call      Chng
         inc       al
         jmp       short navrat


chyba:   mov       dx,offset help
         mov       ah,9
         int       21h
         mov       al,3

navrat:  mov       ah,4ch
         int       21h



; -----------------------------------------------------------------------------
;        Test sign lu v˜mˆny (AL)
; -----------------------------------------------------------------------------

Chng:
         push      ds
         xor       bx,bx                    ; BX <- 0
         mov       ds,bx                    ; DS <- 0
         and       byte ptr ds:[43fh],not 0fh ; motory vypnuty
         mov       byte ptr ds:[440h],0ffh  ; inicializace ‡¡ta‡e pro vypnut¡
         pop       ds

                                          ;* zapnut¡ motoru
         mov       al,ds:[disk]
         mov       dx,3f2h
         out       dx,al

                                          ;* mal  prodleva
         mov       cx,20
         loop      $

                                          ;* zji¨tˆn¡ stavu sign lu v˜mˆny
         mov       dx,3f7h
         in        al,dx                    ; ‡ten¡ stavu sign lu v˜mˆny
         mov       bl,al                    ; £schova stavu sign lu v˜mˆny

                                          ;* vypnut¡ motoru mechanik
         mov       dx,3f2h
         mov       al,0ch                   ; stav pro vypnut¡ motor–
         out       dx,al                    ; vypnut¡ motor–

                                          ;* v p©¡padˆ, ‘e nen¡ vymˆnˆna, konec
         mov       al,bl
         rol       al,1
         and       al,1
         ret

; -----------------------------------------------------------------------------
;        Data
; -----------------------------------------------------------------------------


disk     db        0                        ; disk

help     db        'DISKCHNG V1.10 - test vymeny diskety; (c) Miroslav Nemecek',13,10
         db        'Zadejte oznaceni disketove mechaniky A nebo B.',13,10
         db        '(pouze mechaniky 80 stop a radic kompatibilni s I8272)',13,10
         db        'Navratovy kod ERRORLEVEL: 3=chyba zadani disku',13,10
         db        '                          2=disketa neni vlozena',13,10
         db        '                          1=disketa byla vymenena',13,10
         db        '                          0=disketa je v mechanice',13,10
         db        '$'


code     ends
         end       start

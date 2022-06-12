
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ hl ¨en¡

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ vypnut¡ zvuku PC

         in        al,[61h]
         and       al,not 3
         out       [61h],al

; ------ resetov n¡ ‡¡ta‡–

         mov       ax,6004h
         call      OutByte                  ; resetov n¡ ‡asova‡–
         mov       ax,8004h
         call      OutByte                  ; nulov n¡ p©¡znaku p©eru¨en¡

; ------ resetov n¡ karty ADLIB

         mov       ax,0f5h                  ; AL <- posledn¡ registr, AH <- 0
Start2:  call      OutByte                  ; z pis 0 na registr AL
         dec       ax                       ; ‡¡ta‡ registr–
         jnz       Start2                   ; dal¨¡ registr

         int       20h

; -----------------------------------------------------------------------------
;        vysl n¡ bajtu AH na registr AL karty Adlib (DX=adresa portu ADLIB)
; -----------------------------------------------------------------------------

OutByte  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      dx

; ------ nastaven¡ ‡¡sla registru AL

         sti
         mov       dx,388h
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

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       ax
         ret

OutByte  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'SOUNDOFF V1.0 - vypnuti zvuku PC a ADLIB; (c) Miroslav Nemecek',13,10,'$'

Code     ENDS
         END       Start

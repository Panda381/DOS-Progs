COMMENT %

        %

;------------------------------------------------------------------------------
;                             Segment z sobn¡ku
;------------------------------------------------------------------------------

stack    SEGMENT   stack

         DW        256 DUP(?)               ; z sobn¡k

stack    ENDS

;------------------------------------------------------------------------------
;                             Programov˜ segment
;------------------------------------------------------------------------------

code     SEGMENT   page
         ASSUME    cs:code,ds:data,ss:stack

start:                                      ; hlavn¡ tˆlo programu
         mov       ax,SEG data              ; segment dat
         mov       ds,ax                    ; nastaven¡ datov‚ho segmentu


cyklus:  mov       ah,6                     ; funkce vstupu znaku z konzoly
         mov       dl,0ffh                  ; vstup znaku z konzoly
         int       21h
         jz        cyklus                   ; nebyl zad n ‘ dn˜ znak
         test      al,al                    ; test - je AL = 0 ?
         jnz       cykl2                    ; AL nen¡ = 0
         mov       dl,'*'                   ; ozna‡en¡ roz¨¡©en‚ho k¢du
         jmp       short cykl3              ; vstup k¢du kl vesy
cykl2:   cmp       al,27                    ; je znak <Esc> ?
         jz        konec                    ; konec programu
         call      bajt                     ; tisk bajtu v AL
         mov       dl,13                    ; znak CR
         int       21h                      ; tisk znaku CR
         mov       dl,10                    ; znak LF
cykl3:   int       21h                      ; tisk znaku LF
         jmp       short cyklus

konec:   mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

bajt:    push      ax                       ; znak k v˜stupu
         ror       al,1                     ; rotace AL o 4 bity vpravo
         ror       al,1
         ror       al,1
         ror       al,1
         call      hex                      ; tisk znaku HEX
         pop       ax                       ; n vrat znaku k tisku
hex:     and       al,0fh                   ; ni‘¨¡ tetr da znaku
         add       al,90h                   ; p©evod na znak HEX
         daa
         adc       al,40h
         daa
         mov       ah,6                     ; funkce pro v˜stup znaku
         mov       dl,al                    ; znak k v˜stupu na konzolu
         int       21h                      ; v˜stup znaku na konzolu
         ret



code     ENDS

;------------------------------------------------------------------------------
;                             Datov˜ segment
;------------------------------------------------------------------------------

data     SEGMENT

data     ENDS


         END       start               ; startovac¡ adresa

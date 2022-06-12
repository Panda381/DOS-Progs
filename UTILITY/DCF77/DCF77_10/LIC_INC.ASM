code     segment
         assume    cs:code,ds:code
         org       100h

; ------ na‡ten¡ souboru licence

Start:   call      readlic                  ; na‡ten¡ souboru licence
         jc        chyba                    ; nˆjak  chyba

; ------ zv˜¨en¡ licen‡n¡ho ‡¡sla

         mov       si,offset LicBuff+5
Start2:  dec       si
         inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"
         jbe       Start3
         mov       byte ptr ds:[si],"0"
         jmp       short Start2

; ------ kontroln¡ sou‡et licen‡n¡ho ‡¡sla

Start3:  mov       si,offset LicBuff
         mov       cx,10
         mov       al,0
Start6:  cmp       si,offset LicBuff+5
         je        Start7
         add       al,ds:[si]
         sub       al,"0"
Start7:  inc       si
         loop      Start6

         mov       ah,0
         mov       cl,10
         div       cl
         mov       al,5
         sub       al,ah
         jnc       Start8
         add       al,10
Start8:  add       al,"0"
         mov       ds:[si],al

; ------ z pis souboru licence

         call      WritLic                  ; z pis licence
         jc        chyba                    ; nˆjak  chyba

         mov       ax,4c00h
         int       21h

Chyba:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru licence
; -----------------------------------------------------------------------------

readlic  PROC      NEAR

; ------ na‡ten¡ souboru LICENCE.GEN

         mov       dx,offset SoubLic
         mov       ax,3d00h
         int       21h
         mov       dx,offset licftxt
         jc        readlic9

         mov       bx,ax
         mov       dx,offset LicBuff
         mov       cx,11
         mov       ah,3fh
         int       21h                      ; ‡ten¡ ze souboru
         mov       dx,offset readltxt
         jc        readlic9                 ; chyba ‡ten¡ licence

         cmp       ax,11
         stc
         jne       readlic9                 ; chybn  velikost souboru
         mov       ah,3eh
         int       21h

readlic9:ret

readlic  ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ souboru licence
; -----------------------------------------------------------------------------

writlic  proc      near

; ------ otev©en¡ souboru licence

         mov       dx,offset SoubLic
         xor       cx,cx
         mov       ah,3ch
         int       21h
         jc        writlic9
         mov       bx,ax

; ------ z pis licen‡n¡ho ‡¡sla

         mov       dx,offset LicBuff
         mov       cx,11
         mov       ah,40h
         int       21h
         jc        writlic9
         cmp       ax,11
         jne       writlic9

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h
writlic9:mov       dx,offset writltxt
         ret

writlic  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

licftxt  db        'Soubor LICENCE.NUM nenalezen !',13,7,10,'$'
readltxt db        'Chyba cteni ze souboru LICENCE.NUM !',13,7,10,'$'
writltxt db        'Chyba zapisu do souboru LICENCE.NUM !',13,7,10,'$'

SoubLic  db        'LICENCE.NUM',0          ; soubor s licenc¡

LicBuff  db        11 dup(0)                ; buffer pro na‡ten¡ lic. ‡¡sla

code     ends
         end       start

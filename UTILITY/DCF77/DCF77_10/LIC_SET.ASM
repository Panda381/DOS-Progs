
BuffSize EQU       10240

code     segment
         assume    cs:code,ds:code
         org       100h

; ------ na‡ten¡ zdrojov‚ho souboru

Start:   call      readsoub                 ; na‡ten¡ zdrojov‚ho souboru do pamˆti
         jc        chyba                    ; nˆjak  chyba

; ------ na‡ten¡ souboru licence

         call      readlic                  ; na‡ten¡ souboru licence
         jc        chyba                    ; nˆjak  chyba

; ------ nastaven¡ ‡¡sla licence v souboru

         mov       di,offset Buffer+4
         mov       si,offset LicBuff
         mov       cx,10
         cld
         mov       ah,0
Start2:  lodsb
         cmp       si,offset LicBuff+6
         je        Start3
         stosb
         sub       al,"0"
         add       ah,al
Start3:  loop      Start2

         mov       cl,10
         mov       al,ah
         mov       ah,0
         div       cl

         mov       al,5
         sub       al,ah
         jnc       Start4
         add       al,10
Start4:  add       al,"0"
         stosb

; ------ z pis souboru na disk

         call      writsoub                 ; z pis souboru na disk
         jc        chyba                    ; nˆjak  chyba

         mov       ax,4c00h
         int       21h

Chyba:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

; -----------------------------------------------------------------------------
;        na‡ten¡ vstupn¡ho souboru do pamˆti
; -----------------------------------------------------------------------------

readsoub proc      near

; ------ otev©en¡ souboru

         mov       dx,offset soub1
         mov       ax,3d00h
         int       21h
         jc        readsou8                 ; chyba - soubor nenalezen
         mov       bx,ax

; ------ na‡ten¡ souboru do bufferu

         mov       cx,BuffSize
         mov       dx,offset buffer
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         jc        readsou8                 ; chyba ‡ten¡ ze souboru
         mov       ds:[soubnum],ax          ; velikost souboru
         cmp       ax,BuffSize              ; mohl by b˜t soubor vˆt¨¡ ?
         cmc
         jc        readsou8                 ; chybn  velikost souboru

; ------ zji¨tˆn¡ data a ‡asu souboru

         mov       ax,5700h
         int       21h                      ; zji¨tˆn¡ data a ‡asu souboru
         jc        readsou8                 ; chyba
         mov       ds:[datum],dx            ; datum
         mov       ds:[cas],cx              ; ‡as

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

readsou8:mov       dx,offset readtxt
         ret

readsoub endp

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
;        z pis souboru na disk
; -----------------------------------------------------------------------------

writsoub proc      near

; ------ vytvo©en¡ souboru

         mov       dx,offset soub2
         mov       ah,3ch
         xor       cx,cx
         int       21h
         mov       dx,offset writtxt
         jc        writsou9                 ; soubor nelze vytvo©it
         mov       bx,ax

; ------ z pis souboru na disk

         mov       cx,ds:[soubnum]          ; velikost souboru
         mov       ah,40h
         mov       dx,offset buffer
         int       21h                      ; z pis souboru na disk
         mov       dx,offset writtxt
         jc        writsou9                 ; chyba z pisu
         cmp       ax,cx
         jb        writsou9                 ; chyba z pisu

; ------ nastaven¡ data a ‡asu souboru

         mov       dx,ds:[datum]            ; datum
         mov       cx,ds:[cas]              ; ‡as
         mov       ax,5701h
         int       21h                      ; nastaven¡ data a ‡asu
         mov       dx,offset writtxt
         jc        writsou9                 ; chyba z pisu

; ------ uzav©en¡ souboru

         mov       ah,3eh
         int       21h
         jc        writsou9

; ------ nastaven¡ atribut– souboru

         mov       dx,offset soub1
         mov       ax,4301h
         xor       cx,cx
         int       21h                      ; nulov n¡ atribut– souboru
         mov       dx,offset writtxt

writsou9:
         ret

writsoub endp

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

readtxt  db        'Chyba cteni ze souboru DCF77_.COM !',13,7,10,'$'
writtxt  db        'Chyba zapisu do souboru DCF77.COM !',13,7,10,'$'
licftxt  db        'Soubor LICENCE.NUM nenalezen !',13,7,10,'$'
readltxt db        'Chyba cteni ze souboru LICENCE.NUM !',13,7,10,'$'

datum    dw        0                        ; datum souboru
cas      dw        0                        ; ‡as souboru

soubnum  dw        0                        ; velikost souboru

soub1    db        'DCF77_.COM',0
soub2    db        'DCF77.COM',0
SoubLic  db        'LICENCE.NUM',0          ; soubor s licenc¡

LicBuff  db        11 dup(0)                ; buffer licen‡n¡ho ‡¡sla

buffer   db        BuffSize dup(0)

code     ends
         end       start

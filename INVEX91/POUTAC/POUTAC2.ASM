
code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       ax,16
         int       10h                      ; nastaven¡ videom¢du 16

         mov       dx,offset soubor
         mov       ax,3d00h
         int       21h
         jnc       Start1

         mov       dx,offset errtxt
         mov       ah,9
         int       21h
         int       20h

start1:  mov       ds:[Ident],ax            ; identifik tor
         mov       bx,ax

         mov       ax,2523h
         mov       dx,offset konec          ; konec programu
         int       21h                      ; p©edefinov n¡ INT 23h

         mov       dx,3dah
         in        al,dx                    ; synchronizace
         mov       dx,3c0h
         mov       al,0
         out       dx,al                    ; vypnut¡ videosign lu

         mov       ax,4200h
         xor       cx,cx
         mov       dx,9
         int       21h

         mov       ax,0a000h
         mov       ds,ax

         mov       ah,1
         xor       bx,bx
         call      readmap
         mov       ah,2
         mov       bx,1
         call      readmap
         mov       ah,4
         mov       bx,2
         call      readmap
         mov       ah,8
         mov       bx,3
         call      readmap

         push      cs
         pop       ds                       ; n vrat DS

         mov       ah,3eh
         mov       bx,ds:[Ident]
         int       21h                      ; uzav©en¡ souboru

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bp,ds:[46ch]             ; ‡asova‡
         pop       ds

start9:

         mov       dx,3dah
Startd:  in        al,dx                    ; synchronizace
         test      al,8
         jnz       Startd                   ; ‡ek n¡ na konec zpˆtn‚ho bˆhu

Startc:  in        al,dx                    ; synchronizace
         test      al,8
         jz        Startc                   ; ‡ek n¡ na zpˆtn˜ bˆh


         mov       si,ds:[UkazPal]          ; ukazatel palet
         mov       cx,14                    ; po‡et palet k p©edefinov n¡
         xor       bx,bx                    ; ukazatel registr–
Starta:  inc       bl                       ; zv˜¨en¡ ukazatele registr–


         mov       dx,3c0h
         mov       al,bl                    ; ‡¡slo registru
         out       dx,al                    ; nastaven¡ ‡¡sla registru
         mov       al,ds:[si+Palety]        ; hodnota pro nastaven¡ palety
         out       dx,al                    ; nastaven¡ palety
         inc       si                       ; zv˜¨en¡ ukazatele
         loop      Starta                   ; dal¨¡ registr

         mov       al,20h
         out       dx,al                    ; zapnut¡ videosign lu

         dec       word ptr ds:[UkazPal]    ; zv˜¨en¡ ukazatele
         jns       Startb
         mov       word ptr ds:[UkazPal],13
Startb:
         push      ds
         xor       ax,ax
         mov       ds,ax
Starte:  cmp       bp,ds:[46ch]             ; ‡asova‡
         je        Starte
         mov       bp,ds:[46ch]
         pop       ds

         mov       ah,1
         int       16h
         jz        start9

         xor       ax,ax
         int       16h


Konec:
         mov       dx,3dah
         in        al,dx                    ; synchronizace
         mov       dx,3c0h
         mov       al,20h
         out       dx,al                    ; zapnut¡ videosign lu

         int       20h



readmap:
         mov       dx,03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,ah
         out       dx,al

         mov       dx,03ceh
         mov       al,4
         out       dx,al
         inc       dx
         mov       al,bl
         out       dx,al

         mov       cx,350*80
         xor       dx,dx
         mov       ah,3fh
         mov       bx,cs:[Ident]
         int       21h

         ret


Palety   db        9                        ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        44                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        13                       ; 14 (nar–‘ovˆle modr )

         db        9                        ; 1 (modr )
         db        11                       ; 2 (svˆtle modr )
         db        27                       ; 3 (blankytn  mod©)
         db        19                       ; 4 (modrozelen )
         db        26                       ; 5 (namodrale zelen )
         db        50                       ; 6 (zelen )
         db        22                       ; 7 (‘lutozelen )
         db        54                       ; 8 (‘lut )
         db        38                       ; 9 (oran‘ov )
         db        52                       ; 10 (oran‘ovˆ ‡erven )
         db        44                       ; 11 (‡erven )
         db        37                       ; 12 (r–‘ov )
         db        45                       ; 13 (svˆtle r–‘ov )
         db        13                       ; 14 (nar–‘ovˆle modr )

UkazPal  dw        0                        ; ukazatel palet

ident    dw        0                        ; identifik tor souboru

soubor   db        'POUTAC.SCR',0

errtxt   db        'Nenalezen soubor POUTAC.SCR !!!',13,10,'$'

code     ends
         end       start

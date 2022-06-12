
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld

Start1:  mov       dx,offset HelpTxt
         mov       al,-1
         jcxz      Start2
         lodsb
         dec       cx
         sub       al,"1"
         cmp       al,8
         jae       Start1
         mov       ah,0

         xchg      ax,dx                    ; DX <- ‡¡slo portu COM
         mov       ax,300h
         int       14h

         or        al,al
         mov       al,0                     ; je OK
         mov       dx,offset TxtOK
         js        Start2
         inc       ax
         mov       dx,offset TxtNO

Start2:  push      ax
         mov       ah,9
         int       21h
         pop       ax
         mov       ah,4ch
         int       21h

HelpTxt  db        'TESTDCD V1.0 - test signalu DCD; (c) Miroslav Nemecek',13,10
         db        ' Zadejte jako parametr cislo portu COM 1 az 8.',13,10
         db        ' Bude navracen navratovy kod 0=je CARRIER, 1=neni.',13,10
         db        '$'

TxtOK    db        'OK',13,10,'$'
TxtNO    db        'NO CARRIER',13,10,'$'

Code     ENDS
         END       Start

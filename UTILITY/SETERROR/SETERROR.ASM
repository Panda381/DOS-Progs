Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

Start:   mov       si,81h
         mov       cl,ds:[si-1]
         mov       ch,0
         cld
         xor       bx,bx

         cmp       cl,1
         ja        Start1

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         int       20h

Start1:  jcxz      Start8
         lodsb
         dec       cx
         sub       al,"0"
         jc        Start1
         cmp       al,9
         ja        Start1
         xchg      ax,bx
         mov       ah,10
         mul       ah
         add       bl,al
         jmp       short Start1

Start8:  xchg      ax,bx
         mov       ah,4ch
         int       21h


UvTxt    db        'SETERROR V1.0 - nastaven¡ ERRORLEVEL; (c) Miroslav Nemecek',13,10
         db        'Zadejte jako parametr cislo navratoveho kodu.',13,10
         db        '$'

Code     ENDS
         END       Start

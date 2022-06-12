
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ p©¡prava k rozboru p©¡kazov‚ho © dku

         mov       si,81h
         mov       bl,ds:[si-1]
         mov       bh,0
         mov       ds:[si+bx],bh
         cld

; ------ nalezen¡ ozna‡en¡ disku

Start1:  lodsb
         cmp       al,9
         je        Start1
         cmp       al," "
         je        Start1
         jb        Chyba                    ; nen¡ nic zad no

; ------ konverze na velk‚ p¡smeno

         cmp       al,"a"
         jb        Start2
         cmp       al,"z"
         ja        Start2
         sub       al,32

; ------ kontrola ‡¡sla disku

Start2:  sub       al,"A"
         jb        Chyba
         cmp       al,32
         ja        Chyba
         xchg      ax,dx                    ; DL <- ‡¡slo disku

; ------ nalezen¡ znaku p©ep¡na‡e

Start3:  lodsb
         cmp       al,9
         je        Start3
         cmp       al,":"
         je        Start3
         cmp       al," "
         je        Start3
         jb        Chyba

; ------ nastaven¡ disku

         cmp       al,"+"
         je        Start4                   ; zapnut¡ disku
         cmp       al,"-"
         mov       ax,5f08h
         je        Start5                   ; vypnut¡ disku

; ------ chyba zad n¡

Chyba:   mov       dx,offset HelpTxt
         mov       ah,9
         int       21h
         int       20h

; ------ zapnut¡/vypnut¡ disku

Start4:  mov       ax,5f07h                 ; zapnut¡ disku
Start5:  int       21h                      ; zapnut¡/vypnut¡ disku
         int       20h

UvTxt    db        'DISKOFFX V1.0 - vypnuti disku; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        13,10
         db        'Program umoznuje vypnuti pristupu k diskum.',13,10
         db        'Vyzaduje operacni system MS DOS verze 5.00 a vyssi.',13,10
         db        'Zadejte jako parametr programu oznaceni disku a',13,10
         db        'znak "+" pro vypnuti nebo "-" pro zapnuti disku.',13,10
         db        13,10
         db        '$'

Code     ENDS
         END       Start

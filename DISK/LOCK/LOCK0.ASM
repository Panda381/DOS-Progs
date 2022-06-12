code     segment
         assume    cs:code,ds:code
         org       100h

Start:

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         xor       cx,cx
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku textu souboru/adres ©e

         mov       dx,offset HelpTxt
Start1:  jcxz      Start8                   ; nen¡ nic zad no
         cld
         lodsb
         dec       cx
         cmp       al,13
         je        Start8
         cmp       al," "
         je        Start1
         cmp       al,9
         je        Start1
         mov       dx,si                    ; za‡ tek textu
         dec       dx

; ------ nalezen¡ konce textu

Start2:  jcxz      Start4
         cld
         lodsb
         dec       cx
         cmp       al,13
         je        Start3
         cmp       al," "
         je        Start3
         cmp       al,9
         jne       Start2

Start3:  dec       si
Start4:  mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu

; ------ poskytnut¡ atribut– adres ©e

         mov       ax,4300h
         int       21h                      ; poskytnut¡ atribut– adres ©e
         jc        Start7                   ; chyba - soubor nenalezen

; ------ nastaven¡ atirbut– adres ©e

         and       cl,not 2 + 10h           ; zru¨en¡ atributu adres ©e
         mov       ax,4301h
         int       21h                      ; uzam‡en¡ adres ©e
         mov       dx,offset ErrTxt         ; chyba
         jc        Start8                   ; chyba
         int       20h

; ------ chyba

Start7:  mov       dx,offset FndTxt
Start8:  mov       ah,9
         int       21h
         int       20h

HelpTxt  db        'LOCK0 - odemknuti souboru/adresare; (c) Miroslav Nemecek',13,10
         db        'Zadejte jmeno souboru/adresare k odemknuti !',13,10,'$'

FndTxt   db        'Chybne zadani - soubor/adresar nenalezen !',13,10,'$'

ErrTxt   db        'Chyba - soubor/adresar nelze odemknout !',13,10,'$'

code     ends
         end       start

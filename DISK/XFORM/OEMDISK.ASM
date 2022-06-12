
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ p©¡prava k rozboru p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld

; ------ nalezen¡ ozna‡en¡ disku

Start1:  jcxz      Start2                   ; nen¡ dal¨¡ znak
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         cmp       al," "
         jbe       Start1                   ; vypu¨tˆn¡ mezery

; ------ test platnosti znaku

         or        al,20h                   ; konverze na mal‚ p¡smeno
         sub       al,"a"
         jb        Start2                   ; neplatn˜ disk
         cmp       al,32                    ; maxim ln¡ ‡¡slo disku
         jb        Start3                   ; ‡¡slo disku je OK

; ------ zobrazen¡ n povˆdy

Start2:  mov       dx,offset HelpTxt
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ p©¡prava parametr– disku

Start3:  mov       ds:[Disk],al             ; £schova ‡¡sla disku
         add       ds:[OemTxt1],al          ; ozna‡en¡ disku
         add       ds:[ReadTxt1],al         ; ozna‡en¡ disku

; ------ na‡ten¡ sektoru bˆ‘nou slu‘bou INT 25h

         mov       bx,offset Buffer         ; buffer k na‡ten¡ sektoru
         mov       cx,1                     ; po‡et sektor– k na‡ten¡
         xor       dx,dx                    ; ‡¡slo sektoru BOOT
         mov       ds:[Zasobnik],sp         ; £schova registru SP
         int       25h                      ; pokus o na‡ten¡ BOOT sektoru
         push      cs
         pop       ds
         mov       sp,ds:[Zasobnik]         ; n vrat registru SP
         jnc       Start4                   ; sektor na‡ten OK

; ------ na‡ten¡ sektoru roz¨¡©enou slu‘bou INT 25h

         mov       al,ds:[Disk]             ; ‡¡slo disku
         mov       cx,-1                    ; p©¡znak roz¨¡©en‚ slu‘by
         mov       bx,offset Paket          ; paket roz¨¡©en˜ch informac¡
         mov       ds:[PaketDS],ds          ; segment adresy bufferu
         int       25h                      ; druh˜ pokus o na‡ten¡ BOOT sektoru
         push      cs
         pop       ds
         mov       sp,ds:[Zasobnik]         ; n vrat registru SP
         mov       dx,offset ReadTxt        ; chyba ‡ten¡
         jc        Chyba                    ; chyba ‡ten¡ sektoru

; ------ p©enos OEM textu

Start4:  push      cs
         pop       es                       ; ES <- CS
         mov       cx,8                     ; po‡et znak– k p©enosu
         mov       si,offset Buffer + 3     ; text OEM
         mov       di,offset OEMTxt2
         cld
         rep       movsb                    ; p©enos textu

; ------ zobrazen¡ informac¡ OEM

         mov       dx,offset OEMTxt
         mov       ah,9
         int       21h
         int       20h

Zasobnik dw        0                        ; uschovan˜ registr SP

Disk     db        0                        ; po‘adovan˜ disk

UvTxt    db        'OEMDISK V1.0 - zobrazeni firemni identifikace disku; (c) Miroslav Nemecek',13,10,'$'

HelpTxt  db        '   Zadejte oznaceni disku (napr. OEMDISK D:),',13,10
         db        '   jehoz identifikaci chcete zobrazit.',13,10,'$'

ReadTxt  db        'CHYBA - disk '
ReadTxt1 db        'A: neni pristupny !',13,10,'$'

OemTxt   db        'Firemni identifikace disku '
OemTxt1  db        'A: je "'
OemTxt2  db        8 dup(" "),'".',13,10,'$'

Paket    label     word                     ; paket pro roz¨¡©en‚ informace
         dd        0                        ; ‡¡slo sektoru
         dw        1                        ; po‡et sektor–
         dw        Buffer                   ; adresa bufferu - offset
PaketDS  dw        0                        ; adresa bufferu - segment

Buffer   db        512 dup(" ")             ; buffer k na‡ten¡ BOOT sektoru

Code     ENDS
         END       Start


; *****************************************************************************
;
;                     Rozdˆlova‡ soubor–
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h
start:
         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

                                          ;* p©¡prava p©¡kazov‚ho © dku
         xor       bx,bx
         mov       bl,ds:[80h]              ; po‡et znak–
         mov       si,81h                   ; za‡ tek textu parametru
         mov       byte ptr ds:[bx+si],0    ; ozna‡en¡ konce textu

                                          ;* nalezen¡ za‡ tku jm‚na souboru
cut1:    lodsb
         cmp       al,9
         je        cut1                     ; tabel tor - ignorov n¡
         cmp       al," "
         je        cut1                     ; mezera - ignorov n¡
         jb        cuterr                   ; konec textu
         mov       dx,si
         dec       dx                       ; za‡ tek jm‚na souboru

                                          ;* ozna‡en¡ konce jm‚na souboru
         xor       di,di                    ; adresa p©¡pony
cut2:    lodsb
         cmp       al,"."
         jne       cut20
         mov       di,si
         dec       di                       ; ukazatel na te‡ku
cut20:   cmp       al,"/"
         jne       cut21
         xor       di,di                    ; byl to adres © - te‡ka neplat¡
cut21:   cmp       al," "
         ja        cut2                     ; nen¡ konec jm‚na - dal¨¡ znak
         dec       si                       ; n vrat posledn¡ho znaku
         or        di,di                    ; byla nalezena te‡ka ?
         jnz       cut22                    ; byla nalezena te‡ka
         mov       di,si                    ; adresa konce jm‚na
cut22:   mov       byte ptr ds:[si],0       ; ozna‡en¡ konce jm‚na

                                          ;* otev©en¡ zdrojov‚ho souboru
cut3:    mov       ax,3d00h                 ; otev©en¡ pro ‡ten¡
         int       21h                      ; otev©en¡ zdrojov‚ho souboru
         mov       ds:[inpid],ax            ; identifik tor souboru
         jnc       cut4                     ; soubor otev©en OK

                                          ;* chyba - soubor nenalezen
cuterr:  mov       dx,offset fndtxt
error:   mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h

cut4:                                     ;* zobrazen¡ p©¡pony souboru
         push      dx
         mov       word ptr ds:[pripona0],256*"$"+13
         mov       dx,offset pripona+1
         mov       ah,9
         int       21h
         mov       word ptr ds:[pripona0],256*"j"+" "
         pop       dx

                                          ;* na‡ten¡ ‡ sti souboru
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ BREAK

         push      dx                       ; £schova jm‚na souboru
         mov       bx,ds:[inpid]            ; identifik tor souboru
         mov       cx,8000h                 ; velikost dat k na‡ten¡
         mov       dx,offset buffer         ; buffer k na‡ten¡ dat
         mov       ah,3fh
         int       21h                      ; na‡ten¡ ‡ sti souboru
         pop       dx                       ; n vrat jm‚na souboru
         mov       cx,ax                    ; po‡et na‡ten˜ch bajt–
         jnc       cut5                     ; soubor na‡ten OK

         mov       dx,offset readtxt
         jmp       short error              ; chyba ‡ten¡

                                          ;* sestaven¡ jm‚na souboru
cut5:    jcxz      cuta                     ; konec souboru
         mov       ax,word ptr ds:[pripona] ; prvn¡ 2 bajty p©¡pony
         mov       ds:[di],ax
         mov       ax,word ptr ds:[pripona+2]
         mov       ds:[di+2],ax
         mov       byte ptr ds:[di+4],0     ; ukon‡ovac¡ 0

         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ BREAK

                                          ;* test, zda soubor ji‘ existuje
         push      cx
         mov       ah,4eh
         int       21h                      ; test, zda soubor existuje
         pop       cx
         jc        cut52                    ; soubor neexistuje - OK
         mov       dx,offset exxtxt
         jmp       short error              ; chyba - soubor ji‘ existuje

                                          ;* vytvo©en¡ souboru
cut52:   push      cx
         xor       cx,cx                    ; atributy souboru
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ souboru
         pop       cx
         mov       bx,ax
         jnc       cut7                     ; soubor vytvo©en OK

cut6:    mov       dx,offset writetxt
         jmp       short error

                                          ;* z pis dat do souboru
cut7:    push      dx
         mov       dx,offset buffer
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         pop       dx
         jc        cut6                     ; chyba z pisu do souboru
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         je        cut8                     ; po‡et bajt– souhlas¡

                                          ;* chyba - disk je pln˜
         mov       dx,offset fulltxt
         jmp       error

                                          ;* uzav©en¡ v˜stupn¡ho souboru
cut8:    mov       ah,3eh
         int       21h

                                          ;* zv˜¨en¡ jm‚na v˜stupn¡ho souboru
cut9:
         inc       byte ptr ds:[pripona+3]
         cmp       byte ptr ds:[pripona+3],"9"
         jbe       cut99
         mov       byte ptr ds:[pripona+3],"0"
         inc       byte ptr ds:[pripona+2]
         cmp       byte ptr ds:[pripona+2],"9"
         jbe       cut99
         mov       byte ptr ds:[pripona+2],"0"
         inc       byte ptr ds:[pripona+1]
cut99:   jmp       cut4


cuta:    mov       bx,ds:[inpid]            ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h
         mov       dx,offset kontxt
         mov       ah,9
         int       21h
         mov       ax,4c00h
         int       21h


inpid    dw        0                        ; identifik tor vstupn¡ho souboru


uvtxt    db        'CUTTER V1.0; (c) Miroslav Nemecek',13,10,'$'

fndtxt   db        'Soubor k rozdeleni nenalezen !',13,10,'$'
readtxt  db        'Chyba cteni ze souboru !',13,10,'$'
writetxt db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
fulltxt  db        'Disk je plny !',13,10,'$'
exxtxt   db        'Vystupni soubor s priponou '
pripona  db        '.000'                   ; jm‚no p©¡pony
pripona0 db        ' jiz existuje !',13,10,'$'

kontxt   db        '   ',13,'$'

buffer   label     byte                     ; buffer k na‡ten¡ souboru

code     ends
         end       start

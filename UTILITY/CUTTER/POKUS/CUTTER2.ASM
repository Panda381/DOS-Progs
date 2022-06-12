
; *****************************************************************************
;
;                     Rozdˆlova‡ soubor–
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   xor       bx,bx
         mov       si,81h                   ; za‡ tek textu parametru
         mov       bl,ds:[si-1]             ; po‡et znak–
         mov       byte ptr ds:[bx+si],0    ; ozna‡en¡ konce textu

; ------ inicializace registr–

         push      cs
         pop       ds
         mov       ds:[SegPSP],es           ; £schova segmentu PSP
         push      cs
         pop       ds

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset uvtxt
         mov       ah,9
         int       21h

; ------ nalezen¡ za‡ tku jm‚na souboru

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         call      InpSpc                   ; nalezen¡ za‡ tku jm‚na souboru
         jnc       Start3                   ; je nˆco zad no OK

; ------ chyba - zobrazen¡ n povˆdy

Start1:  mov       dx,offset HelpTxt        ; text n povˆdy
Start2:  mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         mov       ax,4c01h                 ; p©¡znak chyby zad n¡
         int       21h                      ; n vrat z programu s chybou

; ------ p©enos jm‚na souboru do bufferu

Start3:  mov       di,offset Soubor         ; buffer k ulo‘en¡ jm‚na souboru
Start4:  call      InpChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jbe       Start5                   ; konec textu
         cld
         stosb                              ; ulo‘en¡ bajtu do bufferu
         jmp       short Start4             ; p©enesen¡ dal¨¡ho znaku jm‚na
Start5:  mov       al,0                     ; koncov  0
         stosb                              ; ozna‡en¡ konce textu

; ------ test, zda je jako druh˜ parametr zad n znak "!"

         call      InpSpc                   ; vypu¨tˆn¡ mezer mezi parametry
         jc        Start8                   ; nen¡ dal¨¡ znak - v¨e OK
         cmp       al,"!"                   ; je zad n parametr "!" ?
         jne       Start6                   ; nen¡ zad n parametr "!"
         or        byte ptr ds:[Param],1    ; p©¡znak spojov n¡ souboru


Start6:


Start7:
Start8:




; ------ nalezen¡ p©¡pony jm‚na souboru





cut1:



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


; -----------------------------------------------------------------------------
;        vstup ‡¡sla z p©¡kazov‚ho © dku DX:AX (CY=nezad no)
; -----------------------------------------------------------------------------

InpNum   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      cx

; ------ p©¡prava registr–

         xor       bx,bx                    ; st©ada‡ HIGH
         xor       cx,cx                    ; st©ada‡ LOW

; ------ na‡ten¡ prvn¡ ‡¡slice

         call      InpSpc                   ; vypu¨tˆn¡ mezer z textu
         call      InpNm                    ; na‡ten¡ prvn¡ ‡¡slice
         jc        InpNum9                  ; ‡¡slo nen¡ zad no

; ------ vyn soben¡ st©ada‡e 10x

InpNum1: push      ax                       ; £schova ‡¡sla
         mov       ax,10                    ; ‡¡seln  soustava
         mul       bx                       ; vyn soben¡ st©ada‡e HIGH
         xchg      ax,bx                    ; £schova nov‚ho st©ada‡e HIGH
         mov       ax,10                    ; ‡¡seln  soustava
         mul       cx                       ; vyn soben¡ st©ada‡e LOW
         xchg      ax,cx                    ; £schova nov‚ho st©ada‡e LOW
         add       bx,dx                    ; p©enos do HIGH slova st©ada‡e
         pop       ax

; ------ p©i‡ten¡ nov‚ zadan‚ ‡¡slice

         mov       ah,0                     ; AX = zadan  ‡¡slice
         add       cx,ax                    ; p©i‡ten¡ nov‚ ‡¡slice LOW
         adc       bx,0                     ; p©enos do vy¨¨¡ho slova st©ada‡e

; ------ na‡ten¡ nov‚ ‡¡slice

         call      InpNm                    ; na‡ten¡ dal¨¡ ‡¡slice
         jnc       InpNum1                  ; je dal¨¡ ‡¡slice
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

InpNum9: mov       ax,cx                    ; ‡¡slo LOW
         mov       dx,bx                    ; ‡¡slo HIGH
         pop       cx
         pop       bx
         ret

InpNum   ENDP

; -----------------------------------------------------------------------------
;        vstup jedn‚ ‡¡slice z p©¡kazov‚ho © dku (CY=nen¡ platn  ‡¡slice)
; -----------------------------------------------------------------------------

InpNm    PROC      NEAR

         call      InpChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        InpNm9                   ; je konec © dku, nen¡ dal¨¡ znak
         cmp       al,"0"                   ; je ‡¡slice ?
         jb        InpNm9                   ; nen¡ ‡¡slice
         cmp       al,"9"+1                 ; je ‡¡slice ?
         cmc
         jc        InpNm9                   ; nen¡ ‡¡slice
         sub       al,"0"                   ; korekce na ‡¡slo
InpNm9:  ret

InpNm    ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

InpSpc   PROC      NEAR

         call      InpChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        InpSpc2                  ; konec © dku
         je        InpSpc                   ; mezera - p©esko‡en¡
         dec       si                       ; n vrat posledn¡ho znaku
InpSpc2: ret

InpSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku SI (CY=nen¡ dal¨¡ znak)
; -----------------------------------------------------------------------------

InpChr   PROC      NEAR

; ------ na‡ten¡ znaku z p©¡kazov‚ho © dku

         push      ds
         mov       ds,ds:[SegPSP]
         cld
         lodsb

; ------ n hrada tabel toru mezerou

         cmp       al,9                     ; je tabel tor ?
         jne       InpChr1
         mov       al," "                   ; n hrada tabel toru mezerou

; ------ kontrola, zda je konec © dku

InpChr1: cmp       al," "                   ; konec © dku nebo oddˆlova‡ ?
         jae       InpChr9                  ; je platn˜ znak nebo oddˆlova‡
         dec       si                       ; n vrat znaku konce © dku

; ------ n vrat registr–

InpChr9: pop       ds
         ret

InpChr   ENDP

; -----------------------------------------------------------------------------
;                                data
; -----------------------------------------------------------------------------

InpId    dw        0                        ; identifik tor vstupn¡ho souboru

NumBlok  dw        0                        ; po‡et zadan˜ch blok–

Param    db        0                        ; parametry
                                            ;  bit 0: 1=zad n parametr "/Bn"
                                            ;  bit 1: 1=zad n parametr "/Nn"
                                            ;  bit 2: 1=zad n parametr "/W"
                                            ;  bit 3: 1=zad n povel "/In"
                                            ;  bit 4: 1=zad n povel "/Dn"
                                            ;  bit 5: 1=zad n parametr "/T"
                                            ;  bit 6: 1=zad n parametr "/B"
                                            ;  bit 7: 1=zad n parametr "/!"

SegPSP   dw        0                        ; segment PSP
BlokSize dd        8000h                    ; velikost bloku souboru (bajt–)

uvtxt    db        'CUTTER V1.10 - rozsekani souboru; (c) Miroslav Nemecek',13,10,'$'

helptxt  db        'Zadejte: soubor - specifikace souboru k rozsekani/spojeni',13,10
         db        '         /Bn    - n=velikost bloku (implicitne 32KB)',13,10
         db        '         /Nn    - rozsekani na n bloku (implicitne podle /Bn)',13,10
         db        '         /In    - vlozeni bloku s cislem n',13,10
         db        '         /Dn    - vypusteni bloku s cislem n',13,10
         db        '         /W     - vystupni soubory se prepisuji',13,10
         db        '         /T     - textovy soubor',13,10
         db        '         /B     - binarni soubor',13,10
         db        '         /!     - spojeni bloku do jednoho souboru',13,10
         db        '$'

fndtxt   db        'Zadany soubor nenalezen !',13,10,'$'
readtxt  db        'Chyba cteni ze souboru !',13,10,'$'
writetxt db        'Chyba zapisu do vystupniho souboru !',13,10,'$'
fulltxt  db        'Disk je plny !',13,10,'$'
exxtxt   db        'Vystupni soubor s priponou '
pripona  db        '.000'                   ; jm‚no p©¡pony
pripona0 db        ' jiz existuje !',13,10,'$'

kontxt   db        '   ',13,'$'

AdrExt   dw        ?                        ; adresa p©¡pony jm‚na souboru
Soubor   db        80h + 20 dup(?)          ; zadan‚ jm‚no souboru + rezerva

code     ends

; *****************************************************************************
;
;                              datov˜ buffer
;
; *****************************************************************************

BuffSeg  SEGMENT
         db        0ffffh dup(?)            ; datov˜ bufferu
BuffSeg  ENDS

; *****************************************************************************
;
;                                 z sobn¡k
;
; *****************************************************************************

Zasob    SEGMENT   Stack
         db        1000h dup(?)
Zasob    ENDS

         END       Start

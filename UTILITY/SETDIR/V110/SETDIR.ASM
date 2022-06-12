
;             Nastaven¡ (vytvo©en¡) adres ©e

                                            ; n vratov‚ k¢dy:
                                            ;   0 = OK
                                            ;   1 = p©eru¨en¡ Ctrl-Break
                                            ;   2 = chybn‚ zad n¡ disku
                                            ;   3 = chybn‚ zad n¡ adres ©e
                                            ;   4 = chybn˜ soubor jm‚na adres ©e
                                            ;   5 = nen¡ nic zad no

code     segment
         assume cs:code,ds:code
         org       100h
start:

; ------ definice obsluhy p©eru¨en¡ programu

         mov       dx,offset prerus         ; p©eru¨en¡ programu
         mov       ax,2523h
         int       21h                      ; p©edefinov n¡ obsluhy p©eru¨en¡

; ------ p©¡prava p©¡kazov‚ho © dku k rozboru

         cld                                ; smˆr nahoru
         mov       si,81h                   ; za‡ tek zadan‚ho textu
         xor       bx,bx                    ; BX <- 0
         mov       bl,ds:[80h]              ; po‡et znak– zadan‚ho textu
         mov       byte ptr ds:[si+bx],0    ; ozna‡en¡ konce textu

; ------ nalezen¡ za‡ tku zad n¡ - test, zda je nˆco zad no

         call      outspc                   ; vypustˆn¡ oddˆlovac¡ch mezer
         jnc       start1                   ; je nˆjak‚ zad n¡

; ------ chyba zad n¡ - nen¡ ‘ dn˜ text

start11: mov       dx,offset errtxt
         mov       ah,9
         int       21h
         mov       al,5                     ; k¢d chyby - nen¡ nic zad no
         jmp       konec

; ------ test, zda je odkaz na jin˜ soubor

start1:  cmp       byte ptr ds:[si],"@"     ; je odkaz na jin˜ soubor ?
         jne       start3                   ; nen¡ odkaz na jin˜ soubor

; ------ p©¡prava jm‚na souboru - ozna‡en¡ konce jm‚na

         call      inpch                    ; zru¨en¡ znaku "@"
         call      outspc                   ; vypustˆn¡ oddˆlovac¡ch mezer
         mov       dx,si                    ; za‡ tek jm‚na souboru
start2:  call      inpch                    ; na‡ten¡ dal¨¡ho znaku
         jc        start23                  ; konec jm‚na
         jne       start2                   ; nalezen¡ konce textu
         dec       si                       ; n vrat posledn¡ho znaku
start23: mov       byte ptr ds:[si],0       ; ozna‡en¡ konce zad n¡

; ------ na‡ten¡ zadan‚ho souboru

         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         mov       bx,ax                    ; identifik tor souboru
start24: mov       al,4                     ; chyba - chybn˜ soubor specifikace
         jc        konec                    ; soubor nenalezen
         mov       dx,offset buffer         ; buffer k na‡ten¡ souboru
         mov       cx,4000h                 ; max. d‚lka souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ souboru
         jc        start24                  ; chyba na‡ten¡ souboru
         mov       di,ax                    ; po‡et na‡ten˜ch bajt–
         mov       byte ptr ds:[buffer+di],0 ; ozna‡en¡ konce textu
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         mov       si,offset buffer         ; za‡ tek textu v pamˆti
         call      outspc                   ; vypustˆn¡ mezer z textu
         jc        start24                  ; nen¡ nic zad no - chybn˜ soubor

; ------ nastaven¡ disku

start3:  cmp       byte ptr ds:[si+1],":"   ; je to ozna‡en¡ disku ?
         jne       start4                   ; disk nen¡ zad n
         call      inpch                    ; na‡ten¡ ozna‡en¡ disku
         sub       al,"A"                   ; korekce na ‡¡slo disku
         mov       dl,al                    ; ‡¡slo po‘adovan‚ho disku
         mov       ah,0eh
         int       21h                      ; nastaven¡ po‘adovan‚ho disku
         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         cmp       al,dl                    ; opravdu se disk nastavil ?
         mov       al,2                     ; k¢d chyby - chybn‚ zad n¡ disku
         jne       konec                    ; bylo chybn‚ zad n¡ disku
         call      inpch                    ; p©esko‡en¡ znaku ":"

; ------ nastaven¡ z kladn¡ho adres ©e

start4:  cmp       byte ptr ds:[si],"\"     ; je z kladn¡ adres © ?
         jne       start5
         inc       si                       ; p©esko‡en¡ znaku "\"
         mov       dx,offset rootdir        ; z kladn¡ adres ©
         mov       ah,3bh
         int       21h                      ; nastaven¡ z kladn¡ho adres ©e

; ------ nalezen¡ konce podadres ©e

start5:  mov       dx,si                    ; ozna‡en¡ za‡ tku podadres ©e
start6:  call      inpch                    ; na‡ten¡ dal¨¡ho znaku
         jc        start8                   ; nen¡ dal¨¡ znak
         je        start7                   ; je oddˆlova‡ - konec textu
         cmp       al,"\"                   ; je oddˆlova‡ podadres ©– ?
         jne       start6                   ; nen¡ podadres © - dal¨¡ znak
start7:  mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce textu

; ------ vytvo©en¡ a nastaven¡ po‘adovan‚ho podadres ©e

start8:  xor       al,al                    ; k¢d chyby - OK
         cmp       si,dx                    ; je nˆjak˜ znak ?
         je        konec                    ; operace OK
         mov       ah,39h
         int       21h                      ; vytvo©en¡ po‘adovan‚ho adres ©e
         mov       ah,3bh
         int       21h                      ; nastaven¡ nov‚ho podadres ©e
         jnc       start5                   ; operace OK
         xor       al,al
         inc       dx
         cmp       si,dx
         je        konec                    ; byla mezera nebo znak "\"
         mov       al,3                     ; k¢d chyby - chyba adres ©e
         jmp       short konec              ; konec s chybou


prerus:  mov       al,1
konec:   mov       ah,4ch
         int       21h

; --------

outspc:  call      inpch
         jc        outspc2
         je        outspc                   ; vypustˆn¡ mezer
         dec       si
outspc2: ret

; -------

inpch:   mov       al,ds:[si]
         or        al,al
         jz        inpch2
         cmp       al,13
         je        inpch2
         inc       si
         cmp       al,"a"
         jb        inpch0
         cmp       al,"z"
         ja        inpch0
         sub       al,32
inpch0:  cmp       al," "
         je        inpch1
         cmp       al,9
         jne       inpch1
         mov       al," "
inpch1:  clc
         ret


inpch2:  mov       byte ptr ds:[si],0       ; ozna‡en¡ konce textu
         stc
         ret

rootdir  db        "\",0                    ; z kladn¡ adres ©

errtxt   db        'SETDIR V1.10 - nastaveni/vytvoreni adresare; (c) Miroslav Nemecek'
         db        13,10,'parametr: jmeno_pozadovaneho_adresare',13,10
         db        '    nebo: @soubor_se_jmenem_adresare',13,10,'$'

buffer   label     byte                     ; buffer k na‡ten¡ souboru

code     ends
         end       start

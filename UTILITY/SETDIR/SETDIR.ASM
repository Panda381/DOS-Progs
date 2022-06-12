                                            ; n vratov‚ k¢dy:
                                            ;   0 = OK
                                            ;   1 = pýeruçen¡ Ctrl-Break
                                            ;   2 = chybn‚ zad n¡ disku
                                            ;   3 = chybn‚ zad n¡ adres ýe
                                            ;   4 = chybnì soubor jm‚na adres ýe
                                            ;   5 = nen¡ nic zad no
Code     SEGMENT
         ASSUME cs:Code,ds:Code
         ORG       100h

; ------ £schova Ÿ¡sla verze DOS

Start:   mov       ah,30h
         int       21h                      ; naŸten¡ Ÿ¡sla DOS
         mov       ds:[VerzeDOS],al         ; Ÿ¡slo verze DOS

; ------ definice obsluhy pýeruçen¡ programu

         mov       dx,offset INT23          ; pýeruçen¡ programu
         mov       ax,2523h
         int       21h                      ; pýedefinov n¡ obsluhy pýeruçen¡

; ------ pý¡prava pý¡kazov‚ho ý dku

         cld                                ; smØr nahoru
         mov       si,81h                   ; zaŸ tek zadan‚ho textu
         mov       bh,0                     ; BH <- 0
         mov       bl,ds:[si-1]             ; poŸet znak… zadan‚ho textu
         mov       byte ptr ds:[si+bx],bh   ; oznaŸen¡ konce textu
         call      PrepTxt                  ; pý¡prava pý¡kazov‚ho ý dku
         jnc       Start2                   ; je nØjak‚ zad n¡

; ------ chyba zad n¡ - nen¡ § dnì text

Start1:  mov       dx,offset ErrTxt
         mov       ah,9
         int       21h
         mov       al,5                     ; k¢d chyby - nen¡ nic zad no
Start14: jmp       Konec

; ------ test, zda je odkaz na jinì soubor

Start2:  cmp       byte ptr ds:[si],"@"     ; je odkaz na jinì soubor ?
         jne       start3                   ; nen¡ odkaz na jinì soubor

; ------ pý¡prava jm‚na souboru

         inc       si                       ; pýeskoŸen¡ znaku "@"
         call      PrepTxt                  ; pý¡prava jm‚na souboru
         jc        Start1                   ; chyba zad n¡

; ------ naŸten¡ zadan‚ho souboru

         mov       dx,si                    ; DX <- jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru
         xchg      ax,bx                    ; identifik tor souboru
Start24: mov       al,4                     ; chyba - chybnì soubor specifikace
         jc        start14                  ; soubor nenalezen
         mov       dx,offset Buffer         ; buffer k naŸten¡ souboru
         mov       cx,500                   ; max. d‚lka souboru
         mov       ah,3fh
         int       21h                      ; naŸten¡ souboru
         jc        Start24
         xchg      ax,di                    ; poŸet naŸtenìch bajt…
         mov       byte ptr ds:[Buffer+di],0 ; oznaŸen¡ konce textu
         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru

; ------ pý¡prava textu

         mov       si,offset buffer         ; zaŸ tek textu v pamØti
         call      PrepTxt                  ; pý¡prava textu
         jc        start24                  ; nen¡ nic zad no - chybnì soubor

; ------ nastaven¡ disku

Start3:  cmp       byte ptr ds:[si+1],":"   ; je to oznaŸen¡ disku ?
         jne       Start4                   ; disk nen¡ zad n
         cld
         lodsw                              ; naŸten¡ disku + oddØlovŸ ":"
         dec       ax                       ; relativn¡ Ÿ¡slo disku
         and       al,1fh                   ; Ÿ¡slo disku
         xchg      ax,dx                    ; DL <- Ÿ¡slo po§adovan‚ho disku
         mov       ah,0eh
         int       21h                      ; nastaven¡ po§adovan‚ho disku
         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         cmp       al,dl                    ; opravdu se disk nastavil ?
         mov       al,2                     ; k¢d chyby - chybn‚ zad n¡ disku
         jne       Konec                    ; bylo chybn‚ zad n¡ disku

; ------ nastaven¡ z kladn¡ho adres ýe

Start4:  cmp       byte ptr ds:[si],"\"     ; je z kladn¡ adres ý ?
         jne       Start5
         inc       si                       ; pýeskoŸen¡ znaku "\"
         mov       dx,offset RootDir        ; z kladn¡ adres ý
         mov       ah,3bh
         int       21h                      ; nastaven¡ z kladn¡ho adres ýe

; ------ nalezen¡ konce podadres ýe

Start5:  mov       dx,si                    ; £schova zaŸ tku podadres ýe
Start6:  cld
         mov       al,ds:[si]               ; naŸten¡ znaku
         cmp       al,0                     ; je konec textu ?
         je        Start7                   ; je konec textu
         inc       si
         cmp       al,"\"                   ; je oddØlovaŸ podadres ý… ?
         jne       Start6                   ; je oddØlovaŸ podadres ý…
         mov       byte ptr ds:[si-1],0     ; oznaŸen¡ konce textu

; ------ adres ý se nenastavuje, n sleduje-li ".." (=m…§e to bìt soubor)

Start7:  cmp       word ptr ds:[si],".."
         jne       Start8
         cmp       byte ptr ds:[si+2],0
         je        Start72
         cmp       byte ptr ds:[si+2],"\"
         jne       Start8
         inc       si                       ; pýeskoŸen¡ koncov‚ho znaku "\"
Start72: inc       si
         inc       si                       ; pýeskoŸen¡ adres ýe ".."
         jmp       short Start5             ; dalç¡ podadres ý

; ------ test, zda je dalç¡ podadres ý

Start8:  mov       al,0                     ; k¢d chyby - OK
         cmp       si,dx                    ; je nØjakì znak ?
         je        Konec                    ; operace OK

; ------ vytvoýen¡ a nastaven¡ dlouh‚ho podadres ýe

         cmp       byte ptr ds:[VerzeDOS],7 ; je DOS 7.xx ?
         jb        Start82                  ; je mal  verze
         mov       ax,7139h
         int       21h                      ; vytvoýen¡ dlouh‚ho adres ýe
         stc                                ; pýednastaven¡ chyby
         mov       ax,713bh
         int       21h                      ; nastaven¡ dlouh‚ho adres ýe
         jc        Start82                  ; chyba
         cmp       ax,7100h                 ; funkce podporovan  ?
         jne       Start5                   ; je to asi OK

; ------ vytvoýen¡ a nastaven¡ kr tk‚ho podadres ýe

Start82: mov       ah,39h
         int       21h                      ; vytvoýen¡ po§adovan‚ho adres ýe
         mov       ah,3bh
         int       21h                      ; nastaven¡ nov‚ho podadres ýe
         jnc       start5                   ; operace OK

         mov       al,3                     ; k¢d chyby - chyba adres ýe
         jmp       short konec              ; konec s chybou

INT23:   mov       al,1                     ; pý¡znak pýeruçen¡ Ctrl-Break
Konec:   mov       ah,4ch
         int       21h

; -----------------------------------------------------------------------------
;        pý¡prava textu DS:SI (niŸ¡ AL a BX !) -> CY=nen¡ nic zad no
; -----------------------------------------------------------------------------

PrepTxt  PROC      NEAR

; ------ vypuçtØn¡ mezer pýed textem -> SI

         cld
PrepTxt2:lodsb                              ; naŸten¡ znaku
         cmp       al," "                   ; je mezerera ?
         je        PrepTxt2                 ; mezera se vypust¡
         cmp       al,9                     ; je tabul tor ?
         je        PrepTxt2                 ; tabul tor se vypust¡
         dec       si                       ; n vrat na posledn¡ znak

; ------ nalezen¡ konce textu -> BX

         mov       bx,si                    ; BX <- zaŸ tek textu
         dec       bx
PrepTxt3:inc       bx
         mov       al,ds:[bx]
         cmp       al,9                     ; tabul tor
         jne       PrepTxt4
         mov       al," "                   ; n hrada mezerou
         mov       ds:[bx],al               ; n hrada i v textu
PrepTxt4:cmp       al," "                   ; je konec textu ?
         jae       PrepTxt3                 ; je platnì znak

; ------ vypuçtØn¡ mezer z konce textu

PrepTxt5:cmp       bx,si                    ; je ji§ zaŸ tek textu ?
         je        PrepTxt6                 ; je ji§ zaŸ tek textu
         dec       bx
         cmp       byte ptr ds:[bx]," "     ; je mezera ?
         je        PrepTxt5                 ; vypuçtØn¡ mezer
         inc       bx
PrepTxt6:mov       byte ptr ds:[bx],0       ; oznaŸen¡ konce textu
         cmp       byte ptr ds:[si],1       ; text, zda je nØco zad no
         ret

PrepTxt  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

RootDir  db        '\',0                    ; z kladn¡ adres ý

VerzeDOS db        0                        ; verze DOS (hlavn¡ c¡slo)

ErrTxt   db        'SETDIR V1.30 - nastaveni/vytvoreni adresare; (c) Miroslav Nemecek 1997',13,10
         db        13,10
         db        ' zadejte: jmeno_pozadovaneho_adresare',13,10
         db        '    nebo: @soubor_se_jmenem_adresare',13,10
         db        13,10
         db        'V prostredi WINDOWS 95 lze pouzivat tez dlouha jmena adresaru.',13,10
         db        '$'

Buffer   label     byte                     ; buffer k naŸten¡ souboru

Code     ENDS
         END       Start

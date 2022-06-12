
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ p©¡prava p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce textu

; ------ test, zda je nˆco zad no

         call      ParSpc                   ; vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
         jnc       Start2                   ; je nˆco zad no

; ------ nen¡ nic zad no - n povˆda

Chyba:   mov       dx,offset HlpTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h

; ------ parametr "M" - monochromatick˜ re‘im

Start2:  call      ParChr                   ; na‡ten¡ znaku
         mov       ah,12h
         mov       bx,33h
         cmp       al,"M"
         je        Start3                   ; monochrom. re‘im

; ------ parametr "C" - barevn˜ re‘im

         mov       bh,1
         cmp       al,"C"
         je        Start3                   ; barevn˜ re‘im

; ------ parametry "2" a‘ "4"

         mov       bl,30h
         sub       al,"2"                   ; test, zda je znak "2" a‘ "4"
         mov       bh,al
         cmp       al,2
         ja        Chyba                    ; nepovolen˜ znak

; ------ nastaven¡ po‘adovan‚ho re‘imu

Start3:  mov       al,bh
         push      si
         int       10h                      ; nastaven¡ re‘imu

; ------ p©enastaven¡ videore‘imu

         mov       ah,0fh
         int       10h
         mov       ah,0
         int       10h
         pop       si

; ------ test, zda je dal¨¡ znak

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jnc       Start2                   ; dek¢dov n¡ dal¨¡ho znaku
         int       20h                      ; konec

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr
         jc        ParSpc2
         je        ParSpc
         cmp       al,"/"
         je        ParSpc
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
         lodsb
         cmp       al,9
         jne       ParChr2
         mov       al," "
ParChr2: cmp       al,"a"
         jb        ParChr3
         cmp       al,"z"
         ja        ParChr3
         sub       al,32
ParChr3: cmp       al," "
         jae       ParChr4
         dec       si
ParChr4: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'SETVGA V1.0 - nastaveni karty VGA; (c) Miroslav Nemecek',13,10,'$'

HlpTxt   db        'Zadejte:  2 .... nastaveni rezimu 200 videolinek (CGA)',13,10
         db        '          3 .... nastaveni rezimu 350 videolinek (EGA)',13,10
         db        '          4 .... nastaveni rezimu 480 videolinek (VGA)',13,10
         db        '          M .... nastaveni monochromatickeho rezimu',13,10
         db        '          C .... nastaveni barevneho rezimu',13,10
         db        '$'

Code     ENDS
         END       Start

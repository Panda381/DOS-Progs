
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
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ nalezen¡ za‡ tku textu

Start1:  call      ParSpc                   ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         jnc       Start2                   ; nalezen platn˜ znak OK

; ------ chyba zad n¡

Chyba:   mov       dx,offset HlpTxt         ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         int       20h                      ; konec programu

; ------ rozbor ‡¡sla

Start2:  xor       cx,cx                    ; st©ada‡ ‡¡sla
Start3:  call      ParChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jbe       Start6                   ; konec textu
         sub       al,"0"
         cmp       al,10
         jae       Chyba                    ; chybn˜ znak
         mov       ah,0
         xchg      ax,bx                    ; BX <- nov  ‡¡slice
         mov       ax,10
         mul       cx                       ; vyn soben¡ st©ada‡e 10x
         or        dx,dx                    ; je p©ete‡en¡ ‡¡sla ?
         jnz       Start4                   ; je p©ete‡en¡ ‡¡sla
         add       ax,bx
         jnc       Start5                   ; nen¡ p©ete‡en¡ ‡¡sla
Start4:  mov       ax,0ffffh                ; omezen¡ velikosti ‡¡sla
Start5:  xchg      ax,cx                    ; nov˜ stav st©ada‡e
         jmp       short Start3             ; dal¨¡ ‡¡slice

; ------ test, zda je¨tˆ n sleduje nˆjak˜ text

Start6:  call      ParSpc                   ; test, zda je je¨tˆ nˆco zad no
         jnc       Chyba                    ; je¨tˆ nˆco je - chyba

; ------ prodleva

         jcxz      Start9                   ; zad na 0
         xor       bx,bx
         mov       ds,bx                    ; DS <- 0
Start7:  mov       bx,ds:[46ch]             ; stav hodin
Start8:  sti
         mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ programu
         cmp       bx,ds:[46ch]             ; je zmˆna hodin ?
         je        Start8                   ; ‡ek n¡ na hodiny
         loop      Start7                   ; nov˜ impuls hodin

; ------ konec programu

Start9:  int       20h

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; vstup znaku z p©¡kazov‚ho r dku
         jc        ParSpc2                  ; nen¡ dal¨¡ znak
         je        ParSpc                   ; vypu¨tˆn¡ mezery
         dec       si
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

         cld
ParChr1: lodsb
         cmp       al,"/"
         je        ParChr1
         cmp       al,9
         jne       ParChr2
         mov       al," "
ParChr2: cmp       al," "
         jae       ParChr3
         dec       si
ParChr3: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

UvTxt    db        'DELAY V1.0 - casova prodleva; (c) Miroslav Nemecek',13,10,'$'
HlpTxt   db        'Zadejte delku prodlevy v 1/18 sekundy !',13,10
         db        'Napr.: DELAY 36 je prodleva 2 sekundy.',13,10,'$'

Code     ENDS
         END       Start


Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ zobrazen¡ £vodn¡ho textu

Start:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ test, zda je videokarta EGA/VGA

         mov       ah,12h
         mov       bx,0ff10h
         int       10h                      ; test instalace karty EGA/VGA
         cmp       bh,1                     ; m¢d displeje
         ja        DetCard2                 ; nen¡ karta EGA/VGA
         cmp       bl,5                     ; pamˆŸ
         ja        DetCard2                 ; nen¡ karta EGA/VGA

; ------ test, zda je videokarta VGA

         mov       byte ptr ds:[Card],3     ; p©ednastaven¡ - karta EGA
         mov       ax,1a00h
         int       10h                      ; dotaz na instalaci videokarty
         cmp       al,1ah                   ; je funkce obsluhovan  ?
         jne       DetCard4                 ; funkce nen¡ obsluhovan 
         cmp       bl,7
         je        DetCard1                 ; je karta VGA
         cmp       bl,8
         je        DetCard1                 ; je karta VGA
         cmp       bl,11
         je        DetCard1                 ; je karta VGA
         cmp       bl,12
         jne       DetCard4                 ; nen¡ karta VGA
DetCard1:mov       byte ptr ds:[Card],4     ; je karta VGA
         jmp       short DetCard4

; ------ test, zda je videokarta CGA

DetCard2:xor       ax,ax
         mov       es,ax                    ; ES <- 0
         cmp       word ptr es:[463h],3b4h  ; je karta Hercules ?
         je        DetCard4                 ; je karta Hercules
         mov       byte ptr ds:[Card],2     ; jinak je karta CGA

; ------ zobrazen¡ textu nainstalovan‚ videokarty

DetCard4:mov       bl,ds:[Card]             ; ‡¡slo videokarty
         mov       bh,0
         shl       bx,1                     ; ‡¡slo videokarty * 2
         mov       dx,ds:[bx+CardAdr-2]     ; adresa textu videokarty
         mov       ah,9
         int       21h                      ; zobrazen¡ typu videokarty

; ------ n vrat z programu

         mov       al,ds:[Card]             ; typ videokarty
         mov       ah,4ch
         int       21h                      ; konec programu

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

Card     db        1                        ; ‡¡slo nainstalovan‚ videokarty
                                            ;  1=Hercules
                                            ;  2=CGA
                                            ;  3=EGA
                                            ;  4=VGA

UvTxt    db        'DETCARD V1.0 - detekce videokarty; (c) Miroslav Nemecek',13,10
         db        'Nainstalovana videokarta: $'

CardAdr  dw        CardTxt1
         dw        CardTxt2
         dw        CardTxt3
         dw        CardTxt4

CardTxt1 db        'Hercules',13,10,'$'
CardTxt2 db        'CGA',13,10,'$'
CardTxt3 db        'EGA',13,10,'$'
CardTxt4 db        'VGA',13,10,'$'

Code     ENDS
         END       Start

;------------------------------------------------------------------------------
;               Program pro zad v n¡ voleb v povelov‚m souboru
;------------------------------------------------------------------------------
code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h
start:
         mov       si,81h                   ; po‡ te‡n¡ adresa textu
         xor       ch,ch
         mov       cl,ds:[si-1]             ; po‡et znak– povelov‚ho © dku
                                          ;* nalezen¡ za‡ tku textu
ask1:    jcxz      askerr                   ; nen¡ zad n ‘ dn˜ parametr
         lodsb                              ; na‡ten¡ dal¨¡ho znaku
         dec       cx
         cmp       al," "
         jbe       ask1                     ; ignorov n¡ znaku
         cmp       al,'"'                   ; je za‡ tek textu ?
         je        ask2                     ; je zobrazen¡ textu
;         cmp       al,","                   ; jsou parametry ?
;         je        ask5                     ; jsou znaky volby
         dec       si                       ; n vrat znaku volby
         inc       cx
         jmp       short ask5               ; volby kl ves

ask2:                                     ;* zobrazen¡ textu
         jcxz      ask5                     ; je konec © dku
         lodsb                              ; dal¨¡ znak nadpisu
         dec       cx
         cmp       al,'"'                   ; je oddˆlova‡ dat ?
         jne       ask4                     ; nen¡ oddˆlova‡ dat
         jcxz      ask5                     ; je konec textu
         cmp       byte ptr ds:[si],al      ; je zdvojen˜ znak ?
         jne       ask5                     ; je oddˆlova‡ parametr–
         lodsb
         dec       cx
ask4:    mov       dl,al                    ; znak k zobrazen¡
         mov       ah,2
         int       21h                      ; zobrazen¡ znaku
         jmp       short ask2               ; dal¨¡ znak

ask5:                                     ;* vstup znak– volby
         mov       ah,8
         int       21h                      ; vstup znaku bez echa
         or        al,al
         jnz       ask6
         mov       ah,8
         int       21h                      ; zru¨en¡ ©¡dic¡ kl vesy
         jmp       short ask5
ask6:    call      upcase                   ; p©evod znaku na velk‚ p¡smeno
         jcxz      ask9                     ; nen¡ ‘ dn˜ znak parametru
         mov       bl,al                    ; £schova znaku
                                          ;* nalezen¡ znaku v seznamu
         xor       bh,bh                    ; ‡¡ta‡ znaku
ask7:    push      si
         push      cx
ask8:    inc       bh                       ; ‡¡ta‡ znak–
         lodsb
         call      upcase
         cmp       al,bl                    ; byl nalezen znak ?
         loopnz    ask8                     ; dal¨¡ znak
         pop       cx
         pop       si
         mov       al,bh                    ; po©ad¡ znaku
         jne       ask5                     ; dal¨¡ kl vesa
ask9:    mov       ah,4ch                   ; ukon‡en¡ programu
         int       21h

askerr:                                   ;* n vrat p©i chybˆ
         lea       dx,[errtxt]              ; text n povˆdy
         mov       ah,9
         int       21h                      ; zobrazen¡ textu n povˆdy
         mov       ax,4c00h                 ; ukon‡en¡ programu
         int       21h

upcase:                                   ;* p©evod na velk‚ p¡smeno
         cmp       al,"a"
         jb        upcase2
         cmp       al,"z"
         ja        upcase2
         sub       al,32
upcase2: ret


errtxt   db        'ASK V1.12 - vetveni menu; (c) Miroslav Nemecek',13,10
         db        'Pouziti: ASK "text"abcd... (seznam klaves)',13,10
         db        '         ASK abcd... (seznam klaves)',13,10
         db        '         ASK "text" (libovolna klavesa)',13,10
         db        'Test:    IF ERRORLEVEL n ... GOTO ... ',13,10,'$'

code     ENDS

         END       start               ; startovac¡ adresa

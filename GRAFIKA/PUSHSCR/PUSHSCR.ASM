
BUFFSIZE EQU       800h                     ; velikost datov‚ho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©¡prava k dek¢dov n¡ p©¡kazov‚ho © dku

Start:   mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       bl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       bh,0
         mov       ds:[si+bx],bh            ; ozna‡en¡ konce p©¡kazov‚ho © dku
         cld

; ------ nalezen¡ za‡ tku jm‚na souboru

Start1:  mov       dx,si
         lodsb
         cmp       al,9
         je        Start1
         cmp       al," "
         je        Start1
         ja        Start3                   ; je platn˜ znak

; ------ zobrazen¡ n povˆdy

Start2:  mov       dx,offset HelpTxt
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ ozna‡en¡ konce jm‚na souboru

Start3:  lodsb
         cmp       al," "
         ja        Start3
         mov       byte ptr ds:[si-1],0     ; ozna‡en¡ konce jm‚na souboru

; ------ otev©en¡ souboru pro ‡ten¡

         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru pro ‡ten¡
         jnc       Start31                  ; soubor otev©en OK
Start30: jmp       Start4                   ; soubor nenalezen
Start31: mov       ds:[Soubor],ax           ; identifik tor souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ na‡ten¡ z hlav¡ souboru

         mov       dx,offset Zahlavi
         mov       cx,offset(Zahlavi0-Zahlavi)
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ souboru
         jc        Start30
         cmp       ax,cx
         jb        Start30

; ------ nastaven¡ videom¢du

         call      NulEga                   ; nulov n¡ p©¡znaku hust‚ho © dkov n¡
         mov       al,ds:[Videomod]         ; videom¢d
         mov       ah,0
         push      ax
         call      Int10                    ; nastaven¡ videom¢du
         call      NulEga                   ; nulov n¡ p©¡znaku hust‚ho © dkov n¡
         pop       ax

; ------ test, zda je standardn¡ textov˜ videom¢d

         cmp       al,7
         je        Start312
         cmp       al,3
         ja        Start318

; ------ test, zda je pot©eba nastavit vy¨¨¡ © dkov n¡

Start312:cmp       byte ptr ds:[Radku],28   ; je pot©eba v¡ce © dk– ?
         jb        Start318                 ; nen¡ pot©eba v¡ce © dk–

; ------ nastaven¡ hust‚ho © dkov n¡

         mov       ax,1111h                 ; na‡ten¡ font– 8x14 VGA
         je        Start314                 ; budou fonty 8x14
         mov       al,12h                   ; jinak fonty 8x8
Start314:xor       bx,bx
         call      Int10                    ; nastaven¡ hust‚ho © dkov n¡

; ------ nastaven¡ aktivn¡ str nky

Start318:mov       al,ds:[Stranka]
         mov       ah,5
         call      Int10                    ; nastaven¡ aktivn¡ str nky

; ------ na‡ten¡ obsahu bufferu

         call      ReadBuff                 ; na‡ten¡ bufferu

; ------ nastaven¡ pozice kurzoru

         xor       dx,dx                    ; ukazatel pozice a © dku
Start32: call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ zobrazen¡ znaku na pozici kurzoru

         cld
         lodsw                              ; na‡ten¡ znaku a atributu
         mov       bl,ah                    ; barva znaku
         mov       cx,1                     ; po‡et znak– k z pisu
         mov       ah,9
         push      dx
         call      Int10                    ; z pis znaku na pozici kurzoru
         pop       dx

; ------ na‡ten¡ nov‚ho bufferu

         cmp       si,offset Buffer+BUFFSIZE ; je buffer ji‘ pln˜ ?
         jb        Start34                  ; je¨tˆ nen¡ pln˜
         call      ReadBuff                 ; na‡ten¡ obsahu bufferu

; ------ zv˜¨en¡ pozice na © dku

Start34: inc       dx                       ; zv˜¨en¡ pozice na © dku
         cmp       dl,ds:[Pozic]            ; je je¨tˆ platn  pozice ?
         jb        Start32                  ; je je¨tˆ platn  pozice

; ------ zv˜¨en¡ ‡¡sla © dku

         mov       dl,0                     ; pozice na za‡ tek © dku
         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         cmp       dh,ds:[Radku]            ; je je¨tˆ platn˜ © dek ?
         jb        Start32                  ; je je¨tˆ platn˜ © dek
         jmp       Start9                   ; nastaven¡ kurzoru, konec

; ------ vytvo©en¡ nov‚ho souboru

Start4:  xor       cx,cx
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ nov‚ho souboru
         jnc       Start41                  ; soubor vytvo©en OK
         mov       dx,offset ErrTxt
         jmp       Chyba                    ; chyba zad n¡ jm‚na souboru
Start41: mov       ds:[Soubor],ax           ; identifik tor souboru
         xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ £schova ‡¡sla videom¢du

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         mov       ds:[Videomod],al         ; aktu ln¡ videom¢d
         mov       ds:[Pozic],ah            ; po‡et pozic na © dek
         mov       ds:[Stranka],bh          ; aktu lnˆ zobrazen  str nka

; ------ £schova pozice kurzoru (BH=str nka)

         mov       ah,3
         call      Int10
         mov       word ptr ds:[Pozice],dx  ; £schova pozice a © dku kurzoru

; ------ £schova po‡tu © dk– displeje

         xor       ax,ax
         mov       es,ax
         mov       al,es:[484h]             ; ‡¡slo posledn¡ho © dku
         inc       ax                       ; po‡et © dk– displeje
         cmp       al,25                    ; je platn˜ £daj ?
         jb        Start42                  ; nen¡ platn˜ £daj
         cmp       al,240
         ja        Start42
         mov       ds:[Radku],al            ; po‡et © dk– displeje

; ------ ulo‘en¡ z hlav¡ do bufferu

Start42: mov       di,offset Buffer         ; ukl dac¡ adresa do bufferu
         mov       cx,offset(Zahlavi0-Zahlavi)
         mov       si,offset Zahlavi
         cld
         push      ds
         pop       es
         rep       movsb                    ; ulo‘en¡ z hlav¡ do bufferu

; ------ nastaven¡ pozice kurzoru

         xor       dx,dx                    ; ukazatel pozice a © dku
Start43: call      SetKurz                  ; nastaven¡ pozice kurzoru

; ------ na‡ten¡ znaku na pozici kurzoru

         mov       ax,8*256 + 7
         push      dx
         call      Int10                    ; ‡ten¡ znaku z pozice kurzoru
         pop       dx

; ------ oprava barvy znaku pro standardn¡ grafick˜ m¢d

         cmp       byte ptr ds:[Videomod],7
         je        Start44
         cmp       byte ptr ds:[Videomod],3
         jbe       Start44
         cmp       byte ptr ds:[Videomod],13h
         ja        Start44
Start434:mov       ah,7

; ------ ulo‘en¡ znaku do bufferu

Start44: cld
         stosw                              ; ulo‘en¡ znaku do bufferu

; ------ vypr zdnˆn¡ bufferu

         cmp       di,offset Buffer+BUFFSIZE ; je buffer ji‘ pln˜ ?
         jb        Start46                  ; je¨tˆ nen¡ pln˜
         call      WritBuff                 ; z pis obsahu bufferu

; ------ zv˜¨en¡ pozice na © dku

Start46: inc       dx                       ; zv˜¨en¡ pozice na © dku
         cmp       dl,ds:[Pozic]            ; je je¨tˆ platn  pozice ?
         jb        Start43                  ; je je¨tˆ platn  pozice

; ------ zv˜¨en¡ ‡¡sla © dku

         mov       dl,0                     ; pozice na za‡ tek © dku
         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         cmp       dh,ds:[Radku]            ; je je¨tˆ platn˜ © dek ?
         jb        Start43                  ; je je¨tˆ platn˜ © dek

; ------ vypr zdnˆn¡ obsahu bufferu

         call      WritBuff                 ; z pis obsahu bufferu

; ------ navr cen¡ pozice kurzoru

Start9:  mov       dx,word ptr ds:[Pozice]  ; aktivn¡ pozice a © dek
         call      SetKurz                  ; n vrat pozice a © dku kurzoru

; ------ uzav©en¡ souboru

         mov       bx,ds:[Soubor]           ; identifik tor souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         int       20h

; -----------------------------------------------------------------------------
;        nulov n¡ p©¡znaku hust‚ho © dkov n¡ (ni‡¡ AX a ES !)
; -----------------------------------------------------------------------------

NulEga   PROC      NEAR

         xor       ax,ax
         mov       es,ax
         and       byte ptr es:[487h],not 81h
         ret

NulEga   ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu bufferu (DI=ukl dac¡ adresa)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,ds:[Soubor]           ; identifik tor souboru
         mov       cx,di                    ; CX <- konec dat
         mov       dx,offset Buffer         ; buffer souboru
         mov       di,dx                    ; nov  ukl dac¡ adresa
         sub       cx,dx                    ; po‡et bajt– k z pisu
         mov       ah,40h
         int       21h                      ; z pis dat do souboru

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bufferu (-> SI=za‡ tek bufferu)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       bx,ds:[Soubor]           ; identifik tor souboru
         mov       dx,offset Buffer         ; buffer souboru
         mov       si,dx                    ; nov  ‡tec¡ adresa
         mov       ah,3fh
         mov       cx,BUFFSIZE              ; velikost bufferu
         int       21h                      ; na‡ten¡ obsahu bufferu

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru DX (ni‡¡ AX !)
; -----------------------------------------------------------------------------

SetKurz  PROC      NEAR

         push      dx
         mov       ah,2
         call      Int10
         pop       dx
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 10h s £schovou registr–
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         pushf
         push      si
         push      di
         push      ds
         push      es

         mov       bh,ds:[Stranka]          ; aktivn¡ str nka
         int       10h

         pop       es
         pop       ds
         pop       di
         pop       si
         popf
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;                                  data
; -----------------------------------------------------------------------------

ErrTxt   db        'Chybne zadani jmena souboru !',13,10,'$'

HelpTxt  db        'PUSHSCR v1.0 - uschova systemove obrazovky; (c) Miroslav Nemecek',13,10
         db        ' Zadejte jmeno souboru, do ktereho se ma uchovat obsah systemove',13,10
         db        ' obrazovky. Pokud tento soubor jiz existuje, bude obsah obrazovky',13,10
         db        ' navracen z tohoto souboru.',13,10
         db        '$'

Soubor   dw        0                        ; identifik tor souboru

; ------ z hlav¡ souboru (mus¡ b˜t sud  velikost !)

         EVEN
Zahlavi  label     byte
Videomod db        3                        ; ‡¡slo videom¢du
Pozice   db        0                        ; pozice s kurzorem
Radek    db        0                        ; © dek s kurzorem
Pozic    db        80                       ; ¨¡©ka displeje (pozic)
Radku    db        25                       ; v˜¨ka displeje (© dk–)
Stranka  db        0                        ; aktu lnˆ zobrazen  str nka
         EVEN
Zahlavi0 label     byte

Buffer   db        BUFFSIZE dup(?)          ; datov˜ buffer souboru

Code     ENDS
         END       Start

code     SEGMENT
         ASSUME    cs:code,ds:code
; -----------------------------------------------------------------------------
         dd        -1                       ; adresa na n sleduj¡c¡ za©¡zen¡
         dw        0000h                    ; atributy - blokov‚ za©¡zen¡
         dw        offset strateg           ; adresa obsluhy strategie za©¡zen¡
         dw        offset prerus            ; adresa obsluhy p©eru¨en¡ za©¡zen¡
         db        0,0,0,0,0,0,0,0          ; po‡et instalovan˜ch disk–
; -----------------------------------------------------------------------------
heslo    db        'SLOVO',0                ; heslo (max. 10 znak–, ukon‡eno 0)
buffer   db        10 dup(0)                ; vstupn¡ buffer
adrdev   dd        0                        ; adresa z hlav¡ po‘adavku za©¡zen¡
; -----------------------------------------------------------------------------
strateg  PROC      FAR                    ;* obsluha rutiny STRATEGIE
         mov       word ptr cs:[adrdev],bx  ; offset adresy z hlav¡ po‘adavku
         mov       word ptr cs:[adrdev+2],es; segment adresy z hlav¡ po‘adavku
         ret
strateg  ENDP
; -----------------------------------------------------------------------------
prerus   PROC      FAR                    ;* obsluha rutiny PžERU›EN‹
         pushf                              ; £schova p©¡znakov‚ho registru
         push      ax                       ; £schova AX
         push      bx                       ; £schova BX
         push      cx                       ; £schova CX
         push      dx                       ; £schova DX
         push      si                       ; £schova SI
         push      di                       ; £schova DI
         push      bp                       ; £schova BP
         push      ds                       ; £schova DS
         push      es                       ; £schova ES

         push      cs
         pop       ds
                                          ;* kontrola ‡¡sla funkce
         les       di,ds:[adrdev]           ; adresa po‘adavku za©¡zen¡
         mov       bl,es:[di+2]             ; k¢d povelu
         or        bl,bl                    ; kontrola maxim ln¡ho ‡¡sla povelu
         mov       ax,8103h                 ; k¢d chyby - nezn m˜ povel
         jnz       prerus3                  ; chyba - nezn m˜ povel
                                          ;* zobrazen¡ £vodn¡ho textu
         lea       si,[uvtxt]               ; £vodn¡ text
         mov       cx,7                     ; d‚lka textu
prerus1: lodsb
         call      outch                    ; zobrazen¡ znaku
         loop      prerus1                  ; dal¨¡ znak
                                          ;* vstup hesla
         lea       si,[buffer]              ; buffer pro ulo‘en¡ textu
prerus2: xor       ax,ax
         int       16h                      ; vstup znaku
         cmp       al,13                    ; je <Enter>
         je        prerus5                  ; ukon‡en¡ zad n¡
         cmp       al,8                     ; je <BS> ?
         je        prerus4                  ; je krok zpˆt BS
         cmp       al,"a"
         jb        prerus3
         cmp       al,"z"
         ja        prerus3
         sub       al,32                    ; konverze na mal‚ p¡smeno
prerus3: cmp       cl,10                    ; je buffer ji‘ pln˜ ?
         jae       prerus2                  ; buffer je ji‘ pln˜
         mov       ds:[si],al               ; ulo‘en¡ znaku
         inc       si                       ; zv˜¨en¡ adresy v bufferu
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e znak–
         mov       al,"*"
         call      outch                    ; n hradn¡ znak
         jmp       short prerus2            ; vstup dal¨¡ho znaku
prerus4: jcxz      prerus2                  ; buffer je ji‘ pr zdn˜
         call      outch                    ; vymaz n¡ znaku
         mov       al," "
         call      outch
         mov       al,8
         call      outch
         dec       cx                       ; sn¡‘en¡ znak– v bufferu
         dec       si                       ; sn¡‘en¡ ukazatele v bufferu
         jmp       short prerus2            ; dal¨¡ znak
prerus5:                                  ;* zad n¡ ukon‡eno - test hesla
         lea       si,[heslo]               ; zad van‚ heslo
prerus6: lodsb                              ; znak hesla
         or        al,al                    ; je konec hesla ?
         jz        prerus9                  ; konec - zad n¡ OK
         cmp       al,ds:[si+offset(buffer-heslo)-1] ; souhlas¡ heslo ?
         je        prerus6                  ; souhlas¡ - dal¨¡ znak
                                         ;* chyba zad n¡
         lea       si,[errtxt]              ; chybov˜ text
         mov       cl,10                    ; d‚lka textu
prerus7: lodsb
         call      outch                    ; zobrazen¡ znaku
         loop      prerus7                  ; dal¨¡ znak
prerus8: cli
         jmp       short prerus8            ; zastaven¡

prerus9: mov       word ptr es:[di+0eh],offset konec ; konec rezid. modulu
         mov       word ptr es:[di+10h],cs  ; segment konce
         mov       byte ptr es:[di+13],0    ; po‡et nainstalovan˜ch disk– = 0

         mov       ax,0100h                 ; n vratov˜ k¢d
prerusa: mov       es:[di+3],ax             ; nastaven¡ stavov‚ho slova

         pop       es                       ; n vrat ES
         pop       ds                       ; n vrat DS
         pop       bp                       ; n vrat BP
         pop       di                       ; n vrat DI
         pop       si                       ; n vrat SI
         pop       dx                       ; n vrat DX
         pop       cx                       ; n vrat CX
         pop       bx                       ; n vrat BX
         pop       ax                       ; n vrat AX
         popf                               ; n vrat p©¡znakov‚ho registru
         ret
prerus   ENDP
; -----------------------------------------------------------------------------
outch:   mov       ah,0eh
         mov       bx,7
         push      si
         push      cx
         int       10h
         pop       cx
         pop       si
         ret
; -----------------------------------------------------------------------------
uvtxt    db        'HESLO: '
errtxt   db        ' - CHYBA !'
; -----------------------------------------------------------------------------
konec    label     near                     ; konec rezidentn¡ ‡ sti
code     ends
         end

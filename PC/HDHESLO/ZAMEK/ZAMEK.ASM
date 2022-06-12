code     SEGMENT
         ASSUME    cs:code,ds:code
; -----------------------------------------------------------------------------
         dd        -1                       ; adresa na n sleduj¡c¡ za©¡zen¡
         dw        0c000h                   ; atributy - znakov‚ za©¡zen¡
         dw        offset strateg           ; adresa obsluhy strategie za©¡zen¡
         dw        offset prerus            ; adresa obsluhy p©eru¨en¡ za©¡zen¡
         db        '___ZAMEK'               ; jm‚no za©¡zen¡
; -----------------------------------------------------------------------------
adrprer  LABEL     WORD                   ;* tabulka adres obsluh
         dw        offset init              ; 00 inicializace za©¡zen¡
         dw        offset zamret            ; 01
         dw        offset zamret            ; 02
         dw        offset zamret            ; 03
         dw        offset input             ; 04 vstup ze znakov‚ho za©¡zen¡
         dw        offset zamret            ; 05
         dw        offset zamret            ; 06
         dw        offset zamret            ; 07
         dw        offset zamret            ; 08
         dw        offset zamret            ; 09
         dw        offset zamret            ; 0a
         dw        offset zamret            ; 0b
         dw        offset zamret            ; 0c
; -----------------------------------------------------------------------------
adrdev   dd        0                        ; adresa z hlav¡ po‘adavku za©¡zen¡
old08    dd        0                        ; p–vodn¡ adresa obsluhy INT 08h
old1b    dd        0                        ; p–vodn¡ adresa obsluhy INT 1bh
priznak  db        10                       ; p©¡znak: 1=BREAK je blokov n
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
         les       di,cs:[adrdev]           ; adresa po‘adavku za©¡zen¡
         xor       bx,bx                    ; BX <- 0
         mov       bl,es:[di+2]             ; k¢d povelu
         cmp       bl,13                    ; kontrola maxim ln¡ho ‡¡sla povelu
         cmc                                ; CY - ‡¡slo povelu >= 13
         mov       al,3                     ; k¢d chyby - nezn m˜ povel
         jc        prerus2                  ; chyba - nezn m˜ povel
         shl       bx,1                     ; ‡¡slo povelu * 2
         call      word ptr cs:[bx+adrprer] ; vyvol n¡ obsluhy p©eru¨en¡
prerus2:                                  ;* v AL je zde n vratov˜ k¢d chyby
         les       di,cs:[adrdev]           ; adresa po‘adavku za©¡zen¡
         mov       ah,2                     ; nastaven¡ bitu "akce provedena"
         rcr       ah,1                     ; nastaven¡ bitu 15 (=chyba) z CF
         mov       es:[di+3],ax             ; nastaven¡ stavov‚ho slova
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
zamret:                                   ;* n vrat - neobslou‘en  funkce
         xor       al,al                    ; p©¡znak - nen¡ chyba
         ret
; -----------------------------------------------------------------------------
input:                                    ;* FUNKCE 04 - vstup ze za©¡zen¡
         mov       byte ptr cs:[priznak],0  ; zru¨en¡ p©¡znaku blokov n¡ p©eru¨.
         xor       si,si
         mov       ds,si                    ; DS <- 0
         mov       si,word ptr cs:[old1b]   ; offset p–vodn¡ obsluhy INT 1bh
         mov       ds:[6ch],si              ; n vrat p–vodn¡ho offsetu INT 1bh
         mov       si,word ptr cs:[old1b+2] ; segment p–vodn¡ obsluhy INT 1bh
         mov       ds:[6eh],si              ; n vrat p–vodn¡ho segmentu INT 1bh

         mov       si,es:[di+10h]           ; segment adresy DTA pro p©enos dat
         mov       ds,si                    ; DS<-segment adresy DTA
         mov       si,es:[di+0eh]           ; offset adresy DTA pro p©enos dat
         mov       ax,4                     ; po‡et bajt–, kter‚ se p©ed vaj¡
         mov       es:[di+12h],ax           ; po‡et p©enesen˜ch bajt–
         mov       ax,"YV"
         mov       ds:[si],ax
         mov       ax,13*256+"P"
         mov       ds:[si+2],ax
         xor       al,al
         ret
; -----------------------------------------------------------------------------
break:                                    ;* obsluha p©eru¨en¡ z kl vesnice 1Bh
         iret
; -----------------------------------------------------------------------------
int08:                                    ;* obsluha p©eru¨en¡ INT 08h

         cmp       byte ptr cs:[priznak],0  ; je p©eru¨en¡ blokov no ?
         je        int083                   ; p©eru¨en¡ nen¡ blokov no
;         dec       byte ptr cs:[priznak]
         push      ax
         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
;         lea       ax,[break]               ; adresa vlastn¡ obsluhy INT 1bh
;         cmp       ds:[6ch],ax              ; byl zmˆnˆn offset ?
;         jne       int081                   ; byl zmˆnˆn offset
;         mov       ax,cs
;         cmp       ds:[6eh],ax              ; byl zmˆnˆn segment ?
;         je        int082                   ; adresa se nezmˆnila
;                                          ;* £schova adresy INT bh
;int081:  mov       ax,ds:[6ch]              ; offset adresy INT 1bh
;         mov       word ptr cs:[old1b],ax   ; £schova offsetu adresy INT 1bh
;         mov       ax,ds:[6eh]              ; segment adresy INT 1bh
;         mov       word ptr cs:[old1b+2],ax ; £schova segmentu adresy INT bh

         mov       word ptr ds:[6ch],offset break ; offset obsluhy INT 1bh
         mov       ds:[6eh],cs              ; segment obsluhy INT 1bh
         mov       word ptr ds:[8ch],offset break
         mov       ds:[8eh],cs

int082:  pop       ds
         pop       ax
int083:  jmp       dword ptr cs:[old08]     ; skok na p–vodn¡ obsluhu INT 08h

; *****************************************************************************
init:                                     ;* FUNKCE 00 - inicializace za©¡zen¡

         xor       si,si
         mov       ds,si
         mov       si,ds:[6ch]              ; offset adresy INT 1bh
         mov       word ptr cs:[old1b],si   ; £schova offsetu adresy INT 1bh
         mov       si,ds:[6eh]              ; segment adresy INT 1bh
         mov       word ptr cs:[old1b+2],si ; £schova segmentu adresy INT bh
                                          ;* instalace obsluhy INT 08h
         xor       si,si
         mov       ds,si                    ; DS <- 0
         mov       si,ds:[20h]              ; p–vodn¡ offset adresy INT 08h
         mov       word ptr cs:[old08],si   ; £schova offsetu adresy INT 08h
         mov       si,ds:[22h]              ; p–vodn¡ segment adresy INT 08h
         mov       word ptr cs:[old08+2],si ; £schova segmentu adresy INT 08h
         mov       word ptr ds:[20h],offset int08 ; offset obsluhy INT 08h
         mov       ds:[22h],cs              ; segment obsluhy INT 08h

         mov       si,cs                    ; SI <- CS
         mov       ds,si                    ; DS <- CS
         lea       si,[zamret]              ; adresa pr zdn‚ funkce
         mov       ds:[adrprer],si          ; zru¨en¡ funkce 00
         cli                                ; z kaz p©eru¨en¡
         mov       word ptr ds:[zasob],sp   ; £schova SP
         mov       word ptr ds:[zasob+2],ss ; £schova SS
         mov       ss,si                    ; nastaven¡ SS do tohoto segmentu
         lea       sp,[zasob+200h]          ; vrchol z sobn¡ku
         sti                                ; povolen¡ p©eru¨en¡
         lea       si,[uvtxt]               ; £vodn¡ text
         call      outtxt                   ; zobrazen¡ textu
         lea       ax,[init]                ; konec rezidentn¡ ‡ sti driveru
         mov       es:[di+0eh],ax           ; adresa konce rezidentn¡ ‡ sti
         mov       es:[di+10h],cs           ; segment rezidentn¡ ‡ sti
         xor       al,al
         mov       es:[di+0dh],al           ; po‡et disk. jednotek = 0
         cli                                ; z kaz p©eru¨en¡
         mov       sp,word ptr cs:[zasob]   ; n vrat SP
         mov       ss,word ptr cs:[zasob+2] ; n vrat SS
         sti                                ; povolen¡ p©eru¨en¡

         ret

; -----------------------------------------------------------------------------
outtxt:                                   ;* zobrazen¡ textu
                                            ; VSTUP: CS:SI=ukazatel textu

         mov       al,cs:[si]               ; znak k zobrazen¡
         or        al,al                    ; je konec textu ?
         jz        outtxt2                  ; je konec textu
         mov       ah,0eh                   ; funkce zobrazen¡ znaku
         push      si                       ; £schova ukazatele textu SI
         int       10h                      ; zobrazen¡ znaku
         pop       si                       ; n vrat ukazatele textu SI
         inc       si                       ; zv˜¨en¡ adresy ukazatele textu
         jmp       short outtxt             ; zobrazen¡ dal¨¡ho znaku
outtxt2: ret
; -----------------------------------------------------------------------------
uvtxt    db        'OÄÄÁÁÙ',13,10,0
zasob    dd        0                        ; £schova z sobn¡ku (n sleduje z s.)
code     ends
         end

COMMENT %
                     Roz®i©uj°c° komunikaán° driver portu COM:
        %

NUL      equ       0
SOH      equ       1
STX      equ       2
ETX      equ       3
EOT      equ       4
ENQ      equ       5
ACK      equ       6

DLE      equ       10h
NAK      equ       15h
CAN      equ       18h

ADR1     equ       64                       ; parametr
ADR2     equ       64
KOMP     equ       64-16                    ; p©°jem
KOMV     equ       64+16                    ; vys°l†n°

code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h
; *****************************************************************************
;                            Rezidentn° á†st programu
; *****************************************************************************
start:   jmp       init                     ; inicializace a instalace programu

old14    dd        0f000ffffh               ; pñvodn° adresa p©eru®en° INT 14h
old1c    dd        0f000ffffh               ; pñvodn° adresa p©eru®en° INT 1CH

port     dw        0                        ; á°slo portu COM (0 aë 3)
citac    db        0                        ; odeá°t†n° áasu pro TIME-OUT



; *****************************************************************************
;
;               Obsluha funkc° INT 14H - skok na p©°slu®nou funkci
;
; *****************************************************************************

int14:                                    ;* ovladaá p©eru®en° INT 14h

         cmp       ah,40h                   ; je dotaz na instalaci ?
         jne       int142                   ; nen° dotaz na instalaci

         iret

int142:  cmp       ah,41h                   ; je nastaven° parametrñ ?
         jne       int143

         iret

int143:  cmp       ah,42h                   ; je p©°jem vàty ?
         jne       int144
         jmp       fnc42                    ; p©°jem vàty

int144:  cmp       ah,43h                   ; je vysl†n° vàty ?
         jne       int149                   ; nezn†m† funkce

         iret

int149:  jmp       dword ptr cs:[old14]     ; pñvodn° obsluha p©eru®en° INT 14h

; -----------------------------------------------------------------------------
fnc42:                                    ;* p©°jem vàty
                                            ; VSTUP: DS:AX=buffer pro uloëen°
                                            ;      DS:[AX+0] dÇlka bufferu
                                            ;      DS:[AX+2] skut. poáet znakñ
                                            ;      DS:[AX+4] data vàty
                                            ; VùSTUP: AX=n†vratovò k¢d
                                            ;      0 = operace OK - data p©ijata
                                            ;      1 = nejsou ë†dn† data
                                            ;      2 = chyba TIME-OUT p©°jmu
                                            ;      3 = chyba kontroln°ho souátu
                                            ;      4 = p©eteáen° bufferu

         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         push      ds
         pop       es                       ; ES <- DS segment bufferu
         mov       bp,ax                    ; offset bufferu
         mov       cx,es:[bp+0]             ; maxim†ln° dÇlka bufferu
         mov       word ptr ds:[bp+2],0     ; vynulov†n° bufferu
         lea       di,[bp+4]                ; ukl†dac° adresa do bufferu
                                          ;* nav†z†n° spojen°
         mov       al,KOMP                  ; povel pro p©°jem
         call      vyskom                   ; vysl†n° poëadavku o spojen°
                                          ;* áek†n° na odpovàÉ
prijem2: call      prijch                   ; áek†n° na p©°jem znaku
         jc        prijem6                  ; chyba TIME-OUT
         cmp       al,EOT
         je        prijem6
         cmp       al,STX
         jne       prijem2
         xor       bl,bl                    ; kontroln° souáet LRC
         lea       di,[buffer+2]            ; adresa k uloëen° textu
                                          ;* p©°jem £vodn°ch k¢dñ
         mov       cx,6                     ; poáet bin†rn°ch znakñ
prijem3: call      prijch                   ; p©°jem doln° tetr†dy znaku
         jc        prijem6
         xor       bl,al                    ; kontroln° souáet LRC
         cmp       al,ETX
         je        prijem6
         and       al,0fh
         mov       bh,al
         call      prijch                   ; p©°jem horn° tetr†dy znaku
         jc        prijem6
         xor       bl,al                    ; kontroln° souáet LRC
         cmp       al,ETX
         je        prijem6
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
         or        al,bh
         call      store
         loop      prijem3
                                          ;* p©°jem textu
prijem4: call      prijch
         jc        prijem6
         xor       bl,al                    ; kontroln° souáet LRC
         cmp       al,ETX
         je        prijem5
         call      store
         jnc       prijem4
prijem5: call      prijch                   ; p©°jem kontroln°ho souátu
;         cmp       al,bl
         mov       al,ACK
;         je        prijem52
;         mov       al,NAK
prijem52:call      vysch                    ; vysl†n° odpovàdi
prijem6: ret



prijem
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         iret






;vysil:                                    ;* vysl†n° vàty
;                                            ; VùSTUP: CY=TIME-OUT nebo chyba
;                                            ;         BL=kontroln° souáet
;
;         mov       al,KOMV
;         call      vyskom                   ; poëadavek na p©°jem
;vysil2:  call      prijch                   ; áek†n° na p©°jem znaku
;         jc        vysil6                   ; chyba TIME-OUT
;         cmp       al,EOT
;         stc
;         je        vysil6
;         cmp       al,ACK
;         jne       vysil2
;         xor       bl,bl                    ; kontroln° souáet LRC
;         lea       si,[buffer+2]            ; adresa uloëenÇho textu
;         mov       al,STX
;         call      vysch                    ; vysl†n° STX
;                                          ;* vysl†n° £vodn°ch k¢dñ
;         mov       cx,6                     ; poáet bin†rn°ch znakñ
;vysil3:  call      load
;         js        vysil5
;         push      ax
;         and       al,0fh
;         or        al,20h
;         xor       bl,al                    ; kontroln° souáet LRC
;         call      vysch
;         pop       ax
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         shr       al,1
;         or        al,30h
;         xor       bl,al                    ; kontroln° souáet LRC
;         call      vysch
;         loop      vysil3
;                                          ;* vysl†n° ostatn°ho textu
;vysil4:  call      load
;         js        vysil5
;         xor       bl,al                    ; kontroln° souáet LRC
;         call      vysch
;         jmp       short vysil4
;
;vysil5:  mov       al,ETX
;         xor       bl,al                    ; kontroln° souáet LRC
;         call      vysch
;         mov       al,bl
;         call      vysch
;
;         call      prijch                   ; áek†n° na odpovàÉ
;         jc        vysil6
;         cmp       al,ACK
;         je        vysil6
;         cmp       al,NAK
;         je        vysil                    ; opakov†n° vys°l†n°
;
;vysil6:  ret
;




load:    lodsb
         dec       byte ptr cs:[buffer+1]
         ret


store:   push      cs
         pop       es
         stosb                              ; uloëen° znaku
         clc
         inc       byte ptr cs:[buffer+1]
         jnz       store2
         dec       byte ptr cs:[buffer+1]
         stc
store2:  ret


vyskom:                                   ;* vysl†n° poëadavku spojen°
                                            ; VSTUP: AL=k¢d povelu
         push      cx
         push      ax
         mov       al,STX
         call      vysch                    ; vysl†n° znaku STX
         mov       cx,7                     ; poáet znakñ EOT
         mov       al,EOT
vyskon2: call      vysch                    ; vysl†n° znaku EOT
         loop      vyskon2
         mov       al,ADR1
         call      vysch                    ; parametr ADR1
         mov       al,ADR2
         call      vysch                    ; parametr ADR2
         pop       ax
         call      vysch                    ; povel
         pop       cx
         ret


vysch:                                    ;* vysl†n° jednoho znaku
                                            ; VSTUP: AL=znak

         push      dx
         push      ax
                                          ;* áek†n° na p©ipravenost vys°laáe
vysch1:  mov       ah,3
         mov       dx,cs:[port]
         int       14h                      ; dotaz na stav portu
         test      ah,40h
         jz        vysch1                   ; áek†n° na uvolnàn° bufferu
                                          ;* vysl†n° znaku
         pop       ax
         push      ax                       ; AL = znak k vysl†n°
         and       al,7fh
         mov       ah,1
         mov       dx,cs:[port]
         int       14h                      ; vysl†n° znaku na port
         pop       ax
         pop       dx
         ret


prijch:                                   ;* p©°jem jednoho znaku
                                            ; VùSTUP: AL=znak
                                            ;         CY=TIME-OUT

         push      dx
         mov       byte ptr cs:[citac],36   ; TIME-OUT 2 sekundy
prijch1: cmp       byte ptr cs:[citac],0
         mov       al,1                     ; k¢d chyby - TIME-OUT
         stc
         je        prijch3                  ; chyba TIME-OUT
         mov       ah,3
         mov       dx,cs:[port]
         int       14h                      ; dotaz na stav portu
         test      ah,1
         jz        prijch1                  ; nen° p©ijat znak
                                          ;* p©°jem znaku
         mov       ah,2
         mov       dx,cs:[port]
         int       14h                      ; p©°jem jednoho znaku
         and       al,7fh                   ; resetov†n° paritn°ho bitu
prijch3: pop       dx
         ret


int1c:                                    ;* obsluha INT 1ch - á°taá TIME-OUT
         pushf
         call      dword ptr cs:[old1c]     ; pñvodn° obsluha p©eru®en°
         cmp       byte ptr cs:[citac],0
         je        int1c2
         dec       byte ptr cs:[citac]
int1c2:  iret

; *****************************************************************************
;                        Inicializace a instalace programu
; *****************************************************************************
init:                                     ;* instalace programu

                                          ;* nastaven° á°sla portu
         mov       si,81h
         xor       ch,ch
         mov       cl,ds:[80h]              ; poáet znakñ zad†n°
         jcxz      init3                    ; nen° zad†no á°slo veden°
init1:   lodsb
         cmp       al,"1"                   ; minim†ln° á°slo portu
         jb        init2                    ; nen° á°slo portu
         cmp       al,"4"
         jbe       init4                    ; á°slo portu zad†no OK
init2:   loop      init1                    ; test dal®°ho znaku
                                          ;* chyba - nezad†n port
init3:   lea       dx,errinit               ; text chyby "Nebyl zad†n port"
         mov       ah,9
         int       21h
         mov       ax,4c01h
         int       21h                      ; n†vrat z programu s chybou
                                          ;* á°slo portu zad†no OK
init4:   sub       al,"1"                   ; á°slo portu
         mov       byte ptr ds:[port],al    ; nastaven° veden° 2 (port 2)
                                          ;* nastaven° m¢du portu
         mov       ah,0
         mov       al,11111010b
         mov       dx,cs:[port]
         int       14h
                                          ;* nainstalov†n° obsluh p©eru®en°
         mov       ax,351ch
         int       21h
         mov       word ptr ds:[old1c],bx   ; £schova pñvodn° adresy INT 1Ch
         mov       word ptr ds:[old1c+2],es
         lea       dx,[int1c]
         mov       ax,251ch
         int       21h                      ; nastaven° novÇ obsluhy INT 1Ch
         mov       ax,3514h
         int       21h
         mov       word ptr ds:[old14],bx   ; £schova pñvodn° adresy INT 14h
         mov       word ptr ds:[old14+2],es
         lea       dx,[int14]
         mov       ax,2514h
         int       21h                      ; nastaven° novÇ obsluhy INT 14h
                                          ;* nastaven° programu rezidentn°m
         lea       dx,[init]                ; adresa konce rezidentn° á†sti
         int       27h                      ; ukonáen° programu jako rezidentn°

errinit  db        'Chyba: nebylo zad†no á°slo portu (1 aë 4) !',13,10,'$'

code     ends

         end       start

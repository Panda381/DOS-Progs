COMMENT %
                     Roz®i©uj°c° komunikaán° driver portu COM:
        %

code     SEGMENT
         ASSUME    cs:code,ds:code

         org       100h

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

start:   jmp       init

old1c    dd        0                        ; star† adresa INT 1CH
port     dw        0

citac    db        0                        ; odeá°t†n° áasu pro TIME-OUT


int1c:                                    ;* obsluha INT 1ch
         pushf
         call      dword ptr cs:[old1c]     ; pñvodn° obsluha p©eru®en°
         cmp       byte ptr cs:[citac],0
         je        int1c2
         dec       byte ptr cs:[citac]
int1c2:  iret



init:                                     ;* instalace programu
         mov       ax,351ch
         int       21h
         mov       word ptr ds:[old1c],bx
         mov       word ptr ds:[old1c+2],es
         lea       dx,[int1c]
         mov       ax,251ch
         int       21h

                                          ;* inicializace parametrñ
         mov       si,81h
         xor       ch,ch
         mov       cl,ds:[80h]
         jcxz      init11
init1:   lodsb
         cmp       al,"1"
         je        init2
         cmp       al,"2"
         je        init2
         loop      init1

init11:  lea       dx,errinit
         mov       ah,9
         int       21h
         jmp       konec

init2:   sub       al,"1"
         cbw
         mov       ds:[port],ax

         mov       ah,0
         mov       al,11111010b
         mov       dx,ds:[port]
         int       14h

sse2:                                     ;* áek†n° na zad†n° povelu
         mov       ah,0bh
         int       21h                      ; test vstupu
         or        al,al
         jz        sse3                     ; nen° znak - p©°jem vàty

         mov       ah,1
         int       21h
         cmp       al,27
         je        konec

         call      vysch
         jmp       short sse3

;         mov       ah,10
;         lea       dx,[buffer]
;         int       21h                      ; vstup textu
;         cmp       byte ptr ds:[buffer+1],0 ; je nàjakò znak textu ?
;         jne       sse3                     ; je nàjakò znak - vysl†n° textu

konec:
         lds       dx,cs:[old1c]
         mov       ax,251ch
         int       21h

konec0:  mov       ax,4c00h
         int       21h

sse3:

         call      prijch
         jc        sse2
         int       29h
;         mov       dl,al
;         mov       ah,2
;         int       21h
         jmp       short sse2



;         call      vysil                  ;* vysl†n° vàty
;         jnc       sse5
;         lea       dx,[errtime]
;         mov       ah,9
;         int       21h
;                                          ;* p©°jem vàty
;sse5:    call      prijem
;         jnc       sse20
;         lea       dx,[errtime]
;         mov       ah,9
;         int       21h
;sse20:   mov       cl,ds:[buffer+1]
;         xor       ch,ch
;         jcxz      sse24
;         lea       si,[buffer+2]
;sse21:   lodsb
;         mov       dl,al
;         mov       ah,2
;         int       21h
;         loop      sse21
;sse24:   jmp       short sse2
;


vysil:                                    ;* vysl†n° vàty
                                            ; VùSTUP: CY=TIME-OUT nebo chyba
                                            ;         BL=kontroln° souáet

         mov       al,KOMV
         call      vyskom                   ; poëadavek na p©°jem
vysil2:  call      prijch                   ; áek†n° na p©°jem znaku
         jc        vysil6                   ; chyba TIME-OUT
         cmp       al,EOT
         stc
         je        vysil6
         cmp       al,ACK
         jne       vysil2
         xor       bl,bl                    ; kontroln° souáet LRC
         lea       si,[buffer+2]            ; adresa uloëenÇho textu
         mov       al,STX
         call      vysch                    ; vysl†n° STX
                                          ;* vysl†n° £vodn°ch k¢dñ
         mov       cx,6                     ; poáet bin†rn°ch znakñ
vysil3:  call      load
         js        vysil5
         push      ax
         and       al,0fh
         or        al,20h
         xor       bl,al                    ; kontroln° souáet LRC
         call      vysch
         pop       ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         or        al,30h
         xor       bl,al                    ; kontroln° souáet LRC
         call      vysch
         loop      vysil3
                                          ;* vysl†n° ostatn°ho textu
vysil4:  call      load
         js        vysil5
         xor       bl,al                    ; kontroln° souáet LRC
         call      vysch
         jmp       short vysil4

vysil5:  mov       al,ETX
         xor       bl,al                    ; kontroln° souáet LRC
         call      vysch
         mov       al,bl
         call      vysch

         call      prijch                   ; áek†n° na odpovàÉ
         jc        vysil6
         cmp       al,ACK
         je        vysil6
         cmp       al,NAK
         je        vysil                    ; opakov†n° vys°l†n°

vysil6:  ret



prijem:                                   ;* p©°jem vàty
                                            ; VùSTUP: CY=TIME-OUT nebo chyba
                                            ;         BL=kontroln° souáet

         mov       al,KOMP
         call      vyskom                   ; poëadavek na vys°l†n°
prijem2: call      prijch                   ; áek†n° na p©°jem znaku
         jc        prijem6                  ; chyba TIME-OUT
         cmp       al,EOT
         je        prijem6
         cmp       al,STX
         jne       prijem2
         xor       bl,bl                    ; kontroln° souáet LRC
         mov       ds:[buffer+1],bl         ; vynulov†n° poátu znakñ
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
         cmp       al,bl
         mov       al,ACK
         je        prijem52
         mov       al,NAK
prijem52:call      vysch                    ; vysl†n° odpovàdi
prijem6: ret


load:    lodsb
         dec       byte ptr ds:[buffer+1]
         ret


store:   stosb                              ; uloëen° znaku
         clc
         inc       byte ptr ds:[buffer+1]
         jnz       store2
         dec       byte ptr ds:[buffer+1]
         stc
store2:  ret


vyskom:                                   ;* vysl†n° poëadavku spojen°
                                            ; VSTUP: AL=k¢d povelu
         push      cx
         push      ax
         mov       al,STX
         call      vysch                    ; vysl†n° znaku STX
         mov       cx,7
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
vysch1:  mov       ah,3
         mov       dx,ds:[port]
         int       14h
         test      ah,40h
         jz        vysch1
                                          ;* vysl†n° znaku
         pop       ax
         push      ax
         mov       ah,1
         mov       dx,ds:[port]
         int       14h
         pop       ax
         pop       dx
         ret


prijch:                                   ;* p©°jem jednoho znaku
                                            ; VùSTUP: AL=znak
                                            ;         CY=TIME-OUT

         push      dx
;         mov       byte ptr ds:[citac],9 ;180  ; TIME-OUT 10 sekund
prijch1: cmp       byte ptr ds:[citac],0
         stc
         je        prijch3                  ; chyba
         mov       ah,3
         mov       dx,ds:[port]
         int       14h
         test      ah,1
         jz        prijch1
                                          ;* p©°jem znaku
         mov       ah,2
         mov       dx,ds:[port]
         int       14h
prijch3: pop       dx
         ret



buffer   db        128                      ; buffer textu
         db        0
         db        128 dup(?)

errinit  db        'Chyba: nebyl zad†n port (1 nebo 2) !',13,10,'$'
errtime  db        'Chyba:  TIME-OUT !',13,10,'$'


code     ends

         end       start

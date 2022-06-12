
; -----------------------------------------------------------------------------
;                         1. kvart l instrukc¡
; -----------------------------------------------------------------------------
                                          ;* NOP
kod00:   ret

                                          ;* LD BC,a
kod01:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regbc],ax            ; ulo‘en¡ dat do registru BC
         ret

                                          ;* LD (BC),A
kod02:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       bx,ds:[regbc]            ; c¡l - registr (BC)
         mov       es:[bx],al               ; ulo‘en¡ hodnoty registru A
         ret

                                          ;* INC BC
kod03:   inc       word ptr ds:[regbc]      ; zv˜¨en¡ registru BC
         ret

                                          ;* INC B
kod04:   inc       byte ptr ds:[regb]       ; zv˜¨en¡ registru B
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC B
kod05:   dec       byte ptr ds:[regb]       ; dekrementace registru B
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD B,d
kod06:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regb],al             ; ulo‘en¡ dat do registru B
         ret

                                          ;* RLCA
kod07:   mov       al,ds:[rega]             ; registr A
         rol       al,1                     ; rotace o 1 bit vlevo
         mov       ds:[rega],al             ; ulo‘en¡ nov‚ hodnoty A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0edh                  ; nulov n¡ p©¡znaku s‡¡t n¡ a HC
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* EX AF,AF'
kod08:   mov       al,ds:[rega]             ; registr A
         xchg      al,ds:[regax]            ; z mˆna s registrem A'
         mov       ds:[rega],al             ; ulo‘en¡ zamˆnˆn‚ hodnoty
         ret

                                          ;* ADD HL,BC
kod09:   mov       ax,ds:[regbc]            ; registr BC
         add       ds:[reghl],ax            ; p©i‡ten¡ k registru HL
         lahf                               ; p©enos registru p©¡znak–
         and       byte ptr ds:[regf],0ech  ; nulov n¡ HC,N a CY
         and       ah,11h                   ; ponech  p©¡znaky HC a CY
         or        ds:[regf],ah             ; nastaven¡ p©¡znak– HC a CY
         ret

                                          ;* LD A,(BC)
kod0a:   mov       bx,ds:[regbc]            ; zdroj - registr (BC)
         mov       al,es:[bx]               ; na‡ten¡ hodnoty registru A
         mov       ds:[rega],al             ; c¡l - registr A
         ret

                                          ;* DEC BC
kod0b:   dec       word ptr ds:[regbc]      ; dekrementace registru BC
         ret

                                          ;* INC C
kod0c:   inc       byte ptr ds:[regc]       ; zv˜¨en¡ registru C
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC C
kod0d:   dec       byte ptr ds:[regc]       ; dekrementace registru C
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD C,d
kod0e:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regc],al             ; ulo‘en¡ dat do registru C
         ret

                                          ;* RRCA
kod0f:   mov       al,ds:[rega]             ; registr A
         ror       al,1                     ; rotace o 1 bit vpravo
         mov       ds:[rega],al             ; ulo‘en¡ nov‚ hodnoty A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0edh                  ; nulov n¡ p©¡znaku s‡¡t n¡ a HC
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                          ;* DJNZ e
kod10:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         dec       byte ptr ds:[regb]       ; sn¡‘en¡ registru B
         jz        kod101                   ; je ji‘ dosa‘eno 0 registru B
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
kod101:  ret

                                          ;* LD DE,a
kod11:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regde],ax            ; ulo‘en¡ dat do registru DE
         ret

                                          ;* LD (DE),A
kod12:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       bx,ds:[regde]            ; c¡l - registr (DE)
         mov       es:[bx],al               ; ulo‘en¡ hodnoty registru A
         ret

                                          ;* INC DE
kod13:   inc       word ptr ds:[regde]      ; zv˜¨en¡ registru DE
         ret

                                          ;* INC D
kod14:   inc       byte ptr ds:[regd]       ; zv˜¨en¡ registru D
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC D
kod15:   dec       byte ptr ds:[regd]       ; dekrementace registru D
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD D,d
kod16:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regd],al             ; ulo‘en¡ dat do registru D
         ret

                                          ;* RLA
kod17:   mov       al,ds:[rega]             ; registr A
         rcl       al,1                     ; rotace o 1 bit vlevo
         mov       ds:[rega],al             ; ulo‘en¡ nov‚ hodnoty A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0edh                  ; nulov n¡ p©¡znaku s‡¡t n¡ a HC
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* JR e
kod18:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
         ret

                                          ;* ADD HL,DE
kod19:   mov       ax,ds:[regde]            ; registr DE
         add       ds:[reghl],ax            ; p©i‡ten¡ k registru HL
         lahf                               ; p©enos registru p©¡znak–
         and       byte ptr ds:[regf],0ech  ; nulov n¡ HC,N a CY
         and       ah,11h                   ; ponech  p©¡znaky HC a CY
         or        ds:[regf],ah             ; nastaven¡ p©¡znak– HC a CY
         ret

                                          ;* LD A,(DE)
kod1a:   mov       bx,ds:[regde]            ; zdroj - registr (DE)
         mov       al,es:[bx]               ; na‡ten¡ hodnoty registru A
         mov       ds:[rega],al             ; c¡l - registr A
         ret

                                          ;* DEC DE
kod1b:   dec       word ptr ds:[regde]      ; dekrementace registru DE
         ret

                                          ;* INC E
kod1c:   inc       byte ptr ds:[rege]       ; zv˜¨en¡ registru E
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC E
kod1d:   dec       byte ptr ds:[rege]       ; dekrementace registru E
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD E,d
kod1e:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[rege],al             ; ulo‘en¡ dat do registru E
         ret

                                          ;* RRA
kod1f:   mov       al,ds:[rega]             ; registr A
         rcr       al,1                     ; rotace o 1 bit vpravo
         mov       ds:[rega],al             ; ulo‘en¡ nov‚ hodnoty A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0edh                  ; nulov n¡ p©¡znaku s‡¡t n¡ a HC
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                          ;* JR NZ,e
kod20:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jnz       kod201                   ; podm¡nka nesplnˆna - je nastaven
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
kod201:  ret

                                          ;* LD HL,a
kod21:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[reghl],ax            ; ulo‘en¡ dat do registru HL
         ret

                                          ;* LD (a),HL
kod22:   mov       ax,ds:[reghl]            ; zdroj - registr HL
         mov       bx,es:[bp]               ; c¡lov  adresa
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       es:[bx],ax               ; ulo‘en¡ hodnoty registru HL
         ret

                                          ;* INC HL
kod23:   inc       word ptr ds:[reghl]      ; zv˜¨en¡ registru HL
         ret

                                          ;* INC H
kod24:   inc       byte ptr ds:[regh]       ; zv˜¨en¡ registru H
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC H
kod25:   dec       byte ptr ds:[regh]       ; dekrementace registru H
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD H,d
kod26:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regh],al             ; ulo‘en¡ dat do registru H
         ret

                                          ;* DAA
kod27:   mov       al,ds:[rega]             ; registr A
         test      byte ptr ds:[regf],2     ; bylo ode‡¡t n¡ ?
         jnz       kod271                   ; bylo ode‡¡t n¡
         daa                                ; dekadick  korekce po s‡¡t n¡
         jmp       short kod272
kod271:  das                                ; dekadick  korekce po ode‡¡t n¡
kod272:  mov       ds:[rega],al             ; ulo‘en¡ nov‚ hodnoty A
         lahf                               ; p©enos registru p©¡znak–
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* JR Z,e
kod28:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jz        kod281                   ; podm¡nka nesplnˆna - nen¡ nastaven
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
kod281:  ret

                                          ;* ADD HL,HL
kod29:   mov       ax,ds:[reghl]            ; registr HL
         add       ds:[reghl],ax            ; p©i‡ten¡ k registru HL
         lahf                               ; p©enos registru p©¡znak–
         and       byte ptr ds:[regf],0ech  ; nulov n¡ HC,N a CY
         and       ah,11h                   ; ponech  p©¡znaky HC a CY
         or        ds:[regf],ah             ; nastaven¡ p©¡znak– HC a CY
         ret

                                          ;* LD HL,(a)
kod2a:   mov       bx,es:[bp]               ; zdrojov˜ operand
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       ax,es:[bx]               ; na‡ten¡ hodnoty registru HL
         mov       ds:[reghl],ax            ; c¡l - registr HL
         ret

                                          ;* DEC HL
kod2b:   dec       word ptr ds:[reghl]      ; dekrementace registru HL
         ret

                                          ;* INC L
kod2c:   inc       byte ptr ds:[regl]       ; zv˜¨en¡ registru L
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC L
kod2d:   dec       byte ptr ds:[regl]       ; dekrementace registru L
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD L,d
kod2e:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regl],al             ; ulo‘en¡ dat do registru L
         ret

                                          ;* CPL
kod2f:   not       byte ptr ds:[rega]       ; komplement registru A
         or        byte ptr ds:[regf],12h   ; nastaven¡ p©¡znak– HC a N
         ret

; -----------------------------------------------------------------------------

                                          ;* JR NC,e
kod30:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jnz       kod301                   ; podm¡nka nesplnˆna - je nastaven
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
kod301:  ret

                                          ;* LD SP,a
kod31:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[regsp],ax            ; ulo‘en¡ dat do registru SP
         ret

                                          ;* LD (a),A
kod32:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       bx,es:[bp]               ; c¡lov  adresa
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       es:[bx],al               ; ulo‘en¡ hodnoty registru A
         ret

                                          ;* INC SP
kod33:   inc       word ptr ds:[regsp]      ; zv˜¨en¡ registru SP
         ret

                                          ;* INC (HL)
kod34:   mov       bx,ds:[reghl]            ; adresa operandu (HL)
         inc       byte ptr es:[bx]         ; zv˜¨en¡ registru (HL)
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC (HL)
kod35:   mov       bx,ds:[reghl]            ; adresa operandu (HL)
         dec       byte ptr es:[bx]         ; dekrementace registru (HL)
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD (HL),d
kod36:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       bx,ds:[reghl]            ; adresa operandu (HL)
         mov       es:[bx],al               ; ulo‘en¡ dat do registru (HL)
         ret

                                          ;* SCF
kod37:   or        byte ptr ds:[regf],1     ; nastaven¡ p©¡znaku CF
         ret

                                          ;* JR C,e
kod38:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jz        kod381                   ; podm¡nka nesplnˆna - nen¡ nastaven
         cbw                                ; p©evod AL na AX
         add       ax,bp                    ; v˜po‡et nov‚ adresy skoku
         mov       bp,ax                    ; nov  adresa skoku
kod381:  ret

                                          ;* ADD HL,SP
kod39:   mov       ax,ds:[regsp]            ; registr SP
         add       ds:[reghl],ax            ; p©i‡ten¡ k registru HL
         lahf                               ; p©enos registru p©¡znak–
         and       byte ptr ds:[regf],0ech  ; nulov n¡ HC,N a CY
         and       ah,11h                   ; ponech  p©¡znaky HC a CY
         or        ds:[regf],ah             ; nastaven¡ p©¡znak– HC a CY
         ret

                                          ;* LD A,(a)
kod3a:   mov       bx,es:[bp]               ; zdrojov˜ operand
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       al,es:[bx]               ; na‡ten¡ hodnoty registru A
         mov       ds:[rega],al             ; c¡l - registr A
         ret

                                          ;* DEC SP
kod3b:   dec       word ptr ds:[regsp]      ; dekrementace registru SP
         ret

                                          ;* INC A
kod3c:   inc       byte ptr ds:[rega]       ; zv˜¨en¡ registru A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nulov n¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* DEC A
kod3d:   dec       byte ptr ds:[rega]       ; dekrementace registru A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* LD A,d
kod3e:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ds:[rega],al             ; ulo‘en¡ dat do registru A
         ret

                                          ;* CCF
kod3f:   xor       byte ptr ds:[regf],1     ; komplement p©¡znaku CF
         ret

; -----------------------------------------------------------------------------
;                            instrukce LD reg8,reg8
; -----------------------------------------------------------------------------

kod40:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod41:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod42:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod43:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod44:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod45:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod46:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod47:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[regb],al             ; c¡l - registr B
         ret

; -----------------------------------------------------------------------------

kod48:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod49:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[regc],al             ; c¡l - registr C
         ret

kod4f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[regc],al             ; c¡l - registr C
         ret

; -----------------------------------------------------------------------------

kod50:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod51:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod52:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod53:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod54:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod55:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[regd],al             ; c¡l - registr D
         ret

kod56:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[regb],al             ; c¡l - registr B
         ret

kod57:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[regd],al             ; c¡l - registr D
         ret

; -----------------------------------------------------------------------------

kod58:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod59:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[rege],al             ; c¡l - registr E
         ret

kod5f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[rege],al             ; c¡l - registr E
         ret

; -----------------------------------------------------------------------------

kod60:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod61:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod62:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod63:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod64:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod65:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod66:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[regh],al             ; c¡l - registr H
         ret

kod67:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[regh],al             ; c¡l - registr H
         ret

; -----------------------------------------------------------------------------

kod68:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod69:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[regl],al             ; c¡l - registr L
         ret

kod6f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[regl],al             ; c¡l - registr L
         ret

; -----------------------------------------------------------------------------

kod70:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod71:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod72:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod73:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod74:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod75:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

kod76:                                      ; HALT
         jmp       sluzby                   ; vyvol n¡ slu‘eb syst‚mu

kod77:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       bx,ds:[reghl]            ; c¡l - registr (HL)
         mov       es:[bx],al               ; ulo‘en¡ bajtu na adresu (HL)
         ret

; -----------------------------------------------------------------------------

kod78:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod79:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ds:[rega],al             ; c¡l - registr A
         ret

kod7f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ds:[rega],al             ; c¡l - registr A
         ret

; -----------------------------------------------------------------------------
;                        aritmetick‚ operace 8 bit–
; -----------------------------------------------------------------------------

                                            ; ADD

kod80:   mov       al,ds:[regb]             ; zdroj - registr B
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod81:   mov       al,ds:[regc]             ; zdroj - registr C
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod82:   mov       al,ds:[regd]             ; zdroj - registr D
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod83:   mov       al,ds:[rege]             ; zdroj - registr E
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod84:   mov       al,ds:[regh]             ; zdroj - registr H
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod85:   mov       al,ds:[regl]             ; zdroj - registr L
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod86:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod87:   mov       al,ds:[rega]             ; zdroj - registr A
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                            ; ADC

kod88:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru k A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod89:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru k A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod8f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                            ; SUB

kod90:   mov       al,ds:[regb]             ; zdroj - registr B
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod91:   mov       al,ds:[regc]             ; zdroj - registr C
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod92:   mov       al,ds:[regd]             ; zdroj - registr D
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod93:   mov       al,ds:[rege]             ; zdroj - registr E
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod94:   mov       al,ds:[regh]             ; zdroj - registr H
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod95:   mov       al,ds:[regl]             ; zdroj - registr L
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod96:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod97:   mov       al,ds:[rega]             ; zdroj - registr A
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                            ; SBC

kod98:   mov       al,ds:[regb]             ; zdroj - registr B
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod99:   mov       al,ds:[regc]             ; zdroj - registr C
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9a:   mov       al,ds:[regd]             ; zdroj - registr D
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9b:   mov       al,ds:[rege]             ; zdroj - registr E
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9c:   mov       al,ds:[regh]             ; zdroj - registr H
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9d:   mov       al,ds:[regl]             ; zdroj - registr L
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9e:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kod9f:   mov       al,ds:[rega]             ; zdroj - registr A
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ registru
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                            ; AND

koda0:   mov       al,ds:[regb]             ; zdroj - registr B
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda1:   mov       al,ds:[regc]             ; zdroj - registr C
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda2:   mov       al,ds:[regd]             ; zdroj - registr D
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda3:   mov       al,ds:[rege]             ; zdroj - registr E
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda4:   mov       al,ds:[regh]             ; zdroj - registr H
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda5:   mov       al,ds:[regl]             ; zdroj - registr L
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda6:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda7:   mov       al,ds:[rega]             ; zdroj - registr A
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------
                                            ; XOR

koda8:   mov       al,ds:[regb]             ; zdroj - registr B
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

koda9:   mov       al,ds:[regc]             ; zdroj - registr C
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodaa:   mov       al,ds:[regd]             ; zdroj - registr D
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodab:   mov       al,ds:[rege]             ; zdroj - registr E
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodac:   mov       al,ds:[regh]             ; zdroj - registr H
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodad:   mov       al,ds:[regl]             ; zdroj - registr L
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodae:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodaf:   mov       al,ds:[rega]             ; zdroj - registr A
         xor       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------

                                            ; OR

kodb0:   mov       al,ds:[regb]             ; zdroj - registr B
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb1:   mov       al,ds:[regc]             ; zdroj - registr B
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb2:   mov       al,ds:[regd]             ; zdroj - registr D
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb3:   mov       al,ds:[rege]             ; zdroj - registr E
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb4:   mov       al,ds:[regh]             ; zdroj - registr H
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb5:   mov       al,ds:[regl]             ; zdroj - registr L
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb6:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb7:   mov       al,ds:[rega]             ; zdroj - registr A
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------
                                            ; CP

kodb8:   mov       al,ds:[regb]             ; zdroj - registr B
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodb9:   mov       al,ds:[regc]             ; zdroj - registr C
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodba:   mov       al,ds:[regd]             ; zdroj - registr D
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodbb:   mov       al,ds:[rege]             ; zdroj - registr E
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodbc:   mov       al,ds:[regh]             ; zdroj - registr H
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodbd:   mov       al,ds:[regl]             ; zdroj - registr L
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodbe:   mov       bx,ds:[reghl]            ; zdroj - registr (HL)
         mov       al,es:[bx]               ; bajt na adrese (HL)
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

kodbf:   mov       al,ds:[rega]             ; zdroj - registr A
         cmp       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

; -----------------------------------------------------------------------------
;                          4. kvart l instrukc¡ 00
; -----------------------------------------------------------------------------

                                          ;* RET NZ
kodc0:   test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jnz       kodc01                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodc01:  ret

                                          ;* POP BC
kodc1:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ hodnoty ze z sobn¡ku
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       ds:[regbc],ax            ; nov  hodnota registru BC
         ret

                                          ;* JP NZ,a
kodc2:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jnz       kodc21                   ; podm¡nka nesplnˆna - je nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodc21:  ret

                                          ;* JP a
kodc3:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
         ret

                                          ;* CALL NZ,a
kodc4:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jnz       kodc41                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodc41:  ret

                                          ;* PUSH BC
kodc5:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       ax,ds:[regbc]            ; registr BC
         mov       es:[bx],ax               ; ulo‘en¡ registru BC
         ret

                                          ;* ADD A,d
kodc6:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         add       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 00h
kodc7:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,0                     ; nov  adresa
         ret

                                          ;* RET Z
kodc8:   test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jz        kodc81                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodc81:  ret

                                          ;* RET
kodc9:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
         ret

                                          ;* JP Z,a
kodca:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jz        kodca1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodca1:  ret

                                          ;* CALL Z,a
kodcc:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],40h   ; test p©¡znaku ZF
         jz        kodcc1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodcc1:  ret

                                          ;* CALL a
kodcd:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
         ret

                                          ;* ADC A,d
kodce:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         adc       ds:[rega],al             ; p©i‡ten¡ registru k A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 08h
kodcf:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,8                     ; nov  adresa
         ret

; -----------------------------------------------------------------------------

                                          ;* RET NC
kodd0:   test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jnz       kodd01                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodd01:  ret

                                          ;* POP DE
kodd1:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ hodnoty ze z sobn¡ku
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       ds:[regde],ax            ; nov  hodnota registru DE
         ret

                                          ;* JP NC,a
kodd2:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jnz       kodd21                   ; podm¡nka nesplnˆna - je nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodd21:  ret

                                          ;* OUT (d),A
kodd3:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele programu
                                            ; ..........
         ret

                                          ;* CALL NC,a
kodd4:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jnz       kodd41                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodd41:  ret

                                          ;* PUSH DE
kodd5:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       ax,ds:[regde]            ; registr DE
         mov       es:[bx],ax               ; ulo‘en¡ registru DE
         ret

                                          ;* ADD A,d
kodd6:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         sub       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 10h
kodd7:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,10h                   ; nov  adresa
         ret

                                          ;* RET C
kodd8:   test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jz        kodd81                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodd81:  ret

                                          ;* EXX
kodd9:   mov       ax,ds:[regbc]
         xchg      ax,ds:[regbcx]
         mov       ds:[regbc],ax
         mov       ax,ds:[regde]
         xchg      ax,ds:[regdex]
         mov       ds:[regde],ax
         mov       ax,ds:[reghl]
         xchg      ax,ds:[reghlx]
         mov       ds:[reghl],ax
         ret

                                          ;* JP C,a
kodda:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jz        kodda1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodda1:  ret

                                          ;* IN A,(d)
koddb:   ret

                                          ;* CALL C,a
koddc:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],1     ; test p©¡znaku CF
         jz        koddc1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
koddc1:  ret

                                          ;* SBC A,d
kodde:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         mov       ah,byte ptr ds:[regf]    ; registr p©¡znak–
         shr       ah,1                     ; bit C do CF
         sbb       ds:[rega],al             ; ode‡ten¡ dat od A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 18h
koddf:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,18h                   ; nov  adresa
         ret

; -----------------------------------------------------------------------------

                                          ;* RET PO
kode0:   test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jnz       kode01                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kode01:  ret

                                          ;* POP HL
kode1:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ hodnoty ze z sobn¡ku
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       ds:[reghl],ax            ; nov  hodnota registru HL
         ret

                                          ;* JP PO,a
kode2:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jnz       kode21                   ; podm¡nka nesplnˆna - je nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kode21:  ret

                                          ;* EX (SP),HL
kode3:   mov       ax,ds:[reghl]            ; registr HL
         mov       bx,ds:[regsp]            ; registr SP
         xchg      ax,es:[bx]               ; z mˆna HL a (SP)
         mov       ds:[reghl],ax            ; ulo‘en¡ HL
         ret

                                          ;* CALL PO,a
kode4:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jnz       kode41                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kode41:  ret

                                          ;* PUSH HL
kode5:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       ax,ds:[reghl]            ; registr HL
         mov       es:[bx],ax               ; ulo‘en¡ registru HL
         ret

                                          ;* AND d
kode6:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         and       ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 20h
kode7:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,20h                   ; nov  adresa
         ret

                                          ;* RET PE
kode8:   test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jz        kode81                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kode81:  ret

                                          ;* JP (HL)
kode9:   mov       bp,ds:[reghl]            ; nov  adresa - registr HL
         ret

                                          ;* JP PE,a
kodea:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jz        kodea1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodea1:  ret

                                          ;* EX DE,HL
kodeb:   mov       ax,ds:[regde]
         xchg      ax,ds:[reghl]
         mov       ds:[regde],ax
         ret

                                          ;* CALL PE,a
kodec:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],4     ; test p©¡znaku P
         jz        kodec1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodec1:  ret

                                          ;* XOR d
kodee:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         xor       ds:[rega],al             ; operace s A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 28h
kodef:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,28h                   ; nov  adresa
         ret

; -----------------------------------------------------------------------------

                                          ;* RET P
kodf0:   test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jnz       kodf01                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodf01:  ret

                                          ;* POP AF
kodf1:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ hodnoty ze z sobn¡ku
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       ds:[regaf],ax            ; nov  hodnota registru AF
         ret

                                          ;* JP P,a
kodf2:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jnz       kodf21                   ; podm¡nka nesplnˆna - je nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodf21:  ret

                                          ;* DI
kodf3:   ret

                                          ;* CALL P,a
kodf4:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jnz       kodf41                   ; podm¡nka nesplnˆna - je nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodf41:  ret

                                          ;* PUSH AF
kodf5:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       ax,ds:[regaf]            ; registr AF
         mov       es:[bx],ax               ; ulo‘en¡ registru AF
         ret

                                          ;* OR d
kodf6:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         or        ds:[rega],al             ; c¡l - registr A
         lahf                               ; p©enos registru p©¡znak–
         and       ah,0fdh                  ; nastaven¡ p©¡znaku s‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 30h
kodf7:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,30h                   ; nov  adresa
         ret

                                          ;* RET M
kodf8:   test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jz        kodf81                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         mov       ax,es:[bx]               ; p©e‡ten¡ n vratov‚ adresy
         add       bx,2                     ; zv˜¨en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; nov  hodnota ukazatele z sobn¡ku
         mov       bp,ax                    ; nov  adresa ukazatele instrukc¡
kodf81:  ret

                                          ;* LD SP,HL
kodf9:   mov       ax,ds:[reghl]            ; zdroj - registr HL
         mov       ds:[regsp],ax            ; c¡l - registr SP
         ret

                                          ;* JP M,a
kodfa:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele programu
         test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jz        kodfa1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bp,ax                    ; nov  hodnota ukazatele instrukc¡
kodfa1:  ret

                                          ;* EI
kodfb:   ret

                                          ;* CALL M,a
kodfc:   mov       ax,es:[bp]               ; operand instrukce
         add       bp,2                     ; zv˜¨en¡ ukazatele instrukc¡
         test      byte ptr ds:[regf],80h   ; test p©¡znaku S
         jz        kodfc1                   ; podm¡nka nesplnˆna - nen¡ nastaven
         mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,ax                    ; nov  adresa
kodfc1:  ret

                                          ;* CP d
kodfe:   mov       al,es:[bp]               ; operand instrukce
         inc       bp                       ; zv˜¨en¡ ukazatele instrukc¡
         cmp       ds:[rega],al             ; operace s A
         lahf                               ; p©enos registru p©¡znak–
         or        ah,2                     ; nastaven¡ p©¡znaku ode‡¡t n¡
         mov       ds:[regf],ah             ; ulo‘en¡ registru p©¡znak–
         ret

                                          ;* RST 38h
kodff:   mov       bx,ds:[regsp]            ; ukazatel z sobn¡ku
         sub       bx,2                     ; sn¡‘en¡ ukazatele z sobn¡ku
         mov       ds:[regsp],bx            ; ulo‘en¡ nov‚ hodnoty ukazatele SP
         mov       es:[bx],bp               ; ulo‘en¡ n vratov‚ adresy
         mov       bp,38h                   ; nov  adresa
         ret

; -----------------------------------------------------------------------------

                                          ;* prefix CB
kodcb:
         ret

koddd:                                    ;* prefix DD
         ret

koded:                                    ;* prefix ED
         ret

kodfd:                                    ;* prefix FD
         ret

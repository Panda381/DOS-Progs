; Zpomalova‡ chodu po‡¡ta‡e o 25% - pou‘¡v  se p©edev¨¡m p©i p©en ¨en¡ her
; ze star¨¡ch pomal˜ch po‡¡ta‡– typu PC,XT.

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h                     ; za‡ tek programu COM

;------------------------------- rezidentn¡ ‡ st ------------------------------

start:   jmp       short init               ; inicializace programu

int1c:                                    ;* obsluha INT 8 (proveden¡ zpo‘dˆn¡)
         pushf                              ; simulace vol n¡ INT
         call      dword ptr cs:[old1c]     ; vol n¡ p–vodn¡ obsluhy INT 1Ch
         test      byte ptr cs:[par13],0ffh ; prob¡h  obsluha INT 13h ?
         jnz       int1c2                   ; prob¡h  obsluha INT 13h - konec
         push      cx                       ; £schova registru CX
prodl:   mov       cx,1                     ; doba prodlevy (nast. inicializace)
int1c1:  cmp       byte ptr ds:[impuls],0   ; napodoben¡ smy‡ky p©i inicializaci
         loop      int1c1                   ; prodleva
         pop       cx                       ; n vrat registru CX
int1c2:  iret                               ; n vrat z p©eru¨en¡

int13:                                    ;* monitorov n¡ p©eru¨en¡ INT 13h
         mov       cs:[par13],-1            ; p©¡znak obsluhy INT 13h
         pushf                              ; simulace vol n¡ INT
         call      dword ptr cs:[old13]     ; p–vodn¡ obsluha INT 13h
         mov       cs:[par13],0             ; zru¨en¡ p©¡znaku INT 13h
         iret

old1c    dd        0                        ; adresa p–vodn¡ obsluhy INT 8
old13    dd        0                        ; adresa obsluhy INT 13h
par13    db        0                        ; p©¡znak prob¡haj¡c¡ho INT 13h

; ------------------------------ instala‡n¡ ‡ st ------------------------------

init:                                     ;* inicializace a instalace programu
                                          ;* £schova p–vodn¡ch adres p©eru¨en¡
         mov       ax,351ch                 ; funkce poskytnut¡ adresy INT 1Ch
         int       21h                      ; poskytnut¡ adresy INT 1Ch
         mov       word ptr [old1c],bx      ; £schova offsetu adresy INT 1Ch
         mov       word ptr [old1c+2],es    ; £schova segmentu adresy INT 1Ch
         mov       ax,3513h                 ; funkce poskytnut¡ adresy INT 13h
         int       21h                      ; poskytnut¡ adresy INT 13h
         mov       word ptr [old13],bx      ; £schova offsetu adresy INT 13h
         mov       word ptr [old13+2],es    ; £schova segmentu adresy INT 13h
                                          ;* nastaven¡ ‡asov‚ konstanty PRODL
         mov       dx,offset int1cx         ; pracovn¡ adresa obsluha INT 1Ch
         mov       ax,251ch                 ; funkce nastaven¡ adresy INT 1Ch
         int       21h                      ; nastaven¡ adresy INT 1Ch
         xor       ax,ax                    ; AX <- 0 testovac¡ hodnota
         mov       byte ptr ds:[impuls],1   ; nastaven¡ ‡ek n¡ na 1 impuls
test1:   cmp       byte ptr ds:[impuls],al  ; p©i¨el ji‘ 1.impuls ?
         jnz       test1                    ; ‡ek n¡ na p©eru¨en¡ 1.impulsem
         mov       cx,0ffffh                ; v˜choz¡ hodnota
         inc       byte ptr ds:[impuls]     ; nastaven¡ ‡ek n¡ na 1 impuls
test2:   cmp       byte ptr ds:[impuls],al  ; p©i¨el ji‘ 2.impuls ?
         loopnz    test2                    ; ‡ek n¡ na 2.impuls
         dec       ax                       ; AX <- 0ffffh (v˜choz¡ prodleva)
         sub       ax,cx                    ; namˆ©en  doba prodlevy
         shr       ax,1                     ; prodleva/2 = 50% prodlevy
         shr       ax,1                     ; prodleva/4 = 25% prodlevy
         inc       ax                       ; rezerva 1 takt pro p©¡pad AX=0
         mov       word ptr cs:[prodl+1],ax ; nastaven¡ doby prodlevy
                                          ;* instalace obsluh p©eru¨en¡
         mov       dx,offset int1c          ; offset adresy obsluhy INT 1Ch
         mov       ax,251ch                 ; funkce nastaven¡ adresy INT 1Ch
         int       21h                      ; nastaven¡ adresy INT 1Ch
         mov       dx,offset int13          ; offset adresy obsluhy INT 13h
         mov       ax,2513h                 ; funkce nastaven¡ adresy INT 13h
         int       21h                      ; nastaven¡ adresy INT 13h
                                          ;* zobrazen¡ £vodn¡ho textu, konec
         mov       dx,offset text           ; £vodn¡ text
         mov       ah,9                     ; funkce tisku textu na displej
         int       21h                      ; zobrazen¡ textu na displeji
         mov       dx,offset(init-start+100h+15) SHR 4; d‚lka rezidentn¡ ‡ sti
         mov       ah,31h                   ; funkce ukon‡en¡ rezidentn¡ho prog.
         int       21h                      ; ukon‡en¡ jako rezidentn¡

impuls   db        0                        ; ‡¡ta‡ impuls– syst‚mov˜ch hodin

int1cx:                                   ;* pracovn¡ obsluha INT 1Ch
         pushf                              ; simulace vol n¡ instrukce INT
         call      dword ptr cs:[old1c]     ; p–vodn¡ obsluha INT 1Ch
         dec       byte ptr cs:[impuls]     ; sn¡‘en¡ ‡¡ta‡e impuls–
         iret

text     db        'Po‡¡ta‡ zpomalen o 25%.',13,10,'$'

code     ENDS

         END       start               ; startovac¡ adresa

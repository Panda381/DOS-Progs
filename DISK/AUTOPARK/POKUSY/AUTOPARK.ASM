code     segment
         assume    cs:code,ds:code
doba     equ       2*18                     ; doba pro zaparkov n¡ v 1/18 sek.
         org       100h                     ; p©eklad k¢du jako program .COM

autopark:jmp       instal                   ; skok na instalaci programu

citac    dw        doba                     ; ‡¡ta‡ doby pro autoparkov n¡
old13    dd        0                        ; adresa p–vodn¡ obsluhy INT 13h
old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
inter    db        80h                      ;   bit 0: prob¡h  obsluha INT 13h
                                            ;   bit 1: prob¡h  obsluha parkov n¡
                                            ;   bit 7: nen¡ po‘adov no parkov n¡
;-------------------------- monitorov n¡ obsluhy INT 13h ----------------------
int13    proc      far                    ;* obsluha p©eru¨en¡ INT 13h
         or        byte ptr cs:[inter],1    ; nastaven¡ p©¡znaku obsluhy INT 13h
         or        dl,dl                    ; je p©¡stup na pevn˜ disk ?
         jns       int131                   ; nen¡ p©¡stup na pevn˜ disk
int130:  mov       word ptr cs:[citac],doba ; inicializace ‡¡ta‡e pro parkov n¡
int131:  call      int13x                   ; vol n¡ p–vodn¡ obsluhy INT 13h
         pushf                              ; £schova navr cen˜ch p©¡znak–
         and       byte ptr cs:[inter],not 1; zru¨en¡ p©¡znaku obsluhy INT 13h
         popf                               ; n vrat navr cen˜ch p©¡znak–
         ret       +2                       ; n vrat bez obnoven¡ p©¡znak–
int13    endp
; --------------------- vol n¡ p–vodn¡ obsluhy INT 13h ------------------------
int13x:  pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vol n¡ p–vodn¡ obsluhy INT 13h
         ret
; --------------------- ‡asov n¡ pro automatick‚ parkov n¡ --------------------
int08:                                    ;* obsluha p©eru¨en¡ INT 08h
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old08]     ; vol n¡ p–vodn¡ obsluhy INT 08h
         cmp       word ptr cs:[citac],0    ; je ‡¡ta‡ doby parkov n¡ ji‘ 0 ?
         je        int081                   ; je ji‘ dosa‘eno 0 ‡¡ta‡e doby
         dec       word ptr cs:[citac]      ; sn¡‘en¡ ‡¡ta‡e doby parkov n¡
         jnz       int083                   ; nen¡ je¨tˆ dosa‘eno 0 ‡¡ta‡e doby
         and       byte ptr cs:[inter],7fh  ; p©¡znak po‘adavku parkov n¡
int081:  test      byte ptr cs:[inter],83h  ; je mo‘n‚ prov‚st parkov n¡ ?
         jnz       int083                   ; nen¡ mo‘n‚ prov‚st parkov n¡
                                          ;* provede se zaparkov n¡ disk–
         or        byte ptr cs:[inter],82h  ; zru¨en¡ po‘adavku parkov n¡
         sti                                ; povolen¡ p©eru¨en¡
         push      ax                       ; £schova registru AX
         push      bx                       ; £schova registru BX
         push      cx                       ; £schova registru CX
         push      dx                       ; £schova registru DX
         push      di                       ; £schova registru DI
         push      es                       ; £schova registru ES
         mov       dl,80h                   ; ‡¡slo prvn¡ho pevn‚ho disku
         mov       bx,104h                  ; offset adresy INT 41h
         call      park                     ; parkov n¡ prvn¡ho pevn‚ho disku
         mov       ah,8                     ; funkce dotazu na diskov‚ parametry
         call      int13x                   ; poskytnut¡ parametr– pevn‚ho disku
         dec       dl                       ; jsou 2 pevn‚ disky ?
         jz        int082                   ; je pouze 1 pevn˜ disk
         mov       dl,81h                   ; ‡¡slo druh‚ho pevn‚ho disku
         mov       bx,118h                  ; offset adresy INT 46h
         call      park                     ; parkov n¡ druh‚ho pevn‚ho disku
int082:  pop       es                       ; n vrat registru ES
         pop       di                       ; n vrat registru DI
         pop       dx                       ; n vrat registru DX
         pop       cx                       ; n vrat registru CX
         pop       bx                       ; n vrat registru BX
         pop       ax                       ; n vrat registru AX
         and       byte ptr cs:[inter],not 2; zru¨en¡ p©¡znaku obsluhy parkov n¡
int083:  iret                               ; n vrat z obsluhy p©eru¨en¡ INT 08h
; ----------------------- zaparkov n¡ jednoho pevn‚ho disku -------------------
park:                                     ;* parkov n¡ pevn‚ho disku DL
         xor       ax,ax                    ; slu‘ba 0 - reset pevn‚ho disku DL
         call      int13x                   ; resetov n¡ pevn‚ho disku DL
         mov       cx,4                     ; po‡et pokus– o zaparkov n¡
park1:   push      cx                       ; £schova ‡¡ta‡e pokus– o parkov n¡
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       di,es:[bx]               ; offset tabulku diskov˜ch parametr–
         mov       es,es:[bx+2]             ; segment tabulky disk. parametr–
         mov       cx,es:[di+0ch]           ; parkovac¡ stopa disku
         ror       ch,1
         ror       ch,1                     ; p©enesen¡ vy¨¨¡ch 2 bit–
         xchg      ch,cl                    ; CH<-ni‘¨¡ch 8 bit–, CL<-vy¨¨¡ 2 b.
         mov       ah,0ch                   ; funkce vystaven¡ hlav na v lec
         call      int13x                   ; vystaven¡ hlav na parkovac¡ v lec
         pop       cx                       ; n vrat ‡¡ta‡e vystaven¡
         loop      park1                    ; dal¨¡ vystaven¡ hlav
         ret
; -------------------------  instalace programu -------------------------------
instal:                                   ;* instalace programu
         mov       ax,3513h                 ; funkce poskytnut¡ adresy INT 13h
         int       21h                      ; poskytnut¡ adresy INT 13h
         mov       word ptr ds:[old13],bx   ; £schova offsetu adresy INT 13h
         mov       word ptr ds:[old13+2],es ; £schova segmentu adresy INT 13h
         mov       ax,2513h                 ; funkce nastaven¡ adresy INT 13h
         lea       dx,[int13]               ; adresa vlastn¡ obsluhy INT 13h
         int       21h                      ; nastaven¡ adresy obsluhy INT 13h
         mov       ax,3508h                 ; funkce poskytnut¡ adresy INT 08h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[old08],bx   ; £schova offsetu adresy INT 08h
         mov       word ptr ds:[old08+2],es ; £schova segmentu adresy INT 08h
         mov       ax,2508h                 ; funkce nastaven¡ adresy INT 08h
         lea       dx,[int08]               ; adresa vlastn¡ obsluhy INT 08h
         int       21h                      ; nastaven¡ adresy obsluhy INT 08h
         lea       dx,[instal]              ; konec rezidentn¡ ‡ sti programu
         int       27h                      ; instalace programu jako rezidentn¡

code     ends
         end       autopark

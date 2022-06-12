CONTEXT   0  77   6   0  55



AUTOPARK.ASM                         - # -
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


   ÿAÿuÿtÿoÿmÿaÿtÿiÿcÿkÿ‚  ÿpÿaÿrÿkÿoÿvÿ ÿnÿ¡  ÿpÿeÿvÿnÿ‚ÿhÿo  ÿdÿiÿsÿkÿu

               rezidentn¡ program pro parkov n¡ disku v klidu


    Mnoho  pevn˜ch  disk– (p©edev¨¡m star¨¡ konstrukce) vy‘aduje zaparkov n¡
hlav  p©ed  vypnut¡m  po‡¡ta‡e,  jinak hroz¡ p©i manipulaci s po‡¡ta‡em jeho
zni‡en¡.  Uveden˜  program  umo‘¤uje  automatick‚ parkov n¡ pevn‚ho disku po
ur‡it‚  dobˆ  od  posledn¡ho  p©¡stupu  na  pevn˜  disk.  Program je um¡stˆn
rezidentnˆ  v  pamˆti a pokud po ur‡itou dobu nebyla prov dˆna ‘ dn  operace
súpevn˜m   diskem,   hlavy  se  automaticky  zaparkuj¡.  Program  je  naps n
vúassembleru  ©ady  8086  a  p©ekl d  se jako COM (po p©ekladu pomoc¡ MASM a
LINK  se  provede konverze z EXE na COM pomoc¡ EXE2BIN). Jde o nejjednodu¨¨¡
variantu programu bez mo‘nosti nastavov n¡ doby pro parkov n¡










































code     segment
         assume    cs:code,ds:code
doba     equ       2*18                     ; doba pro zaparkov n¡ v 1/18 sek.

         org       100h
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
         test      dl,80h                   ; je p©¡stup na pevn˜ disk ?
         jz        int131                   ; nen¡ p©¡stup na pevn˜ disk
int130:  mov       word ptr cs:[citac],doba ; inicializace ‡¡ta‡e pro parkov n¡
int131:  pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vol n¡ p–vodn¡ obsluhy INT 13h
         pushf                              ; £schova navr cen˜ch p©¡znak–
         and       byte ptr cs:[inter],not 1; zru¨en¡ p©¡znaku obsluhy INT 13h
         popf                               ; n vrat navr cen˜ch p©¡znak–
         ret       +2                       ; n vrat bez obnoven¡ p©¡znak–
int13    endp
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
         or        byte ptr cs:[inter],82h  ; zru¨en¡ po‘adavku parkov n¡
         sti                                ; povolen¡ p©eru¨en¡
         push      dx                       ; £schova registru DX
         mov       dl,80h                   ; ‡¡slo prvn¡ho pevn‚ho disku
         call      park                     ; parkov n¡ prvn¡ho pevn‚ho disku
         cmp       dl,2                     ; jsou 2 pevn‚ disky ?
         jne       int082                   ; nejsou 2 pevn‚ disky
         mov       dl,81h                   ; ‡¡slo druh‚ho pevn‚ho disku
         call      park                     ; parkov n¡ druh‚ho pevn‚ho disku
int082:  pop       dx                       ; n vrat registru DX
         and       byte ptr cs:[inter],not 2; zru¨en¡ p©¡znaku obsluhy parkov n¡
int083:  iret                               ; n vrat z obsluhy p©eru¨en¡ INT 08h
; ----------------------- zaparkov n¡ jednoho pevn‚ho disku -------------------
park:                                     ;* parkov n¡ pevn‚ho disku DL
         push      ax                       ; £schova registru AX
         push      bx                       ; £schova registru BX
         push      cx                       ; £schova registru CX
         push      di                       ; £schova registru DI
         push      es                       ; £schova registru ES
         push      dx                       ; £schova ‡¡sla disku (v DL)
         mov       ah,8                     ; funkce dotazu na diskov‚ parametry
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; poskytnut¡ parametr– pevn‚ho disku
         pop       ax                       ; n vrat ‡¡sla disku (v AL)
         push      dx                       ; £schova po‡tu pevn˜ch disk– (v DL)
         add       ch,1                     ; zv˜¨en¡ ‡¡sla stopy o 1
         jnc       park1                    ; nen¡ p©enos do bit– 8 a 9 ‡¡sla
         add       cl,40h                   ; p©enos do bit– 8 a 9 ‡¡sla stopy
park1:   mov       dl,al                    ; ‡¡slo pevn‚ho disku
         mov       ah,0ch                   ; funkce vystaven¡ hlav na v lec
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vystaven¡ hlav na parkovac¡ v lec
         pop       dx                       ; n vrat po‡tu pevn˜ch disk– (v DL)
         pop       es                       ; n vrat registru ES
         pop       di                       ; n vrat registru DI
         pop       cx                       ; n vrat registru CX
         pop       bx                       ; n vrat registru BX
         pop       ax                       ; n vrat registru AX
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
CONTEXT   0  77   6   0  55



AUTOPARK.ASM                         - # -
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴


   �A�u�t�o�m�a�t�i�c�k��  �p�a�r�k�o�v���n��  �p�e�v�n���h�o  �d�i�s�k�u

               rezidentn� program pro parkov쟮� disku v klidu


    Mnoho  pevn쁟h  disk� (p쯥devÆm starÆ konstrukce) vy멲duje zaparkov쟮�
hlav  p쯥d  vypnut죑  po눀ta놽,  jinak hroz� p쯫 manipulaci s po눀ta놽m jeho
zni놽n�.  Uveden�  program  umo뫀uje  automatick� parkov쟮� pevn괿o disku po
ur뇁t�  dob�  od  posledn죋o  pæstupu  na  pevn�  disk.  Program je um죛t늧
rezidentn�  v  pam늯i a pokud po ur뇁tou dobu nebyla prov쟡늧a 몺dn� operace
s�pevn쁬   diskem,   hlavy  se  automaticky  zaparkuj�.  Program  je  naps쟮
v�assembleru  쯠dy  8086  a  p쯥kl쟡� se jako COM (po p쯥kladu pomoc� MASM a
LINK  se  provede konverze z EXE na COM pomoc� EXE2BIN). Jde o nejjednoduĿ�
variantu programu bez mo몁osti nastavov쟮� doby pro parkov쟮�










































code     segment
         assume    cs:code,ds:code
doba     equ       2*18                     ; doba pro zaparkov쟮� v 1/18 sek.

         org       100h
autopark:jmp       instal                   ; skok na instalaci programu

citac    dw        doba                     ; 눀ta� doby pro autoparkov쟮�
old13    dd        0                        ; adresa p뻱odn� obsluhy INT 13h
old08    dd        0                        ; adresa p뻱odn� obsluhy INT 08h
inter    db        80h                      ;   bit 0: prob죋� obsluha INT 13h
                                            ;   bit 1: prob죋� obsluha parkov쟮�
                                            ;   bit 7: nen� po멲dov쟮o parkov쟮�
;-------------------------- monitorov쟮� obsluhy INT 13h ----------------------
int13    proc      far                    ;* obsluha p쯥ru쮍n� INT 13h
         or        byte ptr cs:[inter],1    ; nastaven� pæznaku obsluhy INT 13h
         test      dl,80h                   ; je pæstup na pevn� disk ?
         jz        int131                   ; nen� pæstup na pevn� disk
int130:  mov       word ptr cs:[citac],doba ; inicializace 눀ta놽 pro parkov쟮�
int131:  pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vol쟮� p뻱odn� obsluhy INT 13h
         pushf                              ; 즧chova navr쟠en쁟h pæznak�
         and       byte ptr cs:[inter],not 1; zru쮍n� pæznaku obsluhy INT 13h
         popf                               ; n쟶rat navr쟠en쁟h pæznak�
         ret       +2                       ; n쟶rat bez obnoven� pæznak�
int13    endp
; --------------------- 놹sov쟮� pro automatick� parkov쟮� --------------------
int08:                                    ;* obsluha p쯥ru쮍n� INT 08h
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old08]     ; vol쟮� p뻱odn� obsluhy INT 08h
         cmp       word ptr cs:[citac],0    ; je 눀ta� doby parkov쟮� ji� 0 ?
         je        int081                   ; je ji� dosa멷no 0 눀ta놽 doby
         dec       word ptr cs:[citac]      ; sn죷en� 눀ta놽 doby parkov쟮�
         jnz       int083                   ; nen� je쮝� dosa멷no 0 눀ta놽 doby
         and       byte ptr cs:[inter],7fh  ; pæznak po멲davku parkov쟮�
int081:  test      byte ptr cs:[inter],83h  ; je mo몁� prov굎t parkov쟮� ?
         jnz       int083                   ; nen� mo몁� prov굎t parkov쟮�
         or        byte ptr cs:[inter],82h  ; zru쮍n� po멲davku parkov쟮�
         sti                                ; povolen� p쯥ru쮍n�
         push      dx                       ; 즧chova registru DX
         mov       dl,80h                   ; 눀slo prvn죋o pevn괿o disku
         call      park                     ; parkov쟮� prvn죋o pevn괿o disku
         cmp       dl,2                     ; jsou 2 pevn� disky ?
         jne       int082                   ; nejsou 2 pevn� disky
         mov       dl,81h                   ; 눀slo druh괿o pevn괿o disku
         call      park                     ; parkov쟮� druh괿o pevn괿o disku
int082:  pop       dx                       ; n쟶rat registru DX
         and       byte ptr cs:[inter],not 2; zru쮍n� pæznaku obsluhy parkov쟮�
int083:  iret                               ; n쟶rat z obsluhy p쯥ru쮍n� INT 08h
; ----------------------- zaparkov쟮� jednoho pevn괿o disku -------------------
park:                                     ;* parkov쟮� pevn괿o disku DL
         push      ax                       ; 즧chova registru AX
         push      bx                       ; 즧chova registru BX
         push      cx                       ; 즧chova registru CX
         push      di                       ; 즧chova registru DI
         push      es                       ; 즧chova registru ES
         push      dx                       ; 즧chova 눀sla disku (v DL)
         mov       ah,8                     ; funkce dotazu na diskov� parametry
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; poskytnut� parametr� pevn괿o disku
         pop       ax                       ; n쟶rat 눀sla disku (v AL)
         push      dx                       ; 즧chova po뇍u pevn쁟h disk� (v DL)
         add       ch,1                     ; zv삩en� 눀sla stopy o 1
         jnc       park1                    ; nen� p쯥nos do bit� 8 a 9 눀sla
         add       cl,40h                   ; p쯥nos do bit� 8 a 9 눀sla stopy
park1:   mov       dl,al                    ; 눀slo pevn괿o disku
         mov       ah,0ch                   ; funkce vystaven� hlav na v쟫ec
         pushf                              ; simulace instrukce INT xx
         call      dword ptr cs:[old13]     ; vystaven� hlav na parkovac� v쟫ec
         pop       dx                       ; n쟶rat po뇍u pevn쁟h disk� (v DL)
         pop       es                       ; n쟶rat registru ES
         pop       di                       ; n쟶rat registru DI
         pop       cx                       ; n쟶rat registru CX
         pop       bx                       ; n쟶rat registru BX
         pop       ax                       ; n쟶rat registru AX
         ret
; -------------------------  instalace programu -------------------------------
instal:                                   ;* instalace programu
         mov       ax,3513h                 ; funkce poskytnut� adresy INT 13h
         int       21h                      ; poskytnut� adresy INT 13h
         mov       word ptr ds:[old13],bx   ; 즧chova offsetu adresy INT 13h
         mov       word ptr ds:[old13+2],es ; 즧chova segmentu adresy INT 13h
         mov       ax,2513h                 ; funkce nastaven� adresy INT 13h
         lea       dx,[int13]               ; adresa vlastn� obsluhy INT 13h
         int       21h                      ; nastaven� adresy obsluhy INT 13h
         mov       ax,3508h                 ; funkce poskytnut� adresy INT 08h
         int       21h                      ; poskytnut� adresy INT 08h
         mov       word ptr ds:[old08],bx   ; 즧chova offsetu adresy INT 08h
         mov       word ptr ds:[old08+2],es ; 즧chova segmentu adresy INT 08h
         mov       ax,2508h                 ; funkce nastaven� adresy INT 08h
         lea       dx,[int08]               ; adresa vlastn� obsluhy INT 08h
         int       21h                      ; nastaven� adresy obsluhy INT 08h
         lea       dx,[instal]              ; konec rezidentn� 뇿sti programu
         int       27h                      ; instalace programu jako rezidentn�

code     ends
         end       autopark


; -----------------------------------------------------------------------------
;  Struktura z hlav¡ CD:
;
;   offset 0000:0000, 16 sektor– z hlav¡ disku (nevyu‘ito)
;   offset 0000:8000, 1 sektor popisova‡ disku (Label atd.)
;                          0:
;                        50h: (4) pocet sektoru disku (od nejnizsiho bajtu)
;                        54h: (4) pocet sektoru disku (od nejvyssiho bajtu)
;   offset 0000:8800, 1 sektor popisova‡ svazku
;                          0: (1) typ svazku (1=bˆ‘n˜, FF=posledn¡)
;                          1: (5) identifik tor svazku ("CD001")
;                          6: (1) = 1 (mo‘n  po‡et sektor– pro strom ?)
;   offset 0000:9000, 1 sektor (bˆ‘nˆ) strom adres ©– svazku
;   offset 0000:9800, za‡ tek dat
; -----------------------------------------------------------------------------
;  Struktura stromu svazku (1 polo‘ka):
;
;   P©ed polo‘kou adres ©e m–‘e p©edch zet bajt 0 jako p©¡znak, ‘e adres ©
;   m  dal¨¡ podadres ©e.
;
;     (1) d‚lka jm‚na adres ©e 1...
;     (1) = 0
;     (4) po‡ te‡n¡ sektor adres ©e (po©ad¡ od nejvy¨¨¡ho bajtu k nejni‘¨¡mu)
;     (2) ‡¡slo p©edch zej¡c¡ polo‘ky adres ©e, pod kterou pat©¡ jako podadres ©
;             (0=nem  nadadres © - je to ROOT, 1=nadadres ©em je ROOT, ...)
;             (po©ad¡ ‡¡sla od vy¨¨¡ho bajtu k ni‘¨¡mu)
;     (x) jm‚no adres ©e
;  (celkov  d‚lka polo‘ky: d‚lka jm‚na + 8 nebo 9)
; -----------------------------------------------------------------------------
;  Struktura polo‘ky v adres ©i:
;
;     (2) d‚lka popisova‡e polo‘ky (bajt–, po©ad¡ od nejni‘¨¡ho bajtu k vy¨¨¡mu)
;     (4) po‡ te‡n¡ sektor polo‘ky (po©ad¡ od nejni‘¨¡ho bajtu k nejvy¨¨¡mu)
;     (4) po‡ te‡n¡ sektor polo‘ky (po©ad¡ od nejvy¨¨¡ho bajtu k nejni‘¨¡mu)
;     (4) velikost polo‘ky v bajtech (po©ad¡ od nejni‘¨¡ho bajtu k nejvy¨¨¡mu)
;     (4) velikost polo‘ky v bajtech (po©ad¡ od nejvy¨¨¡ho bajtu k nejni‘¨¡mu)
;     (1) rok posledn¡ modifikace polo‘ky 0 a‘ 99 (bez stolet¡)
;     (1) mˆs¡c posledn¡ modifikace polo‘ky 1 a‘ 12
;     (1) den posledn¡ modifikace polo‘ky 1 a‘ 31
;     (1) hodina posledn¡ modifikace polo‘ky 0 a‘ 23
;     (1) minuta posledn¡ modifikace polo‘ky 0 a‘ 59
;     (1) sekunda posledn¡ modifikace polo‘ky 0 a‘ 59
;     (1) = 20h
;     (1) 0=soubor, 2=adres ©
;     (1) = 0
;     (1) = 0
;     (1) = 1
;     (1) = 0
;     (1) = 0
;     (1) = 1
;     (1) d‚lka jm‚na polo‘ky
;     (x) jm‚no polo‘ky
;       (1) = 3Bh Ä¿nekdy
;       (1) = 31h ÄÙ
;       (1) = 0 (nekdy)
;  (celkov  d‚lka polo‘ky: d‚lka jm‚na + 33 az 36)
; -----------------------------------------------------------------------------

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ £vodn¡ text

Start:   mov       ah,9
         mov       dx,offset UvTxt
         int       21h

; ------ test p©eru¨en¡ operace

Start1:  mov       ah,0bh
         int       21h                      ; test p©eru¨en¡ z kl vesnice

; ------ nastaven¡ ukazatele DTA pro vyhled v n¡ soubor–

         mov       dx,ds:[AktDTA]           ; aktu ln¡ adresa DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nulov n¡ ‡¡ta‡e velikosti adres ©e

         mov       word ptr ds:[SizDir],3*35 ; nulov n¡ ‡¡ta‡e adres ©e
         mov       word ptr ds:[SizDir+2],0

; ------ vyhled v n¡ soubor–

         mov       dx,offset Vsechno        ; specifikace *.*
         mov       ah,4eh
         mov       cx,110111b               ; hledat v¨e kromˆ VOL
Start2:  int       21h                      ; vyhled n¡ souboru
         jc        Start5                   ; nen¡ dal¨¡ soubor

; ------ stanoven¡ d‚lky jm‚na polo‘ky -> CX

         mov       di,ds:[AktDTA]           ; buffer DTA
         push      di
         add       di,1eh                   ; jm‚no polo‘ky
         cld
         mov       al,0                     ; hledan˜ bajt
         mov       cx,-1
         repne     scasb                    ; nalezen¡ konce jm‚na
         inc       cx
         inc       cx
         neg       cx                       ; CX <- d‚lka jm‚na polo‘ky
         pop       di

; ------ zv˜¨en¡ ‡¡ta‡e d‚lky adres ©e

         mov       ax,cx                    ; AX <- d‚lka jm‚na polo‘ky
         add       ax,35                    ; p©i‡ten¡ z hlav¡
         add       word ptr ds:[SizDir],ax  ; ‡¡ta‡ d‚lky adres ©e
         adc       word ptr ds:[SizDir+2],0

; ------ test, zda to je adres ©

         test      byte ptr ds:[di+15h],10h ; je to adres © ?
         jz        Start3                   ; nen¡ to adres ©

; ------ adres © - zv˜¨en¡ ‡¡ta‡e d‚lky stromu

         cmp       byte ptr ds:[di+1eh],"." ; povolen˜ adres © ?
         je        Start4                   ; to nen¡ povolen˜ adres ©
         inc       word ptr ds:[CitAdr]     ; ‡¡ta‡ nalezen˜ch adres ©–
         mov       ax,cx                    ; AX <- d‚lka jm‚na
         add       ax,8                     ; p©i‡ten¡ z hlav¡
         add       word ptr ds:[SizTre],ax  ; ‡¡ta‡ velikosti stromu
         adc       word ptr ds:[SizTre+2],0
         jmp       short Start4             ; dal¨¡ polo‘ka

; ------ soubor - p©i‡ten¡ velikosti souboru

Start3:  inc       word ptr ds:[CitSoub]    ; ‡¡ta‡ nalezen˜ch soubor–
         mov       ax,ds:[di+1ah]           ; velikost souboru LOW
         mov       dx,ds:[di+1ah+2]         ; velikost souboru HIGH
         add       word ptr ds:[VelSoub],ax ; ‡¡ta‡ velikosti soubor–
         adc       word ptr ds:[VelSoub+2],dx
         add       ax,7ffh                  ; bude zaokrouhlen¡ nahoru na 2KB
         adc       dx,0
         and       ax,not 7ffh              ; zarovn n¡ na 2 KB
         add       word ptr ds:[SumSoub],ax ; ‡¡ta‡ velikost¡ soubor–
         adc       word ptr ds:[SumSoub+2],dx

; ------ p©¡prava pro hled n¡ dal¨¡ho souboru

Start4:  mov       ah,4fh                   ; funkce hled n¡ dal¨¡ polo‘ky
         jmp       short Start2

; ------ p©i‡ten¡ velikosti adres ©e

Start5:  mov       ax,word ptr ds:[SizDir]  ; d‚lka adres ©e
         mov       dx,word ptr ds:[SizDir+2]
         add       ax,7ffh                  ; bude zaokrouhlen¡ nahoru na 2KB
         adc       dx,0
         and       ax,not 7ffh              ; zarovn n¡ na 2 KB
         add       word ptr ds:[SumAdr],ax  ; ‡¡ta‡ velikost¡ adres ©–
         adc       word ptr ds:[SumAdr+2],dx

; ------ vyhled v n¡ adres ©–

         mov       dx,offset Vsechno        ; specifikace *.*
         mov       ah,4eh
         mov       cx,110111b               ; hledat v¨e kromˆ VOL
Start6:  int       21h                      ; vyhled n¡ souboru
         jc        Start7                   ; nen¡ dal¨¡ soubor
         mov       si,ds:[AktDTA]           ; adresa DTA
         test      byte ptr ds:[si+15h],10h ; je to adres © ?
         jz        Start8                   ; nen¡ to adres ©
         cmp       byte ptr ds:[si+1eh],"." ; je to platn˜ adres © ?
         je        Start8                   ; nen¡ to platn˜ adres ©

; ------ vno©en¡ do podadres ©e

         add       si,44                    ; zv˜¨en¡ ukazatele DTA
         mov       ds:[AktDTA],si           ; nov˜ ukazatel DTA
         cmp       si,offset EndDTA         ; bylo by p©ete‡en¡ ?
         jae       Start7                   ; bylo by p©ete‡en¡

; ------ nastaven¡ nov‚ho adres ©e

         lea       dx,[si+1eh-44]           ; jm‚no podadres ©e
         mov       ah,3bh
         int       21h                      ; nastaven¡ adres ©e
         jc        Start9                   ; p©i chybˆ n vrat
         jmp       Start1                   ; jinak obsluha v podadres ©i

; ------ n vrat k p©ede¨l‚mu adres ©i

Start7:  sub       word ptr ds:[AktDTA],44  ; p©i chybˆ n vrat podadres ©e
         cmp       word ptr ds:[AktDTA],offset BuffDTA
         jb        Start9                   ; nen¡ dal¨¡ podadres ©

         mov       dx,offset Zpet
         mov       ah,3bh
         int       21h
         jc        Start9

Start8:  mov       dx,ds:[AktDTA]           ; adresa aktivn¡ho DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

         mov       ah,4fh                   ; funkce hled n¡ dal¨¡ polo‘ky
         jmp       short Start6             ; hled n¡ dal¨¡ polo‘ky

; ------ konec operace

Start9:  mov       di,offset HlasTxt1-2     ; po‡et soubor–
         mov       ax,ds:[CitSoub]          ; po‡et soubor–
         xor       dx,dx
         mov       bx,"."                   ; oddˆlova‡ © d–
         call      DekNumD                  ; dek¢dov n¡ po‡tu soubor–

         mov       di,offset HlasTx12-2     ; po‡et adres ©–
         mov       ax,ds:[CitAdr]           ; po‡et adres ©–
         call      DekNumD                  ; dek¢dov n¡ po‡tu adres ©–

         mov       di,offset HlasTxt2-2
         mov       ax,word ptr ds:[VelSoub] ; velikost soubor–
         mov       dx,word ptr ds:[VelSoub+2]
         call      DekNumD                  ; dek¢dov n¡ velikosti soubor–

         mov       di,offset HlasTxt3-2     ; velikost soubor–
         mov       ax,word ptr ds:[SumSoub] ; kapacita soubor–
         mov       dx,word ptr ds:[SumSoub+2]
         call      DekNumD                  ; dek¢dov n¡ kapacity soubor–

         mov       di,offset HlasTxt4-2     ; velikost adres ©–
         mov       ax,word ptr ds:[SumAdr]  ; kapacita adres ©–
         mov       dx,word ptr ds:[SumAdr+2]
         call      DekNumD                  ; dek¢dov n¡ kapacity adres ©–

         mov       ax,word ptr ds:[SizTre]  ; d‚lka stromu
         mov       dx,word ptr ds:[SizTre+2]
         add       ax,7ffh                  ; bude zaokrouhlen¡ nahoru na 2KB
         adc       dx,0
         and       ax,not 7ffh              ; zarovn n¡ na 2 KB
         add       ax,18*2048               ; d‚lka z hlav¡
         adc       dx,0
         mov       di,offset HlasTxt5-2     ; velikost z hlav¡
         call      DekNumD                  ; dek¢dov n¡ z hlav¡

         add       ax,word ptr ds:[SumAdr]  ; p©i‡ten¡ adres ©–
         adc       dx,word ptr ds:[SumAdr+2]
         add       ax,word ptr ds:[SumSoub] ; p©i‡ten¡ soubor–
         adc       dx,word ptr ds:[SumSoub+2]
         mov       di,offset HlasTxt6-2     ; velikost celkem
         call      DekNumD                  ; dek¢dov n¡ velikosti celkem

         xchg      ax,cx
         xchg      dx,di                    ; DI:CX <- zabran‚ m¡sto
         xor       ax,ax
;         mov       dx,10384                 ; voln  kapacita podle GEAR, ale
;                                            ;   pýeteklo to o asi 400 KB
         mov       dx,10370                 ; DX:AX <- kapacita 648 MB
         sub       ax,cx                    ; zbyl‚ m¡sto
         sbb       dx,di
         push      di
         mov       di,offset HlasTxt7-2
         call      DekNumD                  ; zbyl‚ m¡sto
         pop       di

         xor       ax,ax
;         mov       dx,2512                  ; voln  kapacita podle GEAR, asi
;                                            ;   tak‚ pýeteŸe
         mov       dx,2510                  ; DX:AX <- kapacita 156 MB
         sub       ax,cx
         sbb       dx,di
         mov       di,offset HlasTxt8-2
         call      DekNumD                  ; zbyle misto na mini-CD

; ------ zobrazen¡ textu

         mov       ah,9
         mov       dx,offset HlasTxt
         int       21h

         int       20h

; *****************************************************************************
;                                 DekNumD
;                   Dek¢dov n¡ ‡¡sla od prav‚ho okraje
; -----------------------------------------------------------------------------
; VSTUP: DX:AX=‡¡slo k dek¢dov n¡ (muze byt i zaporne)
;        ES:DI=ukl dac¡ adresa (konec za ‡¡slem)
;        BH=atribut barev (0=atribut barev se neukl d )
;        BL=znak oddˆlova‡e © d– (0=oddˆlova‡ © d– se neukl d )
; VYSTUP: DI=ukazatel na prvni znak cisla
; *****************************************************************************

DekNumD  PROC      NEAR

         or        dx,dx                    ; je to zaporne cislo ?
         jns       DekNumD0                 ; neni to zaporne cislo
         not       ax
         not       dx
         add       ax,1
         adc       dx,0
         call      DekNumD0
         mov       byte ptr ds:[di-1],"-"
         ret

; ------ £schova registr–

DekNumD0:push      ax
         push      cx
         push      dx
         push      si
         push      bp

; ------ p©¡prava registr–

         mov       bp,10                    ; ‡¡seln  soustava
         mov       cx,4                     ; ‡¡ta‡ ‡¡slic © du
         or        bl,bl                    ; ukl d  se oddˆlova‡ © du ?
         jnz       DekNumD1                 ; oddˆlova‡ © du se ukl d 
         mov       ch,0ffh                  ; neplatn˜ ‡¡ta‡ © du

; ------ v˜po‡et jedn‚ ‡¡slice

DekNumD1:xchg      ax,si                    ; SI <- £schova ni‘¨¡ho slova ‡¡sla
         xchg      ax,dx                    ; AX <- vy¨¨¡ slovo ‡¡sla
         xor       dx,dx                    ; DX <- 0
         div       bp                       ; vydˆlen¡ vy¨¨¡ho slova ‡¡sla
         xchg      ax,si                    ; AX <- n vrat ni‘¨¡ho slova
         div       bp                       ; vydˆlen¡ ni‘¨¡ho slova ‡¡sla

; ------ ulo‘en¡ oddˆlova‡e © d–

         dec       cx                       ; ‡¡ta‡ ‡¡slic © du
         jnz       DekNumD3                 ; nen¡ oddˆlova‡ © du
         or        bh,bh                    ; ukl d  se atribut barev ?
         jz        DekNumD2                 ; atribut barev se neukl d 
         dec       di                       ; posun adresy
         mov       es:[di],bh               ; ulo‘en¡ atributu barvy
DekNumD2:dec       di                       ; posun adresy
         mov       es:[di],bl               ; ulo‘en¡ oddˆlova‡e tis¡c–
         mov       cl,3                     ; nov˜ ‡¡ta‡ © du

; ------ ulo‘en¡ nov‚ ‡¡slice

DekNumD3:or        bh,bh                    ; ukl d  se atribut barev ?
         jz        DekNumD4                 ; atribut barev se neukl d 
         dec       di                       ; posun adresy
         mov       es:[di],bh               ; ulo‘en¡ atributu barev
DekNumD4:dec       di                       ; posun adresy
         add       dl,"0"                   ; korekce na znak ASCII
         mov       es:[di],dl               ; ulo‘en¡ ‡¡slice

; ------ test, zda je je¨tˆ nˆjak‚ ‡¡slo

         mov       dx,si                    ; n vrat vy¨¨¡ho slova ‡¡sla
         or        si,ax                    ; je ‡¡slo ji‘ = 0 ?
         jnz       DekNumD1                 ; ‡¡slo je¨tˆ nen¡ = 0 - pokra‡ov n¡

; ------ n vrat registr–

         pop       bp
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

DekNumD  ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------

SizTre   dd        50                       ; ‡¡ta‡ velikosti stromu

SizDir   dd        0                        ; ‡¡ta‡ velikosti adres ©e

CitSoub  dw        0                        ; ‡¡ta‡ soubor–
CitAdr   dw        0                        ; ‡¡ta‡ adres ©–
VelSoub  dd        0                        ; st©ada‡ velikosti soubor–
SumSoub  dd        0                        ; ‡¡ta‡ kapacity soubor–
SumAdr   dd        0                        ; ‡¡ta‡ kapacity adres ©–

UvTxt    db        13,10,'CDSTAT v1.12 - statistika souboru pro CD; (c) Miroslav Nemecek',13,10
         db        'Prohledavam aktualni adresar s podadresari...',13,10,'$'

HlasTxt  db        13,10
         db        '   Pocet souboru:             0',13,10
HlasTxt1 db        '  Pocet adresaru:             0',13,10
HlasTx12 db        'Velikost souboru:             0',13,10
HlasTxt2 db        ' Soubory zaberou:             0',13,10
HlasTxt3 db        'Adresare zaberou:             0',13,10
HlasTxt4 db        '  Zahlavi zabere:             0',13,10
HlasTxt5 db        ' Celkem obsazeno:             0',13,10
HlasTxt6 db        ' Zbyva (pro 74''):             0',13,10
HlasTxt7 db        '       (pro 18''):             0',13,10
HlasTxt8 db        '$'

Vsechno  db        '*.*',0
Zpet     db        '..',0

AktDTA   dw        BuffDTA                  ; ukazatel aktu ln¡ DTA

BuffDTA  db        44*35 dup(0)             ; buffer DTA
EndDTA   label     byte                     ; konec DTA

Code     ENDS
         END       Start

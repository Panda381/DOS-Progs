
KLIC1    EQU       8B35h                    ; kl¡‡ 1 (AX)
KLIC2    EQU       0E63Bh                   ; kl¡‡ 2 (BX)
KLIC3    EQU       2D64h                    ; kl¡‡ 3 (CX)
KLIC4    EQU       6AA8h                    ; kl¡‡ 4 (DX)
KLIC5    EQU       9E61h                    ; kl¡‡ 5 (BX v˜stup)

bit0     EQU       1
bit1     EQU       2
bit2     EQU       4
bit3     EQU       8
bit4     EQU       10h
bit5     EQU       20h
bit6     EQU       40h
bit7     EQU       80h

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

KORIG    EQU       5ch-103h                 ; korekce adres

Start:   jmp       Init                     ; start a inicializace programu

RezidBeg label     byte                     ; za‡ tek rezidentn¡ ‡ sti

Old08    dd        0                        ; p–vodn¡ adresa INT 08h
Old09    dd        0                        ; p–vodn¡ adresa INT 09h
Old16    dd        0                        ; p–vodn¡ adresa INT 16h
Old33    dd        0                        ; p–vodn¡ adresa INT 33h (je-li my¨)

Param    db        bit0                     ; parametry
                                            ;   bit 0: 1=funkce zapnuta
                                            ;   bit 1: 1=znak vygenerov n
                                            ;   bit 2: 1=po‘adavek nulov n¡

                                            ;   bit 5: 1=je ovlada‡ my¨i
                                            ;   bit 6: 1=po‘adavek odinstalov n¡
                                            ;   bit 7: 1=prvn¡ instalace progr.

Timer    dw        0                        ; ‡¡ta‡ pro vygenerov n¡ znaku
Timer0   dw        5*1092                   ; nastaven  doba pro vygenerov n¡

Timer2   db        5*18                     ; ‡¡ta‡ pro test portem
OldKey   db        0                        ; uschovan˜ stav portu kl vesnice
                                            ;   (0=nen¡)

KodKey   dw        2d00h                    ; vygenerovan˜ znak

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

         or        byte ptr cs:[Param+KORIG],bit2 ; po‘adavek nulov n¡
         jmp       dword ptr cs:[Old09+KORIG]    ; pokra‡ov n¡ v obsluze

INT09    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 08h
; -----------------------------------------------------------------------------

INT08    PROC      FAR

; ------ p–vodn¡ obsluha INT 08h

         pushf
         call      dword ptr cs:[Old08+KORIG] ; p–vodn¡ obsluha INT 08h

; ------ test, zda je funkce aktivn¡

         test      byte ptr cs:[Param+KORIG],bit0 ; je funkce aktivn¡ ?
         jnz       INT080                   ; funkce je aktivn¡
         iret                               ; funkce nen¡ aktivn¡

; ------ £schova registr–

INT080:  push      ax
         push      ds

; ------ p©¡prava registr–

         push      cs
         pop       ds                       ; DS <- CS

; ------ test, zda je po‘adov no nulov n¡ ‡¡ta‡e (od my¨i nebo INT 09h)

         test      byte ptr ds:[Param+KORIG],bit2 ; po‘adov no nulov n¡ ?
         jnz       INT085                   ; je po‘adov no nulov n¡

; ------ test, zda se bude dˆlat test pomoc¡ portu

         test      byte ptr ds:[Param+KORIG],bit1 ; byl znak vygenerov n ?
         jnz       INT081                   ; znak vygenerov n - test v‘dy
         dec       byte ptr ds:[Timer2+KORIG] ; ‡¡t n¡ doby pro test
         jnz       INT082                   ; neprov d¡ se test

; ------ test, zda je zmˆna portu kl vesnice

INT081:  in        al,[60h]                 ; ‡ten¡ portu kl vesnice
         xchg      al,ds:[OldKey+KORIG]     ; £schova nov‚ kl vesy
         cmp       al,0                     ; je platn  kl vesa ?
         je        INT082                   ; zmˆna se neporovn v 
         cmp       al,ds:[OldKey+KORIG]     ; je zmˆna portu kl vesnice ?
         jne       INT086                   ; je zmˆna - nulov n¡ ‡¡ta‡e

; ------ je klid - ‡¡t n¡ vygenerov n¡ znaku

INT082:  test      byte ptr ds:[Param+KORIG],bit1 ; byl znak vygenerov n ?
         jnz       INT088                   ; znak ji‘ byl vygenerov n
         dec       word ptr ds:[Timer+KORIG]; ‡¡t n¡ doby pro generov n¡
         jnz       INT088                   ; nen¡ je¨tˆ generov n¡
         or        byte ptr ds:[Param+KORIG],bit1 ; p©¡znak vygenerov n¡ znaku
         in        al,[60h]                 ; stav portu kl vesnice
         mov       ds:[OldKey+KORIG],al     ; £schova portu kl vesnice

; ------ vygenerov n¡ znaku

         push      bx
         mov       ax,ds:[KodKey+KORIG]     ; znak k vygenerov n¡
         mov       bx,40h
         mov       ds,bx                    ; DS <- segment dat BIOS
         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu
         mov       ds:[bx],ax               ; ulo‘en¡ znaku
         inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         cmp       bx,3eh                   ; je p©ete‡en¡ konce ?
         jb        INT083                   ; nen¡ je¨tˆ p©ete‡en¡ konce
         mov       bx,1eh                   ; p©esun na za‡ tek
INT083:  cmp       bx,ds:[1ah]              ; bylo by p©ete‡en¡ bufferu ?
         je        INT084                   ; bylo by p©ete‡en¡ bufferu
         mov       ds:[1ch],bx              ; nov  ukl dac¡ adresa do bufferu
INT084:  pop       bx
         jmp       short INT088

; ------ nulov n¡ ‡¡ta‡e

INT085:  mov       byte ptr ds:[OldKey+KORIG],0  ; zru¨en¡ kl vesy v bufferu
INT086:  mov       ax,ds:[Timer0+KORIG]     ; inicializa‡n¡ nastaven¡ ‡¡ta‡e
         mov       ds:[Timer+KORIG],ax      ; nov‚ nastaven¡ ‡¡ta‡e
         and       byte ptr ds:[Param+KORIG],not bit1+bit2 ; zru¨en¡ p©¡znak–
         mov       byte ptr ds:[Timer2+KORIG],5*18 ; ‡¡ta‡ pro test portem

; ------ n vrat registr–

INT088:  pop       ds
         pop       ax
         iret

INT08    ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 16h - test instalace
; -----------------------------------------------------------------------------

INT16    PROC      FAR

; ------ test, zda je program rezidentn¡

         cmp       ax,KLIC1
         jne       INT161
         cmp       bx,KLIC2
         jne       INT161
         cmp       cx,KLIC3
         jne       INT161
         cmp       dx,KLIC4
         jne       INT161
         push      cs
         pop       es                       ; ES <- segment programu
         mov       bx,KLIC5
         sti
         ret       2

; ------ jinak pokra‡ov n¡ p–vodn¡ obsluhou

INT161:  jmp       dword ptr cs:[Old16+KORIG] ; pokra‡ov n¡ v obsluze INT 16h

INT16    ENDP

RezidEn0 label     byte                     ; konec rezidentn¡ ‡ sti bez my¨i

; -----------------------------------------------------------------------------
;        obsluha INT 33h
; -----------------------------------------------------------------------------

MPozice  dw        0                        ; uschovan  pozice my¨i
MRadek   dw        0                        ; uschovan˜ © dek my¨i

INT33    PROC      FAR

         cmp       ax,3
         je        INT332
         cmp       ax,0bh
         je        INT335
INT331:  jmp       dword ptr cs:[Old33+KORIG] ; pokra‡ov n¡ v obsluze

INT332:  pushf
         call      dword ptr cs:[Old33+KORIG]

         cmp       cx,cs:[MPozice+KORIG]
         jne       INT333
         cmp       dx,cs:[MRadek+KORIG]
         je        INT334

INT333:  or        byte ptr cs:[Param+KORIG],bit2 ; po‘adavek nulov n¡
         mov       cs:[MPozice+KORIG],cx    ; £schova pozice
         mov       cs:[MRadek+KORIG],dx     ; £schova © dku
INT334:  iret

INT335:  pushf
         call      dword ptr cs:[Old33+KORIG]

         or        dx,dx
         jnz       INT336
         jcxz      INT337

INT336:  or        byte ptr cs:[Param+KORIG],bit2 ; po‘adavek nulov n¡
INT337:  iret

INT33    ENDP

RezidEnd label     byte                     ; konec rezidentn¡ ‡ sti, je-li my¨

; *****************************************************************************
;
;                               Start programu
;
; *****************************************************************************
;þ
; ------ zobrazen¡ £vodn¡ho textu

Init:    mov       dx,offset UvTxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

; ------ £schova p©¡kazov‚ho © dku

         mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       di,offset Command        ; buffer p©¡kazov‚ho © dku
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku
         mov       ch,0
         cld
         rep       movsb                    ; £schova p©¡kazov‚ho © dku
         mov       ds:[di],ch               ; ozna‡en¡ konce p©¡kazov‚ho © dku

; ------ posun programu dol–

         mov       si,offset RezidBeg       ; za‡ tek rezidentn¡ ‡ sti
         mov       di,offset RezidBeg+KORIG ; nov  adresa
         mov       cx,(offset(RezidEnd-RezidBeg)+1)/2 ; d‚lka (ve slovech)
         rep       movsw                    ; posun programu dol–

; ------ £schova adresy obsluhy INT 33h

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         mov       word ptr ds:[Old33+KORIG],bx ; £schova adresy INT 33h
         mov       word ptr ds:[Old33+2+KORIG],es

; ------ test, zda je program nainstalov n

         push      cs
         pop       es
         mov       ax,KLIC1
         mov       bx,KLIC2
         mov       cx,KLIC3
         mov       dx,KLIC4
         int       16h                      ; test instalace programu
         cmp       bx,KLIC5                 ; je program nainstalov n ?
         je        Init2                    ; je nainstalov n, v ES je adresa
         or        byte ptr ds:[Param+KORIG],bit7; p©¡znak prvn¡ instalace programu
         push      cs
         pop       es                       ; ES <- segment tohoto programu

; ------ test, zda je adresa INT 33h platn 

         cmp       word ptr ds:[Old33+2+KORIG],70h; minim ln¡ adresa INT 33h
         jb        Init2                    ; adresa INT 33h neplatn , nen¡ my¨
         cmp       word ptr ds:[Old33+KORIG],-1 ; neplatn˜ offset -1 ?
         je        Init2                    ; adresa INT 33h neplatn , nen¡ my¨

; ------ prvn¡ instalace - test, zda je nainstalov n ovlada‡ my¨i

         xor       ax,ax
         push      es
         int       33h                      ; test instalace ovlada‡e my¨i
         pop       es
         inc       ax                       ; je ovlada‡ my¨i nainstalov n ?
         jnz       Init2                    ; nen¡ nainstalov n
         or        byte ptr ds:[Param+KORIG],bit5 ; p©¡znak ovlada‡e my¨i

; ------ rozbor p©¡kazov‚ho © dku (ES=segment rezidentn¡ho programu)

Init2:   or        byte ptr es:[Param+KORIG],bit2 ; po‘adavek nulov n¡
         call      Rozbor                   ; rozbor

; ------ korekce £daje doby 0

         pushf
         cmp       word ptr es:[Timer0+KORIG],18
         jae       Init222
         mov       word ptr es:[Timer0+KORIG],18
         mov       word ptr es:[Timer+KORIG],18
Init222: popf
         jnc       Init3                    ; zad n¡ parametr– OK
         mov       dx,offset HelpTxt        ; text n povˆdy

; ------ chyba - zobrazen¡ textu chyby

Chyba:   call      DispTxt                  ; zobrazen¡ chybov‚ho hl ¨en¡
         int       20h

; ------ test, zda je po‘adov no odinstalov n¡

Init3:   test      byte ptr ds:[Param+KORIG],bit6 ; po‘adov no odinstalov n¡ ?
         jz        Init4                    ; nen¡ po‘adov no odinstalov n¡

; ------ test, zda je program nainstalov n

         mov       dx,offset NeniTxt        ; text - nen¡ nainstalov n
         test      byte ptr ds:[Param+KORIG],bit7 ; je nainstalov n ?
         jnz       Chyba                    ; chyba - nen¡ nainstalov n

; ------ test, zda lze odinstalovat

         call      TestDIns                 ; test, zda lze odinstalovat
         mov       dx,offset NelzeTxt       ; text - nelze odinstalovat
         jc        Chyba                    ; chyba - nelze odinstalovat

; ------ odinstalov n¡ programu z pamˆti

         call      DeInst                   ; odinstalov n¡ programu z pamˆti
         mov       dx,offset DInstTxt       ; text - byl odinstalov n
         jmp       Chyba                    ; hl ¨en¡ o odinstalov n¡

; ------ test, zda je program ji‘ nainstalov n

Init4:   test      byte ptr ds:[Param+KORIG],bit7 ; je to prvn¡ instalace ?
         jnz       Init5                    ; je to prvn¡ instalace

; ------ zobrazen¡ hl ¨en¡ o stavu a konec

         call      DispStav                 ; zobrazen¡ hl ¨en¡ o stavu
         int       20h                      ; konec programu

; ------ instalace obsluhy INT 23h (aby nebyla instalace p©eru¨ena)

Init5:   mov       dx,offset Int23          ; pracovn¡ obsluha INT 23h
         mov       ax,2523h
         int       21h                      ; instalace INT 23h

; ------ £schova adresy INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr ds:[Old08+KORIG],bx ; £schova adresy INT 08h
         mov       word ptr ds:[Old08+2+KORIG],es

; ------ £schova adresy INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr ds:[Old09+KORIG],bx ; £schova adresy INT 09h
         mov       word ptr ds:[Old09+2+KORIG],es

; ------ £schova adresy INT 16h

         mov       ax,3516h
         int       21h                      ; poskytnut¡ adresy INT 16h
         mov       word ptr ds:[Old16+KORIG],bx ; £schova adresy INT 16h
         mov       word ptr ds:[Old16+2+KORIG],es

; ------ instalace obsluhy INT 08h

         mov       dx,offset Int08+KORIG
         mov       ax,2508h
         int       21h                      ; instalace obsluhy INT 08h

; ------ instalace obsluhy INT 09h

         mov       dx,offset Int09+KORIG
         mov       ax,2509h
         int       21h                      ; instalace obsluhy INT 09h

; ------ instalace obsluhy INT 16h

         mov       dx,offset Int16+KORIG
         mov       ax,2516h
         int       21h                      ; instalace obsluhy INT 16h

; ------ instalace obsluhy INT 33h

         test      byte ptr ds:[Param+KORIG],bit5 ; je ovlada‡ my¨i ?
         jz        Init6                    ; nen¡ ovlada‡ my¨i
         mov       dx,offset Int33+KORIG
         mov       ax,2533h
         int       21h                      ; instalace obsluhy INT 33h

; ------ uvolnˆn¡ segmentu prost©ed¡

Init6:   mov       es,ds:[2ch]              ; segment prost©ed¡
         mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu prost©ed¡

; ------ hl ¨en¡ o nainstalov n¡

         mov       dx,offset InstTxt
         call      DispTxt

; ------ hl ¨en¡ o stavu programu

         push      cs
         pop       es
         call      DispStav                 ; zobrazen¡ stavu programu

; ------ instalace programu do pamˆti

         mov       dx,offset RezidEnd+KORIG ; konec, je-li my¨
         test      byte ptr ds:[Param+KORIG],bit5 ; je nainstalov na my¨ ?
         jnz       Init8                    ; je nainstalov na my¨
         mov       dx,offset RezidEn0+KORIG ; konec, nen¡-li my¨
Init8:   int       27h                      ; instalace do pamˆti

; -----------------------------------------------------------------------------
;        p©echodn  obsluha INT 23h
; -----------------------------------------------------------------------------

Int23:   iret

; -----------------------------------------------------------------------------
;        zobrazen¡ hl ¨en¡ o stavu programu (ES=rezidentn¡ program)
; -----------------------------------------------------------------------------

DispStav PROC      NEAR

; ------ zobrazen¡ £vodu hl ¨en¡

         mov       dx,offset AktTxt
         call      DispTxt                  ; zobrazen¡ £vodn¡ ‡ sti hl ¨en¡

; ------ hl ¨en¡, zda je aktivn¡

         mov       dx,offset Akt1Txt        ; text - nen¡ aktivn¡
         test      byte ptr es:[Param+KORIG],bit0 ; je program aktivn¡ ?
         jz        DispStv1                 ; program nen¡ aktivn¡
         mov       dx,offset Akt2txt        ; text - je aktivn¡
DispStv1:call      DispTxt

; ------ zobrazen¡ po‡tu minut

         mov       ax,es:[Timer0+KORIG]     ; nastaven  doba
         xor       dx,dx
         mov       bx,1092                  ; po‡et impuls–
         div       bx                       ; v˜po‡et po‡tu minut
         call      DispNum                  ; zobrazen¡ po‡tu minut
         xchg      ax,dx                    ; AX <- po‡et impuls–
         mov       dx,offset Akt3Txt
         call      DispTxt                  ; text "minut"

; ------ zobrazen¡ po‡tu sekund

         xor       dx,dx                    ; DX <- 0
         mov       bx,18                    ; po‡et impuls– na sekundu
         div       bx                       ; v˜po‡et po‡tu sekund
         or        ax,ax                    ; jsou sekundy ?
         jz        DispStv2                 ; nejsou sekundy
         call      DispNum                  ; zobrazen¡ po‡tu sekund
         mov       dx,offset Akt4Txt        ; text "sekund"
         call      DispTxt

; ------ zobrazen¡ k¢du kl vesy

DispStv2:mov       dx,offset Akt5Txt        ; text "klavesa"
         call      DispTxt
         mov       ax,es:[KodKey+KORIG]
         call      DispHex                  ; zobrazen¡ k¢du kl vesy
         mov       dx,offset Akt6txt
         call      DispTxt
         ret

DispStav ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova AX v HEX tvaru
; -----------------------------------------------------------------------------

DispHex  PROC      NEAR

         xchg      al,ah
         call      DispHex4
         xchg      al,ah

DispHex4:push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHex6
         pop       ax

DispHex6:push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHex8
         add       al,7
DispHex8:add       al,"0"
         call      DispChr
         pop       ax
         ret

DispHex  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡¡sla AX
; -----------------------------------------------------------------------------

DispNum  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ dek¢dov n¡ jedn‚ ‡¡slice

         xor       cx,cx                    ; ‡¡ta‡ znak–
         mov       bx,10                    ; dˆlitel
DispNum1:xor       dx,dx                    ; DX <- 0
         div       bx                       ; v˜po‡et jedn‚ ‡¡slice
         add       dl,"0"                   ; korekce na znak ASCII
         push      dx                       ; £schova ‡¡slice do z sobn¡ku
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         or        ax,ax                    ; je ji‘ 0 ?
         jnz       DispNum1                 ; nen¡ je¨tˆ 0

; ------ zobrazen¡ ‡¡sla

DispNum2:pop       ax
         call      DispChr                  ; zobrazen¡ znaku AL (‡¡slice)
         loop      DispNum2                 ; dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         xchg      ax,dx
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu DS:DX
; -----------------------------------------------------------------------------

DispTxt  PROC      NEAR

         push      ax
         mov       ah,9
         int       21h
         pop       ax
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        test, zda lze program odinstalovat (ES=rezidentn¡ ‡ st)
; -----------------------------------------------------------------------------

TestDIns PROC      NEAR

; ------ £schova registr–

         push      es
         mov       cx,es

; ------ test, zda je nainstalov na obsluha INT 33h

         test      byte ptr es:[Param+KORIG],bit5 ; je ovlada‡ my¨i ?
         jz        TestDIn2                 ; nen¡ ovlada‡ my¨i

; ------ test vektoru INT 33h

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         mov       ax,es
         cmp       ax,cx
         jne       TestDIn8

; ------ test vektoru INT 16h

TestDIn2:mov       ax,3516h
         int       21h                      ; poskytnut¡ adresy INT 16h
         mov       ax,es
         cmp       ax,cx
         jne       TestDIn8

; ------ test vektoru INT 09h

         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       ax,es
         cmp       ax,cx
         jne       TestDIn8

; ------ test vektoru INT 08h

         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       ax,es
         cmp       ax,cx
         je        TestDIn9                 ; lze odinstalovat OK

; ------ n vrat registr–

TestDIn8:stc                                ; p©¡znak chyby - nelze odinstalovat
TestDIn9:pop       es
         ret

TestDIns ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ programu z pamˆti (ES=rezidentn¡ ‡ st)
; -----------------------------------------------------------------------------

DeInst   PROC      NEAR

; ------ £schova registr–

         cli
         push      ds

; ------ n vrat INT 08h

         lds       dx,es:[Old08+KORIG]
         mov       ax,2508h
         int       21h                      ; n vrat adresy INT 08h

; ------ n vrat INT 09h

         lds       dx,es:[Old09+KORIG]
         mov       ax,2509h
         int       21h                      ; n vrat adresy INT 09h

; ------ n vrat INT 16h

         lds       dx,es:[Old16+KORIG]
         mov       ax,2516h
         int       21h                      ; n vrat adresy INT 16h

; ------ n vrat INT 33h

         test      byte ptr es:[Param+KORIG],bit5 ; je ovlada‡ my¨i ?
         jz        DeInst2                  ; nen¡ ovlada‡ my¨i
         lds       dx,es:[Old33+KORIG]
         mov       ax,2533h
         int       21h                      ; n vrat adresy INT 33h

; ------ uvolnˆn¡ segmentu programu

DeInst2: mov       ah,49h
         int       21h                      ; uvolnˆn¡ segmentu programu

; ------ n vrat registr–

         pop       ds
         sti
         ret

DeInst   ENDP

; -----------------------------------------------------------------------------
;        Rozbor p©¡kazov‚ho © dku (ES=rezidentn¡ segment programu)
; -----------------------------------------------------------------------------

Rozbor   PROC      NEAR

         mov       si,offset Command        ; buffer p©¡kazov‚ho © dku

; ------ na‡ten¡ znaku parametru

Rozbor1: call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbChr                  ; na‡ten¡ znaku
         jnc       Rozbor2                  ; je platn˜ znak
         clc                                ; p©¡znak operace OK
         ret

; ------ ignorov n¡ znaku "/"

Rozbor2: cmp       al,"/"
         je        Rozbor1                  ; znak "/" se ignoruje

; ------ parametr "N" - program neaktivn¡

         cmp       al,"N"
         jne       Rozbor3
         and       byte ptr es:[Param+KORIG],not bit0+bit1+bit2 ; vypnut¡ funkce
         jmp       short Rozbor1

; ------ parametr "A" - program aktivn¡

Rozbor3: cmp       al,"A"
         jne       Rozbor4
         cli
         or        byte ptr es:[Param+KORIG],bit0 ; zapnut¡ funkce
         and       byte ptr es:[Param+KORIG],not bit1+bit2 ; nebyl znak
         mov       ax,es:[Timer0+KORIG]
         mov       es:[Timer+KORIG],ax      ; inicializace ‡¡ta‡e
         mov       byte ptr es:[OldKey+KORIG],0  ; zru¨en¡ kl vesy v bufferu
         mov       byte ptr es:[Timer2+KORIG],5*18 ; ‡¡ta‡ pro test portem
         sti
         jmp       short Rozbor1

; ------ parametr "Hxxxx" - k¢d kl vesy

Rozbor4: cmp       al,"H"
         jne       Rozbor5
         call      RozbHex                  ; na‡ten¡ ‡¡sla HEX
         mov       es:[KodKey+KORIG],ax     ; ulo‘en¡ k¢du kl vesy
         jmp       short Rozbor1

; ------ parametr "!" - odinstalov n¡ programu z pamˆti

Rozbor5: cmp       al,"!"
         jne       Rozbor6
         or        byte ptr ds:[Param+KORIG],bit6 ; po‘adavek odinstalov n¡
Rozbor11:jmp       short Rozbor1

; ------ ‡¡seln˜ parametr

Rozbor6: dec       si                       ; n vrat znaku
         call      RozbNum                  ; vstup ‡¡sla
         jc        Rozbor9                  ; nen¡ platn‚ ‡¡slo

; ------ omezen¡ maxim ln¡ po‘adovan‚ doby na 60 minut

         cmp       ax,60                    ; maxim ln¡ doba
         jb        Rozbor62                 ; ‡¡slo je OK
         mov       ax,60                    ; omezen¡ ‡¡sla

; ------ v˜po‡et nov‚ konstanty

Rozbor62:mov       bx,1092                  ; n sobitel
         mul       bx                       ; v˜po‡et ‡¡sla

; ------ nastaven¡ konstanty ‡¡ta‡e

Rozbor64:mov       es:[Timer0+KORIG],ax     ; nov  konstanta pro ztm¡v n¡
         mov       es:[Timer+KORIG],ax      ; nov  konstanta pro aktivn¡ ‡¡ta‡

; ------ test, zda jsou zad ny sekundy

         call      RozbSpc
         jc        Rozbor11
         cmp       al,":"
         jne       Rozbor11
         call      RozbChr
         call      RozbNum                  ; vstup zad n¡ sekund
         jc        Rozbor9

; ------ omezen¡ po‡tu sekund

         cmp       ax,59
         jb        Rozbor65
         mov       ax,59
Rozbor65:mov       bx,18
         mul       bx
         mov       bx,es:[Timer0+KORIG]
         add       ax,bx
         jc        Rozbor66
         cmp       ax,1092*60
         jb        Rozbor67
Rozbor66:mov       ax,1092*60
Rozbor67:mov       es:[Timer0+KORIG],ax     ; nov  konstanta pro ztm¡v n¡
         mov       es:[Timer+KORIG],ax      ; nov  konstanta pro aktivn¡ ‡¡ta‡
         jmp       short Rozbor11

Rozbor9: ret

Rozbor   ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ ‡¡seln‚ho parametru -> AX
; -----------------------------------------------------------------------------

RozbNum  PROC      NEAR

; ------ £schova registr–

         push      dx

; ------ test, zda je zad no ‡¡slo

         xor       dx,dx                    ; st©ada‡ ‡¡sla
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
         call      RozbNm                   ; prvn¡ ‡¡slice
         jc        RozbNum9                 ; nen¡ zad no ‡¡slo

; ------ vyn soben¡ st©ada‡e 10x

RozbNum2:push      ax
         mov       ax,10
         mul       dx                       ; vyn soben¡ st©ada‡e
         or        dx,dx                    ; je p©ete‡en¡ ‡¡sla ?
         jz        RozbNum3                 ; nen¡ p©ete‡en¡ ‡¡sla
         mov       ax,-1                    ; omezen¡ ‡¡sla
RozbNum3:pop       dx                       ; na‡ten‚ ‡¡slo

; ------ p©i‡ten¡ na‡ten‚ ‡¡slice

         mov       dh,0
         add       dx,ax                    ; nov  hodnota st©ada‡e
         jnc       RozbNum4                 ; nen¡ p©ete‡en¡ ‡¡sla
         mov       dx,-1                    ; omezen¡ ‡¡sla

; ------ dal¨¡ ‡¡slice

RozbNum4:call      RozbNm                   ; na‡ten¡ ‡¡slice
         jnc       RozbNum2                 ; je dal¨¡ ‡¡slice
         xchg      ax,dx                    ; AX <- na‡ten‚ ‡¡slo
         clc                                ; p©¡znak operace OK

; ------ n vrat registr–

RozbNum9:pop       dx
         ret

RozbNum  ENDP

; -----------------------------------------------------------------------------
;        rozbor jedn‚ ‡¡slice
; -----------------------------------------------------------------------------

RozbNm   PROC      NEAR

         call      RozbChr                  ; na‡ten¡ znaku
         jc        RozbNm9                  ; nen¡ dal¨¡ znak
         cmp       al,"0"
         jb        RozbNm8
         cmp       al,"9"
         ja        RozbNm8
         sub       al,"0"
         ret

RozbNm8: dec       si
         stc                                ; p©¡znak neplatn‚ho znaku
RozbNm9: ret

RozbNm   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla HEX -> AX
; -----------------------------------------------------------------------------

RozbHex  PROC      NEAR

         push      dx
         xor       dx,dx                    ; DX <- 0 st©ada‡
         call      RozbSpc                  ; vypu¨tˆn¡ mezer
RozbHex1:call      RozbChr                  ; na‡ten¡ dal¨¡ho znaku
         jc        RozbHex4                 ; nen¡ dal¨¡ znak
         sub       al,"0"
         jb        RozbHex3                 ; nen¡ znak HEX
         cmp       al,9
         jbe       RozbHex2                 ; je platn˜ znak
         sub       al,7
         cmp       al,9
         jbe       RozbHex3                 ; neplatn˜ znak
         cmp       al,15
         ja        RozbHex3                 ; neplatn˜ znak
RozbHex2:shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1                     ; posun st©ada‡e
         or        dl,al                    ; p©id n¡ nov‚ho ‡¡sla
         jmp       short RozbHex1           ; dal¨¡ znak

RozbHex3:dec       si                       ; n vrat znaku
RozbHex4:xchg      ax,dx                    ; AX <- na‡ten‚ ‡¡slo
         pop       dx
         ret

RozbHex  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbSpc  PROC      NEAR

         call      RozbChr
         jc        RozbSpc9
         je        RozbSpc
         dec       si

RozbSpc9:ret

RozbSpc  ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku
; -----------------------------------------------------------------------------

RozbChr  PROC      NEAR

         cld
         lodsb

; ------ n hrada tabel toru mezerou

         cmp       al,9
         jne       RozbChr2
         mov       al," "

; ------ konverze na velk‚ p¡smeno

RozbChr2:cmp       al,"a"
         jb        RozbChr3
         cmp       al,"z"
         ja        RozbChr3
         sub       al,32

; ------ test, zda je konec textu

RozbChr3:cmp       al," "
         jae       RozbChr4
         dec       si

RozbChr4:ret

RozbChr  ENDP

; *****************************************************************************
;
;                                   Data
;
; *****************************************************************************

UvTxt    db        'DARKKEY V1.0 - generator klidove klavesy; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:    N ........ program je neaktivni',13,10
         db        '            A ........ program je aktivni (implicitne)',13,10
         db        '            cislo .... doba pro vygenerovani 1 az 60 minut (implicitne 5)',13,10
         db        '            mm:ss .... doba pro vygenerovani ve tvaru minuty:sekundy',13,10
         db        '            Hxxxx .... generovana klavesa v HEX kodu (impl. H2D00 = ALT-X)',13,10
         db        '            ! ........ odinstalovani programu z pameti',13,10
         db        '$'

InstTxt  db        'Program byl nainstalovan do pameti.',13,10,'$'
AktTxt   db        'Program je $'
Akt1Txt  db        'NE'
Akt2Txt  db        'AKTIVNI, doba $'
Akt3Txt  db        ' minut, $'
Akt4Txt  db        ' sekund, $'
Akt5Txt  db        'klavesa $'
Akt6Txt  db        13,10,'$'

DInstTxt db        'Program byl odinstalovan z pameti.',13,10,'$'

NeniTxt  db        'Program nelze odinstalovat, nebyl dosud nainstalovan.',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat, je nutno nejdrive',13,10
         db        'odinstalovat programy nainstalovane pozdeji.',13,10,'$'

Command  db        128 dup(?)               ; buffer p©¡kazov‚ho © dku

Code     ENDS
         END       Start

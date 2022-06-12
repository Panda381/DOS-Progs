
KLIC1    EQU       8A36h                    ; kl¡‡ 1 (AX)
KLIC2    EQU       0E63Bh                   ; kl¡‡ 2 (BX)
KLIC3    EQU       2E64h                    ; kl¡‡ 3 (CX)
KLIC4    EQU       6AA9h                    ; kl¡‡ 4 (DX)
KLIC5    EQU       9E62h                    ; kl¡‡ 5 (BX v˜stup)

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
                                            ;   bit 1: 1=displej ztmaven
                                            ;   bit 2: 1=po‘adov no rozsv¡cen¡

                                            ;   bit 5: 1=je ovlada‡ my¨i
                                            ;   bit 6: 1=po‘adavek odinstalov n¡
                                            ;   bit 7: 1=prvn¡ instalace progr.

Timer    dw        0                        ; ‡¡ta‡ pro ztmaven¡ displeje
Timer0   dw        5*1092                   ; nastaven  doba pro ztmavov n¡

Timer2   db        5*18                     ; ‡¡ta‡ pro test portem
OldKey   db        0                        ; uschovan˜ stav portu kl vesnice
                                            ;   (0=nen¡)

; -----------------------------------------------------------------------------
;        obsluha INT 09h
; -----------------------------------------------------------------------------

INT09    PROC      FAR

; ------ test, zda je displej ztmaven

         or        byte ptr cs:[Param+KORIG],bit2; po‘adavek rozsv¡cen¡
         test      byte ptr cs:[Param+KORIG],bit1; je displej ztmaven ?
         jnz       INT091                   ; displej je ztmaven
INT090:  jmp       dword ptr cs:[Old09+KORIG]    ; pokra‡ov n¡ v obsluze

; ------ ignorov n¡ kl vesy p©i rozsv¡cen¡ displeje

INT091:  pushf
         call      dword ptr cs:[Old09+KORIG]

         push      bx
         push      ds
         xor       bx,bx
         mov       ds,bx
         mov       bx,ds:[41ah]             ; ‡tec¡ adresa z bufferu
         mov       ds:[41ch],bx             ; zru¨en¡ obsahu bufferu
         pop       ds
         pop       bx
INT099:  iret

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
         jz        INT099                   ; funkce nen¡ aktivn¡

; ------ £schova registr–

         push      ax
         push      dx
         push      ds

; ------ p©¡prava adresy stavov‚ho portu

         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje
         mov       ah,ds:[465h]             ; nastaven¡ portu 3d8h
         add       dl,4                     ; adresa ©¡dic¡ho portu displeje
         push      cs
         pop       ds                       ; DS <- CS

; ------ test, zda je po‘adov no rozsv¡cen¡ displeje (od my¨i nebo INT 09h)

         test      byte ptr ds:[Param+KORIG],bit2 ; po‘adov no rozsv¡cen¡ ?
         jnz       INT085                   ; je po‘adov no rozsv¡cen¡

; ------ test, zda se bude dˆlat test pomoc¡ portu

         test      byte ptr ds:[Param+KORIG],bit1 ; je displej ztmaven ?
         jnz       INT081                   ; displej je ztmaven - test v‘dy
         dec       byte ptr ds:[Timer2+KORIG] ; ‡¡t n¡ doby pro test
         jnz       INT082                   ; neprov d¡ se test

; ------ test, zda je zmˆna portu kl vesnice

INT081:  in        al,[60h]                 ; ‡ten¡ portu kl vesnice
         xchg      al,ds:[OldKey+KORIG]     ; £schova nov‚ kl vesy
         cmp       al,0                     ; je platn  kl vesa ?
         je        INT082                   ; zmˆna se neporovn v 
         cmp       al,ds:[OldKey+KORIG]     ; je zmˆna portu kl vesnice ?
         jne       INT086                   ; je zmˆna - rozsv¡cen¡ displeje

; ------ opˆtovn‚ ztmaven¡ displeje

INT082:  test      byte ptr ds:[Param+KORIG],bit1 ; je displej ztmaven ?
         jnz       INT088                   ; displej je ztmaven

; ------ ‡¡t n¡ ztmaven¡ displeje

         dec       word ptr ds:[Timer+KORIG]; ‡¡t n¡ doby pro ztmaven¡
         jnz       INT088                   ; nen¡ je¨tˆ ztmaven¡
         or        byte ptr ds:[Param+KORIG],bit1 ; p©¡znak ztmaven¡ displeje
         in        al,[60h]                 ; stav portu kl vesnice
         mov       ds:[OldKey+KORIG],al     ; £schova portu kl vesnice

; ------ vypnut¡ videosign lu

         and       ah,not 8
         mov       al,ah
         call      SetHerc                  ; korekce videom¢du pro Hercules
         out       dx,al                    ; vypnut¡ videosign lu
         jmp       short INT088

; ------ rozsv¡cen¡ displeje

INT085:  mov       byte ptr ds:[OldKey+KORIG],0  ; zru¨en¡ kl vesy v bufferu
INT086:  test      byte ptr ds:[Param+KORIG],bit1 ; je displej ztmaven ?
         jz        INT087                   ; nen¡ ztmaven

; ------ zapnut¡ videosign lu

         or        ah,8
         mov       al,ah
         call      SetHerc                  ; korekce videom¢du pro Hercules
         out       dx,al                    ; zapnut¡ videosign lu

; ------ nov  inicializace ‡¡ta‡e

INT087:  mov       ax,ds:[Timer0+KORIG]     ; inicializa‡n¡ nastaven¡ ‡¡ta‡e
         mov       ds:[Timer+KORIG],ax      ; nov‚ nastaven¡ ‡¡ta‡e
         and       byte ptr ds:[Param+KORIG],not bit1+bit2 ; zru¨en¡ p©¡znak–
         mov       byte ptr ds:[Timer2+KORIG],5*18 ; ‡¡ta‡ pro test portem

; ------ n vrat registr–

INT088:  pop       ds
         pop       dx
         pop       ax
         iret

INT08    ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ p©¡znaku grafick‚ho m¢du Hercules (DX=port 3b8h, AL=bajt)
; -----------------------------------------------------------------------------

SetHerc  PROC      NEAR

         and       al,not 2
         push      ax
         push      dx

         inc       dx
         inc       dx                       ; stavov˜ registr video©adi‡e 3bah

         sti

SetHerc1:in        al,dx                    ; ‡ten¡ stavov‚ho registru karty MDA
         test      al,80h                   ; prob¡h  synchroimpuls ?
         jz        SetHerc1                 ; ‡ek n¡ na za‡ tek synchroimpulsu

SetHerc2:in        al,dx                    ; ‡ten¡ stavov‚ho registru karty MDA
         test      al,80h                   ; prob¡h  synchroimpuls ?
         jnz       SetHerc2                 ; ‡ek n¡ na konec synchroimpulsu

         cli

         inc       dx                       ; registr svˆteln‚ho pera 3bbh
         xor       al,al                    ; AL <- 00
         out       dx,al                    ; vymaz n¡ registru svˆteln‚ho pera

         dec       dx
         dec       dx                       ; alternativn¡ adresa 3b9h
         out       dx,al                    ; vymaz n¡ registru svˆteln‚ho pera

         sub       dl,5                     ; ©¡dic¡ registr 3b4h
         mov       al,10h                   ; registr svˆteln‚ho pera HIGH
         out       dx,al                    ; nastaven¡ registru 10h

         inc       dx                       ; data registru 10h
         in        al,dx                    ; ‡ten¡ vy¨¨¡ adresy svˆteln‚ho pera

         cmp       al,9 ;2957                  ; je max. pozice pera 2957 ?

         pop       dx
         pop       ax
         jbe       SetHerc3
         or        al,2                     ; p©¡znak grafick‚ho m¢du

SetHerc3:ret

SetHerc  ENDP

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

INT333:  or        byte ptr cs:[Param+KORIG],bit2 ; po‘adavek rozsv¡cen¡
         mov       cs:[MPozice+KORIG],cx    ; £schova pozice
         mov       cs:[MRadek+KORIG],dx     ; £schova © dku
INT334:  iret

INT335:  pushf
         call      dword ptr cs:[Old33+KORIG]

         or        dx,dx
         jnz       INT336
         jcxz      INT337

INT336:  or        byte ptr cs:[Param+KORIG],bit2 ; po‘adavek rozsv¡cen¡
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
         int       33h                      ; test instalace ovlada‡e my¨i
         inc       ax                       ; je ovlada‡ my¨i nainstalov n ?
         jnz       Init2                    ; nen¡ nainstalov n
         or        byte ptr ds:[Param+KORIG],bit5 ; p©¡znak ovlada‡e my¨i

; ------ rozbor p©¡kazov‚ho © dku (ES=segment rezidentn¡ho programu)

Init2:   call      Rozbor                   ; rozbor

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

; ------ zobrazen¡ po‡tu sekund

         xchg      ax,dx
         mov       dx,offset Akt3Txt
         or        ax,ax                    ; jsou sekundy ?
         jz        DispStv2                 ; nejsou sekundy
         mov       dx,offset Akt4Txt
         call      DispTxt
         xor       dx,dx
         mov       bx,18
         div       bx                       ; v˜po‡et po‡tu sekund
         call      DispNum                  ; zobrazen¡ po‡tu sekund

; ------ zobrazen¡ zbytku textu

         mov       dx,offset Akt5Txt
DispStv2:call      DispTxt                  ; zobrazen¡ zbytku textu
         ret

DispStav ENDP

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

DispNum2:pop       dx
         mov       ah,2
         int       21h                      ; zobrazen¡ ‡¡slice
         loop      DispNum2                 ; dal¨¡ ‡¡slice

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispNum  ENDP

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

; ------ rozsv¡cen¡ displeje

         call      Rozsvit                  ; rozsv¡cen¡ displeje

; ------ n vrat registr–

         pop       ds
         sti
         ret

DeInst   ENDP

; -----------------------------------------------------------------------------
;        Rozbor p©¡kazov‚ho © dku (ES=segment programu)
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

; ------ parametr "N" - ztmavov n¡ neaktivn¡

         cmp       al,"N"
         jne       Rozbor3
         cli
         and       byte ptr es:[Param+KORIG],not bit0+bit1+bit2 ; vypnut¡ funkce
         call      Rozsvit                  ; rozsv¡cen¡ displeje
         sti
         jmp       short Rozbor1

; ------ parametr "A" - ztmavov n¡ aktivn¡

Rozbor3: cmp       al,"A"
         jne       Rozbor4
         cli
         or        byte ptr es:[Param+KORIG],bit0 ; zapnut¡ funkce
         mov       ax,es:[Timer0+KORIG]
         mov       es:[Timer+KORIG],ax      ; inicializace ‡¡ta‡e
         sti
         jmp       short Rozbor1

; ------ parametr "X" - okam‘it‚ ztmaven¡

Rozbor4: cmp       al,"X"
         jne       Rozbor5
         cli
         and       byte ptr es:[Param+KORIG],not bit3 ; zru¨en¡ po‘ad.rozsv¡cen¡
         or        byte ptr es:[Param+KORIG],bit0+bit1 ; zapnut¡ + ztmaven¡
         sti
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

; -----------------------------------------------------------------------------
;        rozsv¡cen¡ displeje
; -----------------------------------------------------------------------------

Rozsvit  PROC      NEAR

         push      ax
         push      ds
         xor       ax,ax                    ; AX <- 0
         mov       ds,ax                    ; DS <- 0
         mov       dx,ds:[463h]             ; b zov  ©¡dic¡ adresa displeje
         add       dl,4
         mov       al,ds:[465h]             ; nastaven¡ portu 3x8h
         or        al,8
         out       dx,al                    ; povolen¡ zobrazen¡
         add       dl,2                     ; adresa stavov‚ho portu displeje
         in        al,dx                    ; synchronizace n slednosti
         mov       dl,0c0h                  ; adresa portu palet
         mov       al,20h
         out       dx,al                    ; zapnut¡ videosign lu
         pop       ds
         pop       ax
         ret

Rozsvit  ENDP

; *****************************************************************************
;
;                                   Data
;
; *****************************************************************************

UvTxt    db        'DARKHERC V1.0 - ztmavovac displeje Hercules; (c) Miroslav Nemecek',13,10,'$'
HelpTxt  db        'Zadejte:    N ....... ztmavovani je neaktivni',13,10
         db        '            A ....... ztmavovani je aktivni (implicitne)',13,10
         db        '            cislo ... doba pro ztmaveni 1 az 60 minut (implicitne 5 minut)',13,10
         db        '            min:sek . doba pro ztmaveni ve tvaru minuty:sekundy',13,10
         db        '                       (v rozsahu 1 sekunda az 60 minut)',13,10
         db        '            X ....... okamzite ztmaveni displeje',13,10
         db        '            ! ....... odinstalovani programu z pameti',13,10
         db        '$'

InstTxt  db        'Program byl nainstalovan do pameti.',13,10,'$'
AktTxt   db        'Ztmavovani je $'
Akt1Txt  db        'NE'
Akt2Txt  db        'AKTIVNI, nastavena doba $'
Akt3Txt  db        ' minut.',13,10,'$'
Akt4Txt  db        ' minut, $'
Akt5Txt  db        ' sekund.',13,10,'$'

DInstTxt db        'Program byl odinstalovan z pameti.',13,10,'$'

NeniTxt  db        'Program nelze odinstalovat, nebyl dosud nainstalovan.',13,10,'$'
NelzeTxt db        'Program nelze odinstalovat, je nutno nejdrive',13,10
         db        'odinstalovat programy nainstalovane pozdeji.',13,10,'$'

Command  db        128 dup(?)               ; buffer p©¡kazov‚ho © dku

Code     ENDS
         END       Start


; *****************************************************************************
;
;                              F O R M T
;                     Rezidentn¡ form tovac¡ program
;
; *****************************************************************************

code     segment
         assume    cs:code,ds:code
         org       100h

Sirka    EQU       34                       ; ¨¡©ka okna
Vyska    EQU       12                       ; v˜¨ka okna

start:   jmp       init                     ; inicializace programu

OdInstal db        0                        ; 1=p©¡znak odinstalov n¡ programu
WinBuf   dw        offset init              ; buffer pro £schovu okna
EndBuf   dw        offset init + Sirka*Vyska*2 ; adresa konce bufferu
BufDTA   dw        0                        ; adresa bufferu pro DTA p©enosy
EndRez   dw        0                        ; konec rezidentn¡ ‡ sti


                                          ;* parametry diskety
Old0e    dd        0                        ; p–vodn¡ adresa INT 0eh
ParInt0e db        0                        ; 1=p©¡znak p©eru¨en¡ INT 0eh
Double   db        1                        ; 1=p©¡znak dvoj¡ho krokov n¡
AdrPort  dw        3f0h                     ; adresa ©adi‡e FLOPPY
Disketa  db        0                        ; ‡¡slo diskety (0,...)
MaskDisk db        1                        ; maska diskety
Rate     db        1                        ; p©enosov  rychlost
MaxStop  db        40                       ; maxim ln¡ po‡et stop



OldKurz  dw        0                        ; p–vodn¡ pozice kurzoru
TopPoz   db        0                        ; po‡ te‡n¡ pozice okna
         db        25/2 - Vyska/2           ; po‡ te‡n¡ © dek okna

Barva    db        70h                      ; barva pro zobrazen¡ textu
Mono     db        0                        ; 1=p©¡znak monochrom. videom¢du
AktPage  db        0                        ; aktivn¡ videostr nka

                                          ;* stavov‚ registry v˜sledku operace
StatST0  db        0                        ; stavov˜ registr ST0
StatST1  db        0                        ; stavov˜ registr ST1
StatSt2  db        0                        ; stavov˜ registr ST2
StatTr   db        0                        ; stavov˜ registr - stopa
StatHd   db        0                        ; stavov˜ registr - v lec
StatSt   db        0                        ; stavov˜ registr - sektor
StatLn   db        0                        ; stavov˜ registr - d‚lka sektoru

; *****************************************************************************
;
;        Obsluha INT 08h
;
; *****************************************************************************

Old08    dd        0                        ; p–vodn¡ adresa INT 08h

PUBLIC   INT08

INT08    PROC      FAR

         cmp       byte ptr cs:[OdInstal],0 ; je program odinstalov n ?
         je        INT080                   ; program nen¡ odinstalov n
         jmp       dword ptr cs:[Old08]

                                          ;* vlastn¡ obsluha INT 08h
INT080:  jmp       dword ptr cs:[Old08]



INT08    ENDP


; *****************************************************************************
;
;        Obsluha INT 09h
;
; *****************************************************************************

Old09    dd        0                        ; p–vodn¡ adresa INT 09h
Par09    db        0                        ; 0=p©¡znak, ‘e neprob¡h  INT 09h
Key09    dw        0                        ; uschovan  kl vesa z INT 09h


PUBLIC   INT09

INT09    PROC      FAR

         cmp       byte ptr cs:[OdInstal],0 ; je program odinstalov n ?
         je        INT090                   ; program nen¡ odinstalov n
         jmp       dword ptr cs:[Old09]     ; p–vodn¡ obsluha INT 09h

INT090:  push      ds
         push      bx
         mov       bx,40h
         mov       ds,bx                    ; DS <- segment BIOS (40h)
         mov       bx,ds:[1ch]              ; ‡tec¡ adresa z bufferu kl vesnice
         pushf                              ; simulace INT
         call      dword ptr cs:[Old09]     ; vol n¡ p–vodn¡ obsluhy INT 09h
         cmp       bx,ds:[1ch]              ; byla platn  kl vesa ?
         je        INT092                   ; nebyla platn  kl vesa

                                          ;* £schova kl vesy, pokud je obsluha
         cmp       byte ptr cs:[Par09],0    ; prob¡h  INT 09h ?
         je        INT091                   ; neprob¡h  INT 09h
         mov       ds:[1ch],bx              ; zru¨en¡ kl vesy v bufferu
         mov       bx,ds:[bx]               ; p©ijat  kl vesa
         mov       cs:[Key09],bx            ; £schova p©ijat‚ kl vesy
         jmp       short INT092

                                          ;* test, zda je hork  kl vesa
INT091:  cmp       word ptr ds:[bx],2100h   ; je kl vesa Alt-F ?
         jne       INT092                   ; nen¡ kl vesa Alt-F
         test      byte ptr ds:[17h],4      ; je kl vesa Ctrl- ?
         jz        INT092                   ; nen¡ kl vesa

                                          ;* je obsluha
         mov       ds:[1ch],bx              ; zru¨en¡ kl vesy v bufferu
         inc       byte ptr cs:[Par09]      ; p©¡znak prob¡haj¡c¡ obsluhy
         sti                                ; povolen¡ p©eru¨en¡
         call      Rezid                    ; obsluha rezidentn¡ ‡ sti
         cli                                ; z kaz p©eru¨en¡
         dec       byte ptr cs:[Par09]      ; zru¨en¡ p©¡znaku obsluhy

INT092:  pop       bx
         pop       ds
         iret



INT09    ENDP



; *****************************************************************************
;
;        Obsluha INT 13h
;
; *****************************************************************************

Old13    dd        0                        ; p–vodn¡ adresa INT 13h

PUBLIC   INT13

INT13    PROC      FAR

         cmp       byte ptr cs:[OdInstal],0 ; je program odinstalov n ?
         je        INT130                   ; program nen¡ odinstalov n
         jmp       dword ptr cs:[Old13]     ; p–vodn¡ obsluha INT 13h

INT130:  jmp       dword ptr cs:[Old13]




INT13    ENDP


; *****************************************************************************
;
;        Form tov n¡ diskety
;
; *****************************************************************************

PUBLIC   Format
Format   PROC      NEAR


; ------ instalace INT 0eh

         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[0eh*4]
         mov       word ptr cs:[old0e],ax
         mov       ax,ds:[0eh*4+2]
         mov       word ptr cs:[old0e+2],ax
         mov       ax,offset INT0e
         mov       ds:[0eh*4],ax
         mov       ds:[0eh*4+2],cs
         mov       byte ptr cs:[ParInt0e],0 ; zru¨en¡ p©¡znaku p©eru¨en¡ INT 0eh
         pop       ds


         call      MotorOn                  ; zapnut¡ motoru

         call      Recalib                  ; rekalibrace disku


         mov       cx,10

Form1:   xor       al,al                    ; po‘adovan  stopa 0
         call      Seek                     ; vystaven¡ na stopu 0


         mov       al,39
         call      Seek

         loop      Form1


         mov       al,cs:[Rate]             ; p©enosov  rychlost
         call      SetRate                  ; nastaven¡ p©enosov‚ rychlosti



         call      MotorOff                 ; vypnut¡ motoru


                                          ;* odinstalov n¡ INT 0eh
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,word ptr cs:[old0e]
         mov       ds:[0eh*4],ax
         mov       ax,word ptr cs:[old0e+2]
         mov       ds:[0eh*4+2],ax
         pop       ds

         ret



Format   ENDP

; -----------------------------------------------------------------------------
;        Vystaven¡ mechaniky
; -----------------------------------------------------------------------------

PUBLIC   Seek
Seek     PROC      NEAR

; ------ zdvojn soben¡ stopy p©i dvojit‚m krokov n¡

         cmp       byte ptr cs:[Double],0   ; m  b˜t dvoj¡ krokov n¡ ?
         je        Seek1                    ; nen¡ dvoj¡ krokov n¡
         add       al,al                    ; stopa * 2


Seek1:   push      ax
         mov       al,0fh                   ; povel pro vystaven¡
         call      Command                  ; vysl n¡ povely pro vystaven¡
         mov       al,cs:[Disketa]          ; po‘adovan˜ disk
         call      Command                  ; vysl n¡ po‘adovan‚ho disku
         pop       ax
         call      Command                  ; po‘adovan  stopa
         call      Status                   ; ‡ten¡ stavu operace

         ret


Seek     ENDP

; -----------------------------------------------------------------------------
;        Rekalibrace disku (CY=chyba)
; -----------------------------------------------------------------------------

PUBLIC   Recalib
Recalib  PROC      NEAR

         push      ax
         mov       al,7                     ; povel pro rekalibrace
         call      Command                  ; v˜stup povelu na ©adi‡
         jc        Recalib2
         mov       al,cs:[Disketa]          ; ‡¡slo diskety
         call      Command                  ; v˜stup povelu na ©adi‡
         jc        Recalib2
         call      Status                   ; ‡ten¡ stavu operace
Recalib2:pop       ax
         ret

Recalib  ENDP

; -----------------------------------------------------------------------------
;        V˜stup povelu AL na ©adi‡ (CY=chyba)
; -----------------------------------------------------------------------------

PUBLIC   Command
Command  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava registr– pro operaci

         mov       ah,al                    ; £schova bajtu k v˜stupu
         mov       dx,cs:[AdrPort]
         add       dx,4                     ; hlavn¡ stavov˜ registr MSR
         xor       cx,cx                    ; ‡¡ta‡ ‡asu
         mov       bl,3                     ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

Command1:in        al,dx                    ; ‡ten¡ stavu ©adi‡e
         and       al,11000000b             ; bity p©ipravenosti
         cmp       al,10000000b             ; je ©adi‡ p©ipraven k p©¡jmu ?
         je        Command2                 ; ©adi‡ je p©ipraven p©ijmout povel
         loop      Command1                 ; ‡ek n¡ na p©ipravenost ©adi‡e
         dec       bl                       ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu
         jnz       Command1                 ; dal¨¡ ‡ek n¡
         stc                                ; p©¡znak chyby operace
         jmp       short Command3           ; chyba TIME-OUT

; ------ vysl n¡ povelu na ©adi‡

Command2:mov       al,ah                    ; bajt k vysl n¡
         inc       dx                       ; registr povel– a dat ©adi‡e
         out       dx,al                    ; vysl n¡ bajtu povelu na port

Command3:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Command  ENDP


; -----------------------------------------------------------------------------
;        €ten¡ v˜sledku operace
; -----------------------------------------------------------------------------

PUBLIC   Status
Status   PROC      NEAR

         push      ax
         call      WaitInt                  ; ‡ek n¡ na p©eru¨en¡ od ©adi‡e
         jc        Status3                  ; nastala chyba operace

; ------ ‡ten¡ stavu operace

         mov       ah,8                     ; povel pro ‡ten¡ stavu ©adi‡e
         call      Command                  ; povel pro ‡ten¡ stavu
         call      Result                   ; ‡ten¡ stavu operace
         jc        Status3                  ; chyba operace
         mov       al,cs:[StatST0]          ; ‡ten¡ stavov‚ho registru ST0
         and       al,01100000b             ; p©¡znaky operace
         cmp       al,01100000b             ; byla chyba operace ?
         stc                                ; p©¡znak chyb operace
         je        Status3                  ; byla chyba operace
         clc                                ; p©¡znak - operace OK
Status3: pop       ax
         ret

Status   ENDP

; -----------------------------------------------------------------------------
;        €ten¡ v˜sledku operace
; -----------------------------------------------------------------------------

PUBLIC   Result
Result   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      di

; ------ p©¡prava registr–

         mov       di,offset StatST0        ; buffer stavov˜ch registr–
         mov       bl,7                     ; po‡et stavov˜ch bajt–
         mov       dx,cs:[AdrPort]          ; adresa portu ©adi‡e
         add       dx,4                     ; stavov˜ registr

; ------ ‡ek n¡ na p©ipravenost ©adi‡e

Result1: mov       bh,2                     ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu
         xor       cx,cx                    ; ni‘¨¡ ‡ st ‡¡ta‡e ‡asu
Result2: in        al,dx                    ; ‡ten¡ registru stavu
         and       al,11000000b             ; bity stavu a smˆru
         cmp       al,11000000b             ; je p©ipraven stavov˜ bajt ?
         je        Result3                  ; je p©ipraven stavov˜ bajt
         loop      Result2                  ; ‡ek n¡ na p©ipravenost ©adi‡e
         dec       bh                       ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu
         jnz       Result2                  ; dal¨¡ ‡ek n¡ na p©ipravenost
         stc                                ; p©¡znak chyby
         jmp       short Result4            ; n vrat s chybou TIME-OUT

; ------ ‡ten¡ stavov‚ho bajtu

Result3: inc       dx                       ; povelov˜ registr ©adi‡e
         in        al,dx                    ; ‡ten¡ stavov‚ho bajtu
         mov       cs:[di],al               ; ulo‘en¡ stavov‚ho bajtu
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         dec       dx                       ; stavov˜ registr ©adi‡e

; ------ test, zda je je¨tˆ dal¨¡ bajt

         mov       cx,20
         loop      $                        ; ‡ek n¡ asi 20 us
         in        al,dx                    ; ‡ten¡ stavov‚ho registru
         test      al,00010000b             ; jsou dal¨¡ data ?
         jz        Result4                  ; nen¡ ji‘ dal¨¡ bajt
         dec       bl                       ; sn¡‘en¡ ‡¡ta‡e bajt–
         jnz       Result1                  ; ‡ten¡ dal¨¡ho bajtu

Result4: pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Result   ENDP

; -----------------------------------------------------------------------------
;        €ek n¡ na p©eru¨en¡ od ©adi‡e (CY=chyba TIME-OUT)
; -----------------------------------------------------------------------------

PUBLIC   WaitInt
WaitInt  PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

; ------ p©¡prava registr–

         mov       bl,4                     ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu
         xor       cx,cx                    ; ni‘¨¡ ‡ st ‡¡ta‡e ‡asu
         sti                                ; p©eru¨en¡ mus¡ b˜t povoleno

; ------ ‡ek n¡ na p©eru¨en¡ od ©adi‡e INT 0eh

WaitInt1:cmp       byte ptr cs:[ParInt0e],0 ; nastalo p©eru¨en¡ INT 0eh ?
         jne       WaitInt2                 ; nastalo p©eru¨en¡ INT 0eh
         loop      WaitInt1                 ; ‡ek n¡ na p©eru¨en¡
         dec       bl                       ; vy¨¨¡ ‡ st ‡¡ta‡e ‡asu
         jnz       WaitInt1                 ; ‡ek n¡ na p©eru¨en¡

         stc                                ; p©¡znak chyby - p©eru¨en¡ nep©i¨lo

WaitInt2:mov       byte ptr cs:[ParInt0e],0 ; zru¨en¡ p©¡znaku p©eru¨en¡
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WaitInt  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ p©enosov‚ rychlosti AL
; -----------------------------------------------------------------------------

PUBLIC   SetRate
SetRate  PROC      NEAR

         push      dx
         mov       dx,cs:[AdrPort]          ; adresa ©adi‡e
         add       dx,7
         out       dx,al
         pop       dx
         ret

SetRate  ENDP

; -----------------------------------------------------------------------------
;        Zapnut¡ motoru
; -----------------------------------------------------------------------------

PUBLIC   MotorOn
MotorOn  PROC      NEAR

         push      ax
         push      cx
         push      dx

         mov       al,cs:[MaskDisk]         ; maska diskety
         mov       cl,4
         shl       al,cl                    ; rotace na pozici
         or        al,cs:[Disketa]          ; po‘adovan  disketa
         or        al,00001100b             ; bity pro uvolnˆn¡ ©adi‡e
         mov       dx,cs:[AdrPort]          ; adresa ©adi‡e
         add       dx,2
         out       dx,al                    ; zapnut¡ mechaniky

         pop       dx
         pop       cx
         pop       ax
         ret

MotorOn  ENDP

; -----------------------------------------------------------------------------
;        Vypnut¡ motoru
; -----------------------------------------------------------------------------

PUBLIC   MotorOff
MotorOff PROC      NEAR

         push      ax
         push      dx
         xor       al,al                    ; reset ©adi‡e
         mov       dx,cs:[AdrPort]          ; adresa portu
         out       dx,al
         pop       dx
         pop       ax
         ret

MotorOff ENDP

; -----------------------------------------------------------------------------
;        Obsluha p©eru¨en¡ INT 0eh
; -----------------------------------------------------------------------------

PUBLIC   INT0e
INT0e    PROC      FAR

         push      ax
         or        byte ptr cs:[ParInt0e],1 ; p©¡znak p©eru¨en¡ INT 0eh
         mov       al,20h
         out       [20h],al                 ; uvolnˆn¡ ©adi‡e p©eru¨en¡
         pop       ax
         iret

INT0e    ENDP

; *****************************************************************************
;
;        Obsluha ovl d n¡ rezidentn¡ ‡ sti
;
; *****************************************************************************

PUBLIC   Rezid
Rezid    PROC      NEAR

                                          ;* £schova registr–
         pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      ds
         push      es

         push      cs
         pop       ds
         push      cs
         pop       es

         call      StoreWin                 ; £schova podkladu a parametr– okna

         mov       si,offset MainWind       ; hlavn¡ okno
         call      DispWin                  ; zobrazen¡ hlavn¡ho okna
;         call      DispRam                  ; zobrazen¡ r mu okna

         call      InpKey                   ; ‡ek n¡ na vstup znaku

                                          ;* odinstalov n¡ programu
         cmp       ax,4400h                 ; je F10 ?
         jne       Rezid2                   ; nen¡ F10
         inc       byte ptr ds:[OdInstal]   ; odinstalov n¡ programu
         jmp       short Rezid9


Rezid2:  cmp       ax,3b00h                 ; form tov n¡ diskety ?
         jne       Rezid9

         call      Format



                                          ;* n vrat registr–
Rezid9:  call      RetWind                  ; n vrat podkladu a parametr– okna
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

Rezid    ENDP

; -----------------------------------------------------------------------------
;        €ek n¡ na vstup znaku z kl vesnice
; -----------------------------------------------------------------------------

PUBLIC   InpKey
InpKey   PROC      NEAR

         pushf
         call      KurzOff                  ; vypnut¡ kurzoru
         sti
         mov       word ptr cs:[Key09],0
InpKey1: mov       ax,cs:[Key09]
         or        ax,ax
         jz        InpKey1
         popf
         ret

InpKey   ENDP

; -----------------------------------------------------------------------------
;        —schova podkladu a parametr– okna
; -----------------------------------------------------------------------------

PUBLIC   StoreWin
StoreWin PROC      NEAR

                                          ;* £schova parametr– okna
         mov       ah,0fh
         call      INT10I                   ; zji¨tˆn¡ videom¢du

                                          ;* rozli¨en¡ barevn‚ho videom¢du
         mov       byte ptr ds:[Mono],1     ; p©¡znak monochrom. videom¢du
;         cmp       al,15                    ; monochrom. videom¢d ?
;         je        StoreWn2                 ; monochrom. videom¢du
;         cmp       al,7                     ; monochrom. videom¢d ?
;         ja        StoreWn1                 ; barevn˜ videom¢d
         cmp       al,5                     ; videom¢d 5, 6 nebo 7 ?
         jae       StoreWn2                 ; monochrom. videom¢d
         test      al,1                     ; ¨ed‚ barvy ?
         jz        StoreWn2                 ; ¨ed‚ barvy
StoreWn1:mov       byte ptr ds:[Mono],0     ; p©¡znak barevn‚ho re‘imu

StoreWn2:mov       ds:[AktPage],bh          ; aktivn¡ videostr nka
         shr       ah,1                     ; po‡et pozic / 2
         sub       ah,Sirka/2               ; ode‡ten¡ poloviny okna
         mov       ds:[TopPoz],ah           ; po‡ te‡n¡ pozice okna
         mov       ah,3
         call      INT10I                   ; ‡ten¡ pozice kurzoru
         mov       ds:[OldKurz],dx          ; £schova pozice kurzoru




         ret


StoreWin ENDP

; -----------------------------------------------------------------------------
;        N vrat podkladu a parametr– okna
; -----------------------------------------------------------------------------

PUBLIC   RetWind
RetWind  PROC      NEAR



         mov       dx,ds:[OldKurz]          ; p–vodn¡ pozice kurzoru
         call      SetKurz                  ; n vrat pozice kurzoru
         ret

RetWind  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ okna DS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispWin
DispWin  PROC      NEAR

         call      DispRam                  ; zobrazen¡ r mu a podkladu okna
         mov       dx,word ptr ds:[TopPoz]  ; po‡ te‡n¡ pozice okna
         add       dx,103h                  ; po‡ te‡n¡ pozice textu
DispWin1:cmp       byte ptr ds:[si],0       ; je konec textu okna ?
         je        DispWin2                 ; konec textu okna
         call      WritTxt                  ; zobrazen¡ © dku okna
         jmp       short DispWin1
DispWin2:ret

DispWin  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ r mu okna
; -----------------------------------------------------------------------------

PUBLIC   DispRam
DispRam  PROC      NEAR

                                          ;* p©¡prava pro zobrazen¡ okna
         mov       ah,70h                   ; barva pro zobrazen¡ okna
         call      SetCol                   ; nastaven¡ barvy pro zobrazen¡
         mov       dx,word ptr ds:[TopPoz]  ; po‡ te‡n¡ pozice okna

                                          ;* zobrazen¡ horn¡ linky
         mov       ax,201+256*205           ; lev˜ horn¡ roh a horn¡ linka
         mov       bl,187                   ; prav˜ horn¡ roh
         call      DispLink                 ; zobrazen¡ horn¡ linky

                                          ;* zobrazen¡ vnit©n¡ch linek
         mov       cx,Vyska-2               ; v˜¨ka bez okraj–
         mov       ax,186+256*" "           ; lev˜ okraj a vnit©n¡ mezera
         mov       bl,186                   ; lev˜ okraj
DispRam2:call      DispLink                 ; zobrazen¡ vnit©n¡ linky
         loop      DispRam2                 ; zobrazen¡ dal¨¡ linky

                                          ;* zobrazen¡ doln¡ linky
         mov       ax,200+256*205           ; lev˜ doln¡ roh a doln¡ linka
         mov       bl,188                   ; prav˜ doln¡ roh
         call      DispLink                 ; zobrazen¡ doln¡ linky

         ret


DispRam  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ linky okna (znaky AL, AH, BL)
; -----------------------------------------------------------------------------

PUBLIC   DispLink
DispLink PROC      NEAR


         push      ax
         push      cx
         push      dx

                                          ;* lev  mezera
         push      ax
         mov       al," "
         call      Writ1Ch                  ; po‡ te‡n¡ mezera
         pop       ax

                                          ;* lev  strana
         call      Writ1Ch                  ; zobrazen¡ lev‚ strany

                                          ;* st©edn¡ znak
         mov       cl,Sirka-4               ; ¨¡©ka vnit©ku okna
         xchg      ah,al
         call      WritCh                   ; zobrazen¡ horn¡ linky

                                          ;* prav  strana
         mov       al,bl                    ; prav  strana
         call      Writ1Ch                  ; zobrazen¡ prav‚ strany

                                          ;* prav  mezera
         mov       al," "
         call      Writ1Ch

         pop       dx
         pop       cx
         pop       ax
         inc       dh                       ; zv˜¨en¡ © dku
         ret

DispLink ENDP

; -----------------------------------------------------------------------------
;        Z pis znaku AL na pozici DX
; -----------------------------------------------------------------------------

PUBLIC   Writ1Ch
Writ1Ch  PROC      NEAR

         push      cx
         mov       cl,1
         call      WritCh
         pop       cx
         ret

Writ1Ch  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ barvy AH pro zobrazen¡ textu
; -----------------------------------------------------------------------------

PUBLIC   SetCol
SetCol   PROC      NEAR

         push      ax
         cmp       byte ptr cs:[Mono],0     ; je monochromatick˜ videom¢d ?
         je        SetCol2                  ; je barevn˜ vidoem¢d

                                          ;* oprava barvy pro monochrom. m¢d
         mov       ah,7                     ; barva pro graf. a monochr. re‘imy

SetCol2: mov       cs:[Barva],ah            ; nastaven¡ barvy p¡sma
         pop       ax
         ret

SetCol   ENDP

; -----------------------------------------------------------------------------
;        Z pis textu DS:SI od pozice DX
; -----------------------------------------------------------------------------

PUBLIC   WritTxt
WritTxt  PROC      NEAR

         push      ax
         push      dx
         cld
WritTxt1:lodsb
         or        al,al
         jz        WritTxt2
         call      Writ1Ch
         jmp       short WritTxt1
WritTxt2:pop       dx
         pop       ax
         inc       dh
         ret

WritTxt  ENDP

; -----------------------------------------------------------------------------
;        Z pis CL znak– AL na pozici DX
; -----------------------------------------------------------------------------

PUBLIC   WritCh
WritCh   PROC      NEAR

         call      SetKurz                  ; nastaven¡ pozice kurzoru

         push      ax
         push      bx
         push      cx
         mov       bh,cs:[AktPage]          ; aktivn¡ videostr nka
         mov       bl,cs:[Barva]            ; atribut barvy
         mov       ah,9
         xor       ch,ch
         call      INT10I                   ; zobrazen¡ znaku
         pop       cx
         pop       bx
         pop       ax
         add       dl,cl                    ; zv˜¨en¡ pozice na © dku
         ret

WritCh   ENDP

; -----------------------------------------------------------------------------
;        €ten¡ znaku z pozice DX
; -----------------------------------------------------------------------------

PUBLIC   ReadChar
ReadChar PROC      NEAR

         call      SetKurz                  ; nastaven¡ pozice kurzoru


         ret

ReadChar ENDP

; -----------------------------------------------------------------------------
;        Vypnut¡ kurzoru
; -----------------------------------------------------------------------------

PUBLIC   KurzOff
KurzOff  PROC      NEAR

         push      dx
         mov       dx,60*256
         call      SetKurz
         pop       dx
         ret

KurzOff  ENDP

; -----------------------------------------------------------------------------
;        Nastaven¡ pozice kurzoru DX
; -----------------------------------------------------------------------------

PUBLIC   SetKurz
SetKurz  PROC      NEAR

         push      ax
         push      bx
         mov       bh,cs:[AktPage]          ; aktivn¡ str nka displeje
         mov       ah,2
         call      INT10I                   ; nastaven¡ pozice kurzoru
         pop       bx
         pop       ax
         ret

SetKurz  ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 10h
; -----------------------------------------------------------------------------

PUBLIC   INT10I
INT10I   PROC      NEAR

         pushf
         push      si
         push      di
         push      bp
         push      ds
         push      es
         int       10h
         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         popf
         ret

INT10I   ENDP

                                          ;* z kladn¡ okno
MainWind db        'F1   160 KB (5 1/4")       ',0
         db        'F2   180 KB (5 1/4")       ',0
         db        'F3   320 KB (5 1/4")       ',0
         db        'F4   360 KB (5 1/4")       ',0
         db        'F5   720 KB (5 1/4")       ',0
         db        'F6   1.2 MB (5 1/4")       ',0
         db        'F7   720 KB (3 1/2")       ',0
         db        'F8  1.44 MB (3 1/2")       ',0
         db        'F9  volba disku (nyni je '
MainWin0 db        'A)',0
         db        'F10 odinstalovani programu ',0
         db        0


VarTxt   db        'Disketa v mechanice '
VarTxt0  db        'A',0
         db        'bude zformatovana na',0



         EVEN                               ; zaokrouhlen¡ na slovo

; *****************************************************************************
;
;        Inicializace
;
; *****************************************************************************


init:
         mov       si,offset uvtxt          ; £vodn¡ text
         call      DispTxt                  ; zobrazen¡ £vodn¡ho textu

                                          ;* v˜po‡et adresy DTA bufferu sektoru
         mov       bx,ds:[EndBuf]           ; konec rezidentn¡ ‡ sti programu
         add       bx,60                    ; adresa DTA bufferu sektoru
         mov       ax,cs
         shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; offset v segmentu 64 KB
         add       ax,bx                    ; offset za programem v segmentu
         add       ax,512                   ; kontrola p©ete‡en¡ p©es hranici
         jnc       Init2                    ; nen¡ hranice segmentu
         sub       ax,512                   ; n vrat za‡ tku bufferu
         neg       ax                       ; vzd lenost do konce segmentu
         add       bx,ax                    ; p©ekro‡en¡ hranice segmentu
Init2:   mov       ds:[BufDTA],bx           ; adresa bufferu pro DTA p©enosy

                                          ;* konec rezidentn¡ ‡ sti
         add       bx,512+512               ; prostor pro 1 sektor a z sobn¡k
         mov       ds:[EndRez],bx           ; konec rezidentn¡ ‡ sti

                                          ;* instalace INT 08h
         mov       ax,3508h
         int       21h                      ; poskytnut¡ adresy obsluhy INT 08h
         mov       word ptr ds:[Old08],bx   ; offset INT 08h
         mov       word ptr ds:[Old08+2],es ; segment INT 08h
         mov       ax,2508h
         mov       dx,offset INT08
         int       21h                      ; instalace obsluhy INT 08h

                                          ;* instalace INT 09h
         mov       ax,3509h
         int       21h                      ; poskytnut¡ adresy obsluhy INT 09h
         mov       word ptr ds:[Old09],bx   ; offset INT 09h
         mov       word ptr ds:[Old09+2],es ; segment INT 09h
         mov       ax,2509h
         mov       dx,offset INT09
         int       21h                      ; instalace obsluhy INT 09h

                                          ;* instalace INT 13h
         mov       ax,3513h
         int       21h                      ; poskytnut¡ adresy obsluhy INT 13h
         mov       word ptr ds:[Old13],bx   ; offset INT 13h
         mov       word ptr ds:[Old13+2],es ; segment INT 13h
         mov       ax,2513h
         mov       dx,offset INT13
         int       21h                      ; instalace obsluhy INT 13h

                                          ;* hl ¨en¡ o instalaci
         mov       si,offset insttxt
         call      DispTxt                  ; zobrazen¡ hl ¨en¡ o instalaci

                                          ;* instalace programu
         mov       dx,ds:[EndRez]           ; konec rezidentn¡ ‡ sti
         int       27h                      ; instalace programu


; -----------------------------------------------------------------------------
;        Zobrazen¡ textu DS:SI
; -----------------------------------------------------------------------------

PUBLIC   DispTxt
DispTxt  PROC      NEAR

         pushf
         push      ax
         push      dx
         cld
DispTxt1:lodsb
         or        al,al
         jz        DispTxt2
         call      DispChar
         jmp       short DispTxt1
DispTxt2:pop       dx
         pop       ax
         inc       dh
         popf
         ret

DispTxt  ENDP

; -----------------------------------------------------------------------------
;        Zobrazen¡ znaku
; -----------------------------------------------------------------------------

PUBLIC   DispChar
DispChar PROC      NEAR

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen¡
         mov       ah,2
         int       21h                      ; zobrazen¡ znaku
         pop       dx
         pop       ax
         ret

DispChar ENDP

; -----------------------------------------------------------------------------
;        Data pro inicializaci programu
; -----------------------------------------------------------------------------

uvtxt    db        'FORM V1.0 - formatovani disket; (c) Miroslav Nemecek',13,10
         db        0

insttxt  db        'Program FORM byl nainstalovan - aktivace Ctrl-Alt-F',13,10,0


code     ENDS
         END       start


; *****************************************************************************
;
;                              G M E N P I C
;
;                        Sn¡m n¡ obrazovky pro GMenu
;
; *****************************************************************************

SIRX     EQU       128                      ; ¨¡©ka obr zku (bod–)
VYSY     EQU       70                       ; v˜¨ka obr zku (bod–)

BufSize  equ       200h                     ; velikost diskov‚ho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

start:   jmp       instal                   ; instalace programu

AktScr   db        0                        ; p©¡znak aktivity operace SCREEN
AktAsk   db        0                        ; po‘adavek operace SCREEN

Aktiv21  dd        0                        ; adresa p©¡znaku aktivity DOS

old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
old09    dd        0                        ; adresa p–vodn¡ obsluhy INT 09h
old28    dd        0                        ; adresa p–vodn¡ obsluhy INT 28h


; -----------------------------------------------------------------------------
Zahlavi  label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
Ident    db        'SCR'                    ; identifikace souboru displeje
Verze    db        1                        ; verze souboru
Sirka    dw        SIRX                     ; ¨¡©ka v˜©ezu (pozic, bod–)
Vyska    dw        VYSY                     ; v˜¨ka v˜©ezu (linek)
Rovin    db        4                        ; po‡et barevn˜ch rovin
         db        0                        ; (rezervov no)
Pozadi   db        0                        ; barva pozad¡
Komentar db        0                        ; po‡et bajt– koment ©e + informace
Palet    dw        0                        ; po‡et bajt– za z hlav¡m
         db        16                       ; videom¢d displeje
Param    db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo‘en¡ barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
KonHl    label     byte                     ; konec z hlav¡

VMod     db        16                       ; skute‡n˜ videm¢d

; -----------------------------------------------------------------------------
;        komprese
; -----------------------------------------------------------------------------

; —sek shodn‚ho opakovan‚ho bajtu (komrese):
KompCit  dw        0                        ; ‡¡ta‡ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡

; —sek neshodn˜ch bajt– (nen¡ komprese):
KompBNum dw        0                        ; po‡et bajt– v kompresn¡m bufferu
KompBuff db        255 dup(0)               ; kompresn¡ buffer

; P©¡znak £seku komprese
KompPar  db        1                        ; 1=p©¡znak kompresn¡ho m¢du

; -----------------------------------------------------------------------------

                                          ;* definice kurzoru
X1       dw        0                        ; lev  pozice kurzoru
X2       dw        SIRX-1                   ; prav  pozice kurzoru
Y1       dw        0                        ; horn¡ © dek kurzoru
Y2       dw        VYSY-1                   ; doln¡ © dek kurzoru

MaxSir   dw        640                      ; maxim ln¡ ¨¡©ka
MaxVys   dw        350                      ; maxim ln¡ v˜¨ka

; -----------------------------------------------------------------------------
NumBuff  dw        0                        ; po‡et bajt– v diskov‚m bufferu

                                          ;* jm‚no souboru
Soubor   db        'A:\',64+14 dup(0)       ; buffer pro adres © a soubor
AdrSoub  dw        0                        ; adresa ‡¡sla souboru

Idents   dw        0                        ; identifikace v˜stupn¡ho souboru

Keys     dw        0                        ; uschovan˜ k¢d kl vesy
Citac    db        0                        ; ‡¡ta‡ blik n¡ kurzoru
AktKur   db        0                        ; p©¡znak zapnut¡ kurzoru

; -----------------------------------------------------------------------------
;        Obsluha INT 08h
; -----------------------------------------------------------------------------

int08    PROC      FAR

         pushf
         call      dword ptr cs:[Old08]     ; p–vodn¡ obsluha INT 08h
         call      Screen                   ; obsluha akce SCREEN
         iret

Int08    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 28h
; -----------------------------------------------------------------------------

int28    PROC      FAR

         pushf
         call      dword ptr cs:[Old28]     ; p–vodn¡ obsluha INT 28h
         call      Screen                   ; obsluha akce SCREEN
         iret

Int28    ENDP

; -----------------------------------------------------------------------------
;        Obsluha INT 09h
; -----------------------------------------------------------------------------

int09    PROC      far

         push      ax
         push      bx
         push      ds

         mov       bx,40h
         mov       ds,bx
         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu

         in        al,[60h]                 ; orienta‡n¡ k¢d kl vesy
         cmp       al,37h                   ; je kl vesa <Print Screen> ?
         jne       Int091                   ; nen¡ <Print Screen>
         test      byte ptr ds:[17h],4      ; je Ctrl ?
         jz        Int091                   ; nen¡ Ctrl

         mov       byte ptr cs:[AktAsk],1   ; p©¡znak po‘adavku funkce

         mov       byte ptr ds:[100h],1     ; p©¡znak obsluhy PRINT SCREEN

         pushf
         call      dword ptr cs:[Old09]
         jmp       short Int093

Int091:  pushf
         call      dword ptr cs:[old09]     ; obsluha INT 09h

         cmp       bx,ds:[1ch]              ; je nˆjak˜ znak ?
         je        Int095                   ; nen¡ ‘ dn  kl vesa

         cmp       byte ptr cs:[AktScr],0   ; je funkce aktivn¡ ?
         je        Int095                   ; funkce nen¡ aktivn¡

                                          ;* p©¡jem k¢du kl vesy
         mov       ax,ds:[bx]               ; p©ijat  kl vesa
         mov       cs:[Keys],ax             ; £schova k¢du kl vesy
Int093:  mov       ds:[1ch],bx              ; zru¨en¡ znaku z bufferu

Int095:  pop       ds
         pop       bx
         pop       ax

         iret

Int09    ENDP

; -----------------------------------------------------------------------------
;        Obsluha akce SCREEN
; -----------------------------------------------------------------------------

Screen0: ret

Screen:  cmp       byte ptr cs:[AktScr],0   ; prob¡h  ji‘ akce ?
         jne       Screen0                  ; akce ji‘ prob¡h 
         cmp       byte ptr cs:[AktAsk],0   ; po‘aduje se akce ?
         je        Screen0                  ; akce se nepo‘aduje

         push      ds
         push      bx
         lds       bx,cs:[Aktiv21]          ; adresa p©¡znaku aktivity DOS
         cmp       byte ptr ds:[bx],0       ; je DOS aktivn¡ ?
         pop       bx
         pop       ds
         jne       Screen0                  ; DOS je aktivn¡

                                          ;* akce se provede
         mov       byte ptr cs:[AktScr],1   ; p©¡znak aktivity akce SCREEN
         sti                                ; p©eru¨en¡ povoleno

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

                                          ;* ur‡en¡ segmentu videopamˆti a
                                          ;* test opr vnˆnosti videom¢du
         xor       ax,ax
         mov       ds,ax                    ; segment dat BIOS
         mov       si,ds:[44eh]             ; adresa displeje
         mov       al,ds:[449h]             ; aktivn¡ videom¢d
         and       al,7fh
         mov       bx,0a000h                ; jinak segment EGA
         cmp       al,13
         je        Screen1
         cmp       al,14
         je        Screen1
         cmp       al,16                    ; videom¢d
         je        Screen1                  ; videom¢d OK
         cmp       al,18
         je        Screen1
         jmp       Screen8                  ; neobsluhovan˜ videom¢d
Screen1: mov       es,bx                    ; segment videopamˆti

                                          ;* zvukov  singalizace
         mov       cx,10
Screen2: push      cx
         in        al,[61h]
         or        al,3
         out       [61h],al
         mov       cx,7000
         loop      $
         and       al,0fch
         out       [61h],al
         mov       cx,5000
Screen3: loop      $
         pop       cx
         loop      Screen2

                                          ;* nalezen¡ nepou‘it‚ho souboru
         push      cs
         pop       ds
         mov       bx,ds:[AdrSoub]
         mov       word ptr ds:[bx-1],"10"  ; inicializace ukazatele ‡¡sla soub.
Screen4: mov       dx,offset Soubor
         mov       ax,3d02h                 ; funkce otev©en¡ souboru
         int       21h                      ; pokus o otev©en¡ souboru
         jc        Screen5                  ; soubor asi neexistuje - OK
         mov       bx,ax
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
         call      ZvysSoub                 ; zv˜¨en¡ ‡¡sla souboru
         jmp       short Screen4            ; nov˜ pokus s dal¨¡m souborem

                                          ;* vytvo©en¡ nov‚ho souboru
Screen5: mov       ah,3ch
         xor       cx,cx                    ; atributy
         int       21h                      ; vytvo©en¡ nov‚ho souboru
         jc        Screen8                  ; chyba - soubor nelze vytvo©it
         mov       ds:[Idents],ax           ; £schova identifik toru souboru

                                          ;* nalezen¡ popisu videom¢du v tabulce
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bl,ds:[449h]             ; aktivn¡ videom¢d
         pop       ds
         mov       ds:[VMod],bl             ; aktivn¡ videom¢d
         mov       bh,0
         mov       bp,bx                    ; videom¢d
         shl       bp,1
         shl       bp,1                     ; videom¢d * 4
         add       bp,offset TabMod - 13*4

                                          ;* stanoven¡ parametr– podle tabulky
         mov       ax,ds:[bp]               ; maxim ln¡ ¨¡©ka
         mov       ds:[MaxSir],ax           ; maxim ln¡ ¨¡©ka
         mov       ax,ds:[bp+2]             ; maxim ln¡ v˜¨ka
         mov       ds:[MaxVys],ax           ; maxim ln¡ v˜¨ka

; ------ inicializace ukazatel– komprese

         mov       word ptr ds:[KompCit],0  ; ‡¡ta‡ komprese
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       byte ptr ds:[KompPar],1  ; nastaven¡ p©¡znaku komprese

                                          ;* funkce sn¡m n¡ obrazovky
         call      Anims                    ; sn¡m n¡ obrazovky
         jc        Screen9                  ; p©eru¨en¡ operace

; ------ vypr zdnˆn¡ buffer–

         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         jc        Screen6                  ; chyba z pisu na disk
         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         jc        Screen6                  ; chyba z pisu na disk
         call      WritBuff                 ; z pis bufferu na disk

Screen6: mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor v˜stupn¡ho souboru
         int       21h                      ; uzav©en¡ souboru
         jmp       short Screen8

Screen9: mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor v˜stupn¡ho souboru
         int       21h                      ; uzav©en¡ souboru

         mov       dx,offset Soubor
         mov       ah,41h                   ; funkce zru¨en¡ souboru
         int       21h                      ; zru¨en¡ soubor p©i chybˆ

Screen8: cli
         mov       ax,40h
         mov       ds,ax
         mov       byte ptr ds:[100h],0     ; zru¨en¡ p©¡znaku PRINT SCREEN

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

         cli                                ; opˆt z kaz p©eru¨en¡

         mov       byte ptr cs:[AktScr],0   ; zru¨en¡ p©¡znaku aktivity SCREEN
         mov       byte ptr cs:[AktAsk],0   ; zru¨en¡ po‘adavku na funkci

         ret

; -----------------------------------------------------------------------------
;        Zv˜¨en¡ ‡¡sla souboru
; -----------------------------------------------------------------------------

ZvysSoub:push      si
         mov       si,ds:[AdrSoub]
ZvysSou1:inc       byte ptr ds:[si]
         cmp       byte ptr ds:[si],"9"+1
         jne       ZvysSou2
         mov       byte ptr ds:[si],"0"
         dec       si
         jmp       short ZvysSou1
ZvysSou2:pop       si
         ret

; -----------------------------------------------------------------------------
;        z pis bajtu do souboru s kompres¡ (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------
; Syntaxe komprese:
;    bajt - po‡et n sleduj¡c¡ch bajt– dat 0 a‘ 255 (0=pouze p©ep¡na‡ m¢du)
;         - kromˆ bajtu 255 se p©epne p©¡znak komprese/data
;    za bajtem n sleduje buƒ bajt, kter˜ se m  opakovat, nebo data o dan‚m po‡tu
;    Na za‡ tku souboru je nastaven p©¡znak komprese, prvn¡ bajt r–zn˜
;    od 255 tedy ud v  po‡et n sleduj¡c¡ch dat v bˆ‘n‚m m¢du
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

; ------ test, zda je bajt shodn˜ s bajtem v ‡¡ta‡i shody

         cmp       al,ds:[KompChar]         ; je bajt shodn˜ ?
         je        WritB4                   ; bajt je shodn˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         jc        WritB9                   ; chyba v˜stupu do souboru

; ------ ulo‘en¡ bajtu do bufferu shody

WritB4:  mov       ds:[KompChar],al         ; ulo‘en¡ shodn‚ho znaku
         inc       byte ptr ds:[KompCit]    ; zv˜¨en¡ ‡¡ta‡e shodn˜ch znak–

; ------ je-li 255 stejn˜ch znak–, vypr zdnˆn¡ bufferu shody

         cmp       byte ptr ds:[KompCit],255; je buffer ji‘ pln˜ ?
         clc                                ; p©¡znak operace OK
         jne       WritB9                   ; buffer je¨tˆ nen¡ pln˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
WritB9:  ret

WritB    ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu shody (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushQ   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ test, zda jsou nˆjak  data v bufferu opakov n¡

         mov       cx,ds:[KompCit]          ; po‡et shodn˜ch bajt–
         jcxz      FlushQ8                  ; v bufferu nic nen¡

; ------ kontrola, zda je dostate‡n˜ po‡et opakovan˜ch bajt–

         cmp       cl,3                     ; dostate‡n˜ po‡et bajt– ?
         jb        FlushQ5                  ; je mal˜ po‡et bajt–

; ------ je dostate‡n˜ po‡et bajt– - vypr zdnˆn¡ bˆ‘n‚ho bufferu

         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         jc        FlushQ9                  ; chyba v˜stupu do souboru

; ------ p©¡padn‚ p©epnut¡ do kompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         jne       FlushQ3                  ; je kompresn¡ m¢d - OK
         mov       al,0                     ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do kompresn¡ho m¢du
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         inc       byte ptr ds:[KompPar]    ; p©¡znak kompresn¡ho m¢du

; ------ z pis bajtu d‚lky a opakovan‚ho bajtu

FlushQ3: mov       al,cl                    ; po‡et opakov n¡ bajtu
         call      WritB0                   ; z pis po‡tu bajt–
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         mov       al,ds:[KompChar]         ; opakovan˜ znak
         call      WritB0                   ; z pis opakovan‚ho bajtu
         jc        FlushQ9                  ; chyba v˜stupu do souboru

; ------ nastaven¡ p©¡znaku m¢du komprese

         inc       cl                       ; je 255 znak– ?
         je        FlushQ7                  ; je 255 znak– - m¢d se nep©epne
         dec       byte ptr ds:[KompPar]    ; p©¡znak nekompresn¡ho m¢du
         jmp       short FlushQ7

; ------ mal˜ po‡et bajt– - vypr zdnˆn¡ p©es bˆ‘n˜ buffer

FlushQ5: mov       al,ds:[KompChar]         ; shodn˜ znak
FlushQ6: call      StorBuf                  ; ulo‘en¡ do bˆ‘n‚ho bufferu
         jc        FlushQ9                  ; chyba v˜stupu do souboru
         loop      FlushQ6                  ; ulo‘en¡ dal¨¡ho bajtu

; ------ nulov n¡ bufferu shody

FlushQ7: mov       byte ptr ds:[KompCit],0  ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
FlushQ8: clc                                ; p©¡znak operace OK

; ------ n vrat registr–

FlushQ9: pop       cx
         pop       ax
         ret

FlushQ   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bajtu AL do bˆ‘n‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

StorBuf  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ ulo‘en¡ bajtu do bufferu

         mov       bx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         mov       ds:[bx+KompBuff],al      ; ulo‘en¡ bajtu do bufferu
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       ds:[KompBNum],bx         ; nov˜ po‡et bajt– v bufferu

; ------ p©i zaplnˆn¡ bufferu jeho vypr zdnˆn¡

         cmp       bl,255                   ; je buffer ji‘ pln˜ ?
         clc                                ; p©¡znak operace OK
         jne       StorBuf2                 ; buffer je¨tˆ nen¡ pln˜
         call      FlushB                   ; vypr zdnˆn¡ bufferu

; ------ n vrat registr–

StorBuf2:pop       bx
         ret

StorBuf  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bˆ‘n‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

FlushB   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ kontrola, zda v bufferu nˆco je

         clc                                ; p©¡znak operace OK
         mov       cx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         jcxz      FlushB9                  ; v bufferu nic nen¡

; ------ p©¡padn‚ p©epnut¡ do nekompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         je        FlushB3                  ; nen¡ kompresn¡ m¢d - OK
         mov       al,0                     ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do norm ln¡ho m¢du
         jc        FlushB9                  ; chyba z pisu
         dec       byte ptr ds:[KompPar]    ; p©¡znak bˆ‘n‚ho m¢du

; ------ vysl n¡ bajtu d‚lky ©etˆzce

FlushB3: mov       al,cl                    ; po‡et n sleduj¡c¡ch bajt– textu
         call      WritB0                   ; vysl n¡ bajtu d‚lky
         jc        FlushB9                  ; chyba z pisu

; ------ nastaven¡ p©¡znaku p©epnut¡ m¢du

         cmp       al,255                   ; je 255 bajt– ?
         je        FlushB4                  ; je 255 znak– - m¢d se nep©epne
         inc       byte ptr ds:[KompPar]    ; jinak p©¡znak kompresn¡ho m¢du

; ------ vysl n¡ bufferu dat

FlushB4: mov        si,offset KompBuff      ; buffer s daty
FlushB5: cld
         lodsb                              ; bajt dat k vysl n¡
         call      WritB0                   ; vysl n¡ bajtu
         jc        FlushB9                  ; chyba z pisu
         loop      FlushB5                  ; vysl n¡ dal¨¡ho bajtu
         mov       byte ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu

; ------ n vrat registr–

FlushB9: pop       si
         pop       cx
         pop       ax
         ret

FlushB   ENDP

; -----------------------------------------------------------------------------
;        Z pis bajtu do diskov‚ho bufferu (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

WritB0   PROC      NEAR

; ------ vypr zdnˆn¡ bufferu, pokud je ji‘ zaplnˆn

         cmp       word ptr ds:[NumBuff],BufSize ; buffer je ji‘ zaplnˆn ?
         jb        WritB2                   ; buffer je¨tˆ nen¡ zaplnˆn
         call      WritBuff                 ; z pis bufferu na disk
         jc        WritB3                   ; byla chyba z pisu

; ------ ulo‘en¡ bajtu do bufferu

WritB2:  push      si
         mov       si,ds:[NumBuff]          ; po‡et bajt– v bufferu
         mov       ds:[si+Buffer],al        ; z pis nov‚ho bajtu do bufferu
         inc       si                       ; zv˜¨en¡ ‡¡ta‡e bajt–
         mov       ds:[NumBuff],si          ; nov˜ stav ‡¡ta‡e bajt– v bufferu
         pop       si
         clc                                ; p©¡znak operace OK
WritB3:  ret

WritB0   ENDP

; -----------------------------------------------------------------------------
;        Z pis diskov‚ho bufferu do souboru (DS=datov˜ segment, CY=chyba)
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx

; ------ z pis obsahu bufferu do souboru

         clc                                ; p©ednastaven¡ p©¡znaku OK
         mov       cx,ds:[NumBuff]          ; po‡et bajt– v diskov‚m bufferu
         jcxz      WritBff2                 ; nen¡ ‘ dn˜ bajt k z pisu
         mov       ah,40h                   ; funkce z pisu
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       dx,offset Buffer         ; diskov˜ buffer
         int       21h                      ; z pis souboru
         mov       word ptr ds:[NumBuff],0  ; vynulov n¡ bufferu
         jc        WritBff2                 ; byla chyba
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?

; ------ n vrat registr–

WritBff2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; -----------------------------------------------------------------------------
;        Vlastn¡ funkce sn¡m n¡ obsahu obrazovky
; -----------------------------------------------------------------------------

Anims:   mov       ax,ds:[X2]               ; koncov  pozice X
         inc       ax
         sub       ax,ds:[MaxSir]           ; p©esah
         jbe       Anims12                  ; OK
         sub       ds:[X2],ax               ; oprava sou©adnice X
         sub       ds:[X1],ax

Anims12: mov       ax,ds:[Y2]               ; koncov  linka Y
         inc       ax
         sub       ax,ds:[MaxVys]           ; p©esah
         jbe       Anims14                  ; OK
         sub       ds:[Y2],ax               ; oprava Y
         sub       ds:[Y1],ax

Anims14:

         call      Edit                     ; editace kurzoru
         jc        Anims9                   ; p©eru¨en¡ operace

         call      WritHl                   ; z pis z hlav¡ souboru
         jc        Anims9                   ; chyba z pisu

         xor       ax,ax                    ; po‡ te‡n¡ rovina k z pisu
         mov       bx,ds:[X1]               ; po‡ te‡n¡ pozice
         mov       cx,ds:[X2]               ; koncov  pozice
         sub       cx,bx                    ; ¨¡©ka - 1
         inc       cx                       ; ¨¡©ka okna
Anims1:  mov       dx,ds:[Y1]               ; po‡ te‡n¡ © dek
Anims2:  call      ReadEGA                  ; z pis © dku okna
         inc       dx                       ; zv˜¨en¡ © dku
         cmp       dx,ds:[Y2]               ; dosa‘eno posledn¡ho © dku ?
         jbe       Anims2                   ; nen¡ p©ekro‡en posledn¡ © dek
         inc       ax                       ; zv˜¨en¡ ‡¡sla roviny
         cmp       al,4                     ; jsou ji‘ v¨echny roviny ?
         jb        Anims1                   ; nejsou je¨tˆ v¨echny roviny
         clc
Anims9:  ret

; -----------------------------------------------------------------------------
;        Editace kurzoru (ES:SI=adresa videopamˆti)
; -----------------------------------------------------------------------------

Edit:
         call      Kurzor                   ; zapnut¡ kurzoru

Edit1:   push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       bx,ds:[46ch]             ; sou‡asn˜ stav ‡asova‡e
         mov       byte ptr cs:[Citac],15   ; kurzor zapnut

Edit11:  cmp       ds:[46ch],bx             ; je zmˆna hodin ?
         je        Edit12                   ; nen¡ zmˆna hodin
         mov       bx,ds:[46ch]             ; nov  hodnota hodin
         dec       byte ptr cs:[Citac]      ; sn¡‘en¡ ‡¡ta‡e hodin
         jnz       Edit12                   ; nen¡ je¨tˆ pln˜ ‡as
         call      Kurzor                   ; inverze kurzoru
         mov       byte ptr cs:[Citac],15   ; ‡as pro zapnut˜ kurzor
         cmp       byte ptr cs:[AktKur],0   ; je kurzor aktivn¡ ?
         jne       Edit12                   ; kurzor je aktivn¡
         mov       byte ptr cs:[Citac],4    ; doba pro vypnut¡
Edit12:  xor       ax,ax
         xchg      ax,cs:[Keys]             ; vyjmut¡ znaku z bufferu
         or        ax,ax                    ; byl nˆjak˜ znak ?
         jz        Edit11                   ; nebyl ‘ dn˜ znak

         cmp       byte ptr cs:[AktKur],0   ; je kurzor aktivn¡ ?
         jne       Edit13                   ; kurzor je aktivn¡
         call      Kurzor                   ; zapnut¡ kurzoru
Edit13:  pop       ds


                                          ;* rozli¨en¡ ukon‡en¡ editace
         cmp       al,13                    ; je Enter ?
         je        Edit9                    ; © dn‚ ukon‡en¡ editace
         cmp       al,27                    ; p©eru¨en¡ ESC ?
         stc                                ; p©¡znak p©eru¨en¡ editace Esc
         je        Edit9                    ; p©eru¨en¡ editace ESC

                                          ;* vyvol n¡ funkce podle kl vesy
         cmp       al,9
         je        Edit34
         mov       al,0
Edit34:  mov       bx,offset TabKey         ; tabulka kl ves pro editaci
         mov       cx,offset(TabKey0-TabKey)/6 ; po‡et kl ves v tabulce
Edit3:   cmp       ax,ds:[bx]               ; je to hledan  kl vesa ?
         je        Edit4                    ; kl vesa nalezena
         add       bx,6                     ; adresa dal¨¡ kl vesy
         loop      Edit3                    ; test dal¨¡ kl vesy v tabulce
Edit16:  jmp       short Edit1              ; vstup dal¨¡ kl vesy

Edit4:   mov       cx,ds:[bx+2]             ; posun kurzoru
         call      word ptr ds:[bx+4]       ; vyvol n¡ obsluhy kl vesy
         jmp       short Edit16             ; vstup dal¨¡ kl vesy

Edit9:   call      Kurzor                   ; vypnut¡ kurzoru
         ret

; -----------------------------------------------------------------------------

TabKey   label     word                   ;* tabulka obsluh funkc¡ editoru

                                          ;* posuny kurzoru
         dw        4b00h,1,offset EdLeft      ; LEFT - kurzor 1 pozici vlevo
         dw        4d00h,1,offset EdRight     ; RIGHT - kurzor 1 pozici vpravo
         dw        4800h,1,offset EdUp        ; UP - kurzor 1 pozici nahoru
         dw        5000h,1,offset EdDown      ; DOWN - kurzor 1 pozici dol–
         dw        7300h,8,offset EdLeft      ; ^LEFT - kurzor 10 znak– vlevo
         dw        7400h,8,offset EdRight     ; ^RIGHT - kurzor 10 znak– vpravo
         dw        8d00h,8,offset EdUp        ; ^UP - kurzor 10 linek nahoru
         dw        9100h,8,offset EdDown      ; ^DOWN -kurzor 10 linek dol–
         dw        0f00h,48,offset EdLeft     ; STAB - kurzor 50 pozic vlevo
         dw        0f09h,48,offset EdRight    ; TAB - kurzor 50 pozic vpravo
         dw        4900h,48,offset EdUp       ; PAGEUP - kurzor 50 linek nahoru
         dw        5100h,48,offset EdDown     ; PAGEDOWN - kurzor 50 linek dol–
         dw        4700h,-2,offset EdLeft     ; HOME - kurzor k lev‚mu okraji
         dw        4f00h,-2,offset EdRight    ; END - kurzor k prav‚mu okraji
         dw        7700h,-2,offset EdUp       ; ^HOME - kurzor k horn¡mu okraji
         dw        7500h,-2,offset EdDown     ; ^END - kurzor k spodn¡mu okraji
         dw        8400h,-2,offset EdUp       ; ^PAGEUP - k horn¡mu okraji
         dw        7600h,-2,offset EdDown     ; ^PAGEDOWN - k spodn¡mu okraji

TabKey0  label     word
; -----------------------------------------------------------------------------
                                          ;* kurzor vlevo
EdLeft:  cmp       word ptr ds:[X1],0       ; je ji‘ lev˜ okraj ?
         je        EdLeft2                  ; je ji‘ lev˜ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       cx,ds:[X1]               ; je m‚nˆ pozic ne‘ CX ?
         jbe       EdLeft1                  ; nen¡ m‚nˆ pozic ne‘ CX
         mov       cx,ds:[X1]               ; omezen˜ po‡et pozic
EdLeft1: sub       word ptr ds:[X1],cx      ; posun vlevo
         sub       word ptr ds:[X2],cx      ; posun i prav‚ho okraje
         call      Kurzor                   ; zapnut¡ kurzoru
EdLeft2: ret
; -----------------------------------------------------------------------------
                                          ;* kurzor vpravo
EdRight: mov       ax,ds:[MaxSir]           ; maxim ln¡ prav˜ okraj
         dec       ax                       ; maxim ln¡ prav‚ pozice
         sub       ax,ds:[X2]               ; zbyl˜ po‡et pozic
         jz        EdRight2                 ; nen¡ ‘ dn  dal¨¡ pozice
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je vˆt¨¡ rozd¡l ne‘ CX ?
         jbe       EdRight1                 ; nen¡ vˆt¨¡ rozd¡l ne‘ CX
         mov       ax,cx                    ; omezen¡ na CX pozic
EdRight1:add       ds:[X2],ax               ; zv˜¨en¡ prav‚ho okraje
         add       ds:[X1],ax               ; zv˜¨en¡ lev‚ho okraje
         call      Kurzor                   ; zapnut¡ kurzoru
EdRight2:ret
; -----------------------------------------------------------------------------
                                          ;* kurzor nahoru
EdUp:    cmp       word ptr ds:[Y1],0       ; je ji‘ horn¡ okraj ?
         je        EdUp2                    ; je ji‘ horn¡ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       cx,ds:[Y1]               ; je m‚nˆ pozic ne‘ CX ?
         jbe       EdUp1                    ; nen¡ m‚nˆ pozic ne‘ CX
         mov       cx,ds:[Y1]               ; omezen˜ po‡et pozic
EdUp1:   sub       word ptr ds:[Y1],cx      ; posun nahoru
         sub       word ptr ds:[Y2],cx      ; posun i spodn¡ho okraje
         call      Kurzor                   ; zapnut¡ kurzoru
EdUp2:   ret
; -----------------------------------------------------------------------------
                                          ;* kurzor dol–
EdDown:  mov       ax,ds:[MaxVys]           ; maxim ln¡ spodn¡ okraj
         dec       ax                       ; maxim ln¡ spodn¡ pozice
         sub       ax,ds:[Y2]               ; zbyl˜ po‡et pozic
         jz        EdDown2                  ; nen¡ ‘ dn  dal¨¡ pozice
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je vˆt¨¡ rozd¡l ne‘ CX ?
         jbe       EdDown1                  ; nen¡ vˆt¨¡ rozd¡l ne‘ CX
         mov       ax,cx                    ; omezen¡ na CX pozic
EdDown1: add       ds:[Y2],ax               ; posun spodn¡ho okraje
         add       ds:[Y1],ax               ; posun horn¡ho okraje
         call      Kurzor                   ; zapnut¡ kurzoru
EdDown2: ret

; -----------------------------------------------------------------------------
;        Z pis hlavi‡ky souboru
; -----------------------------------------------------------------------------

WritHl:  push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,offset Zahlavi        ; z hlav¡ souboru
         mov       cx,offset(KonHl-Zahlavi) ; d‚lka z hlav¡ souboru
         mov       bx,ds:[Idents]           ; identifik tor souboru
         mov       ah,40h                   ; funkce z pisu do souboru
         int       21h                      ; z pis z hlav¡ do souboru

         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        Zobrazen¡ kurzoru (ES:SI=adresa videopamˆti)
; -----------------------------------------------------------------------------

Kurzor:  pushf
         push      ax
         push      bx
         push      cx
         push      dx
         push      ds
         push      cs
         pop       ds

         xor       byte ptr ds:[AktKur],1   ; zmˆna p©¡znaku aktivity kurzoru

                                          ;* horn¡ linka
         mov       bx,ds:[X1]               ; lev  pozice
         mov       dx,ds:[Y1]               ; horn¡ © dek
         mov       cx,ds:[X2]               ; prav  pozice
         sub       cx,bx                    ; d‚lka horn¡ linky - 1
         inc       cx                       ; d‚lka horn¡ linky
         call      InvEGAH                  ; zobrazen¡ horn¡ linky

                                          ;* lev˜ okraj
         mov       cx,ds:[Y2]               ; spodn¡ okraj
         sub       cx,dx                    ; d‚lka lev‚ho okraje - 1
         inc       dx                       ; a‘ 2. © dek
         call      InvEGAV                  ; zobrazen¡ lev‚ho okraje

                                          ;* prav˜ okraj
         mov       bx,ds:[X2]               ; prav  pozice
         cmp       bx,ds:[X1]               ; je shodn˜ s lev˜m okrajem ?
         je        Kurzor1                  ; je shodn˜ s lev˜m okrajem
         call      InvEGAV                  ; zobrazen¡ prav‚ho okraje

                                          ;* spodn¡ okraj
         mov       dx,ds:[Y2]               ; spodn¡ okraj
         cmp       dx,ds:[Y1]               ; spl˜v  s horn¡m okrajem ?
         je        Kurzor1                  ; spl˜v  s horn¡m okrajem - nic
         mov       bx,ds:[X1]               ; lev˜ okraj
         inc       bx
         mov       cx,ds:[X2]               ; prav˜ okraj
         sub       cx,bx                    ; ¨¡©ka - 1
         call      InvEGAH                  ; zobrazen¡ spodn¡ho okraje

Kurzor1: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret

; -----------------------------------------------------------------------------
;            Inverze bajtu kurzoru m¢du EGA horizont lnˆ
;          (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

InvEGAH: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cli                                ; z kaz p©eru¨en¡
         push      dx
                                          ;* volba z pisov˜ch rovin
         mov       dx,03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al

                                          ;* nastaven¡ z pisov‚ho m¢du 2
         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du ‡ten¡ a z pisu
         inc       dx
         mov       al,2
         out       dx,al                    ; z pisov˜ m¢d 2
         dec       dx

                                          ;* nastaven¡ re‘imu XOR
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,18h
         out       dx,al                    ; nastaven¡ re‘imu XOR
         dec       dx

                                          ;* volba rovin pro z pis
         mov       al,0
         out       dx,al                    ; registr 0
         inc       dx
         mov       al,0ffh                  ; v¨echny roviny
         out       dx,al                    ; volba rovin pro z pis
         dec       dx

                                         ;* volba rovin pro XOR
         mov       al,1
         out       dx,al                    ; registr 1
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; v¨echny roviny XOR

         pop       dx
         sti                                ; povolen¡ p©eru¨en¡

                                          ;* bitov  pozice v bajtu
         mov       di,bx                    ; pozice
         and       di,7                     ; bitov  pozice v bajtu
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty

                                          ;* v˜po‡et adresy linky ve VRAM
         mov       ax,80                    ; po‡et bajt– na © dek
         cmp       byte ptr ds:[Vmod],13    ; videom¢d 13 ?
         jne       InvEGAH0                 ; nen¡ 13
         mov       al,40                    ; 40 bajt– na © dek
InvEGAH0:mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; p©i‡ten¡ adresy linky
         add       si,bx                    ; p©i‡ten¡ pozic

                                          ;* bitov  maska pro z pis
         mov       dx,03ceh
         mov       al,8
         out       dx,al                    ; registr masky rovin
         inc       dx

         push      cx
         mov       cx,di                    ; bitov  pozice
         mov       al,0ffh                  ; maska
         shr       al,cl                    ; rotace masky na pozici
         pop       cx
         out       dx,al                    ; maska pro z pis

                                          ;* zobrazen¡ ‡ sti z prvn¡ho bajtu
         jcxz      InvEGAH5                 ; nen¡ ‘ dn˜ bod

         mov       al,0ffh
         xchg      al,es:[si]               ; inverze prvn¡ho bajtu kurzoru
         mov       al,0ffh
         out       dx,al                    ; v¨echny bity

         add       cx,di                    ; p©i‡ten¡ prvn¡ osmice
         sub       cx,8                     ; ode‡ten¡ bit– z prvn¡ho bajtu
         jc        InvEGAH2                 ; nen¡ dal¨¡ bajt

         inc       si                       ; zv˜¨en¡ adresy

                                          ;* zobrazen¡ vnit©n¡ch bajt– kurzoru
InvEGAH1:mov       al,0ffh                  ; maska
         xchg      al,es:[si]               ; inverze bit– v bajtu
         sub       cx,8                     ; ode‡ten¡ osmice bit–
         jc        InvEGAH2                 ; je ji‘ p©ete‡en¡
         inc       si                       ; adresa dal¨¡ho znaku
         jmp       short InvEGAH1           ; je dal¨¡ bajt

                                          ;* vymaz n¡ p©ebyte‡n˜ch bit–
InvEGAH2:add       cx,8                     ; n vrat po‡tu zbyl˜ch bit–
         mov       al,0ffh                  ; maska
         shr       al,cl                    ; rotace masky na pozici
         out       dx,al
         mov       al,0ffh
         xchg      al,es:[si]
         mov       al,0ffh
         out       dx,al

InvEGAH5:
         cli                                ; z kaz p©eru¨en¡

                                          ;* nastaven¡ z pisov‚ho m¢du
         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du ‡ten¡ a z pisu
         inc       dx
         mov       al,0
         cmp       byte ptr ds:[Vmod],15
         jne       InvEGAH3
         add       al,10h
InvEGAH3:out       dx,al                    ; z pisov˜ m¢d 0
         dec       dx

                                          ;* nastaven¡ norm ln¡ho re‘imu
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; nastaven¡ norm ln¡ho re‘imu
         dec       dx

                                         ;* volba rovin pro XOR
         mov       al,1
         out       dx,al                    ; registr 1
         inc       dx
         mov       al,0
         out       dx,al                    ; ‘ dn  rovina XOR
         dec       dx

         sti                                ; povolen¡ p©eru¨en¡

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;             Inverze bajtu kurzoru m¢du EGA vertik lnˆ
;          (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

InvEGAV: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         cli                                ; z kaz p©eru¨en¡
         push      dx
                                          ;* volba z pisov˜ch rovin
         mov       dx,03c4h
         mov       al,2
         out       dx,al
         inc       dx
         mov       al,0ffh
         out       dx,al

                                          ;* nastaven¡ z pisov‚ho m¢du 2
         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du ‡ten¡ a z pisu
         inc       dx
         mov       al,2
         out       dx,al                    ; z pisov˜ m¢d 2
         dec       dx

                                          ;* nastaven¡ re‘imu XOR
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,18h
         out       dx,al                    ; nastaven¡ re‘imu XOR
         dec       dx

                                          ;* volba rovin pro z pis
         mov       al,0
         out       dx,al                    ; registr 0
         inc       dx
         mov       al,0ffh                  ; v¨echny roviny
         out       dx,al                    ; volba rovin pro z pis
         dec       dx

                                         ;* volba rovin pro XOR
         mov       al,1
         out       dx,al                    ; registr 1
         inc       dx
         mov       al,0ffh
         out       dx,al                    ; v¨echny roviny XOR
         dec       dx

         mov       al,8
         out       dx,al                    ; volba registru 8
         inc       dx

         push      cx
         mov       cl,bl
         and       cl,7                     ; bitov  pozice
         mov       al,80h
         shr       al,cl
         pop       cx
         out       dx,al                    ; nastaven¡ bitov‚ masky

         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty

         pop       dx
         sti                                ; povolen¡ p©eru¨en¡

         jcxz      InvEGAV5                 ; nen¡ ‘ dn  linka


                                          ;* v˜po‡et adresy linky ve VRAM
         mov       ax,80                    ; po‡et bajt– na © dek
         cmp       byte ptr ds:[Vmod],13    ; videom¢d 13 ?
         jne       InvEGAV0                 ; nen¡ 13
         mov       al,40                    ; 40 bajt– na © dek
InvEGAV0:mov       di,ax                    ; p©¡rustek adresy
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; p©i‡ten¡ adresy linky
         add       si,bx                    ; p©i‡ten¡ pozic

                                          ;* zobrazen¡ kurzoru
InvEGAV1:mov       al,0ffh                  ; maska
         xchg      al,es:[si]               ; inverze bit– v bajtu
         add       si,di                    ; adresa dal¨¡ho znaku
         loop      InvEGAV1                 ; dal¨¡ linka

InvEGAV5:
         cli                                ; z kaz p©eru¨en¡

                                          ;* nastaven¡ z pisov‚ho m¢du
         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du ‡ten¡ a z pisu
         inc       dx
         mov       al,0
         cmp       byte ptr ds:[Vmod],15
         jne       InvEGAV3
         add       al,10h
InvEGAV3:out       dx,al                    ; z pisov˜ m¢d 0
         dec       dx

                                          ;* nastaven¡ norm ln¡ho re‘imu
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al                    ; nastaven¡ norm ln¡ho re‘imu
         dec       dx

                                         ;* volba rovin pro XOR
         mov       al,1
         out       dx,al                    ; registr 1
         inc       dx
         mov       al,0
         out       dx,al                    ; ‘ dn  rovina XOR
         dec       dx

         sti                                ; povolen¡ p©eru¨en¡

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        €ten¡ skupiny bajt– z videopamˆti EGA do v˜stupn¡ho bufferu
;   (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–, AX=rovina)
; -----------------------------------------------------------------------------

ReadEGA:

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         jcxz      ReadEGA6                 ; nen¡ ‘ dn˜ znak

         mov       di,ax                    ; rovina

                                          ;* nastaven¡ ‡tec¡ho m¢du
         push      dx

         mov       dx,03ceh
         mov       al,5
         out       dx,al                    ; registr m¢du
         inc       dx
         mov       al,0
         out       dx,al                    ; m¢d ‡ten¡ 0
         dec       dx

                                          ;* nastaven¡ ‡tec¡ roviny
         mov       al,4
         out       dx,al                    ; registr ‡tec¡ mapy
         inc       dx
         mov       ax,di                    ; rovina ke ‡ten¡
         out       dx,al

         pop       dx


                                          ;* stanoven¡ bitov‚ pozice
         mov       di,bx                    ; po‡ te‡n¡ bod
         and       di,7                     ; offset po‡ te‡n¡ho bodu
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty

                                          ;* v˜po‡et adresy linky ve VRAM
         mov       ax,80                    ; po‡et bajt– na © dek
         cmp       byte ptr ds:[Vmod],13     ; videom¢d 13 ?
         jne       ReadEGA1                 ; nen¡ 13
         mov       al,40                    ; 40 bajt– na © dek
ReadEGA1:mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; adresa ve videopamˆti
         add       si,bx                    ; p©i‡ten¡ pozic

                                          ;* ‡ten¡ jednotliv˜ch bajt–
ReadEGA2:mov       ax,es:[si]               ; slovo z po‘adovan‚ roviny
         xchg      ah,al

         push      cx
         mov       cx,di
         shl       ax,cl
         pop       cx
         mov       al,ah

         sub       cx,8
         jc        ReadEGA3

         call      WritB                    ; z pis bajtu do bufferu
         inc       si                       ; adresa dal¨¡ho bajtu
         jmp       short ReadEGA2

ReadEGA3:add       cl,8
         jz        ReadEGA6
         mov       ah,0ffh
         shr       ah,cl
         not       ah
         and       al,ah                    ; maskov n¡ posledn¡ho bajtu

         call      WritB                    ; z pis posledn¡ho bajtu

ReadEGA6:
         mov       dx,3ceh
         mov       al,1
         out       dx,al
         inc       dx
         mov       al,0
         out       dx,al

         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------

TabMod   label     word                   ;* tabulka videom¢d–
         dw        320,200                  ; 13: 320x200/16 graf
         dw        640,200                  ; 14: 640x200/16 graf
         dw        0,0                      ; 15: 640x350/2 graf
         dw        640,350                  ; 16: 640x350/16 graf
         dw        0,0                      ; 17: 640x480/2 graf
         dw        640,480                  ; 18: 640x480/16 graf

         EVEN                               ; zaokrouhlen¡ na sudou adresu

buffer   label     byte                     ; diskov˜ buffer

; *****************************************************************************
;
;                         Instalace programu
;
; *****************************************************************************
;þ
Instal:
                                          ;* zobrazen¡ £vodn¡ho textu
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

Inst1:   cli
                                          ;* instalace p©eru¨en¡ INT 08h
         mov       ax,3508h                 ; funkce poskytnut¡ adresy INT 08h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr [old08],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old08+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int08          ; vlastn¡ obsluha INT 08h
         mov       ax,2508h                 ; funkce nastaven¡ adresy INT 08h
         int       21h                      ; nastaven¡ adresy INT 08h

                                          ;* instalace p©eru¨en¡ INT 09h
         mov       ax,3509h                 ; funkce poskytnut¡ adresy INT 09h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr [old09],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old09+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int09          ; vlastn¡ obsluha INT 09h
         mov       ax,2509h                 ; funkce nastaven¡ adresy INT 09h
         int       21h                      ; nastaven¡ adresy INT 09h

                                          ;* instalace p©eru¨en¡ INT 28h
         mov       ax,3528h                 ; funkce poskytnut¡ adresy INT 28h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr [old28],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old28+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int28          ; vlastn¡ obsluha INT 28h
         mov       ax,2528h                 ; funkce nastaven¡ adresy INT 28h
         int       21h                      ; nastaven¡ adresy INT 28h

                                          ;* instalace p©¡znaku aktivity DOS
         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       word ptr [aktiv21],bx    ; adresa p©¡znaku aktivity DOS
         mov       word ptr [aktiv21+2],es  ; segment p©¡znaku aktivity DOS

         sti                                ; povolen¡ p©eru¨en¡

         push      cs
         pop       es

                                          ;* £schova aktivn¡ho adres ©e a disku
         mov       ah,19h                   ; funkce poskytnut¡ disku
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         add       byte ptr ds:[Soubor],al  ; ozna‡en¡ aktivn¡ho disku
         mov       ah,47h                   ; funkce poskytnut¡ adres ©e
         mov       dl,0                     ; aktivn¡ disk
         mov       si,offset Soubor + 3     ; buffer k na‡ten¡ adres ©e
         int       21h                      ; poskytnut¡ aktivn¡ho adres ©e
         dec       si
Inst3:   inc       si                       ; zv˜¨en¡ ukazatele adres ©e
         cmp       byte ptr ds:[si],0       ; je konec jm‚na adres ©e ?
         jne       Inst3                    ; nalezen¡ konce adres ©e
         cmp       byte ptr ds:[si-1],"\"   ; je to z kladn¡ adres © ?
         je        Inst4                    ; je to z kladn¡ adres ©
         mov       byte ptr ds:[si],"\"     ; ozna‡en¡ konce adres ©e
         inc       si                       ; p©esko‡en¡ znaku "\"
Inst4:   mov       di,si                    ; adresa k ulo‘en¡ jm‚na souboru
         mov       si,offset Soubor0        ; jm‚no souboru
         mov       cx,offset(Soubor1-Soubor0)
         cld
         rep       movsb                    ; p©enos jm‚na souboru
         sub       di,6                     ; adresa konce ‡¡sla
         mov       ds:[AdrSoub],di          ; adresa ‡¡sla souboru

         mov       dx,offset(Instal+BufSize) ; konec programu
         int       27h                      ; instalace jako rezidentn¡

Soubor0  db        'GMENU_01.PIC',0         ; jm‚no souboru
Soubor1  label     byte

UvTxt    db        'GMENUPIC V1.0 - snimani obrazku ikon; (c) Miroslav Nemecek',13,10
         db        '   <Ctrl>-<Print Screen> = ulozeni obrazku ikony',13,10
         db        '$'

Code     ENDS
         END       start                    ; startovac¡ adresa

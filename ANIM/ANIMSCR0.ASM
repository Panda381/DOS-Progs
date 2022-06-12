
; *****************************************************************************
;
;                              A N I M S C R
;
;                            Sn¡m n¡ obrazovky
;
; *****************************************************************************

BufSize  equ       1000h                    ; velikost diskov‚ho bufferu

code     SEGMENT
         ASSUME    cs:code,ds:code
         org       100h

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
Sirka    dw        0                        ; ¨¡©ka v˜©ezu (pozic)
Vyska    dw        0                        ; v˜¨ka v˜©ezu (linek)
Rovin    dw        0                        ; po‡et barevn˜ch rovin
Pozadi   dw        0                        ; barva pozad¡
Palet    dw        0                        ; po‡et bajt– palet
VMod     db        0                        ; videom¢d displeje
Param    db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo‘en¡ barev
                                            ;  bit 3: 1=obsahuje masku
KonHl    label     byte                     ; konec z hlav¡
; -----------------------------------------------------------------------------
MaxSir   dw        0                        ; maxim ln¡ ¨¡©ka (znak–)
MaxVys   dw        0                        ; maxim ln¡ v˜¨ka (linek)

                                          ;* definice kurzoru
X1       dw        0                        ; lev  pozice kurzoru
X2       dw        0ffffh                   ; prav  pozice kurzoru
Y1       dw        0                        ; horn¡ © dek kurzoru
Y2       dw        0ffffh                   ; doln¡ © dek kurzoru

; -----------------------------------------------------------------------------

ParEGA   db        0                        ; p©¡znak videokarty EGA/VGA

NumBuff  dw        0                        ; po‡et bajt– v diskov‚m bufferu

                                          ;* jm‚no souboru
Soubor   db        'A:\',64+14 dup(0)       ; buffer pro adres © a soubor
AdrSoub  dw        0                        ; adresa ‡¡sla souboru

Idents   dw        0                        ; identifikace v˜stupn¡ho souboru

Keys     dw        0                        ; uschovan˜ k¢d kl vesy
Citac    db        0                        ; ‡¡ta‡ blik n¡ kurzoru
AktKur   db        0                        ; p©¡znak zapnut¡ kurzoru

; ------ komprese

KompCit  dw        0                        ; ‡¡ta‡ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡
KompBNum dw        0                        ; po‡et bajt– v kompresn¡m bufferu
KompBuff db        256 dup(0)               ; kompresn¡ buffer
KompPar  db        1                        ; 1=p©¡znak kompresn¡ho m¢du

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
         mov       bx,0b800h                ; segment CGA
         mov       si,ds:[44eh]             ; adresa displeje
         mov       al,ds:[449h]             ; aktivn¡ videom¢d
         cmp       al,7
         jb        Screen1                  ; povolen˜ videom¢d CGA
         mov       bx,0b000h                ; segment MDA
         je        Screen1                  ; povolen˜ videom¢d MDA
         mov       bx,0a000h                ; jinak segment EGA
         cmp       al,12
         jbe       Screen88                 ; zak zan˜ videom¢d
         cmp       al,19                    ; maxim ln¡ videom¢d
         jbe       Screen1                  ; videom¢d OK
Screen88:jmp       Screen8                  ; neobsluhovan˜ videom¢d
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
         jnc       Screen54
         jmp       Screen8                  ; chyba - soubor nelze vytvo©it

Screen54:
         mov       ds:[Idents],ax           ; £schova identifik toru souboru

                                          ;* nalezen¡ popisu videom¢du v tabulce
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       bl,ds:[449h]             ; aktivn¡ videom¢d
         pop       ds
         mov       ds:[VMod],bl             ; aktivn¡ videom¢d
         mov       bh,0
         mov       ax,12                    ; d‚lka polo‘ky tabulky
         mul       bx                       ; v˜po‡et offsetu v tabulce
         add       ax,offset TabMod         ; adresa v tabulce
         mov       bp,ax                    ; adresa polo‘ky v tabulce

                                          ;* stanoven¡ parametr– podle tabulky
         mov       ax,ds:[bp]               ; maxim ln¡ ¨¡©ka
         mov       ds:[MaxSir],ax           ; maxim ln¡ ¨¡©ka
         mov       ax,ds:[bp+2]             ; maxim ln¡ v˜¨ka
         mov       ds:[MaxVys],ax           ; maxim ln¡ v˜¨ka
         mov       al,ds:[bp+4]             ; po‡et rovin
         mov       byte ptr ds:[Rovin],al   ; po‡et rovin
         mov       al,ds:[bp+5]             ; typ
         and       byte ptr ds:[Param],not 2 + 4
         or        byte ptr ds:[Param],al   ; parametry

                                          ;* up©esnˆn¡ © dk– v textov‚m m¢du
         cmp       byte ptr ds:[ParEGA],0   ; je karta EGA/VGA ?
         je        Screen60                 ; nen¡ karta EGA/VGA
         test      byte ptr ds:[Param],2    ; je textov˜ videom¢d ?
         jz        Screen60                 ; nen¡ textov˜ videom¢d
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; segment dat BIOS
         mov       al,ds:[484h]             ; ‡¡slo posledn¡ho © dku
         inc       ax                       ; po‡et © dk– na obrazovku
         pop       ds
         mov       ds:[MaxVys],ax           ; opraven  v˜¨ka displeje

                                          ;* funkce sn¡m n¡ obrazovky
Screen60:
         call      Anims                    ; sn¡m n¡ obrazovky
         jc        Screen9                  ; p©eru¨en¡ operace

         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         call      WritBuff                 ; z pis bufferu na disk
         mov       ah,3eh
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
;        z pis bajtu do souboru s kompres¡
; -----------------------------------------------------------------------------
; Syntaxe komprese:
;    bajt - po‡et n sleduj¡c¡ch bajt– dat 0 a‘ 255 (0=pouze p©ep¡na‡ m¢du)
;         - kromˆ bajtu 255 se p©epne p©¡znak komprese/data
;    za bajtem n sleduje buƒ bajt, kter˜ se m  opakovat, nebo data o dan‚m po‡tu
;    Na za‡ tku souboru je nastaven p©¡znak komprese, prvn¡ bajt r–zn˜
;    od 255 tedy ud v  po‡et n sleduj¡c¡ch dat v bˆ‘n‚m m¢du
; -----------------------------------------------------------------------------

WritB    PROC      NEAR

         cmp       al,ds:[KompChar]         ; je bajt shodn˜ ?
         je        WritB1                   ; bajt je shodn˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
WritB1:  mov       ds:[KompChar],al         ; ulo‘en¡ shodn‚ho znaku
         inc       byte ptr ds:[KompCit]    ; zv˜¨en¡ ‡¡ta‡e shodn˜ch znak–
         cmp       byte ptr ds:[KompCit],255; je buffer ji‘ pln˜ ?
         jne       WritB9                   ; buffer je¨tˆ nen¡ pln˜
         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
WritB9:  ret

WritB    ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bufferu shody
; -----------------------------------------------------------------------------

FlushQ   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx

; ------ kontrola, zda je dostate‡n˜ po‡et opakovan˜ch bajt–

         mov       cx,ds:[KompCit]          ; po‡et shodn˜ch bajt–
         jcxz      FlushQ9                  ; v bufferu nic nen¡
         cmp       cl,3                     ; dostate‡n˜ po‡et bajt– ?
         jb        FlushQ7                  ; je mal˜ po‡et bajt–

; ------ dostate‡n˜ po‡et bajt– - vypr zdnˆn¡ bˆ‘n‚ho bufferu

         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu

; ------ p©¡padn‚ p©epnut¡ do kompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         jne       FlushQ3                  ; je kompresn¡ m¢d - OK
         xor       al,al                    ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do kompresn¡ho m¢du
         inc       byte ptr ds:[KompPar]    ; p©¡znak kompresn¡ho m¢du

; ------ z pis bajtu d‚lky a opakovan‚ho bajtu

FlushQ3: mov       al,cl                    ; po‡et opakov n¡ bajtu
         call      WritB0                   ; z pis po‡tu bajt–
         mov       al,ds:[KompChar]         ; opakovan˜ znak
         call      WritB0                   ; z pis opakovan‚ho bajtu

; ------ nastaven¡ p©¡znaku m¢du komprese

         inc       cl                       ; je 255 znak– ?
         je        FlushQ9                  ; je 255 znak– - m¢d se nep©epne
         dec       byte ptr ds:[KompPar]    ; p©¡znak nekompresn¡ho m¢du
         jmp       short FlushQ9

; ------ mal˜ po‡et bajt– - vypr zdnˆn¡ p©es bˆ‘n˜ buffer

FlushQ7: mov       al,ds:[KompChar]         ; shodn˜ znak
FlushQ8: call      StorBuf                  ; ulo‘en¡ do bˆ‘n‚ho bufferu
         loop      FlushQ8                  ; ulo‘en¡ dal¨¡ho bajtu

; ------ n vrat registr–

FlushQ9: mov       word ptr ds:[KompCit],0  ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         pop       cx
         pop       ax
         ret

FlushQ   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ bajtu AL do bˆ‘n‚ho bufferu
; -----------------------------------------------------------------------------

StorBuf  PROC      NEAR

; ------ £schova registr–

         push      bx

; ------ ulo‘en¡ bajtu do bufferu

         mov       bx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         inc       word ptr ds:[KompBNum]   ; zv˜¨en¡ ‡¡ta‡e dat v bufferu
         mov       ds:[bx+KompBuff],al      ; ulo‘en¡ bajtu do bufferu

; ------ p©i zaplnˆn¡ bufferu jeho vypr zdnˆn¡

         cmp       bl,254                   ; je buffer ji‘ pln˜ ?
         jne       StorBuf2                 ; buffer je¨tˆ nen¡ pln˜
         call      FlushB                   ; vypr zdnˆn¡ bufferu

; ------ n vrat registr–

StorBuf2:pop       bx
         ret

StorBuf  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ bˆ‘n‚ho bufferu
; -----------------------------------------------------------------------------

FlushB   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      cx
         push      si

; ------ kontrola, zda v bufferu nˆco je

         mov       cx,ds:[KompBNum]         ; po‡et bajt– v kompresn¡m bufferu
         jcxz      FlushB9                  ; v bufferu nic nen¡

; ------ p©¡padn‚ p©epnut¡ do nekompresn¡ho m¢du

         cmp       byte ptr ds:[KompPar],0  ; je kompresn¡ m¢d ?
         je        FlushB3                  ; nen¡ kompresn¡ m¢d - OK
         xor       al,al                    ; bajt pro p©epnut¡ m¢du
         call      WritB0                   ; p©epnut¡ do norm ln¡ho m¢du
         dec       byte ptr ds:[KompPar]    ; p©¡znak bˆ‘n‚ho m¢du

; ------ vysl n¡ bajtu d‚lky ©etˆzce

FlushB3: mov       al,cl                    ; po‡et bajt– textu
         call      WritB0                   ; vysl n¡ bajtu d‚lky

; ------ nastaven¡ p©¡znaku p©epnut¡ m¢du

         inc       al                       ; je 255 bajt– ?
         jz        FlushB4                  ; je 255 znak– - m¢d se nep©epne
         inc       byte ptr ds:[KompPar]    ; p©¡znak kompresn¡ho m¢du

; ------ vysl n¡ dat

FlushB4: mov        si,offset KompBuff      ; buffer s daty
         cld
FlushB5: lodsb                              ; bajt dat k vysl n¡
         call      WritB0                   ; vysl n¡ bajtu
         loop      FlushB5                  ; vysl n¡ dal¨¡ho bajtu
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu

; ------ n vrat registr–

FlushB9: pop       si
         pop       cx
         pop       ax
         ret

FlushB   ENDP

; -----------------------------------------------------------------------------
;        Z pis bajtu do diskov‚ho bufferu
; -----------------------------------------------------------------------------

WritB0:  cmp       word ptr ds:[NumBuff],BufSize ; buffer je ji‘ zaplnˆn ?
         jb        WritB2                   ; buffer je¨tˆ nen¡ zaplnˆn
         call      WritBuff                 ; z pis bufferu na disk
         jc        WritB3                   ; byla chyba z pisu
WritB2:  push      si
         mov       si,ds:[NumBuff]          ; po‡et bajt– v bufferu
         mov       ds:[si+Buffer],al        ; z pis nov‚ho bajtu do bufferu
         inc       word ptr ds:[NumBuff]    ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
         pop       si
WritB3:  ret

; -----------------------------------------------------------------------------
;        Z pis diskov‚ho bufferu do souboru (CY=chyba)
; -----------------------------------------------------------------------------

WritBuff:push      ax
         push      bx
         push      cx
         push      dx

         mov       dx,offset buffer
         mov       cx,ds:[NumBuff]          ; po‡et bajt– v diskov‚m bufferu
         jcxz      WritBff2                 ; nen¡ ‘ dn˜ bajt k z pisu
         mov       ah,40h
         mov       bx,ds:[Idents]           ; identifik tor souboru
         int       21h                      ; z pis souboru
         mov       word ptr ds:[NumBuff],0  ; vynulov n¡ bufferu
         jc        WritBff2                 ; byla chyba
         cmp       ax,cx                    ; souhlas¡ po‡et bajt– ?
         je        WritBff2                 ; po‡et bajt– souhlas¡
         stc                                ; chyba - pln˜ disk

WritBff2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret







; -----------------------------------------------------------------------------
;        Vlastn¡ funkce sn¡m n¡ obsahu obrazovky
; -----------------------------------------------------------------------------

Anims:
         call      Edit                     ; editace kurzoru
         jc        Anims9                   ; p©eru¨en¡ operace

         mov       word ptr ds:[KompCit],0
         mov       word ptr ds:[KompBNum],0 ; zru¨en¡ ‡¡ta‡e bajt– v bufferu
         mov       byte ptr cs:[KompPar],1  ; nastaven¡ p©¡znaku komprese
         call      WritHl                   ; z pis z hlav¡ souboru
         jc        Anims9                   ; chyba z pisu

         xor       ax,ax                    ; po‡ te‡n¡ rovina k z pisu
         mov       bx,ds:[X1]               ; po‡ te‡n¡ pozice
         mov       cx,ds:[X2]               ; koncov  pozice
         sub       cx,bx                    ; ¨¡©ka - 1
         inc       cx                       ; ¨¡©ka okna
Anims1:  mov       dx,ds:[Y1]               ; po‡ te‡n¡ © dek
Anims2:  call      word ptr ds:[bp+10]      ; z pis © dku okna
         inc       dx                       ; zv˜¨en¡ © dku
         cmp       dx,ds:[Y2]               ; dosa‘eno posledn¡ho © dku ?
         jbe       Anims2                   ; nen¡ p©ekro‡en posledn¡ © dek
         inc       ax                       ; zv˜¨en¡ ‡¡sla roviny
         test      byte ptr ds:[Param],4    ; je paraleln¡ ulo‘en¡ barev ?
         jnz       Anims9                   ; je paraleln¡ ulo‘en¡ barev
         cmp       ax,ds:[Rovin]            ; jsou ji‘ v¨echny roviny ?
         jb        Anims1                   ; nejsou je¨tˆ v¨echny roviny
         clc
Anims9:  ret

; -----------------------------------------------------------------------------
;        Editace kurzoru (ES:SI=adresa videopamˆti)
; -----------------------------------------------------------------------------

Edit:
         call      Omez                     ; omezen¡ rozmˆr– kurzoru
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

                                          ;* zji¨tˆn¡ stavu p©esmyka‡–
         push      ds
         mov       bx,40h
         mov       ds,bx                    ; DS <- 40h
         mov       al,ds:[17h]              ; stav p©esmyka‡–
         and       al,0fh                   ; pouze p©esmyka‡e Ctrl, Shift, Alt
         test      al,3                     ; p©esmyka‡e SHIFT ?
         jz        Edit2                    ; nejsou p©esmyka‡e SHIFT
         or        al,3                     ; p©esmyka‡e SHIFT
Edit2:   pop       ds

                                          ;* vyvol n¡ funkce podle kl vesy
         mov       bx,offset TabKey         ; tabulka kl ves pro editaci
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
         dw        7304h,8,offset EdLeft     ; ^LEFT - kurzor 10 znak– vlevo
         dw        7404h,8,offset EdRight    ; ^RIGHT - kurzor 10 znak– vpravo
         dw        8d04h,8,offset EdUp       ; ^UP - kurzor 10 linek nahoru
         dw        9104h,8,offset EdDown     ; ^DOWN -kurzor 10 linek dol–
         dw        0f03h,48,offset EdLeft     ; STAB - kurzor 50 pozic vlevo
         dw        0f00h,48,offset EdRight    ; TAB - kurzor 50 pozic vpravo
         dw        4900h,48,offset EdUp       ; PAGEUP - kurzor 50 linek nahoru
         dw        5100h,48,offset EdDown     ; PAGEDOWN - kurzor 50 linek dol–
         dw        4700h,-2,offset EdLeft     ; HOME - kurzor k lev‚mu okraji
         dw        4f00h,-2,offset EdRight    ; END - kurzor k prav‚mu okraji
         dw        7704h,-2,offset EdUp       ; ^HOME - kurzor k horn¡mu okraji
         dw        7504h,-2,offset EdDown     ; ^END - kurzor k spodn¡mu okraji
         dw        8404h,-2,offset EdUp       ; ^PAGEUP - k horn¡mu okraji
         dw        7604h,-2,offset EdDown     ; ^PAGEDOWN - k spodn¡mu okraji

                                          ;* p©esmyka‡ SHIFT - okraje
         dw        4b03h,1,offset EdSLeft     ; LEFT - vlevo
         dw        4d03h,1,offset EdSRight    ; RIGH - vpravo
         dw        4803h,1,offset EdSUp       ; UP - nahoru
         dw        5003h,1,offset EdSDown     ; DOWN - dol–
         dw        7307h,8,offset EdSLeft    ; ^LEFT - 10 znak– vlevo
         dw        7407h,8,offset EdSRight   ; ^RIGHT - 10 znak– vpravo
         dw        8d07h,8,offset EdSUp      ; ^UP - 10 linek nahoru
         dw        9107h,8,offset EdSDown    ; ^DOWN - 10 linek dol–
         dw        4903h,48,offset EdSUp      ; PAGEUP - 50 znak– nahoru
         dw        5103h,48,offset EdSDown    ; PAGEDOWN - 50 znak– dol–
         dw        4703h,-2,offset EdSLeft    ; HOME - max. vlevo
         dw        4f03h,-2,offset EdSRight   ; END - max. vpravo
         dw        7707h,-2,offset EdSUp      ; ^HOME - max. nahoru
         dw        7507h,-2,offset EdSDown    ; ^END - max. dol–
         dw        8407h,-2,offset EdSUp      ; ^PageUp - max. nahoru
         dw        7607h,-2,offset EdSDown    ; ^PageDown - max. dol–

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
                                          ;* prav˜ okraj vlevo
EdSLeft: mov       ax,ds:[X2]               ; prav˜ okraj
         sub       ax,ds:[X1]               ; sou‡asn  ¨¡©ka
         je        EdSLeft2                 ; je ji‘ lev˜ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je ¨¡©ka men¨¡ ne‘ po‘adovan  ?
         jbe       EdSLeft1                 ; ¨¡©ka je men¨¡
         mov       ax,cx                    ; omezen¡ na po‘adovan˜ posun
EdSLeft1:sub       word ptr ds:[X2],ax      ; posun vlevo
         call      Kurzor                   ; zapnut¡ kurzoru
EdSLeft2:ret
; -----------------------------------------------------------------------------
                                          ;* prav˜ okraj vpravo
EdSRight:mov       ax,ds:[MaxSir]           ; maxim ln¡ prav˜ okraj
         dec       ax                       ; maxim ln¡ prav  pozice
         sub       ax,ds:[X2]               ; zbytek k prav‚mu okraji
         je        EdSRght2                 ; je ji‘ prav˜ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je ¨¡©ka men¨¡ ne‘ po‘adovan  ?
         jbe       EdSRght1                 ; ¨¡©ka je men¨¡
         mov       ax,cx                    ; omezen¡ na po‘adovan˜ posun
EdSRght1:add       word ptr ds:[X2],ax      ; posun prav‚ho okraje vpravo
         call      Kurzor                   ; zapnut¡ kurzoru
EdSRght2:ret
         ret
; -----------------------------------------------------------------------------
                                          ;* spodn¡ okraj nahoru
EdSUp:   mov       ax,ds:[Y2]               ; spodn¡ okraj
         sub       ax,ds:[Y1]               ; sou‡asn  ¨¡©ka
         je        EdSUp2                   ; je ji‘ horn¡ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je ¨¡©ka men¨¡ ne‘ po‘adovan  ?
         jbe       EdSUp1                   ; ¨¡©ka je men¨¡
         mov       ax,cx                    ; omezen¡ na po‘adovan˜ posun
EdSUp1:  sub       word ptr ds:[Y2],ax      ; posun vlevo
         call      Kurzor                   ; zapnut¡ kurzoru
EdSUp2:  ret
; -----------------------------------------------------------------------------
                                          ;* spodn¡ okraj dol–
EdSDown: mov       ax,ds:[MaxVys]           ; maxim ln¡ spodn¡ okraj
         dec       ax                       ; maxim ln¡ prav  pozice
         sub       ax,ds:[Y2]               ; zbytek ke spodn¡mu okraji
         je        EdSDown2                 ; je ji‘ spodn¡ okraj
         call      Kurzor                   ; vypnut¡ kurzoru
         cmp       ax,cx                    ; je ¨¡©ka men¨¡ ne‘ po‘adovan  ?
         jbe       EdSDown1                 ; ¨¡©ka je men¨¡
         mov       ax,cx                    ; omezen¡ na po‘adovan˜ posun
EdSDown1:add       word ptr ds:[Y2],ax      ; posun spodn¡ho okraje dol–
         call      Kurzor                   ; zapnut¡ kurzoru
EdSDown2:ret
         ret

; -----------------------------------------------------------------------------
;        Z pis hlavi‡ky souboru
; -----------------------------------------------------------------------------

WritHl:  push      ax
         push      bx
         push      cx
         push      dx

         mov       ax,ds:[X2]               ; prav˜ okraj
         sub       ax,ds:[X1]               ; ¨¡©ka - 1
         inc       ax                       ; ¨¡©ka
         mov       ds:[sirka],ax            ; ¨¡©ka v˜©ezu

         mov       ax,ds:[Y2]               ; spodn¡ okraj
         sub       ax,ds:[Y1]               ; v˜¨ka - 1
         inc       ax                       ; v˜¨ka
         mov       ds:[vyska],ax            ; v˜¨ka v˜©ezu

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
;        Omezen¡ rozmˆr– kurzoru
; -----------------------------------------------------------------------------

Omez:    push      ax

         mov       ax,ds:[MaxSir]           ; maxim ln¡ ¨¡©ka
         dec       ax                       ; posledn¡ pozice

         cmp       ax,ds:[X1]               ; p©ekro‡ena pozice X ?
         jae       Omez2                    ; nen¡ p©ekro‡eno
         mov       ds:[X1],ax               ; omezen¡ na posledn¡ pozici

Omez2:   cmp       ax,ds:[X2]               ; p©ekro‡ena pozice X2 ?
         jae       Omez4                    ; nen¡ p©ekro‡ena
         mov       ds:[X2],ax               ; omezen¡ na posledn¡ pozici

Omez4:   mov       ax,ds:[MaxVys]           ; maxim ln¡ v˜¨ka
         dec       ax                       ; posledn¡ linka

         cmp       ax,ds:[Y1]               ; p©ekro‡en © dek Y ?
         jae       Omez5                    ; nen¡ p©ekro‡en
         mov       ds:[Y1],ax               ; omezen¡ na posledn¡ © dek

Omez5:   cmp       ax,ds:[Y2]               ; p©ekro‡en © dek Y2 ?
         jae       Omez7                    ; nen¡ p©ekro‡en
         mov       ds:[Y2],ax               ; omezen¡ na posledn¡ © dek

Omez7:   pop       ax
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
         call      word ptr ds:[bp+6]       ; zobrazen¡ horn¡ linky

                                          ;* lev˜ okraj
         mov       cx,ds:[Y2]               ; spodn¡ okraj
         sub       cx,dx                    ; d‚lka lev‚ho okraje - 1
         inc       dx                       ; a‘ 2. © dek
         call      word ptr ds:[bp+8]       ; zobrazen¡ lev‚ho okraje

                                          ;* prav˜ okraj
         mov       bx,ds:[X2]               ; prav  pozice
         cmp       bx,ds:[X1]               ; je shodn˜ s lev˜m okrajem ?
         je        Kurzor1                  ; je shodn˜ s lev˜m okrajem
         call      word ptr ds:[bp+8]       ; zobrazen¡ prav‚ho okraje

                                          ;* spodn¡ okraj
         mov       dx,ds:[Y2]               ; spodn¡ okraj
         cmp       dx,ds:[Y1]               ; spl˜v  s horn¡m okrajem ?
         je        Kurzor1                  ; spl˜v  s horn¡m okrajem - nic
         mov       bx,ds:[X1]               ; lev˜ okraj
         inc       bx
         mov       cx,ds:[X2]               ; prav˜ okraj
         sub       cx,bx                    ; ¨¡©ka - 1
         call      word ptr ds:[bp+6]       ; zobrazen¡ spodn¡ho okraje

Kurzor1: pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         popf
         ret



; -----------------------------------------------------------------------------
;                 Inverze © dku znak– textov‚ho m¢du
;         (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

                                          ;* inverze vertik ln¡ho sloupce
InvTxtV: push      di
         mov       di,ds:[MaxSir]
         shl       di,1
         jmp       short InvTxt0

                                          ;* inverze horizont ln¡ho © dku
InvTxtH: push      di
         mov       di,2

InvTxt0: push      ax
         push      cx
         push      dx
         push      si

         jcxz      InvTxtH2                 ; nen¡ ‘ dn˜ znak

         mov       ax,ds:[MaxSir]           ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       ax,bx                    ; p©i‡ten¡ pozic
         shl       ax,1                     ; p©evod na offset ve VRAM
         add       si,ax                    ; adresa ve videopamˆti
InvTxtH1:xor       byte ptr es:[si+1],77h   ; inverze znaku kurzoru
         add       si,di                    ; adresa dal¨¡ho znaku
         loop      InvTxtH1                 ; dal¨¡ znak

InvTxtH2:pop       si
         pop       dx
         pop       cx
         pop       ax
         pop       di
         ret

; -----------------------------------------------------------------------------
;            Inverze bodu kurzoru m¢du CGA
;     (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–, AX=p©¡rustek)
; -----------------------------------------------------------------------------


InvCGAH:
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di


                                          ;* bitov  pozice v bajtu
         mov       di,bx                    ; pozice
         and       di,7                     ; bitov  pozice v bajtu
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty


                                          ;* v˜po‡et adresy linky ve VRAM
         cmp       byte ptr ds:[Vmod],17
         je        InvCGAH1
         shr       dx,1                     ; po‡et linek / 2
         jnc       InvCGAH1                 ; je sud  linka
         xor       si,2000h                 ; korekce adresy
InvCGAH1:mov       ax,80                    ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; p©i‡ten¡ adresy linky
         add       si,bx                    ; p©i‡ten¡ pozic
         cmp       byte ptr ds:[Vmod],6
         jae       InvCGAH2                 ; je videom¢d 6 nebo 17
         add       si,bx

InvCGAH2:push      cx
         mov       cx,di                    ; bitov  pozice
         mov       ax,0ffh                  ; maska pro videom¢d 6
         shr       ax,cl                    ; rotace masky na pozici
         pop       cx

         cmp       byte ptr ds:[Vmod],6
         jae       InvCGAH3                  ; je videom¢d 6 nebo 17

         push      cx
         mov       cx,di                    ; bitov  pozice
         mov       ax,0ffffh                ; maska pro ostatn¡ videom¢dy
         shr       ax,cl
         shr       ax,cl                    ; rotace masky na pozici
         pop       cx
         xchg      ah,al

                                          ;* zobrazen¡ ‡ sti z prvn¡ho bajtu
InvCGAH3:jcxz      InvCGAH9                 ; nen¡ ‘ dn˜ bod

         xor       word ptr es:[si],ax      ; inverze prvn¡ho bajtu kurzoru
         add       cx,di                    ; p©i‡ten¡ prvn¡ osmice
         sub       cx,8                     ; ode‡ten¡ bit– z prvn¡ho bajtu
         jc        InvCGAH5                 ; nen¡ dal¨¡ bajt

                                          ;* stanoven¡ masky vnit©n¡ch bajt–
         mov       ax,0ffh                  ; maska pro videm¢dy 6 a 17
         mov       bx,1                     ; p©¡rustek pro videom¢dy 6 a 17
         cmp       byte ptr ds:[Vmod],6
         jae       InvCGH33                 ; je videom¢d 6
         mov       ax,0ffffh                ; maska pro ostatn¡ videom¢dy
         inc       bx                       ; ostatn¡ videom¢dy p©¡rustek 2

InvCGH33:add       si,bx
                                          ;* zobrazen¡ vnit©n¡ch bajt– kurzoru
InvCGAH4:xor       word ptr es:[si],ax      ; inverze bit– v bajtu
         sub       cx,8                     ; ode‡ten¡ osmice bit–
         jc        InvCGAH5                 ; je ji‘ p©ete‡en¡
         add       si,bx                    ; adresa dal¨¡ho znaku
         jmp       short InvCGAH4           ; je dal¨¡ bajt

                                          ;* vymaz n¡ p©ebyte‡n˜ch bit–
InvCGAH5:add       cx,8                     ; n vrat po‡tu zbyl˜ch bit–
         mov       ax,0ffh                  ; maska pro videom¢d 6
         shr       ax,cl                    ; rotace masky na pozici

         cmp       byte ptr ds:[Vmod],6
         jae       InvCGAH6                  ; je videom¢d 6

         mov       ax,0ffffh                ; maska pro ostatn¡ videom¢dy
         shr       ax,cl
         shr       ax,cl                    ; rotace masky na pozici
         xchg      ah,al

InvCGAH6:xor       word ptr es:[si],ax

InvCGAH9:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;                Inverze sloupce bod– kurzoru m¢du CGA
;        (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

InvCGAV: push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         jcxz      InvCGAV5                  ; nen¡ ‘ dn˜ znak

                                          ;* bitov  pozice v bajtu
         mov       di,bx                    ; pozice
         and       di,7                     ; bitov  pozice v bajtu
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty

                                          ;* v˜po‡et adresy linky ve VRAM
         push      dx
         cmp       byte ptr ds:[Vmod],17
         je        InvCGAV1
         shr       dx,1                     ; po‡et linek / 2
         jnc       InvCGAV1                 ; je sud  linka
         xor       si,2000h                 ; korekce adresy
InvCGAV1:mov       ax,80                    ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; p©i‡ten¡ adresy linky
         add       si,bx                    ; p©i‡ten¡ pozic
         cmp       byte ptr ds:[Vmod],6
         jae       InvCGAV4                 ; je videom¢d 6 nebo 17
         add       si,bx
InvCGAV4:pop       dx

         push      cx
         mov       cx,di                    ; bitov  pozice
         mov       ax,80h                   ; maska pro videom¢d 6
         shr       ax,cl                    ; rotace masky na pozici
         pop       cx

         cmp       byte ptr ds:[Vmod],6
         jae       InvCGAV2                 ; je videom¢d 6 nebo 17

         push      cx
         mov       cx,di                    ; bitov  pozice
         mov       ax,0c000h                ; maska pro ostatn¡ videom¢dy
         shr       ax,cl
         shr       ax,cl                    ; rotace masky na pozici
         xchg      ah,al                    ; nastaven¡ bajt– na spr vnou pozici
         pop       cx

InvCGAV2:xor       word ptr es:[si],ax      ; inverze bajtu kurzoru
         cmp       byte ptr ds:[Vmod],17
         je        InvCGAV6
         xor       si,2000h
         test      dx,1                     ; je sud  linka ?
         jz        InvCGAV3                 ; je sud  linka
InvCGAV6:add       si,80                    ; zv˜¨en¡ adresy bitu
InvCGAV3:inc       dx                       ; zv˜¨en¡ ‡¡sla linky
         loop      InvCGAV2                 ; dal¨¡ znak

InvCGAV5:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret


; -----------------------------------------------------------------------------
;            Inverze linky kurzoru m¢du MCGH
;     (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–, AX=p©¡rustek)
; -----------------------------------------------------------------------------

InvMCGV: push      di
         mov       di,ds:[MaxSir]           ; p©¡rustek
         jmp       short InvMCG0

InvMCGH: push      di
         mov       di,1                     ; p©¡rustek

InvMCG0: push      ax
         push      cx
         push      dx
         push      si

         jcxz      InvMCG5                  ; nen¡ ‘ dn˜ znak

                                          ;* v˜po‡et adresy linky ve VRAM
         mov       ax,ds:[MaxSir]           ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; p©i‡ten¡ adresy linky
         add       si,bx                    ; p©i‡ten¡ pozic

         mov       al,0fh                   ; maska pro inverzi

InvMCG2: xor       byte ptr es:[si],al      ; inverze bajtu kurzoru
         add       si,di
         loop      InvMCG2                  ; dal¨¡ znak

InvMCG5: pop       si
         pop       dx
         pop       cx
         pop       ax
         pop       di
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
; -----------------------------------------------------------------------------

InvPCJH:  clc
         ret

InvPCJV:
         clc
         RET

ReadPCJ:
         clc
         ret


; -----------------------------------------------------------------------------
;        €ten¡ skupiny bajt– z videopamˆti do v˜stupn¡ho bufferu
;     (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–, AX=rovina)
; -----------------------------------------------------------------------------
                                          ;* ‡ten¡ v textov‚m m¢du
ReadTxt: push      ax
         push      cx
         push      dx
         push      si
         push      di

         jcxz      ReadTxt2                 ; nen¡ ‘ dn˜ znak
         mov       di,ax                    ; rovina

         mov       ax,ds:[MaxSir]           ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       ax,bx                    ; p©i‡ten¡ pozic
         shl       ax,1                     ; p©evod na offset ve VRAM
         add       si,ax                    ; adresa ve videopamˆti
         add       si,di                    ; posun na p©¡slu¨nou rovinu
ReadTxt1:mov       al,es:[si]               ; bajt z po‘adovan‚ roviny
         call      WritB                    ; z pis bajtu do bufferu
         add       si,2                     ; adresa dal¨¡ho znaku
         loop      ReadTxt1                 ; dal¨¡ znak

ReadTxt2:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        €ten¡ skupiny bajt– z videopamˆti CGA do v˜stupn¡ho bufferu
;           (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

ReadCGA:
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         jcxz      ReadCGA6                 ; nen¡ ‘ dn˜ bod

                                          ;* korekce pro videom¢dy 320x200
         cmp       byte ptr ds:[VMod],6
         jae       ReadCGAx
         add       bx,bx                    ; pozice * 2 pro videom¢dy 320x200
         add       cx,cx                    ; po‡et znak– -> po‡et bajt–

                                          ;* adresa pro lichou/sudou linku
ReadCGAx:cmp       byte ptr ds:[VMod],17    ; je videom¢d 17 ?
         je        ReadCGA0                 ; je m¢d 17 - nen¡ posun o 2000h
         shr       dx,1                     ; je to lich  linka ?
         jnc       ReadCGA0                 ; je to sud  linka
         xor       si,2000h                 ; druh  ‡ st videopamˆti

                                          ;* stanoven¡ bitov‚ pozice
ReadCGA0:mov       di,bx                    ; po‡ te‡n¡ bod
         and       di,7                     ; offset po‡ te‡n¡ho bodu
         shr       bx,1
         shr       bx,1
         shr       bx,1                     ; p©epo‡et na bajty

                                          ;* v˜po‡et adresy ve videpamˆti
         mov       ax,80                    ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; adresa ve videopamˆti
         add       si,bx                    ; p©i‡ten¡ pozic

                                          ;* ‡ten¡ jednotliv˜ch bajt–
ReadCGA1:mov       ax,es:[si]               ; slovo z po‘adovan‚ roviny
         xchg      ah,al

         push      cx
         mov       cx,di
         shl       ax,cl
         pop       cx
         mov       al,ah

         sub       cx,8
         jc        ReadCGA3

         call      WritB                    ; z pis bajtu do bufferu
         inc       si                       ; adresa dal¨¡ho bajtu
         jmp       short ReadCGA1

ReadCGA3:add       cl,8
         jz        ReadCGA6
         mov       ah,0ffh
         shr       ah,cl
         not       ah
         and       al,ah                    ; maskov n¡ posledn¡ho bajtu

         call      WritB                    ; z pis posledn¡ho bajtu

ReadCGA6:pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        €ten¡ skupiny bajt– z videopamˆti MCG do v˜stupn¡ho bufferu
;            (BX=pozice, DX=© dek, ES:SI=VRAM, CX=po‡et znak–)
; -----------------------------------------------------------------------------

ReadMCG: push      ax
         push      cx
         push      dx
         push      si

         jcxz      ReadMCG6                 ; nen¡ ‘ dn˜ znak

         mov       ax,320                   ; po‡et bajt– na © dek
         mul       dx                       ; p©epo‡et © dk– na pozice
         add       si,ax                    ; adresa ve videopamˆti
         add       si,bx                    ; p©i‡ten¡ pozice

ReadMCG1:mov       al,es:[si]               ; bajt z displeje
         inc       si                       ; zv˜¨en¡ adresy ve videopamˆti
         call      WritB                    ; z pis bajtu do bufferu
         loop      ReadMCG1                 ; dal¨¡ znak

ReadMCG6:pop       si
         pop       dx
         pop       cx
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
         cmp       byte ptr ds:[Vmod],13    ; videom¢d 13 ?
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


;
;writek:                                     ; z pis bajtu v kompresn¡m m¢du
;                                            ; VSTUP: AL=bajt (pokud CN)
;                                            ;        CY=nen¡ dal¨¡ bajt
;
;         jc        writek0                  ; vypr zdnˆn¡ buffer–
;         test      byte ptr cs:[verze],1    ; je kompresn¡ m¢d ?
;         jnz       writek1                  ; je kompresn¡ m¢d
;         jmp       writeb                   ; z pis bajtu bez komprese
;
;writek0: test      byte ptr cs:[verze],1    ; je kompresn¡ m¢d ?
;         stc
;         jnz       writek1                  ; je kompresn¡ m¢d
;         jmp       writeb                   ; z pis bajtu bez komprese
;writek1: push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      ds
;         push      es
;         push      cs
;         pop       ds
;         push      cs
;         pop       es
;         jnc       writek5                  ; nen¡ vypr zdnˆn¡ bufferu
;                                           ;* vyppr zdnˆn¡ buffer–
;         call      flush                    ; vypr zdnˆn¡ obou buffer–
;         stc                                ; p©¡znak nulov n¡ buffer–
;         call      writeb                   ; nulov n¡ bufferu
;         jmp       writek8                  ; n vrat z obsluhy
;
;writek5: cmp       byte ptr ds:[citeq],0    ; je nˆjak˜ shodn˜ bajt ?
;         jne       writek2                  ; v bufferu je ji‘ nˆjak˜ bajt
;         mov       byte ptr ds:[byteeq],al  ; ulo‘en¡ shodn‚ho bajtu
;         inc       byte ptr ds:[citeq]      ; zv˜¨en¡ ‡¡ta‡e shodn˜ch bajt–
;         jmp       writek8                  ; n vrat
;
;writek2: cmp       byte ptr ds:[byteeq],al  ; je shoda bajtu ?
;         jne       writek3                  ; nen¡ shodn˜ bajt
;         inc       byte ptr ds:[citeq]      ; zv˜¨en¡ po‡tu shodn˜ch bajt–
;         cmp       byte ptr ds:[citeq],255  ; je dosa‘eno pln‚ho po‡tu bajt– ?
;         jnz       writek8                  ; nen¡ je¨tˆ dosa‘eno po‡tu bajt–
;         call      flush                    ; vypr zdnˆn¡ obou buffer–
;         jmp       short writek8            ; n vrat
;
;writek3: cmp       byte ptr ds:[citeq],3    ; je dostate‡n˜ po‡et bajt– ?
;         jb        writek30                 ; nen¡ dostate‡n˜ po‡et bajt–
;         call      flush                    ; vypr zdnˆn¡ obou buffer–
;         jmp       short writek32           ; ulo‘en¡ nov‚ho bajtu
;writek30:call      transeq                  ; vypr zdnˆn¡ bufferu shodn˜ch dat
;writek32:mov       ds:[byteeq],al           ; ulo‘en¡ nov‚ho bajtu
;         inc       byte ptr ds:[citeq]      ; zv˜¨en¡ ‡¡ta‡e shodn˜ch bajt–
;writek8: pop       es
;         pop       ds
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;transeq:                                    ; p©evod shodn˜ch bajt– do bufferu
;         push      ax
;         push      di
;         push      cx
;         xor       cx,cx
;         mov       cl,byte ptr ds:[citeq]   ; po‡et shodn˜ch bajt–
;         jcxz      transe3                  ; nen¡ ‘ dn˜ bajt v bufferu
;         mov       al,ds:[byteeq]           ; shodn˜ bajt
;transe0: call      storb                    ; ulo‘en¡ bajtu AL do bufferu
;         loop      transe0                  ; dal¨¡ bajt
;         mov       byte ptr ds:[citeq],cl   ; nulov n¡ po‡tu shodn˜ch bajt–
;transe3: pop       cx
;         pop       di
;         pop       ax
;         ret
;
;storb:                                      ; ulo‘en¡ bajtu AL do bufferu
;         push      di
;         mov       di,word ptr ds:[kompc]   ; po‡et bajt– v bufferu
;         and       di,0ffh
;         add       di,offset kompb          ; adresa k ulo‘en¡ bajtu
;         stosb                              ; ulo‘en¡ bajtu do bufferu
;         inc       byte ptr ds:[kompc]      ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu
;         cmp       byte ptr ds:[kompc],255  ; dosa‘eno pln‚ho bufferu ?
;         jne       storb0                   ; nen¡ je¨tˆ pln˜ buffer
;         call      flushb                   ; vypr zdnˆn¡ bufferu
;storb0:  pop       di
;         ret
;
;flush:                                      ; vypr zdnˆn¡ obou buffer–
;         call      flushb                   ; vypr zdnˆn¡ norm ln¡ho bufferu
;                                            ; n sleduje vypr zdnˆn¡ bufferu
;                                            ; shodn˜ch bajt–
;
;flusheq:                                    ; vypr zdnˆn¡ bufferu shodn˜ch bajt–
;         push      ax
;         cmp       byte ptr ds:[citeq],0    ; je nˆjak˜ bajt v bufferu ?
;         je        flushe2                  ; v bufferu nen¡ ‘ dn˜ bajt
;         cmp       byte ptr ds:[pareq],1    ; je kompresn¡ m¢d ?
;         je        flushe0                  ; je kompresn¡ m¢d
;         xor       al,al
;         call      writeb                   ; z pis bajtu pro p©epnut¡ m¢du
;flushe0: mov       al,ds:[citeq]            ; po‡et shodn˜ch bajt–
;         mov       byte ptr ds:[pareq],1    ; p©¡znak - je kompresn¡ m¢d
;         cmp       al,255                   ; je trval˜ m¢d ?
;         je        flushe1                  ; je trval˜ m¢d
;         dec       byte ptr ds:[pareq]      ; p©¡znak - je norm ln¡ m¢d
;flushe1: clc
;         call      writeb                   ; z pis po‡tu bajt–
;         mov       al,ds:[byteeq]           ; shodn˜ bajt
;         clc
;         call      writeb                   ; z pis shodn‚ho bajtu
;         mov       byte ptr ds:[citeq],0    ; vynulov n¡ bufferu shodn˜ch bajt–
;flushe2: pop       ax
;         ret
;
;flushb:                                     ; vypr zdnˆn¡ bufferu bajt–
;         push      ax
;         push      si
;         push      cx
;         xor       cx,cx
;         mov       cl,ds:[kompc]            ; po‡et bajt– v bufferu
;         jcxz      flushb3                  ; v bufferu nen¡ ‘ dn˜ bajt
;         cmp       byte ptr ds:[pareq],0    ; je norm ln¡ m¢d ?
;         je        flushb0                  ; je norm ln¡ m¢d
;         xor       al,al
;         call      writeb                   ; z pis bajtu pro p©epnut¡ m¢du
;flushb0: mov       byte ptr ds:[pareq],0    ; p©¡znak - je norm ln¡ m¢d
;         cmp       cl,255                   ; je trval˜ m¢d ?
;         je        flushb1                  ; nen¡ trval˜ m¢d
;         inc       byte ptr ds:[pareq]      ; p©¡znak - je kompresn¡ m¢d
;flushb1: mov       si,offset kompc          ; po‡et bajt– + buffer bajt– dat
;         inc       cx                       ; + po‡et bajt–
;flushb2: lodsb                              ; bajt k v˜stupu
;         clc
;         call      writeb                   ; z pis bajtu do souboru
;         loop      flushb2                  ; z pis dal¨¡ho bajtu
;         mov       byte ptr ds:[kompc],0    ; vynulov n¡ bufferu shodn˜ch bajt–
;flushb3: pop       cx
;         pop       si
;         pop       ax
;         ret
;
;
;citeq    db        0                        ; ‡¡ta‡ shodn˜ch bajt–
;byteeq   db        0                        ; uschovan˜ shodn˜ bajt
;
;pareq    db        0                        ; parametr 1=je kompresn¡ m¢d
;
;kompc    db        0                        ; ‡¡ta‡ rozd¡ln˜ch bajt– v bufferu
;                                            ; 0 = zmˆna m¢du - nen¡ ‘ dn˜ bajt
;                                            ; 1 a‘ 254 = zmˆna m¢du s daty
;                                            ;  - v norm. m¢du po‡et n sl. bajt–
;                                            ;  - v kompr. m¢du po‡et opakov n¡
;                                            ;    n sleduj¡c¡ho bajtu
;                                            ; 255 = n sleduje 255 bajt– beze
;                                            ;  zmˆny stavu (jinak jako 1 a‘ 255)
;                                            ; (data za‡¡naj¡ norm ln¡m stavem)
;
;kompb    db        255 dup(0)               ; buffer rozd¡ln˜ch bajt– dat
;                                            ; (mus¡ n sledovat za KOMPC)
;
;writeb:                                     ; z pis bajtu do souboru
;                                            ; VSTUP: AL=bajt (pokud CN)
;                                            ;        CY=nen¡ dal¨¡ bajt
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      di
;         push      ds
;         push      es
;         push      cs
;         pop       ds
;         push      cs
;         pop       es
;         mov       di,ds:[adrbyte]          ; adresa k ulo‘en¡ bajtu
;         jc        writeb1                  ; je konec dat - ulo‘en¡
;         inc       word ptr ds:[adrbyte]    ; zv˜¨en¡ adresy k ulo‘en¡ bajtu
;         stosb                              ; ulo‘en¡ bajtu
;         cmp       di,offset sektor0        ; je konec bufferu ?
;         jb        writeb3                  ; nen¡ je¨tˆ konec bufferu - n vrat
;writeb1: sub       di,offset sektor         ; po‡ te‡n¡ adresa bufferu
;         jz        writeb3                  ; nen¡ ‘ dn˜ bajt k ulo‘en¡
;         mov       cx,di                    ; po‡et bajt– k z pisu
;         mov       bx,ds:[idents]           ; identifikace souboru
;         mov       dx,offset sektor         ; adresa bufferu s daty
;         mov       ah,40h                   ; funkce z pisu do souboru
;         int       21h                      ; z pis sektoru do souboru
;         mov       di,offset sektor         ; za‡ tek bufferu dat
;         mov       ds:[adrbyte],di          ; nov  adresa k ukl d n¡ dat
;writeb3: pop       es
;         pop       ds
;         pop       di
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;

TabMod   label     word                   ;* tabulka videom¢d–

                                          ;* 0: 40x25 text
         dw        40,25                    ; ¨¡©ka, v˜¨ka
         db        2,2                      ; po‡et rovin, typ
         dw        offset InvTxtH           ; inverze skupiny bod– horizont lnˆ
         dw        offset InvTxtV           ; inverze skupiny bod– vertik lnˆ
         dw        offset ReadTxt           ; ulo‘en¡ linky do souboru

                                          ;* 1: 40x25 text
         dw        40,25
         db        2,2
         dw        offset InvTxtH
         dw        offset InvTxtV
         dw        offset ReadTxt

                                          ;* 2: 80x25 text
         dw        80,25
         db        2,2
         dw        offset InvTxtH
         dw        offset InvTxtV
         dw        offset ReadTxt

                                          ;* 3: 80x25 text
         dw        80,25
         db        2,2
         dw        offset InvTxtH
         dw        offset InvTxtV
         dw        offset ReadTxt

                                          ;* 4: 320x200/4 graf
         dw        320,200
         db        2,4
         dw        offset InvCGAH
         dw        offset InvCGAV
         dw        offset ReadCGA

                                          ;* 5: 320x200/4 graf
         dw        320,200
         db        2,4
         dw        offset InvCGAH
         dw        offset InvCGAV
         dw        offset ReadCGA

                                          ;* 6: 640x200/2 graf
         dw        640,200
         db        1,4
         dw        offset InvCGAH
         dw        offset InvCGAV
         dw        offset ReadCGA

                                          ;* 7: 80x25 text
         dw        80,25
         db        2,2
         dw        offset InvTXTH
         dw        offset InvTXTV
         dw        offset ReadTXT

                                          ;* 8: 160x200/16 graf.
         dw        160,200
         db        4,4
         dw        offset InvPCJH
         dw        offset InvPCJV
         dw        offset ReadPCJ

                                          ;* 9: 320x200/16 graf.
         dw        320,200
         db        4,4
         dw        offset InvPCJH
         dw        offset InvPCJV
         dw        offset ReadPCJ

                                          ;* 10: 640x200/4 graf.
         dw        640,200
         db        2,4
         dw        offset InvPCJH
         dw        offset InvPCJV
         dw        offset ReadPCJ

                                          ;* 11: intern¡
         dw        80,25
         db        2,2
         dw        offset InvTxtH
         dw        offset InvTXTV
         dw        offset ReadTxt

                                          ;* 12: intern¡
         dw        80,25
         db        2,2
         dw        offset InvTxtH
         dw        offset InvTXTV
         dw        offset ReadTxt

                                          ;* 13: 320x200/16 graf
         dw        320,200
         db        4,0
         dw        offset InvEGAH
         dw        offset InvEGAV
         dw        offset ReadEGA

                                          ;* 14: 640x200/16 graf
         dw        640,200
         db        4,0
         dw        offset InvEGAH
         dw        offset InvEGAV
         dw        offset ReadEGA

                                          ;* 15: 640x350/2 graf
         dw        640,350
         db        1,0
         dw        offset InvEGAH
         dw        offset InvEGAV
         dw        offset ReadEGA

                                          ;* 16: 640x350/16 graf
         dw        640,350
         db        4,0
         dw        offset InvEGAH
         dw        offset InvEGAV
         dw        offset ReadEGA

                                          ;* 17: 640x480/2 graf
         dw        640,480
         db        1,4
         dw        offset InvCGAH
         dw        offset InvCGAV
         dw        offset ReadCGA

                                          ;* 18: 640x480/16 graf
         dw        640,480
         db        4,0
         dw        offset InvEGAH
         dw        offset InvEGAV
         dw        offset ReadEGA

                                          ;* 19: 320x200/256 graf
         dw        320,200
         db        8,4
         dw        offset InvMCGH
         dw        offset InvMCGV
         dw        offset ReadMCG


         EVEN                               ; zaokrouhlen¡ na sudou adresu

buffer   label     byte                     ; diskov˜ buffer

; *****************************************************************************
;
;                         Instalace programu
;
; *****************************************************************************

Instal:
                                          ;* zobrazen¡ £vodn¡ho textu
         mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

                                          ;* rozli¨en¡, zda je karta EGA/VGA
         mov       ah,12h                   ; funkce poskytnut¡ informac¡ EGA
         mov       bx,05e10h                ; podfunkce informac¡
         int       10h                      ; poskytnut¡ informac¡ EGA/VGA
         cmp       bh,2                     ; m¢d displeje 0 nebo 1
         jae       Inst1                    ; chyba - neplatn˜ obsah registru
         cmp       bl,5                     ; maxim ln¡ velikost pamˆti 1 MB
         ja        Inst1                    ; chybn  velikost pamˆti

         inc       byte ptr ds:[ParEGA]     ; p©¡znak videokarty EGA/VGA

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


Soubor0  db        'ANIM0001.SCR',0         ; jm‚no souboru
Soubor1  label     byte




UvTxt    db        'ANIMSCR V1.1 - snimani obrazovky; (c) Miroslav Nemecek',13,10
         db        '======================================================',13,10
         db        '   <Ctrl>-<Print Screen> = ulozeni vyrezu obrazovky',13,10
         db        '$'

code     ENDS
         END       start                    ; startovac¡ adresa

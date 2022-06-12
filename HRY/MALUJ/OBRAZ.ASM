
; *****************************************************************************
;
;                              O B R A Z
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

Old08    dd        0                        ; adresa p–vodn¡ obsluhy INT 08h
Old09    dd        0                        ; adresa p–vodn¡ obsluhy INT 09h
Old28    dd        0                        ; adresa p–vodn¡ obsluhy INT 28h

; -----------------------------------------------------------------------------

NumBuff  dw        0                        ; po‡et bajt– v diskov‚m bufferu

                                          ;* jm‚no souboru
Soubor   db        'A:\',64+14 dup(0)       ; buffer pro adres © a soubor
AdrSoub  dw        0                        ; adresa ‡¡sla souboru

Idents   dw        0                        ; identifikace v˜stupn¡ho souboru

KompCit  dw        0                        ; ‡¡ta‡ shodn‚ho bajtu
KompChar db        0                        ; znak k opakov n¡
KompBNum dw        0                        ; po‡et bajt– v kompresn¡m bufferu
KompBuff db        256 dup(0)               ; kompresn¡ buffer
KompPar  db        1                        ; 1=p©¡znak kompresn¡ho m¢du

VMod     db        16                       ; aktivn¡ videom¢d

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

                                          ;* test opr vnˆnosti videom¢du
         xor       ax,ax
         mov       ds,ax                    ; segment dat BIOS
         mov       si,ds:[44eh]             ; adresa displeje
         mov       al,ds:[449h]             ; aktivn¡ videom¢d
         mov       cs:[VMod],al             ; £schova videom¢du
         and       al,7fh
         cmp       al,13
         je        Screen1
         cmp       al,14
         je        Screen1
         cmp       al,16
         je        Screen1
         cmp       al,18
         je        Screen1
Screen88:jmp       Screen8                  ; neobsluhovan˜ videom¢d
Screen1: mov       bx,0a000h
         mov       es,bx                    ; segment videopamˆti

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
         jc        Screen8                  ; chyba - soubor nelze vytvo©it
         mov       ds:[Idents],ax           ; £schova identifik toru souboru

                                          ;* funkce sn¡m n¡ obrazovky
Screen60:call      Anims                    ; sn¡m n¡ obrazovky

         call      FlushQ                   ; vypr zdnˆn¡ bufferu shody
         call      FlushB                   ; vypr zdnˆn¡ bˆ‘n‚ho bufferu
         call      WritBuff                 ; z pis bufferu na disk

         mov       ah,3eh
         mov       bx,ds:[Idents]           ; identifik tor v˜stupn¡ho souboru
         int       21h                      ; uzav©en¡ souboru

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
         mov       byte ptr cs:[KompPar],1  ; nastaven¡ p©¡znaku komprese
         xor       ax,ax                    ; po‡ te‡n¡ rovina k z pisu
Anims2:  call      ReadEGA                  ; z pis © dku okna
         inc       ax                       ; zv˜¨en¡ ‡¡sla roviny
         cmp       ax,4
         jb        Anims2                   ; nejsou je¨tˆ v¨echny roviny
         clc
Anims9:  ret

; -----------------------------------------------------------------------------
;        €ten¡ skupiny bajt– z videopamˆti EGA do v˜stupn¡ho bufferu
;              (ES:SI=VRAM, AX=rovina)
; -----------------------------------------------------------------------------

ReadEGA:

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di

         mov       di,ax                    ; rovina

                                          ;* nastaven¡ ‡tec¡ho m¢du
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

; ------ videom¢dy 16 (640 x 350) a 18 (640 x 480)

         cmp       byte ptr cs:[VMod],16
         je        ReadEGA1
         cmp       byte ptr cs:[VMod],18
         jne       ReadEGA2
ReadEGA1:mov       cx,80*(350-32)
         call      ReadEG
         jmp       short ReadEGA9

; ------ videom¢d 14 (640x200)

ReadEGA2:cmp       byte ptr cs:[VMod],14
         jne       ReadEGA4
         mov       cx,100                   ; polovi‡n¡ po‡et linek
ReadEGA3:push      cx
         mov       cx,80                    ; d‚lka jedn‚ linky
         call      ReadEG                   ; p©enos sud‚ linky
         push      si
         call      ReadEG                   ; p©enos lich‚ linky
         pop       si
         call      ReadEG                   ; duplikace lich‚ linky
         pop       cx
         loop      ReadEGA3                 ; p©enos dal¨¡ho p ru linek
         jmp       short ReadEGA6

; ------ videom¢d 13 (320x200)

ReadEGA4:mov       cx,100                   ; polovi‡n¡ po‡et linek
ReadEGA5:call      ReadEX                   ; z pis sud‚ linky
         push      si
         call      ReadEX                   ; z pis lich‚ linky
         pop       si
         call      ReadEX                   ; duplikace lich‚ linky
         loop      ReadEGA5

; ------ doplnˆn¡ zbytku © dk–

ReadEGA6:mov       cx,80*(350-32-300)       ; zbyl˜ po‡et linek
         xor       al,al                    ; barva pro rovinu 3
         cmp       di,3                     ; je jasov  rovina 3 ?
         je        ReadEGA7                 ; je rovina 3
         not       al                       ; ostatn¡ roviny 0ffh
ReadEGA7:call      WritB
         loop      ReadEGA7

; ------ standardn¡ nastaven¡ registr–

ReadEGA9:mov       dx,3ceh
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
;        p©enos linky se zdvojn soben¡m (40 bajt– -> 80 bajt–)
; -----------------------------------------------------------------------------

ReadEX   PROC      NEAR

         push      cx
         push      dx
         mov       cx,40
ReadEX0: mov       al,es:[si]
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         mov       dl,ah                    ; £schova bajtu
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         ror       ax,1
         sar       ah,1
         mov       al,ah
         call      WritB
         mov       al,dl
         call      WritB
         inc       si
         loop      ReadEX0
         pop       dx
         pop       cx
         ret

ReadEX   ENDP

; -----------------------------------------------------------------------------
;        p©enos skupiny bajt– EGA (CX bajt–)
; -----------------------------------------------------------------------------

ReadEG   PROC      NEAR

         push      cx
ReadEG0: mov       al,es:[si]
         call      WritB
         inc       si
         loop      ReadEG0
         pop       cx
         ret

ReadEG   ENDP

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


         EVEN                               ; zaokrouhlen¡ na sudou adresu

buffer   label     byte                     ; diskov˜ buffer

; *****************************************************************************
;
;                         Instalace programu
;
; *****************************************************************************

Instal:

; ------ test, zda je karta EGA/VGA

         mov       ah,12h                   ; funkce poskytnut¡ informac¡ EGA
         mov       bx,05e10h                ; podfunkce informac¡
         int       10h                      ; poskytnut¡ informac¡ EGA/VGA
         cmp       bh,2                     ; m¢d displeje 0 nebo 1
         jae       Inst1                    ; chyba - neplatn˜ obsah registru
         cmp       bl,5                     ; maxim ln¡ velikost pamˆti 1 MB
         jbe       Inst2                    ; velikost pamˆti OK

; ------ chyba - nen¡ karta EGA/VGA

Inst1:   mov       dx,offset ErrTxt
         mov       ah,9
         int       21h                      ; zobrazen¡ chybov‚ho textu
         int       20h

; ------ zobrazen¡ £vodn¡ho textu

Inst2:   mov       dx,offset UvTxt          ; £vodn¡ text
         mov       ah,9
         int       21h                      ; zobrazen¡ £vodn¡ho textu

; ------ instalace obsluhy INT 08h

         cli                                ; z kaz p©eru¨en¡

         mov       ax,3508h                 ; funkce poskytnut¡ adresy INT 08h
         int       21h                      ; poskytnut¡ adresy INT 08h
         mov       word ptr [Old08],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [Old08+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset Int08          ; vlastn¡ obsluha INT 08h
         mov       ax,2508h                 ; funkce nastaven¡ adresy INT 08h
         int       21h                      ; nastaven¡ adresy INT 08h

; ------ instalace p©eru¨en¡ INT 09h

         mov       ax,3509h                 ; funkce poskytnut¡ adresy INT 09h
         int       21h                      ; poskytnut¡ adresy INT 09h
         mov       word ptr [old09],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old09+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int09          ; vlastn¡ obsluha INT 09h
         mov       ax,2509h                 ; funkce nastaven¡ adresy INT 09h
         int       21h                      ; nastaven¡ adresy INT 09h

; ------ instalace p©eru¨en¡ INT 28h

         mov       ax,3528h                 ; funkce poskytnut¡ adresy INT 28h
         int       21h                      ; poskytnut¡ adresy INT 28h
         mov       word ptr [old28],bx      ; ulo‘en¡ offsetu adresy
         mov       word ptr [old28+2],es    ; ulo‘en¡ segmentu adresy
         mov       dx,offset int28          ; vlastn¡ obsluha INT 28h
         mov       ax,2528h                 ; funkce nastaven¡ adresy INT 28h
         int       21h                      ; nastaven¡ adresy INT 28h

; ------ instalace p©¡znaku aktivity DOS

         mov       ah,34h
         int       21h                      ; poskytnut¡ p©¡znaku aktivity DOS
         mov       word ptr [aktiv21],bx    ; adresa p©¡znaku aktivity DOS
         mov       word ptr [aktiv21+2],es  ; segment p©¡znaku aktivity DOS

         sti                                ; povolen¡ p©eru¨en¡

         push      cs
         pop       es

; ------ £schova aktivn¡ho adres ©e a disku

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


Soubor0  db        'OBRAZ001.MAL',0         ; jm‚no souboru
Soubor1  label     byte

ErrTxt   db        'Program vyzaduje grafickou kartu EGA/VGA !',13,10,'$'

UvTxt    db        'OBRAZ V1.0 - snimani obrazku; (c) Miroslav Nemecek',13,10
         db        '==================================================',13,10
         db        ' stisknete <Ctrl>-<Print Screen> = ulozeni obrazku',13,10
         db        '$'

code     ENDS
         END       start                    ; startovac¡ adresa

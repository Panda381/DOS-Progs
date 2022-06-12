
; *****************************************************************************
;
;                                Ikonov‚ menu
;
; -----------------------------------------------------------------------------
; n vratovì k¢d:   255 ........ chyba (syst‚mov‚ prostýed¡, pamØœ)
;                  251 ........ nenalezen § dnì adres ý
;                  250 ........ pýeruçen¡ programu ESC (nebo prav‚ tlaŸ. myçi)
;                  100 ........ provedena volba pomoc¡ mezery
;                  1 a§ 10 .... zvolen  kl vesa F1 a§ F10
;                  0 .......... provedena volba pomoc¡ Enter (nebo 2*myç vlevo)
; *****************************************************************************

SIRX     EQU       32                       ; ç¡ýka ikony (bod…)
VYSY     EQU       32                       ; vìçka ikony (bod…)
COLS     EQU       16                       ; poŸet barev ikony
COLSB    EQU       4                        ; poŸet bit… na bod
VyskaM   EQU       10                       ; vìçka menu ve spodn¡ Ÿ sti
SeznamS  EQU       9                        ; poŸet bajt… na polo§ku seznamu
MaxDisk  EQU       32                       ; maxim ln¡ poŸet disk…
HercSir  EQU       90                       ; ç¡ýka ý dku pro Hercules
SeznamM  EQU       6400                     ; maxim ln¡ poŸet polo§ek seznamu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code,ss:Zasob

; ------ inicializace registr…

Start:   push      cs
         pop       ds
         mov       ds:[SegPSP],es           ; segment PSP

; ------ inicializace syst‚mov‚ho prostýed¡
; sem se vrac¡ po chybØ nastaven¡ adres ýe

Start10: call      ParEnv                   ; inicializace syst‚mov‚ho prostýed¡
         jnc       Start12                  ; prostýed¡ je OK
         mov       dx,offset EnvTxt         ; text - chyba prostýed¡
         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         mov       ax,4cffh
         int       21h                      ; konec s chybou

; ------ pýedefinov n¡ obsluhy INT 24h

Start12: mov       dx,offset INT24
         mov       ax,2524h
         int       21h                      ; pýedefinov n¡ obsluhy INT 24h

; ------ pýedefinov n¡ obsluhy INT 23h

         mov       dx,offset INT23
         mov       ax,2523h
         int       21h                      ; pýedefinov n¡ obsluhy INT 23h

; ------ £schova aktu ln¡ho disku a upýesnØn¡ hled n¡ pro diskety A:, B:

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         mov       ds:[HomeDisk],al         ; £schova domovsk‚ho disku
         cmp       al,MaxDisk               ; je to platnì disk ?
         jae       Start21                  ; nen¡ to platnì disk
         mov       ah,0
         xchg      ax,bx                    ; BX <- aktivn¡ disk
         mov       byte ptr ds:[bx+MaskDisk],1 ; aktivn¡ disk bude v§dy hledanì

; ------ inicializace videokarty (nastaven¡ videom¢du)

Start21: call      IniCard                  ; inicializace videokarty

; ------ inicializace palet displeje

         call      InitPal                  ; inicializace palet displeje

; ------ inicializace myçi (z…stane vypnut )

         call      InitMous                 ; inicializace myçi

; ------ vymaz n¡ obrazovky (jen Ÿ st bez spodn¡ho okraje) - myç je vypnut 

         call      Vymaz                    ; vymaz n¡ obrazovky

; ------ naŸten¡ seznamu program…

         call      InitSezn                 ; naŸten¡ seznamu program…
         cmp       word ptr ds:[SeznamN],0  ; bylo nØco nalezeno ?
         jne       Start27                  ; jsou nØjak‚ polo§ky
         mov       dl,251                   ; chyba - nic nenalezeno
         jmp       Start9                   ; nebylo nic nalezeno

; ------ zobrazen¡ aktivn¡ str nky seznamu

Start27: call      DispSezn                 ; zobrazen¡ aktivn¡ str nky

; ------ vypr zdnØn¡ bufferu kl vesnice

Start28: mov       ah,1
         int       16h
         jz        Start29
         mov       ah,0
         int       16h
         jmp       short Start28

; ------ vypr zdnØn¡ Ÿ¡taŸe stisk… lev‚ho tlaŸ¡tka myçi

Start29: test      byte ptr ds:[Param],2    ; je myç nainstalov na ?
         jz        Start3                   ; myç nen¡ nainstalov na
         xor       bx,bx                    ; lev‚ tlaŸ¡tko myçi
         mov       al,5
         call      Mouse                    ; test stisk… lev‚ho tlaŸ¡tka myçi

; ------ Ÿasovan‚ zobrazen¡ kurzoru

Start3:  call      MouseOn                  ; zapnut¡ kurzoru myçi
         xor       ax,ax
         mov       es,ax
         test      byte ptr es:[46ch],6
         jnz       Start32                  ; zapnut¡ kurzoru
         call      VypKurz                  ; vypnut¡ kurzoru
         jmp       short Start34

Start32: call      ZapKurz                  ; zapnut¡ kurzoru

; ------ test, zda m…§e bìt obsluha myçi

Start34: test      byte ptr ds:[Param],2    ; je myç nainstalov na ?
         jnz       Start340                 ; myç je nainstalov na
         jmp       Strt3418                 ; myç nen¡ nainstalov na

; ------ test, zda bylo stisknuto lev‚ tlaŸ¡tko myçi

Start340:mov       al,5
         xor       bx,bx                    ; lev‚ tlaŸ¡tko myçi
         call      Mouse                    ; test lev‚ho tlaŸ¡tka myçi
         or        bx,bx                    ; bylo lev‚ tlaŸ¡tko myçi ?
         jnz       Strt3400                 ; bylo lev‚ tlaŸ¡tko myçi
         jmp       Strt3417                 ; nebylo lev‚ tlaŸ¡tko myçi

; ------ £prava souýadnic stisku tlaŸ¡tka myçi

Strt3400:shr       cx,1
         shr       cx,1
         shr       cx,1                     ; bajtov  pozice kurzoru

; ------ ovl d n¡ menu pomoc¡ myçi

         mov       ax,ds:[Vyska]            ; vìçka obrazovky v link ch
         sub       ax,VyskaM                ; odeŸten¡ vìçky menu
         cmp       ax,dx                    ; je ovl d n¡ menu ?
         ja        Strt3411                 ; nen¡ ovl d n¡ menu

         mov       ax,4900h                 ; PageUp
         sub       cl,10
         jb        Strt3410

         mov       ah,51h                   ; PageDown
         sub       cl,12
         jb        Strt3410

         mov       ax,1c0dh                 ; Enter
         sub       cl,13
         jb        Strt3410

         mov       ax,3920h                 ; mezera
         sub       cl,15
         jb        Strt3410

         mov       ax,3b00h                 ; F1
         sub       cl,9
         jb        Strt3410

         mov       ax,4400h                 ; F10
         sub       cl,11
         jb        Strt3410

         mov       ax,11bh                 ; Esc
Strt3410:jmp       short Strt3419

; ------ pýepoŸet souýadnice Y na ý dek

Strt3411:xchg      ax,dx                    ; AX <- souýadnice myçi Y
         sub       ax,ds:[TopY]             ; odeŸten¡ poŸ tku
         jnc       Strt3412
         xor       ax,ax                    ; omezen¡ pýi podteŸen¡
Strt3412:xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[IncY]       ; vìpoŸet ý dku
         cmp       ax,ds:[NumY]             ; je Ÿ¡slo OK ?
         jb        Strt3413                 ; je to OK
         mov       ax,ds:[NumY]             ; poŸet ý dk…
         dec       ax                       ; Ÿ¡slo posledn¡ho ý dku
Strt3413:mul       word ptr ds:[NumX]       ; pýepoŸet na Ÿ¡slo polo§ky
         xchg      ax,cx                    ; CX <- Ÿ¡slo polo§ky, AX <- pozice

; ------ pýepoŸet souýadnice X na pozici

         sub       ax,ds:[TopX]             ; odeŸten¡ poŸ tku
         jnc       Strt3414
         xor       ax,ax                    ; omezen¡ pýi podteŸen¡
Strt3414:xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[IncX]       ; vìpoŸet pozice
         cmp       ax,ds:[NumX]             ; je Ÿ¡slo OK ?
         jb        Strt3415
         mov       ax,ds:[NumX]             ; poŸet pozic
         dec       ax                       ; Ÿ¡slo posledn¡ pozice

; ------ Ÿ¡slo nov‚ polo§ky

Strt3415:add       ax,cx                    ; AX <- Ÿ¡slo polo§ky
         add       ax,ds:[SeznamT]          ; AX <- Ÿ¡slo polo§ky
         cmp       ax,ds:[SeznamN]          ; je pýeteŸen¡ Ÿ¡sla
         jb        Strt3416
         mov       ax,ds:[SeznamN]          ; poŸet polo§ek
         dec       ax                       ; posledn¡ polo§ka

; ------ nastaven¡ nov‚ polo§ky

Strt3416:call      VypKurz                  ; vypnut¡ kurzoru
         xchg      ax,ds:[SeznamA]          ; nov  aktivn¡ polo§ka
         call      ZapKurz                  ; zapnut¡ kurzoru
         cmp       ax,ds:[SeznamA]          ; je to ji§ aktivn¡ polo§ka ?
         jne       Strt3417                 ; polo§ka se zmØnila
         mov       ax,1c0dh                 ; je druhì stisk - jako Enter
         jmp       short Strt3419

; ------ test, zda bylo stisknuto prav‚ tlaŸ¡tko myçi

Strt3417:mov       al,5
         mov       bx,1                     ; prav‚ tlaŸ¡tko myçi
         call      Mouse                    ; test prav‚ho tlaŸ¡tka myçi
         or        bx,bx                    ; bylo prav‚ tlaŸ¡tko myçi ?
         jnz       INT23                    ; pýeruçen¡ pravìm tlaŸ¡tkem

; ------ test, zda je znak z kl vesnice (sem se sk Ÿe z obsluhy kl ves !)

Strt3418:mov       ah,1
         int       16h
         jnz       Str34182                 ; je kl vesa
         jmp       Start3

Str34182:mov       ah,0
         int       16h

Strt3419:call      MouseOff                 ; vypnut¡ kurzoru myçi

         mov       dl,0                     ; n vratovì k¢d pro Enter
         cmp       al,13                    ; je Enter ?
         je        Start9                   ; n vrat s Enter

         mov       dl,ah                    ; DL <- SCAN k¢d kl vesy
         sub       dl,3ah                   ; je kl vesa F1 a§ F10 ?
         jbe       Start342                 ; nen¡ kl vesa F1 a§ F10
         cmp       dl,10
         jbe       Start9                   ; je kl vesa F1 a§ F10

Start342:mov       dl,100                   ; n vratovì k¢d pro mezeru
         cmp       al," "                   ; m…§e bìt rychlovyhled v n¡ ?
         ja        Start35                  ; je rychlovyhled v n¡
         je        Start9                   ; n vrat s mezerou
         cmp       al,8                     ; BS tak‚ neruç¡
         je        Start35                  ; je BS
         mov       byte ptr ds:[QSrcN],0    ; zruçen¡ rychlovyhled v n¡

Start35: or        ax,ax                    ; Ctrl-Break
         jz        INT23
         cmp       al,27                    ; Esc
         jne       Klav1

; ------ pýeruçen¡ programu ESC nebo Ctrl-Break

INT23:   mov       dl,250                   ; pý¡znak pýeruçen¡

; ------ nastaven¡ textov‚ho videom¢du (DL=n vratovì k¢d)

Start9:  push      dx

         push      cs
         pop       ds

         mov       ah,0fh
         call      Int10                    ; poskytnut¡ videom¢du
         cmp       al,7                     ; je videom¢d 7 Hercules ?
         je        Start92                  ; je Hercules
         mov       al,3                     ; jinak videom¢d CGA
Start92: mov       ah,0
         call      Int10                    ; nastaven¡ textov‚ho videom¢du

         pop       ax

; ------ chyba - nenalezen § dnì adres ý

         cmp       al,251                   ; chyba nenalezen¡ adres ýe ?
         jne       Start94
         push      ax
         mov       dx,offset FndTxt         ; text - nic nenalezeno
         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         pop       ax

; ------ ulo§en¡ jm‚na aktivn¡ho programu do syst‚mov‚ho prostýed¡

Start94: push      ax
         call      OutFile                  ; ulo§en¡ jm‚na programu
         pop       ax
         jnc       Start95                  ; operace OK

         mov       dx,offset EnvTxt         ; text - chyba prostýed¡
         mov       ah,9
         int       21h                      ; zobrazen¡ textu
         mov       al,255                   ; syst‚mov  chyba pýeteŸen¡

; ------ nastaven¡ zvolen‚ho disku a adres ýe

Start95: cmp       al,100                   ; je chyba nebo mezera ?
         jae       Start96                  ; je chyba nebo mezera

         push      ax
         mov       dl,ds:[ParDisk0]         ; jm‚no c¡lov‚ho disku
         sub       dl,"A"                   ; Ÿ¡slo disku
         mov       ah,0eh
         int       21h                      ; nastaven¡ disku

         mov       ax,SeznamS               ; poŸet bajt… na polo§ku
         mul       word ptr ds:[SeznamA]    ; offset aktivn¡ polo§ky
         add       ax,offset Seznam         ; adresa polo§ky v seznamu
         xchg      ax,si                    ; SI <- adresa polo§ky v seznamu
         mov       di,ds:[CestaN]           ; adresa konce cesty
         call      GetName                  ; naŸten¡ jm‚na adres ýe

         mov       dx,offset Cesta+2        ; buffer cesty
         mov       ah,3bh
         int       21h                      ; nastaven¡ adres ýe
         pop       ax
         jnc       Start96

         mov       dl,ds:[HomeDisk]         ; domovskì disk
         mov       ah,0eh
         int       21h                      ; nastaven¡ p…vodn¡ho disku
         jmp       Start10                  ; restart programu

; ------ n vrat z programu (AL=n vratovì k¢d)

Start96: mov       ah,4ch
         int       21h

; ------ kurzor vlevo

Klav1:   mov       bx,ds:[SeznamA]          ; aktivn¡ polo§ka
         cmp       ax,0f00h                 ; Shift-Tab
         je        Klav20
         cmp       ax,4b00h                 ; kurzor vlevo
         jne       Klav21
Klav20:  dec       bx                       ; posun kurzoru vlevo

; ------ kurzor vpravo

Klav21:  cmp       ax,0f09h
         je        Klav212
         cmp       ax,4d00h
         jne       Klav22
Klav212: inc       bx                       ; posun kurzoru vpravo

; ------ kurzor dol…

Klav22:  cmp       ax,5000h
         jne       Klav23
         add       bx,ds:[NumX]             ; posun kurzoru dol…

; ------ kurzor nahoru

Klav23:  cmp       ax,4800h
         jne       Klav24
         sub       bx,ds:[NumX]             ; posun kurzoru nahoru

; ------ Home

Klav24:  cmp       ax,4700h
         jne       Klav25
         mov       bx,ds:[SeznamT]          ; kurzor na poŸ tek str nky

; ------ End

Klav25:  cmp       ax,4f00h
         jne       Klav26
         mov       bx,ds:[SeznamT]          ; poŸ tek str nky
         add       bx,ds:[NumXY]            ; konec str nky + 1
         dec       bx                       ; konec str nky

; ------ PageUp

Klav26:  cmp       ax,4900h
         jne       Klav27
         sub       bx,ds:[NumXY]            ; posun o str nku zpØt

; ------ PageDown

Klav27:  cmp       ax,5100h
         jne       Klav28
         add       bx,ds:[NumXY]            ; posun o str nku dol…

; ------ BackSpace - zruçen¡ znaku rychlovyhled v n¡

Klav28:  cmp       al,8                     ; je BackSpace ?
         jne       Klav3                    ; nen¡
         cmp       byte ptr ds:[QSrcN],0    ; je rychlovyhled v n¡ ?
         je        Klav3                    ; nen¡ rychlovyhled v n¡
         dec       byte ptr ds:[QSrcN]      ; sn¡§en¡ rychlovyhled v n¡

; ------ rychlovyhled v n¡ stiskem p¡smene

Klav3:   cmp       al," "
         jbe       Klav4                    ; nen¡ p¡smeno

         cmp       byte ptr ds:[QSrcN],8    ; je buffer ji§ plnì ?
         jb        Klav31                   ; buffer jeçtØ nen¡ plnì
         mov       byte ptr ds:[QSrcN],0    ; vynulov n¡ bufferu

Klav31:  mov       bp,ds:[QSrcN]            ; poŸet p¡smen rychlovyhled v n¡
         inc       byte ptr ds:[QSrcN]      ; zvìçen¡ Ÿ¡taŸe rychlovyhled v n¡

         push      ax
         mov       ax,SeznamS               ; poŸet bajt… na polo§ku
         mul       bx                       ; offset aktivn¡ polo§ky
         add       ax,offset Seznam         ; adresa aktivn¡ polo§ky
         xchg      ax,si                    ; SI <- adresa aktivn¡ polo§ky
         pop       ax

         call      UpCase                   ; konverze AL na velk‚ p¡smeno

         or        bp,bp                    ; je prvn¡ znak rychlovyhled v n¡ ?
         jnz       Klav35                   ; nen¡ prvn¡ znak rychlovyhled v n¡
Klav33:  mov       si,offset Seznam-SeznamS ; adresa polo§ky (zaŸ tek seznamu)
         xor       bx,bx                    ; ukazatel Ÿ¡sla polo§ky
         dec       bx                       ; pýednastaven¡ - 1
Klav34:  add       si,SeznamS               ; zvìçen¡ adresy polo§ky
         inc       bx                       ; zvìçen¡ ukazatele Ÿ¡sla polo§ky
Klav35:  cmp       bx,ds:[SeznamN]          ; je jeçtØ platn  polo§ka ?
         jae       Klav38                   ; nen¡ platn  polo§ka
         cmp       al,ds:[bp+si+1]          ; je to hledan  polo§ka ?
         ja        Klav34                   ; nen¡ hledan  polo§ka - dalç¡
         je        Klav38                   ; nalezeno - OK
         mov       byte ptr ds:[QSrcN],0    ; vynulov n¡ bufferu
         or        bp,bp                    ; bylo to prvn¡ p¡smeno ?
         jz        Klav38                   ; bylo to prvn¡ p¡smeno

         mov       byte ptr ds:[QSrcN],1    ; vynulov n¡ bufferu
         xor       bp,bp
         jmp       short Klav33             ; nalezen¡ polo§ky

Klav38:  jmp       short Klav9


Klav4:

; ------ Ctrl-PageUp, Ctrl-Home zaŸ tek seznamu

Klav8:   cmp       ax,7700h                 ; Ctrl-Home
         je        Klav90
         cmp       ax,8400h                 ; Ctrl-PageUp
         je        Klav90

; ------ Ctrl-PageDown, Ctrl-End konec seznamu

         cmp       ax,7500h                 ; Ctrl-End
         je        Klav912
         cmp       ax,7600h                 ; Ctrl-PageDown
         je        Klav912

; ------ omezen¡ aktivn¡ polo§ky BX

Klav9:   or        bx,bx                    ; je podteŸen¡ kurzoru ?
         jns       Klav91                   ; nen¡ podteŸen¡ kurzoru
Klav90:  xor       bx,bx                    ; omezen¡ kurzoru pýi podteŸen¡
Klav91:  cmp       bx,ds:[SeznamN]          ; je kurzor za koncem ?
         jb        Klav92                   ; kurzor je OK
Klav912: mov       bx,ds:[SeznamN]          ; poŸet polo§ek celkem
         or        bx,bx                    ; je nØjak  polo§ka ?
         jz        Klav92                   ; nen¡ § dn  polo§ka
         dec       bx                       ; omezen¡ na posledn¡ polo§ku

; ------ vìpoŸet nov‚ poŸ teŸn¡ polo§ky -> AX

Klav92:  mov       ax,bx                    ; AX <- aktivn¡ polo§ka
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[NumXY]      ; vìpoŸet Ÿ¡sla str nky
         mul       word ptr ds:[NumXY]      ; vìpoŸet poŸ teŸn¡ polo§ky

; ------ test, zda je zmØna poŸ tku

         cmp       ax,ds:[SeznamT]          ; je zmØna poŸ tku ?
         je        Klav96                   ; nen¡ zmØna poŸ tku
         call      VypKurz                  ; vypnut¡ kurzoru
         mov       ds:[SeznamA],bx          ; nov  aktivn¡ polo§ka
         mov       ds:[SeznamT],ax          ; novì poŸ tek seznamu
         call      DispSezn                 ; nov‚ zobrazen¡ seznamu
         jmp       short Klav97

; ------ test, zda je zmØna kurzoru BX

Klav96:  cmp       bx,ds:[SeznamA]          ; je zmØna aktivn¡ polo§ky ?
         je        Klav98                   ; nen¡ zmØna poŸ tku
         call      VypKurz                  ; vypnut¡ kurzoru
         mov       ds:[SeznamA],bx          ; nov  aktivn¡ polo§ka
Klav97:  call      ZapKurz                  ; zapnut¡ kurzoru
Klav98:  jmp       Start34

; -----------------------------------------------------------------------------
;        inicializace myçi (kurzor myçi bude ponech n vypnutì)
; -----------------------------------------------------------------------------
;þ
InitMous PROC      NEAR

         and       byte ptr ds:[Param],not 2+4 ; pý¡znak, §e nen¡ myç

; ------ z kaz obsluhy pro Hercules

         cmp       byte ptr ds:[TypCard],1  ; je Hercules ?
         je        IniMous9                 ; je Hercules - z kaz

; ------ test platnosti adresy INT 33h

         mov       ax,3533h
         int       21h                      ; poskytnut¡ adresy INT 33h
         cmp       bx,-2
         je        IniMous9                 ; neplatn  adresa INT 33h
         mov       ax,es
         cmp       ax,70h
         jb        IniMous9                 ; neplatn  adresa INT 33h

; ------ test instalace myçi

         mov       al,0
         call      Mouse                    ; reset a test myçi
         inc       ax
         jnz       IniMous9                 ; nen¡ myç
         or        byte ptr ds:[Param],2    ; pý¡znak instalace myçi

; ------ definice okna pro myç

         xor       cx,cx
         mov       dx,640-1                 ; ç¡ýka obrazovky
         mov       al,7
         call      Mouse                    ; horizont ln¡ rozmØry obrazovky
         xor       cx,cx
         mov       dx,ds:[Vyska]            ; vìçka obrazovky
         dec       dx                       ; posledn¡ linka obrazovky
         mov       al,8
         call      Mouse                    ; vertik ln¡ rozmØry obrazovky

; ------ definice obr zku myçi

         mov       al,9
         xor       bx,bx
         xor       cx,cx
         mov       dx,offset KurzMous       ; obr zek kurzoru myçi
         push      ds
         pop       es
         call      Mouse                    ; definice obr zku kurzoru myçi

; ------ definice polohy kurzoru myçi (doprostýed obrazovky)

         mov       cx,640/2
         mov       dx,ds:[Vyska]            ; vìçka obrazovky
         shr       dx,1                     ; stýed obrazovky
         mov       al,4
         call      Mouse                    ; nastaven¡ pozice kurzoru my¨i

; ------ vypr zdØn¡ Ÿ¡taŸe stisk… tlaŸ¡tek myçi

         mov       al,5
         xor       bx,bx                    ; lev‚ tlaŸ¡tko
         call      Mouse                    ; test lev‚ho tlaŸ¡tka

         mov       al,5
         mov       bx,1                     ; prav‚ tlaŸ¡tko
         call      Mouse                    ; test prav‚ho tlaŸ¡tka

IniMous9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru myçi
; -----------------------------------------------------------------------------

MouseOn  PROC      NEAR

         test      byte ptr ds:[Param],4    ; je kurzor myçi ji§ zapnut ?
         jnz       MouseOn2                 ; kurzor myçi je ji§ zapnut
         or        byte ptr ds:[Param],4    ; pý¡znak zapnut¡ kurzoru myçi
         test      byte ptr ds:[Param],2    ; je myç nainstalov na ?
         jz        MouseOn2                 ; myç nen¡ nainstalov na
         push      ax
         mov       al,1
         call      Mouse                    ; zapnut¡ kurzoru
         pop       ax
MouseOn2:ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru myçi
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

         test      byte ptr ds:[Param],4    ; je kurzor myçi ji§ zapnut ?
         jz        MouseOf2                 ; kurzor myçi nen¡ zapnut
         and       byte ptr ds:[Param],not 4 ; pý¡znak vypnut¡ kurzoru myçi
         test      byte ptr ds:[Param],2    ; je myç nainstalov na ?
         jz        MouseOf2                 ; myç nen¡ nainstalov na
         push      ax
         mov       al,2
         call      Mouse                    ; vypnut¡ kurzoru
         pop       ax
MouseOf2:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        obsluha myçi (INT 33h)
; -----------------------------------------------------------------------------

Mouse    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         sti
         mov       ah,0
         int       33h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Mouse    ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ seznamu program… (aktivn¡ str nka)
; -----------------------------------------------------------------------------
;þ
DispSezn PROC      NEAR

; ------ vymaz n¡ obrazovky

         call      Vymaz                    ; vymaz n¡ obrazovky

; ------ ukazatel polo§ek -> SI

         mov       ax,SeznamS               ; poŸet bajt… na polo§ku
         mul       word ptr ds:[SeznamT]    ; offset poŸ teŸn¡ polo§ky
         add       ax,offset Seznam         ; adresa polo§ky v seznamu
         xchg      ax,si                    ; SI <- adresa polo§ky v seznamu

; ------ poŸet polo§ek k naŸten¡ -> BP

         mov       bp,ds:[SeznamN]          ; poŸet polo§ek v seznamu
         sub       bp,ds:[SeznamT]          ; poŸet zbylìch polo§ek
         cmp       bp,ds:[NumXY]            ; zbìv  jeçtØ dost polo§ek ?
         jbe       DispSzn1                 ; je ji§ posledn¡ str nka
         mov       bp,ds:[NumXY]            ; omezen¡ poŸtu polo§ek

; ------ ukazatel ikony na displeji -> BX, DX

DispSzn1:mov       dx,ds:[TopY]             ; ukazatel linek na displeji
DispSzn2:mov       bx,ds:[TopX]             ; ukazatel pozice na displeji
         mov       cx,ds:[NumX]             ; poŸet polo§ek horizont lnØ

; ------ sn¡§en¡ Ÿ¡taŸe polo§ek

DispSzn3:or        bp,bp                    ; bude dalç¡ polo§ka ?
         jnz       DispSzn4                 ; bude dalç¡ polo§ka
         ret

DispSzn4:dec       bp                       ; sn¡§en¡ Ÿ¡taŸe polo§ek

; ------ £schova registr…

         push      bx
         push      cx
         push      dx
         push      si

; ------ vynulov n¡ bufferu ikony

         push      ds
         pop       es

         cld
         mov       di,offset IcoBuff        ; buffer dat ikony
         mov       bx,VYSY/2                ; poŸet linek / 2
DispSz42:mov       al,0f0h                  ; b¡l +Ÿern 
         mov       cx,SIRX/2
         rep       stosb                    ; lich  linka
         mov       al,0fh                   ; Ÿern +b¡l 
         mov       cl,SIRX/2
         rep       stosb                    ; sud  linka
         dec       bx
         jnz       DispSz42                 ; dalç¡ linka

; ------ pý¡prava jm‚na ikony k naŸten¡ (ze spoleŸn‚ho adres ýe _ICO)

         mov       al,ds:[HomeDisk]         ; domovskì disk
         add       al,"A"                   ; oznaŸen¡ disku
         mov       ds:[Cesta],al            ; disk domovsk‚ho adres ýe
         mov       di,ds:[CestaN]           ; adresa konce cesty
         mov       ax,offset ICOAdr         ; adres ý ikon
         call      GetTxt                   ; naŸten¡ textu adres ýe
         call      GetName                  ; naŸten¡ jm‚na ikony
         mov       ax,offset ICOExt         ; pý¡pona souboru ikony
         call      GetTxt                   ; naŸten¡ textu pý¡pony

; ------ otevýen¡ souboru ikony

         mov       dx,offset Cesta          ; jm‚no souboru ikony
         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru ikony
         jnc       DispSz43                 ; soubor nalezen OK

; ------ pý¡prava Ÿ¡sla disku

         cld
         lodsb                              ; Ÿ¡slo disku * 8
         dec       si                       ; n vrat zaŸ tku polo§ky
         shr       al,1
         shr       al,1
         shr       al,1                     ; Ÿ¡slo disku
         add       al,"A"                   ; oznaŸen¡ disku
         mov       ds:[Cesta],al            ; oznaŸen¡ disku

; ------ pý¡prava jm‚na ikony k naŸten¡ (z adres ýe programu)

         mov       di,ds:[CestaN]           ; adresa konce cesty
         call      GetName                  ; naŸten¡ jm‚na adres ýe
         mov       al,"\"                   ; oddØlovaŸ cesty
         stosb                              ; ulo§en¡ oddØlovaŸe
         call      GetName                  ; naŸten¡ jm‚na ikony
         mov       ax,offset ICOExt         ; pý¡pona souboru ikony
         call      GetTxt                   ; naŸten¡ textu pý¡pony

; ------ otevýen¡ ikony v adres ýi programu

         mov       dx,offset Cesta          ; jm‚no souboru ikony
         mov       ax,3d00h
         int       21h                      ; otevýen¡ souboru ikony
         jc        DispSz44                 ; soubor nenalezen
DispSz43:xchg      ax,bx                    ; BX <- identifik tor souboru

; ------ naŸten¡ souboru ikony

         mov       dx,offset SoubICO        ; buffer souboru ikony
         mov       cx,offset(SoubICO2-SoubICO) ; velikost souboru ikony
         mov       ah,3fh
         int       21h                      ; naŸten¡ souboru ikony

; ------ uzavýen¡ souboru ikony

         mov       ah,3eh
         int       21h                      ; uzavýen¡ souboru ikony

; ------ n vrat registr…

DispSz44:pop       si
         pop       dx
         pop       cx
         pop       bx

; ------ zobrazen¡ souboru ikony

         push      bx
         push      dx
         cmp       byte ptr ds:[TypCard],4  ; je videokarta VGA ?
         jb        DispSz45                 ; nen¡ videokarta VGA
         inc       bx
         inc       bx                       ; vystýedØn¡ ikony pro VGA
DispSz45:call      DispIcon                 ; zobrazen¡ ikony
         pop       dx
         pop       bx

; ------ zobrazen¡ jm‚na ikony

         push      si
         push      bx
         push      cx
         push      dx

         add       dx,VYSY+1                ; linka pod ikonou
         cld
         lodsb
         and       ax,7                     ; d‚lka jm‚na souboru - 1
         inc       ax                       ; d‚lka jm‚na souboru
         xchg      ax,cx                    ; CX <- d‚lka jm‚na souboru
         mov       ax,8                     ; maxim ln¡ d‚lka jm‚na souboru
         sub       ax,cx                    ; zbytek na okraje
         shr       ax,1                     ; polovina na okraj
         add       bx,ax                    ; poŸ teŸn¡ pozice k zobrazen¡

         mov       ah,0fh                   ; barva textu (pozor, pou§¡v  se
                                            ; na identifikaci u Hercules a CGA!)
DispSz46:cld
         lodsb                              ; naŸten¡ znaku k zobrazen¡
         call      DispChr                  ; zobrazen¡ znaku AL
         loop      DispSz46                 ; dalç¡ znak

         pop       dx
         pop       cx
         pop       bx
         pop       si

; ------ posun na dalç¡ polo§ku

         add       si,SeznamS               ; adresa dalç¡ polo§ky
         add       bx,ds:[IncX]             ; zvìçen¡ ukazatele pozice
         dec       cx                       ; Ÿ¡taŸ ikon na ý dku
         jz        DispSzn5                 ; jsou ji§ vçechny ikony
         jmp       DispSzn3                 ; dalç¡ ikona

DispSzn5:add       dx,ds:[IncY]             ; zvìçen¡ ukazatele ý dku
         jmp       DispSzn2                 ; dalç¡ ý dek

DispSezn ENDP

; -----------------------------------------------------------------------------
;        pýenesen¡ textu DS:AX s d‚lkou a nulou na konci do bufferu ES:DI
; -----------------------------------------------------------------------------

GetTxt   PROC      NEAR

         push      ax
         push      si

         cld
         xchg      ax,si                    ; SI <- text
         lodsb                              ; naŸten¡ d‚lky textu
         mov       ah,0
         xchg      ax,cx                    ; CX <- d‚lka textu
         rep       movsb                    ; pýenos textu
         mov       byte ptr es:[di],0       ; koncov  0

         pop       si
         pop       ax
         ret

GetTxt   ENDP

; -----------------------------------------------------------------------------
;        pýenesen¡ jm‚na souboru DS:SI do bufferu ES:DI
; -----------------------------------------------------------------------------

GetName  PROC      NEAR

         push      ax
         push      cx
         push      si

         cld
         lodsb                              ; AL <- parametry souboru
         and       ax,7                     ; d‚lka jm‚na souboru - 1
         inc       ax                       ; d‚lka jm‚na souboru
         xchg      ax,cx                    ; CX <- d‚lka jm‚na souboru
         rep       movsb                    ; pýenos jm‚na souboru
         mov       byte ptr es:[di],0       ; koncov  0

         pop       si
         pop       cx
         pop       ax
         ret

GetName  ENDP

; -----------------------------------------------------------------------------
;        naŸten¡ seznamu program…
; -----------------------------------------------------------------------------
;þ
InitSezn PROC      NEAR

         push      ds
         pop       es

; ------ inicializace ukazatel…

         mov       word ptr ds:[SeznamN],0  ; nen¡ § dnì soubor
         mov       word ptr ds:[SeznamT],0  ; prvn¡ zobrazen  polo§ka
         mov       word ptr ds:[SeznamA],0  ; aktivn¡ zobrazen  polo§ka

; ------ naŸten¡ aktu ln¡ho adres ýe

         mov       dl,0                     ; aktivn¡ disk
         mov       si,offset Cesta+3        ; buffer k naŸten¡ adres ýe
         mov       ah,47h
         int       21h                      ; naŸten¡ adres ýe

; ------ nalezen¡ konce cesty

         push      ds
         pop       es                       ; ES <- datovì segment
         mov       al,0                     ; hledanì bajt konce cesty
         mov       di,offset Cesta          ; buffer cesty
         cld
         mov       cx,92                    ; maxim ln¡ d‚lka cesty
         repne     scasb                    ; nalezen¡ konce cesty
         cmp       byte ptr ds:[di-2],"\"   ; je ji§ koncov  "\" ?
         jne       InitSzn2                 ; je ji§ koncov  "\"
         dec       di                       ; n vrat zpØt
InitSzn2:mov       byte ptr ds:[di-1],"\"   ; oddØlovaŸ cesty
         mov       ds:[CestaN],di           ; £schova adresy konce cesty

; ------ pý¡prava k vyhled v n¡ adres ý…

         mov       ax,".*"                  ; bude se hledat "*."
         stosw
         mov       al,0
         stosb

; ------ nastaven¡ prvn¡ho disku - 1

         mov       byte ptr ds:[Cesta],"A"-1 ; oznaŸen¡ prvn¡ho disku

; ------ zvìçen¡ Ÿ¡sla disku a test, zda je disk povolen

InitSzn3:inc       byte ptr ds:[Cesta]      ; zvìçen¡ Ÿ¡sla disku
         mov       bl,ds:[Cesta]            ; oznaŸen¡ disku
         sub       bl,"A"                   ; Ÿ¡slo disku
         mov       bh,0
         cmp       bl,MaxDisk               ; je jeçtØ platn‚ Ÿ¡slo disku ?
         jb        InitSz32                 ; je jeçtØ platn‚ Ÿ¡slo disku
         jmp       InitSzn5                 ; konec naŸ¡t n¡

InitSz32:cmp       byte ptr ds:[bx+MaskDisk],0 ; je disk povolen ?
         je        InitSzn3                 ; disk nen¡ povolen

; ------ test platnosti disku

         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         push      ax                       ; £schova aktivn¡ho disku v AL
         mov       dl,ds:[Cesta]            ; po§adovanì disk
         sub       dl,"A"                   ; Ÿ¡slo po§adovan‚ho disku
         mov       ah,0eh
         push      dx                       ; £schova po§adovan‚ho disku v DL
         int       21h                      ; nastaven¡ po§adovan‚ho disku
         mov       ah,19h
         int       21h                      ; poskytnut¡ aktivn¡ho disku
         pop       dx                       ; n vrat po§adovan‚ho disku -> DL
         cmp       al,dl                    ; souhlas¡ disk ?
         pop       dx                       ; DL<-n vrat p…vodn¡ho aktiv. disku
         pushf
         mov       ah,0eh
         int       21h                      ; n vrat p…vodn¡ho aktivn¡ho disku
         popf
         jne       InitSzn3                 ; disk nen¡ platnì

; ------ nastaven¡ adresy DTA

         mov       dx,offset DTA            ; buffer DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ vyhled n¡ prvn¡ho/dalç¡ho adres ýe

         mov       ah,4eh
         mov       cx,10h                   ; atributy (adres ýe, ne skryt‚)
         mov       dx,offset Cesta
InitSzn4:int       21h                      ; nalezen¡ adres ýe
         jc        InitSzn3                 ; nen¡ dalç¡ adres ý
         mov       ah,4fh                   ; funkce hled n¡ d le
         test      byte ptr ds:[SoubAtr],10h ; je to adres ý ?
         jz        InitSzn4                 ; nen¡ adres ý
         cmp       byte ptr ds:[SoubNam],"." ; je to platnì adres ý ?
         je        InitSzn4
         cmp       byte ptr ds:[SoubNam],"_" ; to jsou pracovn¡ adres ýe
         je        InitSzn4                 ; je pracovn¡ adres ý
         cmp       byte ptr ds:[SoubNam],0  ; pro jistotu (zp…sobilo by probl‚my)
         je        InitSzn4

; ------ test, zda je seznam ji§ plnì

         cmp       word ptr ds:[SeznamN],SeznamM ; je seznam ji§ plnì ?
         jae       InitSzn5                 ; seznam je ji§ plnì

; ------ ukl dac¡ adresa do seznamu -> DI, BX

         mov       ax,SeznamS               ; poŸet bajt… na polo§ku
         mul       word ptr ds:[SeznamN]    ; velikost seznamu
         add       ax,offset Seznam         ; konec seznamu
         inc       word ptr ds:[SeznamN]    ; zvìçen¡ Ÿ¡taŸe program… v seznamu
         mov       bx,ax                    ; BX <- ukl dac¡ adresa do seznamu
         xchg      ax,di                    ; DI <- ukl dac¡ adresa do seznamu

; ------ ulo§en¡ Ÿ¡sla disku

         cld
         mov       al,ds:[Cesta]            ; oznaŸen¡ disku
         sub       al,"A"                   ; Ÿ¡slo disku
         shl       al,1
         shl       al,1
         shl       al,1                     ; rotace disku na pozici
         stosb                              ; ulo§en¡ Ÿ¡sla disku

; ------ vymaz n¡ bufferu jm‚na souboru

         push      di
         mov       cx,8                     ; d‚lka jm‚na souboru
         mov       al," "
         rep       stosb                    ; vymaz n¡ jm‚na souboru
         pop       di

; ------ ulo§en¡ jm‚na programu

         mov       si,offset SoubNam        ; jm‚no souboru
         mov       cl,8                     ; maxim ln¡ d‚lka
InitSz42:lodsb                              ; naŸten¡ znaku jm‚na
         call      UpCase                   ; konverze AL na velk‚ p¡smeno
         cmp       al,"."                   ; bude pý¡pona ?
         je        InitSz44                 ; je pý¡pona - konec
         cmp       al,0                     ; je konec jm‚na ?
         je        InitSz44                 ; je konec jm‚na - konec
         stosb                              ; ulo§en¡ znaku
         inc       byte ptr ds:[bx]         ; zvìçen¡ Ÿ¡taŸe d‚lky jm‚na
         loop      InitSz42                 ; dalç¡ znak
InitSz44:dec       byte ptr ds:[bx]         ; korekce d‚lky jm‚na - 1
         mov       ah,4fh
         jmp       short InitSzn4           ; hled n¡ dalç¡ polo§ky

; ------ pý¡prava k setý¡dØn¡ seznamu

InitSzn5:cld
         mov       si,offset Seznam         ; seznam polo§ek
         mov       cx,ds:[SeznamN]          ; poŸet polo§ek v seznamu

; ------ zjemnØn¡ kroku tý¡dØn¡

InitSz52:shr       cx,1                     ; zjemnØn¡ velikosti kroku
         jcxz      InitSzn6                 ; konec tý¡dØn¡

; ------ pý¡prava ukazatele Ÿ¡sla polo§ky -> BP

InitSz53:mov       bp,cx                    ; AX <- velikost kroku
         dec       bp                       ; pýednastaven¡ - 1

; ------ zvìçen¡ ukazatele aktu ln¡ polo§ky

InitSz54:inc       bp                       ; zvìçen¡ aktu ln¡ polo§ky
         cmp       bp,ds:[SeznamN]          ; je to platn  polo§ka ?
         jae       InitSz52                 ; nen¡ to ji§ platn  polo§ka

; ------ adresa prvn¡ testovan‚ polo§ky -> SI

         mov       bx,bp                    ; BX <- aktu ln¡ polo§ka
InitSz55:sub       bx,cx                    ; odeŸten¡ kroku
         jc        InitSz54                 ; nen¡ ji§ platn  polo§ka
         mov       ax,SeznamS               ; poŸet bajt… na polo§ku seznamu
         mul       bx                       ; pýepoŸet polo§ky na offset
         add       ax,offset Seznam         ; adresa polo§ky
         xchg      ax,si                    ; SI <- adresa prvn¡ polo§ky

; ------ adresa druh‚ testovan‚ polo§ky -> DI

         mov       di,bx                    ; Ÿ¡slo testovan‚ polo§ky
         add       di,cx                    ; druh  testovan  polo§ka
         mov       ax,SeznamS               ; poŸet bajt… na polo§ku seznamu
         mul       di                       ; pýepoŸet polo§ky na offset
         add       ax,offset Seznam         ; adresa polo§ky
         xchg      ax,di                    ; DI <- adresa druh‚ polo§ky

; ------ porovn n¡ polo§ek SI a DI

         push      cx
         push      si
         push      di

         inc       si                       ; zaŸ tek jm‚na polo§ky
         inc       di                       ; zaŸ tek jm‚na polo§ky
         mov       cx,8                     ; d‚lka jm‚na polo§ky
         repe      cmpsb                    ; porovn n¡ jm‚na polo§ky

         pop       di
         pop       si
         pop       cx
         jne       InitSz58                 ; jm‚na polo§ek jsou rozd¡ln 
         mov       al,ds:[si]               ; disk prvn¡ polo§ky
         cmp       al,ds:[di]               ; porovn n¡ disk…
InitSz58:jbe       InitSz54                 ; poýad¡ polo§ek je OK

; ------ z mØna polo§ek pýi chybn‚m poýad¡

         push      cx
         mov       cx,SeznamS               ; d‚lka polo§ky
InitSz59:lodsb
         xchg      al,ds:[di]
         mov       ds:[si-1],al
         inc       di
         loop      InitSz59
         pop       cx
         jmp       short InitSz55           ; dalç¡ polo§ka

; ------ inicializace kurzoru podle polo§ky ze syst‚mov‚ho prostýed¡

InitSzn6:xor       bx,bx                    ; BX <- ukazatel Ÿ¡sla polo§ky
         cld
         mov       si,offset Seznam-SeznamS ; adresa polo§ky (zaŸ tek seznamu)
         dec       bx                       ; pýednastaven¡ - 1
InitSz62:add       si,SeznamS               ; zvìçen¡ adresy polo§ky
         inc       bx                       ; zvìçen¡ ukazatele Ÿ¡sla polo§ky
         cmp       bx,ds:[SeznamN]          ; je jeçtØ platn  polo§ka ?
         jae       InitSz65                 ; nen¡ platn  polo§ka - konec
         push      si
         mov       di,offset ParFile0       ; jm‚no souboru z prostýed¡
         mov       cx,8                     ; d‚lka jm‚na k porovn n¡
         inc       si
         repe      cmpsb                    ; porovn n¡ jm‚na polo§ky
         pop       si
         jne       InitSz63                 ; polo§ky nejsou shodn‚
         mov       al,ds:[si]               ; parametry polo§ky
         shr       al,1
         shr       al,1
         shr       al,1                     ; Ÿ¡slo disku
         add       al,"A"                   ; oznaŸen¡ disku
         cmp       al,ds:[ParDisk0]         ; porovn n¡ disku
InitSz63:jb        InitSz62                 ; dalç¡ polo§ka
         inc       bx

InitSz65:dec       bx
         xchg      ax,bx                    ; AX <- Ÿ¡slo polo§ky
         mov       ds:[SeznamA],ax          ; Ÿ¡slo aktivn¡ polo§ky
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[NumXY]      ; vìpoŸet Ÿ¡sla str nky
         mul       word ptr ds:[NumXY]      ; vìpoŸet poŸ teŸn¡ polo§ky
         mov       ds:[SeznamT],ax          ; poŸ teŸn¡ polo§ka str nky

; ------ nastaven¡ kurzoru myçi na aktivn¡ polo§ku

InitSzn7:test      byte ptr ds:[Param],2    ; je myç nainstalov na ?
         jz        InitSzn8                 ; myç nen¡ nainstalov na

         call      MouseOff                 ; vypnut¡ kurzoru myçi

         mov       ax,ds:[SeznamA]          ; aktivn¡ polo§ka
         sub       ax,ds:[SeznamT]          ; polo§ka relativnØ
         xor       dx,dx
         div       word ptr ds:[NumX]       ; vìpoŸet ý dku a sloupce

         push      ax                       ; £schova ý dku

         mov       ax,ds:[IncX]             ; pý¡rustek adresy X
         mul       dx                       ; vìpoŸet pozice poŸ tku
         add       ax,ds:[TopX]             ; pozice na displeji
         mov       dx,ds:[IncX]             ; pý¡rustek adresy X
         shr       dx,1                     ; polovina pý¡rustku
         add       ax,dx                    ; na stýed ikony
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; pýevod na bitovou pozici
         xchg      ax,cx                    ; CX <- souýadnice X

         pop       ax

         mul       word ptr ds:[IncY]       ; vìpoŸet linky
         add       ax,ds:[TopY]             ; pozice na displeji
         add       ax,VYSY/2                ; na stýed ikony
         xchg      ax,dx                    ; DX <- souýadnice Y

         mov       al,4
         call      Mouse                    ; nastaven¡ pozice kurzoru myçi

         call      MouseOn                  ; zapnut¡ kurzoru myçi

InitSzn8:ret

InitSezn ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru, linka DX, pozice BX
; -----------------------------------------------------------------------------

ZapKurz  PROC      NEAR

         test      byte ptr ds:[Param],1    ; je kurzor zapnut ?
         jz        DispKur                  ; nen¡ zapnut - zapnut¡
         ret

ZapKurz  ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru, linka DX, pozice BX
; -----------------------------------------------------------------------------

VypKurz  PROC      NEAR

         test      byte ptr ds:[Param],1    ; je kurzor zapnut ?
         jnz       DispKur                  ; je zapnut - vypnut¡
         ret

VypKurz  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru
; -----------------------------------------------------------------------------
;þ
DispKur  PROC      NEAR

; ------ £schova registr…

         call      MouseOff                 ; vypnut¡ kurzoru myçi

         xor       byte ptr ds:[Param],1    ; zmØna pý¡znaku kurzoru
         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vìpoŸet pozice kurzoru -> DX, BX

         mov       ax,ds:[SeznamA]          ; aktivn¡ polo§ka
         sub       ax,ds:[SeznamT]          ; polo§ka relativnØ
         xor       dx,dx                    ; DX <- 0
         div       word ptr ds:[NumX]       ; pýepoŸet na ý dek a pozici
         push      dx
         mul       word ptr ds:[IncY]       ; pýepoŸet ý dku na linky
         add       ax,ds:[TopY]             ; poŸ teŸn¡ linka
         xchg      ax,bx                    ; BX <- po§adovan  linka
         pop       ax
         mul       word ptr ds:[IncX]       ; pýepoŸet pozice na bajty
         add       ax,ds:[TopX]             ; poŸ teŸn¡ pozice
         xchg      ax,bx                    ; BX <- pozice
         xchg      ax,dx                    ; DX <- linka

; ------ vìpoŸet adresy ve videopamØti -> DI

         dec       dx
         dec       dx                       ; poŸ teŸn¡ linka

         xor       di,di                    ; DI <- 0 nen¡ korekce
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispKur2                 ; nen¡ videokarta CGA ani Hercules
         shr       dx,1                     ; je lich  linka ?
         jnc       DispKur1                 ; nen¡ lich  linka
         add       di,2000h                 ; korekce pro lichou linku CGA
DispKur1:cmp       byte ptr ds:[TypCard],1  ; je videokarta Hercules ?
         jne       DispKur2                 ; nen¡ videokarta Hercules
         shr       dx,1                     ; je lichì p r linek ?
         jnc       DispKur2                 ; nen¡ lichì p r linek
         add       di,4000h                 ; korekce pro lichì p r linek
DispKur2:mov       ax,ds:[Sirka]            ; poŸet bajt… na linku
         mul       dx                       ; pýepoŸet linky na adresu
         add       di,ax                    ; adresa linky
         add       di,bx                    ; pýiŸten¡ pozice

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         xor       cx,cx                    ; CX <- 0
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         mov       bx,1001h                 ; maska barevn‚ roviny
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispKur5                 ; je videokarta EGA nebo VGA

; ------ horn¡ linka pro CGA a Hercules

DispKur3:call      DispKrL                  ; zobrazen¡ linky CGA a HGC
         call      DispKrL

; ------ z pis okraj…

         mov       cx,40
DispKr34:xor       byte ptr es:[di],0c0h
         xor       byte ptr es:[di+7],3
         call      IncAdr                   ; zvìçen¡ adresy
         loop      DispKr34

; ------ spodn¡ linka pro CGA a Hercules

         call      DispKrL                  ; zobrazen¡ linky CGA a HGC
         call      DispKrL
         jmp       short DispKur9

; ------ nastaven¡ z pisov‚ roviny

DispKur5:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,0fh                   ; z pisov  rovina - vçechno
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ z pisov‚ho m¢du XOR

         mov       dx,3ceh
         mov       al,3
         out       dx,al
         inc       dx
         mov       al,18h
         out       dx,al                    ; z pisovì m¢d XOR

; ------ z pis horn¡ linky

         cld
         call      DispKrV
         call      DispKrV

; ------ z pis okraj…

         mov       cx,40
DispKr74:mov       al,0c0h
         xchg      al,es:[di]
         mov       al,3
         xchg      al,es:[di+7]
         add       di,80
         loop      DispKr74

; ------ z pis spodn¡ linky

         call      DispKrV
         call      DispKrV

; ------ n vrat bØ§n‚ho z pisov‚ho m¢du

         mov       al,0
         out       dx,al                    ; nastaven¡ bØ§n‚ho m¢du

; ------ n vrat registr…

DispKur9:sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

; ------ zapnut¡ kurzoru myçi

         call      MouseOn                  ; zapnut¡ kurzoru myçi
         ret

DispKur  ENDP

; ------ z pis linky EGA a VGA

DispKrV  PROC      NEAR

         mov       cx,8
DispKrV2:mov       al,-1
         xchg      al,es:[di]
         inc       di
         loop      DispKrV2
         add       di,80-8
         ret

DispKrV  ENDP

; ------ z pis linky CGA a Hercules

DispKrL  PROC      NEAR

         mov       cx,8
DispKrL2:xor       byte ptr es:[di],0ffh
         inc       di
         loop      DispKrL2
         sub       di,8
         call      IncAdr                   ; zvìçen¡ adresy DI
         ret

DispKrL  ENDP

; ------ zvìçen¡ adresy linky DI

IncAdr   PROC      NEAR

; ------ rozliçen¡ videokarty

         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         je        IncAdr3                  ; je videokarta CGA
         ja        IncAdr5                  ; videokarta EGA nebo VGA

; ------ videokarta Hercules

         add       di,2000h
         jns       IncAdr2
         sub       di,8000h - HercSir
IncAdr2: ret

; ------ videokarta CGA

IncAdr3: test      di,2000h                 ; jsou sud‚ linky ?
         jnz       IncAdr4                  ; je ji§ sud  linka
         add       di,2000h                 ; sud  linka
         ret

IncAdr4: sub       di,2000h-80
         ret

; ------ videokarta EGA/VGA

IncAdr5: add       di,80
         ret

IncAdr   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL, barva AH, linka DX, pozice BX
; -----------------------------------------------------------------------------
;þ
DispChr  PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa znaku -> SI

         push      ax                       ; £schova barvy znaku

         mov       ah,8
         mul       ah                       ; offset znaku
         add       ax,offset Font08         ; adresa znaku
         xchg      ax,si                    ; SI <- adresa znaku

; ------ vìpoŸet adresy ve videopamØti -> DI

         xor       di,di                    ; DI <- 0 nen¡ korekce
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispChr2                 ; nen¡ videokarta CGA ani Hercules
         shr       dx,1                     ; je lich  linka ?
         jnc       DispChr1                 ; nen¡ lich  linka
         add       di,2000h                 ; korekce pro lichou linku CGA
DispChr1:cmp       byte ptr ds:[TypCard],1  ; je videokarta Hercules ?
         jne       DispChr2                 ; nen¡ videokarta Hercules
         shr       dx,1                     ; je lichì p r linek ?
         jnc       DispChr2                 ; nen¡ lichì p r linek
         add       di,4000h                 ; korekce pro lichì p r linek
DispChr2:mov       ax,ds:[Sirka]            ; poŸet bajt… na linku
         mul       dx                       ; pýepoŸet linky na adresu
         add       di,ax                    ; adresa linky
         add       di,bx                    ; pýiŸten¡ pozice

         pop       ax                       ; po§adovan  barva znaku

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         mov       cx,8                     ; vìçka znaku v link ch

; ------ zobrazen¡ znaku pro Hercules a CGA

         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispChr7                 ; nen¡ videokarta CGA ani Hercules
DispChr4:lodsb                              ; naŸten¡ bajtu
         or        byte ptr es:[di],al      ; b¡l‚ p¡smo
         cmp       ah,0fh                   ; je b¡l  barva ?
         jne       DispCh41                 ; nen¡ b¡l  barva
         xor       byte ptr es:[di],al      ; zmØna na Ÿernou barvu
DispCh41:call      IncAdr                   ; zvìçen¡ adresy DI
         loop      DispChr4                 ; dalç¡ bajt
         jmp       short DispChr9

; ------ nastaven¡ z pisu do vçech rovin

DispChr7:mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,0fh                   ; z pisov  rovina - vçe
         out       dx,al                    ; volba z pisov‚ roviny

; ------ nastaven¡ barvy znaku

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,ah                    ; po§adovan  barva znaku
         out       dx,al                    ; nastaven¡ barvy znaku
         dec       dx

; ------ nastaven¡ volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,1111b                 ; vçechny roviny podle registru 0
         inc       dx
         out       dx,al                    ; volba rovin
         dec       dx

; ------ pýednastaven¡ registru bitov‚ masky

         mov       al,8                     ; registr 8
         out       dx,al                    ; volba registru 8
         inc       dx

; ------ z pis obr zku do roviny

DispChr8:lodsb
         out       dx,al                    ; nastaven¡ masky
         xchg      al,es:[di]               ; z pis znaku
         add       di,640/8
         loop      DispChr8

; ------ n vrat videoregistr…

         mov       al,0ffh                  ; maska - vçechny bity
         out       dx,al                    ; vçechny bity
         dec       dx
         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         mov       al,0                     ; vçechny roviny podle dat
         inc       dx
         out       dx,al                    ; volba rovin

; ------ n vrat registr…

DispChr9:sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       bx                       ; zvìçen¡ ukazatele pozice
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ikony (linka DX, pozice BX)
; -----------------------------------------------------------------------------
;þ
DispIcon PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ vìpoŸet adresy ve videopamØti -> DI

         xor       di,di                    ; DI <- 0 nen¡ korekce
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispIcn2                 ; nen¡ videokarta CGA ani Hercules
         shr       dx,1                     ; je lich  linka ?
         jnc       DispIcn1                 ; nen¡ lich  linka
         add       di,2000h                 ; korekce pro lichou linku CGA
DispIcn1:cmp       byte ptr ds:[TypCard],1  ; je videokarta Hercules ?
         jne       DispIcn2                 ; nen¡ videokarta Hercules
         shr       dx,1                     ; je lichì p r linek ?
         jnc       DispIcn2                 ; nen¡ lichì p r linek
         add       di,4000h                 ; korekce pro lichì p r linek
DispIcn2:mov       ax,ds:[Sirka]            ; poŸet bajt… na linku
         mul       dx                       ; pýepoŸet linky na adresu
         add       di,ax                    ; adresa linky
         add       di,bx                    ; pýiŸten¡ pozice

; ------ pý¡prava k operaci

         cld
         cli                                ; z kaz pýeruçen¡ bØhem operace
         xor       cx,cx                    ; CX <- 0
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         mov       bx,1001h                 ; maska barevn‚ roviny
         cmp       byte ptr ds:[TypCard],2  ; je videokarta CGA ?
         ja        DispIcn5                 ; je videokarta EGA nebo VGA

; ------ pý¡prava hranic pro zobrazen¡ barev

         call      InitHran                 ; pý¡prava hranic pro zobrazen¡

; ------ z pis ikony pro Hercules a CGA

         mov       si,offset IcoBuff+SIRX*(VYSY-1)*COLSB/8 ; buffer ikony k zobrazen¡
         mov       ah,VYSY                  ; vìçka ikony v link ch
DispIcn3:call      DispICM                  ; z pis linky pro MONO
         call      IncAdr                   ; zvìçen¡ adresy DI
         dec       ah                       ; Ÿ¡taŸ linek k z pisu
         jnz       DispIcn3                 ; z pis dalç¡ linky
         jmp       short DispIcn9

; ------ nastaven¡ z pisov‚ roviny

DispIcn5:mov       si,offset IcoBuff+SIRX*(VYSY-1)*COLSB/8 ; buffer ikony k zobrazen¡
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx                       ; datovì registr
         mov       al,bl                    ; z pisov  rovina
         out       dx,al                    ; volba z pisov‚ roviny

; ------ z pis obr zku do roviny pro EGA

         mov       ah,VYSY                  ; vìçka ikony v link ch
         cmp       byte ptr ds:[TypCard],3  ; je videokarta EGA ?
         jne       DispIcn7                 ; nen¡ videokarta EGA

DispIcn6:mov       cl,SIRX/8*2              ; poŸet bajt… k ulo§en¡
DispIc61:mov       al,1                     ; stýadaŸ vìsledku
DispIc62:test      byte ptr ds:[si],bh      ; test bitu prvn¡ho bodu
         jz        DispIc63                 ; bit nen¡ nastaven
         stc                                ; bit bude nastaven
DispIc63:pushf
         rcl       al,1                     ; rotace pý¡znaku do AL
         popf
         rcl       al,1                     ; rotace pý¡znaku do AL
         test      byte ptr ds:[si],bl      ; test bitu druh‚ho bodu
         jz        DispIc65                 ; bit nen¡ nastaven
         stc                                ; bit bude nastaven
DispIc65:inc       si                       ; zvìçen¡ ukazatele dat
         pushf
         rcl       al,1                     ; rotace pý¡znaku do AL
         popf
         rcl       al,1
         jnc       DispIc62                 ; dalç¡ bod
         stosb                              ; ulo§en¡ bajtu do roviny
         loop      DispIc61                 ; dalç¡ bajt k ulo§en¡
         sub       si,2*(SIRX*COLSB/8)      ; posun na zaŸ tek pýedeçl‚ linky
         add       di,640/8 - SIRX/8  - SIRX/8 ; adresa dalç¡ linky
         dec       ah                       ; Ÿ¡taŸ linek k z pisu
         jnz       DispIcn6                 ; z pis dalç¡ linky
         jmp       short DispIcn8

; ------ z pis pro VGA

DispIcn7:mov       cl,SIRX/8                ; poŸet bajt… k ulo§en¡
DispIc71:mov       al,1                     ; stýadaŸ vìsledku
DispIc72:test      byte ptr ds:[si],bh      ; test bitu prvn¡ho bodu
         jz        DispIc73                 ; bit nen¡ nastaven
         stc                                ; bit bude nastaven
DispIc73:rcl       al,1                     ; rotace pý¡znaku do AL
         test      byte ptr ds:[si],bl      ; test bitu druh‚ho bodu
         jz        DispIc75                 ; bit nen¡ nastaven
         stc                                ; bit bude nastaven
DispIc75:inc       si                       ; zvìçen¡ ukazatele dat
         rcl       al,1
         jnc       DispIc72                 ; dalç¡ bod
         stosb                              ; ulo§en¡ bajtu do roviny
         loop      DispIc71                 ; dalç¡ bajt k ulo§en¡
         sub       si,2*(SIRX*COLSB/8)      ; posun na zaŸ tek pýedeçl‚ linky
         add       di,640/8 - SIRX/8        ; adresa dalç¡ linky
         dec       ah                       ; Ÿ¡taŸ linek k z pisu
         jnz       DispIcn7                 ; z pis dalç¡ linky

; ------ pý¡prava pro dalç¡ rovinu

DispIcn8:sub       di,640/8*VYSY            ; n vrat ukl dac¡ adresy obr zku
         shl       bx,1                     ; posun masky barevn‚ roviny
         cmp       bl,10h                   ; jsou ji§ vçechny roviny ?
         jne       DispIcn5                 ; z pis dalç¡ roviny

; ------ n vrat z pisu do vçech rovin

         mov       al,0fh
         out       dx,al                    ; z pis do vçech rovin

; ------ n vrat registr…

DispIcn9:sti                                ; pýeruçen¡ opØt povoleno
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispIcon ENDP

; ------ zobrazen¡ linky pro CGA a Hercules (uchovat AH = Ÿ¡taŸ linek !)

DispICM  PROC      NEAR

         push      di
         cld
         mov       cl,SIRX/8*2              ; poŸet bajt… k ulo§en¡
         mov       bl,1                     ; pro lichou linku
         test      ah,1                     ; je to lich  linka ?
         jnz       DispICM0
         mov       bl,2                     ; pro sudou linku
DispICM0:call      DispIcM1                 ; naŸten¡ 2 bod…
         call      DispIcM1                 ; naŸten¡ dalç¡ch 2 bod…
         stosb                              ; ulo§en¡ bajtu do roviny
         loop      DispICM0                 ; dalç¡ bajt k ulo§en¡
         sub       si,2*(SIRX*COLSB/8)      ; posun na zaŸ tek pýedeçl‚ linky
         pop       di
         ret

DispIcM1:shl       al,1                     ; rotace 2 bit…
         shl       al,1
         mov       bh,ds:[si]               ; po§adovanì bod
         cmp       bh,ds:[Hrana1X]          ; bude Ÿern  barva ?
         jb        DispIcM3                 ; bude Ÿern  barva
         or        al,bl                    ; jinak bude 1 bit nastaven
         cmp       bh,ds:[Hrana2X]          ; bude b¡l  barva ?
         jb        DispIcM3                 ; nebude b¡l  barva
         or        al,3                     ; nastaven¡ bitu pro svØtlou
DispIcM3:shl       al,1                     ; rotace 2 bit…
         shl       al,1
         and       bh,0fh                   ; 2. bod
         cmp       bh,ds:[Hrana1]           ; bude Ÿern  barva ?
         jb        DispIcM4                 ; bude Ÿern  barva
         or        al,bl                    ; jinak bude 1 bit nastaven
         cmp       bh,ds:[Hrana2]           ; bude b¡l  barva ?
         jb        DispIcM4                 ; nebude b¡l  barva
         or        al,3                     ; nastaven¡ bitu pro svØtlou
DispIcM4:inc       si                       ; zvìçen¡ ukazatele dat
         ret

DispIcM  ENDP

; -----------------------------------------------------------------------------
;        inicializace hran pro zobrazen¡ Mono barev
; -----------------------------------------------------------------------------
;þ
InitHran PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      bp
         push      si
         push      di

; ------ vynulov n¡ Ÿ¡taŸe barev

         mov       si,offset CitBarev       ; Ÿ¡taŸ barev
         mov       cx,16                    ; velikost Ÿ¡taŸe
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
InitHrn1:mov       ds:[si],ax
         inc       si
         inc       si
         loop      InitHrn1

; ------ zmapov n¡ barevnìch bod…

         cld
         mov       bh,0
         mov       si,offset IcoBuff        ; buffer dat ikony
         mov       cx,SIRX*VYSY*COLSB/8     ; poŸet bajt… dat ikony
InitHrn2:lodsb
         mov       bl,al
         and       bl,0f0h
         shr       bl,1
         shr       bl,1
         shr       bl,1
         inc       word ptr ds:[bx+CitBarev] ; zvìçen¡ Ÿ¡taŸe barev pro 1. bod
         and       al,0fh
         mov       bl,al
         shl       bl,1
         inc       word ptr ds:[bx+CitBarev] ; zvìçen¡ Ÿ¡taŸe barev pro 2. bod
         loop      InitHrn2                 ; dalç¡ bod

; ------ stanoven¡ hranice pro çedou barvu

         mov       byte ptr ds:[Hrana1],0   ; hranice pro çedou barvu - 1
         mov       byte ptr ds:[Hrana1X],0
         mov       bx,offset CitBarev       ; tabulka Ÿ¡taŸe barev
         xor       ax,ax
InitHrn3:add       ax,ds:[bx]               ; stýadaŸ bod…
InitHrn4:inc       byte ptr ds:[Hrana1]
         add       byte ptr ds:[Hrana1X],10h
         inc       bx
         inc       bx
         cmp       ax,SIRX*VYSY/32          ; je to jeçtØ m lo bod… ?
         jb        InitHrn3                 ; je to jeçtØ m lo bod…
         add       ax,ds:[bx]               ; pýiŸten¡ dalç¡ barvy
         cmp       ax,SIRX*VYSY*3/7         ; bude to jeçtØ m lo bod… ?
         jb        InitHrn4                 ; bude to jeçtØ m lo bod…

; ------ stanoven¡ hranice pro b¡lou barvu

         mov       byte ptr ds:[Hrana2],10h ; hranice pro b¡lou barvu + 1
         mov       byte ptr ds:[Hrana2X],0
         mov       bx,offset CitBarev+2*16
         xor       ax,ax
InitHrn5:add       ax,ds:[bx-2]
InitHrn6:dec       byte ptr ds:[Hrana2]
         sub       byte ptr ds:[Hrana2X],10h
         dec       bx
         dec       bx
         cmp       ax,SIRX*VYSY/64          ; je to jeçtØ m lo bod… ?
         jb        InitHrn5                 ; je to jeçtØ m lo bod…
         add       ax,ds:[bx-2]
         cmp       ax,SIRX*VYSY*3/7
         jb        InitHrn6

; ------ ochrana proti pýekryt¡ barev

         mov       al,ds:[Hrana1]
         cmp       al,ds:[Hrana2]
         jb        InitHrn7
         inc       byte ptr ds:[Hrana2]
         add       byte ptr ds:[Hrana2X],10h

; ------ n vrat registr…

InitHrn7:pop       di
         pop       si
         pop       bp
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

InitHran ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky
; -----------------------------------------------------------------------------
;þ
Vymaz    PROC      NEAR

         call      MouseOff                 ; vypnut¡ kurzoru myçi

; ------ pý¡prava registr…

         and       byte ptr ds:[Param],not 1 ; kurzor vypnut
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         xor       di,di

         mov       bx,ds:[Vyska]            ; poŸet linek
         sub       bx,VyskaM                ; bez menu ve spodn¡ Ÿ sti
         cld

; ------ vymaz n¡ obrazovky Hercules

         cmp       byte ptr ds:[TypCard],2  ; je EGA nebo VGA ?
         ja        Vymaz3                   ; je EGA nebo VGA
         je        Vymaz24                  ; je CGA

Vymaz2:  mov       cx,HercSir-1
         mov       al,-1
         rep       stosb
         mov       al,0
         stosb
         add       di,2000h-HercSir
         jns       Vymaz22
         and       di,7fffh
         add       di,HercSir               ; zaŸ tek dalç¡ linky
Vymaz22: dec       bx
         jnz       Vymaz2
         jmp       short Vymaz8

; ------ vymaz n¡ obrazovky CGA

Vymaz24: shr       bx,1
Vymaz25: mov       cx,640/8/2
         mov       ax,-1
         rep       stosw
         add       di,2000h-640/8
         mov       cl,640/8/2
         rep       stosw
         sub       di,2000h
         dec       bx
         jnz       Vymaz25
         jmp       short Vymaz8

; ------ nastaven¡ z pisu do vçech rovin

Vymaz3:  cli
         mov       dx,3c4h
         mov       al,2
         out       dx,al                    ; volba registru 2
         inc       dx
         mov       al,0fh                   ; z pis do vçech rovin
         out       dx,al                    ; nastaven¡ vçech rovin

; ------ nastaven¡ z kladn¡ barvy

         mov       dx,3ceh
         mov       al,0                     ; registr 0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,0                     ; po§adovan  barva
         out       dx,al                    ; nastaven¡ z kladn¡ barvy
         dec       dx

; ------ nastaven¡ volby rovin

         mov       al,1                     ; registr 1
         out       dx,al                    ; volba registru 1
         inc       dx
         mov       al,1001b
         out       dx,al                    ; volba rovin

; ------ vymaz n¡ videopamØti

         mov       ax,0ffffh
Vymaz6:  mov       cx,640/8/2
         rep       stosw
         dec       bx
         jnz       Vymaz6

; ------ vymaz n¡ plochy pro menu

         mov       al,111b                  ; bude svØtle çed  barva
         out       dx,al
         mov       cx,640/8*VyskaM/2
         mov       ax,0ffffh
         rep       stosw                    ; vymaz n¡ plochy pro menu

; ------ standardn¡ nastaven¡ registru rovin

         xor       al,al
         out       dx,al                    ; vçechny roviny podle dat
         sti

; ------ zobrazen¡ n povØdy

Vymaz8:  mov       dx,ds:[Vyska]           ; vìçka obrazovky v link ch
         sub       dx,VyskaM-1              ; linka n povØdy
         xor       bx,bx                    ; poŸ teŸn¡ pozice
         mov       cx,offset(HelpTxt0-HelpTxt) ; d‚lka textu
         mov       si,offset HelpTxt        ; text n povØdy
         mov       ah,0                     ; Ÿern  barva
Vymaz82: cld
         lodsb
         cmp       al,""                   ; je zmØna barvy ?
         jne       Vymaz83                  ; nen¡ zmØna barvy
         xor       ah,9                     ; vysv¡cen  barva
         jmp       short Vymaz85

Vymaz83: call      DispChr                  ; zobrazen¡ znaku
Vymaz85: loop      Vymaz82                  ; dalç¡ znak
         ret

Vymaz    ENDP

; -----------------------------------------------------------------------------
;        inicializace palet displeje
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

; ------ test, zda je videokarta EGA nebo VGA

         cmp       byte ptr ds:[TypCard],3  ; je videokarta EGA nebo VGA ?
         jb        InitPal8                 ; nen¡ videokarta EGA ani VGA

; ------ inicializace palet EGA

         mov       ax,1002h
         push      ds
         pop       es                       ; ES <- datovì segment
         mov       dx,offset PalEGA         ; tabulka palet EGA
         call      Int10                    ; nastaven¡ palet EGA

; ------ test, zda je videokarta VGA

         cmp       byte ptr ds:[TypCard],4  ; je videokarta VGA ?
         jb        InitPal8                 ; nen¡ videokarta VGA

; ------ inicializace palet VGA

         mov       si,offset PalVGA         ; tabulka palet VGA
         mov       di,offset PalEGA         ; tabulka palet EGA
         mov       bp,16                    ; poŸet palet k inicializaci
InitPal2:cld
         lodsw                              ; modr  a zelen 
         xchg      ax,cx                    ; CL <- modr , CH <- zelen 
         lodsb                              ; Ÿerven 
         mov       dh,al                    ; DH <- Ÿerven 
         xchg      si,di
         lodsb
         xchg      si,di
         mov       ah,0
         xchg      ax,bx                    ; BX <- index barvy
         mov       ax,1010h
         call      Int10                    ; nastaven¡ paletov‚ho registru
         dec       bp
         jnz       InitPal2                 ; dalç¡ registr
InitPal8:ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        inicializace videokarty
; -----------------------------------------------------------------------------
;þ
IniCard  PROC      NEAR

; ------ test videokarty EGA/VGA

         mov       ah,12h                   ; slu§ba EGA/VGA - informace o EGA
         mov       bx,4510h                 ; poskytnut¡ informac¡ o EGA
         call      Int10                    ; poskytnut¡ informac¡ o EGA/VGA
         cmp       bh,2                     ; kontrola navr cen‚ho m¢du displeje
         ja        IniCard1                 ; nen¡ to karta EGA/VGA
         cmp       bl,5                     ; maxim lnØ povolen 1 MB pamØti
         jbe       IniCard2                 ; je to EGA/VGA
IniCard1:jmp       IniCard5                 ; nen¡ to karta EGA/VGA

; ------ rozliçen¡ videokarty EGA a VGA

IniCard2:mov       ax,1a00h
         call      Int10                    ; dotaz na instalaci karty
         cmp       al,1ah
         jne       IniCard4                 ; funkce nen¡ obsluhovan  - je EGA
         cmp       bl,7
         je        IniCard3                 ; je karta VGA
         cmp       bl,8
         je        IniCard3                 ; je karta VGA
         cmp       bl,11
         je        IniCard3                 ; je karta VGA
         cmp       bl,12
         jne       IniCard4                 ; nen¡ karta VGA

; ------ je karta VGA

IniCard3:mov       byte ptr ds:[TypCard],4  ; je karta VGA
         mov       word ptr ds:[AdrVRAM],0a000h ; adresa videopamØti
         mov       word ptr ds:[Sirka],80   ; ç¡ýka obrazovky v bajtech
         mov       word ptr ds:[Vyska],480  ; vìçka obrazovky v link ch
         mov       word ptr ds:[NumX],9     ; poŸet ikon horizont lnØ
         mov       word ptr ds:[NumY],10    ; poŸet ikon vertik lnØ
         mov       word ptr ds:[NumXY],10*9 ; poŸet ikon na str nku
         mov       word ptr ds:[TopX],0     ; poŸ teŸn¡ pozice horizont lnØ
         mov       word ptr ds:[TopY],6     ; poŸ teŸn¡ linka vertik lnØ
         mov       word ptr ds:[IncX],9     ; pý¡rustek pozice horizont lnØ
         mov       word ptr ds:[IncY],46    ; pý¡rustek linky vertik lnØ
         mov       al,18                    ; videom¢d VGA: 640*480
         jmp       IniCard7

; ------ je karta EGA

IniCard4:mov       byte ptr ds:[TypCard],3  ; je EGA
         mov       word ptr ds:[AdrVRAM],0a000h ; adresa videopamØti
         mov       word ptr ds:[Sirka],80   ; ç¡ýka obrazovky v bajtech
         mov       word ptr ds:[Vyska],350  ; vìçka obrazovky v link ch
         mov       word ptr ds:[NumX],9     ; poŸet ikon horizont lnØ
         mov       word ptr ds:[NumY],8     ; poŸet ikon vertik lnØ
         mov       word ptr ds:[NumXY],8*9  ; poŸet ikon na str nku
         mov       word ptr ds:[TopX],0     ; poŸ teŸn¡ pozice horizont lnØ
         mov       word ptr ds:[TopY],3     ; poŸ teŸn¡ linka vertik lnØ
         mov       word ptr ds:[IncX],9     ; pý¡rustek pozice horizont lnØ
         mov       word ptr ds:[IncY],42    ; pý¡rustek linky vertik lnØ
         mov       al,16                    ; videom¢d EGA: 640*350
         jmp       IniCard7

; ------ rozliçen¡ karet CGA/Hercules

IniCard5:mov       ah,0fh
         call      Int10                    ; poskytnut¡ aktivn¡ho videom¢du
         cmp       al,7                     ; je videom¢d 7 (Hercules) ?
         jne       IniCard6                 ; nen¡ Hercules - je CGA

; ------ je karta Hercules (AL=7)

         mov       byte ptr ds:[TypCard],1  ; Hercules
         mov       word ptr ds:[AdrVRAM],0b000h ; adresa videopamØti
         mov       word ptr ds:[Sirka],HercSir ; ç¡ýka obrazovky v bajtech
         mov       word ptr ds:[Vyska],350  ; vìçka obrazovky v link ch
         mov       word ptr ds:[NumX],(HercSir+1)/9 ; poŸet ikon horizont lnØ
         mov       word ptr ds:[NumY],8     ; poŸet ikon vertik lnØ
         mov       word ptr ds:[NumXY],8*((HercSir+1)/9) ; poŸet ikon na str nku
         mov       word ptr ds:[TopX],0     ; poŸ teŸn¡ pozice horizont lnØ
         mov       word ptr ds:[TopY],3     ; poŸ teŸn¡ linka vertik lnØ
         mov       word ptr ds:[IncX],9     ; pý¡rustek pozice horizont lnØ
         mov       word ptr ds:[IncY],42    ; pý¡rustek linky vertik lnØ
         mov       ax,7                     ; videom¢d Hercules: 640*350
         call      Int10                    ; nastaven¡ videom¢du
         call      InitHGC                  ; inicializace grafick‚ho m¢du HGC

         cld
         mov       es,ds:[AdrVRAM]          ; adresa videopamØti
         xor       ax,ax
         xor       di,di
         mov       cx,8000h/2
         rep       stosw                    ; vymaz n¡ videopamØti Hercules
         ret

; ------ je karta CGA

IniCard6:mov       byte ptr ds:[TypCard],2  ; CGA
         mov       word ptr ds:[AdrVRAM],0b800h ; adresa videopamØti
         mov       word ptr ds:[Sirka],80   ; ç¡ýka obrazovky v bajtech
         mov       word ptr ds:[Vyska],200  ; vìçka obrazovky v link ch
         mov       word ptr ds:[NumX],9     ; poŸet ikon horizont lnØ
         mov       word ptr ds:[NumY],4     ; poŸet ikon vertik lnØ
         mov       word ptr ds:[NumXY],4*9  ; poŸet ikon na str nku
         mov       word ptr ds:[TopX],0     ; poŸ teŸn¡ pozice horizont lnØ
         mov       word ptr ds:[TopY],6     ; poŸ teŸn¡ linka vertik lnØ
         mov       word ptr ds:[IncX],9     ; pý¡rustek pozice horizont lnØ
         mov       word ptr ds:[IncY],46    ; pý¡rustek linky vertik lnØ
         mov       al,6                     ; videom¢d CGA: 640*200

; ------ nastaven¡ videom¢du AL

IniCard7:mov       ah,0
         call      Int10                    ; nastaven¡ videom¢du
         ret

IniCard  ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho re§imu karty HGC
; -----------------------------------------------------------------------------

InitHGC  PROC      NEAR

         cli

; ------ nastaven¡ registru m¢du karty HGC

         mov       al,3
         mov       dx,3bfh
         out       dx,al

         mov       al,2
         mov       dx,3b8h
         out       dx,al                    ; grafickì m¢d

; ------ inicializace registr… HGC

         mov       ah,0
         mov       si,offset HGCTabR        ; tabulka registr… karty HGC
         mov       dx,3b4h                  ; adresa portu karty HGC
         cld
InitHGC2:mov       al,ah                    ; Ÿ¡slo registru
         out       dx,al                    ; nastaven¡ Ÿ¡sla registru
         inc       dx
         lodsb                              ; volba Ÿ¡sla registru
         out       dx,al                    ; nastaven¡ registru
         dec       dx
         inc       ah                       ; zvìçen¡ ukazatele registr…
         cmp       ah,16
         jb        InitHGC2                 ; dalç¡ registr

; ------ povolen¡ druh‚ str nky videopamØti (od adresy B800h)

;         mov       dx,3bfh
;         mov       al,1
;         out       dx,al

; ------ zapnut¡ videosign lu

         mov       al,1010b            ; graf.m¢d, sign l zap
         mov       dx,03b8h
         out       dx,al
         sti
         ret

InitHgc  ENDP

;; -----------------------------------------------------------------------------
;;        detekce a ulo§en¡ parametr… VESA karty
;; -----------------------------------------------------------------------------
;
;DetVESA  PROC      NEAR
;
;; ------ £schova registr…
;
;         push      ax
;         push      bx
;         push      cx
;         push      dx
;         push      si
;         push      di
;         push      bp
;         push      es
;
;; ------ naŸten¡ informac¡ VESA
;
;         mov       bp,sp
;         sub       sp,520                   ; buffer
;         push      ss
;         pop       es                       ; ES <- segment v z sobn¡ku
;         mov       di,sp                    ; buffer v z sobn¡ku
;         mov       ax,4f00h
;         mov       word ptr es:[di],0       ; pýednastaven¡ bufferu
;         call      Int10                    ; test instalace VESA
;
;; ------ test, zda je to VESA
;
;         cmp       ax,4fh                   ; je operace OK ?
;         jne       DetVESA0                 ; chyba - nen¡ VESA
;         cmp       word ptr es:[di],"EV"
;         jne       DetVESA0                 ; nen¡ VESA
;         cmp       word ptr es:[di+2],"AS"
;         je        DetVESA1                 ; je VESA OK
;DetVESA0:jmp       DetVESA9
;
;; ------ £schova ukazatel… VESA
;
;DetVESA1:mov       byte ptr ds:[TypVCard],5 ; je VESA VGA
;         cmp       byte ptr ds:[TypVGA],0   ; je karta VGA zn m  ?
;         jne       DetVESA2                 ; karta VGA je zn m 
;         mov       word ptr ds:[DspNMPl1],offset CardTxtS ; je karta VESA VGA
;DetVESA2:mov       ax,es:[di+4]             ; verze VESA
;         mov       ds:[VESAVer],ax          ; verze VESA
;         mov       ax,es:[di+6]             ; ukazatel na OEM LOW
;         mov       word ptr ds:[VESAOEM],ax
;         mov       ax,es:[di+8]
;         mov       word ptr ds:[VESAOEM+2],ax
;
;; ------ £schova seznamu videom¢d… do bufferu v z sobn¡ku
;
;         push      ds
;         cld
;         lds       si,es:[di+0eh]           ; ukazatel na seznam videom¢d…
;         lea       di,ss:[bp-200]           ; buffer v z sobn¡ku
;         mov       cx,200/2-1
;         push      di                       ; zaŸ tek bufferu
;         rep       movsw                    ; pýenos Ÿ¡sel videom¢d…
;         pop       si                       ; SI <- zaŸ tek bufferu
;         mov       ax,-1
;         stosw                              ; pojistn‚ zakonŸen¡ tabulky
;         pop       ds
;
;; ------ Ÿ¡slo dalç¡ho videom¢du VESA (ukazatel bufferu SI)
;
;DetVESA4:mov       cx,es:[si]               ; CX <- videom¢d
;         inc       cx                       ; je konec tabulky ?
;         jz        DetVESA9                 ; je konec tabulky
;         dec       cx                       ; n vrat Ÿ¡sla videom¢du
;         inc       si
;         inc       si                       ; zvìçen¡ ukazatele videom¢d…
;         and       ch,1fh                   ; aby nepýetekly pý¡znaky
;
;; ------ naŸten¡ informac¡ o videom¢du
;
;         mov       di,sp                    ; buffer v z sobn¡ku
;         mov       ax,4f01h
;         mov       byte ptr es:[di],bit4    ; pýednastaven¡ na nespr vnØ
;         push      cx
;         call      far ptr Int10P           ; dotaz na videom¢d
;         pop       cx
;
;; ------ kontrola platnosti videom¢du
;
;         cmp       ax,4fh
;         jne       DetVESA4                 ; chyba
;         mov       al,es:[di]               ; atributy
;         mov       ah,al                    ; £schova atribut…
;         and       al,bit0+bit1+bit4        ; tyto informace jsou d…le§it‚
;         cmp       al,bit0+bit1             ; takovì mus¡ bìt stav
;         jne       DetVESA4                 ; nen¡ spr vnì videom¢d
;         inc       ch                       ; pý¡znak videom¢du VESA
;
;; ------ pý¡znak MONO
;
;         test      ah,bit3                  ; je to MONO m¢d ?
;         jnz       DetVESA7                 ; je to barevnì m¢d
;         or        ch,bit7                  ; je to MONO m¢d
;
;; ------ ç¡ýka a vìçka displeje
;
;DetVESA7:mov       dx,es:[di+12h]           ; ç¡ýka displeje
;         cmp       dx,254                   ; maxim ln¡ ç¡ýka displeje
;         jae       DetVESA4                 ; neplatnì videom¢d
;         cmp       dl,40                    ; minim ln¡ ç¡ýka displeje
;         jb        DetVESA4                 ; neplatnì videom¢d
;         cmp       word ptr es:[di+14h],254 ; vìçka displeje
;         jae       DetVESA4                 ; neplatnì videom¢d
;         mov       dh,es:[di+14h]           ; vìçka okna
;         cmp       dh,24                    ; minim ln¡ vìçka displeje
;         jb        DetVESA4                 ; neplatnì videom¢d
;
;; ------ ulo§en¡ parametr… videom¢du
;
;         xchg      ax,cx                    ; AX <- Ÿ¡slo videom¢du
;         call      StorVMod                 ; ulo§en¡ videom¢du
;         jmp       short DetVESA4           ; dalç¡ videom¢d
;
;; ------ n vrat registr…
;
;DetVESA9:mov       sp,bp
;         pop       es
;         pop       bp
;         pop       di
;         pop       si
;         pop       dx
;         pop       cx
;         pop       bx
;         pop       ax
;         ret
;
;DetVESA  ENDP
;
; -----------------------------------------------------------------------------
;        vol n¡ INT 10h s £schovou registr…
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

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

Int10    ENDP

; *****************************************************************************
;
;                      Obsluha syst‚mov‚ho prostýed¡
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        nastaven¡ jm‚na programu a disku do syst‚mov‚ho prostýed¡ (CY=chyba)
; -----------------------------------------------------------------------------

OutFile  PROC      NEAR

; ------ adresa aktivn¡ polo§ky -> DI

         mov       ax,SeznamS               ; poŸet bajt… na polo§ku
         mul       word ptr ds:[SeznamA]    ; offset aktivn¡ polo§ky v seznamu
         add       ax,offset Seznam         ; adresa aktivn¡ polo§ky v seznamu
         xchg      ax,di                    ; DI <- aktivn¡ polo§ka v seznamu

; ------ nastaven¡ jm‚na programu do syst‚mov‚ho prostýed¡

         mov       bl,ds:[di]               ; parametry
         inc       di                       ; zaŸ tek jm‚na programu
         push      bx
         and       bx,7                     ; d‚lka jm‚na programu - 1
         inc       bx                       ; d‚lka jm‚na programu
         mov       si,offset ParFile        ; jm‚no parametru "XFILE"
         mov       cx,5                     ; d‚lka jm‚na parametru "XFILE"
         call      SetEnv                   ; nastaven¡ parametru "XFILE"
         pop       ax
         jc        OutFile9                 ; chyba

; ------ nastaven¡ jm‚na disku do syst‚mov‚ho prostýed¡ (CX=5)

         shr       al,1
         shr       al,1
         shr       al,1                     ; Ÿ¡slo disku
         add       al,"A"                   ; oznaŸen¡ disku
         mov       si,offset ParDisk        ; jm‚no parametru "XDISK"
         mov       di,offset ParDisk0       ; buffer jm‚na disku
         mov       ds:[di],al               ; jm‚no disku
         mov       bl,1                     ; d‚lka textu parametru
         call      SetEnv                   ; nastaven¡ parametru "XDISK"
         jc        OutFile9                 ; chyba

; ------ nastaven¡ domovsk‚ cesty programu (CX=5)

         mov       si,offset ParPath        ; jm‚no parametru "XPATH"
         mov       di,offset Cesta+2        ; zaŸ tek cesty
         mov       bx,ds:[CestaN]           ; konec cesty
         sub       bx,di                    ; d‚lka cesty
         call      SetEnv                   ; nastaven¡ parametru cesty
         jc        OutFile9                 ; chyba

; ------ nastaven¡ domovsk‚ho disku (CX=5)

         mov       di,offset ParHome0       ; buffer disku
         mov       al,ds:[HomeDisk]         ; domovskì disk
         add       al,"A"                   ; konverze na p¡smeno
         mov       ds:[di],al               ; oznaŸen¡ disku
         mov       si,offset ParHome        ; jm‚no parametru "XHOME"
         mov       bl,1                     ; d‚lka parametru
         call      SetEnv                   ; nastaven¡ parametru disku
         jc        OutFile9                 ; chyba

; ------ nastaven¡ programov‚ho adres ýe (CX=5)

         push      ds

         push      ds
         pop       es                       ; ES <- datovì segment

         mov       ds,ds:[SegPSP]           ; segment PSP
         mov       ds,ds:[2ch]              ; segment prostýed¡
         xor       si,si                    ; zaŸ tek prostýed¡
OutFile3:inc       si
         cmp       word ptr ds:[si-1],0
         jne       OutFile3
         add       si,3                     ; zaŸ tek jm‚na programu

         mov       di,offset ParExec0
OutFile4:mov       bx,di                    ; £schova konce cesty
OutFile5:lodsb
         stosb                              ; pýenesen¡ bajtu
         cmp       al,"\"                   ; je oddØlovaŸ cesty ?
         je        OutFile4                 ; £schova konce cesty
         cmp       di,offset ParExec0+125
         jae       OutFile6
         cmp       al,0
         jne       OutFile5                 ; dalç¡ znak

OutFile6:pop       ds

         mov       di,offset ParExec0
         sub       bx,di                    ; BX <- d‚lka textu parametru
         mov       si,offset ParExec
         call      SetEnv                   ; nastaven¡ textu parametru

OutFile9:ret

OutFile  ENDP

; -----------------------------------------------------------------------------
;                                SetEnv
;           nastaven¡ parametru v syst‚mov‚m prostýed¡ DOS
; -----------------------------------------------------------------------------
; VSTUP: BX=d‚lka textu parametru (0=zruçen¡ parametru) (max. 255 !)
;        CX=d‚lka jm‚na parametru
;        DS:SI=jm‚no parametru (mus¡ bìt velk  p¡smena !)
;        DS:DI=text parametru
;        DS=datovì segment
; VíSTUP: CY=nedostatek pamØti
; -----------------------------------------------------------------------------
; lok ln¡ promØnn‚: SS:[BP-2] (2) d‚lka jm‚na parametru
;                   SS:[BP-4] (2) d‚lka textu parametru
;                   SS:[BP-6] (2) adresa jm‚na parametru
;                   SS:[BP-8] (2) adresa textu parametru
; -----------------------------------------------------------------------------

SetEnv   PROC      NEAR

; ------ £schova registr…

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,sp
         sub       sp,8

; ------ £schova ukazatel…

         mov       ss:[bp-2],cx             ; d‚lka jm‚na parametru
         mov       ss:[bp-4],bx             ; d‚lka textu parametru
         mov       ss:[bp-6],si             ; adresa jm‚na parametru
         mov       ss:[bp-8],di             ; adresa textu parametru

; ------ nalezen¡ parametru v prostýed¡ -> ES:DI

         call      far ptr GetEnv           ; nalezen¡ parametru v prostýed¡ DOS
         jc        SetEnv5                  ; parametr nenalezen

; ------ zaŸ tek parametru -> ES:DI

         dec       di                       ; pýeskoŸen¡ oddØlovaŸe "="
         sub       di,cx                    ; zaŸ tek parametru

; ------ nalezen¡ zaŸ tku dalç¡ho parametru -> SI

         mov       si,di                    ; SI <- zaŸ tek parametru
         mov       cx,-1
         mov       al,0                     ; hledanì bajt
         cld
         repne     scasb                    ; nalezen¡ konce parametru
         xchg      si,di                    ; SI=dalç¡ parametr, DI=zaŸ tek

; ------ zruçen¡ nalezen‚ho star‚ho ýetØzce

SetEnv2: movs      byte ptr es:[di],es:[si] ; pýenos jednoho bajtu
         cmp       word ptr es:[si-2],0     ; byl ji§ konec prostýed¡ ?
         jne       SetEnv2                  ; pýenesen¡ a§ po konec prostýed¡
         xor       ax,ax                    ; AX <- 0 poŸet jmen program…
         stosw                              ; pý¡znak, §e nen¡ ýetØzec programu

; ------ test, zda m  bìt ýetØzec ulo§en

SetEnv5: cmp       word ptr ss:[bp-4],0     ; je nØjakì text ?
         je        SetEnv9                  ; nen¡ text parametru

; ------ pý¡prava velikosti prostýed¡ -> BX

         mov       ax,ds:[EnvParnt]         ; segment prostýed¡
         dec       ax                       ; adresa popisovaŸe bloku
         mov       es,ax                    ; ES <- adresa popisovaŸe bloku
         mov       bx,es:[3]                ; BX <- velikost pamØœov‚ho bloku
         inc       ax                       ; adresa dat pamØœov‚ho bloku
         mov       es,ax                    ; adresa segmentu prostýed¡
         shl       bx,1
         shl       bx,1
         shl       bx,1
         shl       bx,1                     ; velikost v bajtech

; ------ nalezen¡ konce prostýed¡ -> DI

         xor       di,di
         cld
SetEnv6: inc       di
         cmp       word ptr es:[di-1],0
         jne       SetEnv6                  ; nalezen¡ konce prostýed¡

; ------ test, zda je v segmentu dost m¡sta pro ýetØzec

         mov       ax,di                    ; adresa k ulo§en¡ ýetØzce
         add       ax,ss:[bp-2]             ; pýiŸten¡ d‚lky jm‚na parametru
         add       ax,ss:[bp-4]             ; pýiŸten¡ d‚lky textu parametru
         add       ax,1+1+1                 ; vŸetnØ "=" a 2*"0"
         cmp       bx,ax                    ; je dost voln‚ho m¡sta ?
         jb        SetEnv9                  ; nedostatek m¡sta

; ------ pýenesen¡ jm‚na parametru

         cld
         mov       si,ss:[bp-6]             ; adresa jm‚na parametru
         mov       cx,ss:[bp-2]             ; d‚lka jm‚na parametru
         rep       movsb                    ; pýenesen¡ jm‚na parametru

; ------ oddØlovac¡ znak "="

         mov       al,"="
         stosb

; ------ pýenesen¡ textu parametru

         mov       si,ss:[bp-8]             ; adresa textu parametru
         mov       cx,ss:[bp-4]             ; d‚lka textu parametru
         rep       movsb                    ; pýenesen¡ textu parametru

; ------ koncov  0

         xor       ax,ax
         stosw                              ; 0 za ýetØzcem a za prostýed¡m
;         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

SetEnv9: mov       sp,bp
         pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

SetEnv  ENDP

; -----------------------------------------------------------------------------
;                                  GetEnv
;               poskytnut¡ parametru z otcovk‚ho prostýed¡ DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
;        DS:SI=jm‚no parametru (mus¡ bìt velk  p¡smena !)
;        CX=d‚lka jm‚na parametru
; VíSTUP: ES:DI=adresa nalezen‚ho parametru (za oddØlovaŸem "=")
;         CY=parametr nenalezen (ES nedefinov no)
; -----------------------------------------------------------------------------

GetEnv   PROC      NEAR

; ------ £schova registr…

         push      ax

; ------ pý¡prava k vyhled n¡ parametru

         cld
         mov       es,ds:[EnvParnt]         ; segment prostýed¡
         xor       di,di                    ; DI <- 0 zaŸ tek prostýed¡

; ------ test, zda je dalç¡ ýetØzec

GetEnv2: cmp       byte ptr es:[di],0       ; je konec prostýed¡ ?
         stc                                ; pý¡znak nenalezen¡ ýetØzce
         je        GetEnv9                  ; ýetØzec nenalezen

; ------ porovn n¡ jm‚na ýetØzce

         push      cx
         push      si
         push      di

GetEnv3: mov       al,es:[di]
         call      UpCase                   ; konverze AL na velk‚ p¡smeno
         inc       di
         mov       ah,al
         lodsb
         cmp       al,ah                    ; porovn n¡ znak…
         loope     GetEnv3                  ; je shoda - dalç¡ bajt
         jne       GetEnv6                  ; jm‚na nejsou shodn 
         cmp       byte ptr es:[di],"="     ; n sleduj¡c¡ znak mus¡ bìt "="

GetEnv6: pop       di
         pop       si
         pop       cx
         je        GetEnv8                  ; ýetØzec nalezen OK

; ------ ýetØzec nesouhlas¡ - nalezen¡ dalç¡ho ýetØzce

         mov       al,0
GetEnv7: scasb                              ; nalezen konce ýetØzce ?
         jne       GetEnv7                  ; nalezen¡ konce ýetØzce
         jmp       short GetEnv2            ; test dalç¡ho ýetØzce

; ------ ýetØzec nalezen OK

GetEnv8: add       di,cx                    ; pýeskoŸen¡ jm‚na parametru
         inc       di                       ; pýeskoŸen¡ znaku "="
         clc                                ; pý¡znak operace OK

; ------ n vrat registr…

GetEnv9: pop       ax
         ret

GetEnv   ENDP

; -----------------------------------------------------------------------------
;        inicializace otcovsk‚ho prostýed¡ (CY=nenalezeno nebo chyba pamØti)
; -----------------------------------------------------------------------------

ParEnv   PROC      NEAR

; ------ z¡sk n¡ PSP z ukazatele DOS nebo z adresy Ctrl-C

         mov       bp,16h                   ; segment otcovsk‚ho PSP
         call      ParEnv3                  ; test otcovsk‚ho prostýed¡
         jnc       ParEnv8                  ; prostýed¡ nalezeno OK
         mov       bp,10h                   ; segment pýeruçen¡ Ctrl-C

; ------ adresa PSP otcovsk‚ho programu -> ES a BP

ParEnv3: mov       es,ds:[SegPSP]           ; segment PSP
         mov       es,es:[bp]               ; segment otcovsk‚ho PSP
         mov       bp,es                    ; BP <- £schova adresy PSP
         cmp       bp,ds:[SegPSP]           ; nen¡ to n hodou tento program ?
         je        ParEnv6                  ; je to tento program

; ------ test, zda je to PSP - mus¡ zaŸ¡nat INT 20h

         cmp       word ptr es:[0],20cdh    ; je instrukce INT 20h ?
         jne       ParEnv6                  ; nen¡ PSP programu

; ------ test segmentu otcovsk‚ho programu ES

         call      TestAMem                 ; test platnosti alokaŸn¡ho bloku
         jc        ParEnv6                  ; nen¡ to platnì alokaŸn¡ blok

; ------ adresa prostýed¡ otcovsk‚ho programu -> ES

         mov       es,es:[2ch]              ; segment otcovsk‚ho prostýed¡
         mov       ds:[EnvParnt],es         ; adresa prostýed¡ otcovsk‚ho prog.

; ------ test, zda je prostýed¡ platnì blok

         call      TestAMem                 ; test alokaŸn¡ho bloku prostýed¡
         jc        ParEnv6                  ; nen¡ to platnì alokaŸn¡ blok

; ------ ukazatel popisovaŸe alokaŸn¡ho bloku prostýed¡ -> ES

         mov       ax,es                    ; segment prostýed¡
         dec       ax
         mov       es,ax
         inc       ax

; ------ kontrola vlastn¡ka bloku prostýed¡

         cmp       bp,es:[1]                ; souhlas¡ vlastn¡k prostýed¡ ?
         jne       ParEnv6                  ; vlastn¡k prostýed¡ nesouhlas¡

; ------ kontrola velikosti prostýed¡

         mov       bx,es:[3]                ; BX <- velikost prostýed¡
         cmp       bx,5                     ; minim ln¡ velikost prostýed¡
         jb        ParEnv6                  ; prostýed¡ pý¡liç mal‚
         cmp       bx,0f00h                 ; maxim ln¡ velikost prostýed¡
         ja        ParEnv6                  ; prostýed¡ pý¡liç velk‚

; ------ nalezen¡ konc… ýetØzc… v prostýed¡

         mov       es,ax                    ; ES <- adresa prostýed¡
         mov       cx,0e000h                ; maxim ln¡ velikost k hled n¡
         xor       di,di                    ; zaŸ tek dat
ParEnv4: inc       di
         cmp       word ptr es:[di-1],0     ; je konec prostýed¡ ?
         loopne    ParEnv4                  ; nalezen¡ konce prostýes¡
         jne       ParEnv6                  ; nenalezen konec
         inc       di                       ; pýeskoŸen¡ koncov‚ 0

; ------ kontrola velikosti prostýed¡ (zda je uvnitý bloku)

         mov       cl,4
         shl       bx,cl                    ; pýevod velikosti na bajty
         cmp       bx,di                    ; je velikost prostýed¡ OK ?
         jae       ParEnv42                 ; je to OK

; ------ chyba operace

ParEnv6: stc                                ; pý¡znak chyby
ParEnv8: ret

; ------ naŸten¡ parametru "XFILE"

ParEnv42:mov       si,offset ParFile        ; parametr "XFILE"
         mov       cx,5                     ; d‚lka jm‚na parametru
         call      GetEnv                   ; nalezen¡ parametru v prostýed¡
         jc        ParEnv53                 ; parametr nenalezen
         mov       cx,8                     ; maxim lnØ znak…
         mov       si,offset ParFile0       ; buffer k ulo§en¡ parametru
ParEnv51:mov       al,es:[di]               ; znak parametru
         inc       di
         cmp       al," "
         je        ParEnv51                 ; vypuçtØn¡ poŸ teŸn¡ch mezer
         dec       di

ParEnv52:mov       al,es:[di]
         inc       di
         cmp       al,0
         je        ParEnv53
         call      UpCase                   ; konverze na velk‚ p¡smeno
         mov       ds:[si],al               ; ulo§en¡ znaku
         inc       si
         loop      ParEnv52

; ------ naŸten¡ parametru "XDISK"

ParEnv53:mov       si,offset ParDisk        ; parametr "XDISK"
         mov       cx,5                     ; d‚lka jm‚na parametru
         call      GetEnv                   ; nalezen¡ parametru v prostýed¡
         jc        ParEnv56                 ; parametr nenalezen
ParEnv54:mov       al,es:[di]               ; znak parametru
         inc       di
         cmp       al," "
         je        ParEnv51                 ; vypuçtØn¡ poŸ teŸn¡ch mezer
         call      UpCase                   ; konverze na velk‚ p¡smeno
         mov       ds:[ParDisk0],al         ; ulo§en¡ naŸten‚ho parametru

; ------ kontrola pamØti pro "XFILE"

ParEnv56:mov       si,offset ParFile        ; parametr "XFILE"
         mov       cx,5                     ; d‚lka jm‚na parametru
         mov       bx,cx                    ; d‚lka textu parametru
         mov       di,offset ParNul         ; nulovac¡ parametr
         call      SetEnv                   ; nastaven¡ ýetØzce
         jc        ParEnv6                  ; pýeteŸen¡ pamØti

; ------ kontrola pamØti pro "XDISK" (CX=5, BH=0, DI=nulovac¡ parametr)

         mov       si,offset ParDisk        ; parametr "XDISK"
         mov       bl,1                     ; d‚lka textu parametru
         call      SetEnv                   ; nastaven¡ ýetØzce
         jc        ParEnv6                  ; chyba operace

; ------ zruçen¡ parametr…

         xor       bx,bx                    ; BX <- 0
         call      SetEnv                   ; zruçen¡ parametru "XDISK"
         mov       si,offset ParFile        ; parametr "XFILE"
         call      SetEnv                   ; zruçen¡ parametru "XFILE"
         ret

ParEnv   ENDP

; -----------------------------------------------------------------------------
;                              TestAMem
;                      ovØýen¡ platnosti alokaŸn¡ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=adresa alokaŸn¡ho bloku
;        DS=datovì segment
; VíSTUP: CY=nen¡ platnì alokaŸn¡ blok
; -----------------------------------------------------------------------------

TestAMem PROC      NEAR

; ------ test, zda je to platnì alokaŸn¡ blok

         call      Tst1AMem                 ; test alokaŸn¡ho bloku
         jc        TestAMm9                 ; nen¡ to platnì alokaŸn¡ blok

; ------ £schova registr…

         push      ax
         push      bx
         push      es

; ------ pý¡prava k testu alokaŸn¡ho bloku

         mov       bx,ds:[SegPSP]           ; segment PSP
         mov       ax,es                    ; testovanì alokaŸn¡ blok
         cmp       ax,bx                    ; je testovanì blok pýed programem ?
         jb        TestAMm2                 ; testovanì blok je pýed programem
         xchg      ax,bx                    ; oprava poýad¡ bajt…
         mov       es,ax                    ; vìchoz¡ adresa

; ------ test, zda je pr…chod pýes blok

TestAMm2:mov       ax,es
         cmp       ax,bx                    ; je pr…chod pýes testovanì blok ?
         jne       TestAMm3                 ; nen¡
         xor       bx,bx                    ; pý¡znak pr…chodu pýes blok

; ------ nalezen¡ dalç¡ho bloku

TestAMm3:call      NextAMem                 ; nalezen¡ dalç¡ho bloku
         jc        TestAMm8                 ; chyba - nen¡ platnì blok
         jne       TestAMm2                 ; je dalç¡ alokaŸn¡ blok

; ------ test, zda byl pr…chod pýes blok

         or        bx,bx                    ; byl pr…chod pýes program ?
         jz        TestAMm8                 ; byl pr…chod pýes program
         stc                                ; pý¡znak chyby

; ------ n vrat registr…

TestAMm8:pop       es
         pop       bx
         pop       ax
TestAMm9:ret

TestAMem ENDP

; -----------------------------------------------------------------------------
;                                NextAMem
;                   dalç¡ alokaŸn¡ blok ýetØzce blok… DOS
; -----------------------------------------------------------------------------
; VSTUP: DS=datovì segment
;        ES=segment alokaŸn¡ho bloku pamØti (mus¡ bìt platnì !)
; VíSTUP: ZY=je posledn¡, nen¡ dalç¡ blok (a NC)
;         CY=chyba ýetØzce pamØti
;         ES=adresa dalç¡ho alokaŸn¡ho bloku (pýi ZY nebo CY je ES nedefinov n)
; -----------------------------------------------------------------------------

NextAMem PROC      NEAR

; ------ £schova registr…

         push      ax

; ------ adresa prefixu alokaŸn¡ho bloku

         mov       ax,es
         dec       ax
         mov       es,ax                    ; ES <- adresa alokaŸn¡ho bloku
         inc       ax                       ; AX <- adresa dat bloku

; ------ test, zda je to posledn¡ alokaŸn¡ blok

         cmp       byte ptr es:[0],"Z"
         jne       NxtAMem6                 ; bude dalç¡ blok

; ------ test, zda je konec UMB

         cmp       ax,0b800h
         jae       NxtAMem5                 ; nen¡ dalç¡ blok

; ------ test, zda dalç¡ blok pýeskakuje hranici B800

         push      ax
         push      es

         stc
         adc       ax,es:[3]                ; adresa dalç¡ho bloku
         jc        NxtAMem4                 ; chyba
         mov       es,ax                    ; ES <- adresa
         call      Tst1AMem                 ; test alokaŸn¡ho bloku
         jc        NxtAMem4                 ; chyba
         cmp       ax,0b800h                ; je poŸ tek pýed hranic¡ B800 ?
         cmc
         jc        NxtAMem4                 ; nen¡ pýed hranic¡ B800
         dec       ax
         mov       es,ax
         inc       ax
         stc
         adc       ax,es:[3]                ; adresa dalç¡ho bloku
         jc        NxtAMem4                 ; chyba
         cmp       ax,0b800h                ; je za hranic¡ B800 ? (CY=nen¡)

NxtAMem4:pop       es
         pop       ax
         jnc       NxtAMem6                 ; je dalç¡ blok OK
NxtAMem5:xor       ax,ax                    ; pý¡znak, §e nen¡ dalç¡ blok
         jmp       short NxtAMem9           ; nen¡ dalç¡ alokaŸn¡ blok

; ------ adresa dalç¡ho bloku

NxtAMem6:stc
         adc       ax,es:[3]                ; adresa dalç¡ho bloku
         jc        NxtAMem9                 ; chyba pýeteŸen¡

; ------ test, zda je dalç¡ alokaŸn¡ blok platnì

         mov       es,ax                    ; ES <- segment alokaŸn¡ho bloku
         call      Tst1AMem                 ; test alokaŸn¡ho bloku
         jc        NxtAMem9                 ; chyba
         or        ax,ax                    ; nastaven¡ pý¡znaku NZ, NC

; ------ n vrat registr…

NxtAMem9:pop       ax
         ret

NextAMem ENDP

; -----------------------------------------------------------------------------
;                              Tst1AMem
;                test alokaŸn¡ho bloku s testem vlastn¡ka
; -----------------------------------------------------------------------------
; VSTUP: ES=segment alokaŸn¡ho bloku
; VíSTUP: CY=z hlav¡ alokaŸn¡ho bloku je neplatn‚
; -----------------------------------------------------------------------------

Tst1AMem PROC      NEAR

; ------ test alokaŸn¡ho bloku

         call      Tst0AMem                 ; test tohoto alokaŸn¡ho bloku
         jc        Tst1AMm9                 ; alokaŸn¡ blok je neplatnì

; ------ £schova registr…

         push      ax
         push      es

; ------ adresa z hlav¡ alokaŸn¡ho bloku

         mov       ax,es
         dec       ax
         mov       es,ax                    ; ES <- z hlav¡ alokaŸn¡ho bloku

; ------ adresa vlastn¡ka alokaŸn¡ho bloku

         mov       ax,es:[1]                ; adresa vlastn¡ka alokaŸn¡ho bloku
         cmp       ax,70h                   ; tento blok se netestuje
         cmc
         jnc       Tst1AMm8                 ; alokaŸn¡ blok je volnì/DOS
         mov       es,ax                    ; ES <- adresa vlastn¡ka alok. bloku

; ------ test vlastn¡ka alokaŸn¡ho bloku

         call      Tst0AMem                 ; test vlastn¡ka alokaŸn¡ho bloku

; ------ n vrat registr…

Tst1AMm8:pop       es
         pop       ax
Tst1AMm9:ret

Tst1AMem ENDP

; -----------------------------------------------------------------------------
;                               Tst0AMem
;                     test z hlav¡ alokaŸn¡ho bloku
; -----------------------------------------------------------------------------
; VSTUP: ES=segment alokaŸn¡ho bloku
; VíSTUP: CY=z hlav¡ alokaŸn¡ho bloku je neplatn‚
; -----------------------------------------------------------------------------

Tst0AMem PROC      NEAR

; ------ £schova registr…

         push      ax
         push      ds

; ------ adresa prefixu alokaŸn¡ho bloku

         mov       ax,es                    ; segment alokaŸn¡ho bloku
         cmp       ax,50h                   ; minim ln¡ adresa alokaŸn¡ho bloku
         jbe       Tst0AMm8                 ; neplatn  adresa bloku
         dec       ax                       ; adresa z hlav¡ alokaŸn¡ho bloku
         mov       ds,ax                    ; ES <- adresa alokaŸn¡ho bloku

; ------ test typu alokaŸn¡ho bloku

         cmp       byte ptr ds:[0],"M"
         je        Tst0AMm9                 ; stýedn¡ alokaŸn¡ blok
         cmp       byte ptr ds:[0],"Z"
         je        Tst0AMm9                 ; posledn¡ alokaŸn¡ blok

; ------ n vrat registr…

Tst0AMm8:stc                                ; pý¡znak neplatnosti z hlav¡ bloku
Tst0AMm9:pop       ds
         pop       ax
         ret

Tst0AMem ENDP

; *****************************************************************************
;
;                             Pomocn‚ obsluhy
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

Int24:   mov       al,0                     ; pý¡znak ignorov n¡ chyby
         iret

; -----------------------------------------------------------------------------
;        konverze AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

UpCase   PROC      NEAR

         cmp       al,"a"
         jb        UpCase2
         cmp       al,"z"
         ja        UpCase2
         sub       al,32
UpCase2: ret

UpCase   ENDP

; *****************************************************************************
;
;                            Data
;
; *****************************************************************************
;þ
Font08   label     byte
INCLUDE  font08.asm

; ------ obr zek kurzoru myçi

KurzMous dw        0111111111111111b        ; obr zek kurzoru myçi
         dw        0011111111111111b
         dw        0001111111111111b
         dw        0000111111111111b
         dw        0000011111111111b
         dw        0000001111111111b
         dw        0000000111111111b
         dw        0000000011111111b
         dw        0000000001111111b
         dw        0000001111111111b
         dw        0010001111111111b
         dw        0110000111111111b
         dw        1111000111111111b
         dw        1111000011111111b
         dw        1111100011111111b
         dw        1111100011111111b

         dw        0000000000000000b
         dw        0000000000000000b
         dw        0100000000000000b
         dw        0110000000000000b
         dw        0111000000000000b
         dw        0111100000000000b
         dw        0111110000000000b
         dw        0111111000000000b
         dw        0111100000000000b
         dw        0100100000000000b
         dw        0000100000000000b
         dw        0000010000000000b
         dw        0000010000000000b
         dw        0000001000000000b
         dw        0000001000000000b
         dw        0000000000000000b

; -----------------------------------------------------------------------------
;        soubor obr zku ICO
; -----------------------------------------------------------------------------

SoubICO  label     byte
                                           ;* z hlav¡ souboru
         dw        0                        ; (rezervov no)
         dw        1                        ; verze souboru
         dw        1                        ; poŸet obr zk… v souboru
         db        SIRX                     ; ç¡ýka ikony (bod…)
         db        VYSY                     ; vìçka ikony (bod…)
         db        COLS                     ; poŸet barev ikony
         db        0                        ; (rezervov no)
         dw        0,0                      ; (rezervov no)
         dd        40 + 4*COLS + SIRX*VYSY*COLSB/8 + SIRX*VYSY/8 ; velikost dat
         dd        22                       ; velikost z hlav¡ souboru

                                          ;* z hlav¡ obr zku
         dd        40                       ; velikost z hlav¡ obr zku
         dd        SIRX                     ; ç¡ýka a vìçka plochy obr zku
         dd        4*COLS                   ; velikost tabulky palet
         dw        1
         dd        COLSB                    ; poŸet bit… na bod
         dw        0
         dd        SIRX*VYSY*COLSB/8 + SIRX*VYSY/8 ; velikost data+maska obr zku
         dd        0,0,0,0

                                          ;* tabulka palet (poýad¡ B/G/R/0)
         db          0,  0,  0,  0          ;  0: Ÿern 
         db          0,  0,128,  0          ;  1: tmavØ Ÿerven 
         db          0,128,  0,  0          ;  2: tmavØ zelen 
         db          0,128,128,  0          ;  3: tmavØ §lut 
         db        128,  0,  0,  0          ;  4: tmavØ modr 
         db        128,  0,128,  0          ;  5: tmavØ purpurov 
         db        128,128,  0,  0          ;  6: tmavØ azurov 
         db        128,128,128,  0          ;  7: tmavØ çed 
         db        192,192,192,  0          ;  8: svØtle çed 
         db          0,  0,255,  0          ;  9: svØtle Ÿerven 
         db          0,255,  0,  0          ; 10: svØtle zelen 
         db          0,255,255,  0          ; 11: svØtle §lut 
         db        255,  0,  0,  0          ; 12: svØtle modr 
         db        255,  0,255,  0          ; 13: svØtle purpurov 
         db        255,255,  0,  0          ; 14: svØtle azurov 
         db        255,255,255,  0          ; 15: b¡l 

IcoBuff  db        SIRX*VYSY*COLSB/8 dup(0)  ; buffer dat ikony

IcoMask  db        SIRX*VYSY/8 dup(0)       ; maska ikony

SoubIco2 label     byte

; ------ palety

PalVGA   label     byte                     ; palety VGA
;                    modr 
;                    ³   zelen 
;                    ³   ³   Ÿerven 
;                    ³   ³   ³
         db          0,  0,  0              ;  0: Ÿern 
         db          0,  0, 32              ;  1: tmavØ Ÿerven 
         db          0, 32,  0              ;  2: tmavØ zelen 
         db          0, 32, 32              ;  3: tmavØ §lut 
         db         32,  0,  0              ;  4: tmavØ modr 
         db         32,  0, 32              ;  5: tmavØ purpurov 
         db         32, 32,  0              ;  6: tmavØ azurov 
         db         32, 32, 32              ;  7: tmavØ çed 
         db         48, 48, 48              ;  8: svØtle çed 
         db          0,  0, 63              ;  9: svØtle Ÿerven 
         db          0, 63,  0              ; 10: svØtle zelen 
         db          0, 63, 63              ; 11: svØtle §lut 
         db         63,  0,  0              ; 12: svØtle modr 
         db         63,  0, 63              ; 13: svØtle purpurov 
         db         63, 63,  0              ; 14: svØtle azurov 
         db         63, 63, 63              ; 15: b¡l 

; ------ palety EGA

PalEGA   label     byte
;                  sek.Ÿerven 
;                  ³sek.zelen 
;                  ³³sek.modr 
;                  ³³³Ÿerven 
;                  ³³³³zelen 
;                  ³³³³³modr 
;                  ³³³³³³
         db        000000b                  ;  0: Ÿern 
         db        000100b                  ;  1: tmavØ Ÿerven 
         db        000010b                  ;  2: tmavØ zelen 
         db        000110b                  ;  3: tmavØ §lut 
         db        000001b                  ;  4: tmavØ modr 
         db        000101b                  ;  5: tmavØ purpurov 
         db        000011b                  ;  6: tmavØ azurov 
         db        111000b                  ;  7: tmavØ çed 
         db        000111b                  ;  8: svØtle çed 
         db        100100b                  ;  9: svØtle Ÿerven 
         db        010010b                  ; 10: svØtle zelen 
         db        110110b                  ; 11: svØtle §lut 
         db        001001b                  ; 12: svØtle modr 
         db        101101b                  ; 13: svØtle purpurov 
         db        011011b                  ; 14: svØtle azurov 
         db        111111b                  ; 15: b¡l 
         db        000000b                  ; okol¡ obrazovky

; ------ parametry

SegPSP   dw        0                        ; segment PSP (pro program EXE)
EnvParnt dw        0                        ; adresa otcovsk‚ho prostýed¡

;MouseX   dw        0                        ; souýadnice myçi X
;MouseY   dw        0                        ; souýadnice myçi Y
;MouseB   db        0                        ; stav tlaŸ¡tek myçi
;                                            ;   1=lev‚ tlaŸ¡tko
;                                            ;   1=prav‚ tlaŸ¡tko

ParFile  db        'XFILE'                  ; parametr - jm‚no souboru
ParFile0 db        '        '               ; naŸtenì parametr - jm‚no souboru
ParDisk  db        'XDISK'                  ; parametr - jm‚no disku
ParDisk0 db        ' '                      ; naŸtenì parametr - jm‚no disku
ParPath  db        'XPATH'                  ; parametr - jm‚no cesty
ParHome  db        'XHOME'                  ; parametr - domovskì disk
ParHome0 db        ' '                      ; Ÿ¡slo domovsk‚ho disku k nastaven¡
ParExec  db        'XEXEC'                  ; parametr - programovì adres ý
ParExec0 db        128 dup(0)               ; buffer jm‚na programu
ParNul   db        '        '               ; nulovac¡ parametr

QSrcN    dw        0                        ; poŸet p¡smen pýi rychlovyhled v n¡
Param    db        0                        ; parametry
                                            ;   bit 0: 1=kurzor zapnut
                                            ;   bit 1: 1=je myç
                                            ;   bit 2: 1=kurzor myçi zapnut

TypCard  db        0                        ; typ videokarty
                                            ;   1=Hercules
                                            ;   2=CGA
                                            ;   3=EGA
                                            ;   4=VGA
AdrVRAM  dw        0                        ; adresa videopamØti
Sirka    dw        0                        ; ç¡ýka linky obrazovky v bajtech
Vyska    dw        0                        ; vìçka obrazovky v link ch
NumX     dw        0                        ; poŸet ikon horizont lnØ
NumY     dw        0                        ; poŸet ikon vertik lnØ
NumXY    dw        0                        ; poŸet ikon na str nku celkem
TopX     dw        0                        ; poŸ teŸn¡ pozice ikony na ý dku
TopY     dw        0                        ; poŸ teŸn¡ linka ikony
IncX     dw        0                        ; pý¡rustek adresy ikony X (bajt…)
IncY     dw        0                        ; pý¡rustek adresy ikony Y (linek)

;SirkaX   dw        0                        ; ç¡ýka linky obrazovky v bodech
;                                            ;  (pro CGA a Hercules bod=2 bity)
;SirkaB   dw        0                        ; ç¡ýka linky obrazovky v bajtech
;VyskaY   dw        0                        ; vìçka obrazovky v link ch
;
;NumX     dw        0                        ; maxim ln¡ poŸet ikon na ý dku
;NumY     dw        0                        ; maxim ln¡ poŸet ikon na vìçku
;NumXY    dw        0                        ; maxim ln¡ poŸet ikon na str nku
;TopX     dw        0                        ; poŸ teŸn¡ pozice ikon na ý dku
;TopY     dw        0                        ; poŸ teŸn¡ linka ikon na ý dku
;IncX     dw        0                        ; pý¡rustek souýadnice ikon X
;                                            ;  (8 p¡smen + oddØlovac¡ mezera)
;IncY     dw        0                        ; pý¡rustek souýadnice ikon Y
;                                            ;  (ikona + p¡smena + mezera)
;
Hrana1   db        2                        ; hranice Mono pro çedou barvu
Hrana1X  db        20h                      ; hranice Mono pro çedou barvu * 16
Hrana2   db        8                        ; hranice Mono pro b¡lou barvu
Hrana2X  db        80h                      ; hranice Mono pro b¡lou barvu * 16

CitBarev dw        16 dup(0)                ; Ÿ¡taŸ rozlo§en¡ barev

; ------ registry pro inicializaci grafick‚ho re§imu karty HGC

HGCTabR  db        53                       ; 0: horizont lnØ celkem-1
         db        HercSir/2   ;40          ; 1: horizont lnØ zobrazeno
         db        HercSir/2+1 ;44          ; 2: pozice HSYNC
         db        7                        ; 3: ç¡ýka HSYNC
         db        91                       ; 4: vertik lnØ celkem
         db        2           ;1           ; 5: vertik ln¡ korekce
         db        88                       ; 6: vertik lnØ zobrazeno
         db        88                       ; 7: vertik ln¡ pozice
         db        2                        ; 8: m¢d prokl d n¡
         db        3                        ; 9: poŸet linek na ý dek
         db        0                        ; 10: poŸ tek kurzoru
         db        0           ;3           ; 11: konec kurzoru
         db        0                        ; 12: adresa poŸ tku HIGH
         db        0                        ; 13: adresa poŸ tku LOW
         db        0                        ; 14: kurzor HIGH
         db        0                        ; 15: kurzor LOW

; ------ vyhled v n¡ program…

HomeDisk db        0                        ; Ÿ¡slo domovsk‚ho disku
CestaN   dw        Cesta+3                  ; konec cesty (za oddØlovaŸem "\")
Cesta    db        'C:\',90 dup(?)          ; cesta k soubor…m
MaskDisk db        0,0,MaxDisk-2 dup(1)     ; 1=pý¡znaky povolen¡ disk…

ICOExt   db        4,'.ICO'                 ; pý¡pona souboru ikony
ICOAdr   db        5,'_ICO\'                ; adres ý ikon

DTA      label     byte                     ; buffer DTA
         db        21 dup(0)                ; rezervov no
SoubAtr  db        0                        ; atributy souboru
SoubTim  dw        0                        ; Ÿas souboru
SoubDat  dw        0                        ; datum souboru
SoubSiz  dd        0                        ; velikost souboru
SoubNam  db        13 dup(0)                ; buffer jm‚na souboru
         db        0,0,0                    ; nØjak  rezerva za jm‚nem

HelpTxt  db        'PgUp=zpØt  PgDn=vpýed  Enter=start  Mezera=n hled  F1=info  F10=setup  Esc=konec'
HelpTxt0 label     byte

EnvTxt   db        13,10
         db        'Chyba preteceni velikosti systemoveho prostredi ! Je potreba',13,10
         db        'zvetsit prostredi pomoci prikazu SHELL v souboru CONFIG.SYS:',13,10
         db        '      SHELL=C:\COMMAND.COM /E:512 /P',13,10
         db        13,10
         db        '$'

FndTxt   db        13,10
         db        'V aktualnim adresari nenalezen zadny adresar s programy.',13,10
         db        13,10
         db        '$'

; ------ seznam program… (mys¡ bìt posledn¡ !!!!)

SeznamT  dw        ?                        ; Ÿ¡slo prvn¡ polo§ky na str nce
SeznamA  dw        ?                        ; Ÿ¡slo aktivn¡ polo§ky
SeznamN  dw        ?                        ; poŸet program… v seznamu

Seznam   db        SeznamM*SeznamS dup(?)   ; seznam program…
                                            ;  0: (1) bit 0 a§ 2: d‚lka jm‚na-1
                                            ;         bit 3 a§ 7: disk (0...)
                                            ;  1: (8) jm‚no doplnØno mezerami

Code     ENDS
;þ
Zasob    SEGMENT stack 'STACK'
         dw        200h dup(?)
Zasob    ENDS

         END       Start

; *****************************************************************************
;                           Struktura souboru ICO
;
;    0: (22) z hlav¡ souboru
;  16h: (40) z hlav¡ obr zku
;  3Eh: (64) tabulka palet
;  7Eh: (512) data obr zku
; 27Eh: (128) maska obr zku
; 2FEh: konec
;
; Struktura z hlav¡ souboru ICO:
; -----------------------------
;    00h: (2) ........... rezervov no (mus¡ bìt = 0)
;    02h: (2) ........... typ souboru (mus¡ bìt = 1)
;    04h: (2) ........... poŸet obr zk… ikon v souboru (typicky = 1)
;    06h: (1) ........... ç¡ýka ikony v bodech (typicky 32, povoleno 16, 32, 64)
;    07h: (1) ........... vìçka ikony v bodech (typicky 32, povoleno 16, 32, 64)
;    08h: (1) ........... poŸet barev v ikonØ (typicky 16, povoleno 2, 8, 16)
;    09h: (1) ........... rezervov no (typicky = 0)
;    0Ah: (2) ........... rezervov no (typicky = 0)
;    0Ch: (2) ........... rezervov no (typicky = 0)
;    0Eh: (4) ........... velikost jednoho obr zku v bajtech, typicky:
;                 40 + 4*16 (palety) + 32*32*4/8 (data) + 32*32/8 (maska) = 744
;    12h: (4) ........... velikost tohoto z hlav¡ v bajtech (typicky 22)
;    16h: ............... n sleduje definice prvn¡ho obr zku
;
; Struktura z hlav¡ jednoho obr zku:
; ---------------------------------
;    00h: (4) ........... velikost tohoto z hlav¡ v bajtech (typicky 40)
;    04h: (4) ........... ç¡ýka a vìçka plochy obr zku (typicky 32)
;    08h: (4) ........... velikost tabulky palet v bajtech (typicky 4*16=64)
;                          (pro menç¡ poŸet barev velikost tabulky 4*8=32)
;    0Ch: (2) ........... (typicky 1)
;    0Eh: (4) ........... poŸet bit… na bod (typicky 4)
;    12h: (2) ........... (typicky 0)
;    14h: (4) ........... velikost data + maska obr zku (typicky 32*32*5/8=640)
;    18h: (4) ........... (typicky 0)
;    1Ch: (4) ........... (typicky 0)
;    20h: (4) ........... (typicky 0)
;    24h: (4) ........... (typicky 0)
;    28h: ............... n sleduje tabulka palet
;
; Struktura tabulky definice palet:
; --------------------------------
;    00h: (barev*4) ..... definice palet barev (typicky 16*4=64)
;                       (pro menç¡ poŸet barev minim ln¡ velikost 8*4=32)
;                            ka§d  barva definovan  pomoc¡ 4 bajt…:
;                                 (1) modr  slo§ka 0 a§ 255
;                                 (1) zelen  slo§ka 0 a§ 255
;                                 (1) Ÿerven  slo§ka 0 a§ 255
;                                 (1) doplåkov‚ pý¡znaky (typicky = 0)
;        Implicitn¡ definice palet WINDOWS:
;                                  0   0   0   0   ( 0: Ÿern )
;                                  0   0 128   0   ( 1: tmavØ Ÿerven )
;                                  0 128   0   0   ( 2: tmavØ zelen )
;                                  0 128 128   0   ( 3: tmavØ §lut )
;                                128   0   0   0   ( 4: tmavØ modr )
;                                128   0 128   0   ( 5: tmavØ purpurov )
;                                128 128   0   0   ( 6: tmavØ azurov )
;                                128 128 128   0   ( 7: tmavØ çed )
;                                192 192 192   0   ( 8: svØtle çed )
;                                  0   0 255   0   ( 9: svØtle Ÿerven )
;                                  0 255   0   0   (10: svØtle zelen )
;                                  0 255 255   0   (11: svØtle §lut )
;                                255   0   0   0   (12: svØtle modr )
;                                255   0 255   0   (13: svØtle purpurov )
;                                255 255   0   0   (14: svØtle azurov )
;                                255 255 255   0   (15: b¡l )
;
; Struktura dat jednoho obr zku:
; -----------------------------
;    00h: (ç¡ýka*vìçka*barev/8) ... data obr zku (typicky 32*32*4/8=512)
;                            data jsou ukl d na od spodn¡ linky zleva doprava;
;                            pro 16 barev obsahuje 1 bajt 2 body, horn¡ 4 bity
;                            jsou 1. bod (vlevo), doln¡ 4 bity 2. bod (vpravo)
;
; Struktura masky jednoho obr zku:
; -------------------------------
;   00h: (ç¡ýka*vìçka/8) .. bitov  maska obr zku (typicky 32*32/8=128)
;                            data jsou ukl d na od spodn¡ linky zleva doprava,
;                            horn¡ bity odpov¡daj¡ bod…m vlevo; je-li bit
;                            nastaven na "1", je bod pr…choz¡ pro pozad¡
; *****************************************************************************
;

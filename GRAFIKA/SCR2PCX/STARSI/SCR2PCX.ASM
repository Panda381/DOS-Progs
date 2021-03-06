
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;               Konverze soubor� SCR (z programu GDEMO) na soubory PCX
;
;              pracovn� verze programu - nejsou o쮍t쯱v쟮y chybov� stavy
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

BUFFSIZE EQU       1000h                    ; velikost jednoho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p쯥definov쟮� z쟳obn죏u

Start:   cmp       sp,offset Zasobnik
         jbe       Chyba
         mov       sp,offset Zasobnik

; ------ uvoln늧� aloka뇆죋o bloku

         mov       bx,(offset(Zasobnik-Start)+10fh)/16
         mov       ah,4ah
         int       21h
         jc        Chyba

; ------ vytvo쯥n� aloka뇆죋o bloku bufferu

         mov       bx,4000h                 ; po멲dovan� pam닟 256 KB
         mov       ah,48h
         int       21h                      ; vytvo쯥n� bloku pam늯i
         jnc       Start0

; ------ chyba pam늯i

Chyba:   mov       dx,offset MemErr
         mov       ah,9
         int       21h
         int       20h

; ------ sestaven� adres buffer�

Start0:  mov       ds:[Buffer0],ax          ; buffer roviny 0
         add       ax,1000h
         mov       ds:[Buffer1],ax          ; buffer roviny 1
         add       ax,1000h
         mov       ds:[Buffer2],ax          ; buffer roviny 2
         add       ax,1000h
         mov       ds:[Buffer3],ax          ; buffer roviny 3

; ------ zobrazen� 즪odn죋o textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ 놽k쟮� na stisk kl쟶esy

         mov       ah,0
         int       16h                      ; vstup znaku z kl쟶esnice

; ------ p쯥ru쮍n� programu

         or        ax,ax                    ; Ctrl-Break ?
         jz        Start1                   ; je Ctrl-Break
         cmp       al,27                    ; je ESC ?
         jne       Start2                   ; nen� ESC
Start1:  int       20h

; ------ definice adresy DTA

Start2:  mov       dx,offset DTA
         mov       ah,1ah
         int       21h

; ------ nalezen� prvn죋o/dalÆho souboru

         mov       dx,offset Soubory        ; specifikace soubor� SCR
         xor       cx,cx
         mov       ah,4eh
Start3:  int       21h                      ; nalezen� prvn죋o/dalÆho souboru
         jnc       Start4                   ; nalezen soubor OK
         int       20h

; ------ otev쯥n� vstupn죋o souboru

Start4:  mov       ax,3d00h
         mov       dx,offset DTAName
         int       21h                      ; otev쯥n� souboru
         jc        Start9                   ; chyba

; ------ inicializace ukazatel� v쁲tupn죋o souboru

         mov       ds:[InpIdent],ax         ; identifik쟴or vstupn죋o souboru
         mov       word ptr ds:[InpNum],0   ; po놽t bajt� ve vstupn죑 bufferu
         mov       word ptr ds:[InpRead],0  ; offset 뇍ec� adresy z bufferu
         mov       byte ptr ds:[SCRCit],0   ; 눀ta� komprese
         mov       byte ptr ds:[SCRKomp],1  ; nastaven� pæznaku komprese

; ------ nalezen� pæpony jm굈a souboru

         mov       si,dx                    ; SI <- jm굈o souboru
Start5:  inc       si
         cmp       byte ptr ds:[si-1],"."
         jne       Start5                   ; nalezen� odd늢ovac� te뇃y

; ------ n쟦rada pæponou PCX

         mov       word ptr ds:[si],"CP"
         mov       word ptr ds:[si+2],"X"

; ------ vytvo쯥n� v쁲tupn죋o souboru PCX

         xor       cx,cx                    ; atributy
         mov       ah,3ch
         int       21h                      ; vytvo쯥n� v쁲tupn죋o souboru
         jc        Start8                   ; chyba

; ------ inicializace ukazatel� v쁲tupn죋o souboru

         mov       ds:[OutIdent],ax         ; identifik쟴or v쁲tupn죋o souboru
         mov       word ptr ds:[OutNum],0   ; po놽t bajt� ve v쁲tupn죑 bufferu
         mov       byte ptr ds:[PCXCit],0c0h; nen� 몺dn� znak k opakov쟮�

; ------ konverze souboru (SI=pæpona jm굈a souboru !)

         call      Konvert                  ; konverze souboru

; ------ uzav쯥n� v쁲tupn죋o souboru

         mov       bx,ds:[OutIdent]         ; identifik쟴or v쁲tupn죋o souboru
         mov       ah,3eh
         int       21h                      ; uzav쯥n� v쁲tupn죋o souboru

; ------ uzav쯥n� vstupn죋o souboru

Start8:  mov       bx,ds:[InpIdent]         ; identifik쟴or vstupn죋o souboru
         mov       ah,3eh
         int       21h                      ; uzav쯥n� vstupn죋o souboru

; ------ pæprava pro dalÆ soubor

Start9:  mov       ah,4fh
         jmp       Start3                   ; dalÆ soubor

; -----------------------------------------------------------------------------
;        konverze obr쟺ku (SI=pæpona jm굈a souboru)
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

; ------ zobrazen� jm굈a souboru

         mov       word ptr ds:[si-1],13 + 10*256
         mov       word ptr ds:[si+1],"$"
         mov       dx,offset DTAName
         mov       ah,9
         int       21h                      ; zobrazen� jm굈a souboru

; ------ inicializace standardn죅h palet SCR (zbytek VGA se ponech� nedefinov쟮)

         push      ds
         pop       es
         mov       si,offset StandCGA       ; standardn� palety
         mov       di,offset PalCGA         ; buffer palet
         mov       cx,1 + 18 + 3*64         ; velikost standardn죅h palet
         cld
         rep       movsb                    ; inicializace standardn죅h palet

; ------ na뇍en� z쟦lav� souboru SCR

         mov       dx,offset SCR            ; z쟦lav� SCR
         mov       cl,offset(SCR0-SCR)      ; d굃ka z쟦lav�
         mov       bx,ds:[InpIdent]         ; identifik쟴or vstupn죋o souboru
         mov       ah,3fh
         int       21h                      ; na뇍en� z쟦lav� vstupn죋o souboru


         test      byte ptr ds:[SCRParam],2 ; textov� re멼m
         jz        Konv10
         ret


; ------ na뇍en� koment젵e k souboru

Konv10:  mov       cl,ds:[SCRKomnt]         ; d굃ka koment젵e
         mov       dx,offset Koment         ; buffer koment젵�
         mov       ah,3fh
         int       21h                      ; na뇍en� koment젵e

; ------ na뇍en� palety CGA

         test      byte ptr ds:[SCRParam],10h ; jsou palety CGA ?
         jz        Konv12                   ; nejsou palety CGA
         mov       dx,offset PalCGA         ; palety CGA
         mov       cl,1                     ; 1 bajt
         mov       ah,3fh
         int       21h                      ; na뇍en� palet CGA

; ------ na뇍en� palet EGA

Konv12:  test      byte ptr ds:[SCRParam],20h ; jsou palety EGA ?
         jz        Konv14                   ; nejsou palety EGA
         mov       dx,offset PalEGA         ; palety EGA
         mov       cl,18                    ; 18 bajt�
         mov       ah,3fh
         int       21h                      ; na뇍en� palet EGA

; ------ na뇍en� palet VGA

Konv14:  test      byte ptr ds:[SCRParam],40h ; jsou palety VGA ?
         jz        Konv16                   ; nejsou palety VGA
         mov       dx,offset PalVGA         ; palety VGA
         mov       cx,3*256                 ; velikost palet
         mov       ah,3fh
         int       21h                      ; na뇍en� palet VGA

; ------ inicializace palet pro 16 barev (EGA) (ES=DS !)

Konv16:  mov       di,offset PCXVGA         ; buffer palet VGA
         cld
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         jne       Konv17                   ; nen� 16 barev
         call      InitEGA                  ; inicializace palet pro EGA
         jmp       short Konv19

; ------ inicializace palet pro 4 barvy (CGA)

Konv17:  cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         jne       Konv18
         call      InitCGA                  ; inicializace palet pro CGA
         jmp       short Konv19

; ------ inicializace palet VGA

Konv18:  call      InitVGA                  ; inicializace palet pro VGA

; ------ pæprava rozm늭� obr쟺ku

Konv19:  mov       ax,ds:[SCRVyska]         ; v삩ka obr쟺ku (linek)
         mov       ds:[PCXVert],ax          ; vertik쟫n� rozli쮑telnost
         dec       ax
         mov       ds:[PCXY2],ax            ; koncov� sou쯠dnice Y2
         mov       ax,ds:[SCRSirka]         ; Æ쯭a obr쟺ku (bod�)
         mov       ds:[PCXHoriz],ax         ; horizont쟫n� rozli쮑telnost
         dec       ax
         mov       ds:[PCXX2],ax            ; koncov� sou쯠dnice X2
         inc       ax                       ; Æ쯭a displeje

; ------ po놽t bit� na bod a po놽t barevn쁟h rovin - m줰 EGA

         push      ax
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; Æ쯭a displeje / 8
         mov       ds:[PCXByte],ax          ; po놽t bajt� na linku
         pop       ax
         mov       byte ptr ds:[PCXBits],1  ; po놽t bit� na bod pro 16 barev EGA
         mov       byte ptr ds:[PCXRovin],4 ; po놽t barevn쁟h rovin
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         je        Konvert3                 ; je 16 barev

; ------ po놽t bit� na bod a po놽t barevn쁟h rovin - m줰 MCGA

         mov       ds:[PCXByte],ax          ; po놽t bajt� na linku
         mov       byte ptr ds:[PCXRovin],1 ; po놽t barevn쁟h rovin
         mov       byte ptr ds:[PCXBits],8  ; po놽t bit� na bod
         cmp       byte ptr ds:[SCRRovin],8 ; je 256 barev ?
         je        Konvert3                 ; je 256 barev

; ------ po놽t bit� na bod a po놽t barevn쁟h rovin - m줰 CGA

         shr       word ptr ds:[PCXByte],1
         shr       word ptr ds:[PCXByte],1  ; Æ쯭a displeje / 4
         mov       byte ptr ds:[PCXBits],2  ; po놽t bit� na bod pro 4 barvy
         cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         je        Konvert3                 ; jsou 4 barvy

; ------ po놽t bit� na bod a po놽t barevn쁟h rovin - m줰 2 barvy (mono)

         shr       word ptr ds:[PCXByte],1  ; Æ쯭a displeje / 8
         mov       byte ptr ds:[PCXBits],1  ; jinak 1 bit na bod

; ------ z쟰is z쟦lav� souboru PCX

Konvert3:mov       dx,offset PCX            ; z쟦lav� PCX
         mov       cx,offset(PCX0-PCX)      ; d굃ka z쟦lav�
         mov       bx,ds:[OutIdent]         ; identifik쟴or souboru
         mov       ah,40h
         int       21h                      ; z쟰is z쟦lav� souboru

; ------ test, zda je m줰 EGA 16 barev

         cmp       byte ptr ds:[PCXRovin],4 ; je EGA 16 barev ?
         jne       Konv39                   ; nen� EGA 16 barev

; ------ pro m줰 EGA se obr쟺ek nejdæve cel� na뇍e

         mov       bx,4                     ; po놽t rovin k na뇍en�
         mov       ax,ds:[SCRVyska]         ; v삩ka (linek)
         mul       word ptr ds:[PCXByte]    ; po놽t bajt� na rovinu
         xchg      ax,cx                    ; CX <- po놽t bajt� na rovinu
         mov       dx,ds:[Buffer0]          ; adresa prvn죋o bufferu

Konv32:  mov       es,dx                    ; ES <- adresa bufferu
         xor       di,di                    ; offset
         push      cx
Konv33:  call      ReadChr                  ; na뇍en� bajtu
         jc        Konv34
         cld
         stosb                              ; ulo멷n� bajtu
         loop      Konv33
Konv34:  pop       cx
         add       dx,1000h                 ; adresa dalÆ roviny
         dec       bx                       ; 눀ta� rovin
         jnz       Konv32                   ; na뇍en� dalÆ roviny

; ------ z쟰is obr쟺ku v m줰u EGA 16 barev

         mov       dx,ds:[SCRVyska]         ; v삩ka obr쟺ku (linek)
         xor       si,si                    ; ukazatel v bufferu
Konv35:  mov       bx,4                     ; po놽t rovin
         mov       es,ds:[Buffer0]          ; adresa bufferu
Konv36:  push      si
         mov       cx,ds:[PCXByte]          ; po놽t bajt� na linku
Konv37:  mov       al,es:[si]               ; bajt
         inc       si
         call      WritChr
         loop      Konv37                   ; dalÆ bajt
         pop       si
         call      WritFlsh                 ; vypr쟺dn늧� st쯠da놽 opakov쟮�
         mov       ax,es
         add       ax,1000h                 ; adresa dalÆho bufferu
         mov       es,ax
         dec       bx                       ; 눀ta� rovin
         jnz       Konv36                   ; dalÆ rovina
         add       si,ds:[PCXByte]          ; adresa dalÆ linky
         dec       dx                       ; 눀ta� linek
         jnz       Konv35                   ; dalÆ linka
         jmp       short Konvert6

; ------ p쯥konvertov쟮� dat (m줰y krom� EGA 16 barev a text)
;�
Konv39:  mov       dx,ds:[SCRVyska]         ; v삩ka obr쟺ku (linek)
Konvert4:mov       cx,ds:[PCXByte]          ; Æ쯭a linky (bajt�)
Konvert5:call      ReadChr
         jc        Konvert6
         call      WritChr
         loop      Konvert5
         call      WritFlsh                 ; vypr쟺dn늧� st쯠da놽 opakov쟮�
         dec       dx                       ; 눀ta� linek
         jnz       Konvert4

; ------ vypr쟺dn늧� st쯠da놽 opakov쟮�

Konvert6:call      WritFlsh                 ; vypr쟺dn늧� st쯠da놽 opakov쟮�

; ------ vypr쟺dn늧� z쟰isov괿o bufferu

         call      WritBuff                 ; z쟰is v쁲tupn죋o bufferu

; ------ z쟰is palety barev PCX

         mov       dx,offset PCXVGAX        ; tabulka palet barev
         mov       cx,3*256+1               ; velikost tabulky
         mov       bx,ds:[OutIdent]         ; identifik쟴or souboru
         mov       ah,40h
         int       21h                      ; z쟰is palet
Konvert9:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet VGA (256 a 2 barvy) (ES:DI=ukl쟡ac� adresa, CLD)
; -----------------------------------------------------------------------------

InitVGA  PROC      NEAR

         xor       ax,ax                    ; ukazatel 눀sla barvy
InitVGA2:call      Init0VGA                 ; inicializace barvy VGA
         inc       al                       ; zv삩en� ukazatele 눀sla barvy
         jnz       InitVGA2
         ret

InitVGA  ENDP

; ------ dek줰ov쟮� jedn� barvy VGA (AL)

Init0VGA:push      ax
         push      bx

         mov       ah,0
         mov       bx,ax
         shl       ax,1
         add       bx,ax
         mov       ax,word ptr ds:[bx+PalVGA]
         shl       ax,1
         shl       ax,1
         stosw
         mov       al,ds:[bx+PalVGA+2]
         shl       al,1
         shl       al,1
         stosb

         pop       bx
         pop       ax
         ret

; -----------------------------------------------------------------------------
;        inicializace palet pro EGA (16 barev) (ES:DI=ukl쟡ac� adresa, CLD)
; -----------------------------------------------------------------------------

InitEGA  PROC      NEAR

         mov       si,offset PalEGA         ; buffer palet EGA
         mov       cx,16                    ; po놽t palet
InitEGA2:lodsb                              ; barva EGA
         call      Init0VGA                 ; inicializace barvy
         loop      InitEGA2
         ret

InitEGA  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet pro CGA (4 barvy) (ES:DI=ukl쟡ac� adresa, CLD)
; -----------------------------------------------------------------------------

InitCGA  PROC      NEAR

         mov       bl,ds:[PalCGA]           ; palety
         and       bx,0fh
         mov       al,ds:[bx+PalEGA]        ; barva pozad�
         call      Init0VGA                 ; inicializace 놽rn� barvy

         mov       bx,offset PalEGA + 2     ; zelen� barva
         test      byte ptr ds:[PalCGA],10h ; je intenzivn� barva ?
         jz        InitCGA2                 ; nen� intenzivn� barva
         add       bx,8                     ; intenzivn� barva
InitCGA2:test      byte ptr ds:[PalCGA],20h ; je modr� slo멾a ?
         jz        InitCGA4                 ; nen� modr� slo멾a
         inc       bx                       ; je modr� slo멾a
InitCGA4:mov       al,ds:[bx]               ; zelen�
         call      Init0VGA                 ; zelen�
         mov       al,ds:[bx+2]             ; 놽rven�
         call      Init0VGA                 ; 놽rven�
         mov       al,ds:[bx+4]             ; hn늕�
         call      Init0VGA                 ; hn늕�
         ret

InitCGA  ENDP

; -----------------------------------------------------------------------------
;        na뇍en� znaku ze vstupn죋o souboru (s dekompres� SCR) -> AL (CY=konec)
; -----------------------------------------------------------------------------

ReadChr  PROC      NEAR

         test      byte ptr ds:[SCRParam],1 ; je komprese ?
         jz        ReadByte                 ; nen� komprese

; ------ na뇍en� bajtu po뇍u dat komprese

         cmp       byte ptr ds:[SCRCit],0   ; je 눀ta� platn� ?
         jne       ReadChr4                 ; 눀ta� je dosud platn�
ReadChr1:call      ReadByte                 ; na뇍en� bajtu 눀ta놽
         jc        ReadChr8                 ; konec souboru
         mov       byte ptr ds:[SCRCit],al  ; po놽t n쟳leduj죅죅h bajt�

; ------ k줰 0 = p쯥p죒a� m줰u komprese

         or        al,al                    ; je to jen p쯥p죒a� ?
         jnz       ReadChr2                 ; nen� to p쯥p죒a�
         xor       byte ptr ds:[SCRKomp],1  ; zm늧a pæznaku komprese
         jmp       short ReadChr1           ; nov� 뇍en� bajtu

; ------ na뇍en� bajtu k opakov쟮�

ReadChr2:and       byte ptr ds:[SCRKomp],not 2 ; zru쮍n� pæznaku komprese
         test      byte ptr ds:[SCRKomp],1  ; je m줰 komprese ?
         jz        ReadChr3                 ; nen� m줰 komprese
         or        byte ptr ds:[SCRKomp],2  ; pæznak komprese
         call      ReadByte                 ; na뇍en� bajtu k opakov쟮�
         jc        ReadChr8                 ; konec souboru
         mov       ds:[SCRChar],al          ; bajt k opakov쟮�

; ------ zm늧a pæznaku m줰u komprese

ReadChr3:cmp       byte ptr ds:[SCRCit],255 ; je zm늧a m줰u komprese ?
         je        ReadChr4                 ; nen� zm늧a m줰u komprese
         xor       byte ptr ds:[SCRKomp],1  ; zm늧a pæznaku komprese

; ------ na뇍en� dalÆho bajtu

ReadChr4:mov       al,ds:[SCRChar]          ; bajt p쯫 opakov쟮� dat
         test      byte ptr ds:[SCRKomp],2  ; je opakov쟮� dat ?
         jnz       ReadChr5                 ; je opakov쟮� dat
         call      ReadByte                 ; na뇍en� b닊n괿o bajtu dat
         jc        ReadChr8                 ; konec souboru

; ------ sn죷en� 눀ta놽 bajt�

ReadChr5:dec       byte ptr ds:[SCRCit]     ; sn죷en� 눀ta놽 komprese
         clc
ReadChr8:ret

ReadChr  ENDP

; -----------------------------------------------------------------------------
;        na뇍en� bajtu ze vstupn죋o bufferu (CY=konec nebo chyba) -> AL
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         push      si
         mov       si,ds:[InpRead]          ; offset 뇍ec� adresy z bufferu
         cmp       si,ds:[InpNum]           ; jsou n늞ak� data ?
         jb        ReadByt2                 ; jsou n늞ak� data

         call      ReadBuff                 ; na뇍en� vstupn죋o bufferu
         jc        ReadByt9                 ; nejsou data nebo chyba
         xor       si,si                    ; nov� offset v bufferu

ReadByt2:mov       al,ds:[si+InpBuff]       ; na뇍en� znaku z bufferu
         inc       word ptr ds:[InpRead]    ; zv삩en� offsetu 뇍ec� adresy
         clc                                ; pæznak operace OK

ReadByt9:pop       si
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na뇍en� vstupn죋o bufferu (CY=konec nebo chyba)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[InpRead],0  ; offset 뇍ec� adresy z bufferu
         mov       cx,BUFFSIZE              ; velikost bufferu
         mov       dx,offset InpBuff        ; vstupn� buffer
         mov       bx,ds:[InpIdent]         ; identifik쟴or vstupn죋o souboru
         mov       ah,3fh
         int       21h                      ; na뇍en� dat ze vstupn죋o souboru
         jnc       ReadBuf1
         xor       ax,ax                    ; AX <- 0  nic nena뇍eno
ReadBuf1:mov       ds:[InpNum],ax           ; po놽t bajt� ve vstupn죑 bufferu
         cmp       ax,1                     ; bylo n늓o na뇍eno ? (CY=nebylo)

ReadBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        z쟰is znaku AL do v쁲tupn죋o bufferu (s kompres� PCX)
; -----------------------------------------------------------------------------

WritChr  PROC      NEAR

         cmp       byte ptr ds:[PCXCit],0c0h ; bude prvn� bajt ?
         je        WritChr2                 ; bude prvn� bajt

         cmp       al,ds:[PCXChar]          ; je to stejn� bajt ?
         je        WritChr4                 ; je to stejn� bajt
         call      WritFlsh                 ; vypr쟺dn늧� st쯠da놽 opakov쟮�

WritChr2:mov       ds:[PCXChar],al          ; ulo멷n� znaku do bufferu
         inc       byte ptr ds:[PCXCit]     ; zv삩en� 눀ta놽 opakovan쁟h znak�
         jmp       short WritChr6

WritChr4:inc       byte ptr ds:[PCXCit]     ; zv삩en� 눀ta놽 znak�
         cmp       byte ptr ds:[PCXCit],255 ; je ji� maximum ?
         jb        WritChr6                 ; nen� je쮝� maximum
         call      WritFlsh                 ; vypr쟺dn늧� bufferu

WritChr6:ret

WritChr  ENDP

; -----------------------------------------------------------------------------
;        vypr쟺dn늧� v쁲tupn죋o st쯠da놽 opakov쟮�
; -----------------------------------------------------------------------------

WritFlsh PROC      NEAR

         push      ax

         mov       al,ds:[PCXChar]          ; znak k vysl쟮�
         mov       ah,ds:[PCXCit]           ; po놽t znak� opakov쟮�

         cmp       ah,0c0h                  ; je n늞ak� bajt ?
         je        WritFls4                 ; nen� 몺dn� bajt

         cmp       al,0c0h                  ; je povolen� bajt ?
         jae       WritFls1                 ; nen� povolen� bajt
         cmp       ah,0c1h                  ; je 1 bajt ?
         je        WritFls2                 ; je 1 bajt - nen� opakov쟮�

WritFls1:xchg      al,ah                    ; AL <- po놽t bajt�
         call      WritByte                 ; z쟰is po뇍u opakov쟮�
         xchg      al,ah                    ; AL <- bajt
WritFls2:call      WritByte                 ; z쟰is bajtu k opakov쟮�

         mov       byte ptr ds:[PCXCit],0c0h ; nen� 몺dn� bajt

WritFls4:pop       ax
         ret

WritFlsh ENDP

; -----------------------------------------------------------------------------
;        z쟰is bajtu do v쁲tupn죋o bufferu
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      di
         mov       di,ds:[OutNum]           ; po놽t bajt� ve v쁲tupn죑 bufferu
         cmp       di,BUFFSIZE              ; je buffer ji� pln� ?
         jb        WritByt2                 ; buffer je쮝� nen� pln�

         call      WritBuff                 ; z쟰is v쁲tupn죋o bufferu
         xor       di,di                    ; nov� ukazatel v bufferu

WritByt2:mov       ds:[di+OutBuff],al       ; ulo멷n� bajtu do bufferu
         inc       word ptr ds:[OutNum]     ; zv삩en� 눀ta놽 bajt� v bufferu

         pop       di
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z쟰is v쁲tupn죋o bufferu
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       cx,ds:[OutNum]           ; po놽t bajt� ve v쁲tupn죑 bufferu
         jcxz      WritBuf2                 ; v bufferu nejsou 몺dn� data
         mov       bx,ds:[OutIdent]         ; identifik쟴or v쁲tupn죋o souboru
         mov       dx,offset OutBuff        ; v쁲tupn� buffer
         mov       ah,40h
         int       21h                      ; z쟰is dat do souboru
         mov       word ptr ds:[OutNum],0   ; nejsou 몺dn� data v bufferu

WritBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

WritBuff ENDP

; *****************************************************************************
;
;                                  Data
;
; *****************************************************************************
;�
; ------ texty

MemErr   db        'Nedostatek pameti !',13,10,'$'

UvTxt    db        13,10
         db        'SCR2PCX v1.0 - konverze souboru SCR na PCX; (c) Miroslav Nemecek',13,10
         db        13,10
         db        ' Program zkonvertuje vsechny soubory SCR (vygenerovane programem',13,10
         db        ' GDEMO) v aktivnim adresari na soubory ve formatu PCX (existujici',13,10
         db        ' soubory budou prepsany).',13,10
         db        13,10
         db        'Stisknete libovolnou klavesu, ESC=preruseni ...',13,10
         db        13,10
         db        '$'

; ------ z쟦lav� souboru SCR

SCR      label     byte                   ;* z쟦lav� souboru SCREEN (d굃ka 16 B)
SCRIdent db        'SCR'                    ; identifikace souboru displeje
SCRVerze db        1                        ; verze souboru
SCRSirka dw        0                        ; Æ쯭a v삪ezu (pozic, bod�)
SCRVyska dw        0                        ; v삩ka v삪ezu (linek)
SCRRovin db        0                        ; po놽t barevn쁟h rovin
         db        0                        ; (rezervov쟮o)
SCRPozad db        0                        ; barva pozad�
SCRKomnt db        0                        ; po놽t bajt� koment젵e + informace
SCRPalet dw        0                        ; po놽t bajt� za z쟦lav죑
SCRVMod  db        0                        ; videom줰 displeje
SCRParam db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov� videom줰
                                            ;  bit 2: 1=paraleln� ulo멷n� barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
SCR0     label     byte                     ; konec z쟦lav�

Koment   db        256 dup(0)               ; koment젵 SCR
PalCGA   db        0                        ; paleta CGA
PalEGA   db        16 dup(0)                ; buffer palet EGA
PalEGA0  db        0                        ; barva pozad�
PalEGAM  db        0                        ; mapov쟮� palety EGA pro VGA
PalVGA   db        3*256 dup(0)             ; buffer palet VGA

; ------ ukazatele pro dekompresi souboru SCR

SCRCit   db        0                        ; 눀ta� shodn괿o bajtu
SCRChar  db        0                        ; znak k opakov쟮�
SCRKomp  db        1                        ; 1=pæznak kompresn죋o m줰u
                                            ; 2=je komprese

; ------ standardn� paleta CGA

StandCGA db        10h

; ------ standardn� paleta EGA

StandEGA db        0,1,2,3,4,5,20,7         ; 0 a� 7
         db        56,57,58,59,60,61,62,63  ; 8 a� 18
         db        0                        ; pozad�
         db        0                        ; mapov쟮� palet

; ------ standardn� paleta VGA

StandVGA db         0, 0, 0                 ;  0
         db         0, 0,42                 ;  1
         db         0,42, 0                 ;  2
         db         0,42,42                 ;  3
         db        42, 0, 0                 ;  4
         db        42, 0,42                 ;  5
         db        42,42, 0                 ;  6
         db        42,42,42                 ;  7
         db         0, 0,21                 ;  8
         db         0, 0,63                 ;  9
         db         0,42,21                 ; 10
         db         0,42,63                 ; 11
         db        42, 0,21                 ; 12
         db        42, 0,63                 ; 13
         db        42,42,21                 ; 14
         db        42,42,63                 ; 15

         db         0,21, 0                 ; 16
         db         0,21,42                 ; 17
         db         0,63, 0                 ; 18
         db         0,63,42                 ; 19
         db        42,21, 0                 ; 20
         db        42,21,42                 ; 21
         db        42,63, 0                 ; 22
         db        42,63,42                 ; 23
         db         0,21,21                 ; 24
         db         0,21,63                 ; 25
         db         0,63,21                 ; 26
         db         0,63,63                 ; 27
         db        42,21,21                 ; 28
         db        42,21,63                 ; 29
         db        42,63,21                 ; 30
         db        42,63,63                 ; 31

         db        21, 0, 0                 ; 32
         db        21, 0,42                 ; 33
         db        21,42, 0                 ; 34
         db        21,42,42                 ; 35
         db        63, 0, 0                 ; 36
         db        63, 0,42                 ; 37
         db        63,42, 0                 ; 38
         db        63,42,42                 ; 39
         db        21, 0,21                 ; 40
         db        21, 0,63                 ; 41
         db        21,42,21                 ; 42
         db        21,42,63                 ; 43
         db        63, 0,21                 ; 44
         db        63, 0,63                 ; 45
         db        63,42,21                 ; 46
         db        63,42,63                 ; 47

         db        21,21, 0                 ; 48
         db        21,21,42                 ; 49
         db        21,63, 0                 ; 50
         db        21,63,42                 ; 51
         db        63,21, 0                 ; 52
         db        63,21,42                 ; 53
         db        63,63, 0                 ; 54
         db        63,63,42                 ; 55
         db        21,21,21                 ; 56
         db        21,21,63                 ; 57
         db        21,63,21                 ; 58
         db        21,63,63                 ; 59
         db        63,21,21                 ; 60
         db        63,21,63                 ; 61
         db        63,63,21                 ; 62
         db        63,63,63                 ; 63

; ------ z쟦lav� souboru PCX

PCX      label     byte                     ; z쟦lav� souboru PCX
PCXIdent db        10                       ; 0: identifikace souboru
PCXVerze db        5                        ; 1: 5=verze 3.0 s paletou 3*256
PCXMetod db        1                        ; 2: metoda k줰ov쟮� PCX
PCXBits  db        8                        ; 3: po놽t bit�/bod v jedn� rovin�
PCXX1    dw        0                        ; 4: po뇿te뇆� sou쯠dnice X1
PCXY1    dw        0                        ; 6: po뇿te뇆� sou쯠dnice Y1
PCXX2    dw        319                      ; 8: koncov� sou쯠dnice X2
PCXY2    dw        199                      ; 10: koncov� sou쯠dnice Y2
PCXHoriz dw        320                      ; 12: horiz. rozli쮑telnost displeje
PCXVert  dw        200                      ; 14: vert. rozli쮑telnost displeje
PCXEga   db           0,   0,   0           ;        놽rn�
         db           0,   0,4*42           ;        modr�
         db           0,4*42,   0           ;        zelen�
         db           0,4*42,4*42           ;        modrozelen�
         db        4*42,   0,   0           ;        놽rven�
         db        4*42,   0,4*42           ;        purpurov�
         db        4*42,4*21,   0           ;        hn늕�
         db        4*42,4*42,4*42           ;        b죐�
         db        4*21,4*21,4*21           ;        쮍d�
         db        4*21,4*21,4*63           ;        sv늯le modr�
         db        4*21,4*63,4*21           ;        sv늯le zelen�
         db        4*21,4*63,4*63           ;        sv늯le modrozelen�
         db        4*63,4*21,4*21           ;        sv늯le 놽rven�
         db        4*63,4*21,4*63           ;        sv늯le purpurov�
         db        4*63,4*63,4*21           ;        멿ut�
         db        4*63,4*63,4*63           ;        sv늯le b죐�
         db        0                        ; 64: ... nevyu멼to
PCXRovin db        1                        ; 65: po놽t barevn쁟h rovin
PCXByte  dw        320                      ; 66: po놽t bajt� na 찤dek obr쟺ku
PCXInter dw        1                        ; 68: interpretace palety barev
         db        58 dup(0)                ; 70: ... nevyu멼to
PCX0     label     byte

PCXVgaX  db        12                       ; odd늢ova� palet 12
PCXVga   db        3*256 dup(0)             ; paleta barev VGA
                                            ; (1) 놽rven� 0 a� 255
                                            ; (1) zelen� 0 a� 255
                                            ; (1) modr� 0 a� 255

; ------ ukazatele pro kompresi souboru PCX

PCXCit   db        0c0h                     ; 눀ta� shodn괿o bajtu C0 ...
PCXChar  db        0                        ; opakovan� bajt

; ------ vyhled쟶쟮� soubor�

Soubory  db        '*.SCR',0                ; specifikace hledan쁟h soubor�

DTA      db        1eh dup(0)               ; buffer DTA
DTAName  db        13 dup(0)                ; buffer jm굈a souboru
         db        "......."                ; rezerva

; ------ vstupn� soubor

InpIdent dw        0                        ; identifik쟴or vstupn죋o souboru
InpRead  dw        0                        ; offset 뇍ec� adresy z bufferu
InpNum   dw        0                        ; po놽t bajt� ve vstupn죑 bufferu
InpBuff  db        BUFFSIZE dup(0)          ; vstupn� buffer

; ------ v쁲tupn� soubor

OutIdent dw        0                        ; identifik쟴or v쁲tupn죋o souboru
OutNum   dw        0                        ; po놽t bajt� ve v쁲tupn죑 bufferu
OutBuff  db        BUFFSIZE dup(0)          ; v쁲tupn� buffer

; ------ adresa bufferu rovin (ka멶� buffer 64 KB)

Buffer0  dw        0                        ; buffer roviny 0
Buffer1  dw        0                        ; buffer roviny 1
Buffer2  dw        0                        ; buffer roviny 2
Buffer3  dw        0                        ; buffer roviny 3

; ------ z쟳obn죏

         dw        200h dup(0)              ; pracovn� z쟳obn죏
Zasobnik label     word

Code     ENDS
         END       Start

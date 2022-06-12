
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;               Konverze soubor– SCR (z programu GDEMO) na soubory PCX
;
;              pracovn¡ verze programu - nejsou o¨et©ov ny chybov‚ stavy
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

BUFFSIZE EQU       1000h                    ; velikost jednoho bufferu

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov n¡ z sobn¡ku

Start:   cmp       sp,offset Zasobnik
         jbe       Chyba
         mov       sp,offset Zasobnik

; ------ uvolnˆn¡ aloka‡n¡ho bloku

         mov       bx,(offset(Zasobnik-Start)+10fh)/16
         mov       ah,4ah
         int       21h
         jc        Chyba

; ------ vytvo©en¡ aloka‡n¡ho bloku bufferu

         mov       bx,4000h                 ; po‘adovan  pamˆŸ 256 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ bloku pamˆti
         jnc       Start0

; ------ chyba pamˆti

Chyba:   mov       dx,offset MemErr
         mov       ah,9
         int       21h
         int       20h

; ------ sestaven¡ adres buffer–

Start0:  mov       ds:[Buffer0],ax          ; buffer roviny 0
         add       ax,1000h
         mov       ds:[Buffer1],ax          ; buffer roviny 1
         add       ax,1000h
         mov       ds:[Buffer2],ax          ; buffer roviny 2
         add       ax,1000h
         mov       ds:[Buffer3],ax          ; buffer roviny 3

; ------ zobrazen¡ £vodn¡ho textu

         mov       dx,offset UvTxt
         mov       ah,9
         int       21h

; ------ ‡ek n¡ na stisk kl vesy

         mov       ah,0
         int       16h                      ; vstup znaku z kl vesnice

; ------ p©eru¨en¡ programu

         or        ax,ax                    ; Ctrl-Break ?
         jz        Start1                   ; je Ctrl-Break
         cmp       al,27                    ; je ESC ?
         jne       Start2                   ; nen¡ ESC
Start1:  int       20h

; ------ definice adresy DTA

Start2:  mov       dx,offset DTA
         mov       ah,1ah
         int       21h

; ------ nalezen¡ prvn¡ho/dal¨¡ho souboru

         mov       dx,offset Soubory        ; specifikace soubor– SCR
         xor       cx,cx
         mov       ah,4eh
Start3:  int       21h                      ; nalezen¡ prvn¡ho/dal¨¡ho souboru
         jnc       Start4                   ; nalezen soubor OK
         int       20h

; ------ otev©en¡ vstupn¡ho souboru

Start4:  mov       ax,3d00h
         mov       dx,offset DTAName
         int       21h                      ; otev©en¡ souboru
         jc        Start9                   ; chyba

; ------ inicializace ukazatel– v˜stupn¡ho souboru

         mov       ds:[InpIdent],ax         ; identifik tor vstupn¡ho souboru
         mov       word ptr ds:[InpNum],0   ; po‡et bajt– ve vstupn¡m bufferu
         mov       word ptr ds:[InpRead],0  ; offset ‡tec¡ adresy z bufferu
         mov       byte ptr ds:[SCRCit],0   ; ‡¡ta‡ komprese
         mov       byte ptr ds:[SCRKomp],1  ; nastaven¡ p©¡znaku komprese

; ------ nalezen¡ p©¡pony jm‚na souboru

         mov       si,dx                    ; SI <- jm‚no souboru
Start5:  inc       si
         cmp       byte ptr ds:[si-1],"."
         jne       Start5                   ; nalezen¡ oddˆlovac¡ te‡ky

; ------ n hrada p©¡ponou PCX

         mov       word ptr ds:[si],"CP"
         mov       word ptr ds:[si+2],"X"

; ------ vytvo©en¡ v˜stupn¡ho souboru PCX

         xor       cx,cx                    ; atributy
         mov       ah,3ch
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         jc        Start8                   ; chyba

; ------ inicializace ukazatel– v˜stupn¡ho souboru

         mov       ds:[OutIdent],ax         ; identifik tor v˜stupn¡ho souboru
         mov       word ptr ds:[OutNum],0   ; po‡et bajt– ve v˜stupn¡m bufferu
         mov       byte ptr ds:[PCXCit],0c0h; nen¡ ‘ dn˜ znak k opakov n¡

; ------ konverze souboru (SI=p©¡pona jm‚na souboru !)

         call      Konvert                  ; konverze souboru

; ------ uzav©en¡ v˜stupn¡ho souboru

         mov       bx,ds:[OutIdent]         ; identifik tor v˜stupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ v˜stupn¡ho souboru

; ------ uzav©en¡ vstupn¡ho souboru

Start8:  mov       bx,ds:[InpIdent]         ; identifik tor vstupn¡ho souboru
         mov       ah,3eh
         int       21h                      ; uzav©en¡ vstupn¡ho souboru

; ------ p©¡prava pro dal¨¡ soubor

Start9:  mov       ah,4fh
         jmp       Start3                   ; dal¨¡ soubor

; -----------------------------------------------------------------------------
;        konverze obr zku (SI=p©¡pona jm‚na souboru)
; -----------------------------------------------------------------------------

Konvert  PROC      NEAR

; ------ zobrazen¡ jm‚na souboru

         mov       word ptr ds:[si-1],13 + 10*256
         mov       word ptr ds:[si+1],"$"
         mov       dx,offset DTAName
         mov       ah,9
         int       21h                      ; zobrazen¡ jm‚na souboru

; ------ inicializace standardn¡ch palet SCR (zbytek VGA se ponech  nedefinov n)

         push      ds
         pop       es
         mov       si,offset StandCGA       ; standardn¡ palety
         mov       di,offset PalCGA         ; buffer palet
         mov       cx,1 + 18 + 3*64         ; velikost standardn¡ch palet
         cld
         rep       movsb                    ; inicializace standardn¡ch palet

; ------ na‡ten¡ z hlav¡ souboru SCR

         mov       dx,offset SCR            ; z hlav¡ SCR
         mov       cl,offset(SCR0-SCR)      ; d‚lka z hlav¡
         mov       bx,ds:[InpIdent]         ; identifik tor vstupn¡ho souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ vstupn¡ho souboru


         test      byte ptr ds:[SCRParam],2 ; textov˜ re‘im
         jz        Konv10
         ret


; ------ na‡ten¡ koment ©e k souboru

Konv10:  mov       cl,ds:[SCRKomnt]         ; d‚lka koment ©e
         mov       dx,offset Koment         ; buffer koment ©–
         mov       ah,3fh
         int       21h                      ; na‡ten¡ koment ©e

; ------ na‡ten¡ palety CGA

         test      byte ptr ds:[SCRParam],10h ; jsou palety CGA ?
         jz        Konv12                   ; nejsou palety CGA
         mov       dx,offset PalCGA         ; palety CGA
         mov       cl,1                     ; 1 bajt
         mov       ah,3fh
         int       21h                      ; na‡ten¡ palet CGA

; ------ na‡ten¡ palet EGA

Konv12:  test      byte ptr ds:[SCRParam],20h ; jsou palety EGA ?
         jz        Konv14                   ; nejsou palety EGA
         mov       dx,offset PalEGA         ; palety EGA
         mov       cl,18                    ; 18 bajt–
         mov       ah,3fh
         int       21h                      ; na‡ten¡ palet EGA

; ------ na‡ten¡ palet VGA

Konv14:  test      byte ptr ds:[SCRParam],40h ; jsou palety VGA ?
         jz        Konv16                   ; nejsou palety VGA
         mov       dx,offset PalVGA         ; palety VGA
         mov       cx,3*256                 ; velikost palet
         mov       ah,3fh
         int       21h                      ; na‡ten¡ palet VGA

; ------ inicializace palet pro 16 barev (EGA) (ES=DS !)

Konv16:  mov       di,offset PCXVGA         ; buffer palet VGA
         cld
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         jne       Konv17                   ; nen¡ 16 barev
         call      InitEGA                  ; inicializace palet pro EGA
         jmp       short Konv19

; ------ inicializace palet pro 4 barvy (CGA)

Konv17:  cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         jne       Konv18
         call      InitCGA                  ; inicializace palet pro CGA
         jmp       short Konv19

; ------ inicializace palet VGA

Konv18:  call      InitVGA                  ; inicializace palet pro VGA

; ------ p©¡prava rozmˆr– obr zku

Konv19:  mov       ax,ds:[SCRVyska]         ; v˜¨ka obr zku (linek)
         mov       ds:[PCXVert],ax          ; vertik ln¡ rozli¨itelnost
         dec       ax
         mov       ds:[PCXY2],ax            ; koncov  sou©adnice Y2
         mov       ax,ds:[SCRSirka]         ; ¨¡©ka obr zku (bod–)
         mov       ds:[PCXHoriz],ax         ; horizont ln¡ rozli¨itelnost
         dec       ax
         mov       ds:[PCXX2],ax            ; koncov  sou©adnice X2
         inc       ax                       ; ¨¡©ka displeje

; ------ po‡et bit– na bod a po‡et barevn˜ch rovin - m¢d EGA

         push      ax
         shr       ax,1
         shr       ax,1
         shr       ax,1                     ; ¨¡©ka displeje / 8
         mov       ds:[PCXByte],ax          ; po‡et bajt– na linku
         pop       ax
         mov       byte ptr ds:[PCXBits],1  ; po‡et bit– na bod pro 16 barev EGA
         mov       byte ptr ds:[PCXRovin],4 ; po‡et barevn˜ch rovin
         cmp       byte ptr ds:[SCRRovin],4 ; je 16 barev ?
         je        Konvert3                 ; je 16 barev

; ------ po‡et bit– na bod a po‡et barevn˜ch rovin - m¢d MCGA

         mov       ds:[PCXByte],ax          ; po‡et bajt– na linku
         mov       byte ptr ds:[PCXRovin],1 ; po‡et barevn˜ch rovin
         mov       byte ptr ds:[PCXBits],8  ; po‡et bit– na bod
         cmp       byte ptr ds:[SCRRovin],8 ; je 256 barev ?
         je        Konvert3                 ; je 256 barev

; ------ po‡et bit– na bod a po‡et barevn˜ch rovin - m¢d CGA

         shr       word ptr ds:[PCXByte],1
         shr       word ptr ds:[PCXByte],1  ; ¨¡©ka displeje / 4
         mov       byte ptr ds:[PCXBits],2  ; po‡et bit– na bod pro 4 barvy
         cmp       byte ptr ds:[SCRRovin],2 ; jsou 4 barvy ?
         je        Konvert3                 ; jsou 4 barvy

; ------ po‡et bit– na bod a po‡et barevn˜ch rovin - m¢d 2 barvy (mono)

         shr       word ptr ds:[PCXByte],1  ; ¨¡©ka displeje / 8
         mov       byte ptr ds:[PCXBits],1  ; jinak 1 bit na bod

; ------ z pis z hlav¡ souboru PCX

Konvert3:mov       dx,offset PCX            ; z hlav¡ PCX
         mov       cx,offset(PCX0-PCX)      ; d‚lka z hlav¡
         mov       bx,ds:[OutIdent]         ; identifik tor souboru
         mov       ah,40h
         int       21h                      ; z pis z hlav¡ souboru

; ------ test, zda je m¢d EGA 16 barev

         cmp       byte ptr ds:[PCXRovin],4 ; je EGA 16 barev ?
         jne       Konv39                   ; nen¡ EGA 16 barev

; ------ pro m¢d EGA se obr zek nejd©¡ve cel˜ na‡te

         mov       bx,4                     ; po‡et rovin k na‡ten¡
         mov       ax,ds:[SCRVyska]         ; v˜¨ka (linek)
         mul       word ptr ds:[PCXByte]    ; po‡et bajt– na rovinu
         xchg      ax,cx                    ; CX <- po‡et bajt– na rovinu
         mov       dx,ds:[Buffer0]          ; adresa prvn¡ho bufferu

Konv32:  mov       es,dx                    ; ES <- adresa bufferu
         xor       di,di                    ; offset
         push      cx
Konv33:  call      ReadChr                  ; na‡ten¡ bajtu
         jc        Konv34
         cld
         stosb                              ; ulo‘en¡ bajtu
         loop      Konv33
Konv34:  pop       cx
         add       dx,1000h                 ; adresa dal¨¡ roviny
         dec       bx                       ; ‡¡ta‡ rovin
         jnz       Konv32                   ; na‡ten¡ dal¨¡ roviny

; ------ z pis obr zku v m¢du EGA 16 barev

         mov       dx,ds:[SCRVyska]         ; v˜¨ka obr zku (linek)
         xor       si,si                    ; ukazatel v bufferu
Konv35:  mov       bx,4                     ; po‡et rovin
         mov       es,ds:[Buffer0]          ; adresa bufferu
Konv36:  push      si
         mov       cx,ds:[PCXByte]          ; po‡et bajt– na linku
Konv37:  mov       al,es:[si]               ; bajt
         inc       si
         call      WritChr
         loop      Konv37                   ; dal¨¡ bajt
         pop       si
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡
         mov       ax,es
         add       ax,1000h                 ; adresa dal¨¡ho bufferu
         mov       es,ax
         dec       bx                       ; ‡¡ta‡ rovin
         jnz       Konv36                   ; dal¨¡ rovina
         add       si,ds:[PCXByte]          ; adresa dal¨¡ linky
         dec       dx                       ; ‡¡ta‡ linek
         jnz       Konv35                   ; dal¨¡ linka
         jmp       short Konvert6

; ------ p©ekonvertov n¡ dat (m¢dy kromˆ EGA 16 barev a text)
;þ
Konv39:  mov       dx,ds:[SCRVyska]         ; v˜¨ka obr zku (linek)
Konvert4:mov       cx,ds:[PCXByte]          ; ¨¡©ka linky (bajt–)
Konvert5:call      ReadChr
         jc        Konvert6
         call      WritChr
         loop      Konvert5
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡
         dec       dx                       ; ‡¡ta‡ linek
         jnz       Konvert4

; ------ vypr zdnˆn¡ st©ada‡e opakov n¡

Konvert6:call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡

; ------ vypr zdnˆn¡ z pisov‚ho bufferu

         call      WritBuff                 ; z pis v˜stupn¡ho bufferu

; ------ z pis palety barev PCX

         mov       dx,offset PCXVGAX        ; tabulka palet barev
         mov       cx,3*256+1               ; velikost tabulky
         mov       bx,ds:[OutIdent]         ; identifik tor souboru
         mov       ah,40h
         int       21h                      ; z pis palet
Konvert9:ret

Konvert  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet VGA (256 a 2 barvy) (ES:DI=ukl dac¡ adresa, CLD)
; -----------------------------------------------------------------------------

InitVGA  PROC      NEAR

         xor       ax,ax                    ; ukazatel ‡¡sla barvy
InitVGA2:call      Init0VGA                 ; inicializace barvy VGA
         inc       al                       ; zv˜¨en¡ ukazatele ‡¡sla barvy
         jnz       InitVGA2
         ret

InitVGA  ENDP

; ------ dek¢dov n¡ jedn‚ barvy VGA (AL)

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
;        inicializace palet pro EGA (16 barev) (ES:DI=ukl dac¡ adresa, CLD)
; -----------------------------------------------------------------------------

InitEGA  PROC      NEAR

         mov       si,offset PalEGA         ; buffer palet EGA
         mov       cx,16                    ; po‡et palet
InitEGA2:lodsb                              ; barva EGA
         call      Init0VGA                 ; inicializace barvy
         loop      InitEGA2
         ret

InitEGA  ENDP

; -----------------------------------------------------------------------------
;        inicializace palet pro CGA (4 barvy) (ES:DI=ukl dac¡ adresa, CLD)
; -----------------------------------------------------------------------------

InitCGA  PROC      NEAR

         mov       bl,ds:[PalCGA]           ; palety
         and       bx,0fh
         mov       al,ds:[bx+PalEGA]        ; barva pozad¡
         call      Init0VGA                 ; inicializace ‡ern‚ barvy

         mov       bx,offset PalEGA + 2     ; zelen  barva
         test      byte ptr ds:[PalCGA],10h ; je intenzivn¡ barva ?
         jz        InitCGA2                 ; nen¡ intenzivn¡ barva
         add       bx,8                     ; intenzivn¡ barva
InitCGA2:test      byte ptr ds:[PalCGA],20h ; je modr  slo‘ka ?
         jz        InitCGA4                 ; nen¡ modr  slo‘ka
         inc       bx                       ; je modr  slo‘ka
InitCGA4:mov       al,ds:[bx]               ; zelen 
         call      Init0VGA                 ; zelen 
         mov       al,ds:[bx+2]             ; ‡erven 
         call      Init0VGA                 ; ‡erven 
         mov       al,ds:[bx+4]             ; hnˆd 
         call      Init0VGA                 ; hnˆd 
         ret

InitCGA  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ znaku ze vstupn¡ho souboru (s dekompres¡ SCR) -> AL (CY=konec)
; -----------------------------------------------------------------------------

ReadChr  PROC      NEAR

         test      byte ptr ds:[SCRParam],1 ; je komprese ?
         jz        ReadByte                 ; nen¡ komprese

; ------ na‡ten¡ bajtu po‡tu dat komprese

         cmp       byte ptr ds:[SCRCit],0   ; je ‡¡ta‡ platn˜ ?
         jne       ReadChr4                 ; ‡¡ta‡ je dosud platn˜
ReadChr1:call      ReadByte                 ; na‡ten¡ bajtu ‡¡ta‡e
         jc        ReadChr8                 ; konec souboru
         mov       byte ptr ds:[SCRCit],al  ; po‡et n sleduj¡c¡ch bajt–

; ------ k¢d 0 = p©ep¡na‡ m¢du komprese

         or        al,al                    ; je to jen p©ep¡na‡ ?
         jnz       ReadChr2                 ; nen¡ to p©ep¡na‡
         xor       byte ptr ds:[SCRKomp],1  ; zmˆna p©¡znaku komprese
         jmp       short ReadChr1           ; nov‚ ‡ten¡ bajtu

; ------ na‡ten¡ bajtu k opakov n¡

ReadChr2:and       byte ptr ds:[SCRKomp],not 2 ; zru¨en¡ p©¡znaku komprese
         test      byte ptr ds:[SCRKomp],1  ; je m¢d komprese ?
         jz        ReadChr3                 ; nen¡ m¢d komprese
         or        byte ptr ds:[SCRKomp],2  ; p©¡znak komprese
         call      ReadByte                 ; na‡ten¡ bajtu k opakov n¡
         jc        ReadChr8                 ; konec souboru
         mov       ds:[SCRChar],al          ; bajt k opakov n¡

; ------ zmˆna p©¡znaku m¢du komprese

ReadChr3:cmp       byte ptr ds:[SCRCit],255 ; je zmˆna m¢du komprese ?
         je        ReadChr4                 ; nen¡ zmˆna m¢du komprese
         xor       byte ptr ds:[SCRKomp],1  ; zmˆna p©¡znaku komprese

; ------ na‡ten¡ dal¨¡ho bajtu

ReadChr4:mov       al,ds:[SCRChar]          ; bajt p©i opakov n¡ dat
         test      byte ptr ds:[SCRKomp],2  ; je opakov n¡ dat ?
         jnz       ReadChr5                 ; je opakov n¡ dat
         call      ReadByte                 ; na‡ten¡ bˆ‘n‚ho bajtu dat
         jc        ReadChr8                 ; konec souboru

; ------ sn¡‘en¡ ‡¡ta‡e bajt–

ReadChr5:dec       byte ptr ds:[SCRCit]     ; sn¡‘en¡ ‡¡ta‡e komprese
         clc
ReadChr8:ret

ReadChr  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bajtu ze vstupn¡ho bufferu (CY=konec nebo chyba) -> AL
; -----------------------------------------------------------------------------

ReadByte PROC      NEAR

         push      si
         mov       si,ds:[InpRead]          ; offset ‡tec¡ adresy z bufferu
         cmp       si,ds:[InpNum]           ; jsou nˆjak  data ?
         jb        ReadByt2                 ; jsou nˆjak  data

         call      ReadBuff                 ; na‡ten¡ vstupn¡ho bufferu
         jc        ReadByt9                 ; nejsou data nebo chyba
         xor       si,si                    ; nov˜ offset v bufferu

ReadByt2:mov       al,ds:[si+InpBuff]       ; na‡ten¡ znaku z bufferu
         inc       word ptr ds:[InpRead]    ; zv˜¨en¡ offsetu ‡tec¡ adresy
         clc                                ; p©¡znak operace OK

ReadByt9:pop       si
         ret

ReadByte ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ vstupn¡ho bufferu (CY=konec nebo chyba)
; -----------------------------------------------------------------------------

ReadBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       word ptr ds:[InpRead],0  ; offset ‡tec¡ adresy z bufferu
         mov       cx,BUFFSIZE              ; velikost bufferu
         mov       dx,offset InpBuff        ; vstupn¡ buffer
         mov       bx,ds:[InpIdent]         ; identifik tor vstupn¡ho souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ dat ze vstupn¡ho souboru
         jnc       ReadBuf1
         xor       ax,ax                    ; AX <- 0  nic nena‡teno
ReadBuf1:mov       ds:[InpNum],ax           ; po‡et bajt– ve vstupn¡m bufferu
         cmp       ax,1                     ; bylo nˆco na‡teno ? (CY=nebylo)

ReadBuf2:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

ReadBuff ENDP

; -----------------------------------------------------------------------------
;        z pis znaku AL do v˜stupn¡ho bufferu (s kompres¡ PCX)
; -----------------------------------------------------------------------------

WritChr  PROC      NEAR

         cmp       byte ptr ds:[PCXCit],0c0h ; bude prvn¡ bajt ?
         je        WritChr2                 ; bude prvn¡ bajt

         cmp       al,ds:[PCXChar]          ; je to stejn˜ bajt ?
         je        WritChr4                 ; je to stejn˜ bajt
         call      WritFlsh                 ; vypr zdnˆn¡ st©ada‡e opakov n¡

WritChr2:mov       ds:[PCXChar],al          ; ulo‘en¡ znaku do bufferu
         inc       byte ptr ds:[PCXCit]     ; zv˜¨en¡ ‡¡ta‡e opakovan˜ch znak–
         jmp       short WritChr6

WritChr4:inc       byte ptr ds:[PCXCit]     ; zv˜¨en¡ ‡¡ta‡e znak–
         cmp       byte ptr ds:[PCXCit],255 ; je ji‘ maximum ?
         jb        WritChr6                 ; nen¡ je¨tˆ maximum
         call      WritFlsh                 ; vypr zdnˆn¡ bufferu

WritChr6:ret

WritChr  ENDP

; -----------------------------------------------------------------------------
;        vypr zdnˆn¡ v˜stupn¡ho st©ada‡e opakov n¡
; -----------------------------------------------------------------------------

WritFlsh PROC      NEAR

         push      ax

         mov       al,ds:[PCXChar]          ; znak k vysl n¡
         mov       ah,ds:[PCXCit]           ; po‡et znak– opakov n¡

         cmp       ah,0c0h                  ; je nˆjak˜ bajt ?
         je        WritFls4                 ; nen¡ ‘ dn˜ bajt

         cmp       al,0c0h                  ; je povolen˜ bajt ?
         jae       WritFls1                 ; nen¡ povolen˜ bajt
         cmp       ah,0c1h                  ; je 1 bajt ?
         je        WritFls2                 ; je 1 bajt - nen¡ opakov n¡

WritFls1:xchg      al,ah                    ; AL <- po‡et bajt–
         call      WritByte                 ; z pis po‡tu opakov n¡
         xchg      al,ah                    ; AL <- bajt
WritFls2:call      WritByte                 ; z pis bajtu k opakov n¡

         mov       byte ptr ds:[PCXCit],0c0h ; nen¡ ‘ dn˜ bajt

WritFls4:pop       ax
         ret

WritFlsh ENDP

; -----------------------------------------------------------------------------
;        z pis bajtu do v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

WritByte PROC      NEAR

         push      di
         mov       di,ds:[OutNum]           ; po‡et bajt– ve v˜stupn¡m bufferu
         cmp       di,BUFFSIZE              ; je buffer ji‘ pln˜ ?
         jb        WritByt2                 ; buffer je¨tˆ nen¡ pln˜

         call      WritBuff                 ; z pis v˜stupn¡ho bufferu
         xor       di,di                    ; nov˜ ukazatel v bufferu

WritByt2:mov       ds:[di+OutBuff],al       ; ulo‘en¡ bajtu do bufferu
         inc       word ptr ds:[OutNum]     ; zv˜¨en¡ ‡¡ta‡e bajt– v bufferu

         pop       di
         ret

WritByte ENDP

; -----------------------------------------------------------------------------
;        z pis v˜stupn¡ho bufferu
; -----------------------------------------------------------------------------

WritBuff PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx

         mov       cx,ds:[OutNum]           ; po‡et bajt– ve v˜stupn¡m bufferu
         jcxz      WritBuf2                 ; v bufferu nejsou ‘ dn  data
         mov       bx,ds:[OutIdent]         ; identifik tor v˜stupn¡ho souboru
         mov       dx,offset OutBuff        ; v˜stupn¡ buffer
         mov       ah,40h
         int       21h                      ; z pis dat do souboru
         mov       word ptr ds:[OutNum],0   ; nejsou ‘ dn  data v bufferu

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
;þ
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

; ------ z hlav¡ souboru SCR

SCR      label     byte                   ;* z hlav¡ souboru SCREEN (d‚lka 16 B)
SCRIdent db        'SCR'                    ; identifikace souboru displeje
SCRVerze db        1                        ; verze souboru
SCRSirka dw        0                        ; ¨¡©ka v˜©ezu (pozic, bod–)
SCRVyska dw        0                        ; v˜¨ka v˜©ezu (linek)
SCRRovin db        0                        ; po‡et barevn˜ch rovin
         db        0                        ; (rezervov no)
SCRPozad db        0                        ; barva pozad¡
SCRKomnt db        0                        ; po‡et bajt– koment ©e + informace
SCRPalet dw        0                        ; po‡et bajt– za z hlav¡m
SCRVMod  db        0                        ; videom¢d displeje
SCRParam db        1                        ; parametry
                                            ;  bit 0: 1=komprese
                                            ;  bit 1: 1=textov˜ videom¢d
                                            ;  bit 2: 1=paraleln¡ ulo‘en¡ barev
                                            ;  bit 3: 1=obsahuje masku
                                            ;  bit 4: 1=jsou palety CGA
                                            ;  bit 5: 1=jsou palety EGA
                                            ;  bit 6: 1=jsou palety VGA
                                            ;  bit 7:
SCR0     label     byte                     ; konec z hlav¡

Koment   db        256 dup(0)               ; koment © SCR
PalCGA   db        0                        ; paleta CGA
PalEGA   db        16 dup(0)                ; buffer palet EGA
PalEGA0  db        0                        ; barva pozad¡
PalEGAM  db        0                        ; mapov n¡ palety EGA pro VGA
PalVGA   db        3*256 dup(0)             ; buffer palet VGA

; ------ ukazatele pro dekompresi souboru SCR

SCRCit   db        0                        ; ‡¡ta‡ shodn‚ho bajtu
SCRChar  db        0                        ; znak k opakov n¡
SCRKomp  db        1                        ; 1=p©¡znak kompresn¡ho m¢du
                                            ; 2=je komprese

; ------ standardn¡ paleta CGA

StandCGA db        10h

; ------ standardn¡ paleta EGA

StandEGA db        0,1,2,3,4,5,20,7         ; 0 a‘ 7
         db        56,57,58,59,60,61,62,63  ; 8 a‘ 18
         db        0                        ; pozad¡
         db        0                        ; mapov n¡ palet

; ------ standardn¡ paleta VGA

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

; ------ z hlav¡ souboru PCX

PCX      label     byte                     ; z hlav¡ souboru PCX
PCXIdent db        10                       ; 0: identifikace souboru
PCXVerze db        5                        ; 1: 5=verze 3.0 s paletou 3*256
PCXMetod db        1                        ; 2: metoda k¢dov n¡ PCX
PCXBits  db        8                        ; 3: po‡et bit–/bod v jedn‚ rovinˆ
PCXX1    dw        0                        ; 4: po‡ te‡n¡ sou©adnice X1
PCXY1    dw        0                        ; 6: po‡ te‡n¡ sou©adnice Y1
PCXX2    dw        319                      ; 8: koncov  sou©adnice X2
PCXY2    dw        199                      ; 10: koncov  sou©adnice Y2
PCXHoriz dw        320                      ; 12: horiz. rozli¨itelnost displeje
PCXVert  dw        200                      ; 14: vert. rozli¨itelnost displeje
PCXEga   db           0,   0,   0           ;        ‡ern 
         db           0,   0,4*42           ;        modr 
         db           0,4*42,   0           ;        zelen 
         db           0,4*42,4*42           ;        modrozelen 
         db        4*42,   0,   0           ;        ‡erven 
         db        4*42,   0,4*42           ;        purpurov 
         db        4*42,4*21,   0           ;        hnˆd 
         db        4*42,4*42,4*42           ;        b¡l 
         db        4*21,4*21,4*21           ;        ¨ed 
         db        4*21,4*21,4*63           ;        svˆtle modr 
         db        4*21,4*63,4*21           ;        svˆtle zelen 
         db        4*21,4*63,4*63           ;        svˆtle modrozelen 
         db        4*63,4*21,4*21           ;        svˆtle ‡erven 
         db        4*63,4*21,4*63           ;        svˆtle purpurov 
         db        4*63,4*63,4*21           ;        ‘lut 
         db        4*63,4*63,4*63           ;        svˆtle b¡l 
         db        0                        ; 64: ... nevyu‘ito
PCXRovin db        1                        ; 65: po‡et barevn˜ch rovin
PCXByte  dw        320                      ; 66: po‡et bajt– na © dek obr zku
PCXInter dw        1                        ; 68: interpretace palety barev
         db        58 dup(0)                ; 70: ... nevyu‘ito
PCX0     label     byte

PCXVgaX  db        12                       ; oddˆlova‡ palet 12
PCXVga   db        3*256 dup(0)             ; paleta barev VGA
                                            ; (1) ‡erven  0 a‘ 255
                                            ; (1) zelen  0 a‘ 255
                                            ; (1) modr  0 a‘ 255

; ------ ukazatele pro kompresi souboru PCX

PCXCit   db        0c0h                     ; ‡¡ta‡ shodn‚ho bajtu C0 ...
PCXChar  db        0                        ; opakovan˜ bajt

; ------ vyhled v n¡ soubor–

Soubory  db        '*.SCR',0                ; specifikace hledan˜ch soubor–

DTA      db        1eh dup(0)               ; buffer DTA
DTAName  db        13 dup(0)                ; buffer jm‚na souboru
         db        "......."                ; rezerva

; ------ vstupn¡ soubor

InpIdent dw        0                        ; identifik tor vstupn¡ho souboru
InpRead  dw        0                        ; offset ‡tec¡ adresy z bufferu
InpNum   dw        0                        ; po‡et bajt– ve vstupn¡m bufferu
InpBuff  db        BUFFSIZE dup(0)          ; vstupn¡ buffer

; ------ v˜stupn¡ soubor

OutIdent dw        0                        ; identifik tor v˜stupn¡ho souboru
OutNum   dw        0                        ; po‡et bajt– ve v˜stupn¡m bufferu
OutBuff  db        BUFFSIZE dup(0)          ; v˜stupn¡ buffer

; ------ adresa bufferu rovin (ka‘d˜ buffer 64 KB)

Buffer0  dw        0                        ; buffer roviny 0
Buffer1  dw        0                        ; buffer roviny 1
Buffer2  dw        0                        ; buffer roviny 2
Buffer3  dw        0                        ; buffer roviny 3

; ------ z sobn¡k

         dw        200h dup(0)              ; pracovn¡ z sobn¡k
Zasobnik label     word

Code     ENDS
         END       Start

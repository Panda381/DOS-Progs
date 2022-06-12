
Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©¡prava p©¡kazov‚ho © dku

Start:   mov       si,81h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       ch,0
         mov       cl,ds:[si-1]             ; d‚lka p©¡kazov‚ho © dku

; ------ test, zda je nˆco zad no

         call      ParSpc                   ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         jnc       Start10                  ; je nˆco zad no
         jmp       Chyba                    ; chyba - nen¡ nic zad no

; ------ vypu¨tˆn¡ mezer p©ed za‡ tkem parametru

Start1:  call      ParSpc                   ; vypu¨tˆn¡ mezer z p©¡kaz. © dku
         jnc       Start10                  ; je dal¨¡ znak
         jmp       Navrat                   ; nen¡ dal¨¡ parametr - konec
Start10: call      ParChr                   ; vstup prvn¡ho znaku

; ------ parametr "#" - zobrazeni obsahu bufferu kl vesnice

Start11: cmp       al,"#"                   ; zobrazen¡ bufferu ?
         jne       Start110
         call      DispBuff                 ; zobrazen¡ bufferu kl vesnice
         jmp       short Start1             ; dal¨¡ parametr

; ------ parametr "?" - test p©ipravenosti znaku z kl vesnice

Start110:cmp       al,"?"                   ; test znaku ?
         jne       Start113                 ; nen¡ test znaku
         mov       ah,0bh
         int       21h                      ; test stavu kl vesnice
         cmp       al,0
         je        Start111                 ; nen¡ p©ipraven znak
         mov       al,1
Start111:mov       ah,4ch
         int       21h

; ------ parametr "@" - vstup znaku z kl vesnice

Start113:cmp       al,"@"                   ; vstup z kl vesnice ?
         jne       Start116                 ; nen¡ vstup z kl vesnice
Start114:mov       ah,6
         mov       dl,0ffh
         int       21h                      ; vstup znaku z kl vesnice
         jz        Start111                 ; nen¡ znak
         cmp       al,"a"
         jb        Start115
         cmp       al,"z"
         ja        Start115
         sub       al,32                    ; konverze na velk‚ p¡smeno
Start115:cmp       al,0                     ; je ©¡dic¡ kl vesa ?
         jne       Start111                 ; nen¡ ©¡dic¡ kl vesa
         mov       ah,6
         mov       dl,0ffh
         int       21h                      ; zru¨en¡ SCAN k¢du kl vesy
         jmp       short Start114           ; dal¨¡ test znaku z kl vesnice

; ------ parametr "!" - vypr zdnˆn¡ bufferu kl vesnice

Start116:cmp       al,"!"                   ; je parametr "!" ?
         jne       Start2                   ; nen¡ parametr "!"
         cli
         mov       ax,0c06h
         mov       dl,0ffh
         int       21h                      ; vypr zdnˆn¡ bufferu kl vesnice DOS
         cli
         push      ds
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       ax,ds:[41ch]             ; ukl dac¡ adresa do bufferu
         mov       ds:[41ah],ax             ; ‡tec¡ adresa z bufferu
         pop       ds
         sti
Start100:jmp       short Start1             ; dal¨¡ parametr

; ------ text ASCII (uvozovky)

Start2:  cmp       al,"'"                   ; uvozovky ?
         je        Start21                  ; jsou uvozovky
         cmp       al,'"'
         jne       Start3                   ; nejsou uvozovky
Start21: mov       ah,al                    ; £schova znaku uvozovek

Start22: call      ParChr                   ; na‡ten¡ dal¨¡ho znaku
         jc        Navrat                   ; konec textu
         cmp       al,ah                    ; uvozovky ?
         jne       Start23                  ; nejsou uvozovky
         call      ParChr                   ; dal¨¡ znak
         jc        Start1                   ; nen¡ dal¨¡ znak - konec
         cmp       al,ah                    ; opˆt uvozovky ?
         jne       Start11                  ; nejsou = konec, dal¨¡ parametr

Start23: call      KonvAsc                  ; konverze znaku na SCAN k¢d
         call      OutChr                   ; z pis znaku do bufferu
         jmp       short Start22            ; dal¨¡ znak

; ------ vlo‘en¡ znaku zadan‚ho HEX k¢dem

Start3:  cmp       al,"$"                   ; je HEX k¢d ?
         jne       Start4                   ; nen¡ HEX k¢d
         call      ParHex                   ; vstup HEX k¢du kl vesy do DX
         jc        Chyba                    ; chyba zad n¡ k¢du kl vesy
Start32: call      OutChr                   ; z pis znaku do bufferu kl vesnice
         jmp       short Start100           ; dal¨¡ parametr

; ------ vlo‘en¡ kl vesy zadan‚ jm‚nem

Start4:  dec       si                       ; n vrat ukazatele znak–
         inc       cx                       ; n vrat ‡¡ta‡e znak–
         call      ParKey                   ; dek¢dov n¡ k¢du kl vesy
         jnc       Start32                  ; zad n¡ OK - z pis k¢du kl vesy

; ------ chyba - zobrazen¡ n povˆdy

Chyba:   mov       si,offset HlpTxt         ; text n povˆdy
Chyba1:  cld
         lodsb
         or        al,al
         jz        Navrat
         call      DispChr                  ; zobrazen¡ znaku na displej
         jmp       short Chyba1             ; dal¨¡ znak

; ------ n vrat z programu

Navrat:  mov       ax,word ptr ds:[ErrChr]  ; po‡et nep©enesen˜ch znak–
         int       21h                      ; konec programu

; -----------------------------------------------------------------------------
;        zobrazen¡ bufferu kl vesnice
; -----------------------------------------------------------------------------

DispBuff PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      ds

;------- p©¡prava registr–

         mov       bx,40h
         mov       ds,bx                    ; DS <- data BIOS
         mov       bx,ds:[1ah]              ; ‡tec¡ adresa z bufferu kl vesnice

; ------ test, zda je nˆco p©ipraveno

         cmp       word ptr ds:[1ch],3eh
         jae       DispBuf9                 ; neplatn  adresa
         cmp       word ptr ds:[1ch],1eh
         jb        DispBuf9                 ; neplatn  adresa
         cmp       bx,ds:[1ch]              ; je nˆco v bufferu ?
         je        DispBuf9                 ; nen¡ nic v bufferu

; ------ zobrazen¡ k¢du kl vesy

DispBuf2:mov       al,ds:[bx+1]             ; p©ipraven˜ k¢d kl vesy SCAN
         call      DispByte                 ; zobrazen¡ bajtu HEX
         mov       al,ds:[bx]
         call      DispByte                 ; zobrazen¡ bajtu HEX

; ------ zv˜¨en¡ ukazatele v bufferu kl ves

         inc       bx
         inc       bx                       ; zv˜¨en¡ ukazatele v bufferu
         cmp       bl,3eh                   ; konec bufferu ?
         jb        DispBuf7                 ; nen¡ konec bufferu
         mov       bl,1eh                   ; posun na za‡ tek bufferu

; ------ test, zda je p©ipraven dal¨¡ k¢d kl vesy

DispBuf7:cmp       bx,ds:[1ch]              ; je p©ipraven dal¨¡ k¢d ?
         je        DispBuf8                 ; konec
         mov       al," "
         call      DispChr                  ; zobrazen¡ oddˆlovac¡ mezery
         jmp       short DispBuf2           ; je p©ipraven dal¨¡ k¢d

; ------ od© dkov n¡ textu

DispBuf8:mov       al,13
         call      DispChr
         mov       al,10
         call      DispChr

; ------ n vrat registr–

DispBuf9:pop       ds
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

DispBuff ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu HEX
; -----------------------------------------------------------------------------

DispByte PROC      NEAR

         push      ax
         shr       al,1
         shr       al,1
         shr       al,1
         shr       al,1
         call      DispHex                  ; zobrazen¡ znaku HEX
         pop       ax

DispHex: push      ax
         and       al,0fh
         cmp       al,10
         jb        DispHex1
         add       al,7
DispHex1:add       al,"0"
         call      DispChr                  ; zobrazen¡ znaku
         pop       ax
         ret

DispByte ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku DOS
; -----------------------------------------------------------------------------

DispChr  PROC      NEAR

         push      ax
         push      dx
         mov       dl,al                    ; znak k zobrazen¡
         mov       ah,2
         int       21h
         pop       dx
         pop       ax
         ret

DispChr  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ kl vesy zadan‚ jm‚nem do DX (CY=nen¡ platn‚ ozna‡en¡)
; -----------------------------------------------------------------------------

ParKey   PROC      NEAR

         call      ParSpc                   ; vypu¨tˆn¡ mezer
         jc        ParKey9                  ; nen¡ dal¨¡ znak

; ------ nalezen¡ p©esmyka‡e

         mov       di,offset SwcTab         ; tabulka p©esmyka‡–
         call      ParSrc                   ; nalezen¡ p©esmyka‡e v tabulce
         mov       bp,bx                    ; £schova ‡¡sla p©esmyka‡e

; ------ nalezen¡ textu kl vesy

         mov       di,offset KeyTab         ; tabulka kl ves
         call      ParSrc                   ; nalezen¡ ozna‡en¡ kl vesy
         jc        ParKey4                  ; kl vesa nenalezena

; ------ dek¢dov n¡ k¢du kl vesy

         shl       bx,1                     ; k¢d kl vesy * 2
         shl       bp,1                     ; k¢d p©esmyka‡e * 2
         add       bx,ds:[bp+SwcTab0]       ; adresa k¢du kl vesy
         mov       dx,ds:[bx]               ; k¢d kl vesy
         jmp       short ParKey8            ; ulo‘en¡ k¢du kl vesy

; ------ dek¢dov n¡ kl ves Ctrl-znak

ParKey4: call      Par0Chr                  ; na‡ten¡ dal¨¡ho znaku
         jc        ParKey9                  ; nen¡ dal¨¡ znak
         dec       bp                       ; je p©esmyka‡ Ctrl- ?
         jnz       ParKey5                  ; nen¡ p©esmyka‡ Ctrl-
         sub       al,"@"
         jb        ParKey7                  ; neplatn˜ znak
         cmp       al,32
         ja        ParKey7                  ; neplatn˜ znak
         call      KonvAsc                  ; konverze ASCII znaku na SCAN k¢d
         jmp       short ParKey8            ; ulo‘en¡ k¢du kl vesy

; ------ dek¢dov n¡ kl vesy Alt-znak

ParKey5: dec       bp                       ; je p©esmyka‡ Alt- ?
         jnz       ParKey7                  ; nen¡ p©esmyka‡ Alt-
         cmp       al,"A"
         jb        ParKey6                  ; nen¡ p¡smeno
         cmp       al,"Z"
         ja        ParKey                   ; nen¡ p¡smeno
         call      KonvAsc                  ; konverze p¡smene na SCAN k¢d
         mov       dl,0                     ; zru¨en¡ ASCII k¢du kl vesy
         jmp       short ParKey8            ; ulo‘en¡ k¢du kl vesy

ParKey6: mov       di,offset AltTab-3       ; tabulka ASCII znak– pro ALT-
ParKey61:add       di,3                     ; posun adresy v tabulce
         cmp       byte ptr ds:[di],0       ; konec tabulky ?
         je        ParKey7                  ; konec tabulky
         cmp       byte ptr ds:[di],al      ; test znaku
         je        ParKey62                 ; nalezen znak
         cmp       byte ptr ds:[di+1],al    ; alternativn¡ znak
         jne       ParKey61                 ; nesouhlas¡ - dal¨¡ polo‘ka
ParKey62:mov       dh,ds:[di+2]             ; SCAN k¢d kl vesy
         mov       dl,0
         jmp       short ParKey8            ; ulo‘en¡ k¢du kl vesy

; ------ navr cen¡ znaku

ParKey7: dec       si                       ; n vrat ukazatele textu
         inc       cx                       ; n vrat ‡¡ta‡e znak–
         stc                                ; p©¡znak chyby
         ret

ParKey8: clc                                ; p©¡znak operace OK
ParKey9: ret

ParKey   ENDP

; -----------------------------------------------------------------------------
;        konverze ASCII znaku v AL na SCAN k¢d v DX
; -----------------------------------------------------------------------------

KonvAsc  PROC      NEAR

         push      ax
         push      bx
         mov       dh,0                     ; p©ednastaven¡ pro znaky > 128
         mov       dl,al                    ; platn˜ ASCII znak
         cmp       al,128                   ; znak > 128 ?
         jae       KonvAsc2                 ; znak > 128
         mov       bx,offset AsciScan       ; tabulka SCAN k¢d– kl ves
         xlat                               ; konverze znaku na SCAN k¢d
         mov       dh,al                    ; SCAN k¢d kl vesy
KonvAsc2:pop       bx
         pop       ax
         ret

KonvAsc  ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ textu DS:SI v tabulce DI -> BX (CY=nenalezen)
; -----------------------------------------------------------------------------

ParSrc   PROC      NEAR

         xor       bx,bx                    ; ukazatel ‡¡sla polo‘ky

; ------ p©¡prava k porovn n¡ jedn‚ polo‘ky

ParSrc1: mov       ah,ds:[di]               ; d‚lka polo‘ky v tabulce
         or        ah,ah                    ; konec tabulky ?
         stc                                ; p©¡znak nenalezen¡ textu
         jz        ParSrc9                  ; konec - text nenalezen

; ------ £schova registr–

         push      si
         push      di
         push      cx

; ------ porovn n¡ text– jedn‚ polo‘ky

ParSrc2: inc       di                       ; zv˜¨en¡ ukazatele v tabulce
         call      Par0Chr                  ; na‡ten¡ dal¨¡ho znaku
         jc        ParSrc3                  ; konec textu
         cmp       al,ds:[di]               ; porovn n¡ znaku
         jne       ParSrc3                  ; nen¡ shoda
         dec       ah                       ; ‡¡ta‡ d‚lky textu
         jnz       ParSrc2                  ; porovn n¡ dal¨¡ho znaku

; ------ polo‘ka nalezena OK

         pop       ax
         pop       ax
         pop       ax
         clc                                ; p©¡znak nalezen¡ polo‘ky
         jmp       short ParSrc9

; ------ polo‘ka nesouhlas¡ - n vrat registr–

ParSrc3: pop       cx
         pop       di
         pop       si

; ------ adresa dal¨¡ polo‘ky

         mov       al,ds:[di]               ; d‚lka polo‘ky v tabulce
         mov       ah,0
         inc       di                       ; za‡ tek textu polo‘ky
         add       di,ax                    ; adresa dal¨¡ polo‘ky
         inc       bx                       ; zv˜¨en¡ ukazatele polo‘ek
         jmp       short ParSrc1            ; test dal¨¡ polo‘ky

ParSrc9: ret

ParSrc   ENDP

; -----------------------------------------------------------------------------
;        vstup HEX k¢du z p©¡kazov‚ho © dku do DX (CY=HEX k¢d nezad n)
; -----------------------------------------------------------------------------

ParHex   PROC      NEAR

         xor       dx,dx                    ; st©ada‡ ‡¡sla
         call      ParSpc                   ; vypu¨tˆn¡ mezer
         call      ParHx                    ; test, zda je prvn¡ znak
         jc        ParHex8                  ; nen¡ nic zad no - chyba
ParHex2: shl       dx,1
         shl       dx,1
         shl       dx,1
         shl       dx,1
         or        dl,al                    ; p©id n¡ nov‚ ‡¡slice ke st©ada‡i
         call      ParHx                    ; test, zda je dal¨¡ ‡¡slice
         jnc       ParHex2                  ; dek¢dov n¡ dal¨¡ ‡¡slice
         clc                                ; p©¡znak operace OK
ParHex8: ret

ParHex   ENDP

; -----------------------------------------------------------------------------
;        vstup jednoho znaku HEX do AL (CY=nen¡ znak HEX)
; -----------------------------------------------------------------------------

ParHx    PROC      NEAR

         call      Par0Chr                  ; vstup znaku s konverz¡
         jc        ParHx9                   ; nen¡ dal¨¡ znak

         cmp       al,"0"
         jb        ParHx8                   ; nen¡ platn˜ znak
         cmp       al,"9"
         jbe       ParHx4                   ; je platn  ‡¡slice

         cmp       al,"A"
         jb        ParHx8                   ; nen¡ platn˜ znak
         cmp       al,"F"
         ja        ParHx8                   ; nen¡ platn˜ znak

         sub       al,7                     ; korekce na ‡¡slici
ParHx4:  sub       al,"0"                   ; konverze na ‡¡slo
         clc                                ; p©¡znak operace OK
         ret

ParHx8:  dec       si                       ; n vrat ukazatele znak–
         inc       cx                       ; n vrat ‡¡ta‡e znak–
         stc                                ; p©¡znak neplatn‚ho znaku

ParHx9:  ret

ParHx    ENDP

; -----------------------------------------------------------------------------
;        vstup znaku s konverz¡ (CY=nen¡ dal¨¡ znak, ZY=je oddˆlova‡)
; -----------------------------------------------------------------------------

Par0Chr  PROC      NEAR

; ------ vstup znaku z p©¡kazov‚ho © dku

         call      ParChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        Par0Chr9                 ; nen¡ dal¨¡ znak

; ------ n hrada tabel toru mezerou

         jne       Par0Chr2                 ; nen¡ tabel tor ani mezera
         mov       al," "                   ; n hrada mezerou

; ------ konverze na velk‚ p¡smeno

Par0Chr2:cmp       al,"a"
         jb        Par0Chr3
         cmp       al,"z"
         ja        Par0Chr3
         sub       al,32                    ; konverze na velk‚ p¡smeno

; ------ test, zda je mezera

Par0Chr3:cmp       al," "                   ; je oddˆlovac¡ mezera ?
         clc                                ; p©¡znak platn‚ho znaku

Par0Chr9:ret

Par0Chr  ENDP

; -----------------------------------------------------------------------------
;        vypu¨tˆn¡ mezer z p©¡kazov‚ho © dku (CY=nen¡ dal¨¡ znak)
; -----------------------------------------------------------------------------

ParSpc   PROC      NEAR

         call      ParChr                   ; vstup znaku z p©¡kazov‚ho © dku
         jc        ParSpc2                  ; nen¡ dal¨¡ znak
         je        ParSpc                   ; vypu¨tˆn¡ oddˆlovac¡ mezery
         cmp       al,"/"
         je        ParSpc                   ; znak "/" se ignoruje
         clc                                ; p©¡znak platn‚ho znaku
         dec       si                       ; n vrat ukazatele textu
         inc       cx                       ; n vrat ‡¡ta‡e znak–
ParSpc2: ret

ParSpc   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡kazov‚ho © dku (CY=nen¡ dal¨¡ znak, ZY=je oddˆlova‡)
; -----------------------------------------------------------------------------

ParChr   PROC      NEAR

; ------ test, zda je dal¨¡ znak

         stc                                ; p©¡znak chyby
         jcxz      ParChr2                  ; nen¡ dal¨¡ znak

; ------ na‡ten¡ znaku

         cld
         lodsb                              ; na‡ten¡ znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–

; ------ test, zda je znakem oddˆlova‡ (mezera nebo tabel tor)

         cmp       al,9                     ; je tabel tor ?
         je        ParChr1                  ; je tabel tor
         cmp       al," "                   ; je oddˆlovac¡ mezera ?
ParChr1: clc                                ; p©¡znak platn‚ho znaku

ParChr2: ret

ParChr   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku DX do bufferu kl vesnice
; -----------------------------------------------------------------------------

OutChr   PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      ds

; ------ adresa bufferu kl vesnice

         mov       bx,40h
         mov       ds,bx                    ; DS <- segment dat BIOS

; ------ zv˜¨en¡ ukl dac¡ adresy do bufferu

         mov       bx,ds:[1ch]              ; ukl dac¡ adresa do bufferu
         mov       ax,bx                    ; ukl dac¡ adresa do bufferu
         inc       ax
         inc       ax                       ; zv˜¨en¡ ukl dac¡ adresy do bufferu
         cmp       al,3eh                   ; p©ete‡en¡ konce bufferu ?
         jb        OutChr2                  ; nen¡ p©ete‡en¡ konce bufferu
         mov       al,1eh                   ; za‡ tek bufferu

; ------ test p©eplnˆn¡ bufferu

OutChr2: cmp       ax,ds:[1ah]              ; bylo by p©eplnˆn¡ bufferu ?
         jne       OutChr3                  ; nen¡ p©eplnˆn¡ bufferu
         pop       ds
         inc       byte ptr ds:[ErrChr]     ; zv˜¨en¡ ‡¡ta‡e neulo‘en˜ch bajt–
         jmp       short OutChr9

; ------ ulo‘en¡ znaku do bufferu

OutChr3: mov       ds:[bx],dx               ; ulo‘en¡ k¢du kl vesy do bufferu
         mov       ds:[1ch],ax              ; nov  ukl dac¡ adresa do bufferu

; ------ n vrat registr–

         pop       ds
OutChr9: pop       bx
         pop       ax
         ret

OutChr   ENDP

; -----------------------------------------------------------------------------
;        data
; -----------------------------------------------------------------------------
;þ
ErrChr   db        0                        ; ‡¡ta‡ neulo‘en˜ch znak– do buff.
         db        4ch                      ; povel pro konec programu

HlpTxt   db        'INKEY V1.01 - ovladani bufferu klavesnice; (c) Miroslav Nemecek',13,10
         db        '===============================================================',13,10
         db        'Zadejte: # ........ zobrazen¡ obsahu bufferu kl vesnice',13,10
         db        '         ? ........ test pripravenosti znaku z klavesnice (0=neni znak)',13,10
         db        '         @ ........ vstup znaku z klavesnice (0=neni znak)',13,10
         db        '         ! ........ vyprazdeni bufferu klavesnice',13,10
         db        '         "text" ... vlozeni 1 nebo vice znaku ASCII do bufferu',13,10
         db        '         $hex ..... vlozeni kodu klavesy zadane v HEX kodu (napr. $11b=ESC)',13,10
         db        '         klavesa .. vlozeni ridici klavesy zadane jmenem (napr. Ctrl-Left)',13,10
         db        0

AsciScan label     byte                     ; tabulka SCAN k¢d– ASCII znak–
         db        3,1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h  ; 00h-0fh
         db        19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch,1,2bh,1bh,7,0ch    ; 10h-1fh
         db        39h,2,28h,4,5,6,8,28h,0ah,0bh,9,0dh,33h,0ch,34h,35h            ; 20h-2fh
         db        0bh,2,3,4,5,6,7,8,9,0ah,27h,27h,33h,0dh,34h,35h                ; 30h-3fh
         db        3,1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h  ; 40h-4fh
         db        19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch,1ah,2bh,1bh,7,0ch  ; 50h-5fh
         db        29h,1eh,30h,2eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h; 60h-6fh
         db        19h,10h,13h,1fh,14h,16h,2fh,11h,2dh,15h,2ch,1ah,2bh,1bh,29h,0eh; 70h-7fh

AltTab   label     byte                     ; tabulka kl ves se SCAN
         db        '1!',78h
         db        '2@',79h
         db        '3#',7ah
         db        '4$',7bh
         db        '5%',7ch
         db        '6^',7dh
         db        '7&',7eh
         db        '8*',7fh
         db        '9(',80h
         db        '0)',81h
         db        '-_',82h
         db        '=+',83h
         db        '[{',1ah
         db        ']}',1bh
         db        ';:',27h
         db        27h,'"',28h
         db        '`~',29h
         db        '\|',2bh
         db        ',<',33h
         db        '.>',34h
         db        '/?',35h
         db        0

SwcTab   label     byte                     ; tabulka p©esmyka‡–
         db        6,'SHIFT-'               ; 0:
         db        5,'CTRL-'                ; 1:
         db        4,'ALT-'                 ; 2:
         db        0                        ; 3:

SwcTab0  label     word                     ; adresy tabulek
         dw        KeyTabS                  ; 0: SHIFT
         dw        KeyTabC                  ; 1: CTRL
         dw        KeyTabA                  ; 2: ALT
         dw        KeyTab0                  ; 3: bez p©esmyka‡e

KeyTab   label     byte                     ; tabulka ozna‡en¡ kl ves
         db        3,'ESC'                  ;  0:
         db        2,'BS'                   ;  1:
         db        9,'BACKSPACE'            ;  2:
         db        3,'TAB'                  ;  3:
         db        5,'ENTER'                ;  4:

         db        5,'PRSCR'                ;  5:
         db        11,'PRINTSCREEN'         ;  6:

         db        3,'SPC'                  ;  7:
         db        5,'SPACE'                ;  8:

         db        3,'F10'                  ;  9:
         db        3,'F11'                  ; 10:
         db        3,'F12'                  ; 11:
         db        2,'F1'                   ; 12:
         db        2,'F2'                   ; 13:
         db        2,'F3'                   ; 14:
         db        2,'F4'                   ; 15:
         db        2,'F5'                   ; 16:
         db        2,'F6'                   ; 17:
         db        2,'F7'                   ; 18:
         db        2,'F8'                   ; 19:
         db        2,'F9'                   ; 20:

         db        2,'UP'                   ; 21:
         db        4,'LEFT'                 ; 22:
         db        5,'RIGHT'                ; 23:
         db        4,'DOWN'                 ; 24:

         db        4,'HOME'                 ; 25:
         db        3,'END'                  ; 26:

         db        4,'PGUP'                 ; 27:
         db        6,'PAGEUP'               ; 28:
         db        8,'PAGEDOWN'             ; 29:
         db        5,'PGDWN'                ; 30:

         db        6,'INSERT'               ; 32:
         db        3,'INS'                  ; 31:
         db        6,'DELETE'               ; 34:
         db        3,'DEL'                  ; 33:

         db        0                        ; 35:

KeyTab0  label     word                     ; tabulka k¢d– bez p©esmyka‡–
         dw        11bh                     ;  0:ESC
         dw        0e08h                    ;  1:BS
         dw        0e08h                    ;  2:BACKSPACE
         dw        0f09h                    ;  3:TAB
         dw        1c0dh                    ;  4:ENTER

         dw        7200h                    ;  5:PRSCR
         dw        7200h                    ;  6:PRINTSCREEN

         dw        3920h                    ;  7:SPC
         dw        3920h                    ;  8:SPACE

         dw        4400h                    ; 18:F10
         dw        8500h                    ; 19:F11
         dw        8600h                    ; 20:F12
         dw        3b00h                    ;  9:F1
         dw        3c00h                    ; 10:F2
         dw        3d00h                    ; 11:F3
         dw        3e00h                    ; 12:F4
         dw        3f00h                    ; 13:F5
         dw        4000h                    ; 14:F6
         dw        4100h                    ; 15:F7
         dw        4200h                    ; 16:F8
         dw        4300h                    ; 17:F9

         dw        4800h                    ; 21:UP
         dw        4b00h                    ; 22:LEFT
         dw        4d00h                    ; 23:RIGHT
         dw        5000h                    ; 24:DOWN

         dw        4700h                    ; 25:HOME
         dw        4f00h                    ; 26:END

         dw        4900h                    ; 27:PGUP
         dw        4900h                    ; 28:PAGEUP
         dw        5100h                    ; 29:PAGEDOWN
         dw        5100h                    ; 30:PGDWN

         dw        5200h                    ; 32:INSERT
         dw        5200h                    ; 31:INS
         dw        5300h                    ; 34:DELETE
         dw        5300h                    ; 33:DEL

KeyTabS  label     word                     ; tabulka k¢d– s Shift-
         dw        11bh                     ;  0:ESC
         dw        0e08h                    ;  1:BS
         dw        0e08h                    ;  2:BACKSPACE
         dw        0f00h                    ;  3:TAB
         dw        1c0dh                    ;  4:ENTER

         dw        7200h                    ;  5:PRSCR
         dw        7200h                    ;  6:PRINTSCREEN

         dw        3920h                    ;  7:SPC
         dw        3920h                    ;  8:SPACE

         dw        5d00h                    ; 18:F10
         dw        8700h                    ; 19:F11
         dw        8800h                    ; 20:F12
         dw        5400h                    ;  9:F1
         dw        5500h                    ; 10:F2
         dw        5600h                    ; 11:F3
         dw        5700h                    ; 12:F4
         dw        5800h                    ; 13:F5
         dw        5900h                    ; 14:F6
         dw        5a00h                    ; 15:F7
         dw        5b00h                    ; 16:F8
         dw        5c00h                    ; 17:F9

         dw        4800h                    ; 21:UP
         dw        4b00h                    ; 22:LEFT
         dw        4d00h                    ; 23:RIGHT
         dw        5000h                    ; 24:DOWN

         dw        4700h                    ; 25:HOME
         dw        4f00h                    ; 26:END

         dw        4900h                    ; 27:PGUP
         dw        4900h                    ; 28:PAGEUP
         dw        5100h                    ; 29:PAGEDOWN
         dw        5100h                    ; 30:PGDWN

         dw        5200h                    ; 32:INSERT
         dw        5200h                    ; 31:INS
         dw        5300h                    ; 34:DELETE
         dw        5300h                    ; 33:DEL

KeyTabC  label     word                     ; tabulka k¢d– s Ctrl-
         dw        11bh                     ;  0:ESC
         dw        0e7fh                    ;  1:BS
         dw        0e7fh                    ;  2:BACKSPACE
         dw        9400h                    ;  3:TAB
         dw        1c0ah                    ;  4:ENTER

         dw        7200h                    ;  5:PRSCR
         dw        7200h                    ;  6:PRINTSCREEN

         dw        3920h                    ;  7:SPC
         dw        3920h                    ;  8:SPACE

         dw        6700h                    ; 18:F10
         dw        8900h                    ; 19:F11
         dw        8a00h                    ; 20:F12
         dw        5e00h                    ;  9:F1
         dw        5f00h                    ; 10:F2
         dw        6000h                    ; 11:F3
         dw        6100h                    ; 12:F4
         dw        6200h                    ; 13:F5
         dw        6300h                    ; 14:F6
         dw        6400h                    ; 15:F7
         dw        6500h                    ; 16:F8
         dw        6600h                    ; 17:F9

         dw        8de0h                    ; 21:UP
         dw        7300h                    ; 22:LEFT
         dw        7400h                    ; 23:RIGHT
         dw        91e0h                    ; 24:DOWN

         dw        7700h                    ; 25:HOME
         dw        7500h                    ; 26:END

         dw        8400h                    ; 27:PGUP
         dw        8400h                    ; 28:PAGEUP
         dw        7600h                    ; 29:PAGEDOWN
         dw        7600h                    ; 30:PGDWN

         dw        92e0h                    ; 32:INSERT
         dw        92e0h                    ; 31:INS
         dw        93e0h                    ; 34:DELETE
         dw        93e0h                    ; 33:DEL

KeyTabA  label     word                     ; tabulka k¢d– s Alt-
         dw        1f0h                     ;  0:ESC
         dw        0ef0h                    ;  1:BS
         dw        0ef0h                    ;  2:BACKSPACE
         dw        0ef0h                    ;  3:TAB
         dw        1cf0h                    ;  4:ENTER

         dw        7200h                    ;  5:PRSCR
         dw        7200h                    ;  6:PRINTSCREEN

         dw        3920h                    ;  7:SPC
         dw        3920h                    ;  8:SPACE

         dw        7100h                    ; 18:F10
         dw        8b00h                    ; 19:F11
         dw        8c00h                    ; 20:F12
         dw        6800h                    ;  9:F1
         dw        6900h                    ; 10:F2
         dw        6a00h                    ; 11:F3
         dw        6b00h                    ; 12:F4
         dw        6c00h                    ; 13:F5
         dw        6d00h                    ; 14:F6
         dw        6e00h                    ; 15:F7
         dw        6f00h                    ; 16:F8
         dw        7000h                    ; 17:F9

         dw        9800h                    ; 21:UP
         dw        9b00h                    ; 22:LEFT
         dw        9d00h                    ; 23:RIGHT
         dw        0a000h                   ; 24:DOWN

         dw        9700h                    ; 25:HOME
         dw        9f00h                    ; 26:END

         dw        9900h                    ; 27:PGUP
         dw        9900h                    ; 28:PAGEUP
         dw        0a100h                   ; 29:PAGEDOWN
         dw        0a100h                   ; 30:PGDWN

         dw        0a200h                   ; 32:INSERT
         dw        0a200h                   ; 31:INS
         dw        0a300h                   ; 34:DELETE
         dw        0a300h                   ; 33:DEL

Code     ENDS
         END       Start

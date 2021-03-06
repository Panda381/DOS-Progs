
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
;
;                          Anima뇆� soubor FLI
;
; 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�

; -----------------------------------------------------------------------------
; Soubor:
;   - z쟦lav� souboru 128 bajt�
;   - pakety (1 paket p쯥dstavuje 1 obr쟺ek - 1 krok p쯫 animaci)
;        - z쟦lav� paketu 16 bajt�
;        - bloky
;               - z쟦lav� bloku 6 bajt�
;               - paleta, cel� obr쟺ek, delta-obr쟺ek
;
; Zpravidla obsahuje 1. paket definici palet a pln� obr쟺ek, n쟳leduj죅� pakety
; obsahuj� pouze zm늧y. P쯫 stoj죅죑 obr쟺ku jsou pakety pr쟺dn� (0 blok�).
; -----------------------------------------------------------------------------
; Z쟦lav� souboru (128 bajt�):
;                  0: (4) d굃ka souboru v bajtech
;                  4: (2) identifik쟴or souboru 0AF11h  (0AF12h pro FLC)
;                  6: (2) celkov� po놽t obr쟺k� - paket� v souboru
;                  8: (2) rozm늭 obrazovky X
;                 10: (2) rozm늭 obrazovky Y
;                 12: (4) identifik쟴or programu, ve kter굆 byl soubor vytvo쯥n
;                 16: (2) prodleva mezi obr쟺ky v 10 ms (impl.5 -> 20 obr./sek.)
;                 18: (110) ... vypln늧o 0 (koment젵e ASCIIZ)
;                128:  ... n쟳leduj� pakety (obr쟺ky)
;
; -----------------------------------------------------------------------------
; Z쟦lav� paketu (16 bajt�):
;                  0: (4) d굃ka paketu v bajtech
;                  4: (2) identifik쟴or paketu 0F1FAh
;                  6: (2) po놽t blok� v paketu (0=je pouze prodleva)
;                  8: (8)  ... vypln늧o 0
;                 16:  ... n쟳leduj� bloky
;
; -----------------------------------------------------------------------------
; Z쟦lav� bloku - shodn� 뇿st (6 bajt�):
;                  0: (4) d굃ka bloku v bajtech
;                  4: (2) typ bloku
;                              0Bh = paleta
;                              0Ch = delta obr쟺ek
;                              0Fh = pln� obr쟺ek
;                  6: ... n쟳leduj� data podle typu bloku
;
; Blok palety:
;                  0: (4) d굃ka bloku v bajtech
;                  4: (2) typ bloku palety 0Bh
;                  6: (2) 1 (mo몁� verze)
;                  8: (1) po뇿te뇆� barva
;                  9: (1) po놽t barev N (0=v쮍ch 256)
;                 10: (N*3) definice palet pro N barev (3 bajty na barvu)
;                                0: (1) 놽rven� 0 a� 63
;                                1: (1) zelen� 0 a� 63
;                                2: (1) modr� 0 a� 63
;
; Pln� obr쟺ek:
;                  0: (4) d굃ka bloku v bajtech
;                  4: (2) typ bloku pln괿o obr쟺ku 0Fh
;                  6: ... n쟳leduj� definice linek, po놽t linek je d쟮 rozm늭em
;                             0: (1) po놽t 즧ek� na lince
;                             1: ... n쟳leduj� 즧eky:
;                                       0: (1) po놽t bod� k zobrazen�
;                                             -127 a� -1: -po놽t bajt� dat,
;                                                         kter� se p쯥nesou beze
;                                                         zm늧y (n쟳leduj�)
;                                               1 a� 127: po놽t opakov쟮� bajtu,
;                                                         kter� n쟳leduje
;                                       1: (1) bajt k opakov쟮�
;                                     nebo (x) nekomprimovan� data k p쯥nesen�
;
; Delta obr쟺ek:
;                  0: (4) d굃ka bloku v bajtech
;                  4: (2) typ bloku delta obr쟺ku 0Ch
;                  6: (2) po뇿te뇆� linka na obrazovce
;                  8: (2) po놽t linek
;                 10: ... n쟳leduj� definice linek:
;                             0: (1) po놽t 즧ek� na lince
;                             1: ... n쟳leduj� 즧eky:
;                                       0: (1) po놽t bod� k p쯥sko놽n� (pærustek X)
;                                       1: (1) po놽t bod� k zobrazen�
;                                               1 a� 127: po놽t bajt� dat,
;                                                         kter� se p쯥nesou beze
;                                                         zm늧y (n쟳leduj�)
;                                             -127 a� -1: -po놽t opakov쟮� bajtu,
;                                                         kter� n쟳leduje
;                                       2: (1) bajt k opakov쟮�
;                                     nebo (x) nekomprimovan� data k p쯥nesen�
; -----------------------------------------------------------------------------

; ------ na뇍en� hlavi뇃y souboru

SoubFli: call      InitPort                 ; inicializace port�
         and       byte ptr ds:[ParamBuf],not bit0+bit1 ; nulov쟮� p쯥te놽n� bufferu
         call      StrtWait                 ; zah쟩en� m닶en� 놹su
         push      ds
         pop       es                       ; ES <- segment adresy bufferu
         mov       di,offset HeadBuf        ; z쟦lav� souboru
         mov       cx,128                   ; d굃ka z쟦lav� souboru
         call      ReadFile                 ; na뇍en� z쟦lav� souboru

; ------ kontrola typu souboru

         cmp       word ptr ds:[di+4],0af11h ; identifik쟴or souboru
         je        SoubFli3

;         cmp       word ptr ds:[di+4],0af12h ; identifik쟴or souboru
;         je        SoubFli3

SoubFli2:mov       si,offset FormTxt        ; text - nekompatibiln� form쟴
         jmp       Chyba

SoubFli3:cmp       word ptr ds:[di+6],0     ; po놽t obr쟺k� v souboru
         je        SoubFli2
         cmp       word ptr ds:[di+8],320   ; Æ쯭a obrazovky
         jne       SoubFli2
         cmp       word ptr ds:[di+10],200  ; v삩ka obrazovky
         jne       SoubFli2
         mov       ax,ds:[di+16]            ; prodleva mezi obr쟺ky v 14 ms
         or        ax,ax
         jnz       SoubFl30
         inc       ax
SoubFl30:mov       ds:[DeltTime],ax

; ------ kontrola velikosti souboru

         mov       ax,word ptr ds:[SoubSize] ; velikost souboru
         cmp       ax,ds:[di]
         jne       SoubFli2
         mov       dx,word ptr ds:[SoubSize+2]
         cmp       dx,ds:[di+2]
         jne       SoubFli2

; ------ minim쟫n� velikost souboru

         or        dx,dx
         jnz       SoubFl31
         cmp       ax,140                   ; asi tak minimum
         jbe       SoubFli2                 ; chyba

; ------ p쯥vzet� parametr� souboru

SoubFl31:mov       ax,ds:[di+16]            ; prodleva mezi obr쟺ky v 10 ms
         mov       ds:[Rychlost],ax         ; prodleva mezi obr쟺ky
         mov       ax,ds:[di+6]             ; celkov� po놽t paket�/obr쟺k�
         mov       ds:[NumObr],ax           ; celkov� po놽t obr쟺k�

; ------ pæprava ukazatele bufferu

         mov       ax,ds:[BuffAdr]          ; adresa bufferu
         mov       word ptr ds:[BuffWrit+2],ax ; ukl쟡ac� adresa do bufferu
         mov       word ptr ds:[BuffRead+2],ax ; 뇍ec� adresa z bufferu
         xor       ax,ax
         mov       word ptr ds:[BuffWrit],ax
         mov       word ptr ds:[BuffRead],ax
         mov       word ptr ds:[BuffNact],ax ; po놽t na뇍en쁟h bajt�
         mov       word ptr ds:[BuffNact+2],ax

; ------ velikost bloku k na뇍en�

         mov       ax,ds:[di]
         mov       dx,ds:[di+2]             ; velikost souboru
         mov       cx,ds:[di+6]             ; po놽t paket�
         sub       ax,128
         sbb       dx,0
         cmp       dx,cx                    ; je p쯥te놽n� 64 KB ?
         jae       SoubFli2                 ; pæli� velk� soubor
         div       cx                       ; st쯥dn� velikost paketu
         mov       dx,ax
         cmp       ax,0ffe0h
         jbe       SoubFl33
         mov       ax,0ffe0h
SoubFl33:mov       ds:[BuffBlok],ax         ; st쯥dn� velikost paketu
         mov       cs:[FliLast],ax          ; velikost minul괿o bloku

; ------ nastaven� videom줰u 320x200/256

         call      SetVMod
         jnc       SoubFl34

         mov       si,offset CardTxt        ; text - nen� VGA karta
         jmp       Chyba                    ; videom줰 nenastaven

SoubFl34:mov       word ptr ds:[AdrVRAM+2],0a000h ; segment videopam늯i

; ------ za뇿tek animace obr쟺ku

SoubFli4:mov       word ptr ds:[CitObr],1   ; 눀ta� obr쟺k�

; ------ test p쯥ru쮍n� programu

SoubFl42:mov       ah,1
         int       16h
         jz        SoubFl44
         jmp       KonecCek

; ------ na뇍en� dalÆho bloku dat

SoubFl44:call      SoubPrv                  ; korekce pro prvn� soubor
         mov       cx,ds:[BuffBlok]         ; st쯥dn� velikost bloku
         mov       ax,cs:[FliLast]          ; velikost minul괿o bloku
         sub       ax,cx                    ; odchylka od st쯥dn� velikosti
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sub       cx,ax                    ; korekce velikosti dat
         call      FliRead                  ; na뇍en� bloku dat
         call      SoubPrv                  ; korekce pro prvn� soubor

; ------ velikost paketu

         les       si,ds:[BuffRead]         ; 뇍ec� adresa z bufferu
         cmp       word ptr es:[si+2],0     ; je platn� velikost paketu ?
         jne       SoubFl46                 ; chybn� velikost paketu
         mov       cx,es:[si]               ; velikost paketu
         cmp       cx,8                     ; minim쟫n� velikost paketu
         jae       SoubFl48                 ; velikost paketu je OK
SoubFl46:jmp       SoubFli2                 ; nekompatibiln� form쟴
SoubFl48:cmp       cx,0ffe0h
         ja        SoubFl46                 ; paket pæli� velk�

; ------ zaji쮝늧� dostatku dat

         mov       ax,cx
         add       ax,4
         cmp       word ptr ds:[BuffNact+2],0
         jne       SoubFl49
         sub       ax,word ptr ds:[BuffNact]
         jbe       SoubFl49

         push      cx
         xchg      ax,cx                    ; CX <- chyb늞죅� data
         call      FliRead                  ; na뇍en� chyb늞죅죅h dat
         pop       cx
         call      SoubPrv                  ; korekce pro prvn� soubor

; ------ test, zda je voln� m죛to v bufferu

SoubFl49:mov       ax,cx
         add       ax,4                     ; 4 bajty rezerva
         add       ax,si
         mov       bx,ax                    ; BX <- offset
         and       bx,0fh
         mov       dx,es
         shr       ax,1
         shr       ax,1
         shr       ax,1
         shr       ax,1
         add       ax,dx
         cmp       ax,ds:[BuffEnd]
         jb        SoubFl4F
         ja        SoubFl4A
         or        bx,bx                    ; offset
         jz        SoubFl4F                 ; je dost voln괿o m죛ta

; ------ resetov쟮� ukazatele na za뇿tek bufferu

SoubFl4A:mov       es,ds:[BuffAdr]
         xor       si,si
         mov       word ptr ds:[BuffRead],si
         mov       word ptr ds:[BuffRead+2],es

; ------ pæprava k dek줰ov쟮� paketu

SoubFl4F:les       si,ds:[BuffRead]         ; 뇍ec� adresa z bufferu
         add       si,4
         cmp       word ptr es:[si],0f1fah  ; identifik쟴or paketu
         je        SoubFl4X
         jmp       SoubFl46                 ; nekompatibiln� soubor

; ------ prodleva mezi obr쟺ky

SoubFl4X:call      TimeWait                 ; 놽k쟮� na dosa멷n� 놹su

;; ------ 놽k쟮� na zatemn늧�
;
;         sti
;         mov       dx,3dah
;SoubFL4Y:in        al,dx
;         test      al,8
;         jz        SoubFL4Y

; ------ zpracov쟮� paketu

         call      FliPaket                 ; zpracov쟮� paketu

; ------ zv삩en� adresy v bufferu

         mov       cs:[FliLast],cx          ; 즧chova velikosti bloku
         sub       word ptr ds:[BuffNact],cx
         sbb       word ptr ds:[BuffNact+2],0
         add       word ptr ds:[BuffRead],cx ; posun 뇍ec� adresy
         mov       ax,word ptr ds:[BuffRead]
         and       word ptr ds:[BuffRead],0fh ; offset
         mov       cl,4
         shr       ax,cl
         add       word ptr ds:[BuffRead+2],ax ; zv삩en� segmentu adresy

; ------ zv삩en� 눀sla paketu

         inc       word ptr ds:[CitObr]     ; zv삩en� 눀ta놽 obr쟺k�
         mov       ax,ds:[CitObr]           ; 눀ta� obr쟺k�
         cmp       ax,ds:[NumObr]           ; byl to ji� posledn� obr쟺ek ?
         ja        SoubFli8                 ; byl to ji� posledn� obr쟺ek
         jmp       SoubFl42                 ; dalÆ obr쟺ek

SoubFli8:jmp       SoubFli4                 ; od za뇿tku

FliLast  dw        0                        ; velikost minul괿o bloku

; -----------------------------------------------------------------------------
;        korekce adresy pro prvn� obr쟺ek, je-li soubor cel�
; -----------------------------------------------------------------------------

SoubPrv  PROC      NEAR

         push      ax
         push      dx

         test      byte ptr ds:[ParamBuf],bit1 ; je soubor na뇍en cel� ?
         jz        SoubPrv9                 ; nen� na뇍en cel�
         cmp       word ptr ds:[CitObr],1
         jne       SoubPrv9                 ; nen� prvn� obr쟺ek

         mov       ax,ds:[BuffAdr]          ; adresa bufferu
         mov       word ptr ds:[BuffRead+2],ax ; 뇍ec� adresa z bufferu
         mov       word ptr ds:[BuffRead],0
         mov       ax,word ptr ds:[SoubSize]
         mov       dx,word ptr ds:[SoubSize+2]
         sub       ax,128
         sbb       dx,0
         mov       word ptr ds:[BuffNact],ax ; po놽t na뇍en쁟h bajt�
         mov       word ptr ds:[BuffNact+2],ax

SoubPrv9:pop       dx
         pop       ax
         ret

SoubPrv  ENDP

; -----------------------------------------------------------------------------
;        zpracov쟮� paketu
; -----------------------------------------------------------------------------

FliPaket PROC      NEAR

; ------ 즧chova registr�

         push      cx
         push      ds

; ------ pæprava 눀ta놽 blok� v paketu

         cld
         push      es
         pop       ds
         lodsw                              ; p쯥sko놽n� identifik쟴oru paketu
         lodsw                              ; po놽t blok� v paketu
         add       si,8                     ;
         xchg      ax,bp                    ; BP <- 눀ta� blok� v paketu

; ------ test, zda je dalÆ blok

FliPakt1:or        bp,bp                    ; je dalÆ blok ?
         jnz       FliPakt2                 ; je dalÆ blok OK
         jmp       FliPakt9                 ; jsou ji� v쮍chny bloky

; ------ kontrola velikosti jednoho bloku

FliPakt2:cmp       si,-20                   ; asi tolik rezerva pro p쯥te놽n�
         jae       FliPakt9                 ; chyba
         cmp       word ptr ds:[si+2],0
         jne       FliPakt9                 ; chyba
         cmp       word ptr ds:[si],6
         jb        FliPakt9                 ; chyba

; ------ pæprava ukazatel� dat bloku

         push      si                       ; za뇿tek bloku
         push      bp
         add       si,4
         lodsb                              ; AL <- typ bloku
         inc       si                       ; za뇿tek dat bloku

; ------ paleta

         cmp       al,0bh
         jne       FliPakt3                 ; nen� paleta
         call      FliPalet                 ; vysl쟮� palety
         jmp       short FliPakt7

; ------ delta obr쟺ek

FliPakt3:cmp       al,0ch
         jne       FliPakt4                 ; nen� delta obr쟺ek
         call      FliDelta                 ; delta obr쟺ek
         jmp       short FliPakt7

; ------ pln� obr쟺ek

FliPakt4:cmp       al,0fh
         jne       FliPakt5                 ; nen� pln� obr쟺ek
         call      FliPlny                  ; pln� obr쟺ek
;         jmp       short FliPakt7

FliPakt5:

; ------ dalÆ blok

FliPakt7:pop       bp
         pop       si
         add       si,ds:[si]               ; adresa dalÆho bloku
         dec       bp                       ; 눀ta� blok�
         jmp       short FliPakt1           ; dalÆ blok

; ------ n쟶rat registr�

FliPakt9:pop       ds
         pop       cx
         ret

FliPaket ENDP

; -----------------------------------------------------------------------------
;        paleta
; -----------------------------------------------------------------------------

FliPalet PROC      NEAR

         cli
         lodsw

; ------ nastaven� po뇿te뇆� barvy

         lodsb                              ; AL <- po뇿te뇆� barva
         mov       dx,3c8h
         out       dx,al                    ; nastaven� ukazatele barev
         inc       dx

; ------ pæprava po뇍u bajt� k vysl쟮�

         lodsb                              ; AL <- po놽t barev
         mov       ah,0
         cmp       al,0
         jne       FliPalt1
         mov       ah,1
FliPalt1:mov       cx,ax
         shl       ax,1
         add       cx,ax                    ; CX = po놽t bajt� k vysl쟮�

; ------ pro 80286 se nahrad� 2 x NOP

FliPaltK:jmp       short FliPalt3           ; vysl쟮� palet pro 8086

; ------ vysl쟮� definice palet pro 80286 a vyĿ�
.286c
         rep       outsb                    ; vysl쟮� definice palet
         sti
         ret
.8086
; ------ vysl쟮� palet pro 8086

FliPalt3:lodsb
         out       dx,al
         loop      FliPalt3
         sti
         ret

FliPalet ENDP

; -----------------------------------------------------------------------------
;        pln� obr쟺ek
; -----------------------------------------------------------------------------

FliPlny  PROC      NEAR

; ------ pæprava registr�

         xor       bx,bx                    ; BX <- 0
         xor       cx,cx                    ; CX <- 0
         mov       ax,SEG Data
         mov       es,ax
         mov       dx,es:[CelkVys]          ; celkov� po놽t linek
         les       di,es:[AdrVRAM]          ; adresa videopam늯i
         xor       ax,ax                    ; AH <- 0

; ------ pæprava 눀ta놽 즧ek�

FliPlny1:lodsb                              ; po놽t 즧ek� na lince
         or        ax,ax                    ; je n늞ak� 즧ek ?
         jz        FliPlny5                 ; nen� 몺dn� 즧ek
         xchg      ax,bx                    ; BX <- 눀ta� 즧ek�

; ------ d굃ka jednoho 즧eku

FliPlny2:lodsb                              ; AL <- d굃ka jednoho 즧eku
         or        al,al                    ; je kladn� 눀slo ?
         xchg      ax,cx                    ; CX <- po놽t bajt�
         jns       FliPlny3                 ; je kladn� 눀slo - komprimace

; ------ 즧ek nekomprimovan쁟h dat

         neg       cl                       ; CX = po놽t bajt� k p쯥nesen�
         rep       movsb                    ; p쯥nos dat
         jmp       short FliPlny4

; ------ 즧ek opakuj죅죅h se dat

FliPlny3:lodsb                              ; AL <- opakuj죅� se bajt
         rep       stosb                    ; ulo멷n� bajtu

; ------ pæprava pro dalÆ 즧ek

FliPlny4:dec       bx                       ; 눀ta� 즧ek�
         jnz       FliPlny2                 ; dalÆ 즧ek

; ------ pæprava pro dalÆ linku

FliPlny5:dec       dx                       ; 눀ta� linek
         jnz       FliPlny1                 ; dalÆ linka

FliPlny9:ret

FliPlny  ENDP

; -----------------------------------------------------------------------------
;        delta obr쟺ek
; -----------------------------------------------------------------------------

FliDelta PROC      NEAR

; ------ pæprava registr�

         xor       bx,bx                    ; BX <- 0
         xor       cx,cx                    ; CX <- 0
         mov       ax,SEG Data
         mov       es,ax
         mov       dx,es:[IncVAdr]          ; pærustek adresy videolinek
         mov       word ptr cs:[FliDelt7+2],dx ; pærustek adresy videolinek

; ------ po뇿te뇆� adresa obr쟺ku -> ES:BP

         les       bp,es:[AdrVRAM]          ; adresa videopam늯i
         lodsw                              ; AX <- po뇿te뇆� linka
         mul       dx                       ; offset ve videopam늯i
         add       bp,ax                    ; DI = adresa ve videopam늯i

; ------ pæprava 눀ta놽 linek -> DX

         lodsw                              ; AX <- po놽t linek
         or        ax,ax                    ; je n늞ak� linka ?
         jz        FliDelt9                 ; nen� 몺dn� linka
         xchg      ax,dx                    ; DX <- 눀ta� linek
         xor       ax,ax                    ; AH <- 0

; ------ pæprava 눀ta놽 즧ek�

FliDelt1:mov       di,bp                    ; DI <- adresa za뇿tku linky
         lodsb                              ; AL <- po놽t 즧ek� na lince
         or        ax,ax                    ; je n늞ak� 즧ek ?
         jz        FliDelt7                 ; nen� 몺dn� 즧ek
         xchg      ax,bx                    ; BX <- 눀ta� 즧ek�

; ------ p쯥sko놽n� mezery

FliDelt2:lodsb                              ; AL <- po놽t bod� k p쯥sko놽n�
         add       di,ax                    ; p쯥sko놽n� mezery

; ------ d굃ka jednoho 즧eku

         lodsb                              ; AL <- d굃ka jednoho 즧eku
         or        al,al                    ; je kladn� 눀slo ?
         xchg      ax,cx                    ; CX <- po놽t bajt�
         js        FliDelt3                 ; je kladn� 눀slo - komprimace

; ------ 즧ek nekomprimovan쁟h dat

         rep       movsb                    ; p쯥nos dat
         jmp       short FliDelt4

; ------ 즧ek opakuj죅죅h se dat

FliDelt3:neg       cl                       ; CX = po놽t bajt� k ulo멷n�
         lodsb                              ; AL <- opakuj죅� se bajt
         rep       stosb                    ; ulo멷n� bajtu

; ------ pæprava pro dalÆ 즧ek

FliDelt4:dec       bx                       ; 눀ta� 즧ek�
         jnz       FliDelt2                 ; dalÆ 즧ek

; ------ pæprava pro dalÆ linku (instrukce ADD BP,xxxx se nastavuje !)

FliDelt7:add       bp,1234h                 ; BP <- adresa dalÆ linky
         dec       dx                       ; 눀ta� linek
         jnz       FliDelt1                 ; dalÆ linka

FliDelt9:ret

FliDelta ENDP

; -----------------------------------------------------------------------------
;                   na뇍en� CX bajt� do bufferu
; -----------------------------------------------------------------------------

FliRead  PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,cx                    ; BP <- po멲dovan� po놽t bajt�

; ------ stanoven� voln괿o m죛ta do konce bufferu

FliRead0:mov       ax,ds:[BuffEnd]          ; konec bufferu
         sub       ax,word ptr ds:[BuffWrit+2] ; vzd쟫enost od z쟰isov� adresy
         cmp       ax,0ffeh                 ; maxim쟫n� velikost
         jb        FliRead1
         mov       ax,0ffeh                 ; omezen� velikosti bufferu
FliRead1:shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p쯥vod na bajty
         sub       ax,word ptr ds:[BuffWrit] ; ode뇍en� offsetu
         test      byte ptr ds:[ParamBuf],bit1 ; je soubor ji� cel� ?
         jnz       FliRea22                 ; soubor je ji� na뇍en cel�

; ------ omezen� dat do konce bufferu

         mov       cx,bp                    ; CX <- po멲dovan� data
         jcxz      FliRea22                 ; nic se ji� nepo멲duje
         cmp       ax,cx
         jae       FliRead2
         xchg      ax,cx                    ; CX <- omezen� dat
FliRead2:jcxz      FliRead3                 ; je konec bufferu

; ------ omezen� dat po 뇍ec� adresu, je-li z쟰isov� ukazatel pod 뇍ec죑

         mov       ax,word ptr ds:[BuffRead] ; 뇍ec� offset
         mov       dx,word ptr ds:[BuffRead+2] ; 뇍ec� segment
         cmp       dx,word ptr ds:[BuffWrit+2] ; je za z쟰isov쁬 ukazatelem ?
         jne       FliRea24
         cmp       ax,word ptr ds:[BuffWrit]
FliRea24:jbe       FliRea20                 ; nen� za z쟰isov쁬 - OK
         sub       dx,word ptr ds:[BuffWrit+2] ; rozd죐 segment�
         push      ax
         mov       ax,16
         mul       dx                       ; p쯥vod rozd죐u segment� na offset
         pop       bx
         sub       ax,1                     ; 1 bajt mus� z뻮tat mezera
         sbb       dx,0
         add       ax,bx
         adc       dx,0
         sub       ax,word ptr ds:[BuffWrit]
         sbb       dx,0
         jnz       FliRea20                 ; je dost m죛ta
         cmp       ax,cx
         jae       FliRea20                 ; je dost m죛ta
         xchg      ax,cx                    ; CX <- omezen� dat
         jcxz      FliRea22                 ; nen� voln� m죛to

; ------ omezen� dat do voln괿o m죛ta

FliRea20:mov       ax,ds:[BuffSize]         ; velikost bufferu (odstavc�)
         dec       ax                       ; trochu rezerva
         mov       dx,16
         mul       dx                       ; velikost bufferu v bajtech
         sub       ax,word ptr ds:[BuffNact] ; ode뇍en� na뇍en쁟h dat
         sbb       dx,word ptr ds:[BuffNact+2]
         jnz       FliRea21                 ; je dost voln괿o m죛ta
         cmp       ax,cx
         jae       FliRea21                 ; je dost voln괿o m죛ta
         xchg      ax,cx                    ; CX <- omezen� velikosti dat
         jcxz      FliRea22                 ; nen� voln� m죛to

; ------ na뇍en� dat

FliRea21:call      Fli0Read                 ; na뇍en� dat
         sub       bp,cx                    ; sn죷en� 눀ta놽 dat
         jmp       FliRead0                 ; dalÆ data

FliRea22:jmp       FliRead9                 ; jsou v쮍chna data OK

; ------ je na konci bufferu - pæprava k nalezen� posledn죋o paketu

FliRead3:or        byte ptr ds:[ParamBuf],bit0 ; soubor se nevejde cel�
         les       si,ds:[BuffRead]         ; 뇍ec� adresa z bufferu
         mov       cx,4                     ; po놽t rotac�

; ------ nalezen� posledn죋o (necel괿o) paketu v bufferu

FliRead4:mov       ax,si                    ; AX <- offset adresy paketu
         cmp       word ptr es:[si+2],0     ; je velikost HIGH platn� ?
         jne       FliRea22                 ; paket nen� platn�
         add       ax,es:[si]               ; zv삩en� offsetu paketu
         jc        FliRea22                 ; chyba
         mov       di,ax                    ; DI <- offset dalÆho paketu
         add       ax,cx                    ; 4 bajty na dalÆ velikost
         jc        FliRea22                 ; chyba

         push      di                       ; offset dalÆho paketu
         and       di,0fh                   ; normalizace offsetu
         mov       dx,es
         shr       ax,cl                    ; p쯥vod offsetu na segment
         add       ax,dx                    ; AX <- segment dalÆho paketu + 4
         cmp       ax,ds:[BuffEnd]          ; je ji� konec dat ?
         pop       ax                       ; AX <- offset dalÆho paketu
         ja        FliRead5                 ; nalezen konec dat
         jb        FliRea42
         or        di,di
         jnz       FliRead5

FliRea42:shr       ax,cl
         add       ax,dx                    ; AX <- segment dalÆho paketu
         mov       es,ax                    ; ES <- segment dalÆho paketu
         mov       si,di                    ; SI <- offset dalÆho paketu
         jmp       short FliRead4           ; test dalÆho paketu

; ------ po놽t bajt� do zbytku bufferu -> AX

FliRead5:mov       ax,ds:[BuffEnd]          ; konec bufferu
         mov       dx,es
         sub       ax,dx                    ; offset segmentu
         shl       ax,cl                    ; p쯥vod na offset v bajtech
         sub       ax,si                    ; ode뇍en� offsetu

; ------ test, zda bude 뇍en tento posledn� paket

         cmp       dx,word ptr ds:[BuffRead+2]
         jne       FliRead6
         cmp       si,word ptr ds:[BuffRead]
FliRead6:je        FliRead8                 ; je posledn� paket - bude p쯥sun

; ------ nen� posledn� paket - test, zda je dost voln괿o m죛ta na za뇿tku bufferu

         mov       di,ax                    ; DI <- velikost dat k p쯥sunu
         mov       bx,ax                    ; BX <- velikost dat k p쯥sunu
         shr       bx,cl                    ; p쯥vod na segment
         and       di,0fh                   ; normalizace offsetu
         add       bx,ds:[BuffAdr]          ; adresa konce nov쁟h dat
         cmp       bx,word ptr ds:[BuffRead+2]
         jne       FliRead7
         cmp       di,word ptr ds:[BuffRead]
FliRead7:jae       FliRead9                 ; bylo by p쯥te놽n� dat - nic

; ------ p쯥sun dat na za뇿tek bufferu

FliRead8:push      ds
         xchg      ax,cx                    ; CX <- po놽t bajt� k p쯥sunu
         push      es
         mov       es,ds:[BuffAdr]          ; adresa bufferu
         pop       ds                       ; DS <- za뇿tek dat na konci bufferu
         xor       di,di                    ; za뇿tek bufferu
         cld
         shr       cx,1
         rep       movsw                    ; p쯥sun dat
         adc       cx,cx
         rep       movsb
         pop       ds

; ------ nov� ukl쟡ac� adresa dat

         mov       ax,di
         and       di,0fh
         mov       word ptr ds:[BuffWrit],di ; nov� ukl쟡ac� adresa
         mov       cl,4
         shr       ax,cl
         add       ax,ds:[BuffAdr]
         mov       word ptr ds:[BuffWrit+2],ax
         jmp       FliRead0                 ; dalÆ data

; ------ n쟶rat registr�

FliRead9:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

FliRead  ENDP

; -----------------------------------------------------------------------------
;        na뇍en� CX bajt� do bufferu s p쯥te놽n죑 p쯥s konec souboru
;                     nesm� p쯥t괹t p쯥s konec bufferu !
; -----------------------------------------------------------------------------

Fli0Read PROC      NEAR

; ------ 즧chova registr�

         push      ax
         push      bx
         push      cx
         push      dx
         mov       bx,cx                    ; BX <- 즧chova velikosti dat

; ------ velikost zbytku dat v souboru

Fli0Rea1:mov       ax,word ptr ds:[SoubSize] ; velikost souboru
         mov       dx,word ptr ds:[SoubSize+2]
         sub       ax,word ptr ds:[SoubUkaz]
         sbb       dx,word ptr ds:[SoubUkaz+2] ; velikost zbytku dat

; ------ omezen� velikost dat

         mov       cx,bx                    ; CX <- po멲dovan� data
         jnz       Fli0Rea2                 ; je dostate뇆� mno몊tv� dat
         cmp       ax,cx
         jae       Fli0Rea2                 ; je dostate뇆� mno몊tv� dat
         xchg      ax,cx                    ; CX <- omezen� mno몊tv� dat

; ------ na뇍en� dat do konce souboru

Fli0Rea2:jcxz      Fli0Rea3                 ; nezbyla 몺dn� data
         call      ReadBuff                 ; na뇍en� dat do bufferu
         sub       bx,cx                    ; sn죷en� zbyl쁟h dat

; ------ test, zda zbyla n늞ak� data k na뇍en�

Fli0Rea3:or        bx,bx                    ; zbyla n늞ak� data ?
         jz        Fli0Rea9                 ; nezbyla 몺dn� data

; ------ resetov쟮� ukazatele v souboru

         mov       ax,128                   ; ukazatel za hlavi뇃u souboru
         xor       dx,dx                    ; DX <- 0
         call      UkazFile                 ; resetov쟮� ukazatele v souboru

; ------ test, zda je soubor na뇍en cel�

         test      byte ptr ds:[ParamBuf],bit0 ; je soubor na뇍en cel� ?
         jnz       Fli0Rea1                 ; soubor nen� cel�
         or        byte ptr ds:[ParamBuf],bit1 ; soubor je ji� na뇍en

; ------ n쟶rat registr�

Fli0Rea9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Fli0Read ENDP

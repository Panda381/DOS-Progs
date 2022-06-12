
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                          Anima‡n¡ soubor FLI
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

; -----------------------------------------------------------------------------
; Soubor:
;   - z hlav¡ souboru 128 bajt–
;   - pakety (1 paket p©edstavuje 1 obr zek - 1 krok p©i animaci)
;        - z hlav¡ paketu 16 bajt–
;        - bloky
;               - z hlav¡ bloku 6 bajt–
;               - paleta, cel˜ obr zek, delta-obr zek
;
; Zpravidla obsahuje 1. paket definici palet a pln˜ obr zek, n sleduj¡c¡ pakety
; obsahuj¡ pouze zmˆny. P©i stoj¡c¡m obr zku jsou pakety pr zdn‚ (0 blok–).
; -----------------------------------------------------------------------------
; Z hlav¡ souboru (128 bajt–):
;                  0: (4) d‚lka souboru v bajtech
;                  4: (2) identifik tor souboru 0AF11h  (0AF12h pro FLC)
;                  6: (2) celkov˜ po‡et obr zk– - paket– v souboru
;                  8: (2) rozmˆr obrazovky X
;                 10: (2) rozmˆr obrazovky Y
;                 12: (4) identifik tor programu, ve kter‚m byl soubor vytvo©en
;                 16: (2) prodleva mezi obr zky v 10 ms (impl.5 -> 20 obr./sek.)
;                 18: (110) ... vyplnˆno 0 (koment ©e ASCIIZ)
;                128:  ... n sleduj¡ pakety (obr zky)
;
; -----------------------------------------------------------------------------
; Z hlav¡ paketu (16 bajt–):
;                  0: (4) d‚lka paketu v bajtech
;                  4: (2) identifik tor paketu 0F1FAh
;                  6: (2) po‡et blok– v paketu (0=je pouze prodleva)
;                  8: (8)  ... vyplnˆno 0
;                 16:  ... n sleduj¡ bloky
;
; -----------------------------------------------------------------------------
; Z hlav¡ bloku - shodn  ‡ st (6 bajt–):
;                  0: (4) d‚lka bloku v bajtech
;                  4: (2) typ bloku
;                              0Bh = paleta
;                              0Ch = delta obr zek
;                              0Fh = pln˜ obr zek
;                  6: ... n sleduj¡ data podle typu bloku
;
; Blok palety:
;                  0: (4) d‚lka bloku v bajtech
;                  4: (2) typ bloku palety 0Bh
;                  6: (2) 1 (mo‘n  verze)
;                  8: (1) po‡ te‡n¡ barva
;                  9: (1) po‡et barev N (0=v¨ech 256)
;                 10: (N*3) definice palet pro N barev (3 bajty na barvu)
;                                0: (1) ‡erven  0 a‘ 63
;                                1: (1) zelen  0 a‘ 63
;                                2: (1) modr  0 a‘ 63
;
; Pln˜ obr zek:
;                  0: (4) d‚lka bloku v bajtech
;                  4: (2) typ bloku pln‚ho obr zku 0Fh
;                  6: ... n sleduj¡ definice linek, po‡et linek je d n rozmˆrem
;                             0: (1) po‡et £sek– na lince
;                             1: ... n sleduj¡ £seky:
;                                       0: (1) po‡et bod– k zobrazen¡
;                                             -127 a‘ -1: -po‡et bajt– dat,
;                                                         kter  se p©enesou beze
;                                                         zmˆny (n sleduj¡)
;                                               1 a‘ 127: po‡et opakov n¡ bajtu,
;                                                         kter˜ n sleduje
;                                       1: (1) bajt k opakov n¡
;                                     nebo (x) nekomprimovan  data k p©enesen¡
;
; Delta obr zek:
;                  0: (4) d‚lka bloku v bajtech
;                  4: (2) typ bloku delta obr zku 0Ch
;                  6: (2) po‡ te‡n¡ linka na obrazovce
;                  8: (2) po‡et linek
;                 10: ... n sleduj¡ definice linek:
;                             0: (1) po‡et £sek– na lince
;                             1: ... n sleduj¡ £seky:
;                                       0: (1) po‡et bod– k p©esko‡en¡ (p©¡rustek X)
;                                       1: (1) po‡et bod– k zobrazen¡
;                                               1 a‘ 127: po‡et bajt– dat,
;                                                         kter  se p©enesou beze
;                                                         zmˆny (n sleduj¡)
;                                             -127 a‘ -1: -po‡et opakov n¡ bajtu,
;                                                         kter˜ n sleduje
;                                       2: (1) bajt k opakov n¡
;                                     nebo (x) nekomprimovan  data k p©enesen¡
; -----------------------------------------------------------------------------

; ------ na‡ten¡ hlavi‡ky souboru

SoubFli: call      InitPort                 ; inicializace port–
         and       byte ptr ds:[ParamBuf],not bit0+bit1 ; nulov n¡ p©ete‡en¡ bufferu
         call      StrtWait                 ; zah jen¡ mˆ©en¡ ‡asu
         push      ds
         pop       es                       ; ES <- segment adresy bufferu
         mov       di,offset HeadBuf        ; z hlav¡ souboru
         mov       cx,128                   ; d‚lka z hlav¡ souboru
         call      ReadFile                 ; na‡ten¡ z hlav¡ souboru

; ------ kontrola typu souboru

         cmp       word ptr ds:[di+4],0af11h ; identifik tor souboru
         je        SoubFli3

;         cmp       word ptr ds:[di+4],0af12h ; identifik tor souboru
;         je        SoubFli3

SoubFli2:mov       si,offset FormTxt        ; text - nekompatibiln¡ form t
         jmp       Chyba

SoubFli3:cmp       word ptr ds:[di+6],0     ; po‡et obr zk– v souboru
         je        SoubFli2
         cmp       word ptr ds:[di+8],320   ; ¨¡©ka obrazovky
         jne       SoubFli2
         cmp       word ptr ds:[di+10],200  ; v˜¨ka obrazovky
         jne       SoubFli2
         mov       ax,ds:[di+16]            ; prodleva mezi obr zky v 14 ms
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

; ------ minim ln¡ velikost souboru

         or        dx,dx
         jnz       SoubFl31
         cmp       ax,140                   ; asi tak minimum
         jbe       SoubFli2                 ; chyba

; ------ p©evzet¡ parametr– souboru

SoubFl31:mov       ax,ds:[di+16]            ; prodleva mezi obr zky v 10 ms
         mov       ds:[Rychlost],ax         ; prodleva mezi obr zky
         mov       ax,ds:[di+6]             ; celkov˜ po‡et paket–/obr zk–
         mov       ds:[NumObr],ax           ; celkov˜ po‡et obr zk–

; ------ p©¡prava ukazatele bufferu

         mov       ax,ds:[BuffAdr]          ; adresa bufferu
         mov       word ptr ds:[BuffWrit+2],ax ; ukl dac¡ adresa do bufferu
         mov       word ptr ds:[BuffRead+2],ax ; ‡tec¡ adresa z bufferu
         xor       ax,ax
         mov       word ptr ds:[BuffWrit],ax
         mov       word ptr ds:[BuffRead],ax
         mov       word ptr ds:[BuffNact],ax ; po‡et na‡ten˜ch bajt–
         mov       word ptr ds:[BuffNact+2],ax

; ------ velikost bloku k na‡ten¡

         mov       ax,ds:[di]
         mov       dx,ds:[di+2]             ; velikost souboru
         mov       cx,ds:[di+6]             ; po‡et paket–
         sub       ax,128
         sbb       dx,0
         cmp       dx,cx                    ; je p©ete‡en¡ 64 KB ?
         jae       SoubFli2                 ; p©¡li¨ velk˜ soubor
         div       cx                       ; st©edn¡ velikost paketu
         mov       dx,ax
         cmp       ax,0ffe0h
         jbe       SoubFl33
         mov       ax,0ffe0h
SoubFl33:mov       ds:[BuffBlok],ax         ; st©edn¡ velikost paketu
         mov       cs:[FliLast],ax          ; velikost minul‚ho bloku

; ------ nastaven¡ videom¢du 320x200/256

         call      SetVMod
         jnc       SoubFl34

         mov       si,offset CardTxt        ; text - nen¡ VGA karta
         jmp       Chyba                    ; videom¢d nenastaven

SoubFl34:mov       word ptr ds:[AdrVRAM+2],0a000h ; segment videopamˆti

; ------ za‡ tek animace obr zku

SoubFli4:mov       word ptr ds:[CitObr],1   ; ‡¡ta‡ obr zk–

; ------ test p©eru¨en¡ programu

SoubFl42:mov       ah,1
         int       16h
         jz        SoubFl44
         jmp       KonecCek

; ------ na‡ten¡ dal¨¡ho bloku dat

SoubFl44:call      SoubPrv                  ; korekce pro prvn¡ soubor
         mov       cx,ds:[BuffBlok]         ; st©edn¡ velikost bloku
         mov       ax,cs:[FliLast]          ; velikost minul‚ho bloku
         sub       ax,cx                    ; odchylka od st©edn¡ velikosti
         sar       ax,1
         sar       ax,1
         sar       ax,1
         sub       cx,ax                    ; korekce velikosti dat
         call      FliRead                  ; na‡ten¡ bloku dat
         call      SoubPrv                  ; korekce pro prvn¡ soubor

; ------ velikost paketu

         les       si,ds:[BuffRead]         ; ‡tec¡ adresa z bufferu
         cmp       word ptr es:[si+2],0     ; je platn  velikost paketu ?
         jne       SoubFl46                 ; chybn  velikost paketu
         mov       cx,es:[si]               ; velikost paketu
         cmp       cx,8                     ; minim ln¡ velikost paketu
         jae       SoubFl48                 ; velikost paketu je OK
SoubFl46:jmp       SoubFli2                 ; nekompatibiln¡ form t
SoubFl48:cmp       cx,0ffe0h
         ja        SoubFl46                 ; paket p©¡li¨ velk˜

; ------ zaji¨tˆn¡ dostatku dat

         mov       ax,cx
         add       ax,4
         cmp       word ptr ds:[BuffNact+2],0
         jne       SoubFl49
         sub       ax,word ptr ds:[BuffNact]
         jbe       SoubFl49

         push      cx
         xchg      ax,cx                    ; CX <- chybˆj¡c¡ data
         call      FliRead                  ; na‡ten¡ chybˆj¡c¡ch dat
         pop       cx
         call      SoubPrv                  ; korekce pro prvn¡ soubor

; ------ test, zda je voln‚ m¡sto v bufferu

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
         jz        SoubFl4F                 ; je dost voln‚ho m¡sta

; ------ resetov n¡ ukazatele na za‡ tek bufferu

SoubFl4A:mov       es,ds:[BuffAdr]
         xor       si,si
         mov       word ptr ds:[BuffRead],si
         mov       word ptr ds:[BuffRead+2],es

; ------ p©¡prava k dek¢dov n¡ paketu

SoubFl4F:les       si,ds:[BuffRead]         ; ‡tec¡ adresa z bufferu
         add       si,4
         cmp       word ptr es:[si],0f1fah  ; identifik tor paketu
         je        SoubFl4X
         jmp       SoubFl46                 ; nekompatibiln¡ soubor

; ------ prodleva mezi obr zky

SoubFl4X:call      TimeWait                 ; ‡ek n¡ na dosa‘en¡ ‡asu

;; ------ ‡ek n¡ na zatemnˆn¡
;
;         sti
;         mov       dx,3dah
;SoubFL4Y:in        al,dx
;         test      al,8
;         jz        SoubFL4Y

; ------ zpracov n¡ paketu

         call      FliPaket                 ; zpracov n¡ paketu

; ------ zv˜¨en¡ adresy v bufferu

         mov       cs:[FliLast],cx          ; £schova velikosti bloku
         sub       word ptr ds:[BuffNact],cx
         sbb       word ptr ds:[BuffNact+2],0
         add       word ptr ds:[BuffRead],cx ; posun ‡tec¡ adresy
         mov       ax,word ptr ds:[BuffRead]
         and       word ptr ds:[BuffRead],0fh ; offset
         mov       cl,4
         shr       ax,cl
         add       word ptr ds:[BuffRead+2],ax ; zv˜¨en¡ segmentu adresy

; ------ zv˜¨en¡ ‡¡sla paketu

         inc       word ptr ds:[CitObr]     ; zv˜¨en¡ ‡¡ta‡e obr zk–
         mov       ax,ds:[CitObr]           ; ‡¡ta‡ obr zk–
         cmp       ax,ds:[NumObr]           ; byl to ji‘ posledn¡ obr zek ?
         ja        SoubFli8                 ; byl to ji‘ posledn¡ obr zek
         jmp       SoubFl42                 ; dal¨¡ obr zek

SoubFli8:jmp       SoubFli4                 ; od za‡ tku

FliLast  dw        0                        ; velikost minul‚ho bloku

; -----------------------------------------------------------------------------
;        korekce adresy pro prvn¡ obr zek, je-li soubor cel˜
; -----------------------------------------------------------------------------

SoubPrv  PROC      NEAR

         push      ax
         push      dx

         test      byte ptr ds:[ParamBuf],bit1 ; je soubor na‡ten cel˜ ?
         jz        SoubPrv9                 ; nen¡ na‡ten cel˜
         cmp       word ptr ds:[CitObr],1
         jne       SoubPrv9                 ; nen¡ prvn¡ obr zek

         mov       ax,ds:[BuffAdr]          ; adresa bufferu
         mov       word ptr ds:[BuffRead+2],ax ; ‡tec¡ adresa z bufferu
         mov       word ptr ds:[BuffRead],0
         mov       ax,word ptr ds:[SoubSize]
         mov       dx,word ptr ds:[SoubSize+2]
         sub       ax,128
         sbb       dx,0
         mov       word ptr ds:[BuffNact],ax ; po‡et na‡ten˜ch bajt–
         mov       word ptr ds:[BuffNact+2],ax

SoubPrv9:pop       dx
         pop       ax
         ret

SoubPrv  ENDP

; -----------------------------------------------------------------------------
;        zpracov n¡ paketu
; -----------------------------------------------------------------------------

FliPaket PROC      NEAR

; ------ £schova registr–

         push      cx
         push      ds

; ------ p©¡prava ‡¡ta‡e blok– v paketu

         cld
         push      es
         pop       ds
         lodsw                              ; p©esko‡en¡ identifik toru paketu
         lodsw                              ; po‡et blok– v paketu
         add       si,8                     ;
         xchg      ax,bp                    ; BP <- ‡¡ta‡ blok– v paketu

; ------ test, zda je dal¨¡ blok

FliPakt1:or        bp,bp                    ; je dal¨¡ blok ?
         jnz       FliPakt2                 ; je dal¨¡ blok OK
         jmp       FliPakt9                 ; jsou ji‘ v¨echny bloky

; ------ kontrola velikosti jednoho bloku

FliPakt2:cmp       si,-20                   ; asi tolik rezerva pro p©ete‡en¡
         jae       FliPakt9                 ; chyba
         cmp       word ptr ds:[si+2],0
         jne       FliPakt9                 ; chyba
         cmp       word ptr ds:[si],6
         jb        FliPakt9                 ; chyba

; ------ p©¡prava ukazatel– dat bloku

         push      si                       ; za‡ tek bloku
         push      bp
         add       si,4
         lodsb                              ; AL <- typ bloku
         inc       si                       ; za‡ tek dat bloku

; ------ paleta

         cmp       al,0bh
         jne       FliPakt3                 ; nen¡ paleta
         call      FliPalet                 ; vysl n¡ palety
         jmp       short FliPakt7

; ------ delta obr zek

FliPakt3:cmp       al,0ch
         jne       FliPakt4                 ; nen¡ delta obr zek
         call      FliDelta                 ; delta obr zek
         jmp       short FliPakt7

; ------ pln˜ obr zek

FliPakt4:cmp       al,0fh
         jne       FliPakt5                 ; nen¡ pln˜ obr zek
         call      FliPlny                  ; pln˜ obr zek
;         jmp       short FliPakt7

FliPakt5:

; ------ dal¨¡ blok

FliPakt7:pop       bp
         pop       si
         add       si,ds:[si]               ; adresa dal¨¡ho bloku
         dec       bp                       ; ‡¡ta‡ blok–
         jmp       short FliPakt1           ; dal¨¡ blok

; ------ n vrat registr–

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

; ------ nastaven¡ po‡ te‡n¡ barvy

         lodsb                              ; AL <- po‡ te‡n¡ barva
         mov       dx,3c8h
         out       dx,al                    ; nastaven¡ ukazatele barev
         inc       dx

; ------ p©¡prava po‡tu bajt– k vysl n¡

         lodsb                              ; AL <- po‡et barev
         mov       ah,0
         cmp       al,0
         jne       FliPalt1
         mov       ah,1
FliPalt1:mov       cx,ax
         shl       ax,1
         add       cx,ax                    ; CX = po‡et bajt– k vysl n¡

; ------ pro 80286 se nahrad¡ 2 x NOP

FliPaltK:jmp       short FliPalt3           ; vysl n¡ palet pro 8086

;; ------ vysl n¡ definice palet pro 80286 a vy¨¨¡
;.286c
;         rep       outsb                    ; vysl n¡ definice palet
;         sti
;         ret
;.8086
; ------ vysl n¡ palet pro 8086

FliPalt3:lodsb
         sub       al,63
         neg       al
         out       dx,al
         loop      FliPalt3
         sti
         ret

FliPalet ENDP

; -----------------------------------------------------------------------------
;        pln˜ obr zek
; -----------------------------------------------------------------------------

FliPlny  PROC      NEAR

; ------ p©¡prava registr–

         xor       bx,bx                    ; BX <- 0
         xor       cx,cx                    ; CX <- 0
         mov       ax,SEG Data
         mov       es,ax
         mov       dx,es:[CelkVys]          ; celkov˜ po‡et linek
         les       di,es:[AdrVRAM]          ; adresa videopamˆti
         xor       ax,ax                    ; AH <- 0

; ------ p©¡prava ‡¡ta‡e £sek–

FliPlny1:lodsb                              ; po‡et £sek– na lince
         or        ax,ax                    ; je nˆjak˜ £sek ?
         jz        FliPlny5                 ; nen¡ ‘ dn˜ £sek
         xchg      ax,bx                    ; BX <- ‡¡ta‡ £sek–

; ------ d‚lka jednoho £seku

FliPlny2:lodsb                              ; AL <- d‚lka jednoho £seku
         or        al,al                    ; je kladn‚ ‡¡slo ?
         xchg      ax,cx                    ; CX <- po‡et bajt–
         jns       FliPlny3                 ; je kladn‚ ‡¡slo - komprimace

; ------ £sek nekomprimovan˜ch dat

         neg       cl                       ; CX = po‡et bajt– k p©enesen¡
         rep       movsb                    ; p©enos dat
         jmp       short FliPlny4

; ------ £sek opakuj¡c¡ch se dat

FliPlny3:lodsb                              ; AL <- opakuj¡c¡ se bajt
         rep       stosb                    ; ulo‘en¡ bajtu

; ------ p©¡prava pro dal¨¡ £sek

FliPlny4:dec       bx                       ; ‡¡ta‡ £sek–
         jnz       FliPlny2                 ; dal¨¡ £sek

; ------ p©¡prava pro dal¨¡ linku

FliPlny5:dec       dx                       ; ‡¡ta‡ linek
         jnz       FliPlny1                 ; dal¨¡ linka

FliPlny9:ret

FliPlny  ENDP

; -----------------------------------------------------------------------------
;        delta obr zek
; -----------------------------------------------------------------------------

FliDelta PROC      NEAR

; ------ p©¡prava registr–

         xor       bx,bx                    ; BX <- 0
         xor       cx,cx                    ; CX <- 0
         mov       ax,SEG Data
         mov       es,ax
         mov       dx,es:[IncVAdr]          ; p©¡rustek adresy videolinek
         mov       word ptr cs:[FliDelt7+2],dx ; p©¡rustek adresy videolinek

; ------ po‡ te‡n¡ adresa obr zku -> ES:BP

         les       bp,es:[AdrVRAM]          ; adresa videopamˆti
         lodsw                              ; AX <- po‡ te‡n¡ linka
         mul       dx                       ; offset ve videopamˆti
         add       bp,ax                    ; DI = adresa ve videopamˆti

; ------ p©¡prava ‡¡ta‡e linek -> DX

         lodsw                              ; AX <- po‡et linek
         or        ax,ax                    ; je nˆjak  linka ?
         jz        FliDelt9                 ; nen¡ ‘ dn  linka
         xchg      ax,dx                    ; DX <- ‡¡ta‡ linek
         xor       ax,ax                    ; AH <- 0

; ------ p©¡prava ‡¡ta‡e £sek–

FliDelt1:mov       di,bp                    ; DI <- adresa za‡ tku linky
         lodsb                              ; AL <- po‡et £sek– na lince
         or        ax,ax                    ; je nˆjak˜ £sek ?
         jz        FliDelt7                 ; nen¡ ‘ dn˜ £sek
         xchg      ax,bx                    ; BX <- ‡¡ta‡ £sek–

; ------ p©esko‡en¡ mezery

FliDelt2:lodsb                              ; AL <- po‡et bod– k p©esko‡en¡
         add       di,ax                    ; p©esko‡en¡ mezery

; ------ d‚lka jednoho £seku

         lodsb                              ; AL <- d‚lka jednoho £seku
         or        al,al                    ; je kladn‚ ‡¡slo ?
         xchg      ax,cx                    ; CX <- po‡et bajt–
         js        FliDelt3                 ; je kladn‚ ‡¡slo - komprimace

; ------ £sek nekomprimovan˜ch dat

         rep       movsb                    ; p©enos dat
         jmp       short FliDelt4

; ------ £sek opakuj¡c¡ch se dat

FliDelt3:neg       cl                       ; CX = po‡et bajt– k ulo‘en¡
         lodsb                              ; AL <- opakuj¡c¡ se bajt
         rep       stosb                    ; ulo‘en¡ bajtu

; ------ p©¡prava pro dal¨¡ £sek

FliDelt4:dec       bx                       ; ‡¡ta‡ £sek–
         jnz       FliDelt2                 ; dal¨¡ £sek

; ------ p©¡prava pro dal¨¡ linku (instrukce ADD BP,xxxx se nastavuje !)

FliDelt7:add       bp,1234h                 ; BP <- adresa dal¨¡ linky
         dec       dx                       ; ‡¡ta‡ linek
         jnz       FliDelt1                 ; dal¨¡ linka

FliDelt9:ret

FliDelta ENDP

; -----------------------------------------------------------------------------
;                   na‡ten¡ CX bajt– do bufferu
; -----------------------------------------------------------------------------

FliRead  PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es
         mov       bp,cx                    ; BP <- po‘adovan˜ po‡et bajt–

; ------ stanoven¡ voln‚ho m¡sta do konce bufferu

FliRead0:mov       ax,ds:[BuffEnd]          ; konec bufferu
         sub       ax,word ptr ds:[BuffWrit+2] ; vzd lenost od z pisov‚ adresy
         cmp       ax,0ffeh                 ; maxim ln¡ velikost
         jb        FliRead1
         mov       ax,0ffeh                 ; omezen¡ velikosti bufferu
FliRead1:shl       ax,1
         shl       ax,1
         shl       ax,1
         shl       ax,1                     ; p©evod na bajty
         sub       ax,word ptr ds:[BuffWrit] ; ode‡ten¡ offsetu
         test      byte ptr ds:[ParamBuf],bit1 ; je soubor ji‘ cel˜ ?
         jnz       FliRea22                 ; soubor je ji‘ na‡ten cel˜

; ------ omezen¡ dat do konce bufferu

         mov       cx,bp                    ; CX <- po‘adovan  data
         jcxz      FliRea22                 ; nic se ji‘ nepo‘aduje
         cmp       ax,cx
         jae       FliRead2
         xchg      ax,cx                    ; CX <- omezen¡ dat
FliRead2:jcxz      FliRead3                 ; je konec bufferu

; ------ omezen¡ dat po ‡tec¡ adresu, je-li z pisov˜ ukazatel pod ‡tec¡m

         mov       ax,word ptr ds:[BuffRead] ; ‡tec¡ offset
         mov       dx,word ptr ds:[BuffRead+2] ; ‡tec¡ segment
         cmp       dx,word ptr ds:[BuffWrit+2] ; je za z pisov˜m ukazatelem ?
         jne       FliRea24
         cmp       ax,word ptr ds:[BuffWrit]
FliRea24:jbe       FliRea20                 ; nen¡ za z pisov˜m - OK
         sub       dx,word ptr ds:[BuffWrit+2] ; rozd¡l segment–
         push      ax
         mov       ax,16
         mul       dx                       ; p©evod rozd¡lu segment– na offset
         pop       bx
         sub       ax,1                     ; 1 bajt mus¡ z–stat mezera
         sbb       dx,0
         add       ax,bx
         adc       dx,0
         sub       ax,word ptr ds:[BuffWrit]
         sbb       dx,0
         jnz       FliRea20                 ; je dost m¡sta
         cmp       ax,cx
         jae       FliRea20                 ; je dost m¡sta
         xchg      ax,cx                    ; CX <- omezen¡ dat
         jcxz      FliRea22                 ; nen¡ voln‚ m¡sto

; ------ omezen¡ dat do voln‚ho m¡sta

FliRea20:mov       ax,ds:[BuffSize]         ; velikost bufferu (odstavc–)
         dec       ax                       ; trochu rezerva
         mov       dx,16
         mul       dx                       ; velikost bufferu v bajtech
         sub       ax,word ptr ds:[BuffNact] ; ode‡ten¡ na‡ten˜ch dat
         sbb       dx,word ptr ds:[BuffNact+2]
         jnz       FliRea21                 ; je dost voln‚ho m¡sta
         cmp       ax,cx
         jae       FliRea21                 ; je dost voln‚ho m¡sta
         xchg      ax,cx                    ; CX <- omezen¡ velikosti dat
         jcxz      FliRea22                 ; nen¡ voln‚ m¡sto

; ------ na‡ten¡ dat

FliRea21:call      Fli0Read                 ; na‡ten¡ dat
         sub       bp,cx                    ; sn¡‘en¡ ‡¡ta‡e dat
         jmp       FliRead0                 ; dal¨¡ data

FliRea22:jmp       FliRead9                 ; jsou v¨echna data OK

; ------ je na konci bufferu - p©¡prava k nalezen¡ posledn¡ho paketu

FliRead3:or        byte ptr ds:[ParamBuf],bit0 ; soubor se nevejde cel˜
         les       si,ds:[BuffRead]         ; ‡tec¡ adresa z bufferu
         mov       cx,4                     ; po‡et rotac¡

; ------ nalezen¡ posledn¡ho (necel‚ho) paketu v bufferu

FliRead4:mov       ax,si                    ; AX <- offset adresy paketu
         cmp       word ptr es:[si+2],0     ; je velikost HIGH platn  ?
         jne       FliRea22                 ; paket nen¡ platn˜
         add       ax,es:[si]               ; zv˜¨en¡ offsetu paketu
         jc        FliRea22                 ; chyba
         mov       di,ax                    ; DI <- offset dal¨¡ho paketu
         add       ax,cx                    ; 4 bajty na dal¨¡ velikost
         jc        FliRea22                 ; chyba

         push      di                       ; offset dal¨¡ho paketu
         and       di,0fh                   ; normalizace offsetu
         mov       dx,es
         shr       ax,cl                    ; p©evod offsetu na segment
         add       ax,dx                    ; AX <- segment dal¨¡ho paketu + 4
         cmp       ax,ds:[BuffEnd]          ; je ji‘ konec dat ?
         pop       ax                       ; AX <- offset dal¨¡ho paketu
         ja        FliRead5                 ; nalezen konec dat
         jb        FliRea42
         or        di,di
         jnz       FliRead5

FliRea42:shr       ax,cl
         add       ax,dx                    ; AX <- segment dal¨¡ho paketu
         mov       es,ax                    ; ES <- segment dal¨¡ho paketu
         mov       si,di                    ; SI <- offset dal¨¡ho paketu
         jmp       short FliRead4           ; test dal¨¡ho paketu

; ------ po‡et bajt– do zbytku bufferu -> AX

FliRead5:mov       ax,ds:[BuffEnd]          ; konec bufferu
         mov       dx,es
         sub       ax,dx                    ; offset segmentu
         shl       ax,cl                    ; p©evod na offset v bajtech
         sub       ax,si                    ; ode‡ten¡ offsetu

; ------ test, zda bude ‡ten tento posledn¡ paket

         cmp       dx,word ptr ds:[BuffRead+2]
         jne       FliRead6
         cmp       si,word ptr ds:[BuffRead]
FliRead6:je        FliRead8                 ; je posledn¡ paket - bude p©esun

; ------ nen¡ posledn¡ paket - test, zda je dost voln‚ho m¡sta na za‡ tku bufferu

         mov       di,ax                    ; DI <- velikost dat k p©esunu
         mov       bx,ax                    ; BX <- velikost dat k p©esunu
         shr       bx,cl                    ; p©evod na segment
         and       di,0fh                   ; normalizace offsetu
         add       bx,ds:[BuffAdr]          ; adresa konce nov˜ch dat
         cmp       bx,word ptr ds:[BuffRead+2]
         jne       FliRead7
         cmp       di,word ptr ds:[BuffRead]
FliRead7:jae       FliRead9                 ; bylo by p©ete‡en¡ dat - nic

; ------ p©esun dat na za‡ tek bufferu

FliRead8:push      ds
         xchg      ax,cx                    ; CX <- po‡et bajt– k p©esunu
         push      es
         mov       es,ds:[BuffAdr]          ; adresa bufferu
         pop       ds                       ; DS <- za‡ tek dat na konci bufferu
         xor       di,di                    ; za‡ tek bufferu
         cld
         shr       cx,1
         rep       movsw                    ; p©esun dat
         adc       cx,cx
         rep       movsb
         pop       ds

; ------ nov  ukl dac¡ adresa dat

         mov       ax,di
         and       di,0fh
         mov       word ptr ds:[BuffWrit],di ; nov  ukl dac¡ adresa
         mov       cl,4
         shr       ax,cl
         add       ax,ds:[BuffAdr]
         mov       word ptr ds:[BuffWrit+2],ax
         jmp       FliRead0                 ; dal¨¡ data

; ------ n vrat registr–

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
;        na‡ten¡ CX bajt– do bufferu s p©ete‡en¡m p©es konec souboru
;                     nesm¡ p©et‚ct p©es konec bufferu !
; -----------------------------------------------------------------------------

Fli0Read PROC      NEAR

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         mov       bx,cx                    ; BX <- £schova velikosti dat

; ------ velikost zbytku dat v souboru

Fli0Rea1:mov       ax,word ptr ds:[SoubSize] ; velikost souboru
         mov       dx,word ptr ds:[SoubSize+2]
         sub       ax,word ptr ds:[SoubUkaz]
         sbb       dx,word ptr ds:[SoubUkaz+2] ; velikost zbytku dat

; ------ omezen¡ velikost dat

         mov       cx,bx                    ; CX <- po‘adovan  data
         jnz       Fli0Rea2                 ; je dostate‡n‚ mno‘stv¡ dat
         cmp       ax,cx
         jae       Fli0Rea2                 ; je dostate‡n‚ mno‘stv¡ dat
         xchg      ax,cx                    ; CX <- omezen¡ mno‘stv¡ dat

; ------ na‡ten¡ dat do konce souboru

Fli0Rea2:jcxz      Fli0Rea3                 ; nezbyla ‘ dn  data
         call      ReadBuff                 ; na‡ten¡ dat do bufferu
         sub       bx,cx                    ; sn¡‘en¡ zbyl˜ch dat

; ------ test, zda zbyla nˆjak  data k na‡ten¡

Fli0Rea3:or        bx,bx                    ; zbyla nˆjak  data ?
         jz        Fli0Rea9                 ; nezbyla ‘ dn  data

; ------ resetov n¡ ukazatele v souboru

         mov       ax,128                   ; ukazatel za hlavi‡ku souboru
         xor       dx,dx                    ; DX <- 0
         call      UkazFile                 ; resetov n¡ ukazatele v souboru

; ------ test, zda je soubor na‡ten cel˜

         test      byte ptr ds:[ParamBuf],bit0 ; je soubor na‡ten cel˜ ?
         jnz       Fli0Rea1                 ; soubor nen¡ cel˜
         or        byte ptr ds:[ParamBuf],bit1 ; soubor je ji‘ na‡ten

; ------ n vrat registr–

Fli0Rea9:pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

Fli0Read ENDP

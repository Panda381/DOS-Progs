
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;            textov˜ editor       K O N T E X T
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code, ds:Data
         ORG       100h

Start:   jmp       l_2CB6
         nop

l_0104   dw        0CD90h
         db        0ABh

         db        'Copyright (C) 1985 BORLAND Inc'

         db        2,4,0,0E9h,56h,0,76h,32h

         db        40 dup(0)

l_0155   db        13h,'Color display 80x25'

l_0169   db        65h

l_016A   db        80                       ; koncov  pozice okna
l_016B   db        25                       ; koncov˜ © dek okna

l_016C   db        1
l_016D   db        3                        ; po‘adovan˜ videom¢d
l_016E   db        0

l_016F   db        0Fh,7,7,70h              ; barvy pro displej MDA
l_0173   db        0fh,7,7,70h              ; barvy pro displej CGA mono
l_0177   db        0eh,7,7,4fh              ; barvy pro displej CGA barevn˜

; -----------------------------------------------------------------------------
;        v˜stup textov‚ho ©etˆzce CS:BX na displej do okna (d‚lka v 1. bajtu)
; -----------------------------------------------------------------------------

l_017B   PROC      NEAR

         mov       ah,cs:[bx]               ; d‚lka textov‚ho ©etˆzce
l_017E:  or        ah,ah                    ; je nˆjak˜ znak ©etˆzce ?
         stc                                ; p©¡znak chyby - nen¡ ‘ dn˜ znak
         jz        l_0191                   ; nen¡ zad n ‘ dn˜ znak
l_0183:  inc       bx                       ; zv˜¨en¡ ukazatele textu
         mov       al,cs:[bx]               ; znak k v˜stupu na displej
l_0186:  push      ax                       ; £schova ‡¡ta‡e znak–
         call      l_0A44                   ; v˜stup znaku na displej DOS
         pop       ax                       ; n vrat ‡¡ta‡e znak–
         dec       ah                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jnz       l_0183                   ; zobrazen¡ dal¨¡ho znaku
         clc                                ; p©¡znak operace OK
l_0191:  ret

l_017B   ENDP

; -----------------------------------------------------------------------------
;        cejchov n¡ ‡asov‚ prodlevy DELAY
; -----------------------------------------------------------------------------

l_0192   dw        230h                     ; konstanta prodlevy pro cejchov n¡
l_0194   db        -1                       ; p©¡znak p©¡chodu 2. impulsu hodin


l_0195   PROC      NEAR

; ------ p©¡prava k cejchov n¡ konstanty ‡asov‚ prodlevy

         mov       word ptr ds:[d_0012],110 ; maxim ln¡ doba prodlevy
         mov       byte ptr cs:[l_0194],0   ; p©¡znak p©¡chodu 2. impulsu
         mov       si,4*1ch                 ; adresa vektoru INT 1Ch
         push      word ptr es:[si]         ; £schova adresy INT 1Ch
         push      word ptr es:[si+2]
         cli                                ; p©echodn˜ z kaz p©eru¨en¡
         mov       word ptr es:[si],offset l_01B8 ; pracovn¡ obsluha INT 1Ch
         mov       es:[si+2],cs             ; segment
         sti       
         jmp       short l_01D2             ; ‡ek n¡ na p©¡chod p©eru¨en¡

; ------ 1. p©eru¨en¡ od INT 1Ch (start zah jen¡ ‡¡t n¡ prodlevy)

l_01B8:  push      ds
         push      ax
         xor       ax,ax
         mov       ds,ax                    ; DS <- 0
         mov       word ptr ds:[4*1ch],offset l_01CB ; adresa obsluhy 2. p©eru¨en¡
         mov       cs:[l_0192],ax           ; nulov n¡ ‡asovac¡ konstanty
         pop       ax
         pop       ds
         iret      

; ------ 2. p©eru¨en¡ od INT 1Ch (konec ‡¡t n¡ prodlevy)

l_01CB:  mov       byte ptr cs:[l_0194],-1  ; p©¡znak 2. p©eru¨en¡ INT 1Ch
         iret

; ------ ‡¡t n¡ ‡asov‚ prodlevy

l_01D2:  call      l_0201                   ; prodleva (konstanta v d_0012)
         inc       word ptr cs:[l_0192]     ; zv˜¨en¡ ‡¡ta‡¡ konstanty
         cmp       byte ptr cs:[l_0194],0FFh; p©i¨el 2. impuls hodin ?
         jne       l_01D2                   ; ‡ek n¡ na 2. impuls hodin

; ------ n vrat obsluhy p©eru¨en¡ INT 1Ch

         cli       
         pop       word ptr es:[si+2]       ; n vrat p–vodn¡ adresy INT 1Ch
         pop       word ptr es:[si]
         sti       
         mov       ax,cs:[l_0192]           ; ‡¡ta‡ prodlevy
         add       ax,ax                    ; ‡¡ta‡ prodlevy * 2
         mov       ds:[d_0012],ax           ; namˆ©en  doba pro 1 ms
         ret

l_0195   ENDP

; -----------------------------------------------------------------------------
;        prodleva (v BX je doba v [ms])
; -----------------------------------------------------------------------------

l_01F5   PROC      NEAR

         mov       ax,bx                    ; AX <- doba prodlevy v [ms]
         mov       cx,ax                    ; CX <- doba prodlevy v [ms]
         jcxz      l_0200                   ; nen¡ zad na ‘ dn  prodleva
l_01FB:  call      l_0201                   ; prodleva 1 ms
         loop      l_01FB                   ; dal¨¡ cyklus prodlevy
l_0200:  ret

l_01F5   ENDP

; -----------------------------------------------------------------------------
;        prodleva 1 ms
; -----------------------------------------------------------------------------

l_0201   PROC      NEAR

         push      cx
         mov       cx,ds:[d_0012]           ; doba prodlevy pro 1 ms
         loop      $                        ; prodleva 1 ms
         pop       cx
         ret

l_0201   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ obrazovky v textov‚m m¢du
; -----------------------------------------------------------------------------

l_020A   PROC      NEAR

         push      bp
         mov       ah,0fh
         int       10h                      ; poskytnut¡ ‡¡sla videom¢du
         pop       bp
         cmp       al,ds:[d_0006]           ; byla zmˆna videom¢du ?
         je        l_021B                   ; nebyla zmˆna videom¢du
         mov       al,-1                    ; p©¡znak implicitn¡ho videom¢du
         jmp       l_02BC                   ; nastaven¡ videom¢du

l_021B:  push      bp
         mov       ax,600h                  ; funkce vymaz n¡ okna
         mov       bh,ds:[d_0008]           ; aktu ln¡ nastaven¡ barev displeje
         mov       cx,word ptr ds:[d_0004]  ; lev˜ horn¡ roh okna (poz. a © d.)
         mov       dx,word ptr cs:[l_016A]  ; koncov˜ © dek a pozice okna
         dec       dh                       ; oprava - maxim ln¡ ‡¡slo © dku
         dec       dl                       ; oprava - maxim ln¡ pozice na © dku
         int       10h                      ; vymaz n¡ okna obrazovky
         mov       ah,2
         mov       dx,word ptr ds:[d_0004]  ; lev˜ horn¡ roh okna (poz. a © d.)
         xor       bh,bh                    ; str nka 0
         int       10h                      ; nastaven¡ kurzoru do lev‚ho rohu
         pop       bp
         ret

l_020A   ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ okna v textov‚m m¢du o © dek nahoru
; -----------------------------------------------------------------------------

l_023E   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      bp

         call      l_0286                   ; ‡ten¡ pozice kurzoru a velikosti
         mov       ah,6                     ; rolov n¡ smˆrem nahoru
l_0247:  mov       al,1                     ; rolov n¡ o 1 © dek
         mov       bh,ds:[d_0008]           ; aktu ln¡ nastaven¡ barev displeje
         mov       ch,dh                    ; horn¡ © dek pro rolov n¡
         mov       cl,ds:[d_0004]           ; pozice lev‚ho horn¡ho rohu okna
         mov       dx,word ptr cs:[l_016A]  ; koncov˜ © dek a pozice okna
         dec       dh                       ; oprava - maxim ln¡ ‡¡slo © dku
         dec       dl                       ; oprava - maxim ln¡ pozice na © dku
         cmp       ch,dh                    ; je nˆjak˜ © dek k rolov n¡ ?
         jne       l_0262                   ; je nˆjak˜ © dek
         xor       al,al                    ; nen¡ © dek - maz n¡ okna
l_0262:  int       10h                      ; rolov n¡ okna

         pop       bp
         pop       dx
         pop       cx
         pop       bx
         ret

l_023E   ENDP

; -----------------------------------------------------------------------------
;        rolov n¡ okna v textov‚m m¢du o © dek dol–
; -----------------------------------------------------------------------------

l_0269   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      bp

         call      l_0286                   ; ‡ten¡ pozice kurzoru a velikosti
         mov       ah,7
         jmp       short l_0247             ; rolov n¡ okna o 1 © dek

l_0269   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ inverzn¡ch barev
; -----------------------------------------------------------------------------

l_0274   PROC      NEAR

         push      ax
         mov       al,ds:[d_0001]           ; inverzn¡ nastaven¡ barev
         mov       ds:[d_0008],al           ; aktu ln¡ nastaven¡ barev displeje
         pop       ax
         ret

l_0274   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ norm ln¡ch barev
; -----------------------------------------------------------------------------

l_027D   PROC      NEAR

         push      ax
         mov       al,ds:[d_0000]           ; z kladn¡ nastaven¡ barev
         mov       ds:[d_0008],al           ; aktu ln¡ nastaven¡ barev displeje
         pop       ax
         ret

l_027D   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ pozice kurzoru a jeho velikosti
; -----------------------------------------------------------------------------

l_0286   PROC      NEAR

         mov       ah,3
         xor       bh,bh                    ; str nka 0
         int       10h                      ; ‡ten¡ pozice a velikosti kurzoru
         ret

l_0286   ENDP

; -----------------------------------------------------------------------------
;        vymaz n¡ zbytku © dku od kurzoru
; -----------------------------------------------------------------------------

l_028D   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      bp

         call      l_0286                   ; ‡ten¡ pozice a velikosti kurzoru
         mov       ax,600h                  ; funkce vymaz n¡ okna
         mov       bh,ds:[d_0008]           ; aktu ln¡ nastaven¡ barev displeje
         mov       cx,dx                    ; sou©adnice kurzoru
         mov       dl,cs:[l_016A]           ; koncov  pozice okna
         dec       dl                       ; oprava - posledn¡ pozice na © dku
         int       10h                      ; vymaz n¡ © dku od kurzoru

         pop       bp
         pop       dx
         pop       cx
         pop       bx
         ret

l_028D   ENDP

; -----------------------------------------------------------------------------
;        inicializace displeje pro textov˜ videom¢d
; -----------------------------------------------------------------------------

l_02AB   PROC      NEAR

         call      l_05A6                   ; vypnut¡ reproduktoru

; ------ p©ednastaven˜ videom¢d

         mov       al,cs:[l_016D]           ; po‘adovan˜ videom¢d
         cmp       al,0FFh                  ; je implicitn¡ videom¢d ?
         jne       l_02BC                   ; nen¡ implicitn¡ videom¢d

; ------ aktu ln¡ videom¢d

         push      bp
         mov       ah,0Fh
         int       10h                      ; poskytnut¡ aktu ln¡ho videom¢du
         pop       bp

; ------ ur‡en¡ barev displeje a po‡tu znak– na © dek

l_02BC:  mov       byte ptr ds:[d_0004],0   ; pozice lev‚ho horn¡ho rohu okna
         mov       byte ptr ds:[d_0005],0   ; © dek lev‚ho horn¡ho rohu okna
         mov       byte ptr ds:[d_0009],0FFh; grafick˜ videom¢d neur‡en
         cmp       al,7                     ; je textov˜ videom¢d MDA ?
         mov       bh,80                    ; 80 znak– na © dek
         mov       bl,0                     ; p©¡znak ‡ernob¡l‚ho displeje
         mov       si,offset l_016F         ; barvy pro displej MDA
         je        l_02F6                   ; je videom¢d MDA
         mov       si,offset l_0177         ; barvy pro displej CGA barevn˜
         cmp       al,2                     ; je m¢d CGA ‡ernob¡l˜ ?
         je        l_02F3                   ; je m¢d CGA ‡ernob¡l˜
         cmp       al,4                     ; je textov˜ videom¢d CGA ?
         jb        l_02E3                   ; je textov˜ videom¢d CGA
         mov       al,3                     ; jinak barevn˜ videom¢d CGA
l_02E3:  mov       bl,0FFh                  ; p©¡znak barevn‚ho displeje
         cmp       al,3                     ; je textov˜ m¢d CGA barevn˜ ?
         je        l_02F6                   ; je textov˜ m¢d CGA barevn˜
         mov       bh,28h                   ; jinak 40 znak– na © dek
         cmp       al,1                     ; je textov˜ m¢d CGA barevn˜ ?
         je        l_02F6                   ; je textov˜ m¢d CGA barevn˜
         xor       al,al                    ; textov˜ m¢d
         mov       bl,0                     ; p©¡znak ‡ernob¡l‚ho displeje
l_02F3:  mov       si,offset l_0173         ; barvy pro CGA ‡ernob¡l˜
l_02F6:  mov       ds:[d_0006],al           ; aktu ln¡ videom¢d
         mov       ds:[d_0007],bl           ; p©¡znak barevn‚ho displeje
         mov       cs:[l_016A],bh           ; koncov  pozice okna

; ------ p©¡prava barev displeje

         mov       ax,cs:[si]               ; z kladn¡ a inverzn¡ barvy
         mov       word ptr ds:[d_0000],ax  ; z kladn¡ a inverzn¡ barvy
         mov       ax,cs:[si+2]             ; barva pop©ed¡ a pozad¡
         mov       word ptr ds:[d_0002],ax  ; barva pop©ed¡ a pozad¡

; ------ inicializace videom¢du

         push      bp
         mov       ah,0Fh
         int       10h                      ; poskytnut¡ aktu ln¡ho videom¢du
         cmp       al,ds:[d_0006]           ; je videom¢d ji‘ nastaven ?
         je        l_0321                   ; videom¢d je ji‘ nastaven
         mov       al,ds:[d_0006]           ; po‘adovan˜ videom¢d
         xor       ah,ah                    ; AH <- 0
         int       10h                      ; nastaven¡ po‘adovan‚ho videom¢du
l_0321:  pop       bp
         jmp       l_027D                   ; nastaven¡ z kladn¡ch barev
         ret

l_02AB   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru DX v oknˆ
; -----------------------------------------------------------------------------

l_0326   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         pushf     

         xchg      dl,dh                    ; z mˆna pozice a © dku
         add       dx,word ptr ds:[d_0004]  ; p©i‡ten¡ po‡ tku okna
         cmp       dh,cs:[l_016B]           ; p©ekro‡en maxim. © dek okna ?
         jae       l_0348                   ; p©ekro‡en konec displeje
         cmp       dl,cs:[l_016A]           ; p©ekro‡ena max. pozice okna ?
         jae       l_0348                   ; p©ekro‡en konec displeje
         mov       ah,2
         xor       bh,bh                    ; BH <- 0
         int       10h                      ; nastaven¡ pozice kurzoru

l_0348:  popf
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_0326   ENDP

l_0351:  jmp       l_0A81                   ; p©evod na velk‚ p¡smeno

; -----------------------------------------------------------------------------
;        ‡ten¡ pozice kurzoru v oknˆ -> AX
; -----------------------------------------------------------------------------

l_0354   PROC      NEAR

         call      l_0286                   ; ‡ten¡ pozice a velikosti kurzoru
         mov       al,dl                    ; pozice kurzoru na © dku
         sub       al,ds:[d_0004]           ; offset kurzoru v oknˆ
         inc       al                       ; korekce pozice (za‡¡n  od 1)
         xor       ah,ah                    ; AH <- 0
         ret

l_0354   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ © dku kurzoru v oknˆ -> AX
; -----------------------------------------------------------------------------

l_0362   PROC      NEAR

         call      l_0286                   ; ‡ten¡ pozice a velikosti kurzoru
         mov       al,dh                    ; © dek s kurzorem
         sub       al,ds:[d_0005]           ; offset kurzoru v oknˆ
         inc       al                       ; korekce © dku (za‡¡n  od 1)
         xor       ah,ah                    ; AH <- 0
         ret

l_0362   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ sou©adnic okna
; -----------------------------------------------------------------------------
; VSTUP: AX koncov˜ © dek okna
;        [SP+2] koncov  pozice okna
;        [SP+4] po‡ te‡n¡ © dek okna
;        [SP+6] po‡ te‡n¡ pozice okna
; -----------------------------------------------------------------------------

l_0370   PROC      NEAR

; ------ koncov˜ © dek okna

         pop       bx                       ; n vratov  adresa z procedury
         cmp       al,25                    ; kontrola maxim ln¡ho © dku okna
         ja        l_0379                   ; p©ekro‡en maxim ln¡ © dek okna
         mov       cs:[l_016b],al           ; nov˜ koncov˜ © dek okna

; ------ koncov  pozice okna

l_0379:  pop       ax                       ; koncov  pozice okna
         cmp       al,80                    ; kontrola maxim ln¡ pozice okna
         ja        l_0382                   ; p©ekro‡ena maxim ln¡ pozice okna
         mov       cs:[l_016a],al           ; nov  koncov  pozice okna

; ------ po‡ te‡n¡ © dek okna

l_0382:  pop       ax                       ; po‡ te‡n¡ © dek okna
         cmp       al,cs:[l_016b]           ; kontrola po‡ te‡n¡ho © dku okna
         jae       l_038F                   ; p©ekro‡en koncov˜ © dek okna
         dec       al                       ; oprava ‡¡sla © dku
         mov       ds:[d_0005],al           ; nov˜ po‡ te‡n¡ © dek okna

; ------ po‡ te‡n¡ pozice okna

l_038F:  pop       ax                       ; po‡ te‡n¡ pozice okna
         cmp       al,cs:[l_016A]           ; kontrola maxim ln¡ pozice okna
         jae       l_039C                   ; p©ekro‡ena koncov  pozice okna
         dec       al                       ; oprava ‡¡sla pozice
         mov       ds:[d_0004],al           ; nov  po‡ te‡n¡ pozice okna
l_039C:  jmp       bx                       ; n vrat z procedury

l_0370   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ barvy pop©ed¡ textu AL
; -----------------------------------------------------------------------------

l_039E   PROC      NEAR

         and       al,1Fh                   ; barva pop©ed¡ textu
         test      al,10h                   ; p©¡znak blikaj¡c¡ho textu
         jz        l_03A8                   ; nen¡ blikaj¡c¡ text
         and       al,0Fh                   ; zru¨en¡ blikaj¡c¡ho textu
         or        al,80h                   ; nastaven¡ p©¡znaku blik n¡
l_03A8:  and       byte ptr ds:[d_0008],70h ; ponech  barvu pozad¡
         or        ds:[d_0008],al           ; nastaven¡ nov‚ barvy pop©ed¡
         ret

l_039E   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ barvy pozad¡ textu AL
; -----------------------------------------------------------------------------

l_03B2   PROC      NEAR

         and       al,7                     ; barva pozad¡ textu
         mov       cl,4                     ; po‡et rotac¡
         shl       al,cl                    ; rotace barvy na pozici
         and       byte ptr ds:[d_0008],8Fh ; zru¨en¡ barvy pozad¡
         or        ds:[d_0008],al           ; nov  barva pozad¡
         ret

l_03B2   ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho m¢du (vstup AX=max. graf. pozice X)
; -----------------------------------------------------------------------------

l_03C2   PROC      NEAR

; ------ rozmˆry grafick‚ho okna

         push      bp
         mov       ds:[d_000C],ax           ; prav  sou©adnice graf. okna X
         mov       word ptr ds:[d_000A],0   ; lev  sou©adnice graf. okna X
         mov       word ptr ds:[d_000E],0   ; horn¡ sou©adnice graf. okna Y
         mov       word ptr ds:[d_0010],199 ; doln¡ sou©adnice graf. okna X

; ------ inicializace grafick‚ho videom¢du

         mov       al,ds:[d_0009]           ; po‘adovan˜ grafick˜ videom¢d
         xor       ah,ah
         int       10h                      ; inicializace grafick‚ho videom¢du

; ------ inicializace barvy pozad¡ CGA na ‡ernou

         xor       bx,bx                    ; BX <- 0
         mov       ds:[d_0020],bl           ; aktu ln¡ barva pozad¡ graf. m¢du
         mov       ah,0Bh
         int       10h                      ; nastaven¡ ‡ern‚ barvy pozad¡

; ------ inicializace palet CGA

         inc       bh                       ; funkce 1
         mov       ah,0Bh
         int       10h                      ; nastaven¡ palet CGA 0
         pop       bp
         ret

l_03C2   ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho m¢du 320x200 barevn˜
; -----------------------------------------------------------------------------

l_03F1   PROC      NEAR

         mov       byte ptr ds:[d_0009],4   ; grafick˜ m¢d 320x200 barevn˜
l_03F6:  mov       ax,319                   ; maxim ln¡ grafick  pozice X
         jmp       short l_03C2             ; inicializace grafick‚ho m¢du

l_03F1   ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho m¢du 320x200 ‡ernob¡l˜
; -----------------------------------------------------------------------------

l_03FB   PROC      NEAR

         mov       byte ptr ds:[d_0009],5   ; grafick˜ m¢d 320x200 ‡ernob¡l˜
         jmp       short l_03F6             ; inicializace grafick‚ho m¢du

l_03FB   ENDP

; -----------------------------------------------------------------------------
;        inicializace grafick‚ho m¢du 640x200
; -----------------------------------------------------------------------------

l_0402   PROC      NEAR

         mov       byte ptr ds:[d_0009],6   ; grafick˜ m¢d 640x200
         mov       ax,639                   ; maxim ln¡ grafick  pozice X
         call      l_03C2                   ; inicializace videom¢du
         mov       ax,15                    ; barva pop©ed¡ b¡l 
         jmp       short l_0458             ; inicializace barev displeje

l_0402   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ barvy pozad¡ AL (0 a‘ 15) grafick‚ho m¢du 320x200
; -----------------------------------------------------------------------------

l_0412   PROC      NEAR

         and       al,0Fh                   ; po‘adovan  barva pop©ed¡
         mov       ah,ds:[d_0020]           ; aktu ln¡ barva pozad¡ graf. m¢du
         and       ah,10h                   ; aktu ln¡ palety pop©ed¡
         or        al,ah
         mov       ds:[d_0020],al           ; nov‚ nastaven¡ barev pozad¡ g.m¢du

l_0420:  push      bp
         xor       bh,bh                    ; BH <- 0
         mov       bl,ds:[d_0020]           ; aktu ln¡ barva pozad¡ graf. m¢du
         mov       ah,0Bh
         int       10h                      ; nastaven¡ barev pozad¡ graf. m¢du
         pop       bp
         ret

l_0412   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ palet pop©ed¡ AL (0 a‘ 1) grafick‚ho m¢du 320x200
; -----------------------------------------------------------------------------

l_042D   PROC      NEAR

         push      bp
         mov       bl,ds:[d_0020]           ; aktu ln¡ barvy pozad¡ graf. m¢du
         and       bl,not 10h               ; zru¨en¡ nastaven‚ palety
         mov       ah,2                     ; po‡et palet pro barevn˜ m¢d
         cmp       byte ptr ds:[d_0009],4   ; je barevn˜ m¢d ?
         je        l_0440                   ; je barevn˜ m¢d
         mov       ah,1                     ; po‡et palet pro ‡ernob¡l˜ m¢d
l_0440:  cmp       al,ah                    ; p©ekro‡eno ‡¡slo palety ?
         jb        l_0449                   ; ‡¡slo palety je OK
         sub       al,ah                    ; korekce ‡¡sla palety
         or        bl,10h                   ;

l_0449:  mov       ds:[d_0020],bl           ; nov‚ palety pop©ed¡
         mov       bh,1
         mov       bl,al
         mov       ah,0Bh
         int       10h                      ; nastaven¡ palet barev
         pop       bp
         jmp       short l_0420             ; nastaven¡ barvy pozad¡

l_042D   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ barev a palet grafick‚ho m¢du
; -----------------------------------------------------------------------------

l_0458   PROC      NEAR

         push      bp
         mov       bx,ax
         mov       ah,0Bh
         int       10h                      ; nastaven¡ barev graf. m¢du
         pop       bp
         ret

l_0458   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ rozmˆr– okna v grafick‚m m¢du
; -----------------------------------------------------------------------------
; VSTUP: AX doln¡ sou©adnice Y
;        [SP+2] prav  sou©adnice X
;        [SP+4] horn¡ sou©adnice Y
;        [SP+6] lev  sou©adnice X
; -----------------------------------------------------------------------------

l_0461   PROC      NEAR

; ------ p©¡prava maxim ln¡ sou©adnice Y

         pop       bx                       ; n vratov  adresa z procedury
         mov       cx,639                   ; max. pozice X pro m¢d 640x200
         cmp       byte ptr ds:[d_0009],6   ; je grafick˜ m¢d 640x200 ?
         je        l_046F                   ; je grafick˜ m¢d 640x200
         mov       cx,319                   ; max. pozice X pro m¢d 320x200

; ------ doln¡ sou©adnice grafick‚ho okna Y

l_046F:  cmp       ax,199                   ; kontrola maxim ln¡ sou©adnice Y
         ja        l_0477                   ; maxim ln¡ sou©adnice Y p©ekro‡ena
         mov       ds:[d_0010],ax           ; doln¡ sou©adnice graf. okna Y

; ------ prav  sou©adnice grafick‚ho okna X

l_0477:  pop       ax                       ; prav  sou©adnice graf. okna X
         cmp       ax,cx                    ; kontrola maxim ln¡ sou©adnice X
         ja        l_047F                   ; maxim ln¡ sou©adnice X p©ekro‡ena
         mov       ds:[d_000C],ax           ; prav  sou©adnice graf. okna X

; ------ horn¡ sou©adnice grafick‚ho okna Y

l_047F:  pop       ax                       ; horn¡ sou©adnice graf. okna Y
         cmp       ax,ds:[d_0010]           ; kontrola horn¡ sou©adnice Y
         jae       l_0489                   ; koncov  sou©adnice Y p©ekro‡ena
         mov       ds:[d_000E],ax           ; horn¡ sou©adnice graf. okna Y

; ------ lev  sou©adnice grafick‚ho okna X

l_0489:  pop       ax                       ; lev  sou©adnice graf. okna X
         cmp       ax,ds:[d_000C]           ; kontrola lev‚ sou©adnice X
         jae       l_0493                   ; prav  sou©adnice X p©ekro‡ena
         mov       ds:[d_000A],ax           ; lev  sou©adnice graf. okna X
l_0493:  jmp       bx                       ; n vrat z procedury

l_0461   ENDP

; -----------------------------------------------------------------------------
;        z pis grafick‚ho bodu do grafick‚ho okna
; -----------------------------------------------------------------------------
; VSTUP: AL = barva bodu
;        [SP+2] sou©adnice Y
;        [SP+4] sou©adnice X
; -----------------------------------------------------------------------------

l_0495   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         pop       dx                       ; sou©adnice Y
         pop       cx                       ; sou©adnice X
         push      bx                       ; n vratov  adresa z procedury

         mov       ah,0Ch                   ; funkce zobrazen¡ bodu
l_049B:  or        cx,cx                    ; kontrola sou©adnice X
         js        l_04BB                   ; je z porn  - neplatn  sou©adnice X
         add       cx,ds:[d_000A]           ; p©i‡ten¡ po‡ te‡n¡ sou©adnice X
         cmp       cx,ds:[d_000C]           ; kontrola koncov‚ sou©adnice X
         ja        l_04BB                   ; p©ekro‡en konec okna X

         or        dx,dx                    ; kontrola sou©adnice Y
         js        l_04BB                   ; je z porn  - neplatn  sou©adnice Y
         add       dx,ds:[d_000E]           ; p©i‡ten¡ po‡ te‡n¡ sou©adnice Y
         cmp       dx,ds:[d_0010]           ; kontrola koncov‚ sou©adnice Y
         ja        l_04BB                   ; p©ekro‡en konec okna Y

         push      bp
         int       10h                      ; zobrazen¡ grafick‚ho bodu
         pop       bp

l_04BB:  ret

l_0495   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ ‡ ry v grafick‚m m¢du
; -----------------------------------------------------------------------------
; VSTUP: AL = barva bodu
;        [SP+2] koncov  sou©adnice Y
;        [SP+4] koncov  sou©adnice X
;        [SP+6] po‡ te‡n¡ sou©adnice Y
;        [SP+8] po‡ te‡n¡ sou©adnice X
; -----------------------------------------------------------------------------

l_04BC   PROC      NEAR

; ------ p©¡prava registr–

         mov       ah,0Ch                   ; funkce zobrazen¡ bodu
         mov       ds:[d_0014],ax           ; funkce 0Ch a barva graf. bodu
         pop       di                       ; n vratov  adresa z procedury
         pop       ax                       ; koncov  sou©adnice Y
         pop       dx                       ; koncov  sou©adnice X

; ------ parametry sou©adnice Y

         pop       bx                       ; po‡ te‡n¡ sou©adnice Y
         mov       ds:[d_001C],bx           ; ukazatel sou©adnice Y
         call      l_0560                   ; v˜po‡et p©¡rustku sou©adnice Y
         mov       ds:[d_0018],cx           ; p©¡rustek sou©adnice Y
         call      l_10B4                   ; absolutn¡ hodnota rozd¡lu AX
         xchg      ax,dx                    ; DX <- rozd¡l sou©adnic Y

; ------ parametry sou©adnice X

         pop       bx                       ; po‡ te‡n¡ sou©adnice X
         push      di                       ; n vratov  adresa z procedury
         mov       ds:[d_001A],bx           ; po‡ te‡n¡ sou©adnice X
         call      l_0560                   ; v˜po‡et p©¡rustku sou©adnice X
         mov       ds:[d_0016],cx           ; p©¡rustek sou©adnice X
         call      l_10B4                   ; absolutn¡ hodnota rozd¡lu AX
         mov       bx,ax                    ; BX <- rozd¡l sou©adnic X

; ------ p©¡prava parametr– pro strmˆj¨¡ smˆr X

         cmp       bx,dx                    ; je strmˆj¨¡ smˆr X ?
         jle       l_0525                   ; je strmˆj¨¡ smˆr Y
         mov       ax,dx                    ; AX <- rozd¡l sou©adnic Y
         add       ax,ax                    ; rozd¡l sou©adnic Y * 2
         sub       ax,bx                    ; ode‡ten¡ rozd¡lu sou©adnic X
         mov       ds:[d_001E],ax           ; konstanta pro p©¡rustek smˆru Y
         mov       cx,bx                    ; rozd¡l sou©adnic X (=‡¡ta‡ bod–)
         inc       cx                       ; po‡et bod– + 1

; ------ zobrazen¡ ‡ ry strm‚ ve smˆru X

l_04F6:  call      l_056C                   ; zobrazen¡ jednoho bodu
         mov       ax,ds:[d_001E]           ; konstanta pro p©¡rustek smˆry Y
         or        ax,ax                    ; je ‡¡slo z porn‚ ?
         jle       l_0514                   ; ‡¡slo je z porn‚
         add       ax,dx                    ; zv˜¨en¡ ukazatele sou©adnice Y
         add       ax,dx
         sub       ax,bx                    ; ode‡ten¡ sou©adnice X
         sub       ax,bx
         mov       ds:[d_001E],ax           ; nov˜ ‡¡ta‡ p©¡rustku Y
         mov       ax,ds:[d_0018]           ; p©¡rustek sou©adnice Y
         add       ds:[d_001C],ax           ; zv˜¨en¡ sou©adnice Y
         jmp       short l_051B

l_0514:  add       ax,dx                    ; zv˜¨en¡ p©¡rustku Y
         add       ax,dx
         mov       ds:[d_001E],ax           ; nov˜ p©¡rustek Y

l_051B:  mov       ax,ds:[d_0016]           ; p©¡rustek sou©adnice X
         add       ds:[d_001A],ax           ; zv˜¨en¡ sou©adnice X
         loop      l_04F6                   ; zobrazen¡ dal¨¡ho bodu
         ret

; ------ p©¡prava parametr– pro strmˆj¨¡ smˆr Y

l_0525:  mov       ax,bx                    ; AX <- rozd¡l sou©adnic X
         add       ax,ax                    ; rozd¡l sou©adnic X * 2
         sub       ax,dx                    ; ode‡ten¡ rozd¡lu sou©adnic Y
         mov       ds:[d_001E],ax           ; konstanta pro p©¡rustek smˆru X
         mov       cx,dx                    ; rozd¡l sou©adnic Y (=‡¡ta‡ bod–)
         inc       cx                       ; po‡et bod– + 1

; ------ zobrazen¡ ‡ ry strm‚ ve smˆru Y

l_0531:  call      l_056C                   ; zobrazen¡ jednoho bodu
         mov       ax,ds:[d_001E]           ; konstanta pro p©¡rustek Y
         or        ax,ax                    ; je ‡¡slo z porn‚ ?
         jle       l_054F                   ; ‡¡slo je z porn‚
         add       ax,bx                    ; zv˜¨en¡ ukazatele sou©adnice X
         add       ax,bx                    
         sub       ax,dx                    ; ode‡ten¡ sou©adnice Y
         sub       ax,dx                    
         mov       ds:[d_001E],ax           ; nov˜ ‡¡ta‡ p©¡rustku X
         mov       ax,ds:[d_0016]           ; p©¡rustek sou©adnice X
         add       ds:[d_001A],ax           ; zv˜¨en¡ sou©adnice X
         jmp       short l_0556

l_054F:  add       ax,bx                    ; zv˜¨en¡ p©¡rustku X
         add       ax,bx                    
         mov       ds:[d_001E],ax           ; nov˜ p©¡rustek X

l_0556:  mov       ax,ds:[d_0018]           ; p©¡rustek sou©adnice Y
         add       ds:[d_001C],ax           ; zv˜¨en¡ sou©adnice Y
         loop      l_0531                   ; zobrazen¡ dal¨¡ho bodu
         ret

l_04BC   ENDP

; -----------------------------------------------------------------------------
;        vypo‡ten¡ p©¡rustku sou©adnic pro zobrazen¡ ‡ ry
; -----------------------------------------------------------------------------
; VSTUP: AX = koncov  sou©adnice
;        BX = po‡ te‡n¡ sou©adnice
; VSTUP:CX = p©¡rustek
;        AX = rozd¡l sou©adnic
; -----------------------------------------------------------------------------

l_0560   PROC      NEAR

         xor       cx,cx                    ; CX <- 0 p©¡rustek
         sub       ax,bx                    ; rozd¡l sou©adnic
         jz        l_056B                   ; shoda sou©adnic - p©¡rustek = 0
         js        l_056A                   ; koncov  sou©adnice men‘¡ ne‘ po‡.
         inc       cx                       ; p©¡rustek kladn˜ (=1)
         ret
l_056A:  dec       cx                       ; p©¡rustek z porn˜ (=-1)
l_056B:  ret

l_0560   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ grafick‚ho bodu p©i zobrazen¡ ‡ ry
; -----------------------------------------------------------------------------

l_056C   PROC      NEAR

         push      cx
         push      dx
         mov       ax,ds:[d_0014]           ; po‘adovan  barva a funkce
         mov       cx,ds:[d_001A]           ; sou©adnice X
         mov       dx,ds:[d_001C]           ; sou©adnice Y
         call      l_049B                   ; zobrazen¡ grafick‚ho bodu
         pop       dx
         pop       cx
         ret

l_056C   ENDP

; -----------------------------------------------------------------------------
;        zvukov˜ v˜stup (zapnut¡ t¢nu o v˜¨ce AX)
; -----------------------------------------------------------------------------

l_057F   PROC      NEAR

         mov       bx,ax                    ; po‘adovan˜ t¢n
         mov       ax,34DDh                 ; dˆlic¡ konstanta LOW (1193181 Hz)
         mov       dx,12h                   ; dˆlic¡ konstanta HIGH (1193181 Hz)
         cmp       dx,bx                    ; je po‘adovan  frekvence OK ?
         jae       l_05A5                   ; frekvence je p©¡li¨ n¡zk 
         div       bx                       ; v˜po‡et dˆlic¡ konstanty
         mov       bx,ax                    ; dˆlic¡ konstanta dˆli‡ky
         in        al,61h
         test      al,3                     ; je zvukov˜ v˜stup ji‘ aktivn¡ ?
         jnz       l_059D                   ; zvukov˜ v˜stup je ji‘ aktivn¡
         or        al,3
         out       61h,al                   ; zapnut¡ zvukov‚ho v˜stupu
         mov       al,0B6h                  ; povel pro nastaven¡ dˆli‡ky
         out       43h,al                   ; povel pro nastaven¡ dˆli‡ky
l_059D:  mov       al,bl                    ; po‘adovan  konstanta LOW
         out       42h,al                   ; nastaven¡ dˆli‡ky LOW
         mov       al,bh                    ; po‘adovan  konstanta HIGH
         out       42h,al                   ; nastaven¡ dˆli‡ky
l_05A5:  ret

l_057F   ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ zvukov‚ho v˜stupu
; -----------------------------------------------------------------------------

l_05A6   PROC      NEAR

         in        al,61h
         and       al,0FCh                  ; nuluj¡ se bitu 0 a 1
         out       61h,al                   ; vypnut¡ zvukov‚ho v˜stupu
         ret

l_05A6   ENDP

; *****************************************************************************
;
;                   Obsluha spr vce pamˆti
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        P©idˆlen¡ nov‚ho pamˆŸov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: AX = po‘adovan  velikost pamˆŸov‚ho bloku (v bajtech)
;        [SP+2] (4) adresa ukazatele pamˆŸov‚ho bloku
; -----------------------------------------------------------------------------

l_05AD   PROC      NEAR

         xchg      ax,cx                    ; CX <- po‘adovan  velikost bloku
         pop       bx                       ; n vratov  adresa z procedury
         pop       di                       ; offset adresy ukazatele bloku
         jmp       short l_05DB             ; p©idˆlen¡ nov‚ho pamˆŸov‚ho bloku

l_05AD   ENDP

; -----------------------------------------------------------------------------
;        normalizace adresy BX:AX
; -----------------------------------------------------------------------------

l_05B2   PROC      NEAR

         push      ax
         push      cx
         mov       cl,4
         shr       ax,cl                    ; p©enos z offsetu do segmentu
         add       bx,ax                    ; p©i‡ten¡ offsetu k segmentu
         pop       cx
         pop       ax
         and       ax,0Fh                   ; normalizace offsetu
         ret

l_05B2   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ normovan˜ch adres BX:AX a DX:CX
; -----------------------------------------------------------------------------

l_05C0   PROC      NEAR

         cmp       bx,dx                    ; porovn n¡ segment–
         jne       l_05C6                   ; nen¡ shoda
         cmp       ax,cx                    ; porovn n¡ offset–
l_05C6:  ret

l_05C0   ENDP

; -----------------------------------------------------------------------------
;        sou‡et normovan˜ch adres BX:AX a DX:CX
; -----------------------------------------------------------------------------

l_05C7   PROC      NEAR

         add       ax,cx                    ; sou‡et offset–
         add       bx,dx                    ; sou‡et segment– adres
         jmp       short l_05B2             ; normalizace adresy BX:AX

l_05C7   ENDP

; -----------------------------------------------------------------------------
;        test, zda je posledn¡ pamˆŸov˜ blok (velikost bloku = 0)
; -----------------------------------------------------------------------------

l_05CD   PROC      NEAR

         mov       ax,es:[di+4]             ; velikost bloku (offset)
         mov       bx,es:[di+6]             ; velikost bloku (segment)
         push      ax
         or        ax,bx                    ; je velikost bloku = 0 ?
         pop       ax
         ret

l_05CD   ENDP

; -----------------------------------------------------------------------------
;        P©idˆlen¡ nov‚ho pamˆŸov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: CX = velikost po‘adovan‚ho bloku (bajt–)
;        DI = offset ukazatele adresy po‘adovan‚ho bloku
;        [SP+2] (2) segment ukazatele adresy po‘adovan‚ho bloku
; -----------------------------------------------------------------------------

l_05DA   PROC      NEAR

; ------ £schova adresy ukazatele bloku (sem se ulo‘¡ adresa nov‚ho bloku)

         pop       bx                       ; n vratov  adresa z procedury
l_05DB:  pop       es                       ; segment adresy
         push      bx                       ; n vratov  adresa z procedury
         mov       word ptr ds:[d_0026],di  ; offset adresy ukazatele bloku
         mov       word ptr ds:[d_0026+2],es; segment adresy ukazatele bloku

; ------ p©¡prava velikosti po‘adovan‚ho pamˆŸov‚ho bloku

         mov       ax,cx                    ; po‘adovan  velikost pamˆŸ. bloku
         add       ax,7                     ; bude zaokrouhlen¡ na 8 bajt–
         mov       bx,1000h                 ; segment velikosti p©i p©ete‡en¡
         jc        l_05F1                   ; je p©ete‡en¡ 64 KB
         xor       bx,bx                    ; segment velikosti <- 0
l_05F1:  and       al,not 7                 ; zarovn n¡ na 8 bajt–
         call      l_05B2                   ; normalizace adresy BX:AX
         mov       cx,ax                    ; po‘adovan  velikost LOW
         mov       dx,bx                    ; po‘adovan  velikost HIGH

; ------ p©¡prava adresy prvn¡ho pamˆŸov‚ho bloku

         mov       word ptr ds:[d_002E],offset d_0022 ; offset prvn¡ho bloku
         mov       word ptr ds:[d_002E+2],ds ; segment prvn¡ho bloku
         les       di,ds:[d_0022]           ; adresa prvn¡ho pamˆŸov‚ho bloku

; ------ nalezen¡ voln‚ho pamˆŸov‚ho bloku o dostate‡n‚ velikosti

l_0608:  call      l_05CD                   ; test, zda je posledn¡ pamˆŸ. blok
         jz        l_0632                   ; nalezen posledn¡ pamˆŸov˜ blok
         call      l_05C0                   ; porovn n¡ velikosti BX:AX a DX:CX
         jae       l_061F                   ; pamˆŸov˜ blok je dostate‡nˆ velk˜
         mov       word ptr ds:[d_002E],di  ; £schova adresy posledn¡ho bloku
         mov       word ptr ds:[d_002E+2],es; segment adresy posledn¡ho bloku
         les       di,dword ptr es:[di]     ; adresa dal¨¡ho pamˆŸov‚ho bloku
         jmp       short l_0608             ; test dal¨¡ho pamˆŸov‚ho bloku

; ------ nalezen dost velk˜ pamˆŸov˜ blok - ulo‘en¡ jeho adresy

l_061F:  call      l_0695                   ; ulo‘en¡ adresy bloku do ukazatele
         je        l_062D                   ; velikost bloku je nezmˆnˆna
         sub       ax,cx                    ; v˜po‡et zbyl‚ velikosti bloku
         sbb       bx,dx
         and       ax,0Fh                   ; normalizace offsetu velikosti
         jmp       short l_0663             ; zmen¨en¡ voln‚ho bloku
l_062D:  les       di,dword ptr es:[di]     ; adresa dal¨¡ho pamˆŸov‚ho bloku
         jmp       short l_0686             ; ulo‘en¡ odkazu na dal¨¡ blok

; ------ nalezen posledn¡ pamˆŸov˜ blok - v˜po‡et nov‚ho konce voln‚ pamˆti

l_0632:  call      l_0695                   ; ulo‘en¡ adresy bloku do ukazatele
         mov       ax,di                    ; offset nalezen‚ho pamˆŸov‚ho bloku
         mov       bx,es                    ; segment nalezen‚ho pamˆŸ. bloku
         call      l_05C7                   ; sou‡et adres BX:AX a DX:CX
         mov       word ptr ds:[d_018A],ax  ; offset nov‚ho konce pou‘it‚ pamˆti
         mov       word ptr ds:[d_018A+2],bx ; segment za‡ tku voln‚ pamˆti

; ------ kontrola, zda je p©ete‡en¡ pamˆti (zda se dos hne z sobn¡ku)

         push      cx
         push      dx
         mov       cx,ax                    ; offset nov‚ho konce pamˆti
         mov       dx,bx
         mov       ax,sp                    ; offset ukazatele z sobn¡ku
         mov       bx,ss                    ; segment ukazatele z sobn¡ku
         sub       bx,0Eh                   ; rezerva 224 bajt– pro z sobn¡k
         call      l_05B2                   ; normalizace adresy BX:AX
         xor       ax,ax                    ; zarovn n¡ na odstavec smˆrem dol–
         call      l_05C0                   ; porovn n¡ adres BX:AX a DX:CX
         pop       dx
         pop       cx
         ja        l_065F                   ; konec pamˆti je OK
         jmp       l_0FCC                   ; chyba - p©ete‡en¡ pamˆti

; ------ nastaven¡ ukazatel– nov‚ho pamˆŸov‚ho bloku

l_065F:  xor       ax,ax                    ; AX <- 0 p©¡znak posledn¡ho bloku
         xor       bx,bx                    ; BX <- 0
l_0663:  push      bx                       ; velikost dal¨¡ho bloku HIGH
         push      ax                       ; velikost dal¨¡ho voln‚ho bloku LOW
         push      word ptr es:[di+2]       ; segment adresy dal¨¡ho pamˆŸ.bloku
         push      word ptr es:[di]         ; offset adresy dal¨¡ho pamˆŸ. bloku
         mov       ax,di                    ; offset tohoto pamˆŸ. bloku
         mov       bx,es                    ; segment tohoto pamˆŸ. bloku
         call      l_05C7                   ; p©i‡ten¡ velikosti bloku k adrese
         mov       di,ax                    ; offset adresy dal¨¡ho pamˆŸ. bloku
         mov       es,bx                    ; segment adresy dal¨¡ho pamˆŸ.bloku
         pop       word ptr es:[di]         ; offset dal¨¡ho voln‚ho bloku
         pop       word ptr es:[di+2]       ; segment dal¨¡ho voln‚ho bloku
         pop       word ptr es:[di+4]       ; velikost nov‚ho bloku LOW
         pop       word ptr es:[di+6]       ; velikost nov‚ho bloku HIGH

; ------ ulo‘en¡ odkazu na dal¨¡ blok do p©edposledn¡ho bloku

l_0686:  push      es
         push      es
         les       si,dword ptr ds:[d_002E] ; adresa minul‚ho pamˆŸ. bloku
         mov       es:[si],di
         pop       word ptr es:[si+2]
         pop       es
         ret

l_05DA   ENDP

; -----------------------------------------------------------------------------
;        Ulo‘en¡ adresy nalezen‚ho pamˆŸov‚ho bloku do ukazatele pamˆt. bloku
; -----------------------------------------------------------------------------

l_0695   PROC      NEAR

         push      es
         push      es
         les       si,dword ptr ds:[d_0026] ; adresa ukazatele pamˆŸov‚ho bloku
         mov       es:[si],di               ; ulo‘en¡ adresy pamˆŸov‚ho bloku
         pop       word ptr es:[si+2]       ; segment adresy pamˆŸov‚ho bloku
         pop       es
         ret

l_0695   ENDP

; -----------------------------------------------------------------------------
;        uvolnˆn¡ pamˆŸov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: AX=p–vodn¡ velikost pamˆŸov‚ho bloku
;        [SP+2] (4) adresa ukazatele adresy bloku
; -----------------------------------------------------------------------------

l_06A4   PROC      NEAR

         xchg      ax,cx
         pop       bx
         pop       di
         jmp       short l_06AA

l_06A4   ENDP

; -----------------------------------------------------------------------------
;        uvolnˆn¡ pamˆŸov‚ho bloku
; -----------------------------------------------------------------------------
; VSTUP: CX=p–vodn¡ velikost pamˆŸov‚ho bloku
;        DI=offset ukazatele adresy bloku
;        [SP+2] (2) segment ukazatele adresy bloku
; -----------------------------------------------------------------------------

l_06A9   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
l_06AA:  pop       es
         push      bx

; ------ p©¡prava p–vodn¡ velikosti bloku

         mov       ax,cx                    ; p–vodn¡ velikost bloku
         mov       cx,es:[di]               ; adresa pamˆŸov‚ho bloku k uvolnˆn¡
         mov       dx,es:[di+2]
         add       ax,7                     ; bude zarovn n¡ na 8 bajt–
         mov       bx,1000h                 ; p©enos - 64 KB
         jc        l_06BF                   ; je p©enos
         xor       bx,bx                    ; nen¡ p©enos
l_06BF:  and       al,not 7                 ; zarovn n¡ na 8 bajt–
         call      l_05B2                   ; normalizace adresy BX:AX
         mov       word ptr ds:[d_002A],ax  ; £schova p–vodn¡ velikosti bloku
         mov       word ptr ds:[d_002A+2],bx; uschovan  p–vodn¡ velikost bloku

; ------ test, zda je uvol¤ovan˜ blok pod za‡ tkem prvn¡ho voln‚ho bloku

         les       di,ds:[d_0022]           ; adresa prvn¡ho pamˆŸov‚ho bloku
         mov       ax,di                    ; adresa prvn¡ho pamˆŸov‚ho bloku
         mov       bx,es
         call      l_05C0                   ; porovn n¡ adres BX:AX a DX:CX
         jae       l_072F                   ; voln  pamˆŸ

; ------ nalezen¡ pamˆŸov‚ho bloku ukazuj¡c¡ho nad uvol¤ovan˜ blok

l_06D8:  mov       ax,es:[di]               ; adresa dal¨¡ho voln‚ho bloku
         mov       bx,es:[di+2]
         call      l_05C0                   ; porovn n¡ adres BX:AX a DX:CX
         jae       l_06EA                   ; tento blok vyhovuje OK
         mov       di,ax                    ; adresa dal¨¡ho bloku
         mov       es,bx
         jmp       short l_06D8

; ------ za©azen¡ uvol¤ovan‚ho bloku do ©etˆzce voln˜ch blok–

l_06EA:  push      es
         mov       si,cx                    ; adresa uvol¤ovan‚ho bloku
         mov       es,dx
         push      word ptr ds:[d_002A+2]   ; uschovan  p–vodn¡ velikost bloku
         push      word ptr ds:[d_002A]     ; uschovan  p–vodn¡ velikost bloku
         mov       es:[si],ax               ; adresa dal¨¡ho bloku
         mov       es:[si+2],bx
         pop       word ptr es:[si+4]       ; velikost nov‚ho voln‚ho bloku
         pop       word ptr es:[si+6]
         pop       es
         mov       es:[di],cx               ; adresa na tento blok do p©ede¨l‚ho
         mov       es:[di+2],dx

; ------ p©ipojen¡ p©ede¨l‚ho bloku k nov‚mu bloku

         mov       ax,es:[di+4]             ; velikost p©ede¨l‚ho bloku
         mov       bx,es:[di+6]
         call      l_0755                   ; p©ipojen¡ p©ede¨l‚ho pamˆŸ. bloku
         jz        l_071E                   ; bloky byly spojeny OK
         les       di,dword ptr es:[di]     ; adresa tohoto bloku

; ------ parametry aktu ln¡ho bloku

l_071E:  mov       ax,es:[di+4]             ; velikost bloku
         mov       bx,es:[di+6]
         mov       cx,es:[di]               ; adresa bloku
         mov       dx,es:[di+2]
         jmp       short l_0755             ; p©ipojen¡ n sleduj¡c¡ho bloku

; ------ uvol¤ovan˜ pamˆŸov˜ blok je prvn¡m voln˜m blokem
;        nastaven¡ adresy dal¨¡ho bloku do nov‚ho bloku

l_072F:  mov       word ptr ds:[d_0022],cx  ; nov˜ blok je prvn¡m voln˜m blokem
         mov       word ptr ds:[d_0022+2],dx
         mov       di,cx                    ; adresa nov‚ho bloku
         mov       es,dx
         mov       es:[di],ax               ; nastaven¡ adresy dal¨¡ho bloku
         mov       es:[di+2],bx

; ------ nastaven¡ velikosti nov‚ho bloku

         mov       cx,ax                    ; adresa dal¨¡ho bloku
         mov       dx,bx
         mov       ax,word ptr ds:[d_002A]  ; uschovan  p–vodn¡ velikost bloku
         mov       bx,word ptr ds:[d_002A+2]; uschovan  p–vodn¡ velikost bloku
         mov       es:[di+4],ax             ; nastaven¡ velikosti nov‚ho bloku
         mov       es:[di+6],bx
                                            ; n sleduje p©ipojen¡ dal¨¡ho bloku

; -----------------------------------------------------------------------------
;        spojen¡ dvou pamˆŸov˜ch blok– (ES:DI/vel.BX:AX a DX:CX) (ZY=spojeny)
; -----------------------------------------------------------------------------

; ------ test, zda bloky na sebe tˆsnˆ navazuj¡

l_0755:  mov       word ptr ds:[d_0032],ax  ; velikost prvn¡ho bloku
         mov       word ptr ds:[d_0032+2],bx
         add       ax,di                    ; konec prvn¡ho bloku
         mov       bx,es
         add       bx,word ptr ds:[d_0032+2]
         call      l_05B2                   ; normalizace adresy BX:AX
         call      l_05C0                   ; porovn n¡ adres BX:AX a DX:CX
         jne       l_07BD                   ; bloky na sebe nenavazuj¡

; ------ test, zda je druh˜ blok posledn¡m voln˜m blokem v pamˆti

         mov       ax,word ptr ds:[d_018A]  ; adresa za‡ tku voln‚ pamˆti
         mov       bx,word ptr ds:[d_018A+2]; adresa za‡ tku voln‚ pamˆti
         call      l_05C0                   ; porovn n¡ adres BX:AX a DX:CX
         je        l_07A9                   ; je to posledn¡ voln˜ blok v pamˆti

; ------ p©enesen¡ adresy n sleduj¡c¡ho bloku z druh‚ho do prvn¡ho bloku

         push      es
         mov       si,cx                    ; adresa druh‚ho bloku
         mov       es,dx
         mov       ax,es:[si]               ; adresa dal¨¡ho voln‚ho bloku
         mov       bx,es:[si+2]
         mov       cx,es:[si+4]             ; velikost druh‚ho bloku
         mov       dx,es:[si+6]
         pop       es
         mov       es:[di],ax               ; adresa dal¨¡ho bloku do prvn¡ho
         mov       es:[di+2],bx

; ------ p©i‡ten¡ velikosti druh‚ho bloku k velikosti prvn¡ho bloku

         mov       ax,word ptr ds:[d_0032]  ; velikost prvn¡ho bloku
         mov       bx,word ptr ds:[d_0032+2]
         call      l_05C7                   ; sou‡et adres BX:AX a DX:CX
         mov       es:[di+4],ax             ; nov  velikost prvn¡ho bloku
         mov       es:[di+6],bx
         xor       ax,ax                    ; p©¡znak spojen¡ blok–
         ret

; ------ ozna‡en¡ prvn¡ho bloku jako posledn¡ blok (nulov n¡ ukazatel–)

l_07A9:  mov       word ptr ds:[d_018A],di  ; adresa za‡ tku voln‚ pamˆti
         mov       word ptr ds:[d_018A+2],es; adresa za‡ tku voln‚ pamˆti
         push      di
         xor       ax,ax                    ; AX <- 0
         cld       
         mov       cx,4
         rep       stosw                    ; vynulov n¡ ukazatel– bloku
         pop       di
         xor       ax,ax                    ; p©¡znak spojen¡ blok–
l_07BD:  ret

l_06A9   ENDP

; -----------------------------------------------------------------------------
;        se‡ten¡ velikosti zbyl‚ voln‚ pamˆti (-> AX v odstavc¡ch)
; -----------------------------------------------------------------------------

l_07BE   PROC      NEAR

         xor       cx,cx                    ; st©ada‡ voln‚ pamˆti
         xor       dx,dx
         xor       si,si                    ; st©ada‡ nejvˆt¨¡ho nalez. bloku
         les       di,ds:[d_0022]           ; adresa prvn¡ho pamˆŸov‚ho bloku

; ------ sou‡et velikost¡ v¨ech blok–

l_07C8:  call      l_05CD                   ; test, zda je posledn¡ pamˆŸ. blok
         jz        l_07D5                   ; je posledn¡ pamˆŸov˜ blok
         call      l_07ED                   ; p©i‡ten¡ velikosti bloku
         les       di,dword ptr es:[di]     ; adresa dal¨¡ho bloku
         jmp       short l_07C8             ; test dal¨¡ho bloku

; ------ p©i‡ten¡ velikosti voln‚ pamˆti do konce pamˆti

l_07D5:  mov       ax,sp
         mov       bx,ss
         sub       bx,10h
         call      l_05B2                   ; normalizace adresy BX:AX
         xor       ax,ax
         sub       bx,word ptr ds:[d_018A+2]; adresa za‡ tku voln‚ pamˆti
         jc        l_07EA
         call      l_07ED                   ; p©i‡ten¡ velikosti zbytku pamˆti
l_07EA:  mov       ax,dx
         ret

l_07BE   ENDP

; -----------------------------------------------------------------------------
;        p©i‡ten¡ velikosti bloku
; -----------------------------------------------------------------------------

l_07ED   PROC      NEAR

         cmp       si,bx
         jae       l_07F3
         mov       si,bx
l_07F3:  call      l_05C7                   ; sou‡et adres BX:AX a DX:CX
         mov       cx,ax
         mov       dx,bx
         ret

l_07ED   ENDP

; -----------------------------------------------------------------------------
;        stanoven¡ velikosti nejvˆt¨¡ho voln‚ho bloku pamˆti
; -----------------------------------------------------------------------------

l_07FB   PROC      NEAR

         call      l_07BE                   ; sou‡et velikosti voln‚ pamˆti
         mov       ax,si                    ; velikost nejvˆt¨¡ho pamˆŸ. bloku
         ret

l_07FB   ENDP

; -----------------------------------------------------------------------------
;        adresa za‡ tku voln‚ pamˆti
; -----------------------------------------------------------------------------

l_0801   PROC      NEAR

         pop       bx
         pop       es
         mov       ax,word ptr ds:[d_018A]  ; adresa za‡ tku voln‚ pamˆti
         mov       es:[di],ax
         mov       dx,word ptr ds:[d_018A+2]; adresa za‡ tku voln‚ pamˆti
         mov       es:[di+2],dx
         jmp       bx

l_0801   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ za‡ tku voln‚ pamˆti na zadanou adresu
; -----------------------------------------------------------------------------

l_0813   PROC      NEAR

         pop       bx
         pop       es
         les       di,dword ptr es:[di]     ; zadan  adresa za‡ tku pamˆti
         mov       word ptr ds:[d_018A],di  ; adresa za‡ tku voln‚ pamˆti
         mov       word ptr ds:[d_0022],di
         mov       word ptr ds:[d_018A+2],es; adresa za‡ tku voln‚ pamˆti
         mov       word ptr ds:[d_0022+2],es
         xor       ax,ax
         les       di,ds:[d_0022]           ; adresa prvn¡ho voln‚ho bloku
         mov       cx,4
         cld       
         rep       stosw
         jmp       bx

l_0813   ENDP

; *****************************************************************************
;
;                   Obsluha kl vesnice
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        test p©ipravenosti znaku z kl vesnice (AX=1 je p©ipraven)
;        (ze z sobn¡ku nutno zru¨it 1 bajt !)
; -----------------------------------------------------------------------------

l_0836   PROC      NEAR

         cmp       byte ptr ds:[d_0192],0   ; je v bufferu uschov n znak ?
         mov       al,0FFh                  ; p©¡znak - je znak
         jne       l_0849                   ; v bufferu je p©ipraven znak
         mov       ah,1
         int       16h                      ; test znaku z kl vesnice
         mov       al,0                     ; p©¡znak - nen¡ znak
         jz        l_0849                   ; nen¡ p©ipraven znak z kl vesnice
         dec       al                       ; p©¡znak - je znak
l_0849:  and       ax,1                     ; p©¡znak znaku z kl vesnice
         ret       1                        ; n vrat se zru¨en¡m 1 bajtu

l_0836   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice -> AX
; -----------------------------------------------------------------------------

l_084F   PROC      NEAR

         mov       al,byte ptr ds:[d_0192]  ; znak z bufferu kl vesnice
         mov       byte ptr ds:[d_0192],0   ; zru¨en¡ znaku v bufferu kl vesnice
         or        al,al                    ; byl v bufferu znak ?
         jnz       l_087D                   ; v bufferu byl p©ipraven znak
         xor       ah,ah                    ; AH <- 0
         int       16h                      ; vstup znaku z kl vesnice
         or        al,al                    ; je to ©¡dic¡ kl vesa ?
         jnz       l_086F                   ; nen¡ to ©¡dic¡ kl vesa
         mov       byte ptr ds:[d_0192],ah  ; £schova k¢du kl vesy
         mov       al,1Bh                   ; p©¡znak ©¡dic¡ kl vesy ESC
         or        ah,ah                    ; je kl vesa Ctrl-Break ?
         jnz       l_087D                   ; nen¡ kl vesa Ctrl-Break
         mov       al,3                     ; n hradn¡ k¢d Ctrl-C
l_086F:  cmp       byte ptr ds:[d_0194],1   ; je povolena obsluha Ctrl-C ?
         jne       l_087D                   ; nen¡ povolena obsluha Ctrl-C
         cmp       al,3                     ; byla kl vesa Ctrl-C ?
         jne       l_087D                   ; nebyla kl vesa Ctrl-C
         jmp       l_0FF7                   ; p©eru¨en¡ Ctrl-C
l_087D:  xor       ah,ah                    ; AH <- 0
         ret       1                        ; n vrat se zru¨en¡m 1 bajtu

l_084F   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku na displej do textov‚ho okna
; -----------------------------------------------------------------------------

l_0882   PROC      NEAR

; ------ p©¡prava registr–

         pop       ax                       ; n vratov  adresa zprocedury
         pop       dx                       ; znak k v˜stupu
         push      ax                       ; n vratov  adresa z procedury
         push      dx                       ; znak k v˜stupu
         push      bp                       ; £schova BP
         push      dx                       ; £schova DX
         call      l_0286                   ; ‡ten¡ pozice a velikosti kurzoru
         pop       ax                       ; znak k v˜stupu

; ------ znak CR

         cmp       al,0Dh                   ; je znak CR ?
         jne       l_0896                   ; nen¡ znak CR
         mov       dl,ds:[d_0004]           ; po‡ te‡n¡ pozice okna
         jmp       short l_08FE

; ------ znak LF

l_0896:  cmp       al,0Ah                   ; je znak LF ?
         jne       l_08A5                   ; nen¡ znak LF
         inc       dh                       ; zv˜¨en¡ ukazatele © dku
         cmp       dh,byte ptr cs:[l_016B]  ; koncov˜ © dek okna
         jb        l_08FE                   ; © dek je OK
         jmp       short l_08E4             ; rolov n¡ okna o © dek

; ------ znak BS

l_08A5:  cmp       al,8                     ; je znak BS ?
         jne       l_08B3                   ; nen¡ znak BS
         cmp       dl,ds:[d_0004]           ; je dosa‘eno po‡ tku okna ?
         je        l_08FE                   ; je dosa‘eno po‡ tku okna
         dec       dl                       ; sn¡‘en¡ pozice kurzoru
         jmp       short l_08FE

; ------ znak BEL

l_08B3:  cmp       al,7                     ; je znak BEL
         jne       l_08BF                   ; nen¡ znak BEL
         mov       ah,0Eh
         xor       bh,bh                    ; BH <- 0
         int       10h                      ; p¡pnut¡ (znak BEL)
         jmp       short l_0904

; ------ zobrazen¡ platn‚ho znaku

l_08BF:  push      dx
         mov       ah,9
         xor       bh,bh                    ; BH <- 0
         mov       cx,1                     ; 1 znak k zobrazen¡
         mov       bl,ds:[d_0008]           ; aktu ln¡ barva
         int       10h                      ; zobrazen¡ znaku AL
         pop       dx

; ------ zv˜¨en¡ ukazatele pozice na © dku

         inc       dl                       ; zv˜¨en¡ pozice na © dku
         cmp       dl,cs:[l_016A]           ; dosa‘ena maxim ln¡ pozice okna ?
         jb        l_08FE                   ; nen¡ maxim ln¡ pozice okna
         mov       dl,ds:[d_0004]           ; po‡ te‡n¡ pozice okna
         inc       dh                       ; zv˜¨en¡ © dku v oknˆ
         cmp       dh,byte ptr cs:[l_016B]  ; dosa‘en koncov˜ © dek okna ?
         jb        l_08FE                   ; © dek je OK

; ------ rolov n¡ okna o © dek nahoru

l_08E4:  dec       dh                       ; n vrat © dku v oknˆ
         push      dx
         mov       ax,601h                  ; funkce rolov n¡ o 1 © dek
         mov       bh,ds:[d_0008]           ; aktu ln¡ barva
         mov       cx,word ptr ds:[d_0004]  ; sou©adnice lev‚ho horn¡ho rohu
         mov       dx,word ptr cs:[l_016A]  ; maxim ln¡ pozice a © dek okna
         dec       dh                       ; korekce maxim ln¡ho © dku
         dec       dl                       ; korekce maxim ln¡ pozice
         int       10h                      ; rolov n¡ okna o © dek nahoru
         pop       dx

; ------ nastaven¡ nov‚ pozice kurzoru

l_08FE:  mov       ah,2
         xor       bh,bh                    ; BH <- str nka 0
         int       10h                      ; nastaven¡ nov‚ pozice kurzoru

; ------ obsluha kl vesy Ctrl-S (zastaven¡ v˜pisu textu)

l_0904:  pop       bp
         cmp       byte ptr ds:[d_0194],1   ; je povolena obsluha Ctrl-C ?
         jne       l_091E                   ; nen¡ povolena obsluha Ctrl-C


         dec       sp
         call      l_0836                   ; test p©ipravenosti znaku z kl ves.
         jz        l_091E                   ; nen¡ znak z kl vesnice
         dec       sp
         call      l_084F                   ; vstup znaku z kl vesnice
         cmp       al,13h                   ; je kl vesa Ctrl-S ?
         jne       l_091E                   ; nen¡ kl vesa Ctrl-S
         dec       sp
         call      l_084F                   ; ‡ek n¡ na dal¨¡ znak z kl vesnice
l_091E:  pop       ax
         ret

l_0882   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku DL na tisk rnu
; -----------------------------------------------------------------------------

l_0920   PROC      NEAR

         pop       ax                       ; n vratov  adresa z procedury
         pop       dx                       ; znak k v˜stupu na tisk rnu
         push      ax                       ; n vratov  adresa z procedury
         mov       ah,5                     ; funkce v˜stupu na tisk rnu
         jmp       short l_093A             ; vol n¡ slu‘by DOS AH (soubory)
         nop       

l_0920   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku DL na p©¡davn‚ za©¡zen¡ AUX
; -----------------------------------------------------------------------------

l_0928   PROC      NEAR

         pop       ax                       ; n vratov  adresa z procedury
         pop       dx                       ; znak k v˜stupu
         push      ax                       ; n vratov  adresa z procedury
         mov       ah,4                     ; funkce v˜stupu na p©¡davn‚ za©¡z.
         jmp       short l_093A             ; vol n¡ slu‘by DOS AH (soubory)
         nop

l_0928   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z p©¡davn‚ho za©¡zen¡
; -----------------------------------------------------------------------------

l_0930   PROC      NEAR

         mov       ah,3                     ; funkce vstupu z p©¡davn‚ho za©¡z.
         call      l_093a                   ; vol n¡ slu‘by DOS AH (soubory)
         xor       ah,ah                    ; AH <- 0
         ret       1

l_0930   ENDP

; -----------------------------------------------------------------------------
;        vol n¡ slu‘by DOS AH (soubory)
; -----------------------------------------------------------------------------

l_093A   PROC      NEAR

; ------ vol n¡ slu‘by DOS

         cmp       ah,3Dh
         je        l_0953                   ; otev©en¡ souboru
         cmp       ah,3Ch
         je        l_0953                   ; vytvo©en¡ souboru
         cmp       ah,3Eh
         je        l_097B                   ; uzav©en¡ souboru
         cmp       ah,80h
         je        l_0995                   ; uzav©en¡ v¨ech soubor–
l_094E:  push      bp
         int       21h                      ; vol n¡ slu‘by DOS
         pop       bp
         ret

; ------ otev©en¡ souboru

l_0953:  push      si
         push      cx
         mov       si,ds:[d_017A]           ; ukazatel tabulky soubor–
         mov       cx,ds:[d_017C]           ; po‡et polo‘ek v tabulce
l_095D:  cmp       word ptr [si],0          ; nalezena voln  polo‘ka ?
         je        l_096D                   ; nalezena voln  polo‘ka OK
         inc       si
         inc       si
         loop      l_095D                   ; test dal¨¡ polo‘ky
         pop       cx
         pop       si
         mov       ax,4                     ; chyba - nen¡ voln˜ identifik tor
         stc       
         ret

l_096D:  pop       cx
         push      ds
         push      es
         pop       ds
         call      l_094E                   ; otev©en¡ souboru
         pop       ds
         jc        l_0979                   ; chyba otev©en¡
         mov       [si],ax                  ; £schova identifik toru souboru
l_0979:  pop       si
         ret

; ------ uzav©en¡ souboru

l_097B:  push      cx
         push      si
         mov       si,ds:[d_017A]           ; tabulka identifik tor–
         mov       cx,ds:[d_017C]           ; po‡et polo‘ek v tabulce
l_0985:  cmp       [si],bx                  ; nalezena polo‘ka ?
         jne       l_098D                   ; polo‘ka nenalezena
         mov       word ptr [si],0          ; ozna‡en¡ polo‘ky za zru¨enou
l_098D:  inc       si
         inc       si
         loop      l_0985                   ; dal¨¡ polo‘ka
         pop       si
         pop       cx
         jmp       short l_094E             ; uzav©en¡ souboru

; ------ uzav©en¡ v¨ech soubor–

l_0995:  mov       si,ds:[d_017A]           ; tabulka identifik tor–
         mov       cx,ds:[d_017C]           ; po‡et polo‘ek v tabulce
l_099D:  mov       bx,[si]                  ; identifik tor souboru
         or        bx,bx                    ; je platn˜ identifik tor
         jz        l_09AC                   ; nen¡ identifik tor
         mov       ah,3Eh
         call      l_094E                   ; uzav©en¡ souboru
         mov       word ptr [si],0          ; zru¨en¡ polo‘ky v tabulce
l_09AC:  inc       si
         inc       si
         loop      l_099D                   ; dal¨¡ polo‘ka v tabulce
         ret

l_093A   ENDP

; -----------------------------------------------------------------------------
;        inicializace modulu obsluhy DOS (CX=po‡et identifik. soubor–)
; -----------------------------------------------------------------------------

l_09B1   PROC      NEAR

; ------ nulov n¡ tabulky identifik tor– soubor–

         xor       ax,ax                    ; AX <- 0
l_09b3:  mov       ds:[d_0172],ax           ; p©¡znak chodu programu
         mov       di,offset d_0240         ; tabulka identifik tor– soubor–
         mov       ds:[d_017A],di           ; adresa tabulky ident. soubor–
         mov       ds:[d_017C],cx           ; po‡et polo‘ek v tab. ident.soub.
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
         push      ds
         pop       es                       ; ES <- datov˜ segment
         cld       
         rep       stosw                    ; vymaz n¡ tabulky identifik tor–

; ------ inicializace adresy INT 23h

         mov       es,ax                    ; ES <- 0
         mov       word ptr es:[4*23h],offset l_0A43 ; adresa obsluhy INT 23h
         mov       es:[4*23h+2],cs

; ------ cejchov n¡ konstanty ‡asova‡e

         call      l_0195                   ; cejchov n¡ ‡asov‚ prodlevy

; ------ inicializace tabulky adres obsluh funkc¡ z kladn¡ho modulu

l_09D9:  mov       si,offset l_0A07         ; vzorov  tabulka adres
         mov       di,offset d_0136         ; tabulka adres
         push      ds
         pop       es                       ; ES <- datov˜ segment
         push      cs
         pop       ds                       ; DS <- CS
         mov       cx,offset(l_0A070-l_0A07)/2 ; d‚lka tabulky (ve slovech)
         cld
         rep       movsw                    ; p©enos tabulky adres
         push      es
         pop       ds                       ; n vrat DS

; ------ inicializace z kladn¡ch ukazatel–

         xor       ax,ax                    ; AX <- 0
         mov       ds:[d_0192],ax           ; buffer pro £schovu znaku z kl ves.
         mov       ds:[d_0180],al           ; n vrat k¢d chyby disk. operace
         mov       ds:[d_0194],al           ; nen¡ povolena obsluha Ctrl-C
         mov       ds:[d_0182],ax
         mov       ds:[d_0184],ax
         mov       byte ptr ds:[d_0181],7Eh
         mov       byte ptr ds:[d_0036],0Dh
         ret

l_09B1   ENDP

; -----------------------------------------------------------------------------
;        tabulka adres obsluh funkc¡ z kladn¡ho programov‚ho modulu
; -----------------------------------------------------------------------------

l_0A07   label     word

         dw        l_0836                   ; test p©ipravenosti znaku z kl ves.
         dw        l_084f                   ; vstup znaku z kl vesnice -> AX
         dw        l_0882                   ; v˜stup znaku DL na displej do okna
         dw        l_0920                   ; v˜stup znaku DL na tisk rnu
         dw        l_0928                   ; v˜stup znaku DL na za©¡zen¡ AUX
         dw        l_0930                   ; vstup znaku ze za©¡zen¡ AUX
         dw        l_0882                   ; v˜stup znaku DL na displej do okna
         dw        l_084f                   ; vstup znaku z kl vesnice -> AX

         dw        -1
         db        0c1h
         db        0

         dw        -1
         db        82h
         db        0

         dw        -1
         db        43h
         db        0

         dw        -1
         db        0c4h
         db        0

         dw        -1
         db        0c5h
         db        0

         dw        -1
         db        0c1h
         db        0

         dw        0
         db        0
         db        0

         dw        0
         db        0
         db        0

         dw        -1
         db        0c1h
         db        0

         dw        0
         db        0
         db        0

         dw        0
         db        0
         db        0

l_0A070  label     word

; -----------------------------------------------------------------------------
;        obsluha INT 23h
; -----------------------------------------------------------------------------

l_0a43   PROC      FAR

         iret

l_0a43   ENDP

; -----------------------------------------------------------------------------
;        v˜stup znaku AL na displej p©i hl ¨en¡ chyby syst‚mu (do okna)
; -----------------------------------------------------------------------------

l_0A44   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      di
         push      si

         xor       ah,ah
         push      ax                       ; znak k v˜stupu
         call      word ptr ds:[d_013A]     ; v˜stup znaku na displej

l_0A50:  pop       si
         pop       di
         pop       dx
         pop       cx
         pop       bx
         ret

l_0A44   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl vesnice -> AX
; -----------------------------------------------------------------------------

l_0A56   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      di
         push      si

         dec       sp
         call      word ptr ds:[d_0138]     ; vstup znaku z kl vesnice
         jmp       short l_0A50             ; n vrat registr–

l_0A56   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ textu ASCIIZ na displej (text n sleduje za instrukc¡ CALL)
; -----------------------------------------------------------------------------

l_0A62   PROC      NEAR

         push      bp
         mov       bp,sp                    ; BP <- ukazatel parametr–
         xchg      bx,[bp+2]                ; BX <- offset adresy textu
l_0A68:  mov       al,cs:[bx]               ; znak k zobrazen¡
         inc       bx                       ; zv˜¨en¡ ukazatele textu
         or        al,al                    ; je konec textu ?
         jz        l_0A75                   ; je konec textu
         call      l_0A44                   ; v˜stup znaku na displej
         jmp       short l_0A68             ; dal¨¡ znak
l_0A75:  xchg      bx,[bp+2]                ; n vrat BX
         pop       bp
         ret

l_0A62   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ od© dkov n¡ textu
; -----------------------------------------------------------------------------

l_0A7A   PROC      NEAR

         call      l_0A62                   ; zobrazen¡ textu ASCIIZ
         db        13,10,0                  ; text od© dkov n¡
         ret

l_0A7A   ENDP

; -----------------------------------------------------------------------------
;        p©evod znaku AL na velk‚ p¡smeno
; -----------------------------------------------------------------------------

l_0A81   PROC      NEAR

         cmp       al,"a"
         jb        l_0A8B
         cmp       al,"z"
         ja        l_0A8B
         sub       al,32
l_0A8B:  ret

l_0A81   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ slova AX v HEX tvaru
; -----------------------------------------------------------------------------

l_0A8C   PROC      NEAR

         push      ax                       ; ‡¡slo k zobrazen¡
         mov       al,ah                    ; vy¨¨¡ bajt ‡¡sla
         call      l_0A93                   ; zobrazen¡ vy¨¨¡ho bajtu
         pop       ax
                                            ; pokra‡uje zobrazen¡ bajtu AL !

l_0A8C   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ bajtu AL v HEX k¢du
; -----------------------------------------------------------------------------

l_0A93   PROC      NEAR

         push      ax                       ; bajt k zobrazen¡
         ror       al,1
         ror       al,1
         ror       al,1
         ror       al,1                     ; vy¨¨¡ tetr da k zobrazen¡
         call      l_0AA0                   ; zobrazen¡ vy¨¨¡ tetr dy ‡¡sla
         pop       ax

l_0A93   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ tetr dy AL v HEX k¢du
; -----------------------------------------------------------------------------

l_0AA0   PROC      NEAR

         and       al,0Fh                   ; ni‘¨¡ tetr da k zobrazen¡
         add       al,90h
         daa       
         adc       al,40h
         daa       
         jmp       short l_0A44             ; zobrazen¡ znaku AL

l_0AA0   ENDP

; -----------------------------------------------------------------------------
;        omezen¡ ‡¡sla AX na bajt bez znam‚nka
; -----------------------------------------------------------------------------

l_0AAA   PROC      NEAR

         or        ah,ah                    ; je p©ete‡en¡ ‡¡sla ?
         jz        l_0AB6                   ; velikost ‡¡sla je OK
         stc                                ; p©¡znak p©ete‡en¡ ‡¡sla
         mov       ax,0                     ; omezen¡ ‡¡sla p©i p©ete‡en¡ dol–
         js        l_0AB6                   ; bylo p©ete‡en¡ dol– (z porn‚)
         dec       al                       ; omezen¡ ‡¡sla na 255
l_0AB6:  ret

l_0AAA   ENDP

; -----------------------------------------------------------------------------
;        syst‚mov  inicializace programu
; -----------------------------------------------------------------------------
; za instrukc¡ CALL volaj¡c¡ tuto proceduru jsou u‘ivatelsk‚ parametry:
;    +0 (2) p©¡znaky programu
;           bit 0: 1=pamˆŸov˜ blok programu se p©i startu nezmen¨uje
;           bit 1: 1=povoleno pou‘it¡ funkc¡ DOS 44h
;           bit 2: 1=povolena obsluha Ctrl-C
;           bit 3: 1=instaluje se obsluha INT 03h
;    +2 (2)
;    +4 (2)
;    +6 (2) d‚lka programov‚ho segmentu
;    +8 (2) d‚lka datov‚ho segmentu
;   +10 (2) d‚lka z sobn¡ku
;   +12 (2) maxim ln¡ velikost pro data (halda) za programem
;   +14 (2) maxim ln¡ po‡et identifik tor– soubor–
;   +16 (2) p©¡znaky standardn¡ho vstupn¡ho za©¡zen¡
;   +18 (2)
; -----------------------------------------------------------------------------

l_0AB7   PROC      NEAR

; ------ kontrola verze opera‡n¡ho syst‚mu

         call      l_0C08                   ; kontrola verze opera‡n¡ho syst‚mu

; ------ kontrola velikosti pamˆti

         pop       si                       ; n vratov  adresa z procedury
         mov       ax,cs                    ; AX <- CS segment programu
         add       ax,cs:[si+6]             ; p©i‡ten¡ d‚lky programu
         add       ax,cs:[si+8]             ; p©i‡ten¡ d‚lky datov‚ho segmentu
         add       ax,cs:[si+0Ah]           ; p©i‡ten¡ d‚lky z sobn¡ku
         cmp       ax,cs:[2]                ; p©ekro‡ena velikost pamˆti ?
         jbe       l_0AD3                   ; velikost pamˆti je OK
         jmp       l_0C17                   ; chyba - nedostatek pamˆti

; ------ adresa datov‚ho segmentu -> DS

l_0AD3:  mov       bx,cs                    ; BX <- CS segment programu
         add       bx,cs:[si+6]             ; p©i‡ten¡ d‚lky programu
         mov       ds,bx                    ; adresa datov‚ho segmentu

; ------ adresa za‡ tku datov‚ haldy, adresa z sobn¡ku

         add       bx,cs:[si+8]             ; p©i‡ten¡ d‚lky datov‚ho segmentu
         mov       dx,cs:[2]                ; adresa konce p©idˆlen‚ pamˆti
         sub       dx,bx                    ; zbyl  velikost pro data
         cmp       dx,cs:[si+0Ch]           ; posta‡uje men¨¡ velikost dat ?
         jb        l_0AF0                   ; je m‚nˆ ne‘ po‘adov no
         mov       dx,cs:[si+0Ch]           ; omezen¡ - posta‡¡ m‚nˆ dat
l_0AF0:  mov       di,dx                    ; velikost prostoru pro data
         mov       ax,0FFFEh                ; ukazatel z sobn¡ku SP
         sub       dx,1000h                 ; zb˜v  m‚nˆ pamˆti ne‘ 64 KB ?
         jnc       l_0B06                   ; zb˜v  v¡ce pamˆti ne‘ 64 KB
         mov       ax,dx                    ; zbyl  velikost pamˆti
         add       ax,1000h                 ; n vrat zbyl‚ velikosti pamˆti
         mov       cl,4                     ; po‡et rotac¡
         shl       ax,cl                    ; v˜po‡et offsetu SP
         xor       dx,dx                    ; segment SS se nebude posouvat
l_0B06:  add       dx,bx                    ; p©i‡ten¡ segmentu pro SS
         mov       ss,dx                    ; ukazatel z sobn¡ku SS
         mov       sp,ax                    ; ukazatel z sobn¡ku SP
         mov       ds:[d_0174],ax           ; vrchol z sobn¡ku SP

; ------ inicializace ukazatele pamˆŸov˜ch blok–

         xor       ax,ax
         mov       word ptr ds:[d_018A],ax  ; offset za‡ tku voln‚ pamˆti
         mov       word ptr ds:[d_018A+2],bx; segment za‡ tku voln‚ pamˆti
         mov       word ptr ds:[d_0022],ax  ; offset adresy 1. voln‚ho bloku
         mov       word ptr ds:[d_0022+2],bx; segment adresy 1. voln‚ho bloku
         push      di
         les       di,ds:[d_0022]           ; adresa prvn¡ho voln‚ho dat. bloku
         mov       cx,4                     ; po‡et slov k vymaz n¡
         cld       
         rep       stosw                    ; vymaz n¡ ukazatel– prvn¡ho bloku
         pop       di

; ------ zmen¨en¡ pamˆŸov‚ho bloku programu

         test      word ptr cs:[si],1       ; zmen¨¡ se pamˆŸov˜ blok programu ?
         jnz       l_0B3F                   ; pamˆŸov˜ blok programu se nezmen¨¡
         mov       ax,cs
         mov       es,ax                    ; ES <- CS (adresa PSP)
         add       bx,di                    ; p©i‡ten¡ prostoru pro haldu
         sub       bx,ax                    ; ode‡ten¡ CS -> velikost bloku
         mov       ah,4Ah
         call      l_093A                   ; zmen¨en¡ pamˆŸov‚ho bloku programu

; ------

l_0B3F:  mov       ax,cs:[si+2]
         mov       ds:[d_0176],ax
         mov       ax,cs:[si+4]
         mov       ds:[d_0178],ax

; ------ inicializace tabulky identifik tor– soubor–

         mov       ax,cs:[si]               ; p©¡znaky programu
         mov       cx,cs:[si+0Eh]           ; maxim. po‡et identif. soubor–
         push      cx                       ; maxim. po‡et identif. soubor–
         push      si                       ; £schova ukazatele parametr–
         call      l_09B3                   ; inicializace tabulky identifik.
         pop       si
         pop       cx
         mov       di,offset d_0240         ; tabulka identifik tor– soubor–
         add       di,cx
         add       di,cx                    ; konec tabulky identifik tor–
         mov       ds:[d_015E],di           ; za‡ tek voln‚ pamˆti

; ------ inicializace standardn¡ho vstupn¡ho za©¡zen¡

         mov       ax,cs:[si+10h]
         mov       ds:[d_0160],ax           ; p©¡znaky vstupn¡ho za©¡zen¡
         add       di,ax                    ;
         or        ax,ax
         jz        l_0B7E
         mov       word ptr ds:[d_015A],0   ; identifik tor stand.vstup.za©¡zen¡
         mov       byte ptr ds:[d_015C],0   ; parametry za©¡zen¡
l_0B7E:  mov       ds:[d_016A],di

; ------ inicializace standardn¡ho v˜stupn¡ho za©¡zen¡

         mov       ax,cs:[si+12h]
         mov       ds:[d_016C],ax
         or        ax,ax
         jz        l_0B98
         mov       word ptr ds:[d_0166],1   ; identifik. stand. v˜stup. za©¡zen¡
         mov       byte ptr ds:[d_0168],0

; ------ instalace obsluhy INT 00h

l_0B98:  add       si,14h                   ; p©esko‡en¡ dat za procedurou
         push      si                       ; n vratov  adresa z procedury
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,es:[4*0]              ; offset INT 00h
         mov       word ptr ds:[d_018E],ax  ; £schova adresy INT 00h
         mov       ax,es:[4*0+2]
         mov       word ptr ds:[d_018E+2],ax
         mov       word ptr es:[4*0],offset l_1013 ; instalace obsluhy INT 00h
         mov       es:[4*0+2],cs
         test      word ptr ds:[d_0172],8   ; instaluje se obsluha INT 03h ?
         jz        l_0BCE                   ; neinstaluje se
         mov       word ptr es:[4*3],offset l_0FD1 ; instalace obsluhy INT 03h
         mov       es:[4*3+2],cs

; ------ p©¡znak povolen¡ obsluhy Ctrl-C

l_0BCE:  test      word ptr ds:[d_0172],4   ; je povolena obsluha Ctrl-C ?
         jz        l_0BDB                   ; nen¡ povolena obsluha Ctrl-C
         mov       byte ptr ds:[d_0194],1   ; p©¡znak povolen¡ obsluhy Ctrl-C
l_0BDB:  mov       word ptr ds:[d_017E],offset l_10B1 ; adresa obsluhy p©eru¨en¡


         xor       ax,ax
         mov       ds:[d_0188],ax
         mov       byte ptr ds:[d_0196],al  ; zru¨en¡ jm‚na souboru

; ------ inicializace standardn¡ho vstupn¡ho za©¡zen¡

         mov       cx,ds:[d_0160]
         push      ds
         mov       di,offset d_015A         ; parametry standard.vstup. za©¡zen¡
         call      l_2307

; ------ inicializace standardn¡ho v˜stupn¡ho za©¡zen¡

         mov       cx,ds:[d_016C]
         push      ds
         mov       di,offset d_0166
         call      l_230B

; ------ inicializace displeje

         mov       byte ptr ds:[d_01FA],0
         call      l_02AB                   ; inicializace displeje - text. m¢d
         ret

l_0AB7   ENDP

; -----------------------------------------------------------------------------
;        kontrola verze opera‡n¡ho syst‚mu
; -----------------------------------------------------------------------------

l_0C08   PROC      NEAR

         mov       ah,30h
         call      l_093A                   ; poskytnut¡ ‡¡sla syst‚mu
         or        al,al                    ; je opera‡n¡ syst‚m verze 1.x ?
         jz        l_0C12                   ; je syst‚m verze 1.x
         ret

l_0C12:  mov       dx,offset l_0C40         ; text 'Incorrect DOS version'
         jmp       short l_0C1A             ; chybov‚ p©eru¨en¡ programu

l_0C08   ENDP

; -----------------------------------------------------------------------------
;        chyba - neposta‡uj¡c¡ pamˆŸ
; -----------------------------------------------------------------------------

l_0C17:  mov       dx,offset l_0C2E         ; text 'Not enough memory'

; -----------------------------------------------------------------------------
;        chybov‚ p©eru¨en¡ programu (DX=text chybov‚ho hl ¨en¡)
; -----------------------------------------------------------------------------

l_0C1A   PROC      NEAR

         push      cs
         pop       ds                       ; DS <- CS
         mov       ah,9
         call      l_093A                   ; zobrazen¡ chybov‚ho textu DOS

         mov       dx,offset l_0C56         ; text 'Program aborted'
         mov       ah,9
         call      l_093A                   ; zobrazen¡ chybov‚ho textu DOS

         mov       ah,0                     ; funkce p©eru¨en¡ programu
         call      l_093A                   ; ukon‡en¡ programu

l_0C1A   ENDP

l_0C2E   db        'Not enough memory$'
l_0C40   db        'Incorrect DOS version$'
l_0C56   db        13,10,'Program aborted',13,10,'$'

; -----------------------------------------------------------------------------
;        ukon‡en¡ programu - EXIT (t‚‘ ukon‡en¡ p©i chybˆ)
; -----------------------------------------------------------------------------

l_0C6A   PROC      FAR

         push      ax                       ; n vratov˜ k¢d programu
         push      ds
         mov       di,offset d_015A         ; parametry stand. vstup. za©¡zen¡
         call      l_23E4                   ; uzav©en¡ souboru
         push      ds
         mov       di,offset d_0166         ; parametry stand. v˜stup. za©¡zen¡
         call      l_23E4                   ; uzav©en¡ souboru
         xor       ax,ax                    ; AX <- 0
         mov       es,ax                    ; ES <- 0
         mov       ax,word ptr ds:[d_018E]  ; p–vodn¡ adresa INT 00h
         mov       es:[4*0],ax              ; n vrat p–vodn¡ adresy INT 00h
         mov       ax,word ptr ds:[d_018E+2]
         mov       es:[4*0+2],ax
         pop       ax                       ; n vratov˜ k¢d programu

         test      word ptr ds:[d_0172],1   ; zmen¨il se blok programu ?
         jnz       l_0C99                   ; smen¨il se
         mov       ah,4ch
         call      l_093A                   ; ukon‡en¡ programu

l_0C99:  mov       ah,80h                   ; funkce uzav©en¡ v¨ech soubor–
         call      l_093A                   ; uzav©en¡ v¨ech soubor–
         push      word ptr ds:[d_0176]
         mov       ax,3c3ch
         push      ax
         push      ds
         pop       es                       ; ES <- DS
         mov       ds,ds:[d_0178]
         ret

l_0C6A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_0CAD   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         mov       ax,cs:[bx]               ; prvn¡ k¢d za instrukc¡ CALL
         or        ax,ax
         jz        l_0CEA

         push      ds                       ; £schova DS
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         xor       dx,dx                    ; DX <- 0

l_0CBC:  mov       ax,[bx]
         or        ax,ax
         jz        l_0CC8
         push      bx                       ; n vratov  adresa z procedury
         add       bx,ax
         inc       dx
         jmp       short l_0CBC

l_0CC8:  mov       cx,bx
         pop       bx
         mov       si,bx
         add       si,4
         mov       di,[bx+2]
         cmp       si,di
         je        l_0CE2
         sub       cx,si
         add       si,cx
         add       di,cx
         dec       si
         dec       di
         std       
         rep       movsb
l_0CE2:  dec       dx
         jnz       l_0CC8

         mov       word ptr [bx],0
         pop       ds

l_0CEA:  add       bx,4                     ; p©esko‡en¡ parametr– za CALL
         jmp       bx                       ; n vrat z procedury

l_0CAD   ENDP

; -----------------------------------------------------------------------------
;        start bloku programu z p©ekryvn‚ho modulu
; -----------------------------------------------------------------------------
; VSTUP: DX=offset po‘adovan‚ho p©ekryvn‚ho modulu v souboru (n sobek 256 bajt–)
;        CX=velikost modulu (po‡et bajt–)
; za instrukc¡ CALL jsou parametry:
;         0: (2) offset aktu ln¡ho na‡ten‚ho p©ekryvn‚ho modulu
;         2: (13) jm‚no programu ASCIIZ p©ekryvn‚ho modulu
;        15: za‡ tek p©ekryvn‚ho modulu (zde program posta‡uje)
; -----------------------------------------------------------------------------

l_0CEF   PROC      NEAR

; ------ kontrola, zda je modul ji‘ na‡ten

         pop       si                       ; n vratov  adresa z procedury
         cmp       dx,cs:[si]               ; souhlas¡
         jne       l_0CFA
l_0CF5:  add       si,0Fh                   ; p©esko‡en¡ parametr– za CALL
         jmp       si                       ; n vrat z procedury

; ------ £schova registr–

l_0CFA:  push      ax
         push      dx
         push      si

; ------ nalezen¡ konce jm‚na domovsk‚ho adres ©e programu

         mov       di,offset d_0196         ; buffer domovsk‚ho adres ©e progr.
         xor       al,al                    ; AL <- 0
l_0D02:  mov       ah,al                    ; posledn¡ znak jm‚na
         mov       al,[di]                  ; znak z bufferu
         or        al,al                    ; je konec jm‚na adres ©e ?
         jz        l_0D0D                   ; je konec jm‚na adres ©e
         inc       di                       ; zv˜¨en¡ ukazatele textu
         jmp       short l_0D02             ; dal¨¡ znak

; ------ doplnˆn¡ jm‚na adres ©e znakem "\"

l_0D0D:  push      di                       ; adresa konce jm‚na adres ©e
         or        ah,ah                    ; posledn¡ znak jm‚na adres ©e
         jz        l_0D20                   ; jm‚no souboru nebylo zad no
         cmp       ah,3Ah                   ; kon‡¡ jm‚no znakem ":" ?
         je        l_0D20                   ; je zad n pouze disk
         cmp       ah,'\'                   ; konc¡ jm‚no adres ©e znakem "\" ?
         je        l_0D20                   ; je zad n adres © kon‡¡c¡ "\"
         mov       byte ptr [di],'\'        ; ukon‡en¡ jm‚na znakem "\"
         inc       di                       ; dal¨¡ znak

; ------ p©id n¡ jm‚na souboru ke jm‚nu adres ©e

l_0D20:  inc       si                       ; p©esko‡en¡ polo‘ky offsetu modulu
         inc       si
l_0D22:  mov       al,cs:[si]               ; znak jm‚na souboru
         mov       [di],al
         inc       si
         inc       di
         or        al,al                    ; je konec jm‚na souboru ?
         jnz       l_0D22                   ; p©enesen¡ textu po bajt 0

; ------ otev©en¡ zadan‚ho souboru p©ekryvn˜ch modul–

         mov       ax,3D00h                 ; povel k otev©en¡ souboru
         mov       dx,offset d_0196         ; jm‚no souboru p©ekryvn˜ch modul–
         push      ds
         pop       es                       ; ES <- DS
         call      l_093A                   ; otev©en¡ zadan‚ho souboru
         mov       bx,ax                    ; BX <- identifik tor souboru

; ------ n vrat registr–

         pop       di                       ; adresa konce jm‚na adres ©e
         pop       si                       ; za‡ tek parametr–
         pop       dx                       ; offset modulu v souboru
         mov       byte ptr [di],0          ; n vrat ozna‡en¡ konce adres ©e
         jc        l_0D6B                   ; byla chyba p©¡stupu k souboru

; ------ nastaven¡ ukazatele v souboru (v n sobc¡ch 256 bajt–)

         mov       cs:[si],dx               ; nov˜ aktu ln¡ ukazatel v souboru
         mov       ax,4200h                 ; funkce vystaven¡ ukazatele
         xor       ch,ch                    ; CH <- 0
         mov       cl,dh                    ; CL <- DH (offset HIGH)
         mov       dh,dl                    ; DH <- DL (offset LOW)
         xor       dl,dl                    ; DL <- 0
         call      l_093A                   ; nastaven¡ ukazatele v souboru
         pop       cx                       ; d‚lka p©ekryvn‚ho modulu
         jc        l_0D6B                   ; chyba vystaven¡ ukazatele

; ------ na‡ten¡ p©ekryvn‚ho modulu ze souboru

         mov       ah,3Fh                   ; funkce ‡ten¡ ze souboru
         lea       dx,[si+0Fh]              ; adresa k na‡ten¡ dat ze souboru
         push      ds
         push      cs
         pop       ds                       ; DS <- CS
         call      l_093A                   ; na‡ten¡ bloku dat ze souboru
         pop       ds
         jc        l_0D6B                   ; chyba ‡ten¡

; ------ uzav©en¡ souboru a skok do na‡ten‚ho p©ekryvn‚ho modulu

         mov       ah,3Eh
         call      l_093A                   ; uzav©en¡ souboru
         jmp       short l_0CF5             ; n vrat z procedury

; ------ chyba p©¡stupu k p©ekryvn‚mu modulu

l_0D6B:  mov       dl,0F0h                  ; k¢d chyby
         push      si                       ; n vratov  adresa z procedury
         jmp       l_1019                   ; chybov‚ ukon‡en¡ programu

l_0CEF   ENDP

; -----------------------------------------------------------------------------
;        p©enos domovsk‚ho adres ©e ze z sobn¡ku do bufferu
; -----------------------------------------------------------------------------

l_0D71   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         call      l_0EC7                   ; p©enos ©etˆzce ze z sob.do bufferu
         push      bx                       ; n vratov  adresa z procedury
         mov       si,offset d_00B6         ; buffer s dek¢dovan˜m textem
         mov       di,offset d_0196         ; buffer domovsk‚ho adres ©e
         push      ds
         pop       es                       ; ES <- DS
         mov       cx,64/2                  ; d‚lka textu
         cld
         rep       movsw                    ; p©enos ©etˆzce do bufferu
         ret

l_0D71   ENDP

; -----------------------------------------------------------------------------
;        test p©ipravenosti znaku z kl vesnice
; -----------------------------------------------------------------------------

l_0D85   PROC      NEAR

         dec       sp
         call      word ptr ds:[d_0136]     ; test p©ipravenosti znaku z kl ves.
         ret

l_0D85   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ pozice kurzoru v oknˆ
; -----------------------------------------------------------------------------
; VSTUP: AX = pozice na © dku
;        [SP+2] © dek v oknˆ
; -----------------------------------------------------------------------------

l_0D8B   PROC      NEAR

         pop       bx                       ; n vratov  adresa
         pop       cx                       ; © dek v oknˆ
         push      bx                       ; n vratov  adresa
         mov       dl,al                    ; pozice na © dku
         mov       dh,cl                    ; © dek v oknˆ
         dec       dl                       ; korekce pozice na © dku
         dec       dh                       ; korekce © dku v oknˆ
         jmp       l_0326                   ; nastaven¡ pozice kurzoru v oknˆ

l_0D8B   ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ posledn¡ho parametru z p©¡kaz. © dku do bufferu v z sobn¡ku
; -----------------------------------------------------------------------------

l_0D99   PROC      NEAR

         mov       dx,ax                    ; maxim ln¡ po‡et parametr–
         or        dx,dx                    ; jsou povoleny nˆjak‚ parametry ?
         jz        l_0DA3                   ; nejsou povoleny parametry
         call      l_0DB8                   ; stanoven˜ po‡tu parametr– -> AX
         xchg      ax,bx                    ; BX <- po‡et parametr–
l_0DA3:  pop       bx                       ; n vratov  adresa z procedury
         sub       sp,ax                    ; rezerva pro posledn¡ parametr
         dec       sp
         mov       di,sp                    ; adresa k ulo‘en¡ parametru
         push      ds                       ; £schova DS
         push      cs
         pop       ds                       ; DS <- CS
         push      ss
         pop       es                       ; ES <- SS
         cld       
         stosb                              ; d‚lka parametru
         xchg      ax,cx                    ; CX <- d‚lka parametru
         rep       movsb                    ; p©enesen¡ parametru do z sobn¡ku
         pop       ds                       ; n vrat DS
         jmp       bx                       ; n vrat z procedury

l_0D99   ENDP

; -----------------------------------------------------------------------------
;        stanoven¡ po‡tu parametr– v p©¡kazov‚m © dku (max. DX parametr–) -> AX
; -----------------------------------------------------------------------------

l_0DB6   PROC      NEAR

         xor       dx,dx                    ; DX <- 0 po‡et parametr– neomezen
l_0DB8:  mov       di,80h                   ; za‡ tek p©¡kazov‚ho © dku
         mov       cl,cs:[di]               ; d‚lka p©¡kazov‚ho © dku
         xor       ch,ch                    ; CH <- 0
         inc       di                       ; za‡ tek p©¡kazov‚ho © dku
         xor       bx,bx                    ; BX <- 0 ‡¡ta‡ parametr–

; ------ vypu¨tˆn¡ oddˆlovac¡ch mezer

l_0DC3:  jcxz      l_0DD4                   ; konec p©¡kazov‚ho © dku
         mov       al,cs:[di]               ; znak z p©¡kazov‚ho © dku
         cmp       al," "                   ; mezera ?
         je        l_0DD0                   ; je mezera
         cmp       al,9                     ; tabel tor ?
         jne       l_0DD4                   ; nen¡ tabel tor
l_0DD0:  inc       di                       ; p©esko‡en¡ mezery
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short l_0DC3             ; dal¨¡ znak

; ------ nalezen¡ konce parametru

l_0DD4:  mov       si,di                    ; za‡ tek parametru
l_0DD6:  jcxz      l_0DE7                   ; konec p©¡kazov‚ho © dku
         mov       al,cs:[di]               ; znak z p©¡kazov‚ho © dku
         cmp       al," "                   ; mezera ?
         je        l_0DE7                   ; je mezera
         cmp       al,9                     ; tabel tor ?
         je        l_0DE7                   ; je tabel tor
         inc       di                       ; p©esko‡en¡ platn‚ho znaku
         dec       cx                       ; sn¡‘en¡ ‡¡ta‡e znak–
         jmp       short l_0DD6             ; dal¨¡ znak

; ------ zv˜¨en¡ ‡¡ta‡e parametr–

l_0DE7:  mov       ax,di                    ; konec parametru
         sub       ax,si                    ; d‚lka parametru
         jz        l_0DF1                   ; nen¡ parametr
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e parametr–
         dec       dx                       ; maxim ln¡ po‡et parametr–
         jnz       l_0DC3                   ; m–‘e b˜t dal¨¡ parametr
l_0DF1:  xchg      ax,bx                    ; AX <- nalezen˜ po‡et parametr–
         ret

l_0DB6   ENDP

; *****************************************************************************
;
;                   Dek¢dov n¡ ‡¡sel
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla INTEGER do dekadick‚ho tvaru
; -----------------------------------------------------------------------------
; VSTUP: CL = maxim ln¡ d‚lka ©etˆzce
;        DI = offset bufferu k dek¢dov n¡ ‡¡sla
;        [SP+2] (2) segment bufferu k dek¢dov n¡ ‡¡sla
;        [SP+4] (2) max. form tovan  d‚lka
;        [SP+6] (2) ‡¡slo INTEGER k dek¢dov n¡
; -----------------------------------------------------------------------------

l_0DF3   PROC      NEAR

         mov       byte ptr ds:[d_01E6],cl  ; maxim ln¡ d‚lka ©etˆzce ‡¡sla
         mov       word ptr ds:[d_01E8],di  ; adresa bufferu k dek¢dov n¡ ‡¡sla
         pop       bx                       ; n vratov  adresa
         pop       word ptr ds:[d_01E8+2]   ; segment bufferu k dek¢dov n¡ ‡¡sla
         pop       cx                       ; maxim ln¡ form tovan  d‚lka
         pop       ax                       ; ‡¡slo k dek¢dov n¡
         push      bx                       ; n vratov  adresa z procedury
         push      cx                       ; maxim ln¡ form tovan  d‚lka
         mov       bx,offset d_00B6         ; buffer k dek¢dov n¡ textu
         call      l_10FC                   ; dek¢dov n¡ ‡¡sla AX do buff. DS:BX
         jmp       short l_0E2F             ; ulo‘en¡ ©etˆzce do bufferu

l_0DF3   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla REAL do dekadick‚ho tvaru
; -----------------------------------------------------------------------------
; VSTUP: CL = maxim ln¡ d‚lka ©etˆzce
;        DI = offset bufferu k dek¢dov n¡ ‡¡sla
;        [SP+2] (2) segment bufferu k dek¢dov n¡ ‡¡sla
;        [SP+4] (2)
;        [SP+6] (2) max. form tovan  d‚lka
;        [SP+8] (6) ‡¡slo REAL k dek¢dov n¡
; -----------------------------------------------------------------------------

l_0E0C   PROC      NEAR

         mov       byte ptr ds:[d_01E6],cl  ; maxim ln¡ d‚lka ©etˆzce ‡¡sla
         mov       word ptr ds:[d_01E8],di  ; adresa bufferu k dek¢dov n¡ ‡¡sla
         pop       bx                       ; n vratov  adresa z procedury
         pop       word ptr ds:[d_01E8+2]   ; segment bufferu k dek¢dov n¡ ‡¡sla
         pop       dx
         pop       ax
         mov       di,offset d_01F4         ; buffer ‡¡sla REAL k dek¢dov n¡
         pop       word ptr [di]            ; ‡¡slo REAL k dek¢dov n¡
         pop       word ptr [di+2]
         pop       word ptr [di+4]
         push      bx                       ; n vratov  adresa z procedury
         push      ax                       ; d‚lka bufferu k dek¢dov n¡ ‡¡sla
         xchg      ax,cx                    ; CX <- d‚lka bufferu
         mov       bx,offset d_00b6         ; buffer k dek¢dov n¡ ‡¡sla
         call      l_1F22                   ; dek¢dov n¡ ‡¡sla REAL do DS:BX

; ------ p©¡prava k ulo‘en¡ ‡¡sla do bufferu

l_0E2F:  pop       cx                       ; d‚lka bufferu
         les       di,dword ptr ds:[d_01E8] ; adresa bufferu k dek¢dov n¡ ‡¡sla
         push      di
         mov       dl,byte ptr ds:[d_01E6]  ; maxim ln¡ d‚lka ©etˆzce ‡¡sla
         xor       dh,dh                    ; DH <- 0
         xchg      ax,bx
         sub       ax,offset d_00b6         ; d‚lka ©etˆzce ‡¡sla v bufferu
         sub       cx,ax                    ; zbytek d‚lky bufferu
         jbe       l_0E50                   ; nezbyla ‘ dn  voln  pozice

; ------ vymaz n¡ bufferu p©ed ‡¡slem

l_0E43:  inc       di
         mov       byte ptr es:[di]," "     ; mezera p©ed ‡¡slem
         inc       dh                       ; zv˜¨en¡ ‡¡ta‡e znak–
         cmp       dh,dl                    ; dosa‘eno maxim ln¡ d‚lky ?
         je        l_0E63                   ; dosa‘eno maxim ln¡ d‚lky
         loop      l_0E43                   ; dal¨¡ znak

; ------ p©enesen¡ ‡¡sla do bufferu

l_0E50:  xchg      ax,cx                    ; CX <- d‚lka ©etˆzce
         mov       bx,offset d_00B6         ; buffer s dek¢dovan˜m ‡¡slem
l_0E54:  mov       al,[bx]                  ; znak k p©enesen¡
         inc       bx
         inc       di
         mov       es:[di],al               ; ulo‘en¡ adresy do bufferu
         inc       dh                       ; zv˜¨en¡ ‡¡ta‡e d‚lky ‡¡sla
         cmp       dh,dl                    ; dosa‘eno maxim ln¡ d‚lky ‡¡sla ?
         je        l_0E63                   ; dosa‘eno maxim ln¡ d‚lky ‡¡sla
         loop      l_0E54                   ; dal¨¡ znak

; ------ ulo‘en¡ bajtu d‚lky textu ‡¡sla

l_0E63:  pop       di                       ; za‡ tek bufferu k dek¢dov n¡
         mov       es:[di],dh               ; d‚lka textu ‡¡sla
         ret

l_0E0C   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ ‡¡sla INTEGER
; -----------------------------------------------------------------------------

l_0E68   PROC      NEAR

         xor       al,al
         jmp       short l_0E6E

l_0E68   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_0E6C   PROC      NEAR

         mov       al,1
l_0E6E:  mov       byte ptr ds:[d_01E7],al
         mov       word ptr ds:[d_01F0],di
         pop       bx
         pop       word ptr ds:[d_01F0+2]
         pop       word ptr ds:[d_01EC]
         pop       word ptr ds:[d_01EC+2]
         call      l_0ECC                   ; p©enos ©etˆzce ze z sob.do bufferu
         push      bx
         xor       ax,ax
         mov       bx,offset d_00B6
         cmp       [bx],al
         je        l_0EBF
         cmp       byte ptr ds:[d_01E7],al
         jne       l_0EA3
         call      l_1188                   ; ‡ten¡ ‡¡sla HEX/DEK se znam‚nkem
         jc        l_0EBB                   ; chyba
         les       di,ds:[d_01EC]
         mov       es:[di],ax
         jmp       short l_0EB5

l_0EA3:  mov       di,offset d_01F4
         call      l_20AA
         jc        l_0EBB
         mov       si,di
         les       di,ds:[d_01EC]
         cld       
         movsw     
         movsw     
         movsw     

l_0EB5:  xor       ax,ax
         cmp       [bx],al
         je        l_0EBF

l_0EBB:  xchg      ax,bx
         sub       ax,offset d_00B6 - 1
l_0EBF:  les       di,ds:[d_01F0]
         mov       es:[di],ax
         ret

l_0E6C   ENDP

; *****************************************************************************
;
;                   Operace s bloky dat
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;    p©enos ©etˆzce ze z sobn¡ku do bufferu - max. 64 znak– (do tvaru ASCIIZ)
; -----------------------------------------------------------------------------

l_0EC7   PROC      NEAR

         mov       cx,64                    ; omezen¡ d‚lky ©etˆzce
         jmp       short l_0ECF             ; p©enos ©etˆzce ze z sob.do bufferu

l_0EC7   ENDP

; -----------------------------------------------------------------------------
;     p©enos ©etˆzce ze z sobn¡ku do bufferu - max. 128 znak– (do tvaru ASCIIZ)
; -----------------------------------------------------------------------------

l_0ECC   PROC      NEAR

         mov       cx,127                   ; maxim ln¡ d‚lka ©etˆzce 127 B
l_0ECF:  mov       di,offset d_00B6         ; adresa bufferu k vytvo©en¡ ©etˆzce
         pop       ax                       ; n vratov  adresa z procedury
         mov       si,sp                    ; adresa ©etˆzce v z sobn¡ku
         mov       dl,ss:[si]               ; d‚lka ©etˆzce v z sobn¡ku
         xor       dh,dh                    ; DH <- 0
         cmp       cx,dx                    ; p©ekro‡ena maxim. d‚lka ©etˆzce ?
         jbe       l_0EE0                   ; je maxim ln¡ d‚lka ©etˆzce
         mov       cx,dx                    ; je men¨¡ d‚lka ©etˆzce
l_0EE0:  inc       dx                       ; d‚lka ©etˆzce + 1 (+ bajt d‚lky)
         inc       si                       ; za‡ tek ©etˆzce
         mov       di,offset d_00B6         ; buffer k vytvo©en¡ ©etˆzce
         push      ds
         pop       es                       ; ES <- DS datov˜ segment
         push      ss
         pop       ds                       ; DS <- SS z sobn¡k
         cld       
         rep       movsb                    ; p©enos ©etˆzce ze z sob.do bufferu
         push      es
         pop       ds                       ; n vrat DS
         mov       byte ptr [di],0          ; ozna‡en¡ konce ©etˆzce ASCIIZ
         add       sp,dx                    ; zru¨en¡ ©etˆzce z bufferu
         jmp       ax                       ; n vrat z procedury

l_0ECC   ENDP

; -----------------------------------------------------------------------------
;        aktu ln¡ syst‚mov˜ ‡as pro inicializaci gener toru n hody
; -----------------------------------------------------------------------------

l_0EF5   PROC      NEAR

         mov       ah,2Ch
         call      l_093A                   ; zji¨tˆn¡ syst‚mov‚ho ‡asu
         mov       word ptr ds:[d_01FC+2],cx ; hodina a minuta
         mov       word ptr ds:[d_01FC],dx  ; sekuna a setina sekundy
         ret

l_0EF5   ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ bloku dat (CX bajt–)
; -----------------------------------------------------------------------------
; VSTUP: CX = d‚lka ©etˆzce (bajt–)
;        DI = offset zdrojov‚ adresy dat
;        [SP+2] (2) segment zdrojov‚ adresy dat
;        [SP+4] (2) offset c¡lov‚ adresy dat
;        [SP+6] (2) segment c¡lov‚ adresy dat
; -----------------------------------------------------------------------------

l_0F03   PROC      NEAR

         pop       bx
         mov       dx,ds                    ; £schova DS
         mov       si,di                    ; offset zdrojov‚ adresy dat
         pop       ds                       ; segment zdrojov‚ adresy dat
         pop       di                       ; offset c¡lov‚ adresy dat
         pop       es                       ; segment c¡lov‚ adresy dat
         cld       
         rep       movsb                    ; p©enos bloku dat
         mov       ds,dx                    ; n vrat DS
         jmp       bx                       ; n vrat z procedury

l_0F03   ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ ©etˆzce do bufferu v z dobn¡ku
; -----------------------------------------------------------------------------
; VSTUP: DI = offset adresy ©etˆzce k p©enesen¡ do bufferu v z sobn¡ku
;        CX = d‚lka ©etˆzce k p©enesen¡ do bufferu v z sobn¡ku
;        [SP+2] segment adresy ©etˆzce k p©enesen¡ do bufferu v z sobn¡ku
; -----------------------------------------------------------------------------

l_0F12   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         mov       dx,ds                    ; £schova datov‚ho segmentu
         mov       si,di                    ; offset adresy ©etˆzce k p©enesen¡
         pop       ds                       ; segment adresy ©etˆzce k p©enesen¡
         sub       sp,cx                    ; vytvo©en¡ bufferu v z sobn¡ku
         mov       di,sp                    ; za‡ tek bufferu v z sobn¡ku
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         cld       
         rep       movsb                    ; p©enesen¡ ©etˆzce do z sobn¡ku
         mov       ds,dx                    ; n vrat datov‚ho segmentu
         jmp       bx                       ; n vrat z procedury

l_0F12   ENDP

; -----------------------------------------------------------------------------
;        vynulov n¡ bufferu konstantou
; -----------------------------------------------------------------------------
; VSTUP: AL = nulovac¡ konstanta
;        [SP+2] (2) d‚lka bufferu (v bajtech)
;        [SP+4] (4) adresa bufferu
; -----------------------------------------------------------------------------

l_0F25   PROC      NEAR

         pop       bx                       ; n vratov  adresa
         pop       cx                       ; d‚lka bufferu
         pop       di                       ; offset adresy bufferu
         pop       es                       ; segment adresy bufferu
         cld       
         rep       stosb                    ; vymaz n¡ bufferu
         jmp       bx                       ; n vrat z procedury

l_0F25   ENDP

; -----------------------------------------------------------------------------
;        posun dat (s p©ekryvem)
; -----------------------------------------------------------------------------
; VSTUP: AX = d‚lka dat
;        [SP+2] (2) offset c¡lov‚ adresy
;        [SP+4] (2) segment c¡lov‚ adresy
;        [SP+6] (2) offset zdrojov‚ adresy
;        [SP+8] (2) segment zdrojov‚ adresy
; -----------------------------------------------------------------------------

l_0F2E   PROC      NEAR

         xchg      ax,cx                    ; CX <- d‚lka dat (bajt–)
         mov       dx,ds                    ; £schova datov‚ho segmentu
         pop       bx                       ; n vratov  adresa z procedury
         pop       di                       ; offset c¡lov‚ adresy
         pop       es                       ; segment c¡slov‚ adresy
         pop       si                       ; offset zdrojov‚ adresy
         pop       ds                       ; segment zdrojov‚ adresy
         cld                                ; smˆr nahoru
         cmp       si,di                    ; je zdrojov  adresa pod c¡lovou ?
         jae       l_0F42                   ; zdrojov  adresa je nad c¡lovou
         add       si,cx                    ; adresa konce bufferu zdroje
         add       di,cx                    ; adresa konce bufferu c¡le
         dec       si                       ; korekce na posledn¡ bajt
         dec       di                       ; korekce na posledn¡ bajt
         std                                ; smˆr posunu dol–
l_0F42:  rep       movsb                    ; posun dat
         mov       ds,dx                    ; n vrat datov‚ho segmentu
         jmp       bx                       ; n vrat z procedury

l_0F2E   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ registr– z bufferu
; -----------------------------------------------------------------------------
; VSTUP: DI = offset bufferu s registry
;        [SP+2] (2) segment bufferu s registry
; struktura bufferu s registry:
;          0: (2) AX
;          2: (2) BX
;          4: (2) CX
;          6: (2) DX
;          8: (2) BP
;         10: (2) SI
;         12: (2) DI
;         14: (2) DS
;         16: (2) ES
;         18: (2) FLAG (pouze p©i n vratu)
; VSTUP: [SP+2] (2) offset bufferu s registry
;         [SP+4] (2) segment bufferu s registry
;         [SP+6] (2) datov˜ segment DS
;         [SP+8] (2) uschovan˜ registr BP
; -----------------------------------------------------------------------------

l_0F48   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         pop       ax                       ; segment bufferu s registry
         push      bp                       ; £schova BP
         push      ds                       ; £schova datov‚ho segmentu
         push      ax                       ; segment bufferu s registry
         push      di                       ; offset bufferu s registry
         push      bx                       ; n vratov  adresa z procedury

         mov       si,di                    ; offset bufferu s registry
         mov       ds,ax                    ; segment bufferu s registry
         cld
         lodsw     
         push      ax                       ; registr AX
         lodsw     
         mov       bx,ax                    ; registr BX
         lodsw     
         mov       cx,ax                    ; registr CX
         lodsw     
         mov       dx,ax                    ; registr DX
         lodsw     
         mov       bp,ax                    ; registr BP
         lodsw     
         push      ax                       ; registr SI
         lodsw     
         mov       di,ax                    ; registr DI
         lodsw     
         push      ax                       ; registr DS
         lodsw     
         mov       es,ax                    ; registr ES
         pop       ds                       ; nastaven¡ DS
         pop       si                       ; nastaven¡ SI
         pop       ax                       ; nastaven¡ AX
         ret

l_0F48   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ registr– do bufferu
; -----------------------------------------------------------------------------
; VSTUP:  registry k ulo‘en¡
;         [SP+2] (2) offset bufferu s registry
;         [SP+4] (2) segment bufferu s registry
;         [SP+6] (2) datov˜ segment DS
;         [SP+8] (2) uschovan˜ registr BP
; struktura bufferu s registry:
;          0: (2) AX
;          2: (2) BX
;          4: (2) CX
;          6: (2) DX
;          8: (2) BP
;         10: (2) SI
;         12: (2) DI
;         14: (2) DS
;         16: (2) ES
;         18: (2) FLAG (pouze p©i n vratu)
; -----------------------------------------------------------------------------

l_0F70   PROC      NEAR

                                            ; [BP+8] n vratov  adresa
         pushf                              ; [BP+6] £schova FLAG
         push      es                       ; [BP+4] £schova ES
         push      di                       ; [BP+2] £schova DI
         push      bp                       ; [BP+0] £schova BP
         mov       bp,sp                    ; ukazatel parametr– v z sobn¡ku
         les       di,dword ptr [bp+0Ah]    ; adresa bufferu s registry
         cld       
         stosw                              ; registr AX
         mov       ax,bx
         stosw                              ; registr BX
         mov       ax,cx
         stosw                              ; registr CX
         mov       ax,dx
         stosw                              ; registr DX
         pop       ax
         stosw                              ; registr BP
         mov       ax,si
         stosw                              ; registr SI
         pop       ax
         stosw                              ; registr DI
         mov       ax,ds
         stosw                              ; registr DS
         pop       ax
         stosw                              ; registr ES
         pop       ax
         stosw                              ; registr FLAG
         pop       bx                       ; n vratov  adresa z procedury
         add       sp,4                     ; zru¨en¡ adresy bufferu
         pop       ds                       ; n vrat datov‚ho segmentu
         pop       bp                       ; n vrat registru BP
         jmp       bx                       ; n vrat z procedury

l_0F70   ENDP

; *****************************************************************************
;
;                           Obsluha chyb
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_0F9A   PROC      NEAR

         cmp       ax,cx
         jae       l_0F9F
         ret

l_0F9F:  mov       dl,90h
         jmp       short l_1019             ; chybov‚ ukon‡en¡ programu
         nop

l_0F9A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_0FA4   PROC      NEAR

         cmp       ax,cx
         jl        l_0FAD
         cmp       ax,dx
         jg        l_0FAD
         ret

l_0FAD:  mov       dl,91h
         jmp       short l_1019             ; chybov‚ ukon‡en¡ programu
         nop

l_0FA4   ENDP

; -----------------------------------------------------------------------------
;        kontrola p©ete‡en¡ z sobn¡ku
; -----------------------------------------------------------------------------

l_0FB2   PROC      NEAR

         mov       ax,sp                    ; sou‡asn˜ ukazatel z sobn¡ku
         sub       ax,cx                    ; kontrola p©ete‡en¡ z sobn¡ku
         jc        l_0FCC                   ; chyba p©ete‡en¡ z sobn¡ku
         cmp       ax,200h                  ; zb˜v  dost m¡sta pro z sobn¡k ?
         jb        l_0FCC                   ; je m lo m¡sta pro z sobn¡k
         mov       cl,4                     ; po‡et rotac¡
         shr       ax,cl                    ; p©evod offsetu na segment
         mov       cx,ss                    ; segment z sobn¡ku
         add       ax,cx                    ; normovan˜ segment z sobn¡ku
         cmp       ax,word ptr ds:[d_018A+2]; je kolize s koncem dat ?
         jb        l_0FCC                   ; chyba - p©ete‡en¡ z sobn¡ku
         ret

; ------ chyba - p©ete‡en¡ pamˆti

l_0FCC:  mov       dl,0FFh                  ; k¢d pro p©ete‡en¡ pamˆti
         jmp       short l_1019             ; chybov‚ ukon‡en¡ programu
         nop       

l_0FB2   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 03h
; -----------------------------------------------------------------------------

l_0FD1   PROC      NEAR

         pop       bx                       ; offset n vratov‚ adresy
         pop       ax                       ; segment n vratov‚ adresy
         popf                               ; registr p©¡znak–
         push      bx                       ; offset n vratov‚ adresy
         or        byte ptr ds:[d_0194],2   ; p©¡znak vzniku p©eru¨en¡ INT 03h
         dec       sp
         call      l_0836                   ; test p©iprav. znaku z kl vesnice
         jz        l_0FE4                   ; nen¡ p©ipraven znak z kl vesnice
         dec       sp
         call      l_084F                   ; vstup znaku z kl vesnice
l_0FE4:  and       byte ptr ds:[d_0194],1   ; zru¨en¡ p©¡znaku INT 03h
         cmp       al,3                     ; je p©eru¨en¡ kl vesou Ctrl-C ?
         je        l_0FEE                   ; je p©eru¨en¡ kl vesou Ctrl-C
         ret

; ------ obsluha p©eru¨en¡ programu Ctrl-C

l_0FEE:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         add       word ptr ds:[d_0186],2   ; oprava adresy vzniku chyby
l_0FF7:  mov       dx,1                     ; n vratov˜ k¢d
         jmp       short l_101F             ; chybov˜ n vrat z programu

l_0FD1   ENDP

; -----------------------------------------------------------------------------
;        p©eru¨en¡ Ctrl-C
; -----------------------------------------------------------------------------

l_0FFC   PROC      NEAR

         xor       ax,ax
         xchg      al,ds:[d_0180]           ; n vratov˜ k¢d disk. operac¡
         ret

l_0FFC   ENDP

; -----------------------------------------------------------------------------
;        test, zda je nˆjak  chyba programu
; -----------------------------------------------------------------------------

l_1003   PROC      NEAR

         cmp       byte ptr ds:[d_0180],0   ; je nˆjak  chyba ?
         jne       l_100B                   ; je nˆjak  chyba
         ret

l_100B:  mov       dl,ds:[d_0180]           ; k¢d diskov‚ chyby
         mov       dh,1                     ; p©¡znak diskov‚ chyby
         jmp       short l_101F             ; chybov˜ n vrat z programu

l_1003   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 00h
; -----------------------------------------------------------------------------

l_1013   PROC      NEAR

         pop       bx                       ; offset n vratov‚ adresy
         pop       ax                       ; segment n vratov‚ adresy
         popf                               ; registr p©¡znak–
         push      bx                       ; offset n vratov‚ adresy
         mov       dl,4                     ; k¢d chyby (chyba dˆlen¡ nulou)
l_1019:  pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_101D:  mov       dh,2                     ; t©¡da chyb

l_101F:  push      dx
         call      l_09D9                   ; inicializace tabulky adres obsluh
         pop       dx
         mov       ax,ds:[d_0186]           ; adresa vzniku chyby programu
         sub       ax,3                     ; korekce - po‡ tek instrukce CALL
         xchg      ax,ds:[d_0188]
         or        ax,ax
         jnz       l_103D

         push      dx
         push      dx
         push      word ptr ds:[d_0188]
         call      word ptr ds:[d_017E]     ; adresa obsluhy p©eru¨en¡
         pop       dx

; ------ zobrazen¡ hl ¨en¡, ‘e je u‘ivatelsk‚ p©eru¨en¡ programu

l_103D:  cmp       dh,1                     ; je u‘ivatelsk‚ p©eru¨en¡ ?
         jae       l_1056                   ; nen¡ u‘ivatelsk‚ p©eru¨en¡
         call      l_0A62                   ; zobrazen¡ n sleduj¡c¡ho textu
         db        '^C',13,10,'User Break',0
         jmp       short l_1086

; ------ zobrazen¡ hl ¨en¡, ‘e je chyba vstupnˆ/v˜stupn¡ho za©¡zen¡

l_1056:  mov       byte ptr ds:[d_01FA],0FFh
         ja        l_1068
         call      l_0A62                   ; zobrazen¡ n sleduj¡c¡ho textu
         db        13,10,'I/O',0
         jmp       short l_1076

; ------ zobrazen¡ hl ¨en¡ pro jin‚ chyby

l_1068:  call      l_0A62                   ; zobrazen¡ n sleduj¡c¡ho textu
         db        13,10,'Run-time',0

; ------ zobrazen¡ zbytku hl ¨en¡ "error"

l_1076:  call      l_0A62                   ; zobrazen¡ n sleduj¡c¡ho textu
         db        ' error ',0

; ------ zobrazen¡ ‡¡sla chyby - bajt v HEX k¢du

         mov       al,dl                    ; ‡¡slo chyby
         call      l_0A93                   ; zobrazen¡ ‡¡sla chyby (v HEX k¢du)

; ------ zobrazen¡ textu "PC="

l_1086:  call      l_0A62
         db        ', PC=',0

; ------ zobrazen¡ adresy vzniku chyby (slovo v HEX k¢du)

         mov       ax,ds:[d_0188]           ; adresa vzniku chyby
         call      l_0A8C                   ; zobrazen¡ adresy chyby (v HEX)

; ------ zobrazen¡ textu "Program aborted"

         call      l_0A62
         db        13,10,'Program aborted',13,10,0

; ------ ukon‡en¡ programu

         mov       al,1                     ; n vratov˜ k¢d programu - chyba
         jmp       near ptr l_0C6A          ; ukon‡en¡ programu EXIT

l_10B1:  ret      4

l_1013   ENDP

; *****************************************************************************
;
;                     Z kladn¡ operace s ‡¡sly
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        absolutn¡ hodnota ‡¡sla AX
; -----------------------------------------------------------------------------

l_10B4   PROC      NEAR

         or        ax,ax                    ; je z porn‚ ‡¡slo ?
         jns       l_10BA                   ; je kladn‚ ‡¡slo OK
         neg       ax                       ; negace ‡¡sla
l_10BA:  ret

l_10B4   ENDP

; -----------------------------------------------------------------------------
;        vygenerov n¡ n hodn‚ho ‡¡sla s rozsahem AX
; -----------------------------------------------------------------------------

l_10BB   PROC      NEAR

         push      ax
         call      l_10C7                   ; generov n¡ n hodn‚ho ‡¡sla AX
         pop       bx                       ; po‘adovan˜ rozsah
         shr       ax,1                     ; vygenerovan‚ n hodn‚ ‡¡slo
         cwd                                ; DX:AX <- vygenerovan‚ ‡¡slo
         div       bx                       ; omezen¡ na rozsah
         xchg      ax,dx                    ; AX <- omezen‚ ‡¡slo
         ret

l_10BB   ENDP

; -----------------------------------------------------------------------------
;        v˜po‡et n hodn‚ho ‡¡sla
; -----------------------------------------------------------------------------

l_10C7   PROC      NEAR

; ------ st©ada‡ n hodn‚ho ‡¡sla

         mov       bx,word ptr ds:[d_01FC+2]
         mov       cx,word ptr ds:[d_01FC]
         push      bx
         push      cx

; ------ vyn soben¡*256 -> ‡¡slo * 256

         mov       al,bh
         mov       bh,bl
         mov       bl,ch
         mov       ch,cl
         xor       cl,cl

; ------ vydˆlen¡/2 -> ‡¡slo * 128
                                          ;* ‡as / 2 = ‡as * 128
         rcr       al,1
         rcr       bx,1
         rcr       cx,1                     ; ‡as / 2 = ‡as * 128

; ------ p©i‡ten¡ p–vodn¡ho ‡¡sla -> ‡¡slo * 129

         pop       ax                       ; setina a sekunda
         add       cx,ax
         pop       ax                       ; minuta a hodina
         adc       bx,ax

; ------ p©i‡ten¡ konstanty

         mov       ax,62E9h
         add       cx,ax
         mov       ax,3619h
         adc       bx,ax

; ------ ulo‘en¡ nov‚ho st©ada‡e n hodn‚ho ‡¡sla

         mov       word ptr ds:[1FEh],bx
         mov       word ptr ds:[1FCh],cx
         mov       ax,bx                    ; AX <- n hodn‚ ‡¡slo
         ret

l_10C7   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla AX do bufferu DS:BX (v dekadick‚m tvaru)
; -----------------------------------------------------------------------------

l_10FC   PROC      NEAR

; ------ oprava polarity ‡¡sla

         or        ax,ax                    ; je z porn‚ ‡¡slo ?
         jns       l_1106                   ; nen¡ z porn‚ ‡¡slo
         neg       ax                       ; absolutn¡ hodnota ‡¡sla
         mov       byte ptr [bx],"-"        ; znam‚nko ‡¡sla
         inc       bx                       ; zv˜¨en¡ ukazatele textu

; ------ dek¢dov n¡ jednotliv˜ch © d– ‡¡sla

l_1106:  xor       ch,ch                    ; CH <- 0 ‡¡ta‡ platn˜ch ‡¡slic
         mov       dx,10000
         call      l_1123                   ; ‡¡slice desetitis¡c–
         mov       dx,1000
         call      l_1123                   ; ‡¡slice tis¡c–
         mov       dx,100
         call      l_1123                   ; ‡¡slice stovek
         mov       dl,10
         call      l_1123                   ; ‡¡slice des¡tek
         mov       cl,al                    ; zbyl‚ jednotky
         jmp       short l_1137             ; ‡¡slice jednotek

; ------ dek¢dov n¡ jedn‚ ‡¡slice (jednoho © du)

l_1123:  xor       cl,cl                    ; CL <- 0 ‡¡ta‡ ‡¡slice
l_1125:  inc       cl                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slice
         sub       ax,dx                    ; ode‡ten¡ © du
         jnc       l_1125                   ; nen¡ je¨tˆ p©ete‡en¡
         add       ax,dx                    ; n vrat zbytku ‡¡sla
         inc       ch                       ; zv˜¨en¡ ‡¡ta‡e ‡¡slic
         dec       cl                       ; n vrat ‡¡slice
         jnz       l_1137                   ; nen¡ ‡¡slice 0
         dec       ch                       ; sn¡‘en¡ ‡¡ta‡e ‡¡slic
         jz        l_113D                   ; je to prvn¡ ‡¡slice - ru¨¡ se
l_1137:  add       cl,"0"                   ; korekce na znak ASCII
         mov       [bx],cl                  ; ulo‘en¡ dek¢dovan‚ ‡¡slice
         inc       bx                       ; zv˜¨en¡ ukl dac¡ adresy
l_113D:  ret

l_10FC   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ‡¡sla v HEX nebo DEK form tu
; -----------------------------------------------------------------------------
; VSTUP: DS:BX = text k dek¢dov n¡
; VSTUP: AX = na‡ten‚ ‡¡slo
;         CY = chyba
; -----------------------------------------------------------------------------

l_113E   PROC      NEAR

; ------ rozli¨en¡ ‡¡seln‚ soustavy

         xor       ax,ax                    ; AX <- 0 st©ada‡ hodnoty ‡¡sla
         cmp       byte ptr [bx],"$"        ; je prefix HEX ‡¡sla ?
         mov       dx,10                    ; z klad dekadick‚ ‡¡s. soustavy
         jne       l_114B                   ; nen¡ prefix HEX ‡¡sla
         mov       dl,16                    ; z klad hexadecim ln¡ soustavy

; ------ p©e‡ten¡ znaku z textu

l_114A:  inc       bx                       ; p©esko‡en¡ znaku "$"
l_114B:  push      ax                       ; st©ada‡ ‡¡sla
         mov       al,[bx]                  ; znak z textu
         call      l_0A81                   ; konverze na velk‚ p¡smeno
         mov       cl,al                    ; znak z textu
         pop       ax                       ; st©ada‡ ‡¡sla
         sub       cl,"0"                   ; konverze na ‡¡slo
         jc        l_117E                   ; nen¡ platn˜ znak
         cmp       cl,10                    ; je dekadick  ‡¡slice ?
         jb        l_1170                   ; je platn  dekadick  ‡¡slice OK
         cmp       dl,16                    ; je HEX soustava ?
         jne       l_117E                   ; nen¡ HEX soustava - chybn˜ znak
         sub       cl,7                     ; korekce znaku HEX
         cmp       cl,10                    ; je platn˜ znak ?
         jb        l_117E                   ; neplatn˜ znak
         cmp       cl,16                    ; je platn˜ znak ?
         jae       l_117E                   ; neplatn˜ znak

; ------ p©i‡ten¡ nov‚ ‡¡slice ke st©ada‡i

l_1170:  push      dx
         mul       dx                       ; vyn soben¡ st©ada‡e z kladem
         pop       dx
         jc        l_1187                   ; chyba - p©ete‡en¡ ‡¡sla
         xor       ch,ch                    ; CX = na‡ten  ‡¡slice
         add       ax,cx                    ; p©i‡ten¡ nov‚ ‡¡slice
         jnc       l_114A                   ; nen¡ p©ete‡en¡ - dal¨¡ ‡¡slice
         jmp       short l_1187             ; chyba - p©ete‡en¡ ‡¡sla

; ------ konec ‡¡sla - neplatn˜ znak

l_117E:  cmp       dl,16                    ; je HEX soustava ?
         je        l_1187                   ; je HEX soustava
         mov       cx,ax                    ; ‡¡slo pro dekadickou soustavu
         add       cx,cx                    ; na‡ten‚ ‡¡slo * 2
l_1187:  ret

l_113E   ENDP

; -----------------------------------------------------------------------------
;        ‡ten¡ ‡¡sla HEX nebo DEK se znam‚nkem
; -----------------------------------------------------------------------------

l_1188   PROC      NEAR

; ------ p©esko‡en¡ p©¡padn‚ho z porn‚ho znam‚nka

         mov       cl,[bx]                  ; prvn¡ znak ‡¡sla
         cmp       cl,"-"                   ; je z porn‚ ‡¡slo ?
         jne       l_1190                   ; nen¡ z porn‚ ‡¡slo
         inc       bx                       ; p©esko‡en¡ z porn‚ho znam‚nka

; ------ na‡ten¡ ‡¡sla v HEX nebo DEK form tu

l_1190:  push      cx
         call      l_113E                   ; ‡ten¡ ‡¡sla v HEX nebo DEK form tu
         pop       cx
         jc        l_11A0                   ; chyba zad n¡ ‡¡sla
         cmp       cl,"-"                   ; bylo zad no z porn‚ ‡¡slo ?
         jne       l_119E                   ; nebylo zad no z porn‚ ‡¡slo
         neg       ax                       ; negace na‡ten‚ho ‡¡sla
l_119E:  clc                                ; p©¡znak operace OK
         ret

; ------ chyba operace, ‡¡slo -32768 je je¨tˆ platn‚

l_11A0:  cmp       ax,8000h                 ; bylo na‡teno ‡¡slo 32768 ?
         jne       l_11AB                   ; nen¡ ‡¡slo 32768
         cmp       cl,"-"                   ; bylo ‡¡slo z porn‚ ?
         jne       l_11AB                   ; nebylo z porn‚
         ret                                ; toto ‡¡slo je platn‚

l_11AB:  stc                                ; p©¡znak chybn‚ho zad n¡ ‡¡sla
         ret

l_1188   ENDP

; *****************************************************************************
;
;                    Obsluha textov˜ch ©etˆzc–
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        p©enesen¡ ©etˆzce DI do z sobn¡ku
; -----------------------------------------------------------------------------
; VSTUP: DI = offset adresy ©etˆzce (1. bajt = d‚lka)
;        [SP+2] (2) segment adresy ©etˆzce
; -----------------------------------------------------------------------------

l_11AD   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         pop       es                       ; segment adresy ©etˆzce
         mov       si,di                    ; SI <- offset adresy ©etˆzce
         mov       cl,es:[si]               ; d‚lka ©etˆzce
         xor       ch,ch                    ; CH <- 0
         inc       cx                       ; d‚lka ©etˆzce + 1 (+bajt d‚lky)
         sub       sp,cx                    ; vytvo©en¡ bufferu v z sobn¡ku
         mov       di,sp                    ; za‡ tek bufferu v z sobn¡ku
         push      ds                       ; £schova datov‚ho segmentu
         push      es
         pop       ds                       ; DS <- segment adresy ©etˆzce
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         cld       
         rep       movsb                    ; p©enos ©etˆzce do z sobn¡ku
         pop       ds                       ; n vrat datov‚ho segmentu
         jmp       bx                       ; n vrat z procedury

l_11AD   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ ©etˆzce za instrukc¡ CALL do z sobn¡ku
; -----------------------------------------------------------------------------

l_11C6   PROC      NEAR

         pop       si                       ; n vratov  adresa z procedury
         mov       cl,cs:[si]               ; d‚lka ©etˆzce
         xor       ch,ch                    ; CH <- 0
         inc       cx                       ; p©i‡ten¡ 1 bajtu na bajt d‚lky
         sub       sp,cx                    ; vytvo©en¡ bufferu v z sobn¡ku
         mov       di,sp                    ; za‡ tek bufferu v z sobn¡ku
         push      ds                       ; £schova datov‚ho segmentu
         push      cs
         pop       ds                       ; DS <- CS
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         cld       
         rep       movsb                    ; p©enos ©etˆzce do z sobn¡ku
         pop       ds                       ; n vrat datov‚ho segmentu
         jmp       si                       ; n vrat z procedury

l_11C6   ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ ©etˆzce ze z sobn¡ku do bufferu
; -----------------------------------------------------------------------------
; VSTUP: CL = maxim ln¡ d‚lka ©etˆzce (velikost c¡lov‚ho bufferu)
;        [SP+2] (x) ©etˆzec k p©enesen¡ do bufferu
;        [SP+x] (4) adresa bufferu, do kter‚ho se m  ©etˆzec p©en‚st
; -----------------------------------------------------------------------------

l_11DC   PROC      NEAR

         pop       dx                       ; n vratov  adresa z procedury
         mov       al,cl                    ; velikost bufferu
         mov       bx,sp                    ; za‡ tek ©etˆzce v z sobn¡ku
         mov       cl,ss:[bx]               ; d‚lka ©etˆzce v z sobn¡ku
         xor       ch,ch                    ; CH <- 0
         add       bx,cx                    ; adresa konce ©etˆzce v z sobn¡ku
         inc       bx                       ; konec za ©etˆzcem v z sobn¡ku
         les       di,dword ptr ss:[bx]     ; adresa bufferu k ulo‘en¡ ©etˆzce
         mov       si,sp                    ; adresa ©etˆzce v z sobn¡ku
         cmp       cl,al                    ; je ©etˆzec del¨¡ ne‘ buffer ?
         jbe       l_11F7                   ; d‚lka ©etˆzce je OK
         mov       cl,al                    ; omezen¡ d‚lky ©etˆzce
         mov       ss:[si],al               ; nov  omezen  d‚lka ©etˆzce
l_11F7:  inc       cx                       ; korekce - v‡etnˆ bajtu d‚lky
         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         cld       
         rep       movsb                    ; p©enos ©etˆzce do bufferu
         pop       ds                       ; n vrat datov‚ho segmentu
         lea       sp,[bx+4]                ; nov  adresa ukazatele z sobn¡ku
         jmp       dx                       ; n vrat z procedury

l_11DC   ENDP

; -----------------------------------------------------------------------------
;        p©enesen¡ ©etˆzce do z sobn¡ku (ES:DI=adresa, CL=d‚lka)
; -----------------------------------------------------------------------------

l_1204   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         pop       es                       ; segment adresy ©etˆzce
         mov       si,di                    ; offset adresy ©etˆzce
         xor       ch,ch                    ; CH <- 0
         sub       sp,cx                    ; vytvo©en¡ bufferu v z sobn¡ku
         dec       sp                       ; m¡sto pro bajt d‚lky
         mov       di,sp                    ; za‡ tek bufferu v z sobn¡ku
         mov       ss:[di],cl               ; d‚lka p©en ¨en‚ho ©etˆzce
         inc       di                       ; adresa za‡ tku dat ©etˆzce
         push      ds                       ; £schova datov‚ho segmentu
         push      es
         pop       ds                       ; DS <- segment adresy ©etˆzce
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         cld       
         rep       movsb                    ; p©enos ©etˆzce do z sobn¡ku
         pop       ds                       ; n vrat datov‚ho segmentu
         jmp       bx                       ; n vrat z procedury

l_1204   ENDP

; -----------------------------------------------------------------------------
;        zmˆna d‚lky ©etˆzce v z sobn¡ku (CL=nov  d‚lka ©etˆzce)
; -----------------------------------------------------------------------------

l_121E   PROC      NEAR

; ------ p©¡prava registr–

         pop       bx                       ; n vratov  adresa z procedury
         xor       ch,ch                    ; CH <- 0
         mov       si,sp                    ; za‡ tek ©etˆzce v z sobn¡ku
         mov       al,ss:[si]               ; star  d‚lka ©etˆzce v z sobn¡ku
         xor       ah,ah                    ; AH <- 0
         sub       ax,cx                    ; rozd¡l d‚lek ©etˆzce
         mov       di,si                    ; za‡ tek ©etˆzce v z sobn¡ku
         add       di,ax                    ; nov˜ za‡ tek ©etˆzce v z sobn¡ku
         or        ax,ax                    ; jak  je zmˆna ©etˆzce ?
         jz        l_1259                   ; d‚lka ©etˆzce nezmˆnˆna
         jns       l_1245                   ; je zmen¨en¡ d‚lky ©etˆzce

; ------ prodlou‘en¡ ©etˆzce (©etˆzec se posune dol–)

         mov       sp,di                    ; nov˜ ukazatel z sobn¡ku
         mov       cl,ss:[si]               ; star  d‚lka ©etˆzce
         inc       cx                       ; v‡etnˆ bajtu d‚lky
         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         push      ss
         pop       es                       ; ES <- segment ©etˆzce v z sobn¡ku
         cld       
         rep       movsb                    ; posun ©etˆzce dol–
         pop       ds                       ; n vrat datov‚ho segmentu
         jmp       short l_1259

; ------ zkr cen¡ ©etˆzce (©etˆzec se posune nahoru)

l_1245:  mov       ss:[si],cl               ; plat¡ nov  d‚lka ©etˆzce
         add       di,cx                    ; adresa nov‚ho konce ©etˆzce
         add       si,cx                    ; adresa star‚ho konce ©etˆzce
         inc       cx                       ; v‡etnˆ bajtu d‚lky
         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         push      ss
         pop       es                       ; ES <- segment ©etˆzce v z sobn¡ku
         std       
         rep       movsb                    ; posun ©etˆzce nahoru
         pop       ds                       ; n vrat datov‚ho segmentu
         inc       di                       ; n vrat adresy po‡ tku ©etˆzce
         mov       sp,di                    ; ukazatel z sobn¡ku pod ©etˆzec
l_1259:  jmp       bx                       ; n vrat z procedury

l_121E   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ textov˜ch ©etˆzc– "=" (NZ=shoda)
; -----------------------------------------------------------------------------

l_125B   PROC      NEAR

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         je        l_1264                   ; podm¡nka splnˆna, ©etˆzce shodn‚
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_1264:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_125B   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– "<>" (NZ=nen¡ shoda)
; -----------------------------------------------------------------------------

l_1267   PROC      NEAR

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         jnz       l_1270                   ; podm¡nka splnˆna, ©etˆzce neshodn‚
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_1270:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_1267   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– ">=" (vˆt¨¡ nebo rovno)
; -----------------------------------------------------------------------------

l_1273   PROC      NEARE

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         jae       l_127C                   ; podm¡nka splnˆna, 1 vˆt¨¡/rovno 2
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_127C:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_1273   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– "<=" (men¨¡ nebo rovno)
; -----------------------------------------------------------------------------

l_127F   PROC      NEAR

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         jbe       l_1288                   ; podm¡nka splnˆna, 1 men¨¡/rovno 2
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_1288:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_127F   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– ">" (vˆt¨¡)
; -----------------------------------------------------------------------------

l_128B   PROC      NEAR

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         ja        l_1294                   ; podm¡nka splnˆna, 1 vˆt¨¡ ne‘ 2
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_1294:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_128B   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– "<" (men¨¡)
; -----------------------------------------------------------------------------

l_1297   PROC      NEAR

         call      l_12A3                   ; porovn n¡ dvou textov˜ch ©etˆzc–
         mov       ax,1                     ; p©¡znak - podm¡nka splnˆna
         jb        l_12A0                   ; podm¡nka splnˆna, 1 men¨¡ ne‘ 2
         dec       ax                       ; p©¡znak - podm¡nka nesplnˆna
l_12A0:  or        ax,ax                    ; je podm¡nka splnˆna ? (NZ=ano)
         ret

l_1297   ENDP

; -----------------------------------------------------------------------------
;        porovn n¡ dvou textov˜ch ©etˆzc– (CF a ZF nastaveny podle v˜sledku)
; -----------------------------------------------------------------------------

l_12A3   PROC      NEAR

; ------ parametry prvn¡ho ©etˆzce

         mov       di,sp                    ; ukazatel z sobn¡ku
         add       di,4                     ; p©esko‡en¡ n vratov˜ch adres
         mov       cl,ss:[di]               ; d‚lka prvn¡ho ©etˆzce
         xor       ch,ch                    ; CH <- 0
         inc       di                       ; za‡ tek prvn¡ho ©etˆzce

; ------ parametry druh‚ho ©etˆzce

         mov       si,di                    ; za‡ tek prvn¡ho ©etˆzce
         add       si,cx                    ; adresa druh‚ho ©etˆzce
         mov       dl,ss:[si]               ; d‚lka druh‚ho ©etˆzce
         xor       dh,dh                    ; DH <- 0
         inc       si                       ; za‡ tek druh‚ho ©etˆzce

; ------ adresa nov‚ho ukazatele v z sobn¡ku (po zru¨en¡ ©etˆzc–)

         mov       bx,si                    ; za‡ tek druh‚ho ©etˆzce
         add       bx,dx                    ; konec druh‚ho ©etˆzce (=nov˜ SP)

; ------ p©¡prava d‚lky - porovn v  se d‚lka men¨¡ho z ©etˆzc–

         mov       al,cl                    ; d‚lka prvn¡ho ©etˆzce
         mov       ah,dl                    ; d‚lka druh‚ho ©etˆzce
         cmp       cx,dx                    ; je ©etˆzec 1 del¨¡ ne‘ ©etˆzec 2 ?
         jbe       l_12C6                   ; ©etˆzec 1 nen¡ del¨¡ ne‘ ©etˆzec 2
         xchg      cx,dx                    ; z mˆna po©ad¡ - plat¡ d‚lka ©et. 2
l_12C6:  or        cx,cx                    ; jsou nˆjak  data k porovn n¡ ?
         jz        l_12D5                   ; nˆkter˜ ©etˆzec m  nulovou d‚lku

; ------ porovn n¡ ©etˆzc–

         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       es                       ; ES <- segment ©etˆzc– v z sobn¡ku
         push      ss
         pop       ds                       ; DS <- segment ©etˆzc– v z sobn¡ku
         cld       
         repe      cmpsb                    ; porovn n¡ obsahu ©etˆzc–
         pop       ds                       ; n vrat datov‚ho segmentu
         jne       l_12D7                   ; obsahy ©etˆzc– nejsou shodn‚
l_12D5:  cmp       ah,al                    ; p©i shodˆ porovn n¡ d‚lek ©etˆzc–

; ------ zru¨en¡ ©etˆzc– ze z sobn¡ku

l_12D7:  pop       dx                       ; n vratov  adresa 1
         pop       cx                       ; n vratov  adresa 2
         mov       sp,bx                    ; zru¨en¡ ©etˆzc– ze z sobn¡ku
         push      cx                       ; n vratov  adresa 2
         jmp       dx                       ; n vrat z procedury

l_12A3   ENDP

; -----------------------------------------------------------------------------
;        se‡ten¡ textov˜ch ©etˆzc–
; -----------------------------------------------------------------------------

l_12DE   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; p©echodn  £schova n vrat. adresy
         mov       di,sp                    ; za‡ tek prvn¡ho ©etˆzce
         mov       dl,ss:[di]               ; d‚lka prvn¡ho ©etˆzce
         xor       dh,dh                    ; DH <- 0
         mov       si,di                    ; za‡ tek prvn¡ho ©etˆzce
         inc       si                       ; za‡ tek dat prvn¡ho ©etˆzce
         add       si,dx                    ; za‡ tek druh‚ho ©etˆzce
         mov       cl,ss:[si]               ; d‚lka druh‚ho ©etˆzce
         add       dl,cl                    ; sou‡et d‚lek ©etˆzc–
         jc        l_131B                   ; chyba p©ete‡en¡ d‚lek ©etˆzc–
         mov       ss:[si],dl               ; nov  d‚lka sou‡tu ©etˆzc–
         xor       ch,ch                    ; CH <- 0
         sub       di,cx                    ; buffer k £schovˆ druh‚ho ©etˆzce
         mov       sp,di                    ; nov˜ ukazatel z sobn¡ku
         inc       cx                       ; v‡etnˆ bajtu d‚lky
         push      ds                       ; £scova datov‚ho segmentu
         push      si
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku
         push      ss
         pop       ds                       ; DS <- segment bufferu v z sobn¡ku
         cld       
         rep       movsb                    ; p©enos druh‚ho ©etˆzce pod prvn¡
         mov       di,si                    ; star˜ konec druh‚ho ©etˆzce
         pop       si                       ; za‡ tek druh‚ho ©etˆzce
         dec       si                       ; konec prvn¡ho ©etˆzce
         dec       di                       ; konec k ulo‘en¡ ©etˆzc–
         mov       cx,dx                    ; sou‡et d‚lek ©etˆzc–
         inc       cx                       ; v‡etnˆ bajtu d‚lky
         std       
         rep       movsb                    ; posun sou‡tu ©etˆzc– nahoru
         pop       ds
         inc       di                       ; n vrat ukazatele pod ©etˆzec
         mov       sp,di                    ; nov˜ ukazatel z sobn¡ku
         jmp       word ptr ds:[d_0186]     ; n vrat z procedury

l_131B:  mov       dl,10h                   ; chyba p©ete‡en¡ sou‡tu ©etˆzc–
         jmp       l_101D                   ; chybov‚ ukon‡en¡ programu

l_12DE   ENDP

; -----------------------------------------------------------------------------
;        vyjmut¡ pod©etˆzce z ©etˆzce (AX=d‚lka pod©etˆzce, [SP+2]=offset)
; -----------------------------------------------------------------------------

l_1320   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; p©echodn  £schova n vrat. adresy
         call      l_0AAA                   ; omezen¡ d‚lky pod©etˆzce
         mov       cx,ax                    ; d‚lka ©etˆzce k vyjmut¡
         pop       ax                       ; po‡et bajt– k vypu¨tˆn¡
         call      l_149B                   ; kontrola za‡ tku pod©etˆzce
         dec       ax                       ; korekce za‡ tku pod©etˆzce
         mov       si,sp                    ; za‡ tek ©etˆzce v z sobn¡ku
         mov       dl,ss:[si]               ; d‚lka ©etˆzce
         xor       dh,dh                    ; DH <- 0
         mov       di,sp                    ; za‡ tek ©etˆzce v z sobn¡ku
         add       di,dx                    ; adresa konce ©etˆzce
         sub       dx,ax                    ; d‚lka zbyl‚ ‡ sti bez za‡ tku
         jbe       l_1352                   ; nezbyla ‘ dn  data
         add       si,ax                    ; za‡ tek ©etˆzce k vyjmut¡
         cmp       dx,cx                    ; je cel˜ zbytek ©etˆzce ?
         jbe       l_1356                   ; je cel˜ zbytek ©etˆzce

         add       si,cx                    ; konec ©etˆzce k vyjmut¡
         mov       dx,cx                    ; nov  d‚lka ©etˆzce
         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       es                       ; ES <- segment ©etˆzce v z sobn¡ku
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         std       
         rep       movsb                    ; posun ©etˆzce nahoru
         pop       ds
         jmp       short l_1354

l_1352:  xor       dx,dx                    ; nezbyl ‘ dn˜ ©etˆzec
l_1354:  xchg      si,di                    ; SI <- nov˜ za‡ tek ©etˆzce
l_1356:  mov       ss:[si],dl               ; nov  d‚lka ©etˆzce
         mov       sp,si                    ; nov˜ ukazatel z sobn¡ku
         jmp       word ptr ds:[d_0186]     ; n vrat z procedury

l_1320   ENDP

; -----------------------------------------------------------------------------
;        stanoven¡ d‚lky ©etˆzce -> AX
; -----------------------------------------------------------------------------

l_135F   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         mov       di,sp                    ; za‡ tek ©etˆzce v z sobn¡ku
         mov       al,ss:[di]               ; d‚lka ©etˆzce v z sobn¡ku
         xor       ah,ah                    ; AH <- 0
         add       sp,ax                    ; zru¨en¡ ©etˆzce ze z sobn¡ku
         inc       sp                       ; korekce pro bajt d‚lky
         jmp       bx                       ; n vrat z procedury

l_135F   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ pod©etˆzce v ©etˆzci -> AX pozice v ©etˆzci
; -----------------------------------------------------------------------------

l_136C   PROC      NEAR

; ------ parametry prohled van‚ho ©etˆzce

         pop       word ptr ds:[d_0186]     ; p©echodn  £schova n vratov‚ adresy
         mov       di,sp                    ; za‡ tek ©etˆzce
         mov       dl,ss:[di]               ; d‚lka ©etˆzce
         xor       dh,dh                    ; DH <- 0
         inc       di                       ; za‡ tek dat ©etˆzce

; ------ parametry hledan‚ho pod©etˆzce

         mov       si,di                    ; za‡ tek dat ©etˆzce
         add       si,dx                    ; za‡ tek pod©etˆzce
         mov       cl,ss:[si]               ; d‚lka pod©etˆzce
         xor       ch,ch                    ; CH <- 0
         inc       si                       ; za‡ tek dat pod©etˆzce

; ------ kontrola, nen¡-li pod©etˆzec del¨¡ ne‘ prohled van˜ ©etˆzec

         mov       bx,si                    ; za‡ tek dat druh‚ho ©etˆzce
         add       bx,cx                    ; konec druh‚ho ©etˆzce
         xor       ax,ax                    ; AX <- 0 (p©¡znak - nenalezen)
         sub       dx,cx                    ; rozd¡l d‚lek ©etˆzc–
         jc        l_13AA                   ; ©etˆzec 1 je krat¨¡ ne‘ ©etˆzec 2

; ------ m -li pod©etˆzec nulovou d‚lku, je nalezen OK

         inc       ax                       ; AX = 1 (nalezen OK, pozice 1)
         or        cx,cx                    ; m  pod©etˆzec d‚lku 0 ?
         jz        l_13AA                   ; pod©etˆzec m  d‚lku 0 = nalezen OK

; ------ p©¡prava registr– k vyhled n¡ ©etˆzce

         inc       dx                       ; p©ednastaven¡ ‡¡ta‡e mo‘nost¡
         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       es                       ; ES <- segment ©etˆzce v z sobn¡ku
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         cld

; ------ vyhled n¡ pod©etˆzce

l_1398:  push      cx                       ; d‚lka pod©etˆzce
         push      di                       ; ukazatel v ©etˆzci
         push      si                       ; za‡ tek pod©etˆzce
         repe      cmpsb                    ; porovn n¡ pod©etˆzce
         pop       si
         pop       di
         pop       cx
         je        l_13A9                   ; pod©etˆzec nalezen OK
         inc       ax                       ; zv˜¨en¡ ukazatele offsetu
         inc       di                       ; zv˜¨en¡ ukazatele v ©etˆzci
         dec       dx                       ; sn¡‘en¡ ‡¡ta‡e mo‘n˜ch pozic
         jnz       l_1398                   ; test dal¨¡ pozice v ©etˆzci
         xor       ax,ax                    ; AX <- 0 (p©¡znak - nenalezen)
l_13A9:  pop       ds                       ; n vrat datov‚ho segmentu

l_13AA:  mov       sp,bx                    ; nov˜ ukazatel z sobn¡ku
         jmp       word ptr ds:[d_0186]     ; n vrat z procedury

l_136C   ENDP

; -----------------------------------------------------------------------------
;        sestaven¡ pln‚ho jm‚na souboru
; -----------------------------------------------------------------------------
; VSTUP: CL = velikost bufferu k ulo‘en¡ jm‚na souboru
;        AX = po‡ te‡n¡ offset jm‚na souboru v ozna‡en¡ souboru
;        [SP+2] (4) adresa jm‚na souboru s ozna‡en¡m disku (nap©. C:SOUB.TXT)
;                   (sem se ulo‘¡ v˜sledn‚ pln‚ ozna‡en¡ souboru)
;        [SP+6] (x) aktivn¡ adres © (bez ozna‡en¡ disku)
; -----------------------------------------------------------------------------

l_13B0   PROC      NEAR

; ------ p©¡prava registr–

         mov       ds:[d_0200],cl           ; velikost c¡lov‚ho bufferu
         mov       ds:[d_0202],ax           ; po‡et znak– na ozna‡en¡ disku
         pop       bx                       ; n vratov  adresa z procedury
         pop       word ptr ds:[d_0206]     ; offset jm‚na souboru s diskem
         pop       word ptr ds:[d_0206+2]   ; segment jm‚na souboru s diskem
         mov       word ptr ds:[d_020A],sp  ; adresa cesty k souboru
         mov       word ptr ds:[d_020A+2],ss
         push      bx                       ; n vratov  adresa z procedury

; ------ p©enesen¡ jm‚na souboru s diskem do z sobn¡ku

         les       di,ds:[d_0206]           ; adresa ©etˆzce
         push      es                       ; segment adresy ©etˆzce
         push      di                       ; offset adresy ©etˆzce
         push      es                       ; segment adresy ©etˆzce
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku

; ------ vyjmut¡ ozna‡en¡ disku (nap©. C:)

         mov       ax,1                     ; po‡ te‡n¡ pozice v ©etˆzci
         push      ax                       ; offset - po‡ te‡n¡ pozice
         mov       ax,ds:[d_0202]           ; d‚lka pod©etˆzce
         dec       ax                       ;
         call      l_1320                   ; vyjmut¡ pod©etˆzce z ©etˆzce

; ------ p©id n¡ pln‚ cesty k souboru

         les       di,ds:[d_020A]           ; adresa ©etˆzce (adres ©)
         push      es                       ; segment adresy ©etˆzce
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ p©enesen¡ jm‚na souboru do z sobn¡ku

         les       di,ds:[d_0206]           ; adresa ©etˆzce
         push      es                       ; segment adresy ©etˆzce
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku

; ------ vypu¨tˆn¡ ozna‡en¡ disku z po‡ tku jm‚na souboru

         push      word ptr ds:[d_0202]     ; po‡et znak– na ozna‡en¡ disku
         mov       ax,0FFh                  ; cel˜ zbytek textu
         call      l_1320                   ; vyjmut¡ pod©etˆzce z ©etˆzce

; ------ p©id n¡ jm‚na souboru k pln‚ cestˆ

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ p©enesen¡ v˜sledn‚ho jm‚na souboru zpˆt do bufferu

         mov       cl,ds:[d_0200]           ; velikost bufferu
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         jmp       l_135F                   ; stanoven¡ d‚lky ©etˆzce

l_13B0   ENDP

; -----------------------------------------------------------------------------
;        vyjmut¡ cesty z ozna‡en¡ souboru
; -----------------------------------------------------------------------------
; VSTUP: AX = d‚lka textu cesty
;        [SP+2] (2) po‡et znak– na ozna‡en¡ disku
;        [SP+4] (4) adresa textu jm‚na souboru (pln‚ ozna‡en¡ s cestou)
; -----------------------------------------------------------------------------

l_1408   PROC      NEAR

         mov       word ptr ds:[204h],ax    ; d‚lka textu cesty (bez disku)
         pop       bx                       ; n vratov  adresa z procedury
         pop       word ptr ds:[202h]       ; po‡et znak– na ozna‡en¡ disku
         pop       word ptr ds:[206h]       ; offset adresy jm‚na souboru
         pop       word ptr ds:[208h]       ; segment adresy jm‚na souboru
         push      bx                       ; n vratov  adresa z procedury

; ------ p©enesen¡ specifikace souboru do bufferu v z sobn¡ku

         les       di,dword ptr ds:[206h]   ; adresa jm‚na souboru
         push      es                       ; segment adresy jm‚na souboru
         push      di                       ; offset adresy jm‚na souboru
         push      es                       ; segment adresy jm‚na souboru
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku

; ------ vyjmut¡ ozna‡en¡ disku z cesty

         mov       ax,1                     ; po‡ te‡n¡ offset = za‡ tek
         push      ax
         mov       ax,word ptr ds:[202h]    ; po‡et znak– na ozna‡en¡ disku
         dec       ax
         call      l_1320                   ; vyjmut¡ pod©etˆzce z ©etˆzce

; ------ p©enesen¡ specifikace souboru do bufferu v z sobn¡ku

         les       di,dword ptr ds:[206h]   ; adresa jm‚na souboru
         push      es                       ; segment adresy jm‚na souboru
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku

; ------ vyjmut¡ jm‚na souboru

         mov       ax,word ptr ds:[202h]    ; po‡et znak– na ozna‡en¡ disku
         add       ax,word ptr ds:[204h]    ; d‚lka textu cesty (bez disku)
         push      ax
         mov       ax,0FFh                  ; d‚lka - a‘ po konec
         call      l_1320                   ; vyjmut¡ pod©etˆzce z ©etˆzce

; ------ se‡ten¡ ozna‡en¡ disku a jm‚na souboru

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ p©enesen¡ jm‚na souboru zpˆt do bufferu

         mov       cl,0FFh                  ; velikost bufferu (neomezen )
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         ret

l_1408   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_144D   PROC      NEAR

         pop       bx
         pop       ax
         dec       al
         jnz       l_1457
         xchg      al,ah
         jmp       bx

l_1457:  mov       ds:[d_0186],bx           ; adresa vzniku chyby programu
         mov       dl,10h
         jmp       l_101D                   ; chybov‚ p©eru¨en¡ programu

l_144D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1460   PROC      NEAR

         mov       si,sp
         mov       bl,ss:[si+2]
         xor       bh,bh
         mov       ax,ss:[bx+si+3]
         mov       ah,al
         mov       al,1
         mov       ss:[bx+si+3],ax
         ret

l_1460   ENDP

; -----------------------------------------------------------------------------
;        redukce d‚lky ©etˆzce (vypu¨tˆn¡ bajt– po zkr cen¡ d‚lky)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (x) ©etˆzec k redukci (1. bajt = d‚lka ©etˆzce)
;        CL=d‚lka bufferu s ©etˆzcem
;        DX=po‡et bajt– ke zru¨en¡ ze z sobn¡ku
; -----------------------------------------------------------------------------

l_1475   PROC      NEAR

; ------ kontrola, zda byl ©etˆzec operac¡ zkr cen

         pop       bx                       ; n vratov  adresa z procedury
         add       sp,dx                    ; adresa za‡ tku ©etˆzce
         mov       si,sp                    ; za‡ tek ©etˆzce
         mov       al,ss:[si]               ; d‚lka ©etˆzce
         cmp       al,cl                    ; souhlas¡ s p–vodn¡ d‚lkou ?
         je        l_1499                   ; ©etˆzec nebyl zkr cen

; ------ p©¡prava registr–

         xor       ah,ah                    ; AH <- 0
         add       si,ax                    ; adresa nov‚ho konce ©etˆzce
         mov       di,sp                    ; za‡ tek ©etˆzce
         xor       ch,ch                    ; CH <- 0
         add       di,cx                    ; p–vodn¡ konec ©etˆzce
         xchg      ax,cx                    ; CX <- nov  d‚lka ©etˆzce
         inc       cx                       ; v‡etnˆ bajtu d‚lky

; ------ posun ©etˆzce nahoru o vypu¨tˆn‚ bajty

         push      ds                       ; £schova datov‚ho segmentu
         push      ss
         pop       ds                       ; DS <- segment ©etˆzce v z sobn¡ku
         push      ss
         pop       es                       ; ES <- segment ©etˆzce v z sobn¡ku
         std       
         rep       movsb                    ; p©esun ©etˆzce nahoru
         pop       ds                       ; n vrat datov‚ho segmentu
         inc       di                       ; adresa za‡ tku ©etˆzce
         mov       sp,di                    ; nov˜ ukazatel z sobn¡ku
l_1499:  jmp       bx                       ; n vrat z procedury

l_1475   ENDP

; -----------------------------------------------------------------------------
;        kontrola offsetu v ©etˆzci (v rozsahu 1 a‘ 255)
; -----------------------------------------------------------------------------

l_149B   PROC      NEAR

         or        ah,ah                    ; povolen offset maxim lnˆ 255
         jnz       l_14A4                   ; p©ete‡en¡
         or        al,al                    ; povolen offset minim lnˆ 1
         jz        l_14A4                   ; podte‡en¡
         ret

l_14A4:  mov       dl,11h                   ; k¢d chyby
         jmp       l_101D                   ; chybov‚ ukon‡en¡ programu

l_149B   ENDP

; -----------------------------------------------------------------------------
;        (nepou‘¡v  se)
; -----------------------------------------------------------------------------

l_14A9   PROC      NEAR

         pop       bx                       ; n vratov  adresa z procedury
         pop       dx
         mov       si,di
         sub       sp,32                    ; vytvo©en¡ bufferu v z sobn¡ku
         mov       di,sp                    ; DI <- buffer v z sobn¡ku

         push      cx
         push      ss
         pop       es                       ; ES <- segment bufferu v z sobn¡ku

         cld
         or        ch,ch
         jz        l_14C1
         xor       al,al
l_14BC:  stosb
         dec       ch
         jnz       l_14BC

l_14C1:  push      ds
         mov       ds,dx
         rep       movsb
         pop       ds

         pop       cx
         mov       ah,32
         sub       ah,ch
         sub       ah,cl
         jz        l_14D7
         xor       al,al
l_14D2:  stosb
         dec       ah
         jnz       l_14D2

l_14D7:  jmp       bx                       ; n vrat z procedury

l_14A9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_14D9   PROC      NEAR

         pop       bx
         sub       sp,20h
         mov       di,sp
         push      ss
         pop       es
         mov       cx,10h
         xor       ax,ax
         cld       
         rep       stosw
         jmp       bx

l_14D9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_14EB   PROC      NEAR

         call      l_15DD
         or        ss:[bx],al
         ret

l_14EB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_14F2   PROC      NEAR

         xchg      ax,cx
         pop       bx
         pop       ax
         push      bx
         sub       cl,al
         jc        l_1510
         xor       ch,ch
         inc       cx
         mov       ah,cl
         call      l_15DD
         mov       cl,ah
l_1504:  or        ss:[bx],al
         shl       al,1
         jnc       l_150E
         inc       bx
         mov       al,1
l_150E:  loop      l_1504
l_1510:  ret

l_14F2   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1511   PROC      NEAR

         mov       si,sp
         inc       si
         inc       si
         mov       di,ss:[si+20h]
         mov       es,ss:[si+22h]
         mov       dl,ch
         xor       dh,dh
         add       si,dx
         xor       ch,ch
         push      ds
         push      ss
         pop       ds
         cld       
         rep       movsb
         pop       ds
         ret      24h

l_1511   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_152F   PROC      NEAR

         pop       bx
         mov       dl,ch
         xor       dh,dh
         xor       ch,ch
         mov       si,sp
         add       si,dx
         add       si,cx
         mov       di,sp
         add       di,20h
         cmp       si,di
         je        l_1553
         dec       si
         dec       di
         push      ds
         push      ss
         pop       es
         push      ss
         pop       ds
         std       
         rep       movsb
         pop       ds
         inc       di
         mov       sp,di
l_1553:  jmp       bx

l_152F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1555   PROC      NEAR

         mov       ax,1
         jmp       short l_155C

l_1555   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_155A   PROC      NEAR

         xor       ax,ax
l_155C:  call      l_15F4
         repe      cmpsw
         mov       ds,dx
         jz        l_1568
         xor       ax,1
l_1568:  or        ax,ax
         ret       40h

l_155A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_156D   PROC      NEAR

         xor       ax,ax
         jmp       short l_1574

l_156D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1571   PROC      NEAR

         mov       ax,1
l_1574:  call      l_15F4
         dec       ax
         jnz       l_157C
         xchg      di,si
l_157C:  lodsw
         or        ax,[di]
         scasw     
         jnz       l_1589
         loop      l_157C
         mov       ax,1
         jmp       short l_158B
l_1589:  xor       ax,ax
l_158B:  mov       ds,dx
         or        ax,ax
         ret       40h

l_1571   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1592   PROC      NEAR

         call      l_15F4
l_1595:  lodsw
         or        ax,[di]
         stosw     
         loop      l_1595

         mov       ds,dx
         ret       20h

l_1592   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_15A0   PROC      NEAR

         call      l_15F4
l_15A3:  lodsw
         not       ax
         and       ax,[di]
         stosw     
         loop      l_15A3
         mov       ds,dx
         ret       20h

l_15A0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_15B0   PROC      NEAR

         call      l_15F4
l_15B3:  lodsw
         and       ax,[di]
         stosw     
         loop      l_15B3
         mov       ds,dx
         ret       20h

l_15B0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_15BE   PROC      NEAR

         mov       bx,sp
         mov       ax,ss:[bx+22h]
         or        ah,ah
         jz        l_15CC
         xor       ax,ax
         jmp       short l_15D8
l_15CC:  call      l_15DD
         and       al,ss:[bx]
         mov       ax,0
         jz        l_15D8
         inc       ax
l_15D8:  or        ax,ax
         ret      22h

l_15BE   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_15DD   PROC      NEAR

         mov       bl,al
         xor       bh,bh
         mov       cl,3
         shr       bx,cl
         add       bx,4
         add       bx,sp
         mov       cl,al
         and       cl,7
         mov       al,1
         shl       al,cl
         ret

l_15DD   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_15F4   PROC      NEAR

         mov       si,sp
         add       si,4
         mov       di,sp
         add       di,24h
         mov       dx,ds
         push      ss
         pop       es
         push      ss
         pop       ds
         mov       cx,10h
         cld       
         ret

l_15F4   ENDP

; -----------------------------------------------------------------------------
;        test shody DX:AX a CX:BX (NZ=shoda)
; -----------------------------------------------------------------------------

l_1609   PROC      NEAR

         cmp       ax,bx
         mov       ax,0
         jne       l_1615
         cmp       dx,cx
         jne       l_1615
         inc       ax
l_1615:  or        ax,ax
         ret

l_1609   ENDP

; -----------------------------------------------------------------------------
;        test neshody DX:AX a CX:BX (ZY=shoda)
; -----------------------------------------------------------------------------

l_1618   PROC      NEAR

         cmp       ax,bx
         mov       ax,1
         jne       l_1624
         cmp       dx,cx
         jne       l_1624
         dec       ax
l_1624:  or        ax,ax
         ret

l_1618   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1627   PROC      NEAR

         mov       word ptr ds:[d_0220],8000h
         jmp       short l_1635

l_1627   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_162F   PROC      NEAR

         mov       word ptr ds:[d_0220],0
l_1635:  or        cl,cl
         jz        l_1647
         xor       di,ds:[d_0220]
         or        al,al
         jnz       l_1648
l_1641:  mov       ax,cx
         mov       bx,si
         mov       dx,di
l_1647:  ret

l_1648:  cmp       al,cl
         jbe       l_1651
         xchg      ax,cx
         xchg      bx,si
         xchg      dx,di
l_1651:  mov       ds:[d_0224],cl
         sub       cl,al
         cmp       cl,28h
         jb        l_1662
         mov       cl,ds:[d_0224]
         jmp       short l_1641

l_1662:  mov       ds:[d_0220],di
         and       byte ptr ds:[d_0220+1],80h
         mov       ds:[d_0222],di
         xor       byte ptr ds:[d_0222+1],dh
         or        di,8000h
         or        dh,80h
l_167A:  cmp       cl,10h
         jb        l_168A
         mov       ah,bh
         mov       bx,dx
         xor       dx,dx
         sub       cl,10h
         jmp       short l_167A

l_168A:  cmp       cl,8
         jb        l_169C
         mov       ah,bl
         mov       bl,bh
         mov       bh,dl
         mov       dl,dh
         xor       dh,dh
         sub       cl,8
l_169C:  or        cl,cl
         jz        l_16AA
l_16A0:  shr       dx,1
         rcr       bx,1
         rcr       ah,1
         dec       cl
         jnz       l_16A0
l_16AA:  mov       al,ds:[d_0224]
         test      byte ptr ds:[d_0222+1],80h
         jnz       l_16C8
         add       ah,ch
         adc       bx,si
         adc       dx,di
         jnc       l_171A
         rcr       dx,1
         rcr       bx,1
         rcr       ah,1
         inc       al
         jnz       l_171A
         stc       
         ret

l_16C8:  xchg      ah,ch
         xchg      bx,si
         xchg      dx,di
         sub       ah,ch
         sbb       bx,si
         sbb       dx,di
         jnc       l_16EA
         xor       byte ptr ds:[d_0220+1],80h
         not       ah
         not       bx
         not       dx
         add       ah,1
         adc       bx,0
         adc       dx,0
l_16EA:  mov       cl,5
l_16EC:  or        dh,dh
         jnz       l_1704
         mov       dh,dl
         mov       dl,bh
         mov       bh,bl
         mov       bl,ah
         xor       ah,ah
         sub       al,8
         jc        l_1713
         dec       cl
         jnz       l_16EC
         jmp       short l_1713

l_1704:  test      dh,80h
         jnz       l_171A
         shl       ah,1
         rcl       bx,1
         rcl       dx,1
         dec       al
         jnz       l_1704
l_1713:  xor       ax,ax
         xor       bx,bx
         xor       dx,dx
         ret

l_171A:  and       dh,7Fh
         xor       dh,byte ptr ds:[d_0220+1]
         ret

l_162F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1722   PROC      NEAR

         or        cl,cl
         jz        l_1795
         or        al,al
         jz        l_179B
         add       al,cl
         call      l_1833
         mov       ds:[d_020E],ax
         mov       ds:[d_0210],bx
         mov       ds:[d_0212],dx
         xor       ah,ah
         xor       bx,bx
         xor       dx,dx
         mov       di,offset d_0214
         mov       cl,5
l_1745:  inc       di
         mov       ch,[di]
         or        ch,ch
         jnz       l_1758
         mov       ah,bl
         mov       bl,bh
         mov       bh,dl
         mov       dl,dh
         xor       dh,dh
         jmp       short l_1774
l_1758:  mov       si,8
l_175B:  rcr       ch,1
         jnc       l_176B
         add       ah,byte ptr ds:[d_020E+1]
         adc       bx,ds:[d_0210]
         adc       dx,ds:[d_0212]
l_176B:  rcr       dx,1
         rcr       bx,1
         rcr       ah,1
         dec       si
         jnz       l_175B
l_1774:  dec       cl
         jnz       l_1745
         xchg      ax,cx
         lahf      
         test      dh,80h
         jnz       l_178C
         sahf      
         rcl       ch,1
         rcl       bx,1
         rcl       dx,1
         or        cl,cl
         jz        l_178C
         dec       cl
l_178C:  xchg      ax,cx
         xor       dh,byte ptr ds:[d_0220+1]
         or        al,al
         jnz       l_179B
l_1795:  xor       ax,ax
         xor       bx,bx
         xor       dx,dx
l_179B:  ret

l_1722   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_179C   PROC      NEAR

         or        al,al
         jz        l_179B
         sub       al,cl
         cmc       
         call      l_1833
         mov       byte ptr ds:[d_020E],al
         mov       di,offset d_0212+1
         mov       cl,5
         mov       si,8
l_17B1:  cmp       dx,ds:[d_0218]
         jne       l_17C1
         cmp       bx,ds:[d_0216]
         jne       l_17C1
         cmp       ah,byte ptr ds:[d_0214+1]
l_17C1:  jb        l_17CF
         sub       ah,byte ptr ds:[d_0214+1]
         sbb       bx,ds:[d_0216]
         sbb       dx,ds:[d_0218]
l_17CF:  cmc
         rcl       ch,1
         dec       si
         jnz       l_17DF
         mov       [di],ch
         dec       cl
         jz        l_17F6
         dec       di
         mov       si,8
l_17DF:  shl       ah,1
         rcl       bx,1
         rcl       dx,1
         jnc       l_17B1
         sub       ah,byte ptr ds:[d_0214+1]
         sbb       bx,ds:[d_0216]
         sbb       dx,ds:[d_0218]
         clc       
         jmp       short l_17CF

l_17F6:  shl       ah,1
         rcl       bx,1
         rcl       dx,1
         jc        l_180F
         cmp       dx,ds:[d_0218]
         jne       l_180E
         cmp       bx,ds:[d_0216]
         jne       l_180E
         cmp       ah,byte ptr ds:[d_0214+1]
l_180E:  cmc
l_180F:  mov       cx,ds:[d_020E]
         mov       bx,ds:[d_0210]
         mov       dx,ds:[d_0212]
         lahf
         test      dh,80h
         jnz       l_182A
         sahf      
         rcl       ch,1
         rcl       bx,1
         rcl       dx,1
         jmp       short l_1830
l_182A:  inc       cl
         jnz       l_1830
         stc       
         ret
l_1830:  jmp       l_178C

l_179C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1833   PROC      NEAR

         jc        l_1841
         add       al,80h
         jc        l_1848
         pop       bx
         xor       ax,ax
         xor       bx,bx
         xor       dx,dx
         ret

l_1841:  add       al,80h
         jnc       l_1848
         pop       bx
         stc       
         ret

l_1848:  mov       ds:[d_0214],cx
         mov       cx,dx
         xor       cx,di
         not       ch
         and       ch,80h
         mov       byte ptr ds:[d_0220+1],ch
         or        dh,80h
         or        di,8000h
         mov       ds:[d_0216],si
         mov       ds:[d_0218],di
         ret

l_1833   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1869   PROC      NEAR

         push      di
         push      si
         push      cx
         call      l_162F
         pop       cx
         pop       si
         pop       di
         ret

l_1869   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1873   PROC      NEAR

         push      di
         push      si
         push      cx
         call      l_1627
         pop       cx
         pop       si
         pop       di
         ret

l_1873   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_187D   PROC      NEAR

         push      di
         push      si
         push      cx
         call      l_1722
         pop       cx
         pop       si
         pop       di
         ret

l_187D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1887   PROC      NEAR

         push      di
         push      si
         push      cx
         call      l_179C
         pop       cx
         pop       si
         pop       di
         ret

l_1887   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1891   PROC      NEAR

         push      dx
         xor       dx,di
         pop       dx
         jns       l_189C
         push      dx
         rcl       dx,1
         pop       dx
         ret

l_189C:  test      dh,80h
         jz        l_18A8
         call      l_18A8
         jz        l_18BA
         cmc       
         ret

l_18A8:  cmp       al,cl
         jne       l_18BA
         or        al,al
         jz        l_18BA
         cmp       dx,di
         jne       l_18BA
         cmp       bx,si
         jne       l_18BA
         cmp       ah,ch
l_18BA:  ret

l_1891   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_18BB   PROC      NEAR

         or        ax,ax
         jnz       l_18C4
         xor       bx,bx
         xor       dx,dx
         ret

l_18C4:  mov       bh,ah
         mov       dx,ax
         or        dx,dx
         jns       l_18CE
         neg       dx
l_18CE:  mov       ax,90h
         or        dh,dh
         jnz       l_18D9
         mov       al,88h
         xchg      dl,dh
l_18D9:  or        dx,dx
         js        l_18E3
l_18DD:  dec       al
         shl       dx,1
         jns       l_18DD
l_18E3:  or        bh,bh
         js        l_18EA
         and       dh,7Fh
l_18EA:  xor       bx,bx
         ret

l_18BB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_18ED   PROC      NEAR

         cmp       al,0A8h
         jae       l_193A
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         xor       ah,ah
         xor       bx,bx
         xor       dx,dx
         sub       cl,80h
         jbe       l_193B
l_1902:  cmp       cl,10h
         jb        l_1913
         mov       ah,bh
         mov       bx,dx
         mov       dx,0FFFFh
         sub       cl,10h
         jmp       short l_1902

l_1913:  cmp       cl,8
         jb        l_1925
         mov       ah,bl
         mov       bl,bh
         mov       bh,dl
         mov       dl,dh
         mov       dh,0FFh
         sub       cl,8
l_1925:  or        cl,cl
         jz        l_1934
l_1929:  stc
         rcr       dx,1
         rcr       bx,1
         rcr       ah,1
         dec       cl
         jnz       l_1929
l_1934:  and       dx,di
         and       bx,si
         and       ah,ch
l_193A:  ret

l_193B:  xor       al,al
         ret

l_18ED   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_193E   PROC      NEAR

         push      dx
         push      bx
         push      ax
         call      l_18ED
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         pop       ax
         pop       bx
         pop       dx
         jmp       l_1627

l_193E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1950   PROC      NEAR

         pop       bx
         pop       es
         push      word ptr es:[di+4]
         push      word ptr es:[di+2]
         push      word ptr es:[di]
         jmp       bx

l_1950   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_195F   PROC      NEAR

         pop       bx
         push      word ptr cs:[bx+4]
         push      word ptr cs:[bx+2]
         push      word ptr cs:[bx]
         add       bx,6
         jmp       bx

l_195F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1970   PROC      NEAR

         pop       bx
         pop       ax
         pop       cx
         pop       dx
         pop       di
         pop       es
         mov       es:[di],ax
         mov       es:[di+2],cx
         mov       es:[di+4],dx
         jmp       bx

l_1970   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1983   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_162F
l_1990:  jc        l_1999
l_1992:  push      dx
         push      bx
         push      ax
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_1999:  mov       dl,1
         jmp       l_101D

l_1983   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_199E   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1627
         jmp       short l_1990

l_199E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_19AD   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
l_19B7:  call      l_1722
         jmp       short l_1990

l_19AD   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_19BC   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         or        cl,cl
         jz        l_19CF
         call      l_179C
         jmp       short l_1990

l_19CF:  mov       dl,2
         jmp       l_101D

l_19BC   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_19D4   PROC      NEAR

         mov       bx,sp
         cmp       byte ptr ss:[bx+2],0
         je        l_19E2
         xor       byte ptr ss:[bx+7],80h
l_19E2:  ret

l_19D4   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_19E3   PROC      NEAR

         mov       bx,sp
         and       byte ptr ss:[bx+7],7Fh
         ret

l_19E3   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_19EB   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         jz        l_1A02
         dec       ax
l_1A02:  or        ax,ax
         ret

l_19EB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A05   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         jnz       l_1A1C
         dec       ax
l_1A1C:  or        ax,ax
         ret

l_1A05   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A1F   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         jnc       l_1A36
         dec       ax
l_1A36:  or        ax,ax
         ret

l_1A1F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A39   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         jbe       l_1A50
         dec       ax
l_1A50:  or        ax,ax
         ret

l_1A39   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A53   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         ja        l_1A6A
         dec       ax
l_1A6A:  or        ax,ax
         ret

l_1A53   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A6D   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         pop       bx
         pop       dx
         call      l_1891
         push      word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         mov       ax,1
         jc        l_1A84
         dec       ax
l_1A84:  or        ax,ax
         ret

l_1A6D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A87   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         jmp       l_19B7

l_1A87   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1A97   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         call      l_18ED
         jmp       l_1992

l_1A97   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1AA4   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         call      l_193E
         jmp       l_1992

l_1AA4   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1AB1   PROC      NEAR

         call      l_10C7                   ; generov n¡ n hodn‚ho ‡¡sla AX
         mov       dx,80h
         mov       al,20h
l_1AB9:  test      bh,80h
         jnz       l_1ACA
         shl       cx,1
         rcl       bx,1
         dec       dl
         dec       al
         jnz       l_1AB9
         xor       dl,dl
l_1ACA:  and       bh,7Fh
         pop       ax
         push      bx
         push      cx
         push      dx
         jmp       ax

l_1AB1   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1AD3   PROC      NEAR

         mov       ch,0FFh
         jmp       short l_1AD9

l_1AD3   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1AD7   PROC      NEAR

         xor       ch,ch
l_1AD9:  pop       bx
         pop       ax
         pop       dx
         pop       dx
         push      bx

l_1AD7   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1ADE   PROC      NEAR

         xchg      ax,dx
         mov       cl,8Fh
         sub       cl,dl
         jc        l_1B07
         cmp       cl,0Fh
         ja        l_1B04
         inc       cl
         mov       bh,ah
         or        ah,80h
         shr       ax,cl
         jnc       l_1AFC
         or        ch,ch
         jz        l_1AFC
         inc       ax
         js        l_1B07
l_1AFC:  test      bh,80h
         jz        l_1B03
         neg       ax
l_1B03:  ret

l_1B04:  xor       ax,ax
         ret

l_1B07:  mov       dl,92h
         jmp       l_1019

l_1ADE   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------


l_1B0C   PROC      NEAR

         call      l_18BB
         pop       cx
         push      dx
         push      bx
         push      ax
         jmp       cx

l_1B0C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1B15   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         pop       ax
         call      l_18BB
         push      dx
         push      bx
         push      ax
         push      di
         push      si
         push      cx
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu

l_1B15   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1B2A   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         or        al,al
         jz        l_1B7C
         test      dh,80h
         jnz       l_1B83
         mov       ds:[d_021A],ax
         mov       ds:[d_021C],bx
         mov       ds:[d_021E],dx
         add       cl,80h
         sar       cl,1
         add       cl,80h
         mov       al,cl
         sub       al,14h
         mov       ds:[d_0225],al
l_1B5A:  mov       ax,ds:[d_021A]
         mov       bx,ds:[d_021C]
         mov       dx,ds:[d_021E]
         call      l_1887
         call      l_1869
         dec       al
         push      dx
         push      bx
         push      ax
         call      l_1627
         cmp       al,ds:[d_0225]
         pop       cx
         pop       si
         pop       di
         jnc       l_1B5A
l_1B7C:  push      di
         push      si
         push      cx
         jmp       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
l_1B83:  mov       dl,3
         jmp       l_101D

l_1B2A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1B88   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       cx
         pop       si
         pop       di
         mov       ax,2181h
         mov       bx,0DAA2h
         mov       dx,490Fh
         call      l_1627
         jmp       short l_1BA4

l_1B88   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1B9D   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
l_1BA4:  cmp       al,6Ch
         jb        l_1C03
         mov       cx,2183h
         mov       si,0DAA2h
         mov       di,490Fh
         push      dx
         and       dh,7Fh
         call      l_1891
         pop       dx
         jc        l_1BCA
         call      l_1887
         push      di
         push      si
         push      cx
         call      l_193E
         pop       cx
         pop       si
         pop       di
         call      l_187D
l_1BCA:  test      dh,80h
         jz        l_1BD2
         call      l_1869
l_1BD2:  dec       cl
         call      l_1891
         pushf     
         jc        l_1BDD
         call      l_1873
l_1BDD:  dec       cl
         call      l_1891
         jc        l_1BEC
         inc       cl
         or        dh,80h
         call      l_162F
l_1BEC:  cmp       al,6Ch
         jb        l_1BF9
         mov       di,offset l_1C06
         mov       cx,7
         call      l_1EBF
l_1BF9:  popf
         jc        l_1C03
         or        al,al
         jz        l_1C03
         xor       dh,80h
l_1C03:  jmp       l_1992

l_1B9D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1C06   db        58h,9dh,39h,9fh,3fh,0d7h
         db        60h, 43h, 9Dh, 30h, 92h, 30h
         db        67h,0AAh, 3Fh, 28h, 32h,0D7h
         db        6Eh,0B6h, 2Ah, 1Dh,0EFh, 38h
         db        74h, 0Dh,0D0h, 00h, 0Dh,0D0h
         db        7Ah, 88h, 88h, 88h, 88h, 08h
         db        7Eh,0ABh,0AAh
         db        0AAh,0AAh,0AAh

;==========================================================================
;                  SUBROUTINE
;==========================================================================

l_1C30   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         or        al,al
         jz        l_1C40
         test      dh,80h
         jz        l_1C45
l_1C40:  mov       dl,4
         jmp       l_101D

l_1C45:  mov       ch,ah
         mov       cl,81h
         sub       al,cl
         cbw       
         push      ax
         xchg      ax,cx
         mov       cx,0FB80h
         mov       si,0F333h
         mov       di,3504h
         call      l_1722
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         mov       ax,81h
         xor       bx,bx
         xor       dx,dx
         call      l_1869
         push      dx
         push      bx
         push      ax
         mov       ax,81h
         xor       bx,bx
         mov       dx,8000h
         call      l_162F
         pop       cx
         pop       si
         pop       di
         call      l_179C
         mov       di,offset l_1CBC
         mov       cx,6
         call      l_1EBF
         inc       al
         mov       cx,0D27Fh
         mov       si,17F7h
         mov       di,3172h
         call      l_162F
         pop       cx
         push      dx
         push      bx
         push      ax
         xchg      ax,cx
         call      l_18BB
         mov       cx,0D280h
         mov       si,17F7h
         mov       di,3172h
         call      l_1722
         pop       cx
         pop       si
         pop       di
         call      l_162F
         cmp       al,67h             ; 'g'
         jae       l_1CB9
         xor       ax,ax
         xor       bx,bx
         xor       dx,dx
l_1CB9:  jmp       l_1992

l_1C30   ENDP

l_1CBC   db        7dh,8ah,9dh,0d8h,89h,1dh,7dh,0e9h
         db        0a2h,8bh,2eh,3ah,7dh,8eh,0e3h,38h
         db         8Eh, 63h, 7Eh, 49h, 92h, 24h
         db         49h, 12h, 7Eh,0CDh,0CCh,0CCh
         db        0CCh, 4Ch, 7Fh,0ABh,0AAh,0AAh
         db        0AAh
         db        2Ah

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1CE0   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         test      dh,80h
         pushf     
         and       dh,7Fh
         mov       cx,0D280h
         mov       si,17F7h
         mov       di,3172h
         call      l_179C
         cmp       al,88h
         jae       l_1D53
         push      dx
         push      bx
         push      ax
         inc       al
         mov       ch,0FFh
         call      l_1ADE
         pop       cx
         pop       si
         pop       di
         push      ax
         call      l_18BB
         or        al,al
         jz        l_1D15
         dec       al
l_1D15:  xchg      ax,cx
         xchg      bx,si
         xchg      dx,di
         call      l_1627
         mov       di,offset l_1D59
         mov       cx,8
         call      l_1ED8
         pop       cx
         shr       cx,1
         jnc       l_1D39
         push      cx
         mov       cx,0FB81h
         mov       si,0F333h
         mov       di,3504h
         call      l_1722
         pop       cx
l_1D39:  add       al,cl
         jc        l_1D53
         popf      
         jz        l_1D50
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         mov       ax,81h
         xor       bx,bx
         xor       dx,dx
         call      l_179C
l_1D50:  jmp       l_1992
l_1D53:  pop       ax
         mov       dl,1
         jmp       l_101D

l_1CE0   ENDP

l_1D59   db        6Dh
         db         2Eh, 1Dh, 11h, 60h, 31h, 70h
         db         46h, 2Ch,0FEh,0E5h, 7Fh, 74h
         db         36h, 7Ch, 89h, 84h, 21h, 77h
         db         53h, 3Ch,0FFh,0C3h, 2Eh, 7Ah
         db        0D2h, 7Dh, 5Bh, 95h, 1Dh, 7Ch
         db         25h,0B8h, 46h, 58h, 63h, 7Eh
         db         16h,0FCh,0EFh,0FDh, 75h, 80h
         db        0D2h,0F7h, 17h
         db         72h, 31h

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1D89   PROC      NEAR

         pop       word ptr ds:[d_0186]     ; adresa vzniku chyby programu
         pop       ax
         pop       bx
         pop       dx
         or        al,al
         jz        l_1D50
         xor       cx,cx
         test      dh,80h
         jz        l_1D9F
         inc       cx
         and       dh,7Fh
l_1D9F:  push      cx
         mov       cx,81h
         xor       si,si
         xor       di,di
         call      l_1891
         jc        l_1DB8
         xchg      ax,cx
         xchg      bx,si
         xchg      dx,di
         call      l_179C
         pop       cx
         inc       cx
         inc       cx
         push      cx
l_1DB8:  mov       cx,4A7Eh
         mov       si,0E98Eh
         mov       di,0C6Fh
         call      l_1891
         jnc       l_1DCB
         call      l_1EB9
         jmp       short l_1E46

l_1DCB:  mov       di,offset l_1E6B
         mov       cx,2
l_1DD1:  push      cx
         push      di
         mov       cx,cs:[di]
         mov       si,cs:[di+2]
         mov       di,cs:[di+4]
         call      l_1891
         pop       di
         pop       cx
         jc        l_1DED
         add       di,12h
         loop      l_1DD1
         sub       di,6
l_1DED:  add       di,6
         mov       ds:[d_021A],ax
         mov       ds:[d_021C],bx
         mov       ds:[d_021E],dx
         push      di
         mov       cx,cs:[di]
         mov       si,cs:[di+2]
         mov       di,cs:[di+4]
         call      l_1873
         push      dx
         push      bx
         push      ax
         mov       ax,ds:[d_021A]
         mov       bx,ds:[d_021C]
         mov       dx,ds:[d_021E]
         call      l_1722
         mov       cx,81h
         xor       si,si
         xor       di,di
         call      l_162F
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         pop       ax
         pop       bx
         pop       dx
         call      l_179C
         call      l_1EB9
         pop       di
         add       di,6
         mov       cx,cs:[di]
         mov       si,cs:[di+2]
         mov       di,cs:[di+4]
         call      l_162F
l_1E46:  pop       cx
         test      cl,2
         jz        l_1E60
         push      cx
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         mov       ax,2181h
         mov       bx,0DAA2h
         mov       dx,490Fh
         call      l_1627
         pop       cx
l_1E60:  test      cl,1
         jz        l_1E68
         or        dh,80h
l_1E68:  jmp       l_1992

l_1D89   ENDP

l_1E6B   db        7Fh
         db        0E7h,0CFh,0CCh, 13h, 54h, 7Fh
         db        0F6h,0F4h,0A2h, 30h, 09h, 7Fh
         db         6Ah,0C1h, 91h, 0Ah, 06h, 80h
         db        0B5h, 9Eh, 8Ah, 6Fh, 44h, 80h
         db         82h, 2Ch, 3Ah,0CDh, 13h, 80h
         db         6Ah,0C1h, 91h, 0Ah, 06h, 81h
         db         00h, 00h, 00h, 00h, 00h, 80h
         db         21h,0A2h,0DAh, 0Fh, 49h
l_1E9B   db        7dh,0E8h,0A2h, 8Bh, 2Eh,0BAh, 7Dh
         db         8Eh,0E3h, 38h, 8Eh, 63h, 7Eh
         db         49h, 92h, 24h, 49h, 92h, 7Eh
         db        0CDh,0CCh,0CCh,0CCh, 4Ch, 7Fh
         db        0ABh,0AAh,0AAh,0AAh,0AAh

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1EB9   PROC      NEAR

         mov       di,offset l_1E9B
         mov       cx,5
l_1EBF:  push      dx
         push      bx
         push      ax
         push      cx
         push      di
         mov       cx,ax
         mov       si,bx
         mov       di,dx
         call      l_1722
         pop       di
         pop       cx
         call      l_1ED8
         pop       cx
         pop       si
         pop       di
         jmp       l_1722

l_1EB9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1ED8   PROC      NEAR

         mov       ds:[d_021A],ax
         mov       ds:[d_021C],bx
         mov       ds:[d_021E],dx
l_1EE3:  mov       ax,cs:[di]
         mov       bx,cs:[di+2]
         mov       dx,cs:[di+4]
         push      cx
         push      di
         jmp       short l_1F02

l_1ED8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1EF2   PROC      NEAR

         push      cx
         push      di
         mov       cx,cs:[di]
         mov       si,cs:[di+2]
         mov       di,cs:[di+4]
         call      l_162F
l_1F02:  mov       cx,ds:[d_021A]
         mov       si,ds:[d_021C]
         mov       di,ds:[d_021E]
         call      l_1722
         pop       di
         pop       cx
         add       di,6
         loop      l_1EF2
         mov       cx,81h
         xor       si,si
         xor       di,di
         jmp       l_162F

l_1EF2   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ ‡¡sla REAL DS:DI do bufferu DS:BX
; -----------------------------------------------------------------------------

l_1F22   PROC      NEAR

         push      bx                       ; adresa bufferu k dek¢dov n¡
         cmp       dx,25
         jb        l_1F49
         mov       ax,cx                    ; d‚lka bufferu
         call      l_0AAA                   ; omezen¡ ‡¡sla na bajt bez znam‚nka
         mov       dl,7
         test      byte ptr [di+5],80h
         jz        l_1F37
         inc       dl
l_1F37:  sub       al,dl
         jnc       l_1F3D
         xor       al,al
l_1F3D:  cmp       al,9
         jb        l_1F43
         mov       al,9
l_1F43:  inc       al
         mov       dl,al
         mov       dh,al
l_1F49:  push      dx
         call      l_1FE6
         pop       dx
         mov       al,dl
         inc       al
         or        dh,dh
         jnz       l_1F67
         add       al,cl
         jns       l_1F61
         mov       byte ptr ds:[d_0226],0
         jmp       short l_1F6A
l_1F61:  cmp       al,0Ch
         jb        l_1F67
         mov       al,0Bh
l_1F67:  call      l_2080
l_1F6A:  pop       bx
         mov       si,offset d_0226
         test      ch,80h
         jz        l_1F78
         mov       al,"-"
         call      l_1FE2
l_1F78:  mov       ch,cl
         or        dh,dh
         jz        l_1F80
         mov       ch,0
l_1F80:  or        ch,ch
         jns       l_1F89
         call      l_1FE0
         jmp       short l_1F90
l_1F89:  call      l_1FD7
         dec       ch
         jns       l_1F89
l_1F90:  or        dl,dl
         jz        l_1FAD
         mov       al,"."
         call      l_1FE2
l_1F99:  inc       ch
         jz        l_1FA4
         call      l_1FE0
         dec       dl
         jnz       l_1F99
l_1FA4:  dec       dl
         js        l_1FAD
         call      l_1FD7
         jmp       short l_1FA4
l_1FAD:  or        dh,dh
         jnz       l_1FB2
         ret

l_1FB2:  mov       al,"E"
         call      l_1FE2
         mov       al,"+"
         or        cl,cl
         jns       l_1FC1
         neg       cl
         mov       al,"-"
l_1FC1:  call      l_1FE2
         mov       al,"/"
l_1FC6:  inc       al
         sub       cl,0Ah
         jnc       l_1FC6
         call      l_1FE2
         add       cl,":"
         mov       al,cl
         jmp       short l_1FE2

l_1F22   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1FD7   PROC      NEAR

         mov       al,[si]
         or        al,al
         jz        l_1FE0
         inc       si
         jmp       short l_1FE2

l_1FD7   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1FE0   PROC      NEAR

         mov       al,"0"
l_1FE2:  mov       [bx],al
         inc       bx
         ret

l_1FE0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_1FE6   PROC      NEAR

; ------ p©¡prava ‡¡sla k dek¢dov n¡

         mov       ax,[di]
         mov       bx,[di+2]
         mov       dx,[di+4]

; ------ vynulov n¡ bufferu, je-li ‡¡slo = 0

         or        al,al                    ; je ‡¡slo = 0 ?
         jnz       l_2005                   ; ‡¡slo nen¡ = 0
         mov       si,offset d_0226         ; buffer k dek¢dov n¡ ‡¡sla
l_1FF5:  mov       word ptr [si],"00"       ; vynulov n¡ bufferu
         inc       si
         inc       si                       ; zv˜¨en¡ ukazatele v bufferu
         cmp       si,offset d_0232         ; je ji‘ konec bufferu ?
         jne       l_1FF5                   ; nen¡ konec bufferu
         mov       cx,0                     ; ‡¡ta‡ platn˜ch ‡¡slic = 0
         ret

l_2005:  mov       ch,dh
         and       dh,7Fh
         push      ax
         push      dx
         sub       al,80h
         cbw       
         mov       dx,77
         imul      dx
         add       ax,5
         mov       cl,ah
         pop       dx
         pop       ax
         cmp       cl,217
         jne       l_2022
         inc       cl
l_2022:  push      cx
         neg       cl
         call      l_219E
         pop       cx
         cmp       al,81h
         jae       l_2032
         call      l_2225
         dec       cl

l_2032:  push      cx
         or        dh,80h
         mov       cl,84h
         sub       cl,al
         mov       al,0
         jz        l_2048

; ------ normov n¡ mantisy ‡¡sla - rotace o CL bit– vpravo

l_203E:  shr       dx,1
         rcr       bx,1
         rcr       ax,1
         dec       cl
         jnz       l_203E                   ; rotace o dal¨¡ bit vpravo

; ------ dek¢dov n¡ mantisy ‡¡sla do bufferu (12 znak–)

l_2048:  mov       si,offset d_0226         ; buffer k dek¢dov n¡ ‡¡sla
l_204B:  mov       ch,dh                    ; nejvy¨¨¡ bajt ‡¡sla
         mov       cl,4                     ; po‡et rotac¡
         shr       ch,cl                    ; rotace nejvy¨¨¡ ‡¡slice na pozici
         add       ch,"0"                   ; korekce na znak ASCII
         mov       [si],ch                  ; ulo‘en¡ znaku do bufferu
         and       dh,0Fh                   ; zru¨en¡ nejvy¨¨¡ ‡¡slice
                                          ;* £schova dek¢dovan‚ho ‡¡sla
         push      dx
         push      bx
         push      ax
                                          ;* vyn soben¡ ‡¡sla * 2
         shl       ax,1
         rcl       bx,1
         rcl       dx,1                     ; ‡¡slo DX:BX:AX * 2
                                          ;* vyn soben¡ ‡¡sla * 2
         shl       ax,1
         rcl       bx,1
         rcl       dx,1                     ; ‡¡slo DX:BX:AX * 4
                                          ;* p©i‡ten¡ p–vodn¡ho ‡¡sla
         pop       cx
         add       ax,cx
         pop       cx
         adc       bx,cx
         pop       cx
         adc       dx,cx                    ; ‡¡slo DX:BX:AX * 5
                                          ;* vyn soben¡ ‡¡sla * 2
         shl       ax,1
         rcl       bx,1
         rcl       dx,1
                                          ;* zv˜¨en¡ ukazatele v bufferu
         inc       si                       ; zv˜¨en¡ ukazatele v bufferu
         cmp       si,offset d_0226+12      ; je konec bufferu ?
         jne       l_204B                   ; nen¡ konec bufferu - dal¨¡ ‡¡slice
         pop       cx
         ret

l_1FE6   ENDP

Code     ENDS

INCLUDE  KDAT.ASM                           ; datov˜ segment

         END       Start

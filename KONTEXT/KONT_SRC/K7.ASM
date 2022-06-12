
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; *****************************************************************************
;
;                          Obsluha definice maker
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        p©evod znak– Ctrl- v ©etˆzci makra na bajty < 32
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) adresa ©etˆzce
; -----------------------------------------------------------------------------

l_C14D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C154
         db        0e9h,0,0

l_C154:  push      ds
         ;lds       di,dword ptr [bp+4]     ; adresa ©etˆzce
         db        0C5h,0BEh,4,0            ;!
         push      ds
         pop       es
         cld       

         mov       al,[di]                  ; d‚lka textu
         or        al,al                    ; je nˆjak˜ znak ?
         jz        l_C185                   ; nen¡ ‘ dn˜ znak
         mov       ah,0
         mov       bx,1
         push      di
l_C168:  inc       di
         cmp       byte ptr [di],"^"        ; je znak Ctrl- ?
         jne       l_C17D                   ; nen¡ znak Ctrl-
         mov       si,di
         inc       si
         and       byte ptr [si],1Fh        ; p©evod na bajt Ctrl-
         mov       cx,ax
         sub       cx,bx
         push      di
         repne     movsb                    ; vypu¨tˆn¡ znaku "^"
         pop       di
         dec       ax
l_C17D:  inc       bx
         cmp       bx,ax
         jb        l_C168
         pop       di
         mov       [di],al                  ; nov  d‚lka textu

l_C185:  pop       ds
         ;jmp       l_C189
         db        0e9h,0,0

l_C189:  mov       sp,bp
         pop       bp
         ret       4

l_C14D   ENDP

; -----------------------------------------------------------------------------
;        p©evod znak– < 32 na znaky Ctrl-
; -----------------------------------------------------------------------------

l_C18F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C196
         db        0e9h,0,0

l_C196:  push      ds
         ;lds       si,dword ptr [bp+4]     ; adresa ©etˆzce
         db        0C5h,0B6h,4,0            ;!
         push      ds
         pop       es
         std       
         mov       al,[si]
         mov       ah,0
         or        ax,ax
         jz        l_C1D3
         mov       bx,1
         push      si
l_C1AA:  cmp       al,0F0h                  ; maxim ln¡ d‚lka © dku
         jae       l_C1D0                   ; © dek je p©¡li¨ dlouh˜
         inc       si
         cmp       byte ptr [si]," "        ; je ©¡dic¡ znak ?
         jae       l_C1CB                   ; nen¡ ©¡dic¡ znak
         or        byte ptr [si],"@"        ; konverze na znak ASCII
         push      si
         mov       cx,ax
         sub       cx,bx
         add       si,cx
         mov       di,si
         inc       cx
         inc       di
         repne     movsb
         pop       si
         mov       byte ptr [si],"^"         ; vlo‘en¡ prefixu "^"
         inc       ax
         inc       si
         inc       bx
l_C1CB:  inc       bx
         cmp       bx,ax
         jbe       l_C1AA
l_C1D0:  pop       si
         mov       [si],al                  ; nov  d‚lka textu
l_C1D3:  pop       ds
         ;jmp       l_C1D7
         db        0e9h,0,0

l_C1D7:  mov       sp,bp
         pop       bp
         ret       4

l_C18F   ENDP

; -----------------------------------------------------------------------------
;        za©azen¡ makra do bufferu makrokl ves
; -----------------------------------------------------------------------------

l_C1DD   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C1E4
         db        0e9h,0,0

; ------ zru¨en¡ star‚ definice makra

l_C1E4:  ;mov       ax,[bp+8]
         db        8Bh,86h,8,0              ;!
         push      ax
         push      ax
         call      l_40D2                   ; nalezen¡ kl vesy v makrobufferu
         or        ax,ax                    ; byla kl vesa nalezena ?
         jz        l_C21B                   ; kl vesa nebyla nalezena
         mov       si,offset l_2CD9         ; buffer makrokl ves
         add       si,ax                    ; adresa nalezen‚ makrokl vesy
         mov       bl,cs:[si]               ; d‚lka star‚ definice makrokl vesy
         mov       bh,0
         inc       bx
         mov       di,si                    ; adresa za‡ tku makra
         dec       di
         add       si,bx                    ; adresa n sleduj¡c¡ho makra
         mov       cx,word ptr ds:[d_F7A1]  ; po‡et bajt– v tabulce maker
         sub       cx,bx                    ; sn¡‘en¡ po‡tu bajt– v bufferu
         dec       cx
         mov       word ptr ds:[d_F7A1],cx  ; nov˜ po‡et bajt– v tabulce maker
         inc       cx
         sub       cx,ax                    ; po‡et zbyl˜ch dat k p©¡sunu
         push      ds
         push      cs
         pop       ds                       ; DS <- CS
         push      cs
         pop       es                       ; ES <- CS
         cld
         repne     movsb                    ; p©¡sun zbytku makrokl vesy
         xor       ax,ax
         stosb                              ; ukon‡ovac¡ bajt 0
         pop       ds

; ------ test, zda je nˆjak˜ znak makra (makro zru¨eno)

l_C21B:  ;les       si,dword ptr [bp+4]
         db        0C4h,0B6h,4,0            ;!
         cmp       al,es:[si]               ; d‚lka makra = 0 ?
         je        l_C260                   ; d‚lka makra = 0, makro zru¨eno

; ------ p©evod znak– Ctrl- makra na bajty < 32

         push      es
         push      si
         call      l_C14D                   ; p©evod znak– Ctrl- na bajty < 32

; ------ p©¡prava registr– k p©enosu makra

         mov       bx,word ptr ds:[d_F7A1]  ; po‡et bajt– v tabulce maker
         push      ds
         ;lds       si,dword ptr [bp+4]     ; ©etˆzec makra
         db        0C5h,0B6h,4,0            ;!
         mov       cl,[si]                  ; d‚lka ©etˆzce
         mov       ch,0
         inc       cx                       ; v‡etnˆ bajtu d‚lky
         mov       di,offset l_2CD9         ; buffer makrokl ves
         add       di,bx                    ; konec maker v bufferu
         add       bx,cx                    ; nov  d‚lka maker v bufferu
         inc       bx                       ; v‡etnˆ SCAN k¢du kl vesy
         cmp       bx,1000                  ; je buffer maker ji‘ pln˜ ?
         jbe       l_C24E                   ; buffer maker je¨tˆ nen¡ pln˜
         pop       ds
         mov       word ptr ds:[d_F79D],11  ; k¢d chyby KonTextu - buffer pln˜
         jmp       short l_C260

; ------ p©enos textu makra do bufferu makrokl ves

l_C24E:  ;mov       al,[bp+8]               ; SCAN k¢d kl vesy
         db        8Ah,86h,8,0              ;!
         push      cs
         pop       es
         cld
         stosb                              ; ulo‘en¡ SCAN k¢du
         repne     movsb
         xor       ax,ax
         stosb                              ; ukon‡ovac¡ bajt 0 makra
         pop       ds
         mov       ds:[d_F7A1],bx           ; po‡et bajt– v tabulce maker
l_C260:  ;jmp       l_C263
         db        0e9h,0,0

l_C263:  mov       sp,bp
         pop       bp
         ret       6

l_C1DD   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ makrobufferu do textu jako textov˜ blok
; -----------------------------------------------------------------------------

l_C269   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C270
         db        0e9h,0,0

l_C270:  dec       sp
         dec       sp
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         dec       ax
         mov       [bp-4],ax
l_C27C:  push      ds
         pop       ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      cs
         pop       es
         mov       si,offset l_2CD9         ; makrobuffer (makrokl vesy)
         mov       bx,11                    ; funkce v˜pisu k¢du ©¡dic¡ kl vesy
         call      dword ptr ds:[d_FDC7]    ; funkce driveru SCREEN.OVL
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         push      ax
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         je        l_C2A8
         dec       ax
l_C2A8:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_C2B2
         ;jmp       l_C2D0
         db        0e9h
         dw        l_C2D0-$-2

l_C2B2:  mov       ax,[bp-4]
         inc       ax
         mov       [bp-4],ax
         mov       ax,[bp-4]
         push      ax
         mov       ax,1
         push      ax
         call      l_3B6A
         mov       ax,[bp-4]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_3DC5                   ; ulo‘en¡ textu © dku do souboru
l_C2D0:  mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_C2E3
         ;jmp       l_C27C
         db        0e9h
         dw        l_C27C-$-2

l_C2E3:  mov       ax,ds:[d_E698]           ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ds:[d_E690],ax           ; © dek za‡ tku bloku
         mov       ax,[bp-4]
         mov       ds:[d_E692],ax           ; © dek konce bloku
         mov       ax,0
         mov       ds:[d_E6AA],al           ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,ds:[d_E692]           ; © dek konce bloku
         cmp       ax,ds:[d_E690]           ; © dek za‡ tku bloku
         mov       ax,1
         jnl       l_C302
         dec       ax
l_C302:  mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_C30B
         db        0e9h,0,0

l_C30B:  mov       sp,bp
         pop       bp
         ret       

l_C269   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ textov‚ho bloku z textu do bufferu makrokl ves (zak¢dov n¡)
; -----------------------------------------------------------------------------

l_C30F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C316
         db        0e9h,0,0

l_C316:  sub       sp,6
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         jnz       l_C322
         ;jmp       l_C325
         db        0e9h
         dw        l_C325-$-2

l_C322:  jmp       l_C3E6

l_C325:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_C338
         jmp       l_C3E3

l_C338:  inc       cx
         mov       [bp-6],ax
l_C33C:  push      cx
         mov       ax,[bp-6]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         push      ds
         pop       es
         mov       si,offset d_EC59         ; buffer textov‚ho © dku
         mov       bx,10                    ; funkce dek¢dov n¡ k¢du kl vesy
         call      dword ptr ds:[d_FDC7]    ; adresa vstupn¡ho bodu SCREEN.OVL
         ;mov       [bp-4],ax
         db        89h,86h,0FCh,0FFh        ;!
         mov       ax,7C01h
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         mov       [bp-8],ax
         mov       ax,[bp-4]
         cmp       ax,0
         mov       ax,1
         jg        l_C37B
         dec       ax
l_C37B:  push      ax
         mov       ax,[bp-8]
         cmp       ax,0
         mov       ax,1
         jg        l_C388
         dec       ax
l_C388:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_C392
         ;jmp       l_C3C9
         db        0e9h
         dw        l_C3C9-$-2

l_C392:  mov       ax,1
         push      ax
         mov       ax,[bp-8]
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         cmp       ax,7Ch
         je        l_C3B1
         ;jmp       l_C3BA
         db        0e9h
         dw        l_C3BA-$-2

l_C3B1:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         dec       ax
         mov       byte ptr ds:[d_EC59],al  ; d‚lka textov‚ho © dku
l_C3BA:  mov       ax,[bp-4]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_C1DD                   ; za©azen¡ makra do bufferu maker
         ;jmp       l_C3D9
         db        0e9h
         dw        l_C3D9-$-2

l_C3C9:  mov       ax,9
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu - chyba zad n¡
         mov       ax,[bp-6]
         push      ax
         call      l_4CC6                   ; p©esun kurzoru na zadan˜ © dek
         ;jmp       l_C3E9
         db        0e9h
         dw        l_C3E9-$-2

l_C3D9:  pop       cx
         dec       cx
         jz        l_C3E3
         inc       word ptr [bp-6]
         jmp       l_C33C

l_C3E3:  call      l_6886
l_C3E6:  ;jmp       l_C3ED
         db        0e9h
         dw        l_C3ED-$-2

l_C3E9:  pop       ax
         ;jmp       l_C3E6
         db        0e9h
         dw        l_C3E6-$-2

l_C3ED:  mov       sp,bp
         pop       bp
         ret       

l_C30F   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QT a Extra/makrokl vesy (definice makrokl vesy)
; -----------------------------------------------------------------------------

l_C3F1   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C3F8
         db        0e9h,0,0

; ------ zobrazen¡ v˜zvy ke stisku hork‚ kl vesy

l_C3F8:  sub       sp,104h
         call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        55,'Definice makrokl vesy - stisknˆte po‘adovanou kl vesu:_'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ ‡ek n¡ na zad n¡ hork‚ kl vesy

l_C44A:  dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl vesnice
         mov       [bp-6],ax                ; zadan  hork  kl vesa
         dec       sp
         mov       ax,[bp-6]
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno

; ------ p©eru¨en¡ operace kl vesou ESC

         cmp       ax,1Bh
         je        l_C462
         ;jmp       l_C46E
         db        0e9h
         dw        l_C46E-$-2

l_C462:  mov       ax,1
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         jmp       l_C534
         ;jmp       l_C48D
         db        0e9h
         dw        l_C48D-$-2

; ------ funkce na‡ten¡ maker z bufferu do textu (dek¢dov n¡ do text. tvaru)

l_C46E:  cmp       ax,"R"
         je        l_C476
         ;jmp       l_C47F
         db        0e9h
         dw        l_C47F-$-2

l_C476:  call      l_C269                   ; na‡ten¡ makrobufferu do textu
         jmp       l_C534
         ;jmp       l_C48D
         db        0e9h
         dw        l_C48D-$-2

; ------ funkce z pisu maker z textu do bufferu (k¢dov n¡ z text. tvaru)

l_C47F:  cmp       ax,"W"
         je        l_C487
         ;jmp       l_C48D
         db        0e9h
         dw        l_C48D-$-2

l_C487:  call      l_C30F                   ; ulo‘en¡ textov‚ho bloku do maker
         jmp       l_C534

; ------ ovˆ©en¡, zda je ©¡dic¡ kl vesa (jinak n vrat k ‡ek n¡ na kl vesu)

l_C48D:  mov       ax,[bp-6]
         cmp       ax,0
         jl        l_C498
         ;jmp       l_C44A
         db        0e9h
         dw        l_C44A-$-2

; ------ nalezen¡ makra v bufferu

l_C498:  dec       sp
         dec       sp
         mov       ax,[bp-6]                ; zadan  kl vesa
         neg       ax                       ; oprava polarity
         push      ax
         call      l_40D2                   ; nalezen¡ kl vesy v makrobufferu
         mov       [bp-4],ax                ; offset nalezen‚ho makra
         mov       ax,[bp-4]
         cmp       ax,0                     ; byla kl vesa nalezena ?
         jg        l_C4B1                   ; kl vesa byla nalezena
         ;jmp       l_C4D7
         db        0e9h
         dw        l_C4D7-$-2

; ------ ulo‘en¡ textu makra do edita‡n¡ho bufferu makra a p©evod na znaky ASCII

l_C4B1:  mov       ax,[bp-4]                ; offset nalezen‚ho makra
         xchg      ax,di
         add       di,offset l_2CD9         ; definice makrokl vesy
         push      cs
         push      di
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       ax,[bp-4]                ; offset nalezen‚ho makra
         xchg      ax,di
         mov       al,cs:[l_2CD9+di]        ; buffer makrokl ves - d‚lka makra
         xor       ah,ah
         inc       ax                       ; v‡etnˆ bajtu d‚lky
         call      l_0F2E                   ; p©esun dat do edita‡n¡ho bufferu
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         call      l_C18F                   ; p©evod znak– < 32 na znaky Ctrl-

; ------ zobrazen¡ £vodn¡ho textu "Obsah kl vesy:"

l_C4D7:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,1
         mov       byte ptr ds:[d_F790],al  ; 1=povoleno zobrazen¡ menu
         mov       ax,1
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        12,'Obsah kl v.:'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ editace makra

         mov       ax,14
         push      ax                       ; po‡ te‡n¡ pozice k zobrazen¡ textu
         mov       ax,0
         push      ax                       ; © dek k zobrazen¡ textu
         mov       ax,240
         push      ax                       ; maxim ln¡ d‚lka bufferu
         mov       ax,1
         push      ax                       ; maska typy znak– - v¨echny znaky
         lea       di,[bp-106h]             ; buffer k ulo‘en¡ makra
         push      ss                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru

; ------ ulo‘en¡ makra do bufferu maker

         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1                     ; byla zmˆna makra ?
         jnz       l_C525                   ; byla zmˆna makra (byla editace)
         ;jmp       l_C534
         db        0e9h
         dw        l_C534-$-2

l_C525:  mov       ax,[bp-6]                ; zadan  hork  kl vesa
         neg       ax
         push      ax
         lea       di,[bp-106h]             ; zadan‚ makro
         push      ss
         push      di
         call      l_C1DD                   ; za©azen¡ makra do bufferu maker

; ------ nov‚ zobrazen¡ stavov‚ho © dku

l_C534:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ;jmp       l_C53A
         db        0e9h,0,0

l_C53A:  mov       sp,bp
         pop       bp
         ret       

l_C3F1   ENDP

; *****************************************************************************
;
;                             menu Ctrl-Q
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha kl vesy Ctrl-Q (menu kurzoru/maz n¡)
; -----------------------------------------------------------------------------

l_C53E   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C545
         db        0e9h,0,0

l_C545:  jmp       short l_C57D

l_C547   dw        l_BCDB                   ; Ctrl-QA hled n¡/z mˆna
         dw        l_6801                   ; Ctrl-QB za‡ tek bloku
         dw        l_B7D2                   ; Ctrl-QC konec textu
         dw        l_5DC2                   ; Ctrl-QD konec © dku
         dw        l_B7F0                   ; Ctrl-QE horn¡ okraj
         dw        l_BCDB                   ; Ctrl-QF hled n¡
         dw        l_BF2E                   ; Ctrl-QG maz n¡ po konec © dku
         dw        l_BF6E                   ; Ctrl-QH maz n¡ po za‡ tek © dku
         dw        l_6816                   ; Ctrl-QK konec bloku
         dw        l_59E4                   ; Ctrl-QL navr cen¡ posledn¡ch zmˆn
         dw        l_BFC9                   ; Ctrl-QM nastaven¡ zna‡ky
         dw        l_BFAB                   ; Ctrl-QP n vrat na zna‡ku
         dw        l_B797                   ; Ctrl-QR za‡ tek textu
         dw        l_5D74                   ; Ctrl-QS za‡ tek © dku
         dw        l_C3F1                   ; Ctrl-QT definice makra
         dw        l_B828                   ; Ctrl-QX doln¡ okraj
         dw        l_BF2E                   ; Ctrl-QY maz n¡ po konec © dku
         dw        l_BFE3                   ; Ctrl-QZ nastaven¡ na pozici

l_C56B   db        'ABCDEFGHKLMPRSTXYZ'     ; povolen‚ kl vesy
l_C56B0  label     byte

; ------ ‡ek n¡ na zad n¡ druh‚ho znaku volby

l_C57D:  mov       ax,5                     ; menu Ctrl-Q
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volbˆ Ctrl-Q
         push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         push      ax
         mov       ax,5                     ; menu Ctrl-Q
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       ax

; ------ nalezen¡ kl vesy v bufferu

         mov       si,offset l_C56B         ; povolen‚ kl vesy
         mov       cx,offset(l_C56B0-l_C56B) ; po‡et kl ves
         xor       bx,bx
l_C59E:  cmp       al,cs:[si]
         je        l_C5AA
         inc       si
         inc       bx
         inc       bx
         loop      l_C59E
         jmp       short l_C5BB             ; kl vesa nenalezena

; ------ pro funkce Ctrl-QF a Ctrl-QA je vstupn¡ parametr 0

l_C5AA:  xor       dx,dx                    ; DX <- 0
         cmp       al,"F"
         je        l_C5B5
         inc       dx
         cmp       al,"A"
         jne       l_C5B6
l_C5B5:  push      dx
l_C5B6:  call      cs:[l_C547+bx]           ; vol n¡ obsluhy kl vesy
l_C5BB:  ;jmp       l_C5BE
         db        0e9h,0,0

l_C5BE:  mov       sp,bp
         pop       bp
         ret       

l_C53E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_C5C2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C5C9
         db        0e9h,0,0

l_C5C9:  call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         call      l_5C9F                   ; posun kurzoru o © dek dol–
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0
         jg        l_C5DF
         ;jmp       l_C659
         db        0e9h
         dw        l_C659-$-2

l_C5DF:  mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         inc       ax
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         cmp       ax,0
         je        l_C5F3
         ;jmp       l_C611
         db        0e9h
         dw        l_C611-$-2

l_C5F3:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         dec       ax
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         pop       cx
         add       ax,cx
         mov       byte ptr ds:[d_EC59],al  ; d‚lka textov‚ho © dku
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         call      l_372A
         ;jmp       l_C61E
         db        0e9h
         dw        l_C61E-$-2

l_C611:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         push      ax
         call      l_3799                   ; odsun zbytku © dku INSERT
l_C61E:  mov       di,offset d_F059 + 1
         push      ds
         push      di
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         xchg      ax,di
         add       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       al,ds:[d_F059]
         xor       ah,ah
         call      l_0F2E                   ; posun dat (s p©ekryvem)
         mov       di,offset d_F159 + 1
         push      ds
         push      di
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         xchg      ax,di
         add       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         mov       al,ds:[d_F059]
         xor       ah,ah
         call      l_0F2E                   ; posun dat (s p©ekryvem)
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_C659:  ;jmp       l_C65C
         db        0e9h,0,0

l_C65C:  mov       sp,bp
         pop       bp
         ret       

l_C5C2   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_C660   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C667
         db        0e9h,0,0

l_C667:  dec       sp
         dec       sp
         mov       ax,1001h
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         inc       ax
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-4]
         mov       [bp+4],ax
         ;jmp       l_C68C
         db        0e9h,0,0

l_C68C:  mov       ax,[bp+4]
         mov       sp,bp
         pop       bp
         ret       2

l_C660   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_C695   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C69C
         db        0e9h,0,0

l_C69C:  sub       sp,4
         dec       sp
         dec       sp
         call      l_C660
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_387D
         mov       ax,[bp-4]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jl        l_C6C1
         ;jmp       l_C713
         db        0e9h
         dw        l_C713-$-2

l_C6C1:  mov       ax,[bp-4]
         mov       [bp-6],ax
l_C6C7:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jl        l_C6DD
         ;jmp       l_C713
         db        0e9h
         dw        l_C713-$-2

l_C6DD:  mov       ax,[bp-4]
         push      ax
         mov       ax,1
         push      ax
         call      l_3799                   ; odsun zbytku © dku INSERT
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_387D
         mov       ax,[bp-4]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jge       l_C70A
         ;jmp       l_C710
         db        0e9h
         dw        l_C710-$-2

l_C70A:  mov       ax,[bp-6]
         mov       [bp-4],ax
l_C710:  ;jmp       l_C6C7
         db        0e9h
         dw        l_C6C7-$-2

l_C713:  ;jmp       l_C716
         db        0e9h,0,0

l_C716:  mov       sp,bp
         pop       bp
         ret       

l_C695   ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ platn‚ho znaku do © dku
; -----------------------------------------------------------------------------

l_C71A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C721
         db        0e9h,0,0

l_C721:  sub       sp,4
         xor       ax,ax
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         cmp       al,byte ptr ds:[d_F78B]  ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         je        l_C7AB
         mov       byte ptr ds:[d_F78B],al  ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         mov       ds:[d_F059],al
         call      l_5C32                   ; posun kurzoru o © dek nahoru
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         ;cmp       byte ptr [bp+4],20h
         db        80h,0BEh,4,0,20h         ;!
         je        l_C77A
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         mov       bl,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         dec       bl
         cmp       al,bl
         je        l_C758
         sub       bl,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         cmp       al,bl
         jne       l_C77A
l_C758:  mov       ah,0
         ;lea       di,[bp-6]
         db        8Dh,0BEh,0FAh,0FFh       ;!
         mov       ss:[di],ax
         push      ss
         push      di
         call      l_38DD
         push      ax
         call      l_C660
         ;mov       bx,[bp-6]
         db        8Bh,9Eh,0FAh,0FFh        ;!
         cmp       bx,ax
         jbe       l_C77A
         inc       bx
         push      bx
         call      l_390B                   ; rozdˆlen¡ textov‚ho © dku
         call      l_4855                   ; korekce editovan‚ho © dku
l_C77A:  mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       al,1
         and       al,byte ptr cs:[l_325E]  ; zarovn v n¡ (1=zap., 0=vyp.)
         jz        l_C78A
         call      l_C695
l_C78A:  mov       ax,1
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         dec       ax
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         call      l_C5C2
         mov       al,ds:[d_F059]
         add       byte ptr ds:[d_E69A],al  ; pozice kurzoru na © dku
         ;cmp       byte ptr [bp+4],20h
         db        80h,0BEh,4,0,20h         ;!
         jne       l_C7AB
         jmp       l_C98E

l_C7AB:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       ax,1
         push      ax
         call      l_5972
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jbe       l_C7C1
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
l_C7C1:  mov       bl,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         mov       bh,0
         cmp       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         jae       l_C7EF
         cmp       byte ptr ds:[d_EC59+bx],11h ; buffer textov‚ho © dku
         jne       l_C7E2
         push      bx
         push      bx
         push      bx
         push      bx
         mov       bl,1
         push      bx
         call      l_372A
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         pop       bx
l_C7E2:  inc       bx
         push      bx
         dec       bx
         sub       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         neg       bx
         push      bx
         call      l_372A
l_C7EF:  mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         cmp       byte ptr ds:[d_EC59+bx-1],0FFh ; buffer textov‚ho © dku
         jne       l_C801
         call      l_5D88                   ; kurzor o pozici vlevo
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
l_C801:  cmp       bh,byte ptr ds:[d_F78F]  ; 1=p©¡znak dekadick‚ho tabel toru
         je        l_C84E
         ;mov       al,[bp+4]
         db        8Ah,86h,4,0              ;!
         cmp       al,2Ch
         je        l_C845
         cmp       al,20h
         je        l_C845
         mov       si,bx
l_C815:  dec       si
         jz        l_C845
         cmp       byte ptr ds:[d_EC59+si],20h ; buffer textov‚ho © dku
         jne       l_C815
         dec       si
         jz        l_C845
         cmp       byte ptr ds:[d_EC59+si],20h ; buffer textov‚ho © dku
         jne       l_C845
         inc       si
         mov       ax,1
         dec       bx
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na © dku
         push      bx
         push      si
         push      bx
         push      bx
         push      ax
         push      si
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         call      l_3799                   ; odsun zbytku © dku INSERT
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         pop       bx
         jmp       short l_C89B

l_C845:  mov       byte ptr ds:[d_F78F],bh  ; 1=p©¡znak dekadick‚ho tabel toru
         push      bx
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         pop       bx
l_C84E:  cmp       bh,byte ptr cs:[l_3267]  ; p©¡znak INSERT (1=zap., 0=vyp.)
         je        l_C85E
         push      bx
         push      bx
         mov       bl,1
         push      bx
         call      l_3799                   ; odsun zbytku © dku INSERT
         pop       bx
l_C85E:  cmp       bh,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         je        l_C89B
         cmp       bl,0F0h
         jae       l_C89B
         ;cmp       byte ptr [bp+4],20h
         db        80h,0BEh,4,0,20h         ;!
         je        l_C89B
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         dec       al
         cmp       al,bl
         je        l_C89B
         cmp       bh,byte ptr cs:[l_3267]  ; p©¡znak INSERT (1=zap., 0=vyp.)
         je        l_C88A
         push      bx
         push      bx
         mov       bl,1
         push      bx
         call      l_3799                   ; odsun zbytku © dku INSERT
         pop       bx
l_C88A:  mov       byte ptr ds:[d_EC59+bx],0FFh ; buffer textov‚ho © dku
         mov       al,byte ptr ds:[d_F79A]
         mov       byte ptr ds:[d_ED59+bx],al ; buffer atribut– znak– text. © dku
         inc       bx
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na © dku
l_C89B:  ;mov       al,[bp+4]
         db        8Ah,86h,4,0              ;!
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       [bx+di],al
         mov       al,byte ptr ds:[d_F79A]
         mov       byte ptr ds:[d_ED59+bx],al ; buffer atribut– znak– text. © dku
         cmp       [di],bl
         jae       l_C8B1
         mov       [di],bl
l_C8B1:  push      bx
         push      bx
         mov       bl,[di]
         push      bx
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         pop       bx
         inc       bx
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na © dku
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         cmp       al,bl
         je        l_C8CF
         sub       al,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         cmp       al,bl
         jne       l_C934
l_C8CF:  mov       byte ptr ds:[d_F78B],1   ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         cmp       bh,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         jne       l_C934
         push      ax
         call      l_C660
l_C8DF:  cmp       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         jae       l_C922
         ;lea       di,[bp-6]
         db        8Dh,0BEh,0FAh,0FFh       ;!
         mov       ss:[di],ax
         push      ss
         push      di
         call      l_387D
         ;lea       di,[bp-6]
         db        8Dh,0BEh,0FAh,0FFh       ;!
         push      word ptr ss:[di]
         push      ss
         push      di
         call      l_384B
         pop       bx
         inc       bx
         ;mov       ax,[bp-6]
         db        8Bh,86h,0FAh,0FFh        ;!
         cmp       ax,bx
         jbe       l_C8DF
         cmp       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         jae       l_C8DF
         push      bx
         push      bx
         sub       ax,bx
         sub       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         pop       ax
         dec       ax
         mov       byte ptr ds:[d_F78B],0   ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         jmp       short l_C8DF

l_C922:  cmp       byte ptr ds:[d_F78B],0   ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         jne       l_C934
         mov       ax,1
         push      ax
         push      word ptr ds:[d_E6A6]     ; maxim ln¡ d‚lka © dku od L okraje
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_C934:  cmp       byte ptr ds:[d_F78B],0   ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         jne       l_C942
         cmp       byte ptr ds:[d_E69A],0F0h; pozice kurzoru na © dku
         jb        l_C98E
l_C942:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         mov       ax,1
         push      ax
         call      l_3B6A
         xor       ax,ax
         cmp       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         jne       l_C98E
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         cmp       al,byte ptr ds:[d_F78B]  ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         jne       l_C962
         mov       al,0F0h
l_C962:  push      ax
         call      l_390B                   ; rozdˆlen¡ textov‚ho © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         mov       ah,0
         inc       ax
         push      ax
         push      word ptr ds:[d_E6A6]     ; maxim ln¡ d‚lka © dku od L okraje
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         mov       ax,1
         cmp       ah,byte ptr cs:[l_3261]  ; auto-tabel tor (1=zap., 0=vyp.)
         je        l_C982
         push      ax
         call      l_C660
l_C982:  mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_5E8C
         call      l_C5C2
l_C98E:  ;jmp       l_C991
         db        0e9h,0,0

l_C991:  mov       sp,bp
         pop       bp
         ret       2

l_C71A   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-\ a Extra/zvl ¨tn¡ znaky (tabulka ASCII znak–)
; -----------------------------------------------------------------------------

l_C997   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_C99E
         db        0e9h,0,0

l_C99E:  dec       sp
         dec       sp
         dec       sp
         dec       sp
         call      l_557A                   ; volba znaku pomoc¡ ASCII tabulky
         mov       [bp-4],ax                ; zvolen˜ znak

         mov       ax,[bp-4]
         cmp       ax,0
         jg        l_C9B3                   ; byl zad n platn˜ znak
         ;jmp       l_C9BA                  ; jinak p©eru¨en¡ volby
         db        0e9h
         dw        l_C9BA-$-2

l_C9B3:  mov       ax,[bp-4]                ; zadan˜ znak
         push      ax
         call      l_C71A                   ; vlo‘en¡ platn‚ho znaku do © dku
l_C9BA:  ;jmp       l_C9BD
         db        0e9h,0,0

l_C9BD:  mov       sp,bp
         pop       bp
         ret       

l_C997   ENDP

; *****************************************************************************
;
;                           Form tov n¡ textu
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-B a Form t/po konec odstavec (form tov n¡ odstavce)
; -----------------------------------------------------------------------------

l_C9C1   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_D0BC

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_C9C8   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_C9D4
         db        0e9h,0,0

l_C9D4:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         jnz       l_C9E0
         dec       ax
l_C9E0:  push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         cmp       ax,11h
         mov       ax,1
         jz        l_C9F6
         dec       ax
l_C9F6:  pop       cx
         or        ax,cx
         push      ax
         dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         call      l_3D1C                   ; test, zda je © dek definov n
         pop       cx
         or        ax,cx
         push      ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jge       l_CA19
         dec       ax
l_CA19:  pop       cx
         or        ax,cx
         mov       [bp+4],al
         ;jmp       l_CA22
         db        0e9h,0,0

l_CA22:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_C9C8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CA2F   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_CA3B
         db        0e9h,0,0

l_CA3B:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         cmp       ax,11h
         mov       ax,1
         jz        l_CA56
         dec       ax
l_CA56:  pop       cx
         xchg      ax,cx
         sub       ax,cx
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jge       l_CA6B
         dec       ax
l_CA6B:  mov       [bp+4],al
         ;jmp       l_CA71
         db        0e9h,0,0

l_CA71:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_CA2F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CA7E   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_CA8A
         db        0e9h,0,0

l_CA8A:  mov       al,byte ptr ds:[d_EC59] ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         sub       ax,2
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jge       l_CAA3
         dec       ax
l_CAA3:  mov       [bp+4],al
         ;jmp       l_CAA9
         db        0e9h,0,0

l_CAA9:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_CA7E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CAB6   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_CAC2
         db        0e9h,0,0

l_CAC2:  sub       sp,4
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         or        ax,ax
         jnz       l_CAD5
         ;jmp       l_CAE2
         db        0e9h
         dw        l_CAE2-$-2

l_CAD5:  mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         mov       [bp-8],ax
         ;jmp       l_CB3F
         db        0e9h
         dw        l_CB3F-$-2

l_CAE2:  mov       ax,1
         mov       [bp-8],ax
         lea       di,[bp-8]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-8]
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-8]
         jl        l_CAFF
         ;jmp       l_CB14
         db        0e9h
         dw        l_CB14-$-2

l_CAFF:  mov       ax,1
         push      ax
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         sub       ax,[bp-8]
         push      ax
         call      l_3799                   ; odsun zbytku © dku INSERT
         ;jmp       l_CB35
         db        0e9h
         dw        l_CB35-$-2

l_CB14:  mov       ax,[bp-8]
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-8]
         jg        l_CB23
         ;jmp       l_CB35
         db        0e9h
         dw        l_CB35-$-2

l_CB23:  mov       ax,1
         push      ax
         mov       ax,[bp-8]
         mov       bx,[bp-2]
         sub       ax,ss:[bx-8]
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
l_CB35:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         mov       [bp-8],ax
l_CB3F:  mov       ax,[bp-8]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jl        l_CB51
         ;jmp       l_CB8B
         db        0e9h
         dw        l_CB8B-$-2

l_CB51:  lea       di,[bp-8]
         push      ss
         push      di
         call      l_387D
         mov       ax,[bp-8]
         inc       ax
         mov       [bp-6],ax
         lea       di,[bp-8]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-8]
         cmp       ax,[bp-6]
         jg        l_CB73
         ;jmp       l_CB88
         db        0e9h
         dw        l_CB88-$-2

l_CB73:  mov       ax,[bp-6]
         push      ax
         mov       ax,[bp-8]
         sub       ax,[bp-6]
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         mov       ax,[bp-6]
         inc       ax
         mov       [bp-8],ax
l_CB88:  ;jmp       l_CB3F
         db        0e9h
         dw        l_CB3F-$-2

l_CB8B:  ;jmp       l_CB8E
         db        0e9h,0,0

l_CB8E:  mov       sp,bp
         pop       bp
         ret       

l_CAB6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CB92   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_CB9E
         db        0e9h,0,0

l_CB9E:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax                       ; ‡¡slo © dku
         mov       ax,offset d_F059
         push      ds
         push      ax
         mov       ax,offset d_F159
         push      ds
         push      ax
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       si,offset d_F059
         xor       bx,bx
l_CBB5:  inc       bx
         cmp       byte ptr [bx+si],15h
         je        l_CBC0
         cmp       byte ptr [bx+si],20h
         jbe       l_CBB5
l_CBC0:  mov       cx,bx
         mov       si,offset d_ED59         ; buffer atribut– znak– text. © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       bl,[di]
         cmp       byte ptr [bx+di],2Dh
         jne       l_CC04
         mov       al,[bx+si]
         cmp       al,40h
         jb        l_CC04
         and       byte ptr [bx+si],7Fh
         cmp       al,80h
         jae       l_CC17
         dec       bx
         or        byte ptr [bx+si],40h
         mov       al,[bx+di]
         mov       si,offset d_F059
         add       si,cx
         mov       ah,[si]
         or        ax,2020h
         cmp       ax,6B6Bh
         jne       l_CC17
         push      bx
         mov       al,[bx+di-1]
         mov       bx,offset l_3378
         xlat      cs:[bx]
         test      al,40h
         pop       bx
         jz        l_CC17
         sub       byte ptr [bx+di],8
         jmp       short l_CC17

l_CC04:  inc       bx
         mov       byte ptr [bx+di],20h
         mov       si,offset d_F159
         add       si,cx
         mov       al,[si]
         mov       si,offset d_ED59         ; buffer atribut– znak– text. © dku
         and       al,[bx+si-1]
         mov       [bx+si],al
l_CC17:  mov       [di],bl
         push      cx
         call      l_3950                   ; spojen¡ textov˜ch © dk–
         call      l_CAB6
         dec       sp
         call      l_CA2F
         xor       al,1
         push      ax
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         jz        l_CC33
         dec       ax
l_CC33:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_CC3D
         ;jmp       l_CC49
         db        0e9h
         dw        l_CC49-$-2

l_CC3D:  call      l_5C9F                   ; posun kurzoru o © dek dol–
         call      l_6144
         call      l_5C32                   ; posun kurzoru o © dek nahoru
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
l_CC49:  ;jmp       l_CC4C
         db        0e9h,0,0

l_CC4C:  mov       sp,bp
         pop       bp
         ret       

l_CB92   ENDP

; -----------------------------------------------------------------------------
;        form tov n¡ odstavce
; -----------------------------------------------------------------------------

l_CC50   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         jmp       l_CDD9

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CC5C   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         ;jmp       l_CC6B
         db        0e9h,0,0

l_CC6B:  mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         inc       ax
         sub       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         push      ax
         mov       ax,[bp+4]
         push      ax
         mov       ax,ds:[d_FDCD]           ; max. po‡et znak– na © dek displeje
         push      ax
         mov       ax,[bp+4]
         push      ax
         mov       ax,0
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         mov       ax,[bp+4]
         push      ax
         call      l_4361                   ; zobrazen¡ prav‚ho okraje v 1 © dku
         ;jmp       l_CC94
         db        0e9h,0,0

l_CC94:  mov       sp,bp
         pop       bp
         ret       2

l_CC5C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CC9A   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         jmp       l_CD6E

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_CCA9   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         push      word ptr [bp-6]
         mov       bp,ax
         push      bp
         ;jmp       l_CCBB
         db        0e9h,0,0

l_CCBB:  dec       sp
         dec       sp
         mov       ax,[bp+0Ah]
         push      ax
         mov       ax,[bp+8]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_CCCD
         ;jmp       l_CD06
         db        0e9h
         dw        l_CD06-$-2

l_CCCD:  inc       cx
         mov       [bp-0Ah],ax
l_CCD1:  push      cx
         mov       ax,[bp-0Ah]
         xchg      ax,di
         mov       al,byte ptr ds:[d_ED59+di] ; buffer atribut– znak– text. © dku
         xor       ah,ah
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku
         mov       ax,[bp-0Ah]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         push      ax                       ; znak
         mov       ax,[bp+6]
         push      ax                       ; pozice
         mov       ax,[bp+4]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         mov       ax,[bp+6]
         inc       ax
         mov       [bp+6],ax
         pop       cx
         dec       cx
         jz        l_CD06
         inc       word ptr [bp-0Ah]
         ;jmp       l_CCD1
         db        0e9h
         dw        l_CCD1-$-2

l_CD06:  mov       ax,[bp+0Ah]
         cmp       ax,1
         je        l_CD11
         ;jmp       l_CD2D
         db        0e9h
         dw        l_CD2D-$-2

l_CD11:  mov       ax,20h
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - inverzn¡
         mov       ax,2Dh
         push      ax                       ; znak
         mov       ax,[bp+6]
         push      ax                       ; pozice
         mov       ax,[bp+4]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         mov       ax,[bp+6]
         inc       ax
         mov       [bp+6],ax
l_CD2D:  mov       ax,0
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - bˆ‘n˜
         mov       ax,20h
         push      ax                       ; znak
         mov       ax,[bp+6]
         push      ax                       ; pozice
         mov       ax,[bp+4]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         pop       cx
         add       ax,cx
         sub       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         cmp       ax,[bp+6]
         jle       l_CD5E
         ;jmp       l_CD65
         db        0e9h
         dw        l_CD65-$-2

l_CD5E:  mov       ax,[bp+4]
         push      ax
         call      l_4361                   ; zobrazen¡ prav‚ho okraje v 1 © dku
l_CD65:  ;jmp       l_CD68
         db        0e9h,0,0

l_CD68:  mov       sp,bp
         pop       bp
         ret       8

l_CCA9   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_CC9A)
; -----------------------------------------------------------------------------

l_CD6E:  dec       sp
         dec       sp
         mov       ax,1
         push      ax
         mov       bx,[bp-4]
         mov       ax,ss:[bx-0Ah]
         dec       ax
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         inc       ax
         sub       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         push      ax
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         push      ax
         call      l_CCA9
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         mov       bx,[bp-2]
         add       ax,ss:[bx-8]
         sub       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,1
         jl        l_CDAF
         ;jmp       l_CDB5
         db        0e9h
         dw        l_CDB5-$-2

l_CDAF:  mov       ax,1
         mov       [bp-8],ax
l_CDB5:  mov       bx,[bp-4]
         mov       ax,ss:[bx-0Ah]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         mov       ax,[bp-8]
         push      ax
         mov       bx,[bp-4]
         mov       ax,ss:[bx-0Ch]
         push      ax
         call      l_CCA9
         ;jmp       l_CDD5
         db        0e9h,0,0

l_CDD5:  mov       sp,bp
         pop       bp
         ret       

l_CC9A   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_CC50)
; -----------------------------------------------------------------------------

l_CDD9:  sub       sp,9
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_CDE7
         ;jmp       l_CDEA
         db        0e9h
         dw        l_CDEA-$-2

l_CDE7:  jmp       l_D0B5

l_CDEA:  mov       dx,1
         mov       cl,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         mov       ch,0
         dec       cx
         mov       si,cx
l_CDF7:  inc       si
         cmp       byte ptr ds:[d_EC59+si],20h ; buffer textov‚ho © dku
         je        l_CDF7
l_CDFF:  dec       si
         jz        l_CE3B
         mov       ax,word ptr ds:[d_EC59+si] ; buffer textov‚ho © dku
         cmp       al,20h
         je        l_CE3B
         test      byte ptr ds:[d_ED59+si],40h ; buffer atribut– znak– text. © dku
         jnz       l_CE35
         cmp       al,2Dh
         jne       l_CDFF
         cmp       si,dx
         je        l_CDFF
         mov       al,byte ptr ds:[d_EC59+si-1] ; buffer textov‚ho © dku
         mov       bx,offset l_3378
         xlat      cs:[bx]
         test      al,4
         jz        l_CDFF
         mov       al,ah
         xlat      cs:[bx]
         test      al,4
         jz        l_CDFF
         or        byte ptr ds:[d_ED59+si],80h ; buffer atribut– znak– text. © dku
         jmp       short l_CE3A

l_CE35:  cmp       si,cx
         jae       l_CDFF
         inc       dx
l_CE3A:  inc       dx
l_CE3B:  inc       si
         ;mov       [bp-6],si
         db        89h,0B6h,0FAh,0FFh       ;!
         ;mov       [bp-8],dx
         db        89h,96h,0F8h,0FFh        ;!
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         sub       ax,[bp-6]
         add       ax,2
         sub       ax,[bp-8]
         push      ax
         mov       al,byte ptr cs:[l_3270]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jg        l_CE64
         dec       ax
l_CE64:  push      ax
         mov       al,byte ptr cs:[l_325F]  ; rozdˆlov n¡ (1=zap., 0=vyp.)
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_CE75
         jmp       l_D00A

l_CE75:  mov       si,offset d_EC59         ; buffer textov‚ho © dku
         mov       di,offset d_F059
         mov       cl,[si]
         mov       ch,0
         inc       cx
         push      ds
         pop       es
         push      ds
         push      di
         cld       
         repne     movsb
         mov       byte ptr [di],20h
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         mov       bx,9
         ;mov       cx,[bp-6]
         db        8Bh,8Eh,0FAh,0FFh        ;!
         mov       di,offset d_F059
         mov       si,offset l_3378
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         push      cs
         pop       es
         call      dword ptr ds:[d_FDC7]    ; adresa vstupn¡ho bodu SCREEN.OVL
         ;mov       [bp-0Ah],ax
         db        89h,86h,0F6h,0FFh        ;!
         mov       ax,[bp-0Ah]
         cmp       ax,0
         jg        l_CEB3
         jmp       l_D00A

l_CEB3:  mov       al,byte ptr cs:[l_3260]  ; rozdˆl. s dotaz.(1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         jnz       l_CEC0
         ;jmp       l_CECF
         db        0e9h
         dw        l_CECF-$-2

l_CEC0:  mov       ax,[bp-0Ah]
         mov       [bp-6],ax
         mov       ax,3
         mov       [bp-8],ax
         jmp       l_D00A

l_CECF:  dec       sp
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         call      l_491F                   ; normalizace kurzoru na © dku
         jnz       l_CEE9
         ;jmp       l_CEEF
         db        0e9h
         dw        l_CEEF-$-2

l_CEE9:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
l_CEEF:  mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         je        l_CF00
         ;jmp       l_CF03
         db        0e9h
         dw        l_CF03-$-2

l_CF00:  call      l_5CFC                   ; rolov n¡ obrazovky o © dek nahoru
l_CF03:  call      l_4A3C                   ; inic. bufferu ‡¡sel zobraz. © dk–
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         inc       ax
         push      ax
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         inc       ax
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         cmp       ax,0
         mov       ax,1
         jz        l_CF1F
         dec       ax
l_CF1F:  pop       cx
         add       ax,cx
         mov       [bp-0Ch],ax
         mov       ax,[bp-0Ch]
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_CF36
         ;jmp       l_CF40
         db        0e9h
         dw        l_CF40-$-2

l_CF36:  call      l_5CFC                   ; rolov n¡ obrazovky o © dek nahoru
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         mov       [bp-0Ch],ax
l_CF40:  mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         push      ax
         call      l_CC5C
         mov       ax,[bp-0Ch]
         push      ax
         call      l_CC5C
         call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,2
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        78,'Rozdˆlen¡ = Enter, nerozdˆlovat = mezera nebo ^B, nastaven¡ dˆlen¡ kl v. ',27,' a ',26

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

l_CFB3:  call      l_CC9A
l_CFB6:  push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         ;mov       bx,[bp-0Ah]
         db        8Bh,9Eh,0F6h,0FFh        ;!
         cmp       al,13h
         jne       l_CFCF
         dec       bx
         ;cmp       bx,[bp-6]
         db        3Bh,9Eh,0FAh,0FFh        ;!
         jbe       l_D004
l_CFC9:  ;mov       [bp-0Ah],bx
         db        89h,9Eh,0F6h,0FFh        ;!
         jmp       short l_CFB3

l_CFCF:  cmp       al,4
         jne       l_CFDD
         inc       bx
         cmp       bl,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         jae       l_CFB6
         jmp       short l_CFC9

l_CFDD:  cmp       al,0Dh
         je        l_CFE5
         cmp       al,2Dh
         jne       l_CFF1
l_CFE5:  ;mov       [bp-6],bx
         db        89h,9Eh,0FAh,0FFh        ;!
         ;mov       word ptr [bp-8],3
         db        0C7h,86h,0F8h,0FFh,3,0   ;!
         jmp       short l_D004

l_CFF1:  cmp       al,1Bh
         je        l_CFFF
         cmp       al,2
         je        l_D004
         cmp       al,20h
         jne       l_CFB6
         jmp       short l_D004

l_CFFF:  mov       byte ptr ds:[d_F78A],1   ; 1=p©¡znak p©eru¨en¡ editace volby
l_D004:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_D00A:  mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         push      ax
         mov       ax,[bp-6]
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-6]
         mov       ax,1
         jle       l_D024
         dec       ax
l_D024:  pop       cx
         and       ax,cx
         push      ax
         mov       bx,[bp-2]
         mov       al,ss:[bx-9]
         xor       ah,ah
         xor       al,1
         push      ax
         mov       ax,[bp-6]
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-8]
         mov       ax,1
         jle       l_D044
         dec       ax
l_D044:  pop       cx
         and       ax,cx
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_D051
         ;jmp       l_D05A
         db        0e9h
         dw        l_D05A-$-2

l_D051:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         inc       ax
         mov       [bp-6],ax
l_D05A:  mov       ax,[bp-6]
         push      ax
         call      l_390B                   ; rozdˆlen¡ textov‚ho © dku
         call      l_4855                   ; korekce editovan‚ho © dku
         ;cmp       byte ptr [bp-8],3
         db        80h,0BEh,0F8h,0FFh,3     ;!
         jne       l_D0A3
         mov       si,offset d_EC59         ; buffer textov‚ho © dku
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         mov       bl,[si]
         mov       bh,0
         mov       ah,[bx+si]
         mov       al,ds:[d_F059+1]
         or        ax,2020h
         cmp       ax,636Bh
         jne       l_D093
         push      bx
         mov       al,[bx+si-1]
         mov       bx,offset l_3378
         xlat      cs:[bx]
         test      al,40h
         pop       bx
         jz        l_D093
         add       byte ptr [bx+si],8
l_D093:  mov       al,[bx+di]
         and       al,0BFh
         mov       [bx+di],al
         inc       bx
         mov       [si],bl
         mov       byte ptr [bx+si],2Dh
         or        al,40h
         mov       [bx+di],al
l_D0A3:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F159
         push      ds
         push      di
         call      l_3E83                   ; ulo‘en¡ edit. © dku do souboru
l_D0B5:  ;jmp       l_D0B8
         db        0e9h,0,0

l_D0B8:  mov       sp,bp
         pop       bp
         ret       

l_CC50   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_C9C1)
; -----------------------------------------------------------------------------

l_D0BC:  sub       sp,8
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D0CC
         ;jmp       l_D0CF
         db        0e9h
         dw        l_D0CF-$-2

l_D0CC:  jmp       l_D290

l_D0CF:  mov       ax,0
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         call      l_5D74                   ; p©esun kurzoru na za‡ tek © dku
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,1F01h
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         cmp       ax,0
         jg        l_D0F4
         ;jmp       l_D10E
         db        0e9h
         dw        l_D10E-$-2

l_D0F4:  dec       sp
         call      l_C9C8
         xor       al,1
         jnz       l_D0FF
         ;jmp       l_D108
         db        0e9h
         dw        l_D108-$-2

l_D0FF:  call      l_5C9F                   ; posun kurzoru o © dek dol–
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         ;jmp       l_D0F4
         db        0e9h
         dw        l_D0F4-$-2

l_D108:  call      l_5C9F                   ; posun kurzoru o © dek dol–
         jmp       l_D290

l_D10E:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jg        l_D11D
         ;jmp       l_D120
         db        0e9h
         dw        l_D120-$-2

l_D11D:  jmp       l_D290

l_D120:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,1001h
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         inc       ax
         mov       [bp-4],ax
         mov       ax,1
         mov       [bp-9],al
         mov       ax,[bp-4]
         mov       [bp-8],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-4]
         mov       [bp-6],ax
         dec       sp
         call      l_C9C8
         jnz       l_D15B
         ;jmp       l_D164
         db        0e9h
         dw        l_D164-$-2

l_D15B:  mov       ax,[bp-6]
         mov       [bp-8],ax
         ;jmp       l_D19A
         db        0e9h
         dw        l_D19A-$-2

l_D164:  mov       ax,[bp-8]
         cmp       ax,1
         je        l_D16F
         ;jmp       l_D19A
         db        0e9h
         dw        l_D19A-$-2

l_D16F:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         lea       di,[bp-8]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-8]
         cmp       ax,[bp-6]
         jg        l_D194
         ;jmp       l_D19A
         db        0e9h
         dw        l_D19A-$-2

l_D194:  mov       ax,[bp-6]
         mov       [bp-8],ax
l_D19A:  mov       ax,[bp-8]
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3270]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_D1B8
         ;jmp       l_D1BE
         db        0e9h
         dw        l_D1BE-$-2

l_D1B8:  mov       ax,1
         mov       [bp-8],ax
l_D1BE:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       ax,1
         mov       [bp-0Ah],al
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         cmp       ax,0
         jg        l_D1D4
         ;jmp       l_D241
         db        0e9h
         dw        l_D241-$-2

l_D1D4:  call      l_CAB6
         dec       sp
         call      l_CA2F
         jnz       l_D1E0
         ;jmp       l_D1EF
         db        0e9h
         dw        l_D1EF-$-2

l_D1E0:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         mov       ax,1
         push      ax
         call      l_3B6A
         call      l_5E8C
l_D1EF:  dec       sp
         call      l_CA7E
         push      ax
         dec       sp
         call      l_C9C8
         pop       cx
         or        ax,cx
         xor       al,1
         jnz       l_D202
         ;jmp       l_D208
         db        0e9h
         dw        l_D208-$-2

l_D202:  call      l_CB92
         ;jmp       l_D1EF
         db        0e9h
         dw        l_D1EF-$-2

l_D208:  dec       sp
         call      l_CA2F
         jnz       l_D211
         ;jmp       l_D214
         db        0e9h
         dw        l_D214-$-2

l_D211:  call      l_CC50
l_D214:  dec       sp
         call      l_C9C8
         mov       [bp-0Ah],al
         mov       al,byte ptr cs:[l_325E]  ; zarovn v n¡ (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       al,[bp-0Ah]
         xor       ah,ah
         xor       al,1
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_D233
         ;jmp       l_D236
         db        0e9h
         dw        l_D236-$-2

l_D233:  call      l_C695
l_D236:  mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim ln¡ d‚lka © dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_D241:  mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         push      ax
         dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl vesnice
         cmp       ax,1Bh
         mov       ax,1
         jz        l_D255
         dec       ax
l_D255:  pop       cx
         or        ax,cx
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         call      l_5C9F                   ; posun kurzoru o © dek dol–
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_D26A
         ;jmp       l_D27E
         db        0e9h
         dw        l_D27E-$-2

l_D26A:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim ln¡ d‚lka © dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         mov       ax,1
         mov       [bp-0Ah],al
l_D27E:  mov       ax,0
         mov       [bp-9],al
         mov       al,[bp-0Ah]
         xor       ah,ah
         or        ax,ax
         jnz       l_D290
         jmp       l_D1BE

l_D290:  ;jmp       l_D293
         db        0e9h,0,0

l_D293:  mov       sp,bp
         pop       bp
         ret       

l_C9C1   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OB a Form t/po konec textu (form t. po konec textu)
; -----------------------------------------------------------------------------

l_D297   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D29E
         db        0e9h,0,0

l_D29E:  mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D2AB
         ;jmp       l_D2AE
         db        0e9h
         dw        l_D2AE-$-2

l_D2AB:  ;jmp       l_D2DE
         db        0e9h
         dw        l_D2DE-$-2

l_D2AE:  call      l_C9C1
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,1
         jg        l_D2BE
         dec       ax
l_D2BE:  push      ax
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         pop       cx
         or        ax,cx
         push      ax
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         jnz       l_D2D4
         dec       ax
l_D2D4:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_D2DE
         ;jmp       l_D2AE
         db        0e9h
         dw        l_D2AE-$-2

l_D2DE:  ;jmp       l_D2E1
         db        0e9h,0,0

l_D2E1:  mov       sp,bp
         pop       bp
         ret       

l_D297   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-I (tabel tor)
; -----------------------------------------------------------------------------

l_D2E5   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D2EC
         db        0e9h,0,0

l_D2EC:  dec       sp
         dec       sp
         mov       al,byte ptr cs:[l_3261]  ; auto-tabel tor (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D2FB
         ;jmp       l_D36D
         db        0e9h
         dw        l_D36D-$-2

l_D2FB:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         dec       ax
         mov       [bp-4],ax
l_D305:  dec       sp
         mov       ax,[bp-4]
         push      ax
         call      l_3D1C                   ; test, zda je © dek definov n
         push      ax
         mov       ax,[bp-4]
         cmp       ax,1
         mov       ax,1
         jg        l_D31A
         dec       ax
l_D31A:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_D324
         ;jmp       l_D32E
         db        0e9h
         dw        l_D32E-$-2

l_D324:  mov       ax,[bp-4]
         dec       ax
         mov       [bp-4],ax
         ;jmp       l_D305
         db        0e9h
         dw        l_D305-$-2

l_D32E:  mov       ax,[bp-4]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       di,offset d_E69A         ; pozice kurzoru na © dku
         push      ds
         push      di
         call      l_387D
         mov       di,offset d_E69A         ; pozice kurzoru na © dku
         push      ds
         push      di
         call      l_384B
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jge       l_D361
         ;jmp       l_D36A
         db        0e9h
         dw        l_D36A-$-2

l_D361:  mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
l_D36A:  ;jmp       l_D3D7
         db        0e9h
         dw        l_D3D7-$-2

l_D36D:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         inc       ax
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         xchg      ax,di
         mov       al,byte ptr cs:[l_3278+di] ; line l © dku
         xor       ah,ah
         cmp       ax,2Dh
         mov       ax,1
         jnz       l_D392
         dec       ax
l_D392:  push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jge       l_D3A7
         dec       ax
l_D3A7:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_D3B1
         ;jmp       l_D36D
         db        0e9h
         dw        l_D36D-$-2

l_D3B1:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         xchg      ax,di
         mov       al,byte ptr cs:[l_3278+di] ; line l © dku
         xor       ah,ah
         cmp       ax,23h
         je        l_D3CE
         ;jmp       l_D3D7
         db        0e9h
         dw        l_D3D7-$-2

l_D3CE:  mov       ax,1
         mov       byte ptr ds:[d_F78F],al  ; 1=p©¡znak dekadick‚ho tabel toru
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_D3D7:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jge       l_D3EB
         ;jmp       l_D3F1
         db        0e9h
         dw        l_D3F1-$-2

l_D3EB:  call      l_5CE8                   ; posun kurzoru o © dek dol– Ctrl-X
         call      l_5D74                   ; p©esun kurzoru na za‡ tek © dku
l_D3F1:  ;jmp       l_D3F4
         db        0e9h,0,0

l_D3F4:  mov       sp,bp
         pop       bp
         ret

l_D2E5   ENDP

; *****************************************************************************
;
;                        Obsluha nastaven¡ line lu © dku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        nastaven¡ lev‚ho okraje (VSTUP: [SP+2] (2) po‘adovan˜ lev˜ okraj)
; -----------------------------------------------------------------------------

l_D3F8   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D3FF
         db        0e9h,0,0

; ------ n vrat p–vodn¡ch znak– pod okraji v line lu © dku

l_D3FF:  call      l_3F89                   ; n vrat line lu © dk– pod okraji

; ------ nov˜ lev˜ okraj

         mov       ax,[bp+4]                ; zadan˜ lev˜ okraj
         dec       ax
         mov       byte ptr cs:[l_3259],al  ; po‡ te‡n¡ pozice (lev˜ okraj)

; ------ kontrola, zda prav˜ okraj p©es hl maxim ln¡ konec © dku

         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         push      ax                       ; ¨¡©ka © dku textu
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx                    ; prav˜ okraj
         cmp       ax,241                   ; p©es hl prav˜ okraj maxim. konec ?
         jg        l_D422                   ; prav˜ okraj p©es hl maxim. konec
         ;jmp       l_D434
         db        0e9h
         dw        l_D434-$-2

; ------ omezen¡ prav‚ho okraje

l_D422:  mov       ax,241                   ; maxim ln¡ prav˜ okraj
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah                    ; lev˜ okraj
         pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; nov  ¨¡©ka textu
         mov       byte ptr cs:[l_325A],al  ; ¨¡©ka © dku textu (znak–)

; ------ nastaven¡ nov˜ch okraj– v line lu © dku

l_D434:  call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku
         call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–
         ;jmp       l_D43D
         db        0e9h,0,0

l_D43D:  mov       sp,bp
         pop       bp
         ret       2

l_D3F8   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ prav‚ho okraje (VSTUP: [SP+2] (2) po‘adovan˜ prav˜ okraj)
; -----------------------------------------------------------------------------

l_D443   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D44A
         db        0e9h,0,0

; ------ kontrola, zda je prav˜ okraj minim lnˆ 4 pozice za lev˜m okrajem

l_D44A:  mov       ax,[bp+4]                ; zadan˜ prav˜ okraj
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         add       ax,4                     ; rezerva - minim ln¡ ¨¡©ka 4 znaky
         pop       cx
         xchg      ax,cx
         cmp       ax,cx                    ; je prav˜ okraj za lev˜m okrajem ?
         jg        l_D460                   ; prav˜ okraj je zad n OK
         ;jmp       l_D479
         db        0e9h
         dw        l_D479-$-2

; ------ nastaven¡ prav‚ho okraje

l_D460:  call      l_3F89                   ; n vrat line lu © dk– pod okraji
         mov       ax,[bp+4]                ; zadan˜ prav˜ okraj
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; nov  ¨¡©ka textu
         inc       ax                       ; korekce
         mov       byte ptr cs:[l_325A],al  ; ¨¡©ka © dku textu (znak–)
         call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–
l_D479:  ;jmp       l_D47C
         db        0e9h,0,0

l_D47C:  mov       sp,bp
         pop       bp
         ret       2

l_D443   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OI a Str nka/line l (menu line lu © dku)
; -----------------------------------------------------------------------------

l_D482   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D489
         db        0e9h,0,0

; ------ zobrazen¡ line lu © dku

l_D489:  sub       sp,117h                  ; rezerva pro lok ln¡ buffer
         call      l_441E                   ; zobrazen¡ line lu © dku

; ------ zobrazen¡ n povˆdy k nastaven¡ line lu © dku

         mov       ax,15                    ; ‡¡slo n povˆdy -
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k line lu

; ------ pozice kurzoru v textu line lu

         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         mov       [bp-111h],ax             ; pozice kurzoru v textu line lu

; ------ £schova lev‚ho okraje

         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         mov       [bp-10Dh],ax             ; £schova lev‚ho okraje

; ------ £schova prav‚ho okraje (¨¡©ky textu)

         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         mov       [bp-10Fh],ax             ; £schova ¨¡©ky textu

; ------ £schova line lu do bufferu v z sobn¡ku

         lea       di,[bp-102h]             ; buffer k £schovˆ line lu
         push      ss
         push      di
         mov       di,offset l_3278         ; line l © dku
         push      cs
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ £schova znaku pod lev˜m okrajem

         mov       al,byte ptr ds:[d_F79B]  ; £schova znaku line lu-lev˜ okraj
         xor       ah,ah
         mov       [bp-118h],al

; ------ £schova znaku pod prav˜m okrajem

         mov       al,byte ptr ds:[d_F79C]  ; £schova znaku line lu-prav˜ okraj
         xor       ah,ah
         mov       [bp-119h],al

; ------ £schova offsetu za‡ tku zobrazen‚ho © dku

         mov       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         mov       [bp-117h],ax

; ------ zobrazen¡ kurzoru na © dku

l_D4E7:  mov       ax,[bp-111h]             ; pozice kurzoru v textu line lu
         push      ax
         mov       ax,0
         push      ax
         call      l_352A                   ; zobrazen¡ kurzoru

         mov       al,byte ptr ds:[d_F78C]
         xor       ah,ah
         or        ax,ax
         jnz       l_D4FF
         ;jmp       l_D531
         db        0e9h
         dw        l_D531-$-2

; ------ zobrazen¡ ‡¡sla pozice kurzoru na © dku

l_D4FF:  mov       ax,[bp-111h]             ; pozice kurzoru v textu line lu
         push      ax                       ; ‡¡slo k dek¢dov n¡
         mov       ax,3
         push      ax                       ; max. form tovan  d‚lka
         lea       di,[bp-10Bh]             ; buffer k dek¢dov n¡ ‡¡sla
         push      ss
         mov       cl,8                     ; maxim ln¡ d‚lka ©etˆzce
         call      l_0DF3                   ; dek¢d. ‡¡sla INTEGER na text (DEK)

; ------ p©id n¡ mezery p©ed ‡¡slo

         mov       ax,37h
         push      ax                       ; pozice k zobrazen¡ ‡¡sla
         mov       ax,1
         push      ax                       ; © dek k zobrazen¡ ‡¡sla
         lea       di,[bp-10Bh]
         push      ss                       ; buffer s dek¢dovan˜m ‡¡slem
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax," "*HI + 1            ; ©etˆzec - znak mezery
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ zobrazen¡ ‡¡sla pozice kurzoru na © dku

         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ vstup znaku z kl vesnice

l_D531:  dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         mov       [bp-115h],ax             ; zadan  kl vesa

; ------ vypnut¡ kurzoru

         mov       ax,[bp-111h]             ; pozice kurzoru v textu line lu
         push      ax
         mov       ax,0
         push      ax                       ; © dek k zobrazen¡ kurzoru
         call      l_352A                   ; zobrazen¡ kurzoru

         mov       di,offset l_3278         ; line l © dku
         mov       ax,[bp-115h]             ; zadan  kl vesa
         mov       bx,[bp-111h]             ; pozice kurzoru v textu line lu
         cld       

; ------ vymaz n¡/obnoven¡ tabel tor– Ctrl-H (BS) nebo Ctrl-G (DEL)

         cmp       al,CtrlG                 ; zru¨en¡ znaku p©ed kurzorem DEL ?
         je        l_D55A                   ; vymaz n¡ tabel tor– Ctrl-G
         cmp       al,CtrlH                 ; zru¨en¡ znaku za kurzorem BS ?
         jne       l_D58B                   ; nen¡ vymaz n¡ tabel tor– Ctrl-H

; ------ test, zda je v line lu nˆjak˜ znak tabel toru

l_D55A:  mov       bl,cs:[di]               ; po‡et znak– v bufferu
         mov       bh,0
         mov       cx,bx                    ; po‡et znak– v bufferu
l_D561:  cmp       byte ptr cs:[bx+di],1Fh  ; je znak tabel toru ?
         je        l_D57F                   ; je tabel tor - vymaz n¡
         dec       bx                       ; ‡¡ta‡ tabel tor–
         jnz       l_D561                   ; dal¨¡ znak

; ------ inicializace line lu na standardn¡ hodnotu

l_D56A:  inc       di
         inc       bx
         mov       byte ptr cs:[di],"-"     ; vymaz n¡ pozice
         cmp       bl,5                     ; bylo 5 znak– ?
         jb        l_D57B                   ; nen¡ 5 znak–
         mov       byte ptr cs:[di],1Fh     ; ozna‡en¡ tabel toru
         mov       bl,0                     ; ‡¡ta‡ pozic tabel toru
l_D57B:  loop      l_D56A                   ; dal¨¡ znak
         jmp       short l_D586

; ------ je nˆjak˜ znak tabel toru - vymaz n¡ tabel tor– v line lu

l_D57F:  push      cs
         pop       es
         mov       al,2Dh
         inc       di
         repne     stosb
l_D586:  call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–
         jmp       short l_D5EC

; ------ kl vesa Ctrl-D (posun kurzoru o pozici vpravo)

l_D58B:  cmp       al,CtrlD                 ; je pozice vpravo ?
         jne       l_D597                   ; nen¡ pozice vpravo
         cmp       bl,240                   ; je ji‘ maxim ln¡ pozice na © dku
         jae       l_D5C7                   ; je ji‘ maxim ln¡ pozice na © dku
         inc       bx                       ; zv˜¨en¡ pozice na © dku
         jmp       short l_D59E

; ------ kl vesa Ctrl-S (posun kurzoru o pozici vlevo)

l_D597:  cmp       al,CtrlS                 ; je pozice vlevo ?
         jne       l_D5A4                   ; nen¡ pozice vlevo
         dec       bx                       ; sn¡‘en¡ pozice na © dku
         jz        l_D5C7                   ; byl ji‘ za‡ tek © dku
l_D59E:  mov       [bp-111h],bx             ; pozice kurzoru v textu line lu
         jmp       short l_D5C7

; ------ obsluha kl vesy Ctrl-Q (roz¨¡©en‚ volby)

l_D5A4:  cmp       al,CtrlQ                 ; je kl vesa Ctrl-Q ?
         jne       l_D5C9                   ; nen¡ kl vesa Ctrl-Q
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         mov       bl,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         mov       bh,0
         inc       bx                       ; po‡ te‡n¡ pozice (lev˜ okraj)
         cmp       al,"S"                   ; kl vesa Ctrl-QS (za‡ tek © dku)
         je        l_D5C3                   ; je za‡ tek © dku
         cmp       al,"D"                   ; kl vesa Ctrl-QD (konec © dku)
         jne       l_D626                   ; nen¡ konec © dku
         add       bl,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         dec       bx
         dec       bx                       ; prav˜ okraj
l_D5C3:  mov       [bp-111h],bx             ; nov  pozice kurzoru
l_D5C7:  jmp       short l_D626

; ------ obsluha kl vesy TAB (nastaven¡/zru¨en¡ zna‡ky tabel toru)

l_D5C9:  cmp       al,TAB
         jne       l_D5D1
         mov       al,1Fh                   ; zna‡ka tabel toru
         jmp       short l_D5D5

; ------ obsluha kl vesy "#" (nastaven¡ dekadick‚ho tabel toru)

l_D5D1:  cmp       al,"#"                   ; je dekadick˜ tabel tor ?
         jne       l_D5EE                   ; nen¡ dekadick˜ tabel tor
l_D5D5:  cmp       byte ptr cs:[bx+di],"-"  ; je vypnut˜ tabel tor ?
         je        l_D5E9                   ; tabel tor je vypnut˜
         mov       al,"-"                   ; zna‡ka pro vypnut¡ tabel toru
         cmp       byte ptr cs:[bx+di],1Fh  ; je zna‡ka tabel toru ?
         je        l_D5E9                   ; zna‡ka pro vypnut¡ tabel toru
         cmp       byte ptr cs:[bx+di],"#"  ; je dekadick˜ tabel tor ?
         jne       l_D626                   ; nen¡ tabel tor - je okraj
l_D5E9:  mov       cs:[bx+di],al            ; ulo‘en¡ zna‡ky
l_D5EC:  jmp       short l_D642

; ------ obsluha kl vesy ESC - p©eru¨en¡ volby (a n vrat p–vodn¡ho obsahu)

l_D5EE:  cmp       al,ESCP                  ; je kl vesa ESC ?
         jne       l_D628                   ; nen¡ kl vesa ESC
         mov       al,[bp-10Dh]             ; uschovan˜ lev˜ okraj
         mov       byte ptr cs:[l_3259],al  ; n vrat lev‚ho okraje
         mov       al,[bp-10Fh]             ; uschovan  ¨¡©ka textu
         mov       byte ptr cs:[l_325A],al  ; n vrat ¨¡©ky © dku textu (znak–)
         push      ds
         push      cs
         pop       es
         push      ss
         pop       ds
         lea       si,[bp-102h]             ; buffer s uschovan˜m line lem
         mov       cl,[si]                  ; d‚lka textu
         mov       ch,0
         inc       cx
         repne     movsb                    ; n vrat line lu © dku
         pop       ds
         mov       al,[bp-118h]             ; uschovan˜ znak pod lev˜m okrajem
         mov       byte ptr ds:[d_F79B],al  ; n vrat znaku line lu-lev˜ okraj
         mov       al,[bp-119h]             ; uschovan˜ znak pod prav˜m okrajem
         mov       byte ptr ds:[d_F79C],al  ; n vrat znaku line lu-prav˜ okraj
         mov       byte ptr ds:[d_F78A],1   ; 1=p©¡znak p©eru¨en¡ editace volby
l_D626:  jmp       short l_D645

; ------ obsluha kl vesy "L" - nastaven¡ lev‚ho okraje

l_D628:  cmp       al,"L"
         je        l_D630
         cmp       al,"l"
         jne       l_D636
l_D630:  push      bx
         call      l_D3F8                   ; nastaven¡ lev‚ho okraje
         jmp       short l_D642

; ------ obsluha kl vesy "R" - nastaven¡ prav‚ho okraje

l_D636:  cmp       al,"R"
         je        l_D63E
         cmp       al,"r"
         jne       l_D645
l_D63E:  push      bx
         call      l_D443                   ; nastaven¡ prav‚ho okraje

; ------ zobrazen¡ a normalizace line lu © dku

l_D642:  call      l_441E                   ; zobrazen¡ line lu © dku
l_D645:  dec       sp
         mov       ax,[bp-111h]             ; pozice kurzoru v textu line lu
         push      ax
         call      l_491F                   ; normalizace kurzoru na © dku
         jnz       l_D653
         ;jmp       l_D656
         db        0e9h
         dw        l_D656-$-2
l_D653:  call      l_441E                   ; zobrazen¡ line lu © dku

; ------ test, zda je kl vesa ENTER nebo ESC

l_D656:  mov       ax,[bp-115h]             ; zadan  kl vesa
         cmp       ax,CR                    ; je kl vesa ENTER ?
         mov       ax,1
         jz        l_D663
         dec       ax
l_D663:  push      ax
         mov       ax,[bp-115h]             ; zadan  kl vesa
         cmp       ax,ESCP                  ; je kl vesa ESC ?
         mov       ax,1
         jz        l_D671
         dec       ax
l_D671:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_D67B
         jmp       l_D4E7

; ------ ukon‡en¡ volby kl vesy ENTER nebo ESC

l_D67B:  mov       ax,[bp-117h]
         mov       word ptr ds:[d_E6A4],ax  ; offset za‡ tku zobrazen‚ho © dku
         call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ;jmp       l_D68E
         db        0e9h,0,0

l_D68E:  mov       sp,bp
         pop       bp
         ret

l_D482   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ lev‚ho okraje
; -----------------------------------------------------------------------------

l_D692   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D699
         db        0e9h,0,0

l_D699:  mov       ax,[bp+4]                ; po‘adovan˜ lev˜ okraj
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         call      l_D3F8                   ; nastaven¡ lev‚ho okraje
         mov       al,byte ptr cs:[l_3264]  ; zobr. line lu © d.(1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D6B7
         ;jmp       l_D6BA
         db        0e9h
         dw        l_D6BA-$-2

l_D6B7:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_D6BA:  call      l_5D74                   ; p©esun kurzoru na za‡ tek © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_D6C3
         db        0e9h,0,0

l_D6C3:  mov       sp,bp
         pop       bp
         ret       2

l_D692   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ prav‚ho okraje
; -----------------------------------------------------------------------------

l_D6C9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D707
         db        0e9h
         dw        l_D707-$-2

; -----------------------------------------------------------------------------
;        zobrazen¡ prav‚ho okraje
; -----------------------------------------------------------------------------

l_D6D0   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_D6DC
         db        0e9h,0,0

l_D6DC:  mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         sub       ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         push      ax                       ; pozice k zobrazen¡ ‡ ry
         mov       ax,1
         push      ax                       ; prvn¡ © dek k zobrazen¡ ‡ ry
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         push      ax                       ; posledn¡ © dek k zobrazen¡ ‡ ry
         mov       ax,80h
         push      ax                       ; maska pro zobrazen¡ ‡ ry
         call      l_35B7                   ; zobrazen¡ okraje (‡ ry)
         ;jmp       l_D703
         db        0e9h,0,0

l_D703:  mov       sp,bp
         pop       bp
         ret

l_D6D0   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_D6C9)
; -----------------------------------------------------------------------------

l_D707:  call      l_D6D0                   ; zobrazen¡ prav‚ho okraje
         mov       ax,[bp+4]                ; po‘adovan˜ prav˜ okraj
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         call      l_D443                   ; nastaven¡ prav‚ho okraje
         call      l_D6D0                   ; zobrazen¡ prav‚ho okraje
         mov       al,byte ptr cs:[l_3264]  ; zobr. line lu © d.(1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D72B
         ;jmp       l_D72E
         db        0e9h
         dw        l_D72E-$-2

l_D72B:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_D72E:  ;jmp       l_D731
         db        0e9h,0,0

l_D731:  mov       sp,bp
         pop       bp
         ret       2

l_D6C9   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OF a Str nka/prav˜ okraj<-© dek (R okraj dle © dku)
; -----------------------------------------------------------------------------

l_D737   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D73E
         db        0e9h,0,0

l_D73E:  dec       sp
         dec       sp
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_38AF
         mov       ax,[bp-4]
         push      ax
         call      l_D6C9
         ;jmp       l_D760
         db        0e9h,0,0

l_D760:  mov       sp,bp
         pop       bp
         ret

l_D737   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OC a Form t/centrov n¡ (centrov n¡ © dku)
; -----------------------------------------------------------------------------

l_D764   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_D76B
         db        0e9h,0,0

l_D76B:  dec       sp
         dec       sp
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       ax,1
         push      ax
         call      l_5972
         mov       ax,1
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-4]
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jle       l_D79A
         ;jmp       l_D7E9
         db        0e9h
         dw        l_D7E9-$-2

l_D79A:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,1
         push      ax
         mov       ax,[bp-4]
         dec       ax
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jl        l_D7C1
         ;jmp       l_D7DE
         db        0e9h
         dw        l_D7DE-$-2

l_D7C1:  mov       ax,1
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       cx,1
         shr       ax,cl
         push      ax
         call      l_3799                   ; odsun zbytku © dku INSERT
l_D7DE:  mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim ln¡ d‚lka © dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_D7E9:  ;jmp       l_D7EC
         db        0e9h,0,0

l_D7EC:  mov       sp,bp
         pop       bp
         ret

l_D764   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OS a Str nka/© dk– (volba po‡tu © dk– na str nku)
; -----------------------------------------------------------------------------

l_D7F0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_D8F4

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_D7F7   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_D803
         db        0e9h,0,0

l_D803:  sub       sp,6
         lea       di,[bp-0Ah]
         push      ss
         push      di
         mov       di,offset l_3242
         push      cs
         call      l_1950
         call      l_1970
         mov       al,byte ptr cs:[l_3257]  ; samostatn˜ list (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_D822
         ;jmp       l_D831
         db        0e9h
         dw        l_D831-$-2

l_D822:  lea       di,[bp-0Ah]
         push      ss
         push      di
         mov       di,offset l_3248
         push      cs
         call      l_1950
         call      l_1970
l_D831:  lea       di,[bp-0Ah]
         push      ss
         call      l_1950
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Dh]
         call      l_1B0C
         call      l_19BC
         call      l_195F
         db        82h,0f5h,28h,5ch,8fh,22h

         call      l_19AD
         mov       ax,4
         push      ax
         mov       ax,2
         push      ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0bh]
         push      ss
         mov       cl,8
         call      l_0E0C
         mov       ax,41h
         push      ax
         mov       ax,10
         push      ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0bh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         ;jmp       l_D884
         db        0e9h,0,0

l_D884:  mov       sp,bp
         pop       bp
         ret

l_D7F7   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_D888   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_D894
         db        0e9h,0,0

l_D894:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         sub       sp,9
         les       di,dword ptr [bp+4]
         mov       ax,es:[di]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4Bh
         push      ax                       ; pozice k zobrazen¡ textu
         mov       ax,[bp+8]
         push      ax                       ; © dek k zobrazen¡ textu
         mov       ax,2
         push      ax                       ; maxim ln¡ d‚lka textu
         mov       ax,10h
         push      ax                       ; typ znak– (pouze ‡¡slice)
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Bh]
         push      ss                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru


         les       di,dword ptr [bp+4]
         mov       ax,0
         mov       es:[di],ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Bh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-13h]
         push      ss
         call      l_0E68                   ; na‡ten¡ ‡¡sla INTEGER
         ;jmp       l_D8EE
         db        0e9h,0,0

l_D8EE:  mov       sp,bp
         pop       bp
         ret       6

l_D888   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_D7F0)
; -----------------------------------------------------------------------------

l_D8F4:  sub       sp,11h
         mov       ax,11h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       ax,4Bh
         push      ax
         mov       ax,7
         push      ax
         sub       sp,9
         mov       al,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         xor       ah,ah
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,4Bh
         push      ax
         mov       ax,8
         push      ax
         sub       sp,9
         mov       al,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         xor       ah,ah
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
l_D938:  mov       al,byte ptr cs:[l_325D]  ; po‡et © dk– na str nku
         xor       ah,ah
         mov       [bp-0Dh],ax
         call      l_D7F7
         mov       ax,6
         push      ax
         lea       di,[bp-0Dh]
         push      ss
         push      di
         call      l_D888
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_D95C
         ;jmp       l_D95F
         db        0e9h
         dw        l_D95F-$-2

l_D95C:  jmp       l_DA25

l_D95F:  mov       ax,[bp-0Dh]
         cmp       ax,3
         jg        l_D96A
         ;jmp       l_D938
         db        0e9h
         dw        l_D938-$-2

l_D96A:  call      l_D7F7
l_D96D:  mov       al,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         xor       ah,ah
         mov       [bp-0Fh],ax
         mov       ax,7
         push      ax
         lea       di,[bp-0Fh]
         push      ss
         push      di
         call      l_D888
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_D98E
         ;jmp       l_D991
         db        0e9h
         dw        l_D991-$-2

l_D98E:  jmp       l_DA25

l_D991:  mov       ax,[bp-0Fh]
         cmp       ax,0Ah
         mov       ax,1
         jle       l_D99D
         dec       ax
l_D99D:  push      ax
         mov       ax,[bp-0Dh]
         sub       ax,[bp-0Fh]
         cmp       ax,3
         mov       ax,1
         jg        l_D9AD
         dec       ax
l_D9AD:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_D9B7
         ;jmp       l_D96D
         db        0e9h
         dw        l_D96D-$-2

l_D9B7:  mov       al,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         xor       ah,ah
         mov       [bp-11h],ax
         mov       ax,8
         push      ax
         lea       di,[bp-11h]
         push      ss
         push      di
         call      l_D888
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_D9D8
         ;jmp       l_D9DB
         db        0e9h
         dw        l_D9DB-$-2

l_D9D8:  ;jmp       l_DA25
         db        0e9h
         dw        l_DA25-$-2

l_D9DB:  mov       ax,[bp-11h]
         cmp       ax,0Ah
         mov       ax,1
         jle       l_D9E7
         dec       ax
l_D9E7:  push      ax
         mov       ax,[bp-0Dh]
         sub       ax,[bp-0Fh]
         sub       ax,[bp-11h]
         cmp       ax,3
         mov       ax,1
         jg        l_D9FA
         dec       ax
l_D9FA:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_DA04
         ;jmp       l_D9B7
         db        0e9h
         dw        l_D9B7-$-2

l_DA04:  mov       ax,[bp-0Dh]
         mov       byte ptr cs:[l_325D],al  ; po‡et © dk– na str nku
         mov       ax,[bp-0Fh]
         mov       byte ptr cs:[l_325B],al  ; po‡et © dk– z hlav¡
         mov       ax,[bp-11h]
         mov       byte ptr cs:[l_325C],al  ; po‡et © dk– paty
         mov       ax,[bp-0Dh]
         sub       ax,[bp-0Fh]
         sub       ax,[bp-11h]
         mov       word ptr ds:[d_F7A9],ax  ; po‡et © dk– na str nku bez okraj–
l_DA25:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_DA2B
         db        0e9h,0,0

l_DA2B:  mov       sp,bp
         pop       bp
         ret

l_D7F0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_DA2F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DA36
         db        0e9h,0,0

l_DA36:  dec       sp
         dec       sp
         mov       ax,[bp+8]
         cmp       ax,0
         je        l_DA43
         ;jmp       l_DA46
         db        0e9h
         dw        l_DA46-$-2

l_DA43:  jmp       l_DAD0

l_DA46:  call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,[bp+8]
         push      ax
         call      l_3B6A
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_DA5F
         ;jmp       l_DA62
         db        0e9h
         dw        l_DA62-$-2

l_DA5F:  ;jmp       l_DAD0
         db        0e9h
         dw        l_DAD0-$-2

l_DA62:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,1
         push      ax
         mov       ax,[bp+8]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_DA78
         ;jmp       l_DAB1
         db        0e9h
         dw        l_DAB1-$-2

l_DA78:  inc       cx
         mov       [bp-4],ax
l_DA7C:  push      cx
         les       di,dword ptr [bp+4]
         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,0FFFCh
         push      es
         push      di
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         add       ax,[bp-4]
         dec       ax
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_3C8D
         pop       cx
         dec       cx
         jz        l_DAB1
         inc       word ptr [bp-4]
         ;jmp       l_DA7C
         db        0e9h
         dw        l_DA7C-$-2

l_DAB1:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         add       ax,[bp+8]
         dec       ax
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         mov       ax,0
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_DAD0:  ;jmp       l_DAD3
         db        0e9h,0,0

l_DAD3:  mov       sp,bp
         pop       bp
         ret       6

l_DA2F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_DAD9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DAE0
         db        0e9h,0,0

l_DAE0:  dec       sp
         dec       sp
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         push      ax
         mov       ax,[bp+8]
         cmp       ax,0
         mov       ax,1
         jz        l_DAF3
         dec       ax
l_DAF3:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_DAFD
         ;jmp       l_DB00
         db        0e9h
         dw        l_DB00-$-2

l_DAFD:  jmp       l_DBA9

l_DB00:  mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         inc       ax
         mov       [bp-4],ax
         mov       ax,[bp+8]
         cmp       ax,[bp-4]
         jg        l_DB16
         ;jmp       l_DB1C
         db        0e9h
         dw        l_DB1C-$-2

l_DB16:  mov       ax,[bp-4]
         mov       [bp+8],ax
l_DB1C:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,[bp+8]
         dec       ax
         pop       cx
         add       ax,cx
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,1
         push      ax
         mov       ax,0Ah
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_DB3A
         ;jmp       l_DB5D
         db        0e9h
         dw        l_DB5D-$-2

l_DB3A:  inc       cx
         mov       [bp-4],ax
l_DB3E:  push      cx
         les       di,dword ptr [bp+4]
         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,0FFFCh
         push      es
         push      di
         call      l_39D4                   ; uvolnˆn¡ © dku z pamˆti
         pop       cx
         dec       cx
         jz        l_DB5D
         inc       word ptr [bp-4]
         ;jmp       l_DB3E
         db        0e9h
         dw        l_DB3E-$-2

l_DB5D:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       ax,[bp+8]
         mov       cx,2
         shl       ax,cl
         call      l_0F2E                   ; posun dat (s p©ekryvem)
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di                       ; adresa
         mov       ax,[bp+8]
         mov       cx,2
         shl       ax,cl
         push      ax                       ; d‚lka
         mov       ax,0                     ; konstanta
         call      l_0F25                   ; vynulov n¡ bufferu konstantou
         mov       ax,0
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         call      l_6886
l_DBA9:  ;jmp       l_DBAC
         db        0e9h,0,0

l_DBAC:  mov       sp,bp
         pop       bp
         ret       6

l_DAD9   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/zobrazen¡ z hlav¡ (zobrazen¡ z hlav¡)
; -----------------------------------------------------------------------------

l_DBB2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DBB9
         db        0e9h,0,0

l_DBB9:  mov       al,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         xor       ah,ah
         push      ax
         mov       di,offset d_E6AB         ; adresy © dk– z hlav¡
         push      ds
         push      di
         call      l_DA2F
         ;jmp       l_DBCB
         db        0e9h,0,0

l_DBCB:  mov       sp,bp
         pop       bp
         ret

l_DBB2   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/zobrazen¡ paty (zobrazen¡ paty)
; -----------------------------------------------------------------------------

l_DBCF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DBD6
         db        0e9h,0,0

l_DBD6:  mov       al,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         xor       ah,ah
         push      ax
         mov       di,offset d_E6D3         ; adresy © dk– paty
         push      ds
         push      di
         call      l_DA2F
         ;jmp       l_DBE8
         db        0e9h,0,0

l_DBE8:  mov       sp,bp
         pop       bp
         ret

l_DBCF   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/blok jako z hlav¡ (ozna‡en˜ blok jako z hlav¡)
; -----------------------------------------------------------------------------

l_DBEC   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DBF3
         db        0e9h,0,0

l_DBF3:  mov       al,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         xor       ah,ah
         push      ax
         mov       di,offset d_E6AB         ; adresy © dk– z hlav¡
         push      ds
         push      di
         call      l_DAD9
         ;jmp       l_DC05
         db        0e9h,0,0

l_DC05:  mov       sp,bp
         pop       bp
         ret

l_DBEC   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/blok jako pata (ozna‡en˜ blok jako pata)
; -----------------------------------------------------------------------------

l_DC09   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DC10
         db        0e9h,0,0

l_DC10:  mov       al,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         xor       ah,ah
         push      ax
         mov       di,offset d_E6D3         ; adresy © dk– paty
         push      ds
         push      di
         call      l_DAD9
         ;jmp       l_DC22
         db        0e9h,0,0

l_DC22:  mov       sp,bp
         pop       bp
         ret

l_DC09   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_DC26   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DC2D
         db        0e9h,0,0

l_DC2D:  dec       sp
         dec       sp
         mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_DC3B
         ;jmp       l_DC45
         db        0e9h
         dw        l_DC45-$-2

l_DC3B:  mov       ax,0Eh
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         ;jmp       l_DC4C
         db        0e9h
         dw        l_DC4C-$-2

l_DC45:  mov       ax,10h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
l_DC4C:  dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         mov       [bp-4],ax
         mov       ax,0Eh
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         dec       sp
         mov       ax,[bp-4]
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         cmp       ax,4Bh
         je        l_DC6B
         ;jmp       l_DC83
         db        0e9h
         dw        l_DC83-$-2

l_DC6B:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_DC77
         ;jmp       l_DC7D
         db        0e9h
         dw        l_DC7D-$-2

l_DC77:  call      l_DBB2
         ;jmp       l_DC80
         db        0e9h
         dw        l_DC80-$-2

l_DC7D:  call      l_DBEC
l_DC80:  ;jmp       l_DCA0
         db        0e9h
         dw        l_DCA0-$-2

l_DC83:  cmp       ax,46h
         je        l_DC8B
         ;jmp       l_DCA0
         db        0e9h
         dw        l_DCA0-$-2

l_DC8B:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_DC97
         ;jmp       l_DC9D
         db        0e9h
         dw        l_DC9D-$-2

l_DC97:  call      l_DBCF
         ;jmp       l_DCA0
         db        0e9h
         dw        l_DCA0-$-2

l_DC9D:  call      l_DC09
l_DCA0:  ;jmp       l_DCA3
         db        0e9h,0,0

l_DCA3:  mov       sp,bp
         pop       bp
         ret       2

l_DC26   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-ON a Str nka/nedokumentn¡ (nedokumentn¡ m¢d zap/vyp)
; -----------------------------------------------------------------------------

l_DCA9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DCB0
         db        0e9h,0,0

l_DCB0:  mov       ax,0
         mov       word ptr ds:[d_E6A4],ax  ; offset za‡ tku zobrazen‚ho © dku
         call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         mov       byte ptr cs:[l_3263],al  ; zobraz. str nk. (1=zap., 0=vyp.)
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         mov       byte ptr cs:[l_3265],al  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_DCDC
         ;jmp       l_DCED
         db        0e9h
         dw        l_DCED-$-2

l_DCDC:  mov       ax,1
         push      ax
         call      l_D3F8                   ; nastaven¡ lev‚ho okraje
         mov       ax,0F0h
         push      ax
         call      l_D443                   ; nastaven¡ prav‚ho okraje
         ;jmp       l_DCFB
         db        0e9h
         dw        l_DCFB-$-2

l_DCED:  mov       ax,6
         push      ax
         call      l_D3F8                   ; nastaven¡ lev‚ho okraje
         mov       ax,4Bh
         push      ax
         call      l_D443                   ; nastaven¡ prav‚ho okraje
l_DCFB:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_DD04
         db        0e9h,0,0

l_DD04:  mov       sp,bp
         pop       bp
         ret

l_DCA9   ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ zna‡ky u‘iv. tisk. volby
; -----------------------------------------------------------------------------

l_DD08   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DD0F
         db        0e9h,0,0

l_DD0F:  dec       sp
         dec       sp
         mov       al,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         xor       ah,ah
         mov       [bp-3],al
         mov       al,byte ptr ds:[d_F79A]
         xor       ah,ah
         mov       [bp-4],al
         mov       ax,0
         mov       byte ptr ds:[d_F788],al  ; zvolen˜ aktu ln¡ typ p¡sma
         mov       al,[bp+4]
         xor       ah,ah
         mov       byte ptr ds:[d_F79A],al
         mov       al,[bp+6]                ; ‡¡slo zna‡ky 0 a‘ 7
         xor       ah,ah
         push      ax
         call      l_C71A                   ; vlo‘en¡ platn‚ho znaku do © dku
         mov       al,[bp-3]
         xor       ah,ah
         mov       byte ptr ds:[d_F788],al  ; zvolen˜ aktu ln¡ typ p¡sma
         mov       al,[bp-4]
         xor       ah,ah
         mov       byte ptr ds:[d_F79A],al
         ;jmp       l_DD4B
         db        0e9h,0,0

l_DD4B:  mov       sp,bp
         pop       bp
         ret       4

l_DD08   ENDP

; -----------------------------------------------------------------------------
;        vlo‘en¡ znaku do textu (©¡dic¡ k¢d)
; -----------------------------------------------------------------------------

l_DD51   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DD58
         db        0e9h,0,0

l_DD58:  mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         jnz       l_DD65
         ;jmp       l_DD72
         db        0e9h
         dw        l_DD72-$-2

l_DD65:  mov       al,[bp+4]
         xor       ah,ah
         push      ax
         mov       ax,0
         push      ax
         call      l_DD08
l_DD72:  ;jmp       l_DD75
         db        0e9h,0,0

l_DD75:  mov       sp,bp
         pop       bp
         ret       2

l_DD51   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OZ a Form t/dvousloupcovˆ (dvousloupc.form tov n¡)
; -----------------------------------------------------------------------------

l_DD7B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DD82
         db        0e9h,0,0

l_DD82:  sub       sp,4
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_DD92
         ;jmp       l_DD95
         db        0e9h
         dw        l_DD95-$-2

l_DD92:  jmp       l_DEF4

l_DD95:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_325A]  ; ¨¡©ka © dku textu (znak–)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jle       l_DDA8
         ;jmp       l_DDB1
         db        0e9h
         dw        l_DDB1-$-2

l_DDA8:  mov       ax,14h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_DEF4

l_DDB1:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,12h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         mov       ax,12h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_DDD5
         ;jmp       l_DDD8
         db        0e9h
         dw        l_DDD8-$-2

l_DDD5:  jmp       l_DEF4

l_DDD8:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,word ptr ds:[d_F7A9]  ; po‡et © dk– na str nku bez okraj–
         push      ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         dec       ax
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         pop       cx
         imul      cx
         inc       ax
         mov       [bp-6],ax
l_DDF5:  mov       ax,[bp-6]
         add       ax,word ptr ds:[d_F7A9]  ; po‡et © dk– na str nku bez okraj–
         mov       [bp-4],ax
         mov       ax,[bp-4]
         add       ax,word ptr ds:[d_F7A9]  ; po‡et © dk– na str nku bez okraj–
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jg        l_DE0F
         ;jmp       l_DE26
         db        0e9h
         dw        l_DE26-$-2

l_DE0F:  mov       ax,[bp-6]
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         sub       ax,[bp-6]
         mov       cx,2
         cwd       
         idiv      cx
         inc       ax
         pop       cx
         add       ax,cx
         mov       [bp-4],ax
l_DE26:  mov       ax,[bp-6]
         cmp       ax,[bp-4]
         jl        l_DE31
         jmp       l_DEB7

l_DE31:  mov       ax,0
         mov       ds:[d_F059],al
         mov       ax,[bp-4]
         cmp       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         jle       l_DE43
         ;jmp       l_DE62
         db        0e9h
         dw        l_DE62-$-2

l_DE43:  mov       ax,[bp-4]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F159
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       ax,[bp-4]
         push      ax
         mov       ax,1
         push      ax
         call      l_3C04
         call      l_399E                   ; test, zda m  soubor nˆjak˜ © dek
l_DE62:  mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0
         jne       l_DE6F
         ;jmp       l_DEAD
         db        0e9h
         dw        l_DEAD-$-2

l_DE6F:  mov       ax,[bp-6]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         call      l_376B                   ; nastaven¡ nov‚ d‚lky editov. © dku
         mov       ax,1
         push      ax
         call      l_3950                   ; spojen¡ textov˜ch © dk–
         mov       ax,[bp-6]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3E83                   ; ulo‘en¡ edit. © dku do souboru
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_DEAA
         ;jmp       l_DEAD
         db        0e9h
         dw        l_DEAD-$-2

l_DEAA:  ;jmp       l_DEF4
         db        0e9h
         dw        l_DEF4-$-2

l_DEAD:  mov       ax,[bp-6]
         inc       ax
         mov       [bp-6],ax
         jmp       l_DE26

l_DEB7:  mov       ax,[bp-6]
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         mov       cx,1
         shr       ax,cl
         mov       word ptr ds:[d_E69C],ax  ; ‡¡slo © dku kurzoru na obrazovce
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         mov       ax,[bp-6]
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,1
         jge       l_DEDB
         dec       ax
l_DEDB:  push      ax
         dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl vesnice
         cmp       ax,1Bh
         mov       ax,1
         jz        l_DEEA
         dec       ax
l_DEEA:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_DEF4
         jmp       l_DDF5

l_DEF4:  ;jmp       l_DEF7
         db        0e9h,0,0

l_DEF7:  mov       sp,bp
         pop       bp
         ret

l_DD7B   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-O (menu form tov n¡/volby)
; -----------------------------------------------------------------------------

l_DEFB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_DF02
         db        0e9h,0,0

l_DF02:  jmp       l_DFA2

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OA (ozna‡en¡ za‡ tku odstavce)
; -----------------------------------------------------------------------------

l_DF05   PROC      NEAR

         mov       ax,16                    ; k¢d pro ozna‡en¡ za‡ tku odstavce
         jmp       short l_DF0D             ; vlo‘en¡ znaku do textu

l_DF05   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OU (z kaz form tov n¡ odstavce)
; -----------------------------------------------------------------------------

l_DF0A   PROC      NEAR

         mov       ax,31                    ; zna‡ka pro z kaz form tov n¡
l_DF0D:  push      ax
         call      l_DD51                   ; vlo‘en¡ znaku do textu
         ret

l_DF0A   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OE (zobrazen¡ z hlav¡/paty)
; -----------------------------------------------------------------------------

l_DF12   PROC      NEAR

         mov       ax,1
         jmp       short l_DF19

l_DF12   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OO (ozna‡en˜ blok jako pata/z hlav¡)
; -----------------------------------------------------------------------------

l_DF17   PROC      NEAR

         xor       ax,ax
l_DF19:  push      ax
         call      l_DC26
         ret

l_DF17   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OH (dˆlen¡ slov zap/vyp)
; -----------------------------------------------------------------------------

l_DF1E   PROC      NEAR

         xor       byte ptr cs:[l_325F],1   ; rozdˆlov n¡ (1=zap., 0=vyp.)
         ret

l_DF1E   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OJ (zarovn v n¡ zap/vyp)
; -----------------------------------------------------------------------------

l_DF25   PROC      NEAR

         xor       byte ptr cs:[l_325E],1   ; zarovn v n¡ (1=zap., 0=vyp.)
         ret

l_DF25   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OL (nastaven¡ lev‚ho okraje podle kurzoru)
; -----------------------------------------------------------------------------

l_DF2C   PROC      NEAR

         push      word ptr ds:[d_E69A]     ; pozice kurzoru na © dku
         call      l_D692                   ; nastaven¡ lev‚ho okraje
         ret

l_DF2C   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OM (Enter jako konec odstavce zap/vyp)
; -----------------------------------------------------------------------------

l_DF34   PROC      NEAR

         xor       byte ptr cs:[l_3262],1   ; konec odstavce (1=zap., 0=vyp.)
         ret

l_DF34   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OQ (dˆlen¡ s dotazem zap/vyp)
; -----------------------------------------------------------------------------

l_DF3B   PROC      NEAR

         xor       byte ptr cs:[l_3260],1   ; rozdˆl. s dotaz.(1=zap., 0=vyp.)
         ret

l_DF3B   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OP (zobrazen¡ str nkov n¡ zap/vyp)
; -----------------------------------------------------------------------------

l_DF42   PROC      NEAR

         xor       byte ptr cs:[l_3263],1   ; zobraz. str nk. (1=zap., 0=vyp.)
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         jmp       short l_DF53

l_DF42   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OT (zobrazen¡ line lu zap/vyp)
; -----------------------------------------------------------------------------

l_DF4D   PROC      NEAR

         xor       byte ptr cs:[l_3264],1   ; zobr. line lu © d.(1=zap., 0=vyp.)
l_DF53:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ret

l_DF4D   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OR (nastaven¡ prav‚ho okraje podle kurzoru)
; -----------------------------------------------------------------------------

l_DF57   PROC      NEAR

         push      word ptr ds:[d_E69A]     ; pozice kurzoru na © dku
         call      l_D6C9                   ; nastaven¡ prav‚ho okraje
         ret

l_DF57   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-OV (automatick˜ tabel tor zap/vyp)
; -----------------------------------------------------------------------------

l_DF5F   PROC      NEAR

         xor       byte ptr cs:[l_3261],1   ; auto-tabel tor (1=zap., 0=vyp.)
         ret

l_DF5F   ENDP

l_DF66   dw        l_DF05                   ; Ctrl-OA ozna‡en¡ za‡ tku odstavce
l_DF68   dw        l_D297                   ; Ctrl-OB form tov n¡ po konec textu
l_DF6A   dw        l_D764                   ; Ctrl-OC centrov n¡ © dku
l_DF6C   dw        l_DF12                   ; Ctrl-OE zobrazen¡ z hlav¡/paty
l_DF6E   dw        l_D737                   ; Ctrl-OF prav˜ okraj podle konce ©.
l_DF70   dw        l_DF1E                   ; Ctrl-OH dˆlen¡ slov zap/vyp
l_DF72   dw        l_D482                   ; Ctrl-OI menu line lu © dku
l_DF74   dw        l_DF25                   ; Ctrl-OJ zarovn v n¡ zap/vyp
l_DF76   dw        l_DF2C                   ; Ctrl-OL lev˜ okraj podle kurzoru
l_DF78   dw        l_DF34                   ; Ctrl-OM konec odstavce zap/vyp
l_DF7A   dw        l_DCA9                   ; Ctrl-ON nedokumentn¡ m¢d zap/vyp
l_DF7C   dw        l_DF17                   ; Ctrl-OO blok jako pata/z hlav¡
l_DF7E   dw        l_DF42                   ; Ctrl-OP zobrazen¡ str nek zap/vyp
l_DF80   dw        l_DF3B                   ; Ctrl-OQ dˆlen¡ s dotazem zap/vyp
l_DF82   dw        l_DF57                   ; Ctrl-OR prav˜ okraj podle kurzoru
l_DF84   dw        l_D7F0                   ; Ctrl-OS po‡et © dk– na str nku
l_DF86   dw        l_DF4D                   ; Ctrl-OT zobrazen¡ line lu zap/vyp
l_DF88   dw        l_DF0A                   ; Ctrl-OU z kaz form tov n¡ odstavce
l_DF8A   dw        l_DF5F                   ; Ctrl-OV automat. tabel tor zap/vyp
l_DF8C   dw        l_DD7B                   ; Ctrl-OZ dvousloupcov‚ form tov n¡

l_DF8E   db        'ABCEFHIJLMNOPQRSTUVZ'

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_DEFB)
; -----------------------------------------------------------------------------

l_DFA2:  mov       ax,3
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         cmp       byte ptr ds:[d_F78C],0
         je        l_DFD1
         xor       bx,bx
l_DFB2:  mov       ax,2Dh
         cmp       ah,byte ptr cs:[l_325E+bx] ; zarovn v n¡ (1=zap., 0=vyp.)
         je        l_DFBE
         mov       al,0FBh
l_DFBE:  push      bx
         push      ax                       ; znak
         mov       al,2Eh
         push      ax                       ; pozice
         add       bx,3
         push      bx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       bx
         inc       bx
         cmp       bl,7
         jbe       l_DFB2
l_DFD1:  push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         push      ax
         mov       ax,3
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       ax
         cmp       al,30h
         jb        l_DFF4
         cmp       al,37h
         ja        l_DFF4
         push      ax                       ; ‡¡slo zna‡ky
         mov       al,20h
         push      ax
         call      l_DD08                   ; vlo‘en¡ zna‡ky u‘iv. tisk. volby
         jmp       short l_E00C

l_DFF4:  mov       bx,offset l_DF66
         mov       cx,14h
         mov       si,offset l_DF8E
l_DFFD:  cmp       al,cs:[si]
         je        l_E009
         inc       si
         inc       bx
         inc       bx
         loop      l_DFFD
         jmp       short l_E00C

l_E009:  call      word ptr cs:[bx]
l_E00C:  ;jmp       l_E00F
         db        0e9h,0,0

l_E00F:  mov       sp,bp
         pop       bp
         ret

l_DEFB   ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                            Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT BYTE PUBLIC

Data     ENDS
         END

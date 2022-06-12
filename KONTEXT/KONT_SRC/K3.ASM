
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; -----------------------------------------------------------------------------
;        n†vrat parametrñ prostoru z bufferu
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] á°slo prostoru
; -----------------------------------------------------------------------------

l_4053   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_405A
         db        0e9h,0,0

; ------ n†vrat line†lu ©†dkñ (odstranàn° okrajñ)

l_405A:  call      l_3F89                   ; n†vrat line†lu ©†dkñ pod okraji

; ------ n†vrat uschovanòch parametrñ prostoru

         mov       di,offset l_3259         ; parametry aktivn°ho prostoru
         push      cs
         push      di
         mov       ax,[bp+4]
         mov       cx,13
         mul       cx
         xchg      ax,di
         add       di,offset d_EC18 - 13    ; uschovanÇ parametry edit. prostorñ
         push      ds
         mov       cx,13
         call      l_0F03                   ; p©enesen° bloku dat (CX bajtñ)

; ------ n†vrat uschovanòch ukazatelñ prostoru

         mov       di,offset d_E690         ; pole ukazatelñ aktiv. prostoru
         push      ds
         push      di
         mov       ax,[bp+4]                ; aktivn° prostor
         mov       cx,PARSIZU               ; velikost jednÇ poloëky
         mul       cx
         xchg      ax,di
         add       di,offset d_E77C - PARSIZU ; uschovanÇ ukazatele edit. prost.
         push      ds
         mov       cx,PARSIZU               ; poáet bajtñ k p©enosu
         call      l_0F03                   ; p©enesen° bloku dat (CX bajtñ)

; ------ oznaáen° novòch okrajñ line†lu ©†dku

         call      l_3FB7                   ; oznaáen° okrajñ v line†lu ©†dkñ

; ------ vòpoáet poátu ©†dkñ na str†nku bez okrajñ

         mov       al,byte ptr cs:[l_325D]  ; poáet ©†dkñ na str†nku
         xor       ah,ah
         push      ax                       ; poáet ©†dkñ na str†nku celkem
         mov       al,byte ptr cs:[l_325B]  ; poáet ©†dkñ z†hlav°
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; odeáten° ©†dkñ na z†hlav°
         push      ax
         mov       al,byte ptr cs:[l_325C]  ; poáet ©†dkñ paty
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; odeáten° ©†dkñ na patu
         mov       word ptr ds:[d_F7A9],ax  ; poáet ©†dkñ na str†nku bez okrajñ

; ------ omezen° á°sla ©†dku kurzoru na obrazovce

         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         push      ax
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_40C2
         ;jmp       l_40C9
         db        0e9h
         dw        l_40C9-$-2

l_40C2:  mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         dec       ax                       ; á°slo posledn°ho ©†dku
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
l_40C9:  ;jmp       l_40CC
         db        0e9h,0,0

l_40CC:  mov       sp,bp
         pop       bp
         ret       2

l_4053   ENDP

; -----------------------------------------------------------------------------
;        nalezen° ©°dic° kl†vesy v makrobufferu ([SP+2] (1) SCAN k¢d kl†vesy)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (1) SCAN k¢d hledanÇ kl†vesy
;        [SP+4] (2)
; VùSTUP:AX=offset zaá†tku makra v definián° tabulce maker
; -----------------------------------------------------------------------------

l_40D2   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP
         ;jmp       l_40D9
         db        0e9h,0,0

l_40D9:  xor       bx,bx                    ; BX <- 0000
         mov       ah,bh                    ; AH <- 00
l_40DD:  mov       al,cs:[l_2CD9+bx]        ; SCAN k¢d kl†vesy z makrobufferu
         or        al,al                    ; je jië konec bufferu ?
         jz        l_40F7                   ; je jië konec bufferu
         inc       bx                       ; zaá†tek dat makrokl†vesy
         ;cmp       al,[bp+4]                ; je hledan† kl†vesa ?
         db        3Ah,86h,4,0              ;!
         je        l_40FD                   ; byla nalezena makrokl†vesa
         mov       al,cs:[l_2CD9+bx]        ; dÇlka dat makrokl†vesy
         add       bx,ax                    ; adresa dal®° makrofunkce
         inc       bx                       ; zaá†tek dal®° makrofunkce
         jmp       short l_40DD             ; test dal®° makrokl†vesy

l_40F7:  mov       word ptr ds:[d_F7A1],bx  ; poáet bajtñ v tabulce maker
         xor       bx,bx                    ; nen° nalezena makrokl†vesa
l_40FD:  mov       ax,bx                    ; adresa nalezenÇ makrokl†vesy
         mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret       4

l_40D2   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4105   PROC      NEAR

         ;jmp       l_4108
         db        0e9h,0,0

l_4108:  mov       ax,[bp+6]
         mov       sp,bp
         pop       bp
         ret       4

l_4105   ENDP

; -----------------------------------------------------------------------------
;        seáten° poátu ©†dkñ intervalu editaán°ch prostorñ
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] koncovò prostor
;        [SP+4] poá†teán° prostor
;        [SP+8]
; VùSTUP: AX=souáet poátu ©†dkñ prostorñ
; -----------------------------------------------------------------------------

l_4111   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4118
         db        0e9h,0,0

; ------ p©°prava ukazatelñ

l_4118:  sub       sp,4
         mov       ax,0
         mov       [bp-4],ax                ; inicializace st©adaáe ©†dkñ na 0

         mov       ax,[bp+6]                ; poá†teán° prostor
         push      ax
         mov       ax,[bp+4]                ; koncovò prostor
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_4131
         ;jmp       l_4155
         db        0e9h
         dw        l_4155-$-2

l_4131:  inc       cx                       ; á°taá prostorñ
         mov       [bp-6],ax                ; á°slo poá†teán°ho prostoru

; ------ seáten° poátu ©†dkñ prostorñ

l_4135:  push      cx                       ; á°taá prostorñ
         mov       ax,[bp-4]                ; st©adaá poátu ©†dkñ
         push      ax
         mov       ax,[bp-6]                ; sá°tanò prostor
         mov       cx,PARSIZU               ; velikost pole ukazatelñ prostoru
         mul       cx
         xchg      ax,di
         pop       ax
         add       ax,word ptr ds:[d_E69E+di] ; maxim†ln° poáet ©†dkñ prostoru
         mov       [bp-4],ax
         pop       cx
         dec       cx                       ; sn°ëen° á°taáe prostorñ
         jz        l_4155
         inc       word ptr [bp-6]          ; zvò®en° ukazatele prostoru
         ;jmp       l_4135
         db        0e9h
         dw        offset(l_4135-$)-2

l_4155:  mov       ax,[bp-4]                ; naátenò poáet ©†dkñ
         mov       [bp+8],ax                ; poáet ©†dkñ
         ;jmp       l_415E
         db        0e9h,0,0

l_415E:  mov       ax,[bp+8]
         mov       sp,bp
         pop       bp
         ret       6

l_4111   ENDP

; -----------------------------------------------------------------------------
;        spoáten° poátu ©†dkñ p©ed zadanòm prostorem
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] poëadovanò prostor
;        [SP+4]
; -----------------------------------------------------------------------------

l_4167   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_416E
         db        0e9h,0,0

l_416E:  dec       sp
         dec       sp                       ; 1 promànn† pro vòstup
         mov       ax,1
         push      ax                       ; poá†teán° prostor = 1
         mov       ax,[bp+4]                ; poëadovanò novò prostor
         dec       ax
         push      ax                       ; p©edch†zej°c° prostor p©ed novòm
         call      l_4111                   ; seáten° poátu ©†dkñ edit. prostorñ
         mov       [bp+6],ax                ; poáet ©†dkñ p©ed novòm prostorem
         ;jmp       l_4182
         db        0e9h,0,0

l_4182:  mov       ax,[bp+6]
         mov       sp,bp
         pop       bp
         ret       4

l_4167   ENDP

; -----------------------------------------------------------------------------
;        p©epnut° na novò editaán° prostor
; -----------------------------------------------------------------------------

l_418B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4192
         db        0e9h,0,0

; ------ poáet zbylòch ©†dkñ do maxima ©†dkñ

l_4192:  sub       sp,8
         mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         sub       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       [bp-0Ah],ax              ; poáet zbylòch ©†dkñ

; ------ £schova parametrñ pñvodn°ho aktivn°ho prostoru

         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         push      ax                       ; á°slo aktivn°ho prostoru
         call      l_3FED                   ; £schova parametrñ edit. prostoru

; ------ omezen° maxim†ln°ho poátu ©†dkñ na skuteánò poáet ©†dkñ

         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         mov       cx,PARSIZU               ; velikost pole ukazatelñk prostoru
         mul       cx                       ; offset v tabulce ukazatelñ
         xchg      ax,di
         mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       word ptr ds:[d_E69E+di],ax ; maxim†ln° poáet ©†dkñ prostoru

; ------ test, zda je novò prostor za aktivn°m nebo pod

         mov       ax,[bp+4]                ; novò prostor
         cmp       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         jg        l_41C2                   ; novò prostor je za aktivn°m
         ;jmp       l_41ED
         db        0e9h
         dw        l_41ED-$-2


l_41C2:  mov       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         push      ax                       ; poá†teán° ©†dek prostoru
         mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         inc       ax                       ; poáet ©†dkñ + 1
         pop       cx
         add       ax,cx                    ; á°slo dal®°ho ©†dku za prostorem
         mov       [bp-6],ax                ; á°slo dal®°ho ©†dku za prostorem

         mov       ax,[bp-6]                ; á°slo dal®°ho ©†dku za prostorem
         add       ax,[bp-0Ah]              ; p©iáten° zbylòch volnòch ©†dkñ
         mov       [bp-4],ax

; ------ poáet ©†dkñ mezi prostory, je-li novò prostor za aktivn°m

         dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         inc       ax                       ; á°slo dal®°ho prostoru
         push      ax
         mov       ax,[bp+4]                ; á°slo novÇho prostoru
         push      ax
         call      l_4111                   ; seáten° poátu ©†dkñ edit. prostorñ
         mov       [bp-8],ax                ; poáet ©†dkñ mezi prostory
         ;jmp       l_4218
         db        0e9h
         dw        l_4218-$-2

; ------ poáet ©†dkñ mezi prostory, je-li novò prostor p©ed aktivn°m

l_41ED:  dec       sp
         dec       sp
         mov       ax,1
         push      ax                       ;
         mov       ax,[bp+4]
         push      ax                       ; novò prostor
         call      l_4111                   ; seáten° poátu ©†dkñ edit. prostorñ
         inc       ax
         mov       [bp-4],ax

         mov       ax,[bp-4]
         add       ax,[bp-0Ah]
         mov       [bp-6],ax
         dec       sp
         dec       sp
         mov       ax,[bp+4]
         inc       ax
         push      ax
         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         push      ax
         call      l_4111                   ; seáten° poátu ©†dkñ edit. prostorñ
         mov       [bp-8],ax

; ------ p©esun ukazatelñ ©†dkñ tak, aby novò prostor vyuë°val volnÇ ©†dky

l_4218:  mov       ax,[bp-4]                ; starò poá†tek bloku ©†dkñ
         push      ax
         mov       ax,[bp-6]                ; novò poá†tek bloku ©†dkñ
         push      ax
         mov       ax,[bp-8]                ; poáet ©†dkñ k p©esunu
         push      ax
         call      l_3ACA                   ; p©esun bloku ukazatelñ ©†dkñ

; ------ nastaven° novÇho prostoru jako aktivn° a n†vrat parametrñ

         mov       ax,[bp+4]
         mov       word ptr ds:[d_F7A7],ax  ; á°slo aktivn°ho prostoru
         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         push      ax
         call      l_4053                   ; n†vrat parametrñ prostoru

; ------ n†vrat poátu ©†dkñ prostoru

         mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         mov       word ptr ds:[d_F7A3],ax  ; skuteánò poáet ©†dkñ prostoru

; ------ novò maxim†ln° poáet ©†dkñ prostoru

         mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         add       ax,[bp-0Ah]              ; p©iáten° volnòch ©†dkñ
         mov       word ptr ds:[d_E69E],ax  ; maxim†ln° poáet ©†dkñ prostoru

; ------ £schova novòch parametrñ prostoru

         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametrñ edit. prostoru

; ------ stanoven° poá†teán°ho ©†dku prostoru

         dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         push      ax
         call      l_4167                   ; poáet ©†dkñ p©ed zadanòm prostorem
         mov       word ptr ds:[d_F7A5],ax  ; poá†teán° ©†dek prostoru v tabulce
         ;jmp       l_4259
         db        0e9h,0,0

l_4259:  mov       sp,bp
         pop       bp
         ret       2

l_418B   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° oznaáen° bloku pro 1 ©†dek (VSTUP: [SP+2] (2) ©†dek displeje)
; -----------------------------------------------------------------------------

l_425F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4266
         db        0e9h,0,0

l_4266:  jmp       short l_4291

l_425F   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° jednoho znaku oznaáen° bloku/kurzoru
; -----------------------------------------------------------------------------
; VSTUP: [BP+4] (2) ©†dek
;        CX = pozice
; -----------------------------------------------------------------------------

l_4268   PROC      NEAR

         mov       bl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       bh,0                     ; BH <- 0
         sub       bx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         add       cx,bx                    ; pozice k zobrazen° znaku bloku
l_4275:  ;mov       ax,[bp+4]                ; ©†dek k zobrazen°
         db        8Bh,86h,4,0              ;!
         mov       si,ds:[d_FDCB]           ; poáet graf. linek na ©†dek textu
         mul       si                       ; poá†teán° linka k zobrazen° kurz.
         push      cx                       ; pozice k zobrazen° znaáky
         inc       ax                       ; poá†teán° linka k zobrazen°
         push      ax                       ; poá†teán° linka k zobrazen° kurz.
         dec       ax                       ; linka - 1
         push      cx                       ; koncov† pozice k zobrazen° znaáky
         add       ax,si                    ; linka + poáet linek na ©†dek
         dec       ax
         dec       ax
         push      ax                       ; koncov† linka
         mov       ax,2                     ; p©°znak - vykreslen° kurzoru
         push      ax                       ; parametr pro vykreslen° okna
         call      l_34E1                   ; zobrazen° kurzoru, okna
         ret

l_4268   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------
                                          ;* oznaáen° sloupc. bloku pro 1 ©†dek
l_4291   PROC      NEAR

         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         cmp       ah,byte ptr ds:[d_E6A9]  ; 1=p©°znak zapnut° zobrazen° bloku
         je        l_42FB                   ;
         ;mov       di,[bp+0Ah]
         db        8Bh,0BEh,0Ah,0           ;!
         cmp       di,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         jb        l_42FB                   
         cmp       di,word ptr ds:[d_E692]  ; ©†dek konce bloku
         ja        l_42FB                   
         ;mov       cx,[bp+8]
         db        8Bh,8Eh,8,0              ;!
         ;mov       dx,[bp+6]
         db        8Bh,96h,6,0              ;!
         cmp       ah,byte ptr ds:[d_E6AA]  ; 1=p©°znak sloupcovÇho bloku
         jne       l_42D2                   
         mov       bx,ax                    
         add       bx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         sub       bl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         cmp       bx,cx                    
         jl        l_42FB                   
         cmp       bx,dx                    
         jg        l_42FB                   
         mov       cx,ax                    
         call      l_4275                   ; zobrazen° znaáky bloku
         jmp       short l_42FB

l_42D2:  mov       ax,word ptr ds:[d_E694]  ; pozice zaá†tku sloupcovÇho bloku
         mov       bx,word ptr ds:[d_E696]  ; pozice konec sloupcovÇho bloku
         cmp       ax,dx                    
         jg        l_42FB                   
         cmp       bx,cx                    
         jl        l_42FB                   
         cmp       ax,cx                    
         jl        l_42F2                   
         cmp       ax,bx                    
         je        l_42F2                   
         mov       cx,ax                    ; pozice k zobrazen° znaáky bloku
         push      bx                       
         push      dx                       ; ©†dek k zobrazen° znaáky bloku
         call      l_4268                   ; zobrazen° znaku bloku/kurzoru
         pop       dx                       
         pop       bx                       
l_42F2:  cmp       bx,dx                    
         jg        l_42FB                   
         mov       cx,bx                    ; pozice k zobrazen° znaáky bloku
         call      l_4268                   ; zobrazen° znaku bloku/kurzoru
l_42FB:  ;jmp       l_42FE
         db        0e9h,0,0

l_42FE:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret       8                        ; n†vrat se zru®en°m parametrñ

l_4291   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4304   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_430B
         db        0e9h,0,0

l_430B:  mov       ax,[bp+4]
         cmp       ax,word ptr ds:[d_E690]  ; ©†dek zaá†tku bloku
         mov       ax,1
         jge       l_4318
         dec       ax
l_4318:  push      ax
         mov       ax,[bp+4]
         cmp       ax,word ptr ds:[d_E692]  ; ©†dek konce bloku
         mov       ax,1
         jle       l_4326
         dec       ax
l_4326:  pop       cx
         and       ax,cx
         mov       [bp+6],al
         ;jmp       l_432F
         db        0e9h,0,0

l_432F:  mov       al,[bp+6]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       3

l_4304   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ®ipky p©eteáen° vpravo
; -----------------------------------------------------------------------------
; VSTUP: [SP+4] (2) á°slo ©†dku
; -----------------------------------------------------------------------------

l_433C   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_4343
         db        0e9h,0,0

l_4343:  mov       ax,0                     ; zobraz° se jako bàënò znak
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku
         mov       ax,1Ah                   ; znak ®ipky vpravo
         push      ax                       ; znak k vòstupu
         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         push      ax                       ; pozice na pravÇm okraji
         mov       ax,[bp+4]                ; ©†dek kurzoru na displeji
         push      ax                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         ;jmp       l_435B
         db        0e9h,0,0

l_435B:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret       2                        ; n†vrat se zru®en°m parametrñ

l_433C   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° pravÇho okraje v 1 ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] ©†dek
; -----------------------------------------------------------------------------

l_4361   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_4368
         db        0e9h,0,0

l_4368:  mov       al,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu na str†nce
         xor       ah,ah                    ; AH <- 0
         push      ax                       ; ®°©ka ©†dku textu na str†nce
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° poz. ©†dku (levò okraj)
         xor       ah,ah                    ; AH <- 0
         pop       cx                       ; ®°©ka ©†dku textu na str†nce
         add       ax,cx                    ; +pozice pravÇho okraje
         sub       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         push      ax                       ; pozice pro vykreslen° okraje
         mov       ax,[bp+4]                ; prvn° ©†dek pro kreslen° okraje
         push      ax                       ; prvn° ©†dek pro kreslen° okraje
         mov       ax,[bp+4]                ; posledn° ©†dek pro kreslen° okraje
         push      ax                       ; posledn° ©†dek pro kreslen° okraje
         mov       ax,80h                   ; maska pro vykreslen° á†ry
         push      ax                       ; maska pro vykreslen° á†ry
         call      l_35B7                   ; vykreslen° pravÇho okraje (á†ry)
         ;jmp       l_438F
         db        0e9h,0,0

l_438F:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret       2                        ; n†vrat se zru®en°m parametrñ

l_4361   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° levÇho okraje v 1 ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] ©†dek
; -----------------------------------------------------------------------------

l_4395   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_439C
         db        0e9h,0,0

l_439C:  mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice ©†dku (okraj)
         xor       ah,ah                    ; AH <- 0
         sub       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         push      ax                       ; pozice pro vykreslen° okraje
         mov       ax,[bp+4]                ; prvn° ©†dek pro kreslen° okraje
         push      ax                       ; prvn° ©†dek pro kreslen° okraje
         mov       ax,[bp+4]                ; posledn° ©†dek pro kreslen° okraje
         push      ax                       ; posledn° ©†dek pro kreslen° okraje
         mov       ax,1                     ; maska pro vykreslen° á†ry
         push      ax                       ; maska pro vykreslen° á†ry
         call      l_35B7                   ; vykreslen° levÇho okraje (á†ry)
         ;jmp       l_43B9
         db        0e9h,0,0

l_43B9:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret       2                        ; n†vrat se zru®en°m parametrñ

l_4395   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° ©etàzce znakñ
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (1) dÇlka textu k zobrazen° (poáet znakñ)
;        [SP+3] (255) buffer textu k zobrazen°
;        [SP+102h] (2) ©†dek k zobrazen° textu
;        [SP+104h] (2) poá†teán° pozice k zobrazen° textu
; -----------------------------------------------------------------------------

l_43BF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_43C6
         db        0e9h,0,0

l_43C6:  ;mov       cl,[bp+4]               ; poáet bajtñ k zobrazen°
         db        8Ah,8Eh,4,0              ;!
         mov       ch,0
         jcxz      l_43EA                   ; nen° ë†dnò znak k zobrazen°
         xor       di,di                    ; ukazatel znakñ v bufferu
         mov       bx,[bp+106h]             ; pozice k zobrazen° textu
l_43D4:  inc       di
         push      bx
         push      cx
         push      di
         ;push      word ptr [bp+di+4]      ; znak k zobrazen°
         db        0FFh,0B3h,4,0            ;!
         push      bx                       ; pozice na ©†dku
         push      word ptr [bp+104h]       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       di
         pop       cx
         pop       bx
         inc       bx                       ; zvò®en° pozice na ©†dku
         loop      l_43D4                   ; zobrazen° dal®°ho znaku
l_43EA:  ;jmp       l_43ED
         db        0e9h,0,0

l_43ED:  mov       sp,bp
         pop       bp
         ret       104h

l_43BF   ENDP

; -----------------------------------------------------------------------------
;        vymaz†n° horn°ho stavovÇho ©†dku
; -----------------------------------------------------------------------------

l_43F3   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_43FA
         db        0e9h,0,0

l_43FA:  mov       ax,1                     ; poá†teán° pozice
         push      ax                       ; poá†teán° pozice
         mov       ax,0                     ; poá†teán° ©†dek
         push      ax                       ; poá†teán° ©†dek
         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         push      ax                       ; koncov† pozice
         mov       ax,0                     ; koncovò ©†dek
         push      ax                       ; koncovò ©†dek
         mov       ax,1                     ; invertovanÇ okno
         push      ax                       ; parametr pro vykreslen° okna
         call      l_34F8                   ; vykreslen° okna
         mov       ax,20h                   ; p©°znak - inverzn° znak
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku
         ;jmp       l_441A
         db        0e9h,0,0

l_441A:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret                                ; n†vrat se zru®en°m parametrñ

l_43F3   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° line†lu ©†dku
; -----------------------------------------------------------------------------

l_441E   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_4425
         db        0e9h,0,0

; ------ p©°prava registrñ k zobrazen° line†lu ©†dku

l_4425:  mov       byte ptr ds:[d_FE56],20h ; m¢d zobrazen° znaku - inverzn°
         mov       si,offset l_3278         ; line†l ©†dku
         add       si,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         xor       ax,ax                    ; ukazatel pozice na ©†dku

; ------ zobrazen° line†lu ©†dku

l_4433:  inc       si                       ; zvò®en° ukazatele textu line†lu
         inc       ax                       ; zvò®en° pozice na displeji
         push      ax                       ; pozice
         push      si                       ; ukazatel textu
         push      word ptr cs:[si]         ; znak k zobrazen°
         push      ax                       ; pozice
         xor       ax,ax                    ; ©†dek
         push      ax                       
         call      l_34C7                   ; vòstup znaku na displej
         pop       si                       ; ukazatel textu
         pop       ax                       ; pozice
         cmp       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         jb        l_4433                   ; nen° je®tà konec ©†dku-dal®° znak
         ;jmp       l_444C
         db        0e9h,0,0

l_444C:  mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
         ret                                ; n†vrat se zru®en°m parametrñ

l_441E   ENDP

; -----------------------------------------------------------------------------
;        zru®en° cesty ze specifikace souboru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (81h) specifikace souboru
;        [SP+83h] (15) buffer k uloëen° jmÇna souboru
; -----------------------------------------------------------------------------

l_4450   PROC      NEAR

         push      bp                       ; £schova BP
         mov       bp,sp                    ; BP <- SP ukazatel dat
         push      bp                       ; £schova BP (stav SP)
         ;jmp       l_4457
         db        0e9h,0,0

; ------ stanoven° dÇlky ©etàzce

l_4457:  dec       sp
         dec       sp                       
         lea       di,[bp+4]                ; buffer se jmÇnem souboru
         push      ss                       
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F                   ; funkce LEN - dÇlka ©etàzce
         mov       [bp-4],ax                ; dÇlka ©etàzce

; ------ ©etàzec mus° m°t minim†ln° dÇlku 4 znaky

         mov       ax,[bp-4]                ; dÇlka ©etàzce
         cmp       ax,3                     ; minim†ln° dÇlka 4 znaky
         jg        l_4471                   ; dÇlka je minim†lnà 4 znaky
         ;jmp       l_44C7                  ; mal† dÇlka
         db        0e9h
         dw        l_44C7-$-2

; ------ test, zda je posledn° znak "\"

l_4471:  mov       ax,[bp-4]                ; dÇlka ©etàzce
         xchg      ax,di                    ; DI <- dÇlka ©etàzce
         mov       al,[bp+di+4]             ; posledn° znak ©etàzce
         xor       ah,ah                    ; AH <- 0
         cmp       ax,"\"                   ; je posledn° znak "\"
         mov       ax,1                     ; p©°znak - nen° znak "\"
         jnz       l_4483                   ; nen° ukonáen znakem "\"
         dec       ax                       ; p©°znak - je znak "\"

; ------ test, zda je posledn° znak "/"

l_4483:  push      ax
         mov       ax,[bp-4]                ; dÇlka ©etàzce
         xchg      ax,di                    ; DI <- dÇlka ©etàzce
         mov       al,[bp+di+4]             ; posledn° znak ©etàzce
         xor       ah,ah                    ; AH <- 0
         cmp       ax,"/"                   ; je posledn° znak "/"
         mov       ax,1                     ; p©°znak - nen° znak "/"
         jnz       l_4496                   ; nen° ukonáen znakem "/"
         dec       ax                       ; p©°znak - je znak "/"
l_4496:  pop       cx

; ------ nalezen° koncovÇho znaku "\" nebo "/" (vypu®tàn° jmÇna souboru)

         and       ax,cx                    ; test, zda je znak "\" nebo "/"
         or        ax,ax
         jnz       l_44A0                   ; nen° znak "\" ani "/"
         ;jmp       l_44AA                  ; je koncovò znak "\" nebo "/"
         db        0e9h
         dw        l_44AA-$-2
l_44A0:  mov       ax,[bp-4]                ; dÇlka textu
         dec       ax                       ; vypu®tàn° posledn°ho znaku
         mov       [bp-4],ax                
         ;jmp       l_4471                  ; test dal®°ho znaku
         db        0e9h
         dw        offset(l_4471-$)-2

; ------ kontrola, zda je jië ROOT

l_44AA:  mov       ax,[bp-4]                ; dÇlka textu
         cmp       ax,2                     ; zbòvaj° je®tà minim†lnà 2 znaky ?
         jg        l_44B5                   ; je dostateán† dÇlka cesty
         ;jmp       l_44C7                  ; je jië ROOT
         db        0e9h
         dw        l_44C7-$-2

; ------ vyjmut° cesty z oznaáen° souboru

l_44B5:  lea       di,[bp+4]                ; buffer se jmÇnem souboru
         push      ss                       ; segment textu
         push      di                       ; offset textu
         mov       ax,3                     
         push      ax                       ; poáet znakñ na oznaáen° disku
         mov       ax,[bp-4]                ; dÇlka textu cesty s diskem
         sub       ax,2                     ; odeáten° textu oznaáen° disku
l_44C4:  call      l_1408                   ; vyjmut° cesty z oznaáen° souboru

; ------ p©enesen° jmÇna souboru do bufferu

l_44C7:  lea       di,[bp+85h]              ; adresa bufferu
         push      ss                       
         push      di                       
         lea       di,[bp+4]                
         push      ss                       
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,14                    ; dÇlka bufferu
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.
         ;jmp       l_44DC
         db        0e9h,0,0

l_44DC:  mov       dx,81h                   ; poáet bajtñ ke zru®en°
         mov       cl,14                    ; dÇlka bufferu
         mov       sp,bp                    ; n†vrat SP
         pop       bp                       ; n†vrat BP
l_44E4:  jmp       l_1475                   ; redukce dÇlky bufferu na minimum

l_4450   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° horn°ho stavovÇho ©†dku
; -----------------------------------------------------------------------------

l_44E7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_44FA
         db        0e9h
         dw        l_44FA-$-2

l_44ee   db        'VYP>'
l_44f2   db        'ZAP>'
l_44f6   db        'DEK>'

; ------ test, zda je aktivn° hlavn° menu

l_44FA:  mov       al,byte ptr ds:[d_F786]  ; 1=p©°znak zobrazen° horn°ho menu
         xor       ah,ah
         or        ax,ax                    ; je hlavn° menu aktivn° ?
         jnz       l_4506                   ; hlavn° menu je aktivn°
         ;jmp       l_4573
         db        0e9h
         dw        l_4573-$-2

; ------ zobrazen° horn°ho ©†dku menu (hlavn° menu)

l_4506:  mov       ax,20h                   ; atributy - inverzn°
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - inverzn°
         mov       ax,1
         push      ax                       ; poá†teán° pozice
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen° textu
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        80,'Kurzor  Maz†n°   Blok    P°smo  Form†t. Str†nka Displej  Extra   Tisk   Soubor  '

         mov       cl,0ffh                  ; nov† dÇlka bufferu 255 bajtñ
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         jmp       l_4686

; ------ zobrazen° line†lu ©†dku

l_4573:  mov       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax                    ; je line†l ©†dku zapnutò ?
         jnz       l_4580                   ; line†l ©†dku je zapnutò
         ;jmp       l_4586
         db        0e9h
         dw        l_4586-$-2

l_4580:  call      l_441E                   ; zobrazen° line†lu ©†dku
         jmp       l_4686

; ------ vymaz†n° horn°ho stavovÇho ©†dku

l_4586:  call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku

; ------ uloëen° ©etàzce prefixu dvojn†sobnÇ ®°©ky znaku

         mov       ax,1
l_458C:  push      ax
l_458D:  mov       ax,0
         push      ax
         mov       ax,0FFh                  ; prefix dvojn†sobnÇ ®°©ky znaku
         push      ax

; ------ p©id†n° á°sla aktivn°ho editaán°ho prostoru

         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         add       ax,"0"                   ; korekce na znak ASCII
         mov       ah,al                    ; AH <- á°slo prostoru
         mov       al,1                     ; dÇlka textu á°sla prostoru
         push      ax
         call      l_1460
         call      l_12DE                   ; seáten° textovòch ©etàzcñ

; ------ zobrazen° á°sla aktivn°ho editaán°ho prostoru

         mov       cl,255                   ; nov† dÇlka bufferu
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ

; ------ rozli®en°, zda je zobrazeno str†nkov†n°

         mov       al,byte ptr cs:[l_3263]  ; zobraz. str†nk. (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax                    ; je zobrazeno str†nkov†n° ?
         jnz       l_45BB                   ; je zobrazeno str†nkov†n°
         ;jmp       l_45EE
         db        0e9h
         dw        l_45EE-$-2

; ------ zobrazen° horn°ho ©†dku p©i zobrazenÇm str†nkov†n°

l_45BB:  mov       ax,5
         push      ax                       ; poá†teán° pozice k zobrazen° textu
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen° textu
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        28,' Str.      û†dek      Pozice'

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43bf                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_4615
         db        0e9h
         dw        l_4615-$-2

; ------ zobrazen° horn°ho ©†dku bez zobrazenÇho str†nkov†n°

l_45EE:  mov       ax,10
         push      ax                       ; pozice k zobrazen° textu
         mov       ax,0
         push      ax                       ; ©†dek k zobrazen° textu
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        19,'û†dek        Pozice'

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43bf                   ; zobrazen° ©etàzce znakñ

; ------ zobrazen° jmÇna editovanÇho souboru

l_4615:  mov       ax,27h
         push      ax
         mov       ax,0
         push      ax
         sub       sp,0fh
         mov       di,offset d_E6FB         ; jmÇno editovanÇho souboru
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,80h
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_4450                   ; zru®en° cesty ze specifik. souboru
         mov       cl,255
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ

; ------ zobrazen° stavu p©ep°naáe INSERT

         mov       ax,38h
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        5,'Ins <'

         mov       al,byte ptr cs:[l_3267]  ; p©°znak INSERT (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       al,byte ptr ds:[d_F78F]  ; 1=p©°znak dekadickÇho tabel†toru
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         mov       al,byte ptr ds:[d_F78F]  ; 1=p©°znak dekadickÇho tabel†toru
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3267]  ; p©°znak INSERT (1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         pop       cx
         and       ax,cx
         pop       cx
         add       ax,cx
         shl       ax,1
         shl       ax,1
         xchg      ax,di                    ; offset textu stavu INSERT
         add       di,offset l_44EE         ; tabulka textñ stavu INSERT
         push      cs
         mov       cl,4
         call      l_1204
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ

l_4686:  ;jmp       l_4689
         db        0e9h,0,0

l_4689:  mov       sp,bp
         pop       bp
         ret       

l_44E7   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° parametrñ ve stavovÇm ©†dku
; -----------------------------------------------------------------------------

l_468D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4694
         db        0e9h,0,0

l_4694:  jmp       short l_46DB

; ------ bufferu k dek¢dov†n° á°sla (8 bajtñ)

l_4696   db        0,'113',0,0,0,0

; -----------------------------------------------------------------------------
;        zobrazen° znaku AL ve stavovÇm ©†dku (pozice BX)
; -----------------------------------------------------------------------------

l_469E   PROC      NEAR

         push      bx
         push      cx
         push      di
         push      ax                       ; znak k zobrazen°
         push      bx                       ; pozice
         xor       bx,bx
         push      bx                       ; ©†dek = 0
         call      l_34C7                   ; vòstup znaku na displej
         pop       di
         pop       cx
         pop       bx
         inc       bx                       ; zvò®en° ukazatele pozice na ©†dku
         ret       

l_469E   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° á°sla AX ve stavovÇm ©†dku (pozice BX, CX znakñ)
; -----------------------------------------------------------------------------

l_46AE   PROC      NEAR

; ------ dek¢dov†n° á°sla AX do bufferu

         xor       di,di
l_46B0:  cwd                                ; DX:AX <- AX
         mov       si,10                    ; dàlitel
         div       si                       ; vòpoáet jednÇ á°slice
         add       dl,"0"                   ; konverze na znak ASCII
         inc       di                       ; zvò®en° ukazatele v bufferu
         mov       cs:[l_4696+di],dl        ; uloëen° znaku do bufferu
         or        ax,ax                    ; je jië 0 ?
         jnz       l_46B0                   ; dek¢dov†n° dal®°ho znaku

; ------ zobrazen° dek¢dovanÇho á°sla

l_46C3:  mov       al,cs:[l_4696+di]        ; znak k zobrazen°
         call      l_469E                   ; zobrazen° znaku ve stavovÇm ©†dku
         dec       cx                       ; á°taá znakñ k zobrazen°
         dec       di                       ; á°taá znakñ á°sla
         jnz       l_46C3                   ; zobrazen° dal®°ho znaku

; ------ vymaz†n° zbytku ©†dku

         or        cx,cx                    ; zbyla nàjak† pozice ?
         jle       l_46DA                   ; nezbyla ë†dn† pozice
l_46D3:  mov       al," "                   ; mezera
         call      l_469E                   ; zobrazen° znaku ve stavovÇm ©†dku
         loop      l_46D3
l_46DA:  ret

l_46AE   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_468D)
; -----------------------------------------------------------------------------

; ------ zobrazen° kurzoru v hlavn°m menu

l_46DB:  xor       ax,ax                    ; AX <- 0
         cmp       al,byte ptr ds:[d_F786]  ; 1=p©°znak zobrazen° horn°ho menu
         je        l_46FD                   ; nen° zobrazeno horn° menu
         mov       bl,byte ptr ds:[d_E68E]  ; kurzor v hlavn°m menu 0..9
         mov       bh,0
         mov       cl,3
         shl       bx,cl                    ; * 8 pozic na volbu -> pozice
         inc       bx                       ; korekce pozice
         push      bx                       ; pozice k zobrazen° kurzoru
         push      ax                       ; ©†dek k zobrazen° kurzoru
         add       bl,6                     ; koncov† pozice kurzoru
         push      bx                       ; koncov† pozice kurzoru
         push      ax                       ; koncovò ©†dek kurzoru
         mov       al,2                     ; typ okna - kurzor
         push      ax                       ; typ okna - kurzor
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         jmp       short l_474E

; ------ rozli®en°, zda se zobraz° str†nkov†n°

l_46FD:  cmp       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         jne       l_474E                   ; je zobrazen line†l ©†dku
         mov       byte ptr ds:[d_FE56],20h ; m¢d zobrazen° znaku - inverzn°
         cmp       al,byte ptr cs:[l_3263]  ; zobraz. str†nk. (1=zap., 0=vyp.)
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         je        l_4734                   ; nen° zobrazeno str†nkov†n°

; ------ zobrazen° á°sla str†nky (v m¢du bez str†nek)

         dec       ax                       ; á°slo ©†dku - 1
         cwd       
         div       word ptr ds:[d_F7A9]     ; poáet ©†dkñ na str†nku bez okrajñ
         push      dx                       ; á°slo ©†dku na str†nce
         inc       ax                       ; á°slo str†nky
         mov       bx,11                    ; pozice k zobrazen° á°sla str†nky
         mov       cx,4                     ; dÇlka pole
         call      l_46AE                   ; zobrazen° á°sla str†nky

; ------ zobrazen° á°sla ©†dku (v m¢du bez str†nek)

         pop       ax                       ; á°slo ©†dku na str†nce
         inc       ax                       ; korekce á°sla ©†dku na str†nce
         mov       bx,22                    ; pozice k zobrazen° á°sla ©†dku
         mov       cx,2                     ; dÇlka pole (max. 99 ©†dkñ)
         call      l_46AE                   ; zobrazen° á°sla ©†dku
         mov       bx,34                    ; pozice k zobrazen° á°sla pozice
         jmp       short l_4740

; ------ zobrazen° á°sla ©†dku (ve str†nkovÇm m¢du)

l_4734:  mov       bx,16                    ; pozice k zobrazen° á°sla ©†dku
         mov       cx,5                     ; dÇlka pole
         call      l_46AE                   ; zobrazen° á°sla ©†dku

; ------ zobrazen° á°sla pozice na ©†dku

         mov       bx,30                    ; pozice k zobrazen° á°sla pozice
l_4740:  mov       cx,3
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         add       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         call      l_46AE                   ; zobrazen° á°sla pozice na ©†dku
l_474E:  ;jmp       l_4751
         db        0e9h,0,0

l_4751:  mov       sp,bp
         pop       bp
         ret       

l_468D   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktivn°ho editovanÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (2) ©†dek na displeji
; -----------------------------------------------------------------------------

l_4755   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_475C
         db        0e9h,0,0

l_475C:  ;mov       bx,[bp+0Ah]
         db        8Bh,9Eh,0Ah,0            ;!
         ;mov       dx,[bp+8]
         db        8Bh,96h,8,0              ;!
         cmp       bx,dx
         jle       l_476B
         jmp       l_4829

l_476B:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       si,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         mov       ax,bx
         mov       cl,[di]
         mov       ch,0
         cmp       cx,bx
         jl        l_47CA
         dec       bx
         cmp       byte ptr [bx+di],0FFh
         je        l_4782
         inc       bx
l_4782:  mov       ax,cx
         cmp       cx,dx
         jl        l_4794
         xchg      bx,dx
         cmp       byte ptr [bx+di],0FFh
         jne       l_4790
         inc       bx
l_4790:  xchg      bx,dx
         mov       ax,dx

l_4794:  push      bx
         push      dx
         push      cx
         mov       cx,ax
         sub       cx,bx
         inc       cx
         add       si,bx
         add       di,bx
         add       bl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         sub       bx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku

; ------ zobrazen° obsahu ©†dku

l_47A9:  push      bx
         push      cx
         push      si
         push      di
         mov       al,[si]                  ; atributy znaku
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku
         mov       al,[di]                  ; znak k zobrazen°
         push      ax                       ; znak
         push      bx                       ; pozice
         ;push      word ptr [bp+4]         ; ©†dek na displeji
         db        0FFh,0B6h,4,0            ;!
         call      l_34C7                   ; vòstup znaku na displej
         pop       di
         pop       si
         pop       cx
         pop       bx
         inc       bx
         inc       si
         inc       di
         loop      l_47A9

         pop       ax
         inc       ax
         pop       dx
         pop       bx

; ------ vymaz†n° zbytku ©†dku

l_47CA:  push      bx
         push      dx
         mov       cl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       ch,0
         sub       cx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         add       ax,cx
         push      ax                       ; poá†teán° pozice
         ;push      word ptr [bp+4]         ; poá†teán° ©†dek
         db        0FFh,0B6h,4,0            ;!
         add       dx,cx
         push      dx                       ; koncov† pozice
         ;push      word ptr [bp+4]         ; koncovò ©†dek
         db        0FFh,0B6h,4,0            ;!
         xor       ax,ax
         push      ax                       ; p©°znak - vymaz†n° okna
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         pop       dx
         pop       bx

; ------ p©i p©eteáen° konce zobrazen° ®ipky na konci ©†dku

         mov       al,byte ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         cmp       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         jae       l_4805
         cmp       al,dl
         ja        l_4805
         push      bx
         push      dx
         ;push      word ptr [bp+4]          ; ©†dek k zobrazen° ®ipky p©ekroáen°
         db        0FFh,0B6h,4,0            ;!
         call      l_433C                   ; zobrazen° ®ipky ©†dku "za rohem"
         pop       dx
         pop       bx

; ------ zobrazen° kurzoru na ©†dku

l_4805:  push      bx
         push      dx
         ;push      word ptr [bp+6]
         db        0FFh,0B6h,6,0            ;!
         push      bx
         push      dx
         ;push      word ptr [bp+4]
         db        0FFh,0B6h,4,0            ;!
         call      l_425F                   ; zobraz. oznaáen° bloku pro 1 ©†dek
         pop       dx
         pop       bx

; ------ zobrazen° pravÇho okraje na ©†dku

         mov       al,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu (znakñ)
         cmp       al,bl
         jb        l_4829
         cmp       al,dl
         ja        l_4829
         ;push      word ptr [bp+4]
         db        0FFh,0B6h,4,0            ;!
         call      l_4361                   ; zobrazen° pravÇho okraje v 1 ©†dku
l_4829:  ;jmp       l_482C
         db        0e9h,0,0

l_482C:  mov       sp,bp
         pop       bp
         ret       8

l_4755   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° aktivn°ho edit. ©†dku
; -----------------------------------------------------------------------------

l_4832   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4839
         db        0e9h,0,0

l_4839:  mov       ax,[bp+6]
         push      ax
         mov       ax,[bp+4]
         push      ax
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         push      ax
         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         push      ax
         call      l_4755                   ; zobrazen° aktivn°ho edit. ©†dku
         ;jmp       l_484F
         db        0e9h,0,0

l_484F:  mov       sp,bp
         pop       bp
         ret       4

l_4832   ENDP

; -----------------------------------------------------------------------------
;        korekce editovanÇho ©†dku po editaci (odstranàn° mezer)
; -----------------------------------------------------------------------------

l_4855   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_485C
         db        0e9h,0,0

; ------ p©°prava registrñ k redukci ©†dku

l_485C:  mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         mov       bl,[di]                  ; dÇlka textovÇho ©†dku
         or        bl,bl                    ; je nàjakò znak v ©†dku ?
         jz        l_4890                   ; nen° ë†dnò znak v ©†dku
         mov       bh,0
         mov       dx,bx                    ; poáet znakñ v ©†dku

; ------ odstranàn° p©ebyteánòch mezer z konce ©†dku

         mov       cl,0                     ; p©°znak, ëe nen° konec odstavce
l_486B:  mov       al,[bx+di]               ; znak na konci textu
         cmp       al," "                   ; je mezera ?
         je        l_4877                   ; je mezera
         cmp       al,11h                   ; je konec odstavce ?
         jne       l_487A                   ; je jinò platnò znak
         mov       cl,0FFh                  ; p©°znak, ëe je konec odstavce
l_4877:  dec       bx                       ; sn°ëen° dÇlky ©†dku
         jnz       l_486B                   ; dal®° znak
l_487A:  mov       [di],bl                  ; nov† zkr†cen† dÇlka ©†dku

; ------ doplnàn° znaku konce odstavce

         and       cl,bl                    ; byl znak konce odstavce ?
         jz        l_4890                   ; nen° znak konce odstavce
         inc       bx                       ; oprava dÇlky ©†dku
         mov       [di],bl                  ; nov† dÇlka ©†dku váetnà konce
         mov       byte ptr [bx+di],11h     ; znak konce odstavce za text
         mov       byte ptr ds:[d_ED59+bx],0; atribut znaku = bàënò znak

; ------ novÇ zobrazen° opravenÇho ©†dku (opraven konec odstavce)

         push      bx
         push      dx
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
l_4890:  ;jmp       l_4893
         db        0e9h,0,0

l_4893:  mov       sp,bp
         pop       bp
         ret       

l_4855   ENDP

; -----------------------------------------------------------------------------
;        uloëen° obsahu edit. ©†dku, pokud byl modifikov†n
; -----------------------------------------------------------------------------

l_4897   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_489E
         db        0e9h,0,0

l_489E:  mov       al,byte ptr ds:[d_F789]  ; 1=p©°znak modifikace edit. ©†dku
         xor       ah,ah
         or        ax,ax                    ; byl editovanò ©†dek modifikov†n ?
         jnz       l_48AA                   ; byl modifikov†n (bude uloëen°)
         ;jmp       l_48C4
         db        0e9h
         dw        l_48C4-$-2

l_48AA:  call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         push      ax
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      di
         call      l_3E83                   ; uloëen° ©†dku do textu
         mov       ax,0
         mov       byte ptr ds:[d_F789],al  ; zru®en° p©°znaku modifikace ©†dku
l_48C4:  ;jmp       l_48C7
         db        0e9h,0,0

l_48C7:  mov       sp,bp
         pop       bp
         ret       

l_4897   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° ©†dku do textovÇho bufferu
; -----------------------------------------------------------------------------

l_48CB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_48D2
         db        0e9h,0,0

l_48D2:  mov       al,byte ptr ds:[d_F789]  ; 1=p©°znak modifikace edit. ©†dku
         xor       ah,ah
         xor       al,1
         jnz       l_48DE
         ;jmp       l_48F5
         db        0e9h
         dw        l_48F5-$-2

l_48DE:  mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         push      ax
         mov       di,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu
         mov       ax,1
         mov       byte ptr ds:[d_F789],al  ; 1=p©°znak modifikace edit. ©†dku
l_48F5:  ;jmp       l_48F8
         db        0e9h,0,0

l_48F8:  mov       sp,bp
         pop       bp
         ret       

l_48CB   ENDP

; -----------------------------------------------------------------------------
;        nastaven° maxim†ln° dÇlky ©†dku
; -----------------------------------------------------------------------------

l_48FC   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4903
         db        0e9h,0,0

l_4903:  mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         add       ax,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         mov       word ptr ds:[d_E6A6],ax  ; maxim†ln° dÇlka ©†dku od L okraje
         ;jmp       l_491B
         db        0e9h,0,0

l_491B:  mov       sp,bp
         pop       bp
         ret       

l_48FC   ENDP

; -----------------------------------------------------------------------------
;        normalizace kurzoru na ©†dku
; -----------------------------------------------------------------------------

l_491F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4926
         db        0e9h,0,0

l_4926:  dec       sp
         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         mov       bx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         mov       cl,byte ptr cs:[l_326C]
         mov       ch,0
         ;mov       dx,[bp+4]
         db        8Bh,96h,4,0              ;!
         push      bx
l_493A:  mov       di,dx
         sub       di,bx
         cmp       di,ax
         jl        l_4946
         add       bx,cx
         jmp       short l_493A

l_4946:  cmp       dx,bx
         jg        l_494E
         sub       bx,cx
         jmp       short l_4946

l_494E:  pop       ax
         sub       ax,bx
         jz        l_495C
         mov       word ptr ds:[d_E6A4],bx  ; offset zaá†tku zobrazenÇho ©†dku
         call      l_48FC                   ; nastaven° maxim†ln° dÇlky ©†dku
         mov       al,1
l_495C:  ;mov       [bp-3],al
         db        88h,86h,0FDh,0FFh        ;!
         mov       al,[bp-3]
         xor       ah,ah
         mov       [bp+6],al
         ;jmp       l_496B
         db        0e9h,0,0

l_496B:  mov       al,[bp+6]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       3

l_491F   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° zadanÇho ©†dku
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (2) ©†dek na obrazovce
;        [SP+4] (2) á°slo poëadovanÇho ©†dku
; -----------------------------------------------------------------------------

l_4978   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_497F
         db        0e9h,0,0

; ------ dek¢dov†n° ©†dku k zobrazen° do bufferu v z†sobn°ku

l_497F:  sub       sp,202h
         ;push      word ptr [bp+6]         ; á°slo poëadovanÇho ©†dku
         db        0FFh,0B6h,6,0
         lea       di,[bp-102h]
         push      ss                       ; adresa bufferu textu ©†dku
         push      di
         lea       si,[bp-202h]
         push      ss                       ; adresa bufferu atributñ ©†dku
         push      si
         call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu

; ------ p©°prava ukazatelñ k zobrazen° ©†dku

         lea       di,[bp-102h]             ; definice ©†dku
         mov       cl,ss:[di]               ; dÇlka ©†dku
         mov       ch,0
         or        cx,cx                    ; je nàjakò znak ©†dku ?
         jz        l_49E0                   ; nen° ë†dnò znak ©†dku
         push      cx
         mov       dl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       dh,ch                    ; DH <- 0
         sub       dx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         lea       si,[bp-202h]             ; buffer s atributy textu

; ------ zobrazen° ©†dku

l_49B3:  inc       si                       ; zvò®en° ukazatele atributñ
         mov       al,ss:[si]               ; atributy znaku
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku
         inc       di                       ; zvò®en° ukazatele textu
         mov       al,ss:[di]               ; znak textu
         inc       dx                       ; zvò®en° pozice na displeji
         push      cx
         push      dx
         push      si
         push      di
         push      ax                       ; znak
         push      dx                       ; pozice
         ;push      word ptr [bp+4]         ; ©†dek na obrazovce
         db        0FFh,0B6h,4,0            ;!
         call      l_34C7                   ; vòstup znaku na displej
         pop       di
         pop       si
         pop       dx
         pop       cx
         loop      l_49B3                   ; zobrazen° dal®°ho znaku

; ------ p©i p©eteáen° ©†dku zobrazen° ®ipky na konci ©†dku

         pop       cx
         cmp       cx,word ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         jbe       l_49E0
         ;push      word ptr [bp+4]         ; ©†dek na obrazovce
         db        0FFh,0B6h,4,0            ;!
         call      l_433C                   ; zobrazen° ®ipky ©†dku "za rohem"

; ------ vymaz†n° zbytku ©†dku

l_49E0:  ;push      word ptr [bp+6]         ; á°slo ©†dku
         db        0FFh,0B6h,6,0            ;!
         mov       ax,1
         push      ax
         mov       al,0FFh
         push      ax
         ;push      word ptr [bp+4]         ; ©†dek na obravce
         db        0FFh,0B6h,4,0            ;!
         call      l_425F                   ; zobraz. oznaáen° bloku pro 1 ©†dek


         ;push      word ptr [bp+4]
         db        0FFh,0B6h,4,0            ;!
         call      l_4395                   ; zobrazen° levÇho okraje v 1 ©†dku
         ;push      word ptr [bp+4]
         db        0FFh,0B6h,4,0            ;!
         call      l_4361                   ; zobrazen° pravÇho okraje v 1 ©†dku
         ;jmp       l_4A03
         db        0e9h,0,0

l_4A03:  mov       sp,bp
         pop       bp
         ret       4

l_4978   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° p©elomu str†nky (VSTUP: [SP+2] (2) ©†dek na obrazovce)
; -----------------------------------------------------------------------------

l_4A09   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4A10
         db        0e9h,0,0

l_4A10:  mov       byte ptr ds:[d_FE56],0   ; m¢d zobrazen° znaku - bàënò znak
         mov       cx,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         ;mov       bx,[bp+4]               ; ©†dek k zobrazen° p©elomu
         db        8Bh,9Eh,4,0

l_4A1D:  push      cx
         push      bx
         mov       al,"Õ"
         push      ax                       ; znak
         push      cx                       ; pozice
         push      bx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       bx
         pop       cx
         loop      l_4A1D                   ; zobrazen° dal®°ho znaku

         push      bx
         push      bx
         call      l_4395                   ; zobrazen° levÇho okraje v 1 ©†dku
         call      l_4361                   ; zobrazen° pravÇho okraje v 1 ©†dku
         ;jmp       l_4A36
         db        0e9h,0,0

l_4A36:  mov       sp,bp
         pop       bp
         ret       2

l_4A09   ENDP

; -----------------------------------------------------------------------------
;        inicializace bufferu á°sel zobrazenòch ©†dkñ
; -----------------------------------------------------------------------------

l_4A3C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4A43
         db        0e9h,0,0

; ------ p©°prava registrñ

l_4A43:  mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       di,offset d_E5E4         ; tabulka á°sel zobrazenòch ©†dkñ
         mov       si,word ptr ds:[d_F7A9]  ; poáet ©†dkñ na str†nku bez okrajñ
         mov       cx,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce

; ------ p©°prava á°taáe ©†dkñ na str†nce

         mov       dx,1000                  ; ©†dky na str†nce se nepoá°taj°
         cmp       byte ptr cs:[l_3263],0   ; zobraz. str†nk. (1=zap., 0=vyp.)
         je        l_4A64                   ; nen° zobrazeno str†nkov†n°
         push      ax
         dec       ax                       ; á°slo aktivn°ho ©†dku relativnà
         xor       dx,dx                    ; DX <- 0
         div       si                       ; vòpoáet á°sla ©†dku a str†nky
         inc       dx                       ; á°slo ©†dku na str†nce
         pop       ax

; ------ p©°prava ukazatele v bufferu á°sel ©†dkñ

l_4A64:  mov       bx,cx                    ; á°slo ©†dku kurzoru na obrazovce
         dec       bx                       ; á°slo ©†dku na obrazovce relativnà
         shl       bx,1
         add       di,bx                    ; adresa ©†dku s kurzorem

; ------ oznaáen° á°sel ©†dkñ v bufferu p©ed kurzorem

         push      ax
         push      cx
         push      dx
         push      di

l_4A6F:  or        dx,dx                    ; je p©elom str†nky ?
         jnz       l_4A7B                   ; nen° p©elom str†nky
         mov       dx,si                    ; novò á°taá ©†dkñ na str†nce
         mov       word ptr [di],0          ; oznaáen° p©elomu str†nky
         jmp       short l_4A7F
l_4A7B:  mov       [di],ax                  ; uloëen° á°sla ©†dku
         dec       ax                       ; sn°ëen° á°sla ©†dku
         dec       dx                       ; sn°ëen° á°taáe ©†dkñ na str†nce
l_4A7F:  dec       di                       ; posun ukazatele definic ©†dkñ
         dec       di
         loop      l_4A6F                   ; definov†n° dal®°ho ©†dku

         pop       di
         pop       dx
         pop       bx
         pop       ax

; ------ oznaáen° á°sel ©†dkñ v bufferu za kurzorem

         mov       cx,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         sub       cx,bx                    ; poáet zbylòch ©†dkñ k oznaáen°
         jbe       l_4AA4                   ; jsou jië v®echny ©†dky
         inc       di
         inc       di                       ; adresa definice dal®°ho ©†dku
         inc       ax                       ; zvò®en° á°sla ©†dku
l_4A92:  cmp       dx,si                    ; je p©elom str†nky ?
         jne       l_4A9C                   ; nen° p©elom str†nky
         xor       dx,dx                    ; novò á°taá ©†dkñ na str†nce
         mov       [di],dx                  ; oznaáen° p©elomu str†nky
         jmp       short l_4AA0
l_4A9C:  mov       [di],ax                  ; uloëen° á°sla ©†dku
         inc       ax                       ; zvò®en° ukazatele á°sla ©†dku
         inc       dx                       ; zvò®en° ukazatele ©†dku na str†nce
l_4AA0:  inc       di                       ; zvò®en° ukazatele definice ©†dku
         inc       di
         loop      l_4A92                   ; definov†n° dal®°ho ©†dku

l_4AA4:  ;jmp       l_4AA7
         db        0e9h,0,0

l_4AA7:  mov       sp,bp
         pop       bp
         ret       

l_4A3C   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° r†mu okna
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] koncovò ©†dek
;        [SP+4] koncov† pozice
;        [SP+6] poá†teán° ©†dek
;        [SP+8] poá†teán° pozice
; -----------------------------------------------------------------------------

l_4AAB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4AB2
         db        0e9h,0,0

; ------ vymaz†n° podkladu okna

l_4AB2:  sub       sp,102h
         mov       ax,b5
         mov       ds:[d_FE56],al           ; m¢d zobrazen° znaku - inverzn°
         mov       ax,[bp+0Ah]
         push      ax                       ; poá†teán° pozice
         mov       ax,[bp+8]
         push      ax                       ; poá†teán° ©†dek
         mov       ax,[bp+6]
         push      ax                       ; koncov† pozice
         mov       ax,[bp+4]
         push      ax                       ; koncovò ©†dek
         mov       ax,1
         push      ax                       ; parametr - invertovanÇ okno
         call      l_34F8                   ; vykreslen° okna (kurzoru)

         mov       ax,[bp+6]
         sub       ax,[bp+0Ah]
         inc       ax
         mov       [bp-102h],al
         lea       di,[bp-101h]
         push      ss
         push      di                       ; adresa

; ------ p©°prava horn°ho ©†dku v bufferu

         mov       al,[bp-102h]
         xor       ah,ah
         push      ax                       ; dÇlka
         mov       ax,"Õ"                   ; konstanta
         call      l_0F25                   ; vynulov†n° bufferu konstantou
         mov       ax,"…"
         mov       [bp-101h],al
         mov       al,[bp-102h]
         xor       ah,ah
         xchg      ax,di
         mov       ax,"ª"
         mov       [bp+di-102h],al

; ------ zobrazen° horn°ho ©†dku

         mov       ax,[bp+0Ah]
         push      ax
         mov       ax,[bp+8]
         push      ax
         lea       di,[bp-102h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ

; ------ p©°prava k zobrazen° okrajñ okna

         mov       ax,[bp+8]
         inc       ax
         push      ax
         mov       ax,[bp+4]
         dec       ax
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_4B30
         ;jmp       l_4B61
         db        0e9h
         dw        l_4B61-$-2

; ------ zobrazen° levÇho okraje okna

l_4B30:  inc       cx
         mov       [bp-104h],ax
l_4B35:  push      cx
         mov       ax,"∫"
         push      ax                       ; znak
         mov       ax,[bp+0Ah]
         push      ax                       ; pozice
         mov       ax,[bp-104h]
         push      ax                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej

; ------ zobrazen° pravÇho okraje okna

         mov       ax,"∫"
         push      ax                       ; znak
         mov       ax,[bp+6]
         push      ax                       ; pozice
         mov       ax,[bp-104h]
         push      ax                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       cx
         dec       cx                       ; á°taá ©†dkñ k zobrazen°
         jz        l_4B61                   ; jsou jië v®echny ©†dky
         inc       word ptr [bp-104h]       ; zvò®en° ukazatele ©†dku
         ;jmp       l_4B35
         db        0e9h
         dw        l_4B35-$-2

; ------ zobrazen° spodn°ho okraje okna

l_4B61:  mov       ax,"»"
         mov       [bp-101h],al
         mov       al,[bp-102h]
         xor       ah,ah
         xchg      ax,di
         mov       ax,"º"
         mov       [bp+di-102h],al
         mov       ax,[bp+0Ah]
         push      ax
         mov       ax,[bp+4]
         push      ax
         lea       di,[bp-102h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_4B91
         db        0e9h,0,0

l_4B91:  mov       sp,bp
         pop       bp
         ret       8

l_4AAB   ENDP

; -----------------------------------------------------------------------------
;        obnoven° textu pod oknem
; -----------------------------------------------------------------------------

l_4B97   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4B9E
         db        0e9h,0,0

l_4B9E:  sub       sp,0Bh
         ;jmp       l_4C1A
         db        0e9h
         dw        l_4C1A-$-2

; -----------------------------------------------------------------------------
;        zobrazen° p©elomu str†nky
; -----------------------------------------------------------------------------

l_4BA4   PROC      NEAR

         mov       byte ptr ds:[d_FE56],0   ; m¢d zobrazen° znaku - bàënò znak
         ;mov       bx,[bp+0Ah]
         db        8Bh,9Eh,0Ah,0            ;!
         push      dx
l_4BAE:  push      cx
         push      bx
         mov       ax,"Õ"
         push      ax                       ; znak
         push      bx                       ; pozice
         push      cx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       bx
         pop       cx
         inc       bx
         ;cmp       bx,[bp+6]
         db        3Bh,9Eh,6,0              ;!
         jbe       l_4BAE

         dec       bx
         pop       dx
         ;cmp       dx,[bp+0Ah]
         db        3Bh,96h,0Ah,0            ;!
         jl        l_4BD6
         cmp       dx,bx
         jg        l_4BD6
         push      cx
         push      dx
         push      cx
         call      l_4395                   ; zobrazen° levÇho okraje v 1 ©†dku
         pop       dx
         pop       cx
l_4BD6:  add       dl,byte ptr cs:[l_325A]  ; ®°©ka ©†dku textu (znakñ)
         adc       dh,0
         ;cmp       dx,[bp+0Ah]
         db        3Bh,96h,0Ah,0            ;!
         jl        l_4BEE
         ;cmp       dx,[bp+6]
         db        3Bh,96h,6,0              ;!
         jg        l_4BEE
         push      cx
         call      l_4361                   ; zobrazen° pravÇho okraje v 1 ©†dku
l_4BEE:  ret

l_4BA4   ENDP

; -----------------------------------------------------------------------------
;        obnoven° zobrazen° ©†dku pod oknem
; -----------------------------------------------------------------------------

l_4BEF   PROC      NEAR

         or        ah,ah
         mov       ah,0
         push      ax
         push      bx
         push      di
         push      cx
         push      di                       ; á°slo ©†dku
         mov       si,offset d_EC59         ; buffer textovÇho ©†dku
         push      ds
         push      si
         mov       si,offset d_ED59         ; buffer atributñ znakñ text. ©†dku
         push      ds
         push      si
         jz        l_4C13
         push      cx
         mov       al,1
         push      ax
         push      cx
         push      dx
         push      cx
         dec       ax
         push      ax                       ; m¢d - bàën† barva
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         call      l_4395                   ; zobrazen° levÇho okraje v 1 ©†dku
l_4C13:  call      l_3F5A                   ; dek¢dov†n° ©†dku do edit. bufferu
         call      l_4755                   ; zobrazen° aktivn°ho edit. ©†dku
         ret       

l_4BEF   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_4B97)
; -----------------------------------------------------------------------------

l_4C1A:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         ;mov       ax,[bp+0Ah]
         db        8Bh,86h,0Ah,0            ;!
         ;mov       bx,[bp+6]
         db        8Bh,9Eh,6,0              ;!
         mov       dl,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         mov       dh,0
         sub       dx,word ptr ds:[d_E6A4]  ; offset zaá†tku zobrazenÇho ©†dku
         sub       bx,dx
         sub       ax,dx
         jg        l_4C3C
         mov       ax,0FF01h
l_4C3C:  ;mov       cx,[bp+8]
         db        8Bh,8Eh,8,0              ;!
l_4C40:  push      ax
         push      bx
         push      cx
         push      dx
         mov       di,cx
         dec       di
         shl       di,1
         mov       di,word ptr ds:[d_E5E4+di] ; tabulka zobrazenòch ©†dkñ
         or        di,di                    ; je platnò ©†dek ?
         jnz       l_4C56                   ; je platnò ©†dek
         call      l_4BA4                   ; zobrazen° p©elomu str†nky
         jmp       short l_4C59

l_4C56:  call      l_4BEF                   ; obnoven° zobrazen° ©†dku pod oknem
l_4C59:  pop       dx
         pop       cx
         pop       bx
         pop       ax
         inc       cx
         ;cmp       cx,[bp+4]
         db        3Bh,8Eh,4,0              ;!
         jbe       l_4C40
         ;jmp       l_4C67
         db        0e9h,0,0

l_4C67:  mov       sp,bp
         pop       bp
         ret       8

l_4B97   ENDP

; -----------------------------------------------------------------------------
;        obnoven° zobrazen° obrazovky
; -----------------------------------------------------------------------------

l_4C6D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4C74
         db        0e9h,0,0

l_4C74:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         cmp       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         jg        l_4C80
         ;jmp       l_4C86
         db        0e9h
         dw        l_4C86-$-2

l_4C80:  mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
l_4C86:  mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         sub       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         push      ax
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         sub       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jl        l_4C9E
         ;jmp       l_4CAC
         db        0e9h
         dw        l_4CAC-$-2

l_4C9E:  mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         sub       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         add       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       word ptr ds:[d_E69C],ax  ; á°slo ©†dku kurzoru na obrazovce
l_4CAC:  mov       ax,1
         push      ax
         mov       ax,1
         push      ax
         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         push      ax
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         push      ax
         call      l_4B97                   ; obnoven° textu pod oknem
         ;jmp       l_4CC2
         db        0e9h,0,0

l_4CC2:  mov       sp,bp
         pop       bp
         ret       

l_4C6D   ENDP

; -----------------------------------------------------------------------------
;        p©esun kurzoru na zadanò ©†dek
; -----------------------------------------------------------------------------

l_4CC6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4CCD
         db        0e9h,0,0

l_4CCD:  sub       sp,3
         dec       sp
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         call      l_491F                   ; normalizace kurzoru na ©†dku
         mov       [bp-5],al
         mov       al,[bp-5]
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_4CFB
         ;jmp       l_4CFE
         db        0e9h
         dw        l_4CFE-$-2

l_4CFB:  call      l_441E                   ; zobrazen° line†lu ©†dku
l_4CFE:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         ;mov       ax,[bp+4]
         db        8Bh,86h,4,0              ;!
         or        ax,ax
         jg        l_4D0F
         mov       ax,1
l_4D0F:  cmp       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         jbe       l_4D18
         mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
l_4D18:  mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       cx,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         dec       cx
         mov       bx,cx
         mov       dx,cx
         dec       bx
         shl       bx,1
l_4D27:  cmp       ax,word ptr ds:[d_E5E4+bx] ; tabulka zobrazenòch ©†dkñ
         je        l_4D3A
         dec       bx
         dec       bx
         loop      l_4D27
         shr       dx,1
         dec       dx
         mov       word ptr ds:[d_E69C],dx  ; á°slo ©†dku kurzoru na obrazovce
         jmp       short l_4D44

l_4D3A:  mov       word ptr ds:[d_E69C],cx  ; á°slo ©†dku kurzoru na obrazovce
         ;cmp       [bp-5],ch
         db        38h,0AEh,0FBh,0FFh       ;!
         je        l_4D47
l_4D44:  call      l_4C6D                   ; obnoven° zobrazen° obrazovky
l_4D47:  ;jmp       l_4D4A
         db        0e9h,0,0

l_4D4A:  mov       sp,bp
         pop       bp
         ret       2

l_4CC6   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° n†povàdy k volb†m
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] á°slo n†povàdy
; -----------------------------------------------------------------------------

l_4D50   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4DA0
         db        0e9h
         dw        l_4DA0-$-2

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4D57   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_4D63
         db        0e9h,0,0

l_4D63:  mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         sub       ax,2
         push      ax
         mov       ax,0
         push      ax
         mov       ax,5Eh
         push      ax
         mov       al,[bp+6]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         call      l_1460
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       al,[bp+4]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_4D9A
         db        0e9h,0,0

l_4D9A:  mov       sp,bp
         pop       bp
         ret       4

l_4D57   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_4D50)
; -----------------------------------------------------------------------------

; ------ poskytnut° adresy definice n†povàdy

l_4DA0:  mov       bx,7
         call      dword ptr ds:[d_FDC7]    ; poskytnut° adresy n†povàdy

; ------ test, zda se okno m† zobrazit

         mov       al,1
         cmp       al,es:[si]
         je        l_4DBA
         mov       al,0
         cmp       al,byte ptr ds:[d_F259]  ; buffer p©ehr†vanÇ makrokl†vesy
         jne       l_4DBA
         mov       al,byte ptr cs:[3277h]   ; n†povàda (1=zap., 0=vyp.)
l_4DBA:  mov       byte ptr ds:[d_F78C],al
         or        al,al
         jnz       l_4DF2                   ; nezobraz° se
         cmp       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         jne       l_4DEF
         mov       byte ptr ds:[d_FE56],20h ; m¢d zobrazen° znaku - inverzn°
         mov       bx,0Ch
         cmp       byte ptr es:[si+7],43h           ; 'C'
         je        l_4DE1
         mov       bx,15
         cmp       byte ptr es:[si+0Ah],43h         ; 'C'
         jne       l_4DEF
l_4DE1:  mov       ah,0
         mov       al,es:[bx+si]
         push      ax
         mov       al,es:[bx+si+1]
         push      ax
         call      l_4D57
l_4DEF:  ;jmp       l_4E54
         db        0e9h
         dw        l_4E54-$-2

l_4DF2:  push      es
         push      si
         mov       cx,4
         mov       ah,0
l_4DF9:  inc       si
         mov       al,es:[si]
         push      ax
         loop      l_4DF9

         call      l_4AAB                   ; zobrazen° r†mu okna
         pop       si
         pop       es

         inc       si
         mov       bl,es:[si]
         mov       bh,0
         inc       bx
         mov       di,bx
         inc       si
         mov       cl,es:[si]
         mov       ch,0
         inc       si
         inc       si

; ------ zvò®en° pozice na ©†dku

l_4E16:  inc       si
         mov       al,es:[si]               ; bajt k zobrazen°
         or        al,al
         jz        l_4E54
         cmp       al,30                    ; je platnò znak ?
         ja        l_4E26                   ; je platnò znak
         add       bl,al                    ; zvò®en° pozice na ©†dku
         jmp       short l_4E16

; ------ konec ©†dku

l_4E26:  cmp       al,31                    ; je konec ©†dku ?
         jne       l_4E2F
         inc       cx                       ; zvò®en° ukazatele ©†dku
         mov       bx,di                    ; poá†teán° pozice na ©†dku
         jmp       short l_4E16

; ------ zmàna p©°znaku podtrëen° textu

l_4E2F:  cmp       al,"$"
         jne       l_4E3B
         inc       bx
         xor       byte ptr ds:[d_FE56],8   ; m¢d zobrazen° znaku - podtrëen°
         jmp       short l_4E16

; ------ zobrazen° ©°dic°ho znaku

l_4E3B:  cmp       al,0F0h                  ; je ©°dic° znak ?
         jb        l_4E41
         and       al,1Fh                   ; zobrazen° ©°dic°ho znaku 10h - 1Fh

; ------ zobrazen° znaku

l_4E41:  push      bx
         push      cx
         push      si
         push      di
         push      es
         push      ax                       ; znak
         push      bx                       ; pozice
         push      cx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej
         pop       es
         pop       di
         pop       si
         pop       cx
         pop       bx
         inc       bx
         jmp       short l_4E16             ; dal®° znak

l_4E54:  ;jmp       l_4E57
         db        0e9h,0,0

l_4E57:  mov       sp,bp
         pop       bp
         ret       2

l_4D50   ENDP

; -----------------------------------------------------------------------------
;        n†vrat podkladu pod n†povàdou
; -----------------------------------------------------------------------------

l_4E5D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4E64
         db        0e9h,0,0

l_4E64:  xor       ax,ax
         cmp       al,byte ptr ds:[d_F78C]
         je        l_4E8A
         mov       bx,7
         call      dword ptr ds:[d_FDC7]    ; poskytnut° adresy n†povàdy
         cmp       al,es:[si]
         jne       l_4E7B
         mov       byte ptr ds:[d_F259],al  ; buffer p©ehr†vanÇ makrokl†vesy
l_4E7B:  mov       cx,4
l_4E7E:  inc       si
         mov       al,es:[si]
         push      ax
         loop      l_4E7E
         call      l_4B97                   ; obnoven° textu pod oknem
         jmp       short l_4EA2

l_4E8A:  cmp       al,byte ptr cs:[l_3264]  ; zobr. line†lu ©†d.(1=zap., 0=vyp.)
         jne       l_4EA2
         mov       bx,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         dec       bx
         dec       bx
         push      bx
         push      ax
         inc       bx
         inc       bx
         push      bx
         push      ax
         inc       ax
         push      ax
         call      l_34F8                   ; vykreslen° okna (kurzoru)
l_4EA2:  ;jmp       l_4EA5
         db        0e9h,0,0

l_4EA5:  mov       sp,bp
         pop       bp
         ret       2

l_4E5D   ENDP

; *****************************************************************************
;
;                       Obsluha tisku souborñ
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        test p©ipravenosti tisk†rny
; -----------------------------------------------------------------------------

l_4EAB   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4EB2
         db        0e9h,0,0

l_4EB2:  mov       ah,2
         mov       dl,byte ptr cs:[l_324F]  ; á°slo portu tisk†rny LPT
         mov       dh,0
         int       17h                      ; test stavu tisk†rny
         and       ah,0B8h                  ; bity p©ipravenosti a chyby
         mov       dl,byte ptr cs:[l_326F]  ; korekce stavu tisk†rny (0=netest.)
         or        dl,dl                    ; testuje se stav tisk†rny ?
         jz        l_4ECB                   ; netestuje se stav tisk†rny
         xor       ah,dl                    ; test stavu tisk†rny
l_4ECB:  mov       ax,0                     ; p©°znak - nen° p©ipravena
         jnz       l_4ED1                   ; tisk†rna nen° p©ipravena
         inc       ax                       ; p©°znak - je p©ipravena

l_4ED1:  or        ax,ax                    ; test - je tisk†rna p©ipravena ?
         mov       sp,bp
         pop       bp
         ret       1

l_4EAB   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4ED9   PROC      NEAR

         ;jmp       l_4EDC
         db        0e9h,0,0

l_4EDC:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_4ED9   ENDP

; -----------------------------------------------------------------------------
;        test, zda je ukonáen tisk
; -----------------------------------------------------------------------------

l_4EE9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_4EF0
         db        0e9h,0,0

l_4EF0:  mov       ax,0
         mov       [bp+4],al
         mov       ax,word ptr ds:[d_F994]  ; 1=p©°znak prob°haj°c°ho tisku;0=ne
         cmp       ax,0
         mov       ax,1
         jnz       l_4F02
         dec       ax
l_4F02:  push      ax
         mov       ax,word ptr ds:[d_F98A]  ; á°slo ti®tànÇho prostoru
         cmp       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         mov       ax,1
         jz        l_4F10
         dec       ax
l_4F10:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_4F1A
         ;jmp       l_4F26
         db        0e9h
         dw        l_4F26-$-2

l_4F1A:  mov       ax,11h
         mov       ds:[d_F79D],ax           ; k¢d chyby - prostor nevyti®tàn
         mov       ax,1
         mov       [bp+4],al
l_4F26:  ;jmp       l_4F29
         db        0e9h,0,0

l_4F29:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_4EE9   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4F36   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_509F

l_4F36   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4F3D   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         jmp       l_4FE3

l_4F3D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4F49   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         ;jmp       l_4F58
         db        0e9h,0,0

l_4F58:  dec       sp
         dec       sp
         mov       ax,1001h
         push      ax
         mov       di,offset d_FCC7
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,0
         jg        l_4F76
         ;jmp       l_4F9A
         db        0e9h
         dw        l_4F9A-$-2

l_4F76:  mov       ax,word ptr ds:[d_F990]
         and       ax,1
         jnz       l_4F81
         ;jmp       l_4F93
         db        0e9h
         dw        l_4F93-$-2

l_4F81:  mov       di,offset d_FCC7
         push      ds
         push      di
         mov       ax,1
         push      ax
         mov       ax,[bp-8]
         call      l_1408                   ; vyjmut° cesty z oznaáen° souboru
         ;jmp       l_4F9A
         db        0e9h
         dw        l_4F9A-$-2

l_4F93:  mov       ax,[bp-8]
         dec       ax
         mov       ds:[d_FCC7],al
l_4F9A:  mov       ax,2301h
         push      ax
         mov       di,offset d_FCC7
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_136C
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,0
         jg        l_4FB6
         ;jmp       l_4FDC
         db        0e9h
         dw        l_4FDC-$-2

l_4FB6:  mov       di,offset d_FCC7
         push      ds
         push      di
         mov       ax,[bp-8]
         push      ax
         mov       ax,1
         call      l_1408                   ; vyjmut° cesty z oznaáen° souboru
         sub       sp,9
         mov       ax,word ptr ds:[d_F990]
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         mov       di,offset d_FCC7
         push      ds
         push      di
         mov       ax,[bp-8]
         mov       cl,0FFh
         call      l_13B0
l_4FDC:  ;jmp       l_4FDF
         db        0e9h,0,0

l_4FDF:  mov       sp,bp
         pop       bp
         ret       

l_4F49   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_4FE3   PROC      NEAR

         mov       ax,word ptr ds:[d_F996]
         cmp       ax,word ptr ds:[d_F984]
         jle       l_4FEF
         ;jmp       l_5015
         db        0e9h
         dw        l_5015-$-2

l_4FEF:  mov       ax,word ptr ds:[d_F98A]  ; á°slo ti®tànÇho prostoru
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_F996]
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,offset d_E6A6+1       ; maxim†ln° dÇlka ©†dku od L okraje
         push      ds
         push      di
         mov       di,offset d_FCC7
         push      ds
         push      di
         call      l_3EB2                   ; naáten° textu ©†dku do bufferu
         call      l_4F49
         jmp       l_5098

l_5015:  mov       ax,word ptr ds:[d_F996]
         push      ax
         mov       ax,word ptr ds:[d_F988]
         sub       ax,word ptr ds:[d_F986]
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_5029
         ;jmp       l_5059
         db        0e9h
         dw        l_5059-$-2

l_5029:  mov       ax,word ptr ds:[d_F98A]  ; á°slo ti®tànÇho prostoru
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         push      di
         mov       ax,word ptr ds:[d_F996]
         add       ax,word ptr ds:[d_F986]
         sub       ax,word ptr ds:[d_F988]
         pop       di
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,offset d_E6D3 - 4
         push      ds
         push      di
         mov       di,offset d_FCC7
         push      ds
         push      di
         call      l_3EB2                   ; naáten° textu ©†dku do bufferu
         call      l_4F49
         ;jmp       l_5098
         db        0e9h
         dw        l_5098-$-2

l_5059:  mov       ax,word ptr ds:[d_F98C]
         cmp       ax,word ptr ds:[d_F98E]
         jg        l_5065
         ;jmp       l_506E
         db        0e9h
         dw        l_506E-$-2

l_5065:  mov       ax,0
         mov       ds:[d_FCC7],al
         ;jmp       l_5098
         db        0e9h
         dw        l_5098-$-2

l_506E:  mov       ax,word ptr ds:[d_F98C]
         push      ax
         dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_F98A]  ; á°slo ti®tànÇho prostoru
         push      ax
         call      l_4167                   ; poáet ©†dkñ p©ed zadanòm prostorem
         pop       cx
         add       ax,cx
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      di
         mov       di,offset d_FCC7
         push      ds
         push      di
         call      l_3EB2                   ; naáten° textu ©†dku do bufferu
         mov       ax,word ptr ds:[d_F98C]
         inc       ax
         mov       word ptr ds:[d_F98C],ax
l_5098:  ;jmp       l_509B
         db        0e9h,0,0

l_509B:  mov       sp,bp
         pop       bp
         ret       

l_4FE3   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_509F   PROC      NEAR

         jmp       l_520B

l_509F   ENDP

; -----------------------------------------------------------------------------
;        uloëen° znaku do tiskovÇho bufferu
; -----------------------------------------------------------------------------

l_50A2   PROC      NEAR

         cmp       ah,0FFh
         jne       l_50AB
         or        dl,40h
         ret       

l_50AB:  test      dl,40h
         jz        l_50BC
         xor       dl,40h
         test      dl,20h
         jnz       l_50C9
         mov       al,0Ah
         jmp       short l_50C3

l_50BC:  test      dl,20h
         jz        l_50C9
         mov       al,0Bh
l_50C3:  call      l_5113
         xor       dl,20h


l_50C9:  mov       al,ah
         mov       si,offset l_3220         ; tabulka nahrazovanòch znakñ tisku
         mov       cl,cs:[si]               ; poáet znakñ v tabulce
         mov       ch,0
         jcxz      l_50DF
         add       si,cx
l_50D7:  cmp       ah,cs:[si]               ; je to nahrazovanò znak ?
         je        l_50ED
         dec       si
         loop      l_50D7

l_50DF:  cmp       al,20h
         jae       l_50FB
         cmp       al,11h
         je        l_5112
         cmp       al,15h
         je        l_50FB
         jmp       short l_5104

l_50ED:  mov       si,cx
         mov       al,byte ptr cs:[l_3231+si] ; tabulka n†hradn°ch znakñ tisku
         mov       si,offset l_3199         ; k¢dy tisk†rny - uëivatelskÇ funkce
         cmp       al,7
         jbe       l_5122                   ; uloëen° ©etàzce do tisk. bufferu
l_50FB:  or        dh,dh
         jns       l_5106
         test      dl,10h
         jnz       l_5106

; ------ uloëen° znaku do bufferu k tisku

l_5104:  mov       al," "
l_5106:  cmp       di,cs:[l_34AD]           ;
         jae       l_5112
         mov       byte ptr ds:[d_F9A6+di],al ; tiskovò vyrovn†vac° buffer
         inc       di
l_5112:  ret

l_50A2   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5113   PROC      NEAR

         mov       si,offset l_30C1         ; k¢dy tisk†rny tiskovòch efektñ
         jmp       short l_5122             ; uloëen° ©etàzce do tisk. bufferu

l_5113   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5118   PROC      NEAR

         mov       si,offset l_312D         ; k¢dy tisk†rny nastaven° typu p°sma
         jmp       short l_5122             ; uloëen° ©etàzce do tisk. bufferu

l_5118   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_511D   PROC      NEAR

         mov       al,1
l_511F:  mov       si,offset l_31E1         ; k¢dy tisk†rny - z†kladn° ovl†d†n°

l_511D   ENDP

; -----------------------------------------------------------------------------
;        uloëen° ©etàzce AL/SI do tiskovÇho bufferu
; -----------------------------------------------------------------------------

l_5122   PROC      NEAR

         push      ax
         push      cx
         mov       ah,0
         add       si,ax
         mov       cl,3
         shl       ax,cl
         add       si,ax                    ; adresa ©etàzce
         mov       cl,cs:[si]               ; dÇlka ©etàzce
         mov       ch,0
         jcxz      l_513E
l_5135:  inc       si
         mov       al,cs:[si]
         call      l_5106                   ; uloëen° znaku do tiskovÇho bufferu
         loop      l_5135
l_513E:  pop       cx
         pop       ax
         ret       

l_5122   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5141   PROC      NEAR

         mov       al,ah
         shl       al,1
         mov       cl,ah
         mov       ch,1
         shl       ch,cl
         test      dl,ch
         jz        l_5151
         inc       al
l_5151:  xor       dl,ch
         or        dh,ah
         jmp       short l_5113

l_5141   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5157   PROC      NEAR

         push      bx
         mov       si,offset l_3217
         mov       bl,cs:[si]
         mov       bh,0
         or        bx,bx
         jz        l_5173
         add       bx,si
         xchg      al,cs:[bx]
         push      ax
         mov       al,0
         call      l_5122                   ; uloëen° ©etàzce do tisk. bufferu
         pop       ax
         xchg      al,cs:[bx]
l_5173:  pop       bx
         ret       

l_5157   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5175   PROC      NEAR

         mov       bl,ds:[d_FCC7]
         or        bl,bl
         jz        l_51E5
         mov       bh,0
         mov       ah,11h
         cmp       ah,ds:[d_FCC7+bx]
         jne       l_518B
         call      l_50A2                   ; uloëen° znaku do tiskovÇho bufferu
         dec       bx
l_518B:  mov       cx,word ptr ds:[d_F982]
         jcxz      l_5196
l_5191:  call      l_5104
         loop      l_5191
l_5196:  xchg      bx,cx
l_5198:  inc       bx
         push      cx
         mov       ah,ds:[d_FCC7+bx]
         cmp       ah,7
         ja        l_51B4
         cmp       ah,5
         ja        l_51CF
         jz        l_51AF
         call      l_5141
         jmp       short l_51CF

l_51AF:  xor       dl,80h
         jmp       short l_51CF

l_51B4:  or        dl,dl
         jns       l_51CC
         sub       ah,30h
         jc        l_51CF
         cmp       ah,7
         ja        l_51CF
         mov       si,offset l_3199         ; k¢dy tisk†rny - uëivatelskÇ funkce
         mov       al,ah
         call      l_5122                   ; uloëen° ©etàzce do tisk. bufferu
         jmp       short l_51CF

l_51CC:  call      l_50A2                   ; uloëen° znaku do tiskovÇho bufferu
l_51CF:  pop       cx
         loop      l_5198
         mov       ax,1
         mov       cl,dl
l_51D7:  shr       cl,1
         jnc       l_51DE
         call      l_5113
l_51DE:  inc       ax
         inc       ax
         cmp       ax,0Dh
         jb        l_51D7
l_51E5:  ret

l_5175   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_51E6   PROC      NEAR

         mov       ax,word ptr ds:[d_F99E]
         mov       word ptr ds:[d_F98C],ax
         mov       ax,word ptr ds:[d_F9A0]
         mov       word ptr ds:[d_F990],ax
         mov       ax,1
         mov       word ptr ds:[d_F996],ax
         mov       byte ptr ds:[d_F9A5],al
         mov       byte ptr ds:[d_F9A4],ah
         cmp       al,byte ptr cs:[l_3258]  ; vòmàna pap°ru (1=zap., 0=vyp.)
         jne       l_5208
         neg       ax
l_5208:  mov       word ptr ds:[d_F994],ax  ; 1=p©°znak prob°haj°c°ho tisku;0=ne
l_520B:  xor       di,di
         mov       dx,8000h
         cmp       dl,byte ptr ds:[d_F9A4]
         jne       l_5286
         mov       ax,word ptr ds:[d_F990]
         cmp       ax,word ptr ds:[d_F992]
         jbe       l_522C
         dec       word ptr ds:[d_F99C]
         jnz       l_51E6
         mov       word ptr ds:[d_F994],di  ; 1=p©°znak prob°haj°c°ho tisku;0=ne
         jmp       l_5310

l_522C:  call      l_4F3D
         mov       al,1
         xor       di,di
         mov       dx,di
         cmp       al,byte ptr ds:[d_F996]
         jne       l_5286
         cmp       al,byte ptr ds:[d_F9A5]
         jne       l_5274
         mov       byte ptr ds:[d_F9A5],dh
         mov       al,4
         call      l_511F
         mov       al,1
l_524C:  call      l_5113
         inc       ax
         inc       ax
         cmp       al,0Dh
         jb        l_524C
         mov       ah,1
         mov       bx,offset l_3251         ; vy®®° kvalita (1=zap., 0=vyp.)
l_525A:  mov       al,ah
         sub       al,cs:[bx]
         call      l_5118
         inc       bx
         inc       ah
         inc       ah
         cmp       ah,0Dh
         jb        l_525A
         mov       al,byte ptr ds:[d_F998]
         call      l_5157
         jmp       short l_5281

l_5274:  cmp       al,byte ptr cs:[l_3258]  ; vòmàna pap°ru (1=zap., 0=vyp.)
         jne       l_5281
         mov       word ptr ds:[d_F994],0FFFFh ; 1=p©°znak prob°haj°c°ho tisku;0=ne
l_5281:  mov       al,2
         call      l_511F
l_5286:  mov       al,0
         call      l_511F
         call      l_5175
         mov       ah,byte ptr ds:[d_F998]
         mov       bl,ah
         or        dh,dh
         jns       l_52A5
         dec       byte ptr ds:[d_F9A4]
         jnz       l_52B8
         mov       al,ah
         call      l_5157
         jmp       short l_52BF

l_52A5:  shr       dh,1
         shr       dh,1
         shr       dh,1
         jnc       l_52BF
         mov       al,byte ptr cs:[l_324E]
         or        al,al
         jz        l_52BF
         mov       byte ptr ds:[d_F9A4],al
l_52B8:  mov       al,0Dh
         call      l_5106                   ; uloëen° znaku do tiskovÇho bufferu
         jmp       short l_5305

l_52BF:  call      l_511D
         mov       cx,word ptr ds:[d_F996]
         cmp       cx,word ptr ds:[d_F988]
         jne       l_52F7
         mov       al,byte ptr ds:[d_F99A]
         or        al,al
         jz        l_52DD
         mov       bl,al
         call      l_5157
         jz        l_52DD
         call      l_511D
l_52DD:  mov       al,3
         call      l_511F
         mov       cx,word ptr ds:[d_F990]
         cmp       cx,word ptr ds:[d_F992]
         jb        l_52F1
         mov       al,5
         call      l_511F
l_52F1:  xor       cx,cx
         inc       word ptr ds:[d_F990]
l_52F7:  inc       cx
         mov       word ptr ds:[d_F996],cx
         cmp       ah,bl
         je        l_5305
         mov       al,ah
         call      l_5157
l_5305:  mov       byte ptr ds:[d_F9A6+di],0FFh ; tiskovò vyrovn†vac° buffer
         mov       word ptr ds:[d_F9A2],0   ; ukazatel znakñ v tiskovÇm bufferu
l_5310:  ;jmp       l_5313
         db        0e9h,0,0

l_5313:  mov       sp,bp
         pop       bp
         ret       

l_51E6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5317   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_531E
         db        0e9h,0,0

l_531E:  mov       ax,[bp+4]
         mov       word ptr ds:[d_F99C],ax
         mov       al,byte ptr cs:[l_3259]  ; poá†teán° pozice (levò okraj)
         xor       ah,ah
         mov       word ptr ds:[d_F982],ax
         mov       al,byte ptr cs:[l_325B]  ; poáet ©†dkñ z†hlav°
         xor       ah,ah
         mov       word ptr ds:[d_F984],ax
         mov       al,byte ptr cs:[l_325C]  ; poáet ©†dkñ paty
         xor       ah,ah
         mov       word ptr ds:[d_F986],ax
         mov       al,byte ptr cs:[l_325D]  ; poáet ©†dkñ na str†nku
         xor       ah,ah
         mov       word ptr ds:[d_F988],ax
         mov       ax,word ptr ds:[d_F7A7]  ; á°slo aktivn°ho prostoru
         mov       word ptr ds:[d_F98A],ax  ; á°slo ti®tànÇho prostoru
         mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         mov       word ptr ds:[d_F98E],ax
         mov       ax,word ptr ds:[d_F7A9]  ; poáet ©†dkñ na str†nku bez okrajñ
         push      ax
         mov       ax,[bp+0Ah]
         dec       ax
         pop       cx
         imul      cx
         inc       ax
         mov       word ptr ds:[d_F98C],ax
         mov       ax,[bp+6]
         mov       word ptr ds:[d_F990],ax
         mov       ax,[bp+6]
         add       ax,[bp+8]
         sub       ax,[bp+0Ah]
         mov       word ptr ds:[d_F992],ax
         mov       ax,1
         mov       word ptr ds:[d_F994],ax  ; 1=p©°znak prob°haj°c°ho tisku;0=ne
         mov       ax,1
         mov       word ptr ds:[d_F996],ax
         mov       ax,2
         push      ax
         mov       di,offset l_3217
         push      cs
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_135F
         xchg      ax,di
         mov       al,byte ptr cs:[l_3217+di]
         xor       ah,ah
         pop       cx
         imul      cx
         mov       [bp+6],ax
         mov       al,byte ptr cs:[l_3257]  ; samostatnò list (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_53AA
         ;jmp       l_53C3
         db        0e9h
         dw        l_53C3-$-2

l_53AA:  mov       di,offset l_3248
         push      cs
         call      l_1950
         mov       ax,[bp+6]
         call      l_1B0C
         call      l_19AD
         call      l_1AD3
         mov       [bp+6],ax
         ;jmp       l_53D9
         db        0e9h
         dw        l_53D9-$-2

l_53C3:  mov       di,offset l_3242
         push      cs
         call      l_1950
         mov       ax,[bp+6]
         call      l_1B0C
         call      l_19AD
         call      l_1AD3
         mov       [bp+6],ax
l_53D9:  mov       ax,[bp+6]
         cwd       
         idiv      word ptr ds:[d_F988]
         mov       word ptr ds:[d_F998],ax
         mov       ax,[bp+6]
         cwd       
         idiv      word ptr ds:[d_F988]
         xchg      ax,dx
         mov       word ptr ds:[d_F99A],ax
         mov       ax,1
         mov       byte ptr ds:[d_F9A5],al
         mov       ax,0
         mov       byte ptr ds:[d_F9A4],al
         mov       ax,word ptr ds:[d_F98C]
         mov       word ptr ds:[d_F99E],ax
         mov       ax,word ptr ds:[d_F990]
         mov       word ptr ds:[d_F9A0],ax
         call      l_4F36
         ;jmp       l_540E
         db        0e9h,0,0

l_540E:  mov       sp,bp
         pop       bp
         ret       8

l_5317   ENDP

; *****************************************************************************
;
;                           Obsluha kl†vesnice
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        vstup znaku z kl†vesnice
; -----------------------------------------------------------------------------
; VùSTUP: AX=0 nen° p©ipravena kl†vesa
;         AH=0, v AL bàënò ASCII znak
;         AH=-1, v AL negace SCAN k¢du ©°dic° kl†vesy
; -----------------------------------------------------------------------------

l_5414   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_541B
         db        0e9h,0,0

l_541B:  mov       ah,1
         int       16h                      ; test znaku z kl†vesnice
         mov       ax,0                     ; p©°znak - nen° znak z kl†vesnice
         jz        l_5432                   ; nen° p©ipraven znak z kl†vesnice
         int       16h                      ; áten° k¢du kl†vesy z kl†vesnice
         or        al,al                    ; je ©°dic° kl†vesa ?
         jz        l_542E                   ; je ©°dic° kl†vesa
         mov       ah,0                     ; je bàënò ASCII znak
         jmp       short l_5432

l_542E:  xchg      al,ah                    ; AL <- SCAN k¢d ©°dic° kl†vesy
         neg       ax                       ; p©°znak ©°dic° kl†vesy
l_5432:  mov       sp,bp
         pop       bp
         ret       2

l_5414   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5438   PROC      NEAR

         ;jmp       l_543B
         db        0e9h,0,0

l_543B:  mov       ax,[bp+4]
         mov       sp,bp
         pop       bp
         ret       2

l_5438   ENDP

; -----------------------------------------------------------------------------
;        vstup znaku z kl†vesnice s obsluhou tisk†rny a maker
; -----------------------------------------------------------------------------

l_5444   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_544B
         db        0e9h,0,0

; ------ test, zda je nàjakò znak k tisku

l_544B:  cmp       byte ptr ds:[d_F994],1   ; prob°h† vòstup na tisk†rnu ?
         jne       l_547D                   ; neprob°h† vòstup na tisk†rnu
         dec       sp
         call      l_4EAB                   ; test p©ipravenosti tisk†rny
         jz        l_547D                   ; tisk†rna nen° p©ipravena

; ------ dal®° znak k tisku

         mov       di,word ptr ds:[d_F9A2]  ; ukazatel znakñ v tiskovÇm bufferu
         mov       al,byte ptr ds:[d_F9A6+di] ; tiskovò vyrovn†vac° buffer-znak
         cmp       al,0FFh
         jne       l_5469
         call      l_4F36
         jmp       short l_547D

; ------ vòstup znaku AL na tisk†rnu

l_5469:  mov       ah,0
         mov       dl,byte ptr cs:[l_324F]  ; á°slo portu tisk†rny LPT
         mov       dh,0
         int       17h                      ; vòstup znaku na tisk†rnu
         test      ah,1                     ; je TIME-OUT tisk†rny ?
         jnz       l_547D                   ; je TIME-OUT
         inc       word ptr ds:[d_F9A2]     ; ukazatel znakñ v tiskovÇm bufferu

; ------ test, zda je p©ipraven znak v bufferu p©ehr†vanÇ makrokl†vesy

l_547D:  mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         mov       ah,0
         cmp       ah,[di]                  ; je nàco v bufferu ?
         je        l_5499                   ; v bufferu nic nen°

; ------ naáten° znaku z bufferu p©ehr†vanÇ makrokl†vesy

         mov       bx,word ptr ds:[d_F79F]  ; ukazatel p©ehr†vanÇ makrokl†vesy
         mov       al,[bx+di]               ; znak z bufferu makrokl†vesy
         inc       bx                       ; zvò®en° ukazatele v bufferu
         mov       word ptr ds:[d_F79F],bx  ; novò ukazatel makrokl†vesy
         cmp       bl,[di]                  ; byl to posledn° znak makra ?
         jbe       l_54CC                   ; nebyl to je®tà posledn° znak makra
         mov       [di],ah                  ; nulov†n° bufferu makrokl†vesy
         jmp       short l_54CC

; ------ naáten° znaku z kl†vesnice (0=nen° kl†vesa)

l_5499:  dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl†vesnice
         or        ax,ax                    ; je ©°dic° kl†vesa z kl†vesnice ?
         jns       l_54CC                   ; nen° kl†vesa nebo je ASCII znak

; ------ pokus o nalezen° ©°dic° kl†vesy v bufferu makrokl†ves

         neg       ax                       ; oprava k¢du ©°dic° kl†vesy
         push      ax                       ; k¢d ©°dic° kl†vesy
         push      ax                       ; hledan† makrokl†vesa
         call      l_40D2                   ; nalezen° kl†vesy v makrobufferu
         or        ax,ax                    ; byla kl†vesa nalezena ?
         jz        l_54CC                   ; kl†vesa nebyla nalezena

; ------ p©enesen° makra do bufferu p©ehr†vanÇ makrokl†vesy

         mov       si,offset l_2CD9         ; tabulka definice maker
         add       si,ax                    ; adresa nalezenÇ makrokl†vesy
         mov       di,offset d_F259         ; buffer p©ehr†vanÇ makrokl†vesy
         mov       cl,cs:[si]               ; dÇlka ©etàzce makrodefinice
         mov       ch,0                     ; CH <- 00
         inc       cx                       ; dÇlka ©etàzce + 1
l_54BB:  mov       al,cs:[si]               ; znak makrodefinice
         mov       [di],al                  ; uloëen° makrodefinice kl†vesy
         inc       si                       ; zdrojov† adresa
         inc       di                       ; ukl†dac° adresa
         loop      l_54BB                   ; p©enos dal®°ho znaku

; ------ zah†jen° p©ehr†v†n° makra

         mov       word ptr ds:[d_F79F],1   ; ukazatel p©ehr†vanÇ makrokl†vesy
         jmp       short l_547D

l_54CC:  mov       sp,bp
         pop       bp
         ret       2

l_5444   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_54D2   PROC      NEAR

         ;jmp       l_54D5
         db        0e9h,0,0

l_54D5:  mov       ax,[bp+4]
         mov       sp,bp
         pop       bp
         ret       2

l_54D2   ENDP

; -----------------------------------------------------------------------------
;        vstup kl†vesy s áek†n°m + makro + tisk
; -----------------------------------------------------------------------------

l_54DE   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_54E5
         db        0e9h,0,0

l_54E5:  dec       sp
         dec       sp
l_54E7:  dec       sp
         dec       sp
         call      l_5444                   ; vstup z kl†vesnice + makra + tisk
         mov       [bp-4],ax
         mov       ax,[bp-4]
         cmp       ax,0
         jne       l_54FA
         ;jmp       l_54E7
         db        0e9h
         dw        l_54E7-$-2

l_54FA:  mov       ax,[bp-4]
         mov       [bp+4],ax
         ;jmp       l_5503
         db        0e9h,0,0

l_5503:  mov       ax,[bp+4]
         mov       sp,bp
         pop       bp
         ret       2

l_54DE   ENDP

; -----------------------------------------------------------------------------
;        áek†n° na potvrzen° hl†®en° (Enter nebo ESC)
; -----------------------------------------------------------------------------

l_550C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5513
         db        0e9h,0,0

; ------ vstup znaku z kl†vesnice

l_5513:  dec       sp
         dec       sp
l_5515:  dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         mov       [bp-4],ax

; ------ test, zda je kl†vesa ENTER nebo ESC

         mov       ax,[bp-4]
         cmp       ax,CR                    ; je kl†vesa ENTER ?
         mov       ax,1
         je        l_5529
         dec       ax
l_5529:  push      ax
         mov       ax,[bp-4]
         cmp       ax,ESCP                  ; je kl†vesa ESC ?
         mov       ax,1
         je        l_5536
         dec       ax
l_5536:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_5540
         ;jmp       l_5515                  ; p©i jinÇ kl†vese áek†n° d†le
         db        0e9h
         dw        l_5515-$-2

; ------ rozli®en° n†vratovÇho k¢du, zda je ENTER nebo ESC

l_5540:  mov       ax,[bp-4]
         cmp       ax,1Bh
         mov       ax,1
         jz        l_554C
         dec       ax
l_554C:  mov       [bp+4],al
         ;jmp       l_5552
         db        0e9h,0,0

l_5552:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_550C   ENDP

; -----------------------------------------------------------------------------
;        vypr†zdnàn° bufferu kl†vesnice
; -----------------------------------------------------------------------------

l_555F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5566
         db        0e9h,0,0

l_5566:  dec       sp
         dec       sp
         call      l_5414                   ; vstup znaku z kl†vesnice
         cmp       ax,0                     ; je platnò znak ?
         je        l_5573                   ; nen° p©ipraven dal®° znak
         ;jmp       l_5566                  ; zru®en° dal®°ho znaku
         db        0e9h
         dw        l_5566-$-2

l_5573:  ;jmp       l_5576
         db        0e9h,0,0

l_5576:  mov       sp,bp
         pop       bp
         ret       

l_555F   ENDP

; *****************************************************************************
;
;                   Zad†n° znakñ pomoc° ASCII tabulky
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        volba znaku pomoc° ASCII tabulky (vòstup -> AX zadanò znak)
; -----------------------------------------------------------------------------

l_557A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_55C1
         db        0e9h
         dw        l_55C1-$-2

; -----------------------------------------------------------------------------
;        zobrazen° á°sla aktivn°ho znaku v tabulce
; -----------------------------------------------------------------------------

l_5581   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_558D
         db        0e9h,0,0

; ------ zobrazen° á°sla

l_558D:  mov       ax,25h
         push      ax
         mov       ax,0Fh
         push      ax
         mov       ax,20h
         push      ax
         sub       sp,9
         mov       ax,[bp+4]
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         call      l_1460
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       ax," "*HI + 1            ; ©etàzec - £vodn° mezera
         push      ax
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,0FFh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         ;jmp       l_55BB
         db        0e9h,0,0

l_55BB:  mov       sp,bp
         pop       bp
         ret       2

l_5581   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_557A)
; -----------------------------------------------------------------------------

l_55C1:  jmp       short l_55EC

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru v ASCII tabulce pro znak AL
; -----------------------------------------------------------------------------

l_55C3   PROC      NEAR

         sub       al,"{"                   ; znak v tabulce relativnà
         mov       bl,22                    ; poáet znakñ na ©†dek v tabulce
         div       bl                       ; ©†dek a pozice relativnà

         mov       bl,ah                    ; pozice v tabulce relativnà
         mov       bh,0
         shl       bx,1                     ; pozice relativnà * 2
         add       bx,36                    ; pozice kurzoru v tabulce

         mov       cl,al                    ; ©†dek kurzoru relativnà
         mov       ch,0
         shl       cx,1                     ; ©†dek relativnà * 2
         add       cx,3                     ; ©†dek kurzoru v tabulce

         dec       bx
         push      bx                       ; poá†teán° pozice kurzoru
         dec       cx
         push      cx                       ; poá†teán° ©†dek kurzoru
         inc       bx
         inc       bx
         push      bx                       ; koncov† pozice kurzoru
         inc       cx
         inc       cx
         push      cx                       ; koncovò ©†dek kurzoru
         mov       cl,2
         push      cx                       ; povel - zobrazen° kurzoru
         call      l_34F8                   ; vykreslen° okna (kurzoru)
         ret       

l_55C3   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_557A)
; -----------------------------------------------------------------------------

; ------ zobrazen° podkladu okna ASCII tabulky

l_55EC:  mov       ax,21                    ; á°slo n†povàdy - zvl†®tn° znaky
         push      ax
         call      l_4D50                   ; zobrazen° n†povàdy k volb†m

; ------ zobrazen° znakñ v ASCII tabulce

         mov       ax,"{"                   ; poá†teán° znak k zobrazen°
         mov       cx,1                     ; ukazatel ©†dku na displeji / 2
l_55F9:  mov       bx,18                    ; ukazatel pozice na displeji / 2

l_55FC:  push      ax
         push      bx
         push      cx

         push      ax                       ; znak
         shl       bx,1                     ; relativn° pozice * 2
         push      bx                       ; pozice
         shl       cx,1                     ; relativn° ©†dek * 2
         inc       cx
         push      cx                       ; ©†dek
         call      l_34C7                   ; vòstup znaku na displej

         pop       cx
         pop       bx
         pop       ax

         inc       ax                       ; zvò®en° ukazatele znaku
         inc       bx                       ; zvò®en° ukazatele pozice / 2
         cmp       bl,39                    ; je jië konec ©†dku ?
         jbe       l_55FC                   ; dal®° pozice na ©†dku

         inc       cx                       ; zvò®en° ukazatele ©†dku / 2
         cmp       cl,6                     ; je jië posledn° ©†dek ?
         jbe       l_55F9                   ; zobrazen° dal®°ho ©†dku

; ------ zobrazen° kurzoru

         mov       al,byte ptr ds:[d_E68F]  ; zadanò znak z ASCII tabulky
         or        ax,ax                    ; byl jië zadanò nàjakò znak ?
         jnz       l_5623                   ; byl jië zadanò nàjakò znak
         mov       al,"{"                   ; implicitn° znak na zaá†tku tab.
l_5623:  push      ax
         push      ax
         call      l_55C3                   ; zobrazen° kurzoru v ASCII tabulce
         call      l_5581                   ; zobrazen° á°sla aktivn°ho znaku

; ------ áek†n° na zad†n° kl†vesy

         push      ax
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         pop       bx
         push      bx
         push      ax
         mov       ax,bx
         call      l_55C3                   ; vypnut° kurzoru v ASCII tabulce
         pop       dx
         pop       ax

; ------ obsluha kl†vesy Ctrl-D (posun kurzoru o pozici vpravo)

         cmp       dl,CtrlD                 ; je kl†vesa Ctrl-D ?
         jne       l_5645                   ; nen° kl†vesa Ctrl-D
         cmp       al,254                   ; maxim†ln° pozice
         jae       l_5623                   ; je jië maxim†ln° pozice
         inc       ax                       ; zvò®en° pozice
         jmp       short l_5623

; ------ obsluha kl†vesy Ctrl-E (posun kurzoru o ©†dek nahoru)

l_5645:  cmp       dl,CtrlE                 ; je kl†vesa Ctrl-E ?
         jne       l_5652                   ; nen° kl†vesa Ctrl-E
         cmp       al,"ë"                   ; minim†ln° pozice
         jb        l_5623                   ; nelze jië posunout kurzor
         sub       al,22                    ; posun kurzoru o ©†dek nahoru
         jmp       short l_5623

; ------ obsluha kl†vesy Ctrl-S (posun kurzoru o pozici vpravo)

l_5652:  cmp       dl,CtrlS                 ; je kl†vesa Ctrl-S ?
         jne       l_565E                   ; nen° kl†vesa Ctrl-S
         cmp       al,"{"                   ; je jië minim†ln° znak ?
         jbe       l_5623                   ; je jië minim†ln° znak
         dec       ax                       ; posun kurzoru o pozici vlevo
         jmp       short l_5623

; ------ obsluha kl†vesy Ctrl-X (posun kurzoru o ©†dek dolñ)

l_565E:  cmp       dl,CtrlX                 ; je kl†vesa Ctrl-X ?
         jne       l_566B                   ; nen° kl†vesa Ctrl-X
         cmp       al,233                   ; maxim†ln° znak
         jae       l_5623                   ; je jië maxim†ln° znak
         add       al,22                    ; posun kurzoru o ©†dek dolñ
         jmp       short l_5623

; ------ obsluha kl†vesy Ctrl-Q (roz®°©enÇ povely)

l_566B:  cmp       dl,CtrlQ                 ; je kl†vesa Ctrl-Q ?
         jne       l_568F                   ; nen° kl†vesa Ctrl-Q
         push      ax
         push      ax
         call      l_5444                   ; vstup z kl†vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         mov       dl,al
         pop       ax

; ------ obsluha kl†vesy Ctrl-QS (zaá†tek ASCII tabulky)

         cmp       dl,"S"                   ; je zaá†tek okna Ctrl-QS ?
         jne       l_5686
         mov       al,"{"                   ; zaá†tek ASCII tabulky
         jmp       short l_5623

; ------ obsluha kl†vesy Ctrl-QD (konec ASCII tabulky)

l_5686:  cmp       dl,"D"                   ; je konec okna Ctrl-QD ?
         jne       l_5623
         mov       al,254                   ; posledn° znak v tabulce
         jmp       short l_5623

; ------ ukonáen° volby ENTER

l_568F:  cmp       dl,CR                    ; je konec volby ENTER ?
         jne       l_5699                   ; nen° ENTER
         mov       byte ptr ds:[d_E68F],al  ; zadanò znak z ASCII tabulky
         jmp       short l_56A5

; ------ p©eru®en° volby ESC

l_5699:  cmp       dl,ESCP                  ; je p©eru®en° volby ESC ?
         jne       l_5623
         mov       byte ptr ds:[d_F78A],1   ; 1=p©°znak p©eru®en° editace volby
         xor       ax,ax

; ------ vymaz†n° okna ASCII tabulky

l_56A5:  push      ax
         mov       ax,21                    ; okno volby ASCII tabulky
         push      ax
         call      l_4E5D                   ; n†vrat podkladu pod n†povàdou
         pop       ax
         mov       sp,bp
         pop       bp
         ret       2

l_557A   ENDP

; -----------------------------------------------------------------------------
;        (nepouëito)
; -----------------------------------------------------------------------------

l_56B4   PROC      NEAR

         ;jmp       l_56B7
         db        0e9h,0,0

l_56B7:  mov       ax,[bp+4]
         mov       sp,bp
         pop       bp
         ret       2

l_56B4   ENDP

; *****************************************************************************
;
;               Obsluha editace ©†dku textovÇho parametru
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        editace zad†n° textovÇho parametru
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) buffer k uloëen° textovÇho parametru
;        [SP+6] (2) maska povolenòch znakñ
;        [SP+8] (2) maxim†ln° dÇlka textu
;        [SP+10] (2) ©†dek na displeji
;        [SP+12] (2) poá†teán° pozice na displeji
; -----------------------------------------------------------------------------

l_56C0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_56C7
         db        0e9h,0,0

l_56C7:  dec       sp
         jmp       l_587F

; -----------------------------------------------------------------------------
;        zobrazen° editovanÇho ©†dku volby (ve stavovÇm ©†dku)
; -----------------------------------------------------------------------------
; VSTUP: ES:DI=textovò ©etàzec k zobrazen°
;        CX=poá†teán° pozice k zobrazen° textu
;        BX=offset poá†tku textu k zobrazen°
;        [BP+12] (2) ©†dek k zobrazen° textu
; -----------------------------------------------------------------------------

l_56CB   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

; ------ p©°prava registrñ k zobrazen° textu

         mov       dx,cx                    ; poá†teán° pozice k zobrazen° textu
         mov       cl,es:[di]               ; dÇlka textu k zobrazen°
         inc       cx                       ; + bajt dÇlky ©†dku
         sub       cx,bx                    ; zbylò poáet znakñ k zobrazen°
         jcxz      l_56F9                   ; nezbyl ë†dnò znak k zobrazen°
         mov       byte ptr ds:[d_FE56],b5  ; m¢d zobrazen° znaku - inverzn°
         add       bx,di                    ; adresa poá†tku textu k zobrazen°

; ------ zobrazen° textu

l_56E2:  push      bx
         push      cx
         push      dx
         push      es
         push      word ptr es:[bx]         ; znak k zobrazen°
         push      dx                       ; pozice
         ;push      word ptr [bp+0Ch]       ; ©†dek
         db        0FFh,0B6h,0Ch,0          ;!
         call      l_34C7                   ; vòstup znaku na displej
         pop       es
         pop       dx
         pop       cx
         pop       bx
         inc       bx                       ; zvò®en° ukazatele textu
         inc       dx                       ; zvò®en° pozice na ©†dku
         loop      l_56E2                   ; zobrazen° dal®°ho znakñ

; ------ vymaz†n° zbytku ©†dku

l_56F9:  ;mov       ax,[bp+0Ch]             ; ©†dek k zobrazen° textu
         db        8Bh,86h,0Ch,0            ;!
         mov       si,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         or        ax,ax                    ; je ©†dek 0 ?
         jz        l_570D                   ; je ©†dek 0
         ;mov       si,[bp+0Eh]
         db        8Bh,0B6h,0Eh,0           ;!
         ;add       si,[bp+0Ah]
         db        3,0B6h,0Ah,0             ;!
l_570D:  push      dx
         push      ax
         push      si
         push      ax
         mov       al,1                     ; m¢d - inverzn° okno
         push      ax
         call      l_34F8                   ; vykreslen° okna (kurzoru)

; ------ n†vrat registrñ

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_56CB   ENDP

; -----------------------------------------------------------------------------
;        zobrazen° kurzoru v editovanÇm ©†dku
; -----------------------------------------------------------------------------
; VSTUP: DX=pozice kurzoru na displeji
;        BX=offset poá†tku textu k zobrazen°
;        [BP+0Ch] (2) ©†dek k zobrazen° textu
; -----------------------------------------------------------------------------

l_571E   PROC      NEAR

         push      ax
         push      bx
         push      cx
         push      dx
         push      di
         push      es

         ;mov       ax,[bp+0Ch]             ; ©†dek k zobrazen° kurzoru
         db        8Bh,86h,0Ch,0            ;!
         push      dx                       ; poá†teán° pozice k zobraz. kurzoru
         push      ax                       ; poá†teán° ©†dek k zobraz. kurzoru
         push      dx                       ; koncov† pozice k zobraz. kurzoru
         push      ax                       ; koncovò ©†dek k zobraz. kurzoru
         mov       ax,2
         push      ax                       ; m¢d - kurzor
         call      l_34F8                   ; vykreslen° okna (kurzoru)

         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_571E   ENDP

; -----------------------------------------------------------------------------
;        stanoven° offsetu kurzoru v textu
; -----------------------------------------------------------------------------

l_573A   PROC      NEAR

         mov       ax,dx                    ; pozice kurzoru na displeji
         add       ax,bx                    ; p©iáten° offsetu poá†tku
         sub       ax,cx                    ; odeáten° poá†tku na displeji
         ret

l_573A   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-D (posun kurzoru o pozici vpravo)
; -----------------------------------------------------------------------------

l_5741   PROC      NEAR

         call      l_573A                   ; stanoven° offsetu kurzoru v textu
         cmp       al,es:[di]               ; je jië konec ©†dku ?
         ja        l_5759                   ; je jië konec ©†dku
         ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
         inc       dx                       ; zvò®en° pozice kurzoru na ©†dku
         cmp       dx,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         jbe       l_5759                   ; nen° je®tà konec ©†dku
         inc       bx                       ; zvò®en° poá†teán°ho offsetu ©†dku
         dec       dx                       ; n†vrat pozice kurzoru
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
l_5759:  ret

l_5741   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-S (posun kurzoru o pozici vlevo)
; -----------------------------------------------------------------------------

l_575A   PROC      NEAR

         call      l_573A                   ; stanoven° offsetu kurzoru v textu
         cmp       al,1                     ; je jië zaá†tek ©†dku ?
         jbe       l_576F                   ; je jië zaá†tek ©†dku
         ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
         dec       dx                       ; sn°ëen° pozice kurzoru na ©†dku
         cmp       dx,cx                    ; p©ekroáen poá†tek ©†dku ?
         jae       l_576F                   ; poá†tek ©†dku je®tà nep©ekroáen
         dec       bx                       ; sn°ëen° poá†teán°ho offsetu ©†dku
         inc       dx                       ; n†vrat pozice kurzoru
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
l_576F:  ret

l_575A   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-QS (zaá†tek ©†dku)
; -----------------------------------------------------------------------------

l_5770   PROC      NEAR

         mov       dx,cx                    ; kurzor na poá†tek ©†dku
         mov       bl,1                     ; poá†teán° offset ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
         ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
         ret

l_5770   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-QD (konec ©†dku)
; -----------------------------------------------------------------------------

l_577C   PROC      NEAR

         mov       ax,ds:[d_FDCD]           ; max. poáet znakñ na ©†dek displeje
         mov       dx,cx                    ; kurzor na poá†tek ©†dku
         add       dl,es:[di]               ; pozice konce ©†dku
         cmp       dx,ax                    ; p©ekroáen konec displeje ?
         jbe       l_5792                   ; konec displeje nep©ekroáen
         mov       bx,dx                    ; pozice konce ©†dku
         sub       bx,ax                    ; odeáten° pozice konce
         inc       bx                       ; offset poá†tku
         mov       dx,ax                    ; kurzor na konec displeje
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
l_5792:  ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
         ret

l_577C   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-G (zru®en° znaku za kurzorem)
; -----------------------------------------------------------------------------

l_5797   PROC      NEAR

; ------ kontrola, zda je kurzor za koncem textu

         call      l_573A                   ; stanoven° offsetu kurzoru v textu
         cmp       al,es:[di]               ; je kurzor za koncem textu ?
         ja        l_57BD                   ; kurzor je za koncem textu

         push      cx
         push      di
         push      ds

         push      es
         pop       ds                       ; DS <- segment bufferu s textem
         mov       cl,[di]                  ; dÇlka ©†dku
         sub       cl,al                    ; odeáten° kurzoru - zbytek za kurz.
         add       di,ax                    ; adresa kurzoru
         mov       si,di                    ; adresa kurzoru
         inc       si                       ; adresa dal®°ho znaku
         cld       
         repne     movsb                    ; p©°sun zbytku textu

         pop       ds
         pop       di
         pop       cx

         dec       byte ptr es:[di]         ; sn°ëen° dÇlky ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
         ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
l_57BD:  ret

l_5797   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-Y (zru®en° celÇho ©†dku)
; -----------------------------------------------------------------------------

l_57BE   PROC      NEAR

         mov       bx,1                     ; nov† pozice poá†tku ©†dku
         mov       es:[di],bh               ; zru®en° ©†dku <- 0
         mov       dx,cx                    ; nov† pozice kurzoru na ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
         ;mov       [bp-3],bh               ; 0=p©°znak zah†jen° editace ©†dku
         db        88h,0BEh,0FDh,0FFh       ;!
         ret

l_57BE   ENDP

; -----------------------------------------------------------------------------
;        naáten° pñvodn°ho obsahu ©†dku
; -----------------------------------------------------------------------------

l_57CE   PROC      NEAR

         push      cx
         push      di
         mov       si,offset d_F359         ; editaán° buffer zad†n° parametru
         mov       cl,[si]                  ; dÇlka pñvodn°ho obsahu bufferu
         inc       cx
         cld       
         repne     movsb                    ; n†vrat pñvodn°ho obsahu ©†dku
         pop       di
         pop       cx
         mov       bx,1                     ; offset poá†tku ©†dku
         mov       dx,cx                    ; kurzor na poá†tek ©†dku
         ret

l_57CE   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-\ (obsluha ASCII tabulky)
; -----------------------------------------------------------------------------

l_57E1   PROC      NEAR

         cmp       bh,byte ptr ds:[d_F790]  ; 1=povoleno zobrazen° menu
         je        l_5843                   ; nen° povoleno zobrazen° menu

         push      bx
         push      cx
         push      dx
         push      di
         push      es
         push      ax
         call      l_557A                   ; volba znaku pomoc° ASCII tabulky
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx
         mov       byte ptr ds:[d_F78A],bh  ; 1=p©°znak p©eru®en° editace volby
         or        ax,ax                    ; byl zad†n ASCII znak ?
         jz        l_5843
                                            ; vloëen° zadanÇho znaku do textu

l_57E1   ENDP

; -----------------------------------------------------------------------------
;        vloëen° znaku AL do textu
; -----------------------------------------------------------------------------

l_57FD   PROC      NEAR

         mov       ah,al                    ; znak k vloëen° do textu

; ------ test, zda je znak povolen

         push      bx                       ; offset poá†tku textu k zobrazen°
         mov       bx,offset l_3378         ; tabulka masek znakñ
         xlat      cs:[bx]                  ; maska typu znaku
         pop       bx
         ;test      al,[bp+8]               ; je povoleno vloëen° znaku ?
         db        84h,86h,8,0              ;!
         jz        l_5843                   ; vloëen° znaku nen° povoleno

; ------ zru®en° pñvodn°ho obsahu ©†dku, pokud nebyla editace je®tà zah†jena

         ;cmp       bh,[bp-3]               ; je zah†jena editace ©†dku ?
         db        3Ah,0BEh,0FDh,0FFh       ;!
         je        l_5815                   ; editace je jië zah†jena
         call      l_57BE                   ; zru®en° obsahu ©†dku

; ------ omezen° maxim†ln° dÇlky textu

l_5815:  mov       al,es:[di]               ; dÇlka textu
         ;cmp       al,[bp+0Ah]             ;
         db        3Ah,86h,0Ah,0            ;!
         jae       l_5843

; ------ vloëen° znaku do textu

         push      cx
         push      di
         push      ds
         push      ax
         push      es
         pop       ds
         call      l_573A                   ; stanoven° offsetu kurzoru v textu
         mov       cl,[di]                  ; dÇlka textu
         add       di,cx                    ; adresa konce textu
         mov       si,di                    ; konec textu
         inc       di                       ; n†sleduj°c° bajt
         sub       cx,ax                    ; zbytek dat za kurzorem
         inc       cx
         std       
         repne     movsb                    ; odsunut° zbytku textu
         pop       ax
         mov       [di],ah                  ; uloëen° zadanÇho znaku
         pop       ds
         pop       di
         pop       cx

         inc       byte ptr es:[di]         ; zvò®en° dÇlky ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
         call      l_5741                   ; posun kurzoru o pozici vpravo
l_5843:  ret

l_57FD   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-^ (text z bufferu do ©†dku)
; -----------------------------------------------------------------------------

l_5844   PROC      NEAR

         mov       si,offset d_EE59         ; buffer textu
         mov       ah,[si]                  ; dÇlka textu
         or        ah,ah                    ; je nàjakò text ?
         jz        l_585B                   ; nen° ë†dnò text
l_584D:  inc       si                       ; zvò®en° ukazatele textu
         mov       al,[si]                  ; znak ke vloëen°
         push      ax
         push      si
         call      l_57FD                   ; vloëen° znaku do textu ©†dku
         pop       si
         pop       ax
         dec       ah                       ; á°taá znakñ
         jnz       l_584D                   ; vloëen° dal®°ho znaku
l_585B:  ret

l_5844   ENDP

; -----------------------------------------------------------------------------
;        kl†vesa Ctrl-Q (roz®°©enÇ povely s Ctrl-Q)
; -----------------------------------------------------------------------------

l_585C   PROC      NEAR

; ------ vstup druhÇho znaku povelu

         push      bx
         push      cx
         push      dx
         push      di
         push      es
         push      ax
         call      l_5444                   ; vstup z kl†vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velkÇ p°smeno
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx

; ------ kl†vesa Ctrl-QS - zaá†tek ©†dku

         cmp       al,"S"
         jne       l_5877
         call      l_5770                   ; zaá†tek ©†dku
         ret

; ------ kl†vesa Ctrl-QD - konec ©†dku

l_5877:  cmp       al,"D"
         jne       l_587E
         call      l_577C                   ; konec ©†dku
l_587E:  ret

l_585C   ENDP

; -----------------------------------------------------------------------------
;        (pokraáov†n° procedury l_56C0)
; -----------------------------------------------------------------------------

l_587F:  ;les       di,dword ptr [bp+4]     ; adresa textovÇho ©etàzce
         db        0C4h,0BEh,4,0            ;!
         ;mov       cx,[bp+0Eh]             ; poá†teán° pozice na displeji
         db        8Bh,8Eh,0Eh,0            ;!
         ;mov       [bp-3],cl               ; 0=p©°znak zah†jen° editace
         db        88h,8Eh,0FDh,0FFh        ;!
         mov       byte ptr ds:[d_F78A],ch  ; 1=p©°znak p©eru®en° editace volby
         call      l_57CE                   ; naáten° pñvodn°ho obsahu ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby

; VSTUP: ES:DI=textovò ©etàzec k zobrazen°
;        BX=offset poá†tku textu k zobrazen°
;        CX=poá†teán° pozice k zobrazen° textu
;        DX=pozice kurzoru na displeji
;        [BP+0Ch] (2) ©†dek k zobrazen° textu

; ------ áek†n° na zad†n° znaku

l_5895:  call      l_571E                   ; zapnut° kurzoru v edit. ©†dku

         push      bx
         push      cx
         push      dx
         push      di
         push      es
         push      ax
         call      l_54DE                   ; vstup kl†vesy s áek†n°m+makro+tisk
         pop       es
         pop       di
         pop       dx
         pop       cx
         pop       bx

         call      l_571E                   ; vypnut° kurzoru v edit. ©†dku

; ------ kl†vesa Ctrl-D - posun kurzoru o pozici vpravo

         cmp       al,CtrlD                 ; je kurzor vpravo ?
         jne       l_58B2                   ; nen° kurzor vpravo
         call      l_5741                   ; posun kurzoru o pozici vpravo
         jmp       short l_5895             ; dal®° kl†vesa

; ------ kl†vesa Ctrl-S - posun kurzoru o pozici vlevo

l_58B2:  cmp       al,CtrlS                 ; je kurzor vlevo ?
         jne       l_58BB                   ; nen° kurzor vlevo
         call      l_575A                   ; posun kurzoru o pozici vlevo
         jmp       short l_5895             ; dal®° kl†vesa

; ------ kl†vesa Ctrl-G - zru®en° znaku za kurzorem

l_58BB:  cmp       al,CtrlG                 ; je kl†vesa Delete ?
         jne       l_58C4                   ; nen° kl†vesa Delete
l_58BF:  call      l_5797                   ; zru®en° znaku za kurzorem
         jmp       short l_5895

; ------ kl†vesa Ctrl-H - zru®en° znaku p©ed kurzorem

l_58C4:  cmp       al,CtrlH                 ; je kl†vesa Ctrl-H ?
         jne       l_58CD                   ; nen° kl†vesa Ctrl-H
         call      l_575A                   ; posun kurzoru o pozici vlevo
         jmp       short l_58BF             ; zru®en° znaku p©ed kurzorem

; ------ kl†vesa Ctrl-R - navr†cen° pñvodn°ho obsahu ©†dku

l_58CD:  cmp       al,CtrlR                 ; je kl†vesa Ctrl-R ?
         jne       l_58D9                   ; nen° kl†vesa Ctrl-R
         call      l_57CE                   ; navr†cen° pñvodn°ho obsahu ©†dku
         call      l_56CB                   ; zobrazen° editovanÇho ©†dku volby
         jmp       short l_5895

; ------ kl†vesa Ctrl-Y - vymaz†n° ©†dku

l_58D9:  cmp       al,CtrlY                 ; je kl†vesa Ctrl-Y ?
         jne       l_58E2                   ; nen° kl†vesa Ctrl-Y
         call      l_57BE                   ; zru®en° celÇho ©†dku
         jmp       short l_5895

; ------ kl†vesa Ctrl-Q - roz®°©enÇ povely

l_58E2:  cmp       al,CtrlQ                 ; je kl†vesa Ctrl-Q ?
         jne       l_58EB                   ; nen° kl†vesa Ctrl-Q
         call      l_585C                   ; obsluha povelñ s Ctrl-Q
         jmp       short l_5895

; ------ kl†vesa Ctrl-^ - text z bufferu do ©†dku

l_58EB:  cmp       al,1eh                   ; je kl†vesa Ctrl-^ ?
         jne       l_58F4                   ; nen° kl†vesa Ctrl-^
         call      l_5844                   ; text z bufferu do ©†dku
         jmp       short l_5895

; ------ kl†vesa Ctrl-\ - tabulka ASCII znakñ

l_58F4:  cmp       al,1Ch                   ; je kl†vesa Ctrl-\ ?
         jne       l_58FD                   ; nen° kl†vesa Ctrl-\
         call      l_57E1                   ; obsluha ASCII tabulky
         jmp       short l_5895

; ------ kl†vesa ENTER - ukonáen° editace

l_58FD:  cmp       al,CR                    ; je kl†vesa ENTER ?
         je        l_5912                   ; je kl†vesa ENTER]

; ------ kl†vesa ESC - p©eru®en° editace

         cmp       al,ESCP                  ; je kl†vesa ESC ?
         je        l_590A

; ------ jin† kl†vesa - vloëen° platnÇho znaku do textu

         call      l_57FD                   ; vloëen° znaku do textu
         jmp       short l_5895

; ------ p©i p©eru®en° ESC n†vrat pñvodn°ho obsahu ©†dku

l_590A:  call      l_57CE                   ; naáten° pñvodn°ho obsahu ©†dku
         mov       byte ptr ds:[d_F78A],1   ; 1=p©°znak p©eru®en° editace volby

; ------ kl†vesa ENTER - ukonáen° editace - uloëen° dÇlky textu

l_5912:  mov       ds:[d_F359],bh           ; editaán° buffer zad†n° parametru
         ;jmp       l_5919
         db        0e9h,0,0

l_5919:  mov       sp,bp
         pop       bp
         ret       0Ch

l_56C0   ENDP

; *****************************************************************************
;
;                  Obsluha navr†cen° provedenòch zmàn
;
; *****************************************************************************
;˛

; -----------------------------------------------------------------------------
;        nulov†n° bufferu £schovy zmàn
; -----------------------------------------------------------------------------

l_591F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5926
         db        0e9h,0,0

l_5926:  dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_F941]
         dec       ax
         push      ax
         mov       ax,0
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jle       l_5939
         ;jmp       l_5959
         db        0e9h
         dw        l_5959-$-2

l_5939:  dec       cx
         mov       [bp-4],ax
l_593D:  push      cx
         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_F7B1         ; buffer uschovanòch ©†dkñ k obnovà
         push      ds
         push      di
         call      l_39D4                   ; uvolnàn° ©†dku z pamàti
         pop       cx
         inc       cx
         jz        l_5959
         dec       word ptr [bp-4]
         ;jmp       l_593D
         db        0e9h
         dw        l_593D-$-2

l_5959:  mov       ax,0
         mov       word ptr ds:[d_F941],ax
         mov       ax,0
         mov       word ptr ds:[d_F943],ax
         mov       ax,0
         mov       byte ptr ds:[d_F945],al
         ;jmp       l_596E
         db        0e9h,0,0

l_596E:  mov       sp,bp
         pop       bp
         ret

l_591F   ENDP

; -----------------------------------------------------------------------------
;        £schova ©†dku k navr†cen° zmàn
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (2) m¢d 2=ru®en° ©†dkñ
; -----------------------------------------------------------------------------

l_5972   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5979
         db        0e9h,0,0

l_5979:  ;mov       dx,[bp+4]
         db        8Bh,96h,4,0              ;!
         mov       bx,word ptr ds:[d_F941]
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         cmp       bh,byte ptr ds:[d_F945]
         jne       l_599E
         cmp       ax,word ptr ds:[d_F943]
         jne       l_599E
         cmp       dl,1
         jne       l_59AA
         cmp       byte ptr ds:[d_F8F1+bx-1],2
         jne       l_59DB
         jmp       short l_59AA

l_599E:  push      ax
         push      dx
         call      l_591F                   ; nulov†n° bufferu £schovy zmàn
         pop       dx
         pop       ax
         mov       word ptr ds:[d_F943],ax
         xor       bx,bx
l_59AA:  cmp       bl,byte ptr cs:[l_326E]
         ja        l_59DB
         mov       byte ptr ds:[d_F8F1+bx],dl
         inc       bx
         mov       word ptr ds:[d_F941],bx
         dec       bx
         add       ax,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         cmp       dl,3
         jne       l_59C5
         inc       ax
l_59C5:  shl       ax,1
         shl       ax,1
         add       ax,offset d_0274         ; tabulka definic ©†dkñ
         push      ds
         push      ax
         shl       bx,1
         shl       bx,1
         add       bx,offset d_F7B1         ; buffer uschovanòch ©†dkñ k obnovà
         push      ds
         push      bx
         call      l_3C8D
l_59DB:  ;jmp       l_59DE
         db        0e9h,0,0

l_59DE:  mov       sp,bp
         pop       bp
         ret       2

l_5972   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QL a Maz†n°/obnoven° (navr†cen° provedenòch zmàn)
; -----------------------------------------------------------------------------

l_59E4   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_59EB
         db        0e9h,0,0

l_59EB:  mov       bx,word ptr ds:[d_F941]
         or        bx,bx
         jnz       l_59F6
         jmp       l_5A82

l_59F6:  push      bx
         call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         pop       bx
         dec       bx
         mov       cx,word ptr ds:[d_F943]
l_5A00:  xor       di,di
         mov       al,byte ptr ds:[d_F8F1+bx]
         cmp       al,2
         jae       l_5A14
         cmp       bh,byte ptr ds:[d_F945]
         je        l_5A37
         mov       di,bx
         jmp       short l_5A37

l_5A14:  push      bx
         push      cx
         mov       bl,1
         jnz       l_5A21
         push      cx
         push      bx
         call      l_3B6A
         jmp       short l_5A33

l_5A21:  inc       cx
         push      cx
         push      bx
         cmp       al,3
         jne       l_5A30
         call      l_3B6A
         mov       di,1
         jmp       short l_5A35

l_5A30:  call      l_3C04
l_5A33:  xor       di,di
l_5A35:  pop       cx
         pop       bx
l_5A37:  push      bx
         push      cx
         add       di,cx
         push      di
         push      di
         call      l_3A2E                   ; uvolnàn° ©†dku z pamàti
         pop       di
         pop       cx
         pop       bx
         add       di,word ptr ds:[d_F7A5]  ; poá†teán° ©†dek prostoru v tabulce
         shl       di,1
         shl       di,1
         add       di,offset d_0274         ; tabulka definic ©†dkñ
         mov       si,bx
         shl       si,1
         shl       si,1
         add       si,offset d_F7B1         ; buffer uschovanòch ©†dkñ k obnovà
         cld       
         push      ds
         pop       es
         movsw     
         movsw     
         dec       bx
         jns       l_5A00
         inc       bx
         mov       word ptr ds:[d_F943],bx
         mov       word ptr ds:[d_F941],bx
         push      cx                       ; poëadovanò ©†dek
         call      l_4CC6                   ; p©esun kurzoru na zadanò ©†dek
         mov       bx,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         dec       bx
         shl       bx,1
         mov       ax,word ptr ds:[d_E5E4+bx] ; tabulka zobrazenòch ©†dkñ
         cmp       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         jne       l_5A82
         call      l_4C6D                   ; obnoven° zobrazen° obrazovky
l_5A82:  ;jmp       l_5A85
         db        0e9h,0,0

l_5A85:  mov       sp,bp
         pop       bp
         ret

l_59E4   ENDP

; *****************************************************************************
;
;                    ChybovÇ hl†®en° programu
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        zobrazen° chybovÇho hl†®en°
; -----------------------------------------------------------------------------

l_5A89   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5A90
         db        0e9h,0,0

; ------ vymaz†n° horn°ho stavovÇho ©†dku

l_5A90:  sub       sp,82h
         call      l_43F3                   ; vymaz†n° horn°ho stavovÇho ©†dku

; ------ adresa tabulky chybovòch hl†®en°

         mov       bx,8                     ; funkce - adresa chybovÇho textu
         call      dword ptr ds:[d_FDC7]    ; adresa vstupn°ho bodu SCREEN.OVL
         mov       al,byte ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         xor       cx,cx
         mov       [bp-84h],cx              ; 0=p©°znak nalezen° hl†®en°

; ------ nalezen° poëadovanÇho chybovÇho hl†®en°

l_5AA7:  mov       ah,es:[si]               ; k¢d chyby hl†®en°
         or        ah,ah                    ; je konec tabulky ?
         jz        l_5ABB                   ; je konec tabulky
         cmp       al,ah                    ; je to hledan† chyba ?
         je        l_5ABF                   ; hledan† chyba nalezena
l_5AB2:  inc       si                       ; zaá†tek textu
         cmp       cl,es:[si]               ; nalezen konec textu ?
         jne       l_5AB2                   ; nalezen° konce textu ASCIIZ
         inc       si                       ; zaá†tek dal®° poloëky
         jmp       short l_5AA7             ; test dal®° poloëky
l_5ABB:  inc       byte ptr [bp-84h]        ; 1=p©°znak nenalezen° hl†®en°

; ------ p©enesen° textu hl†®en° do bufferu

l_5ABF:  push      bp
         lea       bp,[bp-83h]              ; buffer k uloëen° textu hl†®en°
         push      bp
l_5AC5:  inc       si
         inc       bp
         mov       al,es:[si]               ; znak textu
         or        al,al                    ; je konec textu ?
         jz        l_5AD4                   ; je konec textu
         mov       [bp],al                  ; uloëen° znaku do bufferu
         inc       cx                       ; á°taá dÇlky textu
         jmp       short l_5AC5             ; dal®° znak
l_5AD4:  pop       bp
         mov       [bp],cl                  ; dÇlka textu hl†®en°
         pop       bp

; ------ p©i chybà nedostatku pamàti ...

         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,5                     ; je nedostatek pamàti ?
         je        l_5AE4                   ; je nedostatek pamàti
         ;jmp       l_5AE7
         db        0e9h
         dw        l_5AE7-$-2
l_5AE4:  call      l_591F                   ; nulov†n° bufferu £schovy zmàn

; ------ p©i chybà nenalezen° textu se p©id† p©ed text hledanò text

l_5AE7:  mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,7                     ; text nenalezen ?
         je        l_5AF2                   ; text nenalezen
         ;jmp       l_5B19
         db        0e9h
         dw        l_5B19-$-2

l_5AF2:  lea       di,[bp-83h]              ; buffer s textem hl†®en°
         push      ss
         push      di
         mov       ax,'"'                   ; £vodn° znak uvozovek
         push      ax
         mov       di,offset d_F459         ; text k hled†n°                   i
         push      ds
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_1460
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
l_5B14:  mov       cl,80h
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.

; ------ p©i chybà nevyti®tàn° prostoru doplnàn° á°sla prostoru

l_5B19:  mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,17                    ; chyba - prostor nevyti®tàn ?
         je        l_5B24                   ; chyba - prostor nevyti®tàn
         ;jmp       l_5B2D
         db        0e9h
         dw        l_5B2D-$-2
l_5B24:  mov       ax,word ptr ds:[d_F98A]  ; á°slo ti®tànÇho prostoru
         add       ax,"0"                   ; korekce na znak ASCII
         mov       [bp-7Ah],al              ; á°slo tisknutÇho prostoru

; ------ test, je-li chyba 241 nebo 4 (nenalezen soubor nebo adres†©)

l_5B2D:  mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,241
         mov       ax,1
         jz        l_5B39
         dec       ax
l_5B39:  push      ax
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,4
         mov       ax,1
         jz        l_5B46
         dec       ax
l_5B46:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_5B50
         ;jmp       l_5B5E
         db        0e9h
         dw        l_5B5E-$-2

; ------ p©i chybà zad†n° jmÇna souboru nebo adres†©e doplnàn° tohoto jmÇna

l_5B50:  mov       di,offset d_E6FB         ; jmÇno editovanÇho souboru
         push      ds
         push      di
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        0

         mov       cl,80h
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.

; ------ p©i nezn†mÇ chybà dek¢dov†n° á°sla chyby

l_5B5E:  mov       al,[bp-84h]
         xor       ah,ah
         or        ax,ax
         jnz       l_5B6B
         ;jmp       l_5B8B
         db        0e9h
         dw        l_5B8B-$-2

l_5B6B:  lea       di,[bp-83h]
         push      ss
         push      di
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         sub       sp,9
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         push      ax
         call      l_36BB                   ; p©evod á°sla INTEGER na ©etàzec
         call      l_12DE                   ; seáten° textovòch ©etàzcñ
         mov       cl,80h
         call      l_11DC                   ; p©enesen° ©etàzce ze z†sob.do buf.

; ------ p©id†n° textu ": stiskni ESC"

l_5B8B:  mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen° ©etàzce DI do z†sobn°ku
         call      l_11C6                   ; uloëen° textu za CALL do z†sobn°ku

         db        13, ': stiskni ESC'

         call      l_12DE                   ; seáten° textovòch ©etàzcñ

; ------ zobrazen° textu chybovÇho hl†®en°

         mov       cl,0ffh
         call      l_121E                   ; zmàna dÇlky ©etàzce v z†sob. na CL
         call      l_43BF                   ; zobrazen° ©etàzce znakñ
         call      l_24E9                   ; nastaven° stand. vòstup. za©°zen°

; ------ p°pnut° p©i chybovÇm hl†®en°

         mov       ax,7
         push      ax
         mov       ax,0
         call      l_2819
         call      l_1003                   ; test, zda je nàjak† chyba programu
l_5BC7:  dec       sp
         call      l_550C                   ; áek†n° na potvrzen° hl†®en°
         jnz       l_5BD0
         ;jmp       l_5BC7
         db        0e9h
         dw        l_5BC7-$-2

; ------ zru®en° k¢du chyby

l_5BD0:  mov       ax,0
         mov       ds:[d_F79D],ax           ; zru®en° k¢du chyby KonTextu
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         ;jmp       l_5BDC
         db        0e9h,0,0

l_5BDC:  mov       sp,bp
         pop       bp
         ret

l_5A89   ENDP

; *****************************************************************************
;
;                   Z†kladn° operace s posuny kurzoru
;
; *****************************************************************************
;˛
; -----------------------------------------------------------------------------
;        rolov†n° textu nahoru nebo dolñ ([SP+2] (2) novò ©†dek na displeji)
; -----------------------------------------------------------------------------

l_5BE0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5BE7
         db        0e9h,0,0

; ------ rolov†n° obrazovky o ©†dek dolñ nebo nahoru

l_5BE7:  mov       ax,1
         push      ax                       ; poá†teán° pozice
         push      ax                       ; poá†teán° ©†dek
         push      word ptr ds:[d_FDCD]     ; koncov† pozice
         push      word ptr ds:[d_FDCF]     ; koncovò ©†dek
         ;cmp       ax,[bp+4]               ; je rolov†n° dolñ ?
         db        3Bh,86h,4,0              ;!
         jne       l_5C03                   ; nen° rolov†n° dolñ
         call      l_3589                   ; rolov†n° okna dolñ
         inc       word ptr ds:[d_E69C]     ; zvò®en° á°sla ©†dku kurzoru disp.
         jmp       short l_5C0A
l_5C03:  call      l_355B                   ; rolov†n° okna nahoru
         dec       word ptr ds:[d_E69C]     ; á°slo ©†dku kurzoru na obrazovce

; ------ nov† inicializace bufferu á°sel zobrazenòch ©†dkñ

l_5C0A:  call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ

; ------ zobrazen° novÇho ©†dku

         ;mov       cx,[bp+4]               ; á°slo novÇho ©†dku na displeji
         db        8Bh,8Eh,4,0              ;!
         mov       bx,cx                    ; poëadovanò ©†dek k zobrazen°
         dec       bx
         shl       bx,1
         mov       ax,word ptr ds:[d_E5E4+bx] ; tabulka zobrazenòch ©†dkñ
         or        ax,ax                    ; je p©elom str†nky ?
         jz        l_5C25                   ; je p©elom str†nky
         push      ax
         push      cx
         call      l_4978                   ; zobrazen° zadanÇho ©†dku
         jmp       short l_5C29

l_5C25:  push      cx                       ; ©†dek k zobrazen° p©elomu
         call      l_4A09                   ; zobrazen° p©elomu str†nky
l_5C29:  ;jmp       l_5C2C
         db        0e9h,0,0

l_5C2C:  mov       sp,bp
         pop       bp
         ret       2

l_5BE0   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek nahoru
; -----------------------------------------------------------------------------

l_5C32   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5C39
         db        0e9h,0,0

; ------ uloëen° obsahu editovanÇho ©†dku

l_5C39:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku

; ------ sn°ëen° á°sla aktivn°ho ©†dku

         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         cmp       ax,1                     ; je jië prvn° ©†dek ?
         jle       l_5C84                   ; je jië prvn° ©†dek
         dec       ax                       ; sn°ëen° á°sla aktivn°ho ©†dku
         mov       word ptr ds:[d_E698],ax  ; á°slo aktivn°ho editovanÇho ©†dku

; ------ sn°ëen° á°sla ©†dku na obrazovce

         mov       cx,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         cmp       ch,byte ptr cs:[l_3263]  ; zobraz. str†nk. (1=zap., 0=vyp.)
         je        l_5C5D                   ; nen° zobrazeno str†nkov†n°
         cwd       
         div       word ptr ds:[d_F7A9]     ; poáet ©†dkñ na str†nku bez okrajñ
         or        dx,dx
         jnz       l_5C5D
         dec       cx
l_5C5D:  dec       cx                       ; sn°ëen° ©†dku na obrazovce
         mov       word ptr ds:[d_E69C],cx  ; á°slo ©†dku kurzoru na obrazovce
         jg        l_5C84                   ; nen° podteáen° poá†tku obrazovky

; ------ p©i p©eteáen° horn°ho okraje obrazovky rolov†n° obrazovky dolñ

         mov       ax,1
         push      ax                       ; poá†teán° pozice
         jns       l_5C81                   ; bylo dosaëeno ©†dku 0
         mov       word ptr ds:[d_E69C],0   ; á°slo ©†dku kurzoru na obrazovce
         push      ax                       ; ©†dek k zobrazen° p©elomu
         push      ax
         push      ax
         push      word ptr ds:[d_FDCD]     ; max. poáet znakñ na ©†dek displeje
         push      word ptr ds:[d_FDCF]     ; poáet zobrazenòch textovòch ©†dkñ
         call      l_3589                   ; rolov†n° okna dolñ
         call      l_4A09                   ; zobrazen° p©elomu str†nky
l_5C81:  call      l_5BE0                   ; rolov†n° textu o ©†dek nahoru/dolñ
l_5C84:  ;jmp       l_5C87
         db        0e9h,0,0

l_5C87:  mov       sp,bp
         pop       bp
         ret

l_5C32   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-E (posun kurzoru o ©†dek nahoru)
; -----------------------------------------------------------------------------

l_5C8B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5C92
         db        0e9h,0,0

l_5C92:  call      l_5C32                   ; posun kurzoru o ©†dek nahoru
         call      l_555F                   ; vypr†zdnàn° bufferu kl†vesnice
         ;jmp       l_5C9B
         db        0e9h,0,0

l_5C9B:  mov       sp,bp
         pop       bp
         ret

l_5C8B   ENDP

; -----------------------------------------------------------------------------
;        posun kurzoru o ©†dek dolñ
; -----------------------------------------------------------------------------

l_5C9F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5CA6
         db        0e9h,0,0

l_5CA6:  call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         mov       bx,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         dec       bx
         cmp       ax,bx
         jae       l_5CE1
         inc       word ptr ds:[d_E698]     ; á°slo aktivn°ho editovanÇho ©†dku
         inc       word ptr ds:[d_E69C]     ; á°slo ©†dku kurzoru na obrazovce
         cmp       byte ptr cs:[l_3263],0   ; zobraz. str†nk. (1=zap., 0=vyp.)
         je        l_5CD2
         cwd       
         div       word ptr ds:[d_F7A9]     ; poáet ©†dkñ na str†nku bez okrajñ
         or        dx,dx
         jnz       l_5CD2
         inc       word ptr ds:[d_E69C]     ; á°slo ©†dku kurzoru na obrazovce
l_5CD2:  mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         cmp       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         ja        l_5CE1
         push      ax
         call      l_5BE0                   ; rolov†n° textu o ©†dek nahoru/dolñ
         jmp       short l_5CD2

l_5CE1:  ;jmp       l_5CE4
         db        0e9h,0,0

l_5CE4:  mov       sp,bp
         pop       bp
         ret

l_5C9F   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-X (posun kurzoru o ©†dek dolñ)
; -----------------------------------------------------------------------------

l_5CE8   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5CEF
         db        0e9h,0,0

l_5CEF:  call      l_5C9F                   ; posun kurzoru o ©†dek dolñ
         call      l_555F                   ; vypr†zdnàn° bufferu kl†vesnice
         ;jmp       l_5CF8
         db        0e9h,0,0

l_5CF8:  mov       sp,bp
         pop       bp
         ret

l_5CE8   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-W (rolov†n° obrazovky o ©†dek nahoru)
; -----------------------------------------------------------------------------

l_5CFC   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5D03
         db        0e9h,0,0

; ------ kontrola, zda je jië zobrazeno maxim†ln° á°slo ©†dku

l_5D03:  mov       ax,word ptr ds:[d_E69E]  ; maxim†ln° poáet ©†dkñ prostoru
         sub       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         push      ax
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         sub       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jle       l_5D1B
         ;jmp       l_5D1E
         db        0e9h
         dw        l_5D1E-$-2

l_5D1B:  ;jmp       l_5D33
         db        0e9h
         dw        l_5D33-$-2

; ------ posun kurzoru o ©†dek dolñ, je-li na horn°m okraji

l_5D1E:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         cmp       ax,1                     ; je prvn° ©†dek ?
         je        l_5D29                   ; je prvn° ©†dek - posun kurzoru
         ;jmp       l_5D2C
         db        0e9h
         dw        l_5D2C-$-2

l_5D29:  call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X

; ------ rolov†n° o ©†dek nahoru

l_5D2C:  mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         push      ax
         call      l_5BE0                   ; rolov†n° o ©†dek nahoru
l_5D33:  ;jmp       l_5D36
         db        0e9h,0,0

l_5D36:  mov       sp,bp
         pop       bp
         ret

l_5CFC   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-Z (rolov†n° obrazovky o ©†dek dolñ)
; -----------------------------------------------------------------------------

l_5D3A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5D41
         db        0e9h,0,0

; ------ kontrola, zda je jië zaá†tek souboru

l_5D41:  call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         mov       ax,word ptr ds:[d_E5E4]  ; tabulka zobrazenòch ©†dkñ
         cmp       ax,1                     ; je jië zobrazen zaá†tek souboru ?
         je        l_5D4F                   ; je jië zaá†tek souboru
         ;jmp       l_5D52
         db        0e9h
         dw        l_5D52-$-2

l_5D4F:  ;jmp       l_5D6D
         db        0e9h
         dw        l_5D6D-$-2

; ------ posun kurzoru nahoru, je-li na spodn°m okraji

l_5D52:  mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         push      ax
         mov       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         dec       ax                       ; maxim†ln° ©†dek na displeji
         pop       cx
         xchg      ax,cx
         cmp       ax,cx                    ; je kurzor na spodn°m okraji ?
         je        l_5D63                   ; kurzor je jië na spodn°m okraji
         ;jmp       l_5D66
         db        0e9h
         dw        l_5D66-$-2
l_5D63:  call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE

; ------ rolov†n° obrazovky o ©†dek dolñ

l_5D66:  mov       ax,1                     ; poáet ©†dkñ k rolov†n°
         push      ax
         call      l_5BE0                   ; rolov†n° textu o ©†dek dolñ
l_5D6D:  ;jmp       l_5D70
         db        0e9h,0,0

l_5D70:  mov       sp,bp
         pop       bp
         ret

l_5D3A   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-QS (p©esun kurzoru na zaá†tek ©†dku)
; -----------------------------------------------------------------------------

l_5D74   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5D7B
         db        0e9h,0,0

l_5D7B:  mov       ax,1                     ; pozice na zaá†tku ©†dku
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5D84
         db        0e9h,0,0

l_5D84:  mov       sp,bp
         pop       bp
         ret

l_5D74   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-S (kurzor o pozici vlevo)
; -----------------------------------------------------------------------------

l_5D88   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5D8F
         db        0e9h,0,0

l_5D8F:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       ax,1                     ; je jië zaá†tek ©†dku ?
         mov       ax,1
         jg        l_5D9F                   ; nen° zaá†tek ©†dku
         dec       ax
l_5D9F:  pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; sn°ëen° pozice kurzoru
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5DA9
         db        0e9h,0,0

l_5DA9:  mov       sp,bp
         pop       bp
         ret

l_5D88   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-D (posun kurzoru o pozici vpravo)
; -----------------------------------------------------------------------------

l_5DAD   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5DB4
         db        0e9h,0,0

l_5DB4:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         inc       ax                       ; zvò®en° pozice kurzoru na ©†dku
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5DBE
         db        0e9h,0,0

l_5DBE:  mov       sp,bp
         pop       bp
         ret

l_5DAD   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-QD (p©esun kurzoru na konec ©†dku)
; -----------------------------------------------------------------------------

l_5DC2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5DC9
         db        0e9h,0,0

l_5DC9:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         inc       ax                       ; pozice za koncem ©†dku
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5DDB
         db        0e9h,0,0

l_5DDB:  mov       sp,bp
         pop       bp
         ret

l_5DC2   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-F (posun kurzoru o slovo vpravo)
; -----------------------------------------------------------------------------

l_5DDF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5DE6
         db        0e9h,0,0

l_5DE6:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_5DFE
         ;jmp       l_5E0A
         db        0e9h
         dw        l_5E0A-$-2

l_5DFE:  call      l_5D74                   ; p©esun kurzoru na zaá†tek ©†dku
         call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         ;jmp       l_5E12
         db        0e9h
         dw        l_5E12-$-2

l_5E0A:  mov       di,offset d_E69A         ; pozice kurzoru na ©†dku
         push      ds
         push      di
         call      l_387D
l_5E12:  mov       di,offset d_E69A         ; pozice kurzoru na ©†dku
         push      ds
         push      di
         call      l_384B
         ;jmp       l_5E1D
         db        0e9h,0,0

l_5E1D:  mov       sp,bp
         pop       bp
         ret

l_5DDF   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-A (slovo vlevo)
; -----------------------------------------------------------------------------

l_5E21   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5E28
         db        0e9h,0,0

l_5E28:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_5E40
         ;jmp       l_5E4B
         db        0e9h
         dw        l_5E4B-$-2

l_5E40:  mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5E52
         db        0e9h
         dw        l_5E52-$-2

l_5E4B:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         dec       ax
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
l_5E52:  mov       di,offset d_E69A         ; pozice kurzoru na ©†dku
         push      ds
         push      di
         call      l_38AF

         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         cmp       ax,0
         je        l_5E65
         ;jmp       l_5E76
         db        0e9h
         dw        l_5E76-$-2

l_5E65:  call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5E7E
         db        0e9h
         dw        l_5E7E-$-2


l_5E76:  mov       di,offset d_E69A         ; pozice kurzoru na ©†dku
         push      ds
         push      di
         call      l_38DD
l_5E7E:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         inc       ax
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na ©†dku
         ;jmp       l_5E88
         db        0e9h,0,0

l_5E88:  mov       sp,bp
         pop       bp
         ret

l_5E21   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_5E8C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5E93
         db        0e9h,0,0

l_5E93:  mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         cmp       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         jbe       l_5EFB
         call      l_4A3C                   ; inic. bufferu á°sel zobraz. ©†dkñ
         xor       dx,dx
         mov       byte ptr ds:[d_E6A8],dl  ; 0=p©°znak modifikace textu
         mov       ax,word ptr ds:[d_E69C]  ; á°slo ©†dku kurzoru na obrazovce
         mov       bx,ax
         inc       ax
         shl       bx,1
         add       bx,offset d_E5E4         ; tabulka zobrazenòch ©†dkñ
         cmp       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         ja        l_5EBE
         cmp       dx,[bx]
         jne       l_5EBE
         inc       ax
         inc       bx
         inc       bx
l_5EBE:  cmp       ax,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         ja        l_5EFB
         mov       di,[bx]
         mov       cx,ax
l_5EC8:  cmp       cx,ds:[d_FDCF]           ; poáet zobrazenòch textovòch ©†dkñ
         jae       l_5ED7
         cmp       dx,[bx]
         je        l_5ED7
         inc       cx
         inc       bx
         inc       bx
         jmp       short l_5EC8

l_5ED7:  cmp       dx,[bx]
         jne       l_5EDE
         dec       cx
         dec       bx
         dec       bx
l_5EDE:  push      bx
         push      cx
         push      di
         push      ax
         inc       dx
         push      dx
         push      ax
         push      word ptr ds:[d_FDCD]     ; max. poáet znakñ na ©†dek displeje
         push      cx
         call      l_3589                   ; rolov†n° okna dolñ
         call      l_4978                   ; zobrazen° zadanÇho ©†dku
         xor       dx,dx
         pop       ax
         pop       bx
         inc       ax
         inc       ax
         add       bx,4
         jmp       short l_5EBE

l_5EFB:  ;jmp       l_5EFE
         db        0e9h,0,0

l_5EFE:  mov       sp,bp
         pop       bp
         ret

l_5E8C   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-N (vloëen° pr†zdnÇho ©†dku)
; -----------------------------------------------------------------------------

l_5F02   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5F09
         db        0e9h,0,0

l_5F09:  sub       sp,4
         mov       ax,4
         push      ax
         call      l_5972                   ; £schova ©†dku k navr†cen° zmàn
         mov       ax,word ptr ds:[d_E698]  ; á°slo aktivn°ho editovanÇho ©†dku
         inc       ax
         push      ax
         mov       ax,1
         push      ax
         call      l_3B6A
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_5F2A
         ;jmp       l_5F2D
         db        0e9h
         dw        l_5F2D-$-2

l_5F2A:  jmp       l_5FDF

l_5F2D:  call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,word ptr ds:[d_F7A3]  ; skuteánò poáet ©†dkñ prostoru
         inc       ax
         mov       [bp-4],ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jl        l_5F4D
         dec       ax
l_5F4D:  push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         dec       ax
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textovÇho ©†dku
         xor       ah,ah
         cmp       ax,0FFh
         mov       ax,1
         jz        l_5F62
         dec       ax
l_5F62:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_5F6C
         ;jmp       l_5F6F
         db        0e9h
         dw        l_5F6F-$-2

l_5F6C:  call      l_5D88                   ; kurzor o pozici vlevo
l_5F6F:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         call      l_390B                   ; rozdàlen° textovÇho ©†dku
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na ©†dku
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim†ln° dÇlka ©†dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         mov       ax,1
         mov       [bp-6],ax
         lea       di,[bp-6]
         push      ss
         push      di
         call      l_384B
         call      l_4897                   ; uloëen° obsahu editovanÇho ©†dku
         call      l_5E8C
         call      l_5CE8                   ; posun kurzoru o ©†dek dolñ Ctrl-X
         call      l_48CB                   ; dek¢dov†n° ©†dku do text. bufferu
         mov       al,byte ptr cs:[l_3261]  ; auto-tabel†tor (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_5FAB
         ;jmp       l_5FBF
         db        0e9h
         dw        l_5FBF-$-2

l_5FAB:  mov       ax,[bp-6]
         dec       ax
         mov       byte ptr ds:[d_EC59],al  ; dÇlka textovÇho ©†dku
         mov       ax,1
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         push      ax
         call      l_372A
l_5FBF:  mov       ax,1
         push      ax
         call      l_3950                   ; spojen° textovòch ©†dkñ
         call      l_4855                   ; korekce editovanÇho ©†dku
         mov       ax,1
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; dÇlka textovÇho ©†dku
         xor       ah,ah
         push      ax
         call      l_4832                   ; zobrazen° aktivn°ho edit. ©†dku
         mov       ax,[bp-4]
         mov       word ptr ds:[d_F7A3],ax  ; skuteánò poáet ©†dkñ prostoru
         call      l_5C8B                   ; posun kurzoru o ©†dek nahoru CtrlE
l_5FDF:  ;jmp       l_5FE2
         db        0e9h,0,0

l_5FE2:  mov       sp,bp
         pop       bp
         ret

l_5F02   ENDP

; -----------------------------------------------------------------------------
;        obsluha povelu Ctrl-V (zmàna p©°znaku INSERT)
; -----------------------------------------------------------------------------

l_5FE6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_5FED
         db        0e9h,0,0

l_5FED:  mov       al,byte ptr cs:[l_3267]  ; p©°znak INSERT (1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         mov       byte ptr cs:[l_3267],al  ; p©°znak INSERT (1=zap., 0=vyp.)
         call      l_44E7                   ; zobrazen° horn°ho stavovÇho ©†dku
         ;jmp       l_5FFF
         db        0e9h,0,0

l_5FFF:  mov       sp,bp
         pop       bp
         ret

l_5FE6   ENDP

Code     ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                            Datovò segment
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT BYTE PUBLIC

Data     ENDS
         END

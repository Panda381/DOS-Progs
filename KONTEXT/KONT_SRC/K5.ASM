
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; *****************************************************************************
;
;                       Obsluha spu¨tˆn¡ programu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        start programu
; -----------------------------------------------------------------------------

l_8062   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_81FB
         db        0e9h
         dw        l_81FB-$-2


l_8069   dw        0                        ; £schova SS p©i startu programu
l_806B   dw        0                        ; £schova SP p©i startu programu

; ------ prvn¡ FCB ke spu¨tˆn¡ programu

l_806D   db        12 dup (0)

; ------ druh˜ FCB ke spu¨tˆn¡ programu

l_8079   db        12 dup (0)

; ------ blok parametr– ke spu¨tˆn¡ programu

l_8085   dw        0                        ; adresa segmentu ©etˆzc– prost©ed¡
l_8087   dd        0                        ; adresa p©¡kazov‚ho © dku
l_808B   dd        0                        ; adresa prvn¡ho FCB
l_808F   dd        0                        ; adresa druh‚ho FCB

; -----------------------------------------------------------------------------
;        ulo‘en¡ obsahu pamˆti
; -----------------------------------------------------------------------------

l_8093   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_80D1
         db        0e9h
         dw        l_80D1-$-2

; -----------------------------------------------------------------------------
;        £schova obsahu © dku
; -----------------------------------------------------------------------------

l_809F   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         push      word ptr [bp-4]
         mov       bp,ax
         push      bp
         ;jmp       l_80AE
         db        0e9h,0,0

; ------ £schova obsahu © dku

l_80AE:  les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_3EB2                   ; na‡ten¡ textu © dku do bufferu
         les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_3D53                   ; ulo‘en¡ © dku do souboru
         ;jmp       l_80CB
         db        0e9h,0,0

l_80CB:  mov       sp,bp
         pop       bp
         ret       4

l_809F   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_8093)
; -----------------------------------------------------------------------------

; ------ zobrazen¡ hl ¨en¡, ‘e se ukl d  obsah pamˆti na disk

l_80D1:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        46,'PamˆŸ se ukl d  na disk - pros¡m ‡ekejte .....'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ ulo‘en¡ obsahu pamˆti do souboru

         mov       ax,1
         push      ax
         mov       ax,MAXLINES
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jnl       l_8126
         ;jmp       l_8152
         db        0e9h
         dw        l_8152-$-2

l_8126:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-0ah],ax
l_812E:  push      cx
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ah]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_809F                   ; £schova obsahu editovan‚ho © dku
         pop       cx
         dec       cx
         jz        l_8152
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-0Ah]
         ;jmp       l_812E
         db        0e9h
         dw        l_812E-$-2

l_8152:  mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru
         mov       ax,1
         push      ax
         mov       ax,5
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_8169
         jmp       l_81ED

l_8169:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-0Ah],ax
l_8171:  push      cx
         mov       ax,1
         push      ax
         mov       ax,0Ah
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_8182
         ;jmp       l_81DF
         db        0e9h
         dw        l_81DF-$-2

l_8182:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-0Ch],ax
l_818A:  push      cx
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ah]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ch]
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,offset d_E6A6+1       ; maxim ln¡ d‚lka © dku od L okraje
         push      ds
         push      di
         call      l_809F                   ; £schova obsahu editovan‚ho © dku
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ah]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ch]
         shl       ax,1
         shl       ax,1
         add       di,ax
         add       di,offset d_E6D3 - 4     ; adresy © dk– paty
         push      ds
         push      di
         call      l_809F                   ; £schova obsahu editovan‚ho © dku
         pop       cx
         dec       cx
         jz        l_81DF
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-0Ch]
         ;jmp       l_818A
         db        0e9h
         dw        l_818A-$-2

l_81DF:  pop       cx
         dec       cx
         jz        l_81ED
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-0Ah]
         ;jmp       l_8171
         db        0e9h
         dw        l_8171-$-2

l_81ED:  mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_4053                   ; n vrat parametr– prostoru
         ;jmp       l_81F7
         db        0e9h,0,0

l_81F7:  mov       sp,bp
         pop       bp
         ret       

l_8093   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_8062)
; -----------------------------------------------------------------------------

l_81FB:  sub       sp,0Ah
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         les       di,dword ptr [bp+6]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

         mov       ax," "*HI + 1
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         mov       [bp-8],ax
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,[bp-8]
         cmp       ax,0
         jg        l_823C
         ;jmp       l_8267
         db        0e9h
         dw        l_8267-$-2

l_823C:  mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,[bp-8]
         inc       ax
         push      ax
         mov       ax,0ffh
         call      l_1320
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,[bp-8]
         dec       ax
         mov       ds:[d_EC59],al           ; d‚lka textov‚ho © dku
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_367B                   ; o©ez n¡ ©et. od mezer z obou stran
l_8267:  mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         mov       di,offset d_F76E
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         cmp       ax,3
         jg        l_828F
         ;jmp       l_82B4
         db        0e9h
         dw        l_82B4-$-2

l_828F:  mov       di,offset d_F76E
         push      ds
         push      di
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         sub       ax,2
         push      ax
         mov       ax,3
         call      l_1320
         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_82B4:  mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        3,'COM'

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        3,'EXE'

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_82E1
         ;jmp       l_82ED
         db        0e9h
         dw        l_82ED-$-2

l_82E1:  mov       ax,15h
         mov       ds:[d_F79D],ax           ; k¢d chyby KonTextu
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         jmp       l_850B

l_82ED:  mov       ax,2501h
         push      ax
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_136C
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,0
         jg        l_8309
         ;jmp       l_833F
         db        0e9h
         dw        l_833F-$-2

l_8309:  mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         mov       ax,[bp-8]
         push      ax
         mov       ax,1
         call      l_1408                   ; vyjmut¡ cesty z ozna‡en¡ souboru
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         jnz       l_832B
         ;jmp       l_833F
         db        0e9h
         dw        l_833F-$-2

l_832B:  mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         mov       ax,[bp-8]
         mov       cl,0ffh
         call      l_13B0

l_833F:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         inc       ax
         xchg      ax,di
         mov       ax,0
         mov       byte ptr ds:[d_EC59+di],al ; buffer textov‚ho © dku
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         inc       ax
         xchg      ax,di
         mov       ax,0Dh
         mov       byte ptr ds:[d_ED59+di],al ; buffer atribut– znak– text. © dku
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         call      l_07BE                   ; sou‡et velikosti voln‚ pamˆti
         mov       [bp-8],ax
         jmp       short l_83A0

; -----------------------------------------------------------------------------
;        spu¨tˆn¡ programu
; -----------------------------------------------------------------------------

l_836B   PROC      NEAR

; ------ start programu

         mov       dx,offset d_EC59         ; zadan‚ jm‚no programu
         inc       dx
         mov       ax,cs
         mov       es,ax                    ; ES <- CS
         mov       bx,offset l_8085         ; blok parametr– programu
         mov       ax,4B00h                 ; funkce spu¨tˆn¡ programu
         push      bp
         mov       cs:[l_8069],ss           ; £schova SS p©i startu programu
         mov       cs:[l_806B],sp           ; £schova SP p©i startu programu
         int       21h                      ; start programu

; ------ n vrat ukazatele z sobn¡ku

         cli
         mov       sp,cs:[l_806B]           ; £schova SP p©i startu programu
         mov       ss,cs:[l_8069]           ; £schova SS p©i startu programu
         sti       
         pop       bp

; ------ n vratov˜ k¢d chyby

         mov       dx,0
         jnc       l_839F
         mov       bx,offset l_34B3         ; tabulka pro konverzi chyb DOS
         xlat      cs:[bx]
         mov       dl,al
l_839F:  ret

l_836B   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_8062)
; -----------------------------------------------------------------------------

; ------ odinstalov n¡ programu

l_83A0:  mov       ax,ss
         mov       bx,sp
         mov       cl,4
         shr       bx,cl
         add       ax,bx
         sub       ax,word ptr ds:[d_018A+2]; adresa za‡ tku voln‚ pamˆti
         ;sub       ax,[bp-8]
         db        2Bh,86h,0F8h,0FFh        ;!
         sub       ax,11h
         neg       ax
         cmp       ax,80h
         jb        l_83BF
         call      l_8093                   ; ulo‘en¡ obsahu pamˆti
l_83BF:  call      l_361C                   ; nastaven¡ textov‚ho m¢du displeje
         call      l_6445                   ; odinstalov n¡ obsluhy INT 24h

; ------ p©¡prava bloku parametr– ke spu¨tˆn¡ programu

         push      ds
         mov       bx,ds                    ; £schova DS
         mov       ax,cs
         mov       ds,ax                    ; DS <- CS
         mov       es,ax                    ; ES <- CS
         cld       
         mov       di,offset l_8085         ; blok parametr– ke spu¨tˆn¡ programu
         xor       ax,ax
         stosw                              ; segment ©etˆzce prost©ed¡
         mov       ax,offset d_ED59         ; buffer atribut– znak– text. © dku
         stosw                              ; adresa p©¡kazov‚ho © dku
         mov       ax,bx
         stosw                              ; DS
         mov       ax,offset l_806D
         stosw                              ; prvn¡ FCB
         mov       ax,cs
         stosw                              ; CS
         mov       ax,offset l_8079
         stosw                              ; druh˜ FCB
         mov       ax,cs
         stosw                              ; CS

; ------ kopie prvn¡ho FCB z PSP

         mov       si,5Ch                   ; adresa FCB 1
         mov       di,offset l_806D
         mov       cx,6
         repne     movsw                    ; kopie FCB 1

; ------ kopie druh‚ho FCB z PSP

         mov       si,6Ch                   ; adresa FBC 2
         mov       di,offset l_8079
         mov       cl,6
         repne     movsw                    ; kopie FCB 2

         mov       ds,bx                    ; n vrat DS

; ------ zmen¨en¡ pamˆŸov‚ho bloku na minimum

         mov       bx,ds:[d_F7AB]           ; uschovan˜ ukazatel z sobn¡ku SP
         mov       cl,4
         shr       bx,cl
         or        bx,bx
         jnz       l_840F
         mov       bh,10h
l_840F:  mov       cx,ss
         add       cx,bx
         sub       cx,ax
         mov       bx,word ptr ds:[d_018A+2]; adresa za‡ tku voln‚ pamˆti
         sub       bx,ax
         add       bx,80h
         ;mov       [bp-4],cx
         db        89h,8Eh,0FCh,0FFh        ;!
         ;mov       [bp-6],bx
         db        89h,9Eh,0FAh,0FFh        ;!
         mov       dx,5
         sub       cx,bx
         jbe       l_8489
         mov       ah,4Ah
         push      bp
         push      cx
         int       21h                      ; zmen¨en¡ bloku programu
         pop       dx
         pop       bp

; ------ p©esun z sobn¡ku dol–

         mov       cx,ds:[d_F7AB]           ; uschovan˜ ukazatel z sobn¡ku SP
         sub       cx,sp
         mov       ax,ss
         mov       ds,ax
         mov       si,sp
         sub       ax,dx
         mov       es,ax
         mov       di,sp
         cld       
         repne     movsb
         mov       ss,ax
         pop       ds

; ------ spu¨tˆn¡ programu

         push      ds
         call      l_836B                   ; spu¨tˆn¡ programu
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!

; ------ n vrat velikosti pamˆŸov‚ho bloku

l_8456:  mov       ax,cs
         mov       es,ax
         mov       ah,4Ah
         push      bx
         push      dx
         push      bp
         int       21h
         pop       bp
         pop       dx
         pop       di
         jc        l_8456                   ; p©i chybˆ opakov n¡ s men¨¡m BX
         pop       ds

; ------ n vrat obsahu z sobn¡ku

         push      ds
         mov       cx,ds:[d_F7AB]           ; uschovan˜ ukazatel z sobn¡ku SP
         sub       cx,sp
         mov       ax,ss
         mov       ds,ax
         mov       si,sp
         ;sub       ax,[bp-6]
         db        2Bh,86h,0FAh,0FFh        ;!
         add       ax,di
         mov       es,ax
         mov       di,sp
         add       si,cx
         dec       si
         add       di,cx
         dec       di
         std       
         repne     movsb
         mov       ss,ax
l_8489:  pop       ds

         mov       ds:[d_F79D],dx           ; k¢d chyby KonTextu
         mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_849A
         ;jmp       l_84E4
         db        0e9h
         dw        l_84E4-$-2

; ------ v˜zva ke stisku kl vesy

l_849A:  call      l_24E9                   ; nastaven¡ stand. v˜stup. za©¡zen¡
         call      l_28F1                   ; od© dkov n¡ textu DOS
         call      l_1003                   ; test, zda je nˆjak  chyba programu
         call      l_24E9                   ; nastaven¡ stand. v˜stup. za©¡zen¡
         call      l_28D9                   ; zobrazen¡ textov‚ho ©etˆzce DOS
         db        47,'N vrat do KonTextu stiskem libovoln‚ kl vesy...'

; ------ ‡ek n¡ na stisk kl vesy

         call      l_1003                   ; test, zda je nˆjak  chyba programu
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         mov       [bp-0ch],ax

; ------ obnoven¡ zobrazen¡ displeje

l_84E4:  call      l_6419                   ; instalace obsluhy INT 24h
         mov       ax,0
         mov       byte ptr ds:[d_ED59],al  ; buffer atribut– znak– text. © dku
         mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3274]  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         call      l_35CE                   ; inicializace displeje
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_850B:  ;jmp       l_850E
         db        0e9h,0,0

l_850E:  mov       sp,bp
         pop       bp
         ret       6

l_8062   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KX (start programu)
; -----------------------------------------------------------------------------

l_8514   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_851B
         db        0e9h,0,0

l_851B:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       di,offset d_F6DE         ; jm‚no startovan‚ho programu
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        23,'Jm‚no startov. programu'

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         mov       di,offset d_F6DE         ; jm‚no startovan‚ho programu
l_854F:  push      ds
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_8560
         ;jmp       l_8566
         db        0e9h
         dw        l_8566-$-2

l_8560:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ;jmp       l_857A
         db        0e9h
         dw        l_857A-$-2

l_8566:  mov       di,offset d_F6DE         ; jm‚no startovan‚ho programu
         push      ds
         push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         mov       di,offset d_F6DE         ; jm‚no startovan‚ho programu
         push      ds
         push      di
         mov       ax,1
         push      ax
         call      l_8062                   ; start programu
l_857A:  ;jmp       l_857D
         db        0e9h,0,0

l_857D:  mov       sp,bp
         pop       bp
         ret       

l_8514   ENDP

; *****************************************************************************
;
;                   Obsluha volby souboru ze seznamu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        zobrazen¡ v˜zvy k v˜bˆru souboru nebo volbˆ disku
; -----------------------------------------------------------------------------

l_8581   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_8588
         db        0e9h,0,0

; ------ rozli¨en¡, zda se prov d¡ v˜bˆr souboru

l_8588:  mov       ax,0
         mov       byte ptr ds:[d_FE56],al  ; m¢d zobrazen¡ znaku - bˆ‘n˜
         mov       al,ds:[d_F971]           ; 1=prov d¡ se v˜bˆr souboru
         xor       ah,ah
         or        ax,ax                    ; prov d¡ se v˜bˆr souboru ?
         jnz       l_859A
         ;jmp       l_85D6
         db        0e9h
         dw        l_85D6-$-2

; ------ zobrazen¡ hl ¨en¡ k v˜bˆru soubor–

l_859A:  mov       ax,0Bh
         push      ax
         mov       ax,2
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        37,' Zvolte kurzorov˜mi kl v. a <Enter>  '

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         ;jmp       l_860F
         db        0e9h
         dw        l_860F-$-2

; ------ zobrazen¡ hl ¨en¡ k v˜bˆru disku

l_85D6:  mov       ax,0Bh
         push      ax
         mov       ax,2
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        37,'     Zmˆna disku kl vesami A...K     '

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
l_860F:  mov       ax,20h
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - inverzn¡
         ;jmp       l_8618
         db        0e9h,0,0

l_8618:  mov       sp,bp
         pop       bp
         ret       

l_8581   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ seznamu soubor–
; -----------------------------------------------------------------------------

l_861C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_8623
         db        0e9h,0,0

l_8623:  jmp       short l_8633

; -----------------------------------------------------------------------------
;        zobrazen¡ znaku AL na pozici DX, © dek BX
; -----------------------------------------------------------------------------

l_8625   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      ax                       ; znak
         push      dx                       ; pozice
         push      bx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       dx
         pop       cx
         pop       bx
         inc       dx
         ret       

l_8625   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_861C)
; -----------------------------------------------------------------------------

; ------ p©¡prava ukazatel–

l_8633:  mov       ax,word ptr ds:[d_F978]  ; po‡ te‡n¡ zobraz. polo‘ka seznamu
         mov       bx,3                     ; ukazatel po‡ te‡n¡ho © dku
l_8639:  mov       dx,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         dec       dx                       ; maxim ln¡ © dek
         cmp       bx,dx                    ; je ji‘ maxim ln¡ © dek ?
         ja        l_8691                   ; je ji‘ konec seznamu
         xor       dx,dx                    ; DL = ‡¡ta‡ polo‘ek na © dku

; ------ v˜po‡et pozice na © dku

l_8644:  push      ax
         push      dx
         xchg      ax,dx
         mov       cx,14                    ; po‡et pozic na polo‘ku
         mul       cl
         inc       ax
         inc       ax                       ; po‡ te‡n¡ pozice
         xchg      ax,dx                    ; DX <- pozice k zobrazen¡ polo‘ky
         cmp       ax,word ptr ds:[d_F97C]  ; po‡et polo‘ek v seznamu soubor–
         ja        l_867E                   ; neplatn  polo‘ka

; ------ adresa polo‘ky k zobrazen¡

         mov       cl,23                    ; d‚lka jedn‚ polo‘kyu v seznamu
         dec       ax                       ; ‡¡slo polo‘ky k zobrazen¡
         mul       cl                       ; offset polo‘ky v seznamu
         add       ax,offset d_CD98         ; adresa polo‘ky v seznamu
         mov       si,ax                    ; asresa polo‘ky v seznamu
         mov       cl,[si]                  ; d‚lka jm‚na polo‘ky

; ------ zobrazen¡ jm‚na polo‘ky

         push      si
l_8662:  inc       si
         mov       al,[si]                  ; znak k zobrazen¡
         push      si
         call      l_8625                   ; zobrazen¡ znaku AL/poz. DX/© d. BX
         pop       si
         loop      l_8662
         pop       si

; ------ zobrazen¡ ozna‡en¡ adres ©e "\"

         mov       cl,14                    ; po‡et pozic na polo‘ku
         sub       cl,[si]                  ; zbyl˜ po‡et pozic
         cmp       ch,[si+1]                ; je to adres © ?
         jne       l_867E                   ; nen¡ to adres ©
         mov       al,"\"
         call      l_8625                   ; zobrazen¡ znaku AL/poz. DX/© d. BX
         dec       cx                       ; sn¡‘en¡ d‚lky zbytku polo‘ky
         jz        l_8685

; ------ zobrazen¡ mezer do konce pole pro polo‘ku

l_867E:  mov       al," "
         call      l_8625                   ; zobrazen¡ znaku AL/poz. DX/© d. BX
         loop      l_867E

; ------ p©¡prava pro dal¨¡ polo‘ku

l_8685:  pop       dx
         pop       ax
         inc       ax
         inc       dx                       ; zv˜¨en¡ ‡¡ta‡e polo‘ek na © dku
         cmp       dl,3                     ; jsou ji‘ 4 polo‘ky na © dku ?
         jbe       l_8644                   ; nejsou je¨tˆ 4 polo‘ky na © dku
         inc       bx                       ; zv˜¨en¡ ukazatele © dku
         jmp       short l_8639             ; zobrazen¡ dal¨¡ho © dku

l_8691:  ;jmp       l_8694
         db        0e9h,0,0

l_8694:  mov       sp,bp
         pop       bp
         ret       

l_861C   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ a zobrazen¡ seznamu soubor–
; -----------------------------------------------------------------------------

l_8698   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_869F
         db        0e9h,0,0

; ------ na‡ten¡ seznamu soubor– aktivn¡ho adres ©e

l_869F:  sub       sp,17h
         mov       ax,1
         mov       word ptr ds:[d_F978],ax  ; po‡ te‡n¡ zobraz. polo‘ka seznamu
         mov       ax,1
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
         mov       di,offset d_F97C         ; po‡et polo‘ek v seznamu soubor–
         push      ds
         push      di
         call      l_652C                   ; na‡ten¡ seznamu soubor– adres ©e

; ------ p©i diskov‚ chybˆ konec

         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         push      ax
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,100                   ; chyba - disk nepracuje
         mov       ax,1
         jz        l_86C7
         dec       ax
l_86C7:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_86D1
         ;jmp       l_86F6
         db        0e9h
         dw        l_86F6-$-2


l_86D1:  mov       ax,0
         mov       word ptr ds:[d_F97C],ax  ; po‡et polo‘ek v seznamu soubor–
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         lea       di,[bp-0ah]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
         ;jmp       l_8755
         db        0e9h
         dw        l_8755-$-2

; ------ na‡ten¡ aktivn¡ho adres ©e

l_86F6:  mov       ax,0
         push      ax
         mov       di,offset d_F059         ; buffer k na‡ten¡ aktiv. adres ©e
         push      ds
         mov       cl,0FFh
         call      l_2C0F                   ; poskytnut¡ aktiv. disku a adres ©e
         call      l_0FFC
         mov       [bp-4],ax

; ------ poskytnut¡ voln‚ho m¡sta aktivn¡ho disku

         mov       ax,0
         mov       byte ptr ds:[d_0266],al  ; registr DL pro vol n¡ INT 21h
         mov       ax,36h
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         mov       ax,ds:[d_0260]           ; registr AX - sektor– na blok
         cmp       ax,0FFFFh                ; je disk platn˜ ?
         je        l_8721                   ; neplatn˜ disk
         ;jmp       l_8732
         db        0e9h
         dw        l_8732-$-2

l_8721:  lea       di,[bp-0Ah]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
         ;jmp       l_8755
         db        0e9h
         dw        l_8755-$-2

l_8732:  lea       di,[bp-0Ah]
         push      ss
         push      di
         mov       ax,ds:[d_0262]           ; registr BX pro vol n¡ INT 21h
         call      l_1B0C
         call      l_1A97
         mov       ax,ds:[d_0260]           ; registr AX pro vol n¡ INT 21h
         call      l_1B0C
         call      l_19AD
         mov       ax,ds:[d_0264]           ; registr CX pro vol n¡ INT 21h
         call      l_1B0C
         call      l_19AD
         call      l_1970
l_8755:  mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,32h
         jg        l_8762
         ;jmp       l_8768
         db        0e9h
         dw        l_8768-$-2

l_8762:  mov       ax,32h
         mov       ds:[d_F059],al

; ------ stanoven¡ maxim ln¡ho © dku k zobrazen¡ seznamu

l_8768:  mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         mov       [bp-4],ax                ; maxim ln¡ © dek star‚ho seznamu
         mov       ax,word ptr ds:[d_F97C]  ; po‡et polo‘ek v seznamu soubor–
         dec       ax
         mov       cx,4                     ; po‡et polo‘ek na © dek
         cwd
         idiv      cx                       ; v˜po‡et celkov‚ho po‡tu polo‘ek
         add       ax,4                     ; posledn¡ © dek
         mov       word ptr ds:[d_F976],ax  ; maxim. © dek k zobrazen¡ seznamu
         mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         cmp       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         jg        l_878A                   ; je vˆt¨¡ ne‘ posledn¡ zobr. © dek
         ;jmp       l_8790
         db        0e9h
         dw        l_8790-$-2

l_878A:  mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         mov       word ptr ds:[d_F976],ax  ; maxim. © dek k zobrazen¡ seznamu

; ------ zobrazen¡ r mu okna

l_8790:  mov       ax,1
         push      ax                       ; po‡ te‡n¡ pozice k zobrazen¡ okna
         mov       ax,1
         push      ax                       ; po‡ te‡n¡ © dek k zobrazen¡ okna
         mov       ax,58
         push      ax                       ; koncov  pozice k zobrazen¡ okna
         mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         push      ax                       ; koncov˜ © dek k zobrazen¡ okna
         call      l_4AAB                   ; zobrazen¡ r mu okna

; ------ obnoven¡ zbytku textu p©i zobrazen¡ krat¨¡ho seznamu ne‘ minul˜

         mov       ax,[bp-4]
         cmp       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         jg        l_87AF
         ;jmp       l_87C3
         db        0e9h
         dw        l_87C3-$-2

l_87AF:  mov       ax,1
         push      ax                       ; minim ln¡ pozice okna
         mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         inc       ax
         push      ax                       ; minim ln¡ © dek okna
         mov       ax,58
         push      ax                       ; maxim ln¡ pozice okna
         mov       ax,[bp-4]
         push      ax                       ; maxim ln¡ © dek okna
         call      l_4B97                   ; obnoven¡ textu pod oknem

; ------ zobrazen¡ v˜zvy k v˜bˆru souboru nebo disku

l_87C3:  call      l_8581                   ; zobrazen¡ v˜zvy k v˜bˆru

; ------ zobrazen¡ aktivn¡ho adres ©e

         mov       ax,4
         push      ax
         mov       ax,1
         push      ax
         mov       ax,20h
         push      ax
         mov       di,offset d_F059         ; aktivn¡ adres ©
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       ax," "*HI + 1
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ zobrazen¡ seznamu soubor–

         call      l_861C                   ; zobrazen¡ seznamu soubor–

; ------ zobrazen¡ voln‚ kapacity disku

         lea       di,[bp-0Ah]
         push      ss
         call      l_1950                   ; ‡¡slo - voln  kapacita
         mov       ax,400h                  ; dˆlitel 1 KB
         call      l_1B0C                   ; vydˆlen¡ kapacity 1 KB
         call      l_19BC
         mov       ax,1
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp-19h]
         push      ss
         mov       cl,0Eh
         call      l_0E0C
         mov       ax,2Fh
         push      ax
         lea       di,[bp-19h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         push      ax
         mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         push      ax
         mov       ax,20h
         push      ax
         lea       di,[bp-19h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        8,' KB vol.'

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         ;jmp       l_8854
         db        0e9h,0,0

l_8854:  mov       sp,bp
         pop       bp
         ret

l_8698   ENDP

; -----------------------------------------------------------------------------
;        obnoven¡ textu pod oknem seznamu
; -----------------------------------------------------------------------------

l_8858   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_885F
         db        0e9h,0,0

l_885F:  mov       ax,1
         push      ax                       ; po‡ te‡n¡ pozice okna
         mov       ax,1
         push      ax                       ; po‡ te‡n¡ © dek okna
         mov       ax,58
         push      ax                       ; koncov  pozice okna
         mov       ax,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         push      ax                       ; koncov˜ © dek okna
         call      l_4B97                   ; obnoven¡ textu pod oknem
         mov       ax,0
         mov       word ptr ds:[d_F976],ax  ; maxim. © dek k zobrazen¡ seznamu
         ;jmp       l_887B
         db        0e9h,0,0

l_887B:  mov       sp,bp
         pop       bp
         ret       

l_8858   ENDP

; -----------------------------------------------------------------------------
;        v˜bˆr souboru k operaci
; -----------------------------------------------------------------------------

l_887F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_8947

; -----------------------------------------------------------------------------
;        zapnut¡/vypnut¡ kurzoru
; -----------------------------------------------------------------------------

l_8886   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_8892
         db        0e9h,0,0

; ------ v˜po‡et pozice kurzoru na © dku

l_8892:  mov       dx,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         dec       dx                       ; korekce
         mov       ax,dx
         and       al,3                     ; polo‘ka na © dku
         mov       bl,14                    ; po‡et pozic na polo‘ku
         mul       bl                       ; offset kurzoru na © dku
         inc       ax
         inc       ax
         mov       bx,ax                    ; pozice kurzoru na © dku

; ------ © dek kurzoru relativnˆ v oknˆ

         mov       cx,dx                    ; polo‘ka seznamu s kurzorem
         shr       cx,1
         shr       cx,1                     ; polo‘ka / 4 = © dek relativnˆ
         add       cx,3                     ; © dek s kurzorem
         mov       ax,word ptr ds:[d_F978]  ; po‡ te‡n¡ zobraz. polo‘ka seznamu
         shr       ax,1
         shr       ax,1
         sub       cx,ax                    ; offset kurzoru od za‡ tku okna
         push      bx                       ; pozice kurzoru na © dku

; ------ posun okna nahoru, je-li p©ete‡en¡ kurzoru za koncem seznamu

l_88B6:  cmp       cx,word ptr ds:[d_F976]  ; maxim. © dek k zobrazen¡ seznamu
         jl        l_88C9                   ; kurzor nen¡ nad maxim ln¡m © dkem
         add       word ptr ds:[d_F978],4   ; po‡ te‡n¡ zobraz. polo‘ka seznamu
         dec       cx
         push      cx
         call      l_861C                   ; zobrazen¡ seznamu soubor–
         pop       cx
         jmp       short l_88B6             ; dal¨¡ test

; ------ posun okna dol–, je-li p©ete‡en¡ kurzoru nad horn¡ okraj seznamu

l_88C9:  cmp       cx,3                     ; minim ln¡ © dek k zobraz. seznamu
         jge       l_88DB                   ; kurzor nen¡ nad horn¡m okrajem
         sub       word ptr ds:[d_F978],4   ; po‡ te‡n¡ zobraz. polo‘ka seznamu
         inc       cx
         push      cx
         call      l_861C                   ; zobrazen¡ seznamu soubor–
         pop       cx
         jmp       short l_88C9

; ------ zobrazen¡ aktivn¡ho kurzoru

l_88DB:  pop       bx
         push      bx                       ; po‡ te‡n¡ pozice kurzoru
         push      cx                       ; po‡ te‡n¡ © dek kurzoru
         add       bl,13
         push      bx                       ; koncov  pozice kurzoru
         push      cx                       ; koncov˜ © dek kurzoru
         mov       bl,2
         push      bx                       ; m¢d - kurzor
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         ;jmp       l_88EC
         db        0e9h,0,0

l_88EC:  mov       sp,bp
         pop       bp
         ret       

l_8886   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_88F0   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_88FC
         db        0e9h,0,0

l_88FC:  mov       ax,[bp+4]
         push      ax
         mov       ax,0
         push      ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,[bp+4]
         push      ax
         mov       bx,[bp-2]
         mov       al,ss:[bx-11h]
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         mov       ax,0
         push      ax
         mov       ax,[bp+4]
         add       ax,9
         push      ax
         mov       ax,0
         push      ax
         mov       ax,1
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         ;jmp       l_8941
         db        0e9h,0,0

l_8941:  mov       sp,bp
         pop       bp
         ret       2

l_88F0   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_887F)
; -----------------------------------------------------------------------------

l_8947:  sub       sp,1Ch
         lea       di,[bp+4]
         push      ss
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         push      ax
         mov       ax,ds:[d_F97C]           ; po‡et polo‘ek v seznamu soubor–
         cmp       ax,0
         mov       ax,1
         je        l_8969
         dec       ax
l_8969:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_8973
         ;jmp       l_8976
         db        0e9h
         dw        l_8976-$-2

l_8973:  jmp       l_8D29

; ------ zobrazen¡ v˜zvy k v˜bˆru souboru

l_8976:  mov       ax,1
         mov       byte ptr ds:[d_F971],al  ; 1=prov d¡ se v˜bˆr souboru
         call      l_8581                   ; zobrazen¡ v˜zvy k v˜bˆru

; ------ zobrazen¡ nadpisu nad seznamem

         call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,15h
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        43,'D‚lka:           Datum:                €as:'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

         mov       ax,0
         mov       [bp-18h],al

; ------ zobrazen¡ kurzoru

l_89C7:  call      l_8886                   ; zapnut¡/vypnut¡ kurzoru

; ------ p©¡prava jm‚na souboru k zobrazen¡

         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_CD98+di-8] ; buffer seznamu soubor–
         mov       [bp-15h],ax
         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_CD98+di-6] ; buffer seznamu soubor–
         mov       [bp-17h],ax
         lea       di,[bp-11h]
         push      ss
         push      di
         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         add       di,offset d_CD98 - 17h   ; buffer seznamu soubor–
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,14
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ pro adres © p©id n¡ textu "\"

         mov       al,[bp-10h]
         xor       ah,ah
         cmp       ax,0
         je        l_8A12                   ; je adres ©
         ;jmp       l_8A2A
         db        0e9h
         dw        l_8A2A-$-2

l_8A12:  lea       di,[bp-11h]
         push      ss
         push      di
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,"\"*HI + 1            ;
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ zobrazen¡ jm‚na souboru/adres ©e

l_8A2A:  mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–


         mov       ax,5
         push      ax
         mov       al,[bp-11h]
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax
         mov       ax,0
         push      ax
         mov       ax,13h
         push      ax
         mov       ax,0
         push      ax
         mov       ax,1
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         lea       di,[bp-1Eh]
         push      ss
         push      di
         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_CD98+di-4] ; buffer seznamu soubor–
         call      l_1B0C
         call      l_1970
         lea       di,[bp-1Eh]
         push      ss
         call      l_1950
         mov       ax,0
         call      l_1B0C
         call      l_1A6D
         jnz       l_8A8E
         ;jmp       l_8AA9
         db        0e9h
         dw        l_8AA9-$-2

l_8A8E:  lea       di,[bp-1Eh]
         push      ss
         push      di
         lea       di,[bp-1Eh]
         push      ss
         call      l_1950
         call      l_195F
         db        91h
         db        0,0,0,0,0

         call      l_1983
         call      l_1970
l_8AA9:  lea       di,[bp-1Eh]
         push      ss
         call      l_1950
         call      l_195F
         db        91h
         db        0,0,0,0,0

         mov       ax,ds:[d_F97A]           ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_CD98+di-2] ; buffer seznamu soubor–
         call      l_1B0C
         call      l_19AD
         call      l_1983
         mov       ax,1
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp-11h]
         push      ss
         mov       cl,0Eh
         call      l_0E0C
         mov       ax,1Ch
         push      ax
         call      l_88F0
         lea       di,[bp-11h]
         push      ss
         push      di
         sub       sp,9
         mov       ax,[bp-17h]
         and       ax,1Fh
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       ax,2E01h
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         sub       sp,9
         mov       ax,0Fh
         push      ax
         mov       ax,[bp-17h]
         mov       cx,5
         shr       ax,cl
         pop       cx
         and       ax,cx
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       ax,2E01h
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         sub       sp,9
         mov       ax,[bp-17h]
         mov       cx,9
         shr       ax,cl
         add       ax,1980
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,2Dh
         push      ax
         call      l_88F0
         mov       ax,3Fh
         push      ax
         mov       ax,[bp-15h]
         mov       cx,5
         shr       ax,cl
         pop       cx
         and       ax,cx
         mov       [bp-17h],ax
         lea       di,[bp-11h]
         push      ss
         push      di
         sub       sp,9
         mov       ax,[bp-15h]
         mov       cx,0Bh
         shr       ax,cl
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       ax,":"*HI + 1
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,[bp-17h]
         cmp       ax,0Ah
         jl        l_8B7E
         ;jmp       l_8B96
         db        0e9h
         dw        l_8B96-$-2

l_8B7E:  lea       di,[bp-11h]
         push      ss
         push      di
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,3001h
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_8B96:  lea       di,[bp-11h]
         push      ss
         push      di
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         sub       sp,9
         mov       ax,[bp-17h]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,41h
         push      ax
         call      l_88F0
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         mov       [bp-13h],ax
         call      l_8886                   ; zapnut¡/vypnut¡ kurzoru
         mov       ax,[bp-13h]
         cmp       ax,4
         je        l_8BD1
         ;jmp       l_8BE7
         db        0e9h
         dw        l_8BE7-$-2

l_8BD1:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         cmp       ax,word ptr ds:[d_F97C]  ; po‡et polo‘ek v seznamu soubor–
         jl        l_8BDD
         ;jmp       l_8BE4
         db        0e9h
         dw        l_8BE4-$-2

l_8BDD:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         inc       ax
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
l_8BE4:  jmp       l_8D0C

l_8BE7:  cmp       ax,5
         je        l_8BEF
         ;jmp       l_8C06
         db        0e9h
         dw        l_8C06-$-2

l_8BEF:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         cmp       ax,4
         jg        l_8BFA
         ;jmp       l_8C03
         db        0e9h
         dw        l_8C03-$-2

l_8BFA:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         sub       ax,4
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
l_8C03:  jmp       l_8D0C

l_8C06:  cmp       ax,11h
         je        l_8C0E
         ;jmp       l_8C3A
         db        0e9h
         dw        l_8C3A-$-2

l_8C0E:  dec       sp
         dec       sp
         dec       sp
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         cmp       ax,53h
         je        l_8C20
         ;jmp       l_8C29
         db        0e9h
         dw        l_8C29-$-2

l_8C20:  mov       ax,1
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
         ;jmp       l_8C37
         db        0e9h
         dw        l_8C37-$-2

l_8C29:  cmp       ax,44h
         je        l_8C31
         ;jmp       l_8C37
         db        0e9h
         dw        l_8C37-$-2

l_8C31:  mov       ax,word ptr ds:[d_F97C]  ; po‡et polo‘ek v seznamu soubor–
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
l_8C37:  jmp       l_8D0C

l_8C3A:  cmp       ax,13h
         je        l_8C42
         ;jmp       l_8C57
         db        0e9h
         dw        l_8C57-$-2

l_8C42:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         cmp       ax,1
         jg        l_8C4D
         ;jmp       l_8C54
         db        0e9h
         dw        l_8C54-$-2

l_8C4D:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         dec       ax
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
l_8C54:  jmp       l_8D0C

l_8C57:  cmp       ax,18h
         je        l_8C5F
         ;jmp       l_8C7A
         db        0e9h
         dw        l_8C7A-$-2

l_8C5F:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         add       ax,4
         cmp       ax,word ptr ds:[d_F97C]  ; po‡et polo‘ek v seznamu soubor–
         jle       l_8C6E
         ;jmp       l_8C77
         db        0e9h
         dw        l_8C77-$-2

l_8C6E:  mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         add       ax,4
         mov       word ptr ds:[d_F97A],ax  ; polo‘ka seznamu s kurzorem
l_8C77:  jmp       l_8D0C

l_8C7A:  cmp       ax,0Dh
         je        l_8C82
         ;jmp       l_8CF8
         db        0e9h
         dw        l_8CF8-$-2

l_8C82:  lea       di,[bp-11h]
         push      ss
         push      di
         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         add       di,offset d_CD98-17h     ; buffer seznamu soubor–
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         lea       di,[bp-11h]
         push      ss
         push      di
         mov       ax,1
         push      ax
         mov       ax,1
         call      l_1408                   ; vyjmut¡ cesty z ozna‡en¡ souboru
         mov       ax,word ptr ds:[d_F97A]  ; polo‘ka seznamu s kurzorem
         mov       cx,17h
         mul       cx
         xchg      ax,di
         mov       al,byte ptr ds:[d_CD98+di-17h+1] ; buffer seznamu soubor–
         xor       ah,ah
         cmp       ax,0
         je        l_8CC3
         ;jmp       l_8CDE
         db        0e9h
         dw        l_8CDE-$-2

l_8CC3:  lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2BBF
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_8CD8
         ;jmp       l_8CDB
         db        0e9h
         dw        l_8CDB-$-2

l_8CD8:  call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_8CDB:  ;jmp       l_8CF5
         db        0e9h
         dw        l_8CF5-$-2

l_8CDE:  lea       di,[bp+4]
         push      ss
         push      di
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,1
         mov       [bp-18h],al
l_8CF5:  ;jmp       l_8D0C
         db        0e9h
         dw        l_8D0C-$-2

l_8CF8:  cmp       ax,1Bh
         je        l_8D00
         ;jmp       l_8D0C
         db        0e9h
         dw        l_8D0C-$-2

l_8D00:  mov       ax,1
         mov       [bp-18h],al
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_8D0C:  mov       al,[bp-18h]
         xor       ah,ah
         push      ax
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_8D20
         jmp       l_89C7

l_8D20:  mov       ax,0
         mov       byte ptr ds:[d_F971],al  ; 1=prov d¡ se v˜bˆr souboru
         call      l_8581                   ; zobrazen¡ v˜zvy k v˜bˆru
l_8D29:  ;jmp       l_8D2C
         db        0e9h,0,0

l_8D2C:  mov       dx,0
         mov       cl,0Eh
         mov       sp,bp
         pop       bp
         jmp       l_1475                   ; redukce d‚lky bufferu na minimum

l_887F   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ souboru z disku
; -----------------------------------------------------------------------------

l_8D37   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_8D3E
         db        0e9h,0,0

l_8D3E:  sub       sp,5Bh
         lea       di,[bp-11h]
         push      ss
         push      di
         sub       sp,0Fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_8D64
         ;jmp       l_8D67
         db        0e9h
         dw        l_8D67-$-2

l_8D64:  jmp       l_8DF3

l_8D67:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        54,' je maz n:stisknˆte Enter=potvrzen¡ nebo Esc=p©eru¨en¡'

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         xor       al,1
         jnz       l_8DC9
         ;jmp       l_8DED
         db        0e9h
         dw        l_8DED-$-2

l_8DC9:  lea       di,[bp-5dh]
         push      ss
         push      di
         lea       di,[bp-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-5dh]
         push      ss
         call      l_2B71                   ; zru¨en¡ souboru
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_8DEA
         ;jmp       l_8DED
         db        0e9h
         dw        l_8DED-$-2

l_8DEA:  call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_8DED:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_8DF3:  ;jmp       l_8DF6
         db        0e9h,0,0

l_8DF6:  mov       sp,bp
         pop       bp
         ret       

l_8D37   ENDP

; -----------------------------------------------------------------------------
;        p©ejmenov n¡ souboru
; -----------------------------------------------------------------------------

l_8DFA   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_8E01
         db        0e9h,0,0

l_8E01:  sub       sp,14Eh
         lea       di,[bp-150h]
         push      ss
         push      di
         sub       sp,0Fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         lea       di,[bp-150h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_8E2A
         ;jmp       l_8E2D
         db        0e9h
         dw        l_8E2D-$-2

l_8E2A:  jmp       l_8EC0

l_8E2D:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         lea       di,[bp-150h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        14,'Nov‚ jm‚no pro'

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         lea       di,[bp-0cfh]
         push      ss
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_8E6B
         ;jmp       l_8EBA
         db        0e9h
         dw        l_8EBA-$-2

l_8E6B:  lea       di,[bp-0cfh]
         push      ss
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         dec       sp
         lea       di,[bp-0cfh]
         push      ss
         push      di
         call      l_73F7                   ; nalezen¡ souboru zadan‚ho jm‚na
         jnz       l_8E83
         ;jmp       l_8E8C
         db        0e9h
         dw        l_8E8C-$-2

l_8E83:  mov       ax,0Fh
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         ;jmp       l_8EBA
         db        0e9h
         dw        l_8EBA-$-2

l_8E8C:  lea       di,[bp-4Eh]
         push      ss
         push      di
         lea       di,[bp-150h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-4Eh]
         push      ss
         push      di
         lea       di,[bp-0CFh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2B8E                   ; p©ejmenov n¡ souboru
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_8EB7
         ;jmp       l_8EBA
         db        0e9h
         dw        l_8EBA-$-2

l_8EB7:  call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_8EBA:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_8EC0:  ;jmp       l_8EC3
         db        0e9h,0,0

l_8EC3:  mov       sp,bp
         pop       bp
         ret       

l_8DFA   ENDP

; -----------------------------------------------------------------------------
;        kop¡rov n¡ souboru
; -----------------------------------------------------------------------------

l_8EC7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_8ECE
         db        0e9h,0,0

l_8ECE:  sub       sp,10ah
         lea       di,[bp-8bh]
         push      ss
         push      di
         sub       sp,0fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         lea       di,[bp-8bh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_8EF7
         ;jmp       l_8EFA
         db        0e9h
         dw        l_8EFA-$-2

l_8EF7:  jmp       l_906E

l_8EFA:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         lea       di,[bp-8bh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,'Jm‚no c¡lov‚ho souboru'

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         lea       di,[bp-10ch]
         push      ss
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_8F40
         ;jmp       l_8F43
         db        0e9h
         dw        l_8F43-$-2

l_8F40:  jmp       l_9068

l_8F43:  lea       di,[bp-8bh]
         push      ss
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         lea       di,[bp-10ch]
         push      ss
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         lea       di,[bp-8bh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         lea       di,[bp-10ch]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_8F6D
         ;jmp       l_8F76
         db        0e9h
         dw        l_8F76-$-2

l_8F6D:  mov       ax,10h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_906E

l_8F76:  jmp       l_9017

; -----------------------------------------------------------------------------
;        otev©en¡/vytvo©en¡ souboru
; -----------------------------------------------------------------------------

l_8F79   PROC      NEAR

         push      ds
         mov       dx,ss
         mov       ds,dx
         mov       bl,[si]
         mov       bh,0
         inc       si
         mov       [bx+si],bh
         mov       dx,si
         push      bp
         int       21h
         pop       bp
         jc        l_8F9B
         xor       bx,bx
         xchg      bx,cs:[l_34AF]           ; chyba INT 24h - informa‡n¡ registr
         or        bx,bx
         jz        l_8F9B
         mov       al,64h
         stc       
l_8F9B:  pop       ds
         ret       

l_8F79   ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ souboru pro ‡ten¡ (p©i kop¡rov n¡ souboru)
; -----------------------------------------------------------------------------

l_8F9D   PROC      NEAR

         mov       ax,3D00h
         lea       si,[bp-8Bh]
         call      l_8F79                   ; otev©en¡/vytvo©en¡ souboru
         ;mov       [bp-4],ax
         db        89h,86h,0FCh,0FFh        ;!
         ret

l_8F9D   ENDP

; -----------------------------------------------------------------------------
;        vytvo©en¡ souboru
; -----------------------------------------------------------------------------

l_8FAC   PROC      NEAR

         lea       si,[bp-10Ch]
         xor       cx,cx
         mov       ah,3Ch
         call      l_8F79                   ; otev©en¡/vytvo©en¡ souboru
         ;mov       [bp-6],ax
         db        89h,86h,0FAh,0FFh        ;!
         ret

l_8FAC   ENDP

; -----------------------------------------------------------------------------
;        poskytnut¡ data a ‡asu souboru
; -----------------------------------------------------------------------------

l_8FBC   PROC      NEAR

         push      ds
         push      bp
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       ax,5700h
         int       21h
         ;mov       [bp-8],cx
         db        89h,8Eh,0F8h,0FFh        ;!
         ;mov       [bp-0Ah],dx
         db        89h,96h,0F6h,0FFh        ;!
         pop       bp
         pop       ds
         ret       

l_8FBC   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ data a ‡asu souboru
; -----------------------------------------------------------------------------

l_8FD2   PROC      NEAR

         push      ds
         push      bp
         ;mov       bx,[bp-6]
         db        8Bh,9Eh,0FAh,0FFh        ;!
         ;mov       cx,[bp-8]
         db        8Bh,8Eh,0F8h,0FFh        ;!
         ;mov       dx,[bp-0Ah]
         db        8Bh,96h,0F6h,0FFh        ;!
         mov       ax,5701h
         int       21h
         pop       bp
         pop       ds
         ret       

l_8FD2   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ obsahu bufferu ze souboru
; -----------------------------------------------------------------------------

l_8FE8   PROC      NEAR

         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       cx,1800h
         mov       dx,offset d_CD98         ; buffer seznamu soubor–
         mov       ah,3Fh
         int       21h
         ret       

l_8FE8   ENDP

; -----------------------------------------------------------------------------
;        z pis obsahu bufferu do souboru
; -----------------------------------------------------------------------------

l_8FF7   PROC      NEAR

         ;mov       bx,[bp-6]
         db        8Bh,9Eh,0FAh,0FFh        ;!
         mov       cx,ax
         mov       dx,offset d_CD98         ; buffer seznamu soubor–
         mov       ah,40h
         int       21h
         jc        l_900D
         or        ax,ax
         jnz       l_900D
         mov       al,0F0h
         stc       
l_900D:  ret

l_8FF7   ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru
; -----------------------------------------------------------------------------

l_900E   PROC      NEAR

         push      ds
         push      bp
         mov       ah,3Eh
         int       21h
         pop       bp
         pop       ds
         ret       

l_900E   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_8EC7)
; -----------------------------------------------------------------------------

; ------ otev©en¡ soubor–

l_9017:  call      l_8F9D                   ; otev©en¡ souboru pro ‡ten¡
         jc        l_903E
         call      l_8FAC                   ; vytvo©en¡ souboru
         jc        l_903E
         call      l_8FBC                   ; poskytnut¡ data a ‡asu souboru
         jc        l_903E

; ------ zkop¡rov n¡ obsahu soubor–

l_9026:  call      l_8FE8                   ; na‡ten¡ obsahu bufferu ze souboru
         jc        l_903E
         or        ax,ax
         jz        l_9039
         call      l_8FF7                   ; z pis obsahu bufferu do souboru
         jc        l_903E
         cmp       ax,1800h
         je        l_9026

; ------ uzav©en¡ soubor–

l_9039:  call      l_8FD2                   ; nastaven¡ data a ‡asu souboru
         jnc       l_904C
l_903E:  mov       ah,0
         cmp       al,14h
         jae       l_9049
         mov       bx,offset l_34B3         ; tabulka pro konverzi chyb DOS
         xlat      cs:[bx]
l_9049:  mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
l_904C:  ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         call      l_900E                   ; uzav©en¡ souboru
         ;mov       bx,[bp-6]
         db        8Bh,9Eh,0FAh,0FFh        ;!
         call      l_900E                   ; uzav©en¡ souboru
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_9065
         ;jmp       l_9068
         db        0e9h
         dw        l_9068-$-2

; ------ inicializace seznamu soubor– a obrazovky

l_9065:  call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_9068:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_906E:  ;jmp       l_9071
         db        0e9h,0,0

l_9071:  mov       sp,bp
         pop       bp
         ret       

l_8EC7   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ nastaven¡ konfigurace
; -----------------------------------------------------------------------------

l_9075   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_9082
         db        0e9h
         dw        l_9082-$-2

l_907C:  jmp       l_BC32

l_907F:  call      l_6E80

l_9082:  sub       sp,50h
         lea       di,[bp-4eh]
         push      ss
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        11,'KONTEXT.COM'

         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-4eh]
         push      ss
         mov       cx,1
         call      l_2945
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         jnz       l_90AF
         ;jmp       l_90B2
         db        0e9h
         dw        l_90B2-$-2

l_90AF:  jmp       l_9184

l_90B2:  call      l_8858                   ; obnoven¡ textu pod oknem seznamu
         mov       ax,16h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         xor       al,1
         jnz       l_90C7
         jmp       l_916D

l_90C7:  mov       ax,0
         push      ax
         mov       ax,5
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_90D7
         ;jmp       l_9115
         db        0e9h
         dw        l_9115-$-2

l_90D7:  inc       cx
         mov       [bp-52h],ax
l_90DB:  push      cx
         mov       ax,[bp-52h]
         cmp       ax,3
         je        l_90E7
         ;jmp       l_90F2
         db        0e9h
         dw        l_90F2-$-2

l_90E7:  lea       di,[bp-4Eh]
         push      ss
         push      di
         mov       ax,2BB6h
         call      l_29F6
l_90F2:  lea       di,[bp-4Eh]
         push      ss
         call      l_299C
         mov       ax,[bp-52h]
         xchg      ax,di
         add       di,offset l_907C
         push      cs
         call      l_29C1
         call      l_0FFC
         mov       [bp-50h],ax
         pop       cx
         dec       cx
         jz        l_9115
         inc       word ptr [bp-52h]
         ;jmp       l_90DB
         db        0e9h
         dw        l_90DB-$-2

l_9115:  call      l_3F89                   ; n vrat line lu © dk– pod okraji
         lea       di,[bp-4Eh]
         push      ss
         push      di
         mov       di,offset l_2CD9         ; buffer makrokl ves
         xchg      ax,di
         sub       ax,100h
         call      l_29F6
         call      l_0FFC
         mov       [bp-50h],ax
         mov       ax,0
         push      ax
         mov       ax,69Fh
         dec       ax
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_913E
         ;jmp       l_916A
         db        0e9h
         dw        l_916A-$-2

l_913E:  inc       cx
         mov       [bp-52h],ax
l_9142:  push      cx
         lea       di,[bp-4Eh]
         push      ss
         call      l_299C
         mov       ax,cs
         push      ax
         mov       di,offset l_2CD9         ; buffer makrokl ves
         xchg      ax,di
         add       ax,[bp-52h]
         xchg      ax,di
         pop       es
         push      es
         call      l_29C1
         call      l_0FFC
         mov       [bp-50h],ax
         pop       cx
         dec       cx
         jz        l_916A
         inc       word ptr [bp-52h]
         ;jmp       l_9142
         db        0e9h
         dw        l_9142-$-2

l_916A:  call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–
l_916D:  lea       di,[bp-4Eh]
         push      ss
         call      l_298A
         call      l_0FFC
         mov       [bp-50h],ax
         mov       ax,16h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_9184:  ;jmp       l_9187
         db        0e9h,0,0

l_9187:  mov       sp,bp
         pop       bp
         ret       

l_9075   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KQ (ukon‡en¡ programu KonText)
; -----------------------------------------------------------------------------

l_918B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_9192
         db        0e9h,0,0

l_9192:  dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         cmp       ax,0
         jne       l_919F
         ;jmp       l_91A8
         db        0e9h
         dw        l_91A8-$-2

l_919F:  mov       ax,11h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_92ED

l_91A8:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,0Dh
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru
         mov       ax,0
         mov       ds:[d_F059],al
         mov       ax,1
         push      ax
         mov       ax,5
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_91CF
         ;jmp       l_921A
         db        0e9h
         dw        l_921A-$-2

l_91CF:  inc       cx
         mov       [bp-4],ax
l_91D3:  push      cx
         mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       al,byte ptr ds:[d_E6A8+di] ; 0=p©¡znak modifikace textu
         xor       ah,ah
         xor       al,1
         jnz       l_91EA
         ;jmp       l_9210
         db        0e9h
         dw        l_9210-$-2

l_91EA:  mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,[bp-4]
         add       ax,30h
         mov       ah,al
         mov       al,1
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       ax,2C01h
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_9210:  pop       cx
         dec       cx
         jz        l_921A
         inc       word ptr [bp-4]
         ;jmp       l_91D3
         db        0e9h
         dw        l_91D3-$-2

l_921A:  mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0
         jg        l_9227
         jmp       l_92B1

l_9227:  mov       al,ds:[d_F059]
         xor       ah,ah
         dec       ax
         mov       ds:[d_F059],al
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        27,'Nen¡ dosud ulo‘en: prostor '

         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4dh
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       cx,1
         shr       ax,cl
         mov       [bp-4],ax
         mov       ax,[bp-4]
         push      ax
         mov       ax,2
         push      ax
         mov       ax,[bp-4]
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         pop       cx
         add       ax,cx
         add       ax,3
         push      ax
         mov       ax,4
         push      ax
         call      l_4AAB                   ; zobrazen¡ r mu okna
         mov       ax,[bp-4]
         add       ax,2
         push      ax
         mov       ax,3
         push      ax
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ ‡ek n¡ na potvrzen¡ hl ¨en¡

l_92B1:  dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         xor       al,1
         jnz       l_92BC
         ;jmp       l_92DA
         db        0e9h
         dw        l_92DA-$-2

; ------ n vrat p–vodn¡ obsluhy INT 24h

l_92BC:  call      l_6445                   ; odinstalov n¡ obsluhy INT 24h

; ------ n vrat p–vodn¡ adresy DTA

         mov       ax,word ptr ds:[d_F97E]  ; uschovan  adresa DTA - segment
         mov       ds:[d_026E],ax           ; registr DS pro vol n¡ INT 21h
         mov       ax,word ptr ds:[d_F980]  ; uschovan  adresa DTA - offset
         mov       ds:[d_0266],ax           ; registr DX pro vol n¡ INT 21h
         mov       ax,1Ah
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h

; ------ nastaven¡ textov‚ho m¢du displeje

         call      l_361C                   ; nastaven¡ textov‚ho m¢du displeje
         xor       ax,ax
         jmp       near ptr l_0C6A

; ------ p©i p©eru¨en¡ obnoven¡ obsahu obrazovky

l_92DA:  mov       ax,1
         push      ax
         mov       ax,1
         push      ax
         mov       ax,3Bh
         push      ax
         mov       ax,0Eh
         push      ax
         call      l_4B97                   ; obnoven¡ textu pod oknem
l_92ED:  ;jmp       l_92F0
         db        0e9h,0,0

l_92F0:  mov       sp,bp
         pop       bp
         ret       

l_918B   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KD (menu obsluhy soubor–)
; -----------------------------------------------------------------------------

l_92F4   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_9440

; -----------------------------------------------------------------------------
;        na‡ten¡ nov‚ho souboru z disku
; -----------------------------------------------------------------------------

l_92FB   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9307
         db        0e9h,0,0

l_9307:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         sub       sp,0Fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         mov       bx,[bp-2]
         mov       ss:[bx-12h],al
         mov       bx,[bp-2]
         mov       al,ss:[bx-12h]
         xor       ah,ah
         or        ax,ax
         jnz       l_9344
         ;jmp       l_938C
         db        0e9h
         dw        l_938C-$-2

l_9344:  call      l_8858                   ; obnoven¡ textu pod oknem seznamu
         dec       sp
         call      l_725B                   ; ukon‡en¡ editace - zru¨en¡ souboru
         mov       bx,[bp-2]
         mov       ss:[bx-12h],al
         mov       bx,[bp-2]
         mov       al,ss:[bx-12h]
         xor       ah,ah
         or        ax,ax
         jnz       l_9362
         ;jmp       l_9383
         db        0e9h
         dw        l_9383-$-2

l_9362:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         call      l_7E64                   ; na‡ten¡ zadan‚ho souboru do pamˆti
         mov       al,ds:[d_F786]           ; 1=p©¡znak zobrazen¡ horn¡ho menu
         xor       ah,ah
         xor       al,1
         jnz       l_937A
         ;jmp       l_937D
         db        0e9h
         dw        l_937D-$-2

l_937A:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_937D:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_938C
         db        0e9h
         dw        l_938C-$-2

l_9383:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_938C:  ;jmp       l_938F
         db        0e9h,0,0

l_938F:  mov       sp,bp
         pop       bp
         ret       

l_92FB   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bloku z disku
; -----------------------------------------------------------------------------

l_9393   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_939F
         db        0e9h,0,0

l_939F:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         sub       sp,0Fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         mov       bx,[bp-2]
         mov       ss:[bx-12h],al
         mov       bx,[bp-2]
         mov       al,ss:[bx-12h]
         xor       ah,ah
         or        ax,ax
         jnz       l_93DC
         ;jmp       l_93EB
         db        0e9h
         dw        l_93EB-$-2

l_93DC:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         call      l_7EC8                   ; na‡ten¡ soub. do pamˆti jako blok
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_93EB:  ;jmp       l_93EE
         db        0e9h,0,0

l_93EE:  mov       sp,bp
         pop       bp
         ret       

l_9393   ENDP

; -----------------------------------------------------------------------------
;        start programu
; -----------------------------------------------------------------------------

l_93F2   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_93FE
         db        0e9h,0,0

l_93FE:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         sub       sp,0Fh
         call      l_887F                   ; v˜bˆr souboru k operaci
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         jnz       l_9429
         ;jmp       l_9439
         db        0e9h
         dw        l_9439-$-2

l_9429:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-11h]
         push      ss
         push      di
         mov       ax,1
         push      ax
         call      l_8062                   ; start programu
l_9439:  ;jmp       l_943C
         db        0e9h,0,0

l_943C:  mov       sp,bp
         pop       bp
         ret

l_93F2   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_92F4)
; -----------------------------------------------------------------------------

l_9440:  sub       sp,10h
         jmp       l_9536

; -----------------------------------------------------------------------------
;        zobrazen¡ okna n povˆdy obsluhy soubor– Ctrl-KD
; -----------------------------------------------------------------------------

l_9446   PROC      NEAR

         mov       ax,9
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         call      l_9478                   ; zobrazen¡ p©ep¡na‡– v oknˆ
         xor       ax,ax
         mov       byte ptr ds:[d_F798],al
         mov       word ptr ds:[d_F976],ax  ; maxim. © dek k zobrazen¡ seznamu
         mov       byte ptr ds:[d_F971],al  ; 1=prov d¡ se v˜bˆr souboru
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
         mov       dl,byte ptr ds:[d_E68D]
         mov       dh,0
         inc       dx
         inc       dx
l_9466:  push      dx
         mov       ax,3Eh
         push      ax
         push      dx
         mov       al,4Fh             ; 'O'
         push      ax
         push      dx
         mov       al,2
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         pop       dx
         ret       

l_9446   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ p©ep¡na‡– v oknˆ
; -----------------------------------------------------------------------------

l_9478   PROC      NEAR

         push      dx
         xor       cx,cx
l_947B:  mov       al,0FBh
         cmp       cl,byte ptr cs:[l_3271]  ; form t(0=KonText,1=LAYOUT,2=ASCII)
         je        l_9486
         mov       al,2Dh
l_9486:  push      cx
         push      ax                       ; znak
         mov       ax,4Eh
         push      ax                       ; pozice
         add       cl,0Dh
         push      cx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       cx
         inc       cx
         cmp       cl,2
         jbe       l_947B
         mov       al,0FBh
         cmp       ch,byte ptr cs:[l_3272]  ; z loha BAK (1=zap., 0=vyp.)
         jne       l_94A5
         mov       al,2Dh
l_94A5:  push      ax                       ; znak
         mov       cl,4Eh
         push      cx                       ; pozice
         mov       cl,10h
         push      cx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       dx
         ret

l_9478   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ z lohy BAK
; -----------------------------------------------------------------------------

l_94B1   PROC      NEAR

         xor       byte ptr cs:[3272h],1    ; z loha BAK (1=zap., 0=vyp.)
         jmp       short l_94C1

l_94B1   ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ form tu
; -----------------------------------------------------------------------------

l_94B9   PROC      NEAR

         mov       al,dl
         sub       al,13
         mov       byte ptr cs:[l_3271],al  ; form t(0=KonText,1=LAYOUT,2=ASCII)
l_94C1:  call      l_9466                   ; zobrazen¡ okna n povˆdy
         call      l_9478                   ; zobrazen¡ p©ep¡na‡– v oknˆ
         jmp       short l_9466

l_94B9   ENDP

; -----------------------------------------------------------------------------
;        ulo‘en¡ editovan‚ho souboru na disk
; -----------------------------------------------------------------------------

l_94C9   PROC      NEAR

         cmp       word ptr ds:[d_F7A3],0   ; skute‡n˜ po‡et © dk– prostoru
         je        l_94F5
         mov       si,offset d_E6FB         ; jm‚no editovan‚ho souboru
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         pop       es
         cld       
         mov       cl,[si]
         mov       ch,0
         inc       cx
         repne     movsb
         call      l_79D9
         jmp       short l_94E8

; ------ z pis bloku na disk

l_94E5:  call      l_7886
l_94E8:  call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         cmp       byte ptr ds:[d_F78A],0   ; 1=p©¡znak p©eru¨en¡ editace volby
         jne       l_94F5
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_94F5:  ret

l_94C9   ENDP

; -----------------------------------------------------------------------------
;        start programu
; -----------------------------------------------------------------------------

l_94F6   PROC      NEAR

         call      l_93F2                   ; start programu
         ;cmp       byte ptr [bp-11h],0
         db        80h,0BEh,0EFh,0FFh,0     ;!
         je        l_950D
         cmp       byte ptr ds:[d_F79D],15h ; k¢d chyby KonTextu
         je        l_950D
         call      l_9446                   ; zobrazen¡ n povˆdy menu soubor–
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
l_950D:  ret

l_94F6   ENDP

; -----------------------------------------------------------------------------
;        ukon‡en¡ programu KonText
; -----------------------------------------------------------------------------

l_950E   PROC      NEAR

         call      l_8858                   ; obnoven¡ textu pod oknem seznamu
         call      l_918B                   ; ukon‡en¡ programu KonText
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
l_9517:  ret

l_950E   ENDP

; ------ adresy skok–

l_9518   dw        l_92FB                   ; na‡ten¡ nov‚ho souboru z disku
         dw        l_94C9                   ; ulo‘en¡ souboru na disk
         dw        l_9393                   ; na‡ten¡ bloku z disku
         dw        l_94E5                   ; z pis bloku na disk
         dw        l_8D37                   ; zru¨en¡ souboru z disku
         dw        l_8DFA                   ; p©ejmenov n¡ souboru
         dw        l_8EC7                   ; kop¡rov n¡ souboru
         dw        l_94F6                   ; start programu
         dw        l_9075                   ; ulo‘en¡ nastaven¡ konfigurace
         dw        l_950E                   ; ukon‡en¡ programu KonText
         dw        l_9517                   ; ...
         dw        l_94B9                   ; nastaven¡ form tu KonText
         dw        l_94B9                   ; nastaven¡ form tu Layout
         dw        l_94B9                   ; nastaven¡ form tu ASCII
         dw        l_94B1                   ; nastaven¡ z lohy BAK

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_92F4)
; -----------------------------------------------------------------------------

l_9536:  call      l_9446                   ; zobrazen¡ n povˆdy menu soubor–
l_9539:  push      dx
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         jz        l_9552
         push      word ptr ds:[d_F79D]     ; k¢d chyby KonTextu
         call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         pop       ax
         cmp       al,1
         jne       l_9552
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–

; ------ ‡ek n¡ na zad n¡ kl vesy

l_9552:  call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
         push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         pop       dx

; ------ kurzor dol–

         cmp       al,3
         je        l_9562
         cmp       al,18h
         jne       l_9575
l_9562:  call      l_9466
         cmp       dl,0Bh
         jne       l_956B
         inc       dx
l_956B:  inc       dx
         cmp       dl,10h
         jbe       l_95B0
         mov       dl,2
         jmp       short l_95B0

; ------ kurzor nahoru

l_9575:  cmp       al,5
         je        l_957D
         cmp       al,12h
         jne       l_9590
l_957D:  call      l_9466
         cmp       dl,0Dh
         jne       l_9586
         dec       dx
l_9586:  dec       dx
         cmp       dl,2
         jae       l_95B0
         mov       dl,10h
         jmp       short l_95B0

; ------ kl vesa Ctrl-Q

l_9590:  cmp       al,11h
         jne       l_95B5
         call      l_9466
         push      dx
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         pop       dx
         mov       ah,2
         cmp       al,53h
         je        l_95AE
         mov       ah,10h
         cmp       al,44h
         jne       l_95B0
l_95AE:  mov       dl,ah
l_95B0:  call      l_9466
l_95B3:  jmp       short l_9539


l_95B5:  cmp       dh,ds:[d_F786]           ; 1=p©¡znak zobrazen¡ horn¡ho menu
         je        l_95C7
         mov       ah,1
         cmp       al,4
         je        l_9615
         mov       ah,0FFh
         cmp       al,13h
         je        l_9615
l_95C7:  cmp       al,1Bh
         je        l_9619
         cmp       al,0Dh
         je        l_95F8                   ; volba funkce

; ------ zmˆna disku

         cmp       al,"A"
         jb        l_95B3
         cmp       al,"K"
         jbe       l_95E1
         cmp       al,"a"
         jb        l_95B3
         cmp       al,"k"
         ja        l_95B3
         sub       al,20h                   ; korekce na velk‚ p¡smeno
l_95E1:  sub       al,"A"                   ; korekce na ‡¡slo disku
         push      dx
         push      ax
         xor       dx,dx
         mov       ah,2
         mov       bh,0
         int       10h                      ; nastaven¡ pozice kurzoru
         pop       dx
         mov       ah,0Eh
         int       21h                      ; nastaven¡ nov‚ho aktivn¡ho disku
         call      l_8698                   ; na‡ten¡ a zobraz. seznamu soubor–
         pop       dx
l_95F6:  jmp       short l_95B3

; ------ proveden¡ volby ENTER

l_95F8:  ;mov       [bp-12h],dh
         db        88h,0B6h,0EEh,0FFh       ;!
         push      dx
         mov       bx,dx
         dec       bx
         dec       bx
         mov       ds:[d_E68D],bl
         shl       bx,1
         call      cs:[l_9518+bx]           ; skok na obsluhu volby
         pop       dx
         ;cmp       dh,[bp-12h]
         db        3Ah,0B6h,0EEh,0FFh       ;!
         je        l_95F6
         jmp       short l_9623

; ------ p©eru¨en¡ operace ESC

l_9615:  mov       ds:[d_F798],ah
l_9619:  call      l_8858                   ; obnoven¡ textu pod oknem seznamu
         mov       ax,9
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
l_9623:  ;jmp       l_9626
         db        0e9h,0,0

l_9626:  mov       sp,bp
         pop       bp
         ret

l_92F4   ENDP

; *****************************************************************************
;
;                       Instalace ovlada‡e SCREEN.OVL
;
; *****************************************************************************

; -----------------------------------------------------------------------------
;        instalace ovlada‡e SCREEN.OVL
; -----------------------------------------------------------------------------

l_962A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_9631
         db        0e9h,0,0

l_9631:  sub       sp,50h
         mov       ax,0                     
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         mov       ah,30h                   ; verze opera‡n¡ho syst‚mu
         int       21h                      ; poskytnut¡ verze opera‡n¡ho syst.
         mov       di,offset d_FDD5         ; zav dˆc¡ cesta
         mov       byte ptr [di],0          
         cmp       al,3                     ; po‘adov na verze min. 3.00
         jb        l_9689                   ; je n¡zk  verze opera‡n¡ho syst‚mu
         mov       es,cs:[2ch]              ; adresa segmentu prost©ed¡
         xor       ax,ax                    ; AX <- 0000
         xor       si,si                    ; ukazatel v prost©ed¡
l_9651:  cmp       si,7D00h                 ; p©ekro‡ena hranice prost©ed¡ ?
         jae       l_9689                   ; p©ekro‡en okraj prost©ed¡
         cmp       ax,es:[si]               ; je konec prost©ed¡ ?
         je        l_965F                   ; konec prost©ed¡
         inc       si                       ; zv˜¨en¡ ukazatele
         jmp       short l_9651             ; dal¨¡ bajt

l_965F:  inc       si
         inc       si                       ; adresa po‡tu ©etˆzc–
         cmp       word ptr es:[si],1       ; je 1 ©etˆzec ?
         jne       l_9689                   ; nen¡ 1 ©etˆzec - nezn m˜ typ
         xor       bx,bx                    ; ukazatel ©etˆzce
         xor       dx,dx                    ; ukazatel konce cesty
         inc       si                       
l_966C:  inc       si                       ; adresa za‡ tku ©etˆzce
         mov       al,es:[si]               ; znak ©etˆzce zav dˆc¡ cesty
         cmp       al,0                     ; je konec ©etˆzce ?
         je        l_9687                   ; je konec ©etˆzce
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e d‚lky textu
         cmp       al,3Ah                   ; je znak ":" ? (ozna‡en¡ disku)
         je        l_9681                   ; je oddˆlova‡ ozna‡en¡ disku
         cmp       al,2Fh                   ; je znak "/" ? (parametry)
         je        l_9681                   ; jsou parametry
         cmp       al,5Ch                   ; je znak "\" ? (adres ©)
         jne       l_9683                   ; nen¡ znak "\"
l_9681:  mov       dx,bx                    ; nov˜ konec ozna‡en¡ cesty
l_9683:  mov       [bx+di],al               ; ulo‘en¡ znaku textu
         jmp       short l_966C             ; dal¨¡ znak

l_9687:  mov       [di],dl                  ; ulo‘en¡ po‡tu znak– ©etˆzce
l_9689:  mov       di,offset d_FDD5         ; p©¡stupov  cesta k programu
         push      ds                       
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jne       l_969C                   ; je shoda ©etˆzc– (©etˆzec je 0)
         ;jmp       l_96EC                   ; ©etˆzec m  nulovou d‚lku
         db        0e9h
         dw        l_96EC-$-2

l_969C:  mov       ax,0                     ; AX <- 0000
         push      ax                       ; £schova AX
         mov       di,offset d_FDD5         ; p©¡stupov  cesta k programu
         push      ds                       ; segment k ulo‘en¡ aktiv. cesty
         mov       cl,80h                   ; max. d‚lka ©etˆzce
         call      l_2C0F                   ; poskytnut¡ aktiv. disku a adres ©e
         dec       sp                       ; rezerva m¡sta pro 1 bajt parametru
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1                     ; negace podm¡nky
         push      ax                       ; £schova n vratov‚ podm¡nky
         mov       di,offset d_FDD5         ; p©¡stupov  cesta k programu
         push      ds                       ; datov˜ segment
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F                   ; funkce LEN - d‚lka ©etˆzce
         xchg      ax,di                    ; DI <- d‚lka ©etˆzce
         mov       al,ds:[di+d_FDD5]        ; ukon‡ovac¡ znak p©¡stupov‚ cesty
         xor       ah,ah                    ; AH <- 00
         cmp       ax,"\"                   ; je jin˜ znak ne‘ "\" ?
         mov       ax,1                     ; p©¡znak - nen¡ znak "\"
         jne       l_96CA                   ; nen¡ znak "\"
         dec       ax                       ; p©¡znak 0 - je znak "\"
l_96CA:  pop       cx                       ; n vratov  podm¡nka
         and       ax,cx                    ; je nˆjak˜ ©etˆzec a je konec "\" ?
         or        ax,ax                    ; test v˜sledn‚ podm¡nky
         jnz       l_96D4                   ; podm¡nka splnˆna
         ;jmp       l_96EC                   ; text je ukon‡en "\" nebo je 0
         db        0e9h
         dw        l_96EC-$-2

l_96D4:  mov       di,offset d_FDD5         ; p©¡stupov  cesta k programu
         push      ds                       ; ukl dac¡ adresa ©etˆzce
         push      di                       ; ukl dac¡ adresa ©etˆzce
         mov       di,offset d_FDD5         ; ©etˆzec p©¡stupov‚ cesty k programu
         push      ds                       ; segment ©etˆzce DI
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,"\"*256 + 1           ; ©etˆzec "\" o d‚lce 1
         push      ax                       ; ulo‘en¡ ©etˆzce "\"
         call      l_12DE                   ; p©i‡ten¡ ©etˆzce "\" na konec
         mov       cl,80h                   ; maxim ln¡ d‚lka ©etˆzce
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ zde je ji‘ p©¡stup. cesta sestavena

l_96EC:  lea       di,[bp-4eh]              ; rezerva pro data
         push      ss
         push      di
         mov       di,offset d_FDD5         ; p©¡stupov  cesta k SCREEN.OVL
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        10,'SCREEN.OVL'          ; identifikace souboru driveru

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-4eh]
         push      ss
         mov       cx,1
         call      l_2945
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_9721
         jmp       l_97DD

l_9721:  lea       di,[bp-4eh]
         push      ss
         call      l_2A66
         mov       [bp-50h],ax
         call      l_07FB                   ; velikost nejvˆt¨¡ho bloku pamˆti
         cmp       ax,0                     ; je voln‚ m¡sto v pamˆti ?
         mov       ax,1
         jg        l_9737
         dec       ax
l_9737:  push      ax
         call      l_07FB                   ; velikost nejvˆt¨¡ho bloku pamˆti
         push      ax
         mov       ax,[bp-50h]
         mov       cx,4
         shr       ax,cl
         inc       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jl        l_974F
         dec       ax
l_974F:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_9759
         ;jmp       l_9785
         db        0e9h
         dw        l_9785-$-2

l_9759:  call      l_24E9                   ; nastaven¡ stand. v˜stup. za©¡zen¡
         call      l_28D9                   ; zobrazen¡ textov‚ho ©etˆzce DOS
         db        26,'Nen¡ dost m¡sta v pamˆti !'

         call      l_28F1                   ; od© dkov n¡ textu DOS
         call      l_1003                   ; test, zda je nˆjak  chyba programu
         xor       ax,ax
         jmp       near ptr l_0C6A

l_9785:  mov       di,offset d_FDC7         ; adresa vstupn¡ho bodu SCREEN.OVL
         push      ds
         push      di
         mov       ax,[bp-50h]
         add       ax,10h
         call      l_05AD                   ; p©idˆlen¡ nov‚ho pamˆŸov‚ho bloku
         mov       ax,word ptr ds:[d_FDC7]  ; adresa vstupn¡ho bodu SCREEN.OVL
         cmp       ax,0
         jne       l_979E
         ;jmp       l_97AB
         db        0e9h
         dw        l_97AB-$-2

l_979E:  mov       ax,0
         mov       word ptr ds:[d_FDC7],ax  ; adresa vstupn¡ho bodu SCREEN.OVL
         mov       ax,word ptr ds:[d_FDC7+2]; adresa vstupn¡ho bodu SCREEN.OVL
         inc       ax
         mov       word ptr ds:[d_FDC7+2],ax; adresa vstupn¡ho bodu SCREEN.OVL
l_97AB:  mov       ax,[bp-4Eh]
         mov       ds:[d_0262],ax           ; registr BX pro vol n¡ INT 21h
         mov       ax,[bp-50h]
         mov       ds:[d_0264],ax           ; registr CX pro vol n¡ INT 21h
         mov       ax,word ptr ds:[d_FDC7+2]; adresa vstupn¡ho bodu SCREEN.OVL
         mov       ds:[d_026E],ax           ; registr DS pro vol n¡ INT 21h
         mov       ax,0
         mov       ds:[d_0266],ax           ; registr DX pro vol n¡ INT 21h
         mov       ax,3Fh
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         mov       ax,ds:[d_0272]           ; registr p©¡znak– FLAG pro INT 21h
         and       ax,1
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         lea       di,[bp-4Eh]
         push      ss
         call      l_298A
         call      l_1003                   ; test, zda je nˆjak  chyba programu
l_97DD:  dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         jnz       l_97E6
         ;jmp       l_981F
         db        0e9h
         dw        l_981F-$-2

l_97E6:  call      l_24E9                   ; nastaven¡ stand. v˜stup. za©¡zen¡
         call      l_28D9                   ; zobrazen¡ textov‚ho ©etˆzce DOS
         db        39,'SCREEN.OVL nen¡ mo‘n‚ na‡¡st do pamˆti!'

         call      l_28F1                   ; od© dkov n¡ textu DOS
         call      l_1003                   ; test, zda je nˆjak  chyba programu
         xor       ax,ax
         jmp       near ptr l_0C6A

l_981F:  ;jmp       l_9822
         db        0e9h,0,0

l_9822:  mov       sp,bp
         pop       bp
         ret

l_962A   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KE a Maz n¡/cel˜ text (ukon‡en¡ editace souboru)
; -----------------------------------------------------------------------------

l_9826   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_982D
         db        0e9h,0,0

l_982D:  dec       sp
         call      l_725B                   ; ukon‡en¡ editace - zru¨en¡ souboru
         jnz       l_9836
         ;jmp       l_9839
         db        0e9h
         dw        l_9839-$-2

l_9836:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_9839:  ;jmp       l_983C
         db        0e9h,0,0

l_983C:  mov       sp,bp
         pop       bp
         ret

l_9826   ENDP

; -----------------------------------------------------------------------------
;        p©epnut¡ na nov˜ edita‡n¡ prostor
; -----------------------------------------------------------------------------

l_9840   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_9847
         db        0e9h,0,0

; ------ test, zda je po‘adovan˜ prostor ji‘ aktivn¡

l_9847:  mov       ax,[bp+4]                ; zadan˜ edita‡n¡ prostor
         cmp       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         mov       ax,1                     ; p©¡znak - prostor nen¡ aktivn¡
         jnz       l_9854                   ; je po‘adov n jin˜ prostor
         dec       ax                       ; p©¡znak - prostor je aktivn¡
l_9854:  push      ax

; ------ test, zda je zadan‚ platn‚ ‡¡slo prostoru

         mov       ax,[bp+4]                ; zadan˜ edita‡n¡ prostor
         cmp       ax,PROSTORU              ; je povolen‚ ‡¡slo prostoru ?
         mov       ax,1                     ; p©¡znak - ‡¡slo prostoru je OK
         jle       l_9861                   ; ‡¡slo prostoru je OK
         dec       ax                       ; p©¡znak - nepovolen‚ ‡¡slo
l_9861:  pop       cx

; ------ konec, je-li prostor ji‘ aktivn¡ nebo je neplatn‚ ‡¡slo

         and       ax,cx
         or        ax,ax
         jnz       l_986B
         ;jmp       l_98A6
         db        0e9h
         dw        l_98A6-$-2

l_986B:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         sub       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         push      ax
         mov       ax,[bp+4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         pop       ax
         add       ax,word ptr ds:[d_E69E+di] ; maxim ln¡ po‡et © dk– prostoru
         cmp       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         jl        l_988D
         ;jmp       l_9896
         db        0e9h
         dw        l_9896-$-2

l_988D:  mov       ax,6
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         ;jmp       l_98A6
         db        0e9h
         dw        l_98A6-$-2

l_9896:  call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,[bp+4]
         push      ax
         call      l_418B                   ; p©epnut¡ na nov˜ edita‡n¡ prostor
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_98A6:  ;jmp       l_98A9
         db        0e9h,0,0

l_98A9:  mov       sp,bp
         pop       bp
         ret       2

l_9840   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JB (p©epnut¡ hustoty © dkov n¡ displeje)
; -----------------------------------------------------------------------------

l_98AF   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_98B6
         db        0e9h,0,0

l_98B6:  mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         inc       ax
         mov       byte ptr cs:[l_3273],al  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         cmp       ax,4
         je        l_98CF
         ;jmp       l_98D6
         db        0e9h
         dw        l_98D6-$-2

l_98CF:  mov       ax,1
         mov       byte ptr cs:[l_3273],al  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
l_98D6:  mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3274]  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         call      l_35CE                   ; inicializace displeje
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_98FF
         ;jmp       l_9906
         db        0e9h
         dw        l_9906-$-2

l_98FF:  mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         mov       word ptr ds:[d_E69C],ax  ; ‡¡slo © dku kurzoru na obrazovce
l_9906:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_9912
         db        0e9h,0,0

l_9912:  mov       sp,bp
         pop       bp
         ret

l_98AF   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-JC a Displej/volba barev (volba barev displeje)
; -----------------------------------------------------------------------------

l_9916   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_99A3

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_991D   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9929
         db        0e9h,0,0

l_9929:  dec       sp
         dec       sp
l_992B:  mov       ax,10h
         mov       [bp-6],ax
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         sub       sp,9
         les       di,dword ptr [bp+4]
         mov       ax,es:[di]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4Ch
         push      ax
         mov       ax,[bp+8]
         push      ax                       ; pozice k zobrazen¡ textu
         mov       ax,2
         push      ax                       ; © dek k zobrazen¡
         mov       ax,10h
         push      ax                       ; typ znak– - ‡¡slice
         mov       di,offset d_F76E
         push      ds                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_996C
         ;jmp       l_996F
         db        0e9h
         dw        l_996F-$-2

l_996C:  ;jmp       l_999A
         db        0e9h
         dw        l_999A-$-2

l_996F:  mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         lea       di,[bp-6]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-8]
         push      ss
         call      l_0E68                   ; na‡ten¡ ‡¡sla INTEGER
         mov       ax,[bp-6]
         cmp       ax,10h
         jl        l_9991
         ;jmp       l_992B
         db        0e9h
         dw        l_992B-$-2

l_9991:  les       di,dword ptr [bp+4]
         mov       ax,[bp-6]
         mov       es:[di],ax
l_999A:  ;jmp       l_999D
         db        0e9h,0,0

l_999D:  mov       sp,bp
         pop       bp
         ret       6

l_991D   ENDP

; -----------------------------------------------------------------------------
;        pokra‡ov n¡ procedury l_9916
; -----------------------------------------------------------------------------

l_99A3:  sub       sp,6
         mov       ax,6
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       ax,4Ch
         push      ax
         mov       ax,8
         push      ax
         sub       sp,9
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       al,byte ptr cs:[l_3274]  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         xor       ah,ah
         mov       [bp-4],ax
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         mov       [bp-6],ax
         mov       ax,7
         push      ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_991D
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_99F4
         ;jmp       l_9A47
         db        0e9h
         dw        l_9A47-$-2

l_99F4:  mov       ax,8
         push      ax
         lea       di,[bp-6]
         push      ss
         push      di
         call      l_991D
         mov       ax,[bp-4]
         cmp       ax,[bp-6]
         mov       ax,1
         jnz       l_9A0C
         dec       ax
l_9A0C:  push      ax
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_9A1E
         ;jmp       l_9A47
         db        0e9h
         dw        l_9A47-$-2

l_9A1E:  mov       ax,[bp-4]
         mov       byte ptr cs:[l_3274],al  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         mov       ax,[bp-6]
         mov       byte ptr cs:[l_3275],al  ; barva podkladu-pozad¡ (0 a‘ 15)
         mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3274]  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         push      ax
         call      l_35CE                   ; inicializace displeje
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_9A47:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         ;jmp       l_9A4D
         db        0e9h,0,0

l_9A4D:  mov       sp,bp
         pop       bp
         ret

l_9916   ENDP

; *****************************************************************************
;
;                             Kalkul tor
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_9A51   db        '0123456789ABCDEF'

l_9A61   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_9A68
         db        0e9h,0,0

l_9A68:  lea       di,[bp+4]
         push      ss
         call      l_1950
         mov       ax,7FFFh
         call      l_1B0C
         call      l_1A53
         jnz       l_9A7D
         ;jmp       l_9A98
         db        0e9h
         dw        l_9A98-$-2

l_9A7D:  lea       di,[bp+4]
         push      ss
         push      di
         lea       di,[bp+4]
         push      ss
         call      l_1950
         call      l_195F
         db        91h,0,0,0,0,0

         call      l_199E
         call      l_1970
l_9A98:  lea       di,[bp+4]
         push      ss
         call      l_1950
l_9A9F:  call      l_1AD7
         mov       [bp+0Ah],ax
         ;jmp       l_9AA8
         db        0e9h,0,0

l_9AA8:  mov       ax,[bp+0Ah]
         mov       sp,bp
         pop       bp
         ret       8

l_9A61   ENDP

; -----------------------------------------------------------------------------
;        vy‡¡slen¡ matematick‚ho v˜razu
; -----------------------------------------------------------------------------

l_9AB1   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_A666

l_9AB1   ENDP

l_9AB8   db        ' ',254
         db        ' ',254
         db        ' ',254
         db        'E',254
         db        'PI',254
         db        '(',254
         db        ')',254
         db        ' ',254
         db        'NOT',254
         db        '+',254
         db        '-',254
         db        'AND',254
         db        'OR',254
         db        'XOR',254
         db        '*',254
         db        '/',254
         db        'DIV',254
         db        'MOD',254
         db        '^',254
         db        'DEG',254
         db        'RAD',254
         db        'SIN',254
         db        'COS',254
         db        'TAN',254
         db        'ARCSIN',254
         db        'ARCCOS',254
         db        'ARCTAN',254
         db        'LN',254
         db        'LOG',254
         db        'SQRT',254
         db        0

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_9B20   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9B2C
         db        0e9h,0,0

l_9B2C:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         je        l_9B37
         ;jmp       l_9B4A
         db        0e9h
         dw        l_9B4A-$-2

l_9B37:  mov       ax,32h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         mov       bx,[bp-2]
         les       di,dword ptr ss:[bx+4]
         mov       ax,[bp+4]
         mov       es:[di],ax
l_9B4A:  mov       ax,0
         mov       bx,[bp-2]
         mov       ss:[bx-9],al
         ;jmp       l_9B57
         db        0e9h,0,0

l_9B57:  mov       sp,bp
         pop       bp
         ret       2

l_9B20   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_9B5D   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9B69
         db        0e9h,0,0

l_9B69:  mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         dec       ax
         mov       bx,[bp-2]
         mov       ss:[bx-4],ax
         lea       di,[bp+4]
         push      ss
         push      di
         mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         shl       ax,1
         mov       cx,ax
         shl       ax,1
         add       ax,cx
         xchg      ax,di
         add       di,offset d_CD98         ; buffer seznamu soubor–
         push      ds
         call      l_1950
         call      l_1970
         ;jmp       l_9B9B
         db        0e9h,0,0

l_9B9B:  mov       sp,bp
         pop       bp
         ret

l_9B5D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_9B9F   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9BAB
         db        0e9h,0,0

l_9BAB:  lea       di,[bp+4]
         push      ss
         call      l_1950
         call      l_19E3
         mov       ax,1
         call      l_1B0C
         call      l_19EB
         jnz       l_9BC3
         ;jmp       l_9BE0
         db        0e9h
         dw        l_9BE0-$-2

l_9BC3:  lea       di,[bp+0Ah]
         push      ss
         push      di
         call      l_195F
         db        82h,21h,0a2h,0dah,0fh,49h

         mov       ax,2
         call      l_1B0C
         call      l_19BC
         call      l_1970
         ;jmp       l_9C0C
         db        0e9h
         dw        l_9C0C-$-2

l_9BE0:  lea       di,[bp+0Ah]
         push      ss
         push      di
         lea       di,[bp+4]
         push      ss
         call      l_1950
         mov       ax,1
         push      ax
         lea       di,[bp+4]
         push      ss
         call      l_1950
         call      l_1A87
         call      l_1B15
         call      l_199E
         call      l_1B2A
         call      l_19BC
         call      l_1D89
         call      l_1970
l_9C0C:  ;jmp       l_9C0F
         db        0e9h,0,0

l_9C0F:  mov       sp,bp
         pop       bp
         ret       6

l_9B9F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_9C15   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_9C21
         db        0e9h,0,0

l_9C21:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_9C2C
         ;jmp       l_9C2F
         db        0e9h
         dw        l_9C2F-$-2

l_9C2C:  jmp       l_A0F3

l_9C2F:  mov       al,[bp+4]
         xor       ah,ah
         cmp       ax,2
         je        l_9C3C
         ;jmp       l_9C89
         db        0e9h
         dw        l_9C89-$-2

l_9C3C:  mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         shl       ax,1
         mov       cx,ax
         shl       ax,1
         add       ax,cx
         xchg      ax,di
         add       di,offset d_CD98         ; buffer seznamu soubor–
         push      ds
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1970
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         call      l_1950
         call      l_1970
         mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         inc       ax
         mov       bx,[bp-2]
         mov       ss:[bx-4],ax
         jmp       l_A0F3

l_9C89:  cmp       ax,7
         je        l_9C91
         ;jmp       l_9CAE
         db        0e9h
         dw        l_9CAE-$-2

l_9C91:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_19D4
         call      l_1970
         jmp       l_A0F3

l_9CAE:  cmp       ax,8
         je        l_9CB6
         ;jmp       l_9CDA
         db        0e9h
         dw        l_9CDA-$-2

l_9CB6:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         not       ax
         call      l_1B0C
         call      l_1970
         ;jmp       l_A0F3
         db        0e9h
         dw        l_A0F3-$-2

l_9CDA:  cmp       ax,9
         je        l_9CE2
         ;jmp       l_9D05
         db        0e9h
         dw        l_9D05-$-2

l_9CE2:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         sub       sp,6
         call      l_9B5D
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1983
         call      l_1970
         jmp       l_A0F3

l_9D05:  cmp       ax,0Ah
         je        l_9D0D
         ;jmp       l_9D30
         db        0e9h
         dw        l_9D30-$-2

l_9D0D:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         sub       sp,6
         call      l_9B5D
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_199E
         call      l_1970
         jmp       l_A0F3

l_9D30:  cmp       ax,0Bh
         je        l_9D38
         ;jmp       l_9D69
         db        0e9h
         dw        l_9D69-$-2

l_9D38:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         sub       sp,6
         call      l_9B5D
         call      l_9A61
         push      ax
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         pop       cx
         and       ax,cx
         call      l_1B0C
         call      l_1970
         jmp       l_A0F3

l_9D69:  cmp       ax,0Ch
         je        l_9D71
         ;jmp       l_9DA2
         db        0e9h
         dw        l_9DA2-$-2

l_9D71:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         sub       sp,6
         call      l_9B5D
         call      l_9A61
         push      ax
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         pop       cx
         or        ax,cx
         call      l_1B0C
         call      l_1970
         jmp       l_A0F3

l_9DA2:  cmp       ax,0Dh
         je        l_9DAA
         ;jmp       l_9DDB
         db        0e9h
         dw        l_9DDB-$-2

l_9DAA:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         sub       sp,6
         call      l_9B5D
         call      l_9A61
         push      ax
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         pop       cx
         xor       ax,cx
         call      l_1B0C
         call      l_1970
         jmp       l_A0F3

l_9DDB:  cmp       ax,0Eh
         je        l_9DE3
         ;jmp       l_9E06
         db        0e9h
         dw        l_9E06-$-2

l_9DE3:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         sub       sp,6
         call      l_9B5D
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_19AD
         call      l_1970
         jmp       l_A0F3

l_9E06:  cmp       ax,0Fh
         je        l_9E0E
         ;jmp       l_9E31
         db        0e9h
         dw        l_9E31-$-2

l_9E0E:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         sub       sp,6
         call      l_9B5D
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_19BC
         call      l_1970
         jmp       l_A0F3

l_9E31:  cmp       ax,10h
         je        l_9E39
         ;jmp       l_9E6C
         db        0e9h
         dw        l_9E6C-$-2

l_9E39:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         sub       sp,6
         call      l_9B5D
         call      l_9A61
         push      ax
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         pop       cx
         xchg      ax,cx
         cwd       
         idiv      cx
         call      l_1B0C
         call      l_1970
         jmp       l_A0F3

l_9E6C:  cmp       ax,11h
         je        l_9E74
         ;jmp       l_9EA8
         db        0e9h
         dw        l_9EA8-$-2

l_9E74:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         dec       sp
         dec       sp
         sub       sp,6
         call      l_9B5D
         call      l_9A61
         push      ax
         dec       sp
         dec       sp
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9A61
         pop       cx
         xchg      ax,cx
         cwd       
         idiv      cx
         xchg      ax,dx
         call      l_1B0C
         call      l_1970
         jmp       l_A0F3

l_9EA8:  cmp       ax,12h
         je        l_9EB0
         ;jmp       l_9F1E
         db        0e9h
         dw        l_9F1E-$-2

l_9EB0:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         push      di
         sub       sp,6
         call      l_9B5D
         call      l_1970
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         call      l_1950
         mov       ax,0
         call      l_1B0C
         call      l_1A05
         jnz       l_9EDB
         ;jmp       l_9F09
         db        0e9h
         dw        l_9F09-$-2

l_9EDB:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Fh]
         push      ss
         call      l_1950
         call      l_1C30
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_19AD
         call      l_1CE0
l_9F03:  call      l_1970
         ;jmp       l_9F1B
         db        0e9h
         dw        l_9F1B-$-2

l_9F09:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       ax,0
         call      l_1B0C
         call      l_1970
l_9F1B:  jmp       l_A0F3

l_9F1E:  cmp       ax,13h
         je        l_9F26
         ;jmp       l_9F4C
         db        0e9h
         dw        l_9F4C-$-2

l_9F26:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_195F
         db        7bh,96h,12h,35h,0fah,0eh

         call      l_19BC
         call      l_1970
         jmp       l_A0F3

l_9F4C:  cmp       ax,14h
         je        l_9F54
         ;jmp       l_9F7A
         db        0e9h
         dw        l_9F7A-$-2

l_9F54:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_195F
         db        7bh,96h,12h,35h,0fah,0eh

         call      l_19AD
         call      l_1970
         jmp       l_A0F3

l_9F7A:  cmp       ax,15h
         je        l_9F82
         ;jmp       l_9F9F
         db        0e9h
         dw        l_9F9F-$-2

l_9F82:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1B9D
         call      l_1970
         jmp       l_A0F3

l_9F9F:  cmp       ax,16h
         je        l_9FA7
         ;jmp       l_9FC4
         db        0e9h
         dw        l_9FC4-$-2

l_9FA7:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1B88
         call      l_1970
         jmp       l_A0F3

l_9FC4:  cmp       ax,17h
         je        l_9FCC
         ;jmp       l_9FFA
         db        0e9h
         dw        l_9FFA-$-2

l_9FCC:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1B9D
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1B88
         call      l_19BC
         call      l_1970
         jmp       l_A0F3

l_9FFA:  cmp       ax,18h
         je        l_A002
         ;jmp       l_A022
         db        0e9h
         dw        l_A022-$-2

l_A002:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         sub       sp,6
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9B9F
         call      l_1970
         jmp       l_A0F3

l_A022:  cmp       ax,19h
         je        l_A02A
         ;jmp       l_A056
         db        0e9h
         dw        l_A056-$-2

l_A02A:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         call      l_195F
         db        81h,24h,0a2h,0dah,0fh,49h

         sub       sp,6
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_9B9F
         call      l_199E
         call      l_1970
         jmp       l_A0F3

l_A056:  cmp       ax,1Ah
         je        l_A05E
         ;jmp       l_A07B
         db        0e9h
         dw        l_A07B-$-2

l_A05E:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1D89
         call      l_1970
         ;jmp       l_A0F3
         db        0e9h
         dw        l_A0F3-$-2

l_A07B:  cmp       ax,1Bh
         je        l_A083
         ;jmp       l_A0A0
         db        0e9h
         dw        l_A0A0-$-2

l_A083:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1C30
         call      l_1970
         ;jmp       l_A0F3
         db        0e9h
         dw        l_A0F3-$-2

l_A0A0:  cmp       ax,1Ch
         je        l_A0A8
         ;jmp       l_A0D1
         db        0e9h
         dw        l_A0D1-$-2

l_A0A8:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1C30
         call      l_195F
         db        82h,0ach,0ddh,8dh,5dh,13h

         call      l_19BC
         call      l_1970
         ;jmp       l_A0F3
         db        0e9h
         dw        l_A0F3-$-2

l_A0D1:  cmp       ax,1Dh
         je        l_A0D9
         ;jmp       l_A0F3
         db        0e9h
         dw        l_A0F3-$-2

l_A0D9:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         push      di
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-15h]
         push      ss
         call      l_1950
         call      l_1B2A
         call      l_1970
l_A0F3:  ;jmp       l_A0F6
         db        0e9h,0,0

l_A0F6:  mov       sp,bp
         pop       bp
         ret       2

l_9C15   ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                              Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT BYTE PUBLIC

Data     ENDS
         END

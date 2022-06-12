
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; *****************************************************************************
;
;                      Obsluha bufferu textu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-] a Extra/do bufferu (p©enesen¡ textu do bufferu)
; -----------------------------------------------------------------------------

l_E013   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_E3B5

; -----------------------------------------------------------------------------
;        zobrazen¡ kurzoru k ozna‡en¡ textu pro ulo‘en¡ do bufferu
; -----------------------------------------------------------------------------

l_E01A   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E026
         db        0e9h
         dw        l_E026-$-2

l_E026:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         add       ax,cx
         push      ax                       ; pozice
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         push      ax                       ; © dek
         call      l_352A                   ; zobrazen¡ kurzoru
         ;jmp       l_E03E
         db        0e9h
         dw        l_E03E-$-2

l_E03E:  mov       sp,bp
         pop       bp
         ret

l_E01A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E042   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E04E
         db        0e9h
         dw        l_E04E-$-2

l_E04E:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       al,byte ptr ds:[d_ED59+di] ; buffer atribut– znak– text. © dku
         xor       ah,ah
         cmp       ax,40h
         jl        l_E065
         ;jmp       l_E094
         db        0e9h
         dw        l_E094-$-2

; ------ zv˜¨en¡ d‚lky textov‚ho © dku

l_E065:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         inc       ax
         mov       byte ptr ds:[d_EC59],al  ; d‚lka textov‚ho © dku

; ------ doplnˆn¡ mezery na konec textov‚ho © dku

         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       ax," "
         mov       byte ptr ds:[d_EC59+di],al ; buffer textov‚ho © dku

         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         push      di
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         dec       ax
         xchg      ax,di
         mov       al,byte ptr ds:[d_ED59+di] ; buffer atribut– znak– text. © dku
         xor       ah,ah
         pop       di
         mov       byte ptr ds:[d_ED59+di],al ; buffer atribut– znak– text. © dku
l_E094:  mov       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-4],ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-6]
         jg        l_E0AD
         ;jmp       l_E0B9
         db        0e9h
         dw        l_E0B9-$-2

l_E0AD:  mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-4]
         push      ss
         push      di
         call      l_384B
l_E0B9:  ;jmp       l_E0BC
         db        0e9h
         dw        l_E0BC-$-2

l_E0BC:  mov       sp,bp
         pop       bp
         ret

l_E042   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E0C0   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E0CC
         db        0e9h
         dw        l_E0CC-$-2

l_E0CC:  mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,0FEh
         mov       ax,1
         jl        l_E0DA
         dec       ax

l_E0DA:  push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         cmp       ax,11h
         mov       ax,1
         jnz       l_E0EE
         dec       ax

l_E0EE:  push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         cmp       ax,0
         mov       ax,1
         jz        l_E0FB
         dec       ax
l_E0FB:  pop       cx
         or        ax,cx
         pop       cx
         and       ax,cx
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         mov       ax,1
         jl        l_E115
         dec       ax
l_E115:  push      ax
         dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         call      l_3D1C                   ; test, zda je © dek definov n
         xor       al,1
         pop       cx
         or        ax,cx
         pop       cx
         and       ax,cx
         mov       bx,[bp-2]
         mov       ss:[bx-14h],al
         mov       bx,[bp-2]
         mov       al,ss:[bx-14h]
         xor       ah,ah
         or        ax,ax
         jnz       l_E13E
         ;jmp       l_E19F
         db        0e9h
         dw        l_E19F-$-2

l_E13E:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         inc       ax                       ; zv˜¨en¡ pozice kurzoru na © dku
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku

         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax                       ; pozice kurzoru na © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_E157
         ;jmp       l_E167
         db        0e9h
         dw        l_E167-$-2

l_E157:  call      l_5CE8                   ; posun kurzoru o © dek dol– Ctrl-X
         call      l_E042
         mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku

l_E167:  call      l_E01A                   ; zobrazen¡ kurzoru
         mov       al,ds:[d_F059]
         xor       ah,ah
         inc       ax
         mov       ds:[d_F059],al
         mov       al,ds:[d_F059]
         xor       ah,ah
         xchg      ax,di
         push      di
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         xchg      ax,di
         mov       al,byte ptr ds:[d_EC59+di] ; buffer textov‚ho © dku
         xor       ah,ah
         pop       di
         mov       ds:[d_F059+di],al
         mov       al,ds:[d_F059]
         xor       ah,ah
         xchg      ax,di
         push      di
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         xchg      ax,di
         mov       al,byte ptr ds:[d_ED59+di] ; buffer atribut– znak– text. © dku
         xor       ah,ah
         pop       di
         mov       byte ptr ds:[d_F159+di],al
l_E19F:  ;jmp       l_E1A2
         db        0e9h
         dw        l_E1A2-$-2

l_E1A2:  mov       sp,bp
         pop       bp
         ret

l_E0C0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E1A6   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E1B2
         db        0e9h
         dw        l_E1B2-$-2

l_E1B2:  mov       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-14h],al
         mov       al,ds:[d_F059]
         xor       ah,ah
         cmp       ax,1
         jg        l_E1C9
         ;jmp       l_E1F9
         db        0e9h
         dw        l_E1F9-$-2

l_E1C9:  call      l_E01A                   ; zobrazen¡ kurzoru
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         dec       ax
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-4]
         jl        l_E1E2
         ;jmp       l_E1F0
         db        0e9h
         dw        l_E1F0-$-2

l_E1E2:  call      l_5C8B                   ; posun kurzoru o © dek nahoru CtrlE
         call      l_E042
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
l_E1F0:  mov       al,ds:[d_F059]
         xor       ah,ah
         dec       ax
         mov       ds:[d_F059],al
l_E1F9:  ;jmp       l_E1FC
         db        0e9h
         dw        l_E1FC-$-2

l_E1FC:  mov       sp,bp
         pop       bp
         ret

l_E1A6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E200   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E20C
         db        0e9h
         dw        l_E20C-$-2

l_E20C:  cmp       byte ptr ds:[d_F78A],0   ; 1=p©¡znak p©eru¨en¡ editace volby
         je        l_E215
         jmp       short l_E28E

l_E215:  push      ds
         pop       es
         cld       
         mov       di,offset d_EE59         ; buffer textu
         mov       si,offset d_F059
         mov       cl,[si]
         mov       ch,0
         push      cx
         inc       cx
         repne     movsb
         pop       cx
         mov       di,offset d_EF59+1
         mov       si,offset d_F159+1
         push      cx
         repne     movsb
         pop       cx
         mov       si,offset d_EE59         ; buffer textu
         mov       di,offset d_EF59
         mov       bx,1
l_E23A:  mov       al,[bx+si]
         cmp       al,0FFh
         je        l_E26A
         cmp       al,20h
         jae       l_E24B
         cmp       al,15h
         je        l_E287
         mov       byte ptr [bx+si],20h
l_E24B:  test      byte ptr [bx+di],40h
         jz        l_E287
         cmp       al,2Dh
         jne       l_E287
         or        byte ptr [bx+di-1],40h
         mov       al,[bx+si-1]
         mov       ah,[bx+si+1]
         or        ax,2020h
         cmp       ax,6B6Bh
         jne       l_E26A
         sub       byte ptr [bx+si-1],8
l_E26A:  push      si
         push      di
         push      cx
         add       si,bx
         add       di,bx
         sub       cx,bx
         cld       
         push      di
         push      cx
         mov       di,si
         inc       si
         repne     movsb
         pop       cx
         pop       di
         mov       si,di
         inc       si
         repne     movsb
         pop       cx
         pop       di
         pop       si
         dec       cx
         dec       bx
l_E287:  inc       bx
         cmp       bx,cx
         jbe       l_E23A
         mov       [si],cl
l_E28E:  cmp       byte ptr ds:[d_F059],1
         jbe       l_E29A
         call      l_E1A6
         jmp       short l_E28E

l_E29A:  call      l_E01A                   ; zobrazen¡ kurzoru
         mov       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-13h],al
         ;jmp       l_E2AA
         db        0e9h
         dw        l_E2AA-$-2

l_E2AA:  mov       sp,bp
         pop       bp
         ret

l_E200   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E2AE   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E2BA
         db        0e9h
         dw        l_E2BA-$-2

l_E2BA:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         mov       ss:[bx-0Ah],ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       bx,[bp-2]
         mov       ss:[bx-0Ch],ax
         call      l_E200
l_E2D1:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-0Ah]
         je        l_E2E0
         ;jmp       l_E2F1
         db        0e9h
         dw        l_E2F1-$-2

l_E2E0:  mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ch]
         mov       bx,[bp-2]
         mov       ss:[bx-10h],ax
         ;jmp       l_E2FD
         db        0e9h
         dw        l_E2FD-$-2

l_E2F1:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         mov       bx,[bp-2]
         mov       ss:[bx-10h],ax
l_E2FD:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-6]
         je        l_E30C
         ;jmp       l_E31D
         db        0e9h
         dw        l_E31D-$-2

l_E30C:  mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         mov       bx,[bp-2]
         mov       ss:[bx-0Eh],ax
         ;jmp       l_E333
         db        0e9h
         dw        l_E333-$-2

l_E31D:  mov       ax,1
         mov       bx,[bp-2]
         mov       ss:[bx-0Eh],ax
         mov       bx,[bp-2]
         db        36h                      ;! prefix SS:
         lea       di,[bx-0Eh]
         push      ss
         push      di
         call      l_384B
l_E333:  mov       bx,[bp-2]
         mov       ax,ss:[bx-0Eh]
         push      ax
         mov       bx,[bp-2]
         mov       ax,ss:[bx-10h]
         mov       bx,[bp-2]
         sub       ax,ss:[bx-0Eh]
         add       ax,1
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         cmp       ax,0
         je        l_E360
         ;jmp       l_E375
         db        0e9h
         dw        l_E375-$-2

l_E360:  call      l_6144
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ah]
         dec       ax
         mov       bx,[bp-2]
         mov       ss:[bx-0Ah],ax
         ;jmp       l_E387
         db        0e9h
         dw        l_E387-$-2

l_E375:  mov       bx,[bp-2]
         mov       ax,ss:[bx-0Eh]
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim ln¡ d‚lka © dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         call      l_5CE8                   ; posun kurzoru o © dek dol– Ctrl-X
l_E387:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-0Ah]
         jg        l_E399
         jmp       l_E2D1

l_E399:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         cmp       ax,ss:[bx-6]
         jg        l_E3A8
         ;jmp       l_E3AE
         db        0e9h
         dw        l_E3AE-$-2

l_E3A8:  call      l_5C8B                   ; posun kurzoru o © dek nahoru CtrlE
         ;jmp       l_E399
         db        0e9h
         dw        l_E399-$-2

l_E3AE:  ;jmp       l_E3B1
         db        0e9h
         dw        l_E3B1-$-2

l_E3B1:  mov       sp,bp
         pop       bp
         ret

l_E2AE   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_E013)
; -----------------------------------------------------------------------------

l_E3B5:  sub       sp,12h
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_E3D0
         ;jmp       l_E3D3
         db        0e9h
         dw        l_E3D3-$-2

l_E3D0:  jmp       l_E536

l_E3D3:  mov       al,byte ptr cs:[l_3277]  ; n povˆda (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_E3E0
         ;jmp       l_E42D
         db        0e9h
         dw        l_E42D-$-2

l_E3E0:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,0Eh
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        54,'P©enesen¡ textu = <Enter>, p©enesen¡ + maz n¡ = <Del>.'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
l_E42D:  jmp       l_E4C3

l_E430   db        1                        ; Ctrl-A
         db        4                        ; Ctrl-D
         db        6                        ; Ctrl-F
         db        7                        ; Ctrl-G
         db        8                        ; Ctrl-H
         db        13                       ; Enter (Ctrl-M)
         db        19                       ; Ctrl-S
         db        27                       ; Esc
         db        29                       ; Ctrl-]
         db        30                       ; Ctrl-^
         db        84h                      ;
         db        87h                      ;
         db        88h                      ;
         db        8Dh                      ;
         db        93h                      ;
         db        9Bh                      ;
         db        0B6h                     ;
         db        0B4h                     ;
         db        0

l_E443   dw        l_E47E                   ; Ctrl-A
l_E445   dw        l_E0C0                   ; Ctrl-D
l_E447   dw        l_E4A8                   ; Ctrl-F
l_E449   dw        l_E2AE                   ; Ctrl-G
l_E44B   dw        l_E2AE                   ; Ctrl-H
l_E44D   dw        l_E200                   ; Enter (Ctrl-M
l_E44F   dw        l_E1A6                   ; Ctrl-S
l_E451   dw        l_E200                   ; Esc
l_E453   dw        l_E4A8                   ; Ctrl-]
l_E455   dw        l_E47E                   ; Ctrl-^
l_E457   dw        l_E4A8                   ;
l_E459   dw        l_E2AE                   ;
l_E45B   dw        l_E2AE                   ;
l_E45D   dw        l_E200                   ;
l_E45F   dw        l_E47E                   ;
l_E461   dw        l_E200                   ;
l_E463   dw        l_E4A8                   ;
l_E465   dw        l_E47E                   ;

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E467   PROC      NEAR

         cmp       byte ptr ds:[bx+di],15h
         jz        l_E46F
         cmp       byte ptr ds:[bx+di],21h
l_E46F:  ret

l_E467   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E470   PROC      NEAR

         call      l_E1A6
l_E473:  mov       di,offset d_F059
         mov       bl,[di]
         mov       bh,0
         cmp       bl,1
         ret

l_E470   ENDP

; -----------------------------------------------------------------------------
;        Obsluha kl vesy Ctrl-A (slovo vlevo)
; -----------------------------------------------------------------------------

l_E47E   PROC      NEAR

         call      l_E473
         jbe       l_E498
l_E483:  call      l_E467
         jc        l_E493
         call      l_E470
         ja        l_E483
         ret

l_E47E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E48E   PROC      NEAR

         call      l_E467
         jnc       l_E498
l_E493:  call      l_E470
         ja        l_E48E
l_E498:  ret

l_E48E   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E499   PROC      NEAR

         call      l_E0C0
l_E49C:  mov       di,offset d_F059
         mov       bl,[di]
         mov       bh,0
         ;cmp       bh,[bp-14h]
         db        3Ah,0BEh,0ECh,0FFh       ;!
         ret

l_E499   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E4A8   PROC      NEAR

         call      l_E49C
         jz        l_E4C2
l_E4AD:  call      l_E467
         jnc       l_E4BD
         call      l_E499
         jnz       l_E4AD
         ret

l_E4A8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E4B8   PROC      NEAR

         call      l_E467
         jc        l_E4C2
l_E4BD:  call      l_E499
         jnz       l_E4B8
l_E4C2:  ret

l_E4B8   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_E013)
; -----------------------------------------------------------------------------

l_E4C3:  call      l_E042
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         ;mov       [bp-6],ax
         db        89h,86h,0FAh,0FFh        ;!
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         ;mov       [bp-8],ax
         db        89h,86h,0F8h,0FFh        ;!
         dec       word ptr ds:[d_E69A]     ; pozice kurzoru na © dku
         xor       ax,ax
         ;mov       [bp-13h],al
         db        88h,86h,0EDh,0FFh        ;!
l_E4DE:  mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         mov       ds:[d_F059],al
         inc       ax
         ;mov       [bp-14h],al
         db        88h,86h,0ECh,0FFh        ;!
         ;mov       [bp-4],ax
         db        89h,86h,0FCh,0FFh        ;!
         call      l_E4A8
l_E4F0:  dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         cmp       al,1Bh
         jne       l_E4FE
         mov       byte ptr ds:[d_F78A],1   ; 1=p©¡znak p©eru¨en¡ editace volby
l_E4FE:  push      ax
         mov       ah,2
         int       16h
         and       al,3
         pop       ax
         jz        l_E50A
         or        al,80h
l_E50A:  mov       si,offset l_E430
         xor       bx,bx
l_E50F:  mov       cl,cs:[bx+si]
         or        cl,cl
         jz        l_E524
         cmp       al,cl
         je        l_E51D
         inc       bx
         jmp       short l_E50F

l_E51D:  shl       bx,1
         call      word ptr cs:[l_E443+bx]
l_E524:  ;cmp       byte ptr [bp-13h],0
         db        80h,0BEh,0EDh,0FFh,0     ;!
         je        l_E4F0
         cmp       byte ptr cs:[l_3277],0   ; n povˆda (1=zap., 0=vyp.)
         je        l_E536
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_E536:  ;jmp       l_E539
         db        0e9h
         dw        l_E539-$-2

l_E539:  mov       sp,bp
         pop       bp
         ret

l_E013   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-^ a Extra/z bufferu (p©enesen¡ textu z bufferu)
; -----------------------------------------------------------------------------

l_E53D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_E544
         db        0e9h
         dw        l_E544-$-2

l_E544:  dec       sp
         dec       sp
         mov       ax,1
         push      ax
         mov       al,byte ptr ds:[d_EE59]  ; buffer textu
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_E558
         ;jmp       l_E580
         db        0e9h
         dw        l_E580-$-2

l_E558:  inc       cx
         mov       [bp-4],ax
l_E55C:  push      cx
         mov       ax,[bp-4]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EE59+di] ; buffer textu
         xor       ah,ah
         push      ax
         mov       ax,[bp-4]
         xchg      ax,di
         mov       al,byte ptr ds:[d_EF59+di]
         xor       ah,ah
         push      ax
         call      l_DD08
         pop       cx
         dec       cx
         jz        l_E580
         inc       word ptr [bp-4]
         ;jmp       l_E55C
         db        0e9h
         dw        l_E55C-$-2

l_E580:  ;jmp       l_E583
         db        0e9h
         dw        l_E583-$-2

l_E583:  mov       sp,bp
         pop       bp
         ret

l_E53D   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E587   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_E625

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E58E   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E59A
         db        0e9h
         dw        l_E59A-$-2

l_E59A:  dec       sp
         dec       sp
l_E59C:  les       di,dword ptr [bp+0Ch]
         mov       ax,0
         mov       es:[di],ax
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         sub       sp,9
         mov       ax,[bp+0Ah]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4Bh
         push      ax                       ; pozice k zobrazen¡ textu
         mov       ax,[bp+8]
         push      ax                       ; © dek k zobrazen¡
         mov       ax,4
         push      ax                       ; maxim ln¡ d‚lka textu
         mov       ax,10h
         push      ax                       ; typ znak– - ‡¡slice
         mov       di,offset d_F76E
         push      ds                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_E5DD
         ;jmp       l_E5E0
         db        0e9h
         dw        l_E5E0-$-2

l_E5DD:  ;jmp       l_E61C
         db        0e9h
         dw        l_E61C-$-2

l_E5E0:  mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         les       di,dword ptr [bp+0Ch]
         push      es
         push      di
         lea       di,[bp-6]
         push      ss
         call      l_0E68                   ; na‡ten¡ ‡¡sla INTEGER
         les       di,dword ptr [bp+0Ch]
         mov       ax,es:[di]
         cmp       ax,[bp+6]
         mov       ax,1
         jge       l_E602
         dec       ax
l_E602:  push      ax
         les       di,dword ptr [bp+0Ch]
         mov       ax,es:[di]
         cmp       ax,[bp+4]
         mov       ax,1
         jle       l_E612
         dec       ax
l_E612:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_E61C
         ;jmp       l_E59C
         db        0e9h
         dw        l_E59C-$-2

l_E61C:  ;jmp       l_E61F
         db        0e9h
         dw        l_E61F-$-2

l_E61F:  mov       sp,bp
         pop       bp
         ret       0Ch

l_E58E   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_E587)
; -----------------------------------------------------------------------------

l_E625:  sub       sp,0Ah
         dec       sp
         call      l_4EAB                   ; test p©ipravenosti tisk rny
         xor       al,1
         jnz       l_E633
         ;jmp       l_E653
         db        0e9h
         dw        l_E653-$-2

l_E633:  mov       ax,0Ch
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         dec       sp
         call      l_4EAB                   ; test p©ipravenosti tisk rny
         xor       al,1
         jnz       l_E64A
         ;jmp       l_E653
         db        0e9h
         dw        l_E653-$-2

l_E64A:  mov       ax,1
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         jmp       l_E72E

l_E653:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,0Bh
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         dec       ax
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         inc       ax
         mov       [bp-4],ax
         mov       ax,4Bh
         push      ax
         mov       ax,7
         push      ax
         sub       sp,9
         mov       ax,[bp-4]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         lea       di,[bp-6]
         push      ss
         push      di
         mov       ax,1
         push      ax
         mov       ax,6
         push      ax
         mov       ax,1
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_E58E
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_E6A8
         ;jmp       l_E6C0
         db        0e9h
         dw        l_E6C0-$-2

l_E6A8:  lea       di,[bp-8]
         push      ss
         push      di
         mov       ax,[bp-4]
         push      ax
         mov       ax,7
         push      ax
         mov       ax,[bp-6]
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_E58E
l_E6C0:  mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_E6CC
         ;jmp       l_E6E4
         db        0e9h
         dw        l_E6E4-$-2

l_E6CC:  lea       di,[bp-0Ah]
         push      ss
         push      di
         mov       ax,1
         push      ax
         mov       ax,8
         push      ax
         mov       ax,1
         push      ax
         mov       ax,270Fh
         push      ax
         call      l_E58E
l_E6E4:  mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_E6F0
         ;jmp       l_E708
         db        0e9h
         dw        l_E708-$-2

l_E6F0:  lea       di,[bp-0Ch]
         push      ss
         push      di
         mov       ax,1
         push      ax
         mov       ax,9
         push      ax
         mov       ax,1
         push      ax
         mov       ax,270Fh
         push      ax
         call      l_E58E
l_E708:  mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_E714
         ;jmp       l_E727
         db        0e9h
         dw        l_E727-$-2

l_E714:  mov       ax,[bp-6]
         push      ax
         mov       ax,[bp-8]
         push      ax
         mov       ax,[bp-0Ah]
         push      ax
         mov       ax,[bp-0Ch]
         push      ax
         call      l_5317
l_E727:  mov       ax,0Bh
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
l_E72E:  ;jmp       l_E731
         db        0e9h
         dw        l_E731-$-2

l_E731:  mov       sp,bp
         pop       bp
         ret

l_E587   ENDP

; *****************************************************************************
;
;                   Obsluha s‚riov‚ho tisku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        S‚riov˜ tisk textu
; -----------------------------------------------------------------------------

l_E735   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_E7C3

l_E73C   db        4Eh                ; Data table (indexed access)
         db        4Ah

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_E73E   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_E74A
         db        0e9h
         dw        l_E74A-$-2

l_E74A:  mov       bx,[bp-2]
         mov       ax,ss:[bx-0Eh]
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_E764
         ;jmp       l_E7BC
         db        0e9h
         dw        l_E7BC-$-2

l_E764:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-6],ax
l_E76C:  push      cx
         mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         push      ax
         call      l_3A2E                   ; uvolnˆn¡ © dku z pamˆti
         mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         mov       bx,[bp-2]
         add       ax,ss:[bx-0Ch]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       bx,[bp-2]
         mov       ax,ss:[bx-6]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_3C8D
         pop       cx
         dec       cx
         jz        l_E7BC
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-6]
         ;jmp       l_E76C
         db        0e9h
         dw        l_E76C-$-2

l_E7BC:  ;jmp       l_E7BF
         db        0e9h
         dw        l_E7BF-$-2

l_E7BF:  mov       sp,bp
         pop       bp
         ret

l_E73E   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_E735)
; -----------------------------------------------------------------------------

l_E7C3:  sub       sp,0Eh
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         push      ax
         mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         sub       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         sub       ax,0Ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_E7DD
         ;jmp       l_E7E9
         db        0e9h
         dw        l_E7E9-$-2

l_E7DD:  mov       ax,6
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         jmp       l_ED0E

l_E7E9:  dec       sp
         call      l_4EAB                   ; test p©ipravenosti tisk rny
         xor       al,1
         jnz       l_E7F4
         ;jmp       l_E814
         db        0e9h
         dw        l_E814-$-2

l_E7F4:  mov       ax,0Ch
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         dec       sp
         call      l_4EAB                   ; test p©ipravenosti tisk rny
         xor       al,1
         jnz       l_E80B
         ;jmp       l_E814
         db        0e9h
         dw        l_E814-$-2

l_E80B:  mov       ax,1
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         jmp       l_ED0E

l_E814:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         inc       ax
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,5
         jg        l_E82C
         ;jmp       l_E832
         db        0e9h
         dw        l_E832-$-2

l_E82C:  mov       ax,1
         mov       [bp-8],ax
l_E832:  mov       ax,18h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       al,byte ptr cs:[l_3266]
         xor       ah,ah
         xchg      ax,di
         mov       al,cs:[l_E73C+di]
         xor       ah,ah
         push      ax                       ; znak
         mov       ax,4Dh
         push      ax                       ; pozice
         mov       ax,7
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
l_E853:  mov       ax,0
         mov       [bp-4],ax
         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         sub       sp,9
         mov       ax,[bp-8]
         push      ax
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4Dh
         push      ax                       ; pozice k zobrazen¡ textu
         mov       ax,6
         push      ax                       ; © dek k zobrazen¡
         mov       ax,1
         push      ax                       ; maxim ln¡ d‚lka textu
         mov       ax,10h
         push      ax                       ; typ znak– - ‡¡slice
         mov       di,offset d_F76E
         push      ds                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         lea       di,[bp-4]
         push      ss
         push      di
         lea       di,[bp-6]
         push      ss
         call      l_0E68                   ; na‡ten¡ ‡¡sla INTEGER
         mov       ax,[bp-4]
         cmp       ax,0
         mov       ax,1
         jg        l_E8A4
         dec       ax
l_E8A4:  push      ax
         mov       ax,[bp-4]
         cmp       ax,5
         mov       ax,1
         jle       l_E8B1
         dec       ax
l_E8B1:  pop       cx
         and       ax,cx
         push      ax
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_E8C4
         ;jmp       l_E853
         db        0e9h
         dw        l_E853-$-2

l_E8C4:  mov       ax,[bp-4]
         mov       [bp-8],ax
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_E8D6
         ;jmp       l_E941
         db        0e9h
         dw        l_E941-$-2

l_E8D6:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       al,byte ptr cs:[l_3266]
         xor       ah,ah
         xchg      ax,di
         mov       al,cs:[l_E73C+di]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,4Dh
         push      ax                       ; pozice k zobrazen¡ textu
         mov       ax,7                     
         push      ax                       ; © dek k zobrazen¡
         mov       ax,1                     
         push      ax                       ; maxim ln¡ d‚lka textu
         mov       ax,20h                   
         push      ax                       ; typ znak– - volba s‚riov‚ho tisku
         mov       di,offset d_F76E         
         push      ds                       ; adresa bufferu k ulo‘en¡ textu
         push      di                       
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru
         mov       di,offset d_F76E
         push      ds
         push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         mov       al,byte ptr cs:[l_3266]
         xor       ah,ah
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,4A01h
         push      ax
         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         pop       cx
         or        ax,cx
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,4E01h
         push      ax
         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         pop       cx
         and       ax,cx
         mov       byte ptr cs:[l_3266],al
l_E941:  mov       ax,18h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_E954
         ;jmp       l_E957
         db        0e9h
         dw        l_E957-$-2

l_E954:  jmp       l_ED0E

l_E957:  mov       di,offset d_F76E
         push      ds
         push      di
         sub       sp,0Fh                   ; lok ln¡ buffer k dek¢dov n¡
         call      l_64D0                   ; dek¢dov n¡ syst‚mov‚ho data
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       al,byte ptr ds:[d_E6A8]  ; 0=p©¡znak modifikace textu
         xor       ah,ah
         mov       [bp-0Fh],al
         mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         sub       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       [bp-0Ch],ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       [bp-0Eh],ax
         mov       ax,[bp-8]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_E69E+di] ; maxim ln¡ po‡et © dk– prostoru
         mov       [bp-0Ah],ax
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_E99F
         ;jmp       l_E9D8
         db        0e9h
         dw        l_E9D8-$-2

l_E99F:  inc       cx
         mov       [bp-6],ax
l_E9A3:  push      cx
         mov       ax,[bp-6]
         add       ax,ds:[d_F7A5]           ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       ax,[bp-6]
         add       ax,[bp-0Ch]
         add       ax,ds:[d_F7A5]           ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_3C8D
         pop       cx
         dec       cx
         jz        l_E9D8
         inc       word ptr [bp-6]
         ;jmp       l_E9A3
         db        0e9h
         dw        l_E9A3-$-2

l_E9D8:  mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_E9E3
         ;jmp       l_E9E6
         db        0e9h
         dw        l_E9E6-$-2

l_E9E3:  jmp       l_ECD4

l_E9E6:  mov       ax,1
         push      ax
         mov       ax,[bp-0Ah]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_E9F6
         jmp       l_ECD1

l_E9F6:  inc       cx
         mov       [bp-4],ax
l_E9FA:  push      cx
         mov       ax,[bp-4]
         push      ax
         dec       sp
         dec       sp
         mov       ax,[bp-8]
         push      ax
         call      l_4167                   ; po‡et © dk– p©ed zadan˜m prostorem
         pop       cx
         add       ax,cx
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       di,offset d_F059
         push      ds
         push      di
         call      l_3EB2                   ; na‡ten¡ textu © dku do bufferu
         mov       ax,1
         push      ax
         mov       ax,[bp-0Eh]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_EA2E
         jmp       l_EBA7

l_EA2E:  inc       cx
         mov       [bp-6],ax
l_EA32:  push      cx
         mov       ax,[bp-6]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_3EDF                   ; na‡ten¡ textu © dku do bufferu
         jmp       l_EAF3

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EA42   PROC      NEAR

         mov       cl,[di]
         mov       ch,0
         dec       cx
         jle       l_EA5F
         mov       bx,1
l_EA4C:  cmp       byte ptr [bx+di],40h
         jne       l_EA5C
         mov       al,[bx+di+1]
         sub       al,30h
         jc        l_EA5C
         cmp       al,0Ah
         jb        l_EA61
l_EA5C:  inc       bx
         loop      l_EA4C
l_EA5F:  xor       ax,ax
l_EA61:  ret

l_EA42   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EA62   PROC      NEAR

         mov       cl,[di]
         mov       ch,0
         dec       cx
         dec       cx
         mov       [di],cl
         inc       cx
         sub       cx,bx
         push      di
         add       di,bx
         mov       si,di
         inc       si
         inc       si
         cld       
         repne     movsb
         pop       di
         ret

l_EA62   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EA79   PROC      NEAR

         cmp       ah,[bx+si]
         je        l_EA81
         inc       bx
         loop      l_EA79
         inc       cx
l_EA81:  inc       bx
         dec       cx
         ret

l_EA79   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EA84   PROC      NEAR

         push      bx
         mov       cl,[si]
         mov       ch,0
         jcxz      l_EAC1
         mov       bx,1
l_EA8E:  dec       al
         jz        l_EAAA
         mov       ah,22h
         cmp       ah,[bx+si]
         jne       l_EAA1
         inc       bx
         dec       cx
         jcxz      l_EAC1
         call      l_EA79
         jcxz      l_EAC1
l_EAA1:  mov       ah,2Ch
         call      l_EA79
         jcxz      l_EAC1
         jmp       short l_EA8E

l_EAAA:  mov       ah,2Ch
         cmp       byte ptr [bx+si],22h
         jne       l_EAB7
         inc       bx
         dec       cx
         jcxz      l_EAC1
         mov       ah,22h
l_EAB7:  mov       dx,bx
         call      l_EA79
         dec       bx
         mov       cx,bx
         sub       cx,dx
l_EAC1:  pop       bx
         ret

l_EA84   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EAC3   PROC      NEAR

         mov       al,[di]
         mov       ah,0
         add       al,cl
         jc        l_EAED
         mov       [di],al
         sub       al,cl
         push      si
         push      di
         push      cx
         add       di,ax
         mov       si,di
         add       di,cx
         mov       cx,ax
         sub       cx,bx
         inc       cx
         std       
         repne     movsb
         pop       cx
         pop       di
         pop       si
         push      di
         add       si,dx
         add       di,bx
         cld       
         repne     movsb
         pop       di
         ret

l_EAED:  mov       byte ptr ds:[d_F79D],8   ; k¢d chyby KonTextu
         ret

l_EAC3   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_E735)
; -----------------------------------------------------------------------------

l_EAF3:  push      ds
         pop       es
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      word ptr [di]
l_EAFA:  call      l_EA42
         jz        l_EB1F
         call      l_EA62
         or        al,al
         jnz       l_EB12
         mov       si,offset d_F76E
         mov       cl,[si]
         mov       ch,0
         mov       dx,1
         jmp       short l_EB1A

l_EB12:  mov       si,offset d_F059
         call      l_EA84
         jcxz      l_EAFA
l_EB1A:  call      l_EAC3
         jnc       l_EAFA
l_EB1F:  pop       ax
         xor       ah,ah
         or        al,al
         jz        l_EB43
         mov       cl,[di]
         mov       ch,0
         jcxz      l_EB41
l_EB2C:  inc       di
         mov       al,[di]
         cmp       al,20h
         ja        l_EB43
         cmp       al,15h
         je        l_EB43
         cmp       al,10h
         je        l_EB43
         cmp       al,1Fh
         je        l_EB43
         loop      l_EB2C
l_EB41:  inc       ah
l_EB43:  ;mov       [bp-10h],ah
         db        88h,0A6h,0F0h,0FFh       ;!
         mov       al,[bp-10h]
         xor       ah,ah
         or        ax,ax
         jnz       l_EB53
         ;jmp       l_EB83
         db        0e9h
         dw        l_EB83-$-2

l_EB53:  mov       ax,[bp-6]
         push      ax
         mov       ax,1
         push      ax
         call      l_3C04
         mov       ax,[bp-6]
         dec       ax
         mov       [bp-6],ax
         mov       ax,word ptr ds:[d_F7A9]  ; po‡et © dk– na str nku bez okraj–
         push      ax
         mov       ax,[bp-6]
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         inc       ax
         pop       cx
         imul      cx
         push      ax
         mov       ax,1
         push      ax
         call      l_3B6A
         call      l_399E                   ; test, zda m  soubor nˆjak˜ © dek
         ;jmp       l_EB8F
         db        0e9h
         dw        l_EB8F-$-2

l_EB83:  mov       ax,[bp-6]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_3DC5                   ; ulo‘en¡ textu © dku do souboru
l_EB8F:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_EB9A
         ;jmp       l_EB9D
         db        0e9h
         dw        l_EB9D-$-2

l_EB9A:  jmp       l_ED11

l_EB9D:  pop       cx
         dec       cx
         jz        l_EBA7
         inc       word ptr [bp-6]
         jmp       l_EA32

l_EBA7:  mov       ax,1
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,1
         mov       word ptr ds:[d_E69C],ax  ; ‡¡slo © dku kurzoru na obrazovce
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         mov       al,byte ptr cs:[l_3266]
         xor       ah,ah
         or        ax,ax
         jnz       l_EBC3
         ;jmp       l_EBE8
         db        0e9h
         dw        l_EBE8-$-2

l_EBC3:  call      l_D297
         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         push      ax
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         jnz       l_EBD8
         dec       ax
l_EBD8:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_EBE2
         ;jmp       l_EBE5
         db        0e9h
         dw        l_EBE5-$-2

l_EBE2:  jmp       l_ED16

l_EBE5:  call      l_B797

l_EBE8:  mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         dec       ax
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         inc       ax
         push      ax
         mov       ax,1
         push      ax
         mov       ax,1
         push      ax
         call      l_5317
         call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,17h
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        37,'Prob¡h  s‚riov˜ tisk, <ESC>=p©eru¨en¡'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
l_EC3E:  dec       sp
         dec       sp
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         cmp       ax,1Bh
         mov       ax,1
         jz        l_EC4C
         dec       ax
l_EC4C:  mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         mov       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         cmp       ax,1
         jne       l_EC5A
         ;jmp       l_ECA4
         db        0e9h
         dw        l_ECA4-$-2

l_EC5A:  mov       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         cmp       ax,0FFFFh
         mov       ax,1
         jz        l_EC66
         dec       ax
l_EC66:  push      ax
         mov       al,byte ptr cs:[l_3258]  ; v˜mˆna pap¡ru (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       ax,[bp-4]
         cmp       ax,[bp-0Ah]
         mov       ax,1
         jl        l_EC7A
         dec       ax
l_EC7A:  pop       cx
         and       ax,cx
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_EC87
         ;jmp       l_ECA4
         db        0e9h
         dw        l_ECA4-$-2

l_EC87:  mov       ax,19h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
         mov       ax,19h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         mov       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         neg       ax
         mov       word ptr ds:[d_F994],ax  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
l_ECA4:  mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_ECB0
         ;jmp       l_ECB9
         db        0e9h
         dw        l_ECB9-$-2

l_ECB0:  mov       ax,0
         mov       word ptr ds:[d_F994],ax  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         ;jmp       l_ED1A
         db        0e9h
         dw        l_ED1A-$-2

l_ECB9:  mov       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         cmp       ax,0
         je        l_ECC4
         jmp       l_EC3E

l_ECC4:  call      l_E73E
         pop       cx
         dec       cx
         jz        l_ECD1
         inc       word ptr [bp-4]
         jmp       l_E9FA

l_ECD1:  call      l_E73E
l_ECD4:  mov       ax,[bp-0Ch]
         push      ax
         mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_ECE4
         ;jmp       l_ECFA
         db        0e9h
         dw        l_ECFA-$-2

l_ECE4:  inc       cx
         mov       [bp-6],ax
l_ECE8:  push      cx
         mov       ax,[bp-6]
         push      ax
         call      l_3A2E                   ; uvolnˆn¡ © dku z pamˆti
         pop       cx
         dec       cx
         jz        l_ECFA
         inc       word ptr [bp-6]
         ;jmp       l_ECE8
         db        0e9h
         dw        l_ECE8-$-2

l_ECFA:  mov       al,[bp-0Fh]
         xor       ah,ah
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         mov       ax,0
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby
l_ED0E:  ;jmp       l_ED1E
         db        0e9h
         dw        l_ED1E-$-2

l_ED11:  pop       ax
         pop       ax
         ;jmp       l_ECD1
         db        0e9h
         dw        l_ECD1-$-2

l_ED16:  pop       ax
         ;jmp       l_ECD1
         db        0e9h
         dw        l_ECD1-$-2

l_ED1A:  pop       ax
         ;jmp       l_ECD1
         db        0e9h
         dw        l_ECD1-$-2

l_ED1E:  mov       sp,bp
         pop       bp
         ret

l_E735   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KP (menu tisku)
; -----------------------------------------------------------------------------

l_ED22   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_EE00

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_ED29   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_ED35
         db        0e9h
         dw        l_ED35-$-2

l_ED35:  mov       di,offset d_F76E
         push      ds
         push      di
         sub       sp,0Fh
         mov       ax,word ptr ds:[d_F98A]  ; ‡¡slo ti¨tˆn‚ho prostoru
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         add       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_4450                   ; zru¨en¡ cesty ze specifik. souboru
         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_ED6E
         ;jmp       l_ED92
         db        0e9h
         dw        l_ED92-$-2

l_ED6E:  mov       di,offset d_F76E
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        8,'Rozsah  '

         mov       ax,ds:[d_F98A]           ; ‡¡slo ti¨tˆn‚ho prostoru
         add       ax,30h
         mov       ah,al
         mov       al,1
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_ED92:  mov       ax,3dh
         push      ax
         mov       ax,0eh
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       cx,1
         shr       ax,cl
         pop       cx
         add       ax,cx
         push      ax
         mov       ax,2
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,ds:[d_F994]           ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         cmp       ax,-1
         je        l_EDCF
         ;jmp       l_EDF9
         db        0e9h
         dw        l_EDF9-$-2

l_EDCF:  mov       ax,39h
         push      ax
         mov       ax,4
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,'Pros¡m, vlo‘te pap¡r !'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
l_EDF9:  ;jmp       l_EDFC
         db        0e9h
         dw        l_EDFC-$-2

l_EDFC:  mov       sp,bp
         pop       bp
         ret

l_ED29   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_ED22)
; -----------------------------------------------------------------------------

l_EE00:  dec       sp
         dec       sp
         jmp       short l_EE65

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EE04   PROC      NEAR

         call      l_EE22
l_EE07:  push      bx
         push      cx
         push      dx
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         pop       dx
         pop       cx
l_EE10:  pop       bx
         or        ax,ax
         jnz       l_EE22
         cmp       cl,3Ch
         je        l_EE07
         cmp       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         jne       l_EE07
         mov       al,0FFh
l_EE22:  push      ax
         push      bx
         push      cx
         push      dx
         push      cx
         push      bx
         push      dx
         push      bx
         mov       ax,2
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_EE04   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_EE36   PROC      NEAR

         push      bx
         mov       di,offset l_3251         ; vy¨¨¡ kvalita (1=zap., 0=vyp.)
         mov       bx,7
l_EE3D:  mov       al,2Dh
         cmp       byte ptr cs:[di],0
         je        l_EE47
         mov       al,0FBh
l_EE47:  mov       cx,4Bh
         push      bx
         push      di
         push      ax                       ; znak
         push      cx                       ; pozice
         push      bx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       di
         pop       bx
         inc       bx
         inc       di
         cmp       bl,0Eh
         jbe       l_EE3D
         pop       bx
         ret

l_EE36   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_ED22)
; -----------------------------------------------------------------------------

l_EE5D   dw        l_E587
         dw        l_E735
         dw        l_B533
         dw        l_B63D

l_EE65:  push      word ptr ds:[d_F7A7]     ; ‡¡slo aktivn¡ho prostoru
         call      l_3FED                   ; £schova parametr– edit. prostoru
         xor       ax,ax
         mov       byte ptr ds:[d_F798],al
         cmp       ax,word ptr ds:[d_F994]  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
         je        l_EEE9
         mov       al,0Ch
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         call      l_ED29
         mov       bx,5
l_EE83:  mov       cx,38h
         mov       dx,4Fh
         call      l_EE04
         cmp       al,18h
         jne       l_EE9A
         inc       bx
         cmp       bl,6
         jbe       l_EE83
         mov       bl,5
         jmp       short l_EE83

l_EE9A:  cmp       al,5
         jne       l_EEA8
         dec       bx
         cmp       bl,5
         jae       l_EE83
         mov       bl,6
         jmp       short l_EE83

l_EEA8:  cmp       byte ptr ds:[d_F786],0   ; 1=p©¡znak zobrazen¡ horn¡ho menu
         je        l_EEC5
         cmp       al,4
         jne       l_EEBA
         mov       byte ptr ds:[d_F798],1
         jmp       short l_EEDC

l_EEBA:  cmp       al,13h
         jne       l_EEC5
         mov       byte ptr ds:[d_F798],0FFh
         jmp       short l_EEDC

l_EEC5:  cmp       al,1Bh
         je        l_EEDC
         cmp       al,0FFh
         je        l_EEE2
         cmp       al,0Dh
         jne       l_EE83
         xor       ax,ax
         cmp       bl,6
         je        l_EED9
         inc       ax
l_EED9:  mov       word ptr ds:[d_F994],ax  ; 1=p©¡znak prob¡haj¡c¡ho tisku;0=ne
l_EEDC:  mov       ax,0Ch
         jmp       l_EFA7

l_EEE2:  mov       ax,0Ch
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
l_EEE9:  mov       ax,22h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         mov       bl,byte ptr ds:[d_E68C]
         mov       bh,0
         inc       bx
         inc       bx
l_EEF8:  call      l_EE36
l_EEFB:  mov       cx,3Ch
         mov       dx,4Ch
         call      l_EE04
         cmp       al,5
         jne       l_EF17
l_EF08:  dec       bx
         cmp       bl,6
         je        l_EF08
         cmp       bl,2
         jae       l_EEFB
         mov       bl,0Eh
         jmp       short l_EEFB

l_EF17:  cmp       al,18h
         jne       l_EF2A
l_EF1B:  inc       bx
         cmp       bl,6
         je        l_EF1B
         cmp       bl,0Eh
         jbe       l_EEFB
         mov       bl,2
         jmp       short l_EEFB

l_EF2A:  cmp       al,11h
         jne       l_EF49
         push      bx
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         pop       bx
         cmp       al,53h
         jne       l_EF41
         mov       bl,2
         jmp       short l_EEFB

l_EF41:  cmp       al,44h
         jne       l_EEFB
         mov       bl,0Eh
         jmp       short l_EEFB

l_EF49:  cmp       byte ptr ds:[d_F786],0   ; 1=p©¡znak zobrazen¡ horn¡ho menu
         je        l_EF66
         cmp       al,4
         jne       l_EF5B
         mov       byte ptr ds:[d_F798],1
         jmp       short l_EFA4

l_EF5B:  cmp       al,13h
         jne       l_EF66
         mov       byte ptr ds:[d_F798],0FFh
         jmp       short l_EFA4

l_EF66:  cmp       al,1Bh
         je        l_EFA4
         cmp       al,0Dh
         jne       l_EEFB
         dec       bx
         dec       bx
         mov       byte ptr ds:[d_E68C],bl
         inc       bx
         inc       bx
         cmp       bl,6
         jb        l_EF84
         xor       byte ptr cs:[l_324A+bx],1
         jmp       l_EEF8

l_EF84:  push      bx
         mov       ax,22h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       bx
         dec       bx
         dec       bx
         shl       bx,1
         mov       byte ptr ds:[d_F78A],bh  ; 1=p©¡znak p©eru¨en¡ editace volby
         call      cs:[l_EE5D+bx]
         cmp       byte ptr ds:[d_F78A],0   ; 1=p©¡znak p©eru¨en¡ editace volby
         je        l_EFAB
         jmp       l_EE65

l_EFA4:  mov       ax,22h
l_EFA7:  push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
l_EFAB:  ;jmp       l_EFAE
         db        0e9h
         dw        l_EFAE-$-2

l_EFAE:  mov       sp,bp
         pop       bp
         ret

l_ED22   ENDP

; *****************************************************************************
;
;                  Obsluha volby Ctrl-K (menu blok/soubor)
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-K (menu blok/soubor)
; -----------------------------------------------------------------------------

l_EFB2   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_EFB9
         db        0e9h
         dw        l_EFB9-$-2

l_EFB9:  jmp       short l_EFF1

l_EFBB   dw        l_92F4                   ; Ctrl-KD menu soubor–
         dw        l_9826                   ; Ctrl-KE maz n¡ textu
         dw        l_70A6                   ; Ctrl-KG p©enos z jin‚ho prostoru
         dw        l_6618                   ; Ctrl-KH zobrazen¡ bloku
         dw        l_66AD                   ; Ctrl-KB ozna‡en¡ za‡ tku bloku
         dw        l_66E8                   ; Ctrl-KK ozna‡en¡ konce bloku
         dw        l_6886                   ; Ctrl-KY maz n¡ bloku
         dw        l_6B48                   ; Ctrl-KC kop¡rov n¡ bloku
         dw        l_6D3D                   ; Ctrl-KV p©esunut¡ bloku
         dw        l_7F88                   ; Ctrl-KR ‡ten¡ bloku
         dw        l_7886                   ; Ctrl-KW z pis bloku
         dw        l_79D9                   ; Ctrl-KS ulo‘en¡ souboru
         dw        l_7FF1                   ; Ctrl-KL ‡ten¡ souboru
         dw        l_ED22                   ; Ctrl-KP menu tisku
         dw        l_918B                   ; Ctrl-KQ ukon‡en¡ KonTextu
         dw        l_8514                   ; Ctrl-KX start programu
         dw        l_67B7                   ; Ctrl-KN sloupcov˜ blok
         dw        l_B3AE                   ; Ctrl-KT zmˆna p¡sma v bloku

l_EFDF   db        'DEGHBKYCVRWSLPQXNT'

l_EFF1:  mov       ax,2
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         push      ax
         mov       ax,2
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       ax
         mov       ah,0
         cmp       al,31h
         jb        l_F01C
         cmp       al,35h
         ja        l_F01C
         sub       al,30h
         push      ax
         call      l_9840                   ; p©epnut¡ na nov˜ edita‡n¡ prostor
         jmp       short l_F034

l_F01C:  mov       si,offset l_EFDF
         mov       cx,12h
         mov       bx,offset l_EFBB
l_F025:  cmp       al,cs:[si]
         je        l_F031
         inc       si
         inc       bx
         inc       bx
         loop      l_F025
         jmp       short l_F034

l_F031:  call      word ptr cs:[bx]
l_F034:  ;jmp       l_F037
         db        0e9h
         dw        l_F037-$-2

l_F037:  mov       sp,bp
         pop       bp
         ret

l_EFB2   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-[, ESC (vyvol n¡ horn¡ho menu)
; -----------------------------------------------------------------------------

l_F03B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_F042
         db        0e9h
         dw        l_F042-$-2

l_F042:  jmp       l_F35B

; -----------------------------------------------------------------------------
;        obsluha volby Kurzor/vyhled n¡ textu (hled n¡ textu)
; -----------------------------------------------------------------------------

l_F045   PROC      NEAR

         xor       ax,ax
         jmp       short l_F04C

l_F045   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Kurzor/n hrada textu (hled n¡ a n hrada textu)
; -----------------------------------------------------------------------------

l_F049   PROC      NEAR

         mov       ax,1
l_F04C:  push      ax
         call      l_BCDB                   ; vyhled n¡/z mˆna textu
         ret

l_F049   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/za‡ tek odstavce (vlo‘en¡ znaku za‡ tku odstavce)
; -----------------------------------------------------------------------------

l_F051   PROC      NEAR

         mov       ax,16                    ; znak za‡ tku odstavce
         jmp       short l_F08C

l_F051   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/konec odstavce (vlo‘en¡ znaku konce odstavce)
; -----------------------------------------------------------------------------

l_F056   PROC      NEAR

         cmp       byte ptr cs:[l_3265],1   ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         je        l_F090
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       bl,ds:[di]
         mov       bh,0
         or        bx,bx
         jz        l_F090
         cmp       byte ptr ds:[bx+di],11h
         je        l_F090
         cmp       bl,0ffh
         je        l_F090
         inc       bx
         mov       ds:[di],bl
         mov       byte ptr ds:[bx+di],11h
         mov       byte ptr ds:[bx+d_ED59],bh ; buffer atribut– znak– text. © dku
         push      bx
         push      bx
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         ret

l_F056   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/z kaz form tov n¡ (vlo‘en¡ znaku z kazu form tov.)
; -----------------------------------------------------------------------------

l_F089   PROC      NEAR

         mov       ax,31                    ; znak z kazu form tov n¡
l_F08C:  push      ax
         call      l_DD51                   ; vlo‘en¡ znaku do textu
l_F090:  ret

l_F089   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/lev˜ okraj podle kurzoru (lev˜ okraj dle kurzoru)
; -----------------------------------------------------------------------------

l_F091   PROC      NEAR

         push      word ptr ds:[d_E69A]     ; pozice kurzoru na © dku
         call      l_D692                   ; nastaven¡ lev‚ho okraje
         ret

l_F091   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/str nkov n¡ (zobrazen¡ str nkov n¡ zap/vyp)
; -----------------------------------------------------------------------------

l_F099   PROC      NEAR

         xor       byte ptr cs:[l_3263],1   ; zobraz. str nk. (1=zap., 0=vyp.)
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ret

l_F099   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/prav˜ okraj dle kurzoru (prav˜ okraj dle kurzoru)
; -----------------------------------------------------------------------------

l_F0A6   PROC      NEAR

         push      word ptr ds:[d_E69A]     ; pozice kurzoru na © dku
         call      l_D6C9                   ; nastaven¡ prav‚ho okraje
         ret

l_F0A6   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Str nka/line l (zobrazen¡ line lu zap/vyp)
; -----------------------------------------------------------------------------

l_F0AE   PROC      NEAR

         xor       byte ptr cs:[l_3264],1   ; zobr. line lu © d.(1=zap., 0=vyp.)
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ret

l_F0AE   ENDP

; -----------------------------------------------------------------------------
;        volba Displej/©¡dk‚ © dkov n¡ (nastaven¡ ©¡dk‚ho © dkov n¡ 25 © dk–)
; -----------------------------------------------------------------------------

l_F0B8   PROC      NEAR

         xor       ax,ax                    ; ©¡dk‚ © dkov n¡
         jmp       short l_F0C2

l_F0B8   ENDP

; -----------------------------------------------------------------------------
;        volba Displej/st©edn¡ © dkov n¡ (nastaven¡ st©edn¡ho © dkov n¡ 28 ©.)
; -----------------------------------------------------------------------------

l_F0BC   PROC      NEAR

         mov       al,1                     ; st©edn¡ © dkov n¡
         jmp       short l_F0C2

l_F0BC   ENDP

; -----------------------------------------------------------------------------
;        volba Displej/hust‚ © dkov n¡ (nastaven¡ hust‚ho © dkov n¡ 43/50 © dk–)
; -----------------------------------------------------------------------------

l_F0C0   PROC      NEAR

         mov       al,2                     ; hust‚ © dkov n¡
l_F0C2:  mov       byte ptr cs:[l_3273],al  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         call      l_98AF                   ; zv˜¨en¡ hustoty © dkov n¡
         ret

l_F0C0   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Extra/z pis data (z pis data do textu)
; -----------------------------------------------------------------------------

l_F0CA   PROC      NEAR

         mov       ax,1                     ; p©¡znak z pisu data do textu
         jmp       short l_F0D1

l_F0CA   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Extra/z pis ‡asu (z pis ‡asu do textu)
; -----------------------------------------------------------------------------

l_F0CF   PROC      NEAR

         xor       ax,ax                    ; p©¡znak z pisu ‡asu do textu
l_F0D1:  push      ax
         call      l_A973                   ; z pis data/‡asu do textu
         ret

l_F0CF   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F0D6   PROC      NEAR

         push      bx
         push      cx
         push      dx
         push      si
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         dec       sp
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         pop       si
         pop       dx
         pop       cx
         pop       bx
         ret

l_F0D6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F0E8   PROC      NEAR

         call      l_F0F8
         push      bx
         push      cx
         push      dx
         push      ax
         call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         pop       dx
         pop       cx
         pop       bx

l_F0F8:  push      ax
         push      bx
         push      cx
         push      dx
         push      cx
         push      bx
         push      dx
         push      bx
         mov       ax,2
         push      ax
         call      l_34F8                   ; vykreslen¡ okna (kurzoru)
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_F0E8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F10C   PROC      NEAR

         and       al,dl
l_F10E:  or        al,al
         mov       al,2Dh
         jz        l_F116
         mov       al,0FBh
l_F116:  push      bx
         push      cx
         push      dx
         push      ax                       ; znak
         push      cx                       ; pozice
         push      bx                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       dx
         pop       cx
         pop       bx
         inc       bx
         ret       

l_F10C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F124   PROC      NEAR

         push      cx
         mov       cx,36h
         mov       bx,11
         mov       al,byte ptr cs:[l_3263]  ; zobraz. str nk. (1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3264]  ; zobr. line lu © d.(1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         call      l_F10E
         pop       cx
         ret       

l_F124   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/zarovn v n¡ (zarovn v n¡ zap/vyp)
; -----------------------------------------------------------------------------

l_F142   PROC      NEAR

         mov       di,offset l_325E         ; zarovn v n¡ (1=zap., 0=vyp.)
         jmp       short l_F159

l_F142   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/rozdˆlov n¡ (rozdˆlov n¡ zap/vyp)
; -----------------------------------------------------------------------------

l_F147   PROC      NEAR

         mov       di,offset l_325F         ; rozdˆlov n¡ (1=zap., 0=vyp.)
         jmp       short l_F159

l_F147   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/rozdˆlov n¡+dotaz (rozdˆlov n¡ s dotazem zap/vyp)
; -----------------------------------------------------------------------------

l_F14C   PROC      NEAR

         mov       di,offset l_3260         ; rozdˆl. s dotaz.(1=zap., 0=vyp.)
         jmp       short l_F159

l_F14C   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/autotabel tor (autotabel tor zap/vyp)
; -----------------------------------------------------------------------------

l_F151   PROC      NEAR

         mov       di,offset l_3261         ; auto-tabel tor (1=zap., 0=vyp.)
         jmp       short l_F159

l_F151   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Form t/konec odstavce (Enter jako konec odstavce zap/vyp)
; -----------------------------------------------------------------------------

l_F156   PROC      NEAR

         mov       di,offset l_3262         ; konec odstavce (1=zap., 0=vyp.)
l_F159:  xor       byte ptr cs:[di],1       ; zmˆna p©¡znaku p©ep¡na‡e
l_F15D:  push      cx
         mov       bx,6
         mov       cx,2Ch                   ; pozice k zobrazen¡ p©ep¡na‡–
         mov       al,byte ptr cs:[l_325E]  ; zarovn v n¡ (1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_325F]  ; rozdˆlov n¡ (1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3260]  ; rozdˆl. s dotaz.(1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3261]  ; auto-tabel tor (1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3262]  ; konec odstavce (1=zap., 0=vyp.)
         call      l_F10E
         pop       cx
         ret       

l_F156   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/norm ln¡ (nastaven¡ norm ln¡ho p¡sma)
; -----------------------------------------------------------------------------

l_F189   PROC      NEAR

         xor       ax,ax
         mov       byte ptr ds:[d_F788],al  ; zvolen˜ aktu ln¡ typ p¡sma
         jmp       short l_F1AE

l_F189   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/zv˜raznˆn‚ (zv˜raznˆn‚ p¡smo zap/vyp)
; -----------------------------------------------------------------------------

l_F190   PROC      NEAR

         mov       ax,10FFh                 ; p©¡znak zv˜raznˆn‚ho p¡sma
         jmp       short l_F1AE

l_F190   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/podtr‘en‚ (podtr‘en‚ p¡smo zap/vyp)
; -----------------------------------------------------------------------------

l_F195   PROC      NEAR

         mov       ax,8FFh                  ; p©¡znak podtr‘en‚ho p¡sma
         jmp       short l_F1AE

l_F195   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/kurz¡va (kurz¡va zap/vyp)
; -----------------------------------------------------------------------------

l_F19A   PROC      NEAR

         mov       ax,4FFh                  ; p©¡znak kurz¡vy
         jmp       short l_F1AE

l_F19A   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/¨irok‚ (¨irok‚ p¡smo zap/vyp)
; -----------------------------------------------------------------------------

l_F19F   PROC      NEAR

         xor       byte ptr ds:[d_F788],1   ; zmˆna p©¡znaku ¨irok‚ho p¡sma
         jmp       short l_F1B7

l_F19F   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/nadsazen¡ (nadsazen‚ p¡smo zap/vyp)
; -----------------------------------------------------------------------------

l_F1A6   PROC      NEAR

         mov       ax,1FDh                  ; p©¡znak nadsazen‚ho p¡sma
         jmp       short l_F1AE

l_F1A6   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby P¡smo/podsazen¡ (podsazen‚ p¡smo zap/vyp)
; -----------------------------------------------------------------------------

l_F1AB   PROC      NEAR

         mov       ax,2feh                  ; p©¡znak podsazen‚ho p¡sma
l_F1AE:  xor       ah,byte ptr ds:[d_F79A]
         and       al,ah
         mov       byte ptr ds:[d_F79A],al
l_F1B7:  push      cx
         mov       bx,2
         mov       cx,23h
         mov       dl,byte ptr ds:[d_F79A]
         mov       al,dl
         or        al,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         sub       al,1
         sbb       al,al
         call      l_F10E
         mov       al,10h
         call      l_F10C
         mov       al,8
         call      l_F10C
         mov       al,4
         call      l_F10C
         mov       al,byte ptr ds:[d_F788]  ; zvolen˜ aktu ln¡ typ p¡sma
         call      l_F10E
         mov       al,1
         call      l_F10C
         mov       al,2
         call      l_F10C
         pop       cx
         ret       

l_F1AB   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Displej/n povˆda (n povˆda zap/vyp)
; -----------------------------------------------------------------------------

l_F1F0   PROC      NEAR

         xor       byte ptr cs:[l_3277],1   ; n povˆda (1=zap., 0=vyp.)
         jmp       short l_F1FE

l_F1F0   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Displej/blik n¡ kurzoru (blik n¡ kurzoru zap/vyp)
; -----------------------------------------------------------------------------

l_F1F8   PROC      NEAR

         xor       byte ptr cs:[l_3276],1   ; blik n¡ kurzoru (1=zap., 0=vyp.)
l_F1FE:  push      cx
         mov       cx,3Bh
         mov       bx,6
         mov       al,byte ptr cs:[l_3277]  ; n povˆda (1=zap., 0=vyp.)
         call      l_F10E
         mov       al,byte ptr cs:[l_3276]  ; blik n¡ kurzoru (1=zap., 0=vyp.)
         call      l_F10E
         pop       cx
         ret       

l_F1F8   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F215   PROC      NEAR

         push      cx
         add       cl,1Ah
         push      cx
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         pop       cx
         ret       

l_F215   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F21F   PROC      NEAR

         push      cx
         add       cl,1Ah
         push      cx
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       cx

l_F228:  push      cx
         xor       bx,bx
         shl       cx,1
         shl       cx,1
         shl       cx,1
         inc       cx
         mov       dx,cx
         add       dl,6
         call      l_F0F8
         pop       cx
         ret       

l_F21F   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F23C   PROC      NEAR

         add       ax,2
         add       bx,2
         mov       si,ax
l_F244:  push      si
         call      l_F0E8
         pop       si
         cmp       al,18h
         jne       l_F256
         inc       bx
         cmp       bx,si
         jbe       l_F244
         mov       bl,2
         jmp       short l_F244

l_F256:  cmp       al,5
         jne       l_F264
         dec       bx
         cmp       bl,2
         jae       l_F244
         mov       bx,si
         jmp       short l_F244

l_F264:  cmp       al,11h
         jne       l_F27B
         call      l_F0D6
         cmp       al,53h
         jne       l_F273
         mov       bl,2
         jmp       short l_F244

l_F273:  cmp       al,44h
         jne       l_F244
         mov       bx,si
         jmp       short l_F244

l_F27B:  mov       ah,1
         cmp       al,4
         je        l_F293
         mov       ah,0FFh
         cmp       al,13h
         je        l_F293
         mov       ah,2
         cmp       al,0Dh
         je        l_F293
         cmp       al,1Bh
         jne       l_F244
         mov       ah,0
l_F293:  sub       bx,2
         ret       

l_F23C   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F297   db        10,1,15h                 ; Kurzor
         db        7,3,15h                  ; Maz n¡
         db        12,0ch,1dh               ; Blok
         db        7,13h,25h                ; P¡smo
         db        12,1ah,2eh               ; Form tov n¡
         db        12,20h,38h               ; Str nka
         db        6,2bh,3dh                ; Displej
         db        12,33h,45h               ; Extra

l_F2AF   dw        l_F2BF                   ; Kurzor
         dw        l_F2D3                   ; Maz n¡
         dw        l_F2E1                   ; Blok
         dw        l_F2F9                   ; P¡smo
         dw        l_F307                   ; Form tov n¡
         dw        l_F31F                   ; Str nka
         dw        l_F337                   ; Displej
         dw        l_F343                   ; Extra

; ------ menu Kurzor

l_F2BF   dw        l_B797                   ; za‡ tek textu
         dw        l_B7D2                   ; konec textu
         dw        l_6801                   ; za‡ tek bloku
         dw        l_6816                   ; konec bloku
         dw        l_BFAB                   ; na zna‡ku
         dw        l_BFC9                   ; nastaven¡ zna‡ky
         dw        l_BFE3                   ; na danou pozici
         dw        l_F045                   ; vyhled n¡ textu
         dw        l_F049                   ; hled n¡/z mˆna
         dw        l_B9FD                   ; dal¨¡ hled n¡

; ------ menu Maz n¡

l_F2D3   dw        l_632A                   ; slovo vpravo
         dw        l_BF6E                   ; po kurzor
         dw        l_BF2E                   ; od kurzoru
         dw        l_61AC                   ; cel˜ © dek
         dw        l_6886                   ; cel˜ blok
         dw        l_59E4                   ; obnoven¡ zmˆn
         dw        l_9826                   ; cel˜ text

; ------ menu Blok

l_F2E1   dw        l_66AD                   ; za‡ tek bloku
         dw        l_66E8                   ; konec bloku
         dw        l_672C                   ; za‡ tek sloupc. bloku
         dw        l_676D                   ; konec sloupc. bloku
         dw        l_6886                   ; maz n¡
         dw        l_6D3D                   ; p©em¡stˆn¡
         dw        l_6B48                   ; kop¡rov n¡
         dw        l_70A6                   ; p©enos z prostoru
         dw        l_7F88                   ; ‡ten¡ z disku
         dw        l_7886                   ; ulo‘en¡ na disk
         dw        l_B3AE                   ; zmˆna p¡sma
         dw        l_6618                   ; ozna‡en¡ bloku

; ------ menu P¡smo

l_F2F9   dw        l_F189                   ; norm ln¡
         dw        l_F190                   ; zv˜raznˆn‚
         dw        l_F195                   ; podtr‘en‚
         dw        l_F19A                   ; kurz¡va
         dw        l_F19F                   ; ¨irok‚
         dw        l_F1A6                   ; nadsazen‚
         dw        l_F1AB                   ; podsazen‚

; ------ menu Form tov n¡

l_F307   dw        l_C9C1                   ; po konec odstavce
         dw        l_D297                   ; po konec textu
         dw        l_DD7B                   ; dvousloupcovˆ
         dw        l_D764                   ; centrov n¡ © dku
         dw        l_F142                   ; zarovn v n¡ zap/vyp
         dw        l_F147                   ; rozdˆlov n¡ zap/vyp
         dw        l_F14C                   ; rozdˆlov n¡ s dotazem zap/vyp
         dw        l_F151                   ; auto-tabel tor zap/vyp
         dw        l_F156                   ; Enter jako konec odstavce zap/vyp
         dw        l_F051                   ; za‡ tek odstavce
         dw        l_F056                   ; konec odstavce
         dw        l_F089                   ; z kaz form tov n¡ odstavce

; ------ menu Str nka

l_F31F   dw        l_D7F0                   ; © dk– na str nku
         dw        l_D482                   ; menu line lu © dk–
         dw        l_F091                   ; lev˜ okraj podle kurzoru
         dw        l_F0A6                   ; prav˜ okraj podle kurzoru
         dw        l_D737                   ; prav˜ okraj podle © dku
         dw        l_DBB2                   ; zobrazen¡ z hlav¡
         dw        l_DBCF                   ; zobrazen¡ paty
         dw        l_DBEC                   ; blok jako z hlav¡
         dw        l_DC09                   ; blok jako pata
         dw        l_F099                   ; zobrazen¡ str nkov n¡ zap/vyp
         dw        l_F0AE                   ; zobrazen¡ line lu zap/vyp
         dw        l_DCA9                   ; nedokumentn¡ m¢d zap/vyp

; ------ menu Displej

l_F337   dw        l_F0B8                   ; ©¡dk‚ © dkov n¡ (25 © dk–)
         dw        l_F0BC                   ; st©edn¡ © dkov n¡ (28 © dk–)
         dw        l_F0C0                   ; hust‚ © dkov n¡ (43/50 © dk–)
         dw        l_9916                   ; volba barev
         dw        l_F1F0                   ; n povˆda zap/vyp
         dw        l_F1F8                   ; blik n¡ kurzoru zap/vyp

; ------ menu Extra

l_F343   dw        l_A958                   ; volba pracovn¡ho prostoru
         dw        l_E013                   ; text do bufferu
         dw        l_E53D                   ; text z bufferu
         dw        l_F0CF                   ; z pis ‡asu
         dw        l_F0CA                   ; z pis data
         dw        l_A9CB                   ; kalend ©
         dw        l_ACF4                   ; grafick˜ editor
         dw        l_C997                   ; zvl ¨tn¡ znaky
         dw        l_C3F1                   ; makrokl vesy
         dw        l_A6B6                   ; kalkul tor
         dw        l_B222                   ; sloupcov˜ sou‡et
         dw        l_B20D                   ; sloupcov˜ pr–mˆr

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_F03B)
; -----------------------------------------------------------------------------

l_F35B:  mov       byte ptr ds:[d_F786],1   ; 1=p©¡znak zobrazen¡ horn¡ho menu
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_F363:  mov       cl,ds:[d_E68E]
         mov       ch,0
         call      l_F228
         cmp       cl,8
         jb        l_F386
         push      cx
         ja        l_F379
         call      l_ED22
         jmp       short l_F37C

l_F379:  call      l_92F4
l_F37C:  pop       cx
         call      l_F228
         mov       ah,ds:[d_F798]
         jmp       short l_F3DA

l_F386:  call      l_F215
         cmp       cl,3
         jne       l_F391
         call      l_F1B7
l_F391:  cmp       cl,4
         jne       l_F399
         call      l_F15D
l_F399:  cmp       cl,5
         jne       l_F3A1
         call      l_F124
l_F3A1:  cmp       cl,6
         jne       l_F3A9
         call      l_F1FE
l_F3A9:  mov       bx,cx
         mov       bl,ds:[d_E684+bx]
l_F3AF:  push      cx
         mov       di,cx
         shl       di,1
         add       di,cx
         add       di,offset l_F297
         mov       al,cs:[di]
         mov       ah,0
         dec       ax
         mov       cl,cs:[di+1]
         inc       cx
         mov       dl,cs:[di+2]
         mov       dh,0
         dec       dx
         call      l_F23C
         pop       cx
         cmp       ah,2
         je        l_F3FC
         push      ax
         call      l_F21F
         pop       ax
l_F3DA:  or        ah,ah
         jnz       l_F3E7
         mov       ds:[d_F786],ch           ; 1=p©¡znak zobrazen¡ horn¡ho menu
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         jmp       short l_F455

l_F3E7:  add       cl,ah
         jns       l_F3EE
         mov       cx,9
l_F3EE:  cmp       cl,9
         jbe       l_F3F5
         mov       cl,0
l_F3F5:  mov       ds:[d_E68E],cl
         jmp       l_F363

l_F3FC:  mov       di,cx
         mov       ds:[d_E684+di],bl
         shl       di,1
         mov       di,cs:[l_F2AF+di]
         add       di,bx
         add       di,bx
         cmp       cl,3
         je        l_F42B
         cmp       cl,4
         jne       l_F421
         cmp       bl,3
         jbe       l_F435
         cmp       bl,9
         jb        l_F42B
l_F421:  cmp       cl,6
         jne       l_F435
         cmp       bl,4
         jb        l_F435
l_F42B:  push      bx
         push      cx
         call      word ptr cs:[di]
         pop       cx
         pop       bx
         jmp       l_F3AF

l_F435:  push      di
         mov       ds:[d_F786],ch           ; 1=p©¡znak zobrazen¡ horn¡ho menu
         mov       ds:[d_F78A],ch           ; 1=p©¡znak p©eru¨en¡ editace volby
         call      l_F21F
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         pop       di
         call      word ptr cs:[di]
         cmp       byte ptr ds:[d_F78A],0   ; 1=p©¡znak p©eru¨en¡ editace volby
         je        l_F455
         jmp       l_F35B

l_F455:  ;jmp       l_F458
         db        0e9h
         dw        l_F458-$-2

l_F458:  mov       sp,bp
         pop       bp
         ret       

l_F03B   ENDP

; -----------------------------------------------------------------------------
;        obsluha ©¡dic¡ kl vesy (prvn¡ znak)
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (2) k¢d ©¡dic¡ kl vesy 1 a‘ 31
; -----------------------------------------------------------------------------

l_F45C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_F463
         db        0e9h
         dw        l_F463-$-2

l_F463:  ;jmp       l_F4A4
         db        0e9h
         dw        l_F4A4-$-2

; ------ tabulka obsluh ©¡dic¡ch kl ves

l_F466   dw        l_5E21                   ;  1: Ctrl-A slovo vlevo
         dw        l_C9C1                   ;  2: Ctrl-B form tov n¡
         dw        l_60F6                   ;  3: Ctrl-C str nka dol–
         dw        l_5DAD                   ;  4: Ctrl-D pozice vpravo
         dw        l_5C8B                   ;  5: Ctrl-E © dek nahoru
         dw        l_5DDF                   ;  6: Ctrl-F slovo vpravo
         dw        l_6266                   ;  7: Ctrl-G maz n¡ znaku vpravo
         dw        l_629C                   ;  8: Ctrl-H maz n¡ znaku vlevo
         dw        l_D2E5                   ;  9: Ctrl-I tabel tor
         dw        l_B237                   ; 10: Ctrl-J menu info/displej
         dw        l_EFB2                   ; 11: Ctrl-K menu blok/soubor
         dw        l_B9FD                   ; 12: Ctrl-L hledat d le
         dw        l_6003                   ; 13: Ctrl-M konec odstavce
         dw        l_5F02                   ; 14: Ctrl-N vlo‘en¡ © dku
         dw        l_DEFB                   ; 15: Ctrl-O menu form tov n¡/volby
         dw        l_B6BA                   ; 16: Ctrl-P menu typu p¡sma
         dw        l_C53E                   ; 17: Ctrl-Q menu kurzoru/maz n¡
         dw        l_608C                   ; 18: Ctrl-R str nka nahoru
         dw        l_5D88                   ; 19: Ctrl-S pozice vlevo
         dw        l_632A                   ; 20: Ctrl-T maz n¡ slova vpravo
         dw        l_F03B                   ; 21: Ctrl-U vlo‘en¡ znaku "­"
         dw        l_5FE6                   ; 22: Ctrl-V zmˆna p©ep¡na‡e INSERT
         dw        l_5CFC                   ; 23: Ctrl-W rolov n¡ nahoru
         dw        l_5CE8                   ; 24: Ctrl-X © dek dol–
         dw        l_61AC                   ; 25: Ctrl-Y maz n¡ © dku
         dw        l_5D3A                   ; 26: Ctrl-Z rolov n¡ dol–
         dw        l_F03B                   ; 27: Ctrl-[ (ESC)
         dw        l_C997                   ; 28: Ctrl-\ tabulka ASCII znak–
         dw        l_E013                   ; 29: Ctrl-] text do bufferu
         dw        l_E53D                   ; 30: Ctrl-^ text z bufferu
         dw        l_B363                   ; 31: Ctrl-_ z mˆna 2 znak–

; ------ skok na obsluhu kl vesy

l_F4A4:  ;mov       bx,[bp+4]               ; zadan  kl vesa
         db        8bh,9eh,4,0              ;!
         mov       byte ptr ds:[d_F78B],bh  ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         mov       byte ptr ds:[d_F790],bh  ; 1=povoleno zobrazen¡ menu
         cmp       bh,byte ptr ds:[d_F78F]  ; 1=p©¡znak dekadick‚ho tabel toru
         je        l_F4C7                   ; nen¡ dekadick˜ tabel tor
         cmp       bl,CtrlH                 ; je kl vesa BS ?
         je        l_F4C7                   ; je kl vesa BS - plat¡
         mov       byte ptr ds:[d_F78F],bh  ; 1=p©¡znak dekadick‚ho tabel toru
         push      bx
         call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku
         pop       bx

l_F4C7:  dec       bx
         shl       bx,1
         call      cs:[l_F466+bx]           ; obsluha prvn¡ kl vesy
         call      l_399E                   ; test, zda m  soubor nˆjak˜ © dek
         cmp       byte ptr ds:[d_F789],0   ; 1=p©¡znak modifikace edit. © dku
         je        l_F4EC
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jbe       l_F4EC
         cmp       byte ptr ds:[d_EC59],0   ; d‚lka textov‚ho © dku
         je        l_F4EC
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
l_F4EC:  ;jmp       l_F4EF
         db        0e9h
         dw        l_F4EF-$-2

l_F4EF:  mov       sp,bp
         pop       bp
         ret       2

l_F45C   ENDP

; -----------------------------------------------------------------------------
;        rozbor zad n¡ parametr– v p©¡kazov‚m © dku
; -----------------------------------------------------------------------------

l_F4F5   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_F4FC
         db        0e9h
         dw        l_F4FC-$-2

l_F4FC:  sub       sp,83h
         mov       ax,1
         push      ax
         call      l_0DB6                   ; po‡et parametr– v p©¡kazov‚m © dku
         pop       cx
         xchg      ax,cx                    ; CX <- po‡et parametr–
         sub       cx,ax
         jge       l_F510
         jmp       l_F5A5

l_F510:  inc       cx                       ; po‡et parametr– v p©¡kaz. © dku
         mov       [bp-85h],ax
l_F515:  push      cx
         lea       di,[bp-83h]
         push      ss
         push      di
         mov       ax,[bp-85h]
         call      l_0D99
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.



         mov       al,[bp-82h]              ; prvn¡ znak parametru
         xor       ah,ah
         cmp       ax,"#"                   ; je p©epnut¡ pracovn¡ho prostoru ?
         je        l_F536                   ; je volba pracovn¡ho prostoru
         ;jmp       l_F546
         db        0e9h
         dw        l_F546-$-2
l_F536:  mov       al,[bp-81h]              ; druh˜ znak - ‡¡slo prostoru
         xor       ah,ah
         sub       ax,"0"                   ; korekce na ‡¡slo prostoru
         push      ax
         call      l_9840                   ; p©epnut¡ na edita‡n¡ prostor AL
         ;jmp       l_F59A
         db        0e9h
         dw        l_F59A-$-2
;þ

l_F546:  cmp       ax,21h
         je        l_F54E
         ;jmp       l_F580
         db        0e9h
         dw        l_F580-$-2

l_F54E:  mov       di,offset d_F259         ; buffer p©ehr van‚ makrokl vesy
         push      ds
         push      di
         lea       di,[bp-83h]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       ax,1
         mov       word ptr ds:[d_F79F],ax  ; ukazatel p©ehr van‚ makrokl vesy
         mov       di,offset d_F259         ; buffer p©ehr van‚ makrokl vesy
         push      ds
         push      di
         mov       ax,1
         push      ax
         mov       ax,1
         call      l_1408                   ; vyjmut¡ cesty z ozna‡en¡ souboru
         mov       di,offset d_F259         ; buffer p©ehr van‚ makrokl vesy
         push      ds
         push      di
         call      l_C14D                   ; p©evod znak– Ctrl- na bajty < 32
         ;jmp       l_F59A
         db        0e9h
         dw        l_F59A-$-2

l_F580:  lea       di,[bp-83h]
         push      ss
         push      di
         call      l_7E64
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_F594
         ;jmp       l_F59A
         db        0e9h
         dw        l_F59A-$-2

l_F594:  call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         ;jmp       l_F5A8
         db        0e9h
         dw        l_F5A8-$-2

l_F59A:  pop       cx
         dec       cx
         jz        l_F5A5
         inc       word ptr [bp-85h]
         jmp       l_F515

l_F5A5:  ;jmp       l_F5AC
         db        0e9h
         dw        l_F5AC-$-2

l_F5A8:  pop       ax
         ;jmp       l_F5A5
         db        0e9h
         dw        l_F5A5-$-2

l_F5AC:  mov       sp,bp
         pop       bp
         ret       

l_F4F5   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ tituln¡ho obr zku
; -----------------------------------------------------------------------------

l_F5B0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         jmp       l_F671

l_F5B7   db        'Û'
         db        '²'
         db        '±'
         db        '°'
         db        ' '
         db        ' '
         db        '°'
         db        '±'
         db        '²'
         db        'Û'

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F5C1   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_F5CD
         db        0e9h
         dw        l_F5CD-$-2

l_F5CD:  mov       ax,1
         push      ax
         mov       ax,0Ah
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_F5DD
         jmp       l_F668

l_F5DD:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-8],ax
l_F5E5:  push      cx
         mov       ax,1
         push      ax
         mov       ax,0Ah
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_F5F6
         ;jmp       l_F65A
         db        0e9h
         dw        l_F65A-$-2

l_F5F6:  inc       cx
         mov       bx,[bp-2]
         mov       ss:[bx-0Ah],ax
l_F5FE:  push      cx
         mov       ax,0Ah
         push      ax
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         mov       bx,[bp-2]
         imul      word ptr ss:[bx-0Ah]
         mov       cx,0Bh
         cwd       
         idiv      cx
         xchg      ax,dx
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         xchg      ax,di
         mov       al,cs:[l_F5B7+di]
         xor       ah,ah
         push      ax                       ; znak
         mov       bx,[bp-2]
         mov       ax,ss:[bx-0Ah]
         add       ax,[bp+4]
         mov       bx,[bp-2]
         add       ax,ss:[bx-4]
         push      ax                       ; pozice
         mov       bx,[bp-2]
         mov       ax,ss:[bx-8]
         add       ax,3
         mov       bx,[bp-2]
         add       ax,ss:[bx-6]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       cx
         dec       cx
         jz        l_F65A
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-0Ah]
         ;jmp       l_F5FE
         db        0e9h
         dw        l_F5FE-$-2

l_F65A:  pop       cx
         dec       cx
         jz        l_F668
         mov       bx,[bp-2]
         inc       word ptr ss:[bx-8]
         jmp       l_F5E5

l_F668:  ;jmp       l_F66B
         db        0e9h
         dw        l_F66B-$-2

l_F66B:  mov       sp,bp
         pop       bp
         ret       2

l_F5C1   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_F5B0)
; -----------------------------------------------------------------------------

l_F671:  sub       sp,15h
         mov       ax,ds:[d_FDCD]           ; max. po‡et znak– na © dek displeje
         sub       ax,50h
         mov       cx,2
         cwd       
         idiv      cx
         mov       [bp-4],ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         sub       ax,13h
         mov       cx,2
         cwd       
         idiv      cx
         mov       [bp-6],ax
         mov       ax,0
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - bˆ‘n˜
         mov       ax,5
         push      ax
         call      l_F5C1
         mov       ax,3Fh
         push      ax
         call      l_F5C1
         mov       ax,0
         push      ax
         mov       ax,3
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_F6B6
         jmp       l_F7C2

l_F6B6:  inc       cx
         mov       [bp-8],ax
l_F6BA:  push      cx
         mov       ax,14h
         add       ax,[bp-4]
         push      ax
         mov       ax,[bp-8]
         mov       cx,1
         shl       ax,cl
         pop       cx
         add       ax,cx
         mov       [bp-10h],ax
         mov       ax,3Ah
         add       ax,[bp-4]
         push      ax
         mov       ax,[bp-8]
         mov       cx,1
         shl       ax,cl
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       [bp-12h],ax
         mov       ax,1
         add       ax,[bp-6]
         add       ax,[bp-8]
         mov       [bp-14h],ax
         mov       ax,0Fh
         add       ax,[bp-6]
         sub       ax,[bp-8]
         mov       [bp-16h],ax
         mov       ax,[bp-8]
         xchg      ax,di
         mov       al,cs:[l_F5B7+di]
         xor       ah,ah
         mov       [bp-17h],al
         mov       ax,[bp-10h]
         push      ax
         mov       ax,[bp-12h]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_F71C
         ;jmp       l_F74D
         db        0e9h
         dw        l_F74D-$-2

l_F71C:  inc       cx
         mov       [bp-0Ch],ax
l_F720:  push      cx
         mov       al,[bp-17h]
         xor       ah,ah
         push      ax                       ; znak
         mov       ax,[bp-0Ch]
         push      ax                       ; pozice
         mov       ax,[bp-14h]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         mov       al,[bp-17h]
         xor       ah,ah
         push      ax                       ; znak
         mov       ax,[bp-0Ch]
         push      ax                       ; pozice
         mov       ax,[bp-16h]
         push      ax                       ; © dek
         call      l_34C7                   ; v˜stup znaku na displej
         pop       cx
         dec       cx
         jz        l_F74D
         inc       word ptr [bp-0Ch]
         ;jmp       l_F720
         db        0e9h
         dw        l_F720-$-2

l_F74D:  mov       ax,[bp-14h]
         push      ax
         mov       ax,[bp-16h]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_F75D
         ;jmp       l_F7B8
         db        0e9h
         dw        l_F7B8-$-2

l_F75D:  inc       cx
         mov       [bp-0Eh],ax
l_F761:  push      cx
         mov       ax,[bp-10h]
         push      ax
         mov       ax,[bp-0Eh]
         push      ax
         mov       al,[bp-17h]
         xor       ah,ah
         push      ax
         mov       al,[bp-17h]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,[bp-12h]
         push      ax
         mov       ax,[bp-0Eh]
         push      ax
         mov       al,[bp-17h]
         xor       ah,ah
         push      ax
         mov       al,[bp-17h]
         xor       ah,ah
         mov       ah,al
         mov       al,1
         push      ax
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         pop       cx
         dec       cx
         jz        l_F7B8
         inc       word ptr [bp-0Eh]
         ;jmp       l_F761
         db        0e9h
         dw        l_F761-$-2

l_F7B8:  pop       cx
         dec       cx
         jz        l_F7C2
         inc       word ptr [bp-8]
         jmp       l_F6BA

l_F7C2:  mov       ax,1Dh
         add       ax,[bp-4]
         push      ax
         mov       ax,6
         add       ax,[bp-6]
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,255,'K',255,'o',255,'n',255,'T',255,'e',255,'x',255,'t  ',255,'P',255,'r',255,'o'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,22h
         add       ax,[bp-4]
         push      ax
         mov       ax,7
         add       ax,[bp-6]
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        12,' Verze 2.2‡ '

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,8
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - podtr‘en˜
         mov       ax,1dh
         add       ax,[bp-4]
         push      ax
         mov       ax,8
         add       ax,[bp-6]
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,'(C) 1989  DMV Software'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,0
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - bˆ‘n˜
         mov       ax,1dh
         add       ax,[bp-4]
         push      ax
         mov       ax,10
         add       ax,[bp-6]
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,'Autor: Matthias Uphoff'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         dec       sp
         call      l_7D61                   ; na‡ten¡ cit tu ze soub. CITATY.TXT
         jnz       l_F88D                   ; na‡teno OK
         ;jmp       l_F8E1
         db        0e9h
         dw        l_F8E1-$-2

l_F88D:  mov       ax,ds:[d_FDCD]           ; max. po‡et znak– na © dek displeje
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       cx,1
         shr       ax,cl
         inc       ax
         push      ax
         mov       ax,11h
         add       ax,[bp-6]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,ds:[d_FDCD]           ; max. po‡et znak– na © dek displeje
         push      ax
         mov       al,ds:[d_F059]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       cx,1
         shr       ax,cl
         inc       ax
         push      ax
         mov       ax,12h
         add       ax,[bp-6]
         push      ax
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

l_F8E1:  mov       ax,20h
         mov       ds:[d_FE56],al           ; m¢d zobrazen¡ znaku - inverzn¡
         mov       ax,1Ah
         add       ax,[bp-4]
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        29,'Stisknˆte libovolnou kl vesu!'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         mov       [bp-8],ax
         ;jmp       l_F926
         db        0e9h
         dw        l_F926-$-2

l_F926:  mov       sp,bp
         pop       bp
         ret

l_F5B0   ENDP

; *****************************************************************************
;
;                  z kladn¡ obsluha editace souboru
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        obsluha editace souboru
; -----------------------------------------------------------------------------

l_F92A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_F931
         db        0e9h
         dw        l_F931-$-2

l_F931:  jmp       short l_F95F

; -----------------------------------------------------------------------------
;        zapnut¡/vypnut¡ kurzoru (BL=0 kurzor je vypnut)
; -----------------------------------------------------------------------------

l_F933   PROC      NEAR

; ------ vypnut¡ kurzoru

         or        bl,bl                    ; je kurzor vypnut ?
         jz        l_F94F                   ; kurzor je vypnut

; ------ zmˆna zobrazen¡ kurzoru

l_F937:  push      ax
         push      bx
         push      dx
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         add       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         push      ax
         push      word ptr ds:[d_E69C]     ; ‡¡slo © dku kurzoru na obrazovce
         call      l_352A                   ; zobrazen¡ kurzoru
         pop       dx
         pop       bx
         pop       ax
         not       bl                       ; zmˆna p©¡znaku zapnut¡ kurzoru
l_F94F:  ret

l_F933   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_F950   PROC      NEAR

         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         cmp       byte ptr cs:[l_3264],0   ; zobr. line lu © d.(1=zap., 0=vyp.)
         je        l_F95E                   ; line l © dku nezobrazen
         call      l_441E                   ; zobrazen¡ line lu © dku
l_F95E:  ret

l_F950   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_F92A)
; -----------------------------------------------------------------------------

; ------ p©i prvn¡m pr–chodu £schova registr– BP a SP

l_F95F:  xor       ax,ax
         ;cmp       al,[bp+4]
         db        3Ah,86h,4,0              ;!
         je        l_F971
         mov       word ptr ds:[d_F7AD],bp  ; uschovan˜ registr BP bˆhem editace
         mov       word ptr ds:[d_F7AF],sp
         jmp       short l_F97C

; ------ p©i dal¨¡ch pr–chodech m vrat registr– BP a SP

l_F971:  mov       bp,word ptr ds:[d_F7AD]  ; uschovan˜ registr BP bˆhem editace
         mov       sp,word ptr ds:[d_F7AF]
         mov       ds:[d_0188],ax

; ------ omezen¡ pozice kurzoru na maxim ln¡ pozici (239)

l_F97C:  mov       cl,MAXPOZL               ; maxim ln¡ pozice na © dku
         sub       cl,byte ptr cs:[l_3259]  ; - po‡ te‡n¡ pozice = max. znak–
         mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         cmp       bl,cl                    ; je kurzor za max. koncem © dku ?
         jbe       l_F991                   ; kurzor je OK
         mov       bl,cl                    ; omezen¡ kurzoru na konec © dku
         mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na © dku

l_F991:  cmp       bl,1
         jne       l_F9A8
         xor       ax,ax
         xchg      ax,word ptr ds:[d_E6A4]  ; offset za‡ tku zobrazen‚ho © dku
         or        ax,ax
         jz        l_F9A8
         push      bx
         call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku
         call      l_F950
         pop       bx

; ------ normalizace ukazatel– textu (po‡ tek © dku)

l_F9A8:  add       bl,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         dec       sp
         push      bx                       ; tiskov  pozice kurzoru na © dku
         call      l_491F                   ; normalizace kurzoru na © dku

; ------ zobrazen¡ chybov‚ho hl ¨en¡

         mov       ah,byte ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         or        ah,ah                    ; je nˆjak  chyba ?
         jz        l_F9BF                   ; nen¡ ‘ dn  chyba
         push      ax
         call      l_5A89                   ; zobrazen¡ chybov‚ho hl ¨en¡
         pop       ax

; ------ vymaz n¡ horn¡ho stavov‚ho © dku po zobrazen¡ chybov‚ho hl ¨en¡

l_F9BF:  or        ax,ax                    ; byla nˆjak  chyba ?
         jz        l_F9C6                   ; nebyla chyba
         call      l_F950                   ; zobrazen¡ horn¡ho stavov‚ho © dku

; ------ aktualizace parametr– ve stavov‚m © dku

l_F9C6:  call      l_468D                   ; zobrazen¡ parametr– ve stav. © dku

; ------ zobrazen¡ kurzoru (prvn¡ zobrazen¡ = zapnut¡ kurzoru)

         xor       bx,bx                    ; p©¡znak - kurzor je vypnut
         call      l_F937                   ; zobrazen¡ kurzoru

; ------ ‡ten¡ ‡¡ta‡e syst‚mov‚ho ‡asu na po‡ tku ‡ek n¡

         mov       ah,0
         int       1Ah                      ; ‡ten¡ ‡¡ta‡e syst‚mov‚ho ‡asu

; ------ obsluha blik n¡ kurzoru

l_F9D2:  mov       al,byte ptr cs:[l_3276]  ; blik n¡ kurzoru (1=zap., 0=vyp.)
         xor       al,byte ptr ds:[d_F78B]  ; 1=p©echodn‚ vypnut¡ blik n¡ kurz.
         jz        l_F9FA                   ; kurzor nem  blikat
         push      dx
         push      bx
         mov       ah,0
         int       1Ah                      ; ‡ten¡ ‡¡ta‡e syst‚mov‚ho ‡asu
         mov       cx,dx                    ; CX <- ‡¡ta‡ ‡asu LOW
         mov       ax,dx                    ; AX <- ‡¡ta‡ ‡asu LOW
         pop       bx
         pop       dx
         sub       cx,dx                    ; rozd¡l od posledn¡ho zobrazen¡
         jns       l_F9EE
         neg       cx
l_F9EE:  cmp       cl,byte ptr cs:[l_3268]  ; rychlost blik n¡ kurzoru
         jb        l_F9FA                   ; nen¡ je¨tˆ pln  doba pro bliknut¡
         mov       dx,ax                    ; £schova nov‚ho stavu hodin
         call      l_F937                   ; zmˆna zobrazen¡ kurzoru

; ------ test, zda se m  zobrazit n povˆda Ctrl-Shift

l_F9FA:  mov       ah,2
         int       16h                      ; poskytnut¡ stavu p©esmyka‡–
         and       al,7                     ; p©¡znaky Ctrl a Shift
         cmp       al,4                     ; jsou kl vesy Ctrl i Shift ?
         jbe       l_FA2D                   ; nejsou kl vesy Ctrl i Shift
         cmp       byte ptr ds:[d_F78D],0   ; byl prvn¡ znak ©¡dic¡ho k¢du ?
         jne       l_FA2D                   ; byl ji‘ prvn¡ znak ©¡dic¡ho k¢du

; ------ zobrazen¡ n povˆdy Ctrl-Shift

         call      l_F933                   ; vypnut¡ kurzoru
         push      bx
         push      dx
         xor       ax,ax
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         push      ax
         xor       ax,ax
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         pop       ax
         pop       dx
         pop       bx
         and       al,1Fh                   ; ©¡dic¡ kl vesa
         cmp       al,ESCP                  ; je ESC ?
         jne       l_FA3C                   ; nen¡ ESC - obsluha kl vesy

         call      l_F937                   ; zobrazen¡ kurzoru a pokra‡ov n¡

; ------ vstup znaku z kl vesnice

l_FA2D:  push      bx
         push      dx
         push      ax
         call      l_5444                   ; vstup z kl vesnice + makra + tisk
         pop       dx
         pop       bx
         or        al,al                    ; byla nˆjak  kl vesa ?
         jz        l_F9D2                   ; nebyla ‘ dn  kl vesa-dal¨¡ ‡ek n¡
         call      l_F933                   ; vypnut¡ kurzoru

; ------

l_FA3C:  push      ax
         cmp       ah,byte ptr ds:[d_F78D]
         je        l_FA49
         call      l_AD5F
         jmp       l_F97C

; ------ rozli¨en¡, zda je ©¡dic¡ kl vesa

l_FA49:  cmp       al," "                   ; je platn˜ znak ASCII ?
         jae       l_FA57                   ; je platn˜ znak ASCII
         cmp       al,CtrlU                 ; je kl vesa Ctrl-U ?
         je        l_FA57                   ; je platn˜ znak Ctrl-U

; ------ obsluha ©¡dic¡ kl vesy

         call      l_F45C                   ; obsluha ©¡dic¡ kl vesy
         jmp       l_F97C

; ------ vlo‘en¡ platn‚ho znaku do © dku

l_FA57:  call      l_C71A                   ; vlo‘en¡ platn‚ho znaku do © dku
         jmp       l_F97C


l_FA5D:  ;jmp       l_FA60
         db        0e9h
         dw        l_FA60-$-2

l_FA60:  mov       sp,bp
         pop       bp
         ret       2

l_F92A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_FA66   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_FA6D
         db        0e9h
         dw        l_FA6D-$-2

l_FA6D:  mov       ax,[bp+6]
         mov       al,ah
         xor       ah,ah
         cmp       ax,2
         je        l_FA7C
         ;jmp       l_FA8A
         db        0e9h
         dw        l_FA8A-$-2

l_FA7C:  mov       ax,[bp+6]
         xor       ah,ah
         add       ax,32h
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         ;jmp       l_FA90
         db        0e9h
         dw        l_FA90-$-2

l_FA8A:  mov       ax,0FFh
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
l_FA90:  mov       ax,0
         push      ax
         call      l_F92A
         ;jmp       l_FA9A
         db        0e9h
         dw        l_FA9A-$-2

l_FA9A:  mov       sp,bp
         pop       bp
         ret       4

l_FA66   ENDP

; *****************************************************************************
;
;                         inicializace programu
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        inicializace programu
; -----------------------------------------------------------------------------

l_FAA0   PROC      NEAR

         call      l_962A

; ------ inicializace displeje

         mov       al,byte ptr cs:[l_3273]  ; © dkov.(1=©¡dk‚,2=st©edn¡,3=hust‚)
         xor       ah,ah
         push      ax                       ; aktu ln¡ © dkov n¡
         mov       al,byte ptr cs:[l_3274]  ; barva p¡sma-pop©ed¡ (0 a‘ 15)
         xor       ah,ah
         push      ax                       ; barva p¡sma - pop©ed¡
         mov       al,byte ptr cs:[l_3275]  ; barva podkladu-pozad¡ (0 a‘ 15)
         xor       ah,ah
         push      ax                       ; barva podkladu - pozad¡
         call      l_35CE                   ; inicializace displeje

; ------ vynulov n¡ u‘ivatelsk˜ch dat

         cld
         push      ds
         pop       es                       ; ES <- DS datov˜ segment
         mov       di,offset d_0260         ; buffer registr– pro vol n¡ INT 21h
         mov       cx,offset d_FCC7
         sub       cx,di
         xor       ax,ax                    ; AX <- 0 nulovac¡ slovo
         repne     stosb

; ------ inicializace ukazatel– na 1

         inc       ax                       ; AX <- 1
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       byte ptr ds:[d_E698],al  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       byte ptr ds:[d_E69A],al  ; pozice kurzoru na © dku
         mov       byte ptr ds:[d_E69C],al  ; ‡¡slo © dku kurzoru na obrazovce
         mov       byte ptr ds:[d_E6A0],al  ; © dek uschovan‚ zna‡ky v textu
         mov       byte ptr ds:[d_E6A2],al  ; pozice uschovan‚ zna‡ky v textu
         mov       byte ptr ds:[d_E690],al  ; © dek za‡ tku bloku
         mov       byte ptr ds:[d_E694],al  ; pozice za‡ tku sloupcov‚ho bloku

; ------ maxim ln¡ d‚lka © dku od lev‚ho okraje

         mov       ax,ds:[d_FDCD]           ; max. po‡et znak– na © dek displeje
         push      ax
         mov       al,byte ptr cs:[l_3259]  ; po‡ te‡n¡ pozice (lev˜ okraj)
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       word ptr ds:[d_E6A6],ax  ; maxim ln¡ d‚lka © dku od okraje

; ------ po‡et © dk– na str nku bez okraj–

         mov       al,byte ptr cs:[l_325D]  ; po‡et © dk– na str nku
         xor       ah,ah
         push      ax                       ; po‡et © dk– na str nku celkem
         mov       al,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         xor       ah,ah
         pop       cx                       ; po‡et © dk– na str nku celkem
         xchg      ax,cx
         sub       ax,cx                    ; ode‡ten¡ © dk– na z hlav¡
         push      ax
         mov       al,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         sub       ax,cx                    ; ode‡ten¡ © dk– na patu
         mov       word ptr ds:[d_F7A9],ax  ; po‡et © dk– na str nku bez okraj–

; ------ inicializace okraj– v line lu © dk–

         call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–

; ------ inicializace ukazatele konce maker

         dec       sp
         dec       sp
         mov       ax,0                     ; fiktivn¡ hledan‚ makro 0
         push      ax
         call      l_40D2                   ; nalezen¡ kl vesy v makrobufferu
         mov       word ptr ds:[d_F7A7],ax  ; ‡¡slo aktivn¡ho prostoru <- 0


         mov       ax,2
         push      ax                       ; 2
         mov       ax,5                     ; 5
         pop       cx                       ; 2
         xchg      ax,cx                    ; AX <- 2, CX <- 5
         sub       cx,ax                    ; CX <- 5 - 2 = 3
         jge       l_FB32                   ; OK
         ;jmp       l_FB49
         db        0e9h
         dw        l_FB49-$-2

; ------ inicializace parametr– jednotliv˜ch prostor– prodle prostoru 1

l_FB32:  inc       cx                       ; CX = 4
         mov       word ptr ds:[d_F7A7],ax  ; ‡¡slo aktivn¡ho prostoru = 2
l_FB36:  push      cx                       ; 4
         mov       ax,ds:[d_F7A7]           ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru
         pop       cx
         dec       cx
         jz        l_FB49
         inc       word ptr ds:[d_F7A7]     ; ‡¡slo aktivn¡ho prostoru
         ;jmp       l_FB36
         db        0e9h
         dw        l_FB36-$-2

; ------ inicializace parametr– aktivn¡ho prostoru 1

l_FB49:  mov       ax,1                     ; nov˜ aktivn¡ prostor 1
         mov       ds:[d_F7A7],ax           ; ‡¡slo aktivn¡ho prostoru
         mov       ax,MAXLINES
         mov       ds:[d_E69E],ax           ; maxim ln¡ po‡et © dk– prostoru 1
         mov       ax,ds:[d_F7A7]           ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru


         mov       ax,9
         mov       ds:[d_E68E],al
         call      l_6419

; ------ £schova syst‚mov‚ adresy DTA

         mov       ax,2Fh
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         mov       ax,ds:[d_0270]           ; registr ES pro vol n¡ INT 21h
         mov       ds:[d_F97E],ax           ; £schova p–vodn¡ adresy DTA-segment
         mov       ax,ds:[d_0262]           ; registr BX pro vol n¡ INT 21h
         mov       ds:[d_F980],ax           ; £schova p–vodn¡ adresy DTA-offset

; ------ test, zda je nˆco zad no v p©¡kazov‚m © dku

         call      l_0DB6                   ; po‡et parametr– v p©¡kazov‚m © dku
         cmp       ax,0                     ; je nˆco zad no ?
         jg        l_FB83                   ; je nˆco zad no
         ;jmp       l_FB89
         db        0e9h
         dw        l_FB89-$-2

; ------ rozbor zad n¡ parametr– v p©¡kazov‚m © dku

l_FB83:  call      l_F4F5                   ; rozbor zad n¡ parametr–
         ;jmp       l_FB8C
         db        0e9h
         dw        l_FB8C-$-2
;þ
; ------ nen¡ nic zad no - zobrazen¡ tituln¡ho obr zku

l_FB89:  call      l_F5B0                   ; zobrazen¡ tituln¡ho obr zku

l_FB8C:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         mov       ax,offset l_FA66
         mov       ds:[d_017E],ax           ; adresa obsluhy p©eru¨en¡
         jmp       short l_FBB1

; ------ data pro kontrolu modifikace programu

l_FB9A   db        0e9h
         dw        2CB6h - 100h - 3         ; instrukce JMP l_2CB6
         db        0e8h
         dw        0AB7h - 2CB6h - 3        ; instrukce CALL l_0AB7

; -----------------------------------------------------------------------------
;        kontrola jedn‚ instrukce se vzorkem
; -----------------------------------------------------------------------------

l_FBA0   PROC      NEAR

         mov       cx,3                     ; po‡et bajt– ke kontrole
l_FBA3:  mov       al,cs:[si]               ; kontroln¡ bajt
         cmp       al,cs:[di]               ; je zmˆna ?
         je        l_FBAC                   ; bajt nezmˆnˆn OK
         dec       bx                       ; p©¡znak modifikace programu
l_FBAC:  inc       si
         inc       di
         loop      l_FBA3                   ; dal¨¡ bajt
         ret

l_FBA0   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_FAA0)
; -----------------------------------------------------------------------------

; ------ £schova ukazatele z sobn¡ku

l_FBB1:  mov       ax,sp
         inc       ax
         inc       ax
         jz        l_FBB9                   ; je ukazatel 0fffeh
         dec       ax
         dec       ax
l_FBB9:  mov       word ptr ds:[d_F7AB],ax  ; uschovan˜ ukazatel z sobn¡ku SP

; ------ test, zda byl KONTEXT modifikov n

         mov       si,offset l_FB9A         ; kontroln¡ ©etˆzce
         mov       bl,0                     ; ‡¡ta‡ zmˆn
         mov       di,offset Start
         call      l_FBA0                   ; kontrola instrukce JMP l_2CB6
         mov       di,offset l_2CB6
         call      l_FBA0                   ; kontrola instrukce CALL l_0AB7
         or        bl,bl                    ; byla zmˆna ?
         jz        l_FBD6                   ; nebyla zmˆna
         mov       byte ptr ds:[d_F79D],63h ; k¢d chyby KonTextu - modifikov n
;þ
l_FBD6:  mov       ax,1
         push      ax
         call      l_F92A                   ; obsluha editace souboru
         ;jmp       l_FBE0
         db        0e9h
         dw        l_FBE0-$-2

; ------ konec programu

l_FBE0:  xor       ax,ax                    ; n vratov˜ k¢d 0 - v¨e OK
         call      near ptr l_0C6A          ; konec programu EXIT

l_FAA0   ENDP

         dw        0

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
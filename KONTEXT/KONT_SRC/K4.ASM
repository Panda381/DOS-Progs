
INCLUDE  KDEF.ASM

Code     SEGMENT   BYTE PUBLIC
         ASSUME    cs:Code,ds:Data

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-M, Enter (konec odstavce)
; -----------------------------------------------------------------------------

l_6003   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_600A
         db        0e9h,0,0

; ------ p©elomen¡ © dku, je-li zapnut INSERT

l_600A:  dec       sp
         dec       sp
         mov       al,byte ptr cs:[l_3267]  ; p©¡znak INSERT (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax                    ; je INSERT zapnut ?
         jnz       l_6019                   ; INSERT je zapnut
         ;jmp       l_601C
         db        0e9h
         dw        l_601C-$-2

l_6019:  call      l_5F02                   ; vlo‘en¡ pr zdn‚ho © dku Ctrl-N

; ------ test, zda je povoleno ozna‡en¡ konce odstavce

l_601C:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       al,byte ptr cs:[l_3262]  ; konec odstavce (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3265]  ; nedokumentn¡ m¢d (1=zap., 0=vyp.)
         xor       ah,ah
         xor       al,1
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_6038
         ;jmp       l_6060
         db        0e9h
         dw        l_6060-$-2

; ------ vlo‘en¡ znaku konce odstavce

l_6038:  mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         inc       ax
         mov       byte ptr ds:[d_EC59],al  ; d‚lka textov‚ho © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         mov       ax,11h                   ; znak konce odstavce
         mov       byte ptr ds:[d_EC59+di],al ; buffer textov‚ho © dku
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         xchg      ax,di
         push      di
         mov       ax,0
         pop       di
         mov       byte ptr ds:[d_ED59+di],al ; buffer atribut– znak– text. © dku
         call      l_4855                   ; korekce editovan‚ho © dku

; ------ p©esun kurzoru na za‡ tek © dku

l_6060:  call      l_5D74                   ; p©esun kurzoru na za‡ tek © dku

; ------ test, zda m  b˜t odskok autotabel toru

         mov       al,byte ptr cs:[l_3261]  ; auto-tabel tor (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       al,byte ptr cs:[l_3267]  ; p©¡znak INSERT (1=zap., 0=vyp.)
         xor       ah,ah
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_607A
         ;jmp       l_6082
         db        0e9h
         dw        l_6082-$-2

; ------ odskok autotabel toru

l_607A:  mov       di,offset d_E69A         ; pozice kurzoru na © dku
         push      ds
         push      di
         call      l_384B                   ; odskok autotabel toru

; ------ posun kurzoru o © dek dol–

l_6082:  call      l_5CE8                   ; posun kurzoru o © dek dol– Ctrl-X
         ;jmp       l_6088
         db        0e9h,0,0

l_6088:  mov       sp,bp
         pop       bp
         ret

l_6003   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-R (str nka nahoru)
; -----------------------------------------------------------------------------

l_608C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6093
         db        0e9h,0,0

l_6093:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_4A3C                   ; inic. bufferu ‡¡sel zobraz. © dk–
         mov       ax,word ptr ds:[d_E5E4]  ; tabulka zobrazen˜ch © dk–
         cmp       ax,1
         je        l_60A4
         ;jmp       l_60B3
         db        0e9h
         dw        l_60B3-$-2

l_60A4:  mov       ax,1
         mov       word ptr ds:[d_E69C],ax  ; ‡¡slo © dku kurzoru na obrazovce
         mov       ax,1
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         ;jmp       l_60EF
         db        0e9h
         dw        l_60EF-$-2

l_60B3:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         push      ax
         mov       al,byte ptr cs:[l_3263]  ; zobraz. str nk. (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         pop       cx
         imul      cx
         pop       cx
         add       ax,cx
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,1
         jl        l_60E3
         ;jmp       l_60E9
         db        0e9h
         dw        l_60E9-$-2

l_60E3:  mov       ax,1
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
l_60E9:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
l_60EF:  ;jmp       l_60F2
         db        0e9h,0,0

l_60F2:  mov       sp,bp
         pop       bp
         ret

l_608C   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-C (str nka dol–)
; -----------------------------------------------------------------------------

l_60F6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_60FD
         db        0e9h,0,0

l_60FD:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         dec       ax
         pop       cx
         add       ax,cx
         push      ax
         mov       al,byte ptr cs:[l_3263]  ; zobraz. str nk. (1=zap., 0=vyp.)
         xor       ah,ah
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         cwd       
         idiv      word ptr ds:[d_F7A9]     ; po‡et © dk– na str nku bez okraj–
         pop       cx
         imul      cx
         pop       cx
         xchg      ax,cx
         sub       ax,cx
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         jg        l_6131
         ;jmp       l_6137
         db        0e9h
         dw        l_6137-$-2

l_6131:  mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
l_6137:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
         ;jmp       l_6140
         db        0e9h,0,0

l_6140:  mov       sp,bp
         pop       bp
         ret

l_60F6   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_6144   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_614B
         db        0e9h,0,0

l_614B:  xor       ax,ax
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       byte ptr ds:[d_F789],al  ; 1=p©¡znak modifikace edit. © dku
         push      word ptr ds:[d_E698]     ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax
         call      l_3C04
         call      l_4A3C                   ; inic. bufferu ‡¡sel zobraz. © dk–
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         mov       bx,ax
         dec       bx
         shl       bx,1
         add       bx,offset d_E5E4         ; tabulka zobrazen˜ch © dk–
l_616B:  mov       cx,ax
         xor       dx,dx
l_616F:  cmp       cx,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         jae       l_617E
         cmp       dx,[bx]
         je        l_617E
         inc       cx
         inc       bx
         inc       bx
         jmp       short l_616F

l_617E:  cmp       dx,[bx]
         jne       l_6185
         dec       cx
         dec       bx
         dec       bx
l_6185:  push      bx
         push      cx
         push      word ptr [bx]
         push      cx
         inc       dx
         push      dx
         push      ax
         push      word ptr ds:[d_FDCD]     ; max. po‡et znak– na © dek displeje
         push      cx
         call      l_355B                   ; rolov n¡ okna nahoru
         call      l_4978                   ; zobrazen¡ zadan‚ho © dku
         pop       ax
         pop       bx
         inc       ax
         inc       ax
         add       bx,4
         cmp       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         jbe       l_616B
         ;jmp       l_61A8
         db        0e9h,0,0

l_61A8:  mov       sp,bp
         pop       bp
         ret

l_6144   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-Y a Maz n¡/cel˜ © dek (vymaz n¡ © dku)
; -----------------------------------------------------------------------------

l_61AC   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_61B3
         db        0e9h,0,0

l_61B3:  mov       ax,2                     ; m¢d - ru¨¡ se © dek
         push      ax
         call      l_5972                   ; £schova ru¨en‚ho © dku k navr cen¡
         call      l_6144
         call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
         ;jmp       l_61C3
         db        0e9h,0,0

l_61C3:  mov       sp,bp
         pop       bp
         ret

l_61AC   ENDP

; -----------------------------------------------------------------------------
;        spojen¡ dvou textov˜ch © dk–
; -----------------------------------------------------------------------------

l_61C7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_61CE
         db        0e9h,0,0

l_61CE:  call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         inc       ax
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F159
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         call      l_376B                   ; nastaven¡ nov‚ d‚lky editov. © dku
         mov       ax,1
         push      ax
         call      l_3950                   ; spojen¡ textov˜ch © dk–
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         je        l_61FC
         ;jmp       l_621A
         db        0e9h
         dw        l_621A-$-2

l_61FC:  mov       ax,3
         push      ax
         call      l_5972                   ; £schova © dku k navr cen¡ zmˆn
         mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_E6A6]  ; maxim ln¡ d‚lka © dku od L okraje
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         call      l_5C9F                   ; posun kurzoru o © dek dol–
         call      l_6144
         call      l_5C32                   ; posun kurzoru o © dek nahoru
         call      l_555F                   ; vypr zdnˆn¡ bufferu kl vesnice
l_621A:  ;jmp       l_621D
         db        0e9h,0,0

l_621D:  mov       sp,bp
         pop       bp
         ret

l_61C7   ENDP

; -----------------------------------------------------------------------------
;        zru¨en¡ znaku za kurzorem
; -----------------------------------------------------------------------------

l_6221   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6228
         db        0e9h,0,0

l_6228:  mov       bx,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         cmp       bl,[di]
         ja        l_625F
         mov       ax,1
         mov       byte ptr ds:[d_E6A8],ah  ; 0=p©¡znak modifikace textu
         dec       bx
         cmp       byte ptr [bx+di],0FFh
         je        l_6241
         inc       bx
l_6241:  mov       word ptr ds:[d_E69A],bx  ; pozice kurzoru na © dku
         push      bx
         push      bx
         cmp       byte ptr [bx+di],0FFh
         jne       l_624D
         inc       ax
l_624D:  push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         mov       ah,0
         inc       ax
         inc       ax
         push      ax
         call      l_4855                   ; korekce editovan‚ho © dku
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_625F:  ;jmp       l_6262
         db        0e9h,0,0

l_6262:  mov       sp,bp
         pop       bp
         ret

l_6221   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-G (maz n¡ znaku nad kurzorem)
; -----------------------------------------------------------------------------

l_6266   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_626D
         db        0e9h,0,0

; ------ p©¡prava editovan‚ho © dku

l_626D:  mov       ax,1
         push      ax
         call      l_5972                   ; £schova © dku k navr cen¡ zmˆn
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku

; ------ rozli¨en¡, zda je kurzor na konci © dku

         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx                    ; je kurzor na konci © dku ?
         jg        l_628C
         ;jmp       l_6292
         db        0e9h
         dw        l_6292-$-2

; ------ kurzor je na konci © dku - spojen¡ dvou textov˜ch © dk–

l_628C:  call      l_61C7                   ; spojen¡ dvou textov˜ch © dk–
         ;jmp       l_6295
         db        0e9h
         dw        l_6295-$-2

; ------ kurzor nen¡ na konci © dku - zru¨en¡ znaku za kurzorem

l_6292:  call      l_6221                   ; zru¨en¡ znaku za kurzorem
l_6295:  ;jmp       l_6298
         db        0e9h,0,0

l_6298:  mov       sp,bp
         pop       bp
         ret

l_6266   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-H (maz n¡ znaku p©ed kurzorem)
; -----------------------------------------------------------------------------

l_629C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_62A3
         db        0e9h,0,0

l_62A3:  dec       sp
         dec       sp
         mov       ax,1
         push      ax
         call      l_5972                   ; £schova © dku k navr cen¡ zmˆn
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       al,byte ptr ds:[d_F78F]  ; 1=p©¡znak dekadick‚ho tabel toru
         xor       ah,ah
         or        ax,ax
         jnz       l_62BB
         ;jmp       l_62EE
         db        0e9h
         dw        l_62EE-$-2

l_62BB:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         dec       ax
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di                       ; pozice kurzoru
         call      l_38DD                   ; nalezen¡ za‡ tku slova
         mov       ax,[bp-4]                
         push      ax                       ; pozice k odsunu zbytku © dku
         mov       ax,1                     
         push      ax                       ; po‡et znak– k odsunu
         call      l_3799                   ; odsun zbytku © dku INSERT
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax                       ; pozice pro doplnˆn¡
         mov       ax,1                     
         push      ax                       ; po‡et znak– pro doplnˆn¡
         call      l_372A                   ; doplnˆn¡ editov. © dku mezerami
         mov       ax,[bp-4]
         push      ax
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         push      ax
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
         ;jmp       l_6323
         db        0e9h
         dw        l_6323-$-2

; ------ rozli¨en¡, zda je kurzor na za‡ tku © dku

l_62EE:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         cmp       ax,1
         mov       ax,1
         jz        l_62FA
         dec       ax
l_62FA:  push      ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,1
         mov       ax,1
         jg        l_6307
         dec       ax
l_6307:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_6311
         ;jmp       l_631D
         db        0e9h
         dw        l_631D-$-2

; ------ kurzor je na za‡ tku © dku - spojen¡ © dk–

l_6311:  call      l_5C8B                   ; posun kurzoru o © dek nahoru CtrlE
         call      l_5DC2                   ; p©esun kurzoru na konec © dku
         call      l_61C7                   ; spojen¡ dvou textov˜ch © dk–
         ;jmp       l_6323
         db        0e9h
         dw        l_6323-$-2

; ------ kurzor nen¡ na za‡ tku © dku - zru¨en¡ znaku p©ed kurzorem

l_631D:  call      l_5D88                   ; kurzor o pozici vlevo
         call      l_6221                   ; zru¨en¡ znaku za kurzorem
l_6323:  ;jmp       l_6326
         db        0e9h,0,0

l_6326:  mov       sp,bp
         pop       bp
         ret

l_629C   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-T a Maz n¡/slovo vpravo (maz n¡ slova vpravo)
; -----------------------------------------------------------------------------

l_632A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6331
         db        0e9h,0,0

l_6331:  mov       ax,1
         push      ax
         call      l_5972                   ; £schova © dku k navr cen¡ zmˆn
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         call      l_4855                   ; korekce editovan‚ho © dku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       cl,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         mov       ch,0
         cmp       ax,cx
         jbe       l_6351
         call      l_61C7                   ; spojen¡ dvou textov˜ch © dk–
         jmp       l_63D3

l_6351:  mov       byte ptr ds:[d_E6A8],ah  ; 0=p©¡znak modifikace textu
         mov       bx,ax
         cmp       byte ptr ds:[d_EC59+bx-1],0FFh ; buffer textov‚ho © dku
         jne       l_635F
         dec       ax
l_635F:  mov       word ptr ds:[d_E69A],ax  ; pozice kurzoru na © dku
         mov       si,offset d_EC59         ; buffer textov‚ho © dku
         push      ax
         dec       bx
l_6367:  inc       bx
         mov       al,[bx+si]
         cmp       al,0FFh
         je        l_6367
         cmp       al,20h
         je        l_63AD
         push      bx
         mov       bx,offset l_3378
         xlat      cs:[bx]
         pop       bx
         test      al,2
         jz        l_6395
l_637D:  inc       bx
         cmp       bl,cl
         ja        l_63BC
         mov       al,[bx+si]
         cmp       al,0FFh
         je        l_637D
         push      bx
         mov       bx,offset l_3378
         xlat      cs:[bx]
         pop       bx
         test      al,2
         jnz       l_637D
         jmp       short l_63BC

l_6395:  inc       bx
         cmp       bl,cl
         ja        l_63BC
         mov       al,[bx+si]
         cmp       al,20h
         je        l_63BC
         push      bx
         mov       bx,offset l_3378
         xlat      cs:[bx]
         pop       bx
         test      al,2
         jz        l_6395
         jmp       short l_63BC

l_63AD:  inc       bx
         cmp       bl,cl
         ja        l_63BC
         mov       al,[bx+si]
         cmp       al,0FFh
         je        l_63AD
         cmp       al,20h
         je        l_63AD
l_63BC:  cmp       byte ptr [bx+si-1],0FFh
         jne       l_63C3
         dec       bx
l_63C3:  pop       ax
         push      ax
         push      cx
         push      ax
         sub       bx,ax
         push      bx
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         call      l_4855                   ; korekce editovan‚ho © dku
         call      l_4832                   ; zobrazen¡ aktivn¡ho edit. © dku
l_63D3:  ;jmp       l_63D6
         db        0e9h,0,0

l_63D6:  mov       sp,bp
         pop       bp
         ret

l_632A   ENDP

; -----------------------------------------------------------------------------
;        vol n¡ slu‘by DOS INT 21h
; -----------------------------------------------------------------------------

l_63DA   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_63E1
         db        0e9h,0,0

l_63E1:  mov       al,[bp+4]                ; ‡¡slo po‘adovan‚ slu‘by DOS
         xor       ah,ah
         mov       byte ptr ds:[d_0260+1],al ; ‡¡slo po‘adovan‚ slu‘by DOS (=AH)
         mov       di,offset d_0260         ; buffer registr–
         push      ds
         call      l_0F48                   ; nastaven¡ registr– z bufferu
         int       21h                      ; vol n¡ slu‘by DOS
         call      l_0F70                   ; ulo‘en¡ registr– do bufferu
         ;jmp       l_63F8
         db        0e9h,0,0

l_63F8:  mov       sp,bp
         pop       bp
         ret       2

l_63DA   ENDP

; -----------------------------------------------------------------------------
;        obsluha INT 24h
; -----------------------------------------------------------------------------

l_63FE   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       near ptr int_24h
         db        0e9h,0,0

int_24h  proc      far

         sti
         mov       cs:[l_34AF],ax           ; chyba INT 24h - informa‡n¡ registr
         mov       cs:[l_34B1],di           ; chyba INT 24h - k¢d chyby
         mov       al,3
         iret      

int_24h  endp

         ;jmp       l_6415
         db        0e9h,0,0

l_6415:  mov       sp,bp
         pop       bp
         ret

l_63FE   ENDP

; -----------------------------------------------------------------------------
;        instalace obsluhy INT 24h
; -----------------------------------------------------------------------------

l_6419   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6420
         db        0e9h,0,0

; ------ £schova p–vodn¡ adresy INT 24h

l_6420:  push      ds
         mov       ax,3524h
         int       21h                      ; poskytnut¡ adresy INT 24h
         mov       word ptr ds:[d_F972],es  ; £schova adresy INT 24h
         mov       word ptr ds:[d_F974],bx

; ------ instalace obsluhy INT 24h

         mov       ax,2524h
         mov       dx,offset l_63FE         ; adresa obsluhy INT 24h
         add       dx,offset(int_24h - l_63FE)
         mov       bx,cs
         mov       ds,bx
         int       21h                      ; instalace obsluhy INT 24h
         pop       ds
         ;jmp       l_6441
         db        0e9h,0,0

l_6441:  mov       sp,bp
         pop       bp
         ret

l_6419   ENDP

; -----------------------------------------------------------------------------
;        odinstalov n¡ obsluhy INT 24h
; -----------------------------------------------------------------------------

l_6445   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_644C
         db        0e9h,0,0

l_644C:  mov       ax,24h
         mov       byte ptr ds:[d_0260],al  ; registr AL pro vol n¡ INT 21h
         mov       ax,ds:[d_F972]           ; p–vodn¡ adresa INT 24h - segment
         mov       ds:[d_026E],ax           ; registr DS pro vol n¡ INT 21h
         mov       ax,ds:[d_F974]           ; p–vodn¡ adresa INT 24h - offset
         mov       ds:[d_0266],ax           ; registr DX pro vol n¡ INT 21h
         mov       ax,25h                   ; n vrat adresy obsluhy INT 24h
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         ;jmp       l_6468
         db        0e9h,0,0

l_6468:  mov       sp,bp
         pop       bp
         ret

l_6445   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ syst‚mov‚ho ‡asu
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (15) buffer k dek¢dov n¡ syst‚mov‚ho ‡asu
; -----------------------------------------------------------------------------

l_646C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6473
         db        0e9h,0,0

l_6473:  sub       sp,15                    ; lok ln¡ buffer
         jmp       short l_648B             ; dek¢dov n¡ syst‚mov‚ho ‡asu

; -----------------------------------------------------------------------------
;        dek¢dov n¡ bajtu AL na dvoj‡¡sl¡ ASCII
; -----------------------------------------------------------------------------

l_6478   PROC      NEAR

         aam                                ; p©evod na 2 ‡¡slice
         add       ax,"00"                  ; p©evod na znaky ASCII
         mov       ss:[bx],ah               ; prvn¡ ‡¡slice (des¡tky)
         inc       bx
         mov       ss:[bx],al               ; druh  ‡¡slice (jednotky)
         inc       bx
         mov       byte ptr ss:[bx],":"     ; oddˆlova‡ ‡¡slic
         inc       bx
         ret

l_6478   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_646C - dek¢dov n¡ syst‚mov‚ho ‡asu)
; -----------------------------------------------------------------------------

; ------ poskytnut¡ syst‚mov‚ho ‡asu

l_648B:  mov       ah,2Ch
         int       21h                      ; poskytnut¡ syst‚mov‚ho ‡asu
         ;lea       bx,[bp-11h]
         db        8Dh,9Eh,0EFh,0FFh
         mov       byte ptr ss:[bx],8       ; d‚lka textu syst‚mov‚ho ‡asu

; ------ dek¢dov n¡ hodiny

         inc       bx
         mov       al,ch                    ; hodina
         call      l_6478                   ; dek¢dov n¡ hodiny na ‡¡slice ASCII
         cmp       ah,"0"                   ; byla prvn¡ ‡¡slice hodiny "0" ?
         jne       l_64A7                   ; prvn¡ ‡¡slice nebyla "0"
         mov       byte ptr ss:[bx-3]," "   ; vymaz n¡ prvn¡ nev˜znamn‚ nuly

; ------ dek¢dov n¡ minuty

l_64A7:  mov       al,cl                    ; minuta
         call      l_6478                   ; dek¢dov n¡ minuty na ‡¡slice ASCII

; ------ dek¢dov n¡ sekundy

         mov       al,dh                    ; sekunda
         call      l_6478                   ; dek¢dov n¡ sekundy na ‡¡slo ASCII

; ------ p©enesen¡ dek¢dovan‚ho ©etˆzce do z sobn¡ku

         lea       di,[bp+4]                ; adresa ukazatele bufferu
         push      ss                       ; segment ukazatele bufferu
         push      di                       ; adresa ukazatele bufferu
         lea       di,[bp-11h]              ; offset adresy ©etˆzce
         push      ss                       ; segment adresy ©etˆzce
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku

; ------ p©enesen¡ ©etˆzce ze z sobn¡ku do bufferu

         mov       cl,14                    ; omezen¡ - velikost c¡l. bufferu
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         ;jmp       l_64C5
         db        0e9h,0,0

; ------ redukce d‚lky bufferu na minimum (na d‚lku ©etˆzce)

l_64C5:  mov       dx,0                     ; po‡et bajt– ke zru¨en¡ ze z sob.
         mov       cl,14                    ; d‚lka c¡lov‚ho bufferu
         mov       sp,bp                    ; n vrat SP
         pop       bp                       ; n vrat BP
         jmp       l_1475                   ; redukce d‚lky bufferu na minimum

l_646C   ENDP

; -----------------------------------------------------------------------------
;        dek¢dov n¡ syst‚mov‚ho data
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (15) buffer k dek¢dov n¡ syst‚mov‚ho data
; -----------------------------------------------------------------------------

l_64D0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_64D7
         db        0e9h,0,0

; ------ poskytnut¡ syst‚mov‚ho data

l_64D7:  mov       ax,2Ah                   ; funkce - poskytnut¡ syst‚m. data
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         lea       di,[bp+4]                ; adresa ukazatele bufferu
         push      ss
         push      di

; ------ dek¢dov n¡ dne

         sub       sp,9                     ; rezerva m¡sta pro ©etˆzec
         mov       al,byte ptr ds:[d_0266]  ; registr DL - den
         xor       ah,ah                    ; AH <- 0
         push      ax                       ; ‡¡slo k p©evodu
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec

; ------ oddˆlovac¡ te‡ka

         mov       ax,"."*HI + 1            ; ©etˆzec - znak "."
         push      ax                       
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ dek¢dov n¡ mˆs¡ce

         sub       sp,9                     ; rezerva m¡sta pro ©etˆzec
         mov       al,byte ptr ds:[d_0266+1] ; registr DH - mˆs¡c
         xor       ah,ah                    ; AH <- 0
         push      ax                       ; ‡¡slo k p©evodu
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ oddˆlovac¡ te‡ka

         mov       ax,"."*HI + 1            ; ©etˆzec - znak "."
         push      ax                       
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ dek¢dov n¡ roku

         sub       sp,9                     ; rezerva m¡sta pro ©etˆzec
         mov       ax,ds:[d_0264]           ; registr CX - rok
         push      ax                       ; ‡¡slo k p©evodu
         call      l_36BB                   ; p©evod ‡¡sla INTEGER na ©etˆzec
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ p©enesen¡ ©etˆzce data do bufferu

         mov       cl,0Eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         ;jmp       l_6521
         db        0e9h,0,0

; ------ redukce d‚lky bufferu na minimum

l_6521:  mov       dx,0                     ; po‡et bajt– ke zru¨en¡ ze z sob.
         mov       cl,14                    ; d‚lka c¡lov‚ho bufferu
         mov       sp,bp
         pop       bp
         jmp       l_1475                   ; redukce d‚lky bufferu na minimum

l_64D0   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ seznamu soubor– aktivn¡ho adres ©e
; -----------------------------------------------------------------------------

l_652C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6533
         db        0e9h,0,0

l_6533:  jmp       short l_6539

l_6535   db        '*.*',0                  ; specifikace - v¨echny soubory

; ------ nastaven¡ pracovn¡ adresy DTA

l_6539:  push      ds
         mov       dx,offset d_F946         ; tabulka DTA
         mov       ah,1Ah
         int       21h                      ; nastaven¡ adresy tabulky DTA

; ------ nalezen¡ prvn¡ho souboru, adres ©e

         push      cs
         pop       ds                       ; DS <- CS
         mov       dx,offset l_6535         ; specifikace - v¨echny soubory
         mov       cl,30h                   ; atributy - i adres ©e
         mov       ah,4Eh
         int       21h                      ; nalezen¡ prvn¡ho souboru/adres ©e
         pop       ds
         mov       bx,0                     ; BX <- 0 ‡¡ta‡ nalezen˜ch polo‘ek
         jc        l_6590                   ; chyba - nic nenalezeno
         push      ds
         pop       es                       ; ES <- segment bufferu seznamu
         mov       di,offset d_CD98         ; buffer seznamu soubor–
l_6557:  mov       si,offset d_F95B         ; tabulka souboru DTA - atributy

; ------ rozli¨en¡, zda je platn  polo‘ka (adres © "." se ignoruje)

         cmp       word ptr [si+9],"."      ; je to adres © "." ?
         je        l_658A                   ; je to adres © "." - neplat¡
         inc       bx                       ; zv˜¨en¡ ‡¡ta‡e nalezen˜ch polo‘ek
         push      bx
         xor       bx,bx                    ; BX <- 0 offset v polo‘ce souboru

; ------ p©¡znak typu polo‘ky

         mov       al,0                     ; p©¡znak adres ©e
         cmp       byte ptr [si],10h        ; je to adres © ?
         je        l_656D                   ; je to adres ©
         mov       al,20h                   ; p©¡znak bˆ‘n‚ho souboru

; ------ p©enesen¡ jm‚na polo‘ky

l_656D:  inc       bx                       ; ukazatel v tabulce polo‘ky
         mov       [bx+di],al               ; ulo‘en¡ typu polo‘ky/znaku jm‚na
         mov       al,[bx+si+8]             ; znak jm‚na polo‘ky
         or        al,al                    ; je konec jm‚na polo‘ky ?
         jnz       l_656D                   ; nen¡ konec - dal¨¡ znak jm‚na
         mov       [di],bl                  ; ulo‘en¡ d‚lky jm‚na polo‘ky

; ------ p©enos ostatn¡ch parametr– - ‡asu, data a velikosti

         mov       cx,4
         inc       si                       ; p©esko‡en¡ atribut–
         add       di,15                    ; buffer parametr–
         cld       
         repne     movsw                    ; p©enos ‡asu, data a velikosti

; ------ test, zda je buffer ji‘ pln˜

         pop       bx
         cmp       bx,256                   ; je ji‘ maximum soubor– ?
         jae       l_6590                   ; buffer polo‘ek je ji‘ pln˜

; ------ nalezen¡ dal¨¡ho souboru, adres ©e

l_658A:  mov       ah,4Fh
         int       21h                      ; nalezen¡ dal¨¡ho souboru, adres ©e
         jnc       l_6557                   ; nalezen dal¨¡ soubor, adres ©

; ------ ulo‘en¡ po‡tu nalezen˜ch polo‘ek seznamu

l_6590:  ;les       si,dword ptr [bp+4]     ; adresa po‡tu polo‘ek seznamu
         db        0C4h,0B6h,4,0            ;!
         mov       es:[si],bx               ; po‡et nalezen˜ch polo‘ek seznamu
         or        bx,bx                    ; byla nalezena nˆjak  polo‘ka ?
         jz        l_65DC                   ; nebyla nalezena ‘ dn  polo‘ka

; ------ p©¡prava registr– k t©¡dˆn¡ adres ©e

         push      ds
         pop       es                       ; ES <- DS
         cld       
         mov       ch,0                     ; CH <- 0
         push      bx                       ; ‡¡ta‡ polo‘ek v seznamu
l_65A1:  mov       dx,bx                    ; d‚lka pr–chodu seznamem
         dec       bx                       ; dal¨¡ pr–chod bude o 1 krat¨¡
         jz        l_65DC                   ; byly ji‘ v¨echny pr–chody

; ------ jeden pr–chod t©¡dˆn¡ seznamem

         mov       si,offset d_CD98         ; za‡ tek seznamu polo‘ek
l_65A9:  dec       dx                       ; ‡¡ta‡ zbyl˜ch p r– polo‘ek
         jz        l_65A1                   ; konec jednoho pr–chodu t©¡dˆn¡

; ------ porovn n¡ jmen dvou polo‘ek za sebou

         mov       di,si                    ; adresa polo‘ky
         add       di,23                    ; adresa dal¨¡ polo‘ky
         push      si
         push      di
         mov       cl,[si]                  ; d‚lka jm‚na prvn¡ polo‘ky
         cmp       cl,[di]                  ; je del¨¡ nez jm‚no druh‚ polo‘ky ?
         jbe       l_65BB                   ; prvn¡ jm‚no je krat¨¡
         mov       cl,[di]                  ; bude se porovn vat podle druh‚ho
l_65BB:  inc       si                       ; za‡ tek jm‚na prvn¡ polo‘ky
         inc       di
         repe      cmpsb                    ; porovn n¡ jmen dvou polo‘ek
         pop       di
         pop       si
         jc        l_65D7                   ; prvn¡ polo‘ka je men¨¡ - to je OK
         ja        l_65CB                   ; prvn¡ polo‘ka je vˆt¨¡ - z mˆna

; ------ p©i shodˆ ‡ sti jm‚na porovn n¡ d‚lek jmen polo‘ek

         mov       al,[si]                  ; d‚lka prvn¡ho jm‚na
         cmp       al,[di]                  ; je del¨¡ ne‘ druh‚ jm‚no ?
         jbe       l_65D7                   ; prvn¡ polo‘ka je krat¨¡ - to je OK

; ------ z mˆna polo‘ek

l_65CB:  push      si
         mov       cl,23                    ; po‡et bajt– k z mˆnˆ
l_65CE:  mov       al,[di]
         movsb
         mov       [si-1],al
         loop      l_65CE                   ; z mˆna polo‘ek
         pop       si

; ------ p©¡prava k t©¡dˆn¡ dal¨¡ch polo‘ek

l_65D7:  add       si,23                    ; adresa dal¨¡ho p ru polo‘ek
         jmp       short l_65A9             ; dal¨¡ t©¡dˆn¡

l_65DC:  ;jmp       l_65DF
         db        0e9h,0,0

l_65DF:  mov       sp,bp
         pop       bp
         ret       4

l_652C   ENDP

; -----------------------------------------------------------------------------
;        kontrola, zda je ozna‡en blok (ZY=je ozna‡en)
; -----------------------------------------------------------------------------

l_65E5   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_65EC
         db        0e9h,0,0

l_65EC:  mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         xor       al,1
         jnz       l_65F8
         ;jmp       l_65FE
         db        0e9h
         dw        l_65FE-$-2

l_65F8:  mov       ax,10
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu-neozna‡en blok
l_65FE:  mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         xor       al,1
         mov       [bp+4],al
         ;jmp       l_660B
         db        0e9h,0,0

l_660B:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_65E5   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KH a Blok/ozna‡en¡ bloku (zobrazen¡ bloku zap/vyp)
; -----------------------------------------------------------------------------

l_6618   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_661F
         db        0e9h,0,0

l_661F:  sub       sp,3
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         cmp       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         mov       ax,1
         jle       l_662F
         dec       ax
l_662F:  push      ax
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         push      ax
         mov       ax,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         cmp       ax,word ptr ds:[d_E696]  ; pozice konec sloupcov‚ho bloku
         mov       ax,1
         jg        l_6643
         dec       ax
l_6643:  pop       cx
         and       ax,cx
         xor       al,1
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_6652
         ;jmp       l_66A6
         db        0e9h
         dw        l_66A6-$-2

l_6652:  call      l_4A3C                   ; inic. bufferu ‡¡sel zobraz. © dk–
         mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         mov       [bp-5],al
         mov       ax,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         mov       ax,1
         push      ax
         mov       ax,ds:[d_FDCF]           ; po‡et zobrazen˜ch textov˜ch © dk–
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_6673
         ;jmp       l_669C
         db        0e9h
         dw        l_669C-$-2

l_6673:  inc       cx
         mov       [bp-4],ax
l_6677:  push      cx
         mov       ax,[bp-4]
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         push      ax
         mov       ax,1
         push      ax
         mov       ax,0FFh
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_425F                   ; zobraz. ozna‡en¡ bloku pro 1 © dek
         pop       cx
         dec       cx
         jz        l_669C
         inc       word ptr [bp-4]
         ;jmp       l_6677
         db        0e9h
         dw        l_6677-$-2

l_669C:  mov       al,[bp-5]
         xor       ah,ah
         xor       al,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
l_66A6:  ;jmp       l_66A9
         db        0e9h,0,0

l_66A9:  mov       sp,bp
         pop       bp
         ret

l_6618   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KB a Blok/za‡ tek bloku (ozna‡en¡ za‡ tku bloku)
; -----------------------------------------------------------------------------

l_66AD   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_66B4
         db        0e9h,0,0

l_66B4:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku

; ------ zapnut¡ ozna‡en¡ bloku, nen¡-li zapnuto

         mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_66C3
         ;jmp       l_66C6
         db        0e9h
         dw        l_66C6-$-2
l_66C3:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)


l_66C6:  mov       ax,0
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jle       l_66D8
         ;jmp       l_66DE
         db        0e9h
         dw        l_66DE-$-2

l_66D8:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
l_66DE:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
         ;jmp       l_66E4
         db        0e9h,0,0

l_66E4:  mov       sp,bp
         pop       bp
         ret

l_66AD   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KK a Blok/konec bloku (ozna‡en¡ konce bloku)
; -----------------------------------------------------------------------------

l_66E8   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_66EF
         db        0e9h,0,0

; ------ zapnut¡ ozna‡en¡ bloku, nen¡-li zapnuto

l_66EF:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_66FE
         ;jmp       l_6701
         db        0e9h
         dw        l_6701-$-2
l_66FE:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)

l_6701:  mov       ax,0
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jg        l_6713
         ;jmp       l_671C
         db        0e9h
         dw        l_671C-$-2

l_6713:  mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         ;jmp       l_6722
         db        0e9h
         dw        l_6722-$-2

l_671C:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
l_6722:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
         ;jmp       l_6728
         db        0e9h,0,0

l_6728:  mov       sp,bp
         pop       bp
         ret

l_66E8   ENDP

; -----------------------------------------------------------------------------
;        volba Ctrl-KNB a Blok/za‡ tek sloupc. bloku (za‡ tek sloupcov‚ho bloku)
; -----------------------------------------------------------------------------

l_672C   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6733
         db        0e9h,0,0

l_6733:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_6742
         ;jmp       l_6745
         db        0e9h
         dw        l_6745-$-2

l_6742:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
l_6745:  mov       ax,1
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jle       l_6757
         ;jmp       l_675D
         db        0e9h
         dw        l_675D-$-2

l_6757:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
l_675D:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       word ptr ds:[d_E694],ax  ; pozice za‡ tku sloupcov‚ho bloku
         call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
         ;jmp       l_6769
         db        0e9h,0,0

l_6769:  mov       sp,bp
         pop       bp
         ret

l_672C   ENDP

; -----------------------------------------------------------------------------
;        volba Ctrl-KNK a Blok/konec sloupc. bloku (konec sloupcov‚ho bloku)
; -----------------------------------------------------------------------------

l_676D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6774
         db        0e9h,0,0

l_6774:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       al,byte ptr ds:[d_E6A9]  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_6783
         ;jmp       l_6786
         db        0e9h
         dw        l_6786-$-2

l_6783:  call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
l_6786:  mov       ax,1
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jg        l_6798
         ;jmp       l_67A1
         db        0e9h
         dw        l_67A1-$-2

l_6798:  mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         ;jmp       l_67A7
         db        0e9h
         dw        l_67A7-$-2

l_67A1:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
l_67A7:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       word ptr ds:[d_E696],ax  ; pozice konec sloupcov‚ho bloku
         call      l_6618                   ; zmˆna ozna‡en¡ bloku (zap/vyp)
         ;jmp       l_67B3
         db        0e9h,0,0

l_67B3:  mov       sp,bp
         pop       bp
         ret

l_676D   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KN (nastaven¡ za‡ tku a konce sloupcov‚ho bloku)
; -----------------------------------------------------------------------------

l_67B7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_67BE
         db        0e9h,0,0

; ------ zobrazen¡ n povˆdy

l_67BE:  dec       sp
         mov       ax,17h
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m
         dec       sp
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         mov       [bp-3],al
         mov       ax,17h
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou

; ------ volba Ctrl-KNB (nastaven¡ za‡ tku sloupcov‚ho bloku)

         mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,"B"                   ; nastaven¡ za‡ tku bloku ?
         je        l_67E7                   ; je nastaven¡ za‡ tku bloku
         ;jmp       l_67EA
         db        0e9h
         dw        l_67EA-$-2
l_67E7:  call      l_672C                   ; nastaven¡ za‡ tku sloupc. bloku

; ------ volba Ctrl-KNK (nastaven¡ konce sloupcov‚ho bloku)

l_67EA:  mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,"K"                   ; nastaven¡ konce bloku ?
         je        l_67F7                   ; je nastaven¡ konce bloku
         ;jmp       l_67FA
         db        0e9h
         dw        l_67FA-$-2
l_67F7:  call      l_676D                   ; nastaven¡ konce sloupc. bloku

l_67FA:  ;jmp       l_67FD
         db        0e9h,0,0

l_67FD:  mov       sp,bp
         pop       bp
         ret

l_67B7   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QB a Kurzor/za‡ tek bloku (kurzor na za‡ tek bloku)
; -----------------------------------------------------------------------------

l_6801   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6808
         db        0e9h,0,0

l_6808:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         call      l_4CC6                   ; p©esun kurzoru na zadan˜ © dek
         ;jmp       l_6812
         db        0e9h,0,0

l_6812:  mov       sp,bp
         pop       bp
         ret

l_6801   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-QK a Kurzor/konec bloku (kurzor na konec bloku)
; -----------------------------------------------------------------------------

l_6816   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_681D
         db        0e9h,0,0

l_681D:  mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         push      ax
         call      l_4CC6                   ; p©esun kurzoru na zadan˜ © dek
         ;jmp       l_6827
         db        0e9h,0,0

l_6827:  mov       sp,bp
         pop       bp
         ret

l_6816   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_682B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6832
         db        0e9h,0,0

l_6832:  mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       si,offset d_ED59         ; buffer atribut– znak– text. © dku
         mov       ax,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         mov       bx,word ptr ds:[d_E696]  ; pozice konec sloupcov‚ho bloku
         ;mov       cx,[bp+4]
         db        8Bh,8Eh,4,0              ;!
         push      cx
         push      ds
         push      di
         push      ds
         push      si
         push      ax
         sub       bx,ax
         inc       bx
         push      bx
         push      cx                       ; ‡¡slo © dku
         push      ds
         push      di
         push      ds
         push      si
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
         mov       al,0FFh
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       bl,[di]
         mov       bh,0
         inc       bx
l_6862:  inc       ax
l_6863:  dec       bx
         jz        l_6878
         cmp       byte ptr [bx+di],20h
         je        l_6863
         cmp       byte ptr [bx+di],11h
         je        l_6862
         or        al,al
         jz        l_6878
         inc       bx
         mov       byte ptr [bx+di],11h
l_6878:  mov       [di],bl
         call      l_3E83                   ; ulo‘en¡ edit. © dku do souboru
         ;jmp       l_6880
         db        0e9h,0,0

l_6880:  mov       sp,bp
         pop       bp
         ret       2

l_682B   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KY, Maz n¡/cel˜ blok a Blok/maz n¡ (ru¨en¡ bloku)
; -----------------------------------------------------------------------------

l_6886   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_688D
         db        0e9h,0,0

l_688D:  dec       sp
         dec       sp
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         jnz       l_6898
         ;jmp       l_689B
         db        0e9h
         dw        l_689B-$-2

l_6898:  jmp       l_69A9

l_689B:  mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         mov       word ptr ds:[d_F941],ax
         mov       ax,word ptr ds:[d_F941]
         push      ax
         mov       al,byte ptr cs:[l_326E]
         xor       ah,ah
         pop       cx
         xchg      ax,cx
         cmp       ax,cx
         jg        l_68C4
         ;jmp       l_68CD
         db        0e9h
         dw        l_68CD-$-2

l_68C4:  mov       al,byte ptr cs:[l_326E]
         xor       ah,ah
         mov       word ptr ds:[d_F941],ax
l_68CD:  mov       ax,0
         push      ax
         mov       ax,word ptr ds:[d_F941]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_68DD
         ;jmp       l_6912
         db        0e9h
         dw        l_6912-$-2

l_68DD:  inc       cx
         mov       [bp-4],ax
l_68E1:  push      cx
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         add       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_F7B1         ; buffer uschovan˜ch © dk– k obnovˆ
         push      ds
         push      di
         call      l_3C8D
         pop       cx
         dec       cx
         jz        l_6912
         inc       word ptr [bp-4]
         ;jmp       l_68E1
         db        0e9h
         dw        l_68E1-$-2

l_6912:  mov       ax,word ptr ds:[d_F941]
         inc       ax
         mov       word ptr ds:[d_F941],ax
         mov       di,offset d_F8F1
         push      ds
         push      di
         mov       ax,word ptr ds:[d_F941]
         push      ax
         mov       ax,2
         push      ax                       ; adresa
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         pop       cx                       ; d‚lka
         xchg      ax,cx
         sub       ax,cx                    ; konstanta
         call      l_0F25                   ; vynulov n¡ bufferu konstantou
         mov       ax,1
         mov       byte ptr ds:[d_F945],al
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         mov       word ptr ds:[d_F943],ax
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_694A
         ;jmp       l_6973
         db        0e9h
         dw        l_6973-$-2

l_694A:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_695A
         ;jmp       l_6970
         db        0e9h
         dw        l_6970-$-2

l_695A:  inc       cx
         mov       [bp-4],ax
l_695E:  push      cx
         mov       ax,[bp-4]
         push      ax
         call      l_682B
         pop       cx
         dec       cx
         jz        l_6970
         inc       word ptr [bp-4]
         ;jmp       l_695E
         db        0e9h
         dw        l_695E-$-2

l_6970:  ;jmp       l_6983
         db        0e9h
         dw        l_6983-$-2

l_6973:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         inc       ax
         push      ax
         call      l_3C04
l_6983:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         dec       ax
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,0
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         call      l_6801
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         shl       ax,1
         xchg      ax,di
         mov       ax,word ptr ds:[d_E5E2+di]
         cmp       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         je        l_69A6
         ;jmp       l_69A9
         db        0e9h
         dw        l_69A9-$-2

l_69A6:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_69A9:  ;jmp       l_69AC
         db        0e9h,0,0

l_69AC:  mov       sp,bp
         pop       bp
         ret

l_6886   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_69B0   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_69B7
         db        0e9h,0,0

l_69B7:  ;push      word ptr [bp+4]         ; ‡¡slo © dku
         db        0FFh,0B6h,4,0
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       si,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      si
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       di,offset d_F059
         mov       si,offset d_F159
         mov       dx,word ptr ds:[d_E696]  ; pozice konec sloupcov‚ho bloku
         mov       bx,dx
         cmp       byte ptr [bx+di],0FFh
         jne       l_69DC
         mov       byte ptr [bx+di],20h
l_69DC:  mov       bl,[di]
         mov       bh,0
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         cmp       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         ja        l_6A34
         cmp       byte ptr [bx+di],11h
         je        l_69EF
         inc       bx
l_69EF:  cmp       bx,dx
         ja        l_69FC
         mov       byte ptr [bx+di],20h
         mov       byte ptr [bx+si],0
         inc       bx
         jmp       short l_69EF

l_69FC:  sub       dx,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         inc       dx
         push      ax
         push      dx
         push      ax
         push      dx
         call      l_3799                   ; odsun zbytku © dku INSERT
         pop       cx
         pop       ax
         cmp       byte ptr ds:[d_F79D],0   ; k¢d chyby KonTextu
         jne       l_6A71
         push      ds
         pop       es
         cld       
         mov       si,offset d_F059
         add       si,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         add       di,ax
         push      cx
         repne     movsb
         pop       cx
         mov       si,offset d_F159
         add       si,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         add       di,ax
         repne     movsb
         jmp       short l_6A53

l_6A34:  cmp       bx,dx
         jle       l_6A3A
         mov       bx,dx
l_6A3A:  or        bx,bx
         jz        l_6A71
         cmp       byte ptr [bx+di],20h
         jne       l_6A46
         dec       bx
         jmp       short l_6A3A

l_6A46:  mov       [di],bl
         push      ax
         call      l_376B                   ; nastaven¡ nov‚ d‚lky editov. © dku
         push      word ptr ds:[d_E694]     ; pozice za‡ tku sloupcov‚ho bloku
         call      l_3950                   ; spojen¡ textov˜ch © dk–
l_6A53:  ;push      word ptr [bp+4]
         db        0FFh,0B6h,4,0
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       si,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      si
         call      l_3E83                   ; ulo‘en¡ edit. © dku do souboru
         ;mov       ax,[bp+4]
         db        8Bh,86h,4,0
         cmp       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         jle       l_6A71
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
l_6A71:  ;jmp       l_6A74
         db        0e9h,0,0

l_6A74:  mov       sp,bp
         pop       bp
         ret       2

l_69B0   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_6A7A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6AD6
         db        0e9h
         dw        l_6AD6-$-2

l_6A7A   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_6A81   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_6A8D
         db        0e9h,0,0

l_6A8D:  mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F159
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       bx,[bp-2]
         mov       al,ss:[bx+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_6AB2
         ;jmp       l_6ABD
         db        0e9h
         dw        l_6ABD-$-2

l_6AB2:  mov       bx,[bp-2]
         mov       ax,ss:[bx-4]
         push      ax
         call      l_682B
l_6ABD:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       bx,[bp-2]
         add       ax,ss:[bx-4]
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         call      l_69B0
         ;jmp       l_6AD2
         db        0e9h,0,0

l_6AD2:  mov       sp,bp
         pop       bp
         ret

l_6A81   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_6AD6   PROC      NEAR

         dec       sp
         dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         jg        l_6AE4
         ;jmp       l_6B09
         db        0e9h
         dw        l_6B09-$-2

l_6AE4:  mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         push      ax
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jle       l_6AF4
         ;jmp       l_6B06
         db        0e9h
         dw        l_6B06-$-2

l_6AF4:  dec       cx
         mov       [bp-4],ax
l_6AF8:  push      cx
         call      l_6A81
         pop       cx
         inc       cx
         jz        l_6B06
         dec       word ptr [bp-4]
         ;jmp       l_6AF8
         db        0e9h
         dw        l_6AF8-$-2

l_6B06:  ;jmp       l_6B2B
         db        0e9h
         dw        l_6B2B-$-2

l_6B09:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_6B19
         ;jmp       l_6B2B
         db        0e9h
         dw        l_6B2B-$-2

l_6B19:  inc       cx
         mov       [bp-4],ax
l_6B1D:  push      cx
         call      l_6A81
         pop       cx
         dec       cx
         jz        l_6B2B
         inc       word ptr [bp-4]
         ;jmp       l_6B1D
         db        0e9h
         dw        l_6B1D-$-2

l_6B2B:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         add       ax,word ptr ds:[d_E696]  ; pozice konec sloupcov‚ho bloku
         sub       ax,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         mov       word ptr ds:[d_E696],ax  ; pozice konec sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       word ptr ds:[d_E694],ax  ; pozice za‡ tku sloupcov‚ho bloku
         ;jmp       l_6B42
         db        0e9h,0,0

l_6B42:  mov       sp,bp
         pop       bp
         ret       2

l_6AD6   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KC a Blok/kop¡rov n¡ (kop¡rov n¡ bloku)
; -----------------------------------------------------------------------------

l_6B48   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6B4F
         db        0e9h,0,0

l_6B4F:  sub       sp,6
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         jnz       l_6B5B
         ;jmp       l_6B5E
         db        0e9h
         dw        l_6B5E-$-2

l_6B5B:  jmp       l_6C30

l_6B5E:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         inc       ax
         mov       [bp-4],ax
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_6B81
         ;jmp       l_6B8B
         db        0e9h
         dw        l_6B8B-$-2

l_6B81:  mov       ax,0
         push      ax
         call      l_6A7A
         jmp       l_6C13

l_6B8B:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         jg        l_6B97
         ;jmp       l_6BA7
         db        0e9h
         dw        l_6BA7-$-2

l_6B97:  dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         call      l_4304
         jnz       l_6BA4
         ;jmp       l_6BA7
         db        0e9h
         dw        l_6BA7-$-2

l_6BA4:  jmp       l_6C30

l_6BA7:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_3B6A
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_6BBD
         ;jmp       l_6BC0
         db        0e9h
         dw        l_6BC0-$-2

l_6BBD:  ;jmp       l_6C30
         db        0e9h
         dw        l_6C30-$-2

l_6BC0:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       [bp-8],ax
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_6BD6
         ;jmp       l_6C13
         db        0e9h
         dw        l_6C13-$-2

l_6BD6:  inc       cx
         mov       [bp-6],ax
l_6BDA:  push      cx
         mov       ax,[bp-6]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       ax,[bp-8]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_3C8D
         mov       ax,[bp-8]
         inc       ax
         mov       [bp-8],ax
         pop       cx
         dec       cx
         jz        l_6C13
         inc       word ptr [bp-6]
         ;jmp       l_6BDA
         db        0e9h
         dw        l_6BDA-$-2

l_6C13:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,[bp-4]
         dec       ax
         pop       cx
         add       ax,cx
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_6C30:  ;jmp       l_6C33
         db        0e9h,0,0

l_6C33:  mov       sp,bp
         pop       bp
         ret

l_6B48   ENDP

; -----------------------------------------------------------------------------
;
; -----------------------------------------------------------------------------

l_6C37   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6C3E
         db        0e9h,0,0

l_6C3E:  sub       sp,6
         call      l_48CB                   ; dek¢dov n¡ © dku do text. bufferu
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         cmp       ax,0
         je        l_6C51
         ;jmp       l_6C54
         db        0e9h
         dw        l_6C54-$-2

l_6C51:  jmp       l_6D32

l_6C54:  mov       ax,1
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         sub       ax,[bp-4]
         mov       [bp-8],ax
         mov       ax,[bp-8]
         cmp       ax,0
         je        l_6C76
         ;jmp       l_6C79
         db        0e9h
         dw        l_6C79-$-2

l_6C76:  jmp       l_6D32

l_6C79:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_6C92
         jmp       l_6D2F

l_6C92:  inc       cx
         mov       [bp-6],ax
l_6C96:  push      cx
         mov       ax,[bp-6]
         push      ax                       ; ‡¡slo © dku
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_ED59         ; buffer atribut– znak– text. © dku
         push      ds
         push      di
         call      l_3F5A                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       al,byte ptr ds:[d_EC59]  ; d‚lka textov‚ho © dku
         xor       ah,ah
         cmp       ax,0
         jg        l_6CB5
         ;jmp       l_6D25
         db        0e9h
         dw        l_6D25-$-2

l_6CB5:  mov       ax,[bp-8]
         cmp       ax,0
         jg        l_6CC0
         ;jmp       l_6CCE
         db        0e9h
         dw        l_6CCE-$-2

l_6CC0:  mov       ax,1
         push      ax
         mov       ax,[bp-8]
         push      ax
         call      l_3799                   ; odsun zbytku © dku INSERT
         ;jmp       l_6D06
         db        0e9h
         dw        l_6D06-$-2

l_6CCE:  mov       ax,1
         mov       [bp-4],ax
         lea       di,[bp-4]
         push      ss
         push      di
         call      l_384B
         mov       ax,[bp-8]
         neg       ax
         cmp       ax,[bp-4]
         jl        l_6CE9
         ;jmp       l_6CF4
         db        0e9h
         dw        l_6CF4-$-2

l_6CE9:  mov       ax,[bp-8]
         neg       ax
         mov       [bp-4],ax
         ;jmp       l_6CFB
         db        0e9h
         dw        l_6CFB-$-2

l_6CF4:  mov       ax,[bp-4]
         dec       ax
         mov       [bp-4],ax
l_6CFB:  mov       ax,1
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_37F3                   ; p©¡sun zbytku © dku DELETE
l_6D06:  mov       ax,[bp-6]
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
         jne       l_6D22
         ;jmp       l_6D25
         db        0e9h
         dw        l_6D25-$-2

l_6D22:  ;jmp       l_6D35
         db        0e9h
         dw        l_6D35-$-2

l_6D25:  pop       cx
         dec       cx
         jz        l_6D2F
         inc       word ptr [bp-6]
         jmp       l_6C96

l_6D2F:  call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_6D32:  ;jmp       l_6D39
         db        0e9h
         dw        l_6D39-$-2

l_6D35:  pop       ax
         ;jmp       l_6D32
         db        0e9h
         dw        l_6D32-$-2

l_6D39:  mov       sp,bp
         pop       bp
         ret

l_6C37   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KV a Blok/p©em¡stˆn¡ (p©esun bloku)
; -----------------------------------------------------------------------------

l_6D3D   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6D44
         db        0e9h,0,0

l_6D44:  dec       sp
         dec       sp
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         jnz       l_6D4F
         ;jmp       l_6D52
         db        0e9h
         dw        l_6D52-$-2

l_6D4F:  jmp       l_6E33

l_6D52:  call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         call      l_4304
         push      ax
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         xor       al,1
         pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_6D6F
         ;jmp       l_6D75
         db        0e9h
         dw        l_6D75-$-2

l_6D6F:  call      l_6C37
         jmp       l_6E33

l_6D75:  mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         sub       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         inc       ax
         mov       [bp-4],ax
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_6D95
         ;jmp       l_6D9F
         db        0e9h
         dw        l_6D9F-$-2

l_6D95:  mov       ax,1
         push      ax
         call      l_6A7A
         ;jmp       l_6E16
         db        0e9h
         dw        l_6E16-$-2

l_6D9F:  dec       sp
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         call      l_4304
         jnz       l_6DAC
         ;jmp       l_6DAF
         db        0e9h
         dw        l_6DAF-$-2

l_6DAC:  jmp       l_6E33

l_6DAF:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_3B6A
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_6DC5
         ;jmp       l_6DC8
         db        0e9h
         dw        l_6DC8-$-2

l_6DC5:  ;jmp       l_6E33
         db        0e9h
         dw        l_6E33-$-2

l_6DC8:  mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_3ACA                   ; p©esun bloku definic © dk–
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,[bp-4]
         push      ax
         call      l_3C04
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         cmp       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         jg        l_6DF6
         ;jmp       l_6E16
         db        0e9h
         dw        l_6E16-$-2

l_6DF6:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         sub       ax,[bp-4]
         mov       word ptr ds:[d_E698],ax  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         sub       ax,[bp-4]
         cmp       ax,1
         jg        l_6E0D
         ;jmp       l_6E16
         db        0e9h
         dw        l_6E16-$-2

l_6E0D:  mov       ax,word ptr ds:[d_E69C]  ; ‡¡slo © dku kurzoru na obrazovce
         sub       ax,[bp-4]
         mov       word ptr ds:[d_E69C],ax  ; ‡¡slo © dku kurzoru na obrazovce
l_6E16:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,[bp-4]
         dec       ax
         pop       cx
         add       ax,cx
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_6E33:  ;jmp       l_6E36
         db        0e9h,0,0

l_6E36:  mov       sp,bp
         pop       bp
         ret

l_6D3D   ENDP

; -----------------------------------------------------------------------------
;        volba prostoru (pro Ctrl-JI nebo Ctrl-KG)
; -----------------------------------------------------------------------------

l_6E3A   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_6E41
         db        0e9h,0,0

; ------ ulo‘en¡ editovan‚ho © dku

l_6E41:  sub       sp,0Ah
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku

; ------ zobrazen¡ n povˆdy k volbˆ edita‡n¡ho prostoru

         mov       ax,7
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m

; ------ test, zda je volba Ctrl-KG (volba prostoru k p©enosu bloku)

         mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         jnz       l_6E5A                   ; je volba Ctrl-KG
         ;jmp       l_6E70
         db        0e9h
         dw        l_6E70-$-2

; ------ pro volbu Ctrl-KG oprava nadpisu na Ctrl-KG

l_6E5A:  mov       ax,4Ah
         push      ax
         mov       ax,1
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        2,'KG'

         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ £schova parametr– aktivn¡ho prostoru

l_6E70:  mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru

; ------ p©¡prava k zobrazen¡ parametr– prostor–

         mov       ax,1                     ; po‡ te‡n¡ prostor k zobrazen¡
         push      ax
         mov       ax,5                     ; koncov˜ prostor k zobrazen¡
         pop       cx
         xchg      ax,cx
l_6E80:  sub       cx,ax
         jge       l_6E87
         jmp       l_6F6B
l_6E87:  inc       cx                       ; po‡et prostor– k zobrazen¡
         mov       [bp-0Ah],ax              ; ‡¡slo prvn¡ho prostoru

; ====== p©¡prava k zobrazen¡ parametr– jednoho prostoru

l_6E8B:  push      cx
         mov       di,offset d_F76E         ;
         push      ds
         push      di
         sub       sp,0Fh

; ------ p©¡prava jm‚na souboru

         mov       ax,[bp-0Ah]              ; ‡¡slo prostoru k zobrazen¡
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di                    ; offset za‡ tku definice prostoru
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
         jnz       l_6EC5
         ;jmp       l_6EE1
         db        0e9h
         dw        l_6EE1-$-2

l_6EC5:  mov       di,offset d_F76E
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        14,14 dup(".")

         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

l_6EE1:  mov       ax,38h
         push      ax
         mov       ax,[bp-0Ah]
         add       ax,4
         push      ax
         mov       ax,30h
         add       ax,[bp-0Ah]
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku

         db        2,'. '

         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         mov       ax,[bp-0ah]
         cmp       ax,ds:[d_F7A7]           ; ‡¡slo aktivn¡ho prostoru
         je        l_6F1D
         ;jmp       l_6F26
         db        0e9h
         dw        l_6F26-$-2

l_6F1D:  mov       ax,ds:[d_F7A3]           ; skute‡n˜ po‡et © dk– prostoru
         mov       [bp-0ch],ax
         ;jmp       l_6F36
         db        0e9h
         dw        l_6F36-$-2

l_6F26:  mov       ax,[bp-0ah]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,ds:[di+d_E69E]        ; maxim ln¡ po‡et © dk– prostoru
         mov       [bp-0ch],ax
l_6F36:  mov       ax,[bp-0Ch]
         push      ax
         mov       ax,6
         push      ax
         mov       di,offset d_F76E
         push      ds
         mov       cl,0Eh
         call      l_0DF3                   ; dek¢d. ‡¡sla INTEGER na text (DEK)
         mov       ax,49h
         push      ax
         mov       ax,[bp-0Ah]
         add       ax,4
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         pop       cx
         dec       cx
         jz        l_6F6B
         inc       word ptr [bp-0Ah]        ; zv˜¨en¡ ‡¡sla prostoru
         jmp       l_6E8B                   ; zobrazen¡ dal¨¡ho prostoru

; ------

l_6F6B:  lea       di,[bp-8]
         push      ss
         push      di
         call      l_07BE                   ; sou‡et velikosti voln‚ pamˆti
         call      l_1B0C
         call      l_1970
         lea       di,[bp-8]
         push      ss
         call      l_1950
         mov       ax,0
         call      l_1B0C
         call      l_1A6D
         jnz       l_6F8E
         ;jmp       l_6FA9
         db        0e9h
         dw        l_6FA9-$-2

l_6F8E:  lea       di,[bp-8]
         push      ss
         push      di
         lea       di,[bp-8]
         push      ss
         call      l_1950
         call      l_195F

         db        91h
         db        0,0,0,0,0

         call      l_1983
         call      l_1970
l_6FA9:  lea       di,[bp-8]
         push      ss
         call      l_1950
         mov       ax,10h
         call      l_1B0C
         call      l_19AD
         mov       ax,6D0h
         call      l_1B0C
         call      l_199E
         mov       ax,6
         push      ax
         mov       ax,0
         push      ax
         mov       di,offset d_F76E
         push      ds
         mov       cl,0Eh
         call      l_0E0C
         mov       ax,3Eh
         push      ax
         mov       ax,0Bh
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–


         mov       ax,1000                  ; velikost bufferu maker
         sub       ax,word ptr ds:[d_F7A1]  ; po‡et bajt– v tabulce maker
         push      ax
         mov       ax,4
         push      ax
         mov       di,offset d_F76E
         push      ds
         mov       cl,0Eh
         call      l_0DF3                   ; dek¢d. ‡¡sla INTEGER na text (DEK)
         mov       ax,40h
         push      ax
         mov       ax,0Ch
         push      ax
         mov       di,offset d_F76E
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         jmp       short l_7039

; -----------------------------------------------------------------------------
;        ‡ek n¡ na kl vesu se zobrazen¡m kurzoru pro volbu prostoru
; -----------------------------------------------------------------------------

l_7018   PROC      NEAR

         call      l_7025                   ; zapnut¡ kurzoru
         push      bx
         push      cx
         push      dx
         push      ax
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         pop       dx
         pop       cx
         pop       bx

l_7025:  push      ax
         push      bx
         push      cx
         push      dx
         push      cx
         push      bx
         push      dx
         push      bx
         mov       ax,2
         push      ax
         call      l_34F8                   ; vypnut¡ kurzoru
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         ret

l_7018   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_6E3A)
; -----------------------------------------------------------------------------

l_7039:  mov       bx,4
         add       bl,byte ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         mov       cx,37h
         mov       dx,4Fh
l_7046:  call      l_7018                   ; ‡ek n¡ na kl vesu s kurzorem
         cmp       al,31h
         jb        l_7057
         cmp       al,35h
         ja        l_7057
         sub       al,30h
         mov       bl,al
         jmp       short l_708A

l_7057:  cmp       al,5
         jne       l_7065
         dec       bx
         cmp       bl,5
         jae       l_7046
         mov       bl,9
         jmp       short l_7046

l_7065:  cmp       al,18h
         jne       l_7073
         inc       bx
         cmp       bl,9
         jbe       l_7046
         mov       bl,5
         jmp       short l_7046

l_7073:  cmp       al,0Dh
         je        l_7087
         cmp       al,1Bh
         jne       l_7046
         mov       byte ptr ds:[d_F78A],1   ; 1=p©¡znak p©eru¨en¡ editace volby
         mov       bl,byte ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         add       bl,4
l_7087:  sub       bl,4
l_708A:  ;mov       [bp-0Ch],bx
         db        89h,9Eh,0F4h,0FFh        ;!
         mov       bl,7
         push      bx
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou
         mov       ax,[bp-0Ch]
         mov       [bp+6],ax
         ;jmp       l_709D
         db        0e9h,0,0

l_709D:  mov       ax,[bp+6]
         mov       sp,bp
         pop       bp
         ret       4

l_6E3A   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KG a Blok/p©enos (p©enos bloku z jin‚ho prostoru)
; -----------------------------------------------------------------------------

l_70A6   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_70AD
         db        0e9h,0,0

l_70AD:  sub       sp,0Eh
         dec       sp
         dec       sp
         mov       ax,1
         push      ax
         call      l_6E3A                   ; volba prostoru
         mov       [bp-4],ax
         mov       ax,[bp-4]
         cmp       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         je        l_70C8
         ;jmp       l_70CB
         db        0e9h
         dw        l_70CB-$-2

l_70C8:  jmp       l_7254

l_70CB:  mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       al,byte ptr ds:[d_E6A9+di] ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         xor       ah,ah
         xor       al,1
         jnz       l_70E1
         ;jmp       l_70EA
         db        0e9h
         dw        l_70EA-$-2

l_70E1:  mov       ax,0Ah
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_7254

l_70EA:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         dec       sp
         dec       sp
         mov       ax,[bp-4]
         push      ax
         call      l_4167                   ; po‡et © dk– p©ed zadan˜m prostorem
         mov       [bp-6],ax
         mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_E690+di] ; © dek za‡ tku bloku
         mov       [bp-0Ch],ax
         mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_E692+di] ; © dek konce bloku
         mov       [bp-0Eh],ax
         mov       ax,[bp-0Eh]
         sub       ax,[bp-0Ch]
         inc       ax
         mov       [bp-10h],ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       [bp-0Ah],ax
         mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       al,byte ptr ds:[d_E6AA+di] ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_7150
         jmp       l_71D2

l_7150:  mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_E694+di] ; pozice za‡ tku sloupcov‚ho bloku
         mov       word ptr ds:[d_E694],ax  ; pozice za‡ tku sloupcov‚ho bloku
         mov       ax,[bp-4]
         mov       cx,PARSIZU
         mul       cx
         xchg      ax,di
         mov       ax,word ptr ds:[d_E696+di] ; pozice konec sloupcov‚ho bloku
         mov       word ptr ds:[d_E696],ax  ; pozice konec sloupcov‚ho bloku
         mov       ax,[bp-0Ch]
         push      ax
         mov       ax,[bp-0Eh]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_7180
         ;jmp       l_71BB
         db        0e9h
         dw        l_71BB-$-2

l_7180:  inc       cx
         mov       [bp-8],ax
l_7184:  push      cx
         mov       ax,[bp-8]
         add       ax,[bp-6]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F159
         push      ds
         push      di
         call      l_3F09                   ; dek¢dov n¡ © dku do edit. bufferu
         mov       ax,[bp-0Ah]
         push      ax
         call      l_69B0
         mov       ax,[bp-0Ah]
         inc       ax
         mov       [bp-0Ah],ax
         pop       cx
         dec       cx
         jz        l_71BB
         inc       word ptr [bp-8]
         ;jmp       l_7184
         db        0e9h
         dw        l_7184-$-2

l_71BB:  mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         add       ax,word ptr ds:[d_E696]  ; pozice konec sloupcov‚ho bloku
         sub       ax,word ptr ds:[d_E694]  ; pozice za‡ tku sloupcov‚ho bloku
         mov       word ptr ds:[d_E696],ax  ; pozice konec sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E69A]  ; pozice kurzoru na © dku
         mov       word ptr ds:[d_E694],ax  ; pozice za‡ tku sloupcov‚ho bloku
         ;jmp       l_7237
         db        0e9h
         dw        l_7237-$-2

l_71D2:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         push      ax
         mov       ax,[bp-10h]
         push      ax
         call      l_3B6A
         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         jne       l_71E8
         ;jmp       l_71EB
         db        0e9h
         dw        l_71EB-$-2

l_71E8:  ;jmp       l_7254
         db        0e9h
         dw        l_7254-$-2

l_71EB:  mov       ax,[bp-0Ch]
         push      ax
         mov       ax,[bp-0Eh]
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_71FB
         ;jmp       l_7237
         db        0e9h
         dw        l_7237-$-2

l_71FB:  inc       cx
         mov       [bp-8],ax
l_71FF:  push      cx
         mov       ax,[bp-8]
         add       ax,[bp-6]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         mov       ax,[bp-0Ah]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_0274         ; tabulka definic © dk–
         push      ds
         push      di
         call      l_3C8D
         mov       ax,[bp-0Ah]
         inc       ax
         mov       [bp-0Ah],ax
         pop       cx
         dec       cx
         jz        l_7237
         inc       word ptr [bp-8]
         ;jmp       l_71FF
         db        0e9h
         dw        l_71FF-$-2

l_7237:  mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
         mov       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         push      ax
         mov       ax,[bp-10h]
         dec       ax
         pop       cx
         add       ax,cx
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,1
         mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_7254:  ;jmp       l_7257
         db        0e9h,0,0

l_7257:  mov       sp,bp
         pop       bp
         ret

l_70A6   ENDP

; -----------------------------------------------------------------------------
;        ukon‡en¡ editace - zru¨en¡ souboru z pamˆti (v˜stup AX=0 chyba)
; -----------------------------------------------------------------------------

l_725B   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7262
         db        0e9h,0,0

; ------ test, zda je soubor vyti¨tˆn

l_7262:  dec       sp
         dec       sp
         mov       ax,0
         mov       [bp+4],al                ; p©¡znak chyby operace
         dec       sp
         call      l_4EE9                   ; test, zda je ukon‡en tisk
         jnz       l_7273                   ; chyba - soubor nen¡ vyti¨tˆn
         ;jmp       l_7276
         db        0e9h
         dw        l_7276-$-2

l_7273:  jmp       l_738F

; ------ test, zda byl soubor modifikov n

l_7276:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       al,byte ptr ds:[d_E6A8]  ; 0=p©¡znak modifikace textu
         xor       ah,ah
         xor       al,1
         jnz       l_7285                   ; soubor byl modifikov n
         ;jmp       l_72CE
         db        0e9h
         dw        l_72CE-$-2

; ------ zobrazen¡ hl ¨en¡, ‘e text nebude ulo‘en

l_7285:  mov       ax,20                    ; hl ¨en¡ - text nebude ulo‘en
         push      ax
         call      l_4D50                   ; zobrazen¡ n povˆdy k volb m

; ------ zobrazen¡ ‡¡sla aktivn¡ho prostoru

         mov       ax,32h
         push      ax
         mov       ax,8
         push      ax
         mov       ax,0FFh                  ; prefix dvojn sobn‚ ¨¡©ky znaku
         push      ax
         mov       ax,word ptr ds:[d_F7A7]  ; ‡¡slo aktivn¡ho prostoru
         add       ax,"0"                   ; korekce na znak ASCII
         mov       ah,al
         mov       al,1                     ; d‚lka ©etˆzce
         push      ax                       ; ©etˆzec ‡¡sla prostoru
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ ‡ek n¡ na potvrzen¡ hl ¨en¡

         dec       sp
         call      l_550C                   ; ‡ek n¡ na potvrzen¡ hl ¨en¡
         mov       byte ptr ds:[d_F78A],al  ; 1=p©¡znak p©eru¨en¡ editace volby

; ------ n vrat textu pod oknem hl ¨en¡

         mov       ax,20
         push      ax
         call      l_4E5D                   ; n vrat podkladu pod n povˆdou

; ------ p©i p©eru¨en¡ hl ¨en¡ konec

         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_72CB
         ;jmp       l_72CE
         db        0e9h
         dw        l_72CE-$-2

l_72CB:  jmp       l_738F

; ------ nulov n¡ bufferu £schovy zmˆn

l_72CE:  call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn

; ------ p©¡prava ‡¡ta‡e © dk– ke zru¨en¡ © dk– z hlav¡ a paty

         mov       ax,1
         push      ax
         mov       ax,10
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_72E1
         ;jmp       l_7312
         db        0e9h
         dw        l_7312-$-2

l_72E1:  inc       cx
         mov       [bp-4],ax                ; po‡ te‡n¡ © dek z hlav¡ a paty = 1
l_72E5:  push      cx                       ; po‡et © dk– z hlav¡ a paty = 10

; ------ zru¨en¡ © dk– z hlav¡

         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_E6AB - 4     ; adresy © dk– z hlav¡
         push      ds
         push      di
         call      l_39D4                   ; uvolnˆn¡ © dku z pamˆti

; ------ zru¨en¡ © dk– paty

         mov       ax,[bp-4]
         shl       ax,1
         shl       ax,1
         xchg      ax,di
         add       di,offset d_E6D3 - 4     ; adresy © dk– paty
         push      ds
         push      di
         call      l_39D4                   ; uvolnˆn¡ © dku z pamˆti

; ------ zv˜¨en¡ ‡¡ta‡e © dk– z hlav¡ a paty

         pop       cx
         dec       cx
         jz        l_7312
         inc       word ptr [bp-4]          ; zv˜¨en¡ ‡¡ta‡e z hlav¡ a © dku
         ;jmp       l_72E5                  ; zru¨en¡ dal¨¡ho © dku z hlav¡+paty
         db        0e9h
         dw        l_72E5-$-2

; ------ stanoven¡ po‡tu © dk– souboru ke zru¨en¡

l_7312:  mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_7322
         ;jmp       l_7338
         db        0e9h
         dw        l_7338-$-2

; ------ zru¨en¡ © dk– souboru

l_7322:  inc       cx
         mov       [bp-4],ax
l_7326:  push      cx
         mov       ax,[bp-4]                ; ‡¡slo © dku ke zru¨en¡
         push      ax
         call      l_3A2E                   ; uvolnˆn¡ © dku z pamˆti
         pop       cx
         dec       cx                       ; ‡¡ta‡ © dk–
         jz        l_7338
         inc       word ptr [bp-4]          ; zv˜¨en¡ ‡¡ta‡e © dk–
         ;jmp       l_7326                  ; zru¨en¡ dal¨¡ho © dku
         db        0e9h
         dw        l_7326-$-2

; ------ zru¨en¡ jm‚na editovan‚ho souboru

l_7338:  mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ inicializace ukazatel– souboru

         mov       ax,1
         mov       ds:[d_E6A8],al           ; 0=p©¡znak modifikace textu
         mov       ax,1
         mov       ds:[d_E690],ax           ; © dek za‡ tku bloku
         mov       ax,1
         mov       ds:[d_E694],ax           ; pozice za‡ tku sloupcov‚ho bloku
         mov       ax,0
         mov       ds:[d_E696],ax           ; pozice konec sloupcov‚ho bloku
         mov       ax,1
         mov       ds:[d_E698],ax           ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       ax,1
         mov       ds:[d_E69C],ax           ; ‡¡slo © dku kurzoru na obrazovce
         mov       ax,1
         mov       ds:[d_E69A],ax           ; pozice kurzoru na © dku
         mov       ax,0
         mov       ds:[d_F7A3],ax           ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,0
         mov       ds:[d_E6A4],ax           ; offset za‡ tku zobrazen‚ho © dku
         call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku

; ------ £schova nov˜ch parametr– prostoru

         mov       ax,ds:[d_F7A7]           ; ‡¡slo aktivn¡ho prostoru
         push      ax
         call      l_3FED                   ; £schova parametr– edit. prostoru

; ------ nov‚ zobrazen¡ obrazovky (vymaz n¡)

         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
         mov       ax,1
         mov       [bp+4],al                ; p©¡znak operace OK
l_738F:  ;jmp       l_7392
         db        0e9h,0,0

l_7392:  mov       al,[bp+4]                ; n vratov˜ k¢d
         xor       ah,ah
         or        ax,ax                    ; 0=chyba operace
         mov       sp,bp
         pop       bp
         ret       1

l_725B   ENDP

; -----------------------------------------------------------------------------
;        test, zda nastala diskov  chyba
; -----------------------------------------------------------------------------

l_739F   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_73A6
         db        0e9h,0,0

l_73A6:  dec       sp
         dec       sp
         call      l_0FFC                   ; vyjmut¡ k¢du chyby disk. operace
         mov       [bp-4],ax                ; k¢d chyby disk. operace

         mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         je        l_73B9
         ;jmp       l_73BF
         db        0e9h
         dw        l_73BF-$-2

l_73B9:  mov       ax,[bp-4]                ; k¢d chyby diskov‚ operace
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
l_73BF:  mov       ax,cs:[l_34AF]           ; chyba INT 24h - informa‡n¡ registr
         cmp       ax,0
         jne       l_73CB
         ;jmp       l_73D8
         db        0e9h
         dw        l_73D8-$-2

; ------ chyba INT 24h - diskov  jednotka nepracuje

l_73CB:  mov       ax,64h                   ; chyba - diskov  jednotka nepracuje
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         mov       ax,0
         mov       cs:[l_34AF],ax           ; chyba INT 24h - informa‡n¡ registr
l_73D8:  mov       ax,word ptr ds:[d_F79D]  ; k¢d chyby KonTextu
         cmp       ax,0
         mov       ax,1
         jnz       l_73E4
         dec       ax
l_73E4:  mov       [bp+4],al
         ;jmp       l_73EA
         db        0e9h,0,0

l_73EA:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_739F   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ souboru zadan‚ho jm‚na
; -----------------------------------------------------------------------------
; VSTUP: [SP+2] (4) ukazatel na ©etˆzec jm‚na souboru
; -----------------------------------------------------------------------------

l_73F7   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_73FE
         db        0e9h,0,0

; ------ nastaven¡ adresy DTA

l_73FE:  mov       ax,ds                    ; AX <- DS
         mov       ds:[d_026E],ax           ; registr DS pro vol n¡ INT 21h
         mov       di,offset d_F946         ; tabulka DTA
         xchg      ax,di
         mov       ds:[d_0266],ax           ; registr DX pro vol n¡ INT 21h
         mov       ax,1Ah                   ; slu‘ba nastaven¡ adresy DTA
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h

; ------ doplnˆn¡ 0 za konec jm‚na souboru

         les       di,dword ptr [bp+4]      ; adresa bufferu se jm‚nem souboru
         push      es
         push      di
         les       di,dword ptr [bp+4]      ; adresa bufferu se jm‚nem souboru
         mov       al,es:[di]               ; d‚lka textu jm‚na souboru
         xor       ah,ah
         inc       ax                       ; d‚lka textu jm‚na souboru + 1
         pop       di
         pop       es
         add       di,ax                    ; adresa konce jm‚na souboru
         mov       ax,0
         mov       es:[di],al               ; doplnˆn¡ 0 za konec jm‚na souboru

; ------ adresa jm‚na souboru - segment

         les       di,dword ptr [bp+4]
         mov       ax,es
         mov       ds:[d_026E],ax           ; registr DS pro vol n¡ INT 21h

; ------ adresa jm‚na souboru - offset

         les       di,dword ptr [bp+4]      ; textov˜ ©etˆzec jm‚na souboru
         add       di,1                     ; p©esko‡en¡ bajtu d‚lky
         xchg      ax,di
         mov       ds:[d_0266],ax           ; registr DX pro vol n¡ INT 21h

; ------ atributy polo‘ky - bˆ‘n‚ soubory

         mov       ax,20h                   ; atributy - jen soubory
         mov       byte ptr ds:[d_0264],al  ; registr CL pro vol n¡ INT 21h
         mov       ax,4Eh                   ; slu‘ba - hled n¡ souboru
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         mov       ax,ds:[d_0272]           ; registr p©¡znak– FLAG pro INT 21h
         and       ax,1                     ; p©¡znak CF
         xor       al,1
         mov       [bp+8],al                ; 1=p©¡znak operace OK
         ;jmp       l_7456
         db        0e9h,0,0

; ------ n vratov˜ k¢d operace

l_7456:  mov       al,[bp+8]                ; n vratov˜ k¢d operace
         xor       ah,ah
         or        ax,ax                    ; ZY=chyba operace
         mov       sp,bp
         pop       bp
         ret       5

l_73F7   ENDP

; -----------------------------------------------------------------------------
;        zad n¡ jm‚na souboru
; -----------------------------------------------------------------------------

l_7463   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_746A
         db        0e9h,0,0

l_746A:  dec       sp
         dec       sp
         call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,2
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp+8]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,":"*HI + 1            ; ©etˆzec - oddˆlova‡ jm‚na disku
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

         lea       di,[bp+8]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         add       ax,4
         mov       [bp-4],ax

         mov       ax,[bp-4]
         push      ax                       ; pozice k zobrazen¡ volby
         mov       ax,0
         push      ax                       ; © dek k zobrazen¡ volby
         mov       ax,7Fh
         push      ax                       ; maxim ln¡ d‚lka textu
         mov       ax,8
         push      ax                       ; typ znak– - jm‚no souboru
         les       di,dword ptr [bp+4]
         push      es                       ; adresa bufferu k ulo‘en¡ textu
         push      di
         call      l_56C0                   ; editace zad n¡ textov‚ho parametru

         mov       al,byte ptr ds:[d_F78A]  ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         push      ax
         les       di,dword ptr [bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         pop       cx
         or        ax,cx
         mov       ds:[d_F78A],al           ; 1=p©¡znak p©eru¨en¡ editace volby
         ;jmp       l_74D2
         db        0e9h,0,0

l_74D2:  mov       sp,bp
         pop       bp
         ret       85h

l_7463   ENDP

; -----------------------------------------------------------------------------
;        hl ¨en¡ o ukl d n¡/‡ten¡ souboru
; -----------------------------------------------------------------------------

l_74D8   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_74DF
         db        0e9h,0,0

l_74DF:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         lea       di,[bp+4]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        12,'m soubor....'

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds                       
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        14,': ‡ekejte !   '

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–
         ;jmp       l_752E
         db        0e9h,0,0

l_752E:  mov       sp,bp
         pop       bp
         ret       9

l_74D8   ENDP

; -----------------------------------------------------------------------------
;        p©evod zadan‚ho souboru na plnou specifikaci
; -----------------------------------------------------------------------------

l_7534   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_753B
         db        0e9h,0,0

l_753B:  les       di,dword ptr [bp+4]
         push      es
         push      di
         call      l_367B                   ; o©ez n¡ ©et. od mezer z obou stran
         les       di,dword ptr [bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_7556
         ;jmp       l_7559
         db        0e9h
         dw        l_7559-$-2

l_7556:  jmp       l_765E

l_7559:  les       di,[bp+4]
         push      es
l_755D:  push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         les       di,dword ptr [bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_135F
         cmp       ax,2
         mov       ax,1
         jl        l_7574
         dec       ax
l_7574:  push      ax
         les       di,dword ptr [bp+4]
         mov       al,es:[di+2]
         xor       ah,ah
         cmp       ax,3Ah
         mov       ax,1
         jnz       l_7587
         dec       ax
l_7587:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_7591
         ;jmp       l_75BF
         db        0e9h
         dw        l_75BF-$-2

; ------ poskytnut¡ aktivn¡ho disku

l_7591:  mov       ax,19h                   ; slu‘ba poskytnut¡ aktivn¡ho disku
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h

; ------ ozna‡en¡ aktivn¡ho disku "A:"

         les       di,dword ptr [bp+4]      ; buffer
         push      es
         push      di
         mov       al,byte ptr ds:[d_0260]  ; registr AL - ‡¡slo aktivn¡ho disku
         xor       ah,ah
         add       ax,"A"                   ; korekce ‡¡sla disku na znak ASCII
         push      ax
         mov       ax,":"*HI + 1            ; oddˆlova‡ jm‚na disku
         push      ax
         call      l_1460
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–

; ------ p©i‡ten¡ textu cesty adres ©e

         les       di,dword ptr [bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ test, zda adres © za‡¡n  ozna‡en¡m ROOT "\" nebo "/"

l_75BF:  les       di,dword ptr [bp+4]
         mov       al,es:[di+3]             ; 3. znak cesty
         xor       ah,ah
         cmp       ax,"\"                   ; za‡¡n  znakem "\" (=ROOT) ?
         mov       ax,1
         jnz       l_75D1
         dec       ax
l_75D1:  push      ax
         les       di,dword ptr [bp+4]
         mov       al,es:[di+3]             ; 3. znak cesty
         xor       ah,ah
         cmp       ax,"/"                   ; za‡¡n  znakem "/" (=ROOT) ?
         mov       ax,1
         jnz       l_75E4
         dec       ax
l_75E4:  pop       cx
         and       ax,cx
         or        ax,ax
         jnz       l_75EE
         ;jmp       l_765E
         db        0e9h
         dw        l_765E-$-2

; ------ na‡ten¡ aktivn¡ho disku a adres ©e

l_75EE:  les       di,dword ptr [bp+4]      ; zpecifikace cesty
         mov       al,es:[di+1]             ; ozna‡en¡ disku
         xor       ah,ah
         sub       ax,"A"-1                 ; ‡¡slo disku + 1
         push      ax
         mov       di,offset d_F059         ; buffer k na‡ten¡ aktiv. adres ©e
         push      ds
         mov       cl,0FFh
         call      l_2C0F                   ; poskytnut¡ aktiv. disku a adres ©e
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         jnz       l_760F
         ;jmp       l_765E
         db        0e9h
         dw        l_765E-$-2

l_760F:  mov       di,offset d_F059         ; aktivn¡ adres ©
         push      ds
         push      di
         mov       ax,1
         push      ax
         mov       ax,2
         call      l_1408                   ; vyjmut¡ cesty z ozna‡en¡ souboru
         mov       al,ds:[d_F059]
         xor       ah,ah
         xchg      ax,di
         mov       al,ds:[d_F059+di]
         xor       ah,ah
         cmp       ax,5Ch
         jne       l_7632
         ;jmp       l_764A
         db        0e9h
         dw        l_764A-$-2

l_7632:  mov       di,offset d_F059
         push      ds
         push      di
         mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       ax,5C01h
         push      ax
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_764A:  mov       di,offset d_F059
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       ax,3
         mov       cl,0FFh
         call      l_13B0
l_765E:  ;jmp       l_7661
         db        0e9h,0,0

l_7661:  mov       sp,bp
         pop       bp
         ret       4

l_7534   ENDP

; *****************************************************************************
;
;                        Z pis souboru na disk
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        z pis souboru na disk
; -----------------------------------------------------------------------------

l_7667   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_76EC
         db        0e9h
         dw        l_76EC-$-2

; -----------------------------------------------------------------------------
;        sestaven¡ popisn‚ho © dku z hlav¡ souboru
; -----------------------------------------------------------------------------

l_766E   PROC      NEAR

         push      bp
         mov       ax,sp
         push      word ptr [bp-2]
         mov       bp,ax
         push      bp
         ;jmp       l_767A
         db        0e9h,0,0

; ------ ulo‘en¡ identifik tor "CONTEXT" do bufferu

l_767A:  sub       sp,0Bh
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        7,'CONTEXT'

         mov       cl,0ffh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ p©¡prava k dek¢dov n¡ ‡¡seln˜ch parametr–

         mov       ax,1                     ; po‡ te‡n¡ parametr
         push      ax
         mov       ax,5                     ; koncov˜ parametr
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jnl       l_76A2
         ;jmp       l_76E5
         db        0e9h
         dw        l_76E5-$-2

; ------ p©id n¡ ‡¡seln˜ch parametr–:
;        - lev˜ okraj (po‡ te‡n¡ pozice k tisku)
;        - ¨¡©ka © dku (vzd lenost prav‚ho okraje)
;        - po‡et © dk– na z hlav¡
;        - po‡et © dk– na patu
;        - celkov˜ po‡et © dk– na str nku

l_76A2:  inc       cx
         mov       [bp-6],ax                ; po‡ te‡n¡ parametr
l_76A6:  push      cx
         mov       ax,[bp-6]
         xchg      ax,di
         mov       al,byte ptr cs:[l_3259+di-1] ; parametr form tu
         xor       ah,ah
         push      ax
         mov       ax,4
         push      ax
         lea       di,[bp-0Fh]
         push      ss
         mov       cl,8
         call      l_0DF3                   ; dek¢d. ‡¡sla INTEGER na text (DEK)

         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         lea       di,[bp-0Fh]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         pop       cx
         dec       cx
         jz        l_76E5
         inc       word ptr [bp-6]          ; zv˜¨en¡ ukazate
         ;jmp       l_76A6
         db        0e9h
         dw        l_76A6-$-2

l_76E5:  ;jmp       l_76E8
         db        0e9h,0,0

l_76E8:  mov       sp,bp
         pop       bp
         ret       

l_766E   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_7667)
; -----------------------------------------------------------------------------

l_76EC:  dec       sp
         dec       sp
         jmp       l_77F8

; -----------------------------------------------------------------------------
;        vytvo©en¡ v˜stupn¡ho souboru
; -----------------------------------------------------------------------------

l_76F1   PROC      NEAR

         push      ds
         push      bp
         ;lds       si,dword ptr [bp+4]     ; jm‚no souboru
         db        0C5h,0B6h,4,0            ;!
         mov       bl,[si]
         mov       bh,0
         inc       si
         mov       [bx+si],bh
         mov       dx,si
         xor       cx,cx
         mov       ah,3Ch
         int       21h                      ; vytvo©en¡ v˜stupn¡ho souboru
         pop       bp
         pop       ds
         ;mov       [bp-4],ax               ; identifik tor souboru
         db        89h,86h,0FCh,0FFh
         jc        l_771C
         xor       bx,bx
         xchg      bx,cs:[l_34AF]           ; chyba INT 24h - informa‡n¡ registr
         or        bx,bx
         jz        l_771C
         mov       al,64h
         stc       
l_771C:  ret

l_76F1   ENDP

; -----------------------------------------------------------------------------
;        z pis dat do v˜stupn¡ho souboru (BX bajt– od adresy ES:DI)
; -----------------------------------------------------------------------------

l_771D   PROC      NEAR

         push      bp
         push      dx
         push      si
         push      di
         push      es
         push      ds

         push      es
         pop       ds                       ; DS <- ES segment dat
         mov       cx,bx
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh
         mov       dx,di
         mov       ah,40h
         int       21h                      ; z pid dat do souboru
         jc        l_773A
         or        ax,ax
         jnz       l_773A
         mov       al,0F0h                  ; chyba - disk pln˜
         stc       
l_773A:  mov       bx,0

         pop       ds
         pop       es
         pop       di
         pop       si
         pop       dx
         pop       bp
         ret       

l_771D   ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ v˜stupn¡ho souboru
; -----------------------------------------------------------------------------

l_7744   PROC      NEAR

         push      ds
         push      bp
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh
         mov       ah,3Eh
         int       21h
         pop       bp
         pop       ds
         ret       

l_7744   ENDP

; -----------------------------------------------------------------------------
;        z pis ©etˆzce DS:SI do souboru (z pis CR/LF do souboru)
; -----------------------------------------------------------------------------

l_7751   db        2,CR,LF                  ; text konce © dku

l_7754   PROC      NEAR

         mov       ax,cs
         mov       ds,ax
         mov       si,offset l_7751         ; text konce © dku

; ------ z pis ©etˆzce DS:SI do souboru

; ------ test, zda je buffer ji‘ pln˜

l_775B:  mov       cl,[si]                  ; po‡et bajt– k z pisu
         mov       ch,0
         inc       si                       ; adresa za‡ tku dat
         mov       ax,bx                    ; sou‡asn˜ po‡et bajt– v bufferu
         add       ax,cx                    ; nov˜ po‡et bajt– v bufferu
         sub       ax,1800h                 ; je buffer ji‘ pln˜ ?
         jc        l_777B                   ; buffer je¨tˆ nen¡ pln˜

; ------ p©i zaplnˆn¡ bufferu p©enos alespo¤ ‡ sti ©etˆzce

         push      ax
         push      di
         sub       cx,ax                    ; sn¡‘en¡ d‚lky ©etˆzce o p©esah
         add       di,bx                    ; adresa konce star˜ch dat
         add       bx,cx                    ; zv˜¨en¡ po‡tu bajt– v bufferu
         cld       
         repne     movsb                    ; p©enos prvn¡ ‡ sti dat
         pop       di

; ------ z pis obsahu bufferu do v˜stupn¡ho souboru

         call      l_771D                   ; z pis dat do v˜stupn¡ho souboru
         pop       cx
         jc        l_7784                   ; chyba operace

; ------ ulo‘en¡ ©etˆzce (nebo zbyl‚ ‡ sti) do v˜stupn¡ho bufferu

l_777B:  push      di
         add       di,bx                    ; adresa konce star˜ch dat
         add       bx,cx                    ; zv˜¨en¡ po‡tu bajt– v bufferu
         cld       
         repne     movsb                    ; p©enos dat do bufferu
         pop       di
l_7784:  ret

l_7754   ENDP

; -----------------------------------------------------------------------------
;        konverze © dku na bˆ‘n˜ text ASCII
; -----------------------------------------------------------------------------

l_7785   PROC      NEAR

; ------ p©enos obsahu textov‚ho © dku do v˜stupn¡ho bufferu

         push      di
         cld       
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       cl,[si]
         mov       ch,0
         inc       cx
         repne     movsb

; ------ p©¡prava ukazatel– © dku

         push      es
         pop       ds                       ; DS <- segment diskov‚ho bufferu
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       al,[di]                  ; d‚lka © dku
         mov       ah,1
         inc       di                       ; za‡ tek dat
         mov       ch,0

; ------ vypu¨tˆn¡ ©¡dic¡ho znaku < 8

l_779D:  mov       cl,[di]                  ; znak textu
         cmp       cl,8
         jae       l_77B3                   ; nen¡ znak < 8
         push      di
         mov       si,di
         inc       si
         mov       cl,al
         sub       cl,ah
         repne     movsb                    ; vypu¨tˆn¡ znaku < 8 z textu
         pop       di
         dec       al
         jmp       short l_77BE

; ------ ostatn¡ znaky < 32 se nahrad¡ mezerou

l_77B3:  cmp       cl," "
         jae       l_77BB                   ; je platn˜ znak
         mov       byte ptr [di]," "

l_77BB:  inc       ah
         inc       di
l_77BE:  cmp       ah,al
         jbe       l_779D
         cmp       cl,11h
         jne       l_77C9
         dec       al
l_77C9:  mov       si,offset d_EC59         ; buffer textov‚ho © dku
         mov       [si],al                  ; nov  d‚lka © dku
         pop       di
         ret       

l_7785   ENDP

; -----------------------------------------------------------------------------
;        z pis souboru v ASCII m¢du (DL=2) nebo CONTEXT m¢du (DL nen¡ 2)
; -----------------------------------------------------------------------------

l_77D0   PROC      NEAR

         jcxz      l_77F7                   ; nen¡ ‘ dn˜ © dek k z pisu
l_77D2:  push      cx
         push      si
         push      ds

         lds       si,dword ptr [si]        ; adresa © dku textu
         mov       ax,ds
         or        ax,si                    ; je to platn˜ © dek ?
         jz        l_77EA                   ; nen¡ to platn˜ © dek
         cmp       dl,2                     ; je ASCII m¢d ?
         jne       l_77E5                   ; nen¡ ASCII m¢d
         call      l_7785                   ; konverze © dku na bˆ‘n˜ text ASCII
l_77E5:  call      l_775B                   ; z pis ©etˆzce DS:SI do souboru
         jc        l_77ED                   ; byla chyba operace
l_77EA:  call      l_7754                   ; z pis CR/LF do souboru

l_77ED:  pop       ds
         pop       si
         pop       cx
         jc        l_77F7                   ; byla chyba operace
         add       si,4                     ; zv˜¨en¡ ukazatele © dk–
         loop      l_77D2
l_77F7:  ret

l_77D0   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_7667)
; -----------------------------------------------------------------------------

; ------ vytvo©en¡ v˜stupn¡ho souboru a p©¡prava registr–

l_77F8:  call      l_76F1                   ; vytvo©en¡ v˜stupn¡ho souboru
         jc        l_786C
         xor       bx,bx
         mov       di,offset d_CD98         ; diskov˜ buffer 1800h bajt–
         push      ds
         pop       es                       ; ES <- datov˜ segment
         ;mov       dx,[bp+8]               ; m¢d z pisu souboru
         db        8Bh,96h,8,0              ;!

; ------ ve form ty LAYOUT z pis popisn‚ho z hlav¡ souboru

         cmp       dl,1                     ; je form t LAYOUT ?
         jne       l_7845                   ; nen¡ form t LAYOUT
         push      bx
         push      dx
         push      di
         push      es
         call      l_766E                   ; sestaven¡ © dku z hlav¡ souboru
         pop       es
         pop       di
         pop       dx
         pop       bx
         mov       si,offset d_EC59         ; buffer textov‚ho © dku
         call      l_775B                   ; z pis ©etˆzce DS:SI do souboru
         jc        l_786C                   ; chyba operace
         push      ds
         call      l_7754                   ; z pis CR/LF do souboru
         pop       ds
         jc        l_786C                   ; chyba operace

; ------ z pis © dk– z hlav¡ souboru

         mov       si,offset d_E6AB         ; adresy © dk– z hlav¡
         mov       cl,byte ptr cs:[l_325B]  ; po‡et © dk– z hlav¡
         mov       ch,0
         call      l_77D0                   ; z pis © dk– z hlav¡ souboru
         jc        l_786C                   ; chyba operace

; ------ z pis © dk– paty souboru

         mov       si,offset d_E6D3         ; adresy © dk– paty
         mov       cl,byte ptr cs:[l_325C]  ; po‡et © dk– paty
         mov       ch,0
         call      l_77D0                   ; z pis © dk– paty souboru
         jc        l_786C

; ------ z pis obsahu souboru

l_7845:  mov       si,offset d_0274         ; tabulka definic © dk–
         ;mov       cx,[bp+0Ah]
         db        8Bh,8Eh,0Ah,0            ;!
         ;mov       ax,[bp+0Ch]
         db        8Bh,86h,0Ch,0            ;!
         sub       cx,ax
         inc       cx
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         shl       ax,1
         shl       ax,1
         add       si,ax
         call      l_77D0                   ;
         jc        l_786C

; ------ z pis znaku EOF a vypr zdnˆn¡ obsahu bufferu

         mov       byte ptr es:[bx+di],EOF  ; ozna‡en¡ konce souboru
         inc       bx
         call      l_771D                   ; z pis dat do v˜stupn¡ho souboru
         jnc       l_787A

; ------ konverze chyby DOS na chybu KonText

l_786C:  mov       ah,0
         cmp       al,20                    ; maxim ln¡ ‡¡slo chyby
         ja        l_7877                   ; nepovolen‚ ‡¡slo chyby
         mov       bx,offset l_34B3         ; tabulka pro konverzi chyb DOS
         xlat      cs:[bx]
l_7877:  mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu

; ------ uzav©en¡ v˜stupn¡ho souboru

l_787A:  call      l_7744                   ; uzav©en¡ v˜stupn¡ho souboru
         ;jmp       l_7880
         db        0e9h,0,0

l_7880:  mov       sp,bp
         pop       bp
         ret       0Ah

l_7667   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KW a Blok/z pis na disk (z pis bloku do souboru)
; -----------------------------------------------------------------------------

l_7886   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_788D
         db        0e9h,0,0

; ------ kontrola, zda je ozna‡en blok k z pisu na disk

l_788D:  dec       sp
         dec       sp
         call      l_65E5                   ; kontrola, zda je ozna‡en blok
         jnz       l_7897                   ; blok nen¡ ozna‡en - chyba
         ;jmp       l_789A
         db        0e9h
         dw        l_789A-$-2

l_7897:  jmp       l_79D2

; ------ kontrola, zda se neukl d  sloupcov˜ blok

l_789A:  mov       al,byte ptr ds:[d_E6AA]  ; 1=p©¡znak sloupcov‚ho bloku
         xor       ah,ah
         or        ax,ax
         jnz       l_78A6
         ;jmp       l_78AF
         db        0e9h
         dw        l_78AF-$-2

l_78A6:  mov       ax,12h                   ; chyba - sloupc. blok nelze ulo‘it
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu
         jmp       l_79D2

; ------ ulo‘en¡ obsahu editovan‚ho © dku

l_78AF:  call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku

; ------ p©¡prava minule zadan‚ho jm‚na souboru k editaci

         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ zad n¡ jm‚na souboru k ulo‘en¡ bloku

         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        27,'Jm‚no soub. k ulo‘en¡ bloku'

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_78FB
         jmp       l_79CF                   ; bylo p©eru¨en¡ operace

; ------ konverze zadan‚ho jm‚na souboru na velk  p¡smena

l_78FB:  mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena

; ------ test, zda soubor zadan‚ho jm‚na ji‘ existuje

         dec       sp
         mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         push      di
         call      l_73F7                   ; nalezen¡ souboru zadan‚ho jm‚na
         jnz       l_7911                   ; zadan˜ soubor ji‘ existuje
         jmp       l_79B8

; ------ zobrazen¡ hl ¨en¡, ‘e zadan˜ soubor ji‘ existuje

l_7911:  call      l_43F3                   ; vymaz n¡ horn¡ho stavov‚ho © dku
         mov       ax,5
         push      ax
         mov       ax,0
         push      ax
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        11,'Existuje s.'

         mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,' - p©epsat jej (A/N) ?'

         call      l_12DE                   ; se‡ten¡ textov˜ch ©etˆzc–
         mov       cl,0ffh
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_43BF                   ; zobrazen¡ ©etˆzce znak–

; ------ ‡ek n¡ na potvrzen¡, zda se m  soubor p©epsat

l_795A:  dec       sp
         dec       sp
         dec       sp
         call      l_54DE                   ; vstup kl vesy s ‡ek n¡m+makro+tisk
         push      ax
         call      l_36F5                   ; p©evod znaku na velk‚ p¡smeno
         mov       [bp-3],al

; ------ test, zda se soubor nem  p©episovat (ESC nebo "N")

         mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,ESCP
         mov       ax,1
         jz        l_7975                   ; je kl vesa ESC - p©eru¨en¡
         dec       ax
l_7975:  push      ax
         mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,"N"                   ; je kl vesa "N" - p©eru¨en¡
         mov       ax,1
         jz        l_7984
         dec       ax
l_7984:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_798E                   ; je p©eru¨en¡ operace
         ;jmp       l_7991
         db        0e9h
         dw        l_7991-$-2

l_798E:  ;jmp       l_79CF
         db        0e9h
         dw        l_79CF-$-2

; ------ test, zda se soubor m  p©epsat (ENTER nebo "A")

l_7991:  mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,CR                    ; je kl vesa CR ?
         mov       ax,1
         jz        l_799F                   ; je kl vesa ESC
         dec       ax
l_799F:  push      ax
         mov       al,[bp-3]
         xor       ah,ah
         cmp       ax,"A"                   ; je kl vesa "A" ?
         mov       ax,1
         jz        l_79AE                   ; je potvrzen¡ p©eps n¡ "A"
         dec       ax
l_79AE:  pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_79B8                   ; je potvrzen¡ p©eps n¡ souboru
         ;jmp       l_795A                  ; jin  kl vesa - dal¨¡ znak
         db        0e9h
         dw        l_795A-$-2

; ------ ulo‘en¡ bloku na disk

l_79B8:  mov       ax,ds:[d_E690]           ; © dek za‡ tku bloku
         push      ax
         mov       ax,ds:[d_E692]           ; © dek konce bloku
         push      ax
         mov       al,byte ptr cs:[l_3271]  ; form t(0=KonText,1=LAYOUT,2=ASCII)
         xor       ah,ah
         push      ax
         mov       di,offset d_F5DC         ; jm‚no souboru k z pisu bloku
         push      ds
         push      di
         call      l_7667                   ; z pis bloku na disk

; ------ n vrat zobrazen¡ horn¡ho stavov‚ho © dku

l_79CF:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_79D2:  ;jmp       l_79D5
         db        0e9h,0,0

l_79D5:  mov       sp,bp
         pop       bp
         ret       

l_7886   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KS (ulo‘en¡ textu do souboru)
; -----------------------------------------------------------------------------

l_79D9   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_79E0
         db        0e9h,0,0

; ------ ulo‘en¡ editovan‚ho © dku

l_79E0:  sub       sp,0CFh
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku

; ------ kontrola, zda je nˆjak˜ © dek souboru

         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         cmp       ax,0
         je        l_79F2                   ; nen¡ ‘ dn˜ © dek souboru
         ;jmp       l_79F5
         db        0e9h
         dw        l_79F5-$-2

l_79F2:  jmp       l_7B8B

; ------ test, zda je jm‚no editovan‚ho souboru

l_79F5:  mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         push      ax

; ------ test, zda bylo zad no jm‚no souboru k ulo‘en¡

         mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_1267                   ; porovn n¡ textov˜ch ©etˆzc– "<>"
         pop       cx
         or        ax,cx
         or        ax,ax
         jnz       l_7A1C
         ;jmp       l_7A72
         db        0e9h
         dw        l_7A72-$-2

; ------ zad n¡ jm‚na souboru k ulo‘en¡

l_7A1C:  call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        26,'Jm‚no souboru pro ulo‘en¡ '

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         lea       di,[bp-131]
         push      ss
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         or        ax,ax
         jnz       l_7A54                   ; p©eru¨en¡ operace
         ;jmp       l_7A57
         db        0e9h
         dw        l_7A57-$-2

l_7A54:  jmp       l_7B88

; ------ zobrazen¡ hl ¨en¡, ‘e se ukl d  soubor

l_7A57:  lea       di,[bp-131]              ; zadan‚ jm‚no souboru
         push      ss
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         lea       di,[bp-131]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
l_7A72:  call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        8,'  Ukl d '

         mov       cl,8
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_74D8                   ; hl ¨en¡ o ukl d n¡/‡ten¡ souboru

; ------ test, zda se soubor z lohuje

         mov       al,cs:[l_3272]           ; z loha BAK (1=zap., 0=vyp.)
         xor       ah,ah
         or        ax,ax
         jnz       l_7A93
         jmp       l_7B68                   ; soubor se nez lohuje

; ------ test, zda zadan˜ soubor existuje

l_7A93:  dec       sp
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         call      l_73F7                   ; nalezen¡ souboru zadan‚ho jm‚na
         jnz       l_7AA1
         jmp       l_7B68

; ------ p©¡prava zadan‚ho jm‚na souboru do z sobn¡ku

l_7AA1:  lea       di,[bp-131]
         push      ss
         push      di
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         push      ds
         lea       di,[bp-131]
         push      ss
         pop       ds
         mov       bl,[di]
         mov       bh,0
         mov       ax,bx
         sub       ax,3

; ------ odstranˆn¡ p©¡pony z konce jm‚na souboru

l_7AC3:  or        bx,bx
         jz        l_7AE4
         cmp       bx,ax
         jb        l_7AE4
         mov       cl,[bx+di]
         cmp       cl,"\"
         je        l_7AE4
         cmp       cl,"/"
         je        l_7AE4
         cmp       cl,":"
         je        l_7AE4
         dec       bx
         cmp       cl,"."
         jne       l_7AC3
         mov       [di],bl                  ; nov  zkr cen  d‚lka jm‚na souboru

; ------ doplnˆn¡ p©¡pony "BAK"

l_7AE4:  mov       bl,[di]
         inc       bx
         mov       byte ptr [bx+di],"."
         inc       bx
         mov       byte ptr [bx+di],"B"
         inc       bx
         mov       byte ptr [bx+di],"A"
         inc       bx
         mov       byte ptr [bx+di],"K"
         mov       [di],bl
         pop       ds

; ------ test, zda soubor "BAK" ji‘ existuje

         dec       sp
         lea       di,[bp-131]              ; jm‚no souboru k nalezen¡
         push      ss
         push      di
         call      l_73F7                   ; nalezen¡ souboru zadan‚ho jm‚na
         jnz       l_7B08                   ; soubor BAK existuje
         ;jmp       l_7B2D
         db        0e9h
         dw        l_7B2D-$-2

; ------ pokud soubor BAK existuje, jeho zru¨en¡

l_7B08:  lea       di,[bp-209]
         push      ss
         push      di
         lea       di,[bp-131]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-209]
         push      ss
         call      l_2B71                   ; zru¨en¡ souboru BAK
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         jnz       l_7B2A                   ; chyba
         ;jmp       l_7B2D
         db        0e9h
         dw        l_7B2D-$-2

l_7B2A:  ;jmp       l_7B8B
         db        0e9h
         dw        l_7B8B-$-2

; ------ p©ejmenov n¡ star‚ho souboru na z lo‘n¡ soubor BAK

l_7B2D:  dec       sp
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         call      l_73F7                   ; nalezen¡ souboru zadan‚ho jm‚na
         jnz       l_7B3B
         ;jmp       l_7B68                  ; editovan˜ soubor nenalezen
         db        0e9h
         dw        l_7B68-$-2

l_7B3B:  lea       di,[bp-209]              ; jm‚no souboru BAK
         push      ss
         push      di
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2940                   ; p©¡prava jm‚na souboru k operaci
         lea       di,[bp-209]
         push      ss
         push      di
         lea       di,[bp-131]
         push      ss
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_2B8E                   ; p©ejmenov n¡ souboru
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         jnz       l_7B65
         ;jmp       l_7B68
         db        0e9h
         dw        l_7B68-$-2

l_7B65:  ;jmp       l_7B8B
         db        0e9h
         dw        l_7B8B-$-2

; ------ ulo‘en¡ souboru na disk

l_7B68:  mov       ax,1
         push      ax                       ; ‡¡slo po‡ te‡¤¡ho © dku
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         push      ax                       ; po‡et © dk– k ulo‘en¡
         mov       al,byte ptr cs:[l_3271]  ; form t(0=KonText,1=LAYOUT,2=ASCII)
         xor       ah,ah
         push      ax
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         call      l_7667                   ; z pis souboru na disk
         dec       sp
         call      l_739F                   ; test, zda nastala diskov  chyba
         xor       al,1
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu

; ------ nov‚ zobrazen¡ stavov‚ho © dku

l_7B88:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
l_7B8B:  ;jmp       l_7B8E
         db        0e9h,0,0

l_7B8E:  mov       sp,bp
         pop       bp
         ret       

l_79D9   ENDP

; *****************************************************************************
;
;                   Na‡ten¡ souboru z disku
;
; *****************************************************************************
;þ
; -----------------------------------------------------------------------------
;        na‡ten¡ souboru
; -----------------------------------------------------------------------------

l_7B92   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7B99
         db        0e9h,0,0

l_7B99:  dec       sp
         dec       sp
         call      l_591F                   ; nulov n¡ bufferu £schov˜ zmˆn
         jmp       l_7CE9

; ------ z hlav¡ souboru LAYOUT

l_7BA1   db        'CONTEXT'                ; identifik tor form tu LAYOUT
l_7BA8   db        0                        ; po‡ te‡n¡ pozice (lev˜ okraj)
l_7BA9   db        0                        ; ¨¡©ka © dku textu
l_7BAA   db        0                        ; po‡et © dk– z hlav¡
l_7BAB   db        0                        ; po‡et © dk– paty
l_7BAC   db        0                        ; po‡et © dk– na str nku celkem

; -----------------------------------------------------------------------------
;        otev©en¡ souboru pro ‡ten¡
; -----------------------------------------------------------------------------

l_7BAD   PROC      NEAR

         push      ds
         mov       ax,3D00h
         ;lds       si,dword ptr [bp+6]
         db        0C5h,0B6h,6,0            ;!
         mov       bl,[si]
         mov       bh,0
         inc       si
         mov       [bx+si],bh
         mov       dx,si
         push      bp
         int       21h
         pop       bp
         ;mov       [bp-4],ax
         db        89h,86h,0FCh,0FFh        ;!
         jc        l_7BD6
         xor       bx,bx
         xchg      bx,cs:[l_34AF]           ; chyba INT 24h - informa‡n¡ registr
         or        bx,bx
         jz        l_7BD6
         mov       al,64h
         stc       
l_7BD6:  pop       ds
         ret       

l_7BAD   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ bufferu ze souboru
; -----------------------------------------------------------------------------

l_7BD8   PROC      NEAR

         push      cx
         push      di
         push      si
         push      bp
         push      ds
         push      es
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       cx,1800h                 ; po‡et bajt– ke ‡ten¡
         mov       dx,offset d_CD98         ; diskov˜ buffer
         mov       ah,3Fh
         int       21h                      ; na‡ten¡ obsahu bufferu
         pop       es
         pop       ds
         pop       bp
         pop       si
         pop       di
         pop       cx
         mov       bx,0
         mov       dx,ax
         ret       

l_7BD8   ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru
; -----------------------------------------------------------------------------

l_7BF8   PROC      NEAR

         push      ds
         push      bp
         ;mov       bx,[bp-4]
         db        8Bh,9Eh,0FCh,0FFh        ;!
         mov       ah,3Eh
         int       21h                      ; uzav©en¡ souboru
         pop       bp
         pop       ds
         ret       

l_7BF8   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho © dku ze souboru
; -----------------------------------------------------------------------------

l_7C05   PROC      NEAR

         push      cx
         xor       cx,cx                    ; ‡¡ta‡ d‚lky dat v bufferu
         mov       di,offset d_EC59         ; buffer textov‚ho © dku

; ------ na‡ten¡ © dku do bufferu ©etˆzce

l_7C0B:  cmp       dx,bx                    ; je ji‘ konec bufferu ?
         jbe       l_7C2B                   ; je ji‘ konec dat - na‡ten¡ dal¨¡ch
l_7C0F:  mov       al,byte ptr ds:[d_CD98+bx] ; znak z bufferu
         cmp       al,EOF                   ; je konec souboru ?
         je        l_7C3A                   ; je konec souboru
         inc       bx                       ; zv˜¨en¡ ukazatele dat v bufferu
         cmp       al,LF                    ; je LF ?
         je        l_7C0B                   ; znak LF se ignoruje
         cmp       al,CR                    ; je znak CR ?
         je        l_7C40                   ; je znak CR - konec © dku
         inc       di                       ; zv˜¨en¡ ukl dac¡ adresy
         inc       cx                       ; zv˜¨en¡ ‡¡ta‡e d‚lky dat
         mov       [di],al                  ; ulo‘en¡ znaku do bufferu
         cmp       cl,240                   ; je ji‘ maxim ln¡ d‚lka © dku ?
         jne       l_7C0B                   ; buffer je¨tˆ nen¡ pln˜
         jmp       short l_7C40             ; buffer je pln˜

; ------ na‡ten¡ dal¨¡ho bloku dat z bufferu

l_7C2B:  cmp       dx,1800h                 ; byl ji‘ konec souboru ?
         jb        l_7C3A
         call      l_7BD8                   ; na‡ten¡ bufferu ze souboru
         jc        l_7C45                   ; chyba
         or        dx,dx                    ; bylo nˆco na‡teno ?
         jnz       l_7C0F                   ; jsou dal¨¡ data
l_7C3A:  mov       al,EOF                   ; znak konce souboru
         stc       
         jcxz      l_7C45                   ; nejsou dal¨¡ data
         clc       

; ------ zv˜¨en¡ d‚lky textu

l_7C40:  mov       di,offset d_EC59         ; buffer textov‚ho © dku
         mov       [di],cl                  ; ulo‘en¡ d‚lky dat
l_7C45:  pop       cx
         ret       

l_7C05   ENDP

; -----------------------------------------------------------------------------
;        detekce parametr– form tu souboru LAYOUT
; -----------------------------------------------------------------------------

l_7C47   PROC      NEAR

         push      dx
         push      bx
         push      di

; ------ minim ln¡ d‚lka prvn¡ho © dku

         cmp       byte ptr [di],27         ; minim ln¡ d‚lka prvn¡ho © dku
         jb        l_7CC0                   ; nen¡ informa‡n¡ © dek CONTEXT

; ------ porovn n¡ £vodn¡ho textu "CONTEXT"

         inc       di
         mov       cx,7                     ; d‚lka identifika‡n¡ho textu
         mov       si,offset l_7BA1         ; identifika‡n¡ text "CONTEXT"
l_7C56:  mov       al,[di]
         cmp       al,cs:[si]
         jne       l_7CC0                   ; nen¡ form t LAYOUT
         inc       di
         inc       si
         loop      l_7C56                   ; dal¨¡ znak

; ------ na‡ten¡ ‡¡seln˜ch parametr–

         mov       cl,5                     ; po‡et parametr–
         mov       dl,10                    ; dˆlitel
         mov       si,offset l_7BA8         ; buffer k ulo‘en¡ ‡¡sel
l_7C68:  mov       bh,4                     ; po‡et pozic na jedno ‡¡slo
         mov       al,0                     ; st©ada‡ hodnoty ‡¡sla
l_7C6C:  mov       bl,[di]                  ; znak z bufferu
         cmp       bl," "                   ; je oddˆlovac¡ mezera ?
         je        l_7C81                   ; je mezera - ignoruje se
         sub       bl,"0"                   ; je ‡¡slice ?
         jc        l_7CC0                   ; chyba - neplatn˜ znak
         cmp       bl,9
         ja        l_7CC0                   ; chyba - neplatn˜ znak
         mul       dl                       ; st©ada‡ * 10
         add       al,bl                    ; p©id n¡ nov‚ ‡¡slice
l_7C81:  inc       di
         dec       bh
         jnz       l_7C6C
         mov       cs:[si],al               ; na‡ten˜ ‡¡seln˜ parametr
         inc       si
         loop      l_7C68                   ; dal¨¡ ‡¡slice

; ------ je-li operace s blokem, parametry se nep©en ¨ej¡

         ;cmp       cl,[bp+4]               ; je operace s blokem ?
         db        3Ah,8Eh,4,0
         je        l_7CC0                   ; je operace s blokem - nemˆn¡ par.

; ------ p©enesen¡ na‡ten˜ch parametr– do tabulky parametr–

         call      l_3F89                   ; n vrat line lu © dk– pod okraji
         mov       si,offset l_7BA8         ; na‡ten‚ parametry
         mov       di,offset l_3259         ; po‡ te‡n¡ pozice (lev˜ okraj)
         mov       cx,5
l_7C9E:  mov       al,cs:[si]
         mov       cs:[di],al
         inc       si
         inc       di
         loop      l_7C9E

; ------ stanoven¡ po‡tu © dk– na str nku bez okraj–

         dec       di
         mov       cl,cs:[di]
         dec       di
         sub       cl,cs:[di]
         dec       di
         sub       cl,cs:[di]
         mov       word ptr ds:[d_F7A9],cx  ; po‡et © dk– na str nku bez okraj–
         call      l_3FB7                   ; ozna‡en¡ okraj– v line lu © dk–
         call      l_48FC                   ; nastaven¡ maxim ln¡ d‚lky © dku

         xor       al,al
l_7CC0:  pop       di
         pop       bx
         pop       dx
         ret       

l_7C47   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ © dk– zahlav¡/paty
; -----------------------------------------------------------------------------

l_7CC4   PROC      NEAR

         mov       ch,0
         jcxz      l_7CE8                   ; nen¡ ‘ dn˜ © dek ke ‡ten¡
l_7CC8:  call      l_7C05                   ; na‡ten¡ jednoho © dku ze souboru
         jc        l_7CE8                   ; chyba
         ;cmp       byte ptr [bp+4],0       ; je operace s blokem ?
         db        80h,0BEh,4,0,0           ;!
         je        l_7CE6                   ; je blok - © dek se neulo‘¡
         push      bx
         push      cx
         push      dx
         push      si
         push      ds
         push      si
         push      ds
         push      di
         call      l_3D53                   ; ulo‘en¡ © dku do souboru
         pop       si
         pop       dx
         pop       cx
         pop       bx
         add       si,4                     ; zv˜¨en¡ ukazatele indexu © dk–
l_7CE6:  loop      l_7CC8
l_7CE8:  ret

l_7CC4   ENDP

; -----------------------------------------------------------------------------
;        (pokra‡ov n¡ procedury l_7B92)
; -----------------------------------------------------------------------------

; ------ otev©en¡ souboru

l_7CE9:  call      l_7BAD                   ; otev©en¡ souboru pro ‡ten¡
         jc        l_7D43                   ; chyba
         call      l_7BD8                   ; prvn¡ na‡ten¡ bufferu ze souboru
         jc        l_7D43                   ; chyba
         call      l_7C05                   ; na‡ten¡ jednoho © dku ze souboru
         jc        l_7D43                   ; chyba
         call      l_7C47                   ; detekce parametr– form tu LAYOUT
         jnz       l_7D1C                   ; nen¡ form t LAYOUT

; ------ na‡ten¡ z hlav¡ souboru

         mov       cl,cs:[l_7BAA]           ; po‡et © dk– z hlav¡
         mov       si,offset d_E6AB         ; adresy © dk– z hlav¡
         call      l_7CC4                   ; na‡ten¡ © dk– zahlav¡/paty
         jc        l_7D43

; ------ na‡ten¡ paty souboru

         mov       cl,cs:[l_7BAB]           ; po‡et © dk– paty
         mov       si,offset d_E6D3         ; adresy © dk– paty
         call      l_7CC4                   ; na‡ten¡ © dk– zahlav¡/paty
         jc        l_7D43

; ------ na‡ten¡ prvn¡ho © dku

         call      l_7C05                   ; na‡ten¡ jednoho © dku ze souboru
         jc        l_7D43

; ------ na‡ten¡ obsahu souboru

l_7D1C:  ;mov       si,[bp+0Ch]             ; ukazatel © dk–
         db        8Bh,0B6h,0Ch,0           ;!
         mov       al,6
         mov       cx,[si]
         ;cmp       cx,[bp+0Ah]
         db        3Bh,8Eh,0Ah,0            ;!
         je        l_7D50
         inc       cx
         mov       [si],cx
         push      bx
         push      dx
         push      cx
         push      ds
         push      di
         call      l_3DC5                   ; ulo‘en¡ textu © dku do souboru
         pop       dx
         pop       bx
         cmp       byte ptr ds:[d_F79D],0   ; k¢d chyby KonTextu
         jne       l_7D55                   ; je chyba
         call      l_7C05                   ; na‡ten¡ jednoho © dku ze souboru
         jnc       l_7D1C

; ------ detekce n vratov‚ho k¢du ze souboru

l_7D43:  cmp       al,EOF                   ; byl soubor na‡ten cel˜ ?
         je        l_7D55                   ; soubor byl na‡ten cel˜ OK
         cmp       al,20                    ; povolen‚ ‡¡slo chyby ?
         jae       l_7D50                   ; nepovolen‚ ‡¡slo chyby
         mov       bx,offset l_34B3         ; tabulka pro konverzi chyb DOS
         xlat      cs:[bx]                  ; konverze na vnit©n¡ k¢d chyby
l_7D50:  mov       ah,0
         mov       word ptr ds:[d_F79D],ax  ; k¢d chyby KonTextu

; ------ uzav©en¡ souboru

l_7D55:  call      l_7BF8                   ; uzav©en¡ souboru
         ;jmp       l_7D5B
         db        0e9h,0,0

l_7D5B:  mov       sp,bp
         pop       bp
         ret       0Ch

l_7B92   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ n hodn˜ch 2 © dk– ze souboru CITATY.TXT
; -----------------------------------------------------------------------------

l_7D61   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7D68
         db        0e9h,0,0

l_7D68:  sub       sp,13h
         mov       ax,0
         mov       [bp+4],al
         mov       al,byte ptr cs:[l_326A]
         xor       ah,ah
         xor       al,1
         jnz       l_7D7E
         ;jmp       l_7D81
         db        0e9h
         dw        l_7D81-$-2

l_7D7E:  jmp       l_7E54

; ------ p©¡prava jm‚na souboru CITATY.TXT

l_7D81:  lea       di,[bp-11h]
         push      ss
         push      di
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        10,'CITATY.TXT'

         mov       cl,0eh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.

; ------ na‡ten¡ souboru CITATY.TXT do pamˆti

         mov       di,offset d_F7A3         ; skute‡n˜ po‡et © dk– prostoru
         push      ds
         push      di
         mov       ax,ds:[d_E69E]           ; maxim ln¡ po‡et © dk– prostoru
         push      ax
         lea       di,[bp-11h]
         push      ss
         push      di
         mov       ax,0
         push      ax
         call      l_7B92                   ; na‡ten¡ souboru
         mov       ax,ds:[d_F79D]           ; k¢d chyby KonTextu
         cmp       ax,0
         je        l_7DB9
         ;jmp       l_7E22
         db        0e9h
         dw        l_7E22-$-2

; ------ p©¡prava prvn¡ho © dku souboru do pamˆti

l_7DB9:  mov       ax,1
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_3EDF                   ; na‡ten¡ textu © dku do bufferu
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_367B                   ; o©ez n¡ ©et. od mezer z obou stran

; ------ na‡ten¡ po‡tu © dk– v textu (‡¡seln˜ parametr na prvn¡m © dku)

         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         lea       di,[bp-13h]
         push      ss
         push      di
         lea       di,[bp-15h]              ; buffer k ulo‘en¡ ‡¡sla
         push      ss
         call      l_0E68                   ; na‡ten¡ ‡¡sla INTEGER
         mov       ax,[bp-15h]
         cmp       ax,0
         je        l_7DEB
         ;jmp       l_7E22
         db        0e9h
         dw        l_7E22-$-2

; ------ stanoven¡ n hodn‚ho ‡¡sla © dku

l_7DEB:  mov       ax,2Ch
         push      ax
         call      l_63DA                   ; vol n¡ slu‘by DOS INT 21h
         mov       ax,ds:[d_0266]           ; registr DX = sekunda a setina
         cwd
         idiv      word ptr [bp-13h]        ; n hodn‚ ‡¡slo cit tu
         xchg      ax,dx
         inc       ax
         mov       cx,1
         shl       ax,cl                    ; ‡¡slo * 2
         mov       [bp-13h],ax              ; ‡¡slo © dku

; ------ na‡ten¡ dvou © dk– cit tu

         mov       ax,[bp-13h]
         push      ax
         mov       di,offset d_EC59         ; buffer textov‚ho © dku
         push      ds
         push      di
         call      l_3EDF                   ; na‡ten¡ prvn¡ho textu © dku
         mov       ax,[bp-13h]
         inc       ax
         push      ax
         mov       di,offset d_F059         ; druh  ‡ st © dku
         push      ds
         push      di
         call      l_3EDF                   ; na‡ten¡ druh‚ho textu © dku
         mov       ax,1
         mov       [bp+4],al

; ------ zru¨en¡ souboru z pamˆti

l_7E22:  mov       ax,1
         push      ax
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         pop       cx
         xchg      ax,cx
         sub       cx,ax
         jge       l_7E32
         ;jmp       l_7E48
         db        0e9h
         dw        l_7E48-$-2

l_7E32:  inc       cx
         mov       [bp-13h],ax
l_7E36:  push      cx
         mov       ax,[bp-13h]
         push      ax
         call      l_3A2E                   ; uvolnˆn¡ © dku z pamˆti
         pop       cx
         dec       cx
         jz        l_7E48
         inc       word ptr [bp-13h]
         ;jmp       l_7E36
         db        0e9h
         dw        l_7E36-$-2

l_7E48:  mov       ax,0
         mov       ds:[d_F7A3],ax           ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,0
         mov       ds:[d_F79D],ax           ; k¢d chyby KonTextu
l_7E54:  ;jmp       l_7E57
         db        0e9h,0,0

l_7E57:  mov       al,[bp+4]
         xor       ah,ah
         or        ax,ax
         mov       sp,bp
         pop       bp
         ret       1

l_7D61   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ zadan‚ho souboru do pamˆti
; -----------------------------------------------------------------------------

l_7E64   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7E6B
         db        0e9h,0,0

l_7E6B:  les       di,dword ptr [bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        0

         call      l_125B                   ; porovn n¡ textov˜ch ©etˆzc– "="
         jnz       l_7E7E
         ;jmp       l_7E81
         db        0e9h
         dw        l_7E81-$-2

l_7E7E:  ;jmp       l_7EBF
         db        0e9h
         dw        l_7EBF-$-2

l_7E81:  mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         les       di,[bp+4]
         push      es
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,80h
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         call      l_7534                   ; jm‚no souboru na plnou specifikaci
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        4,' €te'

         mov       cl,8
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         call      l_74D8                   ; hl ¨en¡ o ukl d n¡/‡ten¡ souboru
         mov       di,offset d_F7A3         ; skute‡n˜ po‡et © dk– prostoru
         push      ds
         push      di
         mov       ax,ds:[d_E69E]           ; maxim ln¡ po‡et © dk– prostoru
         push      ax
         mov       di,offset d_E6FB         ; jm‚no editovan‚ho souboru
         push      ds
         push      di
         mov       ax,1
         push      ax
         call      l_7B92                   ; na‡ten¡ souboru

l_7EBF:  ;jmp       l_7EC2
         db        0e9h,0,0

l_7EC2:  mov       sp,bp
         pop       bp
         ret       4

l_7E64   ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ souboru do pamˆti jako blok
; -----------------------------------------------------------------------------

l_7EC8   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7ECF
         db        0e9h,0,0

l_7ECF:  sub       sp,4
         call      l_4897                   ; ulo‘en¡ obsahu editovan‚ho © dku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       word ptr ds:[d_E690],ax  ; © dek za‡ tku bloku
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         dec       ax
         mov       word ptr ds:[d_E692],ax  ; © dek konce bloku
         mov       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         sub       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         mov       [bp-6],ax
         mov       ax,[bp-6]
         cmp       ax,0
         jg        l_7EF7
         ;jmp       l_7F1F
         db        0e9h
         dw        l_7F1F-$-2

l_7EF7:  mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         sub       ax,word ptr ds:[d_F7A3]  ; skute‡n˜ po‡et © dk– prostoru
         add       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         mov       [bp-4],ax
         mov       ax,word ptr ds:[d_E698]  ; ‡¡slo aktivn¡ho editovan‚ho © dku
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,[bp-4]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,[bp-6]
         push      ax
         call      l_3ACA                   ; p©esun bloku definic © dk–
         ;jmp       l_7F2C
         db        0e9h
         dw        l_7F2C-$-2

l_7F1F:  mov       ax,word ptr ds:[d_E69E]  ; maxim ln¡ po‡et © dk– prostoru
         inc       ax
         mov       [bp-4],ax
         mov       ax,0
         mov       [bp-6],ax
l_7F2C:  mov       di,offset d_E692         ; © dek konce bloku
         push      ds
         push      di
         mov       ax,[bp-4]
         dec       ax
         push      ax
         les       di,dword ptr [bp+4]
         push      es
         push      di
         mov       ax,0
         push      ax
         call      l_7B92                   ; na‡ten¡ souboru
         mov       ax,[bp-4]
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         inc       ax
         add       ax,word ptr ds:[d_F7A5]  ; po‡ te‡n¡ © dek prostoru v tabulce
         push      ax
         mov       ax,[bp-6]
         push      ax
         call      l_3ACA                   ; p©esun bloku definic © dk–
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         add       ax,[bp-6]
         mov       word ptr ds:[d_F7A3],ax  ; skute‡n˜ po‡et © dk– prostoru
         mov       ax,0
         mov       byte ptr ds:[d_E6A8],al  ; 0=p©¡znak modifikace textu
         mov       ax,0
         mov       byte ptr ds:[d_E6AA],al  ; 1=p©¡znak sloupcov‚ho bloku
         mov       ax,word ptr ds:[d_E692]  ; © dek konce bloku
         cmp       ax,word ptr ds:[d_E690]  ; © dek za‡ tku bloku
         mov       ax,1
         jge       l_7F7C
         dec       ax
l_7F7C:  mov       byte ptr ds:[d_E6A9],al  ; 1=p©¡znak zapnut¡ zobrazen¡ bloku
         ;jmp       l_7F82
         db        0e9h,0,0

l_7F82:  mov       sp,bp
         pop       bp
         ret       4

l_7EC8   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KR a Blok/‡ten¡ z disku (‡ten¡ bloku ze souboru)
; -----------------------------------------------------------------------------

l_7F88   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7F8F
         db        0e9h,0,0

; ------ zad n¡ jm‚na ke ‡ten¡ bloku

l_7F8F:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       di,offset d_F55B         ; jm‚no souboru ke ‡ten¡ bloku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        23,'   N zev ‡ten‚ho bloku '

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         mov       di,offset d_F55B         ; jm‚no souboru ke ‡ten¡ bloku
         push      ds
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_7FD4
         ;jmp       l_7FE7
         db        0e9h
         dw        l_7FE7-$-2

; ------ na‡ten¡ souboru do pamˆti

l_7FD4:  mov       di,offset d_F55B         ; jm‚no souboru ke ‡ten¡ bloku
         push      ds
         push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         mov       di,offset d_F55B         ; jm‚no souboru ke ‡ten¡ bloku
         push      ds
         push      di
         call      l_7EC8                   ; na‡ten¡ soub. do pamˆti jako blok

; ------ obnoven¡ zobrazen¡ obrazovky

         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_7FE7:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku
         ;jmp       l_7FED
         db        0e9h,0,0

l_7FED:  mov       sp,bp
         pop       bp
         ret

l_7F88   ENDP

; -----------------------------------------------------------------------------
;        obsluha volby Ctrl-KL (‡ten¡ souboru z disku)
; -----------------------------------------------------------------------------

l_7FF1   PROC      NEAR

         push      bp
         mov       bp,sp
         push      bp
         ;jmp       l_7FF8
         db        0e9h,0,0

; ------ zru¨en¡ star‚ho souboru z pamˆti

l_7FF8:  dec       sp
         call      l_725B                   ; ukon‡en¡ editace - zru¨en¡ souboru
         jnz       l_8001
         ;jmp       l_805B
         db        0e9h
         dw        l_805B-$-2

; ------ zad n¡ jm‚na ‡ten‚ho souboru

l_8001:  mov       di,offset d_F359         ; edita‡n¡ buffer zad n¡ parametru
         push      ds
         push      di
         mov       di,offset d_F65D         ; jm‚no ‡ten‚ho souboru z disku
         push      ds
         call      l_11AD                   ; p©enesen¡ ©etˆzce DI do z sobn¡ku
         mov       cl,0FFh
         call      l_11DC                   ; p©enesen¡ ©etˆzce ze z sob.do buf.
         call      l_11C6                   ; ulo‘en¡ textu za CALL do z sobn¡ku
         db        22,'Zadejte jm‚no souboru '

         mov       cl,80h
         call      l_121E                   ; zmˆna d‚lky ©etˆzce v z sob. na CL
         mov       di,offset d_F65D         ; jm‚no ‡ten‚ho souboru z disku
         push      ds
         push      di
         call      l_7463                   ; zad n¡ jm‚na souboru
         mov       al,ds:[d_F78A]           ; 1=p©¡znak p©eru¨en¡ editace volby
         xor       ah,ah
         xor       al,1
         jnz       l_8045
         ;jmp       l_8058
         db        0e9h
         dw        l_8058-$-2

; ------ na‡ten¡ souboru do pamˆti

l_8045:  mov       di,offset d_F65D         ; jm‚no ‡ten‚ho souboru z disku
         push      ds
         push      di
         call      l_3631                   ; konverze ©etˆzce na velk  p¡smena
         mov       di,offset d_F65D         ; jm‚no ‡ten‚ho souboru z disku
         push      ds
         push      di
         call      l_7E64                   ; na‡ten¡ zadan‚ho souboru do pamˆti

; ------ obnoven¡ zobrazen¡ obrazovky

         call      l_4C6D                   ; obnoven¡ zobrazen¡ obrazovky
l_8058:  call      l_44E7                   ; zobrazen¡ horn¡ho stavov‚ho © dku

l_805B:  ;jmp       l_805E
         db        0e9h,0,0

l_805E:  mov       sp,bp
         pop       bp
         ret       

l_7FF1   ENDP

Code     ENDS

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;                             Datov˜ segment
;
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

Data     SEGMENT BYTE PUBLIC

Data     ENDS
         END

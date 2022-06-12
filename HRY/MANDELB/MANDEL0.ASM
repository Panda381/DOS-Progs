
code     segment
         assume    cs:code,ds:code
         org       100h

start:
         mov       ax,5
         int       10h

         mov       word ptr ds:[PozY],0
         mov       di,190h                  ; po‡ tek Y

Mand1:   mov       word ptr ds:[PozX],0
         mov       si,0fda2h                ; po‡ tek X

; ------ generov n¡ jedn‚ linky

Mand2:   mov       bx,si                    ; adresa X
         mov       cx,di                    ; adresa Y
         mov       byte ptr ds:[Barva],6*4  ; v˜choz¡ barva (b¡l )

; ------ X^2

Mand3:   mov       ax,bx                    ; adresa X
         imul      ax                       ; X^2
         mov       al,ah                    ;
         mov       ah,dl                    ; X / 256
         mov       bp,ax                    ; X^2/256

; ------ Y^2

         mov       ax,cx                    ; adresa Y
         imul      cx                       ; Y^2
         mov       al,ah
         mov       ah,dl                    ; Y / 256
         mov       es,ax                    ; Y^2/256

; ------ X^2 + Y^2

         add       ax,bp                    ; AX <- (X^2 + Y^2) / 256
         sub       ax,800h                  ; je > 800h ?
         jnc       Mand5                    ; je > 800h - zobrazen¡


         mov       ax,es                    ; Y^2 / 256
         sub       bp,ax                    ; X^2 - Y^2
         add       bp,si                    ; X^2 - Y^2 + X
         xchg      bp,bx                    ; BP <- X, BX <- X^2-Y^2+X
         mov       ax,cx                    ; AX <- Y
         imul      bp                       ; AX <- X*Y
         mov       cl,ah                    ;
         mov       ch,dl                    ; CX <- X*Y/256

         test      dh,80h                   ; je kladn‚ ‡¡slo ?
         jz        Mand4                    ; je kladn‚ ‡¡slo

         cmp       al,1
         cmc
         adc       cx,0                     ;

Mand4:   add       cx,cx                    ; X*Y/256 * 2
         add       cx,di                    ; X*Y/256 * 2 + Y

         dec       byte ptr ds:[Barva]      ; sn¡‘en¡ ‡¡ta‡e barev
         jnz       Mand3                    ; v¨echny barvy

; ------ zobrazen¡ bodu

Mand5:   mov       ah,0ch
         mov       al,ds:[Barva]            ; barva
         and       al,3                     ; ohrani‡en¡ barvy bodu
         mov       cx,ds:[PozX]             ; pozice bodu X
         mov       dx,ds:[PozY]             ; pozice bodu Y
         int       10h

; ------ dal¨¡ bod na lince

         add       si,3                     ; zv˜¨en¡ adresy X
         inc       cx                       ; zv˜¨en¡ pozice bodu X
         mov       ds:[PozX],cx             ; nov  pozice bodu
         cmp       cx,320                   ; jsou ji‘ v¨echny body ?
         jnz       Mand2                    ; dal¨¡ bod na lince

; ------ test p©eru¨en¡ programu

         mov       ah,1
         int       16h
         jnz       Mand6

; ------ dal¨¡ linka

         sub       di,4                     ; zv˜¨en¡ adresy Y
         inc       dx                       ; zv˜¨en¡ adresy linky Y
         mov       ds:[PozY],dx             ; nov  linka
         cmp       dx,200                   ; jsou ji‘ v¨echny linky ?
         je        Mand6
         jmp       Mand1                    ; dal¨¡ linka

; ------ konec programu

Mand6:   xor       ax,ax                    ; AX <- 0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         mov       ax,2                     ; videom¢d 2
         int       10h                      ; inicializace videom¢du 2
         int       20h                      ; n vrat z programu

PozX     dw        0                        ; pozice bodu X
PozY     dw        0                        ; pozice bodu Y
Barva    db        0

code     ends
         end       start

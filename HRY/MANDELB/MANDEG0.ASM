
code     segment
         assume    cs:code,ds:code
         org       100h

SetMaxX  EQU       320                      ; maxim ln¡ po‡et bod– na linku
SetMaxY  EQU       200                      ; maxim ln¡ po‡et linek
SetVMod  EQU       13                       ; nastaven˜ videom¢d

SetX     EQU       -700                     ; v˜choz¡ sou©adnice X
SetY     EQU       700                      ; v˜choz¡ sou©adnice Y
SetLev   EQU       60                       ; maxim ln¡ hloubka vno©en¡
SetLupa  EQU       1000                     ; zvˆt¨en¡ lupy

start:
         mov       ax,SetVMod
         int       10h

         mov       ax,0a000h
         mov       es,ax
         xor       di,di

         mov       dx,3ceh
         mov       al,1
         out       dx,al                    ; volba registru 1
         inc       dx
         mov       al,0fh
         out       dx,al                    ; v¨echny roviny podle registru 0

Mand1:   mov       word ptr ds:[X],SetX     ; po‡ tek X
         mov       word ptr ds:[MaxX],SetMaxX ; po‡et bod– k zobrazen¡

; ------ generov n¡ jedn‚ linky

Mand2:   mov       bx,ds:[X]                ; adresa X
         mov       cx,ds:[Y]                ; adresa Y
         mov       word ptr ds:[Level],0    ; ‡¡ta‡ po‡tu iterac¡

; ------ X^2

Mand3:   mov       ax,bx                    ; adresa X
         imul      ax                       ; X^2
         idiv      word ptr ds:[Lupa]
         mov       bp,ax                    ; X^2/256

; ------ Y^2

         mov       ax,cx                    ; adresa Y
         imul      cx                       ; Y^2
         idiv      word ptr ds:[Lupa]
         mov       si,ax                    ; Y^2/256

; ------ X^2 + Y^2

         add       ax,bp                    ; AX <- (X^2 + Y^2) / 256
         cmp       ax,800h                  ; je > 800h ?
         jae       Mand5                    ; je > 800h - dosa‘eno bodu

         mov       ax,si                    ; Y^2 / 256
         sub       bp,ax                    ; X^2 - Y^2
         add       bp,ds:[X]                ; X^2 - Y^2 + X
         xchg      bp,bx                    ; BP <- X, BX <- X^2-Y^2+X
         mov       ax,cx                    ; AX <- Y
         imul      bp                       ; AX <- X*Y

         mov       cx,ax
         idiv      word ptr ds:[Lupa]
         xchg      cx,ax

         or        cx,cx
         jns       Mand4                    ; je kladn‚ ‡¡slo

         cmp       al,1
         cmc
         adc       cx,0                     ;

Mand4:   shl       cx,1                     ; X*Y/256 * 2
         add       cx,ds:[Y]                ; X*Y/256 * 2 + Y

         inc       word ptr ds:[Level]      ; ‡¡ta‡ po‡tu iterac¡
         cmp       word ptr ds:[Level],SetLev ; maxim. po‡et iterac¡ ?
         jb        Mand3                    ; nen¡ je¨tˆ maximum
         mov       byte ptr ds:[Level],15   ; p©ete‡en¡ - n hradn¡ barva

; ------ zobrazen¡ bodu

Mand5:   mov       dx,3ceh
         mov       al,0
         out       dx,al                    ; volba registru 0
         inc       dx
         mov       al,byte ptr ds:[Level]
         out       dx,al                    ; volba barvy bodu

         dec       dx
         mov       al,8
         out       dx,al                    ; volba registru 8
         inc       dx

         mov       cl,byte ptr ds:[MaxX]    ; rotace k zobrazen¡ bodu
         dec       cl
         and       cl,7
         mov       al,1
         shl       al,cl
         out       dx,al                    ; bitov  maska pro z pis
         xchg      al,es:[di]               ; zobrazen¡ bodu
         or        cl,cl
         jnz       Mand8
         inc       di
Mand8:

; ------ dal¨¡ bod na lince

         inc       word ptr ds:[X]          ; zv˜¨en¡ adresy X
         dec       word ptr ds:[MaxX]       ; ‡¡ta‡ bod– k zobrazen¡
         jz        Mand7
         jmp       Mand2                    ; dal¨¡ bod na lince

; ------ test p©eru¨en¡ programu

Mand7:   mov       ah,1
         int       16h
         jnz       Mand6

; ------ dal¨¡ linka

         dec       word ptr ds:[Y]          ; zv˜¨en¡ adresy Y
         dec       word ptr ds:[MaxY]       ; nov  linka
         jz        Mand6
         jmp       Mand1                    ; dal¨¡ linka

; ------ konec programu

Mand6:   xor       ax,ax                    ; AX <- 0
         int       16h                      ; ‡ek n¡ na stisk kl vesy
         mov       ax,2                     ; videom¢d 2
         int       10h                      ; inicializace videom¢du 2
         int       20h                      ; n vrat z programu

MaxX     dw        SetMaxX                  ; po‡et bod– k zobrazen¡
MaxY     dw        SetMaxY                  ; po‡et linek k zobrazen¡

X        dw        SetX                     ; sou©adnice X
Y        dw        SetY                     ; sou©adnice Y
Level    dw        0                        ; ‡¡ta‡ iterac¡
Lupa     dw        SetLupa                  ; zvˆt¨en¡ lupy

code     ends
         end       start

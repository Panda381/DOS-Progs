
MODX     EQU       320                      ; ¨¡©ka displeje
MODY     EQU       200                      ; v˜¨ka displeje

MPOZIC   EQU       5                        ; po‡et pozic menu
MRADKU   EQU       5                        ; po‡et © dk– menu
MCELKEM  EQU       MPOZIC*MRADKU            ; po‡et zobrazen˜ch polo‘ek menu
MSIRKA   EQU       MODX/MPOZIC              ; po‡et bod– obr zku menu
MVYSKA   EQU       MODY/MRADKU              ; po‡et linek obr zku menu

PPOZIC   EQU       5                        ; po‡et pozic puzle
PRADKU   EQU       4                        ; po‡et © dk– puzle
PCELKEM  EQU       PPOZIC*PRADKU            ; po‡et puzle celkem
PSIRKA   EQU       MODX/PPOZIC              ; ¨¡©ka jednoho puzle (sud‚ !)
PVYSKA   EQU       MODY/PRADKU              ; v˜¨ka jednoho puzle (sud‚ !)

BPOZIC   EQU       PPOZIC-1                 ; po‡et pozic bufferu
BRADKU   EQU       PRADKU-1                 ; po‡et © dk– bufferu
BCELKEM  EQU       BPOZIC*BRADKU            ; po‡et puzle bufferu celkem

Code     SEGMENT
         ASSUME    cs:Code,ds:Code
         ORG       100h

; ------ p©edefinov n¡ z sobn¡ku

Start:   mov       dx,offset ErrMem
         cmp       sp,offset Zasob
         jbe       Chyba                    ; chyba - m lo pamˆti
         mov       sp,offset Zasob          ; p©edefinov n¡ z sobn¡ku

; ------ zmen¨en¡ bloku programu

         mov       bx,(offset(Zasob-Start)+10fh)/16 ; po‘adovan  velikost
         mov       ah,4ah
         int       21h                      ; zmen¨en¡ bloku programu

; ------ vytvo©en¡ segmentu obr zku

         mov       bx,1000h                 ; 64 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ segmentu obr zku
         jc        Chyba
         mov       ds:[SegmObr],ax          ; segment obr zku

; ------ vytvo©en¡ segmentu bufferu

         mov       bx,1000h                 ; 64 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ segmentu bufferu
         jc        Chyba
         mov       ds:[SegmBuf],ax          ; segment bufferu

; ------ vytvo©en¡ segmentu £schovy obr zk–

         mov       bx,1000h                 ; 64 KB
         mov       ah,48h
         int       21h                      ; vytvo©en¡ segmentu £schovy
         jc        Chyba
         mov       ds:[SegmUsch],ax         ; segment £schovy

; ------ inicializace soubor–

         call      SoubInit                 ; inicializace soubor–
         mov       dx,offset NoTxt
         cmp       word ptr ds:[SoubNum],0  ; bylo nˆco nalezeno ?
         je        Chyba                    ; nic nenalezeno

; ------ nastaven¡ videom¢du

Start0:  mov       ax,13h
         call      Int10
         mov       ax,0f00h
         call      Int10
         cmp       al,13h
         je        Start1
         mov       dx,offset ErrTxt
Chyba:   mov       ah,9
         int       21h
         int       20h

; ------ inicializace palet

Start1:  call      InitPal                  ; inicializace palet

; ------ vymaz n¡ videopamˆti

         xor       di,di
         mov       ax,0a000h
         mov       es,ax
         mov       al,2 + 2*6 + 2*6*7       ; ¨ed  barva
         mov       cx,320*200
         cld
         rep       stosb                    ; vymaz n¡ videopamˆti

; ------ inicializace my¨i

         call      InitMous                 ; inicializace my¨i

; ------ p©¡prava ukazatel–

         or        byte ptr ds:[Param],1    ; p©¡znak re‘imu menu
Start18: mov       word ptr ds:[KonvAPal],offset KonvPal ; ukazatel tabulek palet
         mov       word ptr ds:[AktFramU],0 ; ‡¡slo v tabulce r m–
         xor       di,di                    ; ukazatel ukl dac¡ adresy
         mov       ah,0                     ; ukazatel © dku
Start2:  mov       al,0                     ; ukazatel pozice

; ------ n vrat uschovan‚ho obr zku

Start22: call      MousInt                  ; obsluha kurzoru my¨i
         test      byte ptr ds:[MouseKey],8 ; stisk prav‚ho tla‡¡tka ?
         jz        Start220                 ; nen¡ stisk prav‚ho tla‡¡tka
         jmp       Start9                   ; p©eru¨en¡

Start220:test      byte ptr ds:[MouseKey],4 ; stisk lev‚ho tla‡¡tka ?
         jz        Start221                 ; nen¡ stisk lev‚ho tla‡¡tka
         jmp       Anim

Start221:push      ax
         push      di

         push      ds
         mov       es,ds:[SegmObr]          ; segment obr zku
         mov       ds,ds:[SegmUsch]         ; segment £schovy
         mov       si,di                    ; SI <- adresa obr zku
         xor       di,di

         cld
         mov       dx,MVYSKA                ; po‡et zobrazen˜ch linek
Start222:mov       cx,MSIRKA                ; po‡et zobrazen˜ch bod–

         push      si
         push      di
Start224:movsb
         add       di,MPOZIC-1
         loop      Start224
         pop       di
         pop       si
         add       di,MRADKU*MODX           ; dal¨¡ © dek
         add       si,MODX                  ; dal¨¡ © dek

         dec       dx
         jnz       Start222

         pop       ds

         pop       di
         pop       ax

; ------ otev©en¡ souboru k zobrazen¡ menu

         push      ax
         push      di
         call      OpenFil                  ; otev©en¡ souboru
         pop       di
         pop       ax
         jc        Start3                   ; soubor nenalezen nebo chybn˜

; ------ p©¡prava ukazatele r m–

         push      ax
         mov       bx,ds:[AktFramU]         ; ‡¡slo v tabulce r m–
         mov       ax,ds:[bx+CitFramT]      ; uschovan˜ ‡¡ta‡ r m–
         mov       ds:[CitFram],ax
         shl       bx,1
         mov       ax,word ptr ds:[bx+NxtFramT]
         mov       word ptr ds:[NextFram],ax
         mov       ax,word ptr ds:[bx+NxtFramT+2]
         mov       word ptr ds:[NextFram+2],ax
         pop       ax

; ------ zobrazen¡ souboru

         push      ax
         push      di
         call      DispFil                  ; zobrazen¡ souboru
         pop       di
         pop       ax

; ------ £schova ukazatele r m–

         push      ax
         mov       bx,ds:[AktFramU]         ; ‡¡slo v tabulce r m–
         mov       ax,ds:[CitFram]
         mov       ds:[bx+CitFramT],ax      ; uschovan˜ ‡¡ta‡ r m–
         shl       bx,1
         mov       ax,word ptr ds:[NextFram]
         mov       word ptr ds:[bx+NxtFramT],ax
         mov       ax,word ptr ds:[NextFram+2]
         mov       word ptr ds:[bx+NxtFramT+2],ax
         pop       ax

; ------ £schova obr zku

         push      ax
         push      di

         push      ds
         mov       es,ds:[SegmUsch]         ; segment £schovy
         mov       ds,ds:[SegmObr]          ; segm
         xor       si,si

         cld
         mov       dx,MVYSKA                ; po‡et zobrazen˜ch linek
Start242:mov       cx,MSIRKA                ; po‡et zobrazen˜ch bod–

         push      si
         push      di
Start244:movsb
         add       si,MPOZIC-1
         loop      Start244
         pop       di
         pop       si
         add       si,MRADKU*MODX           ; dal¨¡ © dek
         add       di,MODX                  ; dal¨¡ © dek

         dec       dx
         jnz       Start242

         pop       ds

         pop       di
         pop       ax

; ------ uzav©en¡ souboru

Start3:  push      ax
         push      di
         call      ClosFil                  ; uzav©en¡ souboru
         pop       di
         pop       ax

; ------ vstup znaku z kl vesnice

         push      ax
         mov       ah,1
         int       16h
         pop       ax
         jnz       Start8                   ;

; ------ p©¡prava pro dal¨¡ soubor

         add       word ptr ds:[AktFramU],2 ; ‡¡slo v tabulce r m–
         add       word ptr ds:[KonvAPal],256 ; dal¨¡ konverzn¡ tabulka palet
         add       di,MSIRKA                ; adresa dal¨¡ pozice
         inc       ax                       ; zv˜¨en¡ ‡¡sla pozice
         cmp       al,MPOZIC                ; je konec © dku ?
         jae       Start6
         jmp       Start22                  ; nen¡ konec © dku

Start6:  add       di,MVYSKA*MODX-MODX      ; adresa dal¨¡ho © dku
         inc       ah                       ; zv˜¨en¡ ukazatele © dku
         cmp       ah,MRADKU
         jb        Start7                   ; dal¨¡ © dek

Start62: call      MousInt                  ; obsluha kurzoru my¨i
         test      byte ptr ds:[MouseKey],8 ; stisk prav‚ho tla‡¡tka ?
         jnz       Start9                   ; je stisk prav‚ho tla‡¡tka
         test      byte ptr ds:[MouseKey],4 ; stisk lev‚ho tla‡¡tka ?
         jz        Start64
         jmp       Anim                     ; je stisk lev‚ho tla‡¡tka

Start64: mov       ah,1
         int       16h
         jnz       Start8                   ; je kl vesa
         call      TestTime
         jz        Start62                  ; nen¡ zmˆna

         jmp       Start18

Start7:  jmp       Start2

Start8:  mov       ah,0
         int       16h

Start9:  call      ClosFil                  ; uzav©en¡ souboru

; ------ n vrat videom¢du

         mov       ax,3
         call      Int10
         mov       dx,offset UvTxt
         mov       ah,9
         int       21h
         int       20h

; -----------------------------------------------------------------------------
;        inicializace soubor–
; -----------------------------------------------------------------------------

SoubInit PROC      NEAR

; ------ nalezen¡ za‡ tku domovsk‚ cesty

         mov       ds,ds:[2ch]              ; segment prost©ed¡
         xor       si,si                    ; ukazatel v prost©ed¡
SoubIni1:inc       si                       ; zv˜¨en¡ ukazatele v prost©ed¡
         js        SoubIni2                 ; p©ete‡en¡
         cmp       word ptr ds:[si-1],0     ; je konec prost©ed¡ ?
         jne       SoubIni1                 ; nalezen¡ konce prost©ed¡
         add       si,3                     ; za‡ tek cesty

; ------ p©enesen¡ cesty

SoubIni2:cld
         mov       di,offset SoubBuff       ; buffer jm‚na souboru
         push      cs
         pop       es                       ; segment ukl dac¡ adresy
         mov       bx,di                    ; BX <- konec cesty
SoubIni3:lodsb
         cmp       di,offset SoubBuff+110
         jae       SoubIni6
         stosb
         cmp       al,":"
         je        SoubIni4
         cmp       al,"\"
         jne       SoubIni5
SoubIni4:mov       bx,di                    ; BX <- £schova ukl dac¡ adresy
SoubIni5:cmp       al,0
         jne       SoubIni3
SoubIni6:mov       di,bx                    ; ukl dac¡ adresa jm‚na souboru

; ------ p©enesen¡ specifikace soubor– pro hled n¡

         push      cs
         pop       ds                       ; DS <- datov˜ segment
         mov       ds:[SoubAdr],di          ; adresa jm‚na souboru
         mov       si,offset SoubSrc        ; specifikace soubor–
         mov       cx,14/2                  ; asi tak d‚lka jm‚na souboru
         rep       movsb                    ; p©enesen¡ jm‚na souboru

; ------ nastaven¡ adresy DTA

         mov       dx,offset DTA
         mov       ah,1ah
         int       21h                      ; nastaven¡ adresy DTA

; ------ nalezen¡ souboru

         mov       dx,offset SoubBuff
         mov       ah,4eh
         mov       cx,20h                   ; archivn¡ soubory
SoubIni7:int       21h                      ; nalezen¡ souboru
         jc        SoubIni8                 ; nen¡ dal¨¡ soubor

; ------ ulo‘en¡ jm‚na souboru do bufferu

         mov       cx,14                    ; po‡et bajt– na soubor
         mov       ax,ds:[SoubNum]          ; po‡et soubor– v seznamu
         mul       cx                       ; offset v seznamu
         add       ax,offset SoubSezn       ; adresa v seznamu
         xchg      ax,di                    ; DI <- ukl dac¡ adresa
         mov       si,offset DTA+1eh        ; jm‚no souboru
         cld
         rep       movsb                    ; £schova jm‚na souboru

; ------ zv˜¨en¡ ‡¡ta‡e po‡tu soubor– v seznamu

         inc       word ptr ds:[SoubNum]    ; zv˜¨en¡ po‡tu soubor–
         cmp       word ptr ds:[SoubNum],MCELKEM ; je ji‘ seznam pln˜ ?
         mov       ah,4fh
         jb        SoubIni7                 ; dal¨¡ soubor

; ------ set©¡dˆn¡ seznamu soubor–

SoubIni8:mov       dx,ds:[SoubNum]          ; po‡et soubor– v seznamu
         or        dx,dx                    ; je nˆjak˜ soubor v seznamu ?
         jz        SoubIni9                 ; nen¡ ‘ dn˜ soubor
         dec       dx                       ; je v¡ce ne‘ 1 soubor ?
         jz        SoubIni9                 ; je jen 1 soubor
         cld
         mov       si,offset SoubSezn       ; seznam soubor–
SoubIn82:mov       di,si
         add       di,14                    ; dal¨¡ polo‘ka
         push      si
         push      di
         mov       cx,14
         repe      cmpsb                    ; porovn n¡ jmen soubor–
         pop       di
         pop       si
         jbe       SoubIn86                 ; je to OK

SoubIn84:lodsb
         xchg      al,ds:[di]
         inc       di
         mov       ds:[si-1],al
         loop      SoubIn84
         jmp       short SoubIni8

SoubIn86:add       si,14
         dec       dx
         jnz       SoubIn82                 ; dal¨¡ soubor

SoubIni9:ret

SoubInit ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ animace
; -----------------------------------------------------------------------------

Anim:    call      ClosFil                  ; uzav©en¡ souboru

         and       byte ptr ds:[Param],not 1 ; p©¡znak re‘imu animace

         mov       ax,ds:[MouseX]
         xor       dx,dx
         mov       cx,MSIRKA
         div       cx
         mov       bl,al

         mov       ax,ds:[MouseY]
         xor       dx,dx
         mov       cx,MVYSKA
         div       cx
         mov       ah,bl
         xchg      al,ah

         call      OpenFil
         jc        Anim9

         call      ReadFrm                  ; zaji¨tˆn¡ na‡ten¡ palet
         call      PlayPuz                  ; skl d n¡ puzl¡
         jc        Anim9                    ; p©eru¨en¡

         mov       word ptr ds:[CitFram],0  ; nulov n¡ ‡¡ta‡e r m–

         call      MouseOff

Anim2:   call      TestTime                 ; test ‡asu animace
         jz        Anim3                    ; nen¡ animace

         push      word ptr ds:[SegmObr]
         mov       word ptr ds:[SegmObr],0a000h
         call      ReadFrm                  ; na‡ten¡ jednoho r mu do bufferu
         pop       word ptr ds:[SegmObr]

Anim3:   call      MousInt                  ; obsluha kurzoru my¨i
         test      byte ptr ds:[MouseKey],8+4 ; stisk tla‡¡tka ?
         jnz       Anim9                    ; p©eru¨en¡ prav˜m tla‡¡tkem
         mov       ah,1
         int       16h
         jz        Anim2
         mov       ah,0
         int       16h

Anim9:   call      ClosFil                  ; uzav©en¡ souboru

         call      MouseOff
         mov       byte ptr ds:[PuzlAkt],-1 ; nen¡ aktivn¡ puzle
         mov       word ptr ds:[MousSir],8
         mov       word ptr ds:[MousVys],8
         jmp       Start0

; -----------------------------------------------------------------------------
;        sestaven¡ puzle -> CY=p©eru¨en¡
; -----------------------------------------------------------------------------
;þ
PlayPuz  PROC      NEAR

; ------ inicializace ukazatel– puzl¡

         call      InitPuz                  ; inicializace puzl¡
         or        byte ptr ds:[Param],2    ; p©¡znak prvn¡ volby

; ------ volba puzle

PlayPuz4:call      VolPuz                   ; volba puzle z bufferu
         test      byte ptr ds:[Param],2    ; byla prvn¡ volba ?
         jz        PlayPz41                 ; nebyla prvn¡ volba
         cmp       al,-1                    ; je p©eru¨en¡ volby ?
         jne       PlayPz41                 ; nen¡ p©eru¨en¡ operace
         stc                                ; p©¡znak p©eru¨en¡
         ret

; ------ zobrazen¡ podkladu

PlayPz41:and       byte ptr ds:[Param],not 2 ; nen¡ prvn¡ volba
         call      MouseOff
         mov       ds:[PuzlAkt],al          ; aktivn¡ puzle (-1=nen¡)
         mov       word ptr ds:[MousSir],8
         mov       word ptr ds:[MousVys],8
         cmp       al,-1
         je        PlayPz42
         mov       word ptr ds:[MousSir],PSIRKA
         mov       word ptr ds:[MousVys],PVYSKA

PlayPz42:mov       ax,0a000h
         mov       es,ax
         xor       di,di
         mov       al,ds:[MouseCl3]         ; barva podkladu bufferu
         mov       ah,al
         mov       cx,MODX*MODY/2
         cld
         rep       stosw
         call      MouseOn

; ------ zobrazen¡ puzl¡ (s animac¡)

PlayPuz5:call      TestTime
         jz        PlayPuz8

         call      ReadFrm                  ; na‡ten¡ dal¨¡ho r mu
         xor       di,di                    ; ukl dac¡ adresa
         mov       si,offset PuzlMap        ; mapa puzl¡
         mov       dx,PRADKU                ; po‡et © dk– k zobrazen¡
PlayPuz6:push      di
         mov       cx,PPOZIC                ; po‡et pozic k zobrazen¡
PlayPuz7:cld
         lodsb
         call      DispPuz                  ; zobrazen¡ puzle
         add       di,PSIRKA
         loop      PlayPuz7
         pop       di
         add       di,PVYSKA*MODX
         dec       dx
         jnz       PlayPuz6
         call      MousePuz

; ------ obsluha my¨i

PlayPuz8:call      MousInt                  ; obsluha my¨i

; ------ prav˜m tla‡¡tkem p©eru¨en¡ nebo uvolnˆn¡ puzle

         test      byte ptr ds:[MouseKey],8 ; prav‚ tla‡¡tko my¨i ?
         jz        PlayPz82

         mov       al,ds:[PuzlAkt]
         cmp       al,-1                    ; je zvoleno puzle ?
         je        PlayPz81                 ; nen¡ zvoleno puzle

         mov       si,offset BuffMap - 1    ; buffer
PlayPz80:inc       si
         cmp       byte ptr ds:[si],-1
         jne       PlayPz80
         mov       ds:[si],al
         jmp       short PlayP861

PlayPz81:mov       di,offset BuffMap        ; mapa bufferu
         mov       al,ds:[di]               ; zvolen  polo‘ka
         push      ds
         pop       es
         mov       si,di
         inc       si
         cld
PlayP812:movsb                              ; zru¨en¡ puzle z bufferu
         cmp       di,offset BuffMap0
         jb        PlayP812

         push      ax
         jmp       PlayP892                 ; volba puzle

; ------ lev˜m tla‡¡tkem volba puzle

PlayPz82:test      byte ptr ds:[MouseKey],4 ; lev‚ tla‡¡tko my¨i ?
         jnz       PlayPz84                 ; je lev‚ tla‡¡tko

         mov       ah,1
         int       16h
         jnz       PlayPz83
         jmp       PlayPuz5

PlayPz83:mov       ah,0
         int       16h
         stc                                ; p©¡znak p©eru¨en¡
         ret

PlayPz84:mov       ax,ds:[MouseX]           ; sou©adnice my¨i X
         cmp       byte ptr ds:[PuzlAkt],-1 ; je zvoleno puzle ?
         je        PlayPz85                 ; nen¡ zvoleno puzle
         add       ax,PSIRKA/2              ; korekce
PlayPz85:xor       dx,dx
         mov       cx,PSIRKA                ; po‡et bod– na sloupec
         div       cx                       ; v˜po‡et sloupce
         add       ax,offset PuzlMap        ; mapa bufferu
         xchg      ax,di                    ; DI <- sloupec

         mov       ax,ds:[MouseY]           ; sou©adnice my¨i Y
         cmp       byte ptr ds:[PuzlAkt],-1 ; je zvoleno puzle ?
         je        PlayPz86                 ; nen¡ zvoleno puzle
         add       ax,PVYSKA/2              ; korekce
PlayPz86:xor       dx,dx
         mov       cx,PVYSKA                ; po‡et linek na © dek
         div       cx                       ; v˜po‡et © dku
         mov       ah,PPOZIC                ; po‡et pozic na © dek
         mul       ah                       ; p©epo‡et © dku na pozice
         add       di,ax                    ; p©i‡ten¡ sloupce

         mov       al,ds:[di]               ; zvolen  polo‘ka
         cmp       byte ptr ds:[PuzlAkt],-1 ; je zvoleno puzle ?
         je        PlayPz88                 ; nen¡ zvoleno puzle

         cmp       al,-1                    ; je pole povolen‚ ?
         jne       PlayPz87                 ; pole nen¡ povolen‚
         mov       al,ds:[PuzlAkt]
         mov       ds:[di],al               ; nov‚ pole
PlayP861:call      MouseOff
         mov       byte ptr ds:[PuzlAkt],-1 ; p©¡znak, ‘e nen¡ zvoleno puzle
         mov       word ptr ds:[MousSir],8
         mov       word ptr ds:[MousVys],8

         mov       cx,ds:[MouseX]
         add       cx,PSIRKA/2
         shl       cx,1
         mov       dx,ds:[MouseY]
         add       dx,PVYSKA/2
         mov       al,4
         call      Int33                    ; nastaven¡ pozice my¨i

         call      MouseOn

         mov       si,offset PuzlMap        ; mapa puzl¡
         xor       ax,ax                    ; ukazatel ‡¡sla puzle
         mov       cx,PCELKEM               ; po‡et puzl¡
PlayP862:cmp       al,ds:[si]
         jne       PlayPz87
         inc       ax
         inc       si
         loop      PlayP862
         clc                                ; p©¡znak operace OK
         ret

PlayPz87:jmp       PlayPuz5                 ; pokra‡ov n¡

PlayPz88:cmp       al,-1
         jne       PlayPz89
         jmp       PlayPuz4                 ; volba puzle

PlayPz89:mov       byte ptr ds:[di],-1      ; vyjmut¡ puzle z mapy

         push      ax

         call      MouseOff

         sub       di,offset PuzlMap
         xchg      ax,di                    ; AX <- ‡¡slo pozice
         mov       cl,PPOZIC
         div       cl                       ; v˜po‡et © dku a pozice puzle
         mov       cl,ah                    ; pozice puzle
         mov       ah,0
         mov       dx,PVYSKA*MODX           ; p©¡rustek adresy pro © dek
         mul       dx                       ; p©epo‡et © dku na adresu
         xchg      ax,di
         mov       al,PSIRKA                ; po‡et bajt– na linku
         mul       cl                       ; p©epo‡et pozice na offset
         add       di,ax                    ; adresa puzle
         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti
         mov       al,ds:[MouseCl3]         ; podklad
         mov       ah,al
         mov       dx,PVYSKA                ; v˜¨ka puzle
         cld
PlayP891:mov       cx,PSIRKA/2
         rep       stosw
         add       di,MODX-PSIRKA
         dec       dx
         jnz       PlayP891

PlayP892:mov       cx,ds:[MouseX]
         sub       cx,PSIRKA/2
         jnc       PlayP893
         xor       cx,cx
PlayP893:shl       cx,1
         mov       dx,ds:[MouseY]
         sub       dx,PVYSKA/2
         jnc       PlayP894
         xor       dx,dx
PlayP894:mov       al,4
         call      Int33                    ; nastaven¡ pozice my¨i

         pop       ax

PlayPz8A:call      MouseOff
         mov       ds:[PuzlAkt],al          ; aktivn¡ puzle (-1=nen¡)
         mov       word ptr ds:[MousSir],8
         mov       word ptr ds:[MousVys],8
         cmp       al,-1
         je        PlayPz8B
         mov       word ptr ds:[MousSir],PSIRKA
         mov       word ptr ds:[MousVys],PVYSKA

PlayPz8B:call      MouseOn                  ; zapnut¡ my¨i
         jmp       PlayPuz5

PlayPuz  ENDP

; -----------------------------------------------------------------------------
;        inicializace buffer– puzl¡
; -----------------------------------------------------------------------------

InitPuz  PROC      NEAR

; ------ inicializace ukazatel–

         mov       al,-1
         mov       ds:[PuzlAkt],al          ; nen¡ aktivn¡ puzle
         mov       word ptr ds:[MousSir],8
         mov       word ptr ds:[MousVys],8
         mov       di,offset PuzlMap        ; mapa polo‘en˜ch puzl¡
         push      ds
         pop       es
         mov       cx,PCELKEM               ; po‡et puzl¡
         cld
         rep       stosb                    ; vymaz n¡ mapy puzl¡

         mov       di,offset BuffMap        ; mapa bufferu puzl¡
         mov       cx,PCELKEM               ; po‡et puzl¡
InitPuz2:inc       ax                       ; zv˜¨en¡ ukazatele ‡¡sla
         stosb
         loop      InitPuz2                 ; inicializace bufferu puzl¡

; ------ zam¡ch n¡ bufferu puzl¡

         xor       ax,ax
         mov       es,ax                    ; ES <- 0
         mov       bx,es:[46ch]             ; ‡asova‡
         mov       cx,2000                  ; po‡et zam¡ch n¡
         mov       si,offset Start          ; data k zam¡ch n¡
InitPuz4:lodsb
         add       bx,ax
         add       bx,cx
         and       bx,3fh
         cmp       bl,PCELKEM
         jae       InitPuz6
         mov       al,ds:[bx+BuffMap]       ; m¡chan‚ puzle
         xchg      al,ds:[BuffMap]
         mov       ds:[bx+BuffMap],al
InitPuz6:loop      InitPuz4
         ret

InitPuz  ENDP

; -----------------------------------------------------------------------------
;        volba puzle z bufferu -> AL (-1=neplatn‚)
; -----------------------------------------------------------------------------

VolPuz   PROC      NEAR

; ------ zobrazen¡ podkladu bufferu

         call      MouseOff

         mov       byte ptr ds:[PuzlAkt],-1

         mov       ax,0a000h
         mov       es,ax
         xor       di,di
         mov       al,ds:[MouseCl3]         ; barva podkladu bufferu
         mov       ah,al
         mov       cx,MODX*MODY/2
         cld
         rep       stosw

         xor       di,di
         mov       al,ds:[MouseCl4]         ; barva r mu (‡erven )
         mov       ah,al
         mov       cl,MODX/2
         rep       stosw

         mov       cl,MODY-2
         dec       di
VolPuz2: stosw
         add       di,MODX-2
         loop      VolPuz2

         stosw
         dec       di
         mov       cl,MODX/2
         rep       stosw

         call      MouseOn

; ------ zobrazen¡ bufferu puzl¡ (s animac¡)

VolPuz4: call      TestTime
         jz        VolPuz7

         call      ReadFrm                  ; na‡ten¡ dal¨¡ho r mu
         mov       di,((MODY-BRADKU*PVYSKA)/BRADKU/2)*MODX + (MODX-BPOZIC*PSIRKA)/BPOZIC/2
         mov       si,offset BuffMap        ; mapa bufferu puzl¡
         mov       dx,BRADKU                ; po‡et © dk– k zobrazen¡
VolPuz5: push      di
         mov       cx,BPOZIC                ; po‡et pozic k zobrazen¡
VolPuz6: cld
         lodsb
         call      DispPuz                  ; zobrazen¡ puzle
         add       di,(MODX-BPOZIC*PSIRKA)/BPOZIC + PSIRKA
         loop      VolPuz6
         pop       di
         add       di,(MODY-BRADKU*PVYSKA)/BRADKU*MODX + PVYSKA*MODX
         dec       dx
         jnz       VolPuz5

; ------ obsluha my¨i

VolPuz7: call      MousInt                  ; obsluha my¨i

         test      byte ptr ds:[MouseKey],8 ; stisk prav‚ho tla‡¡tka ?
         jnz       VolPuz9                  ; p©eru¨en¡ prav˜m tla‡¡tkem

         test      byte ptr ds:[MouseKey],4 ; stisk lev‚ho tla‡¡tka ?
         jz        VolPuz8                  ; nen¡ stisk lev‚ho tla‡¡tka

         mov       ax,ds:[MouseX]           ; sou©adnice my¨i X
         xor       dx,dx
         mov       cx,MODX/BPOZIC           ; po‡et bod– na sloupec
         div       cx                       ; v˜po‡et sloupce
         add       ax,offset BuffMap        ; mapa bufferu
         xchg      ax,di                    ; BX <- sloupec

         mov       ax,ds:[MouseY]           ; sou©adnice my¨i Y
         xor       dx,dx
         mov       cx,MODY/BRADKU           ; po‡et linek na © dek
         div       cx                       ; v˜po‡et © dku
         mov       ah,BPOZIC                ; po‡et pozic na © dek
         mul       ah                       ; p©epo‡et © dku na pozice
         add       di,ax                    ; p©i‡ten¡ sloupce

         mov       al,ds:[di]               ; zvolen  polo‘ka
         push      ds
         pop       es
         mov       si,di
         inc       si
         cld
VolPuz72:movsb                              ; zru¨en¡ puzle z bufferu
         cmp       di,offset BuffMap0
         jb        VolPuz72
         ret

VolPuz8: mov       ah,1
         int       16h
         jz        VolPuz4

         mov       ah,0
         int       16h

VolPuz9: mov       al,-1
         ret

VolPuz   ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ puzle AL (-1=neplatn‚) na adresu DI
; -----------------------------------------------------------------------------

DispPuz  PROC      NEAR

         cmp       al,PCELKEM               ; je platn‚ puzle ?
         jb        DispPuz1                 ; je to platn‚ puzle
         ret

DispPuz1:push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      ds
         push      es

; ------ vypnut¡ kurzoru my¨i, je-li pot©eba

         push      ax

         mov       ax,di                    ; AX <- adresa ve videopamˆti
         xor       dx,dx
         mov       cx,MODX                  ; po‡et bod– na linku
         div       cx                       ; p©epo‡et na linku a pozici
         sub       ax,ds:[MousVys]          ; rezerva linky smˆrem nahoru
         sub       dx,ds:[MousSir]          ; rezerva pozice smˆrem vlevo

         cmp       dx,ds:[MouseX]
         jge       DispPuz2                 ; kurzor je p©ed obr zkem
         cmp       ax,ds:[MouseY]
         jge       DispPuz2                 ; kurzor je nad obr zkem

         add       ax,ds:[MousVys]          ; n vrat linky
         add       dx,ds:[MousSir]          ; n vrat pozice
         add       dx,PSIRKA                ; konec za obr zkem
         add       ax,PVYSKA                ; v˜¨ka za obr zkem

         cmp       dx,ds:[MouseX]
         jle       DispPuz2                 ; kurzor je za obr zkem
         cmp       ax,ds:[MouseY]
         jle       DispPuz2                 ; kurzor je pod obr zkem

         pop       ax
         push      ax
         cmp       al,ds:[PuzlAkt]          ; je to aktivn¡ puzle ?
         je        DispPuz2                 ; je to aktivn¡ puzle

         call      MouseOff                 ; vypnut¡ kurzoru my¨i

DispPuz2:pop       ax

         mov       ah,0
         mov       cl,PPOZIC
         div       cl                       ; v˜po‡et © dku a pozice puzle
         mov       cl,ah                    ; pozice puzle
         mov       ah,0
         mov       dx,PVYSKA*MODX           ; p©¡rustek adresy pro © dek
         mul       dx                       ; p©epo‡et © dku na adresu
         xchg      ax,si
         mov       al,PSIRKA                ; po‡et bajt– na linku
         mul       cl                       ; p©epo‡et pozice na offset
         add       si,ax                    ; adresa puzle

         mov       ax,0a000h
         mov       es,ax                    ; segment videopamˆti

         cld
         mov       al,ds:[MouseCl4]         ; barva r mu
         mov       ah,al

         mov       ds,ds:[SegmObr]          ; segment obr zku
         mov       cx,PSIRKA/2
         rep       stosw
         add       di,MODX-PSIRKA
         add       si,MODX

         mov       dx,PVYSKA-2              ; v˜¨ka puzle
DispPuz4:mov       cx,PSIRKA/2
         cmp       di,MODX*MODY
         jae       DispPuz5
         rep       movsw                    ; p©enos jednoho © dku
         dec       di
         stosb
         mov       es:[di-PSIRKA],al

         add       di,MODX-PSIRKA
         add       si,MODX-PSIRKA
         dec       dx
         jnz       DispPuz4

         mov       cx,PSIRKA/2
         rep       stosw

DispPuz5:pop       es
         pop       ds
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax

         cmp       al,ds:[PuzlAkt]          ; je to aktivn¡ puzle ?
         je        DispPuz9                 ; je to aktivn¡ puzle
         call      MouseOn                  ; zapnut¡ kurzoru my¨i
DispPuz9:ret

DispPuz  ENDP

; -----------------------------------------------------------------------------
;        inicializace standardn¡ch palet
; -----------------------------------------------------------------------------

InitPal  PROC      NEAR

         push      cs
         pop       es
         mov       di,offset Palety
         xor       bx,bx                    ; BH = zelen , BL = ‡erven 
         mov       al,0                     ; AL = modr 
         clc

InitPal1:xchg      ax,bx
         stosw                              ; ‡erven  a zelen 
         xchg      ax,bx
         stosb                              ; modr 

         add       bl,12                    ; ‡erven 
         cmp       bl,5*12
         jbe       InitPal1
         mov       bl,0

         add       bh,10                    ; zelen 
         cmp       bh,6*10
         jbe       InitPal1
         mov       bh,0

         add       al,12                    ; modr 
         cmp       al,5*12
         jbe       InitPal1
         mov       al,0

         mov       al,63
         mov       cx,4*3
         rep       stosb

         call      SetPal                   ; nastaven¡ palet
         ret

InitPal  ENDP

; -----------------------------------------------------------------------------
;        nastaven¡ palet v bufferu
; -----------------------------------------------------------------------------

SetPal   PROC      NEAR

         push      cs
         pop       es
         mov       dx,offset Palety         ; buffer palet
         mov       cx,256                   ; po‡et palet k nastaven¡
         xor       bx,bx                    ; ‡¡slo po‡ te‡n¡ palety
         mov       ax,1012h
         call      Int10                    ; nastaven¡ palet VGA

; ------ nalezen¡ barev

         xor       ax,ax                    ; AX = ‡erven 
         xor       bx,bx                    ; BX = zelen 
         xor       cx,cx                    ; CX = modr 
         call      SrcPal                   ; nalezen¡ barvy
         mov       ds:[MouseCl1],al         ; ‡ern  barva my¨i

         mov       ax,3fh                   ; AX = ‡erven 
         mov       bx,3fh                   ; BX = zelen 
         mov       cx,3fh                   ; CX = modr 
         call      SrcPal
         mov       ds:[MouseCl2],al         ; b¡l  barva my¨i

         mov       ax,1fh                   ; AX = ‡erven 
         mov       bx,1fh                   ; BX = zelen 
         mov       cx,1fh                   ; CX = modr 
         call      SrcPal
         mov       ds:[MouseCl3],al         ; ¨ed  barva

         mov       ax,3fh                   ; AX = ‡erven 
         xor       bx,bx                    ; BX = zelen 
         xor       cx,cx                    ; CX = modr 
         call      SrcPal                   ; nalezen¡ barvy
         mov       ds:[MouseCl4],al         ; ‡erven  barva (r m)
         ret

SetPal   ENDP

; -----------------------------------------------------------------------------
;        nalezen¡ barvy (AX=‡erven , BX=zelen , CX=modr ) -> AX
; -----------------------------------------------------------------------------
; lok ln¡ promˆnn‚: SS:[BP-2] (2) ‡erven 
;                   SS:[BP-4] (2) zelen 
;                   SS:[BP-6] (2) modr 
;                   SS:[BP-8] (2) ukazatel ‡¡sla barvy
;                   SS:[BP-10] (2) ‡¡slo nalezen‚ barvy
;                   SS:[BP-12] (2) vzd lenost nalezen‚ barvy
; -----------------------------------------------------------------------------

SrcPal   PROC      NEAR

; ------ £schova registr–

         push      bx
         push      dx
         push      si
         push      bp
         mov       bp,sp

; ------ p©¡prava lok ln¡ch promˆnn˜ch

         sub       sp,12
         mov       ss:[bp-2],ax             ; ‡erven 
         mov       ss:[bp-4],bx             ; zelen 
         mov       ss:[bp-6],cx             ; modr 
         xor       ax,ax                    ; AX <- 0
         mov       ss:[bp-8],ax             ; ukazatel ‡¡sla barvy
         mov       ss:[bp-10],ax            ; ‡¡slo nalezen‚ barvy
         dec       ax                       ; AX <- -1
         mov       ss:[bp-12],ax            ; vzd lenost nalezen‚ barvy

; ------ nalezen¡ barvy

         cld
         mov       si,offset Palety         ; buffer palet
SrcPal2: lodsb                              ; ‡erven 
         mov       ah,0
         sub       ax,ss:[bp-2]             ; vzd lenost od ‡erven‚
         imul      ax                       ; kvadr t vzd lenosti
         xchg      ax,bx                    ; BX <- vzd lenost ‡erven‚

         lodsb                              ; zelen 
         mov       ah,0
         sub       ax,ss:[bp-4]             ; vzd lenost od zelen‚
         imul      ax                       ; kvadr t vzd lenosti
         add       bx,ax                    ; p©id n¡ vzd lenosti ‡erven‚

         lodsb                              ; modr 
         mov       ah,0
         sub       ax,ss:[bp-6]             ; vzd lenost od modr‚
         imul      ax                       ; kvadr t vzd lenosti
         add       ax,bx                    ; celkov  vzd lenost

         cmp       ax,ss:[bp-12]            ; je men¨¡ vzd lenost ?
         jae       SrcPal4                  ; nen¡ men¨¡ vzd lenost
         mov       ss:[bp-12],ax            ; nov  vzd lenost
         mov       ax,ss:[bp-8]             ; ukazatel ‡¡sla barvy
         mov       ss:[bp-10],ax            ; ‡¡slo nalezen‚ barvy

SrcPal4: inc       word ptr ss:[bp-8]       ; zv˜¨en¡ ukazatele ‡¡sla barvy
         cmp       si,offset Palety0
         jb        SrcPal2

; ------ n vrat registr–

         mov       ax,ss:[bp-10]            ; ‡¡slo nalezen‚ barvy
         mov       sp,bp
         pop       bp
         pop       si
         pop       dx
         pop       bx
         ret

SrcPal   ENDP

; -----------------------------------------------------------------------------
;        funkce INT 10h
; -----------------------------------------------------------------------------

Int10    PROC      NEAR

         push      si
         push      di
         push      bp
         push      ds
         push      es

         int       10h

         pop       es
         pop       ds
         pop       bp
         pop       di
         pop       si
         ret

Int10    ENDP

; -----------------------------------------------------------------------------
;        otev©en¡ souboru (‡¡slo AX) -> CY=chyba
; -----------------------------------------------------------------------------

OpenFil  PROC      NEAR

; ------ p©enesen¡ jm‚na souboru

         mov       cx,ax
         mov       ch,0
         mov       al,MPOZIC                ; po‡et pozic na © dek
         mul       ah                       ; p©epo‡et © dku na pozici
         add       ax,cx                    ; p©i‡ten¡ pozice
         mov       cx,14                    ; d‚lka jm‚na souboru
         mul       cx                       ; p©epo‡et na offset v seznamu
         add       ax,offset SoubSezn       ; adresa v seznamu
         xchg      ax,si
         mov       di,ds:[SoubAdr]          ; adresa jm‚na souboru
         push      ds
         pop       es
         rep       movsb                    ; p©enesen¡ jm‚na souboru

; ------ otev©en¡ souboru

         mov       dx,offset SoubBuff       ; jm‚no souboru
         mov       ax,3d00h
         int       21h                      ; otev©en¡ souboru
         jc        OpenFil9                 ; chyba
         mov       ds:[SoubIdnt],ax         ; identifik tor souboru

; ------ na‡ten¡ z hlav¡ souboru

         xchg      ax,bx                    ; BX <- identifik tor souboru
         mov       dx,offset FliZahl        ; buffer z hlav¡ souboru
         mov       cx,offset(FliZahl0-FliZahl) ; velikost z hlav¡ souboru
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ souboru
         jc        OpenFil9                 ; chyba

; ------ inicializace z hlav¡ souboru

         cmp       word ptr ds:[FliFramN],1 ; je nˆjak˜ r m ?
         jb        OpenFil9                 ; nen¡ ‘ dn˜ r m
         cmp       word ptr ds:[FliX],1
         jb        OpenFil9
         cmp       word ptr ds:[FliY],1
         jb        OpenFil9
         mov       word ptr ds:[CitFram],0  ; nen¡ dal¨¡ r m
                                          ;* zde je NC=OK
OpenFil9:ret

OpenFil  ENDP

; -----------------------------------------------------------------------------
;        uzav©en¡ souboru
; -----------------------------------------------------------------------------

ClosFil  PROC      NEAR

         xor       bx,bx                    ; BX <- 0 p©¡znak uzav©en¡ souboru
         xchg      bx,ds:[SoubIdnt]         ; identifik tor souboru
         or        bx,bx                    ; je soubor otev©en ?
         jz        ClosFil9                 ; nen¡ otev©en
         mov       ah,3eh
         int       21h                      ; uzav©en¡ souboru
ClosFil9:ret

ClosFil  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ obr zku menu
; -----------------------------------------------------------------------------
;þ
DispFil  PROC      NEAR

         push      di
         call      ReadFrm                  ; na‡ten¡ jednoho r mu do bufferu

         cld
         push      ds
         pop       es
         mov       si,offset Palety         ; buffer palet
         mov       di,ds:[KonvAPal]         ; aktu ln¡ tabulka palet
         cmp       byte ptr ds:[di],-1      ; je inicializov no ?
         jne       DispFl12                 ; je ji‘ inicializov no
         mov       cx,256
DispFil1:mov       al,6*(256/64)            ; po‡et £rovn¡ ‡erven‚
         mul       byte ptr ds:[si]         ; p©epo‡et ‡erven‚ na 0 a‘ 5
         mov       bl,ah                    ; ‡erven  slo‘ka

         mov       al,7*(256/64)            ; po‡et £rovn¡ zelen‚
         mul       byte ptr ds:[si+1]       ; p©epo‡et zelen‚ na 0 a‘ 6
         mov       bh,ah                    ; zelen  slo‘ka

         mov       al,6*(256/64)            ; po‡et £rovn¡ modr‚
         mul       byte ptr ds:[si+2]       ; p©epo‡et modr‚ na 0 a‘ 5

         mov       al,7                     ; po‡et £rovn¡ zelen‚
         mul       ah                       ; posun modr‚ nad zelenou
         add       al,bh                    ; p©i‡ten¡ zelen‚ slo‘ky
         mov       ah,6                     ; po‡et £rovn¡ ‡erven‚
         mul       ah                       ; posun modr‚ a zelen‚ nad ‡ervenou
         add       al,bl                    ; p©id n¡ ‡erven‚ slo‘ky
         stosb                              ; ulo‘en¡ indexu barvy

         add       si,3
         loop      DispFil1

DispFl12:pop       di

; ------ vypnut¡ kurzoru my¨i, je-li pot©eba

         mov       ax,di                    ; AX <- adresa ve videopamˆti
         xor       dx,dx
         mov       cx,MODX                  ; po‡et bod– na linku
         div       cx                       ; p©epo‡et na linku a pozici
         sub       ax,8                     ; rezerva linky smˆrem nahoru
         sub       dx,8                     ; rezerva pozice smˆrem vlevo

         cmp       dx,ds:[MouseX]
         jg        DispFl18                 ; kurzor je p©ed obr zkem
         cmp       ax,ds:[MouseY]
         jg        DispFl18                 ; kurzor je nad obr zkem

         add       dx,MSIRKA+8              ; konec za obr zkem
         add       ax,MVYSKA+8              ; v˜¨ka za obr zkem

         cmp       dx,ds:[MouseX]
         jl        DispFl18                 ; kurzor je za obr zkem
         cmp       ax,ds:[MouseY]
         jl        DispFl18                 ; kurzor je pod obr zkem

         call      MouseOff                 ; vypnut¡ kurzoru my¨i

; ------ zobrazen¡ obr zku

DispFl18:cld
         push      ds
         mov       bx,cs:[KonvAPal]         ; konverzn¡ tabulka
         mov       ax,0a000h
         mov       es,ax
         mov       ds,ds:[SegmObr]          ; segm
         xor       si,si

         mov       dx,MVYSKA                ; po‡et zobrazen˜ch linek
DispFil2:mov       cx,MSIRKA                ; po‡et zobrazen˜ch bod–

         push      si
         push      di
DispFil4:lodsb
         xlat cs:[bx]
         stosb

         add       si,MPOZIC-1
         loop      DispFil4
         pop       di
         pop       si
         add       si,MRADKU*MODX           ; dal¨¡ © dek
         add       di,MODX                  ; dal¨¡ © dek

         dec       dx
         jnz       DispFil2

         pop       ds

; ------ zapnut¡ kurzoru my¨i

         call      MouseOn                  ; zapnut¡ kurzoru my¨i
         ret

DispFil  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ jednoho obr zku do bufferu
; -----------------------------------------------------------------------------

ReadFrm  PROC      NEAR

; ------ zaji¨tˆn¡, aby byl dal¨¡ r m

         cmp       word ptr ds:[CitFram],0  ; je dal¨¡ r m ?
         jne       ReadFrm1                 ; je dal¨¡ r m OK
         mov       ax,ds:[FliFramN]         ; po‡et r m– celkem
         mov       ds:[CitFram],ax          ; nov˜ ‡¡ta‡ r m–
         mov       word ptr ds:[NextFram],128 ; ukazatel za z hlav¡ souboru
         mov       word ptr ds:[NextFram+2],0

; ------ nastaven¡ ukazatele v souboru

ReadFrm1:mov       ax,4200h
         mov       cx,word ptr ds:[NextFram+2] ; offset ukazatele HIGH
         mov       dx,word ptr ds:[NextFram] ; offset ukazatele LOW
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         int       21h                      ; nastaven¡ ukazatele v souboru

; ------ p©¡prava ukazatele chunk–

         add       ax,offset(FramZhl0-FramZahl) ; posun o z hlav¡ r mu
         adc       dx,0
         mov       word ptr ds:[NextChnk],ax ; ukazatel chunk–
         mov       word ptr ds:[NextChnk+2],dx

; ------ na‡ten¡ z hlav¡ r mu

         mov       dx,offset FramZahl       ; z hlav¡ jednoho r mu
         mov       cx,offset(FramZhl0-FramZahl) ; d‚lka z hlav¡ r mu
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ r mu

; ------ posun ukazatele r mu

         dec       word ptr ds:[CitFram]    ; ‡¡ta‡ r m–
         mov       ax,word ptr ds:[FramDelk] ; d‚lka r mu LOW
         add       word ptr ds:[NextFram],ax ; posun ukazatele r mu
         mov       ax,word ptr ds:[FramDelk+2] ; d‚lka r mu HIGH
         adc       word ptr ds:[NextFram+2],ax

; ------ test, zda bude dal¨¡ chunk

ReadFrm2:cmp       word ptr ds:[FramChnk],0 ; bude dal¨¡ chunk ?
         jne       ReadFrm3                 ; bude dal¨¡ chunk
         ret

; ------ nastaven¡ ukazatele v souboru

ReadFrm3:mov       ax,4200h
         mov       cx,word ptr ds:[NextChnk+2] ; offset ukazatele HIGH
         mov       dx,word ptr ds:[NextChnk] ; offset ukazatele LOW
         mov       bx,ds:[SoubIdnt]         ; identifik tor souboru
         int       21h                      ; nastaven¡ ukazatele v souboru

; ------ na‡ten¡ z hlav¡ chunku

         mov       dx,offset ChnkZahl       ; z hlav¡ jednoho chunku
         mov       cx,offset(ChnkZhl0-ChnkZahl) ; d‚lka z hlav¡ chunku
         mov       ah,3fh
         int       21h                      ; na‡ten¡ z hlav¡ chunku

; ------ posun ukazatele chunku

         dec       word ptr ds:[FramChnk]    ; ‡¡ta‡ chunk–
         mov       ax,word ptr ds:[ChnkDelk] ; d‚lka chunku LOW
         add       word ptr ds:[NextChnk],ax ; posun ukazatele chunku
         mov       ax,word ptr ds:[ChnkDelk+2] ; d‚lka chunku HIGH
         adc       word ptr ds:[NextChnk+2],ax

; ------ na‡ten¡ dat jednoho chunku do bufferu

         push      ds
         mov       cx,word ptr ds:[ChnkDelk] ; d‚lka chunku
         cmp       word ptr ds:[ChnkDelk+2],0
         je        ReadFrm4
         mov       cx,-1                    ; omezen¡ d‚lky dat
ReadFrm4:sub       cx,offset(ChnkZhl0-ChnkZahl) ; ode‡ten¡ z hlav¡
         mov       ds,ds:[SegmBuf]          ; segment bufferu
         xor       dx,dx
         mov       ah,3fh                   ; na‡ten¡ dat chunku
         int       21h                      ; na‡ten¡ dat
         pop       ds

; ------ na‡ten¡ palet

         cmp       word ptr ds:[ChnkIdnt],4 ; palety 256 £rovn¡ ?
         je        ReadFrm5                 ; palety 256 £rovn¡
         cmp       word ptr ds:[ChnkIdnt],11 ; palety 64 £rovn¡ ?
         jne       ReadFrm6
ReadFrm5:call      ReadPal                  ; na‡ten¡ palet
;þ
; ------ bajtov  delta-komprese

ReadFrm6:cmp       word ptr ds:[ChnkIdnt],12 ; bajtov  delta-komprese ?
         jne       ReadFrm7
         call      ReadDelt                 ; na‡ten¡ delta-komprese

; ------ bajtov  length-komprese

ReadFrm7:cmp       word ptr ds:[ChnkIdnt],15 ; bajtov  length-komprese ?
         jne       ReadFrm8
         call      ReadLen                  ; na‡ten¡ length-komprese

; ------ nekomprimovan  data

ReadFrm8:cmp       word ptr ds:[ChnkIdnt],16 ; nekomprimovan  data ?
         jne       ReadFrm9
;         call      ReadCop                  ; na‡ten¡ nekomprimovan˜ch dat

; ------ dal¨¡ chunk

ReadFrm9:jmp       ReadFrm2                 ; dal¨¡ chunk

ReadFrm  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ palet
; -----------------------------------------------------------------------------

ReadPal  PROC      NEAR

         push      ds

         mov       cl,0                     ; pro 64 hladin nejsou rotace
         cmp       word ptr ds:[ChnkIdnt],11 ; jsou palety 64 £rovn¡ ?
         je        ReadPal1                 ; jsou palety 64 £rovn¡
         mov       cl,2                     ; po‡et rotac¡ pro 256 hladin

ReadPal1:push      cs
         pop       es
         mov       ds,ds:[SegmBuf]          ; segment bufferu
         xor       si,si                    ; ukazatel ‡ten˜ch dat
         mov       di,offset Palety         ; buffer palet
         lodsw                              ; po‡et paket–
         xchg      ax,bp                    ; BP <- po‡et paket–
         or        bp,bp                    ; je nˆjak˜ paket ?
         jz        ReadPal8                 ; nen¡ paket

ReadPal2:lodsb                              ; po‡et p©esko‡en˜ch barev
         mov       ah,0
         add       di,ax                    ; p©esko‡en¡ barev
         add       di,ax
         add       di,ax

         lodsb                              ; po‡et barev
         or        ax,ax                    ; je 256 barev ?
         jnz       ReadPal3
         mov       ah,1                     ; je 256 barev
ReadPal3:xchg      ax,dx                    ; DX <- ‡¡ta‡ barev
ReadPal4:cmp       di,offset Palety0
         jae       ReadPal6

         push      si
         lodsb
         shr       al,cl
         stosb

         lodsb
         shr       al,cl
         stosb

         lodsb
         shr       al,cl
         stosb

         pop       si

ReadPal6:add       si,3
         dec       dx
         jnz       ReadPal4

         dec       bp                       ; ‡¡ta‡ paket–
         jnz       ReadPal2

ReadPal8:pop       ds
         test      byte ptr ds:[Param],1    ; je re‘im menu ?
         jnz       ReadPal9                 ; je re‘im menu
         call      SetPal                   ; nastaven¡ palet
ReadPal9:ret

ReadPal  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ length-komprese
; -----------------------------------------------------------------------------

ReadLen  PROC      NEAR

; ------ p©¡prava ‡¡ta‡e linek -> BP

         mov       bp,ds:[FliY]             ; v˜¨ka obr zku
         cmp       bp,MODY
         jbe       ReadLen1
         mov       bp,MODY                  ; omezen¡ po‡tu linek

; ------ p©¡prava registr–

ReadLen1:push      ds
         mov       es,ds:[SegmObr]          ; segment obr zku
         mov       ds,ds:[SegmBuf]          ; segment bufferu
         xor       si,si                    ; ukazatel ‡ten˜ch dat
         xor       di,di                    ; ukazatel ukl dan˜ch dat
         cld

; ------ p©¡prava pro jednu linku

ReadLen2:lodsb                              ; po‡et paket– linky
         mov       ah,0
         or        ax,ax                    ; je nˆjak˜ paket ?
         jz        ReadLen6                 ; nen¡ ‘ dn˜ paket
         xchg      ax,dx                    ; DX <- po‡et paket– linky
         push      di

; ------ dek¢dov n¡ jednoho paketu

ReadLen3:lodsb                              ; po‡et bajt– k dek¢dov n¡
         mov       ah,0
         or        al,al                    ; jsou nˆjak  data ?
         jz        ReadLen5                 ; nejsou ‘ dn  data
         js        ReadLen4                 ; budou se p©en ¨et data
         xchg      ax,cx                    ; CX <- po‡et bajt–
         lodsb                              ; bajt k ulo‘en¡
         rep       stosb                    ; ulo‘en¡ bajtu
         jmp       short ReadLen5

ReadLen4:neg       al                       ; oprava znam‚nka
         xchg      ax,cx                    ; CX <- po‡et bajt–
         rep       movsb                    ; p©enesen¡ dat

ReadLen5:dec       dx                       ; ‡¡ta‡ paket–
         jnz       ReadLen3                 ; dal¨¡ paket

; ------ p©¡prava pro dal¨¡ linku

         pop       di
ReadLen6:add       di,MODX                  ; adresa dal¨¡ linky
         dec       bp                       ; ‡¡ta‡ linek
         jnz       ReadLen2                 ; dal¨¡ linka

         pop       ds
         ret

ReadLen  ENDP

; -----------------------------------------------------------------------------
;        na‡ten¡ delta-komprese
; -----------------------------------------------------------------------------

ReadDelt PROC      NEAR

; ------ p©¡prava registr–

         push      ds
         mov       es,ds:[SegmObr]          ; segment obr zku
         mov       ds,ds:[SegmBuf]          ; segment bufferu
         xor       si,si                    ; ukazatel ‡ten˜ch dat
         cld

; ------ p©esko‡en‚ linky

         lodsw                              ; po‡et p©esko‡en˜ch linek
         mov       dx,MODX                  ; ¨¡©ka linky displeje
         mul       dx
         xchg      ax,di                    ; DI <- ukl dac¡ adresa

; ------ ‡¡ta‡ linek

         lodsw                              ; po‡et modifikovan˜ch linek
         or        ax,ax                    ; jsou linky ?
         jz        ReadDel9                 ; nejsou linky
         xchg      ax,bp                    ; BP <- ‡¡ta‡ linek

; ------ p©¡prava pro jednu linku

ReadDel2:lodsb                              ; po‡et paket– linky
         mov       ah,0
         or        ax,ax                    ; je nˆjak˜ paket ?
         jz        ReadDel6                 ; nen¡ ‘ dn˜ paket
         xchg      ax,dx                    ; DX <- po‡et paket– linky
         push      di

; ------ dek¢dov n¡ jednoho paketu

ReadDel3:lodsb                              ; po‡et p©esko‡en˜ch bod–
         mov       ah,0
         add       di,ax                    ; posun ukl dac¡ adresy

         lodsb                              ; po‡et bajt– k dek¢dov n¡
         or        al,al                    ; jsou nˆjak  data ?
         jns       ReadDel4                 ; budou se p©en ¨et data
         neg       al                       ; oprava znam‚nka
         xchg      ax,cx                    ; CX <- po‡et bajt–
         lodsb                              ; bajt k ulo‘en¡
         rep       stosb                    ; ulo‘en¡ bajtu
         jmp       short ReadDel5

ReadDel4:xchg      ax,cx                    ; CX <- po‡et bajt–
         rep       movsb                    ; p©enesen¡ dat

ReadDel5:dec       dx                       ; ‡¡ta‡ paket–
         jnz       ReadDel3                 ; dal¨¡ paket

; ------ p©¡prava pro dal¨¡ linku

         pop       di
ReadDel6:add       di,MODX                  ; adresa dal¨¡ linky
         dec       bp                       ; ‡¡ta‡ linek
         jnz       ReadDel2                 ; dal¨¡ linka

ReadDel9:pop       ds
         ret

ReadDelt ENDP

; -----------------------------------------------------------------------------
;        test, zda je zmˆna ‡asu -> ZY=nen¡ zmˆna
; -----------------------------------------------------------------------------

TestTime PROC      NEAR

         sti
         push      ax
         push      ds
         xor       ax,ax
         mov       ds,ax
         mov       ax,ds:[46ch]             ; aktu ln¡ ‡asova‡
         pop       ds
         xchg      ax,ds:[OldTime]          ; £schova ‡asova‡e
         cmp       ax,ds:[OldTime]          ; je zmˆna ‡asu ?
         pop       ax
         ret

TestTime ENDP

; -----------------------------------------------------------------------------
;        inicializace my¨i
; -----------------------------------------------------------------------------

InitMous PROC      NEAR

         call      MouseOff                 ; vypnut¡ kurzoru my¨i

; ------ inicializace my¨i

         and       byte ptr ds:[Param],not 80h ; p©¡znak, ‘e nen¡ my¨
         mov       al,0
         call      Int33                    ; inicializace my¨i
         inc       ax                       ; je my¨ ?
         jnz       InitMou9                 ; nen¡ my¨
         or        byte ptr ds:[Param],80h  ; p©¡znak, ‘e je my¨

; ------ horizont ln¡ rozmˆr

         xor       cx,cx                    ; minim ln¡ sloupec
         mov       dx,2*(MODX-8)            ; maxim ln¡ rozmˆr
         mov       al,7
         call      Int33                    ; horizont ln¡ rozmˆr

; ------ vertik ln¡ rozmˆr

         xor       cx,cx                    ; minim ln¡ linka
         mov       dx,MODY-8                ; maxim ln¡ linka
         mov       al,8
         call      Int33                    ; vertik ln¡ rozmˆr

; ------ nastaven¡ pozice my¨i

         mov       cx,ds:[MouseX]
         shl       cx,1
         mov       dx,ds:[MouseY]
         mov       al,4
         call      Int33                    ; nastaven¡ pozice my¨i

; ------ definice kurzoru my¨i

         xor       bx,bx                    ; sloupec bodu my¨i
         xor       cx,cx                    ; linka bodu my¨i
         push      ds
         pop       es
         mov       dx,offset KurzMap        ; mapa kurzoru my¨i
         mov       al,9
         call      Int33                    ; definice kurzoru my¨i

; ------ vypnut¡ kurzoru my¨i

         mov       al,2
         call      Int33                    ; vypnut¡ kurzoru my¨i

; ------ zapnut¡ kurzoru my¨i

         call      MouseOn                  ; zapnut¡ kurzoru my¨i
InitMou9:ret

InitMous ENDP

; -----------------------------------------------------------------------------
;        p©eru¨en¡ od my¨i
; -----------------------------------------------------------------------------

MousInt  PROC      NEAR

; ------ test, zda je my¨ instalov na

         and       byte ptr ds:[MouseKey],40h + 3 ; nulov n¡ p©¡znak–
         test      byte ptr ds:[Param],80h  ; je my¨ nainstalov na ?
         jnz       MousInt1
         ret                                ; my¨ nen¡ nainstalov na

; ------ £schova registr–

MousInt1:push      ax
         push      bx
         push      cx
         push      dx

; ------ na‡ten¡ stavu my¨i

         mov       al,3
         call      Int33                    ; na‡ten¡ stavu my¨i
         shr       cx,1                     ; oprava sloupce

         mov       ax,MODX
         sub       ax,ds:[MousSir]
         cmp       cx,ax
         jbe       MousInt2
         mov       cx,ax

MousInt2:mov       ax,MODY
         sub       ax,ds:[MousVys]
         cmp       dx,ax
         jbe       MousInt4
         mov       dx,ax

MousInt4:cmp       cx,ds:[MouseX]           ; je zmˆna sloupce ?
         jne       MousInt5                 ; nen¡ zmˆna sloupce
         cmp       dx,ds:[MouseY]           ; je zmˆna © dku ?
         je        MousInt6                 ; nen¡ zmˆna © dku

; ------ posun kurzoru my¨i

MousInt5:test      byte ptr ds:[Param],40h  ; je kurzor my¨i zapnut ?
         jnz       MousIn52                 ; kurzor je zapnut
         mov       ds:[MouseX],cx           ; nov˜ sloupec
         mov       ds:[MouseY],dx           ; nov˜ © dek
         or        byte ptr ds:[MouseKey],80h ; p©¡znak posunu my¨i
         jmp       short MousInt6

MousIn52:call      MouseOff                 ; vypnut¡ kurzoru my¨i
         mov       ds:[MouseX],cx           ; nov˜ sloupec
         mov       ds:[MouseY],dx           ; nov˜ © dek
         or        byte ptr ds:[MouseKey],80h ; p©¡znak posunu my¨i
         call      MouseOn                  ; zapnut¡ kurzoru my¨i

; ------ £schova stavu tla‡¡tek

MousInt6:and       bl,3
         mov       al,ds:[MouseKey]
         and       al,3
         and       byte ptr ds:[MouseKey],not 3
         or        ds:[MouseKey],bl         ; nov˜ stav tla‡¡tek

; ------ stisk tla‡¡tek

         xor       al,bl                    ; p©¡znak zmˆn tla‡¡tek
         mov       ah,al                    ; p©¡znak zmˆn tla‡¡tek
         and       ah,bl                    ; stisknut  tla‡¡tka
         shl       ah,1
         shl       ah,1
         or        ds:[MouseKey],ah         ; stisknut  tla‡¡tka

; ------ uvolnˆn¡ tla‡¡tek

         not       bl
         and       al,bl                    ; uvolnˆn  tla‡¡tka
         shl       al,1
         shl       al,1
         shl       al,1
         shl       al,1
         or        ds:[MouseKey],al         ; uvolnˆn  tla‡¡tka

; ------ n vrat registr–

         pop       dx
         pop       cx
         pop       bx
         pop       ax
MousInt9:ret

MousInt  ENDP

; -----------------------------------------------------------------------------
;        zapnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOn0:ret


MouseOn  PROC      NEAR

; ------ test, zda je my¨ instalov na

         test      byte ptr ds:[Param],80h  ; je my¨ nainstalov na ?
         jz        MouseOn0                 ; my¨ nen¡ nainstalov na

; ------ test, zda je kurzor my¨i ji‘ zapnut

         test      byte ptr ds:[Param],40h  ; je kurzor my¨i ji‘ zapnut ?
         jnz       MouseOn0                 ; kurzor my¨i je ji‘ zapnut

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      bp
         push      es

; ------ adresa ve videopamˆti -> SI

         mov       ax,MODX                  ; po‡et bajt– na linku
         mul       word ptr ds:[MouseY]     ; p©epo‡et linky na adresu
         add       ax,ds:[MouseX]           ; p©i‡ten¡ sou©adni‡e X
         xchg      ax,si                    ; SI <- adresa ve videopamˆti

; ------ £schova podkladu pod my¨¡

         cld
         push      si
         push      ds
         push      ds
         pop       es
         mov       ax,0a000h
         mov       ds,ax                    ; DS <- segment videopamˆti
         mov       di,offset KurzBuf        ; buffer kurzoru my¨i
         mov       bx,cs:[MousVys]          ; v˜¨ka kurzoru my¨i
MouseOn1:mov       cx,cs:[MousSir]          ; ¨¡©ka kurzoru my¨i
         shr       cx,1
         cmp       si,MODX*MODY
         jae       MouseO12
         push      si
         rep       movsw
         pop       si
MouseO12:add       si,MODX
         dec       bx
         jnz       MouseOn1
         mov       es,ax                    ; ES <- segment videopamˆti
         pop       ds
         pop       di

; ------ nastaven¡ obr zku my¨i

         cmp       byte ptr ds:[PuzlAkt],-1
         jne       MouseOn7

         mov       si,offset KurzMap        ; mapa kurzoru my¨i
         mov       bx,8                     ; v˜¨ka kurzoru my¨i
MouseOn2:lodsw                              ; znak masky
         xchg      ax,dx                    ; DX <- maska
         mov       bp,ds:[si+32-2]          ; BP <- barva
         mov       cx,8                     ; po‡et bajt– na linku
MouseOn3:mov       al,ds:[MouseCl1]         ; ‡ern  barva
         shl       bp,1                     ; je ‡ern  barva ?
         jnc       MouseOn4                 ; je ‡ern  barva
         mov       al,ds:[MouseCl2]         ; b¡l  barva
MouseOn4:shl       dx,1                     ; je bod mˆnˆn ?
         jc        MouseOn6                 ; bod nen¡ mˆnˆn
         stosb                              ; ulo‘en¡ bajtu
         dec       di
MouseOn6:inc       di
         loop      MouseOn3
         add       di,MODX-8
         dec       bx
         jnz       MouseOn2
         jmp       short MouseOn8

MouseOn7:call      MousePuz

; ------ n vrat registr–

MouseOn8:pop       es
         pop       bp
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         or        byte ptr ds:[Param],40h  ; p©¡znak zapnut¡ kurzoru my¨i
MouseOn9:ret

MouseOn  ENDP

; -----------------------------------------------------------------------------
;        zobrazen¡ my¨i, je-li zvoleno puzle
; -----------------------------------------------------------------------------

MousePuz PROC      NEAR

         push      ax
         push      dx
         push      di

         mov       ax,MODX                  ; po‡et bajt– na linku
         mul       word ptr ds:[MouseY]     ; p©epo‡et linky na adresu
         add       ax,ds:[MouseX]           ; p©i‡ten¡ sou©adni‡e X
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       al,ds:[PuzlAkt]
         cmp       al,-1
         je        MousePz9
         call      DispPuz

MousePz9:pop       di
         pop       dx
         pop       ax
         ret

MousePuz ENDP

; -----------------------------------------------------------------------------
;        vypnut¡ kurzoru my¨i
; -----------------------------------------------------------------------------

MouseOff PROC      NEAR

; ------ test, zda je my¨ instalov na

         test      byte ptr ds:[Param],80h  ; je my¨ nainstalov na ?
         jz        MouseOf9                 ; my¨ nen¡ nainstalov na

; ------ test, zda je kurzor my¨i zapnut

         test      byte ptr ds:[Param],40h  ; je kurzor my¨ zapnut ?
         jz        MouseOf9                 ; kurzor my¨i je ji‘ vypnut

; ------ £schova registr–

         push      ax
         push      bx
         push      cx
         push      dx
         push      si
         push      di
         push      es

; ------ adresa ve videopamˆti -> ES:DI

         mov       ax,MODX                  ; po‡et bajt– na linku
         mul       word ptr ds:[MouseY]     ; p©epo‡et linky na adresu
         add       ax,ds:[MouseX]           ; p©i‡ten¡ sou©adni‡e X
         xchg      ax,di                    ; DI <- adresa ve videopamˆti
         mov       ax,0a000h
         mov       es,ax                    ; ES <- segment videopamˆti

; ------ n vrat podkladu pod my¨¡

         cld
         mov       si,offset KurzBuf        ; buffer kurzoru my¨i
         mov       bx,ds:[MousVys]          ; v˜¨ka kurzoru my¨i
MouseOf2:cmp       di,MODX*MODY
         jae       MouseOf4
         mov       cx,ds:[MousSir]
         shr       cx,1
         push      di
         rep       movsw
         pop       di
         add       di,MODX
         dec       bx
         jnz       MouseOf2

; ------ n vrat registr–

MouseOf4:pop       es
         pop       di
         pop       si
         pop       dx
         pop       cx
         pop       bx
         pop       ax
         and       byte ptr ds:[Param],not 40h ; kurzor my¨i vypnut
MouseOf9:ret

MouseOff ENDP

; -----------------------------------------------------------------------------
;        obsluha my¨i INT 33h (funkce AL)
; -----------------------------------------------------------------------------

Int33    PROC      NEAR

         push      si
         push      di
         push      bp
         push      es
         push      ds

         mov       ah,0
         int       33h

         pop       ds
         pop       es
         pop       bp
         pop       di
         pop       si
         ret

Int33    ENDP

; -----------------------------------------------------------------------------
;                                Data
; -----------------------------------------------------------------------------
;þ
Param    db        0                        ; parametry
                                            ;    bit 0: 1=je re‘im menu
                                            ;    bit 1: 1=je £vodn¡ volba puzle
                                            ;    bit 6: 1=kurzor my¨i zapnut
                                            ;    bit 7: 1=je my¨

NoTxt    db        'Nenalezen zadny soubor FLI !',13,10,'$'
ErrTxt   db        'Lituji, program vyzaduje grafickou kartu VGA !',13,10,'$'
ErrMem   db        'Nedostatek pameti je spusteni programu !',13,10,'$'
UvTxt    db        'PUZFLI V0.4 - animovana puzle; (c) Ing. Miroslav Nemecek 1996',13,10
         db        'Tento program je FREEWARE a muze byt volne siren bez omezeni.',13,10,'$'

SegmObr  dw        0                        ; segment obr zku
SegmBuf  dw        0                        ; segment bufferu
SegmUsch dw        0                        ; segment £schovy obr zk–

OldTime  dw        0                        ; uschovan˜ ‡asova‡

; ------ definice puzl¡

PuzlAkt  db        -1                       ; ‡¡slo aktivn¡ho puzle (-1=nen¡)
PuzlMap  db        PCELKEM dup(-1)          ; mapa polo‘en˜ch puzl¡ (-1=nic)
BuffMap  db        PCELKEM dup(-1)          ; mapa bufferu puzl¡ (-1=nic)
BuffMap0 db        -1                       ; ukon‡ovac¡ bajt mapy bufferu

; ------ obr zek my¨i

MouseX   dw        MODX/2                   ; pozice my¨i X
MouseY   dw        MODY/2                   ; pozice my¨i Y
MouseKey db        0                        ; tla‡¡tka my¨i
                                            ;   bit 0: 1=je lev‚ tla‡¡tko
                                            ;   bit 1: 1=je prav‚ tla‡¡tko
                                            ;   bit 2: 1=stisk lev‚ho tla‡¡tka
                                            ;   bit 3: 1=stisk prav‚ho tla‡¡tka
                                            ;   bit 4: 1=uvolnˆn¡ lev‚ho tla‡¡tka
                                            ;   bit 5: 1=uvolnˆn¡ prav‚ho tla‡¡tka
                                            ;   bit 7: 1=je posun my¨i

MouseCl1 db        0                        ; ‡ern  barva kurzoru my¨i
MouseCl2 db        0ffh                     ; b¡l  barva kurzoru my¨i
MouseCl3 db        7                        ; ¨ed  barva podkladu
MouseCl4 db        4                        ; ‡erven  barva (r m bufferu)

; ------ ¨¡©ka a v˜¨ka kurzoru (mus¡ b˜t sud  !)

MousSir  dw        8                        ; aktu ln¡ ¨¡©ka kurzoru my¨i
MousVys  dw        8                        ; aktu ln¡ v˜¨ka kurzoru my¨i
KurzBuf  db        PSIRKA*PVYSKA dup(0)     ; buffer k £schovˆ my¨i

KurzMap  label     byte                     ; mapa kurzoru my¨i (8 * 8 bod–)
         dw        0000011111111111b
         dw        0000011111111111b
         dw        0000111111111111b
         dw        0000011111111111b
         dw        0010001111111111b
         dw        1111000111111111b
         dw        1111100011111111b
         dw        1111110111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b
         dw        1111111111111111b

         dw        0000000000000000b
         dw        0111000000000000b
         dw        0110000000000000b
         dw        0101000000000000b
         dw        0000100000000000b
         dw        0000010000000000b
         dw        0000001000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b
         dw        0000000000000000b

; ------ obsluha soubor–

SoubIdnt dw        0                        ; identifik tor souboru (0=nen¡)
SoubSrc  db        '*.FLI',0                ; specifikace hledan˜ch soubor–
SoubAdr  dw        SoubBuff                 ; adresa jm‚na souboru v bufferu
SoubBuff db        128 dup(0)               ; buffer jm‚na souboru
DTA      db        44 dup(0)                ; buffer DTA
SoubNum  dw        0                        ; po‡et nalezen˜ch soubor–
SoubSezn db        MCELKEM*14 dup(0)        ; seznam nalezen˜ch soubor–

CitFram  dw        0                        ; ‡¡ta‡ r m–
NextFram dd        0                        ; offset dal¨¡ho r mu
NextChnk dd        0                        ; offset dal¨¡ho CHUNKu

AktFramU dw        0                        ; ‡¡slo v tabulce r m–*2
CitFramT dw        MCELKEM dup(0)           ; tabulka ‡¡ta‡– zbyl˜ch r m–
NxtFramT dd        MCELKEM dup(0)           ; tabulka offset– dal¨¡ch r m–

; ------ palety

Palety   db        256*3 dup(?)             ; buffer palet
Palety0  label     byte

KonvAPal dw        KonvPal                  ; adresa aktu ln¡ tabulky
KonvPal  db        MCELKEM*256 dup(-1)      ; konverzn¡ tabulky univerz. barev
                                            ;  (-1 = nen¡ dosud inicializov no)

; ------ z hlav¡ souboru FLI (FLC) (128 Bajt–) (n sleduj¡ r my)

FliZahl  label     byte
FliDelk  dd        0                        ; 00h: d‚lka souboru FLI/FLC (bajt–)
FliIdent dw        0AF11h                   ; 04h: identifik tor souboru
                                            ;      (0AF11h=FLI, 0AF12h=FLC)
FliFramN dw        1                        ; 06h: celkov˜ po‡et r m– (max.4000)
FliX     dw        320                      ; 08h: rozmˆr obr zku X (320 pro FLI)
FliY     dw        200                      ; 0Ah: rozmˆr obr zku Y (200 pro FLI)
FliBits  dw        8                        ; 0Ch: po‡et bit– na bod (8 pro FLI)
FliFlag  dw        0                        ; 0Eh: p©¡znaky (0 pro FLI)
FliDel   dd        5                        ; 10h: FLI: (2) prodleva mezi obr zky v 1/70 s
                                            ;             (=po‡et sn¡mk– obrazovky)
                                            ;           (2) ... rezervov no (=0)
                                            ;      FLC: (4) prodleva mezi obr zky v [ms]
; Dal¨¡ data jsou=0 pro FLI:
         dw        0                        ; 14h:  ... nepou‘ito (nastaveno na 0)
         dd        0                        ; 16h: datum a ‡as vytvo©en¡ (form t DOS)
         dd        0                        ; 1Ah: s‚riov‚ ‡¡slo tvo©¡c¡ho programu (nebo "FLIB")
         dd        0                        ; 1Eh: datum a ‡as modifikace (form t DOS)
         dd        0                        ; 22h: s‚riov‚ ‡¡slo modifika‡n¡ho programu (nebo "FLIB")
         dw        6                        ; 26h: koeficient zkr cen¡ osy X (6 pro 320x200)
         dw        5                        ; 28h: koeficient zkr cen¡ osy Y (5 pro 320x200)
         db        38 dup(0)                ; 2Ah: ... rezervov no
         dd        0                        ; 50h: offset v souboru prvn¡ho r mu
         dd        0                        ; 54h: offset v souboru druh‚ho r mu
         db        40 dup(0)                ; 58h: ... nepou‘ito (nastaveno na 0)
FliZahl0 label     byte

; ------ z hlav¡ jednoho r mu (nebo prefixov˜ CHUNK) (n sleduj¡ CHUNKy)

FramZahl label     byte
FramDelk dd        0                        ; 00h: d‚lka r mu (bajt–, max. 64KB)
FramIdnt dw        0F1FAh                   ; 04h: identifik tor r mu
                                            ;      (0F1FAh=r m, 0F100h=prefix)
FramChnk dw        0                        ; 06h: po‡et blok– CHUNK
                                            ;      (0=r m je shodn˜ s p©ede¨l˜m)
         db        8 dup(0)                 ; 08h: ... rezervov no (nastaveno na 0)
FramZhl0 label     byte

; ------ z hlav¡ jednoho CHUNK (n sleduj¡ data)

ChnkZahl label     byte
ChnkDelk dd        0                        ; 00h: d‚lka CHUNKu (bajt–)
ChnkIdnt dw        0                        ; 04h: identifik tor typu dat
                                            ;        4=palety 256 £rovn¡
                                            ;        7=slovn¡ delta-komprese (nen¡ u FLI)
                                            ;       11=palety 64 £rovn¡
                                            ;       12=bajtov  delta-komprese
                                            ;       13=‡ern˜ r m (v¨e vymaz no barvou 0)
                                            ;       15=bajtov  komprese run length (1. r m)
                                            ;       16=nekomprimovan˜ r m (n sleduj¡ data)
                                            ;       18=zmen¨en˜ obr zek (nen¡ u FLI)
ChnkZhl0 label     byte

; ------ 4, 11: paletov˜ chunk (256 nebo 64 £rovn¡)
; Organizov n do paket–:
;     0: (2) po‡et paket–
;     2: (x) ... n sleduj¡ paletov‚ pakety
;
; Jeden paletov˜ paket (ukazatel barev pro prvn¡ paket = 0):
;              0: (1) po‡et p©esko‡en˜ch barev v tomto paketu
;              1: (1) po‡et modifikovan˜ch barev v tomto paketu (0=256 barev)
;              2: (x) ... n sleduj¡ definice barev
;
; Jedna barva v paketu:
;                  0: (1) ‡erven  slo‘ka (0 - 63 nebo 0 - 255)
;                  1: (1) zelen  slo‘ka (0 - 63 nebo 0 - 255)
;                  2: (1) modr  slo‘ka (0 - 63 nebo 0 - 255)

; ------ 12: bajtov  delta-komprese
; Z hlav¡ r mu komprimovan‚ho bajtovou delta-kompres¡:
;    0: (2) po‡et p©esko‡en˜ch linek od za‡ tku obr zku
;    2: (2) po‡et modifikovan˜ch linek
;    4: (x) ... n sleduj¡ data modifikovan˜ch linek
;
; Z hlav¡ jedn‚ modifikovan‚ linky:
;            0: (1) po‡et paket– v t‚to lince (0=linka nen¡ modifikov na)
;            1: (x) ... n sleduj¡ pakety linky
;
; Paket modifikovan‚ linky:
;                  0: (1) po‡et p©esko‡en˜ch bod–
;                  1: (1) nula -> nejsou data
;                         kladn˜ -> po‡et n sleduj¡c¡ch modifikovan˜ch bod–
;                         z porn˜ -> -po‡et opakov n¡ n sleduj¡c¡ho bajtu
;                  2: (x) ... n sleduj¡ modifikovan‚ body (bajt velikosti > 0)
;             nebo 2: (1) ... n sleduje opakovan˜ bod (bajt velikosti < 0)

; ------ 7: slovn¡ delta-komprese
; Z hlav¡ r mu komprimovan‚ho slovn¡ delta-kompres¡:
;    0: (2) po‡et modifikovan˜ch linek (nepo‡¡taj¡ se p©esko‡en‚ linky)
;    2: (x) ... n sleduj¡ data modifikovan˜ch linek
;
; Z hlav¡ jedn‚ modifikovan‚ linky:
;            0: (2) slovo p©¡znak–
;                     bit 15:   bit 14:
;                        0         0     slovo obsahuje po‡et paket– (n sleduj¡)
;                                        (nen sleduje bajt po‡tu paket–)
;                                         0 -> n sleduje posledn¡ bajt na lince
;                        1         0     ni‘¨¡ bajt obsahuje posledn¡ bajt linky
;                        1         1     -slovo obsahuje po‡et linek k p©esko‡en¡
;                                        (pou‘ije se absolutn¡ hodnota slova)
;                                        za slovem n sleduje dal¨¡ slovo
;                                        p©esko‡en¡, posledn¡ bajt nebo po‡et paket–
;            2: (1) po‡et paket– v t‚to lince (0=linka nen¡ modifikov na)
;                   (bajt nen sleduje, je-li ji‘ po‡et paket– ud n slovem)
;            3: (x) ... n sleduj¡ pakety linky
;
; Paket modifikovan‚ linky:
;                  0: (1) po‡et p©esko‡en˜ch bod–
;                  1: (1) nula -> nejsou data
;                         kladn˜ -> po‡et n sleduj¡c¡ch modifikovan˜ch slov
;                         z porn˜ -> -po‡et opakov n¡ n sleduj¡c¡ho slova
;                  2: (x) ... n sleduj¡ modifikovan  slova (bajt velikosti > 0)
;             nebo 2: (2) ... n sleduje opakovan‚ slovo (bajt velikosti < 0)

; ------ 15: bajtov  komprese run length (pou‘¡v  se pro 1. r m)
; Z hlav¡ jedn‚ modifikovan‚ linky:
;            0: (1) po‡et paket– v t‚to lince (£daj se zpravidla ignoruje,
;                   proto‘e po‡et paket– m–‘e b˜t vˆt¨¡ ne‘ 255 - pou‘¡v  se
;                   ¨¡©ka obr zku)
;            1: (x) ... n sleduj¡ pakety linky
;
; Paket modifikovan‚ linky:
;                  0: (1) kladn˜ -> po‡et opakov n¡ n sleduj¡c¡ho bodu
;                         z porn˜ -> -po‡et p©¡mo p©enesen˜ch bod–
;                  1: (x) ... n sleduj¡ p©en ¨en‚ body (p©ede¨l˜ bajt < 0)
;             nebo 1: (1) ... n sleduje opakovan˜ bod (p©ede¨l˜ bajt > 0)

         db        400h dup(?)              ; buffer z sobn¡ku
Zasob    label     byte                     ; konec z sobn¡ku

Code     ENDS
         END       Start


; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                               W I N D O W - 3
;
;                            Ovl†d†n° oken adres†©ñ
;
; =============================================================================
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

INCLUDE  ASM\DEF.ASM

CodeWin  SEGMENT   BYTE PUBLIC
         ASSUME    cs:CodeWin,ds:Data

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                  Ovl†d†n° oken adres†©ñ pomoc° kl†ves
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        ovl†d†n° oken pomoc° kl†ves (VSTUP:BX=kl†vesa, VùSTUP:BX=0 obslouëena)
; -----------------------------------------------------------------------------

AWinWin  PROC      FAR

; ------ test, zda je povoleno zap/vyp oken pomoc° ESC

         cmp       bx,11bh
         jne       AWinWn02                 ; nen° ESC
         test      byte ptr ds:[WindPar2],bit2 ; povolena funkce ?
         jnz       AWinWn02                 ; funkce povolena
AWinWin0:jmp       far ptr Main0            ; n†vrat do hlavn°ho menu

AWinWn02:call      far ptr JumpBX           ; skok na obsluhu podle tabulky

         dw        0f09h,AWTab              ; tabul†tor
         dw        0f00h,AWSTab             ; zpàtnò tabul†tor

         dw        011bh,AWCtrlO            ; Esc - zap/vyp oken

         dw        180fh,AWCtrlO            ; ^O - zap/vyp oken
         dw        1615h,AWCtrlU            ; ^U - z†màna oken
         dw        260ch,AWCtrlL            ; ^L - zap/vyp neaktivn°ho okna
         dw        5e00h,AWCtrF1            ; ^F1 - zap/vyp levÇho okna
         dw        5f00h,AWCtrF2            ; ^F2 - zap/vyp pravÇho okna
         dw        3002h,AWCtrlB            ; ^B - n†povàda k funkán°m kl†ves†m
         dw        310eh,AWCtrlN            ; ^N - obnoven° obsahu oken
         dw        250bh,AWCtrlK            ; ^K - form†t zobrazen° oken
         dw        6800h,AWMOL10            ; Alt-F1 - volba disku levÇho okna
         dw        6900h,AWMOR10            ; Alt-F2 - volba disku pravÇho okna
         dw        4e2bh,AWSlPlus           ; [+] oznaáen° souborñ
         dw        4a2dh,AWSlMins           ; [-] nulov†n° oznaáen° souborñ
         dw        372ah,AWSlInvs           ; [*] inverze oznaáen° souborñ
         dw        7000h,AWCompW            ; Alt-F9 - porovn†n° oken
         dw        5c00h,AWSTrid            ; Shift-F9 . t©°dàn° okna
         dw        4b00h,AWLeft             ; kurzor vlevo
         dw        4d00h,AWRght             ; kurzor vpravo
         dw        7300h,AWLeft             ; ^ vlevo
         dw        7400h,AWRght             ; ^ vpravo

         dw        0,AWinWin0               ; neplatn† kl†vesa

AWinWin  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-F1 - zap/vyp levÇho okna
; -----------------------------------------------------------------------------

AWCtrF1: call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      AWCtF1
AWCtrF12:call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        Ctrl-F2 - zap/vyp pravÇho okna
; -----------------------------------------------------------------------------

AWCtrF2: call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      AWCtF2
         jmp       short AWCtrF12

; -----------------------------------------------------------------------------
;        ^L - zap/vyp neaktivn°ho okna
; -----------------------------------------------------------------------------

; ------ test, zda je zapnuto alespo§ 1 okno

AWCtrlL  LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      AWCtrL                   ; zap/vyp neaktivn°ho okna
         call      far ptr DispAll          ; zobrazen° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        volba aktivn°ho disku z menu diskñ
; -----------------------------------------------------------------------------

AWMOL1D  LABEL     FAR

         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       AWMOL11                  ; je aktivn° levÇ okno
         jmp       short AWMOR11            ; jinak pravÇ okno

; -----------------------------------------------------------------------------
;        Alt-F1 volba disku levÇho okna, volba disku levÇho okna z menu
; -----------------------------------------------------------------------------

AWMOL11: add       sp,4                     ; zru®en° n†vratovÇ adresy
AWMOL10: or        byte ptr ds:[WindPar],bit4 ; volba parametrñ levÇho okna
         mov       word ptr ds:[DiskMnu+MnuPol],offset DiskMPlL ; ©†dek nadpisu
         mov       di,offset ParamL         ; parametry levÇho okna
         mov       ax,ds:[SegmL]            ; segment levÇho okna
         jmp       short AWMOR12

; -----------------------------------------------------------------------------
;        Alt-F2 volba disku pravÇho okna, volba disku pravÇho okna z menu
; -----------------------------------------------------------------------------
;˛
AWMOR11: add       sp,4                     ; zru®en° n†vratovÇ adresy
AWMOR10: and       byte ptr ds:[WindPar],not bit4 ; volba parametrñ pravÇho okna
         mov       word ptr ds:[DiskMnu+MnuPol],offset DiskMPlR ; ©†dek nadpisu
         mov       di,offset ParamR         ; parametry pravÇho okna
         mov       ax,ds:[SegmR]            ; segment pravÇho okna

AWMOR12: call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      far ptr InitDPar         ; inicializace diskovòch parametrñ
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         mov       si,offset DiskMnu        ; menu volby diskñ
         mov       dx,ax                    ; £schova á°sla segmentu
         call      far ptr GetDat           ; poskytnut° adresy okna
         test      byte ptr es:[AWinPrm1],bit5 ; je to okno seznamu ?
         jz        AWMOR101
AWMOR129:jmp       AWMOR109                 ; okno seznamu nelze zmànit

AWMOR101:mov       al,es:[AWinDisk]         ; disk okna
         call      far ptr DiskMenu         ; obsluha volby disku
         jc        AWMOR129                 ; p©eru®en° ESC
         cmp       al,DiskMax               ; je to historie ?
         jb        AWMOR102                 ; nen° historie
         call      far ptr AWHistW0         ; historie (nevrac° se zpàt !!!)

AWMOR102:push      di
         mov       di,AWinDir               ; buffer k naáten° adres†©e
         call      far ptr GetDir           ; poskytnut° aktivn° cesty
         pop       di
         jc        AWMOR108                 ; chyba

         or        byte ptr ds:[di],bit0    ; p©°znak zapnut° okna
         or        byte ptr ds:[WindPar],bit1 ; p©°znak zapnut° oken

         or        byte ptr es:[AWinPrm0],bit0 ; neuchov†vat oznaáen° ani kurzor
         mov       es:[AWinDNum],cx         ; poáet bajtñ

         mov       ah,al                    ; AH <- novò disk
         xchg      al,es:[AWinDisk]         ; á°slo novÇho aktivn°ho disku
         cmp       dx,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       AWMOR106                 ; nen° to aktivn° okno

         cmp       al,ah                    ; je disk zmànàn ?
         je        AWMOR106                 ; disk nen° zmànàn

         push      di
         push      ds

         mov       si,AWinDir               ; adres†© aktivn°ho okna
         mov       ds:[AktPathN],cx         ; dÇlka textu adres†©e
         mov       di,offset AktPath        ; aktivn° adres†©
         cld
         inc       cx                       ; váetnà koncovÇ 0
         push      ds
         push      es
         pop       ds
         pop       es
         rep       movsb                    ; p©enesen° textu cesty

         pop       ds
         pop       di

         call      far ptr GetNAWin         ; adresa neaktivn°ho okna
         cmp       al,es:[AWinDisk]         ; byt p©edt°m disk stejnò ?
         jne       AWMOR106                 ; disk p©edt°m nebyl stejnò

         mov       si,AWinDir               ; adres†© neaktivn°ho okna
         call      far ptr SetDir           ; nastaven° adres†©e neaktivn°ho okna

AWMOR106:mov       ax,dx                    ; segment okna
         call      far ptr ReReadD          ; novÇ naáten° okna
         call      far ptr NulBreak         ; pro dal®° okno ignorov†n° p©eru®en°
         call      far ptr AktADir          ; aktualizace adres†©e podle okna
         cmp       ax,ds:[SegmAkt]          ; je to aktivn° okno ?
         jne       AWMOR108                 ; nen° to aktivn° okno
         call      far ptr GetDat
         jc        AWMOR108
         mov       si,AWinDir
         call      far ptr SetDDir          ; nastaven° aktivn°ho disku a cesty

AWMOR108:call      far ptr DispAll
AWMOR109:jmp       AWinWin0

; -----------------------------------------------------------------------------
;        ^N - obnoven° obsahu oken
; -----------------------------------------------------------------------------

; ------ uzav©en° oken menu

AWCtrlN  LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      far ptr ClosMnuA         ; uzav©en° oken menu

; ------ obnoven° obsahu aktivn°ho okna

         mov       ax,ds:[SegmAkt]
         call      AWCtrNN                  ; inicializace okna AX

; ------ obnoven° obsahu neaktivn°ho okna

         mov       ax,ds:[SegmNAkt]
         call      AWCtrNN                  ; inicializace okna AX

; ------ novÇ zobrazen° oken

AWCtrlN3:call      far ptr DispAll
         jmp       AWinWin0

; ------ inicializace okna AX

AWCtrNN  PROC      NEAR

         call      far ptr TestAWin         ; je okno zapnuto ?
         jc        AWCtrNN9                 ; nen° zapnuto

         call      far ptr GetDat           ; adresa okna -> ES
         mov       cx,es:[AWinSouN]         ; poáet poloëek
         jcxz      AWCtrNN4                 ; nen° ë†dn† poloëka
         xor       bx,bx                    ; ukazatel á°sla poloëky
AWCtrNN2:call      far ptr ResSPol          ; odznaáen° poloëky
         inc       bx                       ; zvò®en° ukazatele poloëek
         loop      AWCtrNN2                 ; dal®° poloëka

AWCtrNN4:call      far ptr ReReadD
         call      far ptr NulBreak         ; pro dal®° okno ignorov†n° p©eru®en°
AWCtrNN9:ret

AWCtrNN  ENDP

; -----------------------------------------------------------------------------
;        [*] inverze oznaáen° souborñ
; -----------------------------------------------------------------------------

AWSlInvs PROC      NEAR

         mov       dl,bit2
AWSlInv1:call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         jmp       far ptr SelSelct

AWSlInvs ENDP

; -----------------------------------------------------------------------------
;       [+] oznaáen° zadanòch souborñ
; -----------------------------------------------------------------------------

AWSlPlus PROC      NEAR

         mov       dl,bit0
         jmp       short AWSlInv1

AWSlPlus ENDP

; -----------------------------------------------------------------------------
;        [-] nulov†n° oznaáen° souborñ
; -----------------------------------------------------------------------------

AWSlMins PROC      NEAR

         mov       dl,bit1
         jmp       short AWSlInv1

AWSlMins ENDP

; -----------------------------------------------------------------------------
;        zap/vyp n†povàdy Ctrl-B
; -----------------------------------------------------------------------------

AWCtrlB  PROC      NEAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         xor       byte ptr ds:[HelpPar],bit0 ; zmàna p©°znaku malÇ n†povàdy
         call      far ptr InitRows         ; inicializace vò®ky oken
         call      far ptr DispAll          ; novÇ zobrazen° obrazovky
         jmp       AWinWin0

AWCtrlB  ENDP

; -----------------------------------------------------------------------------
;        Ctrl-K zmàna form†tu zobrazen°
; -----------------------------------------------------------------------------

AWCtrlK  PROC      NEAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°

         call      far ptr TestAAWn
         jc        AWCtrlK9                 ; aktivn° okno nezobrazeno
         call      far ptr GetAAWin         ; poskytnut° aktivn°ho okna
         test      byte ptr es:[AWinPrm1],bit5 ; je okno seznamu ?
         jnz       AWCtrlK9                 ; je okno seznamu

         mov       al,es:[AWinPrm2]         ; parametry zobrazen°
         mov       ah,al
         add       al,bit5                  ; posun
         and       al,bit5+bit6

;         cmp       al,3*bit5                ; dlouh† jmÇna ?
;         jne       AWCtrlK3                 ; nejsou dlouh† jmÇna
;         test      byte ptr ds:[Win95Par],bit2 ; povolena dlouh† jmÇna ?
;         jz        AWCtrlK3                 ; jsou povolena dlouh† jmÇna
;         mov       al,0                     ; posun na plnÇ zobrazen°

AWCtrlK3:and       ah,not bit5+bit6
         or        al,ah

;; ------ komentovanÇ okno
;
;         test      byte ptr ds:[WindPar],bit5 ; je druhò stisk Ctrl-K ?
;         jz        AWCtrlK0                 ; nen° druhò stisk Ctrl-K
;         and       al,not bit5
;         or        al,bit6                  ; komentovanÇ okno
;         jmp       short AWCtrlK3
;
;; ------ plnÇ -> zkr†cenÇ
;
;AWCtrlK0:or        byte ptr ds:[WindPar],bit5 ; p©°znak kl†vesy Ctrl-K
;         test      al,bit5 + bit6
;         jnz       AWCtrlK1
;         or        al,bit5
;         jmp       short AWCtrlK4
;
;; ------ zkr†cenÇ -> plnÇ
;
;AWCtrlK1:test      al,bit5
;         jz        AWCtrlK2
;         and       al,not bit5 + bit6       ; plnÇ zobrazen°
;         jmp       short AWCtrlK4
;
;; ------ komentovanÇ -> plnÇ
;
;AWCtrlK2:and       al,not bit5 + bit6
;AWCtrlK3:and       byte ptr ds:[WindPar],not bit5 ; zru®en° p©°znaku Ctrl-K

AWCtrlK4:mov       byte ptr es:[AWinPrm2],al
         mov       si,offset ParamLC        ; parametry levÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       AWCtrlK5                 ; je aktivn° levÇ okno
         mov       si,offset ParamRC        ; parametry pravÇho okna
AWCtrlK5:mov       ds:[si],al               ; £schova parametrñ

         mov       ax,ds:[SegmAkt]
         call      far ptr LoadFInf         ; naáten° informaán°ho souboru
         call      far ptr InitFKom         ; inicializace koment†©ñ
         call      far ptr DispAAWn

AWCtrlK9:jmp       AWinWin0

AWCtrlK  ENDP

; -----------------------------------------------------------------------------
;        kurzor vlevo
; -----------------------------------------------------------------------------

AWLeft:  call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         test      byte ptr ds:[WindPar],bit0 ; je levÇ okno ?
         jz        AWTab                    ; p©epnut° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        kurzor vpravo
; -----------------------------------------------------------------------------

AWRght:  call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         test      byte ptr ds:[WindPar],bit0 ; je levÇ okno ?
         jnz       AWTab                    ; p©epnut° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        TAB - p©epnut° aktivn°ho okna
; -----------------------------------------------------------------------------

AWTab    LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
AWTab1:  call      AWTb                     ; p©epnut° okna
         call      far ptr DispAll          ; novÇ zobrazen° obrazovky
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        Shft-TAB - kurzor na stejnou poloëku v protàj®°m oknà
; -----------------------------------------------------------------------------

AWSTab:  call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°

         call      far ptr GetAKurz         ; poskytnut° kurzoru
         jc        AWTab1

         push      si
         push      es
         call      AWTb                     ; p©epnut° okna
         pop       es
         pop       si

         mov       ax,ds:[SegmAkt]
         call      far ptr SrcWNam          ; nalezen° stejnÇ poloëky
         jnc       AWSTab2                  ; poloëka nalezena OK
         call      far ptr SrcWKur          ; nalezen° podobnÇ poloëky
AWSTab2: call      far ptr GetDat
         mov       es:[AWinKurz],bx
         call      far ptr AktPthAT         ; aktualizace stromu v aktivn°m oknà
         call      far ptr AktPthAL         ; aktualizace cesty okna seznamu

         call      far ptr DispAll          ; novÇ zobrazen° obrazovky
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        ^U - z†màna oken
; -----------------------------------------------------------------------------

AWCtrlU  LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      AWCtrU                   ; z†màna oken
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        ^O - zap/vyp oken
; -----------------------------------------------------------------------------

AWCtrlO  LABEL     FAR

         call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      AWCtrO                   ; zap/vyp oken
         call      far ptr ClosMnuA         ; uzav©en° menu
         call      far ptr DispAll
AWCtrlO9:jmp       AWinWin0

; -----------------------------------------------------------------------------
;        t©°dàn° okna Shift-F9
; -----------------------------------------------------------------------------
;˛
AWSTrid: call      far ptr TestAAWn         ; test, zda je aktivn° okno zapnuto
         jc        AWCtrlO9                 ; aktivn° okno nen° zapnuto

         mov       al,ds:[WindPar]          ; parametry okna
         and       al,bit0                  ; p©°znak levÇho okna
         mov       cl,4
         shl       al,cl                    ; rotace na pozici
         and       byte ptr ds:[WindPar],not bit4
         or        ds:[WindPar],al          ; p©°znak okna

         call      far ptr GetAAWin         ; poskytnut° aktivn°ho okna
         mov       bl,es:[AWinPrm2]         ; t©°dàn° okna
         mov       al,ds:[ZnakSwch]         ; znak p©ep°naáe (zapnuto)
         test      bl,bit3                  ; je sestupnÇ t©°dàn° ?
         jnz       AWSTrid2                 ; je sestupnÇ t©°dàn°
         mov       al,ds:[ZnakSwch+1]       ; znak p©ep°naáe (vypnuto)
AWSTrid2:mov       ds:[SBSMLPl1],al         ; znak p©ep°naáe "Sestupnà"
         and       bx,bit0+bit1+bit2        ; t©°dàn° okna
         mov       al,cs:[bx+AWSTriT2]      ; t©°dàn°
         mov       si,offset SBSMLine       ; menu volby t©°dàn° okna
         mov       byte ptr ds:[si+MnuAkt],al ; aktivn° poloëka

         call      far ptr Lin1Menu         ; volba t©°dàn° okna

         or        bx,bx                    ; je p©eru®en° volby ?
         jz        AWSTrid9                 ; p©eru®en° volby

         mov       ax,ds:[SegmAkt]          ; segment aktivn°ho okna
         call      far ptr GetDat           ; adresa aktivn°ho okna

         cmp       bl,7                     ; je zad†n° masky ?
         jne       AWSTrid6                 ; nen° zad†n° masky

         jmp       AWMOL4M1                 ; volba masky


AWSTrid6:cmp       bl,6                     ; sestupnÇ t©°dàn° okna ?
         jne       AWSTrid7                 ; nen° sestupnÇ t©°dàn° okna
         xor       byte ptr es:[AWinPrm2],bit3 ; p©°znak sestupnÇho t©°dàn°
         jmp       short AWSTrd71           ; p©et©°dàn° okna

AWSTrid7:and       byte ptr es:[AWinPrm2],not bit0 + bit1 + bit2
         mov       cl,cs:[bx+AWSTriTb-1]    ; novÇ t©°dàn° okna
         or        es:[AWinPrm2],cl         ; nastaven° p©°znaku t©°dàn°

AWSTrd71:mov       cl,es:[AWinPrm2]         ; parametry okna - t©°dàn°
         mov       bx,offset ParamLC        ; levÇ okno
         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
         jnz       AWSTrd72                 ; je levÇ okno
         mov       bx,offset ParamRC        ; pravÇ okno
AWSTrd72:mov       ds:[bx],cl               ; £schova nastaven° t©°dàn°

AWSTrid8:call      far ptr ReSort           ; p©et©°dàn° okna
         call      far ptr DispAWin         ; novÇ zobrazen° okna
AWSTrid9:jmp       AWinWin0

AWSTriTb db        0*bit1                   ; jmÇno
         db        1*bit1                   ; p©°pona
         db        2*bit1                   ; velikost
         db        3*bit1                   ; datum a áas
         db        bit0                     ; net©°dànÇ

AWSTriT2 db        1                        ; jmÇno
         db        5                        ; net©°d° se
         db        2                        ; p©°pona
         db        5                        ; net©°d° se
         db        3                        ; velikost
         db        5                        ; net©°d° se
         db        4                        ; datum a áas
         db        5                        ; net©°d° se

; -----------------------------------------------------------------------------
;        oznaáen° souborñ v obou oknech Alt-F9 (vol†no tÇë z menu)
; -----------------------------------------------------------------------------

AWCompWM PROC      FAR

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech oken menu

; ------ test, zda jsou zobrazena obà okna

AWCompW: call      far ptr QSrcEnd          ; ukonáen° reëimu rychlovyhled†v†n°
         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jc        AWCompW0                 ; nen° zobrazeno

; ------ zad†n° parametrñ pro operaci

         mov       si,offset SBPMLine       ; menu volby parametrñ
         mov       byte ptr ds:[si+MnuAkt],1 ; aktivn° poloëka

         mov       dl,ds:[SelParam]         ; parametry
         mov       cl,4                     ; poáet rotac°
         shr       dl,cl                    ; rotace na pozici
         call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         call      far ptr CentMenu         ; centrov†n° menu
         call      far ptr VertMenu         ; volba parametrñ pro operaci
AWCompW0:jmp       AWinWin0                 ; n†vrat p©i p©eru®en°

; ====== obsluha provedenÇ volby

AWCompW2 label     far

         add       sp,4                     ; zru®en° n†vratovÇ adresy do menu
         call      far ptr ClosMnuA         ; uzav©en° oken menu
         mov       bx,ds:[si+MnuAkt]        ; aktivn° zvolen† poloëka
         mov       dh,cs:[bx+AWMSTab2-1]    ; odpov°daj°c° p©ep°naáe

         mov       dl,ds:[SelParam]
         and       dl,not bit1+bit2
         or        dl,bit0                  ; p©°znak oznaáen° souborñ

; ------ test, zda jsou adres†©e oken shodnÇ

         push      dx
         push      ds

         call      far ptr GetAAWin         ; adresa aktivn°ho okna
         push      es
         call      far ptr GetNAWin         ; adresa neaktivn°ho okna
         pop       ds

         test      byte ptr ds:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        AWCmpW28                 ; nen° adres†©ovÇ okno
         test      byte ptr ds:[AWinFilP],bit6+bit7 ; jsou v®echny soubory ?
         jnz       AWCmpW28                 ; nejsou v®echny soubory

         test      byte ptr es:[AWinPrm1],bit3 ; je adres†©ovÇ okno ?
         jz        AWCmpW28                 ; nen° adres†©ovÇ okno
         test      byte ptr es:[AWinFilP],bit6+bit7 ; jsou v®echny soubory ?
         jnz       AWCmpW28                 ; nejsou v®echny soubory

         mov       cx,ds:[AWinDNum]         ; dÇlka textu adres†©e
         inc       cx                       ; váetnà koncovÇ 0
         mov       si,AWinDir               ; zaá†tek adres†©e
         mov       di,si
         cld
         repe      cmpsb                    ; porovn†n° adres†©ñ
         clc
         jne       AWCmpW28                 ; adres†©e nejsou shodnÇ

; ------ adres†©e jsou shodnÇ

         pop       ds
         push      ds
         mov       si,offset ACmpWMnu       ; menu varov†n°
         call      far ptr Lin0MenF         ; zobrazen° chybovÇho hl†®en°

AWCmpW28:pop       ds
         pop       dx
         jc        AWCompW3                 ; p©eru®en° operace

; ------ porovn†n° obsahñ oken

         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         mov       bx,ds:[SegmNAkt]         ; neaktivn° okno
         call      far ptr CompWin          ; porovn†n° obsahu okna s protàj®°m
         xchg      ax,bx
         call      far ptr CompWin          ; porovn†n° obsahu druhÇho okna
AWCompW3:call      far ptr ClosMnuA         ; uzav©en° oken menu
         jmp       AWinWin0                 ; n†vrat do hlavn°ho menu

AWCompWM ENDP

; ------ parametry pro operaci

AWMSTab2 db        0                        ; 1 = aktu†ln° (dopl§kovÇ a novàj®°)
         db        2                        ; 2 = dopl§kovÇ
         db        4                        ; 3 = novàj®°
         db        6                        ; 4 = shodnÇ
         db        8                        ; 5 = star®°
         db        10                       ; 6 = rozd°lnÇ
         db        12                       ; 7 = existuj°c°
         db        bit6                     ; 8 = volnÇ m°sto

;AWMSTab2 db        bit7 + bit0 + bit1              ; 1 = aktu†ln° (dopl§kovÇ a novàj®°)
;         db        bit7 + bit0                     ; 3 = dopl§kovÇ
;         db        bit7 + bit1                     ; 2 = novàj®°
;         db        bit7 + bit3                     ; 4 = shodnÇ (datum, áas i velikost)
;         db        bit7 + bit2                     ; 5 = star®°
;         db        bit7 + bit1 + bit2 + bit4       ; 6 = rozd°lnÇ (novàj®°,star®°,<,>)
;         db        bit7 + bit1 + bit2 + bit3 + bit4; 7 = jmÇno (novàj®°,star®°,shodnÇ)
;         db        bit7 + bit6                     ; 8 = velikost

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                       Ovl†d†n° oken pomoc° menu
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        obsluha menu "Okna"
; -----------------------------------------------------------------------------

AWMMnuO  PROC      FAR

         call      AWMMnuOS                 ; p©°prava p©ep°naáñ
         jmp       far ptr VertMenu         ; obsluha vertik†ln°ho menu

AWMMnuO  ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ menu "Okna"
; -----------------------------------------------------------------------------

AWMMnuOS PROC      NEAR

         push      dx

         and       byte ptr ds:[OMnuVBlk+2],not bit1 ; povolena volba "aktivn°"
         and       byte ptr ds:[OMnuVBlk+5],not bit1 ; povolena volba "vò®ka"
         and       byte ptr ds:[OMnuVBlk+6],not bit1 ; povolena volba "z†màna"
         or        byte ptr ds:[OMnuVBlk+8],bit1 ; zak†z†na volba "srovn†n°"

         xor       dx,dx
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jz        AWMMnOS2                 ; nen° aktivn° levÇ okno
         or        dl,bit0                  ; p©°znak aktivn°ho levÇho okna

AWMMnOS2:call      far ptr TestNAWn         ; je zapnuto neaktivn° okno ?
         jc        AWMMnOS3                 ; neaktivn° okno nen° zapnuto
         or        dl,bit1                  ; p©°znak zapnut° neaktivn°ho okna

         and       byte ptr ds:[OMnuVBlk+8],not bit1 ; povolena volba "srovn†n°"

AWMMnOS3:call      far ptr TestAAWn         ; je zapnuto aktivn° okno ?
         jnc       AWMMnOS4                 ; okna jsou zapnuta
         or        dl,bit2                  ; p©°znak vypnut° obou oken

         or        byte ptr ds:[OMnuVBlk+2],bit1 ; zak†z†na volba "aktivn°"
         or        byte ptr ds:[OMnuVBlk+5],bit1 ; zak†z†na volba "vò®ka"
         or        byte ptr ds:[OMnuVBlk+6],bit1 ; zak†z†na volba "z†màna"

AWMMnOS4:call      far ptr SetSwch          ; nastaven° p©ep°naáñ

         pop       dx
         ret

AWMMnuOS ENDP

; -----------------------------------------------------------------------------
;        obsluha menu "LevÇ okno"
; -----------------------------------------------------------------------------

AWMMnuO1 PROC      FAR

         or        byte ptr ds:[WindPar],bit4 ; p©°znak volby param. levÇho okna
         jmp       short AWMMnO21

AWMMnuO1 ENDP

; -----------------------------------------------------------------------------
;        obsluha menu "PravÇ okno"
; -----------------------------------------------------------------------------

AWMMnuO2 PROC      FAR

         and       byte ptr ds:[WindPar],not bit4 ; p©°znak volby pravÇho okna

; ------ p©°prava p©ep°naáñ okna

AWMMnO21:call      AWMMnOL                  ; p©°prava p©ep°naáñ okna

; ------ p©°prava pozice k zobrazen° okna

         mov       ax,word ptr ds:[OMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

; ------ obsluha okna

         jmp       far ptr VertMenu         ; obsluha vertik†ln°ho menu

AWMMnuO2 ENDP

; -----------------------------------------------------------------------------
;        oprava p©ep°naáñ okna
; -----------------------------------------------------------------------------

AWMMnOL  PROC      NEAR

         push      ax
         push      dx

         xor       dx,dx
         mov       ax,ds:[SegmL]            ; levÇ okno
         mov       dl,ds:[ParamL]           ; parametry levÇho okna
         test      byte ptr ds:[WindPar],bit4 ; obsluhov†no levÇ okno ?
         jnz       AWMMnOL2                 ; je levÇ okno
         mov       ax,ds:[SegmR]            ; pravÇ okno
         mov       dl,ds:[ParamR]           ; parametry pravÇho okna
AWMMnOL2:and       dl,bit1 + bit2 + bit3 + bit4 ; ponech† se typ okna
         call      far ptr TestAWin         ; test, zda je okno zapnuto
         jnc       AWMMnOL3                 ; okno je zapnuto
         or        dl,bit0                  ; p©°znak vypnut° okna
AWMMnOL3:call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ

         pop       dx
         pop       ax
         ret

AWMMnOL  ENDP

;; -----------------------------------------------------------------------------
;;        volba zobrazen° adres†©e
;; -----------------------------------------------------------------------------
;
;AWMOL5   PROC      FAR
;
;         mov       cl,bit1
;         jmp       short AWMOL82
;
;AWMOL5   ENDP
;
;; -----------------------------------------------------------------------------
;;        volba zobrazen° stromu
;; -----------------------------------------------------------------------------
;
;AWMOL6   PROC      FAR
;
;         mov       cl,bit2
;         jmp       short AWMOL82
;
;AWMOL6   ENDP
;
;; -----------------------------------------------------------------------------
;;        volba zobrazen° seznamu
;; -----------------------------------------------------------------------------
;
;AWMOL7   PROC      FAR
;
;         mov       cl,bit3
;         jmp       short AWMOL82
;
;AWMOL7   ENDP
;
;; -----------------------------------------------------------------------------
;;        volba zobrazen° prohl°ëeáe
;; -----------------------------------------------------------------------------
;
;AWMOL8   PROC      FAR
;
;         mov       cl,bit4
;AWMOL82: mov       di,offset ParamL         ; parametry levÇho okna
;         test      byte ptr ds:[WindPar],bit4 ; obsluhov†no levÇ okno ?
;         jnz       AWMOL83                  ; je levÇ okno
;         mov       di,offset ParamR         ; parametry pravÇho okna
;AWMOL83: and       byte ptr ds:[di],not bit1 + bit2 + bit3 + bit4
;         or        ds:[di],cl               ; nastaven° novòch parametrñ
;
;; ------ zmàna nastaven° oken bez ukonáen° menu
;
;AWMOL84: cmp       bl," "                   ; byla operace s mezerou ?
;         jne       AWMOL85                  ; nebyla mezera
;         call      AWMMnOL                  ; p©°prava p©ep°naáñ menu
;         call      far ptr DispAll          ; novÇ zobrazen° oken
;         ret                                ; n†vrat do menu
;
;; ------ zmàna nastaven° oken s ukonáen°m menu
;
;AWMOL85: add       sp,4                     ; zru®en° n†vratovÇ adresy
;         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
;         call      far ptr DispAll          ; novÇ zobrazen° oken
;         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy
;
;AWMOL8   ENDP

; -----------------------------------------------------------------------------
;        p©epnut° aktivn°ho okna
; -----------------------------------------------------------------------------

AWTabM   PROC      FAR

         call      AWTb                     ; z†màna oken
         jmp       short AWCtrOM1

AWTabM   ENDP

; -----------------------------------------------------------------------------
;        zap/vyp neaktivn°ho okna z menu
; -----------------------------------------------------------------------------

AWCtrlLM PROC      FAR

         call      AWCtrL                   ; zap/vyp neaktivn°ho okna
         jmp       short AWCtrOM1

AWCtrlLM ENDP

; -----------------------------------------------------------------------------
;        zap/vyp oken z menu
; -----------------------------------------------------------------------------

AWCtrlOM PROC      FAR

         call      AWCtrO                   ; zap/vyp oken

; ------ zmàna nastaven° oken bez ukonáen° menu

AWCtrOM1:cmp       bl," "                   ; byla operace s mezerou ?
         jne       AWCtrOM2                 ; nebyla mezera
         call      AWMMnuOS                 ; p©°prava p©ep°naáñ menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         ret                                ; n†vrat do menu

; ------ zmàna nastaven° oken s ukonáen°m menu

AWCtrOM2:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy

AWCtrlOM ENDP

; -----------------------------------------------------------------------------
;        z†màna oken z menu
; -----------------------------------------------------------------------------

AWCtrlUM PROC      FAR

         call      AWCtrU                   ; z†màna oken
         jmp       short AWCtrOM2           ; nen° p©ep°naá

AWCtrlUM ENDP

; -----------------------------------------------------------------------------
;        nastaven° vò®ky oken
; -----------------------------------------------------------------------------

AWMMnuO6 PROC      FAR

; ------ test, zda je nàjakÇ okno zobrazeno

         call      far ptr TestAAWn         ; test, zda je zapnuto aktivn° okno
         jc        AWCtrOM2                 ; nen° zapnuto ë†dnÇ okno

; ------ uzav©en° oken menu

         add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         or        byte ptr ds:[WindPar],bit2 ; p©°znak reëimu zmàny vò®ky oken

; ------ zobrazen° textu n†povàdy

         mov       si,offset VyskTxt
         call      far ptr DispHTxt         ; zobrazen° textu n†povàdy

; ------ £schova pñvodn°ho poátu ©†dkñ

         mov       al,ds:[NumRows0]         ; uëivatelskò poáet ©†dkñ oken
         push      ax                       ; £schova pñvodn°ho poátu ©†dkñ

; ------ inicializace a zobrazen° oken s aktu†ln°m nastaven°m

AWMMnO61:call      far ptr InitRows         ; inicializace vò®ky oken
         call      far ptr DispAll          ; novÇ zobrazen° oken

; ------ vstup znaku z kl†vesnice

AWMMO612:call      far ptr InpChar          ; vstup znaku
         mov       al,ds:[NumRows]          ; aktu†ln° nastaven° vò®ky
         call      far ptr JumpBX

         dw        4800h,AWMMnO62           ; nahoru
         dw        5000h,AWMMnO63           ; dolñ
         dw        4700h,AWMMnO65           ; Home
         dw        4f00h,AWMMnO67           ; End
         dw        011bh,AWMMnO68           ; p©eru®en° operace ESC
         dw        1c0dh,AWMMnO69           ; ukonáen° operace Enter

         dw        0,AWMMO612

; ------ nahoru

AWMMnO62:dec       ax                       ; sn°ëen° uëivatelskÇ vò®ky
         jmp       short AWMMnO64           ; proveden° korekce vò®ky

; ------ dolñ

AWMMnO63:inc       ax                       ; zvò®en° vò®ky oken
AWMMnO64:mov       ds:[NumRows0],al         ; poëadovan† vò®ka
         call      far ptr InitRows         ; inicializace vò®ky oken
         mov       al,ds:[NumRows]          ; zkorigovan† vò®ka okna
         jmp       short AWMMnO66           ; uloëen° zkorigovanÇ vò®ky

; ------ minim†ln° vò®ka HOME

AWMMnO65:mov       al,8                     ; minim†ln° vò®ka okna
AWMMnO66:mov       ds:[NumRows0],al         ; uloëen° uëivatelskÇ vò®ky
         jmp       short AWMMnO61

; ------ maxim†ln° vò®ka END

AWMMnO67:mov       al,255                   ; maxim†ln° vò®ka
         jmp       short AWMMnO66

; ------ Esc

AWMMnO68:pop       ax
         mov       ds:[NumRows0],al         ; n†vrat pñvodn° vò®ky oken
         push      ax

; ------ Enter

AWMMnO69:pop       ax                       ; zru®en° pñvodn° vò®ky oken
         and       byte ptr ds:[WindPar],not bit2 ; zru®en° reëimu vò®ky oken
         call      far ptr InitRows         ; inicializace vò®ky oken
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0

AWMMnuO6 ENDP

; -----------------------------------------------------------------------------
;        zapnut°/vypnut° pravÇho okna z menu
; -----------------------------------------------------------------------------

AWCtMF2  PROC      FAR

         call      AWCtF2                   ; zapnut°/vypnut° pravÇho okna
         jmp       short AWCtMF11

AWCtMF2  ENDP

; -----------------------------------------------------------------------------
;        zapnut°/vypnut° levÇho okna z menu
; -----------------------------------------------------------------------------

AWCtMF1  PROC      FAR

         call      AWCtF1                   ; zapnut°/vypnut° levÇho okna

; ------ zmàna nastaven° oken bez ukonáen° menu

AWCtMF11:push      si
         mov       si,offset OMnuVert       ; menu obsluhy oken
         call      AWMMnuOS                 ; p©°prava p©ep°naáñ menu "okna"
         pop       si

         cmp       bl," "                   ; byla operace s mezerou ?
         jne       AWCtMF12                 ; nebyla mezera
         call      AWMMnOL                  ; p©°prava p©ep°naáñ menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         ret                                ; n†vrat do menu

; ------ zmàna nastaven° oken s ukonáen°m menu

AWCtMF12:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy

AWCtMF1  ENDP

; -----------------------------------------------------------------------------
;        novÇ naáten° obsahu levÇho okna
; -----------------------------------------------------------------------------

AWMOL9   PROC      FAR

         mov       ax,ds:[SegmL]            ; segment levÇho okna
AWMOL91: add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         call      far ptr ReReadD          ; novÇ naáten° levÇho okna
         call      far ptr NulBreak         ; pro dal®° okno ignorov†n° p©eru®en°
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0

AWMOL9   ENDP

; -----------------------------------------------------------------------------
;        novÇ naáten° obsahu pravÇho okna
; -----------------------------------------------------------------------------

AWMOR9   PROC      FAR

         mov       ax,ds:[SegmR]            ; segment pravÇho okna
         jmp       short AWMOL91

AWMOR9   ENDP

; *****************************************************************************
;
;                          volba zobrazen° okna
;
; *****************************************************************************
;˛
AWMOL2   PROC      FAR

         call      AWMOLS                   ; p©°prava p©ep°naáñ

; ------ p©°prava pozice k zobrazen° okna

         mov       ax,word ptr ds:[LMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
         jnz       AWMOL22                  ; je levÇ okno
         mov       ax,word ptr ds:[RMnuVert+MnuPoz] ; pravÇ okno
AWMOL22: add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

; ------ obsluha okna

         jmp       far ptr VertMenu         ; obsluha vertik†ln°ho menu

AWMOL2   ENDP

; -----------------------------------------------------------------------------
;        nastaven° p©ep°naáñ menu volby form†tu zobrazen°
; -----------------------------------------------------------------------------

AWMOLS   PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      es

; ------ poskytnut° adresy okna

         call      AWMGetW                  ; poskytnut° adresy okna

; ------ p©°prava z†kazu dlouhÇho jmÇna

;         and       byte ptr ds:[LZMnVBlk+3],not bit1 ; povoleno
;         test      byte ptr ds:[Win95Par],bit2 ; povoleno ?
;         jz        AWMOLS1                  ; povoleno
;         or        byte ptr ds:[LZMnVBlk+3],bit1 ; nepovoleno

; ------ p©°znak stavovÇho ©†dku

AWMOLS1: xor       dx,dx
         mov       al,es:[AWinPrm2]         ; parametry
         test      al,bit4                  ; je stavovò ©†dek ?
         jnz       AWMOLS2                  ; nen° stavovò ©†dek
         or        dl,bit5                  ; p©°znak stavovÇho ©†dku

; ------ p©°znak zobrazen° atributñ

AWMOLS2: test      al,bit7                  ; zobrazeny atributy ?
         jz        AWMOLS3                  ; nejsou atributy
         or        dl,bit4                  ; p©°znak atributñ

; ------ plnÇ zobrazen° souborñ okna

AWMOLS3: and       al,bit5 + bit6           ; m¢d zobrazen° souborñ
         jnz       AWMOLS4                  ; nen° plnÇ zobrazen°
         or        dl,bit0                  ; p©°znak plnÇho okna
         jmp       short AWMOLS7

; ------ zkr†cenÇ zobrazen° souborñ okna

AWMOLS4: cmp       al,1*bit5                ; je zkr†cenÇ zobrazen° ?
         jne       AWMOLS5                  ; nen° zkr†cenÇ zobrazen°
         or        dl,bit1                  ; p©°znak zkr†cenÇho okna
         jmp       short AWMOLS7

; ------ komentovanÇ zobrazen° souborñ okna

AWMOLS5: cmp       al,2*bit5                ; je komentovanÇ zobrazen° ?
         jne       AWMOLS6                  ; nen° komentovanÇ zobrazen°
         or        dl,bit2                  ; p©°znak komentovanÇho zobrazen°
         jmp       short AWMOLS7

; ------ zobrazen° s dlouhòmi jmÇny

AWMOLS6: or        dl,bit3                  ; p©°znak dlouhòch jmen
AWMOLS7: call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ

; ------ n†vrat registrñ

         pop       es
         pop       dx
         pop       ax
         ret

AWMOLS   ENDP

; -----------------------------------------------------------------------------
;        nastaven° p©°znaku zobrazen° stavovÇho ©†dku
; -----------------------------------------------------------------------------

AWMOL2S  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         xor       byte ptr es:[AWinPrm2],bit4 ; zmàna p©°znaku stav. ©†dku
         jmp       short AWMOL2P2

AWMOL2S  ENDP

; -----------------------------------------------------------------------------
;        nastaven° p©°znaku zobrazen° atributñ
; -----------------------------------------------------------------------------

AWMOL2A  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         xor       byte ptr es:[AWinPrm2],bit7 ; zmàna p©°znaku atributñ
         jmp       short AWMOL2P2

AWMOL2A  ENDP

; -----------------------------------------------------------------------------
;        nastaven° plnÇho zobrazen° okna
; -----------------------------------------------------------------------------

AWMOL2P  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         and       byte ptr es:[AWinPrm2],not bit5 + bit6 ; plnÇ zobrazen°

; ------ zmàna nastaven° oken bez ukonáen° menu

AWMOL2P2:push      ax
         push      si

         mov       al,es:[AWinPrm2]         ; novÇ parametry
         mov       si,offset ParamLC        ; parametry levÇho okna
         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
         jnz       AWMOL2P3                 ; je levÇ okno
         mov       si,offset ParamRC        ; parametry pravÇho okna
AWMOL2P3:mov       ds:[si],al               ; £schova parametrñ

         pop       si
         pop       ax

         cmp       bl," "                   ; byla operace s mezerou ?
         jne       AWMOL2P6                 ; nebyla mezera
         call      AWMOLS                   ; p©°prava p©ep°naáñ menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         ret                                ; n†vrat do menu

; ------ zmàna nastaven° oken s ukonáen°m menu

AWMOL2P6:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy

AWMOL2P  ENDP

; -----------------------------------------------------------------------------
;        nastaven° zkr†cenÇho zobrazen° okna
; -----------------------------------------------------------------------------

AWMOL2Z  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         and       byte ptr es:[AWinPrm2],not bit5+bit6
         or        byte ptr es:[AWinPrm2],1*bit5 ; zkr†cenÇ zobrazen°
         jmp       short AWMOL2P2

AWMOL2Z  ENDP

; -----------------------------------------------------------------------------
;        nastaven° komentovanÇho zobrazen° okna
; -----------------------------------------------------------------------------

AWMOL2K  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         and       byte ptr es:[AWinPrm2],not bit5+bit6
         or        byte ptr es:[AWinPrm2],2*bit5 ; komentovanÇ zobrazen°
         call      far ptr LoadFInf         ; naáten° informaán°ho souboru
         call      far ptr InitFKom         ; inicializace koment†©ñ
         jmp       short AWMOL2P2

AWMOL2K  ENDP

; -----------------------------------------------------------------------------
;        nastaven° dlouhÇho zobrazen° okna
; -----------------------------------------------------------------------------

AWMOL2D  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         or        byte ptr es:[AWinPrm2],3*bit5 ; zobrazen° dlouhòch jmen
         jmp       short AWMOL2P2

AWMOL2D  ENDP

; *****************************************************************************
;
;                         volba t©°dàn° okna
;
; *****************************************************************************
;˛
AWMOL3   PROC      FAR

         call      AWMOL3S                  ; p©°prava p©ep°naáñ

; ------ p©°prava pozice k zobrazen° okna

         mov       ax,word ptr ds:[LMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
         jnz       AWMOL31                  ; je levÇ okno
         mov       ax,word ptr ds:[RMnuVert+MnuPoz] ; pravÇ okno
AWMOL31: add       ax,107h                  ; posun okna
         mov       word ptr ds:[si+MnuPoz],ax        ; pozice okna

; ------ obsluha okna

         jmp       far ptr VertMenu         ; obsluha vertik†ln°ho menu

AWMOL3   ENDP

; -----------------------------------------------------------------------------
;        p©°prava p©ep°naáñ menu volby t©°dàn° okna
; -----------------------------------------------------------------------------

AWMOL3S  PROC      NEAR

; ------ £schova registrñ

         push      ax
         push      dx
         push      es

; ------ poskytnut° adresy okna

         call      AWMGetW                  ; poskytnut° adresy okna
         xor       dx,dx
         mov       al,es:[AWinPrm2]         ; parametry okna

; ------ sestupnÇ t©°dàn°

         test      al,bit3                  ; je sestupnÇ t©°dàn° ?
         jz        AWMOL3S1                 ; nen° sestupnÇ t©°dàn°
         or        dl,bit5                  ; p©°znak sestupnÇho t©°dàn°

; ------ p©°znak t©°dàn° okna

AWMOL3S1:test      al,bit0                  ; t©°d° se okno ?
         jz        AWMOL3S2                 ; okno se t©°d°
         or        dl,bit4                  ; okno se net©°d°
         jmp       short AWMOL3S6

; ------ typ t©°dàn° okna

AWMOL3S2:mov       ah,bit0                  ; t©°dàn° podle jmÇna
         test      al,bit1 + bit2           ; je t©°dàn° podle jmÇna ?
         jz        AWMOL3S3                 ; je t©°dàn° podle jmÇna
         mov       ah,bit1                  ; t©°dàn° podle p©°pony
         test      al,bit2                  ; je t©°dàn° podle p©°pony ?
         jz        AWMOL3S3                 ; je t©°dàn° podle p©°pony
         mov       ah,bit2                  ; t©°dàn° podle velikosti
         test      al,bit1                  ; je t©°dàn° podle velikosti ?
         jz        AWMOL3S3                 ; je t©°dàn° podle velikosti
         mov       ah,bit3                  ; jinak t©°dàn° podle data a áasu
AWMOL3S3:or        dl,ah                    ; nastaven° p©°znaku t©°dàn°

AWMOL3S6:call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ

; ------ n†vrat registrñ

         pop       es
         pop       dx
         pop       ax
         ret

AWMOL3S  ENDP

; -----------------------------------------------------------------------------
;        t©°dàn° podle jmÇna
; -----------------------------------------------------------------------------

AWMOL3J  PROC      FAR

         mov       cl,0                     ; t©°dàn° podle jmÇna
AWMOL3J1:call      AWMGetW                  ; poskytnut° adresy okna
         and       byte ptr es:[AWinPrm2],not bit0 + bit1 + bit2
         or        es:[AWinPrm2],cl         ; nastaven° p©°znaku t©°dàn°

; ------ novÇ set©°dàn° okna (á°slo okna AX)

AWMOL3J3:;call      far ptr SortDir          ; set©°dàn° okna
         call      far ptr ReSort           ; p©et©°dàn° okna

; ------ zmàna nastaven° oken bez ukonáen° menu

         cmp       bl," "                   ; byla operace s mezerou ?
         jne       AWMOL3J4                 ; nebyla mezera
         call      AWMOL3S                  ; p©°prava p©ep°naáñ menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         ret                                ; n†vrat do menu

; ------ zmàna nastaven° oken s ukonáen°m menu

AWMOL3J4:add       sp,4                     ; zru®en° n†vratovÇ adresy
         call      far ptr ClosMnuA         ; uzav©en° v®ech menu
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy

AWMOL3J  ENDP

; -----------------------------------------------------------------------------
;        t©°dàn° podle p©°pony
; -----------------------------------------------------------------------------

AWMOL3P  PROC      FAR

         mov       cl,bit1                  ; bude t©°dàn° podle p©°pony
         jmp       short AWMOL3J1

AWMOL3P  ENDP

; -----------------------------------------------------------------------------
;        t©°dàn° podle velikosti
; -----------------------------------------------------------------------------

AWMOL3V  PROC      FAR

         mov       cl,bit2                  ; bude t©°dàn° podle velikosti
         jmp       short AWMOL3J1

AWMOL3V  ENDP

; -----------------------------------------------------------------------------
;        t©°dàn° podle data a áasu
; -----------------------------------------------------------------------------

AWMOL3D  PROC      FAR

         mov       cl,bit1 + bit2           ; t©°dàn° podle data a áasu
         jmp       short AWMOL3J1

AWMOL3D  ENDP

; -----------------------------------------------------------------------------
;        net©°dànÇ okno
; -----------------------------------------------------------------------------

AWMOL3N  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         xor       byte ptr es:[AWinPrm2],bit0 ; zmàna p©°znaku net©°dànÇho okna
         jmp       short AWMOL3J3

AWMOL3N  ENDP

; -----------------------------------------------------------------------------
;        sestupnÇ t©°dàn°
; -----------------------------------------------------------------------------

AWMOL3T  PROC      FAR

         call      AWMGetW                  ; poskytnut° adresy okna
         xor       byte ptr es:[AWinPrm2],bit3 ; zmàna p©°znaku sestup. t©°dàn°
         jmp       short AWMOL3J3

AWMOL3T  ENDP

; *****************************************************************************
;
;                         volba filtru okna
;
; *****************************************************************************
;˛
;AWMOL4   PROC      FAR
;
;         call      AWMOL4S                  ; p©°prava p©ep°naáñ
;
;; ------ p©°prava pozice k zobrazen° okna
;
;         mov       ax,word ptr ds:[LMnuVert+MnuPoz] ; pozice p©edchoz°ho okna
;         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
;         jnz       AWMOL41                  ; je levÇ okno
;         mov       ax,word ptr ds:[RMnuVert+MnuPoz] ; pravÇ okno
;AWMOL41: add       ax,107h                  ; posun okna
;         mov       ds:[si+MnuPoz],ax        ; pozice okna
;
;; ------ obsluha okna
;
;         jmp       far ptr VertMenu         ; obsluha vertik†ln°ho menu
;
;AWMOL4   ENDP
;
;; -----------------------------------------------------------------------------
;;        p©°prava p©ep°naáñ menu volby filtru okna
;; -----------------------------------------------------------------------------
;
;AWMOL4S  PROC      NEAR
;
;; ------ £schova registrñ
;
;         push      ax
;         push      dx
;         push      es
;
;; ------ poskytnut° adresy okna
;
;         call      AWMGetW                  ; poskytnut° adresy okna
;         xor       dx,dx
;         mov       al,es:[AWinFilP]         ; parametry filtru
;
;; ------ ARC
;
;         test      al,bit5                  ; je z†kaz ARC ?
;         jnz       AWMOL4S1                 ; je z†kaz ARC
;         or        dl,bit0                  ; p©°znak povolen° ARC
;
;; ------ DIR
;
;AWMOL4S1:test      al,bit4                  ; je z†kaz DIR ?
;         jnz       AWMOL4S2                 ; je z†kaz DIR
;         or        dl,bit1                  ; p©°znak povolen° DIR
;
;; ------ HID
;
;AWMOL4S2:test      al,bit1                  ; je z†kaz HID ?
;         jnz       AWMOL4S3                 ; je z†kaz HID
;         or        dl,bit2                  ; p©°znak povolen° HID
;
;; ------ SYS
;
;AWMOL4S3:test      al,bit2                  ; je z†kaz SYS ?
;         jnz       AWMOL4S4                 ; je z†kaz SYS
;         or        dl,bit3                  ; p©°znak povolen° SYS
;
;; ------ R/O
;
;AWMOL4S4:test      al,bit0                  ; je z†kaz R/O ?
;         jnz       AWMOL4S5                 ; je z†kaz R/O
;         or        dl,bit4                  ; p©°znak povolen° R/O
;
;; ------ povoleny v®echny soubory
;
;AWMOL4S5:test      al,bit6 + bit7           ; jsou povoleny v®echny soubory ?
;         jnz       AWMOL4S6                 ; nejsou povoleny v®echny soubory
;         or        dl,bit5                  ; p©°znak povolen° v®ech souborñ
;         jmp       short AWMOL4S8
;
;; ------ povoleny programy
;
;AWMOL4S6:test      al,bit7                  ; povoleny programy ?
;         jnz       AWMOL4S7                 ; nejsou povoleny programy
;         or        dl,bit6                  ; p©°znak povolen° programñ
;         jmp       short AWMOL4S8
;
;; ------ soubory zad†ny maskou
;
;AWMOL4S7:or        dl,bit7                  ; p©°znak zad†n° souborñ maskou
;AWMOL4S8:call      far ptr SetSwch          ; novÇ nastaven° p©ep°naáñ
;
;; ------ n†vrat registrñ
;
;         pop       es
;         pop       dx
;         pop       ax
;         ret
;
;AWMOL4S  ENDP
;
;; -----------------------------------------------------------------------------
;;        zmàna p©ep°naáe ARC
;; -----------------------------------------------------------------------------
;
;AWMOL4A  PROC      FAR
;
;         mov       cl,ARC
;AWMOL4A1:call      AWMGetW                  ; poskytnut° adresy okna
;         xor       es:[AWinFilP],cl         ; zmàna p©°znaku filtru
;
;; ------ novò vòbàr a set©°dàn° poloëek v oknà (á°slo okna AX)
;
;AWMOL4A3:call      far ptr ReSort           ; p©et©°dàn° okna
;
;; ------ zmàna nastaven° oken bez ukonáen° menu
;
;         cmp       bl," "                   ; byla operace s mezerou ?
;         jne       AWMOL4A4                 ; nebyla mezera
;         call      AWMOL4S                  ; p©°prava p©ep°naáñ menu
;         call      far ptr DispAll          ; novÇ zobrazen° oken
;         ret                                ; n†vrat do menu
;
;; ------ zmàna nastaven° oken s ukonáen°m menu
;
;AWMOL4A4:add       sp,4                     ; zru®en° n†vratovÇ adresy
;         cmp       byte ptr ds:[si+MnuAkt],8 ; je volba masky souborñ ?
;         jne       AWMO4A42
;         jmp       AWMOL4M1                 ; volba masky souborñ
;AWMO4A42:call      far ptr ClosMnuA         ; uzav©en° v®ech menu
;         call      far ptr DispAll          ; novÇ zobrazen° oken
;         jmp       AWinWin0                 ; n†vrat do hlavn° obsluhy
;
;AWMOL4A  ENDP
;
;; -----------------------------------------------------------------------------
;;        zmàna p©ep°naáe DIR
;; -----------------------------------------------------------------------------
;
;AWMOL4D  PROC      FAR
;
;         mov       cl,DIR
;         jmp       short AWMOL4A1
;
;AWMOL4D  ENDP
;
;; -----------------------------------------------------------------------------
;;        zmàna p©ep°naáe HID
;; -----------------------------------------------------------------------------
;
;AWMOL4H  PROC      FAR
;
;         mov       cl,HID
;         jmp       short AWMOL4A1
;
;AWMOL4H  ENDP
;
;; -----------------------------------------------------------------------------
;;        zmàna p©ep°naáe SYS
;; -----------------------------------------------------------------------------
;
;AWMOL4T  PROC      FAR
;
;         mov       cl,SYS
;         jmp       short AWMOL4A1
;
;AWMOL4T  ENDP
;
;; -----------------------------------------------------------------------------
;;        zmàna p©ep°naáe R/O
;; -----------------------------------------------------------------------------
;
;AWMOL4R  PROC      FAR
;
;         mov       cl,RO
;         jmp       short AWMOL4A1
;
;AWMOL4R  ENDP
;
;; -----------------------------------------------------------------------------
;;        volba v®ech souborñ k zobrazen°
;; -----------------------------------------------------------------------------
;
;AWMOL4V  PROC      FAR
;
;         call      AWMGetW                  ; poskytnut° adresy okna
;         and       byte ptr es:[AWinFilP],not bit6 + bit7 ; v®echny soubory
;         jmp       short AWMOL4A3
;
;AWMOL4V  ENDP
;
;; -----------------------------------------------------------------------------
;;        volba programñ k zobrazen°
;; -----------------------------------------------------------------------------
;
;AWMOL4P  PROC      FAR
;
;         call      AWMGetW                  ; poskytnut° adresy okna
;         and       byte ptr es:[AWinFilP],not bit7
;         or        byte ptr es:[AWinFilP],bit6 ; programy
;         jmp       short AWMOL4A3
;
;AWMOL4P  ENDP
;
;; -----------------------------------------------------------------------------
;;        volba masky k zobrazen°
;; -----------------------------------------------------------------------------
;
;AWMOL4M  PROC      FAR
;
;         call      AWMGetW                  ; poskytnut° adresy okna
;         and       byte ptr es:[AWinFilP],not bit6
;         or        byte ptr es:[AWinFilP],bit7 ; maska
;         jmp       short AWMOL4A3
;
;AWMOL4M  ENDP
;
; -----------------------------------------------------------------------------
;        volba masky souborñ
; -----------------------------------------------------------------------------
;˛
; ------ zad†n° masky

AWMOL4M1:call      far ptr ClosMnuA         ; uzav©en° v®ech menu

AWMO4M11:call      AWMGetW                  ; poskytnut° aktivn°ho segmentu okna

         mov       bp,sp
         sub       sp,300                   ; buffer textu p©edvolby

         push      ss
         pop       es
         mov       di,sp

         mov       word ptr ds:[LFMMLMsA],di ; adresa masky
         mov       word ptr ds:[LFMMLMsA+2],es
         push      di
         call      AWMDekM                  ; dek¢dov†n° masky
         mov       cx,di
         pop       di
         sub       cx,di
         mov       ds:[LFMMLMsN],cx         ; dÇlka p©edvolby

         mov       si,offset LFMMnLin       ; menu volby masku
         call      far ptr Lin0Menu         ; volba souborñ

         mov       sp,bp

         jnc       AWMO4M13
AWMO4M12:jmp       AWinWin0                 ; konec

; ------ rozbor zad†n° parametrñ

AWMO4M13:mov       byte ptr ds:[FileTyp],bit3+bit6+bit7 ;+bit5 ; parametry hled†n°
         mov       byte ptr ds:[FileParm],0 ; nulov†n° parametrñ
         call      far ptr RozborZ          ; rozbor zad†n° parametrñ
         jc        AWMO4M12                 ; p©eru®en° operace
         jnz       AWMO4M11                 ; opakov†n° zad†n°

; ------ poskytnut° adresy okna

         call      AWMGetW                  ; poskytnut° adresy okna

; ------ p©enesen° definice do okna

         push      cs
         call      near ptr AWMOMsk

; ------ novò vòbàr poloëek okna

AWMOL40j:;call      far ptr ReSort           ; p©et©°dàn° okna
         call      far ptr ReReadD          ; obnoven° okna
         call      far ptr NulBreak         ; pro dal®° okno ignorov†n° p©eru®en°
         call      far ptr DispAll          ; novÇ zobrazen° oken
         jmp       AWinWin0

; -----------------------------------------------------------------------------
;        p©enesen° definice masky do okna ES (neuchov†v† registry)
; -----------------------------------------------------------------------------

AWMOMsk  PROC      FAR

; ------ p©enesen° definice do okna

         mov       si,offset SrcInit        ; definice
         mov       cx,SIZE AWinFilS         ; dÇlka definice
         mov       di,AWinFilF              ; buffer definice
         cld
         rep       movsb                    ; uloëen° definice filtru

; ------ test, zda je zad†na maska "*.*"

         mov       cx,ds:[FileMskN]         ; dÇlka masek
         mov       si,offset FileMask       ; buffer masek

         and       byte ptr es:[AWinFilP],not bit6+bit7 ; v®echny soubory
         cmp       cl,3
         jne       AWMOMsk2
         cmp       word ptr ds:[si],".*"
         jne       AWMOMsk2
         cmp       byte ptr ds:[si+2],"*"
         jne       AWMOMsk2
         jmp       short AWMOMsk9

; ------ test, zda jsou zad†ny programy

AWMOMsk2:xor       bx,bx                    ; p©°znaky
         or        byte ptr es:[AWinFilP],bit6 ; jsou programy
AWMOMsk3:sub       cl,5                     ; je dal®° maska ?
         jb        AWMOMsk7                 ; nejsou dal®° znaky
         cmp       word ptr ds:[si],".*"    ; zaá†tek masky ?
         jne       AWMOMsk8                 ; neplat°
         inc       si
         inc       si
         cmp       word ptr ds:[si],"OC"
         jne       AWMOMsk4
         cmp       byte ptr ds:[si+2],"M"
         jne       AWMOMsk4
         or        bl,bit0                  ; p©°znak COM
         jmp       short AWMOMsk6

AWMOMsk4:cmp       word ptr ds:[si],"XE"
         jne       AWMOMsk5
         cmp       byte ptr ds:[si+2],"E"
         jne       AWMOMsk5
         or        bl,bit1                  ; p©°znak EXE
         jmp       short AWMOMsk6

AWMOMsk5:cmp       word ptr ds:[si],"AB"
         jne       AWMOMsk8
         cmp       byte ptr ds:[si+2],"T"
         jne       AWMOMsk8
         or        bl,bit2                  ; p©°znak BAT

AWMOMsk6:add       si,4
         jcxz      AWMOMsk7
         loop      AWMOMsk3

AWMOMsk7:cmp       bl,bit0+bit1+bit2        ; jsou programy ?
         je        AWMOMsk9                 ; jsou programy OK
AWMOMsk8:xor       byte ptr es:[AWinFilP],bit6+bit7 ; je obecn† maska

; ------ zji®tàn° dÇlky prvn°ho filtru

AWMOMsk9:mov       cx,ds:[FileMskN]         ; dÇlka masek
         mov       si,offset FileMask       ; buffer masek
         xor       bx,bx                    ; á°taá dÇlky textu
AWMOMskA:inc       si
         inc       bx
         cmp       byte ptr ds:[si]," "
         loopne    AWMOMskA
         cmp       bl,15                    ; maxim†ln° dÇlka textu
         jb        AWMOMskB
         mov       bl,15                    ; omezen° dÇlky poloëky
AWMOMskB:mov       es:[AWinFilM],bl         ; dÇlka prvn° poloëky masky
         ret

AWMOMsk  ENDP

; -----------------------------------------------------------------------------
;        dek¢dov†n° masky okna AX do bufferu ES:DI -> DI konec (ostatn° niá°)
; -----------------------------------------------------------------------------

AWMDekM  PROC      NEAR

         call      far ptr GetSgAdr         ; adresa okna
         jc        AWMDekM9

         push      ax
         push      ds

         mov       al,ds:[ZnakTim]          ; znak oddàlovaáe áasu
         mov       cs:[AWMDekTC],al         ; znak oddàlovaáe áasu
         mov       al,ds:[ZnakDat]          ; znak oddàlovaáe data
         mov       cs:[AWMDekTD],al         ; znak oddàlovaáe data
         mov       al,ds:[FormDat]          ; form†t data
         mov       cs:[AWMDekTF],al         ; form†t data

         mov       ds,dx                    ; DS <- segment okna
         mov       si,AWinFilF.AWinFilt              ; filtr okna
         mov       cx,ds:[AWinFilF.AWinFilN]         ; dÇlka filtru
         cld
         rep       movsb                    ; p©enos filtru

         mov       ax,"/ "
         stosw

         call      AWMDekA                  ; dek¢dov†n° atributñ

         call      AWMDekD                  ; dek¢dov†n° data
         call      AWMDekT                  ; dek¢dov†n° áasu
         call      AWMDekN                  ; dek¢dov†n° velikosti
         call      AWMDekX                  ; dek¢dov†n° textu

         pop       ds
         pop       ax

         inc       di
AWMDekM8:dec       di
         cmp       byte ptr es:[di-1]," "
         je        AWMDekM8
         cmp       byte ptr es:[di-1],"/"
         je        AWMDekM8

AWMDekM9:mov       byte ptr es:[di],0
         ret

AWMDekM  ENDP
;˛
; ------ dek¢dov†n° atributñ

AWMDekA: mov       bx,word ptr ds:[AWinFilF.AWinFAtr]         ; atributy souborñ
         shl       bx,1
         shl       bx,1

         mov       al,"A"
         call      AWMDekA2
         mov       al,"C"
         call      AWMDekA2
         shl       bx,1
         mov       al,"S"
         call      AWMDekA2
         mov       al,"H"
         call      AWMDekA2
         mov       al,"R"

AWMDekA2:shl       bx,1
         jnc       AWMDekA3
         stosb
         test      bh,bit0
         jnz       AWMDekA3
         add       byte ptr es:[di-1],32
AWMDekA3:ret

; ------ dek¢dov†n° áasu

AWMDekT: mov       si,AWinFilF.AWinFT1               ; áas poá†tku

         mov       ax,ds:[si+2]
         or        ax,ds:[si+6]             ; je zad†n áas ?
         jz        AWMDekT9                 ; nen° zad†n áas

         mov       ch,cs:[AWMDekTC]         ; oddàlovaá áasu

         mov       al,"T"                   ; £vodn° znak
         call      AWMDekU                  ; uloëen° £vodn°ho znaku

         call      AWMDekT6                 ; dek¢dov†n° áasu zaá†tku

AWMDekT4:call      AWMDekI                  ; dek¢dov†n° intervalu
         jnc       AWMDekT9                 ; nen° interval

         mov       si,AWinFilF.AWinFT2               ; áas konec

AWMDekT6:cmp       word ptr ds:[si+2],0     ; je poloëka definov†na ?
         je        AWMDekT9                 ; poloëka nen° definov†na

         mov       bx,bit11+bit12+bit13+bit14+bit15 ; maska hodiny
         mov       cl,11                    ; rotace
         call      AWMDekK                  ; dek¢dov†n° hodiny

         mov       bx,bit5+bit6+bit7+bit8+bit9+bit10 ; maska minuty
         mov       cl,5                     ; rotace
         call      AWMDekK                  ; dek¢dov†n° minuty

         test      byte ptr ds:[si+2],bit0+bit1+bit2+bit3+bit4 ; sekunda definov†na ?
         jz        AWMDekT9                 ; sekunda nen° definov†na

         mov       ax,ds:[si]
         and       ax,bit0+bit1+bit2+bit3+bit4
         shl       ax,1
         call      far ptr DekNumB          ; sekunda

AWMDekT9:ret

; ------ dek¢dov†n° data

AWMDekD: mov       si,AWinFilF.AWinFD1               ; datum poá†tku

         mov       ax,ds:[si+2]
         or        ax,ds:[si+6]             ; je zad†no datum ?
         jz        AWMDekD9                 ; nen° zad†no datum

         mov       ch,cs:[AWMDekTD]         ; oddàlovaá data

         mov       al,"D"                   ; £vodn° znak
         call      AWMDekU                  ; uloëen° £vodn°ho znaku

         call      AWMDekD6                 ; dek¢dov†n° data zaá†tku

AWMDekD4:call      AWMDekI                  ; dek¢dov†n° intervalu
         jnc       AWMDekD9                 ; nen° interval

         mov       si,AWinFilF.AWinFD2               ; datum konec

AWMDekD6:cmp       word ptr ds:[si+2],0     ; je poloëka definov†na ?
         je        AWMDekD9                 ; poloëka nen° definov†na

         cmp       byte ptr cs:[AWMDekTF],1 ; je evropskò form†t data ?
         jb        AWMDekD7                 ; form†t USA (MDR)
         je        AWMDkD64                 ; evropskò form†t (DMR)

         call      AWMDekDR                 ; rok
         call      AWMDekDM                 ; màs°c
         call      AWMDekDD                 ; den
         jmp       short AWMDkD82

AWMDkD64:call      AWMDekDD                 ; den
         call      AWMDekDM                 ; màs°c
         jmp       short AWMDekD8           ; rok

AWMDekD7:call      AWMDekDM                 ; màs°c
         call      AWMDekDD                 ; den
AWMDekD8:call      AWMDekDR                 ; rok
AWMDkD82:dec       di                       ; zru®en° posledn°ho oddàlovaáe

AWMDekD9:ret

; ------ dek¢dov†n° dne

AWMDekDD:mov       bx,bit0+bit1+bit2+bit3+bit4 ; maska
         mov       cl,0                     ; rotace
         call      AWMDekK                  ; dek¢dov†n° dne
         ret

; ------ dek¢dov†n° màs°ce

AWMDekDM:mov       bx,bit5+bit6+bit7+bit8   ; maska
         mov       cl,5                     ; rotace
         call      AWMDekK                  ; dek¢dov†n° màs°ce
         ret

; ------ dek¢dov†n° roku

AWMDekDR:test      byte ptr ds:[si+2+1],(bit9+bit10+bit11+bit12+bit13+bit14+bit15)/bit8
         jz        AWMDekK2                 ; rok nen° definov†n

         mov       ax,ds:[si]               ; datum
         mov       cl,9                     ; poáet rotac°
         shr       ax,cl                    ; rotace roku
         add       ax,1980                  ; korekce
         xor       bx,bx                    ; nen° barva ani oddàlovaá
         call      far ptr DekNumW          ; rok
         jmp       short AWMDekK2

; ------ dek¢dov†n° á°sla DS:SI (rotace CL, maska BX, oddàlovaá CH)

AWMDekK: test      ds:[si+2],bx             ; je poloëka definov†na ?
         jz        AWMDekK2                 ; poloëka nen° definov†na

         mov       ax,ds:[si]               ; hodnota poloëky
         and       ax,bx                    ; maskov†n° poloëky
         shr       ax,cl                    ; hodnota poloëky
         call      far ptr DekNumB          ; dek¢dov†n° poloëky

AWMDekK2:mov       al,ch                    ; znak oddàlovaáe
         cld
         stosb                              ; uloëen° oddàlovaáe
         ret

; ------ uloëen° £vodn°ho znaku AL

AWMDekU: push      ax
         cld
         cmp       byte ptr es:[di-1],"/"
         je        AWMDekU1
         mov       al," "
         stosb

AWMDekU1:pop       ax
         stosb
         ret

; ------ test, zda je interval (NC=nen°)

AWMDekI: cld
         mov       ax,ds:[si+2]
         cmp       ax,ds:[si+6]
         jne       AWMDekI2
         mov       ax,ds:[si]
         cmp       ax,ds:[si+4]
         je        AWMDekI9                 ; nen° interval

AWMDekI2:mov       al,"-"
         stosb
         stc
AWMDekI9:ret


AWMDekTC db        ":"                      ; znak oddàlovaáe áasu
AWMDekTD db        "."                      ; znak oddàlovaáe data
AWMDekTF db        1                        ; form†t data

; ------ dek¢dov†n° velikosti

AWMDekN: mov       si,AWinFilF.AWinFSz1              ; minim†ln° velikost
         cmp       word ptr ds:[si],0
         jne       AWMDekN1
         cmp       word ptr ds:[si+2],0
         jne       AWMDekN1
         cmp       word ptr ds:[si+4],-1
         jne       AWMDekN1
         cmp       word ptr ds:[si+6],-1
         je        AWMDekN9

AWMDekN1:mov       al,"N"                   ; £vodn° znak
         call      AWMDekU                  ; uloëen° £vodn°ho znaku

         mov       ax,ds:[si]
         or        ax,ds:[si+2]
         jz        AWMDekN4                 ; nen° minim†ln° velikost

         call      AWMDekN6                 ; dek¢dov†n° minim†ln° velikosti

AWMDekN4:call      AWMDekI                  ; dek¢dov†n° intervalu
         jnc       AWMDekN9                 ; nen° interval

         mov       si,AWinFilF.AWinFSz2              ; maxim†ln° velikost
         cmp       word ptr ds:[si],-1
         jne       AWMDekN6
         cmp       word ptr ds:[si+2],-1
         je        AWMDekN9                 ; nen° maxim†ln° velikost

AWMDekN6:mov       ax,ds:[si]
         mov       dx,ds:[si+2]
         xor       bx,bx                    ; nen° oddàlovaá ani barva
         call      far ptr DekNum           ; dek¢dov†n° á°sla velikosti

AWMDekN9:ret

; ------ dek¢dov†n° textu

AWMDekX: mov       cx,ds:[AWinFilF.AWinFTxN]         ; dÇlka textu
         jcxz      AWMDekX9                 ; nen° text

         cld
         mov       al,'"'
         call      AWMDekU                  ; uloëen° £vodn°ho znaku
         mov       si,AWinFilF.AWinFTxt              ; buffer textu
AWMDekX2:lodsb
         stosb
         cmp       al,'"'
         jne       AWMDekX3
         stosb
AWMDekX3:loop      AWMDekX2

         mov       al,'"'
         stosb

         mov       cl,ds:[AWinFilF.AWinFKod]         ; konverze
         jcxz      AWMDekX9                 ; nen° konverze

         mov       al," "
         stosb

         mov       al,"U"
         shr       cl,1
         jc        AWMDekX4

         mov       al,"I"
         shr       cl,1
         jc        AWMDekX4

         mov       al,"K"
         shr       cl,1
         jc        AWMDekX4

         mov       al,"L"
         shr       cl,1
         jc        AWMDekX4

         mov       al,"O"

AWMDekX4:stosb

AWMDekX9:ret

; -----------------------------------------------------------------------------
;        poskytnut° adresy nastavovanÇho okna
; -----------------------------------------------------------------------------

AWMGetW  PROC      NEAR

         mov       ax,ds:[SegmL]            ; segment levÇho okna
         test      byte ptr ds:[WindPar],bit4 ; je levÇ okno ?
         jnz       AWMGetW1                 ; je levÇ okno
         mov       ax,ds:[SegmR]            ; segment pravÇho okna
AWMGetW1:call      far ptr GetDat           ; poskytnut° adresy okna
         ret

AWMGetW  ENDP

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;                SpoleánÇ procedury pro ovl†d†n° oken
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;˛
; -----------------------------------------------------------------------------
;        zapnut°/vypnut° pravÇho okna
; -----------------------------------------------------------------------------

AWCtF2   PROC      NEAR

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta ?
         jz        AWCtF23                  ; okna jsou vypnuta

; ------ okna jsou zapnuta - zap/vyp pravÇho okna

         xor       byte ptr ds:[ParamR],bit0 ; zmàna p©°znaku zapnut° okna
         jmp       short AWCtF14            ; oprava oken

; ------ obà okna jsou vypnuta - zapnut° pravÇho okna

AWCtF23: or        byte ptr ds:[ParamR],bit0 ; zapnut° pravÇho okna
         and       byte ptr ds:[ParamL],not bit0 ; vypnut° levÇho okna
         or        byte ptr ds:[WindPar],bit1 ; p©°znak zapnut° oken
         jmp       short AWCtF14            ; oprava oken

AWCtF2   ENDP

; -----------------------------------------------------------------------------
;        zapnut°/vypnut° levÇho okna
; -----------------------------------------------------------------------------

AWCtF1   PROC      NEAR

         test      byte ptr ds:[WindPar],bit1 ; jsou okna zapnuta ?
         jz        AWCtF13                  ; okna jsou vypnuta

; ------ okna jsou zapnuta - zap/vyp levÇho okna

         xor       byte ptr ds:[ParamL],bit0 ; zmàna p©°znaku zapnut° okna
         jmp       short AWCtF14            ; oprava oken

; ------ obà okna jsou vypnuta - zapnut° pouze levÇho okna

AWCtF13: or        byte ptr ds:[ParamL],bit0 ; zapnut° levÇho okna
         and       byte ptr ds:[ParamR],not bit0 ; vypnut° pravÇho okna
         or        byte ptr ds:[WindPar],bit1 ; p©°znak zapnut° oken

; ------ pokud obà okna vypnuta - oprava p©°znaku zapnut° oken

AWCtF14: call      far ptr TestAAWn         ; test aktivn°ho okna
         jnc       AWCtF15                  ; je zapnuto
         call      far ptr TestNAWn         ; test neaktivn°ho okna
         jnc       AWCtF15                  ; je zapnuto
         and       byte ptr ds:[WindPar],not bit1 ; p©°znak vypnut° oken
         jmp       short AWCtF19

; ------ jsou-li obà okna zapnuta, v®e je OK

AWCtF15: call      far ptr TestLAWn         ; test levÇho okna
         jc        AWCtF16                  ; zapnuto jen pravÇ okno
         call      far ptr TestRAWn         ; test pravÇho okna
         jnc       AWCtF19                  ; takÇ zapnuto - v®e OK

; ------ je pouze levÇ okno

         test      byte ptr ds:[WindPar],bit0 ; je levÇ okno aktivn° ?
         jnz       AWCtF19                  ; levÇ okno aktivn° - OK
         jmp       short AWCtF17            ; zmàna aktivn°ho okna

; ------ je pouze pravÇ okno

AWCtF16: test      byte ptr ds:[WindPar],bit0 ; je pravÇ okno aktivn° ?
         jz        AWCtF19                  ; pravÇ okno aktivn° - OK

; ------ zmàna aktivn°ho okna

AWCtF17: xor       byte ptr ds:[WindPar],bit0 ; zmàna aktivn°ho okna
         push      ax
         push      si
         mov       ax,ds:[SegmAkt]          ; aktivn° okno
         xchg      ax,ds:[SegmNAkt]         ; z†màna oken
         mov       ds:[SegmAkt],ax          ; novÇ aktivn° okno
         call      far ptr AktADir          ; nastaven° adres†©e
         call      far ptr GetAAWin         ; poskytnut° novÇho aktivn°ho okna
         mov       si,offset AWinDir
         call      far ptr SetDDir          ; nastaven° novÇho adres†©e
         pop       si
         pop       ax
AWCtF19: call      far ptr MainRead         ; naáten° obsahñ oken
         ret

AWCtF1   ENDP

; -----------------------------------------------------------------------------
;        p©epnut° aktivn°ho okna
; -----------------------------------------------------------------------------

AWTb     PROC      NEAR

         push      ax
         push      si

         call      far ptr TestAAWn         ; test zapnut° aktivn°ho okna
         jc        AWTb4                    ; aktivn° okno nen° zapnuto

; ------ je-li zapnuto jen jedno okno, jejich z†màna

         call      far ptr TestNAWn         ; test zapnut° neaktivn°ho okna
         jnc       AWTb2                    ; neaktivn° okno je zapnuto
         call      AWCtrU                   ; z†màna oken
         jmp       short AWTb4

; ------ p©epnut° aktivn°ho okna

AWTb2:   mov       ax,ds:[SegmAkt]          ; aktivn° okno
         xchg      ax,ds:[SegmNAkt]         ; z†màna oken
         mov       ds:[SegmAkt],ax          ; novÇ aktivn° okno
         xor       byte ptr ds:[WindPar],bit0 ; zmàna p©°znaku aktivn°ho okna

; ------ p©enesen° textu aktivn° cesty

         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
         mov       si,offset AWinDir
         call      far ptr GetNAWin         ; neaktivn° okno
         mov       al,es:[si]               ; disk okna
         call      far ptr GetAAWin         ; aktivn° okno
         cmp       al,es:[si]               ; je to jinò disk ?
         je        AWTb3                    ; je to stejnò disk

         mov       al,es:[si]               ; c°lovò disk
         sub       al,"A"                   ; á°slo disku
         call      far ptr SetDisk          ; nastaven° poëadovanÇho disku
         jmp       short AWTb4

AWTb3:   call      far ptr SetDDir          ; nastaven° adres†©e

AWTb4:   pop       si
         pop       ax
         ret

AWTb     ENDP

; -----------------------------------------------------------------------------
;        z†màna oken
; -----------------------------------------------------------------------------

AWCtrU   PROC      NEAR

         push      ax

         call      far ptr TestAAWn         ; je aktivn° okno zapnuto ?
         jc        AWCtrU2                  ; okna nejsou zapnuta

         mov       al,ds:[ParamL]
         xchg      al,ds:[ParamR]
         mov       ds:[ParamL],al

         mov       ax,ds:[SegmL]            ; segment levÇho okna
         xchg      ax,ds:[SegmR]            ; z†màna segmentñ
         mov       ds:[SegmL],ax

         mov       ax,ds:[SegmLAdr]
         xchg      ax,ds:[SegmRAdr]
         mov       ds:[SegmLAdr],ax

;         mov       ax,ds:[SegmLLst]
;         xchg      ax,ds:[SegmRLst]
;         mov       ds:[SegmLLst],ax

;         mov       ax,ds:[SegmLTre]
;         xchg      ax,ds:[SegmRTre]
;         mov       ds:[SegmLTre],ax

         xor       byte ptr ds:[WindPar],bit0 ; zmàna p©°znaku aktivity
                                            ; zde je NC = operace provedena
AWCtrU2: pop       ax
         ret

AWCtrU   ENDP

; -----------------------------------------------------------------------------
;        zap/vyp oken
; -----------------------------------------------------------------------------

AWCtrO   PROC      NEAR

         push      di

         xor       byte ptr ds:[WindPar],bit1 ; zmàna p©°znaku zapnut° oken
         test      byte ptr ds:[WindPar],bit1 ; jsou nyn° okna zapnuta ?
         jz        AWCtrO3                  ; okna jsou vypnuta

         mov       di,offset ParamL
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       AWCtrO2                  ; je aktivn° levÇ okno
         mov       di,offset ParamR
AWCtrO2: or        byte ptr ds:[di],bit0    ; zapnut° okna

AWCtrO3: call      far ptr MainRead         ; naáten° obsahñ oken
         pop       di
         ret

AWCtrO   ENDP

; -----------------------------------------------------------------------------
;        zap/vyp neaktivn°ho okna
; -----------------------------------------------------------------------------

AWCtrL   PROC      NEAR

         push      si
         push      di

         mov       si,offset ParamL         ; parametry levÇho okna
         mov       di,offset ParamR         ; parametry pravÇho okna
         test      byte ptr ds:[WindPar],bit0 ; je aktivn° levÇ okno ?
         jnz       AWCtrL3                  ; je aktivn° levÇ okno
         xchg      si,di                    ; z†màna ukazatelñ

AWCtrL3: call      far ptr TestAAWn         ; je aktivn° okno zapnuto ?
         jnc       AWCtrL4                  ; aktivn° okno je zapnuto

; ------ zapnut° obou oken

         or        byte ptr ds:[WindPar],bit1 ; zapnut° oken
         or        byte ptr ds:[si],bit0    ; zapnut° aktivn°ho okna
         call      far ptr AktADir          ; aktualizace aktivn°ho adres†©e
         call      far ptr TestNAWn         ; je neaktivn° okno zapnuto ?
         jc        AWCtrL6                  ; nen° zapnuto - to je OK

AWCtrL4: xor       byte ptr ds:[di],bit0    ; p©epnut° neaktivn°ho okna

AWCtrL6: call      far ptr MainRead         ; naáten° obsahñ oken
         pop       di
         pop       si
         ret

AWCtrL   ENDP

CodeWin  ENDS

; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;
;
;                                 Data
;
;
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

Data     SEGMENT
;˛
HelpS    SEGMENT   BYTE PUBLIC
VyskTxt  db        69,'Nastavte novou velikost oken a stisknàte Enter (Esc=p©eru®en°)...'
HelpS    ENDS

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - okna
; -----------------------------------------------------------------------------

OMnuVert label     byte

         db        1                        ; typ menu - vertik†ln° menu hlavn°

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        9                        ; poáet platnòch poloëek menu
         dw        11                       ; celkovò poáet poloëek menu

         dw        OMnuVPol                 ; adresa definice poloëek menu
         dw        OMnuVHlp                 ; adresa n†povàd
         dw        Hlp@PodmenuOkna          ; á°slo str†nky velkÇ n†povàdy
         dw        OMnuVBlk                 ; adresa blokovac° tabulky
         dw        OMnuVSwc                 ; adresa tabulky p©ep°naáñ
         dw        OMnuVTit                 ; adresa titulu okna
         dw        OMnuVExe                 ; tabulka obsluh voleb menu
         dw        OMnuVMnu                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        22                       ; poá†teán° pozice
         db        1                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        13                       ; vò®ka

OMnuVPol db        1,17,'LevÇ okno       ',16
         db        1,17,'PravÇ okno      ',16
         db        bit6+bit7,0
         db        1+bit7,12,'Aktivn° levÇ'
         db        1+bit7,5,'DruhÇ'
         db        1+bit7,11,'Nezobrazena'
         db        1,5,'Vò®ka'
         db        1,6,'Z†màna'
         db        bit6+bit7,0
         db        1,8,'Obnoven°'
         db        1,8,'Srovn†n°'

OMnuVBlk db        0,0,0,0,0,0,0,0,0,0
OMnuVSwc db        0,0,0

OMnuVTit db        4,'okno'

HelpS    SEGMENT   BYTE PUBLIC
OMnuVHlp db        46,'Nastaven° levÇho okna - vzhled, t©°dàn°, filtr'
         db        47,'Nastaven° pravÇho okna - vzhled, t©°dàn°, filtr'
         db        49,'Zmàna aktivn°ho okna - p©epnut° (Tab, Ctrl-I)'
         db        31,'Zapnut° druhÇho okna (Ctrl-L)'
         db        58,'Vypnut° zobrazen° obou oken, zobrazen° podkladu (Ctrl-O)'
         db        20,'Nastaven° vò®ky oken'
         db        39,'Z†màna levÇho a pravÇho okna (Ctrl-U)'
         db        52,'Obnoven° obsahu obou oken po vòmànà diskñ (Ctrl-N)'
         db        60,'Srovn†n° obsahu obou oken podle parametrñ souborñ (Alt-F9)'
HelpS    ENDS

OMnuVExe label     dword                    ; tabulka obsluh menu
         dd        AWMMnuO1                 ; levÇ okno
         dd        AWMMnuO2                 ; pravÇ okno
         dd        AWTabM                   ; aktivn°
         dd        AWCtrlLM                 ; druhÇ okno
         dd        AWCtrlOM                 ; nezobrazena
         dd        AWMMnuO6                 ; vò®ka oken
         dd        AWCtrlUM                 ; z†màna
         dd        AWCtrlN                  ; obnoven°
         dd        AWCompWM                 ; srovn†n°

OMnuVMnu label     word                     ; tabulka adres podmenu
         dw        LMnuVert                 ; levÇ okno
         dw        RMnuVert                 ; pravÇ okno
         dw        0                        ; aktivn°
         dw        0                        ; druhÇ okno
         dw        0                        ; nezobrazena
         dw        0                        ; vò®ka oken
         dw        0                        ; z†màna
         dw        0                        ; obnoven°
         dw        0                        ; srovn†n°

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - levÇ okno
; -----------------------------------------------------------------------------

LMnuVert label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        LMnuVPol                 ; adresa definice poloëek
         dw        LMnuVHlp                 ; adresa n†povàd
         dw        Hlp@NastaveniLevehoOkna  ; á°slo str†nky velkÇ n†povàdy
         dw        LMnuVBlk                 ; adresa blokovac° tabulky
         dw        LMnuVSwc                 ; adresa tabulky p©ep°naáñ
         dw        LMnuVTit                 ; adresa titulu okna
         dw        LMnuVExe                 ; tabulka obsluh voleb menu
         dw        LMnuVMnu                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        2                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        10                       ; vò®ka

LMnuVPol db        1+bit7,7,'Vypnuto'
         db        1,17,'Zobrazen°       ',16
         db        1,17,'T©°dàn°         ',16
         db        1,5,'Filtr'
;         db        bit6+bit7,0
;         db        1+bit7,7,'Adres†©'
;         db        1+bit7,5,'Strom'
;         db        6+bit7,6,'seznaM'
;         db        1+bit7,9,'Prohl°ëeá'
         db        bit6+bit7,0
         db        1,7,'Naáten°'
         db        1,4,'Disk'
         db        1,8,'Historie'

LMnuVBlk db        0,0,0,0,0,0,0
LMnuVSwc db        0

LMnuVTit db        4,'levÇ'

HelpS    SEGMENT   BYTE PUBLIC
LMnuVHlp db        41,'Zapnut° a vypnut° levÇho okna (Ctrl-F1)'
         db        56,'Form†t zobrazen° okna - plnÇ, zkr†cenÇ, komentovanÇ, ...'
         db        57,'T©°dàn° souborñ v oknà - podle jmÇna, data, sestupnà, ...'
         db        47,'Filtr souborñ - vòbàr souborñ, kterÇ se zobraz°'
;         db        35,'V oknà zobrazeny soubory v adres†©i'
;         db        44,'V oknà zobrazen strom disku (adres†©e disku)'
;         db        30,'V oknà zobrazen seznam souborñ'
;         db        67,'V protàj®°m (pravÇm) oknà aktivov†n prohl°ëeá souboru nebo adres†©e'
         db        50,'NovÇ naáten° obsahu okna (nap©. po vòmànà diskety)'
         db        42,'Volba novÇho disku v levÇm oknà (Alt-F1)'
         db        46,'N†vrat k adres†©i z d©°vàj®° operace (Alt-\)'
HelpS    ENDS

LMnuVExe label     dword                    ; tabulka obsluh menu
         dd        AWCtMF1                  ; vypnuto
         dd        AWMOL2                   ; zobrazen°
         dd        AWMOL3                   ; t©°dàn°
         dd        AWMOL4M1                 ; filtr
;         dd        AWMOL5                   ; adres†©
;         dd        AWMOL6                   ; strom
;         dd        AWMOL7                   ; seznam
;         dd        AWMOL8                   ; prohl°ëeá
         dd        AWMOL9                   ; naáten°
         dd        AWMOL11                  ; disk
         dd        AWHistW0                 ; historie

LMnuVMnu label     word                     ; tabulka adres podmenu
         dw        0                        ; vypnuto
         dw        LZmnVert                 ; zobrazen°
         dw        LTMnVert                 ; t©°dàn°
         dw        0                        ; filtr
;         dw        0                        ; adres†©
;         dw        0                        ; strom
;         dw        0                        ; seznam
;         dw        0                        ; prohl°ëeá
         dw        0                        ; naáten°
         dw        0                        ; disk
         dw        0                        ; historie

; -----------------------------------------------------------------------------
;        Definice vertik†ln°ho menu - pravÇ okno
; -----------------------------------------------------------------------------

RMnuVert label     byte

         db        2                        ; typ menu - vertik†ln° podmenu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        7                        ; poáet platnòch poloëek menu
         dw        8                        ; celkovò poáet poloëek menu

         dw        RMnuVPol                 ; adresa definice poloëek
         dw        RMnuVHlp                 ; adresa n†povàd
         dw        Hlp@NastaveniPravehoOkna ; á°slo str†nky velkÇ n†povàdy
         dw        RMnuVBlk                 ; adresa blokovac° tabulky
         dw        RMnuVSwc                 ; adresa tabulky p©ep°naáñ
         dw        RMnuVTit                 ; adresa titulu okna
         dw        RMnuVExe                 ; tabulka obsluh voleb menu
         dw        RMnuVMnu                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        29                       ; poá†teán° pozice
         db        2                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        10                       ; vò®ka

RMnuVPol db        1+bit7,7,'Vypnuto'
         db        1,17,'Zobrazen°       ',16
         db        1,17,'T©°dàn°         ',16
         db        1,5,'Filtr'
;         db        bit6+bit7,0
;         db        1+bit7,7,'Adres†©'
;         db        1+bit7,5,'Strom'
;         db        6+bit7,6,'seznaM'
;         db        1+bit7,9,'Prohl°ëeá'
         db        bit6+bit7,0
         db        1,7,'Naáten°'
         db        1,4,'Disk'
         db        1,8,'Historie'

RMnuVBlk db        0,0,0,0,0,0,0
RMnuVSwc db        0

RMnuVTit db        5,'pravÇ'

HelpS    SEGMENT   BYTE PUBLIC
RMnuVHlp db        42,'Zapnut° a vypnut° pravÇho okna (Ctrl-F2)'
         db        56,'Form†t zobrazen° okna - plnÇ, zkr†cenÇ, komentovanÇ, ...'
         db        57,'T©°dàn° souborñ v oknà - podle jmÇna, data, sestupnà, ...'
         db        47,'Filtr souborñ - vòbàr souborñ, kterÇ se zobraz°'
;         db        35,'V oknà zobrazeny soubory v adres†©i'
;         db        44,'V oknà zobrazen strom disku (adres†©e disku)'
;         db        30,'V oknà zobrazen seznam souborñ'
;         db        66,'V protàj®°m (levÇm) oknà aktivov†n prohl°ëeá souboru nebo adres†©e'
         db        50,'NovÇ naáten° obsahu okna (nap©. po vòmànà diskety)'
         db        43,'Volba novÇho disku v pravÇm oknà (Alt-F2)'
         db        46,'N†vrat k adres†©i z d©°vàj®° operace (Alt-\)'
HelpS    ENDS

RMnuVExe label     dword                    ; tabulka obsluh menu
         dd        AWCtMF2                  ; vypnuto
         dd        AWMOL2                   ; zobrazen°
         dd        AWMOL3                   ; t©°dàn°
         dd        AWMOL4M1                 ; filtr
;         dd        AWMOL5                   ; adres†©
;         dd        AWMOL6                   ; strom
;         dd        AWMOL7                   ; seznam
;         dd        AWMOL8                   ; prohl°ëeá
         dd        AWMOR9                   ; naáten°
         dd        AWMOR11                  ; disk
         dd        AWHistW0                 ; historie

RMnuVMnu label     word                     ; tabulka adres podmenu
         dw        0                        ; vypnuto
         dw        LZMnVert                 ; zobrazen°
         dw        LTMnVert                 ; t©°dàn°
         dw        0                        ; filtr
;         dw        0                        ; adres†©
;         dw        0                        ; strom
;         dw        0                        ; seznam
;         dw        0                        ; prohl°ëeá
         dw        0                        ; naáten°
         dw        0                        ; disk
         dw        0                        ; historie

; -----------------------------------------------------------------------------
;        volba form†tu zobrazen° okna
; -----------------------------------------------------------------------------

LZMnVert label     byte                   ;* menu form†tu zobrazen°

         db        2                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        LZMnVPol                 ; adresa definice poloëek
         dw        LZMnVHlp                 ; adresa n†povàd
         dw        Hlp@FormatZobrazeniOkna  ; á°slo str†nky velkÇ n†povàdy
         dw        LZMnVBlk                 ; adresa blokovac° tabulky
         dw        LZMnVSwc                 ; adresa tabulky p©ep°naáñ
         dw        LZMnVTit                 ; adresa titulu okna
         dw        LZMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        3                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        9                        ; vò®ka

LZMnVPol db        1+bit7,4,'PlnÇ'
         db        1+bit7,8,'Zkr†cenÇ'
         db        1+bit7,11,'KomentovanÇ'
         db        1+bit7,12,'Dlouh† jmÇna'
         db        bit6+bit7,0
         db        1+bit7,8,'Atributy'
         db        1+bit7,9,'Informace'

LZMnVBlk db        0,0,0,0,0,0
LZMnVSwc db        0,0,0,0,0,0

LZMnVTit db        9,'zobrazen°'

HelpS    SEGMENT   BYTE PUBLIC
LZMnVHlp db        45,'PlnÇ zobrazen° souborñ v 1 sloupci (Ctrl-K)'
         db        52,'Zkr†cenÇ zobrazen° souborñ ve 3 sloupc°ch (Ctrl-K)'
         db        40,'KomentovanÇ zobrazen° souborñ (Ctrl-K)'
         db        74,'Zobrazen° dlouhòch jmen souborñ (mus° bòt aktivn° WINDOWS 95) (Ctrl-K)'
         db        51,'Nam°sto £daje áasu budou zobrazeny atributy souboru'
         db        53,'Zobraz° se ©†dek s dopl§uj°c°mi informacemi k souboru'
HelpS    ENDS

LZMnVExe label     dword                    ; tabulka obsluh menu
         dd        AWMOL2P                  ; plnÇ
         dd        AWMOL2Z                  ; zkr†cenÇ
         dd        AWMOL2K                  ; komentovanÇ
         dd        AWMOL2D                  ; dlouh† jmÇna
         dd        AWMOL2A                  ; atributy
         dd        AWMOL2S                  ; informace

; -----------------------------------------------------------------------------
;        volba t©°dàn° okna
; -----------------------------------------------------------------------------

LTMnVert label     byte                   ;* menu t©°dàn° okna

         db        2                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        6                        ; poáet platnòch poloëek menu
         dw        7                        ; celkovò poáet poloëek menu

         dw        LTMnVPol                 ; adresa definice poloëek
         dw        LTMnVHlp                 ; adresa n†povàd
         dw        Hlp@TrideniSouboruVOkne  ; á°slo str†nky velkÇ n†povàdy
         dw        LTMnVBlk                 ; adresa blokovac° tabulky
         dw        LTMnVSwc                 ; adresa tabulky p©ep°naáñ
         dw        LTMnVTit                 ; adresa titulu okna
         dw        LTMnVExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        36                       ; poá†teán° pozice
         db        3                        ; poá†teán° ©†dek
         db        20                       ; ®°©ka
         db        9                        ; vò®ka

LTMnVPol db        1+bit7,5,'JmÇno'
         db        1+bit7,7,'P©°pona'
         db        1+bit7,8,'Velikost'
         db        1+bit7,11,'Datum a áas'
         db        1+bit7,9,'Net©°dànÇ'
         db        bit6+bit7,0
         db        1+bit7,8,'Sestupnà'

LTMnVBlk db        0,0,0,0,0,0
LTMnVSwc db        0,0,0,0,0,0

LTMnVTit db        7,'t©°dàn°'

HelpS    SEGMENT   BYTE PUBLIC
LTMnVHlp db        37,'Hlavn°m t©°dic°m kritÇriem bude jmÇno'
         db        45,'Hlavn°m t©°dic°m kritÇriem bude p©°pona jmÇna'
         db        48,'Hlavn°m t©°dic°m kritÇriem bude velikost souboru'
         db        43,'Hlavn°m t©°dic°m kritÇriem bude datum a áas'
         db        65,'Obsah okna bude neset©°dàn (tj. bude tak, jak je uloëen na disku)'
         db        35,'SestupnÇ t©°dàn° poloëek v adres†©i'

         db        39,'Vòbàr souborñ v oknà podle zadanÇ masky'
HelpS    ENDS

LTMnVExe label     dword                    ; tabulka obsluh menu
         dd        AWMOL3J                  ; jmÇno
         dd        AWMOL3P                  ; p©°pona
         dd        AWMOL3V                  ; velikost
         dd        AWMOL3D                  ; datum a áas
         dd        AWMOL3N                  ; net©°dànÇ
         dd        AWMOL3T                  ; sestupnà

;; -----------------------------------------------------------------------------
;;        volba filtru okna
;; -----------------------------------------------------------------------------
;
;LFMnVert label     byte                   ;* menu filtru okna
;
;         db        2                        ; typ menu - vertik†ln° menu
;
;         db        0                        ; hladina k zobrazen° menu
;         dw        1                        ; aktivn° poloëka menu
;         dw        8                        ; poáet platnòch poloëek menu
;         dw        9                        ; celkovò poáet poloëek menu
;
;         dw        LFMnVPol                 ; adresa definice poloëek
;         dw        LFMnVHlp                 ; adresa n†povàd
;         dw        Hlp@FiltrProVyberSouboruVOkne ; á°slo str†nky velkÇ n†povàdy
;         dw        LFMnVBlk                 ; adresa blokovac° tabulky
;         dw        LFMnVSwc                 ; adresa tabulky p©ep°naáñ
;         dw        LFMnVTit                 ; adresa titulu okna
;         dw        LFMnVExe                 ; tabulka obsluh voleb menu
;         dw        LinMenTM                 ; tabulka adres podmenu
;         dd        0                        ; n†vratov† adresa p©i p©eru®en°
;
;         db        36                       ; poá†teán° pozice
;         db        3                        ; poá†teán° ©†dek
;         db        20                       ; ®°©ka
;         db        11                       ; vò®ka
;
;LFMnVPol db        1+bit7,12,'ARC archivn°'
;         db        1+bit7,12,'DIR adres†©e'
;         db        1+bit7,10,'HID skrytÇ'
;         db        1+bit7,13,'SYS systÇmovÇ'
;         db        1+bit7,13,'R/O jen áten°'
;         db        bit6+bit7,0
;         db        1+bit7,7,'V®echny'
;         db        1+bit7,8,'Programy'
;         db        1+bit7,5,'Maska'
;
;LFMnVBlk db        0,0,0,0,0,0,0,0
;LFMnVSwc db        0,0,0,0,0,0,0,0
;
;LFMnVTit db        5,'filtr'
;
;HelpS    SEGMENT   BYTE PUBLIC
;LFMnVHlp db        64,'Povoleno zobrazen° archivn°ch souborñ a adres†©ñ (atribut ARC)'
;         db        43,'Povoleno zobrazen° adres†©ñ (atribut DIR)'
;         db        62,'Povoleno zobrazen° skrytòch souborñ a adres†©ñ (atribut HID)'
;         db        65,'Povoleno zobrazen° systÇmovòch souborñ a adres†©ñ (atribut SYS)'
;         db        69,'Povoleno zobrazen° souborñ a adres†©ñ s ochranou proti z†pisu (R/O)'
;         db        34,'Budou zobrazeny soubory v®ech jmen'
;         db        68,'Budou zobrazeny pouze programy EXE, COM a povelovÇ soubory BAT'
;         db        65,'Budou zobrazeny soubory podle zadanÇ masky (Enter=zad†n° masky)'
;HelpS    ENDS
;
;LFMnVExe label     dword                    ; tabulka obsluh menu
;         dd        AWMOL4A                  ; ARC archivn°
;         dd        AWMOL4D                  ; DIR adres†©
;         dd        AWMOL4H                  ; HID skrytÇ
;         dd        AWMOL4T                  ; SYS systÇmovÇ
;         dd        AWMOL4R                  ; R/O jen áten°
;         dd        AWMOL4V                  ; v®echny
;         dd        AWMOL4P                  ; programy
;         dd        AWMOL4M                  ; maska

; -----------------------------------------------------------------------------
;        Definice ©†dkovÇho menu - volba masky okna
; -----------------------------------------------------------------------------

LFMMnLin label     byte                   ;* menu vytvo©en° adres†©e

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        3                        ; poáet platnòch poloëek menu
         dw        5                        ; celkovò poáet poloëek menu

         dw        LFMMLPol                 ; zaá†tek definice poloëek menu
         dw        LFMMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@FiltrProVyberSouboruVOkne ; á°slo str†nky velkÇ n†povàdy
         dw        LFMMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        LFMMLTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        46                       ; ®°©ka okna
         db        8                        ; vò®ka okna

         dw        250                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        1                        ; celkovò poáet ©†dkñ
         dw        1                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        HistSel                  ; identifik†tor historie
         db        3                        ; poáet p©edvoleb

         dw        17
         dd        LFMMLMsk                 ; maska programñ

         dw        3
         dd        All                      ; maska "*.*"

LFMMLMsN dw        0                        ; dÇlka masky
LFMMLMsA dd        0                        ; adresa masky

LFMMLMsk db        '*.COM *.EXE *.BAT'

; ------ poloëky voleb

LFMMLPol db        bit6,31,'Maska pro vòbàr souborñ v oknà:'
         db        0,0
         db        bit6+bit7,0
         db        1,5,'Vòbàr'
         db        1,6,'N†vrat'

LFMMLBlk db        0,0,0                    ; blokovac° tabulka

LFMMLTit db        5,'maska'

; ------ n†povàda

HelpS    SEGMENT   BYTE PUBLIC
LFMMLHlp db        3,1
         dw        MenuSelH
         db        39,'Vòbàr souborñ v oknà podle zadanÇ masky'
         db        3,1
         dw        MenuHlP1
HelpS    ENDS

; -----------------------------------------------------------------------------
;        volba souborñ k vòbàru porovn†n°m - funkce pro obà okna
; -----------------------------------------------------------------------------

SBPMLine label     byte                    ;* menu oznaáen° souborñ porovn†n°m
         db        2                        ; typ menu - vertik†ln° menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        11                       ; poáet platnòch poloëek menu
         dw        14                       ; celkovò poáet poloëek menu

         dw        SBPMLPol                 ; adresa definián° tabulky poloëek
         dw        SBPMLHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniAdresaru  ; á°slo str†nky velkÇ n†povàdy
         dw        SBPMVBlk                 ; adresa blokovac° tabulky
         dw        SBPMLSwc                 ; adresa tabulky p©ep°naáñ
         dw        SBPMVTit                 ; adresa titulu okna
         dw        SBPMLExe                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        43                       ; poá†teán° pozice
         db        8                        ; poá†teán° ©†dek
         db        29                       ; ®°©ka
         db        16                       ; vò®ka


SBPMLPol db        bit6,25,'Oznaáit soubory v oknech:'
         db        bit6+bit7,0
         db        8,15,'       Aktu†ln°'
         db        8,16,'       Dopl§kovÇ'
         db        8,14,'       Novàj®°'
         db        8,13,'       ShodnÇ'
         db        9,13,'       sTar®°'
         db        8,15,'       Rozd°lnÇ'
         db        8,17,'       Existuj°c°'
         db        8,18,'       VolnÇ m°sto'
         db        bit6+bit7,0
         db        8+bit7,18,'       Podadres†©e'
         db        8+bit7,15,'       OznaáenÇ'
         db        8+bit7,14,'       Uchovat'


SBPMLExe label     dword                    ; tabulka obsluh menu
         dd        AWCompW2                 ; aktu†ln°
         dd        AWCompW2                 ; dopl§kovÇ
         dd        AWCompW2                 ; novàj®°
         dd        AWCompW2                 ; shodnÇ
         dd        AWCompW2                 ; star®°
         dd        AWCompW2                 ; rozd°lnÇ
         dd        AWCompW2                 ; existuj°c°
         dd        AWCompW2                 ; volnÇ m°sto
         dd        AWMSBC22                 ; podadres†©e
         dd        AWMSBC24                 ; oznaáenÇ
         dd        AWMSBC26                 ; uchovat

SBPMLSwc db        0,0,0

HelpS    SEGMENT   BYTE PUBLIC
SBPMLHlp db        51,'Oznaá° se novàj®° soubory a soubory, kterÇ',1
         dw        SBPMLHl2
         db        ' chyb°'

         db        19,1
         dw        SBPMLHl1
         db        ', kterÇ',1
         dw        SBPMLHl2
         db        ' chyb°'

         db        41,1
         dw        SBPMLHl1
         db        ' novàj®° neë soubory stejnÇho jmÇna',1
         dw        SBPMLHl2

         db        24,1
         dw        SBPMLHl1
         db        ' shodnÇ se soubory',1
         dw        SBPMLHl2

         db        40,1
         dw        SBPMLHl1
         db        ' star®° neë soubory stejnÇho jmÇna',1
         dw        SBPMLHl2

         db        40,1
         dw        SBPMLHl1
         db        ' odli®nÇ od souborñ stejnÇho jmÇna',1
         dw        SBPMLHl2

         db        41,1
         dw        SBPMLHl1
         db        ', kterÇ existuj°',1
         dw        SBPMLHl2
         db        ' (tj. shodnÇ jmÇno)'

         db        41,1
         dw        SBPMLHl1
         db        ' velikost° vyhovuj°c° volnÇmu m°stu',1
         dw        SBPMLHl2

         db        3,1
         dw        SBPMVHl3

         db        3,1
         dw        SBPMVHl4

         db        64,'Uchovat oznaáen° poloëek - neodpov°daj°c° poloëky se neodznaáuj°'
HelpS    ENDS

SBPMLHl1 db        17,'Oznaá° se soubory'
SBPMLHl2 db        14,' v druhÇm oknà'

; -----------------------------------------------------------------------------
;        varovnÇ hl†®en° - porovn†vanÇ adres†©e jsou shodnÇ
; -----------------------------------------------------------------------------

ACmpWMnu label     byte
         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka menu
         dw        2                        ; poáet platnòch poloëek menu
         dw        6                        ; celkovò poáet poloëek menu

         dw        ACmpWMnP                 ; zaá†tek definice poloëek menu
         dw        ACmpWMnH                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@PorovnavaniAdresaru  ; á°slo str†nky velkÇ n†povàdy
         dw        ACmpWMnB                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        ACmpWMnT                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        23                       ; poá†teán° pozice okna
         db        7                        ; poá†teán° ©†dek okna
         db        44                       ; ®°©ka okna
         db        9                        ; vò®ka okna

         dw        255                      ; maxim†ln° dÇlka textu ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit3                     ; maska zad†vanòch znakñ
         db        0,'      '               ; zak†zanÇ znaky

         db        0                        ; historie specifikac° souborñ
         db        0                        ; poáet p©edvoleb

ACmpWMnT db        14,'stejnò adres†©'

ACmpWMnP db        bit6,9,0,'VAROVèNã'
         db        bit6,34,'Porovn†v†te adres†© s†m se sebou !'
         db        bit6,0
         db        bit6+bit7,0
         db        1,4,'D†le'
         db        1,8,'P©eru®it'

HelpS    SEGMENT   BYTE PUBLIC
ACmpWMnH db        42,'Pokraáov†n° v operaci porovn†v†n° adres†©ñ'
         db        3,1
         dw        MenuHlP2
HelpS    ENDS

ACmpWMnB db        0,0

; -----------------------------------------------------------------------------
;        t©°dàn° okna
; -----------------------------------------------------------------------------

SBSMLine label     byte                    ;* menu oznaáen° souborñ porovn†n°m

         db        3                        ; typ menu - ©†dkovÇ menu

         db        0                        ; hladina k zobrazen° menu
         dw        1                        ; aktivn° poloëka volby
         dw        7                        ; poáet platnòch poloëek menu
         dw        9                        ; celkovò poáet poloëek menu

         dw        SBSMLPol                 ; adresa definián° tabulky poloëek
         dw        LTMnVHlp                 ; adresa tabulky textñ n†povàdy
         dw        Hlp@TrideniSouboruVOkne  ; á°slo str†nky velkÇ n†povàdy
         dw        SBSMLBlk                 ; adresa blokovac° tabulky
         dw        0                        ; adresa tabulky p©ep°naáñ
         dw        LTMnVTit                 ; adresa titulu okna
         dw        LinMenTE                 ; tabulka obsluh voleb menu
         dw        LinMenTM                 ; tabulka adres podmenu
         dd        0                        ; n†vratov† adresa p©i p©eru®en°

         db        6                        ; poá†teán° pozice
         db        7                        ; poá†teán° ©†dek
         db        76                       ; ®°©ka
         db        7                        ; vò®ka

         dw        255                      ; maxim†ln° dÇlka ©†dku
         dw        0                        ; prvn° zobrazenò ©†dek
         dw        0                        ; aktivn° zobrazenò ©†dek
         dw        0                        ; celkovò poáet ©†dkñ
         dw        0                        ; poáet zobrazenòch ©†dkñ

         db        bit2                     ; maska zad†vanòch znakñ
         db        0,'      '               ; dopl§uj°c° zak†zanÇ znaky

         db        0                        ; identifik†tor historie
         db        0                        ; poáet p©edvoleb

SBSMLPol db        bit6,37,'Zvolte zpñsob t©°dàn° poloëek v oknà:'
         db        bit6+bit7,0
         db        1,5,'JmÇno'
         db        1,7,'P©°pona'
         db        1,8,'Velikost'
         db        1,5,'Datum'
         db        1,2,'Ne'
         db        1,6,'Sest.'
SBSMLPl1 db        '-'
         db        1,5,'Maska'

SBSMLBlk db        0,0,0,0,0,0,0

Data     ENDS
         END
